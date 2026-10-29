*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***
#${nsetapx_plugin_addr}
#...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.13.4/nsetapx-4.2-0.7.0-1.13.4+bookworm.so
${tshark_path}      /usr/bin/tshark
${remote_dir_path}   /tmp
${pcmd_file}   PCMD_5G.pcap
${pcmd_file_webui}   PCMD_webui.pcap
${pcmd_file_netact}   PCMD_netact.pcap
${pcmd_file_webui_de}   PCMD_webui_de.pcap+buster.so
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins
${pcmd_file_netact_de}   PCMD_netact_de.pcap

${nsetapx_addr}   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X
${arti_user}   ca_5Gauto
${arti_key}   AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc

*** Keywords ***
Start Tcpdump To Get PCMD
    [Arguments]   ${remote_dir_path}=${remote_dir_path}   ${pcmd_file}=${pcmd_file}   ${eth}=${False}   ${command}=None
    ...   ${hostname}=${LOCAL_SSH_ADDR}   ${username}=${LOCAL_SSH_USER}   ${password}=${LOCAL_SSH_PWD}   ${connection}=LOCAL
    Log To Console   Start Tcpdump To Get PCMD

    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}
    ${eth_port}   Set Variable If
    ...   '${${connection}_SMOD_NAME}'=='ASIK'   fp0
    ...   '${${connection}_SMOD_NAME}'=='ASIB'   br1
    ...   '${${connection}_SMOD_NAME}'=='ASIL'   br0
    ...   '${${connection}_SMOD_NAME}'=='ASOE'   br0
    ...   '${${connection}_SMOD_NAME}'=='ASIM'   br0
    ${any_port}   Set Variable   any
    ${is_CRT}   run keyword and return status   should contain    ${OUTPUT_DIR}   CRT
    ${port}   Run Keyword If   ${eth}   Set Variable   ${eth_port}
    ...   ELSE   Set Variable If   ${is_CRT}   any   ${eth_port}
    ${tcp_command}   Set Variable If   '${command}'=='None'   tcpdump -i ${port}   ${command}
    csn.Send Command   command=${tcp_command} -w ${remote_dir_path}/${pcmd_file} &> /dev/null &   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

Stop Tcpdump To Get PCMD
    [Arguments]   ${remote_dir_path}=${remote_dir_path}   ${pcmd_file}=${pcmd_file}   ${eth}=${False}
    ...   ${hostname}=${LOCAL_SSH_ADDR}   ${username}=${LOCAL_SSH_USER}   ${password}=${LOCAL_SSH_PWD}   ${connection}=LOCAL
    Log To Console   Stop Tcpdump To Get PCMD

    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}
    ${eth_port}   Set Variable If
    ...   '${${connection}_SMOD_NAME}'=='ASIK'   fp0
    ...   '${${connection}_SMOD_NAME}'=='ASIB'   br1
    ...   '${${connection}_SMOD_NAME}'=='ASIL'   br0
    ...   '${${connection}_SMOD_NAME}'=='ASOE'   br0
    ...   '${${connection}_SMOD_NAME}'=='ASIM'   br0
    ${any_port}   Set Variable   any
    ${is_CRT}   run keyword and return status   should contain    ${OUTPUT_DIR}   CRT
    ${port}   Run Keyword If   ${eth}   Set Variable   ${eth_port}
    ...   ELSE   Set Variable If   ${is_CRT}   any   ${eth_port}
    csn.Execute   command=ps -ef | grep ${remote_dir_path}/${pcmd_file} | grep -v grep | awk '{print $2}' | xargs kill -9   connection=${connection}
    csn.Execute   command=ps -ef|grep tcpdump|grep -v grep|grep ${port}   connection=${connection}
    csn.Execute   command=ps -ef|grep tcpdump|grep -v grep|grep ${port}   connection=${connection}
    csn.Download File
    ...   remote_path=${remote_dir_path}/${pcmd_file}
    ...   local_path=${OUTPUT_DIR}/${pcmd_file}
    ...   connection=${connection}
    csn.Execute   command=rm -rf ${remote_dir_path}/${pcmd_file}   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

Load Pcap File with Filter
    [Arguments]    ${pcap_file}    ${record_type}   ${input_type}    ${filter}
    Download wireshark plugin For 1756
#    ${command_template_with_Y}   Set Variable
#    ...   {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
    ${command_template_with_Y}   Set Variable
    ...   {tshark_path} -o ntrstr.port:${dcap_server_port} -o ntrstr.defragment:TRUE -r {pcap_file} -Y ${filter} -T pdml
    wireshark.load_pcap_file
    ...   pcap_file=${pcap_file}
    ...   tshark_path=${tshark_path}
    ...   command_template=${command_template_with_Y}
    ${filter_expression}   Set Variable   nsetapx.${record_type}VendorExtensionRecordDataType == ${input_type}
    wireshark.filter_packets_by_expression   filter_expression=${filter_expression}

Load Pcap File with Filter any Expression
    [Arguments]    ${pcap_file}    ${filter}   ${any_expression}
    Download wireshark plugin For 1756
    # ${command_template_with_Y}   Set Variable
    # ...   {tshark_path} -r {pcap_file} -Y ${filter} -T pdml
    ${command_template_with_Y}   Set Variable
    ...   {tshark_path} -o ntrstr.port:${dcap_server_port} -o ntrstr.defragment:TRUE -r {pcap_file} -Y ${filter} -T pdml
    wireshark.load_pcap_file
    ...   pcap_file=${pcap_file}
    ...   tshark_path=${tshark_path}
    ...   command_template=${command_template_with_Y}
    ${filter_expression}   Set Variable   ${any_expression}
    wireshark.filter_packets_by_expression   filter_expression=${filter_expression}

Load Pcap File with Filter for 1756_B
    [Arguments]    ${pcap_file}    ${filter}   ${TraceMessage}  ${nodeType}
    Download wireshark plugin For 1756
#    ${command_template_with_Y}   Set Variable
#    ...   {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
     ${command_template_with_Y}   Set Variable
    ...   {tshark_path} -o ntrstr.port:${dcap_server_port} -o ntrstr.defragment:TRUE -r {pcap_file} -Y ${filter} -T pdml
    wireshark.load_pcap_file
    ...   pcap_file=${pcap_file}
    ...   tshark_path=${tshark_path}
    ...   command_template=${command_template_with_Y}
    ${filter_expression}   Catenate
    ...   nsetapx.TraceMessage == ${TraceMessage}
    ...   and nsetapx.nodeType == ${nodeType}
    wireshark.filter_packets_by_expression   filter_expression=${filter_expression}

Download wireshark plugin For 1756
#    ${ver}   Run   ls ${plugin_folder}/
#    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
#    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
#    Run Keyword If   ${exist.count('No such file or directory')}>0 and ${exist_utevm.count('No such file or directory')}>0   Run
#    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}
    ${wiresharkver}   Run   ls ${plugin_folder}/
    Run   sudo ls -l ${plugin_folder}/${wiresharkver}/epan/nsetapx*bookworm.so 2>&1
    Run   sudo rm -rf ${plugin_folder}/${wiresharkver}/epan/nsetapx*bookworm.so
    ${apx_p}   Run   curl -u ${arti_user}:${arti_key} -sL -m 15 ${nsetapx_addr}/ |grep "nsetapx" |cut -d '"' -f2 |cut -d '.' -f1 |sort -r |head -1
    ${apx_m}   Run   curl -u ${arti_user}:${arti_key} -sL -m 15 ${nsetapx_addr}/ |grep "${apx_p}" |cut -d '"' -f2 |cut -d '.' -f2 |sort -nr |head -1
    ${nsetapxv}   Run   curl -u ${arti_user}:${arti_key} -sL -m 15 ${nsetapx_addr}/ |grep "${apx_p}\.${apx_m}" |cut -d '"' -f2 |sort -r |head -1
    ${nsetapxlist}   Run   curl -u ${arti_user}:${arti_key} -sL ${nsetapx_addr}/${nsetapxv} |grep "\\-${wiresharkver}\\-" |grep 'bookworm.so</a'
    ${nsetapxbuild}   Run   echo '${nsetapxlist}' |cut -d '"' -f2
    @{nsetapxbuild_list}    Split String     ${nsetapxbuild}    \n
    Sort List    ${nsetapxbuild_list}
    ${nsetapxbuild}    Set Variable    ${nsetapxbuild_list}[-1]
    ${exist}   Run   ls -l ${plugin_folder}/${wiresharkver}/epan/${nsetapxbuild} 2>&1
    ${exist_utevm}   Run  ls -l ${plugin_folder_utevm}/${wiresharkver}/epan/${nsetapxbuild} 2>&1
    ${wget_nsetapx}  Set Variable  `sudo wget --user=${arti_user} --password=${arti_key} ${nsetapx_addr}/${nsetapxv}${nsetapxbuild}`
    Run Keyword If   ${exist.count('No such file or directory')}>0   Run  cd ${plugin_folder}/${wiresharkver}/epan; ${wget_nsetapx}
    Run Keyword If   ${exist_utevm.count('No such file or directory')}>0  Run  cd ${plugin_folder_utevm}/${wiresharkver}/epan; ${wget_nsetapx}


Close Web Startup View Window
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window

Get PCMD Value
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login
    Close Web Startup View Window
    ${cellIdentity}  ${cell_numbers}   Get CellIdentity from WebUI
    Set Suite Variable   ${cellIdentity}
    log to console    cellIdentity == ${cellIdentity}
    Set Suite Variable   ${cell_numbers}
    Log to console   cell_numbers == ${cell_numbers}
    ${PLMNIdentity_dec}  ${mcc}  ${mnc_inital}  ${mnc_length}   Get PLMNIdentity from WebUI
    Set Suite Variable   ${mcc}
    Set Suite Variable   ${mnc_inital}
    Set Suite Variable   ${mnc_length}
    Log to console  mcc == ${mcc}
    Log to console  mnc == ${mnc_inital}
    Log to console  mnc_length == ${mnc_length}
    ${plmn_Identity}   Get hexadecimal PLMNIdentity
    Set Suite Variable   ${plmn_Identity}
    log to console    PLMNIdentity == ${plmn_Identity}
    ${traceId}   Get hexadecimal traceId
    Set Suite Variable   ${traceId}
    log to console    traceId == ${traceId}
    [Return]   ${cellIdentity}   ${plmn_Identity}   ${traceId}

Get CellIdentity from WebUI
    Close Web Startup View Window
    ${cell_numbers}    Get Cell Number
    ${CellIndentity_pure_num_list}   Set Variable   ${EMPTY}
    FOR  ${idx}    IN RANGE    1    ${cell_numbers}+1
         ${CellIndentity_dec}  selenium_coam.get_parameter_value    dist_name=${INSID}/NRCELL-${idx}   filter_param=NR Cell Identity
         ${CellIndentity_hex}     Evaluate    hex(${CellIndentity_dec})
         ${CellIndentity_end}     Catenate    SEPARATOR=     ${CellIndentity_hex}         0
         ${CellIndentity_pure_num}     Remove String    ${CellIndentity_end}       0x
         ${CellIndentity_length}   Get Length    ${CellIndentity_pure_num}
         ${CellIndentity_0_num}    Evaluate      10-${CellIndentity_length}
         ${CellIndentity_pure_num}     Get Pure Number CllIdentity    ${CellIndentity_0_num}   ${CellIndentity_pure_num}
         ${CellIndentity_pure_num_list}     Catenate   ${CellIndentity_pure_num_list}   ${CellIndentity_pure_num}
    END
    [Return]   ${CellIndentity_pure_num_list}    ${cell_numbers}

Get Pure Number CllIdentity
    [Arguments]      ${CellIndentity_0_num}    ${CellIndentity_pure_num}
    FOR   ${idx}    IN RANGE    0    ${CellIndentity_0_num}
          ${CellIndentity_pure_num}     Catenate   SEPARATOR=     0    ${CellIndentity_pure_num}
    END
    [Return]   ${CellIndentity_pure_num}

Get PLMNIdentity from WebUI
    Close Web Startup View Window
    ${mcc}    selenium_coam.get_parameter_value     dist_name=${INSID}    filter_param=MCC in PLMN
    ${mnc_inital}    selenium_coam.get_parameter_value     dist_name=${INSID}    filter_param=MNC in PLMN
    ${mnc_length}    selenium_coam.get_parameter_value     dist_name=${INSID}    filter_param=MNC length of PLMN ID in primary PLMN of gNB
    ${mnc_length_tmp}    Get Length    ${mnc}
    ${zero_num}=    Evaluate     ${mnc_length}-${mnc_length_tmp}
    FOR   ${idx}    IN RANGE    0    ${zero_num+1}
        Exit For Loop If    '${mnc_length}'=='${mnc_length_tmp}'
        ${mnc}     Catenate    SEPARATOR=     0    ${mnc}
        ${mnc_length_tmp}    Get Length    ${mnc}
    END
    ${PLMNIdentity_dec}      Catenate    SEPARATOR=     ${mcc}   ${mnc}
    [Return]   ${PLMNIdentity_dec}  ${mcc}  ${mnc_inital}  ${mnc_length}

Get Cell Number
    ${cell_list}   COAM Get Cell List
    ${cell_numbers}    get length    ${cell_list}
    [Return]    ${cell_numbers}

Get hexadecimal traceId
    ${traceId_hex}     Evaluate       hex(${tl.gnbs[0].instance_id})
    ${traceId_pure_num}     Remove String    ${traceId_hex}       0x
    ${traceId_length}   Get Length    ${traceId_pure_num}
    ${traceId_0_num}    Evaluate      6-${traceId_length}
    FOR   ${idx}    IN RANGE    0    ${traceId_0_num}
        ${traceId_pure_num}     Catenate   SEPARATOR=     0    ${traceId_pure_num}
    END
    [Return]    ${traceId_pure_num}

Get hexadecimal PLMNIdentity
    ${PLMNIdentity_dec}  ${mcc}  ${mnc_inital}  ${mnc_length}   Get PLMNIdentity from WebUI
    ${PLMNIdentity_end}     Catenate    SEPARATOR=     ${PLMNIdentity_dec}         0
    ${first_three}      Get Substring     ${PLMNIdentity_end}   start=0    end=3
    ${PLMNIdentity_rest}     Fetch From Right  ${PLMNIdentity_end}   ${first_three}
    @{first_three}        convert to list      ${first_three}
    ${two_first_f}           Catenate     SEPARATOR=   ${first_three}[1]     ${first_three}[0]       f
    ${PLMNIdentity}        Catenate    SEPARATOR=     ${two_first_f}      ${PLMNIdentity_rest}
    [Return]    ${PLMNIdentity}

Check Cu Record After Activation or Deactivation From NetAct Trace Expert
    [Arguments]  ${operation}=Activation   ${tcpdump_file}=${TCPDUMP_PATH}
    log to console     Check Cu Record After Activation or Deactivation From NetAct Trace Expert
    Load Pcap File with Filter
     ...                        pcap_file=${tcpdump_file}
     ...                        record_type=Cu
     ...                        input_type=12
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${cu_recode_value_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ueDuConnectivityRecord/nsetapx.data_element/nsetapx.setupData//nsetapx.DuUeCtxSetupData_element/nsetapx.result
    ${count}   Count Values In List   ${cu_recode_value_list}   0
    ${length}   Get Length   ${cu_recode_value_list}
    run keyword if   '${operation}'=='Activation'   run keywords   should be equal   ${count}   ${length}
    ...   AND   should not be empty   ${cu_recode_value_list}
    ...   ELSE   should be empty   ${cu_recode_value_list}
    Log To Console   check value is OK

Get nrcti of gnb HO
    [Arguments]  ${HO_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${HO_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    ...   filter=tcp.dstport==${dcap_server_port}
    ${crnti_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_HO_list}   Remove Duplicates   ${crnti_list}
    ${crnti_HO_length}=     Get Length   ${crnti_HO_list}
    Set Suite Variable   ${crnti_HO_list}
    Set Suite Variable   ${crnti_HO_length}
    [Return]  ${crnti_HO_list}   ${crnti_HO_length}

Get PDU Item Lists from PDUsession Record
    [Arguments]   ${file_path}   ${record_PDU_trigger}   ${PDU_crnti}
    ${record_filter}    run keyword if    '${record_PDU_trigger}' == 'InitialContext'    Set Variable   1
    ...    ELSE IF    '${record_PDU_trigger}' == 'PDUSessionResource'    Set Variable   3
    ...    ELSE IF    '${record_PDU_trigger}' == 'handover'    Set Variable   2
    ...    ELSE    Fail    input pdu record trigger is not find in this pcap
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${file_path}
     ...     any_expression=nsetapx.CuVendorExtensionRecordDataType == 14&&nsetapx.trigger == ${record_filter}&&nsetapx.crnti == ${PDU_crnti}
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${xpath_Pdu_e}   set variable   .//nsetapx.pduSessionResourceInfoRecord/nsetapx.data_element
    ${trigger_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.trigger
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.result
    ${trigger_list_length}=  Get Length   ${trigger_list}
    ${xpath1_pdusetup_result}   set variable if   ${result_list}[0] ==0  set   failedToSet
    ${xpath2_pdusetup_result}   set variable if   ${result_list}[0] == 0   Set   FailedToSet
    ${xpath_PduResource_e}   set variable
    ...   /nsetapx.${xpath1_pdusetup_result}upPduSessionResources//nsetapx.PduSessionResource${xpath2_pdusetup_result}upItem_element
    ${xpath_Qos_e}   set variable   /nsetapx.${xpath1_pdusetup_result}upQosFlows//nsetapx.QosFlow${xpath2_pdusetup_result}upItem_element
    ${xpath_QosP_e}   set variable   ${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_e}/nsetapx.qosParameters_element
    ${xpath_fiveQi}   set variable   /nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element
    ${PDUSetup_Items_list} =   wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.${xpath1_pdusetup_result}upPduSessionResources
    ${PDUSetup_Items_length}=  Get Length   ${PDUSetup_Items_list}
    ${snssai_sst_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sst
    ${snssai_sd_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sd
    ${pduSessionId_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionId
    ${pdu-A-Max_dl_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionAggregateMaximumBitRate_element/nsetapx.dlBitRate
    ${pdu-A-Max_ul_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionAggregateMaximumBitRate_element/nsetapx.ulBitRate
    ${qfi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_e}/nsetapx.qfi
    ${fiveQi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_QosP_e}${xpath_fiveQi}/nsetapx.fiveQi
    ${pdu_PL_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_QosP_e}/nsetapx.arp_element/nsetapx.priorityLevel
    ${pdu_PC_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_QosP_e}/nsetapx.arp_element/nsetapx.preemptionCapability
    ${pdu_PV_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_QosP_e}/nsetapx.arp_element/nsetapx.preemptionVulnerability
    Length Should Be   ${result_list}   ${trigger_list_length}
    Length Should Be   ${snssai_sst_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${snssai_sd_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${pduSessionId_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${pdu-A-Max_dl_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${pdu-A-Max_ul_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${qfi_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${fiveQi_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${pdu_PL_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${pdu_PC_list}   ${PDUSetup_Items_list}[0]
    Length Should Be   ${pdu_PV_list}   ${PDUSetup_Items_list}[0]
    ${Record_PDU_list}=   Create List
    Append To List   ${Record_PDU_list}   ${trigger_list}
    Append To List   ${Record_PDU_list}   ${result_list}
    FOR   ${idxy}    IN RANGE    0   ${PDUSetup_Items_list}[0]
        ${RecordPDU_subitem_list}=   Create List
        Append To List   ${RecordPDU_subitem_list}   ${pduSessionId_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${snssai_sst_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${snssai_sd_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${pdu-A-Max_dl_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${pdu-A-Max_ul_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${qfi_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${fiveQi_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${pdu_PL_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${pdu_PC_list}[${idxy}]
        Append To List   ${RecordPDU_subitem_list}   ${pdu_PV_list}[${idxy}]
        Append To List   ${Record_PDU_list}   ${RecordPDU_subitem_list}
    END
#    Append To List   ${Record_PDU_list}   ${RecordPDU_item_list}
    [Return]   ${Record_PDU_list}   ${PDUSetup_Items_list}

Get PDU Item Lists from Ngap
    [Arguments]   ${file_path}   ${ngapPDU_trigger}   ${ngap_ranueid}
    ${ngapPDU_filter}   set variable if   '${ngapPDU_trigger}' == 'InitialContext'   71   74
    ${ngapPDU_success_filter}   set variable if   '${ngapPDU_trigger}' == 'InitialContext'   72   75
    ${ngapPDU_xpath1}   set variable if   '${ngapPDU_trigger}' == 'InitialContext'   InitialContext   PDUSessionResource
    ${ngapPDU_xpath2}   set variable if   '${ngapPDU_trigger}' == 'InitialContext'   Cxt   SU
    ${xpath_IctxsetupR_e1}   set variable   .//ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element
    ${xpath_IctxsetupR_e2}   set variable    /ngap.${ngapPDU_xpath1}SetupRequest_element/ngap.protocolIEs
    ${xpath_IctxsetupR_e3}   set variable    //ngap.ProtocolIE_Field_element/ngap.value_element/ngap.PDUSessionResourceSetupList${ngapPDU_xpath2}Req
    ${xpath_IctxsetupR_e4}   set variable    //ngap.PDUSessionResourceSetupItem${ngapPDU_xpath2}Req_element
    ${xpath_IctxsetupR_E4}   set variable   ${xpath_IctxsetupR_e1}${xpath_IctxsetupR_e2}${xpath_IctxsetupR_e3}${xpath_IctxsetupR_e4}
    ${xpath_IctxsetupR_e5}   set variable   /ngap.pDUSessionResourceSetupRequestTransfer/ngap.PDUSessionResourceSetupRequestTransfer_element
    ${xpath_IctxsetupR_e6}   set variable   /ngap.protocolIEs//ngap.ProtocolIE_Field_element/ngap.value_element
    ${xpath_IctxsetupR_E6}   set variable   ${xpath_IctxsetupR_E4}${xpath_IctxsetupR_e5}${xpath_IctxsetupR_e6}
    ${xpath_IctxsetupR_bit}   set variable   /ngap.PDUSessionAggregateMaximumBitRate_element
    ${xpath_IctxsetupR_qos}   set variable   /ngap.QosFlowSetupRequestList//ngap.QosFlowSetupRequestItem_element
    ${xpath_IctxsetupR_qosP}   set variable   ${xpath_IctxsetupR_E6}${xpath_IctxsetupR_qos}/ngap.qosFlowLevelQosParameters_element
    ${xpath_IctxsetupR_5QI}   set variable   /ngap.qosCharacteristics/ngap.nonDynamic5QI_element/ngap.fiveQI
    ${xpath_IctxsetupR_arp}   set variable   ${xpath_IctxsetupR_qosP}/ngap.allocationAndRetentionPriority_element
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${file_path}
     ...                        any_expression=ngap.id == ${ngapPDU_success_filter}&&ip.dst == ${AMF_IP}&&ngap.RAN_UE_NGAP_ID == ${ngap_ranueid}
     ...                        filter=tcp.dstport==38412
    ${xpath_ngapsetupsuccess_e1}   set variable   .//ngap.NGAP_PDU/ngap.successfulOutcome_element/ngap.value_element
    ${xpath_ngapsetupsuccess_e2}   set variable    /ngap.${ngapPDU_xpath1}SetupResponse_element
    ${xpath_ngapsetupsuccess_e3}   set variable     /ngap.protocolIEs//ngap.ProtocolIE_Field_element/ngap.value_element
    ${xpath_ngapsetupsuccess_e4}   set variable    /ngap.PDUSessionResourceSetupList${ngapPDU_xpath2}Res
    ${ngap_pdusetup_success_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ngapsetupsuccess_e1}${xpath_ngapsetupsuccess_e2}${xpath_ngapsetupsuccess_e3}${xpath_ngapsetupsuccess_e4}

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${file_path}
     ...                        any_expression=ngap.id == ${ngapPDU_filter}&&ip.dst == ${LOCAL_SSH_ADDR}&&ngap.RAN_UE_NGAP_ID == ${ngap_ranueid}
     ...                        filter=tcp.dstport==38412
    ${ngap_pdusetup_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_e1}${xpath_IctxsetupR_e2}${xpath_IctxsetupR_e3}
    ${ngap_pdusetup_length}=  Get Length   ${ngap_pdusetup_list}
    ${ngap_pduSessionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E4}/ngap.pDUSessionID
    ${ngap_snssai_sst_list}=    wireshark.get_field_value_by_xpath      xpath=${xpath_IctxsetupR_E4}/ngap.s_NSSAI_element/ngap.sST
    ${ngap_snssai_sd_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E4}/ngap.s_NSSAI_element/ngap.sD
    ${ngap_pdu-A-M-bit_dl_list}=    wireshark.get_field_value_by_xpath
     ...    xpath=${xpath_IctxsetupR_E6}${xpath_IctxsetupR_bit}/ngap.pDUSessionAggregateMaximumBitRateDL
     ${ngap_pdu-A-M-bit_ul_list}=    wireshark.get_field_value_by_xpath
     ...    xpath=${xpath_IctxsetupR_E6}${xpath_IctxsetupR_bit}/ngap.pDUSessionAggregateMaximumBitRateUL
    ${ngap_qfi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E6}${xpath_IctxsetupR_qos}/ngap.qosFlowIdentifier
    ${ngap_fiveQi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_qosP}${xpath_IctxsetupR_5QI}
    ${ngap_P-L_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_arp}/ngap.priorityLevelARP
    ${ngap_P-C_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_arp}/ngap.pre_emptionCapability
    ${ngap_P-V_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_arp}/ngap.pre_emptionVulnerability
    ${ngap_PDU_list}=   Create List
#    ${ngapPDU_item_list}=   Create List
    FOR   ${idxy}    IN RANGE    0   ${ngap_pdusetup_list}[0]
        ${ngapPDU_subitem_list}=   Create List
        Append To List   ${ngapPDU_subitem_list}   ${ngap_pduSessionId_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_snssai_sst_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_snssai_sd_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_pdu-A-M-bit_dl_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_pdu-A-M-bit_ul_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_qfi_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_fiveQi_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_P-L_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_P-C_list}[${idxy}]
        Append To List   ${ngapPDU_subitem_list}   ${ngap_P-V_list}[${idxy}]
        Append To List   ${ngap_PDU_list}   ${ngapPDU_subitem_list}
    END
#    Append To List   ${ngap_PDU_list}   ${ngapPDU_item_list}
    [Return]   ${ngap_PDU_list}   ${ngap_pdusetup_list}   ${ngap_pdusetup_success_list}

Get nrcti of HO
    [Arguments]  ${HO_file_path}   ${filter_expression}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${HO_file_path}
    ...   any_expression=${filter_expression}
    ...   filter=tcp.dstport==${dcap_server_port}
    ${crnti_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_HO_list}   Remove Duplicates   ${crnti_list}
    [Return]  ${crnti_HO_list}

Get nrcti of Target and Source HO
    [Arguments]  ${HO_file_path}   ${target_expression}   ${source_expression}
    ${source_nrcti}   Get nrcti of HO   ${HO_file_path}   ${source_expression}
    ${target_nrcti}   Get nrcti of HO   ${HO_file_path}   ${target_expression}
    ${target_nrcti}   evaluate   [item for item in ${target_nrcti} if item not in ${source_nrcti}]
    [Return]  ${target_nrcti}   ${source_nrcti}

Get menbUeX2APId and sgnbUeX2APId from X2AP info
    [Arguments]  ${file_path}   ${xpath}=x2ap.SgNBModificationRequired_element   ${expression}=30
    ${X2AP_xpath_part1}   set variable   .//x2ap.X2AP_PDU/x2ap.initiatingMessage_element/x2ap.value_element/${xpath}
    ${X2AP_xpath_part2}   set variable   /x2ap.protocolIEs//x2ap.ProtocolIE_Field_element/x2ap.value_element/
    Load Pcap File with Filter any Expression
            ...   pcap_file=${file_path}
            ...   any_expression=x2ap.procedureCode == ${expression}
            ...   filter=tcp.dstport==${36422}

    ${menbUeX2APId_xpath}   set variable   ${X2AP_xpath_part1}${X2AP_xpath_part2}x2ap.UE_X2AP_ID
    ${menbUeX2APId_info_all}   wireshark.get_field_value_by_xpath   xpath=${menbUeX2APId_xpath}   attribute_name=showname
    ${menbUeX2APId_info}   Remove Duplicates   ${menbUeX2APId_info_all}

    ${sgnbUeX2APId_xpath}   set variable   ${X2AP_xpath_part1}${X2AP_xpath_part2}x2ap.SgNB_UE_X2AP_ID
    ${sgnbUeX2APId_info_all}   wireshark.get_field_value_by_xpath   xpath=${sgnbUeX2APId_xpath}   attribute_name=showname
    ${sgnbUeX2APId_info}   Remove Duplicates   ${sgnbUeX2APId_info_all}

    ${X2AP_menbUeX2APId_ID}   Create List
    FOR   ${item}   IN   @{menbUeX2APId_info}
        ${id_info}   Should Match Regexp   ${item}   ID.*
        ${id}   Should Match Regexp   ${id_info}    \\d+
        Append To List   ${X2AP_menbUeX2APId_ID}   ${id}
    END

    ${X2AP_sgnbUeX2APId_ID}   Create List
    FOR   ${item}   IN   @{sgnbUeX2APId_info}
        ${id_info}   Should Match Regexp   ${item}   ID.*
        ${id}   Should Match Regexp   ${id_info}    \\d+
        Append To List   ${X2AP_sgnbUeX2APId_ID}   ${id}
    END
    [Return]  ${X2AP_menbUeX2APId_ID}   ${X2AP_sgnbUeX2APId_ID}

Get Bearer List from F1AP
    [Arguments]  ${file_path}   ${f1ap_setormod}   ${f1ap_CUUE_id}
    ${request_typeID}   set variable if   '${f1ap_setormod}' == 'set'   35   37
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${file_path}
     ...                        any_expression=f1ap.id == ${request_typeID}&&f1ap.GNB_CU_UE_F1AP_ID == ${f1ap_CUUE_id}
     ...                        filter=sctp.dstport==38472
    ${request_type}   set variable if   '${f1ap_setormod}' == 'set'   Setup   Modification
    ${drb_request_type}   set variable if   '${f1ap_setormod}' == 'set'   Setup   SetupMod
    ${xpath_uectxreq_e1}   set variable
    ...   .//f1ap.F1AP_PDU/f1ap.initiatingMessage_element/f1ap.value_element/f1ap.UEContext${request_type}Request_element
    ${xpath_uectxreq_e2}   set variable   /f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.DRBs_ToBe${drb_request_type}_List
    ${xpath_uectxreq_e3}   set variable   //f1ap.ProtocolIE_SingleContainer_element/f1ap.value_element/f1ap.DRBs_ToBe${drb_request_type}_Item_element
    ${xpath_uectxreq_e4}   set variable   /f1ap.qoSInformation/f1ap.choice_extension_element/f1ap.value_element/f1ap.DRB_Information_element
    ${xpath_uectxreq_A4}   set variable   ${xpath_uectxreq_e1}${xpath_uectxreq_e2}${xpath_uectxreq_e3}${xpath_uectxreq_e4}
    ${xpath_uectxreq_qos}   set variable   ${xpath_uectxreq_A4}/f1ap.dRB_QoS_element/
    ${xpath_qoS-C}   set variable   /f1ap.qoS_Characteristics/f1ap.non_Dynamic_5QI_element
    ${xpath_nGR-P}   set variable   /f1ap.nGRANallocationRetentionPriority_element
    ${xpath_map}   set variable   /f1ap.flows_Mapped_To_DRB_List//f1ap.Flows_Mapped_To_DRB_Item_element
    ${xpath_map_qos}   set variable   ${xpath_map}/f1ap.qoSFlowLevelQoSParameters_element
    ${f1ap_beareritems_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_e1}${xpath_uectxreq_e2}
    ${f1ap_beareritems_length}=  Get Length   ${f1ap_beareritems_list}
    ${f1ap_DRBID_list}=     wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_e1}${xpath_uectxreq_e2}${xpath_uectxreq_e3}/f1ap.dRBID
    ${f1ap_qosC_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_qos}/f1ap.qoS_Characteristics
    ${f1ap_5QI_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_qos}${xpath_qoS-C}/f1ap.fiveQI
    ${f1ap_P-L_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_qos}${xpath_nGR-P}/f1ap.priorityLevel
    ${f1ap_P-E-C_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_qos}${xpath_nGR-P}/f1ap.pre_emptionCapability
    ${f1ap_P-E-V_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_qos}${xpath_nGR-P}/f1ap.pre_emptionVulnerability
    ${f1ap_sst_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_A4}/f1ap.sNSSAI_element/f1ap.sST
    ${f1ap_sd_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_A4}/f1ap.sNSSAI_element/f1ap.sD
    ${f1ap_mapqosC_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_A4}${xpath_map_qos}/f1ap.qoS_Characteristics
    ${f1ap_QFI_list}=     wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_A4}${xpath_map}/f1ap.qoSFlowIdentifier
    ${f1ap_map5QI_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_A4}${xpath_map_qos}${xpath_qoS-C}/f1ap.fiveQI
    ${f1ap_mapP-L_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_A4}${xpath_map_qos}${xpath_nGR-P}/f1ap.priorityLevel
    ${f1ap_mapP-E-C_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_uectxreq_A4}${xpath_map_qos}${xpath_nGR-P}/f1ap.pre_emptionCapability
    ${f1ap_mapP-E-V_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_uectxreq_A4}${xpath_map_qos}${xpath_nGR-P}/f1ap.pre_emptionVulnerability
    ${f1apBearear_list}=   Create List
    FOR   ${idx}    IN RANGE    0   ${f1ap_beareritems_list}[0]
        ${f1apBearear_item_list}=   Create List
        Append To List   ${f1apBearear_item_list}   ${f1ap_DRBID_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_qosC_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_5QI_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_P-L_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_P-E-C_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_P-E-V_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_QFI_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_mapqosC_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_map5QI_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_mapP-L_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_mapP-E-C_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_mapP-E-V_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_sst_list}[${idx}]
        Append To List   ${f1apBearear_item_list}   ${f1ap_sd_list}[${idx}]
        Append To List   ${f1apBearear_list}   ${f1apBearear_item_list}
    END
    [Return]   ${f1apBearear_list}

Get Bearer List from DUBearer Record
    [Arguments]  ${file_path}  ${Filter_expression_record}   ${expected_drb_items}
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${file_path}
     ...                        any_expression=${Filter_expression_record}
     ...                        filter=sctp.dstport==${dcap_server_port}
    ${xpath_dubear}   set variable   .//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.setupBearers//nsetapx.DuBearerDataSetupItem_element
    ${xpath_Qos}   set variable   /nsetapx.qosInformation/nsetapx.nr_Qos_element
    ${xpath_drbQos}   set variable   /nsetapx.drbLevelQos_element/nsetapx.qosCharacteristics
    ${xpath_arp}   set variable   /nsetapx.drbLevelQos_element/nsetapx.arp_element/nsetapx.
    ${xpath_5qi}   set variable   /nsetapx.nonDynamicFiveQiDescriptor_element/nsetapx.fiveQi
    ${xpath_map_QOS}   set variable   ${xpath_dubear}${xpath_Qos}/nsetapx.qosFlowsMappedToBearer//nsetapx.DuQosFlowMappedToBearerItem_element
    ${xpath_map_QOSP}   set variable   /nsetapx.qosParameters_element/nsetapx.qosCharacteristics
    ${xpath_map_arp}   set variable   /nsetapx.qosParameters_element/nsetapx.arp_element/nsetapx.
    ${trigger_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.trigger
    ${beareritems_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.setupBearers
    ${DRB ID_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear}/nsetapx.drb_Id
    ${qosC_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear}${xpath_Qos}${xpath_drbQos}
    ${5QI_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear}${xpath_Qos}${xpath_drbQos}${xpath_5qi}
    ${Priority level_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear}${xpath_Qos}${xpath_arp}priorityLevel
    ${Pre-emption capability_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear}${xpath_Qos}${xpath_arp}preemptionCapability
    ${Pre-emption vulnerability_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_dubear}${xpath_Qos}${xpath_arp}preemptionVulnerability
    ${map_QFI_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_map_QOS}/nsetapx.qfi
    ${map_qosC_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_map_QOS}${xpath_map_QOSP}
    ${map_5QI_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_map_QOS}${xpath_map_QOSP}${xpath_5qi}
    ${map_P-L_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_map_QOS}${xpath_map_arp}priorityLevel
    ${map_P-E-C_list}=    wireshark.get_field_value_by_xpath  xpath=${xpath_map_QOS}${xpath_map_arp}preemptionCapability
    ${map_P-E-V_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_map_QOS}${xpath_map_arp}preemptionVulnerability
    ${snssai_sst_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear}${xpath_Qos}/nsetapx.snssai_element/nsetapx.sst
    ${snssai_sd_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear}${xpath_Qos}/nsetapx.snssai_element/nsetapx.sd
    ${timestaps_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.timestamp_element/nsetapx.seconds
    ${timestapus_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.timestamp_element/nsetapx.useconds
    Should Be True   ${beareritems_list}[0] == ${expected_drb_items}
    Length Should Be   ${trigger_list}   1
    Length Should Be   ${DRB ID_list}   ${expected_drb_items}
    Length Should Be   ${qosC_list}   ${expected_drb_items}
    Length Should Be   ${5QI_list}   ${expected_drb_items}
    Length Should Be   ${map_QFI_list}   ${expected_drb_items}
    Length Should Be   ${Priority level_list}   ${expected_drb_items}
    Length Should Be   ${Pre-emption capability_list}   ${expected_drb_items}
    Length Should Be   ${Pre-emption vulnerability_list}   ${expected_drb_items}
    Length Should Be   ${map_qosC_list}   ${expected_drb_items}
    Length Should Be   ${map_5QI_list}   ${expected_drb_items}
    Length Should Be   ${map_P-L_list}   ${expected_drb_items}
    Length Should Be   ${map_P-E-C_list}   ${expected_drb_items}
    Length Should Be   ${map_P-E-V_list}   ${expected_drb_items}
    Length Should Be   ${snssai_sst_list}   ${expected_drb_items}
    Length Should Be   ${snssai_sd_list}   ${expected_drb_items}
    ${DUBearear_list}=   Create List
    FOR   ${idx}    IN RANGE    0   ${expected_drb_items}
        ${DUBearear_item_list}=   Create List
        Append To List   ${DUBearear_item_list}   ${DRB ID_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${qosC_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${5QI_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${Priority level_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${Pre-emption capability_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${Pre-emption vulnerability_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${map_QFI_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${map_qosC_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${map_5QI_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${map_P-L_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${map_P-E-C_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${map_P-E-V_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${snssai_sst_list}[${idx}]
        Append To List   ${DUBearear_item_list}   ${snssai_sd_list}[${idx}]
        Append To List   ${DUBearear_list}   ${DUBearear_item_list}
    END
    [Return]   ${DUBearear_list}   ${trigger_list}

Check Field Value By Xpath
    [Arguments]   ${xpath}=${EMPTY}
    ${xpath_Output}    wireshark.get_field_value_by_xpath   ${xpath}
    Should Be True    ${xpath_Output}
    [Return]    ${xpath_Output}

Get nrcti of Target and Source in NSA intra HO
    [Arguments]  ${HO_file_path}
    ${ueMeasRecord_nrcti}   Get nrcti of HO   ${HO_file_path}   nsetapx.CuVendorExtensionRecordDataType == 3
    ${source_nrcti}   Get nrcti of HO   ${HO_file_path}   nsetapx.CuVendorExtensionRecordDataType == 8
    ${source_nrcti}   evaluate   [item for item in ${source_nrcti} if item in ${ueMeasRecord_nrcti}]
    ${target_nrcti}   Get nrcti of HO   ${HO_file_path}   nsetapx.CuVendorExtensionRecordDataType == 9
    ${target_nrcti}   evaluate   [item for item in ${target_nrcti} if item not in ${source_nrcti}]
    [Return]  ${target_nrcti}   ${source_nrcti}
