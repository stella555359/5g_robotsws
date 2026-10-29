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
Library        luashark_tools.analyzer    isLuaSharkRequired=False    WITH NAME       analyzer
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
${wts_cfg_file_TC04}     ${CURDIR}/../config/basic_setup_CA_SA_RRE.cfg
${IPHY_FILE_TC04}                    ${CURDIR}/../config/CB006878_B_1_04_CA_T_T_SA_iphy.xml
${scf_TC04}   CB006878_B_1_04_CA_T_T_SA_SCF.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        5
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${PM_PCELL_COUNTER1}    M55167C00001
${PM_PCELL_COUNTER2}    M55167C00002
${PM_PCELL_COUNTER3}    M55139C04001
${PM_SCELL_COUNTER1}    M55308C28001
${PM_SCELL_COUNTER2}    M55308C28002
${EXPECTED_PCELL_VALUE1}
${EXPECTED_PCELL_VALUE2}
${EXPECTED_PCELL_VALUE3}
${EXPECTED_SCELL_VALUE1}
${EXPECTED_SCELL_VALUE2}
${no_of_cells_TC04}   2

#-----------------------------
${SCFC}=                   ${CURDIR}/../config/SBTS25R1/SCF_High_edge_prb_blanking_CA_case_ASOH.xml
${AP_XML}=                 ${CURDIR}/../config/iphy_CA_2Cell_latest_ASOH.xml
${wts_cfg_file_2}      ${CURDIR}/../config/basic_setup_FDD_highedge_prb_blanking.cfg
*** Keywords ***
Testcase Setup
    [Arguments]    ${IPHY_xml}   ${scfc_file}   ${wts_file}   ${num_of_cells}
    Modify IPHY File And Send to Airphone Custom    ${IPHY_xml}
    Find Scfc And Fix And Send Full Commissioning  scfc_filename=${scfc_file}
    Start Default Logging    output_dirpath=${LOG_PATH}
    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_file}   ${num_of_cells}
    Check gNB Bulid

common Teardown
     Run Keyword and Ignore Error    Get Snapshot
     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD_SBTS*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}


Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0


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
    [Arguments]    ${NAME}
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
    [Arguments]    ${NAME}
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

#Full Commission SCF
#    [Arguments]    ${scf_file}
#    ute_adm.Setup Admin    alias=cOAM
#    ute_adm.Perform Commissioning
#    ...    bts_id=1
#    ...    scf_file=${scf_file}
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...    timeout=500
#    ...    alias=cOAM
#    Run Keyword And Ignore Error    ute_adm.Teardown Admin    alias=cOAM

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
    [Arguments]    ${wts_cfg_file}   ${no_of_cells}
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
    FOR     ${i}    IN RANGE   1   ${no_of_cells}+1
        Wait Until Keyword Succeeds     200s    5s	Check MIB_SIB status of GNB cell   ${i}
    END
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
    [Arguments]
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

Regiter UE And Verify Scell Addition On High Data Traffic
#   Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_add
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    UE Register should be Successful     ue_id=${UE_ID}
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully    5    1    31624
    Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=110       trf_id=1
    sleep   5s
	Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=650       qfi_id=${QFI_ID}
	Run Keyword And Continue on Failure    Verify DL Tput For 2CC T_F
#   Stop L1L2 capture  ${CaptureL1L2}
#   Stop CPRT capture   ${CaptureCPRT}
#   Stop Collecting Syslog       NAME=scell_add
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap

Verify DL Tput For 2CC T_F
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${140}
    Should Be True    ${scell_tput} > ${140}

Verify RRC Reestablishment is Successfull
    Wait until the next Measurement Period starts
#   Run Keyword and Ignore Error    Start Collecting Syslog     NAME=rrc_reestablish
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    Trigger RRC Reestablishment   ue_id=${UE_ID}
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully    5    2    31624
#   Stop L1L2 capture  ${CaptureL1L2}
#   Stop CPRT capture   ${CaptureCPRT}
#   Stop Collecting Syslog       NAME=rrc_reestablish
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap

Verify Scell Deactivation On Low Data Traffic
#   Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_remove
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    Start Low Data Traffic And Check Scell Deactivation
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    sleep     60s
# 	Stop CPRT capture   ${CaptureCPRT}
#   Stop L1L2 capture   ${CaptureL1L2}
#   Stop Collecting Syslog       NAME=scell_remove
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_remove.pcap
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap
	Run Keyword And Continue on Failure     Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=3
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=5
    sleep   5s    reason=Wait for successful traffic start

Start Low Data Traffic And Check Scell Deactivation
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=1    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=2    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=3    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=4    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=5    dir=dl     pdu_id=${Pdu_session_ID}

Verify Counters incrementing RRE
    [arguments]     ${EXP_PCELL_VALUE1}      ${EXP_PCELL_VALUE2}     ${EXP_PCELL_VALUE3}      ${EXP_SCELL_VALUE1}     ${EXP_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}
    ...   	expected_value=${EXP_PCELL_VALUE1}   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters bigger than T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}
    ...     expected_value=${EXP_PCELL_VALUE2}   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...   	expected_value=${EXP_PCELL_VALUE3}   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${PM_dir_2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters bigger than T_F    PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER1}
    ...   	expected_value=${EXP_SCELL_VALUE1}   moc=MRBTS-1/NRBTS-1/NRCELL-2
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER2}
    ...  	expected_value=${EXP_SCELL_VALUE2}  moc=MRBTS-1/NRBTS-1/NRCELL-2

Verify Counters decrementing RRE
    [arguments]     ${EXP_PCELL_VALUE1}      ${EXP_PCELL_VALUE2}     ${EXP_PCELL_VALUE3}      ${EXP_SCELL_VALUE1}     ${EXP_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}
    ... 	expected_value=${EXP_PCELL_VALUE1}   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}
    ...  	expected_value=${EXP_PCELL_VALUE2}  moc=MRBTS-1/NRBTS-1/NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...  	expected_value=${EXP_PCELL_VALUE3}   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${PM_dir_2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters T_F     PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER1}
    ...  	expected_value=${EXP_SCELL_VALUE1}   moc=MRBTS-1/NRBTS-1/NRCELL-2
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER2}
    ...  	expected_value=${EXP_SCELL_VALUE2}    moc=MRBTS-1/NRBTS-1/NRCELL-2

Validate PM Counters T_F
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}   ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than T_F
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}   ${moc}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}



Trigger multiple UEs with the 256qam capable with CB006878 enabled
#    Perform SCF Delta Commissioning with CB006878_Enable.json
#	sleep	 50s
#    Start CPRT Trace Capturing
	#Step 1. Attach Single SA UE and start low DL data and Max UL data
    ${crnti_list}=      MultiUE Register should be Successful    2  2
#    Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_TC_6878.pcap
    MultiUE Trigger DL Traffic for SA    2  2    Traffic_rate=mbps     dl_rate=20          trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    2  2    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_1}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    2  2    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_2}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger DL Traffic for SA    3  4    Traffic_rate=mbps     dl_rate=20         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger UL Traffic for SA    3  4    Traffic_rate=mbps     ul_rate=142         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    sleep    30s
#    Validate DL Traffic For MultiUE for SA    1  2     dl_rate=20         qfi_id=${sa_qfi_id}
    Validate UL Traffic For SA    2     ul_rate=210         qfi_id=${sa_qfi_id}
#	Validate DL Traffic For MultiUE for SA    3  4     dl_rate=20         qfi_id=${sa_qfi_id}
#    Validate UL Traffic For MultiUE for SA    3  4     ul_rate=142         qfi_id=${sa_qfi_id}
#    Start L2 BIP Trace Capturing
#    sleep      2s
#    Stop L1L2 capture    ${CaptureL1L2}
    Stop MultiUE Data Traffic for SA     2  2
#    ${result_enable}    int(${output[0]})
    MultiUE Deregister should be Successful   2  2
#    Log to Console  ${CaptureL1L2}
#    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${LOG_PATH}/L1L2_GNB_FS_LO.pcap   ${13}    ${247}

Trigger multiple UEs with the 256qam capable with CB006878 disabled
#	Start CPRT Trace Capturing
	#Step 1. Attach Single SA UE and start low DL data and Max UL data
    ${crnti_list}=      MultiUE Register should be Successful    1  1
#    Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_TC1.pcap
    MultiUE Trigger DL Traffic for SA    1  1    Traffic_rate=mbps     dl_rate=20          trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    1  1    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_1}         qfi_id=${sa_qfi_id}
    MultiUE Trigger UL Traffic for SA    1  1    Traffic_rate=mbps     ul_rate=160          trf_id=${TRF_ID_2}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger DL Traffic for SA    3  4    Traffic_rate=mbps     dl_rate=20         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
#    MultiUE Trigger UL Traffic for SA    3  4    Traffic_rate=mbps     ul_rate=142         trf_id=${TRF_ID}         qfi_id=${sa_qfi_id}
    sleep      30s
#    Validate UL Traffic For SA    1  1     dl_rate=20         qfi_id=${sa_qfi_id}
    Validate UL Traffic For SA    1     ul_rate=200         qfi_id=${sa_qfi_id}
#	Validate DL Traffic For MultiUE for SA    3  4     dl_rate=20         qfi_id=${sa_qfi_id}
#    Validate UL Traffic For MultiUE for SA    3  4     ul_rate=142         qfi_id=${sa_qfi_id}
#    Start L2 BIP Trace Capturing
#    sleep      2s
#    Stop L1L2 capture    ${CaptureL1L2}
#    ${result_disable}      String . Get Regexp Matches ${bearer_stat}, Average data rate +(\\d+), 1
#    result Disable
#    Log to Console    ${output}
    Stop MultiUE Data Traffic for SA     1  1
    MultiUE Deregister should be Successful   1  1
#    Log to Console  ${CaptureL1L2}
#    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq without 6878     ${LOG_PATH}/L1L2_GNB_FS_LO.pcap   ${10}    ${253}
#    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/L1L2_GNB_FS_LO_without_6878.pcap

