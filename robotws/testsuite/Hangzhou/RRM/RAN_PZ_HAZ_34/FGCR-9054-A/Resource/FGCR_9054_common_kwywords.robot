*** Settings ***
Documentation  Author: Eric Guo
...            Description: Feature FGCR-9054 common keywords
Resource    ../../5GC001700_AA/Resources/5GC001700_AA_5GC001077_common_keyword_qualcomm_coam.robot

*** Keywords ***
Get OLScheme from BIP
    [Documentation]    Author: Eric Guo
    [Arguments]    ${connection}=ASIK Master    ${log_prefix}=l1l2bip_log
    run keyword and ignore error    csn.disconnect    connection=${connection}
    connection_alias_store.Connect to Common Unit Master
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    Start L3 Call With Power UE
    ...            ul_data_transfer=20M
    ...            dl_data_transfer=10M
    ...            duration=120
    ...            iperf_type=${iperf_type}
    ${bip_log}   Run keyword if    'ENB_9999' in '${Active_SW_version}'    Start BIP Capture and Download File with SEM    log_prefix=${log_prefix}
    ...             ELSE
    ...           Start BIP Capture and Download File with gnbMirroring scripts
    ${FILTER}    set variable    dldata_pdschsendreq
#    ${command_template}    set variable    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y "${FILTER}" -T pdml
#    ${pdml_packets}=    Convert Pcap to pdml format    file_path=${bip_log}
#    ...            luashark_path=${luashark_path}
#    ...            command_template=${command_template}
    ${bipList}    Check Target Item Value on CPIF Tcpdump    file_path=${bip_log}
    ...            filter_expression=${FILTER}   xpath=.//DlData_PdschGrant.openLoopScheme
    ...            filter=${FILTER}
    ${OLScheme_value}    Remove Duplicates    ${bipList}
    ${OLScheme_length}    get length     ${OLScheme_value}
    Should Be True    ${OLScheme_length} > 0
#
#    cap.filter_packets_by_expression    filter_expression=${FILTER}
#    ${OLScheme_ori}     cap.get_field_value_by_xpath    xpath=.//DlData_PdschSendReq.grants_item_0.openLoopScheme
#    ...                                                 attribute_name=show
#    ${OLScheme_value}    ${OLScheme_count} =    Remove Duplicates And Get IE Length
#    ...            list=${OLScheme_ori}
    [Return]    ${OLScheme_value}[0]

Modify mcs flag
    [Documentation]    Author: Eric Guo
    [Arguments]    ${swconfig_modify}    ${timeout}=600   ${connection}=GNB_OAM
    run keyword and ignore error   COAM Teardown gnb connections
    Connect to Common Unit Master    alias=ASIK Master
    ${local_log_file_folder}    set variable    ${TS_CASE_LOG_PATH}
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_log_file_folder}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${local_log_file_folder}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_log_file_folder}/swconfig.txt    asik_alias=ASIK Master
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=20 min

9054 Case Teardown
    1700 Case TearDown
    @{mcs}    create list    0x58000f=0xffffffff
    Modify mcs flag    ${mcs}

CNI_61418_A_01_2x2_open_loop_controlling_L1_RD_parameters_removal
    [Documentation]    Author: Eric Guo
    [Arguments]    ${ue_index}=${0}
    ${dlMimoMode}    coam_parameter.get_single_value_from_scf_file    parameter=dlMimoMode
    ...            dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...            connection=GNB_OAM
    connection_alias_store.Connect to Common Unit Master    alias=ASIK Master
    connection_alias_store.Connect to Capacity Unit Loner    alias=ABIL Loner    asik_alias=ASIK Master
    ${output}    csn.execute    command=cat /etc/5g-layer-1/const_customizer.conf    connection=ABIL Loner
    should not contain    ${output}    rd_open_loop_scheme
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}
    Start UE Attach With Power UE
    ${OLScheme_value}    Get OLScheme from BIP
    run keyword if    "${dlMimoMode}" == "4x4 or 4x2 Open Loop Spatial Multiplexing"
    ...            should be equal as integers    ${OLScheme_value}    1
    run keyword if    "${dlMimoMode}" == "2x2 Open Loop Spatial Multiplexing"
    ...            should be equal as integers    ${OLScheme_value}    2

FGCR_9054_A_05_dynamic_open_loop_precoding_parameter
    [Documentation]    Author: Eric Guo
    [Arguments]    ${ue_index}=${0}
    ${actBF}    coam_parameter.get_single_value_from_scf_file    parameter=actBeamforming
    ...            dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...            connection=GNB_OAM
    ${dlMimoMode}    coam_parameter.get_single_value_from_scf_file    parameter=dlMimoMode
    ...            dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...            connection=GNB_OAM
    ${modify_param}    Create List
    ${nrcell_list}    Get Cell ID list via Admin CLI    connection=GNB_OAM
    FOR    ${nrcell}    IN    @{nrcell_list}
        &{OLScheme_param}    Create Dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/${nrcell}
        ...                  parameter=openLoopScheme    value=Dynamic
        Append To List    ${modify_param}    ${OLScheme_param}
    END
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    @{mcs_15}    create list    0x58000f=0x00008000
    @{mcs_20}    create list    0x58000f=0x00100000
    Modify mcs flag    ${mcs_15}
    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}
    Start UE Attach With Power UE
    ${OLScheme_value}    Get OLScheme from BIP    log_prefix=l1l2bip_log_mcs15
    run keyword if    "${dlMimoMode}" == "4x4 or 4x2 Open Loop Spatial Multiplexing"
    ...              should be equal as integers    ${OLScheme_value}    1
    ...               ELSE    should be equal as integers    ${OLScheme_value}    2
    Modify mcs flag    ${mcs_20}
    run keyword if    '${ue_type}' == 'qct_dx50'    Run Keywords
    ...    run keyword and continue on failure    UE soft reboot    AND
    ...    wait until keyword succeeds    5min    10s    Ue detach with index
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
    ${OLScheme_value}    Get OLScheme from BIP    log_prefix=l1l2bip_log_mcs20
    run keyword if    "${dlMimoMode}" == "2x2 Open Loop Spatial Multiplexing"
    ...              should be equal as integers    ${OLScheme_value}    2
    run keyword if    "${dlMimoMode}" == "4x4 or 4x2 Open Loop Spatial Multiplexing" and "${actBF}" == "true"
    ...               should be equal as integers    ${OLScheme_value}    1
    run keyword if    "${dlMimoMode}" == "4x4 or 4x2 Open Loop Spatial Multiplexing" and "${actBF}" == "false"
    ...               should be equal as integers    ${OLScheme_value}    0
