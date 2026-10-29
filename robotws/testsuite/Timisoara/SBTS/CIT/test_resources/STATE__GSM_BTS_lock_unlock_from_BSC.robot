*** Settings ***
Documentation
    ...  Step 0: Check All Additional States Before Test
    ...  Step 1: GSM BCF lock from BSC
    ...  Step 2: GSM BCF unlock from BSC

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${BCF_SECTOR_TO_LOCK}  ${EMPTY}  # GSM BTS Id, e.g. 1154 (BCF sector). If this value is empty, lock all sectors on BCF.
${STARTUP_TIMEOUT}  5  # Timeout to check all GSM required states in minutes
${DEGRADED_TRX_REGEX_NO_CNI}  [stateInfo.availabilityStatus=${DEGRADED}]
${STATES_ONAIR_TRX_NO_CNI}  [stateInfo.administrativeState=${UNLOCKED}, stateInfo.blockingState=${UNBLOCKED}, stateInfo.operationalState=${ENABLED}]
${STATES_ON_LOCK_TRX_NO_CNI}  [stateInfo.administrativeState=${LOCKED}, stateInfo.blockingState=${UNBLOCKED}, stateInfo.operationalState=${DISABLED}]


*** Keywords ***
TC__STATE__GSM_BTS_lock_unlock_from_BSC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7148
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 08.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7148 - Initial creation
    ...  - 30.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8395
    ...  - 21.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10193
    ...  - 02.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12449 - Add allowed alarams due to RP001063 delivery
    ...  - 26.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12862 - Add Run Keyword And Continue On Failure before Log all Tx Power
    ...  - 15.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16184 - Removed Get File From Master Sysmod from Fail Test And Collect all Data
    ...                                                              (swconfig is collected during Common Test Teardown)
    ...  - 10.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-18934 - Add GSM_BTS unlock to TC Terdown
    ...  - 07.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-20052 - Add TL recovery action
    ...  - 11.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-22030 - Update bsc connection to ssh
    ...  - 19.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22220 - [CNI-61110] Tests refactoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7148.png#
    ...

    Set Tags  CA-STATE  OWNER-robert.susz@nokia.com  AUTHOR-michal.kwasniewicz@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step 0: Check All Additional States Before Test
    Step 1: GSM BTS Lock
    Step 2: GSM BTS Unlock


Custom Test Setup
    Common Test Setup
    Connect To BSC Setup


Om Link State Should Be
    [Arguments]  ${state}

    ${om_link_state}  hran_bsc.Get Om Link State  ${BCF_ID}
    Should Be Equal As Strings  ${state}  ${om_link_state}  State is not ${state}
    Log  Om Link State is as expected - ${om_link_state}  console=true


Setup Required Test Variables
    [Tags]  Helper

    ${bcf_id}  Infomodel Get BcfId
    Set Test Variable  ${BCF_ID}
    Set Test Variable  ${GSM_CELLS}  /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*//GNCEL_R-*
    Set Test Variable  ${CARRIER}  /CARRIERGROUPC_R-*


Infomodel Check Other Technology States
    Assert All Cells Are In Expected State  check_gsm=${FALSE}


_Infomodel Check States
    [Arguments]  ${distname}  ${state}  ${logging}

    ${verdict}  Run Keyword And Return Status
    ...  Query Infomodel  every ${distname} is ${state}
    Run Keyword If  ${logging}
    ...  _Log Message About States  ${verdict}  ${distname}

    [Return]  ${verdict}


_Log Message About States
    [Arguments]  ${verdict}  ${distname}

    Run Keyword If  ${verdict}
    ...  Log  All states under ${distname} are correct.  console=true
    ...  ELSE
    ...  Log  Some states under ${distname} are incorrect!!!  console=true


Lock BCF Sector
    Log  Lock BCF sector/s  console=true
    Run Keyword If  '${BCF_SECTOR_TO_LOCK}'
    ...  hran_bsc.Lock Sector  ${BCF_SECTOR_TO_LOCK}
    ...  ELSE
    ...  hran_bsc.Lock All Sectors  ${BCF_ID}
    Log  BCF sector/s locked  console=true


Unlock BCF Sector
    Log  Unlock BCF sector/s  console=true
    Run Keyword If  '${BCF_SECTOR_TO_LOCK}'
    ...  hran_bsc.Unlock Sector  ${BCF_SECTOR_TO_LOCK}
    ...  ELSE
    ...  hran_bsc.Unlock All Sectors  ${BCF_ID}
    Log  BCF sector/s unlocked  console=true


Check All GSM Cells States
    [Arguments]  ${states}

    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Run Keywords
    ...  Assert Every  GNCEL  ${states}
    ...  AND
    ...  Assert No  GNCEL  ${DEGRADED_CELL_REGEX}  timeout=20
    ...  AND
    ...  Admin Check Cells Number  GNCEL  ${SCF_COUNT_GSM}


Check States When BSC Sectors Are Locked
    Run Keyword If  '${BCF_SECTOR_TO_LOCK}'
    ...  Check GSM States When One BSC Sector Is Locked
    ...  ELSE
    ...  Check All GSM Cells States  ${STATES_ON_LOCK_LG}


Check States When BSC Sector Are Unlocked
    Check All GSM Cells States  ${STATES_ONAIR_LG}


Check GSM States When One BSC Sector Is Locked
    ${locked_cell}  Get Locked GSM Cell Distname
    ${verdict_1}  Run Keyword And Return Status
    ...  Check GSM Carrier State  ${locked_cell}  ${STATES_ON_LOCK_TRX_NO_CNI}  ${STATES_ON_LOCK_TRX}
    ${verdict_2}  Run Keyword And Return Status
    ...  Assert  GNCEL  ${locked_cell}  ${STATES_ON_LOCK_LG}
    ${unlocked_cells}  Get Unlocked GSM Cells Distname
    ${cells_number}  Evaluate  len(${unlocked_cells})
    ${verdict_3}  Run Keyword If  ${cells_number}>=1
    ...  Run Keyword And Return Status
    ...  _Check Other Unlocked Cells States  ${unlocked_cells}
    ${final_verdict}  Evaluate  ${verdict_1} and ${verdict_2} and ${verdict_3}
    Run Keyword If  ${final_verdict}
    ...  Log  GSM states are correct!  console=true
    ...  ELSE
    ...  Fail  Some states for GSM are incorrect!!! TEST FAIL!!!


Check GSM Carrier State
    [Arguments]  ${cell_distname}  ${states}  ${cni_states}

    ${status_1}  Run Keyword And Return Status
    ...  _Infomodel Check States  ${CELL_DISTAME}${CARRIER}  ${states}  ${False}
    Run Keyword If  ${status_1}==${FALSE}
    ...  _Infomodel Check States  ${cell_distname}${CARRIER}  ${cni_states}  ${False}


_Check Other Unlocked Cells States
    [Arguments]  ${unlocked_cells}

    FOR  ${cell}  IN  @{unlocked_cells}
        ${verdict_1}  Run Keyword And Return Status
        ...  Check GSM Carrier State  ${cell}  ${STATES_ONAIR_TRX_NO_CNI}  ${STATES_ONAIR_TRX}
        ${verdict_2}  Run Keyword And Return Status
        ...  Assert  GNCEL  ${cell}  ${STATES_ONAIR_LG}
        Run Keyword If  ${verdict_1} and ${verdict_2}
        ...  Log  GSM ${cell} is in correct states!  console=true
        ...  ELSE
        ...  Fail
    END


Get Locked GSM Cell Distname
    ${locked_cell_obj}  Query Infomodel  get object ${GSM_CELLS} is [gsmBtsId=${BCF_SECTOR_TO_LOCK}]

    [Return]  ${locked_cell_obj.dist_name}


Get Unlocked GSM Cells Distname
    ${unlocked_cell_obj}  Query Infomodel  get list ${GSM_CELLS} is [gsmBtsId != ${BCF_SECTOR_TO_LOCK}]  allow_negative_result=${TRUE}
    ${distname_list}  Run Keyword If  ${unlocked_cell_obj}
    ...  _Return Distname List  ${unlocked_cell_obj}
    ...  ELSE
    ...  Create List

    [Return]  ${distname_list}


_Return Distname List
    [Arguments]  ${list_obj}

    @{distname_list}  Create List
    FOR  ${cell_obj}  IN  @{list_obj}
        Append To List  ${distname_list}  ${cell_obj.dist_name}
    END

    [Return]  ${distname_list}


Check States BSC Sectors
    [Arguments]  ${operational}  ${administrative}

    Run Keyword If  '${BCF_SECTOR_TO_LOCK}'
    ...  _BSC Locked And Unlocked Sectors State  ${operational}  ${administrative}
    ...  ELSE
    ...  _BSC All Sectors State  ${operational}  ${administrative}


_BSC Locked And Unlocked Sectors State
    [Arguments]  ${operational}  ${administrative}

    ${sectors_status}  hran_bsc.Get Sectors Status  ${BCF_ID}
    FOR  ${sector_status}  IN  @{sectors_status}
        Run Keyword If  '${BCF_SECTOR_TO_LOCK}' in '${sector_status[0]}'
        ...  Run Keywords
        ...  Should Be Equal As Strings  ${sector_status[1]}  ${administrative}
        ...  AND
        ...  Should Be Equal As Strings  ${sector_status[2]}  ${operational}
        ...  ELSE
        ...  Run Keywords
        ...  Should Be Equal As Strings  ${sector_status[1]}  U
        ...  AND
        ...  Should Be Equal As Strings  ${sector_status[2]}  WO
    END


_BSC All Sectors State
    [Arguments]  ${operational}  ${administrative}

    ${sectors_status}  hran_bsc.Get Sectors Status  ${BCF_ID}
    FOR  ${sector_status}  IN  @{sectors_status}
        Should Be Equal As Strings  ${sector_status[1]}  ${administrative}
        Should Be Equal As Strings  ${sector_status[2]}  ${operational}
    END


BSC Check Trx Status
    [Arguments]  ${operational}  ${administrative}

    Run Keyword If  '${BCF_SECTOR_TO_LOCK}'
    ...  _BSC Trx Status For Lock And Unlock Sectors  ${operational}  ${administrative}
    ...  ELSE
    ...  _BSC Trx Status For All Sectors  ${operational}  ${administrative}


_BSC Trx Status For Lock And Unlock Sectors
    [Arguments]  ${operational}  ${administrative}

    ${trx_list}  hran_bsc.Get Trxs List By Bts Id  ${BCF_SECTOR_TO_LOCK}
    ${trx_list_status}  hran_bsc.Get Trxs Status  ${BCF_ID}
    FOR  ${trx_bsc_data}  IN  @{trx_list_status}
        Run Keyword If  '${trx_bsc_data[0]}' in ${trx_list}
        ...  Run Keywords
        ...  Should Be Equal As Strings  ${operational}  ${trx_bsc_data[2]}
        ...  AND
        ...  Should Be Equal As Strings  ${administrative}  ${trx_bsc_data[1]}
        ...  ELSE
        ...  Run Keywords
        ...  Should Be Equal As Strings  WO  ${trx_bsc_data[2]}
        ...  AND
        ...  Should Be Equal As Strings  U  ${trx_bsc_data[1]}
    END


_BSC Trx Status For All Sectors
    [Arguments]  ${operational}  ${administrative}

    ${trx_list_status}  hran_bsc.Get Trxs Status  ${BCF_ID}
    FOR  ${trx_bsc_data}  IN  @{trx_list_status}
        Should Be Equal As Strings  ${operational}  ${trx_bsc_data[2]}
        Should Be Equal As Strings  ${administrative}  ${trx_bsc_data[1]}
    END


Check All Required States On BSC
    [Arguments]  ${operational_trx}  ${administrative_trx}  ${operational_s}  ${administrative_s}

    ${sectors}  Check States BSC Sectors  ${operational_s}  ${administrative_s}
    ${trx}  BSC Check Trx Status  ${operational_trx}  ${administrative_trx}
    ${final_verdict}  Evaluate  ${sectors} and ${trx}

    [Return]  ${final_verdict}


Check All Required GSM States
   [Arguments]  ${operational_trx}  ${administrative_trx}  ${operational_s}  ${administrative_s}  ${locked}

    ${verdict_1}  Run Keyword If  ${locked}
    ...  Run Keyword And Return Status
    ...  Check States When BSC Sectors Are Locked
    ...  ELSE
    ...  Run Keyword And Return Status
    ...  Check States When BSC Sector Are Unlocked
    ${verdict_2}  Run Keyword And Return Status
    ...  Check All Required States On BSC  ${operational_trx}  ${administrative_trx}  ${operational_s}  ${administrative_s}
    @{verdict_gsm_list}  Create List  ${verdict_1}  ${verdict_2}
    Set Test Variable  ${VERDICT_GSM_LIST}
    Run Keyword If  ${verdict_1} and ${verdict_2}
    ...  Log  BSC states are correct!  console=true
    ...  ELSE
    ...  Fail


Log Info About GSM States
    Run Keyword If  ${VERDICT_GSM_LIST[0]}
    ...  Log  All GSM states are corect.  console=true
    ...  ELSE
    ...  Log  Some GSM states are incorect!!!  console=true
    Run Keyword If  ${VERDICT_GSM_LIST[1]}
    ...  Log  All GSM BSC states are corect.  console=true
    ...  ELSE
    ...  Log  Some GSM BSC states are incorect!!!  console=true


Fail Test And Collect All Data
    [Arguments]  ${unlock_bsc}

    Log  Test Fail!!!  console=true
    Run Keyword If  ${unlock_bsc}
    ...  Unlock BCF Sector
    Fail


Step 0: Check All Additional States Before Test
    Log  Step 0: Custom Test Setup  console=true
    Setup Required Test Variables
    ${verdict_0}  Run Keyword And Return Status
    ...  Om Link State Should Be  WO
    ${verdict_1}  Run Keyword And Return Status
    ...  Infomodel Check Other Technology States
    ${verdict_2}  Run Keyword And Return Status
    ...  Check All GSM Cells States  ${STATES_ONAIR_LG}
    ${verdict_3}  Run Keyword And Return Status
    ...  Check All Required States On BSC  WO  U  WO  U
    Run Keyword If  ${verdict_1} and ${verdict_2} and ${verdict_3} and ${verdict_0}
    ...  Log  Pre-test states are correct!  console=true
    ...  ELSE
    ...  Set Test Norun  Some of the pre-test states are incorrect!!!!


Step 1: GSM BTS Lock
    Log  Step 1: GSM BTS Lock  console=true
    Lock BCF Sector
    Log  Check all states, timeout 3 min for GSM.  console=true
    ${verdict_1}  Run Keyword And Return Status
    ...  Infomodel Check Other Technology States
    ${verdict_2}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  25 sec
    ...  Check All Required GSM States  BL-USR  U  BL-USR  L  ${True}
    Log Info About GSM States
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check Active Alarms TAF  collect_snapshot=${False}
    Run Keyword If  ${verdict_1} and ${verdict_2}
    ...  Log  All states are correct!  console=true
    ...  ELSE
    ...  Fail Test And Collect All Data  ${True}


Step 2: GSM BTS Unlock
    Log  Step 2: GSM BTS Unlock  console=true
    Unlock BCF Sector
    Log  Check all states, timeout 3 min for GSM.  console=true
    ${verdict_1}  Run Keyword And Return Status
    ...  Infomodel Check Other Technology States
    ${verdict_2}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT} min  25 sec
    ...  Check All Required GSM States  WO  U  WO  U  ${False}
    Log Info About GSM States
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check Active Alarms TAF  collect_snapshot=${False}
    Run Keyword If  ${verdict_1} and ${verdict_2}
    ...  Log  All states are correct!  console=true
    ...  ELSE
    ...  Fail Test And Collect All Data  ${False}


Custom Test Teardown
    hran_bsc.Unlock All Sectors  ${BCF_ID}
    hran_bsc.Close Connection
    Common Test Teardown  collect_snapshot=passed_with_restriction
    Recover Test Line By Power Reset


TC Setup
    STATE__GSM_BTS_lock_unlock_from_BSC.Custom Test Setup


TC Teardown
    STATE__GSM_BTS_lock_unlock_from_BSC.Custom Test Teardown
