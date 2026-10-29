*** Settings ***
Documentation
    ...  This test case is created to check Site Report menu.
    ...  Product name and Serial number from each SMOD,BBMOD and RMOD are saved in lists.
    ...  For cells the name is saved.
    ...  Check if Expand and Collaps buttons are available and enabled.
    ...  Check BTS Properties.
    ...  Check if SMODs have the PN and SN as well in Site Report.
    ...  Check if BBMODs have the PN and SN as well in Site Report.
    ...  Check if RMODs have the PN and SN as well in Site Report.
    ...  Check if cells have the same name in Site Report.
    ...  Check if SCF exists in SCF File.
    ...  Check if NIDD Version is visible.
    ...  Check if SW release version is the same in Site Report as in Site View.
    ...  Check if Save Report and Print Report buttons are available.
    ...  Save Report in BTS Files directory.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Site_Report
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21606
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21606 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 22.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28509 - Add scroll up to see whole configuration

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step0: TC Preconditions
    Step1: Open Site Report Menu
    Step2: Check If Expand And Collaps Buttons Are Enabled
    Step3: Check BTS Properties
    Step4: Check SCF File
    Step5: Check NIDD Version
    Step6: Check SW Release Version
    Step7: Check If Save Report And Print Report Buttons Are Available


Step0: TC Preconditions
    Get BBMODs PN And SN
    Get SMODs PN And SN
    Get RMODs PN And SN
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Get GSM Cell Name
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Get WCDMA Cell Name
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Get LTE Cell Name
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Get NR Cell Name


Step1: Open Site Report Menu
    Log  Step1: Open Site Report menu  console=true
    Open Site Report


Step2: Check If Expand And Collaps Buttons Are Enabled
    Log  Step2: Check if Expand and Collaps buttons are enabled  console=true
    Wait Until Element Is Enabled  xpath=//*[contains(@a-title, 'Expand all')]  60
    Wait Until Element Is Enabled  xpath=//*[contains(@a-title, 'Collapse all')]  60
    ${expand_button}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(@a-title, 'Expand all')]
    ${collapse_button}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(@a-title, 'Collapse all')]
    Run Keyword If  ${expand_button}
    ...  Log  Expand All Button is Enabled![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Expand All button is not Enabled![NOK]
    Run Keyword If  ${collapse_button}
    ...  Log  Collapse All Button is Enabled![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Collapse All button is not Enabled![NOK]
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Expand all')]  60
    Sleep  30s


Step3: Check BTS Properties
    Log  Step3: Check BTS Properties  console=true
    Wait Until Keyword Succeeds  60  5
    ...  Double Click Element  //*[contains(text(), "Cabinet")]
    Site Report Check SMOD
    Site Report Check BBMOD
    Site Report Check RMOD
    Check Cells In Site Report


Step4: Check SCF File
    Log  Step4: Check SCF File  console=true
    ${scf_text}  Catenate  SEPARATOR=  //*[contains(@class, "site-report-panel")]/div/div[1]
    ...  /div/div/div[2]/ui-expandable-panel/div/div[2]/div
    ${scf}  Run Keyword And Return Status
    ...  Wait Until Element Is Enabled  ${scf_text}  60
    Run Keyword If  ${scf}
    ...  Log  SCF is visible in SCF File![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  SCF is not visible in SCF File![NOK]


Step5: Check NIDD Version
    Log  Step5: Check NIDD Version  console=true
    ${nidd_text}  Catenate  SEPARATOR=  //*[contains(@class, "site-report-panel")]/div/div[1]
    ...  /div/div/div[3]/ui-expandable-panel/div/div[2]/div
    ${nidd_version}  Get Text  ${nidd_text}
    Click Element  ${nidd_text}
    Log  ${nidd_version}  console=true


Step6: Check SW Release Version
    Log  Step6: Check SW Release Version  console=true
    ${sw_site_view}  Get Text  ${SW_NAME}
    Log  In Site View SW release version is: ${sw_site_view}  console=true
    ${sw_vers}  Catenate  SEPARATOR=  //*[contains(@class, "site-report-panel")]
    ...  /div/div[1]/div/div/div[4]/ui-expandable-panel/div/div[2]
    ${value_sw_version}  Get Text  ${sw_vers}
    Click Element  ${sw_vers}
    ${sw_version}  Fetch From Left  ${value_sw_version}  \nActive GSM RAT version
    ${version}  Fetch From Right  ${sw_version}  Software release version\n
    Log  In Site Report SW release version is: ${version}  console=true
    ${status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${sw_site_view}  ${version}
    Run Keyword If  ${status}
    ...  Log  ${version} is the same in Site Report and in Site View![OK]  console=true
    ...  ELSE
    ...  Fail  ${version} is not the same in Site Report and in Site View![NOK]


Step7: Check If Save Report And Print Report Buttons Are Available
    Log  Step7: Check if Save Report and Print Report buttons are available  console=true
    ${save_report}  Run Keyword And Return Status
    ...  Wait Until Element Is Enabled  xpath=//*[contains(@a-text, 'Save Report')]
    ${print_report}  Run Keyword And Return Status
    ...  Wait Until Element Is Enabled  xpath=//*[contains(@a-text, 'Print Report')]
    Run Keyword If  ${save_report}
    ...  Log  Save Report Button is Enabled![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Save Report button is not Enabled![NOK]
    Run Keyword If  ${print_report}
    ...  Log  Print Report Button is Enabled![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Print Report button is not Enabled![NOK]
    Save Report


Get RMODs PN And SN
    ${rmods_site_view}  Get Xpaths For RMODs
    ${rmod_sn}  Create List
    ${rmod_pn}  Create List
    FOR  ${rmod}  IN  @{rmods_site_view}
        Wait Until Keyword Succeeds  30s  5s  Scroll Element Into View  ${rmod}
        Wait Until Element Is Clicked  xpath=${rmod}
        ${serial_number}  Get Text  ${SN_TEXT}
        ${product_name}  Get Text  ${PN_TEXT}
        Append To List  ${rmod_sn}  ${serial_number}
        Append To List  ${rmod_pn}  ${product_name}
    END
    Set Test Variable  ${RMOD_SN}
    Set Test Variable  ${RMOD_PN}
    ${rmods_number}  Get Length  ${RMOD_SN}
    Set Test Variable  ${RMODS_NUMBER}


Get SMODs PN And SN
    ${smods_site_view}  Get Xpaths For SMODs
    ${smod_sn}  Create List
    ${smod_pn}  Create List
    FOR  ${smod}  IN  @{smods_site_view}
        Wait Until Keyword Succeeds  30s  5s  Scroll Element Into View  ${smod}
        Wait Until Element Is Clicked  xpath=${smod}
        ${serial_number}  Get Text  ${SN_TEXT}
        ${product_name}  Get Text  ${PN_TEXT}
        Append To List  ${smod_sn}  ${serial_number}
        Append To List  ${smod_pn}  ${product_name}
    END
    Set Test Variable  ${SMOD_SN}
    Set Test Variable  ${SMOD_PN}
    ${smods_number}  Get Length  ${SMOD_SN}
    Set Test Variable  ${SMODS_NUMBER}


Get BBMODs PN And SN
    ${bbmods_site_view}  Get Xpaths For BBMODs
    ${bbmod_sn}  Create List
    ${bbmod_pn}  Create List
    ${sn_text}  Catenate  SEPARATOR=  //*[contains(@class, 'details-panel-container')]/wf-panel/wf-panel-section/div/div/details-panel-content
    ...  /div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[1]/div/div/div/table/tbody/tr[3]/td[2]
    Set Test Variable  ${SN_TEXT}
    ${pn_text}  Catenate  SEPARATOR=  //*[contains(@class, 'details-panel-container')]/wf-panel/wf-panel-section/div/div/details-panel-content
    ...  /div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[1]/div/div/div/table/tbody/tr[1]/td[2]
    Set Test Variable  ${PN_TEXT}
    FOR  ${bbmod}  IN  @{bbmods_site_view}
        Wait Until Keyword Succeeds  30s  5s  Scroll Element Into View  ${bbmod}
        Wait Until Element Is Clicked  xpath=${bbmod}
        ${serial_number}  Get Text  ${SN_TEXT}
        ${product_name}  Get Text  ${PN_TEXT}
        Append To List  ${bbmod_sn}  ${serial_number}
        Append To List  ${bbmod_pn}  ${product_name}
    END
    Set Test Variable  ${BBMOD_SN}
    Set Test Variable  ${BBMOD_PN}
    ${bbmods_number}  Get Length  ${BBMOD_SN}
    Set Test Variable  ${BBMODS_NUMBER}


Get ${technology} Cell Name
    ${xpaths_cells}  Get Xpath List For Cells  ${technology}
    ${cells}  Create List
    FOR  ${cell}  IN  @{xpaths_cells}
        Wait Until Keyword Succeeds  30s  5s  Scroll Element Into View  ${cell}
        Click Element  ${cell}
        ${text}  Catenate  SEPARATOR=  //*[contains(@class, 'details-panel-container')]/wf-panel/wf-panel-section/div/div/details-panel-content
        ...  /div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div/span[2]
        ${cells_n}  Get Text  ${text}
        ${cell_name}  Convert To String  ${cells_n}
        Append To List  ${cells}  ${cell_name}
    END
    Set Test Variable  ${cells_${technology}}  ${cells}
    ${cells_number}  Get Length  ${cells_${technology}}
    Set Test Variable  ${${technology}_cells_number}  ${cells_number}


Site Report Check RMOD
    Log  Check RMODs in Site Report:  console=true
    Wait Until Element Is Visible  //*[contains(text(), "Radio Modules")]  10
    FOR  ${index}  IN RANGE  0  ${RMODS_NUMBER}
        ${status_sn}  Run Keyword And Return Status
        ...  Wait Until Element Is Enabled  //*[contains(text(), "${RMOD_SN}[${index}]")]  60
        ${status_pn}  Run Keyword And Return Status
        ...  Wait Until Element Is Enabled  //*[contains(text(), "${RMOD_PN}[${index}]")]  60
        Wait Until Element Is Clicked  //*[contains(text(), "${RMOD_SN}[${index}]")]  60
        Run Keyword If  ${status_sn} and ${status_pn}
        ...  Log  RMOD ${RMOD_PN}[${index}] with Serial Number ${RMOD_SN}[${index}] is visible in Site Report![OK]  console=true
        ...  ELSE
        ...  Fail  RMOD ${RMOD_PN}[${index}] with Serial Number ${RMOD_SN}[${index}] is not visible in Site Report![NOK]
    END
    Wait Until Keyword Succeeds  60  5
    ...  Double Click Element  //*[contains(text(), "Radio Modules")]


Site Report Check BBMOD
    Log  Check BBMODs in Site Report:  console=true
    Wait Until Element Is Visible  //*[contains(text(), "Baseband Modules ")]  10
    FOR  ${index}  IN RANGE  0  ${BBMODS_NUMBER}
        ${status_sn}  Run Keyword And Return Status
        ...  Wait Until Element Is Enabled  //*[contains(text(), "${BBMOD_SN}[${index}]")]  60
        ${status_pn}  Run Keyword And Return Status
        ...  Wait Until Element Is Enabled  //*[contains(text(), "${BBMOD_PN}[${index}]")]  60
        Wait Until Element Is Clicked  //*[contains(text(), "${BBMOD_SN}[${index}]")]  60
        Run Keyword If  ${status_sn} and ${status_pn}
        ...  Log  BBMOD ${BBMOD_PN}[${index}] with Serial Number ${BBMOD_SN}[${index}] is visible in Site Report![OK]  console=true
        ...  ELSE
        ...  Fail  BBMOD ${BBMOD_PN}[${index}] with Serial Number ${BBMOD_SN}[${index}] is not visible in Site Report![NOK]
    END
    Wait Until Keyword Succeeds  60  5
    ...  Double Click Element  //*[contains(text(), "Baseband Modules ")]


Site Report Check SMOD
    Log  Check SMODs in Site Report:  console=true
    Wait Until Element Is Visible  //*[contains(text(), "System Modules ")]  10
    FOR  ${index}  IN RANGE  0  ${SMODS_NUMBER}
        ${status_sn}  Run Keyword And Return Status
        ...  Wait Until Element Is Enabled  //*[contains(text(), "${SMOD_SN}[${index}]")]  60
        ${status_pn}  Run Keyword And Return Status
        ...  Wait Until Element Is Enabled  //*[contains(text(), "${SMOD_PN}[${index}]")]  60
        Wait Until Element Is Clicked  //*[contains(text(), "${SMOD_SN}[${index}]")]  60
        Run Keyword If  ${status_sn} and ${status_pn}
        ...  Log  SMOD ${SMOD_PN}[${index}] with Serial Number ${SMOD_SN}[${index}] is visible in Site Report![OK]  console=true
        ...  ELSE
        ...  Fail  SMOD ${SMOD_PN}[${index}] with Serial Number ${SMOD_SN}[${index}] is not visible in Site Report![NOK]
    END
    Wait Until Keyword Succeeds  60  5
    ...  Double Click Element  //*[contains(text(), "System Modules ")]


Check Cells In Site Report
    Log  Check cells in Site Report:  console=true
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Wait Until Keyword Succeeds  60  5
    ...  Double Click Element  //*[contains(text(), "NR Cell Groups")]
    Wait Until Element Is Enabled  //*[contains(text(), "Cells")]  60
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Site Report Check LTE Cells
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Site Report Check NR Cells
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Site Report Check GSM Cells
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Site Report Check WCDMA Cells


Site Report Check ${technology} Cells
    FOR  ${index}  IN RANGE  0  ${${technology}_CELLS_NUMBER}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Element Is Enabled  //*[contains(text(), "${CELLS_${technology}}[${index}]")]  60
        Run Keyword If  ${status}
        ...  Log  ${technology} cell: ${CELLS_${technology}}[${index}] is visible in Site Report![OK]  console=true
        ...  ELSE
        ...  Fail  ${technology} cell: ${CELLS_${technology}}[${index}]is not visible in Site Report![NOK]
    END


Save Report
    Log  Save Report  console=true
    ${im_bts_id}  Admin Get BTS Id
    ${status}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(@a-text, 'Save Report')]
    Sleep  10s
    Run Keyword If  ${status}
    ...  Log  Saving Report has been performed successfully!  console=true
    ...  ELSE
    ...  Set Test Restriction  Save Report action was not performed!
    Move File  /home/ute/Downloads/Site_Report_*.zip  ${BTS_FILES}/Site_Report_SBTS-${im_bts_id}.zip


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
