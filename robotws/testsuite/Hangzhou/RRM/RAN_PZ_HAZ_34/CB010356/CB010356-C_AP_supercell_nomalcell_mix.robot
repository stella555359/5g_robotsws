*** Settings ***
Documentation
...    author: Xiang Kang
...    contact: kang.xiang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2normalcells_1supercell
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R1    tl-CLOUD_5G_I_MP_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    True

@{PARAMS_IN_SWCONFIG}
...    ${sent_measurement_report}
...    ${set_10356_enable_param1}
...    ${set_10356_enable_param2}

${set_10356_enable_param1}    0x59029B = 1
${set_10356_enable_param2}    0x890092 = 1
${sent_measurement_report}    0x59025d=2

${SNAPSHOT_FLAG}    pass:False,fail:False
${SOS_REPORT_FLAG}    pass:False,fail:False
${EMIL_FLAG}    False
@{FAULTS_EXCLUDED_CHECKING}    7107

*** Test Cases ***
CB010356-C-B1_ET_01_06_AMF Reselection When The First AMF Becomes Unreachable for Super Cell and Normal cell
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    interaction with ransharing AMF-1 supports PLMN-1 and PLMN-2, AMF-2 supports PLMN-2 and PLMN-3,
    ...    AMF-3 supports PLMN-1 and PLMN-4
    [Tags]    c1    owner-kang.xiang
    Enable Nrppa Trace Message
    log to console    LMF-1 trigger MEASUREMENT REQUEST to supercell cell-1 and MR report to AMF-1
    Set TRP Measurement Request List    object_id=1    trp_id=6
    Set TRP Measurement Request List    object_id=2    trp_id=7
    Set TRP Measurement Quantities Item List    object_id=1    trp_measurement_type=UL-SRS-RSRP    timing_reporting_granularity_factor=2
    Set TRP Measurement Quantities Item List    object_id=2    trp_measurement_type=UL-RTOA    timing_reporting_granularity_factor=3
    Set SRS Related Configuration

    Start to capture wireshark log    tag=1_supercell_cell1_MR_AMF_1
    Trigger Measurement Request For Periodic timer    lmf_id=1    amf_id=1    lmf_measurement_id=100
    ...    measurement_periodicity=5120ms    trp_meas_req_item_obj_id_list=1,2    trp_meas_qty_item_obj_id=1,2

    ${NRPPA_MR1_FILTER_AMF_1}    Catenate    (ip.dst == 10.0.1.1) && (nrppa.Measurement_ID == 100)
    ${wireshark_log_path_1}    ${ran_measurement_id_1}    Get Ran Measurement Id For Measurement Report
    ...                                                 tag=1_supercell_cell1_MR_AMF_1
    ...                                                 filter=${NRPPA_MR1_FILTER_AMF_1}
    ${mr1_info}    create list    Measurement-ID=100,${ran_measurement_id_1}
    check_wireshark_fields    pcap_file=${wireshark_log_path_1}
    ...                       filter=((nrppa.Measurement_ID == 100) && (ip.dst == 10.0.1.1)) && (nrppa.Measurement_ID == ${ran_measurement_id_1})
    ...                       check_fields=${mr1_info}

    log to console    Break amf-1 link then MR report to AMF-2
    Break AMF_1 Link
    Start to capture wireshark log    tag=2_supercell_cell1_MR_AMF_2
    Sleep    30s    wait for MR report to AMF_2
    ${NRPPA_MR1_FILTER_AMF_2}    Catenate
    ...    ((nrppa.Measurement_ID == 100) && (ip.dst == 10.0.1.102)) && (nrppa.Measurement_ID == ${ran_measurement_id_1})
    Download and check wireshark fields    tag=2_supercell_cell1_MR_AMF_2
    ...                                    filter=${NRPPA_MR1_FILTER_AMF_2}
    ...                                    check_fields=${mr1_info}

    log to console    LMF-2 trigger MEASUREMENT REQUEST to normal cell cell-2 and MR report to AMF-2
    Set TRP Measurement Request List    object_id=1    trp_id=2
    Start to capture wireshark log    tag=3_normalcell_cell2_MR_AMF_2
    Trigger Measurement Request For Periodic timer    lmf_id=2    amf_id=2    lmf_measurement_id=200
    ...    measurement_periodicity=5120ms    trp_meas_req_item_obj_id_list=1    trp_meas_qty_item_obj_id=1
    ${NRPPA_MR2_FILTER_AMF_2}    Catenate    (nrppa.Measurement_ID == 200) && (ip.dst == 10.0.1.102)
    ${wireshark_log_path_3}    ${ran_measurement_id_2}    Get Ran Measurement Id For Measurement Report
    ...                                                   tag=3_normalcell_cell2_MR_AMF_2
    ...                                                   filter=${NRPPA_MR2_FILTER_AMF_2}
    ${mr2_info}    create list    Measurement-ID=200,${ran_measurement_id_2}
    check_wireshark_fields    pcap_file=${wireshark_log_path_3}
    ...                       filter=((nrppa.Measurement_ID == 200) && (ip.dst == 10.0.1.102)) && (nrppa.Measurement_ID == ${ran_measurement_id_2})
    ...                       check_fields=${mr2_info}

    log to console    Break amf-2 link then MR drop for cell2 and report for cell1 to AMF-3
    Break AMF_2 Link
    Start to capture wireshark log    tag=4_supercell_cell1_MR_AMF_3
    Sleep    30s    wait for MR report to AMF_3
    ${NRPPA_MR2_FILTER_AMF_3}    Catenate    (ip.dst == 10.0.1.103) && (nrppa.Measurement_ID == 100)
    ${wireshark_log_path_4}    Download and check wireshark fields    tag=4_supercell_cell1_MR_AMF_3
    ...                                                               filter=${NRPPA_MR2_FILTER_AMF_3}
    ...                                                               check_fields=${mr1_info}
    ${Count}    Get Wireshark Message Count    ${wireshark_log_path_4}    ((ip.dst == 10.0.1.103) && (nrppa.Measurement_ID == 200))
    Should Be True    ${Count}==0

    log to console    resume AMF_1 link then report for cell1 to AMF-1
    Resume AMF_1 Link
    Start to capture wireshark log    tag=5_supercell_cell1_MR_AMF_1
    Sleep    30s    wait for MR report to AMF_3
    ${wireshark_log_path_5}    Download and check wireshark fields    tag=5_supercell_cell1_MR_AMF_1
    ...                                                               filter=${NRPPA_MR1_FILTER_AMF_1}
    ...                                                               check_fields=${mr1_info}
    ${Count}    Get Wireshark Message Count    ${wireshark_log_path_5}    ((ip.dst == 10.0.1.103) && (nrppa.Measurement_ID == 100))
    Should Be True    ${Count}==0
    [Teardown]    Teardown with Lock Unlock All AMF Link

CB010356-C-B3_ET_01_03_Error Indication in Measurement Update
   [Tags]    c2    owner-lishuo.geng
    Enable Nrppa Trace Message
    log to console    LMF-1 trigger MEASUREMENT REQUEST to supercell cell-1 and MR report to AMF-1
    Set TRP Measurement Request List    object_id=2    trp_id=7
    Set TRP Measurement Quantities Item List    object_id=1    trp_measurement_type=UL-SRS-RSRP    timing_reporting_granularity_factor=2
    Set SRS Related Configuration

    Start to capture wireshark log    tag=1_supercell_cell1_MR_AMF_1
    Trigger Measurement Request For Periodic timer    lmf_id=1    amf_id=1    lmf_measurement_id=100
    ...    measurement_periodicity=5120ms    trp_meas_req_item_obj_id_list=2    trp_meas_qty_item_obj_id=1

    ${NRPPA_MR1_FILTER_AMF_1}    Catenate    (ip.dst == 10.0.1.1) && (nrppa.Measurement_ID == 100)
    ${wireshark_log_path_1}    ${ran_measurement_id_1}    Get Ran Measurement Id For Measurement Report
    ...                                                 tag=1_supercell_cell1_MR_AMF_1
    ...                                                 filter=${NRPPA_MR1_FILTER_AMF_1}
    ${mr1_info}    create list    Measurement-ID=100,${ran_measurement_id_1}
    check_wireshark_fields    pcap_file=${wireshark_log_path_1}
    ...                       filter=((nrppa.Measurement_ID == 100) && (ip.dst == 10.0.1.1)) && (nrppa.Measurement_ID == ${ran_measurement_id_1})
    ...                       check_fields=${mr1_info}

    log to console    LMF-1 trigger MEASUREMENT UPDATE with no lmf measurement id,ERROR INDICATION responsed
    Trigger Measurement Update With Mandatory IE Missing    ran_measurement_id=${ran_measurement_id_1}
    log to console    LMF-1 trigger MEASUREMENT UPDATE with no ran measurement id,ERROR INDICATION responsed
    Trigger Measurement Update With Mandatory IE Missing    missing_mandatory_ie_name=ran_measurement_id
    log to console    LMF-1 trigger MEASUREMENT UPDATE with different srs config
    Set SRS Resource Config
    Trigger Measurement Update Successfully    ran_measurement_id=${ran_measurement_id_1}
    log to console    LMF-1 trigger MEASUREMENT ABORT
    Trigger Measurement Abort    ran_measurement_id=${ran_measurement_id_1}

CB010356-C-B4_ET_01_01_Measurement session stop triggered from LMF
   [Tags]    c3    owner-lishuo.geng
    Enable Nrppa Trace Message
    log to console    LMF-1 trigger MEASUREMENT REQUEST to normal cell-2 and normal cell-4
    Set TRP Measurement Request List    object_id=1    trp_id=2
    Set TRP Measurement Request List    object_id=2    trp_id=4
    Set TRP Measurement Quantities Item List    object_id=2    trp_measurement_type=UL-RTOA    timing_reporting_granularity_factor=3
    Set SRS Related Configuration

    Start to capture wireshark log    tag=1_supercell_cell1_MR_AMF_1
    Trigger Measurement Request For Extend Periodic timer    lmf_id=1    lmf_measurement_id=100
    ...    measurement_periodicity=2560ms    trp_meas_req_item_obj_id_list=1,2    trp_meas_qty_item_obj_id=2

    ${NRPPA_MR1_FILTER_AMF_1}    Catenate    (ip.dst == 10.0.1.1) && (nrppa.Measurement_ID == 100)
    ${wireshark_log_path_1}    ${ran_measurement_id_1}    Get Ran Measurement Id For Measurement Report
    ...                                                 tag=1_supercell_cell1_MR_AMF_1
    ...                                                 filter=${NRPPA_MR1_FILTER_AMF_1}
    ${mr1_info}    create list    Measurement-ID=100,${ran_measurement_id_1}
    check_wireshark_fields    pcap_file=${wireshark_log_path_1}
    ...                       filter=((nrppa.Measurement_ID == 100) && (ip.dst == 10.0.1.1)) && (nrppa.Measurement_ID == ${ran_measurement_id_1})
    ...                       check_fields=${mr1_info}
    log to console    LMF-1 trigger MEASUREMENT ABORT with different RAN measurement id
    Trigger Measurement Abort    ran_measurement_id=1111
    log to console    LMF-1 trigger MEASUREMENT ABORT with different LMF measurement id
    Trigger Measurement Abort    lmf_measurement_id=1111
    log to console    LMF-1 trigger MEASUREMENT ABORT with ran measurement id missing
    Trigger Measurement Abort With Mandatory IE Missing    missing_mandatory_ie_name=ran_measurement_id
    log to console    LMF-1 trigger MEASUREMENT ABORT with lmf measurement id missing
    Trigger Measurement Abort With Mandatory IE Missing    ran_measurement_id=${ran_measurement_id_1}
    log to console    check MEASUREMENT is ongoing
    Start to capture wireshark log    tag=2_supercell_cell1_MR_AMF_1
    Sleep    10s    wait for MR report to AMF_1
    log to console    LMF-1 trigger MEASUREMENT ABORT
    Trigger Measurement Abort    ran_measurement_id=${ran_measurement_id_1}
    log to console    check MEASUREMENT is aborted
    Start to capture wireshark log    tag=3_supercell_cell1_MR_AMF_1
    Execute Egate Command    set_log_flash    fail_regexp=LMF Received Measurement Report

CB010356-C-B2_ET_01_04_All requested TRPs do not work in gNB
    [Tags]    c4    owner-yin.zhang
    Set TRP Measurement Request List    object_id=1    trp_id=6
    Set TRP Measurement Quantities Item List    object_id=1
    ...                                         trp_measurement_type=UL-SRS-RSRP
    ...                                         timing_reporting_granularity_factor=3
    Set TRP Measurement Quantities Item List    object_id=2
    ...                                         trp_measurement_type=UL-RTOA
    ...                                         timing_reporting_granularity_factor=0
    Set SRS Related Configuration

    log to console    step1: lock suppercell cell1, LMF trigger NRPPa:MEASUREMENT REQUEST to its subcell and failed
    Start to capture wireshark log    tag=1_lock_cell1_mr_cell1
    lock nrcell1
    Trigger Measurement Request For Periodic timer    lmf_id=1    amf_id=1
    ...                                               measurement_periodicity=10240ms
    ...                                               trp_meas_req_item_obj_id_list=1
    ...                                               trp_meas_qty_item_obj_id=1,2
    ...                                               pass_regexp=LMF Received Measurement Failure
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=1_lock_cell1_mr_cell1
    ...                                                               filter=nrppa.radioNetwork == 2
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=f1ap.radioNetwork == 11
    ...                       check_fields=PositioningMeasurementFailure/radioNetwork=[RE]cell-not-available .*
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=nrppa.radioNetwork == 2
    ...                       check_fields=MeasurementFailure/radioNetwork=[RE]requested-item-temporarily-not-available .*

    log to console    step2: LMF trigger NRPPa:MEASUREMENT REQUEST to cell1 and cell2, only gets measurement report from cell2 periodically
    Start to capture wireshark log    tag=2_mr_cell1_cell2
    Set TRP Measurement Request List    object_id=2    trp_id=2
    Trigger Measurement Request For Periodic timer    lmf_id=1    amf_id=1
    ...                                               measurement_periodicity=10240ms
    ...                                               trp_meas_req_item_obj_id_list=1,2
    ...                                               trp_meas_qty_item_obj_id=1,2
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=2_mr_cell1_cell2
    ...                                                               filter=nrppa.procedureCode == 12
    ...                                                               times=4
    ${cell2_mreport}    Create List    PositioningMeasurementReport/measuredResultsValue=[RE]uL-SRS-RSRP .*,[RE]uL-RTOA .*
    ...                                PositioningMeasurementReport/tRPID=2
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=f1ap.procedureCode == 44
    ...                       check_fields=${cell2_mreport}
    ...                       packet_num=0
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=f1ap.procedureCode == 44
    ...                       check_fields=${cell2_mreport}
    ...                       packet_num=3

    log to console    step3: lock cell2, lmf receives measurement failure from gnb
    Start to capture wireshark log    tag=3_lock_cell2
    lock nrcell2
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=3_lock_cell2
    ...                                                               filter=nrppa.radioNetwork == 2
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=f1ap.radioNetwork == 11
    ...                       check_fields=PositioningMeasurementFailureIndication/radioNetwork=[RE]cell-not-available .*
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=nrppa.radioNetwork == 2
    ...                       check_fields=MeasurementFailureIndication/radioNetwork=[RE]requested-item-temporarily-not-available .*
    [Teardown]    Teardown with Unlock NRCells And Lock Unlock AMF

*** Keywords ***
Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    set_lmf id=2 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef12345678gh
    Update Cfg    set_amf_region id=1 tac_list=0,100,200 plmn=311:489,311:402
    Update Cfg    set_amf_region id=2 tac_list=0,100,200 plmn=311:402,311:403
    Update Cfg    set_amf_region id=3 tac_list=0,100,200 plmn=311:489,311:404
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=3 pointer=1
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=4
    Update Cfg    set_qosflow id=5 5qi=6
    Update Cfg    set_qosflow id=6 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1-3
    Update Cfg    sim_trace lmf=1 protocol=nrppa on

Enable Nrppa Trace Message
    Execute Egate Command    sim_trace lmf=1 protocol=nrppa on
    Execute Egate Command    sim_trace lmf=2 protocol=nrppa on

Set TRP Measurement Request List
    #lmf_set_trp_meas_req_item object_id=1 trp_id=1
    [Arguments]    ${object_id}=1    ${trp_id}=6
    Execute Egate Command    lmf_set_trp_meas_req_item object_id=${object_id} trp_id=${trp_id}

Set TRP Measurement Quantities Item List
    #trp_measurement_type support Multiple_UL-AoA,UL-AoA,UL-RTOA,UL-SRS-RSRP,UL_SRS-RSRPP,gNB-RxTxTimeDiff,but
    #only UL-RTOA and UL-SRS-RSRP supported in CB010332
    #lmf_set_trp_meas_qty_item object_id=1 trp_measurement_type=UL-RTOA timing_reporting_granularity_factor=3
    [Arguments]    ${object_id}=1    ${trp_measurement_type}=UL-RTOA    ${timing_reporting_granularity_factor}=3
    ${cmd}    Catenate    lmf_set_trp_meas_qty_item object_id=${object_id} trp_measurement_type=${trp_measurement_type}
    ...    timing_reporting_granularity_factor=${timing_reporting_granularity_factor}
    Execute Egate Command    ${cmd}

Set SRS Resource Config
    #lmf_set_srs_resource_config object_id=1 srs_resource_id=63 resource_type=Periodic periodicity_periodic=slot1280
    #offset_periodic=2559 b-hop=3 b-srs=3 c-srs=63 transmission_comb=comb_two comb_offset_2=1 cyclic_shift_2=7
    #frequency_domain_position=67 frequency_domain_shift=268 group_or_sequence_hopping=neither repetition_factor=r4
    #sequence_id=1023 start_position=13 number_of_ports=ports4 number_of_symbols=n4
    ${cmd}    Catenate    lmf_set_srs_resource_config object_id=1 srs_resource_id=63 resource_type=Periodic
    ...    periodicity_periodic=slot1280 offset_periodic=2559 b-hop=3 b-srs=3 c-srs=63 transmission_comb=comb_two
    ...    comb_offset_2=1 cyclic_shift_2=7 frequency_domain_position=67 frequency_domain_shift=268
    ...    group_or_sequence_hopping=neither repetition_factor=r4 sequence_id=1023 start_position=13
    ...    number_of_ports=ports4 number_of_symbols=n4
    Execute Egate Command    ${cmd}

Set SRS Resource Set Config
    #lmf_set_srs_resource_set_config object_id=1 resource_set_type=Periodic periodicset=true srs_resource_id=16 srs_resource_set_id=15
    [Arguments]    ${object_id}=1
    ${cmd}    Catenate    lmf_set_srs_resource_set_config object_id=${object_id} resource_set_type=Periodic periodicset=true
    ...    srs_resource_id=16 srs_resource_set_id=15
    Execute Egate Command    ${cmd}

Set SRS Carrier Config
    #lmf_set_srs_carrier_config object_id=1 pointA=3279165 offset_to_carrier=2199 offset_to_carrier_subcarrier_spacing=kHz30
    #carrier_bandwidth=273 location_and_bandwidth=0 location_and_bandwidth_subcarrier_spacing=kHz30 cyclic_prefix=Normal
    #tx_direct_current_location=3301 srs_resource_config_obj_id_list=1 srs_resource_set_config_obj_id_list=1 nr_pci=0
    [Arguments]    ${object_id}=1    ${pointA}=3279165    ${carrier}=2199    ${SCS}=kHz30    ${carrier_bandwidth}=273
    ...    ${location_and_bandwidth}=0    ${cyclic_prefix}=Normal    ${tx_direct_current_location}=3301
    ...    ${srs_resource_config_obj_id_list}=1    ${srs_resource_set_config_obj_id_list}=1    ${nr_pci}=0
    ${cmd}    Catenate    lmf_set_srs_carrier_config object_id=${object_id} pointA=${pointA} offset_to_carrier=${carrier}
    ...    offset_to_carrier_subcarrier_spacing=${SCS} carrier_bandwidth=${carrier_bandwidth}
    ...    location_and_bandwidth=${location_and_bandwidth} location_and_bandwidth_subcarrier_spacing=${SCS}
    ...    cyclic_prefix=${cyclic_prefix} tx_direct_current_location=${tx_direct_current_location}
    ...    srs_resource_config_obj_id_list=${srs_resource_config_obj_id_list}
    ...    srs_resource_set_config_obj_id_list=${srs_resource_set_config_obj_id_list} nr_pci=${nr_pci}
    Execute Egate Command    ${cmd}

Set SRS Configuration For Measurement
    #lmf_set_srs_configuration object_id=1 srs_carrier_obj_id_list=1
    [Arguments]    ${object_id}=1    ${srs_carrier_obj_id_list}=1
    Execute Egate Command    lmf_set_srs_configuration object_id=${object_id} srs_carrier_obj_id_list=${srs_carrier_obj_id_list}

Set SRS Related Configuration
    Set SRS Resource Config
    Set SRS Resource Set Config
    Set SRS Carrier Config
    Set SRS Configuration For Measurement

Trigger Measurement Request For Periodic timer
    [Documentation]    only 640ms,5120ms,10240ms,20480ms, 40960ms supported
    ...    120ms,240ms,480ms,1024ms,2048ms,1min,6min,12min,30min,and 60min are not applicable
    ...    otherwise return with LMF Received Measurement Failure
    #lmf_send_meas_req id=1 amf_id=1 gnb_id=2 nrppa_transaction_id=3 lmf_measurement_id=55536 trp_meas_req_item_obj_id_list=1
    #report_characteristics=Periodic trp_meas_qty_item_obj_id_list=1 measurement_periodicity=10240ms srs_config_obj_id=1
    [Arguments]    ${lmf_id}=1    ${amf_id}=1    ${nrppa_transaction_id}=1    ${lmf_measurement_id}=100    ${trp_meas_req_item_obj_id_list}=1
    ...    ${report_characteristics}=Periodic    ${trp_meas_qty_item_obj_id}=1    ${pass_regexp}=LMF Received Measurement Report
    ...    ${measurement_periodicity}=240ms    ${srs_config_obj_id}=1
    ${cmd}    Catenate    lmf_send_meas_req id=${lmf_id} amf_id=${amf_id} gnb_id=2 nrppa_transaction_id=${nrppa_transaction_id}
    ...    lmf_measurement_id=${lmf_measurement_id} trp_meas_req_item_obj_id_list=${trp_meas_req_item_obj_id_list}
    ...    report_characteristics=${report_characteristics} trp_meas_qty_item_obj_id_list=${trp_meas_qty_item_obj_id}
    ...    measurement_periodicity=${measurement_periodicity} srs_config_obj_id=${srs_config_obj_id}
    ${output}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    [Return]    ${output}

Trigger Measurement Abort
    #lmf_send_meas_abort id=1 gnb_id=2 amf_id=1 nrppa_transaction_id=1 lmf_measurement_id=1 ran_measurement_id=6
    [Arguments]    ${lmf_id}=1    ${nrppa_transaction_id}=1    ${lmf_measurement_id}=100    ${ran_measurement_id}=1
    ${cmd}    Catenate    lmf_send_meas_abort id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${nrppa_transaction_id}
    ...    ran_measurement_id=${ran_measurement_id} lmf_measurement_id=${lmf_measurement_id}
    Execute Egate Command    ${cmd}    pass_regexp=Measurement Abort sent

Get Ran Measurement Id For Measurement Report
    [Arguments]    ${tag}    ${filter}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}    times=3
    ${measurement_id_list}    Get wireshark field value    ${wireshark_log_path}
    ...                                                    MeasurementResponse/Measurement-ID
    ...                                                    ${filter}
    ${ran_measurement_id}    Set Variable    ${measurement_id_list[-1]}
    [Return]    ${wireshark_log_path}    ${ran_measurement_id}

Break AMF_1 Link
    Delta Commission Parameters And Wait Cells Onair    SERVEDAMF-1:administrativeState=Locked

Break AMF_2 Link
    Delta Commission Parameters And Wait Cells Onair    SERVEDAMF-2:administrativeState=Locked

Resume AMF_1 Link
    Delta Commission Parameters And Wait Cells Onair    SERVEDAMF-1:administrativeState=Unlocked

Download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}    times=3
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    [Return]    ${wireshark_log_path}

Teardown with Lock Unlock All AMF Link
    Delta Commission Parameters    ${Lock_ALL_AMF}
    Delta Commission Parameters    ${Unlock_ALL_AMF}
    Common Test Teardown And Stop Capture Logs


Teardown with Unlock NRCells And Lock Unlock AMF
    # lock/unlock AMF1 is to abort measurement report if step2 failed
    delta commission parameters    ${Lock_AMF1_Unlock_NRCells}
    delta commission parameters and wait cells onair    ${Unlock_ALL_AMF}
    Common Test Teardown And Stop Capture Logs

Trigger Measurement Update Successfully
    #lmf_send_meas_update id=1 gnb_id=2 amf_id=1 ran_measurement_id=1 nrppa_transaction_id=1 srs_config_obj_id=1 lmf_measurement_id=1
    [Arguments]    ${lmf_id}=1    ${nrppa_transaction_id}=1    ${lmf_measurement_id}=100    ${srs_config_obj_id}=1
    ...    ${ran_measurement_id}=1    ${pass_regexp}=Measurement Update sent
    ${cmd}    Catenate    lmf_send_meas_update id=${lmf_id} gnb_id=2 amf_id=1 nrppa_transaction_id=${nrppa_transaction_id}
    ...    ran_measurement_id=${ran_measurement_id} lmf_measurement_id=${lmf_measurement_id} srs_config_obj_id=${srs_config_obj_id}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Trigger Measurement Update With No SRS
    #lmf_send_meas_update id=1 gnb_id=2 amf_id=1 ran_measurement_id=1 nrppa_transaction_id=1 lmf_measurement_id=1
    [Arguments]    ${lmf_id}=1    ${nrppa_transaction_id}=1    ${lmf_measurement_id}=100
    ...    ${ran_measurement_id}=1    ${pass_regexp}=Measurement Update sent
    ${cmd}    Catenate    lmf_send_meas_update id=${lmf_id} gnb_id=2 amf_id=1 nrppa_transaction_id=${nrppa_transaction_id}
    ...    ran_measurement_id=${ran_measurement_id} lmf_measurement_id=${lmf_measurement_id}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Trigger Measurement Update With Mandatory IE Missing
    #lmf_send_meas_update id=1 gnb_id=2 amf_id=1 ran_measurement_id=1 nrppa_transaction_id=1 srs_config_obj_id=1
    #lmf_measurement_id=1 action=missing_mandatory_ie_name missing_mandatory_ie_name=lmf_measurement_id
    [Arguments]    ${lmf_id}=1    ${nrppa_transaction_id}=1    ${lmf_measurement_id}=100    ${srs_config_obj_id}=1
    ...    ${ran_measurement_id}=1    ${missing_mandatory_ie_name}=lmf_measurement_id    ${pass_regexp}=abstract-syntax-error-reject
    ${cmd}    Catenate    lmf_send_meas_update id=${lmf_id} gnb_id=2 amf_id=1 nrppa_transaction_id=${nrppa_transaction_id}
    ...    ran_measurement_id=${ran_measurement_id} lmf_measurement_id=${lmf_measurement_id} srs_config_obj_id=${srs_config_obj_id}
    ...    action=missing_mandatory_ie missing_mandatory_ie_name=${missing_mandatory_ie_name}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Trigger Measurement Request For Extend Periodic timer
    #lmf_send_meas_req id=1 amf_id=1 gnb_id=2 nrppa_transaction_id=3 lmf_measurement_id=55536 trp_meas_req_item_obj_id_list=1
    #report_characteristics=Periodic trp_meas_qty_item_obj_id_list=1 measurement_periodicity=extended measurement_periodicity_extended=160ms
    #srs_config_obj_id=1
    [Arguments]    ${lmf_id}=1    ${nrppa_transaction_id}=1    ${lmf_measurement_id}=100
    ...    ${report_characteristics}=Periodic    ${trp_meas_qty_item_obj_id}=1    ${pass_regexp}=LMF Received Measurement Report
    ...    ${measurement_periodicity}=2560ms    ${srs_config_obj_id}=1    ${trp_meas_req_item_obj_id_list}=1
    ${cmd}    Catenate    lmf_send_meas_req id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${nrppa_transaction_id}
    ...    lmf_measurement_id=${lmf_measurement_id} trp_meas_req_item_obj_id_list=${trp_meas_req_item_obj_id_list}
    ...    report_characteristics=${report_characteristics} trp_meas_qty_item_obj_id_list=${trp_meas_qty_item_obj_id}
    ...    measurement_periodicity=extended measurement_periodicity_extended=${measurement_periodicity}
    ...    srs_config_obj_id=${srs_config_obj_id}
    ${output}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    [Return]    ${output}

Trigger Measurement Abort With Mandatory IE Missing
    #lmf_send_meas_abort id=1 gnb_id=2 amf_id=1 nrppa_transaction_id=1 lmf_measurement_id=100 ran_measurement_id=1
    #action=missing_mandatory_ie missing_mandatory_ie_name=ran_measurement_id
    [Arguments]    ${lmf_id}=1    ${nrppa_transaction_id}=1    ${lmf_measurement_id}=100    ${ran_measurement_id}=1
    ...    ${missing_mandatory_ie_name}=lmf_measurement_id
    ${cmd}    Catenate    lmf_send_meas_abort id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${nrppa_transaction_id}
    ...    ran_measurement_id=${ran_measurement_id} lmf_measurement_id=${lmf_measurement_id} action=missing_mandatory_ie
    ...    missing_mandatory_ie_name=${missing_mandatory_ie_name}
    Execute Egate Command    ${cmd}    pass_regexp=abstract-syntax-error-reject
