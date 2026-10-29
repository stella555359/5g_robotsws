*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py


Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             With Simulated Gnb    ip=10.0.1.4
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulated Network Interface    name=eth3:GNB3_NG_ADDR    ip=10.0.1.3/24
...            AND             With Simulated Network Interface    name=eth3:GNB3_XN_ADDR    ip=10.0.1.4/24
...            AND             With Simulated Network Interface    name=eth3:AMF_NG_ADDR    ip=10.0.1.1/24
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_BB2.cfg
${scfc}=              full_scfc_CB006733_B_B2.xml
${GNB_ID}=            2
${simgNB_ID}=         3
${PCELL_ID}=          1  #Cell 1 on simulated gNB
${TARGET_PHYSCELL_ID}=    54  #Cell 4 on real gNB
${UE_ID}=             4
${PDU_4}=             4
${GW_ID_4}=           4
${COUNTER_ID}=    M55118C00030
${COUNTER_NAME}=    A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4


*** Test Cases ***
CB006733-B_B2_Activate_A4_measurements_for_FR1_CA_SCell_Addition_after_inter-gNB_HO_via_XN_completion_with_the_sufficient_NR-Capability_for_CA_setup
    UE Register to simulated gNB And Establish PDU Session    ue_id=${UE_ID}    simgNB_id=${simgNB_ID}    cell_id=${PCELL_ID}
    Perform Inter-gNB HO via XN from sim gNB to real gNB    ue_id=${UE_ID}    gnb_id=${GNB_ID}    phycell_id=${TARGET_PHYSCELL_ID}
    Verify that UEContextModificationRequest_2 of 3 contains measConfig with A4 configuration after HO via XN for gNB2
    Verify that UEContextModificationResponse_2 of 3 contains measGapConfig for gNB2
    Verify if UE4 RRCReconfiguration contains A4 configuration after Inter-gNB HO via XN
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}
