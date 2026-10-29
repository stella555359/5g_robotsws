*** Settings ***
Force Tags    RAN_VRF    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]

Documentation   :copyright: Nokia
...             :authors: Dariusz Maciocha
...             :contact: dariusz.maciocha@nokia.com

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/feature_keywords.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/multignb_variables.py
Library      testsuite/Wroclaw/RRM/resources/scout_report.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaFixer.py
Library      ta5g_admin_operations
Library      ta5g_iphy
Library      ta5g_commissioning
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/resources/keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB008490/resources/CB008490_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008490/resources/test_specific_keywords_CB008490.py
Library      testsuite/Wroclaw/RRM/resources/syslog_checker.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB008490/resources/test_variables.py


Suite Setup       Environment Preaparation
Test Teardown    Run Keywords    Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND       Add Scout Scf Id To Test Data
...    AND       Run Keyword If Test Passed    Find Suspicious Logs

*** Variables ***
${SCFC_MN_P}=        scf_P_MN.xml
${SCFC_SN_P}=        scf_P_SN.xml
${SCFC_MN_X}=        scf_X_MN.xml
${IPHY_P}=           ${CURDIR}/config/iphy_MN_AHGD_AEQE_SN_AWEUB_B1_B2_B3_updated.xml
${EGATE_P}=          ${CURDIR}/config/cfg_PCMD_TRACE.cfg
${SCFC_MN_GI}=       scf_GI_MN.xml
${SCFC_SN_GI}=       scf_GI_SN.xml
${IPHY_GI}=          ${CURDIR}/config/iphy_MN_AHFIB_AHLOA_AEHC_SN_AWEWB.xml
${EGATE_GI}=         ${CURDIR}/config/cfg_GI.cfg
${SCFC_MN_GE}=       scf_GE_MN.xml
${SCFC_SN_GE}=       scf_GE_SN.xml
${IPHY_GE}=          ${CURDIR}/config/iphy_GE.xml
${EGATE_GE}=         ${CURDIR}/config/cfg_GE.cfg
${DELTA_GE}=         delta_unlock_two_cells.json
${SCFC_MN_GG301}=    GG_B301/Full_SCF_MN_CB008490_GG_B101.xml
${SCFC_SN_GG301}=    GG_B301/Full_SCF_SN_CB008490_GG_B101_B301.xml
${IPHY_GG301}=       ${CURDIR}/config/CB008490_GG_B301_iphy.xml
${EGATE_GG301}=      ${CURDIR}/config/CB008490_GG_B301_WTS.cfg
${DELTA_B101}=       GG_B301/CB008490_GG_B101_delta.json
${DELTA_B301}=       GG_B301/CB008490_GG_B301_delta.json

*** Test Cases ***
CB008490-P_BA01_B10_B4_PCMD_Cell_Trace_Records_And_MDT_Measurements_During_PSCellAddition_Transition
    [Setup]    Run Keywords    Setup    ${IPHY_P}    ${SCFC_SN_P}    ${SCFC_MN_P}    ${EGATE_P}
    ...    AND    Start Default Syslog For Enb And Iphy    ${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    cmd=uec_param id=1 scg_ul_dist_percent=50
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Send Ue Measurement Nr For Specific Event    1    1    A4    phycell_id=52    nrsrp_nr=60
    ...    gnss_TOD_msec_r16=123456 locationCoordinate_r16=0102030405060708090A0B0C0D0E0F1112
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 mbps=160 dir=dl trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 mbps=160 dir=dl trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 mbps=160 dir=dl trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 mbps=160 dir=dl trf_id=4
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=4
    Sleep    5s
    Stop Default Syslog For Enb And Iphy
    Verify Tcpdump Log    packet_filter=nr-rrc.c1 == 0 && nr-rrc.physCellId == 52 && nr-rrc.gnss_TOD_msec_r16 == 12:34:56
    Verify Syslog For Correct Prints    ${OUTPUT_DIR}/${TEST_NAME}    ${SYSLOG_MDT_LOG}

CB008490_GE_EC2_Unsuccessful_NGRANNodeConfUpd_due_to_NRDCSN_cell_addition_release_of_the_last_Xnlink
    [Setup]    Setup    ${IPHY_GE}    ${SCFC_SN_GE}    ${SCFC_MN_GE}    ${EGATE_GE}    ${True}
    Attach Ue With SNodeAddition Through Peer Gnb    ue=3
    Attach Ue With SNodeAddition Through Peer Gnb    ue=4
    Execute Egate Command    cmd=gnb_xn_ngran_conf_update_param id=4 action=drop nth=1 action=drop nth=2 action=drop nth=3 action=force_failure nth=4
    ${delta}=    Get Commissioning File For Enb Release Name    ${DELTA_GE}
    Send Delta Commissioning With Fixer    ${delta}    ${REMOTE_HOST_1_IP}
    Sleep    30s    Wait for NGRANNodeConfigurationUpdate resends and alarms appear
    Verify Ngap Messages    packet_filter=xnap.procedureCode == 7    number_of_messages=4
    Verify Alarms    10.0.1.3

CB008490-GI_B101_B1_3_Main_Slices_Operational_State_Changed_To_Disabled_When_Relevant_NR-DC-SN_Cell_Goes_Down
    [Setup]    Setup    ${IPHY_GI}    ${SCFC_SN_GI}    ${SCFC_MN_GI}    ${EGATE_GI}
    Verify Snssai Operational Status    ${REMOTE_HOST_1_IP}    before
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 gw=1 ue=1 nwslice=1
    Sleep    1s
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A4 phycell_id=52 nrsrp_nr=60
    Attach Ue    ue_id=2
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 gw=2 ue=2 nwslice=6
    Sleep    2s
    Execute Egate Command    cmd=ue_measurement_send_nr id=2 meas_id=1 event=A4 phycell_id=53 nrsrp_nr=60
    Perform Parameter Commissioning
    ...    parameter=administrativeState
    ...    value=Locked
    ...    dist_name=MRBTS-3/NRBTS-3/NRCELL-6
    ...    skip_parameter_relation_errors=${False}
    ...    remote_host=${REMOTE_HOST_1_IP}
    Verify Snssai Operational Status    ${REMOTE_HOST_1_IP}    after
    Verify Partial Reset

CB008490-GG_B301_Dynamic_Addition_Of_NR-DC-SN_Cells_With_Multiple_Slices_And_Tas_Without_RAN_Sharing_Enabled
    [Tags]  QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Setup    ${IPHY_GG301}    ${SCFC_SN_GG301}    ${SCFC_MN_GG301}    ${EGATE_GG301}
    ${TEST_QC_ID}=  Set Test ID
    Set Tags    ${TEST_QC_ID}
    Unlock Xn Link
    Dynamic Addition Of NR-DC-SN Cell

CB012328-X_B01_ALT1_ViNR_Call_Setup_while_UE_is_in_NR-DC
    [Setup]    Setup    ${IPHY_P}    ${SCFC_SN_P}    ${SCFC_MN_X}    ${EGATE_P}
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Send Ue Measurement Nr For Specific Event    1    1    A4    phycell_id=52    nrsrp_nr=60
    Sleep    3s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2,3
    Sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2,3
    Sleep    10s
    Send Ue Measurement Nr For Specific Event    1    2    A4    phycell_id=52    nrsrp_nr=60
    Sleep    5s
    Verify NR-DC release during ViNR

*** Keywords ***
Attach Ue With SNodeAddition Through Peer Gnb
    [Arguments]    ${ue}
    Attach Ue    ue_id=${ue}
    Establish PDU Session    ue_id=${ue}    pdu_id=${ue}    gw_id=${ue}
    ${cmd}=    Catenate    gnb_nrdc_param id=4 enable_dl_data_forwarding=off t_reordering=100 serving_cell_index_range_scg_nrdc=1:31
    ...                    direct_bearer_sn_addition_error=off include_candidate_cell_info_list_mn=on
    Execute Egate Command    cmd=${cmd}
    ${cmd}=    Catenate    gnb_nrdc_param id=4 include_config_restrict_info=on include_reestablish_pdcp=on  include_data_fwd_info_from_source=on
    ...                    ue_sec_algo_first_bit_reserved=on allowed_bc_list_mrdc=1:1
    Execute Egate Command    cmd=${cmd}
    Execute Egate Command    cmd=gnb_nrdc_param id=4 include_cgi_in_candidate_cell_info=off
    Execute Egate Command    cmd=ue_meas_param id=${ue} nr_neigh_cell=non_cfgd:53 nr_rsrp=127
    Execute Egate Command    cmd=gnb_ue_nrdc_start ue=${ue} target_gnb=3 target_cells=3 target_pdu_id_list=${ue}
    Sleep    2s

Verify Partial Reset
      Verify Tcpdump Log      ${ResetRequest}    timeout=120
      Verify Tcpdump Log      ${NgReset}
      Verify Tcpdump Log      ${NgRanConfigurationWithCorrectTa}

Unlock Xn Link
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B101}
    Send Delta Commissioning With Fixer    ${DELTA}
    Verify XNAP Messages For GG_B101 Scenario

Dynamic Addition Of NR-DC-SN Cell
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B301}
    Send Delta Commissioning With Fixer    ${DELTA}    ${REMOTE_HOST_1_IP}
    Verify XNAP Messages For GG_B301 Scenario

Verify XNAP Messages For GG_B101 Scenario
      Verify Tcpdump Log      ${XNAP_SETUP_REQUEST_GG_B101}
      Verify Tcpdump Log      ${XNAP_SETUP_RESPONSE_GG_B101}
      Verify Tcpdump Log      ${F1AP_GNBDU_CONF_UPD_FOR_CELL1_GG_B101}
      Verify Tcpdump Log      ${F1AP_GNBDU_CONF_UPD_FOR_CELL2_GG_B101}

Verify XNAP Messages For GG_B301 Scenario
      Verify Tcpdump Log      ${XNAP_NG_RAN_CONF_UPD_GG_B301}
      Verify Tcpdump Log      ${XNAP_NG_RAN_CONF_UPD_ACK_GG_B301}


Setup
    [Arguments]    ${IPHY}    ${SCFC_SN}    ${SCFC_MN}    ${EGATE}    ${xn_link}=${False}
    Update And Put Iphy Xml         input_filepath=${IPHY}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_SN}    remote_host=${REMOTE_HOST_1_IP}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_MN}
    Enable Tshark Verification    logs_path=${OUTPUT_DIR}/${TEST_NAME}/${TSHARK_SUBDIR}
    Reach Onair Without Confirmation    lua_cfg=${EGATE}    remote_hosts=${REMOTE_HOSTS}    align_tac_values=${false}
    IF    ${xn_link}
         Establish Xn Link    source_gnb_id=4    target_gnb_id=3
    END

Environment Preaparation
    Enable C-Plane Debug Logs       with_reboot=${false}
    Start Vm Ethernet Interface    if_name=eth3:GNB_4    ip_with_mask=10.0.2.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB4_XN    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:simgNB    ip_with_mask=10.0.1.6/24
    ${scf_mn}    Get Commissioning File For Enb Release Name    ${SCFC_MN_P}
    ${scf_sn}    Get Commissioning File For Enb Release Name    ${SCFC_SN_P}
    Set Correct Trace Collector Ip In Scf    ${scf_mn}    ${scf_sn}
    Setup Dcap Controller

Verify NR-DC release during ViNR
    FOR    ${msg}    IN    @{CB0012328_X}
        ${length}=    Get Length    ${msg}
        IF    ${length} != 2    Verify Uu Messages    packet_filter=${msg}
        ...    ELSE    Verify Uu Messages    packet_filter=${msg}[0]    number_of_messages=${msg}[1]
    END
