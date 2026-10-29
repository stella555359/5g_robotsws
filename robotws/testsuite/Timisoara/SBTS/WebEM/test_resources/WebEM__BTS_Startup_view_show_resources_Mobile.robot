*** Settings ***
Documentation
    ...  This TC is created to check BTS Start-up View via Mobile in different situations.
    ...  Check in BTS Start-up view via Mobile for NR cells onAir to be visible status Succeeded!
    ...  Check in BTS Start-up view via Mobile for blocked NR cells to be visible status Ongoing!
    ...  Reset the specific RMOD and check in BTS Start-up view via Mobile for failed NR cells to be visible status Failed!
    ...  Check in BTS Start-up view via Mobile for deleted NR RAT to be visible status N/A!(Loading the specific SCF without NR RAT)
    ...  Loading initial SCF back on SBTS.
    ...  All the steps above are performed for the LTE, WCDMA and GSM RATs as well, if exists.
    ...  Check in BTS Start-up view via Mobile for System Modules/Baseband Modules onAir to be visible status Succeeded!
    ...  Reset one BBMOD and check in BTS Start-up view via Mobile for System Modules/Baseband Modules to be visible status Ongoing!
    ...  Send fault 252 and check in BTS Start-up view via Mobile for System Modules/Baseband Modules to be visible status Failed!
    ...  Clear fault 252, reset SBTS and verify all requires states.
    ...  Check in BTS Start-up view via Mobile for Radio Modules onAir to be visible status Succeeded!
    ...  Reset one BBMOD and check in BTS Start-up view via Mobile for Radio Modules to be visible status Ongoing!
    ...  Send fault 1116 and check in BTS Start-up view via Mobile for Radio Modules to be visible status Failed!
    ...  Reset SBTS and verify all requires states.
    ...  Recommissioning is performed if test will be failed.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1800s  # Timeout for SBTS to recover
${SCF_NR_LTE_NA}  ${EMPTY}  # Mandatory! The name of SCF without 5G and 4G RATs. Should be exist in testline_configuration.
${SCF_WCDMA_GSM_NA}  ${EMPTY}  # Mandatory! The name of SCF without 3G and 2G RATs. Should be exist in testline_configuration.
${RMOD_TYPE}  FXDB  # RMOD type that must be failed.
${BBMOD_VERTICAL_POSITION}  3  # BBMOD vertical position that must be failed.


*** Keywords ***
TC__WebEM__BTS_Startup_view_show_resources_Mobile
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27163
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27163 - Initial TAT creation
    ...  - 11.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28514 - Increase the number of fault loops for releases above SBTS24R3
    ...  - 14.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28749 - Send fault 252 for BBMOD to be failed
    ...  - 13.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29102 - Multiple changes
    ...  - 26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29283 - Adding cells verification after sending the fault on RMOD
    ...  - 04.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29588 - Enhancement for RMODs that will be reset
    ...  - 26.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29768 - Add 5 minutes after SBTS is onAir and sending the fault again

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS24

    Step0: Set Preconditions
    Step1: Check BTS Start-up View Via Mobile For NR Cells
    Step2: Check BTS Start-up View Via Mobile For LTE Cells
    Step3: Check BTS Start-up View Via Mobile For WCDMA Cells
    Step4: Check BTS Start-up View Via Mobile For GSM Cells
    Step5: Check BTS Start-up View Via Mobile For System Modules/Baseband Modules
    Step6: Check BTS Start-up View Via Mobile For Radio Modules


Step0: Set Preconditions
    Log  \nStep0: Set Preconditions  console=true
    IF  ${SCF_COUNT_NR} or ${SCF_COUNT_LTE}  Should Not Be Empty  ${SCF_NR_LTE_NA}
    ...  SCF name without NR and LTE cells must be specified, please provide it and retest.
    IF  ${SCF_COUNT_WCDMA} or ${SCF_COUNT_GSM}  Should Not Be Empty  ${SCF_WCDMA_GSM_NA}
    ...  SCF name without WCDMA and GSM cells must be specified, please provide it and retest.
    ${cells_name_dict}  Create Dictionary  NR=NRCEL  LTE=LNCEL  WCDMA=WNCEL  GSM=GNCEL
    Set Test Variable  ${CELLS_NAME_DICT}
    ${RMODS_NAME}  Get RMODs Name From Site Report
    Set Test Variable  ${RMODS_NAME}


Step1: Check BTS Start-up View Via Mobile For NR Cells
    Log  \nStep1: Check BTS Start-up view via Mobile for NR cells  console=true
    IF  ${SCF_COUNT_NR} == 0
        Log  NR cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view via Mobile for NR cells onAir to be visible status Succeeded!  console=true
    BTS Start-up View Via Mobile For Cells  NR  Succeeded
    Log  Check in BTS Start-up view via Mobile for blocked NR cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View Via Mobile  NR
    Log  Check in BTS Start-up view via Mobile for failed NR cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View Via Mobile  NR
    Log  Check in BTS Start-up view via Mobile for deleted NR RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_NR_LTE_NA}  GSM  GNCEL  WCDMA  WNCEL
    BTS Start-up View Via Mobile For Cells  NR  N/A
    Load Initial SCF


Step2: Check BTS Start-up View Via Mobile For LTE Cells
    Log  \nStep2: Check BTS Start-up view via Mobile for LTE cells  console=true
    IF  ${SCF_COUNT_LTE} == 0
        Log  LTE cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view via Mobile for LTE cells onAir to be visible status Succeeded!  console=true
    BTS Start-up View Via Mobile For Cells  LTE  Succeeded
    Log  Check in BTS Start-up view via Mobile for blocked LTE cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View Via Mobile  LTE
    Log  Check in BTS Start-up view via Mobile for failed LTE cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View Via Mobile  LTE
    Log  Check in BTS Start-up view via Mobile for deleted LTE RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_NR_LTE_NA}  GSM  GNCEL  WCDMA  WNCEL
    BTS Start-up View Via Mobile For Cells  LTE  N/A
    Load Initial SCF


Step3: Check BTS Start-up View Via Mobile For WCDMA Cells
    Log  \nStep3: Check BTS Start-up view via Mobile for WCDMA cells  console=true
    IF  ${SCF_COUNT_WCDMA} == 0
        Log  WCDMA cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view via Mobile for WCDMA cells onAir to be visible status Succeeded!  console=true
    BTS Start-up View Via Mobile For Cells  WCDMA  Succeeded
    Log  Check in BTS Start-up view via Mobile for blocked WCDMA cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View Via Mobile  WCDMA
    Log  Check in BTS Start-up view via Mobile for failed WCDMA cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View Via Mobile  WCDMA
    Log  Check in BTS Start-up view via Mobile for deleted WCDMA RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_WCDMA_GSM_NA}  NR  NRCEL  LTE  LNCEL
    BTS Start-up View Via Mobile For Cells  WCDMA  N/A
    Load Initial SCF


Step4: Check BTS Start-up View Via Mobile For GSM Cells
    Log  \nStep4: Check BTS Start-up view via Mobile for GSM cells  console=true
    IF  ${SCF_COUNT_GSM} == 0
        Log  GSM cells does not exist, this KW is skipped!  console=true
        RETURN
    END
    Log  Check in BTS Start-up view via Mobile for GSM cells onAir to be visible status Succeeded!  console=true
    BTS Start-up View Via Mobile For Cells  GSM  Succeeded
    Log  Check in BTS Start-up view via Mobile for blocked GSM cells to be visible status Ongoing!  console=true
    Block And Unblock Cells And Check Status In BTS Start-up View Via Mobile  GSM
    Log  Check in BTS Start-up view via Mobile for failed GSM cells to be visible status Failed!  console=true
    Reset RMOD With Specific Cells And Check Status In BTS Start-up View Via Mobile  GSM
    Log  Check in BTS Start-up view via Mobile for deleted GSM RAT to be visible status N/A!  console=true
    Change The SCF With A Specific One  ${SCF_WCDMA_GSM_NA}  NR  NRCEL  LTE  LNCEL
    BTS Start-up View Via Mobile For Cells  GSM  N/A
    Load Initial SCF


Step5: Check BTS Start-up View Via Mobile For System Modules/Baseband Modules
    Log  \nStep5: Check BTS Start-up view via Mobile for System Modules/Baseband Modules  console=true
    Log  Check in BTS Start-up view via Mobile for System Modules/Baseband Modules onAir to be visible status Succeeded!  console=true
    BTS Start-up View Via Mobile For HW  SMOD_BBMOD  Succeeded
    Log  Check in BTS Start-up view via Mobile for System Modules/Baseband Modules to be visible status Ongoing!  console=true
    Reset One Baseband Module
    BTS Start-up View Via Mobile For HW  SMOD_BBMOD  Ongoing
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  Check in BTS Start-up view via Mobile for System Modules/Baseband Modules to be visible status Failed!  console=true
    Run Keyword And Ignore Error  Go To Site View Via Mobile
    Open BTS Start-up View Pop-up Via Mobile
    Send Or Clear Fault 252  action=send
    Check BTS Start-up View Via Mobile For HW  SMOD_BBMOD  Failed
    Wait Until Element Is Clicked For Mobile
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button  60
    [Teardown]  Clear Fault For Step5

Clear Fault For Step5
    Send Or Clear Fault 252  action=clear
    Sleep  10s  Time for command to be send
    Reset SBTS From Admin Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State


Step6: Check BTS Start-up View Via Mobile For Radio Modules
    Log  \nStep6: Check BTS Start-up view via Mobile for Radio Modules  console=true
    Log  Check in BTS Start-up view via Mobile for Radio Modules onAir to be visible status Succeeded!  console=true
    BTS Start-up View Via Mobile For HW  RMOD  Succeeded
    Log  Check in BTS Start-up view via Mobile for Radio Modules to be visible status Ongoing!  console=true
    Reset One Baseband Module
    BTS Start-up View Via Mobile For HW  RMOD  Ongoing
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    BTS Start-up View Via Mobile For HW  RMOD  Succeeded
    Log  Check in BTS Start-up view via Mobile for Radio Modules to be visible status Failed!  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'  Repeat Keyword  3 times  Send Fault On RMOD For Mobile View
    ${rmod_ip}  ${rmod_serial_number}  Get Radio Module Ip And Serial Number  ${RMOD_TYPE}
    Connect To Radio Module Through Lxc-attach And Telnet  ${rmod_ip}
    SSHLibrary.Write  sendFault 1116 0 0 0 0 0 0
    Log  Fault sent on ${RMOD_TYPE} with SN:${rmod_serial_number}.  console=true
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Sleep  60s  Time for fault to be send.
    BTS Start-up View Via Mobile For HW  RMOD  Failed
    Reset SBTS From Admin Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State


Send Fault On RMOD For Mobile View
    BTS Start-up View Via Mobile For HW  RMOD  Succeeded
    ${rmod_ip}  ${rmod_serial_number}  Get Radio Module Ip And Serial Number  ${RMOD_TYPE}
    Connect To Radio Module Through Lxc-attach And Telnet  ${rmod_ip}
    SSHLibrary.Write  sendFault 1116 0 0 0 0 0 0
    coam.Assert Any  RMOD  operationalState=${DISABLED}  timeout=${RECOVERY_TIMEOUT}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    BTS Start-up View Via Mobile For HW  RMOD  Succeeded
    Sleep  300s  Time for fault to be clear successfully.
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections


BTS Start-up View Via Mobile For Cells
    [Arguments]  ${rat_name}  ${expected_status}

    Open BTS Start-up View Pop-up Via Mobile
    Check BTS Start-up View Via Mobile For Cells  ${rat_name}  ${expected_status}


Check BTS Start-up View Via Mobile For Cells
    [Arguments]  ${rat}  ${expected_status}

    ${rat_path_dictionary}  Create Dictionary  GSM=1  WCDMA=2  LTE=3  NR=4
    ${rat_index}  Set Variable  ${rat_path_dictionary}[${rat}]
    Sleep  5s  Time for ${expected_status} to be visible in BTS Start-up view.
    ${rat_status_in_startup}  Get Text  //div[@class='bts-start-view-cells-status']/div[${rat_index}]/div[1]/div[2]
    IF  '${rat_status_in_startup}' == '${expected_status}'
        Log  ${rat} cells status in BTS start-up view is ${expected_status} (as expected)!  console=true
    ELSE
        Fail  ${rat} cells status in BTS start-up view is ${expected_status} (not as expected)!
    END
    Wait Until Element Is Clicked For Mobile
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button  60


BTS Start-up View Via Mobile For HW
    [Arguments]  ${hw_name}  ${expected_status}

    Open BTS Start-up View Pop-up Via Mobile
    Check BTS Start-up View Via Mobile For HW  ${hw_name}  ${expected_status}
    Wait Until Element Is Clicked For Mobile
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button  60


Check BTS Start-up View Via Mobile For HW
    [Arguments]  ${hw}  ${expected_status}

    ${hw_path_dictionary}  Create Dictionary  SMOD_BBMOD=1  RMOD=2
    ${hw_index}  Set Variable  ${hw_path_dictionary}[${hw}]
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Contains  //div[@class='bts-start-view-hardware-status']/div[${hw_index}]/div[1]/div[2]  ${expected_status}  timeout=60
    IF  ${status}
        Log  ${hw} status in BTS start-up view is ${expected_status} (as expected)!  console=true
    ELSE
        Fail  ${hw} status in BTS start-up view is ${expected_status} (not as expected)!
    END


Block And Unblock Cells And Check Status In BTS Start-up View Via Mobile
    [Arguments]  ${rat}

    Log  Blocking ${rat} cells is ongoing  console=true
    Wait Until Keyword Succeeds  60  5
    ...  Block Cells Via Mobile  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Assert Every  ${CELLS_NAME_DICT}[${rat}]  blockingState=Blocked
    BTS Start-up View Via Mobile For Cells  ${rat}  Ongoing
    Log  Unblocking ${rat} cell is ongoing  console=true
    Wait Until Keyword Succeeds  60  5
    ...  Unblock Cells Via Mobile  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Assert Every  ${CELLS_NAME_DICT}[${rat}]  blockingState=Unblocked
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Assert Every  ${CELLS_NAME_DICT}[${rat}]  operationalState=${ENABLED}
    BTS Start-up View Via Mobile For Cells  ${rat}  Succeeded


Reset RMOD With Specific Cells And Check Status In BTS Start-up View Via Mobile
    [Arguments]  ${rat}

    ${rmods_r_id_list}  Get A List With All Rmods Id With Specific Cells On  ${CELLS_NAME_DICT}[${rat}]
    ${rmod_r_id}  Evaluate  random.choice(${rmods_r_id_list})  random
    Log  ${rmod_r_id} will be choose to reset!  console=true
    FOR  ${rmod_xpath}  IN  @{RMODS_XPATH}
        Click Element  ${rmod_xpath}
        ${rmod_name_details}  Get Text  ${rmod_xpath}/div/div[3]/div[2]/div[2]
        IF  '${rmod_name_details}' == '${RMODS_NAME}[${rmod_r_id}]'
            Reset Specific RMOD And Check BTS Start-up View Via Mobile  ${rmod_xpath}  ${rat}
            BREAK
        END
    END


Reset Specific RMOD And Check BTS Start-up View Via Mobile
    [Arguments]  ${rmod_xpath}  ${rat}

    Click Element  ${rmod_xpath}/div/div[3]/div[1]/span/button
    Click Element  ${rmod_xpath}/div/div[3]/div[1]/span/div/div[1]/button
    Wait Until Element Is Enabled  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[1]/div[1]  60
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Assert Every  ${CELLS_NAME_DICT}[${rat}]  availabilityStatus=${FAILED}  timeout=${RECOVERY_TIMEOUT}
    BTS Start-up View Via Mobile For Cells  ${rat}  Failed
    Assert Every  ${CELLS_NAME_DICT}[${rat}]  availabilityStatus=${OFFLINE}  timeout=${RECOVERY_TIMEOUT}
    Assert Every  ${CELLS_NAME_DICT}[${rat}]  operationalState=${ENABLED}  timeout=${RECOVERY_TIMEOUT}
    BTS Start-up View Via Mobile For Cells  ${rat}  Succeeded


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
    ${rmods_r_id}  Create List
    FOR  ${rmod_dn}  IN  @{rmods_list}
        ${last_part}  Fetch From Right  ${rmod_dn}  /
        Append To List  ${rmods_r_id}  ${last_part}
    END
    RETURN  ${rmods_r_id}


Get Cells Id On The Specific Rmod
    [Arguments]  ${cells_on_rmod}

    ${cells_id}  Create List
    FOR  ${cell_dn}  IN  @{cells_on_rmod}
        ${last_part}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${last_part}  _R
        Append To List  ${cells_id}  ${cell_id}
    END

    [Return]  ${cells_id}


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
    Close BTS Start-up View Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check The Specific Cells To Be Enabled  ${first_rat}  ${first_cells}  ${second_rat}  ${second_cells}


Check The Specific Cells To Be Enabled
    [Arguments]  ${first_rat}  ${first_cells}  ${second_rat}  ${second_cells}

    IF  ${SCF_COUNT_${first_rat}}  Assert Every  ${first_cells}  operationalState=${ENABLED}  timeout=60
    IF  ${SCF_COUNT_${second_rat}}  Assert Every  ${second_cells}  operationalState=${ENABLED}  timeout=60


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
    Close BTS Start-up View Via Mobile
    Log  Wait for all cells to be onAir...  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State


Reset One Baseband Module
    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Click Element  ${xpath}
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
        IF  '${bbmod_name}'=='ABIA' and '${ENB_BRANCH}'>='SBTS25R2'  CONTINUE
        Log  Reset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
        Click Element  ${xpath}/div/div[1]
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


Get Radio Module Ip And Serial Number
    [Arguments]  ${rmod_type}

    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_parameters}
        IF  '${rmod}[productName]'=='${rmod_type}'
            ${rmod_ip}  Set Variable  ${rmod}[ipAddress]
            ${rmod_serial_number}  Set Variable  ${rmod}[serialNumber]
            BREAK
        ELSE
            CONTINUE
        END
    END
    Should Not Be Empty  ${rmod_ip}  RMOD ip not set correctly - there is no ${rmod_type} RMODs on SBTS. [NOK]
    Log  ${rmod_type} serial number and ip are chosen.  console=true

    RETURN  ${rmod_ip}  ${rmod_serial_number}


Connect To Radio Module Through Lxc-attach And Telnet
    [Arguments]  ${rmod_ip}

    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(>|\\$)
    SSHLibrary.Write  lxc-attach -n 0x1018
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  telnet ${rmod_ip} 2323
    SSHLibrary.Read Until Prompt
    Log  RMOD telnet connection opened.  console=true


Get RMODs Name From Site Report
    ${rmods_dictionary}  Create Dictionary
    Go To Site Report Via Mobile
    Wait Until Element Is Visible  //*[contains(text(), "Radio Modules")]  timeout=10
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Radio Modules")]
    ${number_of_rows}  Get Element Count  //*[contains(@class, 'ui-expandable-panel-body ng-star-inserted')]/div/div
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${status}  Run Keyword And Return Status  Page Should Contain Element
        ...  //*[contains(@class, 'ui-expandable-panel-body ng-star-inserted')]/div/div[${row}]/site-report-content-renderer/div
        IF  ${status}
            ${rmod_name_site_report}  Get Text
            ...  //*[contains(@class, 'ui-expandable-panel-body ng-star-inserted')]/div/div[${row}]/site-report-content-renderer/div
            ${status_rmod}  Run Keyword And Return Status  Should Contain  ${rmod_name_site_report}  RMOD
            IF  ${status_rmod}
                ${rmod_id}  Get Regexp Matches  ${rmod_name_site_report}  RMOD-[0-9]*
                ${rmod_r_id}  Get Regexp Matches  ${rmod_name_site_report}  RMOD_R-[0-9]*
                Set To Dictionary  ${rmods_dictionary}  ${rmod_r_id}[0]=${rmod_id}[0]
            END
        END
    END
    Go To Site View Via Mobile

    RETURN  ${rmods_dictionary}


TC Setup
    Common Test Setup  tc_name=WebEM__BTS_Startup_view_show_resources_Mobile
    WebEM Setup Via Mobile


TC Teardown
    Run Keyword If Test Failed
    ...  Load Initial SCF
    WebEM Teardown Via Mobile
    Common Test Teardown
