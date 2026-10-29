*** Settings ***

Documentation    :copyright: Nokia
...              :author: Vibha
...              :contact: vibha.k_p@nokia.com
...
...             TEST SET NAME:    CB015854-SR
...             TESTING SPLIT:    Refer CB015854 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB015854_CFAM


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library           taf.ul.ue.sim.env_setup
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta5g_cell_operations
Library          taf.sw.syslog

Library         Process
Library         Collections
Library         taf.converters.pcaptopdml      WITH NAME    pcaptopdml
Library         taf.collectors.tshark          WITH NAME    tshark
Library         taf.collectors.l2stream3       WITH NAME    ttistream
Library         taf.sbts.oam.coam.admin        WITH NAME    CoamAdmin

Library         taf.sw.dcap.rd                 WITH NAME    rd
Library         taf.sw.wtssim
Library         taf.ue.airphone
Library         taf.config.scf
Library         ta_emss
Library         ta5g_tshark
Library         ute_tshark

Library         ta5g_pm_counters
Library         String
Library           OperatingSystem
Library           Telnet

*** Variables ***
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/BSR/
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${bsr_iphy_folder}     ${CURDIR}/config/
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_folder}     ${CURDIR}/config/
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts

*** Keywords ***

start Data call on ue
         wtsrunner.ue_register    id=1
         sleep    2s
   	     wtsrunner.set_pdu_param    ue=1  pdu=1    trf_type=internal
   	     sleep    10s
         wtsrunner.ue_pdu_session_setup    pdu=1    ue=1    nwslice=1  gw=1
         sleep   5s
         wtsrunner.trf_data_start    ue=1  pdu=1    qfi=1    trf_id=1    dir=dl    mbps=10    seconds=3600
         sleep     2s
#         wtsrunner.trf_data_start    ue=1  pdu=1    qfi=1    trf_id=1    dir=ul    mbps=10    seconds=3600
#         sleep   10s


Configure MRL for UE1
     wtsrunner.amf_mobility_restriction_list_param   id=1   equiv_plmn=311:402
	 wtsrunner.amf_ue_ics_param   id=1    object_id=1     location_reporting_reference_id=1
	 ...     trace_activation=on     trace_plmn=311:402
	 ...     trace_ref_id=1      trace_rec_session_ref_id=1      trace_depth=medium      ifaces_to_trace=Uu,NG-C,Xn-C    tce_ip=10.0.1.1
	 ...     mobility_restriction_list_id=1


check NR stats
      wtsrunner.ue_stats_nr     id=1    type=pdsch
      ${output}    Wait Until Keyword Succeeds     1 min    2 sec    GET UE PDSCH Stats
      Get Lines Matching Regexp    ${output}    NR PDSCH Throughput    partial_match=${TRUE}
      [Return]      ${output}


GET UE PDSCH Stats
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Log to Console    ${output}
    should contain    ${output}    Average
    [Return]      ${output}


perform reverse handover
   wtsrunner.ue_measurement_send_nr     id=1    meas_id=1    event=A3    srsrp_nr=10    phycell_id=50    nrsrp_nr=40
   sleep     120s
   ${output}  wtsrunner.read_wtsemu_output_until_re    expected=GNB-3: UE1: NG Handover successfully completed at Source RAN
    ...     timeout=120
    ${output}         Get Lines Matching Regexp    ${output}    GNB-3: UE1: NG Handover successfully completed at Source RAN
    ...        partial_match=${TRUE}
    Log to Console    ${output}

verify successful HO in wireshark
       Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.radioNetwork == 2
     ...    number_of_messages=1    alias=ABC

verify successful reverse HO in wireshark
      Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.radioNetwork == 2
     ...    number_of_messages=1    alias=ABC

verify 5QI-1 and successful HO in wireshark
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 1
     ...    number_of_messages=1    alias=ABC
      Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.radioNetwork == 2
     ...    number_of_messages=1    alias=ABC

verify 5QI-65 and successful HO in wireshark
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 65
     ...    number_of_messages=1    alias=ABC

      Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.radioNetwork == 2
     ...    number_of_messages=1    alias=ABC

verify 5QI-66 and successful HO in wireshark
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 66
     ...    number_of_messages=1    alias=ABC
      Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.radioNetwork == 2
     ...    number_of_messages=1    alias=ABC

Get_UE_Location
      [Arguments]  ${ue_id}=1
       wtsrunner.ue_disp    id=${ue_id}
       sleep     60s
     ${output}  wtsrunner.read_wtsemu_output_until_re    expected=\ncell
    ...     timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    "'\nenb' | '3'"
    Log to Console    ${output}


Verify 5QI-1 addition
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 1
     ...    number_of_messages=1    alias=ABC


Verify 5QI-65 addition
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 65
     ...    number_of_messages=1    alias=ABC


Verify 5QI-66 addition
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 66
     ...    number_of_messages=1    alias=ABC

start VONR call on ue 5QI_1
#         wtsrunner.ue_nr_rrc_setup_param     id=1    establishment_cause=mo-VoiceCall
         wtsrunner.ue_register    id=1
         sleep    2s
   	     wtsrunner.set_pdu_param    ue=1  pdu=1    trf_type=internal
   	     sleep    10s
         wtsrunner.ue_pdu_session_setup    pdu=1    ue=1    nwslice=1  gw=1
         sleep   5s
         wtsrunner.trf_data_start    ue=1  pdu=1    qfi=1    trf_id=1    dir=dl    mbps=10    seconds=3600
         sleep   2s
         wtsrunner.ue_pdu_session_modify    ue=1  pdu=1 qosflows_to_add=11 by=amf
         sleep   2s
         wtsrunner.ue_pdu_session_modify    ue=1  pdu=1 qosflows_to_add=1 by=amf
         sleep   2s
         ${output}  wtsrunner.read_wtsemu_output_until_re    expected=AMF-1: Added QosFlow with QFI:3 5QI:1
          ...     timeout=120
         ${output}         Get Lines Matching Regexp    ${output}    AMF-1: Added QosFlow with QFI:3 5QI:1
           ...        partial_match=${TRUE}
         Log to Console    ${output}
         sleep     2s
         wtsrunner.trf_data_start    ue=1  pdu=1 qfi=3 trf_id=1 dir=dl  rtp_codec=amr_12_2
         wtsrunner.trf_data_start    ue=1  pdu=1 qfi=3 trf_id=1 dir=ul  rtp_codec=amr_12_2
         sleep   10s

start VONR call on ue 5QI_65
         wtsrunner.ue_register    id=1
         sleep    2s
   	     wtsrunner.set_pdu_param    ue=1  pdu=1    trf_type=internal
   	     sleep    10s
         wtsrunner.ue_pdu_session_setup    pdu=1    ue=1    nwslice=1  gw=1
         sleep   5s
         wtsrunner.trf_data_start    ue=1  pdu=1    qfi=1    trf_id=1    dir=dl    mbps=10    seconds=3600
         sleep   2s
         wtsrunner.ue_pdu_session_modify    ue=1  pdu=1 qosflows_to_add=9 by=amf
         sleep   5s
         ${output}  wtsrunner.read_wtsemu_output_until_re    expected=AMF-1: Added QosFlow with QFI:2 5QI:65
          ...     timeout=150
         sleep   5s
         ${output}         Get Lines Matching Regexp    ${output}    AMF-1: Added QosFlow with QFI:2 5QI:65
           ...        partial_match=${TRUE}
         Log to Console    ${output}
         sleep     5s
         wtsrunner.trf_data_start    ue=1  pdu=1 qfi=3 trf_id=1 dir=dl  rtp_codec=amr_12_2
         wtsrunner.trf_data_start    ue=1  pdu=1 qfi=3 trf_id=1 dir=ul  rtp_codec=amr_12_2
         sleep   10s

start VONR call on ue 5QI_66
         wtsrunner.ue_register    id=1
         sleep    2s
   	     wtsrunner.set_pdu_param    ue=1  pdu=1    trf_type=internal
   	     sleep    10s
         wtsrunner.ue_pdu_session_setup    pdu=1    ue=1    nwslice=1  gw=1
         sleep   5s
         wtsrunner.trf_data_start    ue=1  pdu=1    qfi=1    trf_id=1    dir=dl    mbps=10    seconds=3600
         sleep   2s
         wtsrunner.ue_pdu_session_modify    ue=1  pdu=1 qosflows_to_add=10 by=amf
         sleep   8s
         ${output}  wtsrunner.read_wtsemu_output_until_re    expected=AMF-1: Added QosFlow with QFI:2 5QI:66
          ...     timeout=150
         sleep   12s
         ${output}         Get Lines Matching Regexp    ${output}    AMF-1: Added QosFlow with QFI:2 5QI:66
           ...        partial_match=${TRUE}
         sleep   8s
         Log to Console    ${output}
         sleep     2s
         wtsrunner.trf_data_start    ue=1  pdu=1 qfi=3 trf_id=1 dir=dl  rtp_codec=amr_12_2
         wtsrunner.trf_data_start    ue=1  pdu=1 qfi=3 trf_id=1 dir=ul  rtp_codec=amr_12_2
         sleep   10s

Start Tshark on eth3
      start_tshark    log_filename=Wireshark.pcap    eth_interface=eth3    capture_filter=less 15000    alias=ABC

Stop Tshark on eth3
     stop_tshark     alias=ABC


Change_UE_Location
    [Arguments]  ${ue_id}=1  ${enb_id}=2  ${cell_id}=1
    wtsrunner.ue_change_location    id=${ue_id}    enb=${enb_id}    cell=${cell_id}

Send_EventA3_Measurement_Report
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    Log to Console  \nUE${ue_id} Send A3 report for Handover
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=10    phycell_id=${phycell_id}    nrsrp_nr=40
    sleep     120s
     ${output}  wtsrunner.read_wtsemu_output_until_re    expected=GNB-3: UE1: NG Handover successfully completed at Target RAN
    ...     timeout=120
    ${output}         Get Lines Matching Regexp    ${output}    GNB-3: UE1: NG Handover successfully completed at Target RAN
    ...        partial_match=${TRUE}
    Log to Console    ${output}


detach_ue_with_power_off
    [Arguments]  ${ue_id}=1
    wtsrunner.ue_deregister   id=${ue_id}   ue_deregister_type=switch_off
    log to console  \nUE-${ue_id} Detached!

Configure Routes in WTS
     Run    sudo ip addr add 10.0.1.131/24 dev eth3
     Run    sudo ip addr add 10.0.1.132/24 dev eth3
     Run    sudo ip addr add 10.0.1.133/24 dev eth3
     Run    sudo ip addr add 10.0.1.134/24 dev eth3
     Run    sudo ip addr add 10.0.1.135/24 dev eth3
     Run    sudo ip addr add 10.0.1.136/24 dev eth3
     Run    sudo ip addr add 10.0.1.137/24 dev eth3
     Run    sudo ip addr add 10.0.1.138/24 dev eth3
     Run    sudo ip addr add 10.0.1.139/24 dev eth3
     Run    sudo ip addr add 10.0.1.140/24 dev eth3
     Run    sudo ip addr add 10.0.1.112/24 dev eth3
     Run    sudo ip addr add 10.0.1.113/24 dev eth3
     Run    sudo ip addr add 10.0.1.102/24 dev eth3
     Run    sudo ip addr add 10.0.1.101/24 dev eth3
     Run    sudo ip addr add 10.0.1.200/24 dev eth3


Update bsr package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${bsr_iphy_folder} ${BSR_FILEPATH}    shell=yes
    CoamAdmin.Setup Admin
    CoamAdmin.Update Software    sw_package=${bsr_iphy_folder}/${BSR_FILENAME}

Delta file commissioning for Handover
	CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_commission}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file de-commissioning for Handover
    CoamAdmin.Setup Admin      name=ABC
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_decommission}    skip_parameter_relation_errors=True
    ...     connection=ABC
    CoamAdmin.Teardown admin     connection=ABC


Run cfg file
    [Arguments]    ${wts_cfg_file_TC1}
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

    wtsrunner.configure                   file=${wts_cfg_file_TC1}
    Sleep    30s
    wtsrunner.Gnb Param    id=3    xn_listening_socket=1    send_xn_setup=true
    wtsrunner.Gnb Xn Link Up    gnb=3    target=2
    sleep    30s


Check SIB messagges for all cells_RJIO
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 5: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 6: SystemInformationBlockType1-NR updated


