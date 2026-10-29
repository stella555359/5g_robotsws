*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
Variables    tc_variables/sbts_sbts__state__primary_controller_bbmod_reset_one_by_one.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}         3     # Number of shared RM lock/unlock operations on both BTS, default value 3
${BBMOD_RESET_WRN_THR}    270   # Time from BBMOD Reset to last cell up. Default value: in accordance with KPI 5 specifications
${BBMOD_MAX_WAIT_TIME}    900   # Maximum time for wait of BTS OnAir (first cell up after reset). If this value is exceeded, test will fail
${RESET_BBMOD_TYPE_LIST}  ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ  # BBMOD type list on which Reset operation is valid. User may add/remove BBMOD type
                                                              # according with BBMOD Reset operation validity
*** Keywords ***
TC__SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    [Documentation]
    ...  To be filled
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22038
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for SBTS Primary Controller BBMOD reset, - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for both SBTS Master/Slave BTS
    ...  - perform BBMOD reset on SBTS Master checking states and alarms
    ...  - check final state and alarms for both SBTS Master/Slave BTS
    ...  - check reset behavior on SBTS Master/Slave based on IMS info as follows:
    ...   - SBTS Master - 0 reset
    ...   - SBTS Slave - 0 reset
    ...  - get and check KPI5 info from IMS file
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...
    ...  - 04.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22038 - [5G] SBTS_SBTS__STATE_Primary_controller__BBMOD_reset_one_by_one
    ...  - 02.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22571 - [5G][Connection_type] Update handling of connection_type parameter
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 - [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 08.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23860 -
    ...  [5G][TC review][SBTS-SBTS] Remove "regex" word  from cell/RM/BBMode state
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24619 - [5G]Update scenarios to take reset number from ims2 - BBMOD reset
    ...  tests - SBTS_SBTS
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24618 - [5G][KPI5] Please update BBMOD Reset to use KPI#5 measurements from
    ...  ims - SBTS_SBTS
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24598 - [5G][TC review] Update BBMOD Reset scenario, with input list of BBMOD
    ...  HW Type which need reset - SBTS-SBTS
    ...  - 28.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26038 - [5G][CB007437] Update
    ...  SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one for feature CB007437
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 03.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26641 - [5G] Fix Variable '${BTS}' not found in
    ...  SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 14.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29661 - Running some TC multiple times,
    ...  using 'runs' variable from suite generator, results in 1 successful run and rest of the runs unsuccessful
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22038_SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-alexandru.stamp@nokia.com    PHASE-QT    SW-SBTS21B

    TC Preconditions
    Step 1: Check initial BTS Master state
    Step 2: Check initial BTS Slave state
    Step 3: Check initial BTS Master alarms
    Step 4: Check initial BTS Slave alarms
    Step 5: Get SBTS Master and Slave BBMOD and RMOD and CELL mapping list
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Reset SBTS Master BBMOD for iteration ${INDEX}
        Step 7: Check final BTS Master state
        Step 8: Check final BTS Slave state
        Step 9: Check final BTS Master alarms
        Step 10: Check final BTS Slave alarms
        Step 11: Check SBTS Master and Slave reset behavior based on IMS info
        Step 12: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}

    ${RESET_BBMOD_TYPE_LIST_strip}=  Replace String  ${RESET_BBMOD_TYPE_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_BBMOD_TYPE_LIST_split}=  Split String  ${RESET_BBMOD_TYPE_LIST_strip}  ,
    Set Test Variable  ${RESET_BBMOD_TYPE_LIST_split}
    ${TL_BBMOD_reset_check}=  Set Variable  ${FALSE}
    FOR  ${alias}  IN  @{alias_list}
        ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  TC Preconditions verification started on ${BTS}  console=True
        ${BBMOD_reset_check}=  Check BBMOD type reset info  ${RESET_BBMOD_TYPE_LIST_split}  ${alias}
        Run Keyword If  ${BBMOD_reset_check}
        ...  Log  TC Preconditions passed on ${BTS}. Reset operation will be performed on valid BBMOD(s) from: ${RESET_BBMOD_TYPE_LIST_split}
        ...  console=True
        ...  ELSE
        ...  Log  TC Preconditions failed on ${BTS}. No BBMOD type valid for Reset operation found in: ${RESET_BBMOD_TYPE_LIST_split}  console=True
        Set Test Variable  ${${alias}_BBMOD_reset_check}  ${BBMOD_reset_check}
        ${TL_BBMOD_reset_check}=  Set Variable If  ${BBMOD_reset_check}  ${TRUE}  ${TL_BBMOD_reset_check}
    END
    Run Keyword If  not ${TL_BBMOD_reset_check}  Run Keywords
    ...  Log Long String  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on any BTS. Test execution will be stopped!
    ...  level=ERROR
    ...  AND  Fail  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on any BTS. Test execution will be stopped!

Step ${index}: Check ${when} BTS ${alias} state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS ${alias} alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} alarms  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get SBTS Master and Slave BBMOD and RMOD and CELL mapping list
    [Documentation]
    ...  Get SBTS Master and Slave BBMOD and RMOD and CELL mapping list

    Log  Step ${index}:Get SBTS Master and Slave BBMOD and RMOD and CELL mapping list  console=True
    Get SBTS BBMOD list  Master
    Get SBTS BBMOD list  Slave
    Get SBTS BBMOD RMOD mapping dictionary  Master
    Get SBTS BBMOD RMOD mapping dictionary  Slave
    Get SBTS BBMOD CELL mapping dictionary  Master
    Get SBTS BBMOD CELL mapping dictionary  Slave

    Get SBTS RMOD list  Master
    Get SBTS RMOD list  Slave
    Get SBTS RMOD SN dict  Master
    Get SBTS RMOD SN dict  Slave

Get SBTS BBMOD list
    [Documentation]
    ...  Get SBTS BBMOD list

    [Arguments]  ${alias}
    ${SBTS_BBMOD_list}=  Get Ids For All  BBMOD  alias=${alias}
    Sort List  ${SBTS_BBMOD_list}
    ${SBTS_BBMOD_count}=  Get Length  ${SBTS_BBMOD_list}
    Run Keyword If  ${SBTS_BBMOD_count} > 0
    ...  Log  SBTS ${alias} BBMOD found: ${SBTS_BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No SBTS ${alias} BBMOD are present in runtime view configuration!
    Set Test Variable  ${SBTS_${alias.upper()}_BBMOD_list}  ${SBTS_BBMOD_list}

Get SBTS RMOD list
    [Documentation]
    ...  Get SBTS RMOD list

    [Arguments]  ${alias}
    ${SBTS_RMOD_list}=  Get Ids For All  RMOD  alias=${alias}
    Sort List  ${SBTS_RMOD_list}
    Set Test Variable  ${SBTS_${alias.upper()}_RMOD_list}  ${SBTS_RMOD_list}

Get SBTS RMOD SN dict
    [Arguments]  ${alias}
    ${RMOD_SN_dict}=  Create Dictionary
    ${SN_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{SBTS_${alias.upper()}_RMOD_list}
        ${RM_PARAM_list}=  Get Parameters For  RMOD  ${item}  alias=${alias}
        Set To Dictionary  ${RMOD_SN_dict}  ${RM_PARAM_list['id']}  ${RM_PARAM_list['serialNumber']}
        Set To Dictionary  ${SN_RMOD_dict}  ${RM_PARAM_list['serialNumber']}  ${RM_PARAM_list['id']}
    END
    Set Test Variable  ${SBTS_${alias}_RMOD_SN_dict}  ${RMOD_SN_dict}
    Set Test Variable  ${SBTS_${alias}_SN_RMOD_dict}  ${SN_RMOD_dict}

Get SBTS BBMOD RMOD mapping dictionary
    [Documentation]
    ...  Get SBTS BBMOD RMOD dictionary

    [Arguments]  ${alias}
    ${SBTS_BBMOD_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{SBTS_${alias.upper()}_BBMOD_list}
        ${SBTS_BBMOD_RMOD_list}=  Get RMOD Mapping By BBMOD Id  ${item}  alias=${alias}
        Set To Dictionary  ${SBTS_BBMOD_RMOD_dict}  ${item}  ${SBTS_BBMOD_RMOD_list}
    END
    Set Test Variable  ${SBTS_${alias.upper()}_BBMOD_RMOD_dict}  ${SBTS_BBMOD_RMOD_dict}

Get RMOD Mapping By BBMOD Id
    [Arguments]   ${BBMOD_id}  ${alias}
    ${BBMOD_RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  CABLINK  alias=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${secondEndpointDN_RMOD_R}
        ...  Append To List  ${BBMOD_RMOD_list}  ${item.secondEndpointDN}
    END
    Sort List  ${BBMOD_RMOD_list}
    [Return]  ${BBMOD_RMOD_list}

Get SBTS BBMOD CELL mapping dictionary
    [Documentation]
    ...  Get SBTS BBMOD cell dictionary

    [Arguments]  ${alias}
    ${SBTS_BBMOD_CELL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{SBTS_${alias.upper()}_BBMOD_list}
        ${SBTS_BBMOD_CELL_list}=  Get Cell Mapping By Module Id  ${item}  alias=${alias}
        Set To Dictionary  ${SBTS_BBMOD_CELL_dict}  ${item}  ${SBTS_BBMOD_CELL_list}
    END
    Set Test Variable  ${SBTS_${alias.upper()}_BBMOD_CELL_dict}  ${SBTS_BBMOD_CELL_dict}

Get SBTS Peer RMOD Mapping Info
    [Arguments]  ${RMOD_list}  ${alias}  ${peer_alias}
    ${SBTS_Peer_BBMOD_RMOD_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_SN}=  Get From Dictionary  ${SBTS_${alias}_RMOD_SN_dict}  ${item}
        ${sharedRMOD}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SBTS_${peer_alias}_SN_RMOD_dict}  ${RMOD_SN}
        Continue For Loop If  not ${sharedRMOD}
        ${SBTS_RMOD_id}=  Get From Dictionary  ${SBTS_${peer_alias}_SN_RMOD_dict}  ${RMOD_SN}
        Append To List  ${SBTS_Peer_BBMOD_RMOD_list}  ${SBTS_RMOD_id}
    END
    [Return]  ${SBTS_Peer_BBMOD_RMOD_list}

Get shared RMOD Primary Link Info
    [Documentation]
    ...  Get RMOD Primary Link Info

    Log  Get shared RMOD Primary Link Info  console=True
    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}

        ${BTS_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_id_list
        ${BTS_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_id_list
        ${BTS_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_id_list

        ${BTS_non_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_id_list
        ${BTS_non_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_id_list
        ${BTS_non_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_id_list

        ${BTS_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_CPRI_shared_RMOD_list}
        ${BTS_PL_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_ECPRI_shared_RMOD_list}
        ${BTS_PL_OBSAI_shared_RMOD_count}=  Get Length  ${BTS_PL_OBSAI_shared_RMOD_list}

        Log  CPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_CPRI_shared_RMOD_count}  console=True
        Log  ECPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_ECPRI_shared_RMOD_count}  console=True
        Log  OBSAI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_OBSAI_shared_RMOD_count}  console=True

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_list}  ${BTS_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_list}  ${BTS_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_list}  ${BTS_PL_OBSAI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_CPRI_shared_RMOD_list}  ${BTS_non_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_ECPRI_shared_RMOD_list}  ${BTS_non_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_OBSAI_shared_RMOD_list}  ${BTS_non_PL_OBSAI_shared_RMOD_list}

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_count}  ${BTS_PL_CPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_count}  ${BTS_PL_ECPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_count}  ${BTS_PL_OBSAI_shared_RMOD_count}
    END

Step ${index}: Reset SBTS ${alias} BBMOD for iteration ${CYCLE}
    Log  Step ${index}: Reset SBTS ${alias} BBMOD  console=True
    ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Set Test Variable  ${BTS}
    Run Keyword If  not ${${alias}_BBMOD_reset_check}  Run Keywords
    ...  Log  Test execution will be skipped on ${BTS} due to TC Preconditions check!  console=True
    ...  AND  Return From Keyword
    Get shared RMOD Primary Link Info
    Get Current Date UTC info  start
    FOR  ${item}  IN  @{SBTS_${alias}_BBMOD_list}
        Reset SBTS BBMOD  ${item}  ${alias}  ${CYCLE}
    END
    Get Current Date UTC info  end

Check BBMOD type reset info
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}  ${alias}
    ${BBMOD_reset_check}=  Set Variable  ${FALSE}
    ${BBMOD_param_list}=  Get Parameters For All  class_name=BBMOD  connection=${alias}
    FOR  ${item}  IN  @{BBMOD_param_list}
        ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST}  ${item.productName}
        Exit For Loop If  ${BBMOD_reset_check}
    END

    [Return]  ${BBMOD_reset_check}

Check BBMOD reset validity
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}  ${productName}
    ${BBMOD_reset_check}=  Set Variable  ${FALSE}
    FOR  ${item}  IN  @{RESET_BBMOD_TYPE_LIST}
        ${BBMOD_reset_check}=  Set Variable If  '${item}' in '${productName}'  ${TRUE}  ${BBMOD_reset_check}
        Exit For Loop If  '${item}' in '${productName}'
    END

    [Return]  ${BBMOD_reset_check}

Reset SBTS BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}  ${CYCLE}

    Run Keyword If  '${alias}' == 'Master'
    ...  Set Test Variable  ${peer_alias}  Slave
    ...  ELSE  Set Test Variable  ${peer_alias}  Master
    ${new_alias}=  Set Variable  resetBBMOD

    ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${BBMOD_id}  connection=${alias}
    ${BBMOD_sn}=  Set Variable  ${BBMOD_param['serialNumber']}
    ${BBMOD_prodName}=  Set Variable  ${BBMOD_param['productName']}
    ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST_split}  ${BBMOD_prodName}
    Run Keyword If  not ${BBMOD_reset_check}  Run Keywords
    ...  Log  "Reset" operation on ${BTS} for BBMOD with SN ${BBMOD_sn} will be skipped as not valid!  console=True
    ...  AND  Return From Keyword

    Set Test Variable  ${BBMOD_state_disabled}
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${BBMOD_state_enabled}
    ...  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_disabled}
    ...  operationalState=Disabled|Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled}
    ...  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled}
    ...  operationalState=Enabled, blockingState=Unblocked

    Set Test Variable  ${BBMOD_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${BBMOD_state_enabled_check}
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_disabled_check}
    ...  operationalState=${Disabled_Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_check}
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${CELL_state_enabled_check}
    ...  operationalState=${Enabled_}, blockingState=${Unblocked_}

    ${BBMOD_ids}=  Create List
    Append To List  ${BBMOD_ids}  ${BBMOD_id}
    Set Test Variable  ${BBMOD_id_list}  ${BBMOD_ids}

    ${SBTS_BBMOD_RMOD_list}=  Get From Dictionary  ${SBTS_${alias.upper()}_BBMOD_RMOD_dict}  ${BBMOD_id}
    Set Test Variable  ${SBTS_${alias}_BBMOD_RMOD_list}  ${SBTS_BBMOD_RMOD_list}
    ${SBTS_BBMOD_RMOD_count}=  Get Length  ${SBTS_BBMOD_RMOD_list}
    Set Test Variable  ${SBTS_${alias}_BBMOD_RMOD_count}  ${SBTS_BBMOD_RMOD_count}
    ${SBTS_not_BBMOD_RMOD_list}=  Copy List  ${SBTS_${alias}_RMOD_list}
    FOR  ${item}  IN  @{SBTS_${alias}_BBMOD_RMOD_list}
        Remove Values From List  ${SBTS_not_BBMOD_RMOD_list}  ${item}
    END
    Set Test Variable  ${SBTS_${alias}_not_BBMOD_RMOD_list}  ${SBTS_not_BBMOD_RMOD_list}
    ${SBTS_BBMOD_CELL_list}=  Get From Dictionary  ${SBTS_${alias.upper()}_BBMOD_CELL_dict}  ${BBMOD_id}
    Set Test Variable  ${SBTS_${alias}_BBMOD_CELL_list}  ${SBTS_BBMOD_CELL_list}

    ${SBTS_Peer_BBMOD_RMOD_list}=  Get SBTS Peer RMOD Mapping Info  ${SBTS_${alias}_BBMOD_RMOD_list}  ${alias}  ${peer_alias}
    ${SBTS_Peer_BBMOD_RMOD_CPRI_list}=  Create List
    ${SBTS_Peer_BBMOD_RMOD_OBSAI_list}=  Create List
    ${SBTS_Peer_BBMOD_RMOD_ECPRI_list}=  Create List
    FOR  ${item}  IN  @{SBTS_Peer_BBMOD_RMOD_list}
        Run Keyword If  '${item}' in @{${peer_alias}_non_PL_CPRI_shared_RMOD_list}  Append To List  ${SBTS_Peer_BBMOD_RMOD_CPRI_list}  ${item}
        ...  ELSE IF  '${item}' in @{${peer_alias}_non_PL_OBSAI_shared_RMOD_list}  Append To List  ${SBTS_Peer_BBMOD_RMOD_OBSAI_list}  ${item}
        ...  ELSE IF  '${item}' in @{${peer_alias}_non_PL_ECPRI_shared_RMOD_list}  Append To List  ${SBTS_Peer_BBMOD_RMOD_ECPRI_list}  ${item}
    END

    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_list}  ${SBTS_Peer_BBMOD_RMOD_list}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_CPRI_list}  ${SBTS_Peer_BBMOD_RMOD_CPRI_list}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_OBSAI_list}  ${SBTS_Peer_BBMOD_RMOD_OBSAI_list}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_ECPRI_list}  ${SBTS_Peer_BBMOD_RMOD_ECPRI_list}
    ${SBTS_Peer_BBMOD_RMOD_count}=  Get Length  ${SBTS_Peer_BBMOD_RMOD_list}
    ${SBTS_Peer_BBMOD_RMOD_CPRI_count}=  Get Length  ${SBTS_Peer_BBMOD_RMOD_CPRI_list}
    ${SBTS_Peer_BBMOD_RMOD_OBSAI_count}=  Get Length  ${SBTS_Peer_BBMOD_RMOD_OBSAI_list}
    ${SBTS_Peer_BBMOD_RMOD_ECPRI_count}=  Get Length  ${SBTS_Peer_BBMOD_RMOD_ECPRI_list}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_count}  ${SBTS_Peer_BBMOD_RMOD_count}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_CPRI_count}  ${SBTS_Peer_BBMOD_RMOD_CPRI_count}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_OBSAI_count}  ${SBTS_Peer_BBMOD_RMOD_OBSAI_count}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_ECPRI_count}  ${SBTS_Peer_BBMOD_RMOD_ECPRI_count}
    ${SBTS_Peer_not_BBMOD_RMOD_list}=  Copy List  ${SBTS_${peer_alias}_RMOD_list}
    FOR  ${item}  IN  @{SBTS_${peer_alias}_BBMOD_RMOD_list}
        Remove Values From List  ${SBTS_Peer_not_BBMOD_RMOD_list}  ${item}
    END
    Set Test Variable  ${SBTS_${peer_alias}_not_BBMOD_RMOD_list}  ${SBTS_Peer_not_BBMOD_RMOD_list}

    ${SBTS_Peer_BBMOD_RMOD_CELL_list}=  Create List
    FOR  ${item}  IN  @{SBTS_Peer_BBMOD_RMOD_list}
        ${CELL_list}=  Get Cell Mapping By Module Id  ${item}  alias=${peer_alias}
        Append To List  ${SBTS_Peer_BBMOD_RMOD_CELL_list}  @{CELL_list}
    END
    ${SBTS_Peer_BBMOD_RMOD_CELL_list}=  Remove Duplicates  ${SBTS_Peer_BBMOD_RMOD_CELL_list}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_CELL_list}  ${SBTS_Peer_BBMOD_RMOD_CELL_list}
    ${SBTS_Peer_BBMOD_RMOD_CELL_count}=  Get Length  ${SBTS_Peer_BBMOD_RMOD_CELL_list}
    Set Test Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_CELL_count}  ${SBTS_Peer_BBMOD_RMOD_CELL_count}

    Log  Perform "Reset" operation on SBTS ${alias} BBMOD with SN ${BBMOD_sn} from WebEM  console=True
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    Get Current Time  bts_initial
    Get Current Date UTC info  bbmod_reset
    ${reset_info}=  Run Keyword In Background  Unit Reset Cp  dist_name=${BBMOD_id}  reset_type=Warm  timeout=600  alias=${new_alias}
    Log  Check SBTS ${alias} state and alarms during reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Log  Check SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Check BTS Item State  SBTS  BBMOD  ${BBMOD_id_list}  ${BBMOD_state_disabled_check}  ${BBMOD_state_disabled}  60  ${alias}
    Log  SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    Log  Check SBTS ${alias} RMOD(s) not connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${SBTS_${alias}_not_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  SBTS  RMOD  ${SBTS_${alias}_not_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  ${alias}
    ...  AND  Log  All SBTS ${alias} RMOD(s) not connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE  Log  No SBTS ${alias} RMOD(s) not connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn}, no impact  console=True
    Log  Check SBTS ${alias} RMOD(s) connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${SBTS_${alias}_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  SBTS  RMOD  ${SBTS_${alias}_BBMOD_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  ${alias}
    ...  AND  Log  All SBTS ${alias} RMOD(s) connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE  Log  No SBTS ${alias} RMOD(s) connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn}, no impact  console=True
    Log  Check SBTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}
    ...  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${SBTS_${alias}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${alias}_CRITICAL_ALARMS}
    Log  SBTS ${alias} site - expected, ignored and critical alarms checked  console=True
    Log  Check SBTS ${peer_alias} state and alarms during SBTS ${alias} reset  console=True
    Check peer SBTS state and alarms  ${alias}  ${peer_alias}  ${BBMOD_sn}
    Collect Keyword Result  ${reset_info}  timeout=600
    Check SBTS state after BBMOD reset  ${alias}  ${BBMOD_id}  ${BBMOD_sn}

    Get Current Date UTC info  cells_onair
    Get and check KPI5 info from IMS file  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    [Teardown]  Run Keyword If  ${BBMOD_reset_check}  Teardown Admin  alias=${new_alias}

Get and check KPI5 info from IMS file
    [Documentation]
    ...  Get and check KPI5 info from IMS file.

    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    Log  Get and check KPI5 info from IMS file on BTS ${alias} for iteration ${CYCLE}  console=True

    ${kpi_name_delta_dict_kpi5}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi5  kpi_thresholds=${BBMOD_RESET_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_bbmod_reset_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_cells_onair_UTC}
    ${kpi_delta_list_kpi5}=  Get From Dictionary  ${kpi_name_delta_dict_kpi5}  kpi5
    Export KPI Results to File  alias=${alias}  obj=BBMOD  obj_type=${BBMOD_prodName}_${BBMOD_sn}  obj_id=${BBMOD_id}  action_1=BBMOD_Reset
    ...  kpi_reported_1=KPI_5  event_value_1=${kpi_delta_list_kpi5[0]}  cycle=${CYCLE}  source_info=ims

Check peer SBTS state and alarms
    [Arguments]  ${alias}  ${peer_alias}  ${BBMOD_sn}

    Log  Check SBTS ${peer_alias} state and alarms during reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    ${FID_10_alarm_count}=  Set Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_OBSAI_count}
    ${FID_10_1815_alarm_count}=  Set Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_CPRI_count}
    ${FID_16_alarm_count}=  Set Variable  ${SBTS_${peer_alias}_BBMOD_RMOD_ECPRI_count}
    ${SBTS_peer_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${SBTS_${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID_10_alarm_count}
    ${SBTS_peer_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${SBTS_${peer_alias.upper()}_EXPECTED_ALARMS_10_1815}
    ...  ${FID_10_1815_alarm_count}
    ${SBTS_peer_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${SBTS_${peer_alias.upper()}_EXPECTED_ALARMS_16}  ${FID_16_alarm_count}
    ${SBTS_peer_EXPECTED_alarms_full}=  Combine Lists  ${SBTS_peer_EXPECTED_ALARMS_10_full}  ${SBTS_peer_EXPECTED_ALARMS_10_1815_full}
    ...  ${SBTS_peer_EXPECTED_ALARMS_16_full}
    ${RMOD_state_peer_check}=  Set Variable  ${RMOD_state_disabled_check}
    ${RMOD_state_peer}=  Set Variable  ${RMOD_state_disabled}
    Log  Check SBTS ${peer_alias} RMOD(s) not impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${SBTS_${peer_alias}_not_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  SBTS  RMOD  ${SBTS_${peer_alias}_not_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}
    ...  5  ${peer_alias}
    ...  AND  Log  All SBTS ${peer_alias} RMOD(s) not impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE  Log  No SBTS ${peer_alias} RMOD(s) not impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}, no impact  console=True
    Log  Check SBTS ${peer_alias} RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${SBTS_${peer_alias}_BBMOD_RMOD_OBSAI_list}
    ...  Check BTS Item State  SBTS  RMOD  ${SBTS_${peer_alias}_BBMOD_RMOD_list}  ${RMOD_state_peer_check}
    ...  ${RMOD_state_peer}  120  ${peer_alias}
    Run Keyword If  ${SBTS_${peer_alias}_BBMOD_RMOD_ECPRI_list}
    ...  Check BTS Item State  SBTS  RMOD  ${SBTS_${peer_alias}_BBMOD_RMOD_list}  ${RMOD_state_peer_check}
    ...  ${RMOD_state_peer}  120  ${peer_alias}
    Run Keyword If  ${SBTS_${peer_alias}_BBMOD_RMOD_OBSAI_list} or ${SBTS_${peer_alias}_BBMOD_RMOD_ECPRI_list}
    ...  Log  All SBTS ${peer_alias} RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE  Log  No SBTS ${peer_alias} RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}, no impact  console=True
    Log  Check SBTS ${peer_alias} alarms:  console=True
    Run Keyword If  ${FID_10_alarm_count} > 0
    ...  Log  SBTS ${peer_alias} "No connection to Unit (10)" alarm, expected number: ${FID_10_alarm_count}  console=True
    Run Keyword If  ${FID_10_1815_alarm_count} > 0
    ...  Log Long String  SBTS ${peer_alias} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, expected
    ...  number:  ${FID_10_1815_alarm_count}  console=True
    Run Keyword If  ${FID_16_alarm_count} > 0
    ...  Log  SBTS ${peer_alias} "Unit synchronization failed (16)" alarm, expected number: ${FID_16_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}
    ...  expected_alarms=${SBTS_peer_EXPECTED_alarms_full}
    ...  ignored_alarms=${SBTS_${peer_alias}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${peer_alias}_CRITICAL_ALARMS}
    Run Keyword If  ${FID_10_alarm_count} > 0
    ...  Log  SBTS ${peer_alias} "No connection to Unit (10)" alarm, found number: ${FID_10_alarm_count}, as expected!  console=True
    Run Keyword If  ${FID_10_1815_alarm_count} > 0
    ...  Log Long String  SBTS ${peer_alias} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, found
    ...  number:  ${FID_10_1815_alarm_count}, as expected!  console=True
    Run Keyword If  ${FID_16_alarm_count} > 0
    ...  Log  SBTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number: ${FID_16_alarm_count}, as expected!  console=True
    Log  SBTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check SBTS state after BBMOD reset
    [Arguments]  ${alias}  ${BBMOD_id}  ${BBMOD_sn}

    Log  Check SBTS ${alias} state and alarms after reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Log  Check SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Check BTS Item State  SBTS  BBMOD  ${BBMOD_id_list}  ${BBMOD_state_enabled_check}  ${BBMOD_state_enabled}  300  ${alias}
    Log  SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    Log  Check SBTS ${alias} RMOD(s) connected to SBTS ${alias} BBMOD ${BBMOD_id}:  console=True
    Run Keyword If  ${SBTS_${alias}_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  SBTS  RMOD  ${SBTS_${alias}_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  300  ${alias}
    ...  AND  Log  All SBTS ${alias} RMOD(s) connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE  Log  No SBTS ${alias} RMOD(s) connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn}, no impact  console=True
    Log  Check SBTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}
    ...  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${SBTS_${alias}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${alias}_CRITICAL_ALARMS}
    Log  SBTS ${alias} site - expected, ignored and critical alarms checked  console=True
    Log  Check SBTS ${alias} CELL(s):  console=True
    Run Keyword If  ${SBTS_${alias}_BBMOD_CELL_list}  Run Keywords
    ...  Check cells state  ${alias}
    ...  AND  Log  All SBTS ${alias} CELL(s) mapped on RMOD(s) connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE  Log  No SBTS ${alias} CELL(s) mapped on RMOD(s) connected to SBTS ${alias} BBMOD with SN ${BBMOD_sn}, no impact  console=True

    Log  Check SBTS ${peer_alias} state and alarms after reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Log  Check SBTS ${peer_alias} RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${SBTS_${peer_alias}_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  SBTS  RMOD  ${SBTS_${peer_alias}_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}
    ...  300  ${peer_alias}
    ...  AND  Log  All SBTS ${peer_alias} RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE  Log  No SBTS ${peer_alias} RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn}, no impact  console=True
    Log  Check SBTS ${peer_alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}
    ...  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${SBTS_${peer_alias}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${peer_alias}_CRITICAL_ALARMS}
    Log  SBTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True
    Log  Check SBTS ${peer_alias} CELL(s):  console=True
    Run Keyword If  ${SBTS_${peer_alias}_BBMOD_RMOD_CELL_list}  Run Keywords
    ...  Check BTS Item State  SBTS  LNCEL  ${SBTS_${peer_alias}_BBMOD_RMOD_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  300  ${peer_alias}
    ...  AND  Log  All SBTS ${peer_alias} CELL(s) mapped on RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn} status as expected
    ...  console=True
    ...  ELSE  Log Long String  No SBTS ${peer_alias} CELL(s) mapped on RMOD(s) impacted by reset SBTS ${alias} BBMOD with SN ${BBMOD_sn},
    ...  no impact  console=True

Check cells state
    [Arguments]  ${alias}

    Get Current Time  bbmod_start_check_last_cell_up
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_bbmod_start_check_last_cell_up}  ${time_bts_initial}  number
    ${bbmod_last_cell_up_time}=  BuiltIn.Evaluate  ${BBMOD_MAX_WAIT_TIME} - ${elapsed_time}
    Check BTS Item State  SBTS  LNCEL  ${SBTS_${alias}_BBMOD_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${bbmod_last_cell_up_time}  ${alias}

Step ${index}: Check SBTS Master and Slave reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info.
    ...  Reset behavior as expected in following conditions:
    ...  - SBTS Master site: reset number is 0
    ...  - SBTS Slave site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check SBTS Master and Slave reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Count SBTS alarms
    [Arguments]  ${alias}

    ${SBTS_EXPECTED_ALARMS_FULL}=  Create List  @{EMPTY}
    Set Test Variable  ${SBTS_${alias.upper()}_BBMOD_RMOD_count}  ${SBTS_${alias.upper()}_BBMOD_RMOD_count}

    ${SBTS_EXPECTED_ALARMS_RMOD_FULL}=  Prepare expected alarms list
    ...  ${SBTS_${alias.upper()}_EXPECTED_ALARMS}  ${SBTS_${alias.upper()}_BBMOD_RMOD_count}
    ${SBTS_EXPECTED_ALARMS_CELL_FULL}=  Prepare expected alarms list
    ...  ${SBTS_${alias.upper()}_EXPECTED_ALARMS}  ${SBTS_${alias.upper()}_BBMOD_CELL_count}

    Append To List  ${SBTS_EXPECTED_ALARMS_FULL}  @{SBTS_EXPECTED_ALARMS_RMOD_FULL}
    Append To List  ${SBTS_EXPECTED_ALARMS_FULL}  @{SBTS_EXPECTED_ALARMS_CELL_FULL}
    Set Test Variable  ${SBTS_${alias.upper()}_EXPECTED_ALARMS_FULL}  ${SBTS_EXPECTED_ALARMS_FULL}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  ${BTS_item_class}  ${item}  ${BTS_item_state_check}  timeout=${timeout}  alias=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END


Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${FALSE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
