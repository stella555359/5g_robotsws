*** Variables ***
${alarm_button}   //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...               webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]
${alarms_table}  xpath=/html/body/vdu-webem-root/div/div/webem-single-column-layout/webem-page-layout/
...              div/ui-webem-panel-split/as-split/div[2]/div/div/alarm-active-home/div/div[2]
...              /ui-webem-alarms-table/div/p-table/div/div[1]/table/tbody/
...              tr[@class='p-selectable-row ng-star-inserted']


${Lock_radio}       xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div
...  /ui-webem-panel-split/as-split/div[2]/div/div/vdu-dashboard/dashboard-container/div/ngx-gridster/div
...  /ngx-gridster-item[4]/div/div[1]/vdu-dashboard-vdu-operations-widget/ui-webem-rich-panel/ui-webem-panel
...  /div/div[2]/div/div/div[2]/div[2]/vdu-dashboard-lock-radio-button/ui-webem-lock-button/ui-webem-button
...  /p-button/button/span[1]
${CheckBox_RU}      /html/body/p-dynamicdialog/div/div/div[2]/dashboard-rmod-operation-dialog/div[1]/
...                 dashboard-tree-chips-panel/div/div/div/tree-root/tree-viewport/div/div/tree-node-collection/
...                 div/tree-node/div/tree-node-wrapper/div/div/p-checkbox/div/div[2]
${Check_RU_OK}      /html/body/p-dynamicdialog/div/div/div[2]/dashboard-rmod-operation-dialog/div[2]
${ImpactedCells}    //*[@id="undefined"]/button/span[2]
${FaultyCells}      //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split
...                 /as-split/div[2]/div/div/alarm-active-home/div/div[1]/alarm-active-alarms-active-menu/div/div
...                 /ui-webem-overlay-menu-bar/span/div/div/div/div/div/p-checkbox[1]/div/div[2]
${DegradedCells}    //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                 ui-webem-panel-split/as-split/div[2]/div/div/alarm-active-home/div/div[1]/
...                 alarm-active-alarms-active-menu/div/div/ui-webem-overlay-menu-bar/span/div/div/
...                 div/div/div/p-checkbox[2]/div/div[2]

${AffectedCells}    //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...                 div/ui-webem-panel-split/as-split/div[2]/div/div/alarm-active-home/div/div[1]/
...                 alarm-active-alarms-active-menu/div/div/ui-webem-overlay-menu-bar/span/div/div/
...                 div/div/div/p-checkbox[3]/div/div[2]
${Dashboard}        //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                 webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[1]
${RU_Unlock}        xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div
...  /ui-webem-panel-split/as-split/div[2]/div/div/vdu-dashboard/dashboard-container/div/ngx-gridster/div
...  /ngx-gridster-item[4]/div/div[1]/vdu-dashboard-vdu-operations-widget/ui-webem-rich-panel/ui-webem-panel/div
...  /div[2]/div/div/div[2]/div[2]/vdu-dashboard-unlock-radio-button/ui-webem-lock-open-button/ui-webem-button
...  /p-button/button/span[1]
${diagnostic_menu}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...                div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[8]

${check_box}    xpath=/html/body/p-dynamicdialog/div/div/div[2]/ui-webem-session-token-renewal-dialog/form/
...             div[1]/div/div[2]/p-checkbox/label

${alarm}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...       webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/i

${sw}   //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...      webem-page-header/webem-general-status-info/span[1]

${path}  /home/ute/Downloads

${finistime}   //*[@id="snapshot-notifications"]/div/div/span[2]

${dashboard}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...      div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[1]/i

${reset_vDU}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split/as-split/div[2]/div/div
...  /vdu-dashboard/dashboard-container/div/ngx-gridster/div/ngx-gridster-item[4]/div/div[1]/vdu-dashboard-vdu-operations-widget
...  /ui-webem-rich-panel/ui-webem-panel/div/div[2]/div/div/div[1]/div[2]/vdu-dashboard-reset-vdu-button/div/ui-webem-button/p-button/button/span[1]
#${reset_vDU}  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
#...      div/ui-webem-panel-split/as-split/div[2]/div/div/vdu-dashboard/dashboard-container/
#...      div/ngx-gridster/div/ngx-gridster-item[2]/div/div[1]/vdu-dashboard-vdu-operations-widget/
#...      ui-webem-rich-panel/ui-webem-panel/div/div[2]/div/div/div[1]/div[2]/
#...      vdu-dashboard-reset-vdu-button/div/ui-webem-button/p-button/button/span[1]

#  Verify Webem element states
${selectCellinStatusMenu}       //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...         ui-webem-panel-split/as-split/div[2]/div/div/vdu-radio-modules-status/div/status-shared-operations-view/
...         div[2]/status-shared-tile-grid/div/span/ui-webem-rmod/ui-webem-tile-tooltip/div/div/div/div/div[2]/div[1]
${administrativeStateitemCell}  //*[@id="rmod-states-table"]/ui-webem-detail-data-row[3]/div/div[2]
${detailsMenuitem}              xpath=//*[@id="open-detail-panel-button"]/span[1]
${detailsMenuitemClose}         xpath=//*[@id="open-detail-panel-button"]/span[2]
${Status_buton}                 //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/
...        div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[2]
${statusItem}                   //*[@id="/status/radio-modules"]/span

#   Extract RU Type
${TypeRUpath}         //*[@id="rmod-properties-table"]/ui-webem-detail-data-row[3]/div/div[2]
${RMOD_IDpath}        //*[@id="rmod-properties-table"]/ui-webem-detail-data-row[1]/div/div[2]
${RU_module}          ''
${Number_RU_xpath} =  xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split/as-split/div[2]/div
...  /div/vdu-dashboard/dashboard-container/div/ngx-gridster/div/ngx-gridster-item[1]/div/div[1]/dashboard-rmods-status-summary/ui-webem-rich-panel
...  /ui-webem-panel/div/div[2]/div/span/ui-webem-titled-counter/div[1]

#   OAM_pod
${OAM_pod}          curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults --header 'content-type: application/
...  json' --data "{\"faultId\":4298,\"state\":1,\"severity\":1,\"source\":\"MRBTS-0\",\"sourceType\":1,\"extraInfo\":\"57360\"}"
${OAM_pod1}         curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults --header 'content-type: application/
...  json' --data "{\"faultId\":4298,\"state\":1,\"severity\":1,\"source\":\"MRBTS-0\",\"sourceType\":1,\"extraInfo\":
...  \"57360\",\"recoveryOverride\":1}"

${SW_version_xpath} =  xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/webem-page-header
...  /webem-general-status-info/span[1]/span

${CellsStatusMenuXpath}  xpath=//*[@id="/status/vdu-cells"]/span
${FirstCellSelectXpath}  xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/ui-webem-panel-split/as-split/div[2]
...  /div/div/vdu-cells-status/div/status-shared-operations-view/div[2]/status-shared-tile-grid/div/span[1]/ui-webem-vdu-cell-tile
...  /ui-webem-tile-tooltip/div/div/div/div/div[2]/div[1]/div[3]/div[1]
${AvailabilityCellStatusXpath}  xpath=//*[@id="cell-details-states-table"]/ui-webem-detail-data-row[2]/div/div[2]

