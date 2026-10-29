*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008806-B

Resource    ../../../resources/Common/btslog.robot
Resource    ../../../resources/Common/tcpdump.robot
Resource    ../../../resources/Common/wts_ue.robot
Resource    ../../../resources/Common/commissioning.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/reporting.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/ute_workarounds.robot
Resource    ../../../resources/Common/core.robot

Resource    ../../resources/SQD65/sqd65_keywords.robot
Resource    ../../resources/SQD65/sqd65_commissioning.robot

Library     taf.config.wts      WITH NAME    wts_conf
Library     taf.analyzer.pdml   WITH NAME    pdml_analyzer
Library     ta_pcmd
Library     ute_tshark
Library     Process


*** Variables ***

${TEST_MODE}                auto
${SW_BRANCH}                SBTS00
${WTS_CFG_FILE}             basic_setup_8806-B.cfg
${NIDD_VERSION}             NRBTSCL5G21B_2104_100
${PCAP_FILE_NAME}           ngap.pcap
${PCMD_ASN1_FILE}           asn_decoded_*.log
${TCE_PORT_NUMBER}          49151
${GNB3_CFG}                 SEPARATOR=
...                         set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.3 gnb_id=0x3:22 daemon=
...                         $SERVER_IP:$DAEMON_PORT xn=10.0.1.4 x2_peers=none nssai=0x1:0xd143a5 amf=1

&{plmn}=                    mcc=311  mnc=489  mncLength=3
&{nrRanTraceReference}      &{plmn}  traceId=1

@{IP_LIST_eth3_add}         10.0.1.3  10.0.1.4
@{IP_LIST_eth4_add}

*** Keywords ***

Prepare TL for CB008806-B
    [Documentation]   Prepare UTE TL for CB008806-B test
    ...    backup TL configurations, configure GNB with mobility profile, prepare WTS config file for
    Set Suite Variable  ${suite_setup_status}  Start
    Sqd65 Common Setup
    Get SW Branch
    Commissioning
    Prepare WTS Config
    ute_workarounds.Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE}
    Bring Airphone gNBsim on AIR
    Disable Protocol in Wireshark  protocol=f1ap
    ute_tshark.Setup Tshark        interface=eth3  preferences=ntrstr.defragment:TRUE ntrstr.port:${TCE_PORT_NUMBER}     alias=tshark
    Set Suite Variable  ${suite_setup_status}  Finished

Commissioning
    ${ts_conf_dir}=          Get Test Suite Config Directory
    ${delta_scf}=            Set Variable   ${ts_conf_dir}/delta_8806-B.json
    ${new_scf}=              Set Variable   ${ts_conf_dir}/scf_8806-B.xml
    scf.load_scf             ${P_ORIG_SCF}

    Add Trace Control Entity
    Add Radio CU Trace Session
    Enable PCMD and Cell Trace
    Enable intra-NR NG based handover

    scf.save_scf             ${new_scf}
    scf.calculate_delta_scf  ${new_scf}  ${P_ORIG_SCF}  ${delta_scf}

    Config gNB with delta scf               ${delta_scf}

Perform Precondition of Test Scenario
    IF    '${PREV_TEST_STATUS}'=='FAIL'
        Teardown Egate Connection for Airphone
        Teardown Edaemon Connection for Airphone
        Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE}
        Bring Airphone gNBsim on AIR
    END
    Start 8806-B Logging
    Start PCMD
    Register UE on source gNB

Perform Postconditions of Test Scenario
    Run Keyword and Warn on Failure    Set SCOUT TC ID for Reporting
    Collect Snapshots
    Stop data traffic in egate  ue_id=1  direction=dl
    Stop data traffic in egate  ue_id=1  direction=ul
    UE Deregister
    Stop 8806-B Logging
    Stop PCMD

Collect Snapshots
    IF    '${TEST_MODE}' != 'snapshot'
        IF    '${TEST_STATUS}' == 'PASS' or '${TEST_MODE}' == 'manual'   RETURN
    END
    ${log_dir}=                     Get Testcase Log Directory
    Run Keyword And Ignore Error    wts_ue.Collect sos report logs
    Run Keyword And Ignore Error    collect snapshot from gnb  target_dir=${log_dir}

Start 8806-B Logging
    Set Test Variable    ${LOGGING_STATUS}    False
    Start Tshark
    Start F1AP capturing
    Start Btslog
    Start EGATE Logs
    Set Test Variable    ${LOGGING_STATUS}    True

Start Tshark
    ${log_dir}=               Get Testcase Log Directory
    Set Test Variable         ${PCAP_FILE}   ${log_dir}/${PCAP_FILE_NAME}
    ute_tshark.start capturing    log_dir=${log_dir}   log_name=${PCAP_FILE}   alias=tshark

Stop 8806-B Logging
    [Arguments]    ${target_dir}=None
    IF    not ${LOGGING_STATUS}   RETURN
    ${log_dir}=                              IF    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    Stop F1AP capturing
    Run Keyword And Ignore Error  Stop Btslog  target_dir=${log_dir}
    Send Egate Command and verify output     set_log flush
    ${isset}=  Get Variable Value  ${EGATE_PART}
    IF  "${isset}" == "None"
    ...    Copy File  ${tl.core.dir_path}/egate_console.log   ${log_dir}
    ...  ELSE
    ...    Copy File  ${tl.core.dir_path}/egate_console.log   ${log_dir}/egate_console_part_${EGATE_PART}.log
    ute_tshark.stop capturing    alias=tshark
    Set Test Variable    ${LOGGING_STATUS}    False

Prepare WTS Config
    [Documentation]    use taf.config.wts to modify basic_setup.cfg for feature testing
    ${WTS_CFG_FILE}=             Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.modify              set_gnb id=2   gnb_id=0x1:22
    wts_conf.modify              set_cell id=1  nrci=0x1
    wts_conf.insert              ${GNB3_CFG}    before  set_uec id=1
    wts_conf.insert              gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=ng_based
    ...                          after  set_gnb id=3
    wts_conf.insert              set_cell id=1 gnb=3 pci=17:1 tac=0 nrci=0x03 tdd_cell=on proxy=10.0.1.3:9999 nr_arfcn=636666:636666 gscn=7847
    ...                          after  gnb_param id=3
    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE}  ${ts_conf_dir}

Send Measurement Report
    [Arguments]    ${measurement}   ${ue_id}=1  ${pass_regexp}=EGATE>
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   cmd=ue_measurement_send_nr ${measurement} id=${ue_id}
    ...                                    pass_regexp=${pass_regexp}
    Sleep   1
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   set_log flush

Get Measurement id
    [Arguments]  ${event_type}  ${ue_id}=1
    ${measurements}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  0
    @{words}=  Split String  ${first_line}
    RETURN  ${words}[0]

Enable PCMD and Cell Trace
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1
    scf.modify_scf_element    dist_name=${dist_name}    p_name=actCellTraceReport          value=true
    scf.modify_scf_element    dist_name=${dist_name}    p_name=actPCMDReport               value=true

Enable intra-NR NG based handover
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1
    scf.modify_scf_element    dist_name=${dist_name}    p_name=actIntraNrNgHo              value=targetOnly
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=tNgRelocExecDeltN           value=3000

Disable intra-NR NG based handover
    Modify single parameter via Delta SCF           dist_name=MRBTS-1/NRBTS-1    p_name=actIntraNrNgHo           value=disabled

Disable Cell Tracing
    Modify single parameter via Delta SCF           dist_name=MRBTS-1/NRBTS-1    p_name=actCellTraceReport       value=false

Disable PCMD Tracing
    Stop collecting PCMD reports
    Modify single parameter via Delta SCF           dist_name=MRBTS-1/NRBTS-1    p_name=actPCMDReport            value=false
    Start collecting PCMD reports

Enable NG Handover
    Modify single parameter via Delta SCF           dist_name=MRBTS-1/NRBTS-1    p_name=actIntraNrNgHo           value=targetOnly

Register UE on source gNB
    [Arguments]  ${ue_id}=1
    Send Egate Command and verify output   cmd=ue_change_location id=${ue_id} enb=3 cell=1
    ...                                    pass_regexp=(location updated to eNB-3 cell 1)|(already there)
    Set Traffic Type  ue_id=${ue_id}  pdu_id=1  trf_type=internal
    UE Register                            ue_id=${ue_id}
    Send Egate Command and verify output   cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1
    ...                                    pass_regexp=Pdu Session Resource Setup Response Message with RAN UE NGAP ID \\d+ handled successfully
    Sleep   1
    Start data traffic in egate  ue_id=${ue_id}  direction=dl  pdu=1
    Start data traffic in egate  ue_id=${ue_id}  direction=ul  pdu=1
    Sleep   2

Perform NG Handover
    [Arguments]   ${pass_regexp}=Inter-eNB handover from (EXT_)*ENB-3.1 to EXT_ENB-2.1 performed
    Send Measurement Report                meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100        pass_regexp=${pass_regexp}

Bring Airphone gNBsim on AIR
    Send Egate Command and verify output   cmd=gnb_param id=3 sib1_period=160ms
    ...                                    pass_regexp=eNB 3 cell 1: SystemInformationBlockType1-NR updated

Verify Cell Trace NG Handover
    ${pdml_file}=            Pcap To Pdml For Nsetapx
    ${message_sequence}=     Catenate   SEPARATOR=
    ...                      asn1-MsgId: 64.*
    ...                      asn1-MsgId: 65.*
    ...                      asn1-MsgId: 93.*
    ...                      asn1-MsgId: 67.*
    ${field_name_list}=      Create List
    ...                      nsetapx.asn1_MsgId
    pdml_analyzer.Check MSC                ${pdml_file}  ${field_name_list}  ${message_sequence}
    Compare NGAP-PDUs

Compare NGAP-PDUs
    ${ngap_pdml_file}=         Pcap To Pdml For Ngap
    ${nsetapx_pdml_file}=      Pcap To Pdml For Nsetapx
    ${ngap_pdu_list}=          Get NGAP-PDUs  ${ngap_pdml_file}
    ${num_of_ngap_pdus1}=      Get length     ${ngap_pdu_list}
    ${nsetapx_ngap_pdu_list}=  Get NGAP-PDUs  ${nsetapx_pdml_file}
    ${num_of_ngap_pdus2}=      Get length     ${nsetapx_ngap_pdu_list}
    Should be Equal as Integers     ${num_of_ngap_pdus1}  ${num_of_ngap_pdus2}
    FOR   ${index}   IN RANGE  0    ${num_of_ngap_pdus1}
       Should be Equal as Strings   ${ngap_pdu_list}[${index}]  ${nsetapx_ngap_pdu_list}[${index}]
    END

Get NGAP-PDUs
    [Arguments]  ${pdml_file}
    ${ngap_pdu_list}=        Get Pdml Entries  file_name=${pdml_file}  field_name=ngap.NGAP_PDU  attrib_name=show  attrib_value=0
    ${hex_value_list}=       Get Attrib Value From Pdml Entries        pdml_entries=${ngap_pdu_list}  field_name=ngap.NGAP_PDU  attrib_name=value
    RETURN  ${hex_value_list}

Verify PCMD Trace NG Handover
    ${pcmd_file}=            Get PCMD Trace file
    @{pattern_list}=         Create List
    ...                      "ueDuConnectivityRecord"
    ...                      "result": "success"
    ...                      "pduSessionResourceInfoRecord"
    ...                      "trigger": "handover"
    ...                      "result": "success"
    ...                      "setupPduSessionResources"
    ...                      "setupQosFlows"
    ...                      "ueSetupRecord"
    ...                      "result": "success"
    ...                      "trigger": "other"
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify Cell Trace NG Handover Failure
    ${pdml_file}=             Pcap To Pdml For Nsetapx
    ${message_sequence}=      Catenate   SEPARATOR=
    ...                       asn1-MsgId: 64.*
    ...                       asn1-MsgId: 66.*
    ${field_name_list}=       Create List
    ...                       nsetapx.asn1_MsgId
    pdml_analyzer.Check MSC   ${pdml_file}  ${field_name_list}  ${message_sequence}

verify PCMD Trace NG Handover Failure
    ${pcmd_file}=            Get PCMD Trace file
    @{pattern_list}=         Create List
    ...                      "pduSessionResourceInfoRecord"
    ...                      "trigger": "handover"
    ...                      "result": "miscFailure"
    ...                      "failedToSetupPduSessionResources"
    ...                      "failedToSetupQosFlows"
    ...                      "ueSetupRecord"
    ...                      "result": "miscFailure"
    ...                      "trigger": "other"
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Verify Empty Cell Trace
    ${pdml_file}=            Pcap To Pdml For Nsetapx
    ${message_sequence}=     Catenate   SEPARATOR=
    ...                      asn1-MsgId:*
    ${field_name_list}=      Create List
    ...                      nsetapx.asn1_MsgId
    ${status}=               Run Keyword and Return Status
    ...                      pdml_analyzer.Check MSC      ${pdml_file}  ${field_name_list}  ${message_sequence}
    IF           ${status}
    ...                      Fail  Unexpected cell trace msg found

Verify Empty PCMD Trace
    Stop PCMD
    ${pdml_file}=            Pcap To Pdml For Nsetapx
    ${message_sequence}=     Catenate   SEPARATOR=
    ...                      vendorExtensionData*
    ${field_name_list}=      Create List
    ...                      nsetapx.vendorExtensionData_element
    ${status}=               Run Keyword and Return Status
    ...                      pdml_analyzer.Check MSC      ${pdml_file}  ${field_name_list}  ${message_sequence}
    IF           ${status}
    ...                      Fail  Unexpected PCMD trace msg found

Verify Empty Trace
    Verify Empty PCMD Trace
    Verify Empty Cell Trace

Modify single parameter via Delta SCF
    [Arguments]  ${dist_name}  ${p_name}  ${value}
    ${tc_conf_dir}=          Get Testcase Log Directory
    ${new_scf}=              Set Variable   ${tc_conf_dir}/${p_name}.xml
    ${delta_scf}=            Set Variable   ${tc_conf_dir}/delta_${p_name}.json
    ${current_scf}=          Load current SCF
    scf.modify_scf_element   dist_name=${dist_name}  p_name=${p_name}  value=${value}
    scf.save_scf             ${new_scf}
    scf.calculate_delta_scf  ${new_scf}  ${current_scf}  ${delta_scf}
    Config gNB with delta scf               ${delta_scf}

Pcap To Pdml for Nsetapx
    ${pdml_file}=            Pcap To Pdml   packet_filter=nsetapx
    RETURN  ${pdml_file}

Pcap To Pdml for Ngap
    ${pdml_file}=            Pcap To Pdml   packet_filter=ngap&&!nsetapx
    RETURN  ${pdml_file}

Pcap To Pdml
    [Arguments]  ${packet_filter}
    ute_tshark.stop capturing    alias=tshark
    ${pdml_file}=            Set Variable  ${PCAP_FILE}.pdml
    ${status}=               Run Keyword and Return Status     File Should Not Exist   ${pdml_file}
    IF  '${status}'=='True'      ute_tshark.read pcap and save to file
    ...                      pcap_file_path=${PCAP_FILE}  filename=${pdml_file}  output_type=pdml
    ...                      packet_filter=${packet_filter}  alias=tshark
    RETURN  ${pdml_file}

Perform NG Handover Failure
    Perform NG Handover   pass_regexp=Received Handover Preparation Failure from AMF

Get SW Branch
    ${SW_BRANCH}=    testline.Get gNB SW Branch
    Set Suite Variable  ${SW_BRANCH}
