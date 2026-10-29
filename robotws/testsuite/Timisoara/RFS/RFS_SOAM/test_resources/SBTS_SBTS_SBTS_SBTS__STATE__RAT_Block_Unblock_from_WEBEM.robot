*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
Variables    tc_variables/sbts_sbts_sbts_sbts__state_rat_block_unblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}       3               # Number of RAT Block Unblock operations, default value 3
${MAX_WAIT_TIME}      300               # Maximum waiting time for RAT block/unblock action; default value 300 seconds

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.int.net.nokia.com/browse/TAT-23506
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS test case for RAT Block Unblock on all SBTS
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for SBTS1, SBTS2, SBTS3
    ...  - perform Block Unbloc operation on all RAT from all SBTS
    ...  - check state and alarms for all BTS after RAT Block Unblock operation
    ...  Pass criteria: RAT Block Unblock operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 07.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23506 -
    ...  [5G][CB007588] SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23926 - [5G][CNI-82119] Implement new RAT check in RAT Block Unblock tests
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23834 - [5G] Common part fails for SBTS_SBTS_SBTS configuration
    ...  - 21.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28241 -
    ...  [5G] SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM Improvement
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23506_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.png
    ...

    Set Tags    CA-CM    OWNER-adrian.ierulesc@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS23R1

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get RAT info on all BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform RAT Block/Unblock on all BTS
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

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

Step ${index}: Get RAT info on all BTS
    Log  Step ${index}: Get RAT info on all BTS  console=True

    FOR  ${alias}  IN  @{alias_list}
        Get BTS CELL list by RAT  ${alias}
        Get BTS RAT info  ${alias}
        Get BTS cells info  ${alias}
    END

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_dict}  ${BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_XP_localAlias_remoteAlias_dict}
    Set Test Variable  ${NRBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${LNBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_dict}

    Set Test Variable  ${NR_DSS_alarms_info}  "EN DSS De-activated on partner side (7513)" alarm
    Set Test Variable  ${LTE_DSS_alarms_info}  "EN DSS De-activated on partner side (6134)" alarm

Step ${index}: Perform RAT Block/Unblock on all BTS
    Log  Step ${index}: Perform RAT Block/Unblock on all BTS  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Perform RAT Block/Unblock on BTS ${alias}: *****  console=True
        Perform Block Unblock BTS RAT  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

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

Get BTS RAT info
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  '${alias}' == 'Slave'  BTS2  '${alias}' == 'Slave1'  BTS3  '${alias}' == 'Slave2'  BTS4
    ${RAT_list}=  Create List
    Run Keyword If  ${${alias}_NR_CELL_list}
    ...  Append To List  ${RAT_list}  NR
    Run Keyword If  ${${alias}_LTE_CELL_list}
    ...  Append To List  ${RAT_list}  LTE
    Run Keyword If  ${${alias}_WCDMA_CELL_list}
    ...  Append To List  ${RAT_list}  WCDMA
    Run Keyword If  ${${alias}_GSM_CELL_list}
    ...  Append To List  ${RAT_list}  GSM
    Set Test Variable  ${${alias}_RAT_list}  ${RAT_list}
    Log  ${BTS} RAT found: ${${alias}_RAT_list}  console=True

Get BTS cells info
    [Arguments]  ${alias}

    ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Sort List  ${NR_CELL_id_list}
    Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}

    ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${LTE_HOST_CELL_id_list}  ${LTE_IOT_CELL_id_list}  ${LTE_IOT_SA_CELL__id_list}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${LTE_CELL_id_list}  alias=${alias}
    Sort List  ${LTE_HOST_CELL_id_list}
    Sort List  ${LTE_IOT_CELL_id_list}
    Sort List  ${LTE_IOT_SA_CELL_id_list}

    Set Test Variable  ${${alias}_LTE_CELL_id_list}  ${LTE_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_HOST_CELL_id_list}  ${LTE_HOST_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_IOT_CELL_id_list}  ${LTE_IOT_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_IOT_SA_CELL__id_list}  ${LTE_IOT_SA_CELL__id_list}

    ${LTE_cell_IOT_mapping_dict}=  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

    ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Sort List  ${WCDMA_CELL_id_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_id_list}  ${WCDMA_CELL_id_list}

    ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${GSM_CELL_id_list}
    Set Test Variable  ${${alias}_GSM_CELL_id_list}  ${GSM_CELL_id_list}

Perform Block Unblock BTS RAT
    [Arguments]  ${alias}

    FOR  ${item}  IN  @{${alias}_RAT_list}
        Block RAT  ${item}  ${alias}
        Unblock RAT  ${item}  ${alias}
    END

Block RAT
    [Arguments]  ${rat}  ${alias}

    ${CELL_class_name}=  Set Variable If  '${rat}'=='NR'  NRCEL  '${rat}'=='LTE'  LNCEL  '${rat}'=='WCDMA'  WNCEL  '${rat}'=='GSM'  GNCEL
    ${CELL_state_disabled}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}
    ${SBTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${IGNORED_ALARMS_X2}
    Count BTS expected alarms related to DSS feature info  ${rat}  ${alias}

    Log  Perform ${rat} RAT Block on BTS ${alias}  console=True
    coam.Block Rat  rat=${rat}  timeout=${MAX_WAIT_TIME}  connection=${alias}
    Log  Checking ${rat} cells states after ${rat} RAT Block  console=True
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled}  timeout=${MAX_WAIT_TIME}  connection=${alias}
    Log  ${rat} cells: ${CELL_state_disabled}  console=True
    Log  Checking alarms after ${rat} RAT Block on ${alias} BTS  console=True

    Check BTS alarms  ${rat}  ${alias}

    FOR  ${peer_alias}  IN  @{alias_list}

        Continue For Loop If  '${peer_alias}' == '${alias}'
        Check peer BTS alarms  ${rat}  ${peer_alias}

    END

Unblock RAT
    [Arguments]  ${rat}  ${alias}

    ${CELL_class_name}=  Set Variable If  '${rat}'=='NR'  NRCEL  '${rat}'=='LTE'  LNCEL  '${rat}'=='WCDMA'  WNCEL  '${rat}'=='GSM'  GNCEL
    ${CELL_state_enabled}=  Set Variable  operationalState=${Enabled_}
    Log  Perform ${rat} RAT Unblock on BTS ${alias}  console=True
    coam.Unblock Rat  rat=${rat}  timeout=${MAX_WAIT_TIME}  connection=${alias}
    Log  Checking ${rat} cells states after ${rat} RAT Unblock on BTS ${alias}  console=True
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_enabled}  timeout=${MAX_WAIT_TIME}  connection=${alias}
    Log  ${rat} cells: ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

Count BTS expected alarms related to DSS feature info
    [Arguments]  ${rat}  ${alias}

    FOR  ${item}  IN  @{alias_list}
        Set Test Variable  ${${item}_DSS_alarms_count}  0
    END

    ${DSS_peer_cell_class_name}=  Set Variable If  '${rat}' == 'NR'  LNCEL  '${rat}' == 'LTE'  NRCEL

    FOR  ${cell_id}  IN  @{${alias}_${rat}_CELL_id_list}

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  ${rat}  ${alias}

        Continue For Loop If  '${DSS_peer_cell_id}' == 'None' or '${DSS_peer_alias}' == None

        ${DSS_peer_cell_status}=  Run Keyword And Return Status
        ...  Assert  class_name=${DSS_peer_cell_class_name}  id=${DSS_peer_cell_id}  parameters=operationalState=${Enabled_}  timeout=3
        ...  connection=${DSS_peer_alias}

        ${DSS_alarms_count}=  Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Evaluate  ${${DSS_peer_alias}_DSS_alarms_count} + 1
        ...  ELSE
        ...  Set Variable  ${${DSS_peer_alias}_DSS_alarms_count}

        Set Test Variable  ${${DSS_peer_alias}_DSS_alarms_count}  ${DSS_alarms_count}
    END

Get DSS feature impact
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    Return From Keyword If  '${rat}' in ['WCDMA', 'GSM']  None  None  None

    ${DSS_peer_rat}=  Set Variable If  '${rat}' == 'NR'  LTE  NR

    ${actLteNrDss}=  Run Keyword If  '${rat}' == 'NR'
    ...  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ...  ELSE IF  '${rat}' == 'LTE'
    ...  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

    Return From Keyword If  '${actLteNrDss}' == 'False'  None  ${DSS_peer_rat}  None

    ${DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_dict}  ${alias}
    ${DSS_LTE_NR_CELL_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_dict}  ${alias}
    ${DSS_NR_LTE_dict_keys}=  Get Dictionary Keys  ${DSS_NR_LTE_CELL_dict}
    ${DSS_LTE_NR_dict_keys}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_dict}

    ${DSS_peer_cell_id}=  Run Keyword If  '${rat}' == 'NR' and '${cell_id}' in ${DSS_NR_LTE_dict_keys}
    ...  Get From Dictionary  ${DSS_NR_LTE_CELL_dict}  ${cell_id}
    ...  ELSE IF  '${rat}' == 'LTE' and '${cell_id}' in ${DSS_LTE_NR_dict_keys}
    ...  Get From Dictionary  ${DSS_LTE_NR_CELL_dict}  ${cell_id}
    ...  ELSE
    ...  Set Variable  None

    Return From Keyword If  '${DSS_peer_cell_id}' == 'None'  None  ${DSS_peer_rat}  None

    ${DSS_peer_alias_list}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    ${DSS_peer_alias}=  Get DSS peer BTS  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    [Return]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}

Get DSS peer BTS
    [Arguments]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    ${DSS_peer_alias}=  Set Variable  None

    FOR  ${alias}  IN  @{DSS_peer_alias_list}

        ${DSS_peer_alias}=  Set Variable If  '${DSS_peer_cell_id}' in ${${alias}_${DSS_peer_rat}_CELL_id_list}  ${alias}
        Exit For Loop If  '${DSS_peer_alias}' != 'None'

    END

    [Return]  ${DSS_peer_alias}

Check BTS alarms
    [Arguments]  ${rat}  ${alias}

    ${DSS_peer_rat}=  Set Variable If  '${rat}' == 'NR'  LTE  '${rat}' == 'LTE'  NR
    ${DSS_EXPECTED_ALARMS_full}=  Run Keyword If  '${rat}' in ['NR', 'LTE']
    ...  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_${DSS_peer_rat}_DSS}  ${${alias.upper()}_DSS_alarms_count}
    ...  ELSE
    ...  Create List
    ${BTS_EXPECTED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_EXPECTED_ALARMS_4614}  ${DSS_EXPECTED_ALARMS_full}

    Log  BTS ${alias} "RAT blocked"(FID 4614)" alarm, expected number: 1  console=True
    Run Keyword If  '${rat}' in ['NR', 'LTE'] and ${${alias}_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${${DSS_peer_rat}_DSS_alarms_info}, expected number: ${${alias}_DSS_alarms_count}  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${BTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Log  BTS ${alias} "RAT blocked"(FID 4614)" alarm, found number: 1, as expected  console=True
    Run Keyword If  '${rat}' in ['NR', 'LTE'] and ${${alias}_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${${DSS_peer_rat}_DSS_alarms_info}, found number: ${${alias}_DSS_alarms_count}, as expected  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS alarms
    [Arguments]  ${rat}  ${alias}

    ${DSS_peer_rat}=  Set Variable If  '${rat}' == 'NR'  LTE  '${rat}' == 'LTE'  NR
    ${DSS_EXPECTED_ALARMS_full}=  Run Keyword If  '${rat}' in ['NR', 'LTE']
    ...  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_${DSS_peer_rat}_DSS}  ${${alias.upper()}_DSS_alarms_count}
    ...  ELSE
    ...  Create List

    Run Keyword If  '${rat}' in ['NR', 'LTE'] and ${${alias}_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${${DSS_peer_rat}_DSS_alarms_info}, expected number: ${${alias}_DSS_alarms_count}  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${DSS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  '${rat}' in ['NR', 'LTE'] and ${${alias}_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${${DSS_peer_rat}_DSS_alarms_info}, found number: ${${alias}_DSS_alarms_count}, as expected  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Check if RAT is unblocked  ${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown