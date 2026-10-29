*** Settings ***
Documentation
...    Author: Shuangfeng.f.sun
...    Contact: shuangfeng.f.sun@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For RRM

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Test Cases ***
CB006139_CA_02
    [Tags]    NFTA    CB006139_CA_02
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Initialize PA Signal
    Set Initialize PA Value    pa_port=8,12,18,2,6,31;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start big data DL Call For UE    ue_index=${0}    ue_type=qualcomm
#    [Teardown]    Case Postcondition

CB006139_CA_03
    [Tags]    NFTA    CB006139_CA_03
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Initialize PA Signal
    Set Initialize PA Value    pa_port=8,12,18,2,6,31;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start big data DL Call For UE    ue_index=${0}    ue_type=qualcomm
#    [Teardown]    Case Postcondition

CB006139_CA_07
    [Tags]    NFTA    CB006139_CA_07
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Initialize PA Signal
    Set Initialize PA Value    pa_port=8,12,18,2,6,31;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start big data DL Call For UE    ue_index=${0}    ue_type=qualcomm
#    [Teardown]    Case Postcondition

CB006139_CA_09
    [Tags]    NFTA    CB006139_CA_09
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Initialize PA Signal
    Set Initialize PA Value    pa_port=8,12,18,2,6,31;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start big data DL Call For UE    ue_index=${0}    ue_type=qualcomm
#    [Teardown]    Case Postcondition

CB006139_CA_10
    [Tags]    NFTA    CB006139_CA_10
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Initialize PA Signal
    Set Initialize PA Value    pa_port=8,12,18,2,6,31;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start big data DL Call For UE    ue_index=${0}    ue_type=qualcomm
#    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM
    Run Keyword And Ignore Error    Get Iperf Info
#    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False

Common Test Setup For RRM
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Common Suite Setup For RRM
    _Create Suite Directory

Case Postcondition
    [Arguments]    ${ue_index}=${0}
    Log To Console    ${ue_index}
    log to console    Case Postcondition

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Start big data DL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    ...            ${RemoteHost}=10.108.237.194    ${Account}=ute    ${Password}=Ut3pa5s#ff97
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
    ...              throughput=2000M    duration=${600}    RemoteHost=${RemoteHost}
    ...              Account=${Account}     Password=${Password}

Initialize PA Signal
    SetInitializePAValue    pa_port=1-32;    pa_value=120;

Modify PA Signal For Source
    ${source_pa_port_list}     Create List     9
    ${source_pa_value_list}    Create List     127    0
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${10}

Modify PA Signal For Source And Target
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     127    20
    ${target_pa_port_list}     Create List    5    6    9
    ${target_pa_value_list}    Create List    0    127
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}



