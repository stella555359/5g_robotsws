*** Settings ***
Documentation     author: Dong Tingting
...               contact: tingting.dong@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${base_path}/5G_Setup_And_Teardown.robot
Resource    ${base_path}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${base_path}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${base_path}/General_SiSo_RF_module_power_reset.robot
Resource    ${base_path}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${base_path}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${base_path}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource          Resources/L3call_keywords.robot
Force Tags    5G_RAN    5G_RAN_TDD    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AQQN    STATE_SW_UPLOADED    PY39
Library            string_to_list.py
*** Variables ***
@{GNB_PS_CELL_INDEX_LIST}    1
# ${if_commissioning}   False
${scf_1sector}    SCF_SBTS00.xml
${base_path}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G

*** Keywords ***

5GC000399_eCPRI_Carier_activation
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify carrier configuration and activation using eLLF RU over RP1
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.3.2023 - - Created
    ...    *******************
    ...    Owner_qi.du@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        ${PC_soap_path}    Download soap Log from RU    log_path=${SAVE LOG DIRECTORY}    ru_alias=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        check carier activation by soapmsg parvaluechangeind    PC_soap_path=${PC_soap_path}
    END
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]  csn.Disconnect  connection=ASIK Master

Download soap Log from RU
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
    ${file_list_temp}    csn.execute    command=ls /ram/*/UnitOAM_SOAP_Startup_LBTS_OM*    connection=${ru_alias}
#    @{files_list}=    get_list_of_soap    ${file_list_temp}
    @{files_list}=    Split To Lines    ${file_list_temp}
    ${pattern}   Set Variable    (/ram/UnitOAM_SOAP_Startup_LBTS_OM_L1214009319_Log/.*)(\.xml)(.*)
    ${pattern_1}   Set Variable    /ram/UnitOAM_SOAP_Startup_LBTS_OM_L1214009319_Log/(.*)(\.xml)(.*)
    ${local_path_list}=    Create List
    FOR   ${file_name_temp}    IN    @{files_list}

        ${is_zip}    Run Keyword And Return Status     should contain    ${file_name_temp}    .gz
        Run Keyword If    ${is_zip}
        ...    Run Keyword    csn.execute    command=sudo gzip -d ${file_name_temp}    connection=${ru_alias}
        @{file_name_list0}    Get Regexp Matches     ${file_name_temp}    ${pattern}    1
        ${file_name}       Set Variable        ${file_name_list0}[0]

        @{file_name_local_list0}    Get Regexp Matches     ${file_name_temp}    ${pattern_1}    1
        ${file_name_local}       Set Variable        ${file_name_local_list0}[0]
        csn.Download File    remote_path=${file_name}.xml    local_path=${log_path}${file_name_local}.xml   connection=${ru_alias}
        ${local_path}    set variable    ${log_path}${file_name_local}.xml
        Append To List    ${local_path_list}    ${local_path}
    END
    [Return]    ${local_path_list}

check carier activation by soapmsg parvaluechangeind
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    [Arguments]    ${PC_soap_path}=${PC_soap_path}
    FOR    ${file_name}    IN    @{PC_soap_path}
        ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${file_name}    class_value=LowLevelTxEndpoints
        ...     parameterName=subscribe    newValue=TRUE
        Exit For Loop If     ${status}==True
    END
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}

    FOR    ${file_name}    IN    @{PC_soap_path}
        ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${file_name}    class_value=LowLevelRxEndpoints
        ...     parameterName=subscribe    newValue=TRUE
        Exit For Loop If     ${status}==True
    END
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}

    FOR    ${file_name}    IN    @{PC_soap_path}
        ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${file_name}    class_value=LowLevelTxLinks
        ...     parameterName=subscribe    newValue=TRUE
        Exit For Loop If     ${status}==True
    END
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}

    FOR    ${file_name}    IN    @{PC_soap_path}
        ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${file_name}    class_value=LowLevelRxLinks
        ...     parameterName=subscribe    newValue=TRUE
        Exit For Loop If     ${status}==True
    END
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}

    FOR    ${file_name}    IN    @{PC_soap_path}
        ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${file_name}    class_value=TxArrayCarrier
        ...     parameterName=active    newValue=TRUE
        Exit For Loop If     ${status}==True
    END
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}

    FOR    ${file_name}    IN    @{PC_soap_path}
        ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${file_name}    class_value=RxArrayCarrier
        ...     parameterName=active    newValue=TRUE
        Exit For Loop If     ${status}==True
    END
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}

5GC000399_eCPRI_Basic_configuration_over_RP1
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify carrier configuration and activation using eLLF RU over RP1
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.9.2020 - - Created
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        ${PC_soap_path}    Download soap Log from RU    log_path=${SAVE LOG DIRECTORY}    ru_alias=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        check basic configuration by soapmsg parvaluechangeind    PC_soap_path=${PC_soap_path}
    END
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]  csn.Disconnect  connection=ASIK Master

check basic configuration by soapmsg parvaluechangeind
    [Documentation]    Author: jianhua.li@nokia-sbell.com
    [Arguments]    ${PC_soap_path}=${PC_soap_path}
    FOR    ${file_name}    IN    @{PC_soap_path}
        ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${file_name}    class_value=FaultManagement
        ...     parameterName=subscribe    newValue=TRUE
        Exit For Loop If     ${status}==True
    END
    should be true    ${status}
        
*** Test Cases ***
[1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Teardown]    SISO Coam Test Teardown

[1][2.0] General_SiSo_BTS_startup_with_RF_delayed_startup
    [Documentation]     check the RU connection, detection and configuration to the BTS in a reliable time.
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    General_SiSo_BTS_startup_with_RF_delayed_startup
    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
    [Teardown]    SISO Coam Test Teardown

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_OTA
    [Documentation]
    ...    The purpose of this test is to verify L3 call.
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
	Set_PA_Value    value=${10}    attenuator_index=${0}
    Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=300M  protocol=udp  traffic_duration=900
        ...    ul_tp_target=35  dl_tp_target=150  check_duration=5m
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown

[2][1.0] General_SiSo_RF_module_power_reset
    [Documentation]    General_SiSo_RF_module_power_reset
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_power_reset
    [Teardown]    SISO Coam Test Teardown

[1][1.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_block_and_unblock    with_call=${False}
	Set_PA_Value    value=${10}    attenuator_index=${0}
    Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=300M  protocol=udp  traffic_duration=900
        ...    ul_tp_target=35  dl_tp_target=150  check_duration=5m
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown

[1][2.0] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown

[2][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Teardown]    SISO Coam Test Teardown

[1][1.0] 5GC000399_eCPRI_Carrier_activation
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    Commissioning SCF And Check On Air    scf_path=${SCF_Path}
    5GC000399_eCPRI_Carier_activation
    [Teardown]    SISO Coam Test Teardown

[1]5GC000399_eCPRI_Basic_configuration_over_RP1
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    Commissioning SCF And Check On Air    scf_path=${SCF_Path}
    5GC000399_eCPRI_Basic_configuration_over_RP1
    [Teardown]    SISO Coam Test Teardown
