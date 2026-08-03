import Component from "@ember/component";
import { service } from "@ember/service";
import discourseComputed from "discourse-common/utils/decorators";
import { bind } from "discourse-common/utils/decorators";

export default Component.extend({
  router: service(),
  visible: false,

  topVotedIdeas: [],
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
  async loadTopVotedIdeas() {
    try {
      const response = await fetch(
        "/trending-ideas/top.json"
      );

      if (!response.ok) {
        throw new Error(
          `Could not load top-voted topics: ${response.status}`
        );
      }

      const data = await response.json();

      this.set(
        "topVotedIdeas",
        (data.topics || []).map((topic, index) => ({
          rank: index + 1,
          title: topic.title,
          voteCount: topic.vote_count,
          link: topic.url,
        }))
      );
    } catch (error) {
      console.error("Could not load top-voted topics:", error);
      this.set("topVotedIdeas", []);
    }
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
    const isSuggestionsPage =
      url === "/c/suggestions/40";
    this.set("visible", isSuggestionsPage);
    if (isSuggestionsPage) {
      this.loadTopVotedIdeas();
    }
  },
});