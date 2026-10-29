*** Settings ***
Suite Setup    SISO Coam Suite Setup For 9275
Suite Teardown    SISO Coam Suite Teardown
Test Setup    SISO Coam Test Setup
Test Teardown     Run Keywords    Run Keyword And Continue On Failure
...    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}    AND
...    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB009275_common.robot

Documentation
...    Author:Lin Stella
...    contact:stella.lin@nokia-sbell.com
...    squad group:SG_06
...    Feature CB009275


*** Test Cases ***
[1]02_CB009275_Feature_Enable_with_Fault_1932_actived
    [Tags]    CRT_23R3
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    02_CB009275_Feature_Enable_with_Fault_1932_actived

[1]CB008990-SR-01_Ecpri_RU_Beamer_Beamer_link_fault_activation
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    CB008990-SR-01_Ecpri_RU_Beamer_Beamer_link_fault_activation

[1]CB011039-A_01_Radio_Module_fail_safe_mode_fault_activation
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    ...                                                     2934    2919    4681
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    CB011039-A_01_Radio_Module_fail_safe_mode_fault_activation
    [Teardown]    11039_Case_Teardown

[1]CNI-109465-A_01_SOC SW log collection needs to be added to RU Snapshots
    [Setup]    109465_Case_Setup
    CNI-109465-A_01_SOC SW log collection needs to be added to RU Snapshots
    [Teardown]    109465_Case_Teardown