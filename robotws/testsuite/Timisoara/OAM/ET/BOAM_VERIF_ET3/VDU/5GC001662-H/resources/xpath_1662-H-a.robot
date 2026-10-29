*** Variables ***
${alarmsWidget}=     xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                  ui-webem-panel-split/as-split/div[2]/div/div/vdu-dashboard/dashboard-container/div/
...                  ngx-gridster/div/ngx-gridster-item[1]/div/div[1]/dashboard-alarms/ui-webem-rich-panel/
...                  ui-webem-panel/div/div[2]/div/ui-webem-alarms-dashboard-panel/ui-webem-dashboard-alarms-table/div

${DashboardTab}=     xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...                  div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[1]

${AlarmTab}=        xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                 webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]

@{AlarmList}=         7108  4298
