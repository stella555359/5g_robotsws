*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
#Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         120 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     ../../common/siso_resource.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006277 in 5G22R1 program

Force Tags    RAN_5G_TDD    PY310

*** Test Cases ***
[1]CB006277-EE_01_PTP_Failure_configuration_with_PTP_only
    [Tags]    master_classicalbts_all    CIT_TRUNK   CRT_22R3   CRT_22R2    CDRT_22R1    CIT_22R4
    [Setup]    SISO Coam Test Setup
    #${sync_old}    get sync info of GNB
    #set suite variable    ${sync_old}
    # ${fault_16}    Create Dictionary    faultId=${16}
    # ${fault_4298}    Create Dictionary    faultId=${4298}
    # ${fault_1899}    Create Dictionary    faultId=${1899}
    # ${fault_4405}    Create Dictionary    faultId=${4405}
    # ${fault_4452}    Create Dictionary    faultId=${4452}
    # ${fault_7300}    Create Dictionary    faultId=${7300}
    # Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_16}
    # Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_4298}
    # Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_1899}
    # Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_4405}
    # Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_4452}
    # Run Keyword If    '${gNb_CuType}'=='NSA'    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_7300}
    # Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    Selenium Login And Disable Screen Lock
    selenium_coam.set_parameter_value
    ...    abbr=syncInputType
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    filter_param=Sync input type
    ...    new_value=2.048MHz input
    sleep    1s
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    Selenium Logout And Close Browser
    log to console  \n Wait For Fault 16 Present
    Wait For Expect Fault Present    faultId=${16}    timeout=1800
    log to console  \n Wait For Fault 4298 Present
    Wait For Expect Fault Present    faultId=${4298}    timeout=1800
    run keyword and ignore error     Wait For Expect Fault Present    faultId=${1899}    timeout=1800
    #check sync info of RU    status='abnormal'
    Selenium Login And Disable Screen Lock
    selenium_coam.set_parameter_value
    ...    abbr=syncInputType
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    filter_param=Sync input type
    ...    new_value=1pps/ToD from external GNSS receiver
    sleep    1s
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    Selenium Logout And Close Browser
    log to console  \n Wait For Fault 16 Disappear
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    log to console  \n Wait For Fault 4298 Disappear
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
    run keyword and ignore error     Wait For Expect Fault To Disappear    faultId=${1899}    timeout=1200
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]    Run Keywords    Customized Allowed Faults    AND    SISO Coam Test Teardown     is_check_historyalarm=${True}

*** Keywords ***
Customized Allowed Faults
    [Documentation]    Customized Alarms against specific test case.
    ${fault_16}    Create Dictionary    faultId=${16}
    ${fault_4298}    Create Dictionary    faultId=${4298}
    ${fault_1899}    Create Dictionary    faultId=${1899}
    ${fault_4405}    Create Dictionary    faultId=${4405}
    ${fault_4452}    Create Dictionary    faultId=${4452}
    ${fault_7300}    Create Dictionary    faultId=${7300}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_16}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_4298}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_1899}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_4405}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_4452}
    Run Keyword If    '${gNb_CuType}'=='NSA'    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_7300}
    Set Test Variable    ${ALLOWED_HISTORY_FAULT}
