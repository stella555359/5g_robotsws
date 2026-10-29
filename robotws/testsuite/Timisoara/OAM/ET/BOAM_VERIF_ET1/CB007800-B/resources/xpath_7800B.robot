*** Variables ***
${Configuration_button}     //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...                         div/webem-page-navigation-menu/
...                         ui-webem-side-bar-menu/div/div/div[1]/a[5]/i

${ConfigPlans_list}         //*[@id="configuration-plans-dropdown"]/div/div[2]/span

${Alarms_button}            //*[@id="webem-root"]/div/div/webem-single-column-layout-with-actions-bar/webem-page-layout
...                        /div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/1

${Diagnostic_button}        //*[@id="webem-root"]/div/div/webem-single-column-layout-with-actions-bar/
...                         webem-page-layout/div/webem-page-navigation-menu/
...                         ui-webem-side-bar-menu/div/div/div[1]/a[8]/i

${SourceAddr_list}          //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                         ui-webem-panel-split/as-split/div[2]/div/
...                         div/diagnostic-ip-connectivity/div/form/p-dropdown[1]/div/div[2]/span

${Scope_list}               //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...                         div/ui-webem-panel-split/as-split/div[2]/div/
...                         div/diagnostic-ip-connectivity/div/form/p-dropdown[2]/div/div[2]/span

${success_message}          div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split/as-split/
...                         div[2]/div/div/diagnostic-ip-connectivity/div/form/div[8]/ui-webem-ip-connectivity-table/
...                         p-table/div/div/table/tbody/tr/td[3]

${alarms_table}             //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...                         div/ui-webem-panel-split/as-split/div[2]/div/
...                         div/alarm-active-home/div/div[2]/ui-webem-alarms-table/div/p-table/div/
...                         div[1]/table/tbody/tr[@class='p-selectable-row ng-star-inserted']
