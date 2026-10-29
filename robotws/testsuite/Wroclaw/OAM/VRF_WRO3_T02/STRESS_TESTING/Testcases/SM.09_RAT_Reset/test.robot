*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.09_RAT_Reset
...  AUTHORS:       artur.lebek@nokia.com, jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform RAT Reset operations for every RAT on RAN eNodeB,
...  check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  11.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  18.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test review + FOR loop update to new Robot syntax
...  22.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-424 - robotws migration and small hotfixes
...  28.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-435 - CB008880-F_Enhanced_RAT_Reset - rework TC to support CB008880 feature
...  28.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-499 - CB008880-F_Hard_RAT_Reset - rework TC to support CB008880 feature
...  26.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-562 - Extend downtime for RAT resets with ABIC and ABIL in configuration
...  16.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAW-622 - Ensure PDL rule is followed for actRatResetEnhancement parameter
...  20.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAW-619 - Change logic of checking time for KPI of RAT Reset - add Check KPIs
...  13.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23598 - Fix for keyword "Validate SCF with Backup Online"
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${reset_type}  Mix    #Available values: Mix (resulting in 50% Soft and 50% Legacy), Soft, Hard, Legacy

*** Keywords ***
SM.09_RAT_Reset
    SM.09_RAT_Reset.Test_Step:0 Test Preparation
    SM.09_RAT_Reset.Test_Step:1 Reset RATs
    SM.09_RAT_Reset.Test_Step:2 Final Checkpoint
    SM.09_RAT_Reset.Test_Step:3 KPI Time Measurement

SM.09_RAT_Reset.Test_Step:0 Test Preparation
    Log To Console  \n========================================
    Log To Console  Step: 0 Test Preparation
    Log To Console  ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup
#    Compare current date with PSGRP/NRPGRP  PSGRP
#    Compare current date with PSGRP/NRPGRP  NRPGRP
    Run Keyword If  ${ITERATION_INDEX}==1  First Preparation
    Run Keyword If  ${ITERATION_INDEX} > 1
    ...       Log To Console  Detected RATs available in configuration: ${available_rats}
    Run Keyword If  '${reset_type}'=='Soft' and ${ITERATION_INDEX} > 1
    ...       Log To Console  == RATs suitable for Enhanced Reset: ${rats} ==
    Run Keyword If  '${reset_type}'=='Mix' and ${ITERATION_INDEX} > 1 and ${ITERATION_INDEX} <= ${halved_iterations}
    ...       Log To Console  == RATs suitable for Enhanced Reset: ${rats} ==
    Run Keyword If  ${ITERATION_INDEX} == ${halved_iterations}+1 and '${reset_type}'=='Mix'  Run Keywords
    ...       Log  \n== Enhanced RAT resets are done... \n== Preparing for Hard RAT resets...  WARN
    ...  AND  Set Test Variable  ${rats}  ${available_rats}
    ...  AND  Set Test Variable  ${reset_type}  Hard

SM.09_RAT_Reset.Test_Step:1 Reset RATs
    Log To Console  \n========================================
    Log To Console  Step: 1 Reset RATs
    Log To Console  ========================================
    &{RAT_TIMES}=    Create Dictionary
    ${rats}  Evaluate  random.sample(${rats}, len(${rats}))  random
    ${reset_result}  Create List
    ${mix_or_soft}  Run Keyword And Return Status  Should Contain Any  ${reset_type}  Mix  Soft
    FOR  ${rat}  IN  @{rats}
        ${rat}  Convert To Upper Case  ${rat}
        ${nr_or_lte}  Run Keyword And Return Status  Should Contain Any  '${rat}'  NR  LTE
        ${detection_before_reset}  Get DETECTION_RESULT For Specified Objects  objects_list=${enhanced_capable}
        Log To Console  \nResetting ${rat}...
        Run Keyword If  ${nr_or_lte} and ${if_nr_exist}  Allow NR Faults
        Run Keyword If  ${if_fhs_exist} and not ${mix_or_soft}  Allow Fault In Watchdog  faultID=10  #No connection to unit (visible on FHS)
        ${time_before}  Get Current Date
        Run Keyword If  ${mix_or_soft}
        ...             admin.rat reset  rat_type=${rat}  graceful_cell_shutdown=false  reset_type=Soft  timeout=700
        ...    ELSE IF  '${reset_type}'=='Hard'
        ...             admin.rat reset  rat_type=${rat}  graceful_cell_shutdown=false  reset_type=Hard  timeout=700
        ...       ELSE  admin.rat reset  rat_type=${rat}  timeout=700
        ${time_after}  Get Current Date
        ${detection_after_reset}  Get DETECTION_RESULT For Specified Objects  objects_list=${enhanced_capable}
        ${detection_result}  Run Keyword If  ${mix_or_soft}  Compare DETECTION_RESULT Objects  ${detection_before_reset}  ${detection_after_reset}
        Run Keyword If  ${detection_result}!=[]  Append To List  ${reset_result}  ${detection_result}
        ${diff}  Subtract Date From Date  ${time_after}  ${time_before}
        ${rat_lower}=    Convert To Lower Case    ${rat}
        Set To Dictionary    ${RAT_TIMES}    ${rat_lower}    ${diff}
        Log To Console  Reset of ${rat} is done and it took ${diff} seconds.
        Check If NLWG Cells Are OnAir
        Run Keyword If  ${if_fhs_exist} and not ${mix_or_soft}  Disallow Fault In Watchdog  faultID=10  #No connection to unit (visible on FHS)
        Run Keyword If  ${nr_or_lte} and ${if_nr_exist}  Disallow NR Faults
    END
    Set Test Variable    &{RAT_TIMES}
    Run Keyword If  ${mix_or_soft} and ${reset_result}!=[]
    ...  Fail  msg=Detected SoC reset of ${reset_result}. Check logs for "RESET_TASK has been created:" for relevant BBMOD_L
#    Reselect Cells For NRPGRP
#    Reselect Cells For PSGRP

SM.09_RAT_Reset.Test_Step:2 Final Checkpoint
    Log To Console  \n========================================
    Log To Console  Step: 2 Final Checkpoint
    Log To Console  ========================================
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}

SM.09_RAT_Reset.Test_Step:3 KPI Time Measurement
    Log To Console  \n========================================
    Log To Console  Step: 3 KPI Time Measurement
    Log to console  =======================================
    Check KPIs

SM.09_RAT_Reset.Test Case Teardown
    ${actRatResetEnhancement_dict}  Check Feature Availability And Value  parameter=actRatResetEnhancement  value_to_set=${feature_value_before}
    ${feature_value_after}  Get From Dictionary  ${actRatResetEnhancement_dict}  initial_value
    ${feature_value_diff}  Run Keyword And Return Status  Should Be Equal  ${feature_value_before}  ${feature_value_after}
    Run Keyword If  not ${feature_value_diff} and '${feature_value_before}'!='None'  Run Keywords
    ...       Log To Console  == Setting actRatResetEnhancement to initial value from before test. ==
    ...  AND  Set Feature On Expected Value  parameter=actRatResetEnhancement  value=${feature_value_before}
    common.Common Test Teardown - MEMORY

##### TEST SPECYFIC KEYWORDS ########################
First Preparation
    ${is_forced_enhanced}  Run Keyword And Return Status  Evaluate  re.search(r'(25R[3-9]|(2[6-9]|[3-9][0-9])R[1-9])', '${SW_TYPE}').group(0)  re
    Set Test Variable  ${is_forced_enhanced}
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
    ${halved_iterations}  Evaluate  round(${ITERATIONS}/2)
    Set Test Variable  ${halved_iterations}
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
    Run Keyword If  '${reset_type}'!='Legacy' and '${feature_value_before}'=='None'  Run Keywords
    ...           Log  Enhanced RAT reset feature is not available  WARN
    ...  AND      Log  Proceeding with LEGACY resets  WARN
    ...  AND      Set Test Variable  ${reset_type}  Legacy
    ...  ELSE IF  '${reset_type}'=='Legacy' and '${feature_value_before}'!='None' and not ${is_forced_enhanced}  Run Keywords
    ...           Log To Console    == Preparing for Legacy RAT resets... ==
    ...  AND      Set Feature On Expected Value  parameter=actRatResetEnhancement  value=false
    ...  AND  Set Feature On Expected Value  parameter=actL1ReconfigImprovement  value=false
    ...  AND  Set Feature On Expected Value  parameter=actBbReconfigImprovement  value=false
    ...  AND  Log To Console    == Validating SCF ==
    ...  AND  Validate SCF with Backup
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
    ...  AND      Log To Console  == Validating SCF ==
    ...  AND      Validate SCF with Backup
    ...  AND      Remove From RAT List  WG
    ...  AND      Log To Console  == RATs suitable for Enhanced Reset: ${rats} ==
    ...  ELSE IF  ${is_soft_or_mix} and not ${is_enhanced_suitable}  Run Keywords
    ...           Log  There is no RAT suitable for Enhanced reset. Proceeding with Hard resets.  WARN
    ...  AND      Set Test Variable  ${reset_type}  Hard
#    Run Keyword If  '${reset_type}'=='Hard'  Run Keywords
    ...  ELSE     Run Keywords
    ...           Log To Console  == Preparing for Hard RAT resets... ==
    ...  AND      Set Test Variable  ${reset_type}  Hard
    ...  AND      Set Feature On Expected Value  parameter=actRatResetEnhancement  value=true
    ...  AND      Log To Console  == Validating SCF ==
    ...  AND      Validate SCF with Backup

Check KPIs
    &{KPI_TIMES}=    Calculate KPI7 KPI8 KPI9 KPI10  ${ITERATION_INDEX}
    ${ABIC_AEHC}    Check if BBMOD is connected to RMOD    ABIC    AEHC
    ${EXT_DOWNTIME}  Set Variable If  'lte' in $rats and 'ABIC' in $TOPOLOGY  True
    ...                               'nr' in $rats and 'ABIL' in $TOPOLOGY  True  False
    ${keys}    Get Dictionary Keys    ${KPI_TIMES}
    FOR    ${key}    IN    @{keys}
        ${time_KPI}=    Get From Dictionary    ${KPI_TIMES}    ${key}
        ${time_RAT}=    Get From Dictionary    ${RAT_TIMES}    ${key}
        Log To Console    KPI Time check First cell down to last cell up for '${key}' equals: ${time_KPI} seconds.
        Log To Console    RAT Time check for RAT reset of '${key}' equals: ${time_RAT} seconds.
        Run Keyword If  ${ABIC_AEHC}    Should Be True  ${time_KPI}<750  #OM_GEN_SFS_PERF_CAP.10587 and .10517 - ABIC+AEHC
        ...       ELSE IF    ${EXT_DOWNTIME}    Should Be True  ${time_KPI}<270    #OM_GEN_SFS_PERF_CAP.29072
        ...       ELSE  Should Be True  ${time_RAT}<200  #OM_GEN_SFS_PERF_CAP.26204
    END

Allow NR Faults
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Allow Fault In Watchdog  faultID=7107  #fault_name: Cell problem due to associated X2/NG/E1 link unavailability
    Allow Fault In Watchdog  faultID=7312  #fault_name: NgGnbInitFullReset    on /SERVEDAMF-1
    Allow Fault In Watchdog  faultID=6278  #fault_name: MFBI cell configuration conflict

Disallow NR Faults
    Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Disallow Fault In Watchdog  faultID=7107  #fault_name: Cell problem due to associated X2/NG/E1 link unavailability
    Disallow Fault In Watchdog  faultID=7312  #fault_name: NgGnbInitFullReset    on /SERVEDAMF-1
    Disallow Fault In Watchdog  faultID=6278  #fault_name: MFBI cell configuration conflict

