*** Settings ***
Documentation
    ...  Step 0: Check All Additional State Before Test
    ...  Step 1: GSM BCF lock from BSC
    ...  Step 2: GSM BCF unlock from BSC

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  5  # Timeout to check all GSM required states in minutes


*** Keywords ***
TC__STATE__GSM_BCF_lock_unlock_from_BSC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7147
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 25.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7147 - Initial creation
    ...  - 22.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7458 - WCDMA Cells state changed
    ...  - 30.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8395
    ...  - 14.12.2017 - https://jira3.int.net.nokia.com/browse/TAT-8566 increased timeout to 10 min after unlock BCF
    ...  - 21.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10345
    ...  - 02.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12449 - Add allowed alarams due to RP001063 delivery
    ...  - 26.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12862 - Add Run Keyword And Continue On Failure before Log all Tx Power
    ...  - 15.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16184 - Removed Get File From Master Sysmod keyword from Fail Test And Collect
    ...                                                              all Data (swconfig is collected during Common Test Teardown)
    ...  - 10.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-18934 - Add BCF unlock to TC Terdown
    ...  - 06.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-20049 - Add TL recovery action
    ...  - 11.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-22030 - Update bsc connection to ssh
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7147.png#
    ...

    Set Tags  CA-STATE  OWNER-robert.susz@nokia.com  AUTHOR-michal.kwasniewicz@nokia.com  MAINTAINER-robert.susz@nokia.com  GROUP_IN_CHARGE-WRO_8_Vrf
    ...  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step 0: Check All Additional States Before Test
    Step 1: GSM BCF Lock From BSC
    Step 2: GSM BCF Unlock From BSC


Custom Test Setup
    Common Test Setup
    Connect To BSC Setup


Setup Required Test Variables
    [Tags]  Helper

    ${lte_exist}  Query Infomodel  ${DIST_LTE_CELL}  allow_negative_result=${True}
    Set Test Variable  ${LTE_EXIST}
    ${wcdma_exist}  Query Infomodel  ${DIST_WCDMA_CELL}  allow_negative_result=${True}
    Set Test Variable  ${WCDMA_EXIST}
    Set Test Variable  ${LTE_CELLS_DISTNAME}  /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*//LNCEL_R-*
    Set Test Variable  ${GSM_CELL_DISTNAME}  /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*//GNCEL_R-*
    Set Test Variable  ${WCDMA_CELLS_DISTNAME}  /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*//WNCEL_R-*
    Set Test Variable  ${CARRIER}  /CARRIERGROUPC_R-*
    Set Test Variable  ${UNLOCKED_ST_INFO}  blockingState=${UNBLOCKED}, operationalState=${ENABLED}, usageState=${ACTIVE}
    Set Test Variable  ${UNLOCKED_PROCEDURAL_ST}  [stateInfo.proceduralState=${ON_AIR_DONE}]
    Set Test Variable  ${LOCKED_CARRIER_STATES}
    ...  blockingState=${UNBLOCKED}, operationalState=${DISABLED}, administrativeState=${LOCKED}, usageState=${IDLE}
    Set Test Variable  ${LOCKED_GSM_CELL_STATES}  blockingState=${UNBLOCKED}, operationalState=${DISABLED}, usageState=${IDLE}
    Set Test Variable  ${LOCKED_PROCEDURAL_STATE}  [stateInfo.proceduralState=${VALIDATED}]
    ${bcf_id}  Infomodel Get BcfId
    Set Test Variable  ${BCF_ID}


Om Link State Should Be
    [Arguments]  ${state}

    ${om_link_state}  hran_bsc.Get Om Link State  ${BCF_ID}
    Should Be Equal As Strings  ${state}  ${om_link_state}  State is not ${state}
    Log  Om Link State is as expected - ${om_link_state}  console=true


Infomodel Check Other Technology States
    Assert All Cells Are In Expected State  check_gsm=${FALSE}


Infomodel Check GSM Required States
    [Arguments]  ${st_info_cells}  ${procedural_st}  ${logging}

    ${verdict_1}  Verify Cells  GSM  ${st_info_cells}
    ${verdict_2}  _Infomodel Check State  ${DIST_GSM_CELL}  ${procedural_st}  ${logging}
    @{verdict_gsm_list}  Create List  ${verdict_1}  ${verdict_2}
    Set Test Variable  ${VERDICT_GSM_LIST}
    Run Keyword If  ${verdict_1} and ${verdict_2}
    ...  Log  GSM states are correct!  console=true
    ...  ELSE
    ...  Fail  Some states for GSM are incorrect!!! TEST FAIL!!!


_Infomodel Check State
    [Arguments]  ${distname}  ${state}  ${logging}

    ${verdict}  Run Keyword And Return Status
    ...  Query Infomodel  every ${distname} is ${state}
    Run Keyword If  ${logging}
    ...  _Log Message About State  ${verdict}  ${distname}

    [Return]  ${verdict}


_Log Message About State
    [Arguments]  ${verdict}  ${distname}

    Run Keyword If  ${verdict}
    ...  Log  All states under ${distname} are correct.  console=true
    ...  ELSE
    ...  Log  Some states under ${distname} are incorrect!!!  console=true


BCF States Should Be
    [Arguments]  ${administrative}  ${operational}

    ${state_list}  hran_bsc.Get Bcf Status  ${BCF_ID}
    Should Be Equal As Strings  ${state_list[0]}  ${administrative}
    Should Be Equal As Strings  ${state_list[1]}  ${operational}


Check All GSM States
    [Arguments]  ${st_info_cells}  ${procedural_st}  ${operational_st}  ${administrative_st}  ${administrative_bcf}

    ${verdict_1}  Run Keyword And Return Status
    ...  Infomodel Check GSM Required States  ${st_info_cells}  ${procedural_st}  ${False}
    ${verdict_2}  hran_bsc.Parse Bcf Trxs Status  ${BCF_ID}  ${operational_st}  ${administrative_st}  ${True}
    ${verdict_3}  Run Keyword And Return Status
    ...  BCF States Should Be  ${administrative_bcf}  ${operational_st}
    Set Test Variable  ${BCF_VERDICT}  ${verdict_3}
    Set Test Variable  ${TRX_VERDICT}  ${verdict_2}
    Run Keyword If  ${verdict_1} and ${verdict_2} and ${verdict_3}
    ...  Log  GSM states are correct!  console=true
    ...  ELSE
    ...  Fail


Send BSC Lock Command
    hran_bsc.Lock Bcf  ${BCF_ID}
    Log  BSC lock command sent successfully.  console=true


Send BSC Unlock Command
    hran_bsc.Unlock Bcf  ${BCF_ID}
    Log  BSC unlock command sent successfully.  console=true


Fail Test And Collect All Data
    [Arguments]  ${unlock_bsc}

    Log  Test Fail!!!  console=true
    Run Keyword If  ${unlock_bsc}
    ...  Send BSC Unlock Command
    Fail


Step 0: Check All Additional States Before Test
    Log  \nStep 0: Check All Additional State Before Test\n  console=true
    Setup Required Test Variables
    ${verdict_1}  Run Keyword And Return Status
    ...  Infomodel Check Other Technology States
    ${verdict_2}  Run Keyword And Return Status
    ...  Infomodel Check GSM Required States  ${UNLOCKED_ST_INFO}  ${UNLOCKED_PROCEDURAL_ST}  ${True}
    ${verdict_3}  Run Keyword And Return Status
    ...  Om Link State Should Be  WO
    ${verdict_4}  hran_bsc.Parse Bcf Trxs Status  ${BCF_ID}  WO  U  ${True}
    ${verdict_5}  Run Keyword And Return Status
    ...  BCF States Should Be  U  WO
    Run Keyword If  ${verdict_5}
    ...  Log  BCF states are correct!  console=true
    ...  ELSE
    ...  Log  BCF states are incorrect!!!  console=true
    Run Keyword If  ${verdict_1} and ${verdict_2} and ${verdict_3} and ${verdict_4} and ${verdict_5}
    ...  Log  Pre-test states are correct!  console=true
    ...  ELSE
    ...  Set Test Norun  Some of the pre-test states are incorrect!!!!


Log Info About GSM State
    @{distname_list}  Create List  ${GSM_CELL_DISTNAME}${CARRIER}  ${GSM_CELL_DISTNAME}  ${DIST_GSM_CELL}
    FOR  ${index}  IN RANGE  0  2
        Run Keyword If  ${VERDICT_GSM_LIST[${index}]}
        ...  Log  All states under ${distname_list[${index}]} are correct.  console=true
        ...  ELSE
        ...  Log  Some states under ${distname_list[${index}]} are incorrect!!!  console=true
    END

    Run Keyword If  ${TRX_VERDICT}
    ...  Log  All TRX state from BSC are correct.  console=true
    ...  ELSE
    ...  Log  Some TRX state from BSC are incorrect!!!  console=true

    Run Keyword If  ${BCF_VERDICT}
    ...  Log  BCF states are correct.  console=true
    ...  ELSE
    ...  Log  BCF states are incorrect!!!  console=true


Step 1: GSM BCF Lock From BSC
    Log  \nStep 1: GSM BCF lock from BSC\n  console=true
    Send BSC Lock Command
    ${verdict_1}  Run Keyword And Return Status
    ...  Infomodel Check Other Technology States
    Log  Wait ${STARTUP_TIMEOUT} min until all GSM states are correct.  console=true
    ${verdict_2}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT} min  30 sec
    ...  Check All GSM States  ${LOCKED_GSM_CELL_STATES}  ${LOCKED_PROCEDURAL_STATE}  BL-USR  U  L
    Log Info About GSM State
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check Active Alarms TAF  collect_snapshot=${False}
    Run Keyword If  ${verdict_1} and ${verdict_2}
    ...  Log  Cells states are correct!  console=true
    ...  ELSE
    ...  Fail Test And Collect All Data  ${True}


Step 2: GSM BCF Unlock From BSC
    Log  \nStep 2: GSM BCF unlock from BSC\n  console=true
    Send BSC Unlock Command
    ${verdict_1}  Run Keyword And Return Status
    ...  Infomodel Check Other Technology States
    Log  Wait ${STARTUP_TIMEOUT} min until all GSM states are correct.  console=true
    ${verdict_2}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT} min  30 sec
    ...  Check All GSM States  ${UNLOCKED_ST_INFO}  ${UNLOCKED_PROCEDURAL_ST}  WO  U  U
    Log Info About GSM State
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check Active Alarms TAF  collect_snapshot=${False}
    Run Keyword If  ${verdict_1} and ${verdict_2}
    ...  Log  Cells states are correct!  console=true
    ...  ELSE
    ...  Fail Test And Collect All Data  ${False}


Custom Test Teardown
    Send BSC Unlock Command
    hran_bsc.Close Connection
    Common Test Teardown  collect_snapshot=passed_with_restriction
    Recover Test Line By Power Reset


TC Setup
    STATE__GSM_BCF_lock_unlock_from_BSC.Custom Test Setup


TC Teardown
    STATE__GSM_BCF_lock_unlock_from_BSC.Custom Test Teardown
