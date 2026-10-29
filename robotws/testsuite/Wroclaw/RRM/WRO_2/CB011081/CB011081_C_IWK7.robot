*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marek Kocela
...              :contact: marek.kocela@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/traffic.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB011081.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_lpq.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
...            AND             Create SA Aliases    ue_id=${UE1_ID}    gNB_id=${GNB_ID}
...            AND             Create UE Alias    alias=UE${UE2_ID}    ue_id=${UE2_ID}    id_type=wts_5g
...            AND             Create UE Alias    alias=UE${UE3_ID}    ue_id=${UE3_ID}    id_type=wts_5g

Test Teardown    Run Keywords    Release Multiple UEs    ue_ids=@{UE_IDs_release}    pdu_ids=@{PDU_IDs_release}
...              AND    Add Scout Data Info To Testcase

*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_c_iwk7.cfg
${scfc}=              full_scfc_CB006733_c_iwk7.xml

${SOURCE_CELL_ID}=    3
${GNB_ID}=    2
${PDU_ID_UE1}=    3
${PDU_ID_UE2}=    4
${PDU_ID_UE3}=    5
@{PDU_IDs_release}=    ${PDU_ID_UE1}    ${PDU_ID_UE2}    ${PDU_ID_UE3}
${GW_ID}=    3

${UE1_ID}=    3
${UE2_ID}=    30
${UE3_ID}=    31
@{UE_IDs_release}=     ${UE1_ID}    ${UE2_ID}    ${UE3_ID}

${QOS_FLOW_LIST_ONE_ELEMENT}=    1
${QOS_FLOW_LIST_TWO_ELEMENTS}=    2

@{FIVE_QIS_UE1}=    5    6
@{FIVE_QIS_UE2}=    5    7
@{FIVE_QI_UE3}=    8
${FIVE_QI_UE3_ADD}=    9

${ADDITIONAL_DRB_UE1}=    2
${ADDITIONAL_DRB_UE2}=    3

@{PCELL_INDEX}=    0
@{6CC_SCELLS_INDEXES}=    0    1    2    3    4    5
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
USCB011081-CIWK7_DRB_profile_based_Carrier_Aggregation_interaction_with_6CC_DL_CA_with_FDD_PCell
    Register UE With Additional DBR    ue_id=${UE1_ID}    pdu_id=${PDU_ID_UE1}    drb=${ADDITIONAL_DRB_UE1}
    ...    QosFlowSetupRequestList=${QOS_FLOW_LIST_TWO_ELEMENTS}    fiveQIs=@{FIVE_QIS_UE1}

    Register UE With Additional DBR    ue_id=${UE2_ID}    pdu_id=${PDU_ID_UE2}    drb=${ADDITIONAL_DRB_UE2}
    ...    QosFlowSetupRequestList=${QOS_FLOW_LIST_TWO_ELEMENTS}    fiveQIs=@{FIVE_QIS_UE2}

    Register UE Without Additional DBR    ue_id=${UE3_ID}    pdu_id=${PDU_ID_UE3}    QosFlowSetupRequestList=${QOS_FLOW_LIST_ONE_ELEMENT}
    ...    fiveQIs=@{FIVE_QI_UE3}

    Start Specific Data DL Traffic    ue_id=${UE1_ID}   pdu_id=${PDU_ID_UE1}    mbps_per_trf_id=175    last_trf_id=2
    Start Specific Data DL Traffic    ue_id=${UE2_ID}   pdu_id=${PDU_ID_UE2}    mbps_per_trf_id=175    last_trf_id=2
    Start Specific Data DL Traffic    ue_id=${UE3_ID}   pdu_id=${PDU_ID_UE3}    mbps_per_trf_id=175    last_trf_id=2
    Wait for Traffic to Stabilize    inactive_timer=10

    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE1_ID}    cells_list=${6CC_SCELLS_INDEXES}    expected_throughput=1Mbps
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE2_ID}    cells_list=${PCELL_INDEX}    expected_throughput=1Mbps
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE3_ID}    cells_list=${PCELL_INDEX}    expected_throughput=1Mbps

    Expect Messages PDUSessionResourceModify   ue_id=${UE3_ID}
    Modify PDU Session By Adding QoS Flow    ue_id=${UE3_ID}    pdu_id=${PDU_ID_UE3}    qosflows_to_add=5
    Verify Messages PDUSessionResourceModifyRequest ADD    ue_id=${UE3_ID}    fiveQI=${FIVE_QI_UE3_ADD}
    Verify Messages PDUSessionResourceModifyResponse ADD    ue_id=${UE3_ID}   pdu_id=${PDU_ID_UE3}    qosFlowIdentifier=${QOS_FLOW_LIST_TWO_ELEMENTS}
    Start Specific Data DL Traffic    ue_id=${UE3_ID}   pdu_id=${PDU_ID_UE3}    qfi=2    mbps_per_trf_id=175    first_trf_id=3    last_trf_id=4

    Expect Messages PDUSessionResourceModify   ue_id=${UE1_ID}
    Modify PDU Session By Deleting QoS Flow    ue_id=${UE1_ID}    pdu_id=${PDU_ID_UE1}    qosflows_to_del=1
    Verify Messages PDUSessionResourceModifyRequest DEL    ue_id=${UE1_ID}   pdu_id=${PDU_ID_UE1}    qosFlowIdentifier=${QOS_FLOW_LIST_ONE_ELEMENT}
    Verify Messages PDUSessionResourceModifyResponse DEL    ue_id=${UE1_ID}   pdu_id=${PDU_ID_UE1}

    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE1_ID}    cells_list=${PCELL_INDEX}    expected_throughput=1Mbps
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE2_ID}    cells_list=${PCELL_INDEX}    expected_throughput=1Mbps
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE3_ID}    cells_list=${6CC_SCELLS_INDEXES}    expected_throughput=1Mbps

    Stop DL and UL traffic on PDU for UE    ue_id=${UE1_ID}    pdu_id=${PDU_ID_UE1}
    Stop DL and UL traffic on PDU for UE    ue_id=${UE2_ID}    pdu_id=${PDU_ID_UE2}
    Stop DL and UL traffic on PDU for UE    ue_id=${UE3_ID}    pdu_id=${PDU_ID_UE3}


*** Keywords ***
Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
