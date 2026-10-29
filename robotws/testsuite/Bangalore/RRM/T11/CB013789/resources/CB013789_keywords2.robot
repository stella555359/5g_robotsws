*** Settings ***
Documentation    :copyright: Nokia

Variables        ta5g_global_var
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
Library         taf.collectors.tcpdump         WITH NAME    tcpdump
Library         taf.collectors.core            WITH NAME    core
Library         taf.converters.pcaptopdml      WITH NAME    pcaptopdml
Library         taf.collectors.tshark          WITH NAME    tshark
Library         taf.collectors.l2stream3       WITH NAME    ttistream
Library         taf.collectors.btslog          WITH NAME    btslog
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
Library         ute_tshark
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
${BSR_FILENAME}=    BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${PDU_session_resource_setup_without_ICS}   PDU SESSION ID-.* setup.*reestablishment complete
@{gnb_custom_profile}           controlPlane5g    Tracer_5g

${TC1_delta_file_name}     ${scf_folder}/SBA_MO_creation.json
${TC1_delta_revert}     ${scf_folder}/SBA_MO_revert.json
${wts_cfg_file_TC1}     ${wts_cfg_folder}/D_B1_TC1.cfg
${wts_cfg_file_TC3}     ${wts_cfg_folder}/basic_setup24.cfg
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


*** Keywords ***
Update bsr package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${bsr_iphy_folder} ${BSR_FILEPATH}    shell=yes
    ADMIN Setup Admin
    ADMIN Update Software With Activation    sw_package=${bsr_iphy_folder}/${BSR_FILENAME}

Update TCE IP address in josn
    [Arguments]    ${host_vm_ip}   ${josn_file}
    file_operation.Update Json File    target_json_file=${josn_file}    dist_operation=create
    ...  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1    parameter_operation=update    tceIpAddress=${host_vm_ip}
    ...  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1    parameter_operation=update    tceIdentifier=1
    ...  dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1    parameter_operation=update    tcePortNumber=49151

Testcase setup with delta Commissioning
    [Arguments]    ${josn_file}   ${wts_file}   ${num_of_cells}
    #${host_vm_ip}=  Get Host IP Address  host_index=1
    #Update TCE IP address in josn    ${host_vm_ip}   ${josn_file}
    Send Delta Commissioning     ${josn_file}
    Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_file}   ${num_of_cells}
    Setup PCMD

Start Subscriber trace for UE73 from AMF
      log to console     "Starting SBA Traces for UE=73
      wtsrunner.amf_ue_ics_param    id=1    ue=73    object_id=1    location_reporting_reference_id=1  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=1     trace_rec_session_ref_id=1     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1     tce_ip=10.0.1.1

Start Subscriber trace for UE74 from AMF
      log to console     "Starting SBA Traces for UE=74
      wtsrunner.amf_ue_ics_param    id=1    ue=74    object_id=2    location_reporting_reference_id=2  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=2     trace_rec_session_ref_id=2     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1    tce_ip=10.0.1.1

Start Subscriber trace for UE93 from AMF
      log to console     "Starting SBA Traces for UE=93
      wtsrunner.amf_ue_ics_param    id=1    ue=93    object_id=3    location_reporting_reference_id=3  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=3     trace_rec_session_ref_id=3     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1    tce_ip=10.0.1.1

Start Subscriber trace for UE94 from AMF
      log to console     "Starting SBA Traces for UE=94
      wtsrunner.amf_ue_ics_param    id=1    ue=94    object_id=4    location_reporting_reference_id=4  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=4     trace_rec_session_ref_id=4     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1    tce_ip=10.0.1.1




Stop Subscriber trace for UE73 from AMF
     wtsrunner.amf_ue_ics_param    id=1    ue=73    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1
Stop Subscriber trace for UE74 from AMF
     wtsrunner.amf_ue_ics_param    id=1    ue=74    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1
Stop Subscriber trace for UE72 from AMF
     wtsrunner.amf_ue_ics_param    id=1    ue=93    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1
Stop Subscriber trace for UE92 from AMF
     wtsrunner.amf_ue_ics_param    id=1    ue=94    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1


Start Subscriber trace for UE from AMF END
      log to console     "Starting SBA Traces for all UE
      wtsrunner.amf_ue_ics_param    id=1    ue=71    object_id=1    location_reporting_reference_id=1  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=1     trace_rec_session_ref_id=1     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.0.1.1

      wtsrunner.amf_ue_ics_param    id=1    ue=72    object_id=1    location_reporting_reference_id=1  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=1     trace_rec_session_ref_id=1     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.0.1.1

      wtsrunner.amf_ue_ics_param    id=1    ue=91    object_id=1    location_reporting_reference_id=1  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=1     trace_rec_session_ref_id=1     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.0.1.1

      wtsrunner.amf_ue_ics_param    id=1    ue=92    object_id=1    location_reporting_reference_id=1  trace_activation=on
      ...    trace_plmn=310:260     trace_ref_id=1     trace_rec_session_ref_id=1     trace_depth=maximum
      ...    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.0.1.1


Stop Subscriber trace for UE from AMF END
     wtsrunner.amf_ue_ics_param    id=1    ue=71    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1
     wtsrunner.amf_ue_ics_param    id=1    ue=72    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1
     wtsrunner.amf_ue_ics_param    id=1    ue=91    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1
     wtsrunner.amf_ue_ics_param    id=1    ue=92    trace_activation=off     trace_ref_id=1    trace_rec_session_ref_id=1


Load CFG Config And Verify cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}   ${no_of_cells}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    8min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    30min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Check gNB Airscale is Ready - ${BBoard_Type}
    Log To console     loading cfg file
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    FOR     ${i}    IN RANGE   1   ${no_of_cells}+1
        Wait Until Keyword Succeeds     200s    5s	Check MIB_SIB status of GNB cell   ${i}
    END

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

Detach UEs
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    FOR	  ${ue_idx}   IN RANGE    ${start_ue_id}   ${end_ue_id}+1
        wtsrunner.ue_deregister    id=${ue_idx}    ue_deregister_type=switch_off
    END

Verify PDU Session resoruce setup response
    [Arguments]    ${output}    ${ue_id}     ${pdu_session_id}
    [Documentation]    This keyword checks the PDU Session resoruce setup response without ICS
    ...                in the output file for the SA variant
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     UE-${ue_id}.*\\n.*PDU SESSION ID-${pdu_session_id} setup/reestablishment complete

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

    wtsrunner.configure                   file=${wts_cfg_file_TC3}
    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240
    Sleep    30s

     wtsrunner.enb_x2_link_up    enb=1    target=2
     sleep    30s


Delta file commissioning for SBA_1
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_configuration}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin

Delta file commissioning for SBA_Del
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_configuration1}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin

Delta file commissioning for SBA_addation
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_configuration2}    skip_parameter_relation_errors=True
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

Stop DCAP service on the testline
     Run     utf_lab-controller stop
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


Register UE and Fetch CRNTI for UE-71
      wtsrunner.ue_register    id=71
      sleep    2s
      ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	  Create File     ${OUTPUT_DIR}/regst_71.txt     ${output}
      ${crnti_71}    Run     cat ${OUTPUT_DIR}/regst_71.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2

      ${crnti_71}    Run    grep -i crnti ${OUTPUT_DIR}/regst_71.txt | awk -F 'crnti:' '{print $2}' | cut -d ' ' -f 2
   	  Set global variable    ${crnti_71}




Register UE and Fetch CRNTI for UE-72
      wtsrunner.ue_register    id=72
      sleep    2s
      ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	  Create File     ${OUTPUT_DIR}/regst_72.txt     ${output}
      ${crnti_72}    Run     cat ${OUTPUT_DIR}/regst_72.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
   	  Set global variable    ${crnti_72}



Register UE and Fetch CRNTI for UE-91
      wtsrunner.ue_register    id=91
      sleep    2s
      ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	  Create File     ${OUTPUT_DIR}/regst_91.txt     ${output}
      ${crnti_91}    Run     cat ${OUTPUT_DIR}/regst_91.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
   	  Set global variable    ${crnti_91}



Register UE and Fetch CRNTI for UE-92
      wtsrunner.ue_register    id=92
      sleep    2s
      ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	  Create File     ${OUTPUT_DIR}/regst_92.txt     ${output}
      ${crnti_92}    Run     cat ${OUTPUT_DIR}/regst_92.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
   	  Set global variable    ${crnti_92}



Register UE and Fetch CRNTI for UE-73
      wtsrunner.ue_register    id=73
      sleep    2s
      ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	  Create File     ${OUTPUT_DIR}/regst_73.txt     ${output}
      ${crnti_73}    Run     cat ${OUTPUT_DIR}/regst_73.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
   	  Set global variable    ${crnti_73}

Register UE and Fetch CRNTI for UE-74
      wtsrunner.ue_register    id=74
      sleep    2s
      ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	  Create File     ${OUTPUT_DIR}/regst_74.txt     ${output}
      ${crnti_74}    Run     cat ${OUTPUT_DIR}/regst_74.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
   	  Set global variable    ${crnti_74}


Register multi-UEs and Fetch CRNTI
      Register UE and Fetch CRNTI for UE-71
      Register UE and Fetch CRNTI for UE-72
      Register UE and Fetch CRNTI for UE-91
      Register UE and Fetch CRNTI for UE-92


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


Fetch C-RNTI of all UEs
      wtsrunner.ue_disp    id=93
      ${output}    Read WTS Output Until Pattern Matches    imeisv    10
      Create File     ${OUTPUT_DIR}/regst_93.txt     ${output}
      ${crnti_93}    Run     awk '/C-RNTI/ {print $2}' ${OUTPUT_DIR}/regst_93.txt
   	  Set global variable    ${crnti_93}

      wtsrunner.ue_disp    id=94
      ${output}    Read WTS Output Until Pattern Matches    imeisv    10
      Create File     ${OUTPUT_DIR}/regst_94.txt     ${output}
      ${crnti_94}    Run     awk '/C-RNTI/ {print $2}' ${OUTPUT_DIR}/regst_94.txt
   	  Set global variable    ${crnti_94}

Detach all UEs
       wtsrunner.ue_deregister    id=93    ue_deregister_type=switch_off
       wtsrunner.ue_deregister    id=94    ue_deregister_type=switch_off

Detach UE
       wtsrunner.ue_deregister    id=71    ue_deregister_type=switch_off

Detach1 UEs
       wtsrunner.ue_deregister    id=73    ue_deregister_type=switch_off

Detach2 UEs
       wtsrunner.ue_deregister    id=74    ue_deregister_type=switch_off

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

        ${pdmlFile}=  Run Process    tshark    -r    /home/ute/logs/NODECPRT_GNB.pcap   -Y    nsetapx    -w   /home/ute/logs/NODECPRT_GNB.pcmd.pcap
        ${pdmlFile}=  Run    tshark -r /home/ute/logs/NODECPRT_GNB.pcmd.pcap -T pdml > /home/ute/logs/CPRT.pdml
        [Return]    ${pdmlFile}
