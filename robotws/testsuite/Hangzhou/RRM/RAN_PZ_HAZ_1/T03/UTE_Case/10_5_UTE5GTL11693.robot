*** Settings ***
Documentation
...   author: Xiaofeng Nie
...   contact: xiaofeng.nie@nokia-sbell.com
...   This is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        Create Test Directory
Test Teardown     TL Test Teardown
Force Tags
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIA_ABIAL_AZNC_FXEB
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     VRF_HAZ_T06
...                     TA_LEVEL_22
Test Timeout            75h


*** Variables ***
&{Init_Enviroment}      IP=10.56.198.130
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot    Case_Tag=Upgrade
&{CB007123_1_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007123${/}CB007123.robot    Case_Tag=CB007123_1
&{CB007123_2_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007123${/}CB007123.robot    Case_Tag=CB007123_2
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
...    CB007123_1=&{CB007123_1_Case_Info}
...    CB007123_2=&{CB007123_2_Case_Info}


*** Test Cases ***
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
CB007123_TC01_B1-NR activated by DL buffer overflow indication
    Run Feature Case    CB007123_1
CB007123_TC04_B1-NR activated by UL buffer overflow indication
    Run Feature Case    CB007123_2
