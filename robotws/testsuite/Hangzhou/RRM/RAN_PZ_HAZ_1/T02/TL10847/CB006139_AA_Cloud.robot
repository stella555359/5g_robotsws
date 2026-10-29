*** Settings ***
Documentation
...    Author: shuangfeng.f.sun@nokia-sbell.com
...    Contact: shuangfeng.f.sun@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
#Resource          ../../Resources/Common/AIC_UE.robot



*** Test Cases ***
CB006139_AA_01_Common _Preconditions_Verification_on_webEM
    [Tags]    AA_01    case1
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In Gnb For CB006139_Deactive
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    [Teardown]    Case Postcondition

CB006139_AA_02_Buffer-based_step-wise_NR_FR1_SCell_addition_feature_activation
    [Tags]    AA_02    case2
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
#    Open DCAP
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    flowTracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    ne_type=vcu    vcu_custom_profile=${vcu_profile}
    Parameter Updated In Gnb For CB006139_Deactive
    Parameter Updated In Gnb For CB006139
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    60s    reason=wait call stable
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    [Teardown]    Case Postcondition

CB006139_AA_03_Buffer-based_step-wise_NR_FR1_SCell_addition_feature_activation_ALT1
    [Tags]    AA_03    case3
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    flowTracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    ne_type=vcu    vcu_custom_profile=${vcu_profile}
    Parameter Updated In Gnb For CB006139_Deactive
    Parameter Updated In Gnb For CB006139
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    60s    reason=wait call stable
    Stop Call For UE    ue_index=0    ue_type=qualcomm
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;120;0;10;
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    [Teardown]    Case Postcondition

CB006139_AA_04_Buffer-based_step-wise_NR_FR1_SCell_addition_feature_deactivation
    [Tags]    AA_04    case4
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    flowTracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    ne_type=vcu    vcu_custom_profile=${vcu_profile}

    Parameter Updated In Gnb For CB006139
    Prepare And Attach UE For Qualcomm    ue_index=0

    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    60s    reason=wait call stable
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}

    [Teardown]    Case Postcondition

CB006139_AA_12_Exploratory_test_feature_deactivation_leagcy_counter_check
    [Tags]    AA_12    case12
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
    Parameter Updated In Gnb For CB006139
    Start Counter For case12_VDU
    Start Counter For case12_VCU
#    Set Library Search Order    AIC_UE    real_ue
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    Collect And Check Counter VDU
    Collect And Check Counter VCU
    [Teardown]    Case Postcondition

CB006139_AA_13_Exploratory_test
    [Tags]    AA_13    case13
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    flowTracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    ne_type=vcu    vcu_custom_profile=${vcu_profile}
    Parameter Updated In Gnb For CB006139
#    Set Library Search Order    AIC_UE    real_ue
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    60s    reason=wait call stable
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}

    [Teardown]    Case Postcondition

CB006139_AA_14_Robustness_Operations
    [Tags]    AA_14    case14
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    flowTracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    ne_type=vcu    vcu_custom_profile=${vcu_profile}
    Parameter Updated In Gnb For CB006139
#    Set Library Search Order    AIC_UE    real_ue
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    60s    reason=wait call stable
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}

    [Teardown]    Case Postcondition

CB006139_AA_15_robustness_verification
    [Tags]    AA_15    case15
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=9;13;17,21;25,29;    pa_value=10;10;0;10;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    flowTracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    ne_type=vcu    vcu_custom_profile=${vcu_profile}
    Parameter Updated In Gnb For CB006139
#    Set Library Search Order    AIC_UE    real_ue
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    60s    reason=wait call stable
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}

    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Open DCAP    OperatingSystem.Run    DCAP_Basic_controller start

Common Test Setup For AIC
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Common Suite Setup For AIC
    Create Suite Directory
    ${vdu_version}=    Get vDU Version
    Set Suite Variable    ${VDU_VERSION}    ${vdu_version}
    Get SSH Connection Infor For vDU K8s Master
    Get SSH Connection Infor For vCU K8s Master
    ${mrbts_id_list}    ${nrbts_id_list}    Get Multi Gnb Id
    Set suite variable     ${MRBTS_ID_LIST}    ${mrbts_id_list}
    Set suite variable     ${NRBTS_ID_LIST}    ${nrbts_id_list}
    Run Keyword And Ignore Error    Get Iperf Info
    Run Keyword And Ignore Error    Prepare Netrc On VM
    Run Keyword And Ignore Error    Get TestLine Name From UTE Cloud
    Run Keyword And Ignore Error    Get Testline Type

Case Postcondition
    [Arguments]    ${ue_index}=${0}
    Log To Console    ${ue_index}
    log to console    Case Postcondition

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0    ${capabilities}=REAL_QUALCOMM_UE
    Log To Console    ${ui_version}
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Parameter Updated In Gnb For CB006139_Deactive
    @{para_list}          Create List    actBufferBasedSCellAddition
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    oneShot_Dl_Fr1
    @{para_list}          Create List    actBufferBasedSCellAddition
    @{mo_list_vcu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    oneShot_Dl_Fr1
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu

Parameter Updated In Gnb For CB006139
    @{para_list}          Create List    actBufferBasedSCellAddition
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    oneShot_stepWise_Dl_Fr1
    @{para_list}          Create List    actBufferBasedSCellAddition
    @{mo_list_vcu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    oneShot_stepWise_Dl_Fr1
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu

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

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}    ${ne_type}=vdu   ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    ...            ${gnb_index}=0    ${vdu_index}=0
    Log To Console    ${ne_type}
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
    ...    ${TRUE}    dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${webem_info}

    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vcu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
    Log To Console     Trace Collection start on DCAP
    [Return]    ${trace_id}

Get Trace Log
    [Arguments]    ${btsip}
    ${trace_file_path}    Download Trace File    btsip=${btsip}
    @{zip_file_name}    OperatingSystem.List Files In Directory    ${trace_file_path}    *.zip
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.5gm
    [Return]    ${log_file_paths}

Get WebEM Info
    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...                                   '${ne_type.upper()}'=='VCU'
    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
    [return]    ${webem_info}

Start DL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    ...            ${RemoteHost}=10.108.237.194    ${Account}=ute    ${Password}=Ut3pa5s#ff97
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
	...              throughput=1800M    duration=${600}    RemoteHost=${RemoteHost}
	...              Account=${Account}     Password=${Password}

Start DL and UL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
	...              throughput=1800M    duration=${600}
	Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    dt_index=${ue_index}
	...              throughput=110M    duration=${600}

Start Counter For case12_VDU
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55139C01001;
    ...         Counter rule: max(M55139C01001)==1;
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55139C01001;
    ...         Counter rule: max(M55139C01001)==1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-31;
    ...         Counter: M55139C01001;
    ...         Counter rule: max(M55139C01001)==1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55139C01002;
    ...         Counter rule: max(M55139C01002)==1;
    ${rule5}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55139C01002;
    ...         Counter rule: max(M55139C01002)==1;
    ${rule6}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-31;
    ...         Counter: M55139C01002;
    ...         Counter rule: max(M55139C01002)==1;
    ${rule_list}    Create List    ${rule2}    ${rule1}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vdu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter VDU
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Start Counter For case12_VCU
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55118C00033;
    ...         Counter rule: max(M55118C00033)>=1;
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55138C03001;
    ...         Counter rule: max(M55138C03001)>=1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55138C03002;
    ...         Counter rule: max(M55138C03002)>=1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55138C03512;
    ...         Counter rule: max(M55138C03512)>=1;
    ${rule5}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55138C03519;
    ...         Counter rule: max(M55138C03519)>=1;
    ${rule6}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55138C00008;
    ...         Counter rule: max(M55138C00008)>=1;
    ${rule7}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55138C00009;
    ...         Counter rule: max(M55138C00009)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}    ${rule7}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter VCU
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Stop Call For UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    Log To Console    ${ue_type}
    Log to Console    \n***Prepare to Stop a Call..***
    Stop traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=dl
    sleep    5s    reason=wait call stoped
    Log to Console    \n***Call stoped..***
