*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB005934_keywords.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${basic_setup}
...            AND             Wait For Next Full Pm Interval

*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_AP_LOO_AHFII_AHFIB_AEQE_AHFII_gnb_ABIO_4FDD_2TDD.xml
${basic_setup}=       ${CURDIR}/config/wts_5934_A_B5.cfg
${scfc}=    CB005934_A_B5_interaction_with_5CC.xml

${ue_id}=    1
${a1_meas_id}=    1
${UeContextModReqAfterA1}=
...   f1ap.SCell_ToBeSetupMod_List==3 &&
...   f1ap.nRCellIdentity==00:00:04:00:20 &&
...   f1ap.nRCellIdentity==00:00:04:00:30 &&
...   f1ap.nRCellIdentity==00:00:04:00:40

${RRCReconfigurationAfterA1}=
...   nr-rrc.measObjectToAddModList==3 &&
...   nr-rrc.freqBandIndicatorNR==25 &&
...   nr-rrc.freqBandIndicatorNR==66 &&
...   nr-rrc.freqBandIndicatorNR==71 &&
...   nr-rrc.measIdToRemoveList==1 &&
...   nr-rrc.MeasId==1 &&
...   nr-rrc.sCellToAddModList==3 &&
...   nr-rrc.physCellId==52 &&
...   nr-rrc.physCellId==53 &&
...   nr-rrc.physCellId==54

${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

*** Test Cases ***
CB005934-SR-A-B5_Single_UE_Call-A1_event_measurement_based_SCell_addition_for_4CC_DL_CA_with_FDD_PCell_and_3_FDD_SCells_interaction_with_5CC_CA
    Register UE To gNB    ue_id=${ue_id}
    Trigger A1 Measurement    ue_id=${ue_id}     meas_id=${a1_meas_id}
    Verify 3FDD SCells Addition After A1 Event Trigger    ${UeContextModReqAfterA1}
    Verify RRC A1 Measurement Removal And SCell Addition    ${RRCReconfigurationAfterA1}
    Start Data Traffic
    Verify Pm Counters For 5CC Configuration   local_moid=${LOCAL_MOID}
    Deregister Ue    ue_id=1


