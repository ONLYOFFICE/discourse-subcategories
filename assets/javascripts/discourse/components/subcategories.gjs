import Component from "@ember/component";
import { service } from "@ember/service";
import { bind } from "discourse-common/utils/decorators";

export default class Subcategories extends Component {
  @service router;
  @service site;
  @service siteSettings;

  visible = false;
  topVotedIdeas = [];

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

  get renderUrl() {  
    const renderUrl = this.siteSettings.discourse_subcategories_render_address;
    return renderUrl;
  }

  get subcategoryKeys() {
    const configuredKeys = this.siteSettings.discourse_subcategories_subcategory_keys;

    const keys = Array.isArray(configuredKeys)
      ? configuredKeys
      : typeof configuredKeys === "string"
        ? configuredKeys.split("|")
        : [];

    return keys
      .map((key) => key.trim())
      .filter(Boolean);
  }

  get subcategories() {
    const categoryUrl = this.renderUrl.split("/").slice(0, 3).join("/");;
    const categoriesList = this.site.categoriesList;
    if (!categoriesList) {
      return [];
    }

    const bySlug = {};

    Object.values(categoriesList).forEach((subcategory) => {
      const key = subcategory.slug.replace(/-/g, "_");
      bySlug[key] = subcategory;
    });

    return this.subcategoryKeys.map((key) => {
      const normalizedKey = key.replace(/-/g, "_");
      const subcategory = bySlug[normalizedKey];
      if (!subcategory) {
        return null;
      }

      return {
        key: normalizedKey,
        label: subcategory.name,
        cssClass: `subcategory-${normalizedKey}`,
        link: categoryUrl + `/${subcategory.slug}/${subcategory.id}`,
        postCount: subcategory.post_count ?? 0,
      };
    })
    .filter(Boolean);
  }

  @bind
  _checkRoute() {
    const currentURL = this.router.currentURL;
    const baseRenderURL = this.renderUrl;
    const isRenderPage = currentURL === baseRenderURL;
    this.set("visible", isRenderPage);
    if (isRenderPage) {
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
              <li><a href="/login" target="_blank">Log in</a>
                or <a href="/signup" target="_blank">Sign up</a></li>
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
          {{#each this.subcategories as |subcategory|}}
            <a href={{subcategory.link}} class={{subcategory.cssClass}}>
              <h4>{{subcategory.label}}</h4>
              <span>{{subcategory.postCount}}</span>
            </a>
          {{/each}}
        </div>
      </div>
    {{/if}}
  </template>
}