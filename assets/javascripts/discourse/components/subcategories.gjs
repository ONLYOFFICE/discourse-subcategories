import Component from "@ember/component";
import { service } from "@ember/service";
import { bind } from "discourse-common/utils/decorators";

export default class Subcategories extends Component {
  @service router;
  @service site;

  visible = false;

  topVotedIdeas = [];
  categories = {
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
  };

  init() {
    super.init(...arguments);
    this._checkRoute();
    this.router.on("routeDidChange", this._checkRoute);
  }

  willDestroyElement() {
    super.willDestroyElement();
    this.router.off("routeDidChange", this._checkRoute);
  }

  async loadTopVotedIdeas() {
    try {
      const response = await fetch("/trending-ideas/top.json");

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
  }

  initLinks() {
    Object.values(this.site.get("categoriesList")).forEach((category) => {
      const slug = category.slug.replace("-", "_");

      if (this.categories[slug]) {
        this.categories[slug].link = "/c/suggestions/" + category.slug + "/" + category.id;
        this.categories[slug].postCount = category.post_count;
      }
    });
    return this.categories;
  }

  @bind
  _checkRoute() {
    this.initLinks();
    const url = this.router.currentURL;
    const isSuggestionsPage = url === "/c/suggestions/40";
    this.set("visible", isSuggestionsPage);
    if (isSuggestionsPage) {
      this.loadTopVotedIdeas();
    }
  }

  <template>
    {{#if this.visible}}
      <div class="subberino">
        <h3>Sections</h3>
        <div class="note_wrapper">
          <div class="note">
            <div>📋 To submit your suggestion in this section of the community:</div>
            <ol>
              <li><a href="https://community.onlyoffice.com/login" target="_blank">Log in</a>
                or <a href="https://community.onlyoffice.com/signup" target="_blank">Sign up</a></li>
              <li>Use <span class="topic_button">new topic</span> button</li>
              <li>Set the title for your suggestion</li>
              <li>Select a category for your suggestion</li>
              <li>Provide a description of your idea</li>
            </ol>
          </div>
          <div class="card">
            <div>🔥 Trending ideas across all sections:</div>
            <ol>
              {{#if this.topVotedIdeas.length}}
                {{#each this.topVotedIdeas as |topic|}}
                  <div class="top-voted-topic">
                    <span>{{topic.rank}}.</span>
                    <a href={{topic.link}} target="_blank">{{topic.title}}</a>
                    <span>- </span>
                    <span id="subcat-votes">{{topic.voteCount}} votes</span>
                  </div>
                {{/each}}
              {{else}}
                <div class="no-top-voted-topics">No voted ideas yet.</div>
              {{/if}}
            </ol>
          </div>
        </div>
        <div class="subcats">
          <a class="sub_ai" href={{this.categories.aisuggestions.link}}>
            <h4>AI</h4>
            <span>{{this.categories.aisuggestions.postCount}}</span>
          </a>
          <a class="sub_document_editor" href={{this.categories.document_editor.link}}>
            <h4>Document Editor</h4>
            <span>{{this.categories.document_editor.postCount}}</span>
          </a>
          <a class="sub_spreadsheet_editor" href={{this.categories.spreadsheet_editor.link}}>
            <h4>Spreadsheet Editor</h4>
            <span>{{this.categories.spreadsheet_editor.postCount}}</span>
          </a>
          <a class="sub_presentation_editor" href={{this.categories.presentation_editor.link}}>
            <h4>Presentation Editor</h4>
            <span>{{this.categories.presentation_editor.postCount}}</span>
          </a>
          <a class="sub_pdf" href={{this.categories.pdf_editor.link}}>
            <h4>PDF Editor</h4>
            <span>{{this.categories.pdf_editor.postCount}}</span>
          </a>
          <a class="sub_docspace" href={{this.categories.docspacesuggestions.link}}>
            <h4>DocSpace</h4>
            <span>{{this.categories.docspacesuggestions.postCount}}</span>
          </a>
          <a class="sub_mobile" href={{this.categories.mobile.link}}>
            <h4>Mobile Apps</h4>
            <span>{{this.categories.mobile.postCount}}</span>
          </a>
          <a class="sub_integrations" href={{this.categories.integrations.link}}>
            <h4>Integrations</h4>
            <span>{{this.categories.integrations.postCount}}</span>
          </a>
          <a class="sub_desktop" href={{this.categories.desktop.link}}>
            <h4>Desktop Editors</h4>
            <span>{{this.categories.desktop.postCount}}</span>
          </a>
          <a class="sub_macros" href={{this.categories.macros.link}}>
            <h4>Macros</h4>
            <span>{{this.categories.macros.postCount}}</span>
          </a>
        </div>
      </div>
    {{/if}}
  </template>
}