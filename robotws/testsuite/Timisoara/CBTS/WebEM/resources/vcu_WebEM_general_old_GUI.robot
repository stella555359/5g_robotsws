*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for vCU WebEM TCs with the old GUI.


*** Variables ***
${VCU_OPTIONS_MENU}  //*[@class="side-bar-container"]/div/div[1]/a[10]/i  # Xpath for options menu
${VCU_SITE_PROPERTIES}  //*[@class="side-bar-container"]/div/div[1]/a[2]/i  # Xpath for site properties button
${VCU_DASHBOARD}  //p-button[@title='Dashboard']  # Xpath for dashboard button
${VCU_ALARMS}   //ui-webem-alarm-counter[contains(@title, 'Active alarms')]  # Xpath for active alarms button
