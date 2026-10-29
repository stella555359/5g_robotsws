*** Settings ***
Documentation
    ...  This test case is created to verify ALD SW package in online and offline mode.
    ...  Get info about all alds from site view.
    ...  Open antenna line devices software.
    ...  Verify the table headers and buttons to exists on page.
    ...  Verify info for all alds in antenna line devices software.
    ...  Edit and update ALD Build Descriptor in HW info with SN.
    ...  Save to local drive in HW info with SN.
    ...  Edit and update ALD Build Descriptor in HW info without SN.
    ...  Save to local drive in HW info without SN.
    ...  Save Ims, download application and logout from online mode.
    ...  Open Offline Mode and load ims.
    ...  Get info about all alds from site view.
    ...  Open antenna line devices software.
    ...  Verify the table headers and buttons to exists on page.
    ...  Verify info for all alds in antenna line devices software.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${ALD_SW_BIN}  #Mandatory! Path to ALD SW! Must be a bin file. Eg. /media/BuildShareTimi01/SBTS/Trunk/ALD/RET/ALD_SW/Andrew/atm300fw_22.bin
${ALD_SW_ZIP}  #Mandatory! Path to ALD SW! Must be a zip file. Eg. /media/BuildShareTimi01/SBTS/Trunk/ALD/RET/ALD_SW/Andrew/Andrew.zip


*** Keywords ***
TC__WebEM__ALD_SW_package_in_online_and_offline_mode
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28459
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28459 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS25  FEATURE-CB012840

    Step1: Open Antenna Line Devices Software And Verify The Table In Online Mode
    Step2: Edit And Update ALD Build Descriptor In HW Info With SN
    Step3: Save To Local Drive In HW Info With SN
    Step4: Edit And Update ALD Build Descriptor In HW Info Without SN
    Step5: Save To Local Drive In HW Info Without SN
    Step6: Download Application And Logout From Online Mode
    Step7: Open Offline Mode And Load Ims
    Step8: Open Antenna Line Devices Software And Verify The Table In Offline Mode


Step1: Open Antenna Line Devices Software And Verify The Table In Online Mode
    Log  Step1: Open Antenna Line Devices Software And Verify The Table In Online Mode  console=true
    ${info_from_all_alds_list}  Get Info About All Alds From Site View
    Open Antenna Line Devices Software
    Verify The Table Headers And Buttons To Exists On Page
    Verify Info For All Alds In Antenna Line Devices Software  ${info_from_all_alds_list}


Step2: Edit And Update ALD Build Descriptor In HW Info With SN
    Log  Step2: Edit And Update ALD Build Descriptor In HW Info With SN  console=true
    Verify If Table Can Be Edited In HW Info With/Without SN  With
    Log  \nUpload ALD SW for each ALD  console=true
    ${number_of_rows}  SeleniumLibrary.Get Element Count  xpath=//table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${file_input}  Catenate  SEPARATOR=  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[2]/div/ot-upload
        ...  /div/div/p-fileupload/div/div[1]/span/input
        Choose File  ${file_input}  ${ALD_SW_BIN}
        Sleep  5s  Time for file to be uploaded!
        Log  SW was uploaded for row ${row}!  console=true
    END


Step${index}: Save To Local Drive In HW Info ${specific_menu} SN
    Log  Step${index}: Save To Local Drive In HW Info ${specific_menu} SN  console=true
    Element Should Be Enabled  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Save SW Package')]
    Log  Button 'Save SW Package' is enabled!  console=true
    Click Element  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Save SW Package')]
    Sleep  60  Time for ald sw to be saved!
    Move File  /home/ute/Downloads/ALD_SW_*.zip  ${BTS_FILES}/ALD_SW_${specific_menu}.zip
    Log  ALD SW was saved in location: ${BTS_FILES}/ALD_SW_${specific_menu}.zip  console=true


Step4: Edit And Update ALD Build Descriptor In HW Info Without SN
    Log  Step4: Edit And Update ALD Build Descriptor In HW Info Without SN  console=true
    Click Element  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'HW Info without SN')]
    Sleep  5s  Time for menu to be opened!
    Verify If Table Can Be Edited In HW Info With/Without SN  Without
    Choose File  //*[@id="Import Existing File..."]/div/div/p-fileupload/div/div[1]/span/input  ${ALD_SW_ZIP}
    Sleep  5s  Time for file to be uploaded!
    Log  SW package was uploaded via 'Import Existing File...' button!  console=true


Step6: Download Application And Logout From Online Mode
    Log  Step6: Download Application And Logout From Online Mode  console=true
    Collect Infomodel Log From Current Session  target_file_name=${BTS_FILES}/test_ims2/InfoModel.ims2  timeout=300  leave_disconnect_logs=True
    Download Application
    Logout From SBTS
    Close Browser


Step7: Open Offline Mode And Load Ims
    Log  Step7: Open Offline Mode And Load Ims  console=true
    Open WebEM In Offline Mode
    Choose File  //ot-upload[@class="p-element p-button-icon-only p-button-secondary ng-star-inserted"]//input  ${BTS_FILES}/test_ims2/InfoModel.ims2
    Sleep  60s  Time for ims2 to be uploaded!


Step8: Open Antenna Line Devices Software And Verify The Table In Offline Mode
    Log  Step8: Open Antenna Line Devices Software And Verify The Table In Offline Mode  console=true
    ${info_from_all_alds_list}  Get Info About All Alds From Site View
    Open Antenna Line Devices Software
    Verify The Table Headers And Buttons To Exists On Page
    Verify Info For All Alds In Antenna Line Devices Software  ${info_from_all_alds_list}


Verify The Table Headers And Buttons To Exists On Page
    Log  \nVerify The Table Headers And Buttons To Exists On Page  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element text-center ot-text-ellipsis') and contains(text(), 'Status')]
    ...  Status is not visible in Antenna Line Devices Software![NOK]
    Log  Status is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'SW file')]
    ...  SW file is not visible in Antenna Line Devices Software![NOK]
    Log  SW file is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'Vendor')]
    ...  Vendor is not visible in Antenna Line Devices Software![NOK]
    Log  Vendor is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@psortablecolumn, 'productCode')]
    ...  Product code is not visible in Antenna Line Devices Software![NOK]
    Log  Product code is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'Serial number')]
    ...  Serial number is not visible in Antenna Line Devices Software![NOK]
    Log  Serial number is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'HW version')]
    ...  HW version is not visible in Antenna Line Devices Software![NOK]
    Log  HW version is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'Target SW version')]
    ...  Target SW version is not visible in Antenna Line Devices Software![NOK]
    Log  Target SW version is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'SW update options')]
    ...  SW update options is not visible in Antenna Line Devices Software![NOK]
    Log  SW update options is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //th[contains(@class, 'p-element text-center ot-text-ellipsis') and contains(text(), 'Actions')]
    ...  Actions is not visible in Antenna Line Devices Software![NOK]
    Log  Actions is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'HW Info with SN')]
    ...  HW Info with SN button is not visible in Antenna Line Devices Software![NOK]
    Log  HW Info with SN button is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'HW Info without SN')]
    ...  HW Info without SN button is not visible in Antenna Line Devices Software![NOK]
    Log  HW Info without SN button is visible in Antenna Line Devices Software![OK]  console=true
    Page Should Contain Element  //*[contains(@class, 'p-button-label') and contains(text(), 'Import Existing File...')]
    ...  Import Existing File button is not visible in Antenna Line Devices Software![NOK]
    Log  Import Existing File button is visible in Antenna Line Devices Software![OK]  console=true
    ${errors}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element oi-error')]
    Run Keyword If  ${errors} > 0
    ...  Run Keywords
    ...  Page Should Contain Element  //*[contains(@class, 'p-ripple p-element p-button-neutral p-button-sm p-button p-component p-disabled')]  AND
    ...  Log  Save SW Package button is disabled because the configuration has errors![OK]  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Element Should Be Enabled  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Save SW Package')]  AND
    ...  Log  Save SW Package button is enabled because the configuration has no errors![OK]  console=true


Get Info About All Alds From Site View
    ${mha_alds_xpath}  Get List Of Specific ALDs Xpath From Site View  mha
    ${ret_alds_xpath}  Get List Of Specific ALDs Xpath From Site View  ret
    ${rae_alds_xpath}  Get List Of Specific ALDs Xpath From Site View  rae
    ${all_alds_xpath_list}  Combine Lists  ${mha_alds_xpath}  ${ret_alds_xpath}  ${rae_alds_xpath}
    ${info_alds_list}  Create list
    FOR  ${xpath}  IN  @{all_alds_xpath_list}
        Click Element  ${xpath}
        Sleep  2s  Time for ald details to be visible!
        ${product_code}  Get Text  //*[contains(@class, 'details-info-body')]/div/div[1]/div/div/div/table/tbody/tr[1]/td[2]
        ${serial_number}  Get Text  //*[contains(@class, 'details-info-body')]/div/div[1]/div/div/div/table/tbody/tr[2]/td[2]
        ${vendor_code}  Get Text  //*[contains(@class, 'details-info-body')]/div/div[1]/div/div/div/table/tbody/tr[3]/td[2]
        ${hw_version}  Get Text  //*[contains(@class, 'details-info-body')]/div/div[1]/div/div/div/table/tbody/tr[5]/td[2]
        Append To List  ${info_alds_list}  ${product_code}  ${serial_number}  ${vendor_code}  ${hw_version}
    END

    [Return]  ${info_alds_list}


Verify Info For All Alds In Antenna Line Devices Software
    [Arguments]  ${info_list}

    Log  \nVerify Info For All Alds In Antenna Line Devices Software  console=true
    FOR  ${info}  IN  @{info_list}
        Page Should Contain  ${info}
        ...  ${info} is not visible in Antenna Line Devices Software table as in Site View![NOK]
        Log  ${info} is visible in Antenna Line Devices Software table as in Site View![OK]  console=true
    END


Verify If Table Can Be Edited In HW Info With/Without SN
    [Arguments]  ${speficied_menu}

    Log  \nVerify If Table Can Be Edited In HW Info With/Without SN  console=true
    ${number_of_rows}  SeleniumLibrary.Get Element Count  xpath=//table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${vendor_before}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[3]/div/input
        Input Text  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[3]/div/input  TS
        ${vendor_after}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[3]/div/input
        Should Not Be Equal  ${vendor_before}  ${vendor_after}
        ...  Vendor value for row ${row} was not changed successfully![NOK]
        Log  Vendor value for row ${row} was ${vendor_before} and has been changed successfully into ${vendor_after}![OK]  console=true
        ${pc_before}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[4]/div/input
        Input Text  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[4]/div/input  100.${row}
        ${pc_after}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[4]/div/input
        Should Not Be Equal  ${pc_before}  ${pc_after}
        ...  Product Code value for row ${row} was not changed successfully![NOK]
        Log  Product Code value for row ${row} was ${pc_before} and has been changed successfully into ${pc_after}![OK]  console=true
        ${sn_before}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[5]/div/input
        Input Text  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[5]/div/input  ABC.${row}
        ${sn_after}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[5]/div/input
        Run keyword if  '${speficied_menu}' == 'Without'
        ...  Should Be Empty  ${sn_before}
        ...  ELSE
        ...  Should Not Be Empty  ${sn_before}
        Should Not Be Equal  ${sn_before}  ${sn_after}
        ...  Serial number value for row ${row} was not changed successfully![NOK]
        Log  Serial number value for row ${row} was ${sn_before} and has been changed successfully into ${sn_after}![OK]  console=true
        ${hw_before}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[6]/div/input
        Input Text  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[6]/div/input  ${row}
        ${hw_after}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[6]/div/input
        Should Not Be Equal  ${hw_before}  ${hw_after}
        ...  HW version value for row ${row} was not changed successfully![NOK]
        Log  HW version value for row ${row} was ${hw_before} and has been changed successfully into ${hw_after}![OK]  console=true
        Input Text  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[7]/div/input  1${row}
        ${target_sw}  Get Value  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[7]/div/input
        Run keyword if  ${target_sw}
        ...  Log  Target SW version value for row ${row} was setting successfully ${target_sw}![OK]  console=true
        ...  ELSE
        ...  Fail  Target SW version value for row ${row} was not setting successfully![NOK]
        ${sw_before}  Get Text  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[8]/p-dropdown/div
        Click Element  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[8]/p-dropdown/div
        Click Element  //*[contains(@aria-label, "Restricted")]
        ${sw_after}  Get Text  //table[@class="p-datatable-table w-full ng-star-inserted"]/tbody/tr[${row}]/td[8]/p-dropdown/div
        Should Not Be Equal  ${sw_before}  ${sw_after}
        ...  SW update options value for row ${row} was not changed successfully![NOK]
        Log  SW update options value for row ${row} was ${sw_before} and has been changed successfully into ${sw_after}![OK]  console=true
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
