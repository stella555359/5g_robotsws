*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CB008502_AVQC_common_keyword.robot

Documentation
...    Author: Lan Shifu
...    Contact: shifu.lan@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008502 in trunk program

Force Tags    5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    SBTS00    PY310    HAZ4_T04


*** Test Cases ***
[1]CB008502-SR-AA_05_SFP28_AVQC_Ethernet_mode_reconfiguration_during_BTS_runtime
    [Tags]    1S-1CC-8D-4U    RF50
    General_SiSo_Online_Modify_LinkSpeed    with_call=${True}    ue_num_each_call=1    default_link_speed=eCpri25    link_speed=eCpri10

[1]CB008502-SR-B_06_SFP56_AVQC_Radio_Unit_replacement
    [Tags]    1S-2CC-72E    RF50
    ${fault_list}    Create List    10    4589
    # Commitment is introuduced from:https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10220
    # Case steps include "RRU power off" which will trigger the expected FID_10/4589.
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_SFP56_AVQC_Radio_Unit_replacement
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB008502-SR-C_02_Fault_4679_was_triggered_with_SFP28
    [Tags]    1S-2CC-72E    RF50
    ${fault_list}    Create List    4679
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Fault_4679_was_triggered_with_SFP28
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}
