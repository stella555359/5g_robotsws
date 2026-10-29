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
&{CB007320_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007320${/}CB007320.robot
&{CB012582_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB012582${/}CB012582_A_TMO_DF.robot
&{CB009849_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009849${/}CB009849_C_CRT.robot
&{Feature_File_INFO}
...    Rollback=&{Rollback_Case_Info}
...    Upgrade=&{Upgrade_Case_Info}
...    Performance_Testing=&{Performance_Testing_Case_Info}
...    CB006127=&{CB006127_Case_Info}
...    CB007320=&{CB007320_Case_Info}
...    CB012582=&{CB012582_Case_Info}
...    CB009849=&{CB009849_Case_Info}
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
CB008428-SR_01_EFT-95_UDP_DL
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    Performance_Testing
CB008428-SR_07_EFF-143_UDP_DL
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    Performance_Testing
# CB008532-5G_04_D5860_SA-81_SR100
#     Run Feature Case    Performance_Testing
CB008532-5G_12_D5860_SA-75_SR100
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    Performance_Testing
CB008542-5G_01_EFT-156_UDP_DL
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    Performance_Testing
CB008542-5G_12_D5860-57_UDP_SR_100
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    Performance_Testing
# CB006127_A_01_NSA_Report_CGI_configuration_to_UE_based_on_RSRQ
#     Run Feature Case    CB006127
CB006127_A_02_SA_Report_CGI_configuration_to_UE_based_on_RSRP_RSRQ
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006127
IWK_ESP_CB7320_Keeping_UL_256QAM_mode_and_CQM_after_ENDC_entry
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007320
Case18_Counter for 5QI modification success used by USCB008126-SR-A-B1
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006127
Case21_Counter for 5QI modification failure used by USCB008126-SR-A-B7
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006127
USCB008234_C_B1_DL_and_UL_UE_AMBR_limitation_modification_for_UE_Context modification request
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006127
USCB008234_counters_for_AMBR_value_distribution_with_newly_received_and_validated_AMBR_value
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006127
USCB008234_counters_for_AMBR_value_distribution_with_DLAMBR_and_ULAMBR_value_set_0
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006127
CB012582_A_4_SA Intra-gNB Intra-DU Inter-Freq HO Interruption time Target Range
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB012582
CB009849_C_05_Update VoNR downlink rank reduction algorithm for SRB, 5QI5 and 5QI1
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB009849
CB009849_C_12_Update VoNR downlink rank reduction algorithm to use CQI data for SRB, 5QI5, 5QI1 and non-GBR
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB009849
