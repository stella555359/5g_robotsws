*** Settings ***
Suite Setup          Run keywords    open_udp_port_on_VM    AND    SISO Coam Suite Setup    AND
...    run keyword and ignore error    Output RU logs to control PC
Suite Teardown       SISO Coam Suite Teardown
Test Setup           Run keywords    SG8 Common case Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=6825
Test Teardown        Run keywords    AlarmWatchdog.remove_allow_alarms    fault_id=6825     AND     SG8 Common case Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB007447_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SG8_SISO_common_case/resources/SISO_common_case_keywords_SG8.robot

Documentation
...    Author: jiangjing.lin
...    Contact: jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB007447

Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
...   PY36
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374

*** Test Cases ***
[1]CB007447_C_D_Long_PL_break_with_recovery
    CB007447_Long_PL_break_with_recovery

[1]CB007447_C_D_Long_SL_break_with_recovery
    CB007447_Long_SL_break_with_recovery

[1]CB007447_C_D_Short_PL_break_with_recovery
    CB007447_Short_PL_break_with_recovery

[1]CB007447_C_D_Short_SL_break_with_recovery
    CB007447_Short_SL_break_with_recovery

[1]CB007447_D_Long_short_link_break_counter_check_with_webem_and_netact
    CB007447_Long_short_link_break_counter_check_with_webem_and_netact

[1]CB007447_D_Link_break_with_RU_reset
    CB007447_Link_break_with_RU_reset

[1]CB007447_Short_PL_SL_break_with_energysaving
    Commissioning SCF And Check BTS On Air
    CB007447_Short_PL_SL_break_with_energysaving
