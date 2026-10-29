*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for vCU WebEM TCs with the new GUI.


*** Variables ***
${VCU_OPTIONS_MENU}  //*[contains(@aria-label, "Options menu")]/span  # Xpath for options menu
${VCU_SITE_PROPERTIES}  //*[contains(@aria-label, "Site Properties")]/i  # Xpath for site properties button
${VCU_DASHBOARD}  //*[contains(@aria-label, "Dashboard")]/i  # Xpath for dashboard button
${VCU_ALARMS}  //*[@id="laf-component"]/otx-product-bar/div/div/div[3]/a[5]/i  # Xpath for active alarms button
