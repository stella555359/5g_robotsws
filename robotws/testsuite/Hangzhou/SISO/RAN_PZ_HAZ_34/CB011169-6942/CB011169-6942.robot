*** Settings ***
Documentation
...    author: Kaijia Chen
...    contact: kaijia.chen@nokia-sbell.com
...    squad group: VRF3_SG04
...    feature : CB011169-6942


Resource    ./Resources/11169_common_keyword.robot
Variables   ./Resources/TLConfigration_11169.py

Suite Setup    CB011169 Suite Setup
Suite Teardown    CB011169 Suite Teardown


*** Test Cases ***
[1]CB011169-CR-CB007841-5G-A_1_BTS_startup_SFP_power_level_compatibility_validation_alarming_of_power_class_incompatibility
    Check vDU And CU On Air
    Check Power Level for SFP

[1]CB011169-CR-CB007841-5G-D_1_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support_for_FH_interface
    Check vDU And CU On Air
    Check temperature on SFP

[1]CB011169-CR-CB007841-5G-E_1_The_BTS_shall_support_NIDD_parameter_EQM_APEQM-SFPOperatorMode_to_enable_and_disable_SFP_compliance_validation
    [Setup]    robot_common_operations.Common case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4657
    VDU Online Change Parameters Activate    updated_paras_list=${SFP_Operator_Mode_False}
    Check FID4657
    VDU Online Change Parameters Activate    updated_paras_list=${SFP_Operator_Mode_True}
    Check FID4657 is cleared
    VDU Online Change Parameters Activate    updated_paras_list=${SFP_Operator_Mode_False}
    Check FID4657
    [Teardown]    Run keywords    Recover modified parameter    AND    CB011169 Case Teardown

[1]CB011169-CR-CB007841-5G-E_2_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    Check vDU And CU On Air
    log to console    case can be passed by previous case passed

*** Keywords ***
Recover modified parameter
    VDU Online Change Parameters Activate    updated_paras_list=${SFP_Operator_Mode_True}
