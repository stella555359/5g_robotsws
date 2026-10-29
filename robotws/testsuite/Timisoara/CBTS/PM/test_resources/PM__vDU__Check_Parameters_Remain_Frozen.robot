*** Settings ***
Documentation
...  This TC checks if following parameter remain frozen.
...  1. berMajorAlarmThreshold shall be set to a value '-12'.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/PM_general.robot


*** Keywords ***
TC__PM__vDU__Check_Parameters_Remain_Frozen
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28923
    ...
    ...  *******************
    ...  History of changes
    ...  - 02.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28923 - Initial TC creation

    Set Tags  CA-PM  OWNER-mihai-adrian.pirjol@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB014041

    Step0: Check Parameter Remain Frozen


Step0: Check Parameter Remain Frozen
    Log  \nStep0: Check Parameter Remain Frozen  console=true
    ${status}  Run Keyword And Return Status  Change Specific Parameter For VDU  berMajorAlarmThreshold  -14  MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1
    IF  ${status}
        Fail  Parameter:berMajorAlarmThreshold can change to value:-14![NOK]
    ELSE
        Log  Parameter:berMajorAlarmThreshold cannot be changed![OK]  console=true
    END


TC Setup
    Common VDU Setup


TC Teardown
    Common VDU Teardown
