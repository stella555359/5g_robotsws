*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
#Test Setup
#Test Teardown
Test Timeout      4 hours

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
Resource     ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
#Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource     ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource     ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007511_AQQL/resource/CB007511_Common_KW.robot
#Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009027-5G-K/resource/CB009027_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010766/Resource/CB010766_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008238_A/resource/CB008238_Common_KW.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/optical_switch/optical_switch.robot
Resource      ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010846/Resource/CB010846_Common_KW.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005763/Resources/CB005763_common_keyword.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    Squad group:SG_05
...    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
#@{rd8DL8RxonHalfAbip}      0x42008C=1   #rd8DL8RxonHalfAbip=true    #addtional falg for CB010713
#${key_rd8DL8RxonHalfAbip}  0x42008C

${btslog_path}    /tmp/btslog2
${btslog_launcher}    /opt/btslog/btslog_launcher
${btslog_launcher_path}    /opt/btslog/btslog
${Expected_ERR_WRN_deviation}    0.2
${FilesSystem}    /dev/mapper/vg_sys-lv_home

*** Test Cases ***
[1]CB010846_5G_A_02_eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK    CRT_25R2    CDRT_25R2  CRT_26R1
    [Setup]   SISO Coam Test Setup
    eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case    ru_index=${1}
    [Teardown]    SISO Coam Test Teardown

[1]CB010846_5G_C_01_RU_resiliency_to_BTS_DU_L1Soc_reset_on_line_activation
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK    CRT_25R2    CDRT_25R2  CRT_26R1
    [Setup]   SISO Coam Test Setup
    eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_on_line_activation
    [Teardown]    SISO Coam Test Teardown

[1]CB010846_5G_D_01_eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_uncontrolled_case
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK    CRT_25R2    CDRT_25R2  CRT_26R1
    [Setup]   SISO Coam Test Setup
    eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_uncontrolled_case    ru_index=${1}
    [Teardown]    SISO Coam Test Teardown

[1]CB010766-SR-A_06 Change RU deep sleep mode when time window is re-configured (AQQL)
    [Tags]     CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK    CRT_25R3    CRT_25R2    CRT_25R1  CRT_26R1
    [Setup]    SISO Coam Test Setup
    Change RU deep sleep mode when time window is re-configured
    [Teardown]    SISO Coam Test Teardown

[1]CB007511-5G-A_03 RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    [Tags]  1S-2CC-8D4U_AQQY_CNI-122115  CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL  CRT_UTE  CRT_TRUNK  CRT_25R3  CRT_25R2  CRT_25R1  CRT_26R1
    [Setup]    SISO Coam Test Setup
    RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_disable_5GC000431    LOOPS=${2}
    [Teardown]    SISO Coam Test Teardown

#### part-9: CB012195-SR - 2 TCs ###
[1]CB012195-SR-A-1a-06-General_SiSo_BB_sub-unit_reset_with_L3_call
    [Tags]    3S-2CC-16D8U_8Rx-4Rx_CB012195_1a    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_25R1
    [Setup]    SISO Coam Test Setup
    Baseband_module_reset_via_WEBUI    with_call=${True}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB012195-SR-A-1b-21-Manual_SiSo_SM_NR RAT reset
    [Tags]    3S-2CC-8D8U_8Rx-4Rx_CB012195_1b   CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL   CRT_UTE   CRT_25R1   CDRT_24R3
    [Setup]    Run Keywords       SISO Coam Test Setup    AND
    ...        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...                           Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...                           Test_PC_password=${Test_PC_password}
    ...                           btslog_path=${btslog_path}    btslog_launcher=${btslog_launcher}
    ...                           btslog_launcher_path=${btslog_launcher_path}

    ${fault_list}    Create List    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Manual_SiSo_SM_NR_RAT_reset    with_call=${True}

    [Teardown]    Run Keywords    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    ...    AND    Run Keyword And Ignore error    Check ERR Or WRN From Syslog
    ...                           sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...                           base_file=${Base_ERR_WRN_csv_path}
    ...                           Expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}    Delete_old_ERR_WRN=15
    ...                           Fail_Case=${False}    Clear_log=${True}
    ...                           FilesSystem=${FilesSystem}    Max_used_space_ratio=0.85
    ...    AND    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-10: CB012196-SR-A - 2 TCs ###
[1]CB012196-SR-A-17-General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Tags]  5S-1CC_CB012196-A_CB010713-A  CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL  CRT_UTE  CRT_25R3  CRT_25R2  CRT_26R1  CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    optical_switch.General_SiSo_SFP_lock_unlock_for_configuration_testing    is_optical_switch=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB012196-SR-A-04-General_SiSo_RAT_Block_Unblock_with_L3Call
    [Tags]  3S-1CC_CB012196-A_CB010713-B  CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL  CRT_UTE  CRT_25R3  CRT_25R2  CRT_26R1  CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    4614
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RAT_Block_Unblock    with_call=${True}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-11: CB005763 - 1 TCs - Reg for RU6-AKQJ in T760 ###
[1]CB005763_D_04_trigger_and_cancell_dying_gasp_alarm_on_eCPRI_with_RF_standalone
    [Tags]    6S-1CC_CB012196-A_CB010713-A    CRT_TRUNK  CRT_26R1
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Power_off_radio    ru_index=${6}
    check_fault_addition_information
    [Teardown]    Run keywords    Power_on_radio    ru_index=${6}     AND
    ...    Wait Until Keyword Succeeds    6min    30s    RU Should Be Online    ru_index=${6}    AND
    ...    add fault to allowed history fault list    faultId=${10}   AND
    ...    add fault to allowed history fault list    faultId=${4589}   AND
    ...    Run Keyword And Ignore Error   Connect to gnb coam via ssl    AND
    ...    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}    AND
    ...    SISO Coam Test Teardown

#### part-4: CB009487/CB009142 non-peak cases - 3*Made2 - 3 TCs ###
[1]CB009487_B_08_General_SiSo_SM_RF_Module_lock_unlock_Configuration_#5
    [Tags]    3S-1CC-16D8U_100M_CB009487-5    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_25R1
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${true}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB009142-SR-A-02-General_SiSo_Cell_block_and_unblock
    [Tags]    3S-2CC-8D8U_100M_CB009487-2    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${true}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}
    ...    AND    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB009142-SR-A-28-General_SiSo_RU_module_reset_from_GUI_full_ABIP
    [Tags]    3S-4CC-8D4U_50M_CB009487-3    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CDRT_24R3
    [Setup]    Run Keywords       SISO Coam Test Setup    AND
    ...        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...                           Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...                           Test_PC_password=${Test_PC_password}
    ...                           btslog_path=${btslog_path}    btslog_launcher=${btslog_launcher}
    ...                           btslog_launcher_path=${btslog_launcher_path}

    General_SiSo_RF_module_reset_from_GUI    with_call=${true}

    [Teardown]    Run Keywords    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    ...    AND    Run Keyword And Ignore error    Check ERR Or WRN From Syslog
    ...                           sys_logs_path=${UTE_syslogs_path}    UTE_logs_path=${UTE_logs_path}
    ...                           base_file=${Base_ERR_WRN_csv_path}
    ...                           Expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}    Delete_old_ERR_WRN=15
    ...                           Fail_Case=${False}    Clear_log=${True}
    ...                           FilesSystem=${FilesSystem}    Max_used_space_ratio=0.85
    ...    AND    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-5: CB010744 cases for cell with 8Rx IRC - 1 TCs ###
[1]CB010744-SR-E-04-General_SiSo_Cell_block_and_unblock
    [Tags]    3S-1CC-8D8U_100M_8Rx-IRC_CB010744-5    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_25R1
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${true}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}
    ...    AND    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#### part-8-1: CB010713-SR-D UC-D-1:CB010713 BB cell set B (NR TDD eCPRI)+CB009142 BB cell set A (NR TDD eCPRI) - 1 TCs ###
[1]CB010713-SR-D-03-Manual_SiSo_SM_RF_Module_lock_unlock
#    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true
    [Tags]    1S-1CC-8RxIRC_2S-4CC-4RxIRC_CB0010713-D_CB009142-A    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_25R1    CDRT_24R3
#    [Setup]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    param_list=${rd8DL8RxonHalfAbip}
#    ...    AND    SISO Coam Test Setup
#    ${radMasterValue}    CB008238_Common_KW.Get AaShell SW Config    rad_param=0x42008C
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
#    [Teardown]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${key_rd8DL8RxonHalfAbip}
#    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown

#### Optimized TCs
#### part-1: CB008325-5G-A non-peak cases - 1*Made2 - 1 TCs ###
#[1]CB008325-5G-A_30_General_SiSo_BB_sub-unit_reset_with_L3_call
#    [Tags]    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    Baseband_module_reset_via_WEBUI    with_call=${True}
#    [Teardown]    SISO Coam Test Teardown

### part-2: CB007511-5G-A non-peak cases - 1*Made2 - 2 TCs ###
#[1]CB007511-5G-A_01 RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
#    [Tags]    2S-2CC-8D4U    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled
#    [Teardown]    SISO Coam Test Teardown

##### part-3: CB009027-5G-K non-peak cases - 2*Made2 - 2 TCs ###
#[1]CB009027-5G-K_01_General_SiSo_Cell_block_and_unblock_with_5GC001086_enabled_4x8DL4UL_100M
#    [Tags]    2S-2CC-8D4U    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    ${fault_list}    Create List    49
#    Allowed Watchdog additional alarms    fault_list=${fault_list}
#    General_SiSo_Cell_block_and_unblock_with_5GC001086_enabled_4x8DL4UL_100M
#    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
#    ...    SISO Coam Test Teardown
#
#[1]CB009027-5G-K_05_Manual_SiSo_SM_RF_Module_lock_unlock_with_5GC001086_enabled_4x8DL4U_100M
#    [Tags]    2S-2CC-8D4U    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    Manual_SiSo_SM_RF_Module_lock_unlock_with_5GC001086_enabled_4x8DL4U_100M
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown

##### part-7: CB008990 'Improve detection and recovery for internal RU problems' (limit to 1CC for simplify scenario) - 2 TCs ###
#[1]CB008990-SR-01_Ecpri_RU_DFE_no_TX_Data_fault_activation
#    [Tags]    3S-1CC-16D8U_100M_CB009487-5    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    Ecpri_RU_DFE_no_TX_Data_fault_activation_Fault1904_AQQL
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008990-SR-01_Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation
#    [Tags]    3S-1CC-16D8U_100M_CB009487-5    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation_Fault1981_AQQL
#    [Teardown]    SISO Coam Test Teardown
#

#### part-8-2: CB010713-SR-C UC-C-2:CB010713 BB cell set B on half ABIP with 8Rx IRC (or 8Rx/4Rx mixed IRC) - 1 TCs ###
#[1]CB010713-SR-C-01-General_SiSo_Cell_block_and_unblock
#    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true active CB010713-C
#    [Tags]    3S-1CC-8D8U_100M_8Rx-4Rx-mixedIRC_CB010713-C    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    #General_SiSo_Cell_block_and_unblock    with_call=${True}
#    ${fault_list}    Create List    49
#    Allowed Watchdog additional alarms    fault_list=${fault_list}
#    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}
#    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
#    ...    SISO Coam Test Teardown
