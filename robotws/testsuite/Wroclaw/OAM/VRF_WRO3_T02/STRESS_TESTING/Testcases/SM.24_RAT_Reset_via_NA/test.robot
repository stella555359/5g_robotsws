*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.24_RAT_Reset_via_NA
...  AUTHORS:       pawel.bartkowiak@nokia.com, jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This User Scenario describes how to perform RAT reset from NetAct by using Open API with Graceful Cell Shutdown active.
...  *****************
...  Pre-conditions
...  *****************
...  BTS-NetAct M-Plane connection is working
...  ACTIONS NIDD adaptation is supported by SW releases on both NetAct and BTS
...  SRNCLAB with "pure trunk base"
...  NetActTrunk - NetAct - 99.23.04.0.96 (or higher)
...  ******************
...  History of changes
...  ******************
...  08.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-356 - TC creation
...  26.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-388 - Update TC with conditional Graceful Cell Shutdown set as "false".
...  26.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-395 - Add FID10 to watchdog during NR RAT reset for it is expected on FHS.
...  28.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-537 - Adapt SM.24_RAT_Reset_via_NA to work with CB008880
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${reset_type}  Soft    #Available values: Soft, Legacy


*** Keywords ***
SM.24_RAT_Reset_via_NA
    SM.24_RAT_Reset_via_NA.Test_Step:0 Test Preparation
    SM.24_RAT_Reset_via_NA.Test_Step:1 Resetting RAT
    SM.24_RAT_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.24_RAT_Reset_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    Log To Console  Detected RATs: ${rats}
    ${available_rats}  Set Variable  ${rats}
    Set Test Variable  ${available_rats}
    ${fhs_list}  admin.get_fhs_list
    ${if_fhs_exist}  Run Keyword And Return Status  Should Not Be Empty  ${fhs_list}
    Set Test Variable  ${if_fhs_exist}
    ${if_nr_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    Set Test Variable  ${if_nr_exist}
    ${if_lte_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  lte
    Set Test Variable  ${if_lte_exist}
    Check For Enhanced Reset Availability

SM.24_RAT_Reset_via_NA.Test_Step:1 Resetting RAT
    ${check_sw}=  Run Keyword And Return Status  Should Not Contain  ${active_sw_version}  23R
    ${reset_result}  Create List
    ${mix_or_soft}  Run Keyword And Return Status  Should Contain Any  ${reset_type}  Mix  Soft
    FOR  ${rat}  IN  @{rats}
        ${nr_or_lte}  Run Keyword And Return Status  Should Contain Any  '${rat}'  nr  lte
        ${detection_before_reset}  Get DETECTION_RESULT For Specified Objects  objects_list=${enhanced_capable}
        Log  ==Resetting ${rat}...==  console=true
        Run Keyword If  '${rat}' == 'lte'  Run keywords
        ...  Set test variable    ${RAT_ID}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
        ...  AND  Allow NR Faults
        Run Keyword If  '${rat}' == 'nr'  Run Keywords
        ...  Set test variable    ${RAT_ID}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...  AND  Allow NR Faults
        Run Keyword If  '${rat}' == 'nr' and ${if_fhs_exist} and not ${mix_or_soft}
        ...  Allow Fault In Watchdog  faultID=10  #No connection to unit (visible on FHS)
        Run Keyword If  '${rat}' == 'wcdma'
        ...  Set test variable    ${RAT_ID}  MRBTS-${MRBTS_ID}/WNBTS-1
        Run Keyword If  '${rat}' == 'gsm'
        ...  Set test variable    ${RAT_ID}  MRBTS-${MRBTS_ID}/GNBTS-1
        ${time_before}=  Get Current Date
        Run Keyword If  ${check_sw}
        ...  netact.Reset NE  dist_names=${RAT_ID}  parameters=gracefulCellShutdown=false  timeout=700
        ...  ELSE  netact.Reset NE  dist_names=${RAT_ID}  timeout=700
        ${time_after}=  Get Current Date
        ${detection_after_reset}  Get DETECTION_RESULT For Specified Objects  objects_list=${enhanced_capable}
        ${detection_result}  Run Keyword If  ${mix_or_soft}  Compare DETECTION_RESULT Objects  ${detection_before_reset}  ${detection_after_reset}
        Run Keyword If  ${detection_result}!=[]  Append To List  ${reset_result}  ${detection_result}
        ${diff}=  Subtract Date From Date  ${time_after}  ${time_before}
        Should Be True  ${diff}<200  #OM_GEN_SFS_PERF_CAP.26204
        Log  ==Reset time is ${diff}==  console=true
        Log  ==Reset ${rat} is done==  console=true
        Check If NLWG Cells Are OnAir
        Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
        Run Keyword If  '${rat}' == 'lte' or '${rat}' == 'nr'  Disallow NR Faults
        Run Keyword If  '${rat}' == 'nr' and ${if_fhs_exist} and not ${mix_or_soft}
        ...  Disallow Fault In Watchdog  faultID=10  #No connection to unit (visible on FHS)
    END
    Run Keyword If  ${mix_or_soft} and ${reset_result}!=[]
    ...  Fail  msg=Detected SoC reset of ${reset_result}. Check logs for "RESET_TASK has been created:" for relevant BBMOD_L

SM.24_RAT_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
#	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}

SM.24_RAT_Reset_via_NA.Test Case Teardown
    ${actRatResetEnhancement_dict}  Check Feature Availability And Value  parameter=actRatResetEnhancement  value_to_set=${feature_value_before}
    ${feature_value_after}  Get From Dictionary  ${actRatResetEnhancement_dict}  initial_value
    ${feature_value_diff}  Run Keyword And Return Status  Should Be Equal  ${feature_value_before}  ${feature_value_after}
    Run Keyword If  not ${feature_value_diff} and '${feature_value_before}'!='None'  Run Keywords
    ...       Log To Console  == Setting actRatResetEnhancement to initial value from before test. ==
    ...  AND  Set Feature On Expected Value  parameter=actRatResetEnhancement  value=${feature_value_before}


##### TEST SPECYFIC KEYWORDS ########################
Check For Enhanced Reset Availability
    ${actRatResetEnhancement_dict}  Check Feature Availability And Value  parameter=actRatResetEnhancement  value_to_set=true
    Set Test Variable  ${actRatResetEnhancement_dict}
    ${feature_value_before}  Get From Dictionary  ${actRatResetEnhancement_dict}  initial_value
    Set Test Variable  ${feature_value_before}
    ${ASOx}  Run Keyword And Return Status  Evaluate  re.search(r'(?i)ASO(E|F|G|H)', '${SMOD_COMPOSITION}').group(0)  re
    ${managed_soc_l}  Get Managed Objects  SOC_L
    ${enhanced_capable}  Create List
    FOR  ${item}  IN  @{managed_soc_l}
        ${status}  Run Keyword And Return Status  Should Contain Any  ${item['parameters']['hwVariant']}  Loki  Thor  Magni  Snowfish  Marlin
        Continue For Loop If  not ${status}
        ${not_smod}  Run Keyword And Return Status  Should Not Contain  ${item['distName']}  SMOD_L
        Run Keyword If  not ${ASOx} and ${not_smod}
        ...                    Append To List  ${enhanced_capable}  ${item['distName']}
        ...  ELSE IF  ${ASOx}  Append To List  ${enhanced_capable}  ${item['distName']}
    END
    Set Test Variable  ${enhanced_capable}
    Run Keyword If  ${enhanced_capable}
    ...        Log To Console  SoC(s) capable of enhanced reset: ${enhanced_capable}
    ...  ELSE  Run Keywords
    ...        Log  There are no BBMODS in configuration that are supporting enhanced reset.\nProceeding with LEGACY resets...  WARN
    ...  AND   Set Test Variable  ${reset_type}  Legacy
    Run Keyword If  '${reset_type}'!='Legacy' and '${feature_value_before}'=='None'  Run Keywords
    ...           Log  Enhanced RAT reset feature is not available  WARN
    ...  AND      Log  Proceeding with LEGACY resets  WARN
    ...  AND      Set Test Variable  ${reset_type}  Legacy
    ...  ELSE IF  '${reset_type}'=='Legacy' and '${feature_value_before}'!='None'  Run Keywords
    ...           Log To Console    == Preparing for Legacy RAT resets... ==
    ...  AND      Set Feature On Expected Value  parameter=actRatResetEnhancement  value=false
    ...  ELSE IF  '${reset_type}'!='Legacy' and ${actRatResetEnhancement_dict.possible_to_set}
    ...           Reset With actRatResetEnhancement Preparation
    ...  ELSE IF  '${reset_type}'!='Legacy' and not ${actRatResetEnhancement_dict.possible_to_set}  Run Keywords
    ...           Log To Console  == Feature actRatResetEnhancement is not available on ${RELEASE} release. Preparing for Legacy RAT resets... ==
    ...  AND      Set Test Variable  ${reset_type}  Legacy

Reset With actRatResetEnhancement Preparation
    ${is_soft_or_mix}  Run Keyword And Return Status  Should Contain Any  '${reset_type}'  Soft  Mix
    ${is_enhanced_suitable}  Run Keyword And Return Status  Should Be True  ${if_nr_exist} or ${if_lte_exist}
    Run Keyword If  ${is_soft_or_mix} and ${is_enhanced_suitable}  Run Keywords
    ...           Log To Console  == Preparing for Enhanced RAT resets... ==
    ...  AND      Set Feature On Expected Value  parameter=actRatResetEnhancement  value=true
    ...  AND      Log To Console  == RATs suitable for Enhanced Reset: ${rats} ==
    ...  ELSE IF  ${is_soft_or_mix} and not ${is_enhanced_suitable}  Run Keywords
    ...           Log  There is no RAT suitable for Enhanced reset. Proceeding with Legacy resets.  WARN
    ...  AND      Set Test Variable  ${reset_type}  Legacy
    Run Keyword If  '${reset_type}'=='Legacy'  Run Keywords
    ...           Log To Console  == Preparing for Legacy RAT resets... ==
    ...  AND      Set Feature On Expected Value  parameter=actRatResetEnhancement  value=false

Allow NR Faults
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Allow Fault In Watchdog  faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability

Disallow NR Faults
    Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Disallow Fault In Watchdog  faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability
