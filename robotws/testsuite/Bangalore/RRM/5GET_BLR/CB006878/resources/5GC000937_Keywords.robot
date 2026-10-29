*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Madhu
...              :contact: madhusudhan.y@nokia.com


Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       ../../resources/ECEcommon/common_setup_teardown.robot
Library        ../../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../../resources/robot/Setup_Env.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
#Library        taf.collectors.core   WITH NAME   CORE
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library        ../../resources/python/BIP_Capture.py
Library        ../../resources/python/CPRT_Capture.py
Library        ./verify_rnti_bwpid.py
Library           XML    use_lxml=True    WITH NAME    Myxml

*** Variables ***
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}


*** Keywords ***

# Tshark keywords
Verify Ngap Messages
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Tcpdump Log
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=default    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Loopback Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_LOOPBACK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria= ${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Get number of occurrences of message in pcap
    [Arguments]    ${packet_filter}   ${pcap_file_path}=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}    ${alias}=${DEFAULT_TCPDUMP_ALIAS}
    ${number_of_packets}=     ute_tshark.Get packets count
    ...                       packet_filter=${packet_filter} && ip.src == 0.0.0.0/0 || ipv6.src==::0
    ...                       alias=${alias}    pcap_file_path=${pcap_file_path}
    [return]    ${number_of_packets}

Stop Capturing Tshark
    Stop Capturing    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    Stop Tcpdump On Remote Interface

Start Capturing Tshark
    Start Capturing    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    Start Tcpdump On Remote Interface

Set Counter Collecting Interval To Five Minutes
    Send Delta Commissioning    input_filepath=${delta_set_collecting_counters_to_five_minutes}

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init        ${capture_var_cprt}
    Capture start       ${capture_var_cprt}

Set L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture.Modify BIP Script File    ${BIP_SCRIPT_PATH}
    Capture init        ${capture_var_l1l2}
    Capture start       ${capture_var_l1l2}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop        ${capture_var_cprt}

Stop L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture stop        ${capture_var_l1l2}

Start CPRT Trace Capturing
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set suite variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}

Start L2 BIP Trace Capturing
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set suite variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture  ${CaptureL1L2}

Start Collecting Syslog
    [Arguments]    ${NAME}      #${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/
    set suite variable      ${CURRENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_${NAME}.log
    ta5g_syslog.Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.255.126
    ...       ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}

Stop Collecting Syslog
    [Arguments]    ${NAME}
    ${file_path}    ta5g_syslog.Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}

Start Collecting AP Syslog
    [Arguments]    ${NAME}      #${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/
    set suite variable      ${CURRENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_${NAME}.log
    ta5g_syslog.Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.200.126
    ...       ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}

Stop Collecting AP Syslog
    [Arguments]    ${NAME}
    ${file_path}    ta5g_syslog.Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}

Start Btslog Collect
    [Arguments]      ${names}=${NAME}     ${btslog_dir}=/opt/btslog     ${log_dir}=/tmp/btslog2
    log to console     Starting BTS logger
    btslog.create_btslog_collector    name=${names}    btslog_path=${btslog_dir}/btslog
    ...                               btslog_launcher_path=${btslog_dir}/btslog_launcher
    ...                               log_dir=${log_dir}
    core.setup_collectors      names=${names}
    core.start_collectors      names=${names}
    btslog.Set Suite Alias     ${names}

Stop Btslog Collect
    [Timeout]  3 hours
    [Arguments]               ${names}=${NAME}     ${target_dir}=${LOG_PATH}
    log to console     Stopping BTS logger
    run keyword and ignore error      core.stop_collectors    names=${names}
    run keyword and ignore error      core.collect_collectors      names=${names}    target_dir=${target_dir}
    core.teardown_collectors      names=${names}

Syslog should not contain BWP in DCI messages
    [Arguments]      ${bwpswitch}      ${NAME}    ${bwp_regex}
    log to console     Verifying bwpswitch in DCI messages in syslog
    FOR   ${item}   IN    @{bwp_regex}
        ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "${item}"
        Should Not Match Regexp   ${status}     ${bwpswitch}
    END

Syslog should contain BWP in DCI messages
    [Arguments]      ${bwpswitch}      ${NAME}    ${bwp_regex}
    log to console     Verifying bwpswitch in DCI messages in syslog
    FOR   ${item}   IN    @{bwp_regex}
          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "${item}"
          Should Match Regexp   ${status}     ${bwpswitch}
    END

Syslog should contain CSI Reports in syslogs
    [Arguments]      ${NAME}    ${csi_regex}
    log to console     Verifying CSI Reporting messages in syslog
    FOR   ${item}   IN    @{csi_regex}
          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "${item}"
          Should Not Be Empty    ${status}
    END

Syslog should contain BWP in DCI messages MultiUe
    [Arguments]      ${crnti}   ${bwpswitch}      ${NAME}    ${bwp_regex}
    log to console     Verifying bwpswitch in DCI messages in syslog    MultipleUE
    FOR    ${item}   IN    @{bwp_regex}
    	BuiltIn.Log     Checking with DCI ${item}
	    check_patteren	  ${crnti}   ${bwpswitch}      ${NAME}  ${item}
    END

check_patteren
   [Arguments]      ${crnti}   ${bwpswitch}      ${NAME}   ${item}
	FOR    ${crnti_id}   IN     @{crnti}
           ${pattern}=     Set Variable    ${item}.*rnti:${crnti_id}.*${bwpswitch}
            #${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep -m 1 "${pattern}"
	       ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "${pattern}"
           Should Match Regexp   ${status}     ${bwpswitch}
    END

Syslog should not contain BWP in DCI messages MultiUe
    [Arguments]      ${crnti}   ${bwpswitch}      ${NAME}    ${bwp_regex}
    log to console     Verifying bwpswitch in DCI messages in syslog    MultipleUE
    FOR    ${item}   IN    @{bwp_regex}
    	BuiltIn.Log     Checking with DCI ${item}
	    check_patteren_1	  ${crnti}   ${bwpswitch}      ${NAME}  ${item}
    END

check_patteren_1
   [Arguments]      ${crnti}   ${bwpswitch}      ${NAME}   ${item}
	FOR    ${crnti_id}   IN     @{crnti}
           ${pattern}=     Set Variable    ${item}.*rnti:${crnti_id}.*${bwpswitch}
            #${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep -m 1 "${pattern}"
	       ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "${pattern}"
           Should Not Match Regexp    ${status}     ${bwpswitch}
    END
BIP_Verify that DlData_PdcchSendReq message contains the BandwidthPartIndicator
    [Documentation]      this KW Verifies the value of BandwidthPartIndicator IE of DCI format 1_1
    ...                  in DlData_PdcchSendReq message in captured BIP traces
    log to console       Verifies the value of BandwidthPartIndicator IE of DCI format 1_1 in  DlData_PdcchSendReq message
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}     dldata_pdcchsendreq
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=dldata_pdcchsendreq
    ...                             path=dci.dci11.BandwidthPartIndicator
    ...                             startPacket=1
    ...                             endPacket=-1
    @{listpacketMatch}     get slice from list     ${listpacketMatch}     0     20
    FOR      ${packet}     IN      @{listpacketMatch}
        ${value}               Get Value In Packet Match
        ...                   packetMatch=${packet}
        ...                   field=BandwidthPartIndicator
       should be equal    ${value}    1
    END

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Full Commission SCF
    [Arguments]    ${scf_file}
    ute_adm.Setup Admin    alias=cOAM
    ute_adm.Perform Commissioning
    ...    bts_id=1
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    ...    alias=cOAM
    Run Keyword And Ignore Error    ute_adm.Teardown Admin    alias=cOAM

CellSetupRequest Should contain powersavingBWP in the capture
    [Arguments]    ${file_name}
    [Documentation]      this KW Verifies the value of CellSetupRequest IE conatins powersavingbandwidthpart
    ...                  in CellSetupRequest message in captured CPRT logs
    log to console       Verifies the value of CellSetupRequest IE conatins powersavingbandwidthpart
     pdml entries should match    pcapfile=${LOG_PATH}/${file_name}     field_name=itf_l2_ps_cell_CellSetupReq.cellBwpList_item_0.bwpType
     ...           value=initial        attrib_value=0
     pdml entries should match    pcapfile=${LOG_PATH}/${file_name}     field_name=itf_l2_ps_cell_CellSetupReq.cellBwpList_item_1.bwpType
     ...           value=dedicated      attrib_value=1
#     pdml entries should match    pcapfile=${LOG_PATH}/${file_name}     field_name=itf_l2_ps_cell_CellSetupReq.cellBwpList_item_2.bwpType
#     ...           value=powersaving       attrib_value=2
     pdml entries should match    pcapfile=${LOG_PATH}/${file_name}     field_name=itf_l2_ps_cell_CellSetupReq.cellBwp.actPowerSavingBwp
     ...           value=0x00       attrib_value=0x00000000

pdml entries should match
    [Arguments]      ${pcapfile}     ${field_name}     ${value}    ${attrib_value}
    [Documentation]      this KW matches the entry in the pdml file
    log to console       Verifies the value of ${field_name} in pdml file
    ${pdmlFile} =    analyzer.pcap_to_pdml           ${pcapfile}
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=${field_name}      attrib_name=show     attrib_value=${attrib_value}
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=${field_name}    attrib_name=showname
    should contain     ${attrib_values}[0]      ${value}

UECompatibilityInfomation Should contain bwpSwitchingDelay and bwpSameNumerology in the capture
    [Documentation]      this KW Verifies the value of UECompatibilityInfomation IE contains
    ...                  SwitchingDelay and bwp_SameNumerology in UECompatibilityInfomation message in captured CPRT logs
    log to console       Verifies the value of UECompatibilityInfomation IE conatins powersavingbandwidthpart
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}     f1ap
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nr-rrc.phy_ParametersCommon_element      attrib_name=showname     attrib_value=phy-ParametersCommon
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=per.optional_field_bit   attrib_name=showname
    should contain    ${attrib_values}      1... .... Optional Field Bit: True (bwp-SwitchingDelay is present)
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nr-rrc.bwp_SameNumerology     attrib_name=show    attrib_value=1
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nr-rrc.bwp_SameNumerology   attrib_name=showname
    should contain    ${attrib_values}      bwp-SameNumerology: upto4 (1)

Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    set Suite variable      ${file_name}
    Check gNB Airscale is Ready - ${BBoard_Type}
    Run keyword and ignore error    Start Collecting Syslog    NAME=cell_setup
    run keyword if     '${BBoard_Type}'=='ASOE'     CPRT Monitoring Start ASOE
    ...    ELSE        Start CPRT Trace Capturing
    Log To console     loading cfg file
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    run keyword if     '${BBoard_Type}'=='ASOE'     CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    ...    ELSE        Stop CPRT capture     ${CaptureCPRT}
    run keyword if     '${BBoard_Type}'=='ASOE'     Move File      ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/${file_name}
    ...    ELSE        Move File      ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/${file_name}
    run keyword if     '${BBoard_Type}'=='ASOE'     Move File      ${LOG_PATH}/External_NODECPRT_GNB.pcap
    ...     ${LOG_PATH}/External_NODECPRT_GNB_cellsetup.pcap
    log to console     ${file_name}
    Run keyword and ignore error     Stop Collecting Syslog     NAME=cell_setup
#    CellSetupRequest Should contain powersavingBWP in the capture       ${file_name}

Assign lmpAddr to f1Addr
   [Arguments]    ${gnb_index}=0     ${du_index}=0
   ${tl.gnbs[0].dus[0].f1_m_ip_addr}     set variable
   ...      ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}

TTI LOG Capture and Download CSV Files to VM
    [Arguments]    ${duration}=3s
    [Documentation]    This KW captures the TTI Traces
    log to console    \n***Start TTI LOG Capture and Download***
    run keyword if     '${BBoard_Type}'=='ASOE'     Start TTI trace log capturing for ASOE
    ...    ELSE       Start TTI trace log capturing
    Sleep    ${duration}
    run keyword if     '${BBoard_Type}'=='ASOE'     Stop TTI trace log capturing for ASOE
    ...    ELSE       Stop TTI trace log capturing
    OperatingSystem.Run And Return Rc And Output
    ...     sh /home/ute/robotws5g/testsuite/Bangalore/RRM/5GET_BLR/resources/python/Decode_TTITrace_on_PC.sh ${LOG_PATH}

TTI LOG Capture Start
    [Documentation]    This KW captures the TTI Traces
    log to console    \n***Start TTI LOG Capture and Download***
    run keyword if     '${BBoard_Type}'=='ASOE'     Start TTI trace log capturing for ASOE
    ...    ELSE       Start TTI trace log capturing

TTI LOG Capture Stop
    run keyword if     '${BBoard_Type}'=='ASOE'     Stop TTI trace log capturing for ASOE
    ...    ELSE       Stop TTI trace log capturing

Download TTI CSV Files to VM
    OperatingSystem.Run And Return Rc And Output
    ...     sh /home/ute/robotws5g/testsuite/Bangalore/RRM/5GET_BLR/resources/python/Decode_TTITrace_on_PC.sh ${LOG_PATH}

Generate DL CSV TTI File based on filters
    [Arguments]    ${tti_csv_dir}=${LOG_PATH}    ${filters}=${EMPTY}
    [Documentation]    | ${filters} | No | str with separator ;, dlFdSchedData;dlFlowControlData |
    ${out_file_name}    Set Variable    ${tti_csv_dir}/TTI_Traces_Filterd_DL.csv
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*dl.csv    ${True}
    Should Not Be Empty    ${tti_csv_files}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    END

Generate UL CSV TTI File based on filters
    [Arguments]    ${tti_csv_dir}    ${filters}=${EMPTY}
    ${out_file_name}    Set Variable    ${tti_csv_dir}/TTI_Traces_Filterd_UL.csv
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*ul.csv    ${True}
    Should Not Be Empty    ${tti_csv_files}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    END

Format Tti In Snapshot Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by eventsCollect.sh(snapshot mode)
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${input_csv_name} | Yes | str, ${CURDIR}/TtiFiles/L2TtiTrace_EventsSnapshot.bin.01.dl.csv |
    ...    | ${output_csv_name} | Yes | str, ${CURDIR}/TtiFiles/tti_snapshot.csv |
    ...    | ${filters} | No | str with separator ;, dlFdSchedData;dlFlowControlData |
    ...
    ...    Examples:
    ...    | Format Tti In Snapshot Mode | ${input_csv_name} | ${output_csv_name} |
    ...    | Format Tti In Snapshot Mode | ${input_csv_name} | ${output_csv_name} | ${filters} |
    ...
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiConvert.Format Tti No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiConvert.Format Tti With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Download TTI bin files to VM
    [Arguments]     ${tti_folder}
    create directory     ${LOG_PATH}/${tti_folder}
    ${ASP_board}=     Get BB Board Type        airscale=${AIRSCALE_GNB}
    ${CPU_ID}    set variable if    '${ASP_board}'=='ABIO'     ${0}    ${1}
    ${check_tti}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
	...      bsh 1:${CPU_ID} ls -1rt /var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz
    ${Result}=      Run Keyword And Ignore Error    Process.Run Process    command=${check_tti}    shell=yes
    ${download_tti}=    Catenate    sudo sshpass -p oZPS0POrRieRtu scp -p
    ...             toor4nsn@192.168.255.1 bsh 1:${CPU_ID}:/var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz ${LOG_PATH}/${tti_folder}/
    Run Keyword And Ignore Error    Process.Run Process    command=${download_tti}     shell=yes

Download ASOE TTI bin files to VM
    [Arguments]     ${tti_folder}
    create directory     ${LOG_PATH}/${tti_folder}
	${check_tti}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
	...      ls -1rt /var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz
    ${Result}=      Run Keyword And Ignore Error    Process.Run Process    command=${check_tti}    shell=yes
    ${download_tti}=    Catenate    sudo sshpass -p oZPS0POrRieRtu scp -p
    ...             toor4nsn@192.168.255.1:/var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz ${LOG_PATH}/${tti_folder}/
    Run Keyword And Ignore Error    Process.Run Process    command=${download_tti}     shell=yes

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Start And Stop Tti Trace Streaming after BWP switch
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode_2
    Sleep    3s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Convert Tti To CSV Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

Create Rntibwp Dictionary
    [Arguments]   ${rnti}   ${bwpid}
    ${Dict1}   Create Dictionary
    ${len}   Get Length    ${rnti}
    FOR    ${i}    IN RANGE   ${len}
         Set To Dictionary   ${Dict1}    ${rnti}[${i}]   ${bwpid}[${i}]
    END
    Run Keyword if   ${len}==0    Set To Dictionary   ${Dict1}    ${EMPTY}   ${bwpid}[0]
    [Return]   &{Dict1}

Verify Rnti ueBWPid
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}   ${flag}
    ${rntibwp}   Create Rntibwp Dictionary   ${rnti}   ${bwp}
    ${Result}  verify_rnti_bwpid.check_rnti_bwpid    ${csv_file_path}   ${rntibwp}   ${flag}
    [Return]   ${Result}

Validate UE bwpid from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}   ${flag}
    ${Check}  Verify Rnti ueBWPid    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${bwp}   ${flag}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Bwpid is not matching
    ${Check1}  Verify Rnti ueBWPid    ${csv_file_path}/output_ul_formated.csv     ${rnti}   ${bwp}   ${flag}
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail   Bwpid is not matching

Capture TTI Traces and Validate UE bwpid
     [Arguments]   ${LOG_PATH}   ${filename}    ${rnti}   ${bwp}   ${flag}
     Start And Stop Tti Trace Streaming after BWP switch   ${LOG_PATH}/ttitrace_streaming/${filename}
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate UE bwpid from TTI traces    ${LOG_PATH}/ttitrace_streaming/${filename}     ${rnti}   ${bwp}   ${flag}

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Fetch AMF and Nglink Status
    Get Classical gNB Nglink Status
    Get AMF Local Ip Status

Get Classical gNB Nglink Status
    Connect to DU1
    Check classical gNB Nglink Status
    [Teardown]    Disconnect from DU

Disconnect from DU
    [Arguments]    ${alias}=default
    coam.teardown     connection=${alias}

Check classical gNB Nglink Status
    [Arguments]        ${admin_alias}=default
    coam.collect_scf     target_file_name=FetchNgLinkStatus.xml      export_type=configurationAndRuntimeObjects      connection=default
    @{NgLinkStatus}    Myxml.Get Elements Texts    FetchNgLinkStatus.xml    .//p[@name="ngLinkStatus"]
    log     ${NgLinkStatus}   ${admin_alias}

Dump RMOD BBMOD And Cell Status
    Get cgNB RMOD BBMOD And Cell Status

Get cgNB RMOD BBMOD And Cell Status
    Connect to DU1
    Check classical RMOD BBMOD And Cell Status
    [Teardown]    Disconnect from DU

Check classical RMOD BBMOD And Cell Status
#    [Arguments]        ${admin_alias}=default
    coam.collect_scf     target_file_name=RuntimeStatus.xml      export_type=runtimeObjects      connection=default
    Get_cGNB_System_Status

Connect to DU1
    [Arguments]    ${alias}=default
    ${conn}=    coam.connect_to
#    ...    bts_host=${DU_IP}
    ...    bts_host=192.168.255.129
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}
