*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   This is a robot case for UTE regression
# Resource          ../Resources/common_resource.robot
# # Resource          ../Resources/ute_case_common_resource.robot
# Library           ute_ue
# Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Teardown    TL Suite Teardown
# Test Setup        _Create Test Directory
# Test Teardown     TL Test Teardown
# Force Tags
# # ...                     CRT
# ...                     RAN_5G
# ...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIAL_ABIAB2_AZHA_FZHM-ASIBR_ABINB1_ABIAB1_FXEB_AHFIB
# # ...                     SBTS22R4
# ...                     SBTS00
# ...                     STATE_SKIP_AGENT
# ...                     CA_RAN_PZ_HAZ_1
# ...                     RAN_PZ_HAZ1_SG07_ST_RRM
# ...                     TA_LEVEL_22
# Test Timeout            75h
# *** Variables ***
# &{Init_Enviroment}      IP=10.106.230.5
# ...                     USERNAME=root
# ...                     PASSWORD=uteadmin
# ...                     Reinstall_Script_Path=${/}root${/}scripts
# ...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
# ${testline_configuration_path}    ~${/}testline_configuration
# #Storge case file info and path case file : { case path : path, case list: case list}
# &{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
# ...                       Case_Tag=Upgrade
# &{CB008656_1_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008656${/}CB008656.robot
# ...                       Case_Tag=CB008656_1
# &{CB008656_2_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008656${/}CB008656.robot
# ...                       Case_Tag=CB008656_2
# &{Feature_File_INFO}
# ...    Upgrade=&{Upgrade_Case_Info}
# ...    CB008656_1=&{CB008656_1_Case_Info}
# ...    CB008656_2=&{CB008656_2_Case_Info}
# *** Test Cases ***
# Init Enviroment
#     ReInstall Vm    ${False}
# Case1_Feature_migration_activation_and_deactivation_for_CB008656
#     Compare Release And Choose Suitable Upgrade
#     Run Feature Case    Upgrade
# Case3_eNB_sends_IMMCI_at_TAU_in_RRC_connection_for_TAU_initiated_from_idle_mode_and_released_for_UE_enabled_for_CB008656
#     Run Feature Case    CB008656_1
# Case4_ATTACH_procedure_in_CB008656_enabled_cell
#     Run Feature Case    CB008656_2
# Case5_DETACH_procedure_in_CB008656_enabled_cell
#     Run Feature Case    CB008656_2

