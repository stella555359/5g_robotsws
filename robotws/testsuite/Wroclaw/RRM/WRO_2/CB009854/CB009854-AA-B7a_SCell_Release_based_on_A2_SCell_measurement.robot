*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Krystian Kozlowski, Vira Solomashenko
...              :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB009854_keywords.robot
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_testline_management
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_9854.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

*** Variables ***
${REBOOT}=    ${False}
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${scfc}=    CB009854_AAB7.xml
${BASIC_SETUP}=    ${CURDIR}/config/wts_9854_basic.cfg
${UE_ID}=     3
${PCELL_ID}=    3
${PDU_PCELL_1}=    3
${GW_ID}=    3
${GNB_ID}=    2
${A1_meas_id}=    1
${A2_meas_id}=    2
${Verification_A1_measurement}=
...    nr-rrc.measId == 1 &&
...    nr-rrc.physCellId == 53
${UeContextModReqAfterA2}=
...   f1ap.UEContextModificationRequest_element &&
...   f1ap.SCell_ToBeRemoved_Item_element &&
...   f1ap.nRCellIdentity == 00:00:04:00:10
${UeContextModResAfterA2}=
...   f1ap.UEContextModificationResponse_element &&
...   nr-rrc.resourceSetToAddModList == 2 &&
...   nr-rrc.pucch_ResourceSetId == 1 &&
...   nr-rrc.maxPayloadSize == 8 &&
...   nr-rrc.resourceToReleaseList == 1 &&
...   nr-rrc.PUCCH_ResourceId == 19 &&
...   nr-rrc.csi_ReportConfigToReleaseList == 1 &&
...   nr-rrc.CSI_ReportConfigId == 13 &&
...   nr-rrc.sCellToReleaseList == 1 &&
...   nr-rrc.SCellIndex == 1
${rrcReconfiguration}=
...   nr-rrc.measIdToRemoveList == 1 &&
...   nr-rrc.MeasId == 2
${A2_cmd}=
...  id=${UE_ID} meas_id=${A2_meas_id} event=A2 srsrp_nr=90 srsrq_nr=0
...  scell=1 scell_rsrp=5
...  scell=2 scell_rsrp=58
...  scell=3 scell_rsrp=57
...  scell=4 scell_rsrp=56

*** Test Cases ***
CB009854-AA-B7a_SCell_Release_based_on_A2_SCell_measurement

    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Trigger A1 Measurement    ue_id=${UE_ID}     meas_id=${A1_meas_id}
    Verify A1 Measurement    Verify_A1_Measurement=${Verification_A1_measurement}
    Start Data Traffic
    Wait for Traffic to Stabilize
    Verify DL Traffic Is Scheduled On All Cells 5CC
    Verify UL Traffic Is Scheduled On All Cells 2CC
    Trigger A2 Measurement    A2_cmd=${A2_cmd}
    Verify Message    expectation=${UeContextModReqAfterA2}
    Verify Message    expectation=${UeContextModResAfterA2}
    Verify Message    expectation=${rrcReconfiguration}





