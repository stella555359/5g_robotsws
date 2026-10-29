*** Settings ***
Library    taf.transport.ssh    WITH NAME    csn
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Library    Process
Library    taf.converters.eventdecoder    WITH NAME    ctti
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu


*** Variables ***
${CU_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${DU_IP}              ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${DU_username}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
${DU_password}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
${DU_OAM_IP}          ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${DU_OAM_username}    ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${DU_OAM_password}    ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
${TEST_PC_IP}         ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}   ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}   ${tl.test_pc.default_ssh_connection_details.password}
@{cell_list}    ${GNB_CELL_NAME}2    ${GNB_CELL_NAME}3    ${GNB_CELL_NAME}4    ${GNB_CELL_NAME}12    ${GNB_CELL_NAME}5    ${GNB_CELL_NAME}14

${tcpdump_filter}       nr-rrc.physCellId && nr-rrc.newUE_Identity
&{Non_CA_eligible}     ${5}=NonCA    ${7}=NonCA

${NRBTS}              ${GNB_NR_BTS_NAME}
${tl_name}            tl37519
${vdu_namespace}      cranl37519
${GAP_Acceptable}    2000

&{A_DL_Counters}    RLC_PDU_VOL_TX_NON_CA_SA=M55310C02021
...                 RLC_PDU_VOL_TX_PRI_SA_CA=M55310C02022
...                 RLC_PDU_VOL_TX_SEC_SA_CA_FR1=M55349C00022
...                 RLC_PDU_VOL_TX_SCELL_SA_CA=M55310C02024
...                 NR_RLC_PDU_DL_VOL_CA_PCELL=M55310C20001
...                 NR_RLC_PDU_DL_VOL_CA_SCELL=M55310C20000
...                 RLC_PDU_VOL_TX_NON_CA_NSA=M55310C02025
...                 RLC_PDU_VOL_TX_PRI_NSA_CA=M55310C02026
...                 RLC_PDU_VOL_TX_SEC_NSA_CA_FR1=M55349C00024
...                 RLC_PDU_VOL_TX_SCELL_NSA_CA=M55310C02028

&{A_UL_Counters}    RLC_PDU_VOL_RX_NON_CA_SA=M55310C02029
...                 RLC_PDU_VOL_RX_PRI_SA_CA=M55310C02030
...                 RLC_PDU_VOL_RX_SEC_SA_CA_FR1=M55349C00025
...                 RLC_PDU_VOL_RX_SCELL_SA_CA=M55310C02032
...                 UL_RLC_PDU_VOL_RX_PRI_PATH=M55316C14001
...                 UL_RLC_PDU_VOL_RX_SEC_PATH=M55316C14002
...                 RLC_PDU_VOL_RX_NON_CA_NSA=M55310C02033
...                 RLC_PDU_VOL_RX_PRI_NSA_CA=M55310C02034
...                 RLC_PDU_VOL_RX_SCELL_NSA_CA=M55310C02036

&{C_DL_Counters}    DL_RLC_PDU_VOL_UE_TPUT=M55349C03002
...                 DL_RLC_PDU_TIME_UE_TPUT=M55349C04002
...                 DL_MAC_SDU_VOL_UE_TPUT=M55309C00002
...                 DL_MAC_SDU_TIME_UE_TPUT=M55309C00003
...                 DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-7=M55353C00002
...                 DL_RLC_PDU_TIME_UE_TPUT_NRPMQAP-7=M55353C00003
...                 DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-5=M55353C00002
...                 DL_RLC_PDU_TIME_UE_TPUT_NRPMQAP-5=M55353C00003
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_1CC=M55349C00026
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_2CC=M55349C00027
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_3CC=M55349C00028
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_4CC=M55349C00029
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_5CC=M55349C00030
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_1CC=M55349C00032
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_2CC=M55349C00033
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_3CC=M55349C00034
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_4CC=M55349C00035
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_5CC=M55349C00036
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_1CC=M55349C00038
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_2CC=M55349C00039
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_1CC=M55349C00040
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_2CC=M55349C00041

&{C_UL_Counters}    UL_RLC_VOL_UE_TPUT_FR1_SA_1CC=M55349C00042
...                 UL_RLC_VOL_UE_TPUT_FR1_SA_2CC=M55349C00043
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_1CC=M55349C00044
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_2CC=M55349C00045
...                 UL_RLC_TIME_UE_TPUT=M55349C04001
...                 UL_RLC_VOL_UE_TPUT_TOT=M55349C03001

&{D_DL_Counters}    DL_RLC_PDU_UE_TPUT_DENOM_FR1=M55349C00046

*** Keywords ***
Check vdu counter update
    [Arguments]    ${counter_id}=${counterid}    ${counter_dist_name}=counter_name    ${connection}=DU
    ${counter_result}=vdu.Get Counter    Values counter_id=${counter_id}, dimension_dn=${counter_dist_name}, vdu_connection=${connection}
    Should Be True    ${counter_result}>=1

Verify emf info in CP log
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    [Arguments]    ${syslog_filename}=CPRT_SYSLOG    ${ute_logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${du_cprt_syslog_path}    Download syslog from DU    remote_path=/tmp    syslog_filename=CPRT_SYSLOG
    ${full_log_name}    set variable     ${ute_logpath}/${syslog_filename}
    ${output}    OperatingSystem.Run    cat ${full_log_name}.txt |grep -i "NrBeamEMF"|wc -l
    Should Be True    ${output}>=1

Verify emf info in PS log
    [Arguments]    ${syslog_filename}=L2RT_SYSLOG    ${ute_logpath}=${OUTPUT_DIR}/${TEST NAME}
    Log To Console    \nCheck 10944 feature is activated...
    ${du_cprt_syslog_path}    Download syslog from DU    remote_path=/tmp    syslog_filename=L2RT_SYSLOG
    ${output}    OperatingSystem.Run    cat ${du_cprt_syslog_path}/${syslog_filename}.txt |grep -i
... "ArtificialLoadConfigResp result=ESTATUS5G_OK"|wc -l
    Should Be True    ${output}>=1

Start SYSLOG On DU And Tcpdump On CU
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    Start Capture tcpdump on vCU    pcap_filename=tcpdump_cplane_cu
    Start Capture SYSLOG on vDU    component=${tl_name} po-${tl_name}-l2rt-0    syslog_filename=L2RT_SYSLOG    module=ctr-${tl_name}-l2rt
    Start Capture SYSLOG on vDU    component=${tl_name} po-${tl_name}-l2nrt-0    syslog_filename=L2HI_SYSLOG    module=ctr-${tl_name}-l2hi

Stop SYSLOG On DU And Tcpdump On CU
    Stop Capture tcpdump on vCU
    Stop Capture SYSLOG on vDU    component=${tl_name} po-${tl_name}-l2rt-0    module=ctr-${tl_name}-l2rt
    Stop Capture SYSLOG on vDU    component=${tl_name} po-${tl_name}-l2nrt-0    module=ctr-${tl_name}-l2hi

Dowload SYSLOG And Tcpdump
    [Arguments]    ${filter}=${tcpdump_filter}
    Download tcpdump from CU    pcap_filename=tcpdump_cplane_cu
    ${du_l2rt_syslog_path}    Download syslog from DU    remote_path=/tmp    syslog_filename=L2RT_SYSLOG
    ${du_l2hi_syslog_path}    Download syslog from DU    remote_path=/tmp    syslog_filename=L2HI_SYSLOG
    ${txt_path}    Convert pcap to text    pcap_filename=tcpdump_cplane_cu    filter=${filter}
    [Return]    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}

Analysis SYSLOG And Tcpdump
    [Arguments]    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}
    get_dl_tput_from_syslog    path=${du_l2rt_syslog_path}
    get_ul_tput_from_syslog    path=${du_l2rt_syslog_path}
    ${ca_info}    get_rnti_and_ca_info    txt_file_path=${txt_path}
    log to console    [ca_info]:\n ${ca_info}
    [Return]    ${ca_info}
    
Start Capture SYSLOG on vDU
    [Arguments]    ${po_name}=po-${vdu_namespace}-l2rt-a-0    ${syslog_filename}=L2RT_SYSLOG
    ...    ${connection}=DU    ${module}=ctr-${vdu_namespace}-l2rt
    ${component}    Evaluate    '${vdu_namespace} ${po_name}'
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    csn.send_command
    ...    command=kubectl logs -f -n ${component} --since=1s -c ${module} > /tmp/${syslog_filename}.txt &
    ...    connection=${connection}
    sleep    2s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Stop Capture SYSLOG on vDU
    [Arguments]    ${po_name}=po-${vdu_namespace}-l2rt-a-0    ${module}=ctr-${vdu_namespace}-l2rt    ${connection}=DU
    ${component}    Evaluate    '${vdu_namespace} ${po_name}'
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${output}    csn.execute
    ...    command=ps -ef | grep kubectl | grep '${component}' | grep '${module}' | awk '{print $2}'
    ...    connection=${connection}
    ${trace_id_list}    Strip String    string=${output}
    ${trace_id_list}    Split String    string=${output}    separator=\r\n
    log to console    \nfind pid: ${trace_id_list}
    FOR   ${trace_id}    IN    @{trace_id_list}
        ${output}    Run Keyword If    '${trace_id}'!=''    csn.execute    kill -9 ${trace_id.strip()}    connection=${connection}
        Run Keyword If    '${trace_id}'!=''    log to console    kill id: ${trace_id}
        sleep    1s
    END
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Start Capture tcpdump on vDU
    [Arguments]    ${component}=po-${tl_name}-l2rt-0    ${pcap_filename}=tcpdump_cplane_du    ${connection}=DU
    ...    ${module}=ctr-${tl_name}-nwmgmt
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${command_str}    set variable
    ...    kubectl exec ${component} -c ${module} -n ${tl_name} -- nohup tcpdump -i any sctp -n -w - > /var/home/${tl_name}/${pcap_filename}.pcap &
    csn.send_command    command=${command_str}    connection=${connection}
    sleep    2s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Stop Capture tcpdump on vDU
    [Arguments]  ${connection}=DU
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${output}    csn.execute    command=ps -ef | grep kubectl | awk '{print $2}'    connection=${connection}
    ${trace_id_list}    Strip String    string=${output}
    ${trace_id_list}    Split String    string=${output}    separator=\r\n
    log to console    \nfind pid: ${trace_id_list}
    FOR   ${trace_id}    IN    @{trace_id_list}
        ${output}    Run Keyword If    '${trace_id}'!=''    csn.execute    kill -9 ${trace_id.strip()}    connection=${connection}
        Run Keyword If    '${trace_id}'!=''    log to console    kill id: ${trace_id}
        sleep    1s
    END
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
        
Download tcpdump from DU
    [Arguments]    ${pcap_filename}    ${connection}=DU    ${ute_logpath}=${OUTPUT_DIR}/${TEST NAME}
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${log_full_path_ute}    set variable     ${ute_logpath}/${pcap_filename}.pcap
    csn.download_file   rem
    ote_path=/var/home/${tl_name}/${pcap_filename}.pcap   local_path=${log_full_path_ute}   connection=${connection}
    Wait Until Keyword Succeeds   2min   2s    OperatingSystem.File Should Exist    ${log_full_path_ute}
    #    csn.execute    command=rm /tmp/${filename}.pcap    connection=${connection}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Download syslog from DU
    [Arguments]    ${syslog_filename}=L2Lo_tput    ${connection}=DU    ${ute_logpath}=${OUTPUT_DIR}/${TEST NAME}
    ...    ${remote_path}=/var/home/core
    csn.connect_to   hostname=${DU_IP}    username=${DU_username}    password=${DU_password}    alias=${connection}
    sleep    1s
    ${log_full_path_ute}    set variable     ${ute_logpath}/${syslog_filename}
    csn.download_file   remote_path=${remote_path}/${syslog_filename}.txt   local_path=${log_full_path_ute}.txt   connection=${connection}
    # Wait Until Keyword Succeeds   2min   2s    OperatingSystem.File Should Exist    ${log_full_path_ute}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Convert pcap to text
    [Arguments]    ${pcap_filename}    ${filter}    ${connection}=ute    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${source}      set variable     ${logpath}/${pcap_filename}.pcap
    ${target}      set variable     ${logpath}/${pcap_filename}.txt
    csn.connect_to   hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    csn.send_command
    ...  command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    Wait Until Keyword Succeeds   2min   2s    OperatingSystem.File Should Exist    ${target}
    [Return]    ${target}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Get L2stream logs using cOAM cli from vDU
    [Documentation]    https://confluence.ext.net.nokia.com/display/CV/%5Bdeprecated%5D+L2stream3_Collectors+Example
    ...    (L2Lo, L2Ps, L2HiRlc, L2HiPdcp)
    [Arguments]    ${collectors_name}=l2stream    ${component}=L2Lo    ${output_path}=${OUTPUT_DIR}/${TEST NAME}/
    ...    ${cell_dn_list}=${cell_list}
    ${webservice}=  Create Dictionary
    ...  host=${DU_OAM_IP}
    ...  user=${DU_OAM_username}
    ...  password=${DU_OAM_password}
    ${l2lo_stream_config}=  Create Dictionary
    ...  trace_type=Component
    ...  target_component=${component}
    ...  nr_cell_dn_list=${cell_dn_list}
    @{l2_stream_configuration}    Create List    ${l2lo_stream_config}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth0 udp and dst ${TEST_PC_IP} and dst port 5678
    ...  sudo_password=${TEST_PC_PASSWORD}
    l2stream3.create vdu l2stream collector
    ...  name=${collectors_name}
    ...  webservice=${webservice}
    ...  destination_ip_addr=${TEST_PC_IP}
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  timeout=60
    run keyword and ignore error     core.stop_collectors      names=${collectors_name}
    run keyword and ignore error     core.teardown_collectors      names=${collectors_name}
    core.setup_collectors      names=${collectors_name}
    log to console    start capture.
    core.start_collectors      names=${collectors_name}
    core.set_suite_alias    alias=${collectors_name}
    [Return]    ${output_path}l2stream/tcpdump/tcpdump.pcap

Stop Capture L2TTI Trace
    [Arguments]    ${collectors_name}=l2stream    ${output_path}=${OUTPUT_DIR}/${TEST NAME}/
    log to console    stop capture
    core.stop_collectors      names=${collectors_name}
    core.collect_collectors      names=${collectors_name}    target_dir=${output_path}
    log to console    end
    [Return]    ${output_path}l2stream/tcpdump/tcpdump.pcap
    [Teardown]    core.teardown_collectors      names=${collectors_name}

Decode TTI Traces from PCAP or BIN
    [Documentation]    Decodes TTI Traces from PCAP or BIN file to output files in CSV or JSON format.
    ...                Program ``/opt/tti-dec/tti-dec-bin/bin/eventDecoder`` is used for legacyCsv and json conversion.
    ...                Script ``/opt/tti-dec/tti-dec-bin/outputGenerator/excelCsv/ExcelCsvGenerator.py`` is used for
    ...                excelCsv conversion.
    ...                - ``input_filepath``: Path to input PCAP or BIN file
    ...                - ``output_path``: Path to output directory, Default: Same as input file
    ...                - ``output_name``: Prefix name of the output files, Default: ttitrace
    ...                - ``format``: json, legacyCsv or excelCsv, Default: legacyCsv
    ...                - ``conversion_filter``: Regular expression for filtering TTI event type, Default: None
    ...                - ``excel_csv_options``: Options for ExcelCsvGenerator.py script, Default: None
    [Arguments]    ${input_filepath}    ${output_path}=${Empty}    ${output_name}=ttitrace    ${format}=legacyCsv
    ...    ${conversion_filter}=${None}    ${excel_csv_options}=${None}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${input_filepath}
    ${match}    ${dir}    @{rest}    Should Match Regexp    ${input_filepath}    ^(.*/)([^/]+)\\.(pcap|bin)$
    ...    msg=Invalid KW parameter: input_filepath
    Should Be True    '${format}' in ('json','legacyCsv','excelCsv')    msg=Invalid KW parameter: format
    #---------------------------------------------------------------------------------------------------------------
    ${output_path}    Set Variable If    '${output_path}' == ''    ${dir}    ${output_path}
    ${output_file_path}    Set Variable    ${output_path}/${output_name}
    ctti.create_eventdecoder_converter
    ...    name=tti_converter
    ...    input_file_path=${input_filepath}
    ...    output_file_path=${output_file_path}
    ...    output_file_format=${format}
    ...    conversion_filter=${conversion_filter}
    ...    excel_csv_options=${excel_csv_options}
    Log to Console    Decoding TTI Traces...
    ${status}    ${msg}    Run Keyword And Ignore Error    ctti.convert    tti_converter
    Run Keyword If    '${status}' == 'FAIL'    Fail
    ...    Error decoding TTI Traces. Ensure the decoder version matches the BTS build version.${\n}${msg}
    ${ext}    Set Variable If    'Csv' in '${format}'    csv    json
    ${files}    Find Files    ${output_path}   -name    '*.${ext}'    fail_on_empty=yes    return=dict
    [Return]    ${files}

Run Process And Expect Success
    [Documentation]    Runs a process and fails if return status is not 0. Returns result object.
    ...                - ``process``: Process name
    ...                - ``params``: Process parameters as list
    ...                - ``shell``: Specifies whether to run the command in shell, Default: True
    ...                - ``msg``: Custom fail message, Default: Standard message
    ...                - ``config``: Additonal process configuration,\
    ...                See: https://robotframework.org/robotframework/3.1.2/libraries/Process.html#Process%20configuration
    [Arguments]    ${process}    @{params}    ${shell}=${True}    ${msg}=${Empty}    &{config}
    ${result}    Run Process    ${process}    @{params}    shell=${shell}    &{config}
    Log    stdout: ${result.stdout}${\n}stderr: ${result.stderr}${\n}rc: ${result.rc}    level=DEBUG
    ${mlen}    Get Length    ${msg}
    ${msg}    Set Variable If    ${mlen} == 0    Error running ${process} @{params}    ${msg}
    ${msg}    Set Variable    ${msg}${\n}stdout: ${result.stdout}${\n}stderr: ${result.stderr}
    Should Be Equal As Integers    ${result.rc}    0    values=${False}    msg=${msg}
    [Return]    ${result}

Find Files
    [Documentation]    Searches for files in directory hierarchy via ``find`` command and returns a list of files.
    ...                WARNING: Do not pass unquoted wildcards into search patterns (Use: ``-name '*.json'``, not: ``-name *.json``).
    ...                Use single-quotes only.
    ...                - ``dir``: Directory to search in
    ...                - ``params``: List of search parameters for ``find`` command, See: https://manpages.org/find
    ...                - ``fail_on_empty``: If keyword should fail when no files are found, Default: no
    ...                - ``return``: Type of return data: list or dict, Default: list
    [Arguments]    ${dir}    @{params}    ${fail_on_empty}=no    ${return}=list
    #--------- Param check -----------------------------------------------------------------------------------------
    Directory Should Exist    ${dir}
    Should Be True    '${fail_on_empty}' in ('yes','no')    msg=Invalid KW parameter: fail_on_empty
    Should Be True    '${return}' in ('list','dict')    msg=Invalid KW parameter: return
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Create List    find    ${dir}    -type    f    @{params}
    ${result}    Run Process And Expect Success    @{cmd}
    ${list}    Split To Lines    ${result.stdout}
    Run Keyword If    '${fail_on_empty}' == 'yes'    Should Not Be Empty    ${list}
    ...    msg=No files were found using command: @{cmd}
    ${dict}    Create Dictionary
    FOR    ${path}    IN    @{list}
      ${dir}    ${filename}    Split Path    ${path}
      ${name}    ${ext}    Split Extension    ${filename}
      Set To Dictionary    ${dict}    ${name}=${path}
    END
    ${files}    Set Variable If    '${return}' == 'dict'    ${dict}    ${list}
    [Return]    ${files}

Get VDU PM Counters
    [Arguments]    ${counter_id_dict}    ${dist_name}    ${connection}=vdu_pm
    Log to console    get ${dist_name} counters from webui.
    vdu.connect_to    host=${DU_OAM_IP}    port=443   secure=${True}
    ...    username=${DU_OAM_username}    password=${DU_OAM_password}    connection_name=${connection}
    ${counter_id_list}    get dictionary keys    ${counter_id_dict}
    ${counter_value}    Create dictionary
    FOR    ${counter_name}    IN    @{counter_id_list}
        ${counter_id}    set variableFrom Right    ${counter_name}    marker=_
        ${counter_dist_name}     set    ${counter_id_dict}[${counter_name}]
        ${last_word}    String.Fetch  variable if    'PMQAP' in '${counter_name}'    ${dist_name}/${last_word}    ${dist_name}
        ${counter_result}    vdu.get_counter_values
        ...    counter_id=${counter_id}
        ...    dimension_dn=${counter_dist_name}
        ...    vdu_connection=${connection}
        set to dictionary    ${counter_value}    ${counter_name}=${counter_result}
    END
    [Return]   ${counter_value}
    [Teardown]    run keyword and ignore error    vdu.disconnect    vdu_connection=${connection}

Get VDU PM Counters Latest period time
    [Arguments]    ${counter_id_dict}    ${connection}=vdu_pm
    ${dist_name}    set variable    ${cell_list}[${0}]
    vdu.connect_to    host=${DU_OAM_IP}    port=443   secure=${True}
    ...    username=${DU_OAM_username}    password=${DU_OAM_password}    connection_name=${connection}
    ${counter_id_list}    get dictionary keys    ${counter_id_dict}
    ${counter_last_period_time_dict}    Create dictionary
    ${counter_start_time}    set variable    now
    FOR    ${counter_name}    IN    @{counter_id_list}
        ${counter_id}    set variable    ${counter_id_dict}[${counter_name}]
        ${counter_result}    vdu.get_counter_values
        ...    counter_id=${counter_id}
        ...    dimension_dn=${dist_name}
        ...    vdu_connection=${connection}
        ${counter_start_time}    _get_pm_data_strat_time    counter_result=${counter_result}
        Exit For Loop
    END
    set to dictionary    ${counter_last_period_time_dict}    start_time=${counter_start_time}
    [Return]   ${counter_last_period_time_dict}
    [Teardown]    run keyword and ignore error    vdu.disconnect    vdu_connection=${connection}

_get_pm_data_strat_time
    [Arguments]    ${counter_result}
    ${counter_start_time}    set variable    now
    ${counter_length}    Get Length    ${counter_result}
    FOR    ${i}    IN RANGE    ${counter_length}-1    ${-1}    ${-1}
        ${counter_start_time}    set variable    ${counter_result}[${i}][start_time]
        Exit For Loop
    END
    [Return]    ${counter_start_time}


###### From pengliang CB010636 robot #######
Get A_Counter From MacSubPdu Csv Log
    [Arguments]    ${csv_path}    ${ca_info}    ${direction}=dl    ${isDefaultCA}=${True}
    dealCounter.setCsvPath    csv_path=${csv_path}
    dealCounter.getMacSubPduAm18    caInfo=${ca_info}    channelInfo=${Non_CA_eligible}    isDefaultCA=${isDefaultCA}

Get C_Counter From MacPduMuxReq Csv Log
    [Arguments]    ${csv_path}    ${ca_info}    ${direction}=dl
    dealCounter.setCsvPath    csv_path=${csv_path}
    dealCounter.get_mac_sdu_value_from_L2LO_ttitrace_log
    dealCounter.get_RLC_value_from_L2LO_ttitrace_log    path=${OUTPUT_DIR}/${TEST NAME}    ca_info=${ca_info}
    dealCounter.get_RLC_per_CC_DL_counters    path=${OUTPUT_DIR}/${TEST NAME}    ca_info=${ca_info}    output_path=${OUTPUT_DIR}/${TEST NAME}

Get D_Counter From MacPduMuxReq Csv Log
    [Arguments]    ${csv_path}    ${ca_info}    ${direction}=dl
    dealCounter.setCsvPath    csv_path=${csv_path}
    dealCounter.get_RLC_time_DENOM_from_L2LO_tti    ca_info=${ca_info}

Check CB010636_A Counter between Log and Webui
    [Arguments]    ${csv_path}    ${ca_info}    ${counter_dict}    ${before_counter_time}    ${direction}=dl    ${isDefaultCA}=${True}
    log to console    \n[Get CB010636-A ${direction} counters from TTI]:
    Log to console    TTI Path: ${csv_path}
    Get A_Counter From MacSubPdu Csv Log    csv_path=${csv_path}    ca_info=${ca_info}    direction=${direction}    isDefaultCA=${isDefaultCA}
    log to console    \n[Get CB010636-A ${direction} counters from WEBUI]:
    ${all_cell_counter_dict}    Get All NRCELL Counter From VDU    counter_dict=${counter_dict}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    ${result}    dealCounter.checkCounters    OamCounterData=${all_cell_counter_dict}    outputpath=${OUTPUT_DIR}/${TEST NAME}/
    ...    gap=${GAP_Acceptable}
    Run Keyword And Continue On Failure    Should be true    ${result}    msg=CB010636_A Some ${direction} Counters eroor

Check CB010636_C Counter between Log and Webui
    [Arguments]    ${csv_path}    ${ca_info}    ${counter_dict}    ${before_counter_time}    ${direction}=dl    ${percc_flag}=${True}
    log to console    \n[Get CB010636-C ${direction} counters from TTI]:
    Log to console    TTI Path: ${csv_path}
    Get C_Counter From MacPduMuxReq Csv Log    csv_path=${csv_path}    ca_info=${ca_info}    direction=${direction}
    log to console    \n[Get CB010636-C ${direction} counters from WEBUI]:
    ${all_cell_counter_dict}    Get All NRCELL Counter From VDU    counter_dict=${counter_dict}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    ${burst_length}    dealCounter.getBurstLength
    log to console    burst_length: ${burst_length}
    ${dl_legacy_check}    compare_percc_counter_with_legacy    web_counter_dict=${all_cell_counter_dict}    dlul=${direction}
    ...    burst_id_length=${burst_length}
    Run Keyword And Continue On Failure    Should be True    ${dl_legacy_check}    msg=CB010636_C_DL Counters mismatch with legacy
    ${result}    run keyword if    ${percc_flag}    dealCounter.checkCounters    OamCounterData=${all_cell_counter_dict}     
    ...    outputpath=${OUTPUT_DIR}/${TEST NAME}/    gap=${GAP_Acceptable}    subfeature=C
    run keyword if    ${percc_flag}    Run Keyword And Continue On Failure    Should be true    ${result}
    ...    msg=CB010636_C Some ${direction} Counters eroor

Check CB010636_C UL Counter between Log and Webui
    [Arguments]  ${before_counter_time}    ${nsa_ul_cell}=${Empty}
    log to console    \n[Get CB010636-C ul counters from WEBUI]:
    ${c_ul_counters_dict}    Get All NRCELL Counter From VDU    counter_dict=${C_UL_Counters}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    dict_to_csv    data=${c_ul_counters_dict}    output_path=${OUTPUT_DIR}/${TEST NAME}/CB010636_C_UL_Counters.csv
    ${ul_result}    compare_percc_counter_with_legacy    web_counter_dict=${c_ul_counters_dict}    dlul=ul    nsa_ul_cell=${nsa_ul_cell}
    Run Keyword And Continue On Failure    Should be True    ${ul_result}    msg=CB010636_C_UL Counters mismatch with legacy

Check CB010636_D Counter between Log and Webui
    [Arguments]    ${csv_path}    ${ca_info}    ${counter_dict}    ${before_counter_time}    ${direction}=dl
    log to console    \n[Get CB010636-D ${direction} counters from TTI]:
    Log to console    TTI Path: ${csv_path}
    Get D_Counter From MacPduMuxReq Csv Log    csv_path=${csv_path}    ca_info=${ca_info}    direction=${direction}
    log to console    \n[Get CB010636-D ${direction} counters from WEBUI]:
    ${all_cell_counter_dict}    Get All NRCELL Counter From VDU    counter_dict=${counter_dict}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    ${result}    dealCounter.checkCounters    OamCounterData=${all_cell_counter_dict}    outputpath=${OUTPUT_DIR}/${TEST NAME}/
    ...    gap=${GAP_Acceptable}    subfeature=D
    Run Keyword And Continue On Failure    Should be true    ${result}    msg=CB010636_D Some ${direction} Counters eroor

Get All NRCELL Counter From VDU
    [Arguments]    ${counter_dict}    ${before_counter_time}    ${nrcell_list}=${cell_list}    ${nrbtsid}=${NRBTS}
    ${after_counter_dict}    Create dictionary
    FOR    ${cell}    IN    @{nrcell_list}
        ${web_counter}    Get VDU PM Counters    counter_id_dict=${counter_dict}    dist_name=${cell}
        ${cell_name}    String.Fetch From Right    ${cell}    marker=/
        set to dictionary    ${after_counter_dict}    ${cell_name}=${web_counter}
    END
    ${all_cell_counter_dict}    get_counter_sum_value_after_dedicate_time
    ...    before_counter_time=${before_counter_time}
    ...    after_counter_dict=${after_counter_dict}
    [Return]    ${all_cell_counter_dict}
