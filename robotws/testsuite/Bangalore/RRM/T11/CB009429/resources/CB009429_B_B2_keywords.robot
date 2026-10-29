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
Library         file_operation.py

*** Variables ***
${scf_folder}       ${CURDIR}/../config/scf/
${bsr_iphy_folder}     ${CURDIR}/../config/
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_folder}     ${CURDIR}/../config/wts
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${connection}				admin_1
@{ListofCountervalues1}=    M55125C09530
${path1}=         BTS']['MRBTS-1']['NRBTS-1']['[VRF_BLR_T10_JIO_FUll_TDD_1]NRCELL-1']['NNGCC
${ue_id}=     3
*** Keywords ***

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

Start VONR call on UE-${ue_id}
      wtsrunner.ue_nr_rrc_setup_param     id=${ue_id}    establishment_cause=mo-VoiceCall
      wtsrunner.ue_register    id=${ue_id}
      sleep    2s
   	  wtsrunner.set_pdu_param    ue=${ue_id}  pdu=1    trf_type=internal
   	  sleep    2s
      wtsrunner.ue_pdu_session_setup    pdu=1    ue=${ue_id}    nwslice=1  gw=1
      sleep   2s
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=2 by=amf
      sleep   2s
      wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=dl    trf_id=1    qfi=2
      sleep   2s
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=3 by=amf
      sleep   2s
      wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=dl    trf_id=2    qfi=3


Delete Normal VONR QoSflow
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_del=3    by=amf

Verify fiveQI1RrcRelDelayTimer started
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameActive   alias=feat_act
	Should be True     ${1} == 1

Verify fiveQI1RrcRelDelayTimer stop
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameInActive   alias=feat_act
	Should be True     ${1} == 1

Verify fiveQI1RrcRelDelayTimer started post Ho
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameActive   alias=feat_act
	Should be True     ${2} == 2

Verify fiveQI1RrcRelDelayTimer started after new VONR call
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameActive   alias=feat_act
	Should be True     ${2} == 2

Verify fiveQI1RrcRelDelayTimer stop post Ho
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameInActive   alias=feat_act
	Should be True     ${2} == 2

Add QoSflow for VONR call
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=3    by=amf

Verify 5QI-1 addition

    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 1
     ...    number_of_messages=1    alias=ABC

#    Registration complete
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nas-5gs.mm.message_type == 0x43
     ...    number_of_messages=1    alias=ABC

#    Authentication response
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nas-5gs.mm.message_type == 0x57
     ...    number_of_messages=1    alias=ABC

#    Security mode command
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nas-5gs.mm.message_type == 0x5d
     ...    number_of_messages=1    alias=ABC


Verify 5QI-1 addition after New VONR call

    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 1
     ...    number_of_messages=1    alias=ABC1

    Verify_tshark_for_given_number_of_messages    packet_filter=nas-5gs.mm.message_type == 0x43
     ...    number_of_messages=0    alias=ABC1

    Verify_tshark_for_given_number_of_messages    packet_filter=nas-5gs.mm.message_type == 0x57
     ...    number_of_messages=0    alias=ABC1

    Verify_tshark_for_given_number_of_messages    packet_filter=nas-5gs.mm.message_type == 0x5d
     ...    number_of_messages=0    alias=ABC1

Detach UE-${ue_id}
       wtsrunner.ue_deregister    id=${ue_id}    ue_deregister_type=switch_off

Check SIB messagges for all cells
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 3 cell 5: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 3 cell 6: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 3 cell 7: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 3 cell 8: SystemInformationBlockType1-NR updated

Start Tshark on eth3
      start_tshark   log_filename=CB009429_ABC.pcap    eth_interface=eth3   capture_filter=less 15000   alias=ABC

Start Tshark on eth3 after New VONR call
      start_tshark   log_filename=CB009429_ABC1.pcap    eth_interface=eth3   capture_filter=less 15000   alias=ABC1

Stop Tshark on eth3
     stop_tshark     alias=ABC

Stop Tshark on eth3 after New VONR call
     stop_tshark     alias=ABC1


syslog crash verification
#K2 DSP crash
    ${1}=    taf.sw.syslog.count_syslog_messages    regexp=faultID: 6706      alias=feat_act
    ${2}=    taf.sw.syslog.count_syslog_messages    regexp=faultId: 6707      alias=feat_act
    ${3}=    taf.sw.syslog.count_syslog_messages    regexp=faultID: 6709      alias=feat_act

#K2 ARM Application crash
    ${4}=    taf.sw.syslog.count_syslog_messages  regexp=faultID: 6708      alias=feat_act
	${5}=    taf.sw.syslog.count_syslog_messages  regexp=faultId: 4019      alias=feat_act
	${6}=    taf.sw.syslog.count_syslog_messages  regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded  alias=feat_act
#AXM ARM crash
	${7}=    taf.sw.syslog.count_syslog_messages   regexp=faultID: 6450      alias=feat_act
	${8}=    taf.sw.syslog.count_syslog_messages  regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act
	${9}=    taf.sw.syslog.count_syslog_messages   regexp=BTSOM_COLLECT_DSP_CRASH_LOGS      alias=feat_act
    ${10}=    taf.sw.syslog.count_syslog_messages  regexp=EAaErrorFatality_Fatal      alias=feat_act

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

Perform Inter-gNb HO to gnb-2 cell-7 via NG Interface
#    [Arguments]     ${first_ue}     ${last_ue}
#    FOR	    ${ue_id}   IN RANGE    ${first_ue}	  ${last_ue}+1
        log to console      "Performing Inter-gNb HO to gnb-2 now for UE-${ue_id}"
        wtsrunner.ue_meas_cfg_disp    id=${ue_id}
        sleep     2s
        wtsrunner.ue_measurement_send_nr    id=${ue_id}  meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
        sleep     2s
        wtsrunner.ue_meas_cfg_disp    id=${ue_id}
        sleep     2s
        wtsrunner.ue_measurement_send_nr    id=${ue_id}  meas_id=5 event=A3 srsrp_nr=9 phycell_id=56 nrsrp_nr=85
        sleep     2s
        wtsrunner.ue_disp    id=${ue_id}
        ${output}  wtsrunner.read_wtsemu_output_until_re    expected=UE3: Inter-eNB handover from EXT_ENB-2.3 to EXT_ENB-3.7
        ...     timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    UE3: Inter-eNB handover from EXT_ENB-2.3 to EXT_ENB-3.7
        ...      partial_match=${TRUE}
        Log to Console    ${output}

Perform Delta changes for intergNB_NGHO
    log to console     "Doing Delta Changes for GNB-1"
    taf.sbts.oam.coam.admin.Setup admin    bts_host=10.0.1.2    bts_port=443   use_ssl=True
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${scfc_gnb1}    skip_parameter_relation_errors=True    host_id=1
    taf.sbts.oam.coam.admin.Teardown admin
    log to console     "Doing Delta Changes for GNB-2"
    taf.sbts.oam.coam.admin.Setup admin    bts_host=10.0.1.3    bts_port=443   use_ssl=True
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${scfc_gnb2}    skip_parameter_relation_errors=True    host_id=2
    taf.sbts.oam.coam.admin.Teardown admin

Get gNB2 IP address
    ${hostid1}  ${hostid2}  Get Host Addr
    set suite variable   ${hostid1}
    set suite variable   ${hostid2}

Delete New VONR QoSflow call
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_del=3    by=amf
