*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    this file is for p&c testing.

Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Library           ../../Resources/Common/python/fading.py    WITH NAME    fading

*** Variables ***
&{dcap_info}    host=10.56.221.45    port=443    username=utfuser    password=utfadmin!
@{tti_condition_1}    physCellId    ==    117
@{basic_rules}    or    ${tti_condition_1}
&{tti_check_rules_1}         basic_rules=${basic_rules}
&{tti_analysis_dict_1}       check_rules=${tti_check_rules_1}

*** Test Cases ***
Fading And Spark With DL
    [Tags]        case1
    [Setup]        Case Precondition
    Modify Channel Smulate Parameters    sceneid=0    type=1    steplimit=80
    ...                                  Timeout=3000    loopcnt=1    loopmode=0
    Connect All UEs For Spark
    Attach Single UE For Spark    ue_index=0
    Start Traffic For Spark    ue_index=0    direction=dl
    Stop Traffic For Spark    ue_index=0    direction=dl
    [Teardown]        Case Postcondition For Spark

Fading And Spark With UL
    [Tags]        case2
    [Setup]        Case Precondition
    Modify Channel Smulate Parameters
    Connect All UEs For Spark
    Attach Single UE For Spark    ue_index=0
    Start Traffic For Spark    ue_index=0    direction=ul
    Stop Traffic For Spark    ue_index=0    direction=ul
    [Teardown]        Case Postcondition For Spark    ue_index=0

Get All Logs
    [Tags]        case3
    [Setup]        Case Precondition
    ${local_file_path}    Log Collection    start    syslog    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console        \nSyslog log of VCU: ${local_file_path}
    ${local_file_path}    Log Collection    start    snapshot    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSnapshot of VCU: ${local_file_path}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    sleep    2s    reason=Waiting For TTI capture
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}

Fading And Spark With VONR
    [Tags]        case4
    [Setup]        Case Precondition
    Modify Channel Smulate Parameters
    Connect All UEs For Spark
    Attach Single UE For Spark    ue_index=0
    Start VONR For Spark    ue_index=0
    Start VONR For Spark    ue_index=1
    Stop VONR For Spark    ue_index=0
    Stop VONR For Spark    ue_index=1
    [Teardown]        Case Postcondition For Spark

Fading And Dingli With DL
    [Tags]        case5
    [Setup]        Case Precondition
    Modify Channel Smulate Parameters
    Prepare UE For Dingli
    Start Log For Dingli
    Attach Single UE For Dingli    ue_index=0
    Start DL Traffic For Dingli     ue_index=0
    Stop DL Traffic For Dingli     ue_index=0
    [Teardown]        Case Postcondition For Dingli

Fading And Dingli With UL
    [Tags]        case6
    [Setup]        Case Precondition
    Modify Channel Smulate Parameters
    Prepare UE For Dingli
    Start Log For Dingli
    Attach Single UE For Dingli    ue_index=0
    Start UL Traffic For Dingli    ue_index=0
    Stop UL Traffic For Dingli     ue_index=0
    [Teardown]        Case Postcondition For Dingli

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Common Test Setup For AIC
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Common Suite Setup For AIC
    _Create Suite Directory

Case Postcondition For Spark
    [Arguments]    ${ue_index}=${0}
    log to console    Case Postcondition
    Detach UE For Spark    ue_index=${ue_index}
    Disconnect All UEs For Spark

Case Postcondition For Dingli
    [Arguments]    ${ue_index}=${0}
    log to console    Case Postcondition
    Detach single UE For Dingli   ue_index=${ue_index}
    client.teardown_service    service=pioneer

Modify Channel Smulate Parameters
    [Arguments]    ${sceneid}=0    ${type}=1    ${steplimit}=80    ${Timeout}=3000    ${loopcnt}=1    ${loopmode}=0
    fading.connect    ip=10.68.254.12     user=Administrator    password=ksw123
    fading.setup
    fading.get_smulate_parameters    sceneid=${sceneid}
    fading.set_smulate_parameters    sceneid=${sceneid}    type=${type}    steplimit=${steplimit}
    ...                              Timeout=${Timeout}    loopcnt=${loopcnt}    loopmode=${loopmode}
    fading.get_smulate_parameters    sceneid=${sceneid}