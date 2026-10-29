*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO  CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Akanksha Raina
...              :contact: akanksha.raina@nokia.com
...
...             INTRODUCTION:     This user scenario verifies Monitoring of PCMD trace records with Subscriber Trace activated
...                               and tracePCMDSetting set to XnAP HO related trace records for gNB-CU-CP for FR1.
...             TEST SET NAME:    CB013789
...             TESTING SPLIT:    Refer CB013789 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013789 CFAM
...             Requirement ID:   OM_GEN_SFS_TRACEMGMNT.6175

Library		     taf.sbts.oam.coam.admin
Library          taf.analyzer.pdml
Library          ta_pcmd
Library		     taf.sw.syslog
Resource         ../../../resources/robot/configuration_id.robot
Resource         ./resources/CB013789_keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../5G_CRT/resources/common_Resource.robot
Resource         ../5G_CRT/resources/common_keywords.robot
Library       ta_egate_cmd_parser


#Suite Setup         Run keywords    Suite setup from scratch
#...                 AND     gnb.Perform gNB reboot
#...                 AND     sleep    180s

*** Variables ***
${xnHoSrc_record}=     SEPARATOR=
...   ((nsetapx.CuVendorExtensionRecordDataType == 19) && (nsetapx.result == 0) &&
...   (nsetapx.mobilityReason == 1) && (nsetapx.traceActivationType == 1))
${xnHoTgt_record}=     SEPARATOR=
...   ((nsetapx.CuVendorExtensionRecordDataType == 20) && (nsetapx.result == 0) &&
...    (nsetapx.traceActivationType == 1))
${Other_record}=    SEPARATOR=
...   ((nsetapx.CuVendorExtensionRecordDataType != 19)     &&
...   (nsetapx.CuVendorExtensionRecordDataType != 20))

${scfc_gnb1}     ${CURDIR}/config/scf/BTS1_Delta.json
${scfc_gnb2}     ${CURDIR}/config/scf/BTS2_Delta.json
#${cfg}      ${CURDIR}/config/wts/basic_setup.cfg
${cfg}      /opt/wts/latest/basic_setup.cfg
${ue_id}    3
${regexp}=   *UE3: Inter-eNB handover from EXT_ENB-2.3 to EXT_ENB-3.7 performed*
${timeout}=	30
${first_ue}=    3
${last_ue}=     5

*** Test Cases ***
CB013789-A_B2_TC11_Activation_of_the_Subscriber_Trace_with_tracePCMDSetting_set_to_FR1_Inter_gnb_Xn_HO_for_gNB-CU-CP
    [Documentation]  This user scenario verifies Monitoring of PCMD trace records with Subscriber Trace activated and
     ...              tracePCMDSetting set to XnAP HO related trace records for gNB-CU-CP for FR1.

    [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    Start WTS Using WTS_Runner       ${cfg}
    ...        AND    wtsrunner.enb_x2_link_up    enb=1    target=3
    ...        AND    wtsrunner.enb_x2_link_up    enb=1    target=2
    ...        AND    sleep   60s
    ...        AND    Perform Delta changes for intergNB_XnHO
    ${TEST_NAME}    Set Variable   A_B2_TC11
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    sleep    30s
    Log to console    ${xnHoSrc_record}
    Log to console    ${xnHoTgt_record}
    Start Tcp Pcap
    Start PCMD
    Start Syslog
    Start Subscriber trace for UE from AMF
    Attach UE and start traffic
    Run keyword and continue on failure    Perform Inter-gNb HO to gnb-2 cell-7 via XN Interface
    Run keyword and continue on failure    Verify PCMD Trace Records for xnHoSrc Record     packet_filter=${xnHoSrc_record}
#    ...         rnti_list=${rnti_list}
    Run keyword and continue on failure    Verify PCMD Trace Records for xnHoTgt Record     packet_filter=${xnHoTgt_record}
#    ...         rnti_list=${rnti_list}
    Run keyword and continue on failure    Verify PCMD Trace Records for Other Records      packet_filter=${Other_record}
#    ...         rnti_list=${rnti_list}
    Stop Data traffic and deregister UE
    sleep    5s
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
     ...    AND   Link SCOUT SCF to Configuration ID for Reporting
     ...    AND   Stop Tcp Pcap
     ...    AND   Stop And Teardown PCMD
     ...    AND   Stop Default Logging


*** Keywords ***
Start PCMD
    Log to console  "Configuring PCMD"
    Configure PCMD    technology=5G    asn1per_decoding=${True}    port=49151
    Configure PCMD    technology=5G    asn1per_decoding=${True}    port=49150
    Start collecting PCMD reports


Start Tcp Pcap
    Log to console  "Starting Tshark Pcap log"
    OperatingSystem.Run   nc -lvp 49150 > ${LOG_PATH}/tce_49150.txt&
    OperatingSystem.Run   nc -lvp 49151 > ${LOG_PATH}/tce_49151.txt&
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/tshark
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Stop And Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Perform Delta changes for intergNB_XnHO
    log to console     "Doing Delta Changes for GNB-1"
    taf.sbts.oam.coam.admin.Setup admin    bts_host=10.0.1.2    bts_port=443   use_ssl=True
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${scfc_gnb1}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin
    log to console     "Doing Delta Changes for GNB-2"
    taf.sbts.oam.coam.admin.Setup admin    bts_host=10.0.1.3    bts_port=443   use_ssl=True
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${scfc_gnb2}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin

Start Syslog
    taf.sw.syslog.Start Syslog	log_dir=${output_dir}/enb	log_name=default_syslog_enb	ip=192.168.255.126	alias=default_enb

Stop Default Logging
	[Documentation]	Keyword to get active alarms and faults on SBTS and to stop Syslogs on SBTS
	taf.sbts.oam.coam.admin.connect_to
	taf.sbts.oam.coam.admin.get_active_alarms
	taf.sbts.oam.coam.admin.get_default_fault_list
	taf.sw.syslog.Stop Syslog	alias=default_enb
	Collect GNB SnapShot      ${LOG_PATH}

Start Subscriber trace for UE from AMF
#    [Arguments]     ${first_ue}     ${last_ue}
#    FOR	    ${ue_id}   IN RANGE    ${first_ue}	  ${last_ue}+1
      log to console     "Starting SBA Traces for UE-${ue_id}"
      wtsrunner.amf_ue_ics_param    id=1    ue=${ue_id}    object_id=${ue_id}    location_reporting_reference_id=${ue_id}  trace_activation=on
      ...    trace_plmn=311:489     trace_ref_id=${ue_id}     trace_rec_session_ref_id=${ue_id}     trace_depth=medium
      ...    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.0.1.1
    #END

Attach UE and start traffic
#      [Arguments]     ${first_ue}     ${last_ue}
#      FOR	    ${ue_id}   IN RANGE    ${first_ue}	  ${last_ue}+1
          log to console     "Attaching UE-${ue_id} and starting data traffic"
          wtsrunner.set_pdu_param    ue=${ue_id}  pdu=1    trf_type=internal
          wtsrunner.ue_register    id=${ue_id}
          sleep    10s
          wtsrunner.ue_pdu_session_setup    pdu=1    ue=${ue_id}    nwslice=1  gw=1
          sleep   5s
          wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=dl    trf_id=1    mbps=100    period_ms=20
          wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=ul    trf_id=1    mbps=100    period_ms=20
          sleep    5s
          wtsrunner.ue_disp    id=${ue_id}
          wtsrunner.ue_stats_nr    id=${ue_id}    scell=0-2    type=pdsch
          wtsrunner.ue_stats_nr    id=${ue_id}    scell=0-2    type=pusch
          Sleep    5s
      #END

Perform Inter-gNb HO to gnb-2 cell-7 via XN Interface
#    [Arguments]     ${first_ue}     ${last_ue}
#    FOR	    ${ue_id}   IN RANGE    ${first_ue}	  ${last_ue}+1
        log to console      "Performing Inter-gNb HO to gnb-2 now for UE-${ue_id}"
        wtsrunner.ue_meas_cfg_disp    id=${ue_id}
        sleep     10s
        wtsrunner.ue_measurement_send_nr    id=${ue_id}  meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
        sleep     20s
        wtsrunner.ue_meas_cfg_disp    id=${ue_id}
        sleep     10s
        wtsrunner.ue_measurement_send_nr    id=${ue_id}  meas_id=5 event=A3 srsrp_nr=9 phycell_id=56 nrsrp_nr=85
        sleep     20s
        wtsrunner.ue_disp    id=${ue_id}
        ${output}  wtsrunner.read_wtsemu_output_until_re    expected=UE3: Inter-eNB handover from EXT_ENB-2.3 to EXT_ENB-3.7
        ...     timeout=60
        ${output}         Get Lines Matching Regexp    ${output}    UE3: Inter-eNB handover from EXT_ENB-2.3 to EXT_ENB-3.7
        ...        partial_match=${TRUE}
        Log to Console    ${output}


Stop Data traffic and deregister UE
#    [Arguments]     ${first_ue}     ${last_ue}
#    FOR	    ${ue_id}   IN RANGE    ${first_ue}	  ${last_ue}+1
        log to console    "Stopping Data traffic and deregistering the UE-${ue_id}"
        wtsrunner.trf_data_stop    ue=${ue_id}  pdu=1 qfi=1
        wtsrunner.ue_deregister    id=${ue_id}  ue_deregister_type=switch_off
    #END

Verify PCMD Trace Records for xnHoSrc Record
    [Arguments]    ${packet_filter}     ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
#    @{rnti_list}=     Split     ${rnti_list}    ${space}
#    FOR    ${rnti_id}    IN    @{rnti_list}
        Verify Tshark
        ...    alias=${alias}
        ...    packet_filter=${packet_filter}
        ...   pass_criteria= >=1
        ...    pcap_file_path=${pcap_file_path}
        ...    timeout=${timeout}
        ...    continue_on_failure=${continue_on_failure}
    #END

Verify PCMD Trace Records for xnHoTgt Record
    [Arguments]    ${packet_filter}      ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
#    @{rnti_list}=     Split String    ${rnti_list}    ${space}
#    FOR    ${rnti_id}    IN    @{rnti_list}
        Verify Tshark
        ...    alias=${alias}
        ...    packet_filter=${packet_filter}
        ...   pass_criteria= >=1
        ...    pcap_file_path=${pcap_file_path}
        ...    timeout=${timeout}
        ...    continue_on_failure=${continue_on_failure}
    #END

Verify PCMD Trace Records for Other Records
    [Arguments]    ${packet_filter}       ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
#    @{rnti_list}=     Split String    ${rnti_list}    ${space}
#    FOR    ${rnti_id}    IN    @{rnti_list}
        Verify Tshark
        ...    alias=${alias}
        ...    packet_filter=${packet_filter}
        ...   pass_criteria= ==0
        ...    pcap_file_path=${pcap_file_path}
        ...    timeout=${timeout}
        ...    continue_on_failure=${continue_on_failure}
    #END
