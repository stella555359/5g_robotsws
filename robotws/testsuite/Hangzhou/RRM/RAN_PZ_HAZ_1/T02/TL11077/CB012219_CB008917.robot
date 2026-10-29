*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot




*** Test Cases ***
CB012219_18_CB008917_Activate specific BWP on FDD with PRB pooling - PRB45 - pdschRat0RbgConfig = config2
    [Tags]    CRT    CB012219_18
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Start Counter For CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    Modify PA Signal
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

CB012219_13_CB008917_bwpDN PDL validation check with CB008917
    [Tags]    NFTA    CB012219_13
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Start Counter For CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    Modify PA Signal
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

CB012219_14_CB008917_reqMinNumPuschPrb PDL validation check with specialbwp
    [Tags]    NFTA    CB012219_14
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Start Counter For CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    Modify PA Signal
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

CB012219_16_CB008917_cell setup with configure Dedicated BWP 45 PRB is configured in N5 FDD 10MHz for DoCoMo
    [Tags]    NFTA    CB012219_16
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Start Counter For CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    Modify PA Signal
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

CB012219_20_CB008917_Robustness_Verify that the performance KPI & PM update is abnormal after CB008917 is activated
    [Tags]    NFTA    CB012219_20
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Start Counter For CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    Modify PA Signal
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

CB012219_30_CB008917_Multiple_UE_support_in_NSA_mode_for_DoCoMo_FDD_specific_configuration
    [Tags]    NFTA    CB012219_30
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    [Teardown]    Case Postcondition

CB012219_31_CB008917_Multiple_UE_support_in_SA_mode_for_DoCoMo_FDD_specific_configuration
    [Tags]    NFTA    CB012219_31
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    [Teardown]    Case Postcondition

CB012219_32_CB008917_Multiple_UE_support_in_NSA_mode_for_DoCoMo_TDD_specific_configuration
    [Tags]    NFTA    CB012219_32
    [Documentation]
    ...    Author: XXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_18_CB008917
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    Prepare And Attach UE    ue_index=${1}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Run Keyword And Ignore Error    common_resource_new.Detach UE    ue_index=${0}
    Run Keyword And Ignore Error    common_resource_new.Detach UE    ue_index=${1}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Parameter Updated In vDU For CB012219_18_CB008917
    @{para_list}          Create List    actSpecificBwpSize
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu

Start Counter For CB008917
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55125C09014;
    ...         Counter rule: max(M55125C09014)>0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0

Modify PA Signal
    ${source_pa_port_list}     Create List     1    18
    ${source_pa_value_list}    Create List     0    40
    ${target_pa_port_list}     Create List    37    54
    ${target_pa_value_list}    Create List    63    30
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Check Wireshark Log
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    UEContextReleaseCommand
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END