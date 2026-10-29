*** Settings ***
Documentation
    ...  This is the resource for STATE__LTE_S1_Lock_Unlock TC

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__STATE__LTE_S1_Lock_Unlock
    Set Tags  CA-STATE  OWNER-rafal.wisniewski@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  AUTHOR-slawomir.klos@nokia.com  PHASE-CR1  SW-SBTS17
    ...  SW-SBTS18  FEATURE-RP001578_LTE1910

    TC Preconditions
    Step1: S1 Link Status Check
    Step2: S1 Link Lock
    Step3: S1 Link Unlock


Custom Test Teardown
    FOR  ${s1_dn}  IN  @{S1_DN_LIST}
        Run Keyword If Test Failed
        ...  Run Keywords
        ...  Log  \nLNMME administrative state recovery  level=WARN  console=true
        ...  AND
        ...  Perform Parameter Recommissioning  ${s1_dn}  administrativeState  update  unlocked  skip_parameter_relation_errors=${True}  timeout=1200
    END
    Common Test Teardown


TC Preconditions
    ${s1_object_list}  Query Infomodel  get list //SCF-*//LNMME_A-*
    ${lnbts_dn_list}  Create List
    ${s1_dn_list}  Create List
    FOR  ${s1_object}  IN  @{s1_object_list}
        ${s1_object_dn}  Remove String Using Regexp  ${s1_object}[dist_name]  .*/SCF-\\d/
        ${s1_dn}  Remove String Using Regexp  ${s1_object_dn}  _A
        ${lnbts_dn}  Remove String Using Regexp  ${s1_dn}  /LNMME-\\d
        Append To List  ${lnbts_dn_list}  ${lnbts_dn}
        Append To List  ${s1_dn_list}  ${s1_dn}
    END
    Set Test Variable  ${LNBTS_DN_LIST}
    Set Test Variable  ${S1_DN_LIST}
    Set Test Variable  ${LTE_STATES_S1_LOCKED}  blockingState=${UNBLOCKED}, administrativeState=${UNLOCKED}, operationalState=${DISABLED}
    # LTE states when S1 is locked

    FOR  ${lnbts_dn}  IN  @{LNBTS_DN_LIST}
        Perform Parameter Recommissioning  ${lnbts_dn}  s1InducedCellDeactDelayTime  update  60  skip_parameter_relation_errors=${True}  timeout=1200
    END


Step1: S1 Link Status Check
    ${s1_status}  Run Keyword And Return Status
    ...  Query Infomodel  check //LNMME_R-* is [s1LinkStatus=available]  allow_negative_result=True
    Run Keyword If  not ${s1_status}
    ...  Fail  Incorrect s1LinkStatus, test failed.


Step2: S1 Link Lock
    Log  \nLocking s1 link  console=true
    FOR  ${s1_dn}  IN  @{S1_DN_LIST}
        Perform Parameter Recommissioning  ${s1_dn}  administrativeState  update  locked  skip_parameter_relation_errors=${True}  timeout=1200
    END
    ${verdict_1}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  20 sec
    ...  Verify Cells States  lte_procedural_state=regex"Validated|Initializing"  lte_states_s1=${STATES_ON_LOCK_LNMME}  s1_status=unavailable
    Run Keyword If  not ${verdict_1}
    ...  Fail  One or more states are incorrect, test failed.
    Check Alarms And Log TX Power


Step3: S1 Link Unlock
    Log  \nUnlocking s1 link  console=true
    FOR  ${s1_dn}  IN  @{S1_DN_LIST}
        Perform Parameter Recommissioning  ${s1_dn}  administrativeState  update  unlocked  skip_parameter_relation_errors=${True}  timeout=1200
    END
    ${verdict_2}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  20 sec
    ...  Verify Cells States  lte_procedural_state=OnAirDone  lte_states_s1=${STATES_ONAIR_LG}  s1_status=available
    ${verdict_3}  Run Keyword And Return Status
    ...  Assert Every  RMOD  ${STATES_ONAIR_RMOD}
    Run Keyword If  not ${verdict_2} or not ${verdict_3}
    ...  Fail  One or more states are incorrect,test failed.
    Check Alarms And Log TX Power


Verify Cells States
    [Arguments]  ${lte_procedural_state}  ${lte_states_s1}  ${s1_status}

    Log  \nCheck cells states  console=true

    Assert All Cells Are In Expected State  check_lte=${FALSE}

    Run Keywords
    ...  Assert Every  LNCEL  ${lte_states_s1}
    ...  AND
    ...  Assert No  LNCEL  ${DEGRADED_CELL_REGEX}  timeout=20
    ...  AND
    ...  Admin Check Cells Number  LNCEL  ${SCF_COUNT_LTE}

    Run Keywords
    ...  Query Infomodel  every /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=${lte_procedural_state}]
    ...  AND
    ...  Query Infomodel  check //LNMME_R-* is [s1LinkStatus=${s1_status}]  allow_negative_result=True


Check Alarms And Log TX Power
    Admin Check Active Alarms TAF
    Admin Set Test Restriction If Active Alarms Exist TAF
    Run Keyword And Ignore Error
    ...  Log All Tx Power


TC Setup
    Common Test Setup  tc_name=STATE__LTE_S1_Lock_Unlock


TC Teardown
    Custom Test Teardown
