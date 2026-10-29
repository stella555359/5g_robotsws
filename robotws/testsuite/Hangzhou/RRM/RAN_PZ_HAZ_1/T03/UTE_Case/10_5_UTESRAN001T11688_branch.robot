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
&{CB009059_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009059${/}CB009059.robot
&{CB009059_CJH_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009059${/}CB009059-CJH.robot
&{CB012331_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB012331${/}CB012331.robot
&{CB008126_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126-B7.robot
&{CB008242_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB008242${/}CB008242_FG.robot
&{CB008234_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB008234_ST_A${/}CB008234_ST_A.robot
&{CB007742_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB007742TMO${/}CB007742_TMO.robot
&{CB005825_Case_Info}       Case_Path=${CURDIR}${/}..${/}CB005825_TMO${/}CB005825_TMO.robot
&{Feature_File_INFO}
...    Rollback=&{Rollback_Case_Info}
...    Upgrade=&{Upgrade_Case_Info}
...    CB009059=&{CB009059_Case_Info}
...    CB009059-CJH=&{CB009059_CJH_Case_Info}
...    CB012331=&{CB012331_Case_Info}
...    CB008126-B7=&{CB008126_Case_Info}
...    CB008242-G4=&{CB008242_Case_Info}
...    CB008234-A=&{CB008234_Case_Info}
...    CB007742=&{CB007742_Case_Info}
...    CB005825=&{CB005825_Case_Info}

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
# CB012331-SR_06_01 Inter-PLMN CA with Measurement based Scell change in 4CC
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB012331
# CB012331-SR_05_01 Inter-PLMN CA with Measurement based Scell swap 4CC
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB012331
case30_CB008126 Interacts with CB009059_5QI modification with Not CA eligible DRB profile
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB008126-B7
case31_CB008126 Interacts with CB009059_5QI modification with CA incompatible DRB profile
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB008126-B7
# CB008242-SR_G_04_01 actUacAuto online modification
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB008242-G4
# CB008242-SR_G_04_01 actUacAuto online modification without BBPooling
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB008242-G4
CB008242-SR_F_01_01 SgNBAddition rejections due to auto UAC broadcast in SIB1
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB008242-G4
CB008234_A_B1 DL AMBR limitation for the non_GBR bearer of the SA UE
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB008234-A
# CB008234_A_B6 DL AMBR limitation handling with PDU Session Modify
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB008234-A
# USCB008234_D AMBR_DL_UL limitation interworking with CB009059 RLC_UM DRB for non-GBR setting
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB008234-A
USCB008234_D_B10 UL UE AMBR interworking with FR1 UL CA
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB008234-A
CB007742-SR_22_Handover to 5G-SA non EN-DC case
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007742
# CB007742-SR_27_New PM counter update for handover from LTE to NR without VoLTE
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
#     Run Feature Case    CB007742
CB005825_03_NR neighbor creation when number of unknown B2-NR MRs has crossed threshold B1-NR MR already reported
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB005825
CB005825_06_Periodic LNADJN and LNADJNL removal due to no matching LNRELN found
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB005825