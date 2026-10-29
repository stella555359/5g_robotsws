*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        _Create Test Directory
Test Teardown     TL Test Teardown
Force Tags              CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
# ...                     SBTS22R4
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
&{Init_Enviroment}      IP=10.108.230.19
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                       Case_Tag=Upgrade
&{CB009426_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009426${/}CB009426.robot

&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
...    CB009426=&{CB009426_Case_Info}
*** Test Cases ***
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
CB009426-A_Enable_Disable_Randomized_RBG_allocations_in_one_BWP
    Run Feature Case    CB009426
CB009426-B_Randomized_RBG_allocations_in_cell_with_two_dedicated_BWPs
    Run Feature Case    CB009426
CB009426-C_Randomized_RBG_allocations_in_one_BWP_with_CB008955_enabled
    Run Feature Case    CB009426

