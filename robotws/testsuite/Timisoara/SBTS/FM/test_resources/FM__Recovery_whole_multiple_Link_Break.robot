*** Settings ***
Documentation
    ...  step1:
    ...  Check all required states.
    ...  step2:
    ...  Actions in loop:
    ...  Break IuB Linkl
    ...  Break S1 Link
    ...  Break Abis Link
    ...  Break M Plane Link
    ...  Wait Random Time (1-30s)
    ...  Restore IuB Link
    ...  Restore S1 Link
    ...  Restore Abis Link
    ...  Restore M Plane Link
    ...  step3:
    ...  Check all required states.

Library  XML  use_lxml=true
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${NUMBER_OF_LOOPS}  6  # Number of loops with link breaks and restors. Default value 6.
${TIMEOUT_AFTER_RESTOR}  200  # Time to wait after link restoration in second


*** Keywords ***
TC__FM__Recovery_whole_multiple_Link_Break
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7556
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7556 - Initial creation
    ...  - 15.01.2018 - https://jira3.int.net.nokia.com/browse/TAT-8839 - added support not full RAT
    ...  - 29.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9318 - change KW for obtaining GSM NE IP address
    ...  - 09.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9679 - add KW for links restoration in teardown
    ...  - 19.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9326 - enhance sleep time to 120 seconds
    ...  - 23.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9662 - add -w option to iptables to prevent xtables lock
    ...  - 24.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-9851 - add new user parameter to customise time to wait after link restoration
    ...  - 01.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12376 - Add allowed alarams due to RP001063 delivery
    ...  - 15.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12646 - Improvment for `Step ${step}: Check All Required States`
    ...  - 16.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-12646 - correct bug in which secondary MME IP is not recognized
    ...  - 05.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14341 - check if ipAddrSec exist and if not, set variable to 'None'.
    ...  - 13.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14341 - fix bug TAT-14474
    ...  - 21.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14765 - support 4+3 (7)
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24943 - Import ca_FM_general
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 02.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27270 - Add fault for watchdog monitoring
    ...  - 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27990 - Fix argument name
    ...  - 04.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29030 - Quick fix for checking NR
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-michal.kwasniewicz@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001534  FEATURE-RP001145_RP000920
    ...  FEATURE-RP001486_RP000920

    Step 1: Check All Required States
    Step 2: Whole Multiple Short Link Breaks
    Step 3: Check All Required States


Step ${step}: Check All Required States
    IF  ${step}==1  Run Keyword And Return  Check All Required States  ${step}
    Log  \nWait ${TIMEOUT_AFTER_RESTOR}s after multiple link breaks.  console=true
    Wait Until Keyword Succeeds  ${TIMEOUT_AFTER_RESTOR}s  30s
    ...  Check All Required States  ${step}  simple_fail=${True}


Check All Required States
    [Arguments]  ${step}  ${simple_fail}=${False}

    Log  \nStep ${step}: Check All Required States  console=true
    ${obj_info}  Query Infomodel  get object //MRBTS_R-*
    ${obj_state_info}  Run Keyword And Return Status  Variable Should Exist  ${obj_info['stateInfo']}
    ${state_info_obj_r}  IF  ${obj_state_info}  Set Variable  stateInfo.  ELSE  Set Variable  ${EMPTY}
    Set Test Variable  ${STATE_INFO_OBJ_R}
    IF  ${SCF_COUNT_GSM}
      Query Infomodel  every /MRBTS-*/RAT-*/GTS-*/BCF_L-* is [abisOMLinkStatus = Available]
      Query Infomodel  every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/GNBTS_R-* is [${STATE_INFO_OBJ_R}operationalState=${ON_AIR}]
      Assert Every  GNCEL  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}, usageState=${ACTIVE}
    END

    IF  ${SCF_COUNT_WCDMA}
      Query Infomodel  every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/WNBTS_R-* is [${STATE_INFO_OBJ_R}operationalState=${ON_AIR}]
      Query Infomodel  every /MRBTS-*/RAT-*/WTS-*/RNC_L-* is [cnbapLinkStatus = Available, dnbapLinkStatus = Available]
      Assert Every  WNCEL  operationalState=${ENABLED},  blockingState=${UNBLOCKED}, usageState=${ACTIVE}
    END

    IF  ${SCF_COUNT_LTE}
      Assert Every  LNMME  s1LinkStatus=available
      Query Infomodel  every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-* is [${STATE_INFO_OBJ_R}operationalState=${ON_AIR}]
      Assert Every  LNCEL  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}
    END

    IF  ${SCF_COUNT_NR}  coam.Assert Every  NRCEL  operationalState=${ENABLED}

    ${configuration}  Check System Modules Configuration In InfoModel
    ${chain}  Set Variable If  '${configuration}' == '4+3'  FORWARD  INPUT
    Set Test Variable  ${CHAIN}

    Log  All states are correct.  console=true

    ${ignored_alarms}  Create Dictionary  severity=Warning|Minor
    ${ignored_alarms}  Create List  ${ignored_alarms}
    ${critical_alarms}  Create Dictionary  severity=.*
    ${critical_alarms}  Create List  ${critical_alarms}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  ignored_patterns=${ignored_alarms}  critical_patterns=${critical_alarms}

    IF  '${alarms_status}'=='FAIL' and ${simple_fail}  Fail  msg=${alarms_msg}

    IF  '${alarms_status}'=='FAIL'
      Set Test Failed  Critical fail while checking alarms: ${alarms_msg}
    ELSE IF  ${alarms_msg}
      Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    END


Step 2: Whole Multiple Short Link Breaks
    Log  \nStep 2: Whole Multiple Short Link Breaks\n Number of loops: ${NUMBER_OF_LOOPS}  console=true

    FOR  ${loop}  IN RANGE  1  ${NUMBER_OF_LOOPS}+1
        Log  Loop: ${loop}  console=true
        IF  ${SCF_COUNT_WCDMA}  Break IuB Link
        IF  ${SCF_COUNT_LTE}  Break S1 Link
        IF  ${SCF_COUNT_GSM}  Break Abis Link
        Break M Plane Link
        Wait Random Time
        IF  ${SCF_COUNT_WCDMA}  Restore IuB Link
        IF  ${SCF_COUNT_LTE}  Restore S1 Link
        IF  ${SCF_COUNT_GSM}  Restore Link Abis
        Restore M Plane Link
    END


Get All Links Ip Addresses
    Connect To SMOD  ${SMOD1['IP']}

    ${im_object}  IF  ${SCF_COUNT_WCDMA}  Query Infomodel  get object /MRBTS-*/RAT-*/WTS-*/RNC_L-*
    IF  ${SCF_COUNT_WCDMA}  Set Test Variable  ${IUB_IP_RNC}  ${im_object.ipAddress}

    ${lnmme_list}  IF  ${SCF_COUNT_LTE}  Setup LTE Data

    ${ip_omusign_trxsig}  IF  ${SCF_COUNT_GSM}  Get BCF IPs From SCF
    IF  ${SCF_COUNT_GSM}  Set Test Variable  ${ip_omusign_trxsig}

    ${m_plane_obj}  Query Infomodel  get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/MNL_A-*/MNLENT_A-*/MPLANENW_A-*
    Set Test Variable  ${M_PLANE_IP}  ${MPLANE_IP}


Setup LTE Data
    ${lnmme_list}  Get Parameters For All  LNMME
    ${ip_addr_sec_status}  Evaluate  'ipAddrSec' in ${lnmme_list[0]}
    ${ip_sec_s1}  Set Variable If  ${ip_addr_sec_status}  ${lnmme_list[0].ipAddrSec}  ${NONE}
    Set Test Variable  ${IP_PRIM_S1}  ${lnmme_list[0].ipAddrPrim}
    Set Test Variable  ${IP_SEC_S1}


Break IuB Link
    ${output}  ssh.Execute  iptables -w -I ${CHAIN} -s ${IUB_IP_RNC} -j DROP
    ssh.Assert Exit Status  0  msg=IuB link break execution failed\n ${output}.


Restore IuB Link
    ${output}  ssh.Execute  iptables -w -D ${CHAIN} -s ${IUB_IP_RNC} -j DROP
    ssh.Assert Exit Status  0  msg=IuB link restore execution failed\n ${output}.


Break S1 Link
    Send S1 Link Command  ${IP_PRIM_S1}  d_or_i=I
    IF  '${IP_SEC_S1}' != '${NONE}'  Send S1 Link Command  ${IP_SEC_S1}  d_or_i=I


Restore S1 Link
    Send S1 Link Command  ${IP_PRIM_S1}  d_or_i=D
    IF  '${IP_SEC_S1}' != '${NONE}'  Send S1 Link Command  ${IP_SEC_S1}  d_or_i=D


Send S1 Link Command
    [Arguments]  ${ip}  ${d_or_i}
    ${output}  ssh.Execute  iptables -w -${d_or_i} INPUT -s ${ip} -j DROP
    ssh.Assert Exit Status  0  msg=S1 linkl command execution failed\n ${output}.


Break Abis Link
    FOR  ${ip}  IN  @{IP_OMUSIGN_TRXSIG}
        ssh.Execute  iptables -w -I INPUT -d ${ip} -j DROP
        ssh.Assert Exit Status  0  msg=Abis link break execution failed.
    END


Restore Link Abis
    FOR  ${ip}  IN  @{IP_OMUSIGN_TRXSIG}
        ssh.Execute  iptables -w -D INPUT -d ${ip} -j DROP
        ssh.Assert Exit Status  0  msg=Abis link restore execution failed.
    END


Break M Plane Link
    ${output}  ssh.Execute  iptables -w -I INPUT -d ${M_PLANE_IP} -j DROP
    ssh.Assert Exit Status  0  msg=M Plane linkl break execution failed\n ${output}.


Restore M Plane Link
    ${output}  ssh.Execute  iptables -w -D INPUT -d ${M_PLANE_IP} -j DROP
    ssh.Assert Exit Status  0  msg=M Plane linkl restore execution failed\n ${output}.


Wait Random Time
    ${random_int}  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random_int}  Wait before links restoration


Try To Restore All Links
    Log  Try to restore links which could remain unrestored  console=true
    Run Keyword And Ignore Error
    ...  Restore IuB Link
    Run Keyword And Ignore Error
    ...  Restore S1 Link
    Run Keyword And Ignore Error
    ...  Restore Link Abis
    Run Keyword And Ignore Error
    ...  Restore M Plane Link
    Sleep  60s  Wait for link restoration


TC Setup
    Common Test Setup  tc_name=FM__Recovery_whole_multiple_Link_Break
    Get All Links Ip Addresses


TC Teardown
    Run Keyword If Test Failed
    ...  Try To Restore All Links
    Common Test Teardown
