*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LOOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC    CONFIGURED
...           NoResUsage    PY311

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com
...              :testsuite description: This test case aims to verify the establishment of NR FR1 mixed Intra- and Inter-Band Contiguous CA
...              for a NR CA configuration introduced in 3GPP TS 38.101-1 V19.0.0 (2024-12), Table 5.5A.2-1 and Table 5.5A.2-2.

Resource    resources/CB013513_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...             AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...             AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy.xml
...             AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB013513.json
...             AND             Trigger Site Reset
...             AND             Check Radios Availability
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_n41_n66.cfg
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords  Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND           Roll Delta Back
...                             initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                             delta_scf_filename=delta_CB013513.json
...               AND           Stop Default Processes And Gather Logs And Compress Logs
...               AND           Trigger Site Reset

*** Test Cases ***
CB013513_A_B2_Mixed_Intra_Band_Contiguous_And_Non_Contiguous_CA
    [Documentation]    UE#4 supports the following NR FR1 CA configuration: CA_n66(3A) with BCS 4
    ...                UE#1 supports the following NR FR1 CA configuration: CA_n41(A-C) with BCS 4

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE  ue_id=4
    Set Internal Traffic Type To UE    ue_id=4    pdu_id=4
    Establish PDU Session    ue_id=4    pdu_id=4    gw_id=4
    Start Data Traffic    ues=4    direction=both    pdu=4    throughput=100Mbps    traffic_id=4
    Start Data Traffic    ues=4    direction=dl    pdu=4    throughput=100Mbps    traffic_id=5
    Start Data Traffic    ues=4    direction=dl    pdu=4    throughput=100Mbps    traffic_id=6
    Send UE Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=4    pcell_id=4    scellTechnology=FDD    srsrp_nr=127    srsrq_nr=127    ssinr_nr=127
    Check Traffic On Every Scell    ue_id=4    scells_amount=2
    Send UE Measurement Nr Event A2 Scell Release With Aligned Meas Id
    ...    ue_id=4    scell_id=5    scell=1    scell_rsrp=1   scell_sinr=1   scell_rsrq=1
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    Deregister UE   ue_id=4

    Attach UE    ue_id=1
    Set Internal Traffic Type To UE    ue_id=1    pdu_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic    ues=1    direction=both    pdu=1    throughput=100Mbps    traffic_id=1
    Start Data Traffic    ues=1    direction=dl    pdu=1    throughput=100Mbps    traffic_id=2
    Start Data Traffic    ues=1    direction=dl    pdu=1    throughput=100Mbps    traffic_id=3
    Send UE Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=1    pcell_id=1    scellTechnology=TDD    srsrp_nr=127    srsrq_nr=127    ssinr_nr=127
    ...    pass_regexp=${SCELL_ACTIVATION_REGEXP}
    Check Traffic On Every Scell    ue_id=1    scells_amount=2
    Send UE Measurement Nr Event A2 Scell Release With Aligned Meas Id
    ...    ue_id=1    scell_id=2    scell=1    scell_rsrp=1   scell_sinr=1   scell_rsrq=1
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    Deregister UE    ue_id=1

    [Teardown]    Run Keywords   Add Scout External Execution ID To Reporting Portal
    ...           AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

