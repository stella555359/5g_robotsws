*** Settings ***

Resource    resources/CB008562_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Documentation    This suite is prepared for automation execution of CB008562 features for AMBER and CHILE radio families.
...              Every testcase is executed twice to check measuring for both radios.
...              Authors: Krzysztof Domino
...              Contact: krzysztof.domino@nokia.com
...              squad: 5G_PZ_KRK_3_SG

Force Tags    STATE_SW_UPLOADED    CRT    PY36
...  RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABIOB4B5_AEHC_AEQY
...  RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABIOB4B5_AEHC_AEQY


Suite Setup    Common Suite Setup With OnAir Test Line Preparation  increase_timeout_for_update_sw=3600

Suite Teardown    Common Suite Teardown

*** Variables ***
${cell_id_amber}  83
${cell_id_chile}  2
${tput_ul}  30 MBits/sec
${deviation}     50%


*** Test Cases ***
[1][2.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    [Setup]     Run keywords
    ...         Allow alarms on BTS during test     AND
    ...         Lock gNB Cell  cell_id=${cell_id_chile}     AND
    ...         Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}
    General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break  ${cell_id_amber}  Block unblock gnb cell
    [Teardown]  Run keywords
    ...         Unlock gNB Cell  cell_id=${cell_id_chile}  AND
    ...         wait until keyword succeeds     5 min  1 min  Verify gNB Cell is onAir  cell_id=${cell_id_chile}  AND
    ...         Disallow alarms on BTS after test   AND
    ...         Common Postconditions

[1][1.0] General_SiSo_Auto_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call
    [Setup]     Run keywords
    ...         Allow alarms on BTS during test     AND
    ...         Lock gNB Cell  cell_id=${cell_id_chile}     AND
    ...         Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}
    General_SiSo_Auto_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call  ${cell_id_amber}
    [Teardown]  Run keywords
    ...         Unlock gNB Cell  cell_id=${cell_id_chile}  AND
    ...         wait until keyword succeeds     5 min  1 min  Verify gNB Cell is onAir  cell_id=${cell_id_chile}  AND
    ...         Disallow alarms on BTS after test   AND
    ...         Common Postconditions

[1][2.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_CLI_commands_with_break
    [Setup]     Run keywords
    ...         Allow alarms on BTS during test     AND
    ...         Lock gNB Cell  cell_id=${cell_id_chile}     AND
    ...         Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}
    General_SiSo_Auto_Antenna_Online_Monitoring_using_CLI_commands_with_break  ${cell_id_amber}  Block unblock gnb cell
    [Teardown]  Run keywords
    ...         Unlock gNB Cell  cell_id=${cell_id_chile}  AND
    ...         wait until keyword succeeds     5 min  1 min  Verify gNB Cell is onAir  cell_id=${cell_id_chile}  AND
    ...         Disallow alarms on BTS after test   AND
    ...         Common Postconditions


