*** Variables ***
${reset_vCU}    //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split/
...             as-split/div[2]/div/div/cu-dashboard/dashboard-container/div/ngx-gridster/div/ngx-gridster-item[8]/div/
...             div[1]/dashboard-operations/ui-webem-rich-panel/ui-webem-panel/div/div[2]/div/
...             ui-webem-operations-control-panel/div/div[1]/div[1]/div[2]/ui-webem-reset-button/div/ui-webem-button/
...             p-button/button/span[1]

${confirm_dialog}   //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split/
...                 as-split/div[2]/div/div/cu-dashboard/dashboard-container/p-confirmdialog/div/div/div[3]/button[2]

${alarms_vCU}   //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...             webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/i
