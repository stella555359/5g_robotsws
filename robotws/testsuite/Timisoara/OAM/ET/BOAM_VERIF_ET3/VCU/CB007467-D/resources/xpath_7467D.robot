*** Variables ***
${Status_buton}    //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[2]

${PODS_Table}      //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  ui-webem-panel-split/as-split/div[2]/div/div/vm-status/div/vm-status-infrastructure-status/
...  infrastructure-status-table-view/ui-webem-table-view/p-table/div/div[1]/div

${Details_button}   //*[@id="open-detail-panel-button"]

${details_panel_pod_xpath}   //*[@id="pod-properties-table"]/ui-webem-detail-data-row[1]/div/div[2]

${details_id}        //*[@id="pod-properties-table"]/ui-webem-detail-data-row[2]/div/div[2]

${details_availability_status}  //*[@id="pod-properties-table"]/ui-webem-detail-data-row[3]/div/div[2]

${details_operational_state}  //*[@id="pod-properties-table"]/ui-webem-detail-data-row[4]/div/div[2]

${alarm_active}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...              div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/i

${pod-ip-addresses-table}  //*[@id="pod-ip-addresses-table"]/ui-webem-detail-data-row[@class='ng-star-inserted']
