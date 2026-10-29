*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${LTE_STATES}  blockingState=${Unblocked_}, administrativeState=${Unlocked_}, operationalState=${Enabled_}
${WCDMA_STATES}  blockingState=${Unblocked_}, operationalState=${Enabled_}, usageState=${Active_}
${GSM_STATES}  administrativeState=${Unlocked_}, blockingState=${Unblocked_}, operationalState=${Enabled_}, usageState=${Active_}
${GSM_STATES_AFTER_BLOCK}  administrativeState=${Unlocked_}, blockingState=${Blocked_}, operationalState=${Disabled_}, usageState=${Idle_}
${BLOCKING_TIMEOUT}  600


*** Keywords ***
TC__WebEM__BCF_block_unblock_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10185
    ...
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  State verification when BCF is blocked then unblocked
    ...  In first step BCF is blocked from ADMIN - states for all cells and alarms are checked
    ...  In second step  BCF is unblocked - states for all cells and alarms are checked
    ...  Any unexpected cell state fails TC, any newly rised alarm different than fault 49 fails TC
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10649 - change KW Log TX-Power to Log all tx-power
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-11974 - Recovery actions and 1-2 RAT BTS support for STATE RGT TCs
    ...
    ...
    ...  - 12.06.2018 - initial creation
    ...  - 02.10.2020  https://jira3.int.net.nokia.com/browse/TAT-20267 - Fault 4614 - RAT blocked is reproted instead of 49 - BCF blocked
    ...  - 05.01.2021  https://jira3.int.net.nokia.com/browse/TAT-20719 - variable GSM_STATES_AFTER_BLOCK changed (availabilityStatus=Offline)
    ...  - 25.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21353 - Replacing KW block to TAF library
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 04.04.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22933 - Telnet connection to bsc replacement with SSH
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24952 - Replacing hran_infomodel to sbts_infomodel
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/BCF_block_unblock_from_admin.jpg

    Set Tags    CA-WebEM    OWNER-robert.susz@nokia.com    MAINTAINER-andreea.burtic@nokia.com
    ...    AUTHOR-daniel.bartkowiak@nokia.com    PHASE-CR1    SW-SBTS17    FEATURE-RP001498_RP000923
    ...    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923    FEATURE-RP0001145_RP000923

    Step1: Trigger BCF block
    Step2: Trigger BCF unblock


Step1: Trigger BCF block
    [Tags]  Step1
    Log  Step1: Trigger BCF-${BCF_ID} block from ADMIN  console=${True}
    Verify States of BCF Resources  operational_sector=WO  administrative_sector=U  operational_trx=WO  administrative_trx=U
    BCF Block
    Check Expected Alarms
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2 min  10 sec  Run Keywords
    ...  Verify States of BCF Resources  operational_sector=WO  administrative_sector=U  operational_trx=BL-TRX  administrative_trx=U
    ...  AND  _Verify WCDMA LTE GSM Cells States  ${GSM_STATES_AFTER_BLOCK}
    Run Keyword Unless   ${Status}  Set Test Failed  message=States after BCF block are different than expected.  fail_fast=${True}
    Log  All cells (WCDMA, LTE, GSM) on tested BTS, after BCF block from ADMIN, have expected states  console=${True}

Step2: Trigger BCF unblock
    Log  Step2: Trigger BCF-${BCF_ID} unblock from ADMIN      console=${True}
    BCF Unblock
    ${status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  10 min  30 sec  Run Keywords
    ...  Verify States of BCF Resources  operational_sector=WO  administrative_sector=U  operational_trx=WO  administrative_trx=U
    ...  AND  _Verify WCDMA LTE GSM Cells States  ${GSM_STATES}
    Run Keyword Unless   ${Status}  Set Test Failed  message=States after BCF unblock are different than expected.  fail_fast=${True}
    Log  All cells (WCDMA, LTE, GSM) on tested BTS, after BCF unblock from ADMIN, have expected states  console=${True}
    Admin Check Active Alarms TAF

Open BSC Session
    [Tags]  Flatten
    hran_bsc.Bsc ssh connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    hran_bsc.Set Timeout  240s

Get BCF ID
    [Tags]  Flatten
    Log  Getting BCF id from infomodel.  console=${True}
    ${BCF_ID}  sbts_infomodel.Infomodel Get BcfId
    Set Test Variable  ${BCF_ID}
    Log  BCF ID: ${BCF_ID}   console=${True}

Verify States of BCF Resources
    [Arguments]  ${operational_sector}  ${administrative_sector}  ${operational_trx}  ${administrative_trx}
    Log  BCF states Verification started.  console=${True}
    Check BCF States
    Log  BCF states have expected values. Administrative State: U, Operational State: WO.  console=${True}
    Log  Sectors states Verification started.  console=${True}
    hran_bsc.Parse BCF Sectors Status   bcf_id=${BCF_ID}  expected_operational_state=${operational_sector}
    ...  expected_administrative_state=${administrative_sector}
    Log  All Sectors have expected values. Administrative State: ${administrative_sector}, Operational State: ${operational_sector}  console=${True}
    Log  TRXs states Verification started.  console=${True}
    hran_bsc.Parse BCF Trxs Status  bcf_id=${BCF_ID}   expected_operational_state=${operational_trx}
    ...  expected_administrative_state=${administrative_trx}
    Log  All TRXs have expected values. Administrative State: ${administrative_trx}, Operational State: ${operational_trx}    console=${True}
    Log  OM link state Verification started.  console=${True}
    Check OM Link State
    Log  OM link state has expected value: WO.  console=${True}

Check BCF States
    [Tags]  Flatten
    ${bcf_administrative_state}  ${bcf_operational_state}  hran_bsc.Get BCF status  ${BCF_ID}
    Should Be Equal As Strings   ${bcf_administrative_state}  U
    Should Be Equal As Strings   ${bcf_operational_state}  WO

Check OM Link State
    ${om_link_state}  hran_bsc.Get OM Link State  bcf_id=${BCF_ID}
    Should Be Equal As Strings  ${om_link_state}  WO

BCF Block
    Log  Blocking BCF-${BCF_ID}  console=${True}
    ${GSM_NOTIFIERS}  Infomodel Get Objects Parameter  //GTS-*//BTS-*  dist_name  allow_negative_result=True
    Set Test Variable  ${GSM_NOTIFIERS}
    ${BCF_DISTNAME}  Infomodel Get Objects Parameter  //GNBCF_R-*  dist_name  allow_negative_result=True
    ${BCF_DISTNAME}  Get From List  ${BCF_DISTNAME}  0
    Set Test Variable  ${BCF_DISTNAME}
    ${status}  ${msg}  Run Keyword And Ignore Error  Block Rat  rat=GSM  timeout=${BLOCKING_TIMEOUT}
    Run Keyword Unless  '${status}'=='PASS'  Set Test Failed  message=Blocking BCF-${BCF_ID} failed  fail_fast=${True}
    Log  BCF-${BCF_ID} blocked  console=${True}
    sleep  5s

Check Expected Alarms
    Assert alarm active  faultId=${FAULT_4614}[fault_id], technology=GSM  timeout=150
    Log  Expected fault 4614 visible  console=${True}

_Verify WCDMA LTE GSM Cells States
    [Arguments]  ${GSM}
	Log  \nCheck cells states  console=${True}
    Run Keyword If  ${SCF_COUNT_GSM}  Run Keywords
    ...  Assert Every  GNCEL  ${GSM}
    ...  AND
    ...  Admin Check Cells Number  GNCEL  ${SCF_COUNT_GSM}
    Run Keyword If  ${SCF_COUNT_WCDMA}  Run Keywords
    ...  Assert Every  WNCEL  ${WCDMA_STATES}
    ...  AND
    ...  Admin Check Cells Number  WNCEL  ${SCF_COUNT_WCDMA}
    Run Keyword If  ${SCF_COUNT_LTE}  Run Keywords
    ...  Assert Every  LNCEL  ${LTE_STATES}
    ...  AND
    ...  Admin Check Cells Number  LNCEL  ${SCF_COUNT_LTE}

BCF Unblock
    Log  Unblocking BCF-${BCF_ID}  console=${True}
    ${status}  ${msg}  Run Keyword And Ignore Error  Unblock Rat  rat=GSM  timeout=${BLOCKING_TIMEOUT}
    Run Keyword Unless  '${status}'=='PASS'  Set Test Failed  message=Unblocking BCF-${BCF_ID} failed  fail_fast=${True}
    Log  BCF-${BCF_ID} unblocked  console=${True}

Try To Recover BCF From Block State
    Log  Trying to recover BCF-${BCF_ID} from block state  console=${True}
    ${status}  ${msg}  Run Keyword And Ignore Error  Unblock Rat  rat=GSM  timeout=${BLOCKING_TIMEOUT}
    Run Keyword Unless  '${status}'=='PASS'
    ...  Fail  message=Unblocking BCF-${BCF_ID} failed. Please try to unblock BCF manually.  fail_fast=${True}
    Log  BCF-${BCF_ID} unblocked  console=${True}


TC Setup
    Run Keywords
    ...  Common Test Setup  tc_name=WebEM__BCF_block_unblock_from_ADMIN
    ...  AND    WebEM__BCF_block_unblock_from_ADMIN.Open BSC Session
    ...  AND    WebEM__BCF_block_unblock_from_ADMIN.Get BCF ID

TC Teardown
    Run Keywords
    ...  Run Keyword If Test Failed  Try To Recover BCF From Block State
    ...  AND    Close all BSC sessions
    ...  AND    Common Test Teardown



