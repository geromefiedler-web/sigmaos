// Sigma OS - Firefox-Voreinstellungen (in about:config aenderbar).
// Inaktive Tabs bei RAM-Mangel entladen statt das System auszubremsen.
pref("browser.tabs.unloadOnLowMemory", true);
// Weniger Inhaltsprozesse -> deutlich weniger RAM auf kleinen Systemen.
pref("dom.ipc.processCount", 4);
// Sitzung seltener auf die Platte schreiben (Standard: 15 s).
pref("browser.sessionstore.interval", 60000);
// Hardware-Videodekodierung.
pref("media.ffmpeg.vaapi.enabled", true);
// Keine Telemetrie, keine gesponserten Inhalte.
pref("datareporting.healthreport.uploadEnabled", false);
pref("toolkit.telemetry.enabled", false);
pref("browser.newtabpage.activity-stream.showSponsored", false);
pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
