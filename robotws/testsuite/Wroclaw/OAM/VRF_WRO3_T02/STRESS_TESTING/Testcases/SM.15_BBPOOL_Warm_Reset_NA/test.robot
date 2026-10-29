*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/netact.robot

Documentation
...  TEST NAME:     SM.15_BBPOOL_Warm_Reset_NA
...  AUTHORS:       anna.niedzwiecka@nokia.com, tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform BBPOOL warm reset operation with Netact, check eNB status after operation is finished.
...
...  BBPOOL ID mapping to power group [example: LTE only]:
...  +============+====================================+========================================+
...  | BB card ID | BBPOOL ID for critical power group | BBPOOL ID for non critical power group |
...  +============+====================================+========================================+
...  |      1     |                11                  |                    12                  |
...  |      2     |                21                  |                    22                  |
...  |      3     |                31                  |                    32                  |
...  |      4     |                41                  |                    42                  |
...  |      5     |                51                  |                    52                  |
...  |      6     |                61                  |                    62                  |
...  +============+====================================+========================================+
...
...  Examples of ABIA numbering:
...  +=======================+=======================+
...  |       ABIA #3         |       ABIA #6         |
...  +-----------------------+-----------------------+
...  | BBPool 31 | BBPool 32 | BBPool 61 | BBPool 62 |
...  +=======================+=======================+
...  |       ABIA #2         |       ABIA #5         |
...  +-----------------------+-----------------------+
...  | BBPool 21 | BBPool 22 | BBPool 51 | BBPool 52 |
...  +=======================+=======================+
...  |       ABIA #1         |       ABIA #4         |
...  +-----------------------+-----------------------+
...  | BBPool 11 | BBPool 12 | BBPool 41 | BBPool 42 |
...  +=======================+=======================+
...  |       ASIA #1 MSM     |       ASIA #2 ESM     |
...  +=======================+=======================+
...
...  *****************
...  Pre-conditions
...  *****************
...  necessary: ABIA with LTE and POWERGROUP_R-2
...  ******************
...  History of changes
...  ******************
...  23.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  09.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-470 - robotws migration and small hotfixes, adaptation to taf.nms.netact
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.15_BBPOOL_Warm_Reset_NA

    SM.15_BBPOOL_Warm_Reset_NA.Test_Step:0 Test Preparation
    SM.15_BBPOOL_Warm_Reset_NA.Test_Step:1 Delete HWRESETREQ object
    SM.15_BBPOOL_Warm_Reset_NA.Test_Step:2 Select BBPOOL
    SM.15_BBPOOL_Warm_Reset_NA.Test_Step:3 Perform BBPOOL Warm Reset

SM.15_BBPOOL_Warm_Reset_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}

SM.15_BBPOOL_Warm_Reset_NA.Test_Step:1 Delete HWRESETREQ object
    Log to console    \n========================================
    Log  Step: 1 Delete HWRESETREQ object  console=${True}
    Log to console    ========================================
    ${hwresetreqs}  admin.get managed objects  HWRESETREQ_A
    ${hwresetreq_dns}  Create List
    FOR  ${hwresetreq}  IN  @{hwresetreqs}
        ${ignore}  ${hwresetreq_dn}  Split String From Right  ${hwresetreq['distName']}  separator=SCF-1/
        ${hwresetreq_dn}  Replace String  ${hwresetreq_dn}  search_for=_A  replace_with=
        Append To List  ${hwresetreq_dns}  ${hwresetreq_dn}
    END
    ${if_hwresetreqs_exist}  Run Keyword And Return Status  Should Not Be Empty  ${hwresetreq_dns}
    Run Keyword If  ${if_hwresetreqs_exist}  Remove Objects Via NA  ${hwresetreq_dns}
    ...  ELSE  Log To Console  There is no any object HWRESETREQ on BTS

SM.15_BBPOOL_Warm_Reset_NA.Test_Step:2 Select BBPOOL
    Log to console    \n========================================
    Log  Step: 2 Select BBPOOL  console=${True}
    Log to console    ========================================
    Log To Console  Select resettable BBPOOL
    ${BBPOOL_parameters}  admin.Get Managed Objects  BBPOOL_R
    ${BBPOOL_dns}  Create List
    FOR  ${bbpool}  IN  @{BBPOOL_parameters}
        Run Keyword If  '${bbpool['parameters']['bbPoolTech']}'=='LTE' and 'POWERGROUP_R-2' in '${bbpool['parameters']['bbPwrGroupDNList'][0]}'
        ...  Append To List  ${BBPOOL_dns}  ${bbpool['distName']}
    END
    ${selected_bbpool}  Evaluate  random.choice(${BBPOOL_dns})  random
    Should Not Be Empty  ${selected_bbpool}  There is no resettable BBPOOL - pre-conditions criteria does not meet!
    Set Test Variable  ${selected_bbpool}
    Log To Console  Selected BBPOOL: ${selected_bbpool}

SM.15_BBPOOL_Warm_Reset_NA.Test_Step:3 Perform BBPOOL Warm Reset
    Log to console    \n========================================
    Log  Step: 3 Perform BBPOOL Warm Reset  console=${True}
    Log to console    ========================================
    ${ID}  Evaluate  re.search(r'BBPOOL_R-(\\d+)','''${selected_bbpool}''').group(1)  re
    Create HWRESETREQ Object Via NA  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-${ID}
    Wait Until Keyword Succeeds  4x  15s  Verify hwResetResult  expected_state=success
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

Verify hwResetResult
    [Arguments]  ${expected_state}
    ${HWRESETRES_parameters}  admin.Get Managed Objects  HWRESETRES_R
    Should Be Equal  ${HWRESETRES_parameters[0]['parameters']['hwResetResult']}  ${expected_state}
    Log To Console  Warm reset is done

SM.15_BBPOOL_Warm_Reset_NA.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
