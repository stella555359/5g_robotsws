*** Settings ***
Documentation
    ...  This TC is created to check BTS Start-up View in different situations.
    ...  Check in BTS Start-up view for NR cells onAir to be visible status Succeeded!
    ...  Check in BTS Start-up view for blocked NR cells to be visible status Ongoing!
    ...  Reset the specific RMOD and check in BTS Start-up view for failed NR cells to be visible status Failed!
    ...  Check in BTS Start-up view for deleted NR RAT to be visible status N/A!(Loading the specific SCF without NR RAT)
    ...  Loading initial SCF back on SBTS.
    ...  All the steps above are performed for the LTE, WCDMA and GSM RATs as well, if exists.
    ...  Check in BTS Start-up view for System Modules/Baseband Modules onAir to be visible status Succeeded!
    ...  Reset one BBMOD and check in BTS Start-up view for System Modules/Baseband Modules to be visible status Ongoing!
    ...  Send fault 252 and check in BTS Start-up view for System Modules/Baseband Modules to be visible status Failed!
    ...  Clear fault 252, reset SBTS and verify all requires states.
    ...  Check in BTS Start-up view for Radio Modules onAir to be visible status Succeeded!
    ...  Reset one BBMOD and check in BTS Start-up view for Radio Modules to be visible status Ongoing!
    ...  Send fault 1116 and check in BTS Start-up view for Radio Modules to be visible status Failed!
    ...  Reset SBTS and verify all requires states.
    ...  Recommissioning is performed if test will be failed.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1800s  # Timeout for SBTS to recover
${SCF_NR_LTE_NA}  ${EMPTY}  # Mandatory! The name of SCF without 5G and 4G RATs. Should be exist in testline_configuration.
${SCF_WCDMA_GSM_NA}  ${EMPTY}  # Mandatory! The name of SCF without 3G and 2G RATs. Should be exist in testline_configuration.
${RMOD_TYPE}  FXED  # RMOD type that must be failed.
${BBMOD_VERTICAL_POSITION}  2  # BBMOD vertical position that must be failed.


*** Keywords ***
TC__WebEM__BTS_Startup_view_show_resources
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26764
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26764 - Initial TAT creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27750 - Improving the TC
    ...  - 11.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28514 - Increase the number of fault loops for releases above SBTS24R3
    ...  - 16.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28623 - Fix reset method for ABIA BBMODs
    ...  - 14.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28749 - Send fault 252 for BBMOD to be failed
    ...  - 22.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29101 - Multiple changes
    ...  - 26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29283 - Adding cells verification after sending the fault on RMOD
    ...  - 26.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29742 - Add 5 minutes after SBTS is onAir and sending the fault again
    ...  - 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30177 - Create Confirm Screen Lock Pop-Up If It's Visible KW
    ...  - 12.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30280 - Multiple changes
    ...  - 21.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30405 - ABIA BBMOD with LTE mapped on it can reset

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS24

    Step0: Set Preconditions
    Step1: Check BTS Start-up View For NR Cells
    Step2: Check BTS Start-up View For LTE Cells
    Step3: Check BTS Start-up View For WCDMA Cells
    Step4: Check BTS Start-up View For GSM Cells
    Step5: Check BTS Start-up View For System Modules/Baseband Modules
    Step6: Check BTS Start-up View For Radio Modules


Step0: Set Preconditions
    IF  ${SCF_COUNT_NR} or ${SCF_COUNT_LTE}  Should Not Be Empty  ${SCF_NR_LTE_NA}
    ...  SCF name without NR and LTE cells must be specified, please provide it and retest.
    IF  ${SCF_COUNT_WCDMA} or ${SCF_COUNT_GSM}  Should Not Be Empty  ${SCF_WCDMA_GSM_NA}
    ...  SCF name without WCDMA and GSM cells must be specified, please provide it and retest.
    Set Window Size  ${1920}  ${2000}


Step1: Check BTS Start-up View For NR Cells
    Log  \nStep1: Check BTS Start-up view for NR cells  console=true
    IF  ${SCF_COUNT_NR} == 0
        Log  NR cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view for NR cells onAir to be visible status Succeeded!  console=true
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  NR  Succeeded  ${SCF_COUNT_NR}
    Log  Check in BTS Start-up view for blocked NR cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View  NR
    Log  Check in BTS Start-up view for failed NR cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View  NR
    IF  ${SCF_COUNT_LTE}
        Log  N/A check will be performed in the next step!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view for deleted NR RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_NR_LTE_NA}  GSM  GNCEL  WCDMA  WNCEL
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  NR  N/A
    Load Initial SCF
    Close Browser
    Open WebEM  timeout=60s
    Set Window Size  ${1920}  ${2000}


Step2: Check BTS Start-up View For LTE Cells
    Log  \nStep2: Check BTS Start-up view for LTE cells  console=true
    IF  ${SCF_COUNT_LTE} == 0
        Log  LTE cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view for LTE cells onAir to be visible status Succeeded!  console=true
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  LTE  Succeeded  ${SCF_COUNT_LTE}
    Log  Check in BTS Start-up view for blocked LTE cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View  LTE
    Log  Check in BTS Start-up view for failed LTE cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View  LTE
    Log  Check in BTS Start-up view for deleted LTE RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_NR_LTE_NA}  GSM  GNCEL  WCDMA  WNCEL
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  LTE  N/A
    IF  ${SCF_COUNT_NR}
        Log  Check in BTS Start-up view for deleted NR RAT to be visible status N/A!  console=true
        Open BTS Start-up View pop-up
        BTS Start-up View For Cells  NR  N/A
    END
    Load Initial SCF
    Close Browser
    Open WebEM  timeout=60s
    Set Window Size  ${1920}  ${2000}


Step3: Check BTS Start-up View For WCDMA Cells
    Log  \nStep3: Check BTS Start-up view for WCDMA cells  console=true
    IF  ${SCF_COUNT_WCDMA} == 0
        Log  WCDMA cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view for WCDMA cells onAir to be visible status Succeeded!  console=true
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  WCDMA  Succeeded  ${SCF_COUNT_WCDMA}
    Log  Check in BTS Start-up view for blocked WCDMA cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View  WCDMA
    Log  Check in BTS Start-up view for failed WCDMA cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View  WCDMA
    IF  ${SCF_COUNT_GSM}
        Log  N/A check will be performed in the next step!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view for deleted WCDMA RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_WCDMA_GSM_NA}  NR  NRCEL  LTE  LNCEL
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  WCDMA  N/A
    Load Initial SCF
    Close Browser
    Open WebEM  timeout=60s
    Set Window Size  ${1920}  ${2000}


Step4: Check BTS Start-up View For GSM Cells
    Log  \nStep4: Check BTS Start-up view for GSM cells  console=true
    IF  ${SCF_COUNT_GSM} == 0
        Log  GSM cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view for GSM cells onAir to be visible status Succeeded!  console=true
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  GSM  Succeeded  ${SCF_COUNT_GSM}
    Log  Check in BTS Start-up view for blocked GSM cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View  GSM
    Log  Check in BTS Start-up view for failed GSM cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View  GSM
    Log  Check in BTS Start-up view for deleted GSM RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_WCDMA_GSM_NA}  NR  NRCEL  LTE  LNCEL
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  GSM  N/A
    IF  ${SCF_COUNT_WCDMA}
        Log  Check in BTS Start-up view for deleted WCDMA RAT to be visible status N/A!  console=true
        Open BTS Start-up View pop-up
        BTS Start-up View For Cells  WCDMA  N/A
    END
    Load Initial SCF
    Close Browser
    Open WebEM  timeout=60s
    Set Window Size  ${1920}  ${2000}


Step5: Check BTS Start-up View For System Modules/Baseband Modules
    Log  \nStep5: Check BTS Start-up view for System Modules/Baseband Modules  console=true
    Log  Check in BTS Start-up view for System Modules/Baseband Modules onAir to be visible status Succeeded!  console=true
    BTS Start-up View For HW  SMOD_BBMOD  Succeeded
    Log  Check in BTS Start-up view for System Modules/Baseband Modules to be visible status Ongoing!  console=true
    Reset One Baseband Module
    BTS Start-up View For HW  SMOD_BBMOD  Ongoing
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  Check in BTS Start-up view for System Modules/Baseband Modules to be visible status Failed!  console=true
    Go To Site View
    Open BTS Start-up View pop-up
    Send Or Clear Fault 252  action=send
    Check BTS Start-up View For HW  SMOD_BBMOD  Failed
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button
    ...  10  1
    IF  '${GUI_VERSION}' == 'new'  Close Status Menu
    [Teardown]  Clear Fault For Step5


Clear Fault For Step5
    Log  Clear fault 252.  console=true
    Sleep  30s  Wait for registry to be readable.
    Send Or Clear Fault 252  action=clear
    Sleep  10s  Time for command to be send
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Sleep  300s  Time for fault to be clear successfully.
    Close Browser
    Open WebEM  timeout=60s
    Set Window Size  ${1920}  ${2000}


Step6: Check BTS Start-up View For Radio Modules
    Log  \nStep6: Check BTS Start-up view for Radio Modules  console=true
    Log  Check in BTS Start-up view for Radio Modules onAir to be visible status Succeeded!  console=true
    BTS Start-up View For HW  RMOD  Succeeded
    Log  Check in BTS Start-up view for Radio Modules to be visible status Ongoing!  console=true
    Reset One Baseband Module
    BTS Start-up View For HW  RMOD  Ongoing
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  Check in BTS Start-up view for Radio Modules to be visible status Failed!  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'  Repeat Keyword  3 times  Send Fault On RMOD
    ${rmod_side}  ${rmod_ip}  ${stored_role}  ${rmod_serial_number}  Set RMOD Parameters By RMOD Type  ${RMOD_TYPE}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${rmod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1116 0 0 0 0 0 0
    Log  Fault sent on ${RMOD_TYPE} with SN:${rmod_serial_number}.  console=true
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Sleep  60s  Time for fault to be send.
    BTS Start-up View For HW  RMOD  Failed
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State


Send Fault On RMOD
    ${rmod_side}  ${rmod_ip}  ${stored_role}  ${rmod_serial_number}  Set RMOD Parameters By RMOD Type  ${RMOD_TYPE}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${rmod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1116 0 0 0 0 0 0
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  coam.Assert Any  RMOD  operationalState=${DISABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Sleep  300s  Time for fault to be clear successfully.
    Login On WebEM If Lock Screen Or Logout Performed
    Confirm Screen Lock Pop-Up If It's Visible
    BTS Start-up View For HW  RMOD  Succeeded
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections


BTS Start-up View For Cells
    [Arguments]  ${rat_name}  ${expected_status}  ${cells_number}=${EMPTY}

    IF  '${expected_status}' == 'N/A'
        Check BTS Start-up View For N/A Cells  ${rat_name}
    ELSE
        Check BTS Start-up View For Cells  ${rat_name}  ${expected_status}  ${cells_number}
    END
    IF  '${GUI_VERSION}' == 'new'  Close Status Menu


Check BTS Start-up View For Cells
    [Arguments]  ${rat}  ${expected_status}  ${cells_number}

    ${rat_path_dictionary}  Create Dictionary  GSM=1  WCDMA=2  LTE=3  NR=4
    ${rat_index}  Set Variable  ${rat_path_dictionary}[${rat}]
    ${rat_status_in_startup}  Get Text  //div[@class='bts-start-view-cells-status']/div[${rat_index}]/div[1]/span
    ${cells_failed_in_startup}  Get Text  //div[@class='bts-start-view-cells-status']/div[${rat_index}]/div[4]/span
    IF  '${rat_status_in_startup}' == '${expected_status}'
        Log  ${rat} cells status in BTS start-up view is ${expected_status} (as expected)!  console=true
    ELSE
        Fail  ${rat} cells status in BTS start-up view is ${rat_status_in_startup} (not as expected)!
    END
    ${cells_in_configuration_in_startup}  Get Text  //div[@class='bts-start-view-cells-status']/div[${rat_index}]/div[2]/span
    ${cells_onair_in_startup}  Get Text  //div[@class='bts-start-view-cells-status']/div[${rat_index}]/div[3]/span
    ${cells_number}  Convert To String  ${cells_number}
    IF  '${expected_status}' == 'Succeeded'
        Should Be Equal  ${cells_number}  ${cells_onair_in_startup}
        Should Be Equal  ${cells_failed_in_startup}  0
    ELSE IF  '${expected_status}' == 'Failed'
        Should Be Equal  ${cells_number}  ${cells_failed_in_startup}
    ELSE IF  '${expected_status}' == 'Ongoing'
        Should Be Equal  ${cells_number}  ${cells_in_configuration_in_startup}
        Should Be Equal  ${cells_failed_in_startup}  0
    END
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button  60


Check BTS Start-up View For N/A Cells
    [Arguments]  ${rat}

    ${rat_path_dictionary}  Create Dictionary  GSM=1  WCDMA=2  LTE=3  NR=4
    ${rat_index}  Set Variable  ${rat_path_dictionary}[${rat}]
    ${rat_status_in_startup}  Get Text  //div[@class='bts-start-view-cells-status']/div[${rat_index}]/div[1]/span
    IF  '${rat_status_in_startup}' == 'N/A'
        Log  ${rat} cells status in BTS start-up view is ${rat_status_in_startup} (as expected)!  console=true
    ELSE
        Fail  ${rat} cells status in BTS start-up view is ${rat_status_in_startup} (not as expected)!
    END
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button  60


BTS Start-up View For HW
    [Arguments]  ${hw_name}  ${expected_status}

    Open BTS Start-up View pop-up
    Check BTS Start-up View For HW  ${hw_name}  ${expected_status}
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button
    ...  10  1
    IF  '${GUI_VERSION}' == 'new'  Close Status Menu


Check BTS Start-up View For HW
    [Arguments]  ${hw}  ${expected_status}

    ${hw_path_dictionary}  Create Dictionary  SMOD_BBMOD=1  RMOD=2
    ${hw_index}  Set Variable  ${hw_path_dictionary}[${hw}]
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Contains  //div[@class='bts-start-view-hardware-status']/div[${hw_index}]/div[1]/span  ${expected_status}  timeout=60
    IF  ${status}
        Log  ${hw} status in BTS start-up view is ${expected_status} (as expected)!  console=true
    ELSE
        Fail  ${hw} status in BTS start-up view is ${expected_status} (not as expected)!
    END


Block And Unblock Cells And Check Status In BTS Start-up View
    [Arguments]  ${rat}

    Log  Blocking ${rat} cells is ongoing  console=true
    Wait Until Keyword Succeeds  60  5
    ...  Block Cells  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check ${rat} Cells Blocking State To Be Blocked
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  ${rat}  Ongoing  ${SCF_COUNT_${rat}}
    Log  Unblocking ${rat} cell is ongoing  console=true
    Wait Until Keyword Succeeds  60  5
    ...  Unblock Cells  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check ${rat} Cells Blocking State To Be Unblocked
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check ${rat} Cells Availability Status To Be Online|-
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  ${rat}  Succeeded  ${SCF_COUNT_${rat}}


Reset RMOD With Specific Cells And Check Status In BTS Start-up View
    [Arguments]  ${rat}

    ${cells_name_dict}  Create Dictionary  NR=NRCEL  LTE=LNCEL  WCDMA=WNCEL  GSM=GNCEL
    ${rmods_id_list}  Get A List With All Rmods Id With Specific Cells On  ${cells_name_dict}[${rat}]
    ${rmod_id}  Evaluate  random.choice(${rmods_id_list})  random
    ${cells_on_rmod}  coam.Get Cell Mapping By Module Id  ${rmod_id}
    ${specific_rat_cells_on_rmod}  Create List
    FOR  ${cell_on_rmod}  IN  @{cells_on_rmod}
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cell_on_rmod}  ${cells_name_dict}[${rat}]
        IF  ${status}  Append To List  ${specific_rat_cells_on_rmod}  ${cell_on_rmod}
    END
    IF  '${rat}' == 'LTE'
        FOR  ${cell}  IN  @{specific_rat_cells_on_rmod}
            ${cell_parameters}  coam.Get Parameters For  LNCEL  ${cell}
            ${status}  Run Keyword And Return Status  Should Contain  ${cell_parameters}[technology]  IoT
            IF  ${status}  Remove Values From List  ${specific_rat_cells_on_rmod}  ${cell}
        END
    END
    Log  ${rmod_id} with cells ${specific_rat_cells_on_rmod} will be choose to reset!  console=true
    FOR  ${rmod_xpath}  IN  @{RMODS_XPATH}
        Click Element  ${rmod_xpath}
        ${rmod_name_details}  Get Text  //div[@class='hardware-details-info']/div[2]/div[1]/div[2]/span
        IF  '${rmod_name_details}' == 'Runtime object: ${rmod_id}'
            Reset Specific RMOD And Check BTS Start-up View  ${rat}  ${specific_rat_cells_on_rmod}
            BREAK
        END
    END


Reset Specific RMOD And Check BTS Start-up View
    [Arguments]  ${rat}  ${cells_on_rmod}

    ${no_cells}  Get Length  ${cells_on_rmod}
    Click Element  //*[@ui-tooltip='Reset']
    Click Element  //*[contains(@a-text, 'Reset')]/button
    Open BTS Start-up View pop-up
    Check Cells On RMOD Availability Status To Be Failed  ${rat}  ${cells_on_rmod}
    BTS Start-up View For Cells  ${rat}  Failed  ${no_cells}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check ${rat} Cells Availability Status To Be Online|-
    Open BTS Start-up View pop-up
    BTS Start-up View For Cells  ${rat}  Succeeded  ${SCF_COUNT_${rat}}


Check Cells On RMOD Availability Status To Be Failed
    [Arguments]  ${rat}  ${cells_on_rmod}

    ${cells_name_dict}  Create Dictionary  NR=NRCEL  LTE=LNCEL  WCDMA=WNCEL  GSM=GNCEL
    FOR  ${cell}  IN  @{cells_on_rmod}
        Assert  ${cells_name_dict}[${rat}]  ${cell}  availabilityStatus=${FAILED}  timeout=300
    END
    Sleep  5s  Time for cells to be failed also in webem site view.


Check ${rat} Cells Blocking State To Be ${state}
    ${cells_status}  Get States For Cells In RAT  ${rat}
    FOR  ${cell}  IN  @{cells_status.keys()}
        Should Be Equal  ${cells_status}[${cell}][Blocking state]  ${state}
    END


Check ${rat} Cells Availability Status To Be ${state}
    ${cells_status}  Get States For Cells In RAT  ${rat}
    FOR  ${cell}  IN  @{cells_status.keys()}
        Should Match Regexp  ${cells_status}[${cell}][Availability status]  ${state}
    END


Get A List With All Rmods Id With Specific Cells On
    [Arguments]  ${cells_tachnology}

    ${rmod_ids}  coam.Get Ids For All  RMOD
    ${rmods_list}  Create List
    FOR  ${rmod_id}  IN  @{rmod_ids}
        ${cells_on_rmod}  coam.Get Cell Mapping By Module Id  ${rmod_id}
        ${cells_ids}  Get Cells Id On The Specific Rmod  ${cells_on_rmod}
        ${status}  Run Keyword And Return Status
        ...  Should Contain Match  ${cells_ids}  ${cells_tachnology}*
        IF  ${status}  Append To List  ${rmods_list}  ${rmod_id}
    END
    ${rmods_id}  Create List
    FOR  ${rmod_dn}  IN  @{rmods_list}
        ${last_part}  Fetch From Right  ${rmod_dn}  /
        Append To List  ${rmods_id}  ${last_part}
    END

    [Return]  ${rmods_id}


Get Cells Id On The Specific Rmod
    [Arguments]  ${cells_on_rmod}

    ${cells_id}  Create List
    FOR  ${cell_dn}  IN  @{cells_on_rmod}
        ${last_part}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${last_part}  _R
        Append To List  ${cells_id}  ${cell_id}
    END

    [Return]  ${cells_id}


Reset One Baseband Module
    ${abia_bbmod_with_lte}  Get ABIA BBMOD List With LTE Mapped On It
    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Click Element  ${xpath}
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
        ${bbmod_r_object}  Get Text  //div[@class='hardware-details-info']/div[2]/div[1]/div[2]/span
        ${bbmod_r_object}  Fetch From Right  ${bbmod_r_object}  :${SPACE}
        Log  Reset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
        Click Element  ${xpath}/div/div[1]
        ${status_abia}  Run Keyword And Return Status  List Should Contain Value  ${abia_bbmod_with_lte}  ${bbmod_r_object}
        IF  '${bbmod_name}'=='ABIA' and '${ENB_BRANCH}'>='SBTS25R2' and ${status_abia}==${FALSE}
            Try To Reset ABIA BBMOD Without LTE Mapped On It  ${xpath}  ${bbmod_number}
            CONTINUE
        END
        ${status_reset}  Run Keyword And Return Status
        ...  Element Should Be Enabled  ${xpath}/div/div[1]/span/div/div[1]/button
        IF  ${status_reset}
            Reset Baseband Module And Verify If The Status Is Offline  ${bbmod_number}  ${bbmod_name}  ${xpath}
            BREAK
        ELSE
            Click Element  ${xpath}/div/div[1]
            Log  ${bbmod_number}: ${bbmod_name} Reset button is disabled because it doesn't support 5G![OK]  console=true
        END
    END


Reset Baseband Module And Verify If The Status Is Offline
    [Arguments]  ${bbmod_number}  ${bbmod_name}  ${xpath}

    Log  ${bbmod_number}: ${bbmod_name} Reset button is enabled because it supports 5G![OK]  console=true
    Click Element  ${xpath}/div/div[1]/span/div/div[1]/button
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Log  ${bbmod_number}: ${bbmod_name} Reset is ongoing!  console=true
    Wait Until Keyword Succeeds  300  10
    ...  Assert Any  BBMOD  availabilityStatus=${OFFLINE}
    Sleep  15s  Time for Ongoing to be visible in BTS Start-up view.


Change The SCF With A Specific One
    [Arguments]  ${new_scf}  ${first_rat}  ${first_cells}  ${second_rat}  ${second_cells}

    ${config_path}  Fetch From Left  ${COMMISSIONING_PATH}  BTS
    ${specific_scf}  Set Variable  ${config_path}${new_scf}
    Log  Loading SCF ${new_scf} will be performed...  console=true
    ${commissioning_status}  Run Keyword And Return Status
    ...  coam.Perform Commissioning  bts_id=${BTS_ID}
    ...  scf_file=${specific_scf}
    ...  skip_parameter_relation_errors=${TRUE}
    ...  should_activate=${TRUE}
    ...  timeout=1200
    IF  ${commissioning_status}
        Log  Loading Scf ${new_scf} is performed.[OK]  console=true
    ELSE
        Fail  Loading Scf ${new_scf} is failed.[NOK]
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check The Specific Cells To Be Enabled  ${first_rat}  ${first_cells}  ${second_rat}  ${second_cells}
    Close Startup View If Visible


Check The Specific Cells To Be Enabled
    [Arguments]  ${first_rat}  ${first_cells}  ${second_rat}  ${second_cells}

    Run Keyword If  ${SCF_COUNT_${first_rat}}
    ...  Assert Every  ${first_cells}  operationalState=${ENABLED}  timeout=60
    Run Keyword If  ${SCF_COUNT_${second_rat}}
    ...  Assert Every  ${second_cells}  operationalState=${ENABLED}  timeout=60


Load Initial SCF
    Log  Loading initial SCF will be performed...  console=true
    ${commissioning_status}  Run Keyword And Return Status
    ...  coam.Perform Commissioning  bts_id=${BTS_ID}
    ...  scf_file=${COMMISSIONING_PATH}
    ...  skip_parameter_relation_errors=${TRUE}
    ...  should_activate=${TRUE}
    ...  timeout=600
    IF  ${commissioning_status}
        Log  Loading initial SCF is performed successfully.[OK]  console=true
    ELSE
        Fail  Loading initial SCF is failed.[NOK]
    END
    Log  Wait for all cells to be onAir...  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Close Startup View If Visible


Send Or Clear Fault 252
    [Arguments]  ${action}

    Open Connection To Primary Core
    IF  '${action}'=='clear'
        SSHLibrary.Execute Command  bmutool -s ${BBMOD_VERTICAL_POSITION} -r 0x1F 1
        RETURN
    END
    SSHLibrary.Execute Command  bmutool -s ${BBMOD_VERTICAL_POSITION} -r 0x10 0xA0
    SSHLibrary.Execute Command  bmutool -s ${BBMOD_VERTICAL_POSITION} -r 0x11 0xA0

    [Teardown]  SSHLibrary.Close Connection


Confirm Screen Lock Pop-Up If It's Visible
    ${session_locked}  Run Keyword and Return Status  Element Should Be Visible  //*[contains(text(), "Screen Lock")]
    IF  ${session_locked}
       Log  Screen lock pop-up is visible!  console=true
       Wait Until Element Is Clicked
       ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/screen-lock-warning-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
       Sleep  5s  Time for pop-up to be closed.
    END


TC Setup
    Common Test Setup  tc_name=WebEM__BTS_Startup_view_show_resources
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Load Initial SCF
    WebEM Teardown
    Common Test Teardown
