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
...                     CLOUD_5G_CLASSICAL_ANDROID_ASIMR_ABIP_ABIO_ABIQ_AHFIB_AHLOA_AZHL_AVQQA
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
# &{Rollback_Case_Info}    Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
&{CB007035_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007035_ET${/}CB007035.robot
# &{CNI128069_Case_Info}   Case_Path=${CURDIR}${/}..${/}CNI128069${/}CNI128069.robot
# &{CB012331_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB012331${/}CB012331.robot

&{Feature_File_INFO}
# ...    Rollback=&{Rollback_Case_Info}
...    Upgrade=&{Upgrade_Case_Info}
...    CB007035=&{CB007035_Case_Info}
# ...    CNI128069=&{CNI128069_Case_Info}
# ...    CB012331=&{CB012331_Case_Info}

*** Test Cases ***
Init Enviroment
    ReInstall Vm    ${False}
# Rollback For Local
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Rollback
# Rollback For Remote GNBs
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Rollback
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
CB007035-SR-A-19 NR SBHO is triggered based on received NR SBHO B1-NR measurement report
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007035
CB007035_TMOUS_CVR_001 EPS Fallback from TMOUS configuration
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007035
CB007035_TMOUS_CVR_002 interaction with ENDC onTMOUS configuration
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007035
# CB012331-SR_06_01 Inter-PLMN CA with Measurement based Scell change in 4CC
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB012331
# CB012331-SR_05_01 Inter-PLMN CA with Measurement based Scell swap 4CC
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB012331
CB007035_TMOUS_CVR_003 CB007742 disabled on TMOUS configuration
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007035
CB007035-SR-D-01 NR SBHO B1-NR measurement report received from the UE counter threshold NOT crossed
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007035
# CNI-128069_CB012118_FIM_Robustness_and_Exploratory
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CNI128069