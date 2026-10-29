*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for vDU WebEM TCs that contain common KWs, both from old GUI and from the new GUI.

Library  DateTime
Library  SeleniumLibrary  run_on_failure=Nothing
Resource  WebEM_general.robot
Resource  WebEM_general_${GUI_VERSION}_GUI.robot
Resource  vdu_WebEM_general_${GUI_VERSION}_GUI.robot


*** Variables ***
${GUI_VERSION}  new  # GUI version can be old or new. The new GUI is for software releases newer or equal to 25R1.


*** Keywords ***
VDU WebEM Teardown
    [Documentation]  This keyword is used to vDU WebEM Teardown.

    Run Keyword If Test Failed
    ...  Capture Page Screenshot  Snapshot_after_test_failed.png
    Logout From CBTS
    Close Browser


VDU WebEM Setup
    [Documentation]  This keyword is used to vDU WebEM Setup.
    [Arguments]  ${timeout}=90s

    Set Screenshot Directory  ${TEST_RESULTS_DIR}/selenium_screenshot_${TEST_NAME}
    Open VDU WebEM  timeout=${timeout}


Open VDU WebEM
    [Documentation]  This keyword opens the vDU WebEM in chrome browser and maximizes the window.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${VDU_OAM_IP}
    Set Window Size  ${1920}  ${1400}
    Check Private Connection From CBTS
    Login On CBTS
    Confirm Legal Notice From CBTS
    Log  Wait until the page is loaded!  console=true
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'Radio Modules Status Summary')]  ${timeout}
    ...  WebElement is not fully loaded in ${timeout} seconds.
    Capture Page Screenshot  vDU_WebEM_initial_state.png


Open Remote VCU WebEM From VDU
    [Documentation]  This keyword opens the vCU WebEM in chrome browser remotely on vDU VM and maximizes the window.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    Call Method  ${chrome_options}  add_argument  --headless
    ${options}  Call Method  ${chrome_options}  to_capabilities
    Create Webdriver  Remote  command_executor=http://${VCU_OAM_IP}:10020  desired_capabilities=${options}
    Go To  https://${VCU_OAM_IP}
    Set Window Size  ${1920}  ${1800}
    Check Private Connection From CBTS
    Login On CBTS
    Confirm Legal Notice From CBTS
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'DUs Status Summary')]  30s
    ...  WebElement is not fully loaded in 30s seconds.
    Capture Page Screenshot  remote_vCU_WebEM_initial_state.png


Save Results For RF Statistic/Diagnostic Test For VDU WebEM
    [Documentation]  This keyword saves the results for RF Statistic Diagnostic Test and RF Diagnostic Test from vDU.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${specific_button}  ${test_name}  ${cell_or_module}

    Log  ${specific_button} is perform!  console=true
    Click Element  //*[contains(@label, "${specific_button}")]
    Sleep  60s  Time for txt file to be saved!
    Move File  /home/ute/Downloads/${test_name}_${VDU_MRBTS_NAME}_${cell_or_module}-*.txt
    ...  ${TEST_RESULTS_DIR}/${test_name}_${VDU_MRBTS_NAME}_${cell_or_module}.txt
    Log  The result is moved in ${TEST_RESULTS_DIR}/${test_name}_${VDU_MRBTS_NAME}_${cell_or_module}.txt!  console=true
    Log  Save All Results is performed!  console=true
    Click Element  //*[contains(@label, "Save All Results")]
    Sleep  60s  Time for txt file to be saved!
    ${date}  DateTime.Get Current Date  result_format=%Y%m%d
    Move File  /home/ute/Downloads/${test_name}_${VDU_MRBTS_NAME}_${date}.txt  ${TEST_RESULTS_DIR}/${test_name}_${VDU_MRBTS_NAME}_${date}.txt
    Log  The result is moved in ${TEST_RESULTS_DIR}/${test_name}_${VDU_MRBTS_NAME}_${date}.txt  console=true


Reset VDU From VDU WebEM
    [Documentation]  This keyword is used to reset vDU from vDU WebEM
    [Arguments]  ${cells_recovery_timeout}

    Log  Reset vDU from vDU WebEM  console=true
    Wait Until Element Is Clicked  //p-button[@title="Reset vDU"]
    Wait Until Element Is Visible  xpath:/html/body/p-dynamicdialog/div/div  30
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'OK')]  60
    Wait Until Keyword Succeeds  400s  10s
    ...  Check All Cells From VDU  availability_status=${OFFLINE}  operational_state=${DISABLED}
    Log  All cells are Offline and Disabled![OK]  console=true
    Close Start-up View From VDU WebEM
    Wait Until Keyword Succeeds  ${cells_recovery_timeout}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  All cells are Online and Enabled![OK]  console=true


Close Start-up View From VDU WebEM
    [Documentation]  This keyword is used to close Start-up view from vDU WebEM

    Log  Close Start-up view from vDU WebEM  console=true
    Wait Until Element Is Visible  //*[contains(@class, 'vdu-startup-view')]  600
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Close')]  60
    Log  Start-up view is closed![OK]  console=true


Find ALDs And Subunits Mapped On Given RMOD
    [Documentation]  This keyword is used to find all ALDs and subunits mapped on given RMOD.
    ...  Given argument is ${rmod_id}.
    ...  It is used with "Parse ALDs and save dist names" keyword.
    ...  Returned values: ${alds_dns} ${subunits_dns}.
    ...  E.g. [MRBTS-10334/EQM-1/APEQM-1/ALD-1] [MRBTS-10334/EQM-1/APEQM-1/ALD-1/RETU-1]
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${rmod_id}

    ${alds_dns}  Create List
    ${subunits_dns}  Create List
    ${all_alds}  Create List
    ${ret_alds}  Get Rets Information
    ${rae_alds}  Get Raes Information
    ${mha_alds}  Get Mhas Information
    Append To List  ${all_alds}  @{ret_alds}  @{rae_alds}  @{mha_alds}

    ${alds_dns}  ${subunits_dns}  Run Keyword If  ${all_alds}
    ...  Parse ALDs And Save Dist Names  ${all_alds}  ${rmod_id}
    ...  ELSE
    ...  Fail  There are no ALDs mapped on RMOD. [NOK]

    [Return]  ${alds_dns}  ${subunits_dns}


Parse ALDs And Save Dist Names
    [Documentation]  This keyword parses all ALDs that are mapped on RMOD and appends ALD and subunits dist names to two separate lists.
    ...  Given arguments are:
    ...  ${alds} - list of alds obtained with get_rets_information, get_rae_information, get_mha_information.
    ...  ${rmod_id} - given rmod id.
    ...  Returned values:
    ...  ${ald_dns} - E.g. [MRBTS-10334/EQM-1/APEQM-1/ALD-1, MRBTS-10334/EQM-1/APEQM-1/ALD-2]
    ...  ${subunits_dns} - E.g. [MRBTS-10334/EQM-1/APEQM-1/ALD-1/RETU-1, MRBTS-10334/EQM-1/APEQM-1/ALD-1/RETU-2]
    ...  It is used with "Parse ALD RMODs list and verify RMOD id" keyword.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${alds}  ${rmod_id}

    ${alds_dns}  Create List
    ${subunits_dns}  Create List
    FOR  ${ald}  IN  @{alds}
        ${rmod_status}  Run Keyword And Return Status
        ...  Parse ALD RMODs List And Verify RMOD Id  ${ald}[dc_power_sources]  ${rmod_id}
        Continue For Loop If  ${rmod_status}==${FALSE}
        Append To List  ${alds_dns}  ${ald}[dist_names][config]
        ${subunits_dns}  Append All ALD Subunits Dist Names To ALD Subunits List  ${ald}[subunits]
    END
    Should Not Be Empty  ${alds_dns}  No ALDs found on RMOD-${rmod_id}. [NOK]

    [Return]  ${alds_dns}  ${subunits_dns}


Parse ALD RMODs List And Verify RMOD Id
    [Documentation]  This keyword parses all RMODs found in ALDs dc_power_sources parameter.
    ...  dc_power_sources parameter contains all RMODs that an ALD is mapped on.
    ...  Given arguments are:
    ...  ${ald_rmods} - list of ald rmods from dc_power_sources.
    ...  ${rmod_id} - given rmod id.
    ...  This keyword if used in "Parse ALDs and save dist names" keyword.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${ald_rmods}  ${rmod_id}

    FOR  ${rmod}  IN  @{ald_rmods}
        ${rmod_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${rmod}[rmod_id]  ${rmod_id}
        Run Keyword If  ${rmod_id_status}
        ...  Return From Keyword
    END
    Fail  RMOD-${rmod_id} not found in ALD list. [NOK]


Append All ALD Subunits Dist Names To ALD Subunits List
    [Documentation]  This keyword parses all subunits of an ALD and appends their dist names to a given list.
    ...  Given arguments are:
    ...  ${subunits} - list of ald subunits.
    ...  Returned values:
    ...  ${subunits_dns} - E.g. [MRBTS-10334/EQM-1/APEQM-1/ALD-1/RETU-1, MRBTS-10334/EQM-1/APEQM-1/ALD-1/RETU-2]
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${subunits}

    ${subunits_dns}  Create List
    FOR  ${subunit}  IN  @{subunits}
        Append To List  ${subunits_dns}  ${subunit}[dist_names][config]
    END
    Should Not Be Empty  ${subunits_dns}  No ALD subunits found on RMOD-${RMOD_ID}. [NOK]

    [Return]  ${subunits_dns}


Configure ALD And RAEU
    [Documentation]  This keyword configures ALD RAE.
    ...  E.g. Configure ALD and RAEU  1
    ...                         AEQP
    ...                         TRAE-TDGA12V01
    ...                         201500181
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com
    [Arguments]  ${ald_id}  ${rmod_name}  ${ald_product_code}  ${ald_serial_number}  ${ald_mechanical_angle}

    Press Keys  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  CTRL+a+BACKSPACE
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  ALD-${ald_id}
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'ALD-${ald_id}')]/span/span/div/div[1]  30  2
    Verify Parameter Name For ALD - RAE And RET
    Set Selenium Speed  0.2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'AISG 2.0')]  30  2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]  30  2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]  30  2
    ${pc_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${pc_ald}  ${ald_product_code}
    ${sn_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[5]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${sn_ald}  ${ald_serial_number}
    Set Selenium Speed  1
    ${status}  Run Keyword And Return Status
    ...  Page should contain  RAEU-1
    Run Keyword If  ${status}
    ...  Click Element  //*[contains(@aria-label, 'RAEU-1')]/span/span/div/div[1]
    ...  ELSE
    ...  Run Keywords
    ...  Wait Until Element Is Clicked  //*[contains(@aria-label, 'ALD-${ald_id}')]/button/span  30  2
    ...  AND
    ...  Wait Until Element Is Clicked  //*[contains(@aria-label, 'RAEU-1')]  30  2
    Verify Parameter Name For RAE Subunit
    Set Selenium Speed  0.2
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[3]/p-button[1]/button  30  2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/PHYANT')]  30  2
    ${mechanical_angle}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/
    ...  cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${mechanical_angle}  ${ald_mechanical_angle}
    Set Selenium Speed  1


Configure ALD And RETU
    [Documentation]  This keyword configures ALD RET.
    ...  E.g. Configure ALD and RETU  1
    ...                         AEQP
    ...                         TRAE-TDGA12V01
    ...                         201500181
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com
    [Arguments]  ${ald_id}  ${rmod_name}  ${ald_product_code}  ${ald_serial_number}

    Press Keys  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  CTRL+a+BACKSPACE
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  ALD-${ald_id}
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'ALD-${ald_id}')]/span/span/div/div[1]  30  2
    Verify Parameter Name For ALD - RAE And RET
    Set Selenium Speed  0.2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'AISG 2.0')]  30  2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]  30  2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]  30  2
    ${pc_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${pc_ald}  ${ald_product_code}
    ${sn_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[5]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${sn_ald}  ${ald_serial_number}
    Set Selenium Speed  1
    ${status}  Run Keyword And Return Status
    ...  Page Should Contain  RETU-1
    Run Keyword If  ${status}
    ...  Click Element  //*[contains(@aria-label, 'RETU-1')]/span[2]/span/div/div[1]
    ...  ELSE
    ...  Run Keywords
    ...  Click Element  //*[contains(@aria-label, 'ALD-${ald_id}')]/button
    ...  AND
    ...  Wait Until Element Is Clicked  //*[contains(@aria-label, 'RETU-1')]/span[2]/span/div/div[1]  30  2
    Verify Parameter Name For RET Subunit
    Set Selenium Speed  0.2
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/PHYANT')]  30  2
    Set Selenium Speed  1


Configure ALD And MHA
    [Documentation]  This keyword configures ALD MHA.
    ...  E.g. Configure ALD and MHA   1
    ...                         AEQP
    ...                         TRAE-TDGA12V01
    ...                         201500181
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com
    [Arguments]  ${ald_id}  ${rmod_name}  ${ald_product_code}  ${ald_serial_number}

    Press Keys  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  CTRL+a+BACKSPACE
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  Nokia ALD-${ald_id}
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Nokia ALD-${ald_id}')]/span/span/div/div[1]  30  2
    Verify Parameter Name For ALD - MHA
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'AISG 2.0')]  30  2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div  30  2
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]  30  2
    ${pc_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${pc_ald}  ${ald_product_code}
    ${sn_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${sn_ald}  ${ald_serial_number}
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[contains(@aria-label, 'LNA-1')]
    Run Keyword If  ${status}
    ...  Click Element  //*[contains(@aria-label, 'LNA-1')]/span/span/div/div[1]
    ...  ELSE
    ...  Run Keywords
    ...  Click Element  //*[contains(@aria-label, 'ALD-${ald_id}')]/button
    ...  AND
    ...  Wait Until Element Is Clicked  //*[contains(@aria-label, 'LNA-1')]/span/span/div/div[1]  30  2
    Verify Parameter Name For MHA Subunit
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-multiselect-input/div/p-multiselect/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]  30  2
    ${mast_locator}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-number-input
    ...  /ot-field/div/ot-input-number/span/input
    Input Text  ${mast_locator}  12
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'LNA-2')]/span/span/div/div[1]/div  30  2
    Verify Parameter Name For MHA Subunit
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-multiselect-input/div/p-multiselect/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]  30  2
    ${mast_locator}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-number-input
    ...  /ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${mast_locator}  12


Verify Parameter Name For ALD - RAE And RET
    [Documentation]  This keyword is used in "Configure ALD and RAEU" and "Configure ALD and RETU" kws.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com

    ${first_ald_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_ald_paramter}  Control protocol  "Control protocol" parameter is not visible![NOK]
    Log  "Control protocol" parameter is visible![OK]  console=true
    ${second_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_ald_parameter}  Controlling port  "Controlling port" parameter is not visible![NOK]
    Log  "Controlling port" parameter is visible![OK]  console=true
    ${third_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_ald_parameter}  DC power sources  "DC power sources" parameter is not visible![NOK]
    Log  "DC power sources" parameter is visible![OK]  console=true
    ${fourth_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${fourth_ald_parameter}  Product code  "Product code" parameter is not visible![NOK]
    Log  "Product code" parameter is visible![OK]  console=true
    ${fifth_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[5]/td[1]
    Should Be Equal  ${fifth_ald_parameter}  Serial number  "Serial number" parameter is not visible![NOK]
    Log  "Serial number" parameter is visible![OK]  console=true


Verify Parameter Name For ALD - MHA
    [Documentation]  This keyword is used in "Configure ALD and MHA" kw.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com

    ${first_ald_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_ald_paramter}  Control protocol  "Control protocol" parameter is not visible![NOK]
    Log  "Control protocol" parameter is visible![OK]  console=true
    ${second_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_ald_parameter}  Controlling port  "Controlling port" parameter is not visible![NOK]
    Log  "Controlling port" parameter is visible![OK]  console=true
    ${third_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_ald_parameter}  Product code  "Product code" parameter is not visible![NOK]
    Log  "Product code" parameter is visible![OK]  console=true
    ${fourth_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${fourth_ald_parameter}  Serial number  "Serial number" parameter is not visible![NOK]
    Log  "Serial number" parameter is visible![OK]  console=true


Verify Parameter Name For RAE Subunit
    [Documentation]  This keyword is used in "Configure ALD and RAEU" kw.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com

    ${first_rae_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_rae_paramter}  List of associated antenna lines  "List of associated antenna lines" parameter is not visible![NOK]
    Log  "List of associated antenna lines" parameter is visible![OK]  console=true
    ${second_rae_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_rae_parameter}  Mechanical angle  "Mechanical angle" parameter is not visible![NOK]
    Log  "Mechanical angle" parameter is visible![OK]  console=true
    ${third_rae_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_rae_parameter}  Subunit number  "Subunit number" parameter is not visible![NOK]
    Log  "Subunit number" parameter is visible![OK]  console=true


Verify Parameter Name For RET Subunit
    [Documentation]  This keyword is used in "Configure ALD and RETU" kw.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com

    ${first_ret_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_ret_paramter}  Configuration file  "Configuration file" parameter is not visible![NOK]
    Log  "Configuration file" parameter is visible![OK]  console=true
    ${second_ret_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_ret_parameter}  List of associated antenna lines  "List of associated antenna lines" parameter is not visible![NOK]
    Log  "List of associated antenna lines" parameter is visible![OK]  console=true
    ${third_ret_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${third_ret_parameter}  Subunit number  "Subunit number" parameter is not visible![NOK]
    Log  "Subunit number" parameter is visible![OK]  console=true


Verify Parameter Name For MHA Subunit
    [Documentation]  This keyword is used in "Configure ALD and MHA" kw.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com

    ${first_mha_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_mha_paramter}  Amplified antenna line  "Amplified antenna line" parameter is not visible![NOK]
    Log  "Amplified antenna line" parameter is visible![OK]  console=true
    ${second_mha_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_mha_parameter}  DC power sources  "DC power sources" parameter is not visible![NOK]
    Log  "DC power sources" parameter is visible![OK]  console=true
    ${third_mha_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_mha_parameter}  Mast head amplifier gain  "Mast head amplifier gain" parameter is not visible![NOK]
    Log  "Mast head amplifier gain" parameter is visible![OK]  console=true
    ${fourth_mha_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${fourth_mha_parameter}  Subunit number  "Subunit number" parameter is not visible![NOK]
    Log  "Subunit number" parameter is visible![OK]  console=true


Get The First Cloned NRCELLGRP Id
    [Documentation]  This keyword returns first cloned NRCELLGRP id.
    ...  "Get list of NRCELLGRP ids" is found in WebEM_general.robot
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com

    ${nr_cells_group_list}  Get List Of NRCELLGRP Ids
    ${length}  Get Length  ${nr_cells_group_list}
    ${last_group_id}  Run Keyword If  ${length} > 1
    ...  Remove From List  ${nr_cells_group_list}  -1
    ...  ELSE
    ...  Set Variable  ${nr_cells_group_list}[0]
    ${value}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${nr_cells_group_list}  0
    ${first_cloned_group_id}  Run Keyword If  ${value}
    ...  Set Variable  0
    ...  ELSE
    ...  Evaluate  ${last_group_id} + 1

    [Return]  ${first_cloned_group_id}


Get The Second Cloned NRCELLGRP Id
    [Documentation]  This keyword returns second cloned NRCELLGRP id.
    ...  "Get list of NRCELLGRP ids" is found in WebEM_general.robot
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com

    ${nr_cells_group_list}  Get List Of NRCELLGRP Ids
    ${second_cloned_group_id}  Run Keyword If  ${FIRST_CLONED_GROUP_ID} == 0
    ...  Evaluate  ${nr_cells_group_list}[-1] + 1
    ...  ELSE
    ...  Evaluate  ${FIRST_CLONED_GROUP_ID} + 1

    [Return]  ${second_cloned_group_id}


Verify If The NRCELLGRP Was Created And Check The Parameters
    [Documentation]  This keyword checks if NRCELLGRP was created and verifies it's parameters.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com
    [Arguments]  ${cloned_group_id}  ${mrbts_id}  ${nrbts_id}

    Log  Verify if the NRCELLGRP was created and check the parameters  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[contains(@aria-label, "NRCELLGRP-${cloned_group_id}")]
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[@id="MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-${cloned_group_id}"]
    Click Element  //*[contains(@aria-label, "NRCELLGRP-${cloned_group_id}")]/span[2]/span/div/div[1]
    Log  NRCELLGRP-${cloned_group_id} was created!  console=true
    Sleep  10s  Time for parameters to be visible.
    ${number_of_parameters}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr
    ${name_of_parameters_list}  Create List  Additional number of RRC connected users in a New Radio cell for SA handover  Beamforming grid selection
    ...  Maximum number of DL HARQ transmissions  Maximum number of Msg3 transmissions
    ...  Maximum number of non-GBR data radio bearers in New Radio Cell Group for SA
    ...  Maximum number of RRC connected users in a New Radio Cell Group for SA  Maximum number of UL HARQ transmissions
    ...  Number of transmitted Synchronization Signal Blocks  Pucch F2 Max Code Rate  SCS  SP-Cell change enabled  SS Burst Set Period
    FOR  ${row}  IN RANGE  1  ${number_of_parameters}
        ${name}  Wait Until Keyword Succeeds  30  5
        ...  Get Text  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[1]
        ${list_index}  Evaluate  ${row} - 1
        Should Be Equal  ${name}  ${name_of_parameters_list}[${list_index}]  "${name}" is not visible![NOK]
        Log  "${name}" is visible![OK]  console=true
    END


Verify And Configure Parameters For FDD Cells From Step-by-step
    [Documentation]  This keyword verifies and configures FDD cell parameters.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com
    [Arguments]  ${nrcell_grp}  ${cell_id}

    Sleep  10s  Time for parameters to be visible.
    ${number_of_parameters}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr
    ${name_of_parameters_list}  Create List  Activate super cell  Cell name  Cell technology  Channel bandwidth in downlink
    ...  Channel bandwidth in uplink  Downlink frequency  Downlink MIMO Mode  Frequency band Indicator NR  Local cell resource ID
    ...  Maximum output power  New Radio Cell instance identifier  NR Absolute radio frequency channel number in downlink
    ...  NR Absolute radio frequency channel number in uplink  NR cell group  NR Cell type  Physical cell identifier  Timing advance offset
    ...  Uplink frequency  Uplink MIMO mode
    FOR  ${row}  IN RANGE  1  ${number_of_parameters}
        ${name}  Wait Until Keyword Succeeds  30  5
        ...  Get Text  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[1]
        ${list_index}  Evaluate  ${row} - 1
        Should Be Equal  ${name}  ${name_of_parameters_list}[${list_index}]  "${name}" is not visible![NOK]
        Log  "${name}" is visible![OK]  console=true
    END
    Log  Update Channel bandwidth in downlink parameter!  console=true
    ${channel_downlink_locator}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[4]
    ...  /td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${channel_downlink_locator}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "40MHz")]
    Log  Update Channel bandwidth in uplink parameter!  console=true
    ${channel_uplink_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[5]
    ...  /td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${channel_uplink_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "20MHz")]
    Log  Update NR Absolute radio frequency channel number in downlink parameter!  console=true
    ${first_param_text}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[12]/td[2]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  ${first_param_text}  61000
    Log  Update NR Absolute radio frequency channel number in uplink parameter!  console=true
    ${second_param_text}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[13]/td[2]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  ${second_param_text}  63000
    Log  Update NR cell group parameter!  console=true
    ${nrcell_group_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[14]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span
    Wait Until Element Is Clicked  ${nrcell_group_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NRCELLGRP-${nrcell_grp}")]
    Log  Update NR Cell type parameter!  console=true
    ${nrcell_type_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[15]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${nrcell_type_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "4DL4UL")]
    Log  Update Physical cell identifier!  console=true
    ${physical_cell_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[16]/td[2]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  ${physical_cell_location}  ${cell_id}
    Log  Update Timing advance offset!  console=true
    ${timing_advance_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[17]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${timing_advance_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "n0")]
    Log  Update frequency band indicator!  console=true
    ${frequency_band_locator}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[8]/td[2]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  ${frequency_band_locator}  78


Verify And Configure Parameters For TDD Cells From Step-by-step
    [Documentation]  This keyword verifies and configures TDD cell parameters.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com, anna.benzar@nokia.com
    [Arguments]  ${nrcell_grp}  ${cell_id}

    Sleep  10s  Time for parameters to be visible.
    ${number_of_parameters}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr
    ${name_of_parameters_list}  Create List  Activate super cell  Cell name  Cell technology  Channel bandwidth  Downlink MIMO Mode  Frequency
    ...  Frequency band Indicator NR  Local cell resource ID  Maximum output power  New Radio Cell instance identifier
    ...  NR Absolute radio frequency channel number  NR cell group  NR Cell type  Physical cell identifier  Timing advance offset  Uplink MIMO mode
    FOR  ${row}  IN RANGE  1  ${number_of_parameters}
        ${name}  Wait Until Keyword Succeeds  30  5
        ...  Get Text  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[1]
        ${list_index}  Evaluate  ${row} - 1
        Should Be Equal  ${name}  ${name_of_parameters_list}[${list_index}]  "${name}" is not visible![NOK]
        Log  "${name}" is visible![OK]  console=true
    END
    Log  Update NR cell group parameter!  console=true
    ${nrcell_group_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[12]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span
    Wait Until Element Is Clicked  ${nrcell_group_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NRCELLGRP-${nrcell_grp}")]
    Log  Update NR Cell type parameter!  console=true
    ${nrcell_type_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[13]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${nrcell_type_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "4DL4UL")]
    Log  Update Downlink MIMO Mode parameter!  console=true
    ${downlink_mimo_mode_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[5]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${downlink_mimo_mode_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "4x4 or 4x2 Closed Loop Spatial Multiplexing")]  15  2
    Log  Update Uplink MIMO Mode parameter!  console=true
    ${uplink_mimo_mode_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[16]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${uplink_mimo_mode_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "Closed loop Spatial Multiplexing (2x2)")]  15  2
    Log  Update NR Absolute radio frequency channel number parameter!  console=true
    ${first_param_text}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[11]/td[2]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  ${first_param_text}  638000
    Log  Update Frequency band Indicator NR parameter!  console=true
    ${second_param_text}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[7]/td[2]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  ${second_param_text}  78
    Log  Update NR Cell type parameter!  console=true
    ${nrcell_type_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[14]/td[2]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  ${nrcell_type_location}  ${cell_id}
    Log  Update Timing advance offset parameter!  console=true
    ${timing_advance_location}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody
    ...  /tr[15]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown
    Wait Until Element Is Clicked  ${timing_advance_location}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "n0")]


Verify Parameters Names For RAN NIC Module
    [Documentation]  This keyword is used to verify parameters names for RAN NIC module

    ${first_rnic_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_rnic_parameter}  Administrative state  "Administrative state" parameter is not visible![NOK]
    Log  "Administrative state" parameter is visible. [OK]  console=true
    ${second_rnic_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_rnic_parameter}  Product code planned  "Product code planned" parameter is not visible![NOK]
    Log  "Product code planned" parameter is visible. [OK]  console=true
    ${third_rnic_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_rnic_parameter}  Serial number planned  "Serial number planned" parameter is not visible![NOK]
    Log  "Serial number planned" parameter is visible. [OK]  console=true
    Log  All parameters are sorted in ascending order. [OK]  console=true


Generate One Specific Fault Id With EAC
    [Documentation]  This keyword is used to generate one specific fault id from EAC_IN object.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${portid_value}  ${eac_id}

    ${descr_parameter}  Create Dictionary  parameterName=descr  value=This alarm is generated for feature testing  operation=update
    ${inUse_parameter}  Create Dictionary  parameterName=inUse  value=true  operation=update
    ${polarity_parameter}  Create Dictionary  parameterName=polarity  value=Normally_closed  operation=update
    ${portId_parameter}  Create Dictionary  parameterName=portId  value=${portid_value}  operation=update
    ${severity_parameter}  Create Dictionary  parameterName=severity  value=Minor  operation=update
    ${parameters_list}  Create List  ${descr_parameter}  ${inUse_parameter}  ${polarity_parameter}  ${portId_parameter}  ${severity_parameter}
    ${eac_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/EAC_IN-${eac_id}  operation=create
    ...  parameters=${parameters_list}
    ${eac_parameters_list}  Create List  ${eac_parameter}
    ${eac_parameters_string}  Evaluate  json.dumps(${eac_parameters_list})  json
    vdu.Perform Delta Recommissioning  ${eac_parameters_string}
    Log  Operation was done successfully!  console=true


Cancel One Specific Fault Id Generated With EAC And Verify If Fault Is Cleared
    [Documentation]  This keyword is used to cancel one specific fault id generated with EAC_IN object and verify if fault is cleared from WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${eac_id}  ${timeout}  ${fault_id}

    ${eac_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/EAC_IN-${eac_id}  operation=delete
    ${eac_parameters_list}  Create List  ${eac_parameter}
    ${eac_parameters_string}  Evaluate  json.dumps(${eac_parameters_list})  json
    vdu.Perform Delta Recommissioning  ${eac_parameters_string}
    Log  Operation delete was done successfully!  console=true
    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Check If Fault Is Cleared From VDU WebEM  7103  ${fault_id}


Disable actAlarmsSuppression Parameter And Delete Instances
    [Documentation]  This keyword is used to disabled actAlarmsSuppression parameter and deleted instances.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${actAlarmsSuppression_parameter}  Create Dictionary  parameterName=actAlarmsSuppression  value=disabled  operation=update
    ${allowedAlarmList_parameter}  Create Dictionary  parameterName=allowedAlarmList  operation=delete
    ${allowedFaultList_parameter}  Create Dictionary  parameterName=allowedFaultList  operation=delete
    ${suppressedAlarmList_parameter}  Create Dictionary  parameterName=suppressedAlarmList  operation=delete
    ${suppressedFaultList_parameter}  Create Dictionary  parameterName=suppressedFaultList  operation=delete
    ${parameters_change_list}  Create List  ${actAlarmsSuppression_parameter}  ${allowedAlarmList_parameter}  ${allowedFaultList_parameter}
    ...  ${suppressedAlarmList_parameter}  ${suppressedFaultList_parameter}
    ${actAlarmsSuppression_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  operation=update  parameters=${parameters_change_list}
    ${changed_parameters_list}  Create List  ${actAlarmsSuppression_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAlarmsSuppression was changed to disabled![OK]  console=true
    Log  Parameters allowedAlarmList, allowedFaultList, suppressedAlarmList and suppressedFaultList was deleted![OK]  console=true
    vdu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true


Get List Of Active Fault Ids From WebEM
    [Documentation]  This keyword is used to get a list with active fault ids from WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Sleep  20s
    ${active_fault_ids}  Create List
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr
    FOR  ${tr}  IN RANGE  1  ${alarm_table_tr}+1
        IF  ${tr} == 1
            ${fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr/td[5]
        ELSE
            ${fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr[${tr}]/td[5]
        END
        Append To List  ${active_fault_ids}  ${fault_id}
    END

    RETURN  ${active_fault_ids}


Get List Of Active Alarm Ids From WebEM
    [Documentation]  This keyword is used to get a list with active alarm ids from WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Sleep  20s
    ${active_alarm_ids}  Create List
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr
    FOR  ${tr}  IN RANGE  1  ${alarm_table_tr}+1
        IF  ${tr} == 1
            ${alarm_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr/td[3]
        ELSE
            ${alarm_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr[${tr}]/td[3]
        END
        Append To List  ${active_alarm_ids}  ${alarm_id}
    END

    RETURN  ${active_alarm_ids}


Save Statictics File And Move It To Test Results Directory
    [Documentation]  This keyword is used to save statistics file and move it to test results directory.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${operation_time}

    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[3]/p-button/button/span[1]
    Log  Save button for statistics file was pushed!  console=true
    ${DATE_FOR_TXT}  Get Current Date  result_format=%Y%m%d
    Set Test Variable  ${DATE_FOR_TXT}
    Wait Until Created  /home/ute/Downloads/MRBTS-${VDU_MRBTS_ID}_${VDU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}-*.txt  timeout=120s
    Move File  /home/ute/Downloads/MRBTS-${VDU_MRBTS_ID}_${VDU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}-*.txt
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VDU_MRBTS_ID}_${VDU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_${operation_time}.txt
    Log  Location: ${TEST_RESULTS_DIR}/MRBTS-${VDU_MRBTS_ID}_${VDU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_${operation_time}.txt  console=true


Verify Generated EAC Fault Info From The Statistics File With Suppressed Alarms
    [Documentation]  This keyword is used to verify the generated eac fault info from the statistics file with suppressed alarms.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${file_content}  ${fault_id}

    ${date}  Get Current Date  result_format=%d.%m.%Y
    Should Contain  ${file_content}  minor  The file doesn't contains severity minor![NOK]
    Log  The saved file contains severity minor![OK]  console=true
    Should Contain  ${file_content}  7103
    ...  The file doesn't contains alarm id 7103![NOK]
    Log  The saved file contains alarm id 7103![OK]  console=true
    Should Contain  ${file_content}  BASE STATION EXTERNAL ALARM NOTIFICATION
    ...  The file doesn't contains alarm name 'BASE STATION EXTERNAL ALARM NOTIFICATION'![NOK]
    Log  The saved file contains alarm name 'BASE STATION EXTERNAL ALARM NOTIFICATION'![OK]  console=true
    Should Contain  ${file_content}  ${fault_id}
    ...  The file doesn't contains fault id ${fault_id}![NOK]
    Log  The saved file contains fault id ${fault_id}![OK]  console=true
    Should Contain  ${file_content}  This alarm is generated for feature testing
    ...  The file doesn't contains fault name 'This alarm is generated for feature testing'![NOK]
    Log  The saved file contains fault name 'This alarm is generated for feature testing'![OK]  console=true
    Should Contain  ${file_content}  ${date}  The file doesn't contains ${date}![NOK]
    Log  The saved file contains ${date}![OK]  console=true
