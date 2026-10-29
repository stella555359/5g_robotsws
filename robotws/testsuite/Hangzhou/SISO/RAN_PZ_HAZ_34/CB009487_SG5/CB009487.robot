*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         180 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
#Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
#Resource             ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
#Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009487 in SBTS23R4 LL program with configuration block 24R1_N_CB009487_5
...    Feature CB009142 in SBTS24R1 program with configuration block 24R1_N_CB009487_2 and 24R1_N_CB009487_3

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
${btslog_path}    /tmp/btslog2
${btslog_launcher}    /opt/btslog/btslog_launcher
${btslog_launcher_path}    /opt/btslog/btslog
${Expected_ERR_WRN_deviation}    0.2
${FilesSystem}    /dev/vda2

*** Test Cases ***
# [1]CB009487_B_08_General_SiSo_SM_RF_Module_lock_unlock_Configuration_#5
#     [Tags]    3S-1CC-16D8U_100M_CB009487-5    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
#     [Teardown]    SISO Coam Test Teardown
#
# [1]CB009142-SR-A-02-General_SiSo_Cell_block_and_unblock
#     [Tags]    3S-2CC-8D8U_100M_CB009487-2    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Cell_block_and_unblock    with_call=${False}
#     [Teardown]    SISO Coam Test Teardown

[1]CB009142-SR-A-28-General_SiSo_RU_module_reset_from_GUI_full_ABIP
    [Tags]    3S-4CC-8D4U_50M_CB009487-3    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CDRT_UTE    CRT_TRUNK    CRT_24R2
    [Setup]    Run Keywords       SISO Coam Test Setup    AND
    ...        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...                           Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...                           Test_PC_password=${Test_PC_password}
    ...                           btslog_path=${btslog_path}    btslog_launcher=${btslog_launcher}
    ...                           btslog_launcher_path=${btslog_launcher_path}

    General_SiSo_RF_module_reset_from_GUI    with_call=${true}

    [Teardown]    Run Keywords    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    ...    AND    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog
    ...                           sys_logs_path=${UTE_syslogs_path}    UTE_logs_path=${UTE_logs_path}
    ...                           base_file=${Base_ERR_WRN_csv_path}
    ...                           Expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}    Delete_old_ERR_WRN=15
    ...                           Fail_Case=${False}    Clear_log=${True}
    ...                           FilesSystem=${FilesSystem}    Max_used_space_ratio=0.85
    ...    AND    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
