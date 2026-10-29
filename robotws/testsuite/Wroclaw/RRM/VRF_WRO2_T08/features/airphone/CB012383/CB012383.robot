*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    CRT
...           SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Dariusz Maciocha
...              :contact: dariusz.maciocha@nokia.com

Resource   testsuite/Wroclaw/RRM/resources/airphone/scripts/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_iphy
Library    ta5g_throughput
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/resources/keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaFixer.py
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB012383/resources/test_variables.py

Suite Setup    Run Keywords     Start Vm Ethernet Interfaces
...    AND     Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...    AND     Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1  parameter=fPdcchMonOccsnPo  value=${fPdcchMonOccsnPo_val}
...    AND     Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2  parameter=fPdcchMonOccsnPo  value=${fPdcchMonOccsnPo_val}
Test Teardown    Run Keywords     Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...         AND                   Add Scout Scf Id To Test Data
...         AND                   Run Keyword If Test Passed    Find Suspicious Logs

*** Variables ***
${actual_delta}=      ${NULL}
${initial_config}=    ${TRUE}
${modify_snsai}=      ${NULL}
@{fPdcchMonOccsnPo_val}=    2
@{SWCONFIG_FLAGS_LIST}=        0x890062=1 #Removal timer

*** Test Cases ***
CB012383-A-B1_ANR_IF_HO_Interrupted_by_PDU_Session_Setup_5QI-5_1
    [Setup]    Setup    delta=delta_B11.json    egate=b3_alt2.lua
    Attach Ue    ue_id=16
    Establish PDU Session    ue_id=16    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2
    Set Additional Qos Flow To Activate    qos_flows=3
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id    ue_id=16    pcell_id=1    cell_type=SA
    ...      srsrp_nr=30
    ${set_rrc_reconf_param}    Catenate    ue_nr_rrc_reconf_param id=16 if_contains=report_cgi
    ...                                    action=send_nas_pdu_session_setup anr_cgi_delay=1000 pduSessionInfo=2:2:1:2
    Execute Egate Command    cmd=${set_rrc_reconf_param}
    Sleep    2s
    Send Custom Ue Measurement Nr    id=16    meas_id=5    event=A3    srsrp_nr=80    phycell_id=52    nrsrp_nr=90
    Verify Wireshark    messages=${A_B1_TCP}
    Verify Wireshark    messages=${A_B1_NGAP}
    Verify That NRRel Object Is Not Present

CB012383-A-B3-alt2_ANR_Intra_freq_HO_Interrupted_by_PDU_Session_Setup_5QI-5_1_2_with_cgi-Info_report
    [Setup]    Setup    delta=delta_B11.json    egate=b3_alt2.lua
    Attach Ue    ue_id=16
    Establish PDU Session    ue_id=16    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2
    Set Additional Qos Flow To Activate    qos_flows=3,4
    Execute Egate Command    cmd=amf_ue_pdu_setup_param id=1 ue=16 action=delay time_to_wait=1150
    Sleep    2s
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 gw=2 ue=16 nwslice=2
    Sleep    1s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=report_cgi delay=1000 anr_cgi_delay=100
    Send Custom Ue Measurement Nr    id=16    meas_id=2    event=A3    srsrp_nr=80    phycell_id=51    nrsrp_nr=90
    Verify Wireshark    messages=${A_B3_TCP}
    Verify Wireshark    messages=${A_B3_NGAP}
    Verify That NRRel Object Is Not Present

CB012383-A-B11_B5_main_ANR_IF_HO_Interrupted_by_PDU_Session_Modify_add_5QI-8_no-reportCGI
    [Setup]    Run Keywords    Setup    delta=delta_B11.json    egate=b3_alt2.lua
    ...    AND          Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1  parameter=maxNumOfNonGBRBearersSA  value=2
    Attach Ue    ue_id=16
    Establish PDU Session    ue_id=16    pdu_id=1    gw_id=1
    Send Custom Ue Measurement Nr    id=16    meas_id=1    event=A2    srsrp_nr=30
    Set QoS Flow As Default    qos_flow=2
    Establish PDU Session    ue_id=16    pdu_id=2    nwslice=2    gw_id=2
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=meas_gap_release action=none delay=400
    Send Custom Ue Measurement Nr    id=16    meas_id=5    event=A3    srsrp_nr=80    phycell_id=52    nrsrp_nr=90
    Sleep    0.1s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=16 pdu=1 qosflows_to_add=5
    Verify Wireshark    messages=${A_B11_5_TCP}
    Verify Wireshark    messages=${A_B11_5_NGAP}
    Verify That NRRel Object Is Not Present
    [Teardown]    Run Keywords    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1  parameter=maxNumOfNonGBRBearersSA  value=550
    ...    AND    Add Scout Scf Id To Test Data
    ...    AND    Run Keyword If Test Passed    Find Suspicious Logs
    ...    AND    Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB012383-A-B11_B6_main_ANR_IF_HO_Interrupted_by_PDU_Session_Modify_remove_5QI-8_no-reportCGI
    [Setup]    Setup    delta=delta_B11.json    egate=b3_alt2.lua
    Attach Ue    ue_id=16
    Set Additional Qos Flow To Activate    qos_flows=5
    Sleep    2s
    Establish PDU Session    ue_id=16    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2
    Establish PDU Session    ue_id=16    pdu_id=2    gw_id=2    nwslice=2
    Send Custom Ue Measurement Nr    id=16    meas_id=1    event=A2    srsrp_nr=30
    Sleep    2s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=any delay=1000
    Sleep    1s
    Send Custom Ue Measurement Nr    id=16    meas_id=5    event=A3    srsrp_nr=80    phycell_id=52    nrsrp_nr=90
    Execute Egate Command    cmd=ue_pdu_session_modify ue=16 pdu=1 qosflows_to_del=5
    Verify Wireshark    messages=${A_B11_6_TCP}
    Verify Wireshark    messages=${A_B11_6_NGAP}
    Verify That NRRel Object Is Not Present

CB012383-A-B4-alt1_ANR_Intra_HO_Interrupted_by_failed_PDU_Session_Modify_add_5QI-1_5QI-2
    [Setup]    Setup    delta=delta_B4.json    egate=b4_alt1.lua
    Attach Ue    ue_id=16
    Establish PDU Session    ue_id=16    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2
    Establish PDU Session    ue_id=16    pdu_id=2    gw_id=2    nwslice=2
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id    ue_id=16    pcell_id=1    cell_type=SA
    ...    srsrp_nr=30
    ${set_rrc_reconf_param}    Catenate
    ...    ue_nr_rrc_reconf_param id=16 if_contains=report_cgi action=send_nas_pdu_session_modify
    ...    anr_cgi_delay=1000 pduSessionInfo=2:2:1:2:2 qosflows_to_add=3,4
    Execute Egate Command            cmd=${set_rrc_reconf_param}
    Sleep    2s
    Send Custom Ue Measurement Nr    id=16    meas_id=5    event=A3    srsrp_nr=80    phycell_id=52    nrsrp_nr=90
    Verify Wireshark    messages=${A_B4_TCP}
    Verify Wireshark    messages=${A_B4_NGAP}
    Verify That NRRel Object Is Not Present

CB012383-B-B3_ANR_XN_HO_Interrupted_by_NGAP_UE_Context_Modification_Request_with_Emergency_Fallback_Indicator_IE
    [Setup]    Setup    delta=delta_B_B3.json    egate=B_B3.lua    snsai=${FALSE}
    Delay Handover Response
    Attach Ue    ue_id=3
    Set QoS Flow As Default    qos_flow=1    priority=9
    Establish PDU Session    ue_id=3    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2    priority=1
    Establish PDU Session    ue_id=3    pdu_id=2    gw_id=2
    Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=3 index=0 nrs_result=125:125:0 event=A5 phycell_id=150 nrsrq_nr=125 srsrq_nr=17
    Sleep    0.8s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=2 qosflows_to_add=3
    Verify Wireshark    messages=${B_B3_TCP}
    Verify Wireshark    messages=${B_B3_NGAP}
    Verify That NRRel Object Is Not Present

CB012383-A-B11_B2_alt_1_ANR_IF_HO_Interrupted_by_failed_PDU_Session_Modify_5QI-1_no-reportCGI
    [Setup]    Setup    delta=delta_B11_alt2.json    egate=b11_alt2.lua
    Attach Ue    ue_id=16
    Establish PDU Session    ue_id=16    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2
    Establish PDU Session    ue_id=16    pdu_id=2    nwslice=2    gw_id=2
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=1 event=A2 srsrp_nr=30
    Sleep    2s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=report_cgi anr_cgi_delay=300
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=5 event=A3 srsrp_nr=80 phycell_id=50 nrsrp_nr=90
    Execute Egate Command    cmd=ue_pdu_session_modify ue=16 pdu=2 qosflows_to_add=3
    Verify Wireshark    messages=${A_B11_2_TCP}
    Verify Wireshark    messages=${A_B11_2_NGAP}
    Verify That NRRel Object Is Not Present

CB012383-A-B10_Ongoing_ANR_IF_HO_Interrupted_by_PDU_Session_Modify_5QI-1
    [Setup]    Setup    delta=delta_A10.json    egate=B10.lua    snsai=${FALSE}
    Delay Handover Response
    Attach Ue    ue_id=3
    Set QoS Flow As Default    qos_flow=1    priority=9
    Establish PDU Session    ue_id=3    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2    priority=1
    Establish PDU Session    ue_id=3    pdu_id=2    gw_id=2
    Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=1 event=A2 srsrp_nr=20
    Sleep    2s
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=5 event=A3 srsrp_nr=80 phycell_id=150 nrsrp_nr=90
    Sleep    0.8s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=2 qosflows_to_add=3
    Sleep    2s
    Verify Wireshark    messages=${A_B10_TCP}
    Verify Wireshark    messages=${A_B10_NGAP}
    Verify That NRRel Object Is Not Present
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=2 qosflows_to_del=3
    Sleep    2s
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=7 event=A2 srsrp_nr=20
    Sleep    1s
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=9 event=A3 srsrp_nr=80 phycell_id=150 nrsrp_nr=90
    Sleep    2s
    Wait For Object To Exist    object_name=NRREL    moc=NRREL_A        timeout=70
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=1 event=A3 phycell_id=50 nrsrp_nr=95
    Sleep    5s
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=7 event=A2 srsrp_nr=20
    Sleep    2s
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 reset
    Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 action=force_failure_with_delay time_to_wait=v1s cause=handover_target_not_allowed
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=11 event=A3 srsrp_nr=80 phycell_id=150 nrsrp_nr=90
    Sleep    10s
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 reset
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=11 event=A3 srsrp_nr=80 phycell_id=150 nrsrp_nr=90
    Sleep    5s
    Stop Default Syslog For Enb And Iphy
    Verify Wireshark    messages=${A_B10_TCP_EDA}
    Verify Wireshark    messages=${A_B10_NGAP_EDA}
    Verify Syslog For Correct Prints    ${OUTPUT_DIR}/${TEST_NAME}    ${ANR_RECHECK_STATE}
    [Teardown]    Run Keywords    Delete Scf Objects    dist_names=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-256
    ...    AND    Add Scout Scf Id To Test Data
    ...    AND    Run Keyword If Test Passed    Find Suspicious Logs
    ...    AND    Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB012383-C-B1_ANR_PCI_Resolution_Interrupted_by_NGAP_UE_Context_Modification_Request_with_UE_AMBR_IE
    [Setup]    Run Keywords    Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
    ...    AND                 Setup    delta=delta_C.json    egate=C.lua    snsai=${FALSE}
    FOR    ${ue_id}    IN RANGE    4    53    1
        Attach UE    ue_id=${ue_id}
        ...    pass_regexp=Received REGISTRATION COMPLETE from UE
        Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
        Establish PDU Session    ue_id=${ue_id}    pdu_id=1    gw_id=${ue_id}
        Start Data Traffic    ues=${ue_id}    direction=dl    pdu=1    throughput=10mbps    optional_parameters=protocol=udp
    END
    Attach Ue    ue_id=3
    Set QoS Flow As Default    qos_flow=1
    Execute Egate Command    cmd=set_pdu_param ue=3 pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=3 pdu=2 trf_type=internal
    Establish PDU Session    ue_id=3    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2
    Sleep    2s
    Verify Traffic    expected_throughput=10
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=1 event=A2 srsrp_nr=30
    Sleep    2s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=3 if_contains=meas_gap_release action=none delay=800
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=5 event=A3 srsrp_nr=80 phycell_id=150 nrsrp_nr=90
    Execute Egate Command    cmd=amf_ue_ctx_modify_param id=1 ue=3 ue_ambr_ul=5:Mbps ue_ambr_dl=5:Mbps
    Sleep    0.5s
    Execute Egate Command    cmd=ue_ctx_ng_mod id=3
    Sleep    2s
    Verify Traffic    expected_throughput=5
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=7 event=A2 srsrp_nr=30
    Sleep    2s
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=9 event=A3 srsrp_nr=80 phycell_id=150 nrsrp_nr=90
    Sleep    5s
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=10 event=A2 srsrp_nr=30
    Sleep    2s
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=12 event=A3 srsrp_nr=80 phycell_id=150 nrsrp_nr=90
    Verify Wireshark    messages=${C_B_TCP}
    Verify Wireshark    messages=${C_B_NGAP}
    Check If Object Exists    object_name=XNLINK    moc=XNLINK_A
    Check If Object Exists    object_name=NRADJGNB    moc=NRADJGNB_A
    Wait For Object To Exist    object_name=NRREL    moc=NRREL_A    timeout=60
    Check If Object Exists    object_name=NRADJNRCELL    moc=NRADJNRCELL_A
    Wait For Object To Not Exist    object_name=NRREL    moc=NRREL_A    timeout=60
    Wait For Object To Not Exist    object_name=NRADJNRCELL    moc=NRADJNRCELL_A    timeout=60
    Wait For Object To Not Exist    object_name=XNLINK    moc=XNLINK_A    timeout=60
    Check If Object Doesnt Exist    object_name=NRADJGNB    moc=NRADJGNB_A
    FOR    ${ue_id}    IN RANGE    4    53    1
        Expected Throughput For Ue Should Be Reached    ue_id=${ue_id}    throughput=10
        ...    direction=dl    selection_type=current    layer=physical
        Stop Data Traffic    ues=${ue_id}    direction=dl    pdu=1
    END

CNI126048-A-B2_SA_ANR_PCI_Resolution_recovery_rollback_after_CGI_report_configuration_T321_timeout
    [Setup]    Setup    delta=delta_B4.json    egate=b4_alt1.lua
    Attach Ue    ue_id=16
    Establish PDU Session    ue_id=16    pdu_id=1    gw_id=1
    Set QoS Flow As Default    qos_flow=2
    Establish PDU Session    ue_id=16    pdu_id=2    gw_id=2    nwslice=2
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=1 event=A2 srsrp_nr=30
    Sleep    3s
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=7 event=B2 srsrp_nr=80 phycell_id=11 nrsrp_nr=90
    Sleep    10s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=report_cgi action=donot_send_NRCGI
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=2 event=A3 srsrp_nr=80 phycell_id=51 nrsrp_nr=90
    Sleep    10s
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=9 event=A2 srsrp_nr=30    srsrp_nr=30
    Sleep    3s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=report_cgi action=donot_send_NRCGI
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=11 event=A3 srsrp_nr=80 phycell_id=52 nrsrp_nr=90
    Sleep    10s
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=14 event=A2 srsrp_nr=30    srsrp_nr=30
    Sleep    3s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=report_cgi_eutra action=donot_send_EUTRACGI
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=18 event=B2 srsrp_nr=80 phycell_id=11 nrsrp_nr=90
    Sleep    10s
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=19 event=A2 srsrp_nr=30
    Sleep    3s
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=16 if_contains=report_cgi action=report_noSIB1
    Execute Egate Command    cmd=ue_measurement_send_nr id=16 meas_id=21 event=A3 srsrp_nr=80 phycell_id=52 nrsrp_nr=90
    Sleep    10s
    Verify Wireshark    messages=${CB0126048_TCP}
    Verify Wireshark    messages=${CB0126048_NGAP}
    Verify That NRRel Object Is Not Present

*** Keywords ***
Send A3 Measurement
    [Arguments]    ${ue_id}    ${target_phycell_id}=52    ${srsrp_nr}=80    ${nrsrp_nr}=90    ${carrier_freq}=126530
    ${meas_id}    Get Meas Id For Event A3    pcell_id=1    carrier_freq=${carrier_freq}
    Send Custom Ue Measurement Nr    pass_regexp=measResultListNR  get_ue_meas_cfg=1  id=${ue_id}  meas_id=${meas_id}
    ...                              index=0    event=A5  srsrp_nr=${srsrp_nr}
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  rs_type=ssb
    Sleep    3s    reason=Waiting for handover request to be processed

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB3_XN    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_NG    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_XN    ip_with_mask=10.0.1.103/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_NG    ip_with_mask=10.0.1.104/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_X2    ip_with_mask=10.0.1.105/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_X2    ip_with_mask=10.0.1.106/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_S1    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_S1    ip_with_mask=10.0.1.4/24

Set QoS Flow As Default
    [Arguments]    ${qos_flow}    ${priority}=15
    Execute Egate Command    cmd=qosflow_modify qos_flow=${qos_flow} priority=${priority} default=on

Set Additional Qos Flow To Activate
    [Arguments]    ${qos_flows}
    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=${qos_flows}

Delay Handover Response
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 action=delayed_rsp time_to_wait=v1s

Setup
    [Arguments]    ${delta}    ${egate}    ${snsai}=${TRUE}
    IF    '${delta}' != '${actual_delta}'    Prepare Configuration    ${delta}    ${snsai}
    Trigger Site Reset
    Check Radios Availability
    Reach Onair    lua_cfg=${CURDIR}/config/${egate}
    Execute egate command    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=ENB-1: X2AP Link with GNB-2.*is up
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Prepare Configuration
    [Arguments]    ${delta}    ${snsai}
    IF    ${initial_config} != ${TRUE}    Roll Back To Initial Scfc
    Set Suite Variable    ${modify_snsai}    ${snsai}
    ${preparation}    Get Commissioning File For Enb Release Name    delta_preparation.json
    IF    ${modify_snsai}    Send Delta Commissioning With Fixer    ${preparation}
    ${delta}    Get Commissioning File For Enb Release Name    ${delta}
    Send Delta Commissioning With Fixer    ${delta}
    Check Radios Availability
    Set Suite Variable    ${actual_delta}    ${delta}
    Set Suite Variable    ${initial_config}    ${FALSE}

Roll Back To Initial Scfc
    ${preparation}    Get Commissioning File For Enb Release Name    delta_preparation.json
    IF    ${modify_snsai}    Send Delta Commissioning With Fixer    ${preparation}
    Roll Delta Back
    ...    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...    delta_scf_filename=${actual_delta}
    Set Suite Variable    ${initial_config}    ${TRUE}
    Check Radios Availability

Verify That NRRel Object Is Not Present
    Sleep    60s
    Check If Object Doesnt Exist    object_name=NRREL    moc=NRREL_A

Verify Traffic
    [Arguments]    ${expected_throughput}
    Start Data Traffic    ues=3    direction=both    pdu=1    throughput=10mbps    optional_parameters=protocol=udp
    Sleep    5s    Wait for throughput to stabilize
    Expected Throughput For Ue Should Be Reached    ue_id=3    throughput=${expected_throughput}
    ...    direction=dl    selection_type=current    layer=physical
    Expected Throughput For Ue Should Be Reached    ue_id=3    throughput=${expected_throughput}
    ...    direction=ul    selection_type=current    layer=physical
    Stop Data Traffic    ues=3    direction=both    pdu=1

Verify Wireshark
    [Arguments]    ${messages}
    FOR    ${msg}    IN    @{messages}
        ${length}=    Get Length    ${msg}
        IF    ${length} != 2    Verify Tcpdump Log    packet_filter=${msg}
        ...    ELSE    Verify Tcpdump Log    packet_filter=${msg}[0]    number_of_messages=${msg}[1]
    END
