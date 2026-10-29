*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Lukasz Klimowicz
...              :contact: lukasz.klimowicz@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../../../WRO_2/keywords/messaging.robot
Resource     ../../../WRO_2/keywords/traffic.robot
Resource     ../../../WRO_2/keywords/L3_Call.robot
Resource     ../../../WRO_2/keywords/tshark_verifying.robot
Resource     ../../resources/common_airphone_keywords.robot
Resource     ../../resources/common_keywords.robot
Resource     ../../resources/ute_report.robot
Resource     variables.robot
Resource     keywords.robot
Resource     ta_messaging/flow.robot
Library      ta5g_tshark
Library      ta_messaging

Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${KEEP_ALIVE}=    ${True}
${LOGGING_POLICY}=    SYSLOGS_PER_TEST_CASE
${BASIC_SETUP}=       ${CURDIR}/config/wts_CB013438_TC_07.cfg
${scfc}=              TC_07_ARP_scfc.xml
${IPHY_SETUP}=        ${CURDIR}/config/iphy_CB013438.xml


*** Test Cases ***
TC07_CB013438-A_A4_Online_modification_of_scheduling_weight_with_extended_range_between_1_to_1000_and_its_interaction_with_ARP
    [Setup]    Run Keywords        Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND             Update And Put Iphy Xml    input_filepath=${IPHY_SETUP}
    ...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

    Add Scout Data Info To Testcase

    Attach UE And Establish PDU Session    ue_id=5   cell_id=5    enb_id=2    pdu_id=5    gw_id=1
    Attach UE And Establish PDU Session    ue_id=50   cell_id=5    enb_id=2    pdu_id=5    gw_id=5
    Modify PDU By Adding Additional DRB    ue_id=5    pdu_id=5    qos_flows=2,3
    Modify PDU By Adding Additional DRB    ue_id=50    pdu_id=5    qos_flows=5,6
    Start Data Traffic    ue_id=5   pdu_id=5    qfi_id_list=${UE5_qfi_ids}
    ...    trf_id_list=${UE5_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE5_mbps}
    ...    protocol=tcp
    Start Data Traffic    ue_id=50   pdu_id=5    qfi_id_list=${UE50_qfi_ids}
    ...    trf_id_list=${UE50_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE5_mbps}
    ...    protocol=tcp

    Enable ARP And Increase Schedule Weights    delta_activation=TC_07_ARP_enable_delta_scfc.json

    Attach UE And Establish PDU Session    ue_id=51   cell_id=5    enb_id=2    pdu_id=5    gw_id=2
    Attach UE And Establish PDU Session    ue_id=52   cell_id=5    enb_id=2    pdu_id=5    gw_id=3
    Modify PDU By Adding Additional DRB    ue_id=51    pdu_id=5    qos_flows=2,3
    Modify PDU By Adding Additional DRB    ue_id=52    pdu_id=5    qos_flows=5,6
    Start Data Traffic    ue_id=51   pdu_id=5    qfi_id_list=${UE51_qfi_ids}
    ...    trf_id_list=${UE51_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE51_mbps}
    ...    protocol=tcp
    Start Data Traffic    ue_id=52   pdu_id=5    qfi_id_list=${UE52_qfi_ids}
    ...    trf_id_list=${UE52_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE52_mbps}
    ...    protocol=tcp

    Wait For Traffic to Stabilize And Fill UEs Buffers

    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${PCell_id}
    ...    expected_throughput=28    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${SCell_id}
    ...    expected_throughput=14    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${PCell_id}
    ...    expected_throughput=28    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${SCell_id}
    ...    expected_throughput=14    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=225    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${SCell_id}
    ...    expected_throughput=85    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=52    cells_list=${PCell_id}
    ...    expected_throughput=225    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=52    cells_list=${SCell_id}
    ...    expected_throughput=85    direction=dl    margin=3%    selection_type=maximum

    Release Multiple UEs    ue_ids=${UE_AP_ids}    pdu_ids=${UE_PDU_AP_ids}

    Lock And Unlock Cell    cell_id=5
    Register Robustness UE51 And Verify UL And DL Traffic
    Release UE    ue_id=51   pdu_id=5

    Lock And Unlock RMOD And Wait For Cell To Be In Operational State Again     rmod_id=3    cell_id=5
    Register Robustness UE51 And Verify UL And DL Traffic
    Release UE    ue_id=51   pdu_id=5

    Lock And Unlock AMF And Wait For Cell To Be In Operational State Again     amf_id=1    cell_id=5
    Register Robustness UE51 And Verify UL And DL Traffic
    Release UE    ue_id=51   pdu_id=5

    [Teardown]    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


*** Keywords ***
Register Robustness UE51 And Verify UL And DL Traffic
    Attach UE And Establish PDU Session    ue_id=51   cell_id=5    enb_id=2    pdu_id=5    gw_id=2
    Modify PDU By Adding Additional DRB    ue_id=51    pdu_id=5    qos_flows=2,3
    Start Data Traffic    ue_id=51   pdu_id=5    qfi_id_list=${UE51_qfi_ids_dl}
    ...    trf_id_list=${UE51_trf_ids_robustness_dl}
    ...    dir=dl
    ...    mbps_list=${UE51_mbps_robustness_dl}
    ...    protocol=tcp
    Start Data Traffic    ue_id=51   pdu_id=5    qfi_id_list=${UE51_qfi_ids_ul}
    ...    trf_id_list=${UE51_trf_ids_robustness_ul}
    ...    dir=ul
    ...    mbps_list=${UE51_mbps_robustness_ul}
    ...    protocol=tcp
    Wait For Traffic to Stabilize And Fill UEs Buffers

    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=390    direction=dl    margin=5%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=50    direction=ul    margin=5%    selection_type=maximum

