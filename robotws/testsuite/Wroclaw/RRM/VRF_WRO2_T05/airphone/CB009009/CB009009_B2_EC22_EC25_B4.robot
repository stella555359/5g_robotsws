*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    PY311
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska, Piotr Pinderak
...              :contacts: katarzyna.wisniewska@nokia.com, piotr.pinderak@nokia.com

Resource     CB009009_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Multiple Vms Interfaces
...            AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...            AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy.xml
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_inter_freq.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB009009_inter_freq.lua
...            AND             Wait For Timer X2AP interface up
...			   AND			   Attach Ue To Enb    ue_id=11
...            AND             Start Gnb Addition Procedure    ue=11    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
...                            pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
...            AND             Send UE Measurement NR Event A2 Handover With Aligned Meas ID    ue_id=11    pcell_id=1    cell_type=NSA    srsrp_nr=30
...			   AND			   Detach Ue    ue_id=11
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Multiple Vms Interfaces
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_CB009009_inter_freq.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Trigger Site Reset

*** Test Cases ***
CB009009_A_B2_2_Intra_NR_Inter_Freq_ANR_NSA_Dedicated_DRX_Profile_Setup_In_UE_To_Allow_Intra_NR_NRCGI_Meas_Reporting_MeasGap_Released_SRB3
    [Documentation]    This Test Case verifies - if gNB is able to setup Dedicated DRX profile after Measurement Gap release.
    ...                For easier recognition, the default drx has the drx-retransmissionTimer set to 16 slots and the dedicated one to 0.
    ...                Inter-Freq handover with events A2 and then A5 finished successfully. SRB3 is enabled in scf file.
    ...                Object NRREL should be created after ANR procedure.
    ...                5G_RAN_USR_RRM_15991

    [Setup]            Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}

    Turn On DRX And Measurement Gap    ue_id=12
    Attach Ue To Enb    			   ue_id=12
    Start Gnb Addition Procedure    ue=12    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Send UE Measurement NR Event A2 Handover With Aligned Meas ID    ue_id=12    pcell_id=1    cell_type=NSA    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send UE Measurement NR Event A5 With Aligned Meas ID    ue_id=12    carrier_freq=637152    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Verify Ngap Messages             packet_filter=${MEAS_GAP_RELEASE}
    Verify Ngap Messages             packet_filter=${DEDICATED_DRX_SETUP}
    Verify Existing NRREL

   [Teardown]    Run Keywords       Detach Ue    ue_id=12
    ...          AND                Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRREL.json
    ...          AND                Add Scout External Execution ID To Reporting Portal
    ...          AND                Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_A_B2_9_Intra_NR_Inter_Freq_ANR_NSA_Dedicated_DRX_Profile_Setup_In_UE_To_Allow_Intra_NR_NR_CGI_No_Valid_DRX_Profile
    [Documentation]    This Test Case verifies gNB behaviour when valid Dedicated DRX profile is not configured.
    ...                gNB should discard A5 mesurement report after trying to setup Dedicated DRX profile.
    ...                Dedicated DRX with incorrect value for FR1 configuration - drxControl:intraNRFR2
    ...                5G_RAN_USR_RRM_15991; Alternate scenario 7

    [Setup]       Run Keywords     Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    ...           AND              Find Scfc and Send Delta Commissioning    scfc_filename=delta_invalid_DRX_config.json

    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=13
    Attach Ue To Enb                 ue_id=13
    Start Gnb Addition Procedure     ue=13    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Send UE Measurement NR Event A2 Handover With Aligned Meas ID    ue_id=13    pcell_id=1    cell_type=NSA    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send UE Measurement NR Event A5 With Aligned Meas ID    ue_id=13    carrier_freq=637152    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    Verify Ngap Messages             packet_filter=${MEAS_GAP_SETUP}
    Verify Ngap Messages             packet_filter=${MEAS_GAP_RELEASE}    number_of_messages=0

    [Teardown]    Run Keywords      Detach Ue    ue_id=13
    ...           AND               Find Scfc and Send Delta Commissioning    scfc_filename=delta_invalid_DRX_config_revert.json
    ...           AND               Add Scout External Execution ID To Reporting Portal
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_A_EC22_2_Intra_NR_Inter_Frequency_ANR_NSA_Failure_Default_DRX_Release_No_UE_Response_On_RRC_Reconfiguration_MeNB_ScgFailureInfo_Without_SRB3
    [Documentation]    This Test Case verifies the gNB behaviour, when UE sends SCG failure information message to MeNB and MeNB sends
    ...                SgNB modification request with CG-ConfigInfo.scgFailureInfo IE to SgNB.
    ...                Intra frequency Handover is not started.
    ...                To trigger this test case, we use the egate command to send scg_failure message.
    ...                Measurement gap is configured with MeNB coordination. SRB3 is disabled in scf file.
    ...                5G_RAN_USR_RRM_16101

    [Setup]    Run Keywords     Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    ...        AND              Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_SRB3_Disabled.json

    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=14
    Attach Ue To Enb                 ue_id=14
    Start Gnb Addition Procedure     ue=14    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Set Ue RRC Reconf Param          ue_id=14    contains=report_cgi    value=scg_failure
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id    ue_id=14    pcell_id=1    cell_type=NSA    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=14    carrier_freq=637152    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    Verify Tcpdump Log               packet_filter=${X2AP_SGNB_MODIFICATION_REQUIRED} && ${MEAS_CONFIG_SN_EMPTY}
    ...                              number_of_messages=2    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${MEAS_GAP_RELEASE}
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQ_MEAS_GAP_CONFIG}
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}    number_of_messages=5    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE_MEAS_GAP_CONFIG}    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${X2AP_SGNB_MODIFICATION_CONFIRM_RRC_RECONFIG_COMPLETE}
    ...                              number_of_messages=2    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_REPORT_CGI}
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_DRX_SETUP}         relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST_SCF_FAILURE_INFO}

    [Teardown]    Run Keywords      Detach Ue    ue_id=14
    ...           AND               Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_SRB3_Enabled.json
    ...           AND               Add Scout External Execution ID To Reporting Portal
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_A_EC25_1_Intra_NR_Inter_Freq_ANR_NSA_Dedicated_ANR_DRX_Profile_Setup_In_UE_PCI_Resolution_Failed_T321_Timer_Without_SRB3
    [Documentation]    This Test Case verifies gNB behaviour when Measurement Report is not delivered in time and NRCGI timer expires.
    ...                After timeout gNB is obligated to rollback to default configuration - in this case it
    ...                requires release of dedicated DRX and setup of measurement gap.
    ...                To trigger this test case, we use the egate command to do not send NRCGI report. SRB3 is disabled in scf file.
    ...                5G_RAN_USR_RRM_16109

    [Setup]    Run Keywords     Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    ...        AND              Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_SRB3_Disabled.json

    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=15
    Attach Ue To Enb                 ue_id=15
    Start Gnb Addition Procedure     ue=15    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Set Ue RRC Reconf Param          ue_id=15    contains=report_cgi    value=donot_send_NRCGI
    Send UE Measurement NR Event A2 Handover With Aligned Meas ID    ue_id=15    pcell_id=1    cell_type=NSA    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send UE Measurement NR Event A5 With Aligned Meas ID    ue_id=15    carrier_freq=637152    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=UE15: Hit on RRC Reconfiguration Rule presence=report_cgi delay=0 action=donot_send_NRCGI
    Sleep    5s    reason=Waiting for A5 measurement procedure to complete.
    Send UE Measurement NR Event A2 Handover With Aligned Meas ID    ue_id=15    pcell_id=1    srsrp_nr=30    cell_type=NSA
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Verify Ngap Messages             packet_filter=${DEDICATED_DRX_SETUP}
    Verify Ngap Messages             packet_filter=${DRX_RELEASE}
    Verify Ngap Messages             packet_filter=${MEAS_GAP_SETUP}    number_of_messages=2
    Verify Ngap Messages             packet_filter=${MEAS_GAP_RELEASE}
    Verify Ngap Messages             packet_filter=${NR_RRC_NO_MEASUREMENT_REPORT_WITH_NRCGI}    number_of_messages=0

    [Teardown]    Run Keywords      Detach Ue    ue_id=15
    ...           AND               Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_SRB3_Enabled.json
    ...           AND               Add Scout External Execution ID To Reporting Portal
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_B_B4_2_IntraNR_InterFrequency_ANR_NSA_Disable_UL_Proactive_Grant_Scheduling_For_The_UE_To_Allow_NRCGI_Reporting_Without_SRB3
    [Documentation]    This Test Case verifies that during the setup of the dedicated DRX (NR_CGI reporting),
    ...                the parameter skipUplinkTxDynamic has the value False.
    ...                Inter-Freq handover with events A2 and then A5 finished successfully. SRB3 is disabled in scf file.
    ...                NRREL object should be created after ANR procedure.
    ...                For easier recognition, the default drx has the drx-retransmissionTimer set to 16 slots and the dedicated one to 0.
    ...                5G_RAN_USR_RRM_15991;5G_RAN_USR_RRM_16138

    [Setup]    Run Keywords    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_skipULTXDynamic.json

    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=16
    Attach Ue To Enb                 ue_id=16
    Start Gnb Addition Procedure     ue=16    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=${SUCCESSFUL_GNB_ADD}
    Send UE Measurement NR Event A2 Handover With Aligned Meas ID    ue_id=16    pcell_id=1    cell_type=NSA    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send UE Measurement NR Event A5 With Aligned Meas ID    ue_id=16    carrier_freq=637152    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Verify Ngap Messages             packet_filter=${DEDICATED_DRX_SETUP} && ${SKIP_UL_TX_DYNAMIC}
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && ${SKIP_UL_TX_DYNAMIC}    number_of_messages=2
    Verify Existing NRREL

    [Teardown]    Run Keywords    Detach Ue    ue_id=16
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRREL.json
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_skipULTXDynamic_revert.json
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
