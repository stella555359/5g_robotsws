*** Settings ***
Documentation
...    Author: sudi Lou
...    Contact: sudi.lou@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot


*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${NSA_UE_ID}    101
#${NSA_UE_ID}    11
#${pcmd_delta_file}    ./delta_pcmd_activation.json
#${pcmd_tmo_delta_file}    ./delta_pcmd_releated_paras_on_TMO.json
#${a5_delta_file}    ./delta_a5_activation.json
#${nrrel_delta_file}    ./delta_add_nrrel_on_TMO.json
${pcmd_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CNI-129708/delta_pcmd_activation.json
${pcmd_tmo_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CNI-129708/delta_pcmd_releated_paras_on_TMO.json
${a5_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CNI-129708/delta_a5_activation.json
${nrrel_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CNI-129708/delta_add_nrrel_on_TMO.json
${log_type}    syslog+cell_trace


*** Test Cases ***
CNI-129708_01_PCMD_records_reporting_during_NSA_IntraDU_InterCell_handover
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    CNI-129708
    [Setup]    Case Precondition
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${pcmd_tmo_delta_file}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${nrrel_delta_file}
    start_log_collection    log_type=${log_type}
    UE attach and traffic    local_cell_id=1
    Trigger IntraDU InterCell Handover on TMO    phycell_id=53    ue_id=${NSA_UE_ID}
    sleep    3s    reason=wait call stable
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check Records for TC01    ${local_file_path}
    [Teardown]  Run Keyword And Ignore Error    Teardown_for_CNI-129708

CNI-129708_02_PCMD_records_reporting_during_NSA_IntraDU_IntraCell_handover
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    NFTA    CLOUD_5G_I_LO_AP_LO
    Case Precondition For AP    tag=TC_01_02    product_type=gnb    operation=env_setup_sa
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${pcmd_delta_file}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${a5_delta_file}
    start_log_collection    log_type=${log_type}
    X2 Link for external gNB
    UE attach and traffic    local_cell_id=1
    Trigger sCell addition    ${NSA_UE_ID}
    sleep    3s    reason=wait call stable
#    Check sCellIndex of ULCA UE From Tput    ${NSA_UE_ID}    9
#    sleep    3s    reason=wait call stable
    Trigger sCell Release During IntraDU IntraCell Handover
    sleep    3s    reason=wait call stable
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check Records for TC02    ${local_file_path}
    [Teardown]  Teardown_for_CNI-129708

PCMD_records_reporting_during_NSA_IntraDU_InterCell_handover_with_scell_release
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    debug_pcmd
#    NRREL-1 is for SCell addition(cell 3 band5), NRREL-2 is for IntraDU HO, A2 of cell 3 is for scell release
    Case Precondition For AP    tag=TC_01_02    product_type=gnb    operation=env_setup_sa
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${pcmd_delta_file}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${a5_delta_file}
    start_log_collection    log_type=${log_type}
    X2 Link for external gNB
    UE attach and traffic    local_cell_id=1
    Trigger sCell addition    ${NSA_UE_ID}
    sleep    3s    reason=wait call stable
    Check sCellIndex of ULCA UE From Tput    ${NSA_UE_ID}    9
    sleep    3s    reason=wait call stable
    Trigger IntraDU InterCell Handover    phycell_id=51    ue_id=${NSA_UE_ID}
    sleep    3s    reason=wait call stable
    ute_wtssim.Execute Egate Command    cmd=ue_detach id=${NSA_UE_ID}
    sleep    3s    reason=wait call stable
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]  Teardown_for_CNI-129708

*** Keywords ***
Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sansa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s
    ...                   customer=TMO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

X2 Link for external gNB
    ute_wtssim.Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    ...    pass_regexp=X2AP Link with GNB-2

start_log_collection
    [Arguments]  ${log_type}=emil+syslog+cell_trace
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}  dict_argument=${dict_argument}

UE attach and traffic
    [Arguments]    ${local_cell_id}
    ute_wtssim.Execute Egate Command    cmd=ue_attach id=${NSA_UE_ID}    pass_regexp=UE IS ACTIVE
    ute_wtssim.Execute Egate Command    cmd=ue_dc_enb_start ue=${NSA_UE_ID} target_gnb=2 target_cells=${local_cell_id} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA
    Send Throughput

Send Throughput
    ute_wtssim.Execute Egate Command    cmd=data_trf_start ue=${NSA_UE_ID} id=2 dir=ul mbps=150 trf_id=1    pass_regexp=UDP UL
    ute_wtssim.Execute Egate Command    cmd=data_trf_start ue=${NSA_UE_ID} id=2 dir=dl mbps=150 trf_id=2    pass_regexp=UDP DL

Trigger IntraDU InterCell Handover
    [Arguments]    ${phycell_id}    ${ue_id}=11
    ${a5_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A5
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5_meas_id} index=0 nrs_result=68:19:0 event=A5
    ...    phycell_id=${phycell_id} nrsrp_nr=68 srsrp_nr=19
    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity

Trigger IntraDU InterCell Handover on TMO
    [Arguments]    ${phycell_id}    ${ue_id}=101
    ${a5_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=520110    event_type=A5
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5_meas_id} index=0 nrs_result=68:19:0 event=A5
    ...    phycell_id=${phycell_id} nrsrp_nr=68 srsrp_nr=19
    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity

Trigger sCell addition
    [Arguments]    ${ue_id}=11
    ${a1_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a1_meas_id} event=A1 srsrp_nr=80
    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=SCellToAddMod-r15 present in SCG

Get Scell Index of ULCA UE From Tput
    [Arguments]    ${ue_id}
    ${cmd}    Catenate    ue_stats_nr id=${ue_id} scell=0-9
#    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=pusch scell\=1-31
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Set Variable    CellIndex-(?P<cell_index>\\d{1,2})\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ${match_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    cell_index
    [Return]    ${match_list[0]}

Check sCellIndex of ULCA UE From Tput
    [Arguments]    ${ue_id}    ${exp_scell_index}
    ${scell_index}    Get Scell Index of ULCA UE From Tput    ${ue_id}
    Should be True    '${scell_index}'=='${exp_scell_index}'

Trigger sCell Release During IntraDU IntraCell Handover
    [Arguments]    ${ue_id}=11
    ute_wtssim.Execute Egate Command    cmd=ue_sgnb_mod_param id=${ue_id} allowed_bc_list_mrdc=1:1 exclude_sgnb_security_key=on
    ute_wtssim.Execute Egate Command    cmd=enb_endc_param id=1 serving_cell_index_range_scg=8:8
    ${cmd}    Catenate    enb_ue_dc_modify ue=${ue_id} bearer_to_release=2 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=SCellToRelease-r15 present in SCG

Check Records for TC01
    [Arguments]    ${trace_file}
    ${trace_message_count}    Create Dictionary    DuHoSrcTraceRecord=0    UeCtxModificationTraceRecord=0
    ...                                      DuUeReleaseTraceRecord=0
    ${multi_filters}   catenate   SEPARATOR=    "User data"="DU: DuHoSrcTraceRecord";
    ...    "User data"="DU: UeCtxModificationTraceRecord";
    ...    "User data"="DU: DuUeReleaseTraceRecord"
    ${json_file_list}=    Log Analysis   check   cell_trace   ${trace_file}   filter_cell_trace=${multi_filters}    convert_type=json
    ${trace_info_list}    Get trace info from json file    ${json_file_list}
    FOR    ${trace}    IN    @{trace_info_list}
        FOR    ${trace}    IN    @{trace}
            ${User_data}=    Set Variable    ${trace}[User_data]
            ${prefix}  ${record_type}   Split String From Right    ${User_data}    :${SPACE}    1
            ${tmp_info}=    Run Keyword If    '${record_type}' == 'DuHoSrcTraceRecord'
                ...    Run Keyword And Ignore Error    Check Source HO Trace Record    ${trace}
            ...    ELSE IF    '${record_type}' == 'UeCtxModificationTraceRecord'
                ...    Run Keyword And Ignore Error    Check UE Context Modification Trace Record    ${trace}
            ...    ELSE IF    '${record_type}' == 'DuUeReleaseTraceRecord'
                ...    Run Keyword And Ignore Error    Check UE Release Trace Record    ${trace}
            ...    ELSE     Log To Console    \nThe value of user dta is unexpected!
            Run Keyword If    '${tmp_info}[0]' == 'PASS'    Add Value To Dictionary Key    ${trace_message_count}    ${record_type}    1
        END
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}

    Should Be True    ${trace_message_count}[DuHoSrcTraceRecord] >= ${1}
    Should Be True    ${trace_message_count}[UeCtxModificationTraceRecord] >= ${1}
    Should Be True    ${trace_message_count}[DuUeReleaseTraceRecord] >= ${1}

Check Records for TC02
    [Arguments]    ${trace_file}
    ${trace_message_count}    Create Dictionary    UeCtxModificationTraceRecord=0    DuCaConfigurationTraceRecord=0
    ${multi_filters}   catenate   SEPARATOR=    "User data"="DU: UeCtxModificationTraceRecord";
    ...    "User data"="DU: DuCaConfigurationTraceRecord";
    ${json_file_list}=    Log Analysis   check   cell_trace   ${trace_file}   filter_cell_trace=${multi_filters}    convert_type=json
    ${trace_info_list}    Get trace info from json file    ${json_file_list}
    FOR    ${trace}    IN    @{trace_info_list}
        FOR    ${trace}    IN    @{trace}
            ${User_data}=    Set Variable    ${trace}[User_data]
            ${prefix}  ${record_type}   Split String From Right    ${User_data}    :${SPACE}    1
            ${tmp_info}=    Run Keyword If    '${record_type}' == 'UeCtxModificationTraceRecord'
                ...    Run Keyword And Ignore Error    Check UE Context Modification Trace Record    ${trace}    exp_reason=pdcpCountWraparound
            ...    ELSE IF    '${record_type}' == 'DuCaConfigurationTraceRecord'
                ...    Run Keyword And Ignore Error    Check Du Ca Configuration Trace Record    ${trace}
            ...    ELSE     Log To Console    \nThe value of user dta is unexpected!
            Run Keyword If    '${tmp_info}[0]' == 'PASS'    Add Value To Dictionary Key    ${trace_message_count}    ${record_type}    1
        END
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}

    Should Be True    ${trace_message_count}[UeCtxModificationTraceRecord] >= ${1}
    Should Be True    ${trace_message_count}[DuCaConfigurationTraceRecord] >= ${1}

Add Value To Dictionary Key
    [Arguments]    ${message_count_dict}    ${update_key}    ${add_value}
    ${new_value}    Evaluate    ${message_count_dict}[${update_key}] + ${add_value}
    Set To Dictionary    ${message_count_dict}    ${update_key}=${new_value}

Get trace info from json file
    [Arguments]    ${file_path}
    ${trace_info_list}    Create List
    FOR    ${file}    IN    @{file_path}
        ${parsed_json}    OperatingSystem.Get File    ${file}
        ${context_dict}    json.Loads    ${parsed_json}
        ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
        Run Keyword If    ${trace_info} != []    Append to list    ${trace_info_list}    ${trace_info}
        ...    ELSE    Log    The trace info is empty
    END
    [Return]    ${trace_info_list}

Check Source HO Trace Record
    [Arguments]    ${emil_data}
    ${JsonContent_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${JsonContent_info}[DuVendorExtensionRecordDataType][hoSrcRecord][data]

    ${result}=    Set Variable    ${record_data}[result]
    ${plmn-Identity}=    Set Variable    ${record_data}[tgtCellId][plmn-Identity]
    ${cellIdentity}=    Set Variable    ${record_data}[tgtCellId][cellIdentity]

    Should Be Equal    ${result}    success
    Should Be Equal    ${plmn-Identity}    132006
    Should Be Equal    ${cellIdentity}    0000040030

Check UE Context Modification Trace Record
    [Arguments]    ${emil_data}    ${exp_reason}=pSCellChange
    ${JsonContent_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${JsonContent_info}[DuVendorExtensionRecordDataType][ueCtxModificationRecord][data-r1]

    ${ueCtxModificationReason}=    Set Variable    ${record_data}[ueCtxModificationReason]
    ${result}=    Set Variable    ${record_data}[result]
    ${plmn-Identity}=    Set Variable    ${record_data}[tgtPSCellId][plmn-Identity]
    ${cellIdentity}=    Set Variable    ${record_data}[tgtPSCellId][cellIdentity]

    Should Be Equal    ${ueCtxModificationReason}    ${exp_reason}
    Should Be Equal    ${result}    success
    Should Be Equal    ${plmn-Identity}    132006
#    Should Be Equal    ${plmn-Identity}    134198

Check UE Release Trace Record
    [Arguments]    ${emil_data}
    ${JsonContent_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${JsonContent_info}[DuVendorExtensionRecordDataType][ueReleaseRecord][data]

    ${finalClass}=    Set Variable    ${record_data}[classifier][finalClass]
    ${primaryQualifier}=    Set Variable    ${record_data}[classifier][primaryQualifier]
    ${secondaryQualifier}=    Set Variable    ${record_data}[classifier][secondaryQualifier]

    Should Be Equal    ${finalClass}    normal
    Should Be Equal    ${primaryQualifier}    pSCellChange
    Should Be Equal    ${secondaryQualifier}    intraDuHo

Check Du Ca Configuration Trace Record
    [Arguments]    ${emil_data}
    ${JsonContent_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${JsonContent_info}[DuVendorExtensionRecordDataType][ueReleaseRecord][data]
    Dictionary Should Contain Key    ${record_data}    releasedSCells

Teardown_for_CNI-129708
    Log To Console    \nstop test
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False
    ute_wtssim.Execute Egate Command    cmd=ue_sgnb_mod_param id=${NSA_UE_ID} reset
    ute_wtssim.Execute Egate Command    cmd=ue_enb_endc_param id=${NSA_UE_ID} reset
    ute_wtssim.Execute Egate Command    cmd=enb_endc_param id=1 reset
    ute_wtssim.Execute Egate Command    cmd=ue_detach id=${NSA_UE_ID}
    ${local_file_path}    Run Keyword And Ignore Error  Log Collection  stop_and_download  ${log_type}  product_type=gnb
      ...    bts_index=${0}
    Case Postcondition For AP