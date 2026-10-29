*** Settings ***
Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]    TOOLS_PROFILE_5G_TTI_NOKIA
...           NoResUsage    PY311

Documentation    :copyright: Nokia
...              :authors: Pawel Sniady
...              :contact: pawel.sniady@nokia.com
...              :topology: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...              :testsuite description: This testsuite outlines the behavior of the target gNB during an incoming XN-based
...              inter-gNB handover when a UE connected to the source gNB is on an NR-DC call. As Nokia gNB does not support
...              incoming handovers for NR-DC calls, it releases NR-DC by setting the mrdc-SecondaryCellGroupConfig IE to release
...              in the Handover Request Acknowledge upon the reception of sourceSCG-Configured IE
...              in the Handover Request. The handover to the target cell is completed successfully following legacy procedures,
...              but NR-DC is released at the UE.

Resource    resources/CB014817_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs    remote_host=${REMOTE_HOST_1_IP}
...             AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy_init.xml
...             AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/MN_SCF_init.xml
...             AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/SN_SCF_init.xml    remote_host=${REMOTE_HOST_1_IP}
...             AND             Copy File    source=${CURDIR}/config/preferences    destination=${WS_PERSONAL_CFG_PATH}
...             AND             Add Custom VM IP Configuration
...             AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy.xml
...             AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=MN_SCF.xml
...             AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=SN_SCF.xml   remote_host=${REMOTE_HOST_1_IP}
...             AND             Start WTS And Store Config File In Logs Dir    lua_cfg=${CURDIR}/config/egate_config_xnho.cfg
...             AND             Check Radios Availability    remote_hosts=${REMOTE_HOSTS}
...             AND             Wait For All Cells To Be Enabled
...             AND             Setup X2 Link    initiator_device=3    complementary_device=1
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown  Run Keywords    Update And Put Iphy Xml    input_filepath=${OUTPUT_DIR}/iphy_init.xml
...             AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/MN_SCF_init.xml
...             AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/SN_SCF_init.xml    remote_host=${REMOTE_HOST_1_IP}
...             AND             Wait For Testline Icmp Echo Replies And Ssh Services
...             AND             Stop Default Processes And Gather Logs And Compress Logs
...             AND             Delete Custom VM IP Configuration

*** Test Cases ***
CB014817_A_B2_NRDC_Release_During_Incoming_Xn_Based_Handover_SourceSCG_Configured_IE
    [Documentation]    This test case verifies that during an Xn-based inter-gNB handover, the T-gNB releases NR-DC by setting
    ...                mrdc-SecondaryCellGroupConfig to release upon receiving the sourceSCG-Configured IE, completing the handover successfully.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    remote_host=${REMOTE_HOST_1_IP}

    Change UE Location    ue_id=1    dst_enb=1    dst_cell=2
    Attach UE    ue_id=1
    Set Internal Traffic Type For UE    ue=1    pdu=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic    ues=1    direction=both    pdu=1    throughput=100Mbps    traffic_id=1
    Start Data Traffic    ues=1    direction=dl    pdu=1    throughput=100Mbps    traffic_id=2
    Start Data Traffic    ues=1    direction=dl    pdu=1    throughput=100Mbps    traffic_id=3
    Send UE Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=1    pcell_id=2    srsrp_nr=20    pass_regexp=message c1 : rrcReconfigurationComplete
    Send Custom UE Measurement Nr    id=1    meas_id=3     event=A3    srsrp_nr=19    srsrq_nr=10    phycell_id=291    nrsrp_nr=85    nrsrq_nr=31
    ...    pass_regexp=XN Handover Successfully completed
    Set SCG Active During Handover    ue_id=1    gnb_id=4
    Send Custom UE Measurement Nr    id=1    meas_id=41    event=A2    srsrp_nr=7
    ...   pass_regexp=message c1 : rrcReconfigurationComplete
    Send Custom UE Measurement Nr    id=1    meas_id=3     event=A3    srsrp_nr=19    srsrq_nr=10    phycell_id=129    nrsrp_nr=85    nrsrq_nr=31
    ...   pass_regexp=mrdc-SecondaryCellGroupConfig release
    Start Data Traffic    ues=1    direction=dl    pdu=1    throughput=100Mbps    traffic_id=4
    Set Uplink Data Flow Distribution In SCG    uec_id=1    percent=50
    Wait For Event A4 And Send UE Measurement Nr With Aligned Meas Id    ue_id=1    carrier_freq=2017243    phycell_id=154    nrsrp_nr=80
    ...   pass_regexp=reported successful RA
    # Check Traffic On MCG    ue_id=1           # PR853633
    # Check Traffic On SCG    ue_id=1    cc=4   # PR853633
    Verify Message Sequence In CB014817_A_B2

    [Teardown]    Run Keywords   Stop Data Traffic    ues=1
    ...           AND            Release PDU Session    ue_id=1    pdu_id=1
    ...           AND            Deregister UE   ue_id=1
    ...           AND            Add Scout External Execution ID To Reporting Portal
    ...           AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
