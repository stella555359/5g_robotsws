*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.08_BBMOD_Warm_Reset
...  AUTHORS:       aleksandra.trojak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform BBMOD Warm Reset for random reset-able baseband module on eNB
...  and then check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  Installed extension plug-in unit (ABIA/ABIO/ABIN etc).
...  ******************
...  History of changes
...  ******************
...  04.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  11.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-136 - TAW
...  12.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-273 - timeout increase for warm reset
...  21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-456 - robotws migration and small hotfixes
...  19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-618 - move KWs "Get Resttable BBMOD" and "BBMOD Mapping" to common resources_mem
...  26.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22855 - add solution for allowed FID10 on OBSAI radios connected to FHS
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.08_BBMOD_Warm_Reset

    SM.08_BBMOD_Warm_Reset.Test_Step:0 Test Preparation
    SM.08_BBMOD_Warm_Reset.Test_Step:1 Select Resttable BBMOD
    SM.08_BBMOD_Warm_Reset.Test_Step:2 Perform BBMOD Warm Reset
    SM.08_BBMOD_Warm_Reset.Test_Step:3 KPI Time Measurement

SM.08_BBMOD_Warm_Reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup
    ${rmod_to_rmod_r_dict}  Mapping RMOD To RMOD_R
    Set Test Variable  ${rmod_to_rmod_r_dict}
#    Compare current date with PSGRP/NRPGRP  PSGRP
#    Compare current date with PSGRP/NRPGRP  NRPGRP

SM.08_BBMOD_Warm_Reset.Test_Step:1 Select Resttable BBMOD
    Log to console    \n========================================
    Log  Step: 1 Select Resttable BBMOD  console=${True}
    Log to console    ========================================
    ${BBMODs_R}  Get Resettable BBMOD
    ${selected_bbmod_r}  Evaluate  random.choice(${BBMODs_R})  random
    ${bbmods_mapping}  BBMOD Mapping
    ${selected_bbmod}  Get From Dictionary  ${bbmods_mapping}  ${selected_bbmod_r}
    Log To Console  Selected BBMOD: ${selected_bbmod}
    Set Test Variable  ${selected_bbmod}

SM.08_BBMOD_Warm_Reset.Test_Step:2 Perform BBMOD Warm Reset
    Log to console    \n========================================
    Log  Step: 2 Perform BBMOD Warm Reset  console=${True}
    Log to console    ========================================
    ${obsai_rmod_list}  Get RMODs Connected To BBMOD Through FHS  given_bbmod=${selected_bbmod}  radio_protocol=OBSAI
    Run Keyword If  'nr' or 'lte' in $rats  Run Keywords
    ...           Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    FOR  ${obsai_rmod}  IN  @{obsai_rmod_list}
        ${unit_path}  Set Variable  [${BTS_NAME}] ${obsai_rmod}
        ${unit_path}  Evaluate   re.sub('\\[--\\]','','''${unit_path}''')  re
        Allow Fault In Watchdog  faultID=10  unit_path=${unit_path}  #fault_name: No connection to unit
    END
    Log To Console  Warm Reset BBMOD: ${selected_bbmod}
    ${status}  Run Keyword And Return Status  admin.Reset Unit  ${selected_bbmod}  reset_type=Warm  timeout=240
    Run Keyword If  not ${status}  admin.Reset Unit  ${selected_bbmod}  reset_type=Warm  timeout=240
    Log To Console  Checking if selected BBMOD has reached the expected state: operationalState=Disabled, the rest of the BBMODs should be Enabled
    ${bts_info}  admin.get bts info
    FOR  ${bbmod}  IN  @{bts_info['basebandModules']}
        ${bbmod_states}  Get From Dictionary  ${bbmod}  status
        ${operationalState}  Get From Dictionary  ${bbmod_states}  operationalState
        Run Keyword And Ignore Error    Run Keyword If  '${bbmod['id']['configuration']}'=='${selected_bbmod}'
        ...                 Should Be Equal As Strings   ${operationalState}  Disabled  ignore_case=True
        ...         ELSE    Should Be Equal As Strings   ${operationalState}  Enabled   ignore_case=True
        ${administrativeState}  Get From Dictionary  ${bbmod_states}  administrativeState
        Should Be Equal As Strings  ${administrativeState}  Unlocked  ignore_case=True
        Log To Console  State of ${bbmod['id']['configuration']} is correct
    END
    Log To Console  BBMOD warm reset is done
    FOR  ${obsai_rmod}  IN  @{obsai_rmod_list}
        Log To Console  Checking state of ${obsai_rmod}...${SPACE}  no_newline=True
        ${RMOD_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  7min  30s
        ...                                            admin.Assert  RMOD  ${rmod_to_rmod_r_dict['${obsai_rmod}']}  parameters=${RMOD_expected_states}
        ${unit_path}  Set Variable  [${BTS_NAME}] ${obsai_rmod}
        ${unit_path}  Evaluate   re.sub('\\[--\\]','','''${unit_path}''')  re
        Run Keyword If  ${RMOD_status}!=True  Wait For Inactive Fault  faultID=10  unit_path=${unit_path}  timeout=15min
        ...                             ELSE  Log To Console  Done
        Disallow Fault In Watchdog  faultID=10  unit_path=${unit_path}  #fault_name: No connection to unit
    END
    Check If NLWG Cells Are OnAir
    Run Keyword If  'nr' in $rats  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    Run Keyword If  'nr' or 'lte' in $rats  Run Keywords
    ...           Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.08_BBMOD_Warm_Reset.Test_Step:3 KPI Time Measurement
    Log to console    \n========================================
    Log  Step: 3 KPI Time Measurement  console=${True}
    Log to console    ========================================
    Run Keyword And Ignore Error  Calculate KPI5  ${ITERATION_INDEX}
#    Reselect Cells For NRPGRP
#    Reselect Cells For PSGRP

SM.08_BBMOD_Warm_Reset.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
