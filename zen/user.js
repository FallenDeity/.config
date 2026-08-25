// user.js - Zen Browser Clean Reproducible Configuration (Managed by .config)

// 1. Enable User Stylesheets & Hardware Acceleration
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.allow_transparent_browser", true);
user_pref("layout.css.backdrop-filter.enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("extensions.autoDisableScopes", 0);

// 2. Cleaned URL Bar (Acrylic Glassmorphism) Preferences
user_pref("mod.cleanedurlbar.glassopacity", "100%");
user_pref("mod.cleanedurlbar.glassblur", "25px");
user_pref("mod.cleanedurlbar.customdarkcolor", "#2a2c2e");
user_pref("mod.cleanedurlbar.backdropdim", "60%");
user_pref("mod.cleanedurlbar.backdropblur", "25px");
user_pref("mod.cleanedurlbar.baraccent", false);
user_pref("mod.cleanedurlbar.dimurls", true);
user_pref("mod.cleanedurlbar.faviconbg", "subtle");
user_pref("mod.cleanedurlbar.selectaccent", true);
user_pref("mod.cleanedurlbar.selectopacity", "0%");
user_pref("mod.cleanedurlbar.customblur", "25px");
user_pref("mod.cleanedurlbar.customcolor", "hsl(0 0 0)");
user_pref("mod.cleanedurlbar.customlightcolor", "hsl(0 0 90)");
user_pref("mod.cleanedurlbar.customselectcolor", "rgba(80, 80, 250, 0.75)");
user_pref("mod.cleanedurlbar.customselectfontcolor", "rgba(255,255,255,1)");
user_pref("mod.cleanedurlbar.customtransparency", "70%");

// 3. Transparent Zen Preferences
user_pref("mod.sameerasw.zen_bg_blur", "3px");
user_pref("mod.sameerasw.zen_bg_color_enabled", true);
user_pref("mod.sameerasw.zen_bg_img", "url('https://github.com/sameerasw/my-internet/blob/main/wallpapers/zen-coral-01.jpeg?raw=true')");
user_pref("mod.sameerasw.zen_bg_img_enabled", false);
user_pref("mod.sameerasw.zen_bg_img_not_fullscreen", false);
user_pref("mod.sameerasw.zen_bg_opacity", "0.8");
user_pref("mod.sameerasw.zen_compact_sidebar_width", "165px");
user_pref("mod.sameerasw.zen_no_shadow", false);
user_pref("mod.sameerasw.zen_notab_img", "url('https://github.com/sameerasw/my-internet/blob/main/wave-light.png?raw=true')");
user_pref("mod.sameerasw.zen_notab_img_opacity", "1");
user_pref("mod.sameerasw.zen_notab_img_size", "150px");
user_pref("mod.sameerasw.zen_tab_switch_anim", true);
user_pref("mod.sameerasw.zen_trackpad_anim", false);
user_pref("mod.sameerasw.zen_transparency_color", "#00000070");
user_pref("mod.sameerasw.zen_transparent_glance_enabled", true);
user_pref("mod.sameerasw.zen_transparent_sidebar_enabled", true);
user_pref("mod.sameerasw.zen_urlbar_zoom_anim", false);
user_pref("mod.sameerasw_zen_animations", "1");
user_pref("mod.sameerasw_zen_compact_sidebar_type", "0");
user_pref("mod.sameerasw_zen_empty_tab_logo", "0");
user_pref("mod.sameerasw_zen_light_tint", "2");

// 4. SuperPins & Sidebar Preferences
user_pref("mod.superpins.essentials.grid-count", "1");
user_pref("mod.superpins.pins.grid-count", "1");
user_pref("uc.essentials.box-like-corners", false);
user_pref("uc.essentials.gap", "Normal");
user_pref("uc.essentials.transition-speed", "100ms");
user_pref("uc.essentials.width", "Normal");
user_pref("uc.fixcontext.applyzengradient", false);
user_pref("uc.fixcontext.ergonomicsfortabs", true);
user_pref("uc.hidecontext.bookmark", true);
user_pref("uc.hidecontext.copylink", true);
user_pref("uc.hidecontext.printselection", true);
user_pref("uc.hidecontext.reloadtab", true);
user_pref("uc.hidecontext.searchinpriv", true);
user_pref("uc.hidecontext.selectalltabs", true);
user_pref("uc.hidecontext.selectalltext", true);
user_pref("uc.pins.essentials-layout", false);
user_pref("uc.pins.stay-at-top", false);
user_pref("uc.pins.transition-speed", "100ms");
user_pref("uc.tabs.dim-type", "both");
user_pref("uc.tabs.strikethrough-on-pending", false);

// 5. Better Find Bar Preferences
user_pref("theme.better_find_bar.custom_background", "#112233");
user_pref("theme.better_find_bar.hide_find_status", false);
user_pref("theme.better_find_bar.hide_found_matches", false);
user_pref("theme.better_find_bar.hide_highlight", "not_hide");
user_pref("theme.better_find_bar.hide_match_case", "not_hide");
user_pref("theme.better_find_bar.hide_match_diacritics", "not_hide");
user_pref("theme.better_find_bar.hide_whole_words", "not_hide");
user_pref("theme.better_find_bar.horizontal_position", "default");
user_pref("theme.better_find_bar.instant_animations", false);
user_pref("theme.better_find_bar.textbox_width", "800");
user_pref("theme.better_find_bar.transparent_background", false);
user_pref("theme.better_find_bar.vertical_position", "top");
user_pref("theme.nosidebarscrollbar.before125b", false);

// 6. Zen UI & Workspaces
user_pref("zen.keyboard.shortcuts.version", 20);
user_pref("zen.mods.milestone", "1.21.15b");
user_pref("zen.themes.disable-all", false);
user_pref("zen.ui.migration.compact-mode-button-added", true);
user_pref("zen.ui.migration.version", 7);
user_pref("zen.urlbar.behavior", "float");
user_pref("zen.urlbar.suggestions-learner", "{\"zen:global-action-add-to-essentials\":-1,\"zen:global-action-switch-to-dark-mode\":-1,\"zen:extension-{91aa3897-2634-4a8a-9092-279db23a7689}\":-5,\"Browser:Reload\":-1,\"Browser:ReloadSkipCache\":-3,\"Browser:Screenshot\":-1,\"Tools:Addons\":-1}");
user_pref("zen.view.compact.enable-at-startup", false);
user_pref("zen.view.show-newtab-button-top", false);
user_pref("zen.welcome-screen.seen", true);
user_pref("zen.workspaces.indicator-name-center", false);
user_pref("zen.workspaces.show-workspace-indicator", true);
