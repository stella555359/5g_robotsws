*** Settings ***
Documentation
    ...  Step 1: GSM TRX Block From ADMIN
    ...  Step 2: GSM TRX Unblock From ADMIN

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  10  # Timeout to check all GSM required states in minutes
${GSM_BTS_ID}  ${None}  # All TRXs to block/unblock on one GSM cell (cell id). Parameter is not mandatory
${CHANNEL_GROUP_ID}  ${None}  # TRX number to block/unblock. Parameter is not mandatory, with this parameter is required ${GSM_BTS_ID}
${TRX_LOCK_TIMEOUT}  6  # Timeout to BSC Validate Locked TRXs
${DEGRADED_TRX_REGEX_NO_CNI}  [stateInfo.availabilityStatus=${DEGRADED}]
${STATES_ONAIR_TRX_NO_CNI}  [stateInfo.administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED} operationalState=${ENABLED}]
${STATES_ON_BLOCK_TRX_NO_CNI}  [stateInfo.administrativeState=${UNLOCKED}, stateInfo.blockingState=${BLOCKED}, stateInfo.operationalState=${DISABLED}]


*** Keywords ***
TC__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7149
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 30.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7149 - Initial creation
    ...  - 13.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-9291 - Deleted swconfig download in test teardown.
    ...  - 14.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-9325 - Corrected expected fault when all TRXes ar blocked on one cell
    ...  - 04.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-9825 - Corrected EOFError: telnet connection closed
    ...  - 21.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10194 - Add test variable STARTUP_TIMEOUT
    ...  - 21.09.2018 - https://jira3.int.net.nokia.com/browse/TAT-12267 - Add parametr TRX_LOCK_TIMEOUT for KW BSC Validate Locked TRXs
    ...  - 08.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12425 - Add allowed alarams due to RP001063 delivery
    ...  - 24.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12786 - Modify timeout after unblock TRX for checking TRXes states on BSC
    ...  - 26.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12862 - Add Run Keyword And Continue On Failure before Log all Tx Power
    ...  - 05.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-13171 - Increase timeout for Block TRXs By Admin to 180
    ...  - 05.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15103 - Fixed checking Om Link State Should Be
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-13168 - Check BB Hopping
    ...  - 31.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19889 - Allow snapshot collection after fail
    ...  - 25.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21353 - Replacing KW block to TAF library
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7149.png#
    ...

    Set Tags  CA-STATE  OWNER-robert.susz@nokia.com  AUTHOR-michal.kwasniewicz@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step 1: GSM TRX Block From ADMIN
    Step 2: GSM TRX Unblock From ADMIN


Step 1: GSM TRX Block From ADMIN
    Log  \nStep 1: GSM TRX block from ADMIN\n  console=true
    Block TRXs By Admin
    Log  \nCheck all states, timeout 3 min for GSM.  console=true
    Run Keyword And Continue On Failure
    ...  Infomodel Check Other Technology States
    Run Keyword And Continue On Failure
    ...  Wait Until Keyword Succeeds  3 min  20 s
    ...  Infomodel Validate Locked TRXs
    Run Keyword And Continue On Failure
    ...  Wait Until Keyword Succeeds  ${TRX_LOCK_TIMEOUT} min  20 s
    ...  BSC Validate Locked TRXs
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    ${expected_fault_id}  Set Variable If  ${GSM_BTS_ID} and not ${CHANNEL_GROUP_ID} or not ${GSM_BTS_ID}  ^${FAULT_49}[fault_id]$
    ...  ^${FAULT_4399}[fault_id]$
    ${expected_alarms}  Create Dictionary  faultId=${expected_fault_id}
    ${expected_alarms}  Create List  ${expected_alarms}
    Admin Check Active Alarms TAF  expected_patterns=${expected_alarms}


Step 2: GSM TRX Unblock From ADMIN
    Log  \nStep 2: GSM TRX unblock from ADMIN\n  console=true
    Unblock TRXs By Admin
    Log  \nCheck all states, timeout ${STARTUP_TIMEOUT} min for GSM.  console=true
    Run Keyword And Continue On Failure
    ...  Infomodel Check Other Technology States
    Run Keyword And Continue On Failure
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT} min  20 s
    ...  Infomodel Check All TRXs States And Cells Procedural State  ${STATES_ONAIR_TRX}
    ...  ${DEGRADED_TRX_REGEX}
    ...  ${STATES_ONAIR_TRX_NO_CNI}
    ...  ${DEGRADED_TRX_REGEX_NO_CNI}
    ...  ${UNBLOCKED_PROCEDURAL_ST}
    Run Keyword And Continue On Failure
    ...  Wait Until Keyword Succeeds  ${TRX_LOCK_TIMEOUT} min  20 s
    ...  BSC Check All TRXs States  WO  U
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check Active Alarms TAF


Custom Test Setup
    Common Test Setup  tc_name=STATE__GSM_TRX_block_unblock_from_ADMIN
    Connect To BSC Setup
    STATE__GSM_TRX_block_unblock_from_ADMIN.Setup Required Test Variables
    Verify If BbHopping Mode Is Enabled
    Check All Additional States Before Test


Verify If BbHopping Mode Is Enabled
    Log  \nVerify If BbHopping Mode Is Enabled\n  console=true
    ${gncel_r_dist_names}  Create List
    FOR  ${gncel_r_obj}  IN  @{TR_XS_LIST}
        ${dist_name}  Fetch From Left  ${gncel_r_obj}  /CARRIERGROUPC_R-
        Append To List  ${gncel_r_dist_names}  ${dist_name}
    END
    ${gncel_r_dist_names}  Remove Duplicates  ${gncel_r_dist_names}

    FOR  ${dn}  IN  @{gncel_r_dist_names}
        ${ref_obj}  Query Infomodel  get object ${dn}/REF-1
        ${gncel_dist_name}  Set Variable  ${ref_obj['distName']}
        ${im_gsm_cell}  Query Infomodel  get object ${gncel_dist_name}
        Run Keyword If  "${im_gsm_cell['hoppingMode']}"=="BbHopping"
        ...  Set Test Norun  GSM cell ${dn} has BbHopping mode enabled.
    END
    Log  Selected GSM cell hasn't got BbHopping mode enabled, test can proceed  console=true


Check All Additional States Before Test
    Log  \nCheck All Additional States Before Test\n  console=true
    ${verdict_0}  Run Keyword And Return Status
    ...  STATE__GSM_TRX_block_unblock_from_ADMIN.Om Link State Should Be  WO
    ${verdict_1}  Run Keyword And Return Status
    ...  STATE__GSM_TRX_block_unblock_from_ADMIN.Infomodel Check Other Technology States
    ${verdict_2}  Run Keyword And Return Status
    ...  Infomodel Check All TRXs States And Cells Procedural State  ${STATES_ONAIR_TRX}
    ...  ${DEGRADED_TRX_REGEX}
    ...  ${STATES_ONAIR_TRX_NO_CNI}
    ...  ${DEGRADED_TRX_REGEX_NO_CNI}
    ...  ${UNBLOCKED_PROCEDURAL_ST}
    ${verdict_3}  Run Keyword And Return Status
    ...  BSC Check All TRXs States  WO  U
    Run Keyword If  ${verdict_0} and ${verdict_1} and ${verdict_2} and ${verdict_3}
    ...  Log  All pre-test states are correct.  console=true
    ...  ELSE
    ...  Set Test Norun  Some of the pre-test states are incorrect!!!!


Custom Test Teardown
    hran_bsc.Unset Keepalive
    hran_bsc.Close Connection
    Common Test Teardown


Setup Required Test Variables
    [Tags]  Helper

    Set Test Variable  ${LTE_CELLS_DISTNAME}  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*//LNCEL_R-*
    Set Test Variable  ${GSM_CELL_DISTNAME}  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*//GNCEL_R-*
    Set Test Variable  ${WCDMA_CELLS_DISTNAME}  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*//WNCEL_R-*
    Set Test Variable  ${CARRIER}  /CARRIERGROUPC_R-*
    Set Test Variable  ${UNBLOCKED_PROCEDURAL_ST}  [stateInfo.proceduralState=${ON_AIR_DONE}]
    Set Test Variable  ${BLOCKED_PROCEDURAL_ST}  [stateInfo.proceduralState=${VALIDATED}]
    Set Test Variable  ${OTHER_TECHNOLOGY_STATES}  ${False}
    Set Test Variable  ${GSM_BSC_STATES}  ${False}
    Set Test Variable  ${GSM_ADMIN_STATES}  ${False}
    Set Test Variable  ${DIST_LTE_CELL_BTS}  /MRBTS-*/RAT-*//BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-*
    Set Test Variable  ${DIST_WCDMA_CELL_BTS}  /MRBTS-*/RAT-*//BBTOP_M-*/MRBTS_M-*/WNBTS_M-*/CELL_M-*
    Set Test Variable  ${DIST_GSM_CELL_BTS}  /MRBTS-*/RAT-*//BBTOP_M-*/MRBTS_M-*/GNBTS_M-*/CELL_M-*

    ${bcf_id}  Infomodel Get BcfId
    Set Test Variable  ${BCF_ID}
    ${tr_xs_list}  Infomodel Get TRXs Distname
    Set Test Variable  ${TR_XS_LIST}


Om Link State Should Be
    [Arguments]  ${state}

    ${om_link_state}  hran_bsc.Get Om Link State  ${BCF_ID}
    Should Be Equal As Strings  ${state}  ${om_link_state}  State is not ${state}


_Check Other Than GSM Technology States
    [Arguments]  ${distname_xncel_r}  ${cell_distname}  ${unlocked_states}

    Assert Every  ${distname_xncel_r}  ${unlocked_states}  timeout=20
    Assert No  ${distname_xncel_r}  ${DEGRADED_CELL_REGEX}
    Query Infomodel  every ${cell_distname} is ${UNBLOCKED_PROCEDURAL_ST}


Infomodel Check Other Technology States
    Set Test Variable  ${OTHER_TECHNOLOGY_STATES}  ${False}
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  STATE__GSM_TRX_block_unblock_from_ADMIN._Check Other Than GSM Technology States  LNCEL  ${DIST_LTE_CELL_BTS}  ${STATES_ONAIR_LG}
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  STATE__GSM_TRX_block_unblock_from_ADMIN._Check Other Than GSM Technology States  WNCEL  ${DIST_WCDMA_CELL_BTS}  ${STATES_ONAIR_WCDMA}
    Set Test Variable  ${OTHER_TECHNOLOGY_STATES}  ${True}


Infomodel Get TRXs Distname
    ${im_trxs_object}  Run Keyword If  ${GSM_BTS_ID} and ${CHANNEL_GROUP_ID}
    ...  Infomodel Get TRX Object
    ...  ELSE IF  ${GSM_BTS_ID} and not ${CHANNEL_GROUP_ID}
    ...  Infomodel Get All TRXs Objects For One GSM Cell
    ...  ELSE
    ...  Query Infomodel  get list ${GSM_CELL_DISTNAME}${CARRIER}
    ${trx_distname}  Create List
    FOR  ${trx_obj}  IN  @{im_trxs_object}
        Append To List  ${trx_distname}  ${trx_obj.dist_name}
    END

    [Return]  ${trx_distname}


Infomodel Get TRX Object
    ${im_cell_object}  Query Infomodel  get object ${GSM_CELL_DISTNAME} is [gsmBtsId = ${GSM_BTS_ID}]
    ${im_trxs_object}  Query Infomodel  get object ${im_cell_object.dist_name}${CARRIER} is [channelGroupId = ${CHANNEL_GROUP_ID}]
    ${trx_object_in_list}  Create List  ${im_trxs_object}

    [Return]  ${trx_object_in_list}


Infomodel Get All TRXs Objects For One GSM Cell
    ${im_cell_object}  Query Infomodel  get object ${GSM_CELL_DISTNAME} is [gsmBtsId = ${GSM_BTS_ID}]
    ${im_trxs_object}  Query Infomodel  get list ${im_cell_object.dist_name}${CARRIER}

    [Return]  ${im_trxs_object}


Block TRXs By Admin
    Log  \nBlocking TRX/s  console=true
    FOR  ${distname}  IN  @{TR_XS_LIST}
        Block Gsmtrx  dist_name=${distname}  timeout=180
        Log  Blocked ${distname}  console=true
    END


Unblock TRXs By Admin
    Log  \nUnblocking TRX/s  console=true
    FOR  ${distname}  IN  @{TR_XS_LIST}
        Unblock Gsmtrx  dist_name=${distname}  timeout=120
        Sleep  5s  Simulate user click unblock ${distname}
        Log  Unblock ${distname}  console=true
    END


Infomodel Validate Locked TRXs
    Set Test Variable  ${GSM_ADMIN_STATES}  ${False}
    Run Keyword If  ${GSM_BTS_ID} and ${CHANNEL_GROUP_ID}
    ...  Infomodel Check States When One TRX Is Blocked
    ...  ELSE IF  ${GSM_BTS_ID} and not ${CHANNEL_GROUP_ID}
    ...  Infomodel Check States When All TRX Are Blocked On One Cell
    ...  ELSE
    ...  Infomodel Check All TRXs States And Cells Procedural State  ${STATES_ON_BLOCK_TRX}
    ...  ${DEGRADED_TRX_REGEX}
    ...  ${STATES_ON_BLOCK_TRX_NO_CNI}
    ...  ${DEGRADED_TRX_REGEX_NO_CNI}
    ...  ${BLOCKED_PROCEDURAL_ST}
    Set Test Variable  ${GSM_ADMIN_STATES}  ${True}


BSC Validate Locked TRXs
    Set Test Variable  ${GSM_BSC_STATES}  ${False}
    Run Keyword If  ${GSM_BTS_ID} and ${CHANNEL_GROUP_ID}
    ...  BSC Check States When One TRX Is Blocked
    ...  ELSE IF  ${GSM_BTS_ID} and not ${CHANNEL_GROUP_ID}
    ...  BSC Check States When All TRX Are Blocked On One Cell
    ...  ELSE
    ...  BSC Check All TRXs States  BL-TRX  U
    Set Test Variable  ${GSM_BSC_STATES}  ${True}


Infomodel Check All TRXs States And Cells Procedural State
    [Documentation]    This Keyword check all states using Infomodel when all TRXs are block or unblock.
    [Arguments]  ${trx_st}  ${degraded_st}  ${trx_st_no_cni}  ${degraded_st_no_cni}  ${procedural_states}

    Set Test Variable  ${GSM_ADMIN_STATES}  ${False}
    ${trx_status}  Run Keyword And Return Status
    ...  Run Keywords
    ...  Query Infomodel  every ${GSM_CELL_DISTNAME}${CARRIER} is ${trx_st}
    ...  AND
    ...  Query Infomodel  count ${GSM_CELL_DISTNAME}${CARRIER} is ${degraded_st} = 0
    Run Keyword If  ${trx_status}==${FALSE}
    ...  Run Keywords
    ...  Query Infomodel  every ${GSM_CELL_DISTNAME}${CARRIER} is ${trx_st_no_cni}
    ...  AND
    ...  Query Infomodel  count ${GSM_CELL_DISTNAME}${CARRIER} is ${degraded_st_no_cni} = 0
    Query Infomodel  every ${DIST_GSM_CELL_BTS} is ${procedural_states}
    Set Test Variable  ${GSM_ADMIN_STATES}  ${True}


Infomodel Check States When One TRX Is Blocked
    ${number_of_gsm_cells}  Query Infomodel  get count ${DIST_GSM_CELL_BTS} is
    ${number_unblocked_cells}  Evaluate  ${number_of_gsm_cells}-1
    Query Infomodel  count ${DIST_GSM_CELL_BTS} is ${BLOCKED_PROCEDURAL_ST} = 1
    Query Infomodel  count ${DIST_GSM_CELL_BTS} is ${UNBLOCKED_PROCEDURAL_ST} = ${number_unblocked_cells}
    ${im_cell_object}  Query Infomodel  get object ${GSM_CELL_DISTNAME} is [gsmBtsId = ${GSM_BTS_ID}]
    Set Test Variable  ${IM_CELL_OBJECT}
    ${number_of_trxs}  Query Infomodel  get count ${GSM_CELL_DISTNAME}${CARRIER} is
    ${number_unblocked_trxs}  Evaluate  ${number_of_trxs}-1
    Set Test Variable  ${NUMBER_UNBLOCKED_TRXS}
    ${status_1}  Run Keyword And Return Status
    ...  GSM State Check One TRX  ${STATES_ON_BLOCK_TRX}  ${STATES_ONAIR_TRX}  ${DEGRADED_TRX_REGEX}
    Run Keyword If  ${status_1}==${FALSE}
    ...  GSM State Check One TRX  ${STATES_ON_BLOCK_TRX_NO_CNI}  ${STATES_ONAIR_TRX_NO_CNI}  ${DEGRADED_TRX_REGEX_NO_CNI}


GSM State Check One TRX
    [Arguments]  ${block_trx}  ${onair_trx}  ${degraded_trx}

    Query Infomodel  count ${IM_CELL_OBJECT.dist_name}${CARRIER} is ${block_trx} = 1
    Query Infomodel  count ${GSM_CELL_DISTNAME}${CARRIER} is ${onair_trx} = ${NUMBER_UNBLOCKED_TRXS}
    Query Infomodel  count ${GSM_CELL_DISTNAME}${CARRIER} is ${degraded_trx} = 0


Infomodel Check States When All TRX Are Blocked On One Cell
    ${im_cell_object}  Query Infomodel  get object ${GSM_CELL_DISTNAME} is [gsmBtsId = ${GSM_BTS_ID}]
    Set Test Variable  ${IM_CELL_OBJECT}
    ${number_of_trxs}  Query Infomodel  get count ${GSM_CELL_DISTNAME}${CARRIER} is
    ${number_of_blocked_trxs}  Query Infomodel  get count ${IM_CELL_OBJECT.dist_name}${CARRIER} is
    ${number_unblocked_trxs}  Evaluate  ${number_of_trxs}-${number_of_blocked_trxs}
    Set Test Variable  ${NUMBER_UNBLOCKED_TRXS}
    Query Infomodel  count ${DIST_GSM_CELL_BTS} is ${BLOCKED_PROCEDURAL_ST} = ${number_of_blocked_trxs}
    Query Infomodel  count ${DIST_GSM_CELL_BTS} is ${UNBLOCKED_PROCEDURAL_ST} = ${NUMBER_UNBLOCKED_TRXS}
    ${status_1}  Run Keyword And Return Status
    ...  GSM State Check One Cell  ${STATES_ON_BLOCK_TRX}  ${STATES_ONAIR_TRX}  ${DEGRADED_TRX_REGEX}
    Run Keyword If  ${status_1}==${FALSE}
    ...  GSM State Check One Cell  ${STATES_ON_BLOCK_TRX_NO_CNI}  ${STATES_ONAIR_TRX_NO_CNI}  ${DEGRADED_TRX_REGEX_NO_CNI}


GSM State Check One Cell
    [Arguments]  ${block_trx}  ${onair_trx}  ${degraded_trx}

    Query Infomodel  every ${IM_CELL_OBJECT.dist_name}${CARRIER} is ${block_trx}
    Query Infomodel  count ${GSM_CELL_DISTNAME}${CARRIER} is ${onair_trx} = ${NUMBER_UNBLOCKED_TRXS}
    Query Infomodel  count ${GSM_CELL_DISTNAME}${CARRIER} is ${degraded_trx} = 0


BSC Check All TRXs States
    [Documentation]    This Keyword check all TRXs states using BSC when all TRXs are block or unblock.
    [Arguments]  ${operational_state}  ${administrative_state}

    Set Test Variable  ${GSM_BSC_STATES}  ${False}
    hran_bsc.Parse Bcf Trxs Status  ${BCF_ID}  ${operational_state}  ${administrative_state}
    Set Test Variable  ${GSM_BSC_STATES}  ${True}


_Check TRXs List State
    [Arguments]  ${operational_state}  ${trxs_operational_state_list}  ${trxs_administrative_state_list}

    FOR  ${trx}  IN  @{trxs_operational_state_list}
        Should Be Equal As Strings  ${trx[1]}  ${operational_state}
    END
    _Administrative State Should Be U  ${trxs_administrative_state_list}


_Administrative State Should Be U
    [Arguments]  ${trxs_administrative_state_list}

    FOR  ${trx}  IN  @{trxs_administrative_state_list}
        Should Be Equal As Strings  ${trx[1]}  U
    END


BSC Check States When All TRX Are Blocked On One Cell
    ${blocked_trxs_op}  hran_bsc.Get Trxs States By Bts Id  ${GSM_BTS_ID}  operational
    ${blocked_trx_adm}  hran_bsc.Get Trxs States By Bts Id  ${GSM_BTS_ID}  administrative
    _Check TRXs List State  BL-TRX  ${blocked_trxs_op}  ${blocked_trx_adm}

    ${all_trxs_op}  hran_bsc.Get Trxs State  ${BCF_ID}  operational
    ${all_trxs_adm}  hran_bsc.Get Trxs State  ${BCF_ID}  administrative
    FOR  ${trx}  IN  @{blocked_trxs_op}
        Remove Values From List  ${all_trxs_op}  ${trx}
    END
    FOR  ${trx}  IN  @{blocked_trx_adm}
        Remove Values From List  ${all_trxs_adm}  ${trx}
    END
    _Check TRXs List State  WO  ${all_trxs_op}  ${all_trxs_adm}


BSC Check States When One TRX Is Blocked
    ${all_trxs_op}  hran_bsc.Get Trxs State  ${BCF_ID}  operational
    ${all_trxs_adm}  hran_bsc.Get Trxs State  ${BCF_ID}  administrative
    _Administrative State Should Be U  ${all_trxs_adm}
    ${op_state_list}  Evaluate  [state[1] for state in ${all_trxs_op}]
    ${num_blocked_state}  Count Values In List  ${op_state_list}  BL-TRX
    ${number_of_trxs}  Query Infomodel  get count ${GSM_CELL_DISTNAME}${CARRIER} is
    ${num_unblocked_state}  Count Values In List  ${op_state_list}  WO
    Run Keyword If  ${num_blocked_state}!=1 and ${num_unblocked_state}!=(${number_of_trxs}-1)
    ...  Fail  BSC TRXs states are incorrect!!!


TC Setup
    Custom Test Setup


TC Teardown
    Custom Test Teardown
