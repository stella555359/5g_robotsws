*** Settings ***
Resource       CB008285_variables.robot
Library        ute_ue
Library        taf.sbts.oam.coam.admin    WITH NAME    coam
Resource       ./../../CB007873/Resources/CB007873_keywords.robot
#Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/qualcomm_cpe.robot
Library        ./../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Library        String
Library        DateTime
Library        XML    True
Library        Collections
Library        OperatingSystem
Resource       testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library        testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library        taf.transport.ssh    WITH NAME    ssh
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot
Library        taf.ue    WITH NAME    taf_ue

*** Variables ***

*** Keywords ***
check CSI report with pucchF2MaxCodeRate from rrc reconfiguration msg
    [Documentation]  Author: ludan fang
    ...    CSI report from RRC reconfiguration msg
    ...    ${log_file_path}: pcap log file path
    [Arguments]    ${log_file_path}    ${display_filter}=${FILTER_RRC_SETUP}  ${alias}=test0  ${CQI_EXP}=${10}
    ...   ${beam_reprot_EXP}=${10}
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}
    ${CQI_result}    pcap.get_field_value_by_xpath    xpath=${CQI_XPATH}    pcap_parser=${alias}
    ${beam_report_result}    pcap.get_field_value_by_xpath    xpath=${BEAM_REPORT_XPATH}    pcap_parser=${alias}
    should be equal as integers   ${CQI_result}[0]  ${CQI_EXP}
    should be equal as integers   ${beam_report_result}[0]  ${beam_reprot_EXP}

check counter M55306C06001 M55306C03001
    [Documentation]     author: ludan.fang@nokia-sbell.com
    ...      Following counter will be counted under Pcell
    ...      M55306C06001: RA msg3 receptions
    ...      M55306C03001: RA setup completions for contention based group A preambles
    [Arguments]       ${starting_log_timestamp}   ${cell_id}=${CELL_INDEX_PCELL}   ${counter_expected_number}=${1}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${cell_id}
    ${list_measurement_ids}    create list    M55306C06001    M55306C03001
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=${cell_check_list}
    ...      list_measurement_ids=${list_measurement_ids}
    ${M55306C06001}    set variable    ${dict_measurements_value['${CELL_INDEX_PCELL}']['M55306C06001']}
    ${M55306C03001}    set variable    ${dict_measurements_value['${CELL_INDEX_PCELL}']['M55306C03001']}
    run keyword and continue on failure   run keywords    Should be true      ${M55306C06001}==${counter_expected_number}
    ...                                        AND        Should be true      ${M55306C03001}>=${counter_expected_number}

check DMRS and codebookSubset from rrc reconfiguration msg
    [Documentation]  Author: ludan fang
    ...    DMRS and codebookSubset from RRC reconfiguration msg
    ...    ${log_file_path}: pcap log file path
    [Arguments]    ${log_file_path}    ${display_filter}=${FILTER_RRC_RECONFIG}  ${alias}=test0
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=${alias}
    ${codebook_result}    pcap.get_field_value_by_xpath    xpath=${CODEBOOK_XPATH}    pcap_parser=${alias}
    ${DMRS_result}    pcap.get_field_value_by_xpath    xpath=${DMRS_XPATH}    pcap_parser=${alias}
    should be equal as integers   ${codebook_result}[0]  ${2}
    should be equal as integers   ${DMRS_result}[0]  ${0}

check counter M55303C04002 M55303C03001 M55303C03000
    [Documentation]     author: ludan.fang@nokia-sbell.com
    ...      Following counter will be counted under Pcell
    ...      M55303C04002: PUSCH transmissions with CP-OFDM using 2TX transmission with rank 2
    ...      M55303C03001: PUSCH transmissions in Rank2 with CP-OFDM using PMI 01
    ...      M55303C03000: PUSCH transmissions in Rank2 with CP-OFDM using PMI 00
    [Arguments]       ${starting_log_timestamp}   ${cell_id}=${CELL_INDEX_PCELL}   ${counter_expected_number}=${1}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${cell_id}
    ${list_measurement_ids}    create list    M55303C04002    M55303C03001   M55303C03000
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=${cell_check_list}
    ...      list_measurement_ids=${list_measurement_ids}

    ${M55303C04002}    set variable    ${dict_measurements_value['${CELL_INDEX_PCELL}']['M55303C04002']}
    ${M55303C03001}    set variable    ${dict_measurements_value['${CELL_INDEX_PCELL}']['M55303C03001']}
    ${M55303C03000}    set variable    ${dict_measurements_value['${CELL_INDEX_PCELL}']['M55303C03000']}
    ${sum_of_PMI}      evaluate        ${M55303C03001}+${M55303C03000}
    run keyword and continue on failure   run keywords    Should be true      ${M55303C04002}>=${counter_expected_number}
    ...                                        AND        Should be true      ${sum_of_PMI}>=${counter_expected_number}

8285 suite preparation
    Suite common setup preparation   NSA_SA=SA
    coam_gnb_classical.connect to gnb coam via ssl
    ${gnb_nr_cell_id_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
    Set suite variable    ${all_cell_ids}
    Set suite variable   ${CELL_INDEX_PCELL}  ${all_cell_ids}[0]
    Set suite variable    ${pcell_nrCellIdentity}    ${gnb_nr_cell_id_mapping}[${CELL_INDEX_PCELL}][nrCellIdentity]
    import variables   ${CURDIR}/../TestData/8285_params.py

8285 case teardown
    [Arguments]    ${data_transfer_direction}=both    ${protocol}=udp    ${ue_index}=${0}    ${attach_result}=${ATTACH_RESULT}
    run keyword and ignore error    Stop data transfer based on direction
    ...    protocol=${protocol}   data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}
    run keyword and ignore error    power_ue.UE detach    ue_type=${UE_TYPE}    ue_index=${ue_index}
    run keyword and ignore error    taf_ue.detach ue    UE_0
    run keyword if    ${attach_result}==${False}    run keyword and ignore error    Restart the UE Proxy
    run keyword if    ${attach_result}==${False}    sleep    60s
    run keyword and ignore error    Teardown the Aasyslog save progress
    run keyword and ignore error    coam teardown gnb connections
    Common case teardown    is_log_required=${True}

#8285 case teardown
#    [Arguments]  ${alias}=AT_BASED_UE
#    Cpe_operation.stop_ul_data_transfer
#    ...   hostname=${UE_PC_IP}
#    ...   username=${UE_PC_USERNAME}
#    ...   password=${UE_PC_PASSWD}
#    ...   port=${APPSERVER_PORT}
#    ...   ue_sn=${UE_SN}
#    ute_ue.Release PDU session     ${alias}
#    ute_ue.Detach Ue    ${alias}
#    Teardown the Aasyslog save progress
#    coam teardown gnb connections
#    Close the iperf process on APPserver    port=${APPSERVER_PORT}
#    Common case teardown    is_log_required=${True}

check puccch resource from F1AP
    [Documentation]  Author: ludan fang
    ...    puccch resource from RRC reconfiguration msg, and return as a dict. Can extend content if needed.
    ...    ${log_file_path}: pcap log file path
    [Arguments]    ${log_file_path}    ${display_filter}=${FILTER_RRC_RECONFIG}
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=test0
    ${codebook_result}    pcap.get_field_value_by_xpath    xpath=${PUCCH_RESOURCE}    pcap_parser=test0
    should be equal as integers   ${codebook_result}[0]  ${2}
    should be equal as integers   ${DMRS_result}[0]  ${0}

Check All NR cells On Air
    [Documentation]    Author: Zhou Charlie
    ...      check if all NR cells are on air.
    [Arguments]       ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info    cell_type=nr    timeout=30    connection=${connection}
    FOR  ${cell}  IN  @{cells_info}
         run keywords    Run keyword and continue on failure
         ...    Should be equal as strings    ${cell['status']['operationalState']}    enabled
         ...    AND     Run keyword and continue on failure   Dictionary Should Not Contain Value    ${cell['status']}    degraded
    END

Check Only Default AMF ngLinkStatus Inactive
    [Documentation]    Author: Zhou Charlie
    ...      check if only default AMF NG link statusn is Inactive.
    [Arguments]       ${connection}=GNB_OAM
    ${SERVEDAMF_L}    coam.get_managed_objects    class_name=SERVEDAMF_L    connection=${connection}
    ${amf_length}=  Get Length   ${SERVEDAMF_L}
     FOR    ${id}    IN RANGE   ${amf_length}
         ${dict_ngLinkStatus}    coam.get_parameters    dist_name=${SERVEDAMF_L[${id}]['distName']}    pattern=ngLinkStatus
         ...                                            connection=${connection}
         ${default_AMF}=    Run Keyword And Return Status   should contain   ${SERVEDAMF_L[${id}]['distName']}   SERVEDAMF_L-1
         run keyword if    '${default_AMF}'=='True'
         ...    run keyword and continue on failure    should contain    ${dict_ngLinkStatus['ngLinkStatus']}    Inactive
         ...    ELSE    run keyword and continue on failure    should contain    ${dict_ngLinkStatus['ngLinkStatus']}    Active
     END

Check All AMF ngLinkStatus Active
    [Documentation]    Author: Zhou Charlie
    ...      check if all AMF NG link statusn are Active.
    [Arguments]       ${connection}=GNB_OAM
    ${SERVEDAMF_L}    coam.get_managed_objects    class_name=SERVEDAMF_L    connection=${connection}
    ${amf_length}=  Get Length   ${SERVEDAMF_L}
     FOR    ${id}    IN RANGE   ${amf_length}
         ${dict_ngLinkStatus}    coam.get_parameters    dist_name=${SERVEDAMF_L[${id}]['distName']}    pattern=ngLinkStatus
         ...                                            connection=${connection}
         run keyword and continue on failure   should contain   ${dict_ngLinkStatus['ngLinkStatus']}   Active
     END

Check NG Link Lock Unlock Counter
    [Documentation]    Author: Zhou Charlie
    ...      Following counter will be counted under gNB level
    ...      M55119C00501: This counter provides the number of SCTP shutdowns due to locked NG-C link with AMF.
    ...      Incremented when SCTP association is shutdown due to NG-C link being locked.
    ...      M55119C00001: This counter provides the number of NGAP: NG Setup Request messages sent by the gNB-CU.
    ...      This counter is incremented every time when an NGAP : NG Setup Request message is sent by the gNB-CU.
    ...      M55119C00002: This counter provides the number of NGAP: NG Setup Response messages received by the gNB-CU.
    ...      This counter is incremented every time when an NGAP : NG Setup Response message is received by the gNB-CU.
    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${list_measurement_ids}    create list    M55119C00501    M55119C00001    M55119C00002
    ${dict_measurements_value}    counter.get_total_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_measurement_ids=${list_measurement_ids}
    ${bts_M55119C00501}    set variable    ${dict_measurements_value['M55119C00501']}
    ${bts_M55119C00001}    set variable    ${dict_measurements_value['M55119C00001']}
    ${bts_M55119C00002}    set variable    ${dict_measurements_value['M55119C00002']}
    run keyword and continue on failure   run keywords    Should be true      ${bts_M55119C00501} >= ${1}
    ...                                        AND        Should be true      ${bts_M55119C00001} >= ${1}
    ...                                        AND        Should be true      ${bts_M55119C00002} >= ${1}

Check PM counter M55124C00001 M55124C05501 M55157C00033
    [Documentation]    author: xin.qi@nokia-sbell.com
    ...    M55124C00001: Number of RRC RELEASE messages sent.
    ...    M55124C05501: Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target.
    ...    M55157C00033: Number of times the SA mobility profile 1 is selected

    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${CELL_INDEX_1TH}
    ${list_measurement_ids}    create list    M55124C00001    M55124C05501    M55157C00033
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}

    ${M55124C00001}    set variable    ${dict_measurements_value['${CELL_INDEX_1TH}']['M55124C00001']}
    ${M55124C05501}    set variable    ${dict_measurements_value['${CELL_INDEX_1TH}']['M55124C05501']}
    ${M55157C00033}    set variable    ${dict_measurements_value['${CELL_INDEX_1TH}']['M55157C00033']}
    run keyword and continue on failure     should not be equal as strings      ${M55124C00001}       0
    run keyword and continue on failure     should not be equal as strings      ${M55124C05501}       0
    run keyword and continue on failure     should not be equal as strings      ${M55157C00033}       0

#Stop both traffic FR2 SA and detach CPE
#    [Documentation]    Author: Zhou Charlie
#    ...      Stop CPE UL data traffic and detach CPE, then stop APPsever DL traffic.
#    [Arguments]  ${alias}=AT_BASED_UE
#    Cpe_operation.stop_ul_data_transfer
#    ...   hostname=${UE_PC_IP}
#    ...   username=${UE_PC_USERNAME}
#    ...   password=${UE_PC_PASSWD}
#    ...   port=${APPSERVER_PORT}
#    ...   ue_sn=${UE_SN}
#    ute_ue.Release PDU session     ${alias}
#    ute_ue.Detach Ue    ${alias}
#    Close the iperf process on APPserver    port=${APPSERVER_PORT}

Stop both traffic FR2 SA and detach CPE
    Run Keyword And Continue On Failure    Stop data transfer based on direction   data_transfer_direction=both
    Run Keyword And Continue On Failure    power_ue.UE detach    ue_type=${UE_TYPE}

Verify RRC SETUP configuring BWP using initial BWP profile
    [Documentation]    author: Zhou Charlie
    ...      check RRC SETUP configuring BWP using initial BWP profile by cpif
    [Arguments]     ${log_path_pcap}    ${isUsedInitialBwp}=${False}
    ${filter}    set variable    ( f1ap.procedureCode == 12 ) && (nr-rrc.firstActiveDownlinkBWP_Id)
    ${pkt_CPE_attach}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
    ${firstActiveDownlinkBWP_Id}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_CPE_attach}        attribute_name=show
    ...    xpath=.//nr-rrc.spCellConfig_element/nr-rrc.spCellConfigDedicated_element/nr-rrc.firstActiveDownlinkBWP_Id

    ${firstActiveDownlinkBWP_Id_exp}    set variable if    ${isUsedInitialBwp}==${True}    ${0}    ${1}
    run keyword and continue on failure   should be true    ${firstActiveDownlinkBWP_Id}[0] == ${firstActiveDownlinkBWP_Id_exp}

Perform Serving Cell Block Unblock
    [Documentation]   Auther: Jing Chen
    [Arguments]  ${cell_idx}=${1}    ${cell_type}=nr    ${with_call}=${False}  ${with_peak}=${False}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${cell_idx_list}  create list  ${cell_idx}
    Block and UnBlock Cells and L3call    block_list=${cell_idx_list}


Common Debug Trace Configure And Sherpa Enable
    [Documentation]    capture sherpa logs from webui
    [Arguments]   ${url}=https://${GNB_IP}    ${username}=${WEBUI_NAME}   ${password}=${WEBUI_PWD}   ${display}=${false}
    ...    ${driver_alias}=chromedriver   ${version}=Sbts${PROGRAM}    ${alias}=${None}    ${uplane_port}=${UTE_IP}:5679
    ...    ${cplane_port}=${UTE_IP}:5677
    Return From Keyword If   '${alias}' in @{selenium_gnb_login}
    Run Keyword and Ignore Error    selenium_coam.enable_virtual_display
    Run Keyword and Ignore Error   selenium_coam.disable_message_box
    Run Keyword and Ignore Error   selenium_coam.disable_screen_lock
    selenium_coam.enable_virtual_display
    log to console   \n ... Login to GNB...
    selenium_coam.login    url=${url}    username=${username}    password=${password}    version=${version}     browser=Chrome     log_level=all
    Append To List   ${selenium_gnb_login}   ${alias}
    Set Global Variable   ${selenium_gnb_login}
    selenium_coam.deactivate_internal_trace   timeout=60
    log to console   \n ... Enable Sherpa configuration...
    selenium_coam.configure_logging_agent     source_ip=${GNB_IP}   dscp=${dscp}    uplane_destination=${uplane_port}     timeout=40
    sleep    10
    selenium_coam.activate_internal_trace     timeout=60
    run keyword and continue on failure    selenium_coam.save_screenshot    debug_coam_web
    sleep    10
    log to console   \n ... Start Sherpa capture...
    selenium_coam.start_l2_hi_pdcp_sherpa_trace_and_return_result       timeout=20
    selenium_coam.start_l2_hi_rlc_sherpa_trace_and_return_result       gnb_type=Classical    timeout=20
    selenium_coam.start_l2_lo_sherpa_trace_and_return_result      timeout=20
    selenium_coam.start_l2_ps_sherpa_trace_and_return_result     timeout=20
    selenium_coam.start_l2_hi_pdcp_component_trace_and_return_result    timeout=20
    selenium_coam.start_l2_hi_rlc_component_trace_and_return_result    timeout=20
    selenium_coam.start_l2_lo_component_trace_and_return_result    timeout=20
    selenium_coam.start_l2_ps_component_trace_and_return_result    timeout=20

Disable sherpa Trace
    selenium_coam.stop_sherpa_trace    uplane_sherpa_name=L2-HI    source=PDCP    timeout=40
    selenium_coam.stop_sherpa_trace    uplane_sherpa_name=L2-HI    source=RLC    timeout=40
    selenium_coam.stop_sherpa_trace    uplane_sherpa_name=L2-LO    timeout=40
    selenium_coam.stop_sherpa_trace    uplane_sherpa_name=L2-PS    timeout=40
    selenium_coam.stop_component_trace    uplane_component_name=L2-HI    source=PDCP    timeout=40
    selenium_coam.stop_component_trace    uplane_component_name=L2-HI    source=RLC    timeout=40
    selenium_coam.stop_component_trace    uplane_component_name=L2-LO    timeout=40
    selenium_coam.stop_component_trace    uplane_component_name=L2-PS    timeout=40
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    selenium_coam.close_browser


Start UTE capture
    Connect to UTE
    ssh.execute    command=sudo rm -f /tmp/sherpa.pcap*    connection=UTE-conn   timeout=20s
    ssh.execute    command=sudo timeout 30 tcpdump -v -ni eth0 port 5679 -C 150 -W 10 -w /tmp/sherpa.pcap
    ...    connection=UTE-conn    timeout=60s

Stop UTE capture
    ssh.execute    command=sudo kill `ps -ef | grep tcpdump| grep -v grep | awk '{print $2}'`
    ...    connection=UTE-conn   timeout=20s
    ${sherpa}    ssh.execute    command=sudo find /tmp -name sherpa.pcap*
    ...   connection=UTE-conn   timeout=10s
    ${sherpa_file_size}    Get File Size    path=/tmp/sherpa.pcap0
    ${result}    run keyword if    ${sherpa_file_size}>1000   set variable    PASS    ELSE    set variable    FAIL
    should contain    ${result}    PASS
    Close connect of UTE


Connect to UTE
   ssh.connect_to    hostname=${UTE_IP}   username=${UTE_NAME}    password=${UTE_PWD}   alias=UTE-conn


Close connect of UTE
   ssh.disconnect    connection=UTE-conn

Check tput via power UE with power UE method
    [Documentation]    Author: Liu Zheng
    ...   use TPUT check keyword of pwoer ue, and it will draw a tput picture
    ...   if specific cell tput not need to check, please set exp tput to -1
    ...   :param cell_id: is the nrcellidentity, not global cell id
    ...   :param exp_ul: expected tput of UL, can be 50 or 50,100. Unit in Mbps.
    ...   :param exp_dl: expected tput of DL, can be 50 or 50,100. Unit in Mbps.
    ...   :param log: log path of aasyslog throughput file.
    ...                Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...   :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...   :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...                   If you want to check cell TPUT one by one, please set it to ${False}
    ...   :param connection: SSL connection alias, pls create the connection before use the keyword
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...   e.g: Check tput via power UE with power UE method   cell_id=179749115    exp_ul=50    exp_dl=100    log=${tput_log}
    [Arguments]     ${cell_id}    ${exp_ul}    ${exp_dl}     ${log}
    ...    ${ue_type}=${UE_TYPE}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${actCarrierAggregation}=${False}    ${connection}=GNB_OAM    ${customized_log_name}=${None}
    ${list_nr_cell_id}    string2list    ${cell_id}
    ${list_exp_ul}    string2list    ${exp_ul}
    ${list_exp_dl}    string2list    ${exp_dl}
    FOR    ${index}    ${nr_cell_id}    IN ENUMERATE    @{list_nr_cell_id}
        @{list_nr_cell_ids}    Create list    ${nr_cell_id}
        ${dl_exp_tput}    set variable   ${list_exp_dl}[${index}]
        ${ul_exp_tput}    set variable   ${list_exp_ul}[${index}]
        run keyword if    '${dl_exp_tput}'=='${-1}'    run keyword and continue on failure
        ...    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}
        ...        target_throughput=${ul_exp_tput}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${ul_exp_tput}'=='${-1}'    run keyword and continue on failure
        ...        power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}
        ...        target_throughput=${dl_exp_tput}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${dl_exp_tput}'=='${0}' and '${ul_exp_tput}'=='${0}'    run keyword and continue on failure
        ...        sub check no tput for specify direction    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}   direction=both
        ...        target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
        ...        ultarget_throughput=1    dltarget_throughput=1    min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${dl_exp_tput}'=='${0}' and '${ul_exp_tput}'!='${0}'    run keyword and continue on failure
        ...        sub check no tput for specify direction    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}   direction=DL
        ...        target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
        ...        ultarget_throughput=${ul_exp_tput}    dltarget_throughput=1    min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${ul_exp_tput}'=='${0}' and '${dl_exp_tput}'!='${0}'    run keyword and continue on failure
        ...        sub check no tput for specify direction    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}   direction=UL
        ...        target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
        ...        ultarget_throughput=1   dltarget_throughput=${dl_exp_tput}    min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE    power_ue.Check Bi Tput    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}
        ...        ultarget_throughput=${ul_exp_tput}   dltarget_throughput=${dl_exp_tput}     target_avg_percent=${target_avg_percent}
        ...        actCarrierAggregation=${actCarrierAggregation}   min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
    END

L3 call check tput with power UE method
    [Documentation]     Author: Liu Zheng
    ...    compare with keyword "Call case with Commercial UE and record throughput info", this keyword check tput via power ue
    ...    1. attach ue
    ...    2. start traffic
    ...    3. check throughput
    ...   :param cell_id: global cell id, can be 1
    ...   :param dl_tput: Start traffic of DL, Unit in Mbps.
    ...   :param ul_tput: Start traffic of UL, Unit in Mbps.
    ...   :param exp_ul: expected tput of UL, Unit in Mbps.
    ...   :param exp_dl: expected tput of DL, Unit in Mbps.
    [Arguments]     ${nr_cell_id}=1    ${dl_tput}=${DL_TPUT_COMMON}    ${ul_tput}=${UL_TPUT_COMMON}    ${exp_ul}=1    ${exp_dl}=1
    ...    ${tput_check_duration}=60s    ${ignore_time}=1min    ${actCarrierAggregation}=${False}    ${data_transfer_direction}=both
    ...    ${traffic_duration}=3000s    ${protocol}=udp    ${process_num}=default   ${seg_size}=1350
    ...    ${iperf_ul_port}=${None}    ${iperf_dl_port}=${None}    ${buffer_size}=1400B
    ...    ${window}=16M    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}

    ...    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${prepare_ue_needed}=${False}
    ...    ${attach_check_type}=PROXY_log    ${retry_time}=2     ${detach_request}=${False}    ${connection}=GNB_OAM
    ...    ${target_avg_percent}=0.95    ${filter}=L2Lo    ${throughput_check_source}=Aasyslog
    ...    ${upload_duration}=${True}    ${min_percent}=0.85    ${is_need_to_stop_traffic}=${True}

    ${attach_result}    run keyword and return status    Retry commercial ue attach if failed
    ...    ue_type=${UE_TYPE}    retry_time=${retry_time}    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}
    ...    attach_check_type=${attach_check_type}   detach_request=${detach_request}
    ...    cell_id=${nr_cell_id}
    Run Keyword And Continue On Failure    should be true     ${attach_result}==${True}
    set test variable    ${ATTACH_RESULT}    ${attach_result}
    Run Keyword And Continue On Failure    Start data transfer based on direction    dl_tput=${dl_tput}    ul_tput=${ul_tput}
    ...    duration=${traffic_duration}    protocol=${protocol}
    ...    process_num=${process_num}    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}    seg_size=${seg_size}
    ...    iperf_ul=${iperf_ul_port}    iperf_dl=${iperf_dl_port}    buffer_size=${buffer_size}
    ...    window=${window}

    ${tput_log}    power_ue.Collect Tput     ue_type=${ue_type}    duration=${tput_check_duration}    ignore_time=${ignore_time}   filter=${filter}
    ...    check_source=${throughput_check_source}
    run keyword and ignore error    check iperf process on appserver
    Run Keyword And Continue On Failure    Check tput via power UE with power UE method   cell_id=${nr_cell_id}   exp_ul=${exp_ul}   exp_dl=${exp_dl}
    ...    log=${tput_log}    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}   min_percent=${min_percent}

    run keyword if    ${is_need_to_stop_traffic}==${True}   Run Keyword And Continue On Failure   Stop data transfer based on direction
    ...    protocol=${protocol}   data_transfer_direction=${data_transfer_direction}    iperf_ul=${iperf_ul_port}    iperf_dl=${iperf_dl_port}
    ...     ue_index=${ue_index}
