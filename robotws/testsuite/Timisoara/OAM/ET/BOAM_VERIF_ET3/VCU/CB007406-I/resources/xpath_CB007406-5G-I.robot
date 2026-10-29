*** Variables ***
${status}               //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[2]

${VNFCStatus}           //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  ui-webem-panel-split/as-split/div[2]/div/div/cu-dashboard/dashboard-container/div/ngx-gridster/div/
...  ngx-gridster-item[10]/div/div[1]/dashboard-vnfc-status/ui-webem-rich-panel/ui-webem-panel/div/div[2]/div/
...  dashboard-vm-summary-table/div/p-table/div/div[1]

${alarmWidget}          //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  webem-page-header/div/webem-quick-menu/ui-webem-routed-menu/ui-webem-alarm-counter


${table}     //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split/
...  as-split/div[2]/div/div/vm-status/div/vm-status-infrastructure-status/infrastructure-status-table-view/
...  ui-webem-table-view/p-table/div/div[1]/div/cdk-virtual-scroll-viewport/div[1]/table

${alarms}               //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  webem-page-header/div/webem-quick-menu/ui-webem-routed-menu/ui-webem-alarm-counter/button

#${historicalAlarms}     //*[@id="/alarm/historical"]/span

${historicalAlarms}  xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/i

${activeAlarms}         //*[@id="/alarm/active"]/span

${majorAlarm}           //*[@id="filter-major"]/button/ui-webem-alarm-severity-icon/i

${userSettings}         //*[@id="user-settings"]/button/span[2]

${signOut}              //*[contains(text(),'Sign out')]
