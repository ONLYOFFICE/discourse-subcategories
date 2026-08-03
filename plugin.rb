# name: discourse-subcategories
# about: Subcategory grid
# version: 0.2.0
# authors: Ascensio System SIA

enabled_site_setting :onlyoffice_subcategories_enabled

PLUGIN_NAME ||= "discourse-subcategories".freeze

after_initialize do
  require File.expand_path(
    "app/controllers/discourse_subcategories/top_controller.rb",
    __dir__
  )

  Discourse::Application.routes.append do
    get "/trending-ideas/top",
        to: "discourse_subcategories/top#index",
        defaults: { format: :json }
  end
end