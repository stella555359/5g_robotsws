*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__FHS_Reset_from_WEBEM
Variables    tc_variables/sbts_sbts__state__fhs_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of FHS reset operations, default value 3

*** Keywords ***
TC__SBTS_SBTS__STATE__FHS_Reset_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22961
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for FHS reset from BTS configured with it, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get both BTS, FHS and RM info
    ...  - perform reset FHS operation on BTS configured with it checking states and alarms
    ...  Pass criteria: FHS reset operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22961 -
    ...  [5G][CB007636] New SBTS_SBTS scenario_RFS_SBTS_RF_Share_FHS_reset_from_SBTS
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 - [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 06.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25761 - SBTS_SBTS__STATE__FHS_Reset_from_WEBEM should take into account
    ...  dedicated RMs impact + DSS impact
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 08.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29832 - Remove infomodel use for SBTS_SBTS__STATE__FHS_Reset_from_WEBEM.robot
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22961_SBTS_SBTS__STATE__FHS_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-razvan.roman@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R4

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get both BTS, FHS, RM and cells info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Reset FHS operation
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get both BTS, FHS, RM and cells info
    Log  Step ${index}: Get both BTS, FHS, RM and cells info  console=True
    Get module info on both BTS  RMOD
    Get module info on both BTS  FHS
    Run Keyword If  ${Master_dedicated_FHS_list}  Get FHS RMOD and cells info dict  ${Master_dedicated_FHS_list}  Master
    Run Keyword If  ${Slave_dedicated_FHS_list}  Get FHS RMOD and cells info dict  ${Slave_dedicated_FHS_list}  Slave
    Get BTS CELL list by RAT  Master
    Get BTS CELL list by RAT  Slave
    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_runtime_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}
    FOR  ${alias}  IN  @{alias_list}
        ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
        ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
        ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

        ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' or '${BTS_actLteNrDss_LTE}' == 'True'  True  False
        ${BTS_DSS_peer}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
        Run Keyword If  '${peer_alias}' not in ${BTS_DSS_peer}
        ...  Set Test Variable  ${BTS_DSS_configured}  False

        Set Test Variable  ${${alias}_DSS_configured}  ${BTS_DSS_configured}
    END

    Run Keyword If  ${Master_DSS_configured} and ${Slave_DSS_configured}
    ...  Log  DSS is configured between BTS1 and BTS2. DSS alarms check will be performed!  console=True
    ...  ELSE  Log  DSS is not configured between BTS1 and BTS2. DSS alarms check will be skipped!  console=True

Step ${index}: Perform Reset FHS operation
    Log  Step ${index}: Perform Reset FHS operation  console=True
    Run Keyword If  ${Master_dedicated_FHS_list}  Perform Reset FHS on BTS  Master
    Run Keyword If  ${Slave_dedicated_FHS_list}  Perform Reset FHS on BTS  Slave

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get module info on both BTS
    [Arguments]  ${module}
    ${Master_shared_module_list}  ${Slave_shared_module_list}  ${Master_dedicated_module_list}  ${Slave_dedicated_module_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  ${module}  Master  Slave
    Sort List  ${Master_shared_module_list}
    Sort List  ${Slave_shared_module_list}
    Sort List  ${Master_dedicated_module_list}
    Sort List  ${Slave_dedicated_module_list}
    Set Test Variable  ${Master_shared_${module}_list}  ${Master_shared_module_list}
    Set Test Variable  ${Slave_shared_${module}_list}  ${Slave_shared_module_list}
    Set Test Variable  ${Master_dedicated_${module}_list}  ${Master_dedicated_module_list}
    Set Test Variable  ${Slave_dedicated_${module}_list}  ${Slave_dedicated_module_list}

    Run Keyword If  '${module}' == 'RMOD'  Run Keywords
    ...  Get RMOD ID SN dict  Master
    ...  AND  Get RMOD ID SN dict  Slave
    ...  ELSE IF  '${module}' == 'FHS'  Run Keywords
    ...  Get FHS ID SN dict  Master
    ...  AND  Get FHS ID SN dict  Slave
    Set Test Variable  ${Master_${module}_SN_ID_dict}   ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_${module}_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_${module}_SN_ID_dict}   ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_${module}_ID_SN_dict}  ${Slave_module_ID_SN_dict}

    Run Keyword If  ${Master_shared_module_list}
    ...  Get shared module info  ${module}
    Run Keyword If  ${Master_dedicated_module_list}
    ...  Get dedicated module info  ${module}  Master
    Run Keyword If  ${Slave_dedicated_module_list}
    ...  Get dedicated module info  ${module}  Slave

Get shared module info
    [Arguments]  ${module}
    FOR  ${Master_module_id}  IN  @{Master_shared_${module}_list}
        ${module_sn}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_module_id}
        ${Slave_module_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${module_sn}
        Log  Shared ${module} with SN ${module_sn}:  console=True
        Log  - BTS1 ${module} id: ${Master_module_id}  console=True
        Log  - BTS2 ${module} id: ${Slave_module_id}  console=True
    END

Get dedicated module info
    [Arguments]  ${module}  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    FOR  ${module_id}  IN  @{${alias}_dedicated_${module}_list}
        ${module_sn}=  Get From Dictionary  ${${alias}_module_ID_SN_dict}  ${module_id}
        Log  Dedicated ${module} with SN ${module_sn}:  console=True
        Log  - ${BTS} ${module} id: ${module_id}  console=True
    END

Get FHS RMOD and cells info dict
    [Arguments]  ${FHS_list}  ${alias}
    ${FHS_all_RMOD_dict}=  Create Dictionary
    ${FHS_CELL_dict}=  Create Dictionary
    FOR  ${FHS_id}  IN  @{FHS_list}
        Get RMOD mapping info by FHS Id  ${FHS_id}  ${alias}
        Set To Dictionary  ${FHS_all_RMOD_dict}  ${FHS_id}  ${${alias}_RMOD_id_list}
        Get CELL Mapping By RMOD Id  ${${alias}_RMOD_id_list}  ${alias}
        Set To Dictionary  ${FHS_CELL_dict}  ${FHS_id}   ${${alias}_CELL_id_list}
    END
    Set Test Variable  ${${alias}_FHS_all_RMOD_dict}  ${FHS_all_RMOD_dict}
    Set Test Variable  ${${alias}_FHS_CELL_dict}  ${FHS_CELL_dict}

Get RMOD mapping info by FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_id_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  '${item.firstEndpointDN}' != '${FHS_id}' or '${secondEndpointDN_RMOD_R}' == 'False'
        ...  Continue For Loop
        Append To List  ${RMOD_id_list}  ${item.secondEndpointDN}
    END
    ${RMOD_id_list}=  Remove Duplicates  ${RMOD_id_list}
    Set Test Variable  ${${alias}_RMOD_id_list}  ${RMOD_id_list}

Get CELL Mapping By RMOD Id
    [Arguments]   ${RMOD_list}  ${alias}
    ${CELL_id_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${CELL_id_list}  @{RMOD_CELL_list}
    END
    ${CELL_id_list}=  Remove Duplicates  ${CELL_id_list}
    Set Test Variable  ${${alias}_CELL_id_list}  ${CELL_id_list}

Get BTS CELL list by RAT
    [Arguments]  ${alias}
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}

Perform Reset FHS on BTS
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    ${peer_BTS}=  Set Variable If  '${alias}' == 'Master'  BTS2  BTS1
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    Set Test Variable  ${BTS}
    Set Test Variable  ${peer_BTS}
    Set Test Variable  ${peer_alias}
    FOR  ${item}  IN  @{${alias}_dedicated_FHS_list}
        Perform Reset FHS  ${item}  ${alias}
    END

Perform Reset FHS
    [Arguments]  ${FHS_id}  ${alias}

    ${new_alias}=  Set Variable  resetFHS
    ${FHS_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${FHS_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${RMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    ${FHS_sn}=  Get From Dictionary  ${${alias}_FHS_ID_SN_dict}  ${FHS_id}
    ${FHS_all_RMOD_list}=  Get From Dictionary  ${${alias}_FHS_all_RMOD_dict}  ${FHS_id}
    Sort List  ${FHS_all_RMOD_list}
    Get FHS shared RMOD  ${FHS_all_RMOD_list}  ${alias}
    ${FHS_shared_RMOD_count}=  Get Length  ${FHS_shared_RMOD_list}
    ${FHS_CELL_list}=  Get From Dictionary   ${${alias}_FHS_CELL_dict}  ${FHS_id}
    Sort List  ${FHS_CELL_list}

    Set Test Variable  ${FID7513_alarm_count}  0
    Set Test Variable  ${FID6134_alarm_count}  0

    Get Primary Link status for shared RMOD before Reset FHS  ${FHS_id}  ${FHS_sn}  ${alias}
    Run Keyword If  ${${alias}_DSS_configured}  Get DSS alarms  ${alias}
    Log  Perform "Reset" operation on FHS with SN ${FHS_sn} from ${BTS}  console=True
    Log  Get ${BTS} cell(s) mapped on shared RMOD(s) connected to FHS with SN ${FHS_sn}:\n - ${FHS_CELL_list}  console=True
    ${SBTS_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_10}  ${FHS_shared_RMOD_count}
    ${peer_SBTS_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}
    ...  ${${alias}_Primary_Link_FHS_shared_RMOD_count}
    ${SBTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_RESET}
    ${peer_SBTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS}  ${${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET}

    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${FHS_id}  reset_type=Hard  timeout=600  connection=${new_alias}
    Sleep  3s

    Log  Check ${BTS} and ${peer_BTS} states and alarms during reset FHS with SN ${FHS_sn}:  console=True

    Log  Check ${BTS} states and alarms:  console=True
    Wait Until Keyword Succeeds  60 sec  10 sec  Admin Check FHS state  ${FHS_id}  ${Disabled_}  ${NotInstalled_}  ${Unlocked_}  ${alias}
    Log  ${BTS} FHS ${FHS_id} status:\n - ${FHS_state_disabled}  console=True
    Check BTS Item State  ${BTS}  RMOD  ${FHS_shared_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  ${alias}
    Log  All ${BTS} shared RMOD(s) connected to FHS with SN ${FHS_sn} status as expected  console=True
    Log  ${BTS} "No connection to unit (10)" alarm, expected number: ${FHS_shared_RMOD_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${SBTS_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${SBTS_IGNORED_ALARMS_FULL}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${BTS} "No connection to unit (10)" alarm, found number: ${FHS_shared_RMOD_count}, as expected  console=True
    Log  ${BTS} site - expected, ignored and critical alarms checked  console=True

    Log  Check ${peer_BTS} states and alarms:  console=True
    Check BTS Item State  ${peer_BTS}  RMOD  ${${peer_alias}_non_Primary_Link_FHS_shared_RMOD_list}  ${RMOD_state_disabled_check}
    ...  ${RMOD_state_disabled}  60  ${peer_alias}
    Check BTS Item State  ${peer_BTS}  RMOD  ${${peer_alias}_Primary_Link_FHS_shared_RMOD_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  60  ${peer_alias}
    Log  ${peer_BTS} shared RMOD(s) connected to FHS with SN ${FHS_sn} status as expected  console=True
    Log  ${peer_BTS} "No connection to unit (10)" alarm, expected number: ${${alias}_Primary_Link_FHS_shared_RMOD_count}  console=True

    ${peer_SBTS_EXPECTED_ALARMS}=  Create List
    ${peer_SBTS_EXPECTED_ALARMS}=  Set Variable If  ${${peer_alias}_DSS_configured}
    ...  ${peer_SBTS_EXPECTED_ALARMS_DSS_full}  ${peer_SBTS_EXPECTED_ALARMS}

    ${peer_SBTS_EXPECTED_ALARMS}=  Run Keyword If  ${${peer_alias}_DSS_configured}
    ...  Combine Lists  ${peer_SBTS_EXPECTED_ALARMS_10_full}  ${peer_SBTS_EXPECTED_ALARMS_DSS_full}
    ...  ELSE  Set Variable  ${peer_SBTS_EXPECTED_ALARMS_10_full}

    Run Keyword If  ${${peer_alias}_DSS_configured} and ${FID7513_alarm_count}>0
    ...  Log Long String  ${peer_BTS} "EN DSS De-activated on partner side (7513)" alarm, expected number:
    ...  ${FID7513_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=5 sec  expected_alarms=${peer_SBTS_EXPECTED_ALARMS}
    ...  ignored_alarms=${peer_SBTS_IGNORED_ALARMS_FULL}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  ${peer_BTS} "No connection to unit (10)" alarm, found number: ${${alias}_Primary_Link_FHS_shared_RMOD_count}, as expected  console=True
    Log  ${peer_BTS} "EN DSS De-activated on partner side (7513), found number: ${FID7513_alarm_count}, as expected  console=True
    Log  ${peer_BTS} site - expected, ignored and critical alarms checked  console=True

    Log  Check ${BTS} and ${peer_BTS} cell(s) state:  console=True
    Run Keyword If  ${${alias}_NR_CELL_list}  Check NR cells state and MIMO alarm  alias=${alias}
    Run Keyword If  ${${alias}_LTE_CELL_list}  Check LTE cells state and MIMO alarm  alias=${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_list}  Check WCDMA cells state and MIMO alarm  alias=${alias}
    Run Keyword If  ${${alias}_GSM_CELL_list}  Check GSM cells state and MIMO alarm  alias=${alias}
    Run Keyword If  ${${peer_alias}_NR_CELL_list}  Check NR cells state and MIMO alarm  alias=${peer_alias}
    Run Keyword If  ${${peer_alias}_LTE_CELL_list}  Check LTE cells state and MIMO alarm  alias=${peer_alias}
    Run Keyword If  ${${peer_alias}_WCDMA_CELL_list}  Check WCDMA cells state and MIMO alarm  alias=${peer_alias}
    Run Keyword If  ${${peer_alias}_GSM_CELL_list}  Check GSM cells state and MIMO alarm  alias=${peer_alias}

    Collect Keyword Result  ${reset_info}  timeout=600

    Log  Check ${BTS} and ${peer_BTS} states and alarms after reset FHS with SN ${FHS_sn}:  console=True

    Log  Check ${BTS} states and alarms:  console=True
    Wait Until Keyword Succeeds  360 sec  10 sec  Admin Check FHS state  ${FHS_id}  ${Enabled_}  ${EMPTY}  ${Unlocked_}  ${alias}
    Log  ${BTS} FHS ${FHS_id} status:\n - ${FHS_state_enabled}  console=True
    Check BTS Item State  ${BTS}  RMOD  ${FHS_all_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  360  ${alias}
    Log  All ${BTS} shared RMOD(s) connected to FHS with SN ${FHS_sn} status as expected  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
    Log  All ${BTS} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${BTS} site - expected, ignored and critical alarms checked  console=True

    Log  Check ${peer_BTS} states and alarms:  console=True
    Check BTS Item State  ${peer_BTS}  RMOD  ${peer_FHS_shared_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  360  ${peer_alias}
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=360  connection=${peer_alias}
    Log  All ${peer_BTS} shared RMOD(s) connected to FHS with SN ${FHS_sn} status as expected  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${peer_alias}
    Log  All ${peer_BTS} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  ${peer_BTS} site - expected, ignored and critical alarms checked  console=True

    [Teardown]  Teardown Admin  alias=${new_alias}

Get DSS alarms
    [Arguments]  ${alias}
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${DSS_NR_LTE_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${peer_alias}
    ${DSS_LTE_NR_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  ${peer_alias}

    ${NR_CELL_DSS_ids}=  Get Dictionary Keys  ${DSS_NR_LTE_CELL_runtime_dict}
    ${LTE_CELL_DSS_ids}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_runtime_dict}

    ${peer_FHS_Primary_Link_Shared_RMOD_cell_ids}=  Create List

    FOR  ${item_id}  IN  @{${peer_alias}_Primary_Link_FHS_shared_RMOD_list}
         ${RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item_id}  connection=${peer_alias}
         ${peer_FHS_Primary_Link_Shared_RMOD_cell_ids}=  Combine Lists  ${peer_FHS_Primary_Link_Shared_RMOD_cell_ids}  ${RMOD_CELL_list}
    END

     Remove Duplicates  ${peer_FHS_Primary_Link_Shared_RMOD_cell_ids}

     ${FHS_NR_CELL_DSS_ids_impacted}=  Create List
     ${FHS_LTE_CELL_DSS_ids_impacted}=  Create List

     FOR  ${cell_id}  IN  @{peer_FHS_Primary_Link_Shared_RMOD_cell_ids}
         Run Keyword If  '${cell_id}' in ${NR_CELL_DSS_ids}  Append To List  ${FHS_NR_CELL_DSS_ids_impacted}  ${cell_id}
         Run Keyword If  '${cell_id}' in ${LTE_CELL_DSS_ids}  Append To List  ${FHS_LTE_CELL_DSS_ids_impacted}  ${cell_id}
     END

     Remove Duplicates  ${FHS_NR_CELL_DSS_ids_impacted}
     Remove Duplicates  ${FHS_LTE_CELL_DSS_ids_impacted}

    ${NR_CELL_DSS_count}=  Get Length  ${FHS_NR_CELL_DSS_ids_impacted}
    ${LTE_CELL_DSS_count}=  Get Length  ${FHS_LTE_CELL_DSS_ids_impacted}

    Set Test Variable  ${FID7513_alarm_count}  ${NR_CELL_DSS_count}
    Set Test Variable  ${FID6134_alarm_count}  ${LTE_CELL_DSS_count}

    ${peer_SBTS_EXPECTED_ALARMS_DSS_NR}=  Prepare expected alarms list
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_NR_DSS}  ${FID7513_alarm_count}

    ${peer_SBTS_EXPECTED_ALARMS_DSS_full}=  Copy List  ${peer_SBTS_EXPECTED_ALARMS_DSS_NR}
    Set Test Variable  ${peer_SBTS_EXPECTED_ALARMS_DSS_full}

Get FHS shared RMOD
    [Arguments]  ${RMOD_list}  ${alias}
    ${peer_FHS_shared_RMOD_list}=  Create List
    ${FHS_shared_RMOD_list}=  Create List
    ${FHS_dedicated_RMOD_list}=  Create List
    FOR  ${item_id}  IN  @{RMOD_list}
        ${item_sn}=  Get From Dictionary  ${${alias}_RMOD_ID_SN_dict}  ${item_id}
        ${key_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${peer_alias}_RMOD_SN_ID_dict}  ${item_sn}
        Run Keyword If  not ${key_exists}  Run Keywords  Append To List  ${FHS_dedicated_RMOD_list}  ${item_id}  AND  Continue For Loop
        ${peer_item_id}=  Get From Dictionary  ${${peer_alias}_RMOD_SN_ID_dict}  ${item_sn}
        Append To List  ${peer_FHS_shared_RMOD_list}  ${peer_item_id}
        Append To List  ${FHS_shared_RMOD_list}  ${item_id}
    END
    Sort List  ${peer_FHS_shared_RMOD_list}
    Set Test Variable  ${peer_FHS_shared_RMOD_list}
    Set Test Variable  ${FHS_shared_RMOD_list}
    Set Test Variable  ${FHS_dedicated_RMOD_list}

Get Primary Link status for shared RMOD before Reset FHS
    [Arguments]  ${FHS_id}  ${FHS_sn}  ${alias}
    Log  Get Primary Link status for shared RMOD(s) connected to FHS with SN ${FHS_sn}:  console=True
    ${FHS_shared_RMOD_list}=  Get From Dictionary  ${${alias}_FHS_all_RMOD_dict}  ${FHS_id}
    ${Master_Primary_Link_FHS_shared_RMOD_list}=  Create List
    ${Slave_Primary_Link_FHS_shared_RMOD_list}=  Create List
    ${Master_non_Primary_Link_FHS_shared_RMOD_list}=  Create List
    ${Slave_non_Primary_Link_FHS_shared_RMOD_list}=  Create List
    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link shared RMOD status based on linkModeSynchronization
    ${Master_keys}=  Get Dictionary Keys  ${Master_Primary_Link_dict}  False
    ${Slave_keys}=  Get Dictionary Keys  ${Slave_Primary_Link_dict}  False
    FOR  ${Master_key}  ${Slave_key}  IN ZIP  ${Master_keys}  ${Slave_keys}
        ${Master_value}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${Master_key}
        ${Slave_value}=  Get From Dictionary  ${Slave_Primary_Link_dict}  ${Slave_key}
        ${RMOD_sn}=  Get From Dictionary  ${Master_RMOD_ID_SN_dict}  ${Master_key}
        Run Keyword If  '${${alias}_key}' in ${FHS_shared_RMOD_list}  Run Keywords
        ...  Log  Primary Link status for shared RMOD with SN ${RMOD_sn}:  console=True
        ...  AND  Log  - ${BTS} RMOD ${Master_key}: ${Master_value}  console=True
        ...  AND  Log  - ${peer_BTS} RMOD ${Slave_key}: ${Slave_value}  console=True
        Run Keyword If  '${${alias}_key}' in ${FHS_shared_RMOD_list} and 'True' in '${Master_value}'
        ...  Append To List  ${Master_Primary_Link_FHS_shared_RMOD_list}  ${Master_key}
        ...  ELSE IF  '${${alias}_key}' in ${FHS_shared_RMOD_list} and 'True' in '${Slave_value}'
        ...  Append To List  ${Slave_Primary_Link_FHS_shared_RMOD_list}  ${Slave_key}
        Run Keyword If  '${${alias}_key}' in ${FHS_shared_RMOD_list} and 'False' in '${Master_value}'
        ...  Append To List  ${Master_non_Primary_Link_FHS_shared_RMOD_list}  ${Master_key}
        ...  ELSE IF  '${${alias}_key}' in ${FHS_shared_RMOD_list} and 'False' in '${Slave_value}'
        ...  Append To List  ${Slave_non_Primary_Link_FHS_shared_RMOD_list}  ${Slave_key}
    END
    ${Master_Primary_Link_FHS_shared_RMOD_count}=  Get Length  ${Master_Primary_Link_FHS_shared_RMOD_list}
    ${Slave_Primary_Link_FHS_shared_RMOD_count}=  Get Length  ${Slave_Primary_Link_FHS_shared_RMOD_list}
    Set Test Variable  ${Master_Primary_Link_FHS_shared_RMOD_list}
    Set Test Variable  ${Slave_Primary_Link_FHS_shared_RMOD_list}
    Set Test Variable  ${Master_non_Primary_Link_FHS_shared_RMOD_list}
    Set Test Variable  ${Slave_non_Primary_Link_FHS_shared_RMOD_list}
    Set Test Variable  ${Master_Primary_Link_FHS_shared_RMOD_count}
    Set Test Variable  ${Slave_Primary_Link_FHS_shared_RMOD_count}
    Log  ${BTS} Primary Link shared RMOD count: ${Master_Primary_Link_FHS_shared_RMOD_count}  console=True
    Log  ${peer_BTS} Primary Link shared RMOD count: ${Slave_Primary_Link_FHS_shared_RMOD_count}  console=True

Get Primary Link shared RMOD status based on linkModeSynchronization
    ${Master_Primary_Link_dict}=  Create Dictionary
    ${Slave_Primary_Link_dict}=  Create Dictionary
    FOR  ${Master_RMOD_id}  ${Slave_RMOD_id}  IN ZIP  ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}
        ${Master_RMOD_linkModeSynchronization_list}=  Get RMOD linkModeSynchronization from CABLINK   ${Master_RMOD_id}  Master
        Run Keyword If  ${Master_RMOD_linkModeSynchronization_list}
        ...  Set To Dictionary  ${Master_Primary_Link_dict}  ${Master_RMOD_id}  ${Master_RMOD_linkModeSynchronization_list}
        ${Slave_RMOD_linkModeSynchronization_list}=  Get RMOD linkModeSynchronization from CABLINK   ${Slave_RMOD_id}  Slave
        Run Keyword If  ${Slave_RMOD_linkModeSynchronization_list}
        ...  Set To Dictionary  ${Slave_Primary_Link_dict}  ${Slave_RMOD_id}  ${Slave_RMOD_linkModeSynchronization_list}
    END
    [Return]  ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}

Get RMOD linkModeSynchronization from CABLINK
    [Arguments]  ${module_id}  ${alias}
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    ${linkModeSynchronization_list}=  Create List
    FOR  ${item}  IN  @{CABLINK_list}
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item['firstEndpointDN']}  FHS_R
        ${firstEndpointDN_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${item['firstEndpointDN']}  BBMOD_R
        ${firstEndpointDN_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${item['firstEndpointDN']}  SMOD_R
        ${condition}=  Create Long String  (${firstEndpointDN_FHS_R} or ${firstEndpointDN_BBMOD_R} or ${firstEndpointDN_SMOD_R}) and
        ...  '${item['secondEndpointDN']}' == '${module_id}' and '${item['operationalState']}' in '${Enabled_}'
        Run Keyword If  ${condition}
        ...  Append To List  ${linkModeSynchronization_list}  ${item['linkModeSynchronization']}
    END
    [Return]  ${linkModeSynchronization_list}

Check BTS Item State
    [Arguments]   ${BTS}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${BTS} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
