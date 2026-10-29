*** Settings ***
Documentation     author: y63li
...               contact: ying.15.li@nokia-sbell.com
...               squad group: MMW_SG3

Suite Setup       Run Keywords       Run Keyword And Continue On Failure
...      CNI98930_Common Suite Setup for COAM
...      AND      Run Keyword And Ignore error
...      Adjust One HBTE ATT Value      PA_Info=${Block_TL926_PA}  PA_IP=${att_ipaddr}     HBTE_max_value=${127}
...      model=PA-16-16-6-127-0.5-B-S
Suite Teardown    Run Keyword     CNI98930_Common Suite Teardown for COAM

Resource       Resources/CNI-98930_Common_Keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
*** Variables ***
${Test_PC_IP}             ${tl.test_pc[0].default_ssh_connection_details.addr}
${Test_PC_username}       ${tl.test_pc[0].default_ssh_connection_details.username}
${Test_PC_password}       ${tl.test_pc[0].default_ssh_connection_details.password}

*** Test Cases ***
[1]CNI-98930_01_Enable_and_Disable_of_PRACH_format0_116_0ms_Prachconfig_9_14
    [Tags]    HAZ3_T03
    [Documentation]    This test case is used to test GNB’s supporting of the enable and disable of PRACH format 0 per cell
    [Setup]    CNI-98930_Common_Keywords.Case Setup
    Run Keyword And Ignore error    Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    Run Keyword And Continue On Failure      PRACH_format0_1116_0ms_PrachConfig_9_14
    Run Keyword And Ignore error     Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=1
    ...      Clear_log=True
    ...      Max_used_space_ratio=0.85
    [Teardown]     CNI-98930_Common_Keywords.Case Teardown

[1]CNI-98930_02_Enable_and_Disable_of_PRACH_format0_1116_3ms_PrachConfig_3_4_5_6_7_12
    [Documentation]    This test case is used to test GNB’s supporting of the enable and disable of PRACH format 0 per cell
    [Setup]     CNI-98930_Common_Keywords.Case Setup
    PRACH_format0_1116_3ms_PrachConfig_3_4_5_6_7_12
    [Teardown]    CNI-98930_Common_Keywords.Case Teardown

[1]CNI-98930_05_Enable_and_Disable_of_PRACH_format0_1070_PrachConfig_1_Two_SSB
    [Documentation]    This test case is used to test GNB’s supporting of the enable and disable of PRACH format 0 per cell
    [Setup]     CNI-98930_Common_Keywords.Case Setup
    PRACH_format0_1070_PrachConfig_0
    [Teardown]    CNI-98930_Common_Keywords.Case Teardown

[1]CNI-98930_10_Enable_and_Disable_of_PRACH_format0_1116_0ms_PrachConfig_9_14
    [Documentation]   This test case is used to PRACH PM counters are increased correctly.
    [Setup]     CNI-98930_Common_Keywords.Case Setup
    PRACH_format0_1116_0ms_PrachConfig_9_14_PMCounter
    [Teardown]    CNI-98930_Common_Keywords.Case Teardown
