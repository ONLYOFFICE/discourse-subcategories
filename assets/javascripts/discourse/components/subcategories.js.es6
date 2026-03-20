import Component from "@ember/component";
import { service } from "@ember/service";
import discourseComputed from "discourse-common/utils/decorators";
import { bind } from "discourse-common/utils/decorators";

export default Component.extend({
  router: service(),
  visible: false,

  categories: {
    aisuggestions: { link: "", postCount: 0 },
    document_editor: { link: "", postCount: 0 },
    spreadsheet_editor: { link: "", postCount: 0 },
    presentation_editor: { link: "", postCount: 0 },
    pdf_editor: { link: "", postCount: 0 },
    docspacesuggestions: { link: "", postCount: 0 },
    mobile: { link: "", postCount: 0 },
    integrations: { link: "", postCount: 0 },
    desktop: { link: "", postCount: 0 },
    macros: { link: "", postCount: 0 },
  },

  init() {
    this._super(...arguments);
    this._checkRoute();
    this.router.on("routeDidChange", this._checkRoute);
  },

  willDestroyElement() {
    this._super(...arguments);
    this.router.off("routeDidChange", this._checkRoute);
  },

  initLinks() {   
    Object.values(this.site.get("categoriesList")).forEach((category) => {

      const slug = category.slug.replace("-", "_");

      if (this.categories[slug]) {
          this.categories[slug].link = "/c/suggestions/" + category.slug + "/" + category.id;
          this.categories[slug].postCount = category.post_count;
      }
    });
    return this.categories;
  },

  @bind
  _checkRoute() {
    this.initLinks();
    const url = this.router.currentURL;
    this.set("visible", url === "/c/suggestions/40");
  },
});