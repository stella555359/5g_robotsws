*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    QC_350561    QCD_MN_RAN    QCP_RAN_ET

Documentation    :copyright: Nokia
...              :authors: Vira Solomashenko
...              :contact: vira.solomashenko@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB005934_keywords.robot
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_testline_management
Library      taf.ul.ettf.setups
Library      ta5g_ue_mobility
Variables    ta5g_global_var
Variables    CB005934_messaging_filters.py
Variables    logging_policy.py

Suite Setup    Run Keywords   With Retry Context    3
...                           Update And Put Iphy Xml    input_filepath=${iphy}
...            AND            With Gnb Configuration    commissioning=${scfc}
...            AND            Wait For Testline Icmp Echo Replies And Ssh Services
...            AND            Start Default Logging
...            AND            With Simulator Configuration    config=${basic_setup}
...            AND            Wait For Next Full Pm Interval

*** Variables ***
${REBOOT}=    ${False}
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY

${iphy}=    ${CURDIR}/config/iphy_AP_LOO_AHFII_AHFIB_AEQE_AHFII_gnb_ABIO_4FDD_2TDD.xml
${scfc}=    SCF_A_B10.xml
${basic_setup}=    ${CURDIR}/config/wts_4cells_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.cfg

${ue_id}=    1
${pcell_id}=    1
${gnb_id}=    2
${pdu_id}=    1
${gw_id}=    1
${a1_meas_id}=    1
${a1_rsrp}=    75
${a1_rsrp_scell_change}=    90
${scell_change_a1_meas_id}=    5
${local_moid}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

${Verification_A1_measurement}=
...  f1ap && nr-rrc.rrcReconfiguration_element &&
...  nr-rrc.measObjectToAddModList == 3 &&
...  nr-rrc.reportConfigToAddModList == 2 &&
...  nr-rrc.measIdToAddModList == 4 &&
...  nr-rrc.reportConfigToRemoveList == 1 &&
...  nr-rrc.measIdToRemoveList == 1
${rrcReconfigurationComplete}=
...  f1ap &&
...  nr-rrc.rrcReconfigurationComplete_element &&
...  nr-rrc.rrc_TransactionIdentifier == 3
${ULRRCMessageTransfer}=
...  f1ap &&
...  nr-rrc.measurementReport_element &&
...  nr-rrc.measId == 5 &&
...  nr-rrc.physCellId == 51
${UEContextModificationRequest}=
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.SCell_ToBeRemoved_List == 3 &&
...  f1ap.SCell_ToBeSetupMod_List == 1
${UEContextModificationResponse}=
...  f1ap.UEContextModificationResponse_element &&
...  nr-rrc.maxPayloadSize == 4 &&
...  nr-rrc.resourceList == 2 &&
...  nr-rrc.sCellToAddModList == 1 &&
...  nr-rrc.sCellToReleaseList == 3
${DLRRCMessageTransfer}=
...  f1ap &&
...  nr-rrc.rrcReconfiguration_element &&
...  nr-rrc.measIdToRemoveList == 4 &&
...  nr-rrc.MeasId == 5 &&
...  nr-rrc.measObjectToRemoveList == 3 &&
...  nr-rrc.reportConfigToRemoveList == 2
${RRCReconfigurationCompleteIndicator}=
...  sctp.data_ssn == 16 &&
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.RRCReconfigurationCompleteIndicator == 0
${GNB_DUConfigurationQuery}=
...  sctp.data_ssn == 17 &&
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.GNB_DUConfigurationQuery == 0

*** Test Cases ***
CB005934-SR-A-B10_Single_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_4CC_F-F-F-F_CA_to_2CC_F-T_CA
    Attach UE And Verify Establishing PDU Session    ue_id=${ue_id}    cell_id=${pcell_id}
    ...    gnb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger A1 Measurement    ue_id=${ue_id}     meas_id=${a1_meas_id}    srsrp_nr=${a1_rsrp}
    Verify Message After A1 Measurement Triggered    expectation=${Verification_A1_measurement}
    Trigger A1 Measurement    ue_id=${ue_id}     meas_id=${scell_change_a1_meas_id}    srsrp_nr=${a1_rsrp_scell_change}
    Verify Message After A1 Measurement Triggered    expectation=${rrcReconfigurationComplete}
    Verify Message After A1 Measurement Triggered    expectation=${ULRRCMessageTransfer}
    Verify Message After A1 Measurement Triggered    expectation=${UEContextModificationRequest}
    Verify Message After A1 Measurement Triggered    expectation=${UEContextModificationResponse}
    Verify Message After A1 Measurement Triggered    expectation=${DLRRCMessageTransfer}
    Verify Message After A1 Measurement Triggered    expectation=${RRCReconfigurationCompleteIndicator}
    Verify Message After A1 Measurement Triggered    expectation=${GNB_DUConfigurationQuery}
    Verify Pm Counters After SCell Change    local_moid=${local_moid}
    [Teardown]    Release UE    ue_id=${ue_id}    pdu_id=${pdu_id}
