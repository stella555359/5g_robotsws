*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008806-A_Keywords

Resource    CB008806-A_Commissioning.robot
Resource    ../../resources/SQD65/sqd65_keywords.robot
Resource    ../5GC000705-A_Commissioning.robot
Resource    ../5GC000705-A_Keywords.robot
Resource    ../CB008806-B/CB008806-B_Keywords.robot

Library     taf.config.wts       WITH NAME    wts_conf
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.analyzer.pdml    WITH NAME    pdml_analyzer
Library     taf.ul.hanging_resources   WITH NAME   resources


*** Variables ***

${TEST_MODE}                auto
${WTS_CFG_FILE_CB008806-A_EC10}      basic_setup_CB008806-A_EC10.cfg
${WTS_CFG_FILE_CB008806-A_B3}      basic_setup_CB008806-A_B3.cfg
${WTS_CFG_FILE_CB008806-A_EC5}      basic_setup_CB008806-A_EC5.cfg
${WTS_CFG_FILE_CB008806-A_delta_EC1_robust_mulUEs}     basic_setup_CB008806-A_delta_EC1_robust_mulUEs.cfg
${WTS_CFG_FILE_CB008806-A_B61}      basic_setup_CB008806-A_B61.cfg
${WTS_CFG_FILE_CB008806-A_B7}      basic_setup_CB008806-A_B7.cfg

${EGATE_CONSOLE_LOG}        /opt/iphy/latest/egate_console.log

${UE_CAPA_TDD}  SEPARATOR=
...                         ue_nr_capabilities=69A00000446084C00E83626D52B04610D04083E52F55555553D5555554220003800200713
...                         400000000989A007FFFC00026006C005038280301884C00C000F01E0A00C03C00000000000008A80000000000000A8000008010020445

${UE_CAPA_B7_TDD}           SEPARATOR=
...                         ue_nr_capabilities=21000000010900000004D0100000000900A00883C00000000000008A80000000000000A8

${UE_CAPA_EC1_TDD}       SEPARATOR=
...                         ue_nr_capabilities=21A00000010900000004D0100389A00000340280221C0C0300F000000000000022A00000000000002A0000020040081114

@{PDML_FIELDS}              ngap.HandoverRequired_element
...                         ngap.HandoverCommand_element
...                         ngap.DownlinkNASTransport_element
...                         ngap.radioNetwork
...                         ngap.NASNonDeliveryIndication_element
...                         ngap.PDUSessionResourceSetupRequest_element
...                         ngap.PDUSessionResourceReleaseCommand_element
...                         ngap.PDUSessionResourceModifyRequest_element
...                         ngap.ErrorIndication_element
...                         nr-rrc.rrcSetup_element
...                         nr-rrc.rrcSetupComplete_element
...                         ngap.InitialUEMessage_element
...                         ngap.UEContextReleaseRequest_element
...                         ngap.UEContextReleaseCommand_element
...                         ngap.UEContextReleaseComplete_element

${B4_1_MSG_SEQ}             SEPARATOR=
...                         HandoverRequired.*
...                         PDUSessionResourceSetupRequest.*
...                         ng-intra-system-handover-triggered.*
...                         HandoverCommand.*
...                         successful-handover.*

${B4_2_MSG_SEQ}             SEPARATOR=
...                         HandoverRequired.*
...                         PDUSessionResourceReleaseCommand.*
...                         ng-intra-system-handover-triggered.*
...                         ErrorIndication.*
...                         HandoverCommand.*
...                         successful-handover.*

${B4_3_MSG_SEQ}             SEPARATOR=
...                         HandoverRequired.*
...                         PDUSessionResourceModifyRequest.*
...                         ng-intra-system-handover-triggered.*
...                         HandoverCommand.*
...                         successful-handover.*

${B4_4_MSG_SEQ}             SEPARATOR=
...                         HandoverRequired.*
...                         HandoverCommand.*
...                         PDUSessionResourceSetupRequest.*
...                         ng-intra-system-handover-triggered.*
...                         successful-handover.*

${B5_1_MSG_SEQ}             SEPARATOR=
...                         HandoverRequired.*
...                         (DownlinkNASTransport.*|HandoverCommand.*)    # Sent in Parallel
...                         (DownlinkNASTransport.*|HandoverCommand.*)
...                         successful-handover.*

${B5_2_MSG_SEQ}             SEPARATOR=
...                         HandoverRequired.*
...                         (DownlinkNASTransport.*|HandoverCommand.*)
...                         (DownlinkNASTransport.*|HandoverCommand.*)
...                         NASNonDeliveryIndication.*
...                         successful-handover.*

${B8_MSG_SEQ}               SEPARATOR=
...                         HandoverRequired.*
...                         HandoverCommand.*
...                         rrcSetup.*
...                         rrcSetupComplete.*
...                         InitialUEMessage.*
...                         UEContextReleaseRequest.*
...                         UEContextReleaseCommand.*
...                         UEContextReleaseComplete.*

${Simulated_gNB_ID}         3
${NGIP_simulated_gNB}       10.0.1.3
${XNIP_simulated_gNB}       10.0.1.4
${PROXY1_simulated_gNB}     10.0.2.90
${PROXY2_simulated_gNB}     10.0.2.91
${AMF2_NG_ADDR}             10.0.1.10

@{IP_LIST_eth3_add}        ${XNIP_simulated_gNB}  ${NGIP_simulated_gNB}  ${AMF2_NG_ADDR}

@{IP_LIST_eth4_add}        ${PROXY1_simulated_gNB}  ${PROXY2_simulated_gNB}

@{pdu1_qos_list_B3_EC10}  ${2}  ${3}  ${4}  ${5}
@{pdu2_qos_list_B3_EC10}  ${2}
@{pdu1_qos_list_EC5}  ${4}  ${5}  ${6}  ${7}
@{pdu1_qos_list_EC1_robust}  ${2}

@{EC1_1_PM_COUNTER}         M55125C07507  # NG_HO_PREP_FAIL_RRL_SRC
*** Keywords ***

Prepare TL for CB008806-A
    [Documentation]   Prepare UTE TL for CB008806-A test
    Set Suite Variable  ${suite_setup_status}  Start
    Sqd65 Common Setup
    5GC000705-A_Keywords.Get SW Branch
    ${cellTechnology}=        wts_ue.Get cellTechnology Info
    ${cellTechnology}=  Set Variable If  "${cellTechnology}" == "TDD+FDD"  TDD  ${cellTechnology}
    Set Suite Variable        ${cellTechnology}
    Change RD Parameters in swconfig File to Disable PCMD Records Bundling
    CB008806-A_Commissioning.Commissioning for NG HO
    Prepare CB008806-A_B3 WTS Config
    ute_tshark.Setup Tshark    interface=eth3    preferences=ntrstr.defragment:TRUE ntrstr.port:49151    alias=tshark
    Set Suite Variable  ${suite_setup_status}  Finished

Perform Postconditions of Test Case
    run_keyword_and_warn_on_failure    Stop logging
    IF    '${TEST_MODE}'=='auto'   Collect AP Sos Report and Snapshots
    Run Keyword and Ignore Error    Stop collecting PCMD reports
    Run Keyword and Ignore Error    Deconfigure PCMD
    Revert Present Delta Commissioning

Revert Present Delta Commissioning
    ${log_dir}=               Get Testcase Log Directory
    ${scf}=                   Get SCF from gNB  target_dir=${log_dir}
    ${ts_conf_dir}=           Get Test Suite Config Directory
    ${revert_file}=           Set Variable  ${log_dir}/revert.json
    scf.calculate_delta_scf   ${ts_conf_dir}/${CB008806-A_SCF}  ${scf}  ${revert_file}
    Config gNB with delta scf                ${revert_file}

Prepare CB008806-A_B3 WTS Config
    ${WTS_CFG_FILE_CB008806-A_B3}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_B3}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.insert              set GNB3_NG_ADDR="${NGIP_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert              set PROXY_SERVER1_IP="${PROXY1_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert              set PROXY_SERVER2_IP="${PROXY2_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert              set AMF2_NG_ADDR="${AMF2_NG_ADDR}"   after    set DAEMON_PORT="22222"

    wts_conf.modify              set_amf id=1  name=simAMF1 pointer=1,2
    wts_conf.insert              upf_param id=1 end_markers_delay=1000   after    set_upf id=1
    wts_conf.insert              amf_timer T_Local=4000 T_NotifyProcessing=2500  after  upf_param id=1
    wts_conf.modify              set_cell id=1 gnb=2  gscn=7880
    wts_conf.modify              set_cell id=2 gnb=2  gscn=7880

    wts_conf.insert
    ...  set_gnb id=${Simulated_gnb_ID} type=simulated plmn=311:489 ng=$GNB3_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT
    ...  after  set_cell id=2 gnb=2
    wts_conf.modify
    ...  set_gnb id=${Simulated_gnb_ID}  gnb_id=0x3:22 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts_conf.insert              set_cell id=1 gnb=${Simulated_gnb_ID} pci=16:0 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=${nrarfcn}:${nrarfcn}
    ...                          after  set_gnb id=${Simulated_gnb_ID}
    wts_conf.modify
    ...  set_cell id=1 gnb=${Simulated_gnb_ID}  gscn=7880 proxy=$PROXY_SERVER1_IP:9999 mandatory_for_activation=off
    wts_conf.insert              set_cell id=2 gnb=${Simulated_gnb_ID} pci=16:1 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=633372:633372
    ...                          after  set_cell id=1 gnb=${Simulated_gnb_ID}
    wts_conf.modify
    ...  set_cell id=2 gnb=${Simulated_gnb_ID}  gscn=7847 proxy=$PROXY_SERVER2_IP:9999 mandatory_for_activation=off
    wts_conf.insert
    ...  gnb_param id=${Simulated_gnb_ID} xn_listening_socket=off ng_forwarding_tunnel_type=pdu
    ...  after  set_gnb id=${Simulated_gnb_ID}

    wts_conf.modify    amf_param id=1 ims_voice_3gpp=on  intra5gs_data_forwarding=on
    wts_conf.modify    ue_param id=1       modification=nr_usage_setting=voice_centric ${UE_CAPA_${cellTechnology}}
    wts_conf.modify    ue_param id=2       modification=nr_usage_setting=voice_centric ${UE_CAPA_${cellTechnology}}
    wts_conf.modify    ue_param id=3       modification=nr_usage_setting=voice_centric ${UE_CAPA_${cellTechnology}}
    wts_conf.modify    ue_param id=4       modification=nr_usage_setting=voice_centric ${UE_CAPA_${cellTechnology}}

    wts_conf.modify    set_qosflow id=1    modification=5qi=5
    wts_conf.modify    set_qosflow id=2    modification=5qi=1
    wts_conf.modify    set_qosflow id=3    modification=5qi=2
    wts_conf.insert    set_qosflow id=4 5qi=6   after  set_qosflow id=3
    wts_conf.insert    set_qosflow id=5 5qi=7   after  set_qosflow id=4
    wts_conf.insert    set_qosflow id=6 5qi=8   after  set_qosflow id=5
    wts_conf.insert    set_qosflow id=7 5qi=9   after  set_qosflow id=6
    wts_conf.delete    set_qosrule id=1
    wts_conf.delete    set_qosrule id=2
    wts_conf.insert    set_qosrule id=1 proto=udp qos_flow=1  after  set_qosflow id=7
    wts_conf.insert    set_qosrule id=2 proto=udp qos_flow=2  after  set_qosrule id=1
    wts_conf.insert    set_qosrule id=3 proto=udp qos_flow=3  after  set_qosrule id=2
    wts_conf.insert    set_qosrule id=4 proto=udp qos_flow=4  after  set_qosrule id=3
    wts_conf.insert    set_qosrule id=5 proto=udp qos_flow=5  after  set_qosrule id=4
    wts_conf.insert    set_qosrule id=6 proto=udp qos_flow=6  after  set_qosrule id=5
    wts_conf.insert    set_qosrule id=7 proto=udp qos_flow=7  after  set_qosrule id=6
    wts_conf.modify    nwslice_set id=1    modification=qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3,4,5,6,7

    wts_conf.modify    debug_log level=4    level=0
    wts_conf.modify    sim_debug_log uec=1  level=0
    wts_conf.modify    sim_trace amf=1      protocol=ng,nas on

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_CB008806-A_B3}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_CB008806-A_B3}  ${ts_conf_dir}

Prepare CB008806-A_EC10 WTS Config
    ${WTS_CFG_FILE_CB008806-A_EC10}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_EC10}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_B3}

    # specific to EC10: intra5gs_data_forwarding=off
    wts_conf.modify    amf_param id=1 ims_voice_3gpp=on  intra5gs_data_forwarding=off

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_CB008806-A_EC10}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_CB008806-A_EC10}  ${ts_conf_dir}

Prepare CB008806-A_B61 WTS Config
    ${WTS_CFG_FILE_CB008806-A_B61}=    Set Variable    ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_B61}
    wts_conf.Load Wts Cfg    ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_B3}
    wts_conf.insert    amf_param id=1 support_guami_unavailability=on   after   set_amf id=1
    wts_conf.insert    set_amf id=2 daemon=$SERVER_IP:$DAEMON_PORT ng=$AMF2_NG_ADDR:38412 name=simAMF2 region=1 set_id=2 pointer=3,4
    ...   after  amf_param id=1 ims_voice_3gpp=on
    wts_conf.insert    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc   after   set_amf id=2
    wts_conf.insert    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on   after   amf_param id=2
    wts_conf.insert    amf_ng_setup_param id=2 relative_capacity=100 include_backup_amf_name=on   after   amf_ng_setup_param id=1
    wts_conf.insert    set_backup_amf main=1 backup_amfs=2   after   amf_ng_setup_param id=2
    wts_conf.modify    nwslice_set id=1    modification=amf=1,2
    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_CB008806-A_B61}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_CB008806-A_B61}  ${ts_conf_dir}

Prepare CB008806-A_EC5 WTS Config
    ${WTS_CFG_FILE_CB008806-A_EC5}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_EC5}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_B3}
    wts_conf.modify
    ...  gnb_param id=${Simulated_gnb_ID}  rlc_config=6:um:size_12,7:um:size_12,8:am:size_12,9:am:size_12

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_CB008806-A_EC5}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_CB008806-A_EC5}  ${ts_conf_dir}

Prepare CB008806-A_B7 WTS Config
    ${WTS_CFG_FILE_CB008806-A_B7}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_B7}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_B3}
    wts_conf.modify
    ...   gnb_param id=${Simulated_gnb_ID}    sib1_period=160ms

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_CB008806-A_B7}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_CB008806-A_B7}  ${ts_conf_dir}

Prepare CB008806-A_delta_EC1_robust_mulUEs WTS Config
    ${WTS_CFG_FILE_CB008806-A_delta_EC1_robust_mulUEs}=   Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE_CB008806-A_delta_EC1_robust_mulUEs}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.insert              set GNB3_NG_ADDR="${NGIP_simulated_gNB}"   after    set DAEMON_PORT="22222"

    wts_conf.insert              set PROXY_SERVER1_IP="${PROXY1_simulated_gNB}"   after    set DAEMON_PORT="22222"
    wts_conf.insert
    ...  set_gnb id=${Simulated_gnb_ID} type=simulated plmn=311:489 ng=$GNB3_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT
    ...  after  set_gnb id=2
    wts_conf.modify
    ...  set_gnb id=${Simulated_gnb_ID}  gnb_id=0x3:22 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts_conf.insert              set_cell id=1 gnb=${Simulated_gnb_ID} pci=16:0 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=${nrarfcn}:${nrarfcn}
    ...                          after  set_cell id=1 gnb=2
    wts_conf.modify
    ...  set_cell id=1 gnb=${Simulated_gnb_ID}  proxy=$PROXY_SERVER1_IP:9999|$PROXY_SERVER1_IP:8888 mandatory_for_activation=off

    wts_conf.modify    set_qosflow id=1    modification=5qi=5
    wts_conf.modify    set_qosflow id=2    modification=5qi=1
    wts_conf.delete    set_qosflow id=3
    wts_conf.delete    set_qosrule id=1
    wts_conf.delete    set_qosrule id=2
    wts_conf.insert    set_qosrule id=1 proto=udp qos_flow=1  after  set_qosflow id=2
    wts_conf.insert    set_qosrule id=2 proto=udp qos_flow=2  after  set_qosrule id=1
    wts_conf.modify    nwslice_set id=1    modification=qos_flows=1,2 qos_rules=1,2
    wts_conf.insert    set_pdu_gateway id=11 ue_nat_ip=72.23.0.11 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=10
    wts_conf.insert    set_pdu_gateway id=12 ue_nat_ip=72.23.0.12 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=11
    wts_conf.insert    set_pdu_gateway id=13 ue_nat_ip=72.23.0.13 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=12
    wts_conf.insert    set_pdu_gateway id=14 ue_nat_ip=72.23.0.14 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=13
    wts_conf.insert    set_pdu_gateway id=15 ue_nat_ip=72.23.0.15 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=14
    wts_conf.insert    set_pdu_gateway id=16 ue_nat_ip=72.23.0.16 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=15
    wts_conf.insert    set_pdu_gateway id=17 ue_nat_ip=72.23.0.17 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=16
    wts_conf.insert    set_pdu_gateway id=18 ue_nat_ip=72.23.0.18 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=17
    wts_conf.insert    set_pdu_gateway id=19 ue_nat_ip=72.23.0.19 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=18
    wts_conf.insert    set_pdu_gateway id=20 ue_nat_ip=72.23.0.20 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=19

    FOR    ${ue_id}    IN RANGE    1    11
        wts_conf.modify              ue_param id=${ue_id}      nr_usage_setting=voice_centric ${UE_CAPA_EC1_${cellTechnology}}
    END

    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE_CB008806-A_delta_EC1_robust_mulUEs}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE_CB008806-A_delta_EC1_robust_mulUEs}  ${ts_conf_dir}

Setup for CB008806-A_EC10
    Prepare CB008806-A_EC10 WTS Config
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_CB008806-A_EC10}  force_cu_type=SA

Setup for CB008806-A_B3
    [Arguments]    ${pcmd}=${FALSE}
    Set Test Variable    ${TEST_RESULT}   failed
    ${log_dir}=               Get Testcase Log Directory
    Set Test Variable    ${LOG_DIR}
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_CB008806-A_B3}  force_cu_type=SA
    IF    ${pcmd}    Configure PCMD    technology=5G    asn1per_decoding=${True}    load_plugin=${False}

Setup for CB008806-A_EC5
    Prepare CB008806-A_EC5 WTS Config
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_CB008806-A_EC5}  force_cu_type=SA

Setup for CB008806-A_B61
    Prepare CB008806-A_B61 WTS Config
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_CB008806-A_B61}  force_cu_type=SA

Setup for CB008806-A_B7
    Set Test Variable    ${TEST_RESULT}   failed
    Prepare CB008806-A_B7 WTS Config
    Wait For Minimum Required State For Cell Setup
    Apply Config for CB008806_A_B7_inter_gNB
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_CB008806-A_B7}  force_cu_type=SA

Setup for CB008806-A_EC1_robust_mulUEs
    Prepare CB008806-A_delta_EC1_robust_mulUEs WTS Config
    Set Test Variable    ${TEST_RESULT}   failed
    Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_CB008806-A_delta_EC1_robust_mulUEs}  force_cu_type=SA

Apply Config for CB008806-A_EC1_robust
    ${scf_file}=              Load current SCF
    5GC000705-A_Commissioning.Add NRADJGNB to SCF NoXn
    Apply Delta SCF           ${scf_file}  scf_EC1_robust

Apply Config for CB008806-A_B3_alternate_scenario_1
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=tNgRelocOverallN    value=2000
    Apply Delta SCF           ${scf_file}  scf_B3_alt

Apply Config for CB008806_A_B7_inter_gNB
    ${scf_file}=              Load current SCF
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actSaUeBasedAnrNr    value=true
    5GC000705-A_Commissioning.Add NRANR to SCF
    5GC000705-A_Commissioning.Add NRANRPR to SCF
    Delete NRREL1 to SCF
    Delete NRADJNRCELL1 to SCF
    Apply Delta SCF           ${scf_file}  scf_B7

Apply Config for CB008806-A_B8
    ${scf_file}=                           Load current SCF
    scf.modify_scf_element                 dist_name=MRBTS-1/NRBTS-1    p_name=rrcReestabTypeSA    value=viaRRCSetup
    Apply Delta SCF    ${scf_file}  scf_B8

Trigger NG HO intra_freq
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd_ue_meas}    Catenate    ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=30 nrsrq_nr=30
    Send Egate Command and verify output   cmd=${cmd_ue_meas}   pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Trigger NG HO B61_intra_freq_UE2
    Send Egate Command and verify output   ue_meas_cfg_disp id=2
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd_ue_meas}    Catenate    ue_measurement_send_nr id=2 meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=30 nrsrq_nr=30
    Send Egate Command and verify output   cmd=${cmd_ue_meas}   pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Trigger A3 Handover inter gNB B7 HO unsuccessful
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd_ue_meas}    Catenate   ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=20 phycell_id=48 nrsrp_nr=100
    ...       phycell_id=60 nrsrp_nr=45
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd_ue_meas}
    ...    fail_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed    timeout=10    alias=ap_egate
    # Sleep   200s    # time required for creation of NRREL object needed for verification

Trigger A3 Handover inter gNB B7 HO successful
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd_ue_meas}    Catenate   ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=20 phycell_id=48 nrsrp_nr=100
    ...       phycell_id=60 nrsrp_nr=45
    Send Egate Command and verify output   cmd=${cmd_ue_meas}   pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Sleep   200s    # time required for creation of NRREL object needed for verification

Set UE for RRC Reestablishment then trigger NG HO
    ${cmd_nr_rrc_reconf}=                   Catenate    ue_nr_rrc_reconf_param id=1
    ...                                                 if_contains=reconfiguration_with_sync action=reestablish gnb=2 cell=1
    ${cmd_ue_meas}=                         Catenate    ue_measurement_send_nr id=1 meas_id=2 event=A3
    ...                                                 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=30 nrsrq_nr=30
    Send Egate Command and verify output    cmd=${cmd_nr_rrc_reconf}
    Send Egate Command and verify output    cmd=${cmd_ue_meas}
    ...                                     pass_regexp=Received Handover Required
    Sleep    15s    reason=wait for ue context release complete

Verify No NRREL Object Creation
    [Arguments]    ${save_scf_post_verification}
    Load current SCF
    ${dist_name}=   Set Variable    NRBTS-1/NRCELL-1/NRREL-256
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}==False   Set Test Variable   ${TEST_RESULT}   passed
    ${tc_conf_dir}=   Get Testcase Log Directory
    scf.save_scf    ${tc_conf_dir}/${save_scf_post_verification}

Trigger NG HO B3_EC10_inter_freq
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd_ue_meas}    Catenate    ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=49 nrsrp_nr=30 nrsrq_nr=30
    Send Egate Command and verify output   cmd=${cmd_ue_meas}   pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.2 performed

Trigger A2 Measurement Report B3_EC10
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    ${cmd_ue_meas}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Send Egate Command and verify output   cmd=${cmd_ue_meas}

Trigger A3 Measurement with concurrent amf msg
    [Arguments]    ${amf_msg}    ${meas_id}=2    ${ue_id}=1    ${action}=send_concurrent_msg
    Send Egate Command and verify output   ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   amf_ue_ng_handover_param id=1 ue=${ue_id} action=${action} msg=${amf_msg}

    ${cmd_ue_meas}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id}
    ...                                          event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=30 nrsrq_nr=30
    Send Egate Command and verify output   cmd=${cmd_ue_meas}    pass_regexp=Received Handover Required

Trigger A3 Handover with Concurrent AMF Msg
    [Arguments]    ${id}=1    ${action}=send_concurrent_msg    ${amf_msg}=ng_pdu_session_setup    ${meas_id}=2
    ${collector}=                     Set Variable      ue${id}_${amf_msg}
    tcpdump.Start Tcpdump on TestPc   options=-i any -U sctp                  collector=${collector}
    UE Register                       ue_id=${id}       nwslice=1
    Set traffic type                  ue_id=${id}       pdu_id=${id}          trf_type=internal
    UE PDU Session Setup              ue_id=${id}       pdu=${id}             gw=${id}
    Start data traffic in egate       ue_id=${id}       pdu=${id}             direction=dl    trf_id=${id}    qfi=1    mbps=1
    ...                               size=1000         protocol=udp
    Trigger A3 Measurement with concurrent amf msg    ue_id=${id}       amf_msg=${amf_msg}    action=${action}    meas_id=${meas_id}
    Sleep    10s    reason=buffer after handover
    tcpdump.Stop Tcpdump on TestPc    collector=${collector}
    util.Convert PCAP to PDML         ${LOG_DIR}/${collector}/${collector}.pcap
    ...                               ${LOG_DIR}/${collector}/${collector}.pdml
    ...                               filter=\"ngap||nr-rrc\"

Verify B8 with pcap trace
    ${log_dir}=          testline.Get Testcase Log Directory
    tcpdump.Stop Tcpdump on TestPc    collector=ue1_reestablish
    util.Convert PCAP to PDML         ${log_dir}/ue1_reestablish/ue1_reestablish.pcap
    ...                               ${log_dir}/ue1_reestablish/ue1_reestablish.pdml
    ...                               filter=\"ngap||nr-rrc\"
    pdml_analyzer.Check MSC    ${log_dir}/ue1_reestablish/ue1_reestablish.pdml    ${PDML_FIELDS}    ${B8_MSG_SEQ}

Verify EC5
    @{msg_seq_UL}=    Create List
    ...               Received UplinkRanStatusTransfer for Amf UE ID \\d and RAN UE ID \\d
    @{msg_seq_DL}=    Create List
    ...               Unexpected DRBsSubjectToStatusTransferItem for DRB with DRB-ID 5 \\(DRB is not found in admitted RLC AM RadioBearers\\)
    ...               Unexpected DRBsSubjectToStatusTransferItem for DRB with DRB-ID 6 \\(DRB is not found in admitted RLC AM RadioBearers\\)
    ...               Some admitted AM DRBs did not receive DL Ran status\\. Traffic may not work for E-RAB\\(s\\) with DRB_ID=7\\, 8
    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq_UL}
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq_DL}

Verify B61_1
    @{msg_seq}=       Create List
    ...               Sending AMF Status Indication in response to HO required for UE with AMF UE ID 1 and RAN UE ID
    ...               Sending AMF Status Indication in response to HO required for UE with AMF UE ID 2 and RAN UE ID

    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq}

Verify B61_2
    @{msg_seq}=       Create List
    ...               Sending TNLA binding release in response to HO required for UE with AMF UE ID 1 and RAN UE ID 0

    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq}

Verify B3 message sequence
    @{msg_seq}=       Create List
    ...               Session-Endpoint-id:1 QFI:1
    ...               End marker received\\? Yes
    ...               Session-Endpoint-id:1 QFI:4
    ...               Session-Endpoint-id:1 QFI:5

    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq}

    @{msg_seq}=       Create List    Session-Endpoint-id:2 QFI:1
    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq}

Verify B61 message sequence
    @{msg_seq}=       Create List
    ...               Session-Endpoint-id:1 QFI:1
    ...               End marker received\\? Yes

    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq}

Verify B5 RRC DL Information Transfer Message
    @{msg_seq}=       Create List
    ...               Received Handover Required from GNB-\\d with Handover Type INTRA-5GS and cause RAN handover desirable for radio reason for UE
    ...               dlInformationTransfer
    ...               dedicatedNAS-Message
    ...               Received Handover Request Acknowledge Message with RAN UE NGAP ID \\d, AMF UE NGAP ID \\d
    ...               Inter-eNB handover from EXT_ENB.*to ENB.*performed
    ...               End marker received\\? Yes
    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq}

Verify B8 message sequence
    @{msg_seq}=       Create List
    ...               Received Handover Required from GNB-\\d with Handover Type INTRA-5GS and cause RAN handover desirable for radio reason for UE
    ...               message c1 : rrcReconfiguration
    ...               Hit on error cases presence.reconfiguration_with_sync action.reestablish
    ...               message c1 : rrcReestablishmentRequest :
    ...               message c1 : rrcSetup
    ...               message c1 : rrcSetupComplete
    ...               GNB-\\d:.*::Initial UE Message Success
    ...               UE CONTEXT RELEASE REQUEST: gNB.\\d, AMF_UE_NGAP_ID.\\d
    ...               UE CONTEXT RELEASE COMPLETE: gNB.\\d, AMF_UE_NGAP_ID.\\d

    Send Egate Command and verify output     set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{msg_seq}

Verify PDU Session Resource Setup during inter-gNB Ng based Handover on source gNB
    pdml_analyzer.Check MSC    ${LOG_DIR}/ue1_ng_pdu_session_setup/ue1_ng_pdu_session_setup.pdml                  ${PDML_FIELDS}    ${B4_1_MSG_SEQ}

Verify PDU Session Resource Release during inter-gNB Ng based Handover on source gNB
    pdml_analyzer.Check MSC    ${LOG_DIR}/ue2_ng_pdu_session_release/ue2_ng_pdu_session_release.pdml              ${PDML_FIELDS}    ${B4_2_MSG_SEQ}

Verify PDU Session Resource Modification during inter-gNB Ng based Handover on source gNB
    pdml_analyzer.Check MSC    ${LOG_DIR}/ue3_ng_pdu_session_modification/ue3_ng_pdu_session_modification.pdml    ${PDML_FIELDS}    ${B4_3_MSG_SEQ}

Verify NGAP PDU Session management message received after handover preparation phase
    pdml_analyzer.Check MSC    ${LOG_DIR}/ue4_ng_pdu_session_setup/ue4_ng_pdu_session_setup.pdml                  ${PDML_FIELDS}    ${B4_4_MSG_SEQ}

Verify DL NAS message transfer during inter-gNB Ng based Handover on source gNB
    pdml_analyzer.Check MSC    ${LOG_DIR}/ue1_ng_dl_nas_transport/ue1_ng_dl_nas_transport.pdml    ${PDML_FIELDS}    ${B5_1_MSG_SEQ}

Verify DL NAS message is received after Handover Command
    pdml_analyzer.Check MSC    ${LOG_DIR}/ue2_ng_dl_nas_transport/ue2_ng_dl_nas_transport.pdml    ${PDML_FIELDS}    ${B5_2_MSG_SEQ}

Attach 10 UEs with 2 PDU sessions and start DL traffic
    FOR    ${ue_id}    IN RANGE    1  11
        UE Register   ue_id=${ue_id}
        Set traffic type   ue_id=${ue_id}   pdu_id=1   trf_type=internal
        Set traffic type   ue_id=${ue_id}   pdu_id=2   trf_type=internal
        UE PDU Session Setup    ue_id=${ue_id}  pdu=1  gw=${2*${ue_id}-1}
        UE PDU Session Setup    ue_id=${ue_id}  pdu=2  gw=${2*${ue_id}}
        ...    pass_regexp=Pdu Session.*successfully
        CB008806-A_Keywords.Start data traffic on 2 PDU sessions EC1 robustness   ue_id=${ue_id}
    END

Stop Traffic and teardown all UEs
    FOR    ${ue_id}    IN RANGE    1  11
        CB008806-A_Keywords.Stop data traffic on 2 PDU sessions EC1 robustness   ue_id=${ue_id}
        run_keyword_and_warn_on_failure    UE Deregister  ue_id=${ue_id}
    END

Trigger A3 Handover Radio Resources not available robustness test mul UEs
    FOR    ${ue_id}    IN RANGE    1  11
        ${cmd}    Catenate   amf_ue_ng_handover_param id=1 ue=${ue_id} action=ho_preparation_failure cause=RN_radio_resources_not_available
        Send Egate Command and verify output   ${cmd}
    END
    FOR    ${index}    IN RANGE    100
        Trigger A3 Measurement Report for 10 UEs
    END

Trigger A3 Measurement Report for 10 UEs
    FOR    ${ue_id}    IN RANGE    1  11
        Trigger Measurement Report mul UEs  ue_id=${ue_id}
    END

Trigger Measurement Report mul UEs
    [Arguments]   ${ue_id}=1
    ${cmd}    Catenate   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=48 nrsrp_nr=90 nrsrq_nr=50
    Send Egate Command and verify output   cmd=${cmd}

Verify B3 pmcounters IAF
    [Arguments]    ${pm_files_location}   ${trunk_or_25R2_onwards}=True
    ${expected_pm_counter_list}=    Create List
    ...   M55147C00504  ==  1       Successfull Preparation of Handover for Emergency call
    ...   M55147C00501  ==  1       Handover attempts for IMS Emergency Call
    ...   M55147C00503  ==  1       Successfull Handover Completions for IMS Emergency Call
    ...   M55125C07512  ==  1       successful NG based HO prep att on the source cell
    ...   M55125C07502  ==  1       NG based Intra-freq HO prep att on the source cell
    ...   M55125C07514  ==  1       NG based Intra-freq HO exec att on the source cell
    ...   M55125C07523  ==  1       successful NG based Intra-freq HO exec att on the source cell
    ...   M55125C00501  ==  1       Number of UE CONTEXT RELEASE COMMAND received
    ...   M55125C00502  ==  1       Number of UE CONTEXT RELEASE COMPLETE sent

    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list}
    ...  pm_dir=${pm_files_location}  distname_suffix=1

    ${expected_pm_counter_list_older_rel}=    Create List
    ...   M55125C07525  >=  1       Mean time of requested HO exec att for NG based HO
    ...   M55125C07526  >=  1       Max time of requested HO exec att for NG based HO

    IF  not ${trunk_or_25R2_onwards}     Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list_older_rel}
    ...  pm_dir=${pm_files_location}  distname_suffix=1

    ${expected_pm_counter_list2}=    Create List
    ...   M55153C00501  ==  1       HO prep att on the source cell for NG based HO per neighbor cell relation
    ...   M55153C00502  ==  1       HO exec att on the source cell for NG based HO per neighbor cell relation
    ...   M55153C00503  ==  1       successful HO exec att on the source cell for NG based HO per neighbor cell relation

    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list2}
    ...  pm_dir=${pm_files_location}  distname_suffix=MNC-489

    ${expected_pm_counter_list3}=    Create List
    ...   M55149C03001  ==  1       NG based Intra-freq HO prep att on the source cell per PLMN per slice
    ...   M55149C03002  ==  1       NG based Intra-freq HO exec att on the source cell per PLMN per slice
    ...   M55149C03003  ==  1       successful NG based Intra-freq HO exec att on the source cell per PLMN per slice
    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list3}
    ...  pm_dir=${pm_files_location}  distname_suffix=SD-13714341

Verify B3 pmcounters instance 5
    [Arguments]    ${pm_files_location}
    ${expected_pm_counter_list}=    Create List
    ...   M55125C09526  >=  1       In-session connected time for 5QI1 QoS Flows released due to normal cause
    ...   M55125C09516  >=  1       In-session connected time for QoS Flows
    ...   M55125C09508  ==  2       Num of 5QI-1 QoS Flows released due to successful Intra NR HO at source cell
    ...   M55125C09015  ==  7       Num of QoS Flows released due to successful Intra NR HO at source cell
    ...   M55337C01001  >=  0       DL data volume sent over DL PDU session or DRB data forwarding GTP-U tunnel - For QoS Group 01
    ...   M55337C01002  >=  0       DL data volume sent over DL PDU session or DRB data forwarding GTP-U tunnel - For QoS Group 02

    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list}
    ...  pm_dir=${pm_files_location}  distname_suffix=1

    ${expected_pm_counter_list2}=    Create List
    ...   M55163C00521  >=  1       In-session connected time for PMQAP Profile based QoS Flows
    ...   M55163C00515  ==  7       Num of PMQAP QoS Flows released due to successful Intra NR HO at source cell

    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list2}
    ...  pm_dir=${pm_files_location}  distname_suffix=NRCELL-1/PLMN-PLMN/NRPMQAP-1

Verify B3 pmcounters IEF
    [Arguments]    ${pm_files_location}
    ${expected_pm_counter_list}=    Create List
    ...   M55147C00504  ==  1       Successfull Preparation of Handover for Emergency call
    ...   M55147C00501  ==  1       Handover attempts for IMS Emergency Call
    ...   M55147C00503  ==  1       Successfull Handover Completions for IMS Emergency Call
    ...   M55125C07512  ==  1       successful NG based HO prep att on the source cell
    ...   M55125C07525  >=  1       Mean time of requested HO exec att for NG based HO
    ...   M55125C07526  >=  1       Max time of requested HO exec att for NG based HO
    ...   M55125C07501  ==  1       NG based Inter-freq HO prep att on the source cell
    ...   M55125C07513  ==  1       NG based Inter-freq HO exec att on the source cell
    ...   M55125C07522  ==  1       successful NG based Inter-freq HO exec att on the source cell
    ...   M55125C00501  ==  1       Number of UE CONTEXT RELEASE COMMAND received
    ...   M55125C00502  ==  1       Number of UE CONTEXT RELEASE COMPLETE sent

    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list}
    ...  pm_dir=${pm_files_location}  distname_suffix=1

    ${expected_pm_counter_list2}=    Create List
    ...   M55153C00501  ==  1       HO prep att on the source cell for NG based HO per neighbor cell relation
    ...   M55153C00502  ==  1       HO exec att on the source cell for NG based HO per neighbor cell relation
    ...   M55153C00503  ==  1       successful HO exec att on the source cell for NG based HO per neighbor cell relation

    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list2}
    ...  pm_dir=${pm_files_location}  distname_suffix=MNC-489

    ${expected_pm_counter_list3}=    Create List
    ...   M55149C03004  ==  1       NG based Inter-freq HO prep att on the source cell per PLMN per slice
    ...   M55149C03005  ==  1       NG based Inter-freq HO exec att on the source cell per PLMN per slice
    ...   M55149C03006  ==  1       successful NG based Inter-freq HO exec att on the source cell per PLMN per slice
    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list3}
    ...  pm_dir=${pm_files_location}  distname_suffix=SD-13714341


Verify B3 pmcounters alternate scenario
    [Arguments]    ${pm_files_location}
    ${expected_pm_counter_list}=    Create List
    ...   M55125C01001  ==  1       Number of UE Context Release Request sent
    ...   M55125C07521  ==  1       failed NG based HO exec att on the source cell due TNGRELOCoverall guard timer expiry
    ...   M55125C00501  ==  1       Number of UE CONTEXT RELEASE COMMAND received
    ...   M55125C00502  ==  1       Number of UE CONTEXT RELEASE COMPLETE sent

    Verify PM Counter Reference Table     reference_table=${expected_pm_counter_list}
    ...  pm_dir=${pm_files_location}  distname_suffix=1

Set Emergency Call Priority
    [Arguments]   ${priority}=1  ${ue_id}=1
    Send Egate Command and verify output    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Send Egate Command and verify output    qosflow_modify qos_flow=1 priority=${priority}
    Send Egate Command and verify output    qosflow_modify qos_flow=2 priority=${priority}

Start data traffic on 2 PDU sessions EC10_B3
    [Arguments]   ${ue_id}=1
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=2   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=3   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=4   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=5   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=2   qfi=1   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=2   qfi=2   mbps=1   size=100

Stop data traffic on 2 PDU sessions EC10_B3
    [Arguments]   ${ue_id}=1
    # Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=1    qfi=1
    # Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=1    qfi=2
    # Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=1    qfi=3
    # Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=1    qfi=4
    # Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=1    qfi=5
    # Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=2    qfi=1
    # Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=2    qfi=2
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=1
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=2
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=3
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=4
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=5
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=2   qfi=1
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=2   qfi=2

Start data traffic on PDU session EC5
    [Arguments]   ${ue_id}=1
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=2   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=3   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=4   mbps=1   size=100
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=5   mbps=1   size=100

Stop data traffic on PDU session EC5
    [Arguments]   ${ue_id}=1
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=1
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=2
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=3
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=4
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=5

Start data traffic on 2 PDU sessions EC1 robustness
    [Arguments]   ${ue_id}=1
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1
    Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=1   pdu=2   qfi=1   mbps=1

Stop data traffic on 2 PDU sessions EC1 robustness
    [Arguments]   ${ue_id}=1
    Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=1    qfi=1
    Get Average Data Rate via Egate    ue_id=${ue_id}    dir=dl    trf_id=1    pdu=2    qfi=1
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=1   qfi=1
    Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=1   pdu=2   qfi=1

Verify UPLINK RAN STATUS TRANSFER in Cell Trace
    ${pdml_file}=    CB008806-B_Keywords.Pcap To Pdml for Nsetapx
    ${field_name_list}=      Create List
    ...                      nsetapx.asn1_MsgId
    pdml_analyzer.Check MSC        ${pdml_file}  ${field_name_list}  asn1-MsgId: 92

Verify UPLINK RAN STATUS TRANSFER not in Cell Trace
    ${trace_exsits}=         Run Keyword and Return Status
    ...                      Verify UPLINK RAN STATUS TRANSFER in Cell Trace
    IF    ${trace_exsits}    Fail  Unexpected cell trace msg found

get resources taken before_test
    Log To Console    \nget used resources and save in var "resources_usage_before_test"
    ${resources_usage_before_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    set test variable    ${resources_usage_before_test}

get resources taken after_test
    Sleep    5s    reason=wait until resource clean up
    Log To Console    \nget used resources and save in var "resources_usage_after_test"
    ${resources_usage_after_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    set test variable    ${resources_usage_after_test}

verify resource usage
    Log To Console    \nverify used resources
    Run Keyword And Continue On Failure      resources.Resources Should Be Equal
    ...    ${resources_usage_before_test}
    ...    ${resources_usage_after_test}

Change RD Parameters in swconfig File to Disable PCMD Records Bundling
    [Documentation]    This keyword modifies the swconfig file in gNB to disable new feature CB008411 CT/PCMD records bundling
    @{swconfig_rd_param}=  create list
    ...    0xA40000=0   # CB008411 CT/PCMD records bundling (0 = disabled, 1 = enabled/default)
    Update SW Config file on System Module  param_list=${swconfig_rd_param}

Modify WTS file for EDA_04087344 Test Scenario
    ${ts_conf_dir}=           Get Test Suite Config Directory
    wts_conf.load_wts_cfg     file_path=${ts_conf_dir}/${WTS_CFG_FILE_CB008806-A_B3}
    wts_conf.insert           set UPF2_ADDR="1.2.4.2"        after        set UPF_ADDR="1.2.4.1"
    wts_conf.insert           set DEV_TUN2_NAME="tun2UPF"    after        set UPF2_ADDR="1.2.4.2"
    wts_conf.insert           set DNN="internet"             after        set DEV_TUN2_NAME="tun2UPF"
    wts_conf.modify           set_gnb id=2                   modification=amf=1-2 plmnList=311:489,311:488 nssai=0x1:0xFFFFFF
    wts_conf.modify           set_cell id=1 gnb=2            modification=eq_plmn=311:488
    wts_conf.modify           set_gnb id=3                   modification=amf=1-2 plmnList=311:489,311:488 nssai=0x1:0xFFFFFF
    wts_conf.modify           set_cell id=1 gnb=3            modification=eq_plmn=311:488
    wts_conf.insert           set_amf_region id=2 tac_list=7627107,100,788,200,0 plmn=311:488    after    amf_param id=1 ims_voice_3gpp=on
    wts_conf.insert           set_amf id=2 daemon=$SERVER_IP:$DAEMON_PORT ng=$AMF2_NG_ADDR:38412 region=2 set_id=3 pointer=2
    ...                       after    set_amf_region id=2
    wts_conf.insert           amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc    after    set_amf id=2
    ${upf_id_2}=              Catenate     SEPARATOR=${SPACE}      set_upf id=2 daemon=$SERVER_IP:$DAEMON_PORT type=simulated addr=$UPF2_ADDR/24
    ...    ngu=$AMF2_NG_ADDR n4=$DAEMON_IP dnn=$DNN devname=$DEV_TUN2_NAME ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20
    wts_conf.insert           ${upf_id_2}    after      amf_param id=2
    wts_conf.insert           upf_param id=2 end_markers_delay=1000    after      set_upf id=2
    wts_conf.insert           amf_timer T_Local=4000 T_NotifyProcessing=2500    after      upf_param id=2
    wts_conf.modify           set_ue simulated id=1          modification=suci=0:311:488:0000:0:0:021645400
    wts_conf.modify           nwslice_set id=1               modification=snssai=0x1:0xFFFFFF default=on ue=all amf=1-2
    wts_conf.save_wts_cfg     file_path=${tl.core.dir_path}/basic_setup_EDA_04087344.cfg
    Copy File                 ${tl.core.dir_path}/basic_setup_EDA_04087344.cfg  ${ts_conf_dir}

Setup for CB008806_A_EDA_04087344 Scenario
    [Arguments]
    Modify WTS file for EDA_04087344 Test Scenario
    CB008806-A_Commissioning.Apply SCF Configuration for EDA_04087344 Test Scenario
    ute_workarounds.Bring Airphone TL to on Air status  cfg_file=basic_setup_EDA_04087344.cfg
    sqd65_keywords.Start Logging   pmcounter_enabled=${FALSE}

Tear Down for CB008806_A_EDA_04087344 Scenario
    Run Keyword And Warn On Failure    sqd65_keywords.Stop logging
    ${config_dir}=      testline.Get test suite config directory
    commissioning.Execute full commissioning      ${config_dir}/scfc_8806-A.xml
    ute_workarounds.Bring Airphone TL to on Air status  cfg_file=${WTS_CFG_FILE_CB008806-A_B3}
