export default {
  setupComponent(args, component) {
    const composer = Discourse.__container__.lookup("controller:composer");

    component.setProperties({ composer });
  },

  actions: {
    anonymousReply() {
      const setVal = (t) => {
        this.composer.model.set("is_anonymous_post", t);
      };

      setVal(1);

      const isSaved = this.composer.save(true);
      if (isSaved) {
        isSaved.catch(_e => {
          setVal(null);
        });
      } else {
        setVal(null);
      }
    }
  }
}
