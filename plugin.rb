# name: onlyoffice-discourse-subcategories
# about: Subcategory grid
# version: 0.1
# authors: Ascensio System SIA

enabled_site_setting :onlyoffice_subcategories_enabled

PLUGIN_NAME ||= "onlyoffice-discourse-subcategories".freeze

after_initialize do
    module ::OnlyofficeDiscourseSubcategories
        class Engine < ::Rails::Engine
            engine_name PLUGIN_NAME
            isolate_namespace OnlyofficeDiscourseSubcategories
        end
    end
end