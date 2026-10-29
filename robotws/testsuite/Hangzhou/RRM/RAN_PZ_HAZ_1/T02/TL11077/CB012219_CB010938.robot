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
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot




*** Test Cases ***
CB012219_01_CB010938_CM_verification
    [Tags]    NFTA    CB012219_01
    [Documentation]
    ...    Author: xxxxxx@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_CB010938
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    [Teardown]    Case Postcondition

CB012219_02_CB010938_PM_visibility_verification
    [Tags]    NFTA    CB012219_02
    [Documentation]
    ...    Author: xxxxxx@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Start Counter For CB012219
    Parameter Updated In vDU For CB012219_CB010938
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    Start Counter For CB012219_02_False
    Parameter Updated In vDU For CB012219_CB010938 With False
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

CB012219_03_CB010938_Chipset_and_RAN_Identification_exchange_during_UE_registration
    [Tags]    CRT    CB012219_03
    [Documentation]
    ...    Author: xxxxxx@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In vDU For CB012219_CB010938
    Start Counter For CB012219
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${0}
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition


*** Keywords ***
Parameter Updated In vDU For CB012219_CB010938
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu

Parameter Updated In vDU For CB012219_CB010938 With False
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu

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

Start Counter For CB012219
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C00025;M55124C00026;
    ...         Counter rule: max(M55124C00025)>0;max(M55124C00026)>0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0


Start Counter For CB012219_02_False
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C00027;M55124C00028;
    ...         Counter rule: max(M55124C00027)>0;max(M55124C00028)>0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0


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