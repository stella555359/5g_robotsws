*** Variables ***
${alarmtablehistory}   //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div
...                  /ui-webem-panel-split/as-split/div[2]/div/div/alarm-history-home/div/div[2]/ui-webem-alarms-table
...                    /div/p-table/div
${alarmbutton}  xpath=//button[@class="alarm-counter ui-corner-all ui-button-secondary p-button ui-state-default"]
${alarmtableactive}  xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div
...              /ui-webem-panel-split/as-split/div[2]/div/div/alarm-active-home/div/div[2]/ui-webem-alarms-table/div