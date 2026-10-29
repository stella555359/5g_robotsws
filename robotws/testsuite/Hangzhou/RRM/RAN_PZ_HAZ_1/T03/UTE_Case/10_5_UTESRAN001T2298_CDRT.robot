*** Settings ***
Documentation
...   author: winnie.he
...   contact: winnie.he@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        _Create Test Directory
Test Teardown     TL Test Teardown
Force Tags
...                     CDRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS22R4
#...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
&{Init_Enviroment}      IP=10.56.198.140
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{Upgrade_Case_Info}    Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                     Case_Tag=Upgrade
&{CB007163_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007163${/}CB007163.robot
&{LTE5003_Case_Info}    Case_Path=${CURDIR}${/}..${/}LTE5003${/}LTE5003.robot
&{CB009189_Case2_Info}    Case_Path=${CURDIR}${/}..${/}CB009189${/}CB009189.robot
...                       Case_Tag=CB009189_A
&{CB008033_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008033${/}CB008033.robot
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
...    CB007163=&{CB007163_Case_Info}
...    LTE5003=&{LTE5003_Case_Info}
...    CB009189_2=&{CB009189_Case2_Info}
...    CB008033=&{CB008033_Case_Info}
${APC_Index}    -1

*** Test Cases ***
Init Enviroment
    ReInstall Vm
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
CB007163_03_MR-DC capabilities shall be considered when steering UE to preferred layer when CB006607 is enabled
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007163
LTE5003-A_FDD_Coverage and buffer based EN-DC setup before LTE CA configuration
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    LTE5003
CB009189-A_02_SA_TDD_Successful admission control for specific SR period configured DRB addition for non-VoNR UEs additional DRBs SR change
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB009189_2
CB008033_01_ Verify SA VoNR handover counters in successful intra-gNB handover procedures
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB008033

