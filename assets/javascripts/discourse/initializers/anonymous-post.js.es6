import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";

function initWithApi(api) {
  if (!Discourse.SiteSettings.anonymous_post_enabled) return;

  Composer.serializeOnCreate("is_anonymous_post");

  api.includePostAttributes("is_anonymous_post");

  api.reopenWidget("post", {
    buildClasses(attrs) {
      const classes = this._super(...arguments);

      if (attrs.is_anonymous_post) {
        classes.push("anonymous-post");
      }

      return classes;
    }
  });
}

export default {
  name: "anonymous-post",
  initialize() {
    withPluginApi("0.8", initWithApi);
  }
}
