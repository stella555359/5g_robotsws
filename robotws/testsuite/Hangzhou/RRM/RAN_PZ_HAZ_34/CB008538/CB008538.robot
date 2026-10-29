*** Settings ***
Documentation
...   author: Qian Jianwu
...   contact: jianwu.qian@nokia-sbell.com
...   squad group: 5G_PZ_MMW_HZ_3_SG
...   Feature CB008538

Resource    ./Resources/common_keyword.robot
Force Tags    5G_RRM

Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Test Setup     Run Keywords    Common Case Setup For 8538    AND    robot_common_operations.Common Case Setup
Test Teardown    Run Keywords    Common Case Teardown For 8538    AND    robot_common_operations.Common Case Teardown

*** Variables ***

*** Test Cases ***
CB008538-5G_01_RU_Reset_Startup_Time_WebEM_Ru_Reset_Puslar
    [Documentation]
    ...    The purpose of this test case is to verify traffic is success with required configuration.
    [Tags]    CRT_TRUNK
    [Setup]
    Start Capture Syslog
    Selenium Login With Version
    Perform RU Reset via WebEM
    ${time}    Get RU Startup Time From Syslog
	should be true    ${time}<300
    run keyword and ignore error    Stop Capture Syslog
    [Teardown]

CB008538-5G_02_RU_Reset_Startup_Time_Power_Reset_On_Puslar
    [Documentation]
    ...    The purpose of this test case is to verify traffic is success with required configuration.
    [Tags]    CRT_TRUNK
    [Setup]
    Start Capture Syslog
    ${RU_Power_off_time}    Get RU Current Time From Terminal
    Perform RU Power Off    ru_index=1      model=hbte
    sleep    30s
    Perform RU Power On    ru_index=1      model=hbte
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    20min    1min    COAM Check GNB cell on air
    ${RU_active_time}    Get RU Active Time From Syslog
    ${RU_startup_time}    evaluate    ${RU_active_time}-${RU_Power_off_time}-30
	should be true    ${RU_startup_time}<300
    run keyword and ignore error    Stop Capture Syslog
    [Teardown]

CB008538-5G_03_RU_Reset_Startup_Time_WebEM_Site_Reset_Puslar
    [Documentation]
    ...    The purpose of this test case is to verify traffic is success with required configuration.
    [Tags]    CRT_TRUNK
    Start Capture Syslog
    Perform BTS Site Reset
    Wait Until Keyword Succeeds    20min    1min    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    20min    1min    COAM Check GNB cell on air
    ${time}    Get RU Startup Time From Syslog
	should be true    ${time}<300
    run keyword and ignore error    Stop Capture Syslog

CB008538-5G_04_RU_Reset_Startup_Time_WebEM_CM_Plan_Activation__Puslar
    [Documentation]
    ...    The purpose of this test case is to verify traffic is success with required configuration.
    [Tags]    CRT_TRUNK
    [Setup]
    Start Capture Syslog
    Scf Commition And Wair For On-air    scf_name=${scf_path}/${8T8R_scf_name}
    ${time}    Get RU Startup Time From Syslog        system_reset=${True}
	should be true    ${time}<300
    run keyword and ignore error    Stop Capture Syslog
    [Teardown]
