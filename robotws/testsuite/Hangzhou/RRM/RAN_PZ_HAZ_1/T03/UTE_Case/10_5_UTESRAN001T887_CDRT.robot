*** Settings ***
Documentation
...   author: nicky.lu
...   contact: nicky.lu@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        _Create Test Directory
Test Teardown     TL Test Teardown
Force Tags              CRT
...                     CDRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBR_ABIO_ABIL2_AEHC_AHFIB_AHLOA_AHFIG
# ...                     SBTS22R4
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            12h
*** Variables ***
&{Init_Enviroment}      IP=10.56.198.130
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                       Case_Tag=Upgrade
&{Rollback_Case_Info}    Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
&{Performance_Testing_Case_Info}   Case_Path=${CURDIR}${/}..${/}Performance_Testing${/}Performance_Testing.robot
&{CB006127_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB006127${/}CB006127.robot
&{Feature_File_INFO}
...    Rollback=&{Rollback_Case_Info}
...    Upgrade=&{Upgrade_Case_Info}
...    Performance_Testing=&{Performance_Testing_Case_Info}
...    CB006127=&{CB006127_Case_Info}
*** Test Cases ***
Init Enviroment
    Upgrade ute-ca
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
CB008428-SR_01_EFT-95_UDP_DL
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    Performance_Testing
CB008428-SR_07_EFF-143_UDP_DL
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    Performance_Testing


