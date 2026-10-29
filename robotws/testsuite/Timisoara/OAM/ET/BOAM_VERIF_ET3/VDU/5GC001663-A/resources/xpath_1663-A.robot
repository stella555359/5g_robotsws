*** Variables ***

${diagnostic_menu}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...                div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[8]

${check_box}    xpath=/html/body/p-dynamicdialog/div/div/div[2]/ui-webem-session-token-renewal-dialog/form/div[1]/div/div[2]/p-checkbox/label

${alarm}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...       div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/i

${sw}   //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/webem-page-header/webem-general-status-info/span[1]

${path}  /home/ute/Downloads

${finistime}   //*[@id="snapshot-notifications"]/div/div/span[2]

${dashboard}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...      div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[1]/i

${reset_vDU}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...      div/ui-webem-panel-split/as-split/div[2]/div/div/vdu-dashboard/dashboard-container/
...      div/ngx-gridster/div/ngx-gridster-item[2]/div/div[1]/vdu-dashboard-vdu-operations-widget/
...      ui-webem-rich-panel/ui-webem-panel/div/div[2]/div/div/div[1]/div[2]/
...      vdu-dashboard-reset-vdu-button/div/ui-webem-button/p-button/button/span[1]
