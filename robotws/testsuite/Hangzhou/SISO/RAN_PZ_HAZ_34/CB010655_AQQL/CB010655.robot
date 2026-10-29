*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         2h

Resource    ./Resource/CB010655_Common_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB010655 in SBTS24R3 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
${btslog_path}    /tmp/btslog2
${btslog_launcher}    /opt/btslog/btslog_launcher
${btslog_launcher_path}    /opt/btslog/btslog
${Expected_ERR_WRN_deviation}    0.2
${FilesSystem}    /dev/vda2

*** Test Cases ***
[1]CB010655-A_parity_legacy_black_box_5_function_of_CB006622_CB007833
    [Tags]     CRT_TRUNK
    [Setup]    Run Keywords       SISO Coam Test Setup    AND
    ...        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...                           Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...                           Test_PC_password=${Test_PC_password}
    ...                           btslog_path=${btslog_path}     btslog_launcher=${btslog_launcher}
    ...                           btslog_launcher_path=${btslog_launcher_path}

    Check_RU_Black_Box_contents_in_snapshot_with_most_important_files

    [Teardown]    Run Keywords    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    ...    AND    Run Keyword And Ignore error     Check ERR Or WRN From Syslog
    ...                           sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...                           base_file=${Base_ERR_WRN_csv_path}
    ...                           Expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}      Delete_old_ERR_WRN=15
   ...                            Fail_Case=${False}       Clear_log=${True}
    ...                           FilesSystem=${FilesSystem}      Max_used_space_ratio=0.85
    ...    AND    SISO Coam Test Teardown

[1]CB010655-B_support_NVM_updating_for_controlled_radio_reset
    [Tags]     CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    support_NVM_updating_for_controlled_radio_reset
    [Teardown]    SISO Coam Test Teardown

[1]CB010655-C_01_support_fault_history
    [Tags]     CRT_TRUNK
    [Setup]    Run Keywords    SISO Coam Test Setup    AND
    ...        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...                        Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...                        Test_PC_password=${Test_PC_password}
    ...                        btslog_path=${btslog_path}      btslog_launcher=${btslog_launcher}
    ...                        btslog_launcher_path=${btslog_launcher_path}

    ${fault_list}    Create List    1904    2923
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    support_fault_history
    [Teardown]    Run Keywords    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    ...    AND    Run Keyword And Ignore error     Check ERR Or WRN From Syslog
    ...                           sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...                           base_file=${Base_ERR_WRN_csv_path}
    ...                           Expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}      Delete_old_ERR_WRN=15
   ...                            Fail_Case=${False}       Clear_log=${True}
    ...                           FilesSystem=${FilesSystem}      Max_used_space_ratio=0.85
    ...    AND    SISO Coam Test Teardown

