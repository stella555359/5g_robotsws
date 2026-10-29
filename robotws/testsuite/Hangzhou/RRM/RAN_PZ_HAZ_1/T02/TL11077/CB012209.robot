*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot





*** Test Cases ***
CB012209_05_Verification_of_IWK_with_CB010217
    [Tags]    CRT    CB012209    TC05
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Start Counter For 12209_05
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition



CB013289-PMO#2_TC27_Counter_update_for_the_successful_Inter-RAT_handover_with_indirect_data_forwarding
    [Tags]    CRT    CB013289    TC27
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Start Counter For 12209_05
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition


CB015045_A_SR_10_B3_EPS_fallback_during_PDU_Session_Modify
    [Tags]    CRT    CB015045    TC10
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Start Counter For 12209_05
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition


CB015045_A_SR_14_B4_Online_modification_of_Feature_Activation_Flag
    [Tags]    CRT    CB015045    TC14
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Start Counter For 12209_05
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition


CB015045_A_SR_07_B2_EPS_fallback_during_PDU_Session_Setup
    [Tags]    CRT    CB015045    TC07
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Start Counter For 12209_05
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition


CB015045_A_SR_04_B1_EPS_fallback_during_Initial_Context_Setup
    [Tags]    CRT    CB015045    TC04
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Start Counter For 12209_05
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition




*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM
    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False

Common Test Setup For RRM
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Common Suite Setup For RRM
    _Create Suite Directory


Case Postcondition
    log to console    Case Postcondition
    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False
#    Common Test Teardown For RRM


Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Start Counter For 12209_05
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C00025;
    ...         Counter rule: max(M55124C00025)>0;
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C00026;
    ...         Counter rule:max(M55124C00026)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Start Counter    rule_list=${rule_list}    product_type=gnb    bts_index=0

