*** Settings ***
Documentation
    ...  In first step: S1 link is locked (all states are checked)
    ...  In second step: Site reset is performed (all states are checked)
    ...  In third step: S1 link is unlocked (all states are checked)
    ...
    ...  Restrictions:
    ...  Valid only for configuratin with one MME

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  10  # Time needed to restore BTS after reset, default value 10 min


*** Keywords ***
TC__STATE__S1_Lock_Reset_Unlock
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10465
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...
    ...  27.08.2018 - TC delivery
    ...  25.02.2020 - TAT-19032  restriction added - valid only for configuratin with one MME
    ...  15.06.2020 - TAT-19680  more than one MME handling
    ...  30.09.2022 - TAT-23756  S1 lock unlock tests are failing when checking NbIoT cells
    ...  19.01.2024 - TAT-26771 - Add watchdog alarm monitoring
    ...  26.08.2024 - TAT-27991 - Fix argument name
    ...  15.10.2025 - TAT-30023 - Add check for RMODs state after SBTS reset
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/s1_lock_unlock_reset.jpg

    Set Tags  CA-STATE  OWNER-grzegorz.gulaj@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  AUTHOR-daniel.bartkowiak@nokia.com  PHASE-CR1
    ...  SW-SBTS17  SW-SBTS18  FEATURE-RP001578_LTE1910

    TC Preconditions
    Step1: S1 Link Lock
    Step2: Site Reset
    Step3: S1 Link Unlock


TC Preconditions
    ${s1_status}  Run Keyword And Return Status
    ...  Query Infomodel  check //LNMME_R-* is [s1LinkStatus=available]  allow_negative_result=True
    IF  not ${s1_status}  Fail  Incorrect s1LinkStatus, test failed.
    ${s1_list}  Get MMEs Dist_name
    ${lnbts_dn}  Remove String Using Regexp  ${s1_list}[0]  /LNMME-\\d
    Set Test Variable  ${LNBTS_DN}  ${lnbts_dn}
    Set Test Variable  ${S1_LIST}
    Set Test Variable  ${LTE_STATES_S1_LOCKED}
    ...  availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Disabled
    Perform Parameter Recommissioning  ${LNBTS_DN}  s1InducedCellDeactDelayTime  update  60  skip_parameter_relation_errors=${True}  timeout=1200
    ${bts_info}  Get Bts Info
    ${status}  ${5g_cu_type}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${bts_info}  gNbCuType
    IF  "${5g_cu_type}" == "SA"
        Set Test Variable  ${CHECK_NR_CELLS}  ${TRUE}
    ELSE
        Set Test Variable  ${CHECK_NR_CELLS}  ${FALSE}
    END


Step1: S1 Link Lock
    Log  \nLocking s1 link  console=true
    FOR  ${s1_dn}  IN  @{S1_LIST}
        Perform Parameter Recommissioning  ${s1_dn}  administrativeState  update  locked  skip_parameter_relation_errors=${True}  timeout=1200
    END
    ${verdict_1}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  20 sec
    ...  Verify Cells States  lte_procedural_state=regex"Validated|Initializing"  lte_states_s1=${STATES_ON_LOCK_LNMME}  s1_status=unavailable
    IF  not ${verdict_1}  Fail  One or more states are incorrect, test failed.
    Check Alarms And Log TX Power


Step2: Site Reset
    Log  \nSBTS performs reset  console=true
    Reset Site  600
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}min  20 sec
    ...  Assert Every  RMOD  ${STATES_ONAIR_RMOD}
    ${verdict_2}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}min  20 sec
    ...  Verify Cells States  lte_procedural_state=regex"Validated|Initializing"  lte_states_s1=${STATES_ON_LOCK_LNMME}  s1_status=unavailable
    IF  not ${verdict_2}  Fail  One or more states are incorrect after site reset.
    Check Alarms And Log TX Power


Step3: S1 Link Unlock
    Log  \nUnlocking s1 link  console=true
    FOR  ${s1_dn}  IN  @{S1_LIST}
        Wait Until Keyword Succeeds  10min  1min
        ...  Perform Parameter Recommissioning  ${s1_dn}  administrativeState  update  unlocked  skip_parameter_relation_errors=${True}  timeout=1200
    END
    ${verdict_3}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  20 sec
    ...  Verify Cells States  lte_procedural_state=OnAirDone  lte_states_s1=${STATES_ONAIR_LG}  s1_status=available
    ${verdict_4}  Run Keyword And Return Status
    ...  Assert Every  RMOD  ${STATES_ONAIR_RMOD}
    IF  not ${verdict_3} or not ${verdict_4}  Fail  One or more states are incorrect,test failed.
    Check Alarms And Log TX Power


Verify Cells States
    [Arguments]  ${lte_procedural_state}  ${lte_states_s1}  ${s1_status}

    Log  \nCheck cells states  console=true
    Assert All Cells Are In Expected State  check_lte=${FALSE}  check_nr=${CHECK_NR_CELLS}

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


Get MMEs Dist_name
    ${mmes_dn_list}  Create List
    ${mmes_object}  Query Infomodel  get list //SCF-*//LNMME_A-*
    FOR  ${mme}  IN  @{mmes_object}
        ${mme_dn}  Remove String Using Regexp  ${mme.dist_name}  .*/SCF-\\d/
        ${mme_dn}  Remove String Using Regexp  ${mme_dn}  _A
        Append To List  ${mmes_dn_list}  ${mme_dn}
    END

    [Return]  ${mmes_dn_list}


Custom Test Teardown
    Log  \nLNMME administrative state recovery  level=WARN  console=true
    FOR  ${s1_dn}  IN  @{S1_LIST}
        Perform Parameter Recommissioning  ${s1_dn}  administrativeState  update  unlocked  skip_parameter_relation_errors=${True}  timeout=1200
    END
    Common Test Teardown


TC Setup
    Common Test Setup  tc_name=STATE__S1_Lock_Reset_Unlock


TC Teardown
    Custom Test Teardown
