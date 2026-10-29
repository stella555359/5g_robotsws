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
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/BSR/
${BSR_FILENAME}=    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${wts_cfg_file_TC3}     ${wts_cfg_folder}/wts_RJO_CB009429.cfg
${connection}				admin_1
@{ListofCountervalues1}=    M55125C09530
${path1}=         BTS']['MRBTS-1']['NRBTS-1']['[VRF_BLR_T10_JIO_FUll_TDD_1]NRCELL-1']['NNGCC
${ue_id}=     1
${ue_id1}=    91
*** Keywords ***

Configure Routes in WTS

     Run    sudo ip addr add 10.0.1.131/24 dev eth3
     Run    sudo ip addr add 10.0.1.132/24 dev eth3
     Run    sudo ip addr add 10.0.1.133/24 dev eth3
     Run    sudo ip addr add 10.0.1.134/24 dev eth3
     Run    sudo ip addr add 10.0.1.135/24 dev eth3
     Run    sudo ip addr add 10.0.1.136/24 dev eth3
     Run    sudo ip addr add 10.0.1.137/24 dev eth3
     Run    sudo ip addr add 10.0.1.138/24 dev eth3
     Run    sudo ip addr add 10.0.1.99/24 dev eth3
     Run    sudo ip addr add 10.0.1.121/24 dev eth3
     Run    sudo ip addr add 10.0.1.61/24 dev eth3
     Run    sudo ip addr add 10.0.1.101/24 dev eth3
     Run    sudo ip addr add 10.0.1.102/24 dev eth3
     Run    sudo ip addr add 10.0.1.103/24 dev eth3
     Run    sudo ip addr add 10.0.1.140/24 dev eth3
     Run    sudo ip addr add 10.0.2.90/24 dev eth3 ; sudo ip addr add 10.0.2.91/24 dev eth3 ; sudo ip addr add 10.0.2.92/24 dev eth3
     Run    sudo ip addr add 10.0.2.94/24 dev eth3 ; sudo ip addr add 10.0.1.104/24 dev eth3 ; sudo ip addr add 10.0.1.105/24 dev eth3
     Run    sudo ip addr add 10.0.1.106/24 dev eth3 ; sudo ip addr add 10.0.1.107/24 dev eth3 ; sudo ip addr add 10.0.1.108/24 dev eth3
     Run    sudo ip addr add 10.0.1.109/24 dev eth3 ; sudo ip addr add 10.0.1.12/24 dev eth3 ; sudo ip addr add 10.0.1.13/24 dev eth3
     Run    sudo ip addr add 10.0.1.14/24 dev eth3 ; sudo ip addr add 10.0.1.15/24 dev eth3



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

    Sleep    30s
    wtsrunner.enb_x2_link_up    enb=1    target=2
     sleep    30s


Delta file commissioning for HPA and RedCap

    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Add NRREL MOs and Activate CB009429_B#B1 scenario
    [Arguments]    ${Add_NRREL_MOs_CB009429_B_B1}    ${Activate_CB009429_B_B1}
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${Add_NRREL_MOs_CB009429_B_B1}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin
    Sleep    60s
    CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${Activate_CB009429_B_B1}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Start VONR call on UE-${ue_id}
      wtsrunner.ue_nr_rrc_setup_param     id=${ue_id}    establishment_cause=highPriorityAccess
      wtsrunner.ue_register    id=${ue_id}
      sleep    2s
   	  wtsrunner.set_pdu_param    ue=${ue_id}  pdu=1    trf_type=internal
   	  sleep    10s
      wtsrunner.ue_pdu_session_setup    pdu=1    ue=${ue_id}    nwslice=1  gw=1
      sleep   5s
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=2 by=amf
      sleep   2s
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=3 by=amf
      sleep   2s
      wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    dir=dl    trf_id=2    qfi=3



Verify fiveQI1RrcRelDelayTimer started
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameActive   alias=feat_act
	Should be True     ${1} == 1

Verify fiveQI1RrcRelDelayTimer stop
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameInActive   alias=feat_act
	Should be True     ${1} == 1

Verify fiveQI1RrcRelDelayTimer is not stopped
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameInActive   alias=feat_act
	Should be True     ${1} == 0

Add QoSflow for VONR call
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=3    by=amf

Change UE_${ue_id} location to ENB_${enb_id} Cell_${cell_id}
    wtsrunner.ue_change_location    id=${ue_id}    enb=${enb_id}    cell=${cell_id}

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
      Should Contain    ${file_content}          eNB 2 cell 7: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 8: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 10: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 11: SystemInformationBlockType1-NR updated

Send A1 measurement report and verify HO to cell_1
    wtsrunner.ue_measurement_send_nr    id=1    meas_id=4    event=A1    srsrp_nr=70
    Sleep    10s
    wtsrunner.ue_measurement_send_nr    id=1    meas_id=5    event=A1    scell=1    scell_rsrp=70
    sleep    30s
    ${output}  wtsrunner.read_wtsemu_output_until_re    expected=UE1: Intra-eNB handover from EXT_ENB-2.7 to EXT_ENB-2.1
    ...     timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    UE1: Intra-eNB handover from EXT_ENB-2.7 to EXT_ENB-2.1
    ...        partial_match=${TRUE}
    Log to Console    ${output}

Send A1 measurement report and verify HO to cell_2
    wtsrunner.ue_measurement_send_nr    id=1    meas_id=14    event=A1     srsrp_nr=70
    Sleep    10s
    wtsrunner.ue_measurement_send_nr    id=1    meas_id=15    event=A1    scell=1    scell_rsrp=70
    sleep    30s
    ${output}  wtsrunner.read_wtsemu_output_until_re    expected=UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
    ...     timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
    ...        partial_match=${TRUE}
    Log to Console    ${output}

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
    ${1}=    taf.sw.syslog.count_syslog_messages    regexp=faultID: 6706      alias=feat_act_2
    ${2}=    taf.sw.syslog.count_syslog_messages    regexp=faultId: 6707      alias=feat_act_2
    ${3}=    taf.sw.syslog.count_syslog_messages    regexp=faultID: 6709      alias=feat_act_2

#K2 ARM Application crash
    ${4}=    taf.sw.syslog.count_syslog_messages  regexp=faultID: 6708      alias=feat_act_2
	${5}=    taf.sw.syslog.count_syslog_messages  regexp=faultId: 4019      alias=feat_act_2
	${6}=    taf.sw.syslog.count_syslog_messages  regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded  alias=feat_act_2
#AXM ARM crash
	${7}=    taf.sw.syslog.count_syslog_messages   regexp=faultID: 6450      alias=feat_act_2
	${8}=    taf.sw.syslog.count_syslog_messages  regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act_2
	${9}=    taf.sw.syslog.count_syslog_messages   regexp=BTSOM_COLLECT_DSP_CRASH_LOGS      alias=feat_act_2
    ${10}=    taf.sw.syslog.count_syslog_messages  regexp=EAaErrorFatality_Fatal      alias=feat_act_2

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

Start Tshark for redcap ue
      start_tshark   log_filename=CB009429_ABC1.pcap    eth_interface=eth3   capture_filter=less 2000   alias=ABC1

Start VONR for RedCap call on UE-${ue_id1}
      wtsrunner.ue_nr_rrc_setup_param    id=${ue_id1}     establishment_cause=mo-VoiceCall
      wtsrunner.ue_register    id=${ue_id1}
      sleep    2s
   	  wtsrunner.set_pdu_param    ue=${ue_id1}  pdu=1    trf_type=internal
   	  sleep    10s
      wtsrunner.ue_pdu_session_setup    pdu=1    ue=${ue_id1}    nwslice=1  gw=1    request_type=initial-request
      sleep   5s
      wtsrunner.ue_pdu_session_modify    ue=${ue_id1}  pdu=1 qosflows_to_add=2 by=amf
      sleep   5s
      wtsrunner.ue_pdu_session_modify    ue=${ue_id1}  pdu=1 qosflows_to_add=3 by=amf
      sleep   2s
      wtsrunner.trf_data_start    ue=${ue_id1} pdu=1 qfi=3 trf_id=1 dir=dl  rtp_codec=custom

Verify RedCap addition

    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.fiveQI == 1
     ...    number_of_messages=1    alias=ABC1
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.RedCapIndication == 0
     ...    number_of_messages=1    alias=ABC1

Stop Tshark for redcap ue
     stop_tshark     alias=ABC1

Delete Normal RedcapVONR QoSflow
      wtsrunner.ue_pdu_session_modify    ue=${ue_id1}  pdu=1 qosflows_to_del=3    by=amf

Add QoSflow for RedCapVONR call
      wtsrunner.ue_pdu_session_modify    ue=${ue_id1}  pdu=1 qosflows_to_add=3    by=amf

Disconnect WTS And Egate Session
     Run Keyword And Ignore Error    teardown_egate
     Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Verify multi VONR established

     CoamAdmin.Setup Admin
     ${counter_List}=    CoamAdmin.get_counters_info       timeout=100    dist_name=BTS/MRBTS-1/NRBTS-1/NRCELL-1/NNGCC/M55125C09530
     CoamAdmin.Teardown admin
    ${count}=    set variable    ${counter_List['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']['M55125C09530']}
    ${a}=    get dictionary values    ${count}
    ${value}=    Set Variable    ${a[-1]}
     should be true    ${value} >= 5


Verify fiveQI1RrcRelDelayTimer started for multi-UE
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameActive   alias=feat_act_2
	Should be True     ${1} == 3

Verify fiveQI1RrcRelDelayTimer stop for multi-UE

	${log_content}=    operatingSystem.Get File    ${OUTPUTDIR}${/}feat_act_2.log/feat_act_2.log
    ${matches}=        Get Regexp Matches    ${log_content}    Timer FiveQI1RrcRelDelayTimer deleted.
    Should Not Be Empty      ${matches}
Verify voicefallback counter

     CoamAdmin.Setup Admin
     ${counter_List}=    CoamAdmin.get_counters_info       timeout=100    dist_name=BTS/MRBTS-1/NRBTS-1/NRCELL-1/NNGCC/M55125C09008
     CoamAdmin.Teardown admin
     ${count}=    set variable    ${counter_List['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']['M55125C09008']}
     ${a}=    get dictionary values    ${count}
     ${value}=    Set Variable    ${a[-1]}
     should be true    ${value} >= 3


Delta file commissioning for IRAT
     CoamAdmin.Setup Admin    name=ABC
     CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_IRAT}    skip_parameter_relation_errors=True
     CoamAdmin.Teardown admin


Delta file commissioning for No Resouce
     CoamAdmin.Setup Admin
     CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_No_Resorce}    skip_parameter_relation_errors=True
     CoamAdmin.Teardown admin

Feature deactivation by delta file
     CoamAdmin.Setup Admin
     CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_deactivation}    skip_parameter_relation_errors=True
     CoamAdmin.Teardown admin

Feature activation by delta file
     CoamAdmin.Setup Admin
     CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_activation}    skip_parameter_relation_errors=True
     CoamAdmin.Teardown admin

Decommission the feature changes
    [Arguments]    ${delta_file}
     CoamAdmin.Setup Admin
     CoamAdmin.perform_delta_recommissioning    delta_file=${delta_file}    skip_parameter_relation_errors=True
     CoamAdmin.Teardown admin
     Sleep    20s


Start Tshark on eth3 for re-direct
      start_tshark   log_filename=CB009429_ABC1.pcap    eth_interface=eth3   capture_filter=less 15000   alias=ABC_1

Stop Tshark on eth3 for re-direct
     stop_tshark     alias=ABC_1

Verify voice fallback to eutran
#radioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered (36)
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.radioNetwork == 36
     ...    number_of_messages=1    alias=ABC_1
#radioNetwork: redirection (41)
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=ngap.radioNetwork == 41
     ...    number_of_messages=1    alias=ABC_1

Start non-emergency VONR call on UE
       [Arguments]    ${i1}     ${i2}
    FOR    ${ue_id}    IN RANGE   ${i1}     ${i2}
         wtsrunner.ue_nr_rrc_setup_param     id=${ue_id}    establishment_cause=mo-VoiceCall
         wtsrunner.ue_register    id=${ue_id}
         sleep    2s
   	     wtsrunner.set_pdu_param    ue=${ue_id}  pdu=1    trf_type=internal
   	     sleep    10s
         wtsrunner.ue_pdu_session_setup    pdu=1    ue=${ue_id}    nwslice=1  gw=1
         sleep   5s
         wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=2 by=amf
         sleep   2s
         wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=3 by=amf
         sleep   2s
         wtsrunner.trf_data_start    ue=${ue_id}  pdu=1 qfi=3 trf_id=1 dir=dl  rtp_codec=custom
    END


Delete Normal VONR QoSflow
      wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_del=3    by=amf


Delete non-emergency VONR QoSflow UE
            [Arguments]    ${i1}     ${i2}
      FOR    ${ue_id}    IN RANGE   ${i1}     ${i2}
           wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_del=3    by=amf
      END


Check SIB messagges for all cells_RJIO
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 5: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 6: SystemInformationBlockType1-NR updated

Detach non-emergency VONR Call
              [Arguments]    ${i1}     ${i2}
      FOR    ${ue_id}    IN RANGE   ${i1}     ${i2}
             wtsrunner.ue_deregister    id=${ue_id}    ue_deregister_type=switch_off
      END
Add QoSflow for non-emergency VONR call
            [Arguments]    ${i1}     ${i2}
      FOR    ${ue_id}    IN RANGE   ${i1}     ${i2}
           wtsrunner.ue_pdu_session_modify    ue=${ue_id}  pdu=1 qosflows_to_add=3    by=amf
      END


Verify fiveQI1RrcRelDelayTimer not started
    ${1}=    taf.sw.syslog.count_syslog_messages   regexp=ueFiveQI1RrcRelDelayTimerBecameActive   alias=feat_act_1
	Should be True     ${1} == 0

Verify fiveQI1RrcRelDelayTimer stop after IRAT


    ${log_content}=    operatingSystem.Get File    ${OUTPUTDIR}${/}feat_act.log/feat_act.log
    ${matches}=        Get Regexp Matches    ${log_content}    Timer FiveQI1RrcRelDelayTimer deleted.
    Should Not Be Empty      ${matches}

