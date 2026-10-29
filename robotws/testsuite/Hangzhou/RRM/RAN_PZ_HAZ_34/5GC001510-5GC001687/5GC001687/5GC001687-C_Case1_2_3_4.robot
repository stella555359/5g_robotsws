*** Settings ***
Documentation    Suite description
...    author: y63li
...    contact: ying.15.li@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : 5GC001687-C

Force Tags          CIT_TRUNK    CRT_22R2
...    PY36
Suite Setup          Run Keywords
...      Run Keyword And Ignore Error       5GC001687_Common Suite Setup for COAM
...      AND      Run Keyword And Ignore error
...      Adjust One HBTE ATT Value      PA_Info=${Block_TL926_PA}    PA_IP=${att_ipaddr}
...      HBTE_max_value=${127}
...      model=PA-16-16-6-127-0.5-B-S
Suite Teardown      Run Keyword    5GC001687_Common Suite Teardown for COAM
Test Timeout      270 minutes

Library     OperatingSystem
Library     XML   use_lxml=True    WITH NAME    myxml
Library     taf.config.scf    WITH NAME    scf
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010636/Resources/CB010636_CDE.robot
Resource    Resources/5GC001687-C_Common_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${Test_PC_IP}             ${tl.test_pc[0].default_ssh_connection_details.addr}
${Test_PC_username}       ${tl.test_pc[0].default_ssh_connection_details.username}
${Test_PC_password}       ${tl.test_pc[0].default_ssh_connection_details.password}
*** Test Cases ***
[1]5GC001687-C_001_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call_20M_1070_C2
    [Documentation]    This test case is used to check that 5G L3 Call on 20M 1070 C2
    [Tags]    HAZ3_T03
    [Setup]     5GC001687-C_Common_Keywords.case set up
    Run Keyword And Ignore error    Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    Run Keyword And Continue On Failure       L3_Call_20M_1070_C2
    Run Keyword And Ignore error     Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=1
    ...      Clear_log=True
    ...      Max_used_space_ratio=0.85
    [Teardown]      Run Keywords
    ...      Run Keyword And Ignore Error     Tests Recover for NSA
    ...      AND      Run Keyword And Ignore Error     CI_interface.Common Case Teardown

#[1]5GC001687-C_002_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call_80M_1070_B4
#    [Documentation]    This test case is used to check that 5G L3 Call on 80M 1070 B4
#    [Setup]        case set up
#    L3_Call_80M_1070_B4
#    [Teardown]      Run Keyword And Ignore Error     Tests Recover for NSA

#[1]5GC001687-C_003_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call_20M_1116_C2
#    [Documentation]    This test case is used to check that 5G L3 Call on 20M 1116 C2
#    [Setup]case set up
#    L3_Call_20M_1116_C2
#   [Teardown]      Run Keyword And Ignore Error     Tests Recover for NSA

[1]5GC001687-C_004_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call_80M_1116_B4
    [Documentation]    This test case is used to check that 5G L3 Call on 80M 1116 B4
    [Tags]    HAZ3_T03
    [Setup]     5GC001687-C_Common_Keywords.case set up
    Run Keyword And Ignore error    Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    Run Keyword And Continue On Failure       L3_Call_80M_1116_B4
    Run Keyword And Ignore error     Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=1
    ...      Clear_log=True
    ...      Max_used_space_ratio=0.85
    [Teardown]      Run Keywords
    ...      Run Keyword And Ignore Error     Tests Recover for NSA
    ...      AND      Run Keyword And Ignore Error     CI_interface.Common Case Teardown

