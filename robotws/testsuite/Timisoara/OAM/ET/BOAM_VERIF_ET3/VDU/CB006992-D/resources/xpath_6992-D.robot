*** Settings ***
Documentation
...    Author: Raluca Ciobanu / Adrian Cretu (raluca.ciobanu@nokia.com/adrian.1.cretu@nokia.com)
...    Maintainer: Raluca Ciobanu / Adrian Cretu (raluca.ciobanu@nokia.com/adrian.1.cretu@nokia.com)
...    RF diagnostic and RF statistics diagnostic tests. All cells shoud be up for this test.

Resource    6992-D.robot

*** Variables ***

${WEBEM}            https://10.15.255.154
${SSH}              10.15.255.244
${SSHPASS}         system123
${FHGWSSH}          10.5.50.230
${FHGWSSHPASS}      root

${ADVANCED}         xpath=//*[@id="details-button"]
${SAFE_PROCEED}     xpath=//*[@id="proceed-link"]
${CLOSE}            xpath=//*[contains(text(),"Close")]
${RADIO_STATUS}     xpath=//*[contains(text(),"Radio Modules Status")]
${CELL_STATUS}      xpath=//*[contains(text(),"Cells Status")]
${LOGOUT}           xpath=//*[contains(text(),"Nemuadmin")]
${SIGNOUT}          xpath=//*[contains(text(),"Sign out")]

${STATUS}           xpath=//html/body/vdu-webem-root/div/div/webem-single-column-layout/webem-page-layout/div/
...                 webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[2]

${RMOD_COUNT}       xpath=//div[@class="rmod-id"]
${NRCELL_COUNT}     xpath=//span[@class="vdu-cell-id"]
${VIEW}             xpath=//div[@class="tiles-view-container ng-star-inserted"]

${Sidebar}          xpath=//ui-webem-button[@class="side-bar-expand-button"]

${Stetoscope}       xpath=//i[@class="side-bar-icon mdi-16px mdi mdi-stethoscope ng-star-inserted"]
${RFDiagDropdown}   xpath=//div[@role="button"]
${RFStatDropdown}   xpath=/html/body/vdu-webem-root/div/div/webem-single-column-layout/webem-page-layout/div/
...                 ui-webem-panel-split/as-split/div[2]/div/div/rf-diagnostic-test-wrap/div/blocks-rf-diagnostic-test/
...                 p-tabview/div/div[2]/p-tabpanel[1]/div/blocks-test-setup/div/div/blocks-start-test/cem-block-panel/
...                 div/div/ot-field[2]/div/div/p-dropdown/div/div[2]
#xpath=//div[@class="cem-block-panel"]/div/div/ot-field[2]/div/div/p-dropdown/div/div[2]
${ParameterSearch}  xpath=//*[@id="parameter-search-input"]/div/input
#se pune la final /div/input ca sa stie pe care din locator trebuie sa mearga,
#asta in cazul in care sunt mai multe locate-uri cu acelasi nume sau ID-ul e sub alt obiect
${SearchButton}     xpath=//i[@class="mdi mdi-magnify"]
${path}             C:\\Users\\cretu\\Downloads\\
${ResultsTable}     xpath=//tbody[@class="p-element p-datatable-tbody"]

${M2MgetToken}      curl -k -X POST ${WEBEM}:443/api/licensed/sec/v1/login -H "Accept: application/json" -H
...                 "Content-Type: application/json" -H "Authorization: Basic TmVtdWFkbWluOk5va2lhQDEyMw=="

${HighTempThreshold}     xpath=//div[@class="formgrid grid"]/div[5]/cem-form-input/div/ot-field/div/div/div[1]/div/input
${FlagDropdown}          xpath=//tbody[@class="p-element p-treetable-tbody"]/tr/td[4]/div/span/
...                      configuration-shared-input/div/span[1]/p-dropdown/div/div[2]
${DeltaPlanOK}           xpath=//ui-webem-button[@id="edit-plan-create-button"]