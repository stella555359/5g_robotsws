*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot
Resource    ../../../resources/rnc.robot

Documentation
...  TEST NAME:     PS.32_RAN955_Power_saving_mode_for_3G
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to verify that network operator can shutdown cells to gain power savings in BTS during low traffic periods.
...  The use of Power Saving Mode for BTS shall be controlled by a BTS level switch PWSMInUse, managed by RNC. By this parameter the PWSM feature
...  can be set ON and OFF on BTS basis. Default value is OFF.
...  *****************
...  Pre-conditions
...  *****************
...  - All cells in the BTS belong to the same Power Saving Mode cell group. The value of the PWSMCellGroup parameter is different from zero.
...  - Every non-remaining cell in one frequency has PWSMShutdownOrder parameter value set to "1".
...  - All cells of the BTS belong to the same Local Cell Group.
...  - Licence is installed in RNC (SSH to RNC, and check feature license statues: show license feature-mgmt code 0000001459).
...  ******************
...  History of changes
...  ******************
...  22.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-214 - Test case creation
...  13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-378 - New KW "Clean Pegasus Project In Workspace" has been added as a WA solution
...  26.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-528 - Change PSWM time from 12:12 - 12:12 to 0:00 - 23:59
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.32_RAN955_Power_saving_mode_for_3G

    PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:0 Test Preparation
    PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:1 Disable Feature RAN955
    PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:2 Configure Power Saving On RNC
    PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:3 Activate Feature RAN955
    PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:4 Final Recovery and Checkpoint

PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Check which RAT are on given TestLine
    IF  '${IF_WCDMA_EXIST}'!='EXIST'  Fail  msg=There is no WCDMA technology configured on BTS
    Variable Should Exist  ${WBTS_ID}  Variable WBTS_ID should be defined
    Should Not Be Empty  ${WBTS_ID}  Variable WBTS_ID should not be empty
    Variable Should Exist  ${PWSM_WCELs}  Variable PWSM_WCELs should be defined
    Should Not Be Empty  ${PWSM_WCELs}  Variable PWSM_WCELs should not be empty

PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:1 Disable Feature RAN955
    Log to console  \n========================================
    Log  Step: 1 Disable Feature RAN955  console=${True}
    Log to console  ========================================
    Setup Connection to OMS
    ${get_PWSMInUse}=  Get WBTS Value  PWSMInUse  #PWSMInUse=OFF -> 0  PWSMInUse=ON -> 1
    IF  '${get_PWSMInUse}'=='${1}'
        Set WBTS Values  PWSMInUse  0
    ELSE
        Log To Console  PWSMInUse feature flag is OFF
    END

PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:2 Configure Power Saving On RNC
    Log to console  \n========================================
    Log  Step: 2 Configure Power Saving On RNC  console=${True}
    Log to console  ========================================
    #If time limit begin and time limit end have the same values for hour and minute, the time window is 24 hours.
    ${get_PWSMShutdownBeginHour}=  Get WBTS Value  PWSMShutdownBeginHour
    IF  '${get_PWSMShutdownBeginHour}'!='${0}'
        Set WBTS Values  PWSMShutdownBeginHour  0
    ELSE
        Log To Console  Parameter PWSMShutdownBeginHour is set to 0
    END
    ${get_PWSMShutdownBeginMin}=  Get WBTS Value   PWSMShutdownBeginMin
    IF  '${get_PWSMShutdownBeginMin}'!='${0}'
        Set WBTS Values  PWSMShutdownBeginMin   0
    ELSE
        Log To Console  Parameter PWSMShutdownBeginMin is set to 0
    END
    ${get_PWSMShutdownEndHour}=  Get WBTS Value    PWSMShutdownEndHour
    IF  '${get_PWSMShutdownEndHour}'!='${23}'
        Set WBTS Values  PWSMShutdownEndHour    23
    ELSE
        Log To Console  Parameter PWSMShutdownEndHour is set to 23
    END
    ${get_PWSMShutdownEndMin}=  Get WBTS Value     PWSMShutdownEndMin
    IF  '${get_PWSMShutdownEndMin}'!='${59}'
        Set WBTS Values  PWSMShutdownEndMin     59
    ELSE
        Log To Console  Parameter PWSMShutdownEndMin is set to 59
    END

PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:3 Activate Feature RAN955
    Log to console  \n========================================
    Log  Step: 3 Activate Feature RAN955  console=${True}
    Log to console  ========================================
    Set WBTS Values  PWSMInUse  1
    Log To Console  Waiting for ENERGYSAVING...
    ${WNCEL_IDs}=  Get WNCEL IDs
    FOR  ${WNCEL}  IN  @{WNCEL_IDs}
        ${WNCEL}=  Convert To String  ${WNCEL}
        ${status}=  Run Keyword And Return Status  Should Contain  ${PWSM_WCELs}  ${WNCEL}
        IF  ${status}
            Wait Until Keyword Succeeds  15x  1min
            ...  Check If WNCEL Is As Expected  ${WNCEL}  operationalState  DISABLED
            Check If WNCEL Is As Expected  ${WNCEL}  availabilityStatus  OFFLINE
            Check If WNCEL Is As Expected  ${WNCEL}  usageState  IDLE
        ELSE
            Check If WNCEL Is As Expected  ${WNCEL}  operationalState  ENABLED
            Check If WNCEL Is As Expected  ${WNCEL}  usageState  ACTIVE
        END
    END

PS.32_RAN955_Power_saving_mode_for_3G.Test_Step:4 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 4 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    Set WBTS Values  PWSMInUse  0
    ${beginHour}=   Evaluate  random.randint(0, 23)  modules=random
    ${beginMin}=    Evaluate  random.randint(0, 59)  modules=random
    ${endHour}=     Evaluate  random.randint(0, 23)  modules=random
    ${endMin}=      Evaluate  random.randint(0, 59)  modules=random
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownBeginHour  ${beginHour}
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownBeginMin   ${beginMin}
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownEndHour    ${endHour}
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownEndMin     ${endMin}
    Clean Pegasus Project In Workspace
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.32_RAN955_Power_saving_mode_for_3G.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Run Keyword And Ignore Error  Set WBTS Values  PWSMInUse  0
    ${beginHour}=   Evaluate  random.randint(0, 23)  modules=random
    ${beginMin}=    Evaluate  random.randint(0, 59)  modules=random
    ${endHour}=     Evaluate  random.randint(0, 23)  modules=random
    ${endMin}=      Evaluate  random.randint(0, 59)  modules=random
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownBeginHour  ${beginHour}
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownBeginMin   ${beginMin}
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownEndHour    ${endHour}
    Run Keyword And Ignore Error  Set WBTS Values  PWSMShutdownEndMin     ${endMin}
    Clean Pegasus Project In Workspace

PS.32_RAN955_Power_saving_mode_for_3G.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.32_RAN955_Power_saving_mode_for_3G.Test Specific Teardown
