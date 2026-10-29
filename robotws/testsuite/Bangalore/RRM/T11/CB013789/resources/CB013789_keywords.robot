*** Settings ***
Documentation    :copyright: Nokia

Variables    ta5g_global_var
Library           OperatingSystem
Library           Telnet
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.ul.ue.sim.env_setup
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../../resources/robot/TTI_Traces.robot
Library          ../../../../resources/python/CPRT_Capture.py
Resource         ../../../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../../../../resources/robot/Setup_Env.robot
Resource         ../../../../resources/robot/Airphone.robot
Resource         ../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Resource         ../../../../resources/robot/common_log_collection.robot
Resource         ../../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../../resources/robot/BBpooling_MuMIMO.robot
Library         ta5g_egate
Library         Process
Library         Collections
Library         taf.converters.pcaptopdml      WITH NAME    pcaptopdml
Library         taf.collectors.tshark          WITH NAME    tshark
Library         taf.collectors.l2stream3       WITH NAME    ttistream
Library         taf.sbts.oam.coam.admin        WITH NAME    CoamAdmin
Library         taf.transport.ssh              WITH NAME    taf_ssh
Library         taf.sw.dcap.rd                 WITH NAME    rd
Library         taf.wts.runner              WITH NAME    wtsrunner
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sw.wtssim
Library         taf.ue.airphone
Library         taf.config.scf
Library         ta_emss
Library         ta5g_tshark
Library         ta5g_commissioning
Library         ta5g_pm_counters
Library         String
Library         ta_pcmd.tshark_plugin_configurator
Library         ta_pcmd
Library         taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library         file_operation.py

*** Variables ***
${wts_cfg_folder}     ${CURDIR}/../config/wts
${scf_folder}       ${CURDIR}/../config/scf/
${bsr_iphy_folder}     ${CURDIR}/../config/
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/BSR/
${BSR_FILENAME}=    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${PDU_session_resource_setup_without_ICS}   PDU SESSION ID-.* setup.*reestablishment complete
@{gnb_custom_profile}           controlPlane5g    Tracer_5g

${TC1_delta_file_name}     ${scf_folder}/SBA_MO_creation.json
${TC1_delta_revert}     ${scf_folder}/SBA_MO_revert.json
${wts_cfg_file_TC1}     ${wts_cfg_folder}/D_B1_TC1.cfg
${wts_cfg_file_TC3}     ${wts_cfg_folder}/CB013789_FR1_WTS_CFG.cfg
${no_of_cells_TC1}    6
${start_ue_id}    1
${end_ue_id}     2
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}   1
${Pdu_ID}      1
${TRF_ID}     1
${QFI_ID}     1
${UE_stats_pdsch_pattern}        NR PDSCH Throughput
${UE_stats_pusch_pattern}       NR PUSCH Throughput
${alias}
${TIME_FORMAT}    %H:%M:%S


#CB013789-E TC3 Variables
${AOA_SSB_record}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 34) && (nsetapx.beamType == 3) &&
...    (nsetapx.azimuthAngle == -1161) && (nsetapx.zenithAngle == 970))

${AOA_PMI_record}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 34) && (nsetapx.beamType == 2) &&
...    (nsetapx.azimuthAngle == -800) && (nsetapx.zenithAngle == 970))

${AOA_DFT_record}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 34) && (nsetapx.beamType == 1) &&
...    (nsetapx.azimuthAngle == -354) && (nsetapx.zenithAngle == 1007))


${DOA_PMI_record}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 29) && (nsetapx.beamType == 2) &&
...    (nsetapx.azimuthAngle == 0) && (nsetapx.elevationAngle == 70))

${DOA_SSB_record}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 29) && (nsetapx.beamType == 3) &&
...    (nsetapx.azimuthAngle == -361) && (nsetapx.elevationAngle == 70))

${DOA_DFT_record}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 29) && (nsetapx.beamType == 1) &&
...    (nsetapx.azimuthAngle == 447) && (nsetapx.elevationAngle == 107))

## RLC Records
${ulRbRlcMeasRecord}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 5) && (nsetapx.sumOfRlcPduRxBytes > 0 ) && (nsetapx.numOfRlcPduRx > 0))

${dlRbRlcMeasRecord}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 6) && (nsetapx.sumOfRlcPduTxBytes > 0) && (nsetapx.numOfRlcPduTx > 0))

${ulRbrlcthroughputRecord}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 17) && (nsetapx.sumOfRlcSduRxDataBurstBytes >= 0))

${dlRbrlcthroughputRecord}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 33) && (nsetapx.sumOfRlcPduTxDataBurstBytes >= 0))

${dlRbHighRlcMeasRecord}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 32) && (nsetapx.numOfRlcSduTx > 0) && (nsetapx.sumOfRlcSduTxBytes > 0))

${ulRbHighRlcMeasRecord}=     SEPARATOR=
...   ((nsetapx.DuVendorExtensionRecordDataType == 31) && (nsetapx.numOfRlcSduRx > 0) && (nsetapx.sumOfRlcSduRxBytes > 0))

##PDCP Records
${ulRbPdcpMeasRecord}=     SEPARATOR=
...   ((nsetapx.CuUpVendorExtensionRecordDataType == 3) && (nsetapx.sumOfPdcpSduRxBytes >= 0) && (nsetapx.numOfPdcpSduRx >= 0))

${dlRbPdcpMeasRecord}=     SEPARATOR=
...   ((nsetapx.CuUpVendorExtensionRecordDataType == 3) && (nsetapx.sumOfPdcpSduRxBytes >= 0) && (nsetapx.numOfPdcpSduRx >= 0))

${dlRbPdcpThroughputRecord}=     SEPARATOR=
...   ((nsetapx.CuUpVendorExtensionRecordDataType == 5) && (nsetapx.sumOfPdcpSduTxDataBurstBytes >= 0))

${enable_pcmd}    ${scf_folder}/TC3_Delta_pcmd.json
${disable_pcmd}   ${scf_folder}/TC3_Delta_disable_pmcd.json


*** Keywords ***

USCB013789_A_B1_TC2_suit_setup
     Suite Setup         Suite setup from scratch

Update TCE IP address in josn
    [Arguments]    ${host_vm_ip}   ${josn_file}
    file_operation.Update Json File    target_json_file=${josn_file}    dist_operation=create
    ...  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1    parameter_operation=update    tceIpAddress=${host_vm_ip}
    ...  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1    parameter_operation=update    tceIdentifier=1
    ...  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1    parameter_operation=update    tcePortNumber=49151

Setup PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}
    Start collecting PCMD reports

Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Start Tshark For Nsetapx
    ${tshark_alias_tcp}=     Start Tshark For Custom Interface
    ...                          eth_interface='eth3'
    ...                          log_dirpath=${RESULT_DIR}${/}${TEST_NAME}${/}${TSHARK_SUBDIR}
    ...                          log_filename_prefix='tcp_nsetapx'
    ...                          capture_filter='tcp'
    [Return]    ${tshark_alias_tcp}

Start Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${LOG_PATH}
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Attach 2 UEs with SBA trace type
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}     ${end_ue_id}+${1}
        wtsrunner.amf_ue_ics_param    id=1   ue=${ue_id}   trace_ref_id=${ue_id}   trace_rec_session_ref_id=${ue_id}   trace_activation=off
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        Run Keyword If    ${ue_id}==1
        ...    wtsrunner.amf_ue_ics_param    id=1    ue=${ue_id}   object_id=1    location_reporting_reference_id=1
                ...    trace_activation=on   trace_plmn=311:489   trace_ref_id=${ue_id}   trace_rec_session_ref_id=${ue_id}
                ...    trace_depth=maximum   ifaces_to_trace=NG-C,Xn-C,Uu    tce_ip=10.0.1.1
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        sleep  2s
        Run Keyword If    ${ue_id}==2
        ...    wtsrunner.ng_ue_trace_start   id=${ue_id}   trace_plmn=311:489   trace_ref_id=2   trace_rec_session_ref_id=${ue_id}
               ...    ifaces_to_trace=Xn-C,NG-C,Uu   trace_depth=maximum   tce_ip=10.0.1.1
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=dl    protocol=tcp    size=4048    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=ul    protocol=tcp    size=1048    burst=60
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=dl
        ${dl_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput}    Average data rate +(\\d+)    1
        ${cell_dl_tput}     Evaluate    int(${output[0]})>0
    END


Configure Routes in WTS

     Run    sudo ip addr add 10.0.1.131/24 dev eth3
     Run    sudo ip addr add 10.0.1.132/24 dev eth3
     Run    sudo ip addr add 10.0.1.133/24 dev eth3
     Run    sudo ip addr add 10.0.1.131/24 dev eth3
     Run    sudo ip addr add 10.0.1.134/24 dev eth3
     Run    sudo ip addr add 10.0.1.135/24 dev eth3
     Run    sudo ip addr add 10.0.1.136/24 dev eth3
     Run    sudo ip addr add 10.0.1.137/24 dev eth3
     Run    sudo ip addr add 10.0.1.99/24 dev eth3
     Run    sudo ip addr add 10.0.1.61/24 dev eth3
     Run    sudo ip addr add 10.0.1.123/24 dev eth3

Connect to WTS
     SSH.connect to    hostname=192.168.200.1     username=toor4nsn    password=oZPS0POrRieRtu   alias=WTS

Start UTE WTS
      Connect to WTS
      ${execute_info}    SSH.execute    cd /opt/iphy/latest; sudo ./edaemon --port 22222    connection=WTS
      ${execute_info}    SSH.execute    cd /opt/iphy/latest; ./egate --port 20000    connection=WTS


Disconnect WTS And Egate Session
     Run Keyword And Ignore Error    teardown_egate
     Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Run cfg file

       [Arguments]    ${wts_cfg_file_TC}
    Stop Edaemon and Egate process
    Stop Sim_enb

    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000

    wtsrunner.configure                   file=${wts_cfg_file_TC}
    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240
    Sleep    30s

     wtsrunner.enb_x2_link_up    enb=1    target=2
     sleep    30s


Delta file commissioning for CA
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_configuration}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin

Start Tcpdump On WTS
    ${command}=     Set Variable    sudo tcpdump -i any -w /tmp/NODECPRT_GNB.pcap > /dev/null 2>&1 &
    Start Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    [Return]       NODECPRT_GNB.pcap

Stop Tcpdump On WTS

    ${command}=    Set Variable    sudo pkill tcpdump
    Start Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    Run      cp /tmp/NODECPRT_GNB.pcap ${Log_Path}/NODECPRT_GNB.pcap
    [Return]       NODECPRT_GNB.pcap

Start DCAP service on the testline
     Run     utf_lab-controller start
     Sleep    60s


DCAP_Start_Trace_with_gnb_custom_profile

    [Arguments]    ${custom_profile_gnb}=${gnb_custom_profile}
    Start DCAP service on the testline
    rd.connect_to     host=127.0.0.1     port=9443     rd_version=dcapv3    secure=${True}
    &{bts_info}      create dictionary    host=10.0.1.2    port=443    username=Nemuadmin     password=nemuuser
    ${output}     rd.start_trace     tag=start_trace      duration=1     bts=${bts_info}
    ...           gnb_custom_profile=${custom_profile_gnb}    wait_for_activation=${True}
    set Test Variable       ${dcap_logs_started}    ${True}
    ${trace_id}   Get From Dictionary   ${output}   tracer_id
    set Test Variable       ${trace_id}
    sleep   60s    msg=stablising dcap trace collection
    [Return]    ${trace_id}

Stop DCAP Trace

    return from keyword if    '${dcap_logs_started}' == 'False'
    rd.stop_trace     trace_id=${trace_id}    timeout=180

Start AMF-UE traces for UE-71 AND UE-91
    wtsrunner.amf_ue_ics_param    id=1    ue=71    object_id=1    location_reporting_reference_id=1  trace_activation=on    trace_plmn=310:260
    ...    trace_ref_id=1    trace_rec_session_ref_id=1    trace_depth=medium    ifaces_to_trace=Uu,NG-C,Xn-C  tce_ip=10.0.1.1
    wtsrunner.amf_ue_ics_param    id=1    ue=91    object_id=2    location_reporting_reference_id=2    trace_activation=on    trace_plmn=310:260
     ...    trace_ref_id=2    trace_rec_session_ref_id=2    trace_depth=medium    ifaces_to_trace=Uu,NG-C,Xn-C  tce_ip=10.0.1.1

Stop AMF-UE traces for UE-71 AND UE-91
   wtsrunner.amf_ue_ics_param    id=1    ue=71    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1
   wtsrunner.amf_ue_ics_param    id=1    ue=91    trace_activation=off     trace_ref_id=2    trace_rec_session_ref_id=2

CB013789 Suite Setup
     Log to console      "suite setup"


CB013789 Suite Teardown
     Log to console      "suite teardown"

Fetch C-RNTI of all UEs
      wtsrunner.ue_disp    id=72
      ${output}    Read WTS Output Until Pattern Matches    imeisv    10
      Create File     ${OUTPUT_DIR}/regst_72.txt     ${output}
      ${crnti_72}    Run     awk '/C-RNTI/ {print $2}' ${OUTPUT_DIR}/regst_72.txt
   	  Set global variable    ${crnti_72}

      wtsrunner.ue_disp    id=92
      ${output}    Read WTS Output Until Pattern Matches    imeisv    10
      Create File     ${OUTPUT_DIR}/regst_92.txt     ${output}
      ${crnti_92}    Run     awk '/C-RNTI/ {print $2}' ${OUTPUT_DIR}/regst_92.txt
   	  Set global variable    ${crnti_92}

Start PDU Session AND Traffic ON UE-${ue_id}

      wtsrunner.ue_register    id=${ue_id}
      sleep    2s
   	  wtsrunner.set_pdu_param    ue=${ue_id}  pdu=1    trf_type=internal
   	  sleep    10s
      wtsrunner.ue_pdu_session_setup    pdu=1    ue=${ue_id}    nwslice=1  gw=1
      sleep   5s
      wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=dl    trf_id=1    mbps=100
      wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=ul    trf_id=1    mbps=100
      wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=dl    trf_id=2    mbps=100
      wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=ul    trf_id=2    mbps=100
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}    pdu=1 qosflows_to_add=2 by=amf
      sleep    10s
      wtsrunner.ue_stats_nr    id=${ue_id}    scell=0-2    type=pdsch
	   wtsrunner.ue_stats_nr    id=${ue_id}    scell=0-2    type=pusch


Register UE-73 and Start traffic
      wtsrunner.ue_register    id=73
      sleep    5s
      wtsrunner.set_pdu_param    ue=73  pdu=1    trf_type=internal
   	  sleep    10s
      wtsrunner.ue_pdu_session_setup    pdu=1    ue=73    nwslice=1  gw=1
      sleep   5s
      wtsrunner.trf_data_start    ue=73   pdu=1    dir=dl    trf_id=1    mbps=100
      wtsrunner.trf_data_start    ue=73    pdu=1    dir=ul    trf_id=1    mbps=100
      wtsrunner.trf_data_start    ue=73    pdu=1    dir=dl    trf_id=2    mbps=100
      wtsrunner.trf_data_start    ue=73   pdu=1    dir=ul    trf_id=2    mbps=100
       sleep    5s


Detach all UEs
       wtsrunner.ue_deregister    id=72    ue_deregister_type=switch_off
       wtsrunner.ue_deregister    id=92    ue_deregister_type=switch_off

Detach UE_73
       wtsrunner.ue_deregister    id=73    ue_deregister_type=switch_off

Change vm ip in scf
    ${host_vm_ip}=  Run    ip addr show | grep 'inet 10.42' | awk '{print $2}' | cut -d/ -f1
#     taf.config.scf.Load Scf    ${scf}
     taf.sbts.oam.coam.admin.Setup Admin
     CoamAdmin.Create Delta     delta_id=tce

     taf.sbts.oam.coam.admin.append_managed_object_to_delta   dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1       operation=create    delta_id=tce
     taf.sbts.oam.coam.admin.append_parameter_update_to_delta  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1   parameter=tceIdentifier
     ...    value=1   delta_id=tce
     taf.sbts.oam.coam.admin.append_parameter_update_to_delta     dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1    parameter=tceIpAddress
           ...    value=${host_vm_ip}      delta_id=tce
     ${tce_delta}=    CoamAdmin.Get Delta   delta_id=tce
     taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${tce_delta}    skip_parameter_relation_errors=True
     taf.sbts.oam.coam.admin.Teardown admin

Remove unwanted parameter
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_configuration_1}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin


Check SIB messagges for all cells
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 7: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 8: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 10: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 11: SystemInformationBlockType1-NR updated

Get PDML file from pcap

        ${pdmlFile}=    Run Process    tshark    -r    /home/ute/logs/NODECPRT_GNB.pcap   -Y    nsetapx    -w   /home/ute/logs/NODECPRT_GNB.pcmd.pcap
        ${pdmlFile}=     Run    tshark -r /home/ute/logs/NODECPRT_GNB.pcmd.pcap -T pdml > /home/ute/logs/CPRT.pdml
        [Return]    ${pdmlFile}

Verify syslog for 8000 cancel time
      [Arguments]    ${sys_dir}
      ${tcetime}=    Run   cat ${sys_dir}/gnb_syslog.log |grep -i "deactivating, filtering timer" |awk '{print $15}'| awk -F's' '{print $1}'
      ${tcestart}=    Run   cat ${sys_dir}/gnb_syslog.log |grep -i "deactivating, filtering timer" |awk '{print $2}'| awk -F'.' '{print $1}'
      ${alarmtime}=    Run   cat ${sys_dir}/gnb_syslog.log |grep -i "processDeactivation for {inactive 8000" |awk '{print $2}'| awk -F'.' '{print $1}'
      ${t1}=   Evaluate  (datetime.datetime.strptime('${alarmtime}','${TIME_FORMAT}') - datetime.datetime.strptime('${tcestart}','${TIME_FORMAT}'))
      ${sec_time}=  convert to string  ${t1}
      ${sec_time}=  Split string  ${sec_time}   :
      should be true    ${sec_time[2]}==${tcetime}






syslog crash verification
#K2 DSP crash
    ${1}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6706      alias=feat_act
    ${2}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 6707      alias=feat_act
    ${3}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6709      alias=feat_act

#K2 ARM Application crash
    ${4}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6708      alias=feat_act
	${5}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 4019      alias=feat_act
	${6}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act
#AXM ARM crash
	${7}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6450      alias=feat_act
	${8}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act
	${9}=    taf.sw.syslog.count_syslog_messages      regexp=BTSOM_COLLECT_DSP_CRASH_LOGS      alias=feat_act
    ${10}=    taf.sw.syslog.count_syslog_messages      regexp=EAaErrorFatality_Fatal      alias=feat_act

	Should be True     ${1} == 0
	Should be True     ${2} == 0
	Should be True     ${3} == 0
	Should be True     ${4} == 0
	Should be True     ${5} == 0
	Should be True     ${6} == 0
	Should be True     ${7} == 0
	Should be True     ${8} == 0
	Should be True     ${9} == 0
	Should be True     ${10} == 0


Start Tshark on br-utf_lab_net
      start_tshark   log_filename=CB013789_ABC.pcap    eth_interface=br-utf_lab_net   capture_filter=less 15000   alias=ABC

verify no resource for gbr bearer
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
     ...    number_of_messages=1    alias=resource_check_Deact

Stop Tshark on br-utf_lab_net
     stop_tshark     alias=ABC

Start Tshark on eth3
      start_tshark   log_filename=CB013789_3CC.pcap    eth_interface=eth3   capture_filter=less 10000   alias=3CC

Stop Tshark on eth3
     stop_tshark     alias=3CC

Verify 3CC CA
     Verify_tshark_for_at_least_given_number_of_messages      number_of_messages=1    alias=3CC
          ...    packet_filter=nr-rrc.sCellToAddModList == 2 && nr-rrc.sCellIndex == 1 && nr-rrc.physCellId == 51

	 Verify_tshark_for_at_least_given_number_of_messages      number_of_messages=1    alias=3CC
	      ...     packet_filter=nr-rrc.sCellToAddModList == 2 && nr-rrc.sCellIndex == 2 && nr-rrc.physCellId == 61
     Sleep     5s

verify vendor_extention_records for DU_CA_Records

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 7 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 7 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 7 && nsetapx.nrci == 00:00:04:00:80

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 14 && nsetapx.cellIdentity == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 14 && nsetapx.cellIdentity == 00:00:04:00:b0
     Verify_tshark_for_at_least_given_number_of_messages  number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 14 && nsetapx.cellIdentity == 00:00:04:00:80

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 8 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 8 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 8 && nsetapx.nrci == 00:00:04:00:80

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 20 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 20 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 20 && nsetapx.nrci == 00:00:04:00:80

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 21 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 21 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 21 && nsetapx.nrci == 00:00:04:00:80

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 22 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 22 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 22 && nsetapx.nrci == 00:00:04:00:80

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 24 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 24 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 24 && nsetapx.nrci == 00:00:04:00:80

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 26 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 26 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 26 && nsetapx.nrci == 00:00:04:00:80

    Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 28 && nsetapx.nrci == 00:00:04:00:10
     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 28 && nsetapx.nrci == 00:00:04:00:b0
     Verify_tshark_for_given_number_of_messages   number_of_messages=0    alias=ABC
     ...    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 28 && nsetapx.nrci == 00:00:04:00:80

verify vendor_extention_records for CU_UP_Records
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 1
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 2
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 3
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 4
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 5
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 0
     ...    number_of_messages=0    alias=ABC


verify vendor_extention_records for CU_CP_Records
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 0
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 4
     ...    number_of_messages=0    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 10
     ...    number_of_messages=0    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 11
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 13
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 14
     ...    number_of_messages=0    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 18
     ...    number_of_messages=1    alias=ABC

Start Tshark on br-utf_lab_net_1
      start_tshark   log_filename=CB013789_ABC_1.pcap    eth_interface=br-utf_lab_net   capture_filter=less 15000   alias=ABC_multi_ue

Stop Tshark on br-utf_lab_net_1
     stop_tshark     alias=ABC_multi_ue

verify vendor_extention_records for CU_CP_Records_multi-UE

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC_multi_ue
     ...    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 0 && nsetapx.crnti == ${crnti_72}

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC_multi_ue
     ...    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 0 && nsetapx.crnti == ${crnti_92}


     Verify_tshark_for_given_number_of_messages   packet_filter=nsetapx.CuVendorExtensionRecordDataType == 4
     ...    number_of_messages=0    alias=ABC_multi_ue

     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 10
     ...    number_of_messages=0    alias=ABC_multi_ue


	 Verify_tshark_for_at_least_given_number_of_messages     number_of_messages=1    alias=ABC_multi_ue
     ...     packet_filter=nsetapx.CuVendorExtensionRecordDataType == 11 && nsetapx.cellIdentity == 00:00:04:00:10 && nsetapx.crnti == ${crnti_72}

     Verify_tshark_for_at_least_given_number_of_messages     number_of_messages=1    alias=ABC_multi_ue
     ...     packet_filter=nsetapx.CuVendorExtensionRecordDataType == 11 && nsetapx.cellIdentity == 00:00:04:00:10 && nsetapx.crnti == ${crnti_92}


     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC_multi_ue
     ...    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 13 && nsetapx.crnti == ${crnti_72}

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC_multi_ue
     ...    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 13 && nsetapx.crnti == ${crnti_92}

     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 14
     ...    number_of_messages=0    alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC_multi_ue
     ...    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 18 && nsetapx.crnti == ${crnti_72}

     Verify_tshark_for_at_least_given_number_of_messages   number_of_messages=1    alias=ABC_multi_ue
     ...    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 18 && nsetapx.crnti == ${crnti_92}

verify vendor_extention_records for CU_UP_Records_multi-UE

     Verify_tshark_for_given_number_of_messages     packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 0
     ...    number_of_messages=0     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 1
     ...    number_of_messages=2     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 2
     ...    number_of_messages=2     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 3
     ...    number_of_messages=2     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 4
     ...    number_of_messages=2     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 5
     ...    number_of_messages=2    alias=ABC_multi_ue

verify vendor_extention_records for DU_CA Records_multi-UE
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 7 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 7 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 14 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 14 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 0 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 0 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 20 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 20 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 21 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 21 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 22 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 22 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 24 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 24 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 26 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 26 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 28 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 28 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 36 && nsetapx.crnti == ${crnti_92}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 36 && nsetapx.crnti == ${crnti_72}
     ...    number_of_messages=1     alias=ABC_multi_ue


Verify PCMD Trace Records for a Trace Record
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}      ${pass_criteria}= >=1
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria=${pass_criteria}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Stop UL and DL data Traffic For all UEs
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        Log to Console    \nStopping Data Traffic...
        wtsrunner.trf_data_stop     ue=${ue_idx}   pdu=${pdu_id}
        ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
        ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
        Log to Console    ${output}
    END
