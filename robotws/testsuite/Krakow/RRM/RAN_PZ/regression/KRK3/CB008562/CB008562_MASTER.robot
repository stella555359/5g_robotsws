*** Settings ***

Resource    resources/CB008562_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Documentation    This suite is prepared for automation execution of CB008562 features for MASTER radio family.
...              Authors: Krzysztof Domino
...              Contact: krzysztof.domino@nokia.com
...              squad: 5G_PZ_KRK_3_SG

Force Tags    STATE_SW_UPLOADED    CRT    PY36
...  RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABIOB1B2_AEQE_AEQP
...  RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABIOB1B2_AEQE_AEQP


Suite Setup    Common Suite Setup With OnAir Test Line Preparation  increase_timeout_for_update_sw=3600

Suite Teardown    Common Suite Teardown

*** Variables ***
${cell_id}  1
${cell_id2}  2
${tput_ul}  15 MBits/sec

*** Test Cases ***
[1][3.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    [Setup]  Lock gNB Cell  cell_id=${cell_id2}
    Allow alarms on BTS during test
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${True}
    General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break  ${cell_id}  Reset bbmod and sleep
    [Teardown]  Run keywords
    ...         Unlock gNB Cell  cell_id=${cell_id2}  AND
    ...         wait until keyword succeeds     5 min  1 min  Verify gNB Cell is onAir  cell_id=${cell_id2}  AND
    ...         Common Postconditions

[4][1.0] General_SiSo_Auto_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call
    [Setup]  Lock gNB Cell  cell_id=${cell_id2}
    Allow alarms on BTS during test
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${True}
    General_SiSo_Auto_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call  ${cell_id}
    [Teardown]  Run keywords
    ...         Unlock gNB Cell  cell_id=${cell_id2}  AND
    ...         wait until keyword succeeds     5 min  1 min  Verify gNB Cell is onAir  cell_id=${cell_id2}  AND
    ...         Common Postconditions

[1][3.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_CLI_commands_with_break
    [Setup]  Lock gNB Cell  cell_id=${cell_id2}
    Allow alarms on BTS during test
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${True}
    General_SiSo_Auto_Antenna_Online_Monitoring_using_CLI_commands_with_break  ${cell_id}  Reset bbmod and sleep
    [Teardown]  Run keywords
    ...         Unlock gNB Cell  cell_id=${cell_id2}  AND
    ...         wait until keyword succeeds     5 min  1 min  Verify gNB Cell is onAir  cell_id=${cell_id2}  AND
    ...         Common Postconditions




