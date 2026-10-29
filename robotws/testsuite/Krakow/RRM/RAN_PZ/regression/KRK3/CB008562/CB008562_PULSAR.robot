*** Settings ***

Resource    resources/CB008562_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Documentation    This suite is prepared for automation execution of CB008562 features for PULSAR radio family.
...              Authors: Krzysztof Domino
...              Contact: krzysztof.domino@nokia.com
...              squad: 5G_PZ_KRK_3_SG

Force Tags    STATE_SW_UPLOADED    CRT    PY36
...  RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABINB4_AZQG
...  RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABINB4_AZQG


Suite Setup    Common Suite Setup With OnAir Test Line Preparation  increase_timeout_for_update_sw=3600

Suite Teardown    Common Suite Teardown

Test Teardown       Common Postconditions

*** Variables ***
${cell_id}  1
${tput_ul}  20 MBits/sec
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  LMP access via port 3600
...                  Diagnostic Files collected
...                  Radio Diagnostic Files collected
...                  BTS Reset Cause
...                  Service account root access is enabled
...                  Ethernet port security is disabled
...                  ToP reference missing
...                  Sanity Check Error
...                  Diagnostic Check Error
...                  No X2 link available
...                  No X2 link available for a specific LTEENB
...                  Cell blocked


*** Test Cases ***
[1][1.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    Set Test Variable    @{mandatory_alarms}    No connection to unit
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}
    General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break  ${cell_id}  Reset RU and Verify Alarm

[3][1.0] General_SiSo_Auto_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}
    General_SiSo_Auto_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call  ${cell_id}
