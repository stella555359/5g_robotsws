*** Settings ***
Documentation
...    Test Configuration - cells:
...
...    cell     | band   |  techn. |   BW (DL/UL)    |  nrarfcn        |     DL MIMO
...    -----------------------------------------------------------------------------------
...    cell_1	 |	n71	 |	FDD	   |	10Mhz		 |	127420/136620  |  2x2 Open Loop
...    cell_2	 |	n5	 |	FDD    |	5MHz		 |	176300/167300  |  2x2 Open Loop
...    cell_3	 |	n66	 |	FDD	   |	20MHz/10Mhz	 |	427000/347000  |  2x2 Open Loop
...    cell_4	 |	n2	 |	FDD	   |	20MHz		 |	392000/376000  |  2x2 Open Loop
...    cell_5	 |	n41	 |	TDD	   |	60MHz		 |	518580         |  2x2 Open Loop
...    cell_6	 |	n77	 |	TDD	   |	60MHz		 |	649970         |  2x2 Open Loop

...    Authors: Piotr Gudas,
...    Contact: piotr.gudas@nokia.com,

Force Tags    CLOUD_5G_I_BOO_AP_LOO    PY310    NoResUsage    RF50

Resource     ./resources/CB006877_Keywords.robot
Resource     ./resources/CB006877_Variables.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND             Change RD Parameters in swconfig File
...            AND             Setup Test Line
...                                iphy_xml_filepath=${CURDIR}/config/iphy_multi_BWP.xml
...                                scfc_filename=SCFC_CB006877_B_IWK5.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CA_4FDD_2TDD_large_BWP.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Update Iphy Configuration And Modify Swconfig
...                                   iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...               AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
@{LONG_PUCCH_CSI_RESOURCES_ODD}=    29    27    33    31    37    35
@{LONG_PUCCH_CSI_RESOURCES_EVEN}=   27    29    31    33    35    37
${PRB_IDX_1}=                       0


*** Test Cases ***
CB006877_SR_B_ET_IWK5_01_02_Only_UL_PRB_Blanking_When_CB006877_Is_Enabled_With_Multi_BWP
    [Documentation]    This test case main purpose is to verify values of the startingPRB and secondHopPRB
    ...                before and after Housekeeping Function (HKF). When some of the UEs are detached/deregistered,
    ...                then UEs, which are active, should receive PRB resources from the deallocated UEs.
    ...                Requirement: 5G_RAN_USR_RRM_24298, 5G_RAN_USR_RRM_24299, CB_FIM_43190

    Log To Console    Attach SA UEs 31-36 to cell-3
    FOR    ${index}    IN RANGE    31    37
        Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${index}
        Establish Pdu Session With Traffic    ue_id=${index}    pdu_id=1    gw_id=${index}
    END

    Log To Console    Attach NSA UEs 1-6 to cell-3
    FOR    ${index}    IN RANGE    1    7
        Attach UE To Enb And Gnb    ue_id=${index}    target_cells=3
    END

    Log To Console    Deregister SA UEs 31-35
    FOR    ${index}    IN RANGE    31    36
        Deregister Ue Without Confirmation    ue_id=${index}
    END

    Log To Console    Detach NSA UEs 1-5
    FOR    ${index}    IN RANGE    1    6
        Detach Ue    ue_id=${index}
    END

    Log To Console    wait for HKF period 60 sec
    Verify Ngap Messages    packet_filter=${MSG_FILTER_SA_HKF}
    ...    pcap_file_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap    timeout=60
    Verify Ngap Messages    packet_filter=${MSG_FILTER_NSA_HKF}
    ...    pcap_file_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap    timeout=60

    Log To Console    Convert pcap to json
    ${GNB_F1_E1_RRC_MSG_FILTER_SA}=    Convert Pcap To Json Using Tshark    message_filter=${MSG_FILTER_SA}
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap
    ...    output_filename=gnb_F1_E1_RRC_msg_filter_SA.json

    ${GNB_F1_E1_RRC_MSG_FILTER_NSA}=    Convert Pcap To Json Using Tshark    message_filter=${MSG_FILTER_NSA}
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap
    ...    output_filename=gnb_F1_E1_RRC_msg_filter_NSA.json

    ${GNB_F1_E1_RRC_MSG_FILTER_SA_HKF}=    Convert Pcap To Json Using Tshark    message_filter=${MSG_FILTER_SA_HKF}
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap
    ...    output_filename=gnb_F1_E1_RRC_msg_filter_SA_HKF.json

    ${GNB_F1_E1_RRC_MSG_FILTER_NSA_HKF}=    Convert Pcap To Json Using Tshark    message_filter=${MSG_FILTER_NSA_HKF}
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap
    ...    output_filename=gnb_F1_E1_RRC_msg_filter_NSA_HKF.json

    Log To Console    Get values from json
    @{CSI_STARTING_PRB_UES_SA}=    Find All Values In Json With Regex    json_file=${GNB_F1_E1_RRC_MSG_FILTER_SA}
    ...    pattern=${PATTERN_CSI_RESOURCE_STARTING_PRB}
    @{CSI_SECOND_HOP_PRB_UES_SA}=    Find All Values In Json With Regex    json_file=${GNB_F1_E1_RRC_MSG_FILTER_SA}
    ...    pattern=${PATTERN_CSI_RESOURCE_SECOND_HOP_PRB}

    @{CSI_STARTING_PRB_UES_NSA}=    Find All Values In Json With Regex    json_file=${GNB_F1_E1_RRC_MSG_FILTER_NSA}
    ...    pattern=${PATTERN_CSI_RESOURCE_STARTING_PRB}
    @{CSI_SECOND_HOP_PRB_UES_NSA}=    Find All Values In Json With Regex    json_file=${GNB_F1_E1_RRC_MSG_FILTER_NSA}
    ...    pattern=${PATTERN_CSI_RESOURCE_SECOND_HOP_PRB}

    ${CSI_STARTING_PRB_SA_HKF_UE36}=    Find All Values In Json With Regex   json_file=${GNB_F1_E1_RRC_MSG_FILTER_SA_HKF}
    ...    pattern=${PATTERN_CSI_RESOURCE_STARTING_PRB_HKF}
    ${CSI_SECOND_HOP_SA_HKF_UE36}=    Find All Values In Json With Regex   json_file=${GNB_F1_E1_RRC_MSG_FILTER_SA_HKF}
    ...    pattern=${PATTERN_CSI_RESOURCE_SECOND_HOP_HKF}

    ${CSI_STARTING_PRB_NSA_HKF_UE6}=    Find All Values In Json With Regex    json_file=${GNB_F1_E1_RRC_MSG_FILTER_NSA_HKF}
    ...    pattern=${PATTERN_CSI_RESOURCE_STARTING_PRB_HKF}
    ${CSI_SECOND_HOP_NSA_HKF_UE6}=    Find All Values In Json With Regex   json_file=${GNB_F1_E1_RRC_MSG_FILTER_NSA_HKF}
    ...    pattern=${PATTERN_CSI_RESOURCE_SECOND_HOP_HKF}


    Log To Console    Check CSI Pattern for ODD slots
    Lists Should Be Equal    ${LONG_PUCCH_CSI_RESOURCES_ODD}    ${CSI_STARTING_PRB_UES_SA}
    Lists Should Be Equal    ${LONG_PUCCH_CSI_RESOURCES_EVEN}    ${CSI_SECOND_HOP_PRB_UES_SA}

    Log To Console    Check CSI Pattern for EVEN slots
    Lists Should Be Equal    ${LONG_PUCCH_CSI_RESOURCES_EVEN}    ${CSI_STARTING_PRB_UES_NSA}
    Lists Should Be Equal    ${LONG_PUCCH_CSI_RESOURCES_ODD}    ${CSI_SECOND_HOP_PRB_UES_NSA}

    Log To Console    Check CSI resource after HKF for SA UE36
    Should Be Equal    ${CSI_STARTING_PRB_SA_HKF_UE36}[${PRB_IDX_1}]    ${CSI_STARTING_PRB_UES_SA}[${PRB_IDX_1}]
    Should Be Equal    ${CSI_SECOND_HOP_SA_HKF_UE36}[${PRB_IDX_1}]    ${CSI_SECOND_HOP_PRB_UES_SA}[${PRB_IDX_1}]

    Log To Console    Check CSI resource after HKF for NSA UE6
    Should Be Equal    ${CSI_STARTING_PRB_NSA_HKF_UE6}[${PRB_IDX_1}]    ${CSI_STARTING_PRB_UES_NSA}[${PRB_IDX_1}]
    Should Be Equal    ${CSI_SECOND_HOP_NSA_HKF_UE6}[${PRB_IDX_1}]    ${CSI_SECOND_HOP_PRB_UES_NSA}[${PRB_IDX_1}]
