# frozen_string_literal: true

# name: discourse-anonymous-post
# version: 0.1.0
# authors: github.com/fokx
# url: https://github.com/fokx/discourse-anonymous-post

%i[common desktop mobile].each do |layout|
  register_asset "stylesheets/anonymous-post/#{layout}.scss", layout
end

enabled_site_setting :anonymous_post_enabled

after_initialize do
  require_dependency 'category'
  require_dependency 'guardian'
  require_dependency 'site_setting'
  require_dependency 'user'
  require_dependency 'anonymous_shadow_creator'
  require_dependency 'new_post_result'
  require_dependency 'post_creator'

  register_svg_icon 'ghost'
  add_permitted_post_create_param(:is_anonymous_post)
  register_post_custom_field_type('is_anonymous_post', :integer)

  add_to_serializer(:post, :is_anonymous_post) do
    object.custom_fields['is_anonymous_post'].to_i
  end

  on(:post_created) do |post, opts|
    srt = opts[:is_anonymous_post].to_i

    if srt.positive?
      post.custom_fields['is_anonymous_post'] = srt
      post.save_custom_fields(true)
      post.publish_change_to_clients!(:revised)
      return if post.blank?
      topic_id = post.topic.id
      raw = post.raw
      post.destroy
      post.publish_change_to_clients! :deleted
      return if post.deleted_at.present?
      anonymous_post_user = User.find_by(username: SiteSetting.anonymous_post_user)
      unless anonymous_post_user
        return
      end
      PostCreator.create!(
        anonymous_post_user,
        topic_id: topic_id,
        raw: raw
      )

    end
  end

end
