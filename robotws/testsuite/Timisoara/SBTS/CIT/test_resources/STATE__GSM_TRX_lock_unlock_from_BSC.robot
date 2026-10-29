*** Settings ***
Documentation
    ...  Verification of operability function for TRX block unblock operation

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TRX_ID}  ${EMPTY}  # Specific TRX ID to be tested, e.g., 2, or 002
${GSM_SECTOR_ID}  ${EMPTY}  # Specific GSM_SECTOR_ID - for test included TRXs, e.g, 1091


*** Keywords ***
TC__STATE__GSM_TRX_lock_unlock_from_BSC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6808
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.06.2017 - https://jira3.int.net.nokia.com/browse/TAT-6808 - initial creation
    ...  - 11.10.2017 - https://jira3.int.nert.nokia.com/browse/TAT-7975 - Wrong states are expected after TRX lock
    ...  - 16.10 2017 - https://jira3.int.net.nokia.com/browse/TAT-8007 - Improve TRX to CELL_M mapping
    ...  - 24.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8084 - TRX states should be checked under CARRIERGROUPC_R instead of CELL_M
    ...  - 11.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12443 -
    ...  - 26.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12862 - Add Run Keyword And Continue On Failure before Log all Tx Power
    ...  - 07.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-20051 - Add TL recovery action
    ...  - 10.11.2021 - https://jira3.int.net.nokia.com/browse/TAT-22030 - telnet connection from VM to BSC should be change with SSH
    ...  - 05.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27591- Replace variable name
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-6808.png#

    Set Tags  CA-CIT  OWNER-delia.margulescu@nokia.com  AUTHOR-piotr.krych@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf
    ...  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Pre-test Actions
    Step1: States Verification Before TRX Lock
    Step2: GSM TRX Lock
    Step3: States Verification After TRX Lock
    Step4: GSM TRX Unlock
    Step5: States Verification After TRX Unlock


Test Specific Teardown
    Run Keyword If  ${TRX_LOCKED}
    ...  _GSM TRX Unlock
    Close All BSC Sessions
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check Active Alarms TAF
    Common Test Teardown
    Recover Test Line By Power Reset


Pre-test Actions
    Set Test Variable  ${TRX_STATE_NOT_LOCKED}
    ...  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}, usageState=${ACTIVE}
    Set Test Variable  ${TRX_STATE_LOCKED}
    ...  administrativeState=${LOCKED}, blockingState=${UNBLOCKED}, operationalState=${DISABLED}, usageState=${IDLE}
    Set Test Variable  ${CHECK_TRX_STATE}  ${True}

    ${all_carriergroupc_dn_list}  Infomodel Get Objects Parameter  //CARRIERGROUPC_R-*  dist_name
    Sort List  ${all_carriergroupc_dn_list}
    Set Test Variable  ${ALL_CARRIERGROUPC_DN_LIST}
    Set Test Variable  ${TRX_LOCKED}  ${False}
    Check Parameters


Step1: States Verification Before TRX Lock
    Log  Step1: States verification before TRXs lock (the whole RAT).  console=true
    TRXs States Verification  ${ALL_CARRIERGROUPC_DN_LIST}  ${TRX_STATE_NOT_LOCKED}
    BCF States Verification  bcf_admin_state=U  bcf_oper_state=WO  trx_oper_state=WO  trx_admin_state=U


Step2: GSM TRX Lock
    Log  Step2: GSM TRX lock.  console=true
    Run Keyword If  '${TRX_ID}'=='${EMPTY}' and '${GSM_SECTOR_ID}'=='${EMPTY}'
    ...  Lock All GSM TRXs On BCF
    ...  ELSE IF  '${TRX_ID}' and '${GSM_SECTOR_ID}'
    ...  Lock Specific TRX On BTS  ${TRX_ID}  ${GSM_SECTOR_ID}
    ...  ELSE IF  '${TRX_ID}'=='${EMPTY}' and '${GSM_SECTOR_ID}'!='${EMPTY}'
    ...  Lock TRXs On BTS  ${GSM_SECTOR_ID}
    Set Test Variable  ${TRX_LOCKED}  ${True}


Step3: States Verification After TRX Lock
    Log  Step3: States verification after TRX lock.  console=true

    ${temp_carriergroupc_dn_list}  Copy List  ${ALL_CARRIERGROUPC_DN_LIST}
    Remove Values From List  ${temp_carriergroupc_dn_list}  @{LOCKED_CARRIERGROUPC_DN_LIST}
    Set Test Variable  ${NOT_LOCKED_CARRIERGROUPC_DN_LIST}  ${temp_carriergroupc_dn_list}

    Log  States verification of locked TRXs  console=true
    TRXs States Verification  ${LOCKED_CARRIERGROUPC_DN_LIST}  ${TRX_STATE_LOCKED}
    Run Keyword If  len(${NOT_LOCKED_CARRIERGROUPC_DN_LIST})>0
    ...  Run Keywords
    ...  Log  States verification of not locked TRXs  console=true
    ...  AND
    ...  TRXs States Verification  ${NOT_LOCKED_CARRIERGROUPC_DN_LIST}  ${TRX_STATE_NOT_LOCKED}
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check Active Alarms TAF


Step4: GSM TRX Unlock
    Log  Step4: GSM TRX unlock.  console=true
    _GSM TRX Unlock
    Set Test Variable  ${TRX_LOCKED}  ${False}


Step5: States Verification After TRX Unlock
    Log  Step5: States verification after TRX unlock (the whole RAT).  console=true
    TRXs States Verification  ${ALL_CARRIERGROUPC_DN_LIST}  ${TRX_STATE_NOT_LOCKED}
    Admin Check Active Alarms TAF


Specific Test Setup
    STATE__GSM_TRX_lock_unlock_from_BSC.Open BSC Session
    STATE__GSM_TRX_lock_unlock_from_BSC.Get BCF ID


Get BCF ID
    ${bcf_id}  sbts_infomodel.Infomodel Get BcfId
    Set Test Variable  ${BCF_ID}
    Log  BCF ID: ${BCF_ID}  console=true


Open BSC Session
    hran_bsc.Bsc SSH Connection  ${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    hran_bsc.Set Timeout  240s


Lock All GSM TRXs On BCF
    Log  Locking all TRXs on BCF.  console=true
    ${status}  hran_bsc.Lock All Trxs  bcf_id=${BCF_ID}  timeout=3min  retry_interval=10  allow_negative_result=${True}
    Run Keyword If  '${status}'=='False'
    ...  Fail  TRXs lock operation failed in 3min per TRX.
    Log  TRXs lock operation done sucessfully.  console=true

    ${trx_ids}  hran_bsc.Get Trxs Ids  ${BCF_ID}  alias=${False}
    ${locked_carriergroupc_dn_list}  Get Dist_names Of Tested TRXs  ${trx_ids}
    Set Test Variable  ${LOCKED_CARRIERGROUPC_DN_LIST}


Lock Specific TRX On BTS
    [Arguments]  ${trx_id}  ${gsm_sector_id}

    Log  Locking specific TRX on BSC.  console=true
    ${status}  Run Keyword And Return Status
    ...  hran_bsc.Lock Trx  trx_id=${trx_id}  bts_id=${gsm_sector_id}  timeout=3min  retry_interval=5
    Run Keyword If  '${status}'=='False'
    ...  Fail  TRX lock operation failed in 3min per TRX.
    Log  TRXs ${trx_id} lock operation done sucessfully.  console=true

    ${trx_id_as_list}  Create List  ${trx_id}
    ${locked_carriergroupc_dn_list}  Get Dist_names Of Tested TRXs  ${trx_id_as_list}
    Set Test Variable  ${LOCKED_CARRIERGROUPC_DN_LIST}


Lock TRXs On BTS
    [Arguments]  ${gsm_sector_id}

    Log  Locking all TRXs on given BTS.  console=true
    ${status}  hran_bsc.Lock All Trxs On Bts  bts_id=${gsm_sector_id}  timeout=3min
    Run Keyword If  '${status}'=='False'
    ...  Fail  TRXs lock on BTS ${gsm_sector_id} operation failed in 3min per TRX.
    Log  TRXs lock on BTS ${gsm_sector_id} operation done sucessfully.  console=true

    ${trx_ids}  hran_bsc.Get Trxs List By Bts Id  ${gsm_sector_id}  alias=${False}
    ${locked_carriergroupc_dn_list}  Get Dist_names Of Tested TRXs  ${trx_ids}
    Set Test Variable  ${LOCKED_CARRIERGROUPC_DN_LIST}


Unlock All GSM TRXs On BCF
    Log  Unlocking all TRXs on BCF.  console=true
    ${status}  hran_bsc.Unlock All Trxs  bcf_id=${BCF_ID}  timeout=3min  allow_negative_result=${True}
    Run Keyword If  '${status}'=='False'
    ...  Fail  TRXs unlock operation failed in 3min per TRX.
    Log  All TRXs unlock operation done sucessfully.  console=true


Unlock Specific TRX On BTS
    [Arguments]  ${trx_id}  ${gsm_sector_id}

    Log  Unlocking specific TRX on BSC.  console=true
    ${status}  Run Keyword And Return Status
    ...  hran_bsc.Unlock Trx  bts_id=${gsm_sector_id}  trx_id=${trx_id}  timeout=3min
    Run Keyword If  '${status}'=='False'
    ...  Fail  TRX unlock operation failed in 3min per TRX.
    Log  TRX ${trx_id} unlock operation done sucessfully.  console=true


Unlock TRXs On BTS
    [Arguments]  ${gsm_sector_id}

    Log  Unlocking TRXs on given BTS.  console=true
    ${status}  hran_bsc.Unlock All Trxs On Bts  bts_id=${gsm_sector_id}  timeout=3min  allow_negative_result=${True}
    Run Keyword If  '${status}'=='False'
    ...  Fail  TRXs unlock on BTS ${gsm_sector_id} operation failed in 3min TRX.
    Log  TRXs unlock on BTS ${gsm_sector_id} operation done sucessfully.  console=true


TRXs States Verification
    [Arguments]  ${trxs_dn_list}  ${expected_state}

    Log  Expected state for each TRX: \n${expected_state}  console=true
    ${status}  Run Keyword And Return Status
    ...  TRXs States Check In Infomodel  ${trxs_dn_list}  ${expected_state}
    Run Keyword If  '${status}'=='False'
    ...  Fail  Not all TRXs states have expected values.
    Log  All TRXs states have expected values.  console=true


TRXs States Check In Infomodel
    [Arguments]  ${trxs_dn_list}  ${expected_state}

    FOR  ${trx_dn}  IN  @{trxs_dn_list}
        ${trx_state}  Query Infomodel  get count ${trx_dn} is [stateInfo.availabilityStatus=Online]
        Run Keyword If  ${CHECK_TRX_STATE} and ${trx_state}
        ...  Set TRX StateInfo Varibles
        Wait Until Keyword Succeeds  3min  15sec
        ...  Query Infomodel  check ${trx_dn} is [${expected_state}]
    END


Set TRX StateInfo Varibles
    Set Test Variable  ${CHECK_TRX_STATE}  ${False}
    Set Test Variable  ${TRX_STATE_NOT_LOCKED}  stateInfo.administrativeState=${UNLOCKED}
    ...  stateInfo.blockingState=${UNBLOCKED}, stateInfo.operationalState=${ENABLED}, stateInfo.usageState=${ACTIVE}
    Set Test Variable  ${EXPECTED_STATE}  ${TRX_STATE_NOT_LOCKED}
    ${var_trx_state_locked}  Catenate  stateInfo.administrativeState=${LOCKED}  stateInfo.blockingState=${UNBLOCKED}
    ...  stateInfo.operationalState=${DISABLED}  stateInfo.usageState=${IDLE}
    Set Test Variable  ${TRX_STATE_LOCKED}  ${var_trx_state_locked}


BCF States Verification
    [Arguments]  ${bcf_admin_state}  ${bcf_oper_state}  ${trx_oper_state}  ${trx_admin_state}

    Verify BCF Status  ${bcf_admin_state}  ${bcf_oper_state}
    Verify TRXs States On BSC  ${trx_oper_state}  ${trx_admin_state}
    Verify OM Link State


Verify BCF Status
    [Arguments]  ${bcf_admin_state}  ${bcf_oper_state}

    Log  BCF status verification.  console=true
    ${bcf_states}  Run Keyword And Return Status
    ...  Check BCF Status  ${bcf_admin_state}  ${bcf_oper_state}
    Run Keyword If  '${bcf_states}'=='False'
    ...  Fail  Invalid BCF state.
    Log  BCF states have expected values. Administrative State: ${bcf_admin_state}, Operational State: ${bcf_oper_state}.  console=true


Check BCF Status
    [Arguments]  ${bcf_admin_state}  ${bcf_oper_state}

    ${bcf_administrative_state}  ${bcf_operational_state}  hran_bsc.Get Bcf Status  ${BCF_ID}
    Should Be Equal As Strings  ${bcf_administrative_state}  ${bcf_admin_state}
    Log  BCF administrative state = ${bcf_administrative_state}  console=true
    Should Be Equal As Strings  ${bcf_operational_state}  ${bcf_oper_state}
    Log  BCF operational state = ${bcf_operational_state}  console=true


Verify TRXs States On BSC
    [Arguments]  ${trx_oper_state}  ${trx_admin_state}  # WO, BL-USR; U, L.

    ${status}  Run Keyword And Return Status
    ...  Check Trxs States On BSC  ${trx_oper_state}  ${trx_admin_state}
    Run Keyword If  '${status}'=='False'
    ...  Fail  Some TRXs states are different than expected.
    Log  All TRXs have expected values. Administrative State: U, Operational State: WO  console=true


Check Trxs States On BSC
    [Arguments]  ${trx_oper_state}  ${trx_admin_state}  # WO, BL-USR; U, L.

    hran_bsc.Parse BCF Trxs Status  bcf_id=${BCF_ID}  expected_operational_state=${trx_oper_state}  expected_administrative_state=${trx_admin_state}


Verify OM Link State
    ${status}  Run Keyword And Return Status
    ...  Check OM Link State
    Run Keyword If  '${status}'=='False'
    ...  Fail  Invalid OM link state.
    Log  OM link state has expected value: WO.  console=true


Check OM Link State
    ${om_link_state}  hran_bsc.Get OM Link State  bcf_id=${BCF_ID}
    Should Be Equal As Strings  ${om_link_state}  WO


Get Serial Numbers Of Radio Modules
    [Arguments]  ${rmods_distnames}

    ${rmods_serial_numbers}  Create Dictionary
    FOR  ${rmod_single_distname}  IN  @{rmods_distnames}
        ${rmod_obj}  Query Infomodel  get object ${rmod_single_distname}
        Set To Dictionary  ${rmods_serial_numbers}  ${rmod_obj['serialNumber']}=${rmod_single_distname}
    END

    [Return]  ${rmods_serial_numbers}


Check Parameters
    ${sector_ids}  hran_bsc.Get Sectors Ids  ${BCF_ID}  alias=${False}
    Log  List of BTS IDs: ${sector_ids} on BCF: ${BCF_ID}
    ${msg}  Set Variable  BCF parameters entered by user mismatch with actual configuration.
    Run Keyword If  '${GSM_SECTOR_ID}'!='${EMPTY}'
    ...  List Should Contain Value  ${sector_ids}  ${GSM_SECTOR_ID}  msg=${msg}


Get Dist_names Of Tested TRXs
    [Documentation]  For a list of TRX IDs return a list of respective CARRIERGROUPC_R dist_names
    ...  *EXAMPLE*
    ...  ${list_of_trx_ids}  ['001', '002']
    ...  or ${list_of_trx_ids}  ['1', '2']
    ...  =>  ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-1/CARRIERGROUPC_R-1',
    ...   '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-1/CARRIERGROUPC_R-2']
    ...
    ...  *AUTHOR*
    ...  andrzej.cichon@nokia.com
    [Arguments]  ${list_of_trx_ids}

    ${mapping}  Get TRX To CARRIERGROUPC Mapping
    ${dns}  Create List
    FOR  ${trx_id}  IN  @{list_of_trx_ids}
        ${trx_id_normalized}  _Normalize TRX ID  ${trx_id}
        ${carriergroupc_r_dn}  Get From Dictionary  ${mapping}  ${trx_id_normalized}
        Append To List  ${dns}  ${carriergroupc_r_dn}
    END

    [Return]  ${dns}


Get TRX To CARRIERGROUPC Mapping
    [Documentation]
    ...  *EXAMPLE*
    ...  ${trx_to_carriergroupc_mapping}  Get TRX To CARRIERGROUPC Mapping
    ...  ${trx_to_carriergroupc_mapping} =>
    ...  {'1': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-1/CARRIERGROUPC_R-1',
    ...  '2': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-1/CARRIERGROUPC_R-2',
    ...  '3': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-2/CARRIERGROUPC_R-2',
    ...  '4': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-2/CARRIERGROUPC_R-1',
    ...  '5': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-3/CARRIERGROUPC_R-1',
    ...  '6': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_R-3/CARRIERGROUPC_R-2'}

    ${gncel_r_dn_list}  Get IDs For All  GNCEL
    Sort List  ${gncel_r_dn_list}

    ${trx_to_carriergroupc_mapping}  Create Dictionary
    FOR  ${gncel_r}  IN  @{gncel_r_dn_list}
        ${carriergroupc_r_d_ns}  Infomodel Get Objects Parameter  ${gncel_r}/CARRIERGROUPC_R-*  dist_name
        Sort List  ${carriergroupc_r_d_ns}
        _Resolve TRX IDs And Add To Dictionary  ${trx_to_carriergroupc_mapping}  ${carriergroupc_r_d_ns}
    END

    [Return]  ${trx_to_carriergroupc_mapping}


_Resolve TRX IDs And Add To Dictionary
    [Documentation]
    ...  For each CARRIERGROUPC_R dist_name resolve TRX ID
    ...  and add it to a dictionary as TRX_ID : CARRIERGROUPC_R_DN
    [Arguments]  ${dict}  ${carriergroupc_r_d_ns}

    FOR  ${carriergroupc_r}  IN  @{carriergroupc_r_d_ns}
        ${ref}  Set Variable  ${carriergroupc_r}/REF-*
        ${carrier_group_l}  Infomodel Get Objects Parameter  ${ref}  distName
        ${carrier_group_l}  Evaluate  [dist_name for dist_name in ${carrier_group_l} if 'CARRIER_GROUP_L' in dist_name]
        ${carrier_group_l}  Get From List  ${carrier_group_l}  0
        ${trx_id}  Infomodel Get Objects Parameter  ${carrier_group_l}/CARRIER_GROUPC_L-*  trxId
        ${trx_id}  Get From List  ${trx_id}  0
        ${trx_id}  Convert To String  ${trx_id}
        Set To Dictionary  ${dict}  ${trx_id}=${carriergroupc_r}
    END


_Normalize TRX ID
    [Documentation]
    ...  Assure trx id to be a string with no leading zeros
    [Arguments]  ${trx_id}

    ${output}  Evaluate  int(${trx_id})
    ${output}  Convert To String  ${output}

    [Return]  ${output}


_GSM TRX Unlock
    Run Keyword If  '${TRX_ID}'=='${EMPTY}' and '${GSM_SECTOR_ID}'=='${EMPTY}'
    ...  Unlock All GSM TRXs On BCF
    ...  ELSE IF  '${TRX_ID}' and '${GSM_SECTOR_ID}'
    ...  Unlock Specific TRX On BTS  ${TRX_ID}  ${GSM_SECTOR_ID}
    ...  ELSE IF  '${TRX_ID}'=='${EMPTY}' and '${GSM_SECTOR_ID}'!='${EMPTY}'
    ...  Unlock TRXs On BTS  ${GSM_SECTOR_ID}


TC Setup
    Common Test Setup
    STATE__GSM_TRX_lock_unlock_from_BSC.Specific Test Setup


TC Teardown
    Test Specific Teardown
