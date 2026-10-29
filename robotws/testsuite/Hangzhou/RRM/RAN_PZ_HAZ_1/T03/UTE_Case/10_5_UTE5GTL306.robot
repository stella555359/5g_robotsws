*** Settings ***
Documentation
...   author: Dong tony
...   contact: tony.1.dong@nokia-sbell.com
...   This is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        _Create Test Directory
Test Teardown     TL Test Teardown
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDROID_SA_CA_ASIBL_ABIOB1_AHEH
# ...                   SBTS24R3
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
&{Init_Enviroment}      IP=10.56.198.130
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#Storge case file info and path case file : { case path : path, case list: case list}
&{CB008126_1_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_1
&{CB008126_2_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_2
&{CB008126_3_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_3
&{CB008126_4_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_4
&{CB008126_5_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_5
&{CB008126_6_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_6
&{CB008126_7_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_7
&{CB008126_8_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008126${/}CB008126.robot
...                       Case_Tag=CB008126_8
&{CB008234_1_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_1
&{CB008234_2_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_2
&{CB008234_3_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_3
&{CB008234_4_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_4
&{CB008234_5_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_5
&{CB008234_6_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_6
&{CB008234_7_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_7
&{CB008234_8_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_8
&{CB008234_9_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008234${/}CB008234-SR-B.robot
...                       Case_Tag=CB008234_9
&{CB009849_1_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009849${/}CB009849_A1.robot
...                       Case_Tag=CB009849_1


&{Feature_File_INFO}
...    CB008126_1=&{CB008126_1_Case_Info}
...    CB008126_2=&{CB008126_2_Case_Info}
...    CB008126_3=&{CB008126_3_Case_Info}
...    CB008126_4=&{CB008126_4_Case_Info}
...    CB008126_5=&{CB008126_5_Case_Info}
...    CB008126_6=&{CB008126_6_Case_Info}
...    CB008126_7=&{CB008126_7_Case_Info}
...    CB008126_8=&{CB008126_8_Case_Info}
...    CB008234_1=&{CB008234_1_Case_Info}
...    CB008234_2=&{CB008234_2_Case_Info}
...    CB008234_3=&{CB008234_3_Case_Info}
...    CB008234_4=&{CB008234_4_Case_Info}
...    CB008234_5=&{CB008234_5_Case_Info}
...    CB008234_6=&{CB008234_6_Case_Info}
...    CB008234_7=&{CB008234_7_Case_Info}
...    CB008234_8=&{CB008234_8_Case_Info}
...    CB008234_9=&{CB008234_9_Case_Info}
...    CB009849_1=&{CB009849_1_Case_Info}

*** Test Cases ***
#Init Enviroment
#    ReInstall Vm    ${False}
Case2_Successful 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_single non-GBR for 5QI modification with different DRB profile
    Run Feature Case    CB008126_1
Case4_Successful 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_VoNR established before QoS modification
    Run Feature Case    CB008126_2
Case9_Successful 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_single non-GBR for 5QI modification with same DRB profile
    Run Feature Case    CB008126_3
Case10_Feature flag-NRBTS.act5qiAndUlNguTnlQosFlowModification off reject QoS modification request
    Run Feature Case    CB008126_4
Case14_ Fail to perform 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_Change 5QI value from NonVoNR GBR to NonVoNR GBR
    Run Feature Case    CB008126_5
Case17_Fail to perform 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_Admission control failure in CU-CP
    Run Feature Case    CB008126_6
Case18_Counter for 5QI modification success used by USCB008126-SR-A-B1
    Run Feature Case    CB008126_7
Case21_Counter for 5QI modification failure used by USCB008126-SR-A-B7
    Run Feature Case    CB008126_8
USCB008234_B_B1_UL_UE_AMBR_Enforcement_on_FDD_with_one_UE
    Run Feature Case    CB008234_1
USCB008234_B_B1_UL_UE_AMBR_Enforcement_with_disable_feature_and_enable_it_back
    Run Feature Case    CB008234_2
USCB008234_B_B3_UL_AMBR_limitation_handling_during_ICS_with_PDU_session_setup
    Run Feature Case    CB008234_3
USCB008234_C_B1_DL_and_UL_UE_AMBR_limitation_modification_for_UE_Context modification request
    Run Feature Case    CB008234_9
USCB008234_counters_for_AMBR_value_distribution_with_AMBR_value_modification
    Run Feature Case    CB008234_5
USCB008234_counters_for_AMBR_value_distribution_with_newly_received_and_validated_AMBR_value
    Run Feature Case    CB008234_6
USCB008234_counters_for_AMBR_value_distribution_with_DLAMBR_and_ULAMBR_value_set_0
    Run Feature Case    CB008234_7
USCB008234_D_B11_DL_UE_AMBR_interworking_with_Nominal_Bit_Rate
    Run Feature Case    CB008234_8
USCB008234_D_B16_DL_UE_AMBR_interworking_with_CA_FDD_intraband_2CC
    Run Feature Case    CB008234_4
CB009849_A Successful feature flag online modify
    Run Feature Case    CB009849_1



