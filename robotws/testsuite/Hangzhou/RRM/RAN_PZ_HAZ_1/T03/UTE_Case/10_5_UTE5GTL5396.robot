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
...                     CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIB_ABIO2_AEHC_AHLOA_AHFIB
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
&{CB008927_1_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008927${/}CB008927.robot    Case_Tag=CB008927_1
&{CB008927_2_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008927${/}CB008927.robot    Case_Tag=CB008927_2
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
...    CB008927_1=&{CB008927_1_Case_Info}
...    CB008927_2=&{CB008927_2_Case_Info}


*** Test Cases ***
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
TC01_USCB008927-Q#B1_single UE in LTE-NR FDD DSS cell SA mode 10MHz with bbpooling disabled
    Run Feature Case    CB008927_1
TC02_USCB008927-Q#B1_single UE in LTE-NR FDD DSS cell SA mode 20MHz with bbpooling enabled
    Run Feature Case    CB008927_2
