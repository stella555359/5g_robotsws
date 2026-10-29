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
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
# ...                     SBTS22R4
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
&{Init_Enviroment}      IP=10.106.230.5
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                       Case_Tag=Upgrade
&{Rollback_Case_Info}    Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
# &{CB009426_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009426${/}CB009426.robot
# &{CB009059_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009059${/}CB009059.robot
# &{CB009059_CJH_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009059${/}CB009059-CJH.robot
# &{CB012331_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB012331${/}CB012331.robot
# &{CB008126_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126-B7.robot
# &{CB008242_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB008242${/}CB008242_FG.robot
# &{CB008234_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB008234_ST_A${/}CB008234_ST_A.robot
# &{CB007742_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB007742TMO${/}CB007742_TMO.robot
# &{CB005825_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB005825_TMO${/}CB005825_TMO.robot
&{CB008218_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB008218_TMO${/}CB008218.robot
&{Feature_File_INFO}
...    Rollback=&{Rollback_Case_Info}
...    Upgrade=&{Upgrade_Case_Info}
# ...    CB009059=&{CB009059_Case_Info}
# ...    CB009059-CJH=&{CB009059_CJH_Case_Info}
# ...    CB012331=&{CB012331_Case_Info}
# ...    CB008126-B7=&{CB008126_Case_Info}
# ...    CB008242-G4=&{CB008242_Case_Info}
# ...    CB008234-A=&{CB008234_Case_Info}
# ...    CB007742=&{CB007742_Case_Info}
# ...    CB005825=&{CB005825_Case_Info}
...    CB008218=&{CB008218_Case_Info}

*** Test Cases ***
Init Enviroment
    ReInstall Vm    ${False}
Rollback For Local
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback
Rollback For Remote GNBs
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
#     CB005825_19_Activation and configuration of ANR for LTE-5G Standalone
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB005825
CB008218_04_B1-NR measurements can be periodically configured when waiting for DL buffer overflow
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB008218