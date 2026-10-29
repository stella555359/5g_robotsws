*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test cases

Resource          ../CERTA_Module.robot

Force Tags        RAN_VRF_HAZ1

Test Timeout      2000 minutes



*** Test Cases ***
# TC01_Wrong_Operation
#     ${case_result}    ${msg}    Run Keyword And Ignore Error    Temp Nidd Check    operation=asdf
#     ...                                                                            target_release=trunk
#     Log To Console    \nMsg: ${msg}
#     Log To Console    \nCase Result: ${case_result}
#     Should Be Equal    ${case_result}    FAIL

# TC02_Upgrade_Case
#     Temp Nidd Check    operation=upgrade    target_release=23R2    target_version=SBTS23R2_ENB_0000_001194_000000

# TC03_Upgrade_Case
#     Temp Nidd Check    operation=upgrade    target_release=23R4

# TC04_Delta_Commission_Case
#     Temp Nidd Check    operation=delta_plan_update    target_release=23R4

# TC05_Set_Temp_NIDD_Case
#     Temp Nidd Check    operation=check_temp_nidd      target_release=23R4
#     Temp Nidd Check    operation=set_temp_nidd      target_release=23R4
#     Temp Nidd Check    operation=check_temp_nidd      target_release=23R4

# TC06_Check_Temp_NIDD_Case
#     Temp Nidd Check    operation=check_temp_nidd      target_release=23R4
#     Temp Nidd Check    operation=check_temp_nidd      target_release=23R4

# TC07_Check_Target_NIDD_Case
#     Temp Nidd Check    operation=check_target_nidd    target_release=25R2

TC88_Temp_NIDD_Check_From_23R2_To_24R3
    Temp Nidd Check    operation=upgrade              target_release=23R2    target_version=SBTS23R2_ENB_0000_001194_000000
    Temp Nidd Check    operation=full_commission      target_release=23R2
    Temp Nidd Check    operation=check_temp_nidd      target_release=23R2
    Temp Nidd Check    operation=delta_plan_update    target_release=23R2
    Temp Nidd Check    operation=check_temp_nidd      target_release=23R2

    Temp Nidd Check    operation=upgrade              target_release=23R3
    Temp Nidd Check    operation=check_temp_nidd      target_release=23R2
    Temp Nidd Check    operation=delta_plan_update    target_release=23R3
    Temp Nidd Check    operation=check_temp_nidd      target_release=23R3

    Temp Nidd Check    operation=upgrade              target_release=23R4
    Temp Nidd Check    operation=check_temp_nidd      target_release=23R3
    Temp Nidd Check    operation=delta_plan_update    target_release=23R4
    Temp Nidd Check    operation=check_temp_nidd      target_release=23R4

    Temp Nidd Check    operation=upgrade              target_release=24R1
    Temp Nidd Check    operation=check_target_nidd    target_release=24R1
    # Temp Nidd Check    operation=check_temp_nidd      target_release=23R4_part
    Temp Nidd Check    operation=delta_plan_update    target_release=24R1
    Temp Nidd Check    operation=check_temp_nidd      target_release=24R1

    Temp Nidd Check    operation=upgrade              target_release=24R2
    Temp Nidd Check    operation=check_target_nidd    target_release=24R2

    Temp Nidd Check    operation=upgrade              target_release=24R3
    Temp Nidd Check    operation=delta_plan_update    target_release=24R3
    Temp Nidd Check    operation=check_temp_nidd      target_release=24R3


