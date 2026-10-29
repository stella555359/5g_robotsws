*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
#Test Setup
#Test Teardown
Test Timeout      2 hours

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
Resource     ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource     ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource     ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource     ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007511_AQQL/resource/CB007511_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010766/Resource/CB010766_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008238_A/resource/CB008238_Common_KW.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008997/resource/CB008997_Common_KW.robot

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/optical_switch/optical_switch.robot
Resource      ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010846/Resource/CB010846_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    Squad group:SG_05
...    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
@{rd8DL8RxonHalfAbip}      0x42008C=1   #rd8DL8RxonHalfAbip=true    #addtional falg for CB010713
${key_rd8DL8RxonHalfAbip}  0x42008C

${btslog_path}    /tmp/btslog2
${btslog_launcher}    /opt/btslog/btslog_launcher
${btslog_launcher_path}    /opt/btslog/btslog
${Expected_ERR_WRN_deviation}    0.2
${FilesSystem}    /dev/mapper/vg_sys-lv_home

#Branch: sg5_aa_customCovage
#repo_path: testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/CustomerCvg/Customer_tl692.robot

*** Test Cases ***
#7_5_UTE5G402T260
##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012196_SG05/CB012196-SR.robot
[1]CB012196-SR-C-41-Manual_SiSo_SM_NR RAT reset
    #[Tags]    2S-4CC-8D8U_50M_4Rx_CB012196_7    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #Manual_SiSo_SM_NR_RAT_reset    with_call=${True}
    Manual_SiSo_SM_NR_RAT_reset    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB012196-SR-D-45-General_SiSo_Cell_block_and_unblock
    #[Tags]    3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${True}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
#    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008997/CB008997.robot
[1]CB008997-SR_13_Manual_SiSo_SM_RF_Module_lock_unlock
    #[Tags]   1S-1CC-8D4U_A8_20M_C2-195    CIT_23R4    CRT_TRUNK
    [Tags]    3S-2CC-8D8U_CB010914_3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
#    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}    with_peak=${True}
#    [Teardown]    Run Keywords    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_38_General_SiSo_E2E_system_setup_with_data_transfer_conducted_20M_peak_tput
    #[Tags]    1S-1CC-8D4U_A8_20M_C2-195    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_42_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60M+80M_peak_tput
    #[Tags]    1S-2CC-8D4U_A6_60-80M_A2-98    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_46_General_SiSo_E2E_system_setup_with_data_transfer_conducted_50M+70M_peak_tput
    #[Tags]    1S-2CC-8D4U_A3_50-70M_F0-7    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_48_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100M+100M_peak_tput
    #[Tags]    1S-2CC-8D4U_A5_100-100M_C2-191_TA-3000    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

#7_5_UTE5G402T662
##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012510_SG05/CB012510-A-B1.robot
[1]CB012510-SR-A_General_SiSo_Auto_RF_lock_unlock
    #[Tags]    5S-25R1_NL_CB012510_A    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009183-SG5/CB009183-SG5.robot
[1]CB009183-SR-A_001_L3_call_on_M1-L_configuration_for_tri-mode_LTE_FDD_normal_cell
    #[Tags]    5S-CB009183-A_BBCellSet-M1-L    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log    To be updated after UE prepared.
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown
##    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${4681}
##    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
##    ...    AND    SISO Coam Test Teardown

[1]CB009183-SR-C_001_L3_call_on_M2_configuration_for_tri-mode_LTE_FDD_normal_cell
    #[Tags]    5S-CB009183-C_BBCellSet-M2    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log    To be updated after UE prepared.
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown
##    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${4681}
##    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
##    ...    AND    SISO Coam Test Teardown

#7_5_UTE5G402T688
##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012518/CB012518.robot
[1]CB012518-SR-A_01_03_10MHz_L3Call_Setup
    #[Tags]    1S-1CC-8D8U_10M_CB012518   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${11}
    Run Keyword If    ${MRBTS_ID}==${2599}    Samsung open screen
    #Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}    4G_check=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB012518-SR-A_02_03_10MHz_60MHz_Split_Mode_Cell_Locked_Unlocked
    #[Tags]    1S-2CC-8D8U_10-60M_Split_CB012518   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_lock_and_unlock    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#7_5_UTE5G402T696
##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010914/CB010914.robot
[1]CB010914-SR_General_SiSo_Cell_block_and_unblock
    #[Tags]    3S-2CC-8D8U_CB010914_3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${False}
    ${fault_list}    Create List    49    7319    7300
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
    #WA for tl692-NSA as 9 enbs used; FID:7319 No X2 link available for a specific LTEENB
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${7319}    AND
    ...           add fault to the allowed fault list    faultId=${7300}    AND
    ...           add fault to allowed history fault list    faultId=${7319}    AND
    ...           add fault to allowed history fault list    faultId=${7300}    AND
    ...           SISO Coam Test Teardown

[1]CB010914-SR_General_SiSo_RU_lock_unlock
    #[Tags]    2S-3CC-16D8U-8D8U_CB010914_6    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    #WA for tl692-NSA as 9 enbs used; FID:7319 No X2 link available for a specific LTEENB
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${7319}    AND
    ...           add fault to the allowed fault list    faultId=${7300}    AND
    ...           add fault to allowed history fault list    faultId=${7319}    AND
    ...           add fault to allowed history fault list    faultId=${7300}    AND
    ...           SISO Coam Test Teardown

[1]CB010914-SR_Manual_SiSo_SM_BTS_Site_Reset
    #[Tags]    3S-4CC-8D8U-8D4U_CB010914_5    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset    with_call=${False}
    #WA for tl692-NSA as 9 enbs used; FID:7319 No X2 link available for a specific LTEENB
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${7319}    AND
    ...           add fault to the allowed fault list    faultId=${7300}    AND
    ...           add fault to allowed history fault list    faultId=${7319}    AND
    ...           add fault to allowed history fault list    faultId=${7300}    AND
    ...           SISO Coam Test Teardown

##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009843/CB009843.robot
[1]CB009843-B4-09_General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=${False}
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

##testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012170_SG5/CB012170.robot
[1]CB012170-SR-A_02_Online_feature_activation_validation_cMAAr7_1_64T64R
  [Setup]  SISO Coam Test Setup
  [Documentation]    Author: Zhang Xuewen
  [Tags]   CRT_TRUNK
  log to console    \n this is used for debugging
##  Step 1 Active 5GC000430 on webEM
##  Step 2 Active CB008133 on webEM
##  Step 3 Active CB012170 on webEM
#  Download MCShark To UTE
#  Bip capture and Check PatternID
#  Step 4 Check gnb status
  [Teardown]    SISO Coam Test Teardown

[1]CB012170-SR-B_06_IWK_CB002001_SSB_muting_when_enable_CB012170_cMAAr7_1_64T64R
  [Setup]  SISO Coam Test Setup
  [Documentation]    Author: Zhang Xuewen
  [Tags]   CRT_TRUNK
  log to console    \n this is used for debugging
##  Step 1 UE run DL traffic and reduce the traffic load of power saving group
##  Step 3 Online change NRBTS.actSSBBoostInmMIMOMuting to true on WebEM
##  Step 4 Check service is not interrupted
##  Step 5 Check gnb status
#  Download MCShark To UTE
#  Bip capture and Check PatternID
#  Step 5 Check gnb status
  [Teardown]    SISO Coam Test Teardown
