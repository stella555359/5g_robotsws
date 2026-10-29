*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
#Resource      ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012195-SR in SBTS24R3 program
...    Config: 24R3_N_CB012195_1a; 3S-2CC; up to 100MHz; up to 16DL8UL; mix 8Rx-4Rx IRC; up to 3*25 Gbps eCPRI links per radio
...            24R3_N_CB012195_1b; 3S-2CC; up to 100MHz; up to 8DL8UL; mix 8Rx-4Rx IRC; up to 2*25 Gbps eCPRI links per radio

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
${btslog_path}    /tmp/btslog2
${btslog_launcher}    /opt/btslog/btslog_launcher
${btslog_launcher_path}    /opt/btslog/btslog
${Expected_ERR_WRN_deviation}    0.2
${FilesSystem}    /dev/vda2

*** Test Cases ***
# [1]CB012195-SR-A-1a-06-General_SiSo_BB_sub-unit_reset_with_L3_call
#     [Tags]    3S-2CC-16D8U_8Rx-4Rx_CB012195_1a   CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Baseband_module_reset_via_WEBUI    with_call=${True}
#     [Teardown]    SISO Coam Test Teardown

[1]CB012195-SR-A-1b-21-Manual_SiSo_SM_NR RAT reset
    [Tags]     3S-2CC-8D8U_8Rx-4Rx_CB012195_1b    CRT_UTE    CRT_TRUNK
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
