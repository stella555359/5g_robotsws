*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marcin Holowinski
...              :contact: Marcin.Holowinski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ta_messaging/flow.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Resource     Keywords_CB011081.robot
Variables    logging_policy.py



Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/${IPHY}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             With Simulator Configuration    config=${BASIC_SETUP}

Test Setup    Setup Dedicated Wireshark For UU Interface

Test Teardown    Run Keywords    Stop Capturing    alias=${UU_ALIAS}
...              AND    Teardown Tshark    alias=${UU_ALIAS}
...              AND    Deregister UEs From Test
...              AND    Add Scout Data Info To Testcase

*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    FULL_POLICY
${IPHY}=              iphy_6cc_AHFIHA_n25n25_AHPCA_n5_AHFIHA_n66_AZHN_n38_AQQL_n78n78_CLOUD_5G_I_BOO_AP_LOO.xml
${scfc}=              full_scfc_6cc_AHFIHA_n25n25_AHPCA_n5_AHFIHA_n66_AZHN_n38_AQQL_n78n78_CLOUD_5G_I_LPQ_AP_LOO.xml
${BASIC_SETUP}=       ${CURDIR}/config/wts_setup_B_B_3.cfg
${UE_ID_4}=    4
${UE_ID_40}=    40
${UE_ID_41}=    41
${UE_ID_42}=    42
${UE_ID_43}=    43
${UE_ID_44_all_pairs}=    44
${SOURCE_CELL_ID}=    4

${4_SCELL_ADD}=  (nr-rrc.sCellToAddModList == 4)
${5_SCELL_ADD}=  (nr-rrc.sCellToAddModList == 5)
${5CC_SCELLS}=  (nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 56 && nr-rrc.physCellId == 57)
${6CC_SCELLS}=  (nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 55 && nr-rrc.physCellId == 56 && nr-rrc.physCellId == 57)
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB011081-BB3_Simultaneous_Rx_Tx_Inter_Band_CA_Per_Band_Pair_transmission_handling_for_6CC_DL_CA
    [Documentation]   All UEs supports supportedBandCombinationList: n25, n25, n38, n66, n78, n78
    ...               UEs 4 and 40-43 do not support band pair  n38 and n66 (simultaneousRxTXInterBandCAPerBandPair)
    ...               As PCell is cell 4 with n66 the cell n38 is eleminated as Scell candidate
    ...               Scell addition is blind. Reference UE 44 is supporting all bands pair and proves 6CC setup in such case

    Attach Multiple UEs Without Support Of CA Band Pair n38_n66
    Start Data For Single UE And Verify Correct 5 CC Addition

    Attach Reference UE With Support Of All Bands Pairs And Check 6CC Addition

*** Keywords ***
Attach Multiple UEs Without Support Of CA Band Pair n38_n66
    Attach UE And Establish PDU Session    ue_id=${UE_ID_4}    cell_id=${SOURCE_CELL_ID}    enb_id=2   pdu_id=3    gw_id=3
    Sleep    1    Stability
    Attach UE And Establish PDU Session    ue_id=${UE_ID_40}    cell_id=${SOURCE_CELL_ID}    enb_id=2   pdu_id=3    gw_id=3
    Sleep    1    Stability
    Attach UE And Establish PDU Session    ue_id=${UE_ID_41}    cell_id=${SOURCE_CELL_ID}    enb_id=2   pdu_id=3    gw_id=3
    Sleep    1    Stability
    Attach UE And Establish PDU Session    ue_id=${UE_ID_42}    cell_id=${SOURCE_CELL_ID}    enb_id=2   pdu_id=3    gw_id=3
    Sleep    1    Stability
    Attach UE And Establish PDU Session    ue_id=${UE_ID_43}    cell_id=${SOURCE_CELL_ID}    enb_id=2   pdu_id=3    gw_id=3

Start Data For Single UE And Verify Correct 5 CC Addition
    Start Specific Data DL Traffic    ue_id=${UE_ID_4}   pdu_id=3    mbps_per_trf_id=80
    Start Specific Data UL Traffic    ue_id=${UE_ID_4}   pdu_id=3   first_trf_id=1    last_trf_id=2
    Sleep    10    Stability
    Verify DL Traffic Is Scheduled On All Cells    ue_id=${UE_ID_4}
    Verify UL Traffic Is Scheduled On PCell and SCell    ue_id=${UE_ID_4}
    Verify Tshark For Given Number Of Messages
   ...    alias=${UU_ALIAS}
   ...    packet_filter=${4_SCELL_ADD}&&${5CC_SCELLS}
   ...    number_of_messages=5

Attach Reference UE With Support Of All Bands Pairs And Check 6CC Addition
	Attach UE And Establish PDU Session    ue_id=${UE_ID_44_all_pairs}    cell_id=${SOURCE_CELL_ID}    enb_id=2   pdu_id=3    gw_id=3
    Sleep    5    Stability
    Verify Tshark For Single Message    alias=${UU_ALIAS}
    ...   packet_filter=${5_SCELL_ADD}&&${6CC_SCELLS}

Verify DL Traffic Is Scheduled On All Cells
    [Arguments]    ${ue_id}
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=4
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=4    expected_throughput=1Mbps

Deregister UEs From Test
    Deregister UE    ue_id=${UE_ID_4}
    Deregister UE    ue_id=${UE_ID_40}-${UE_ID_43}
    Deregister UE    ue_id=${UE_ID_44_all_pairs}

Verify UL Traffic Is Scheduled On PCell and SCell
    [Arguments]    ${ue_id}=1
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=2    cell_index_min=0
    ...   cell_index_max=0    direction=ul
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=2    cell_index_min=3
    ...   cell_index_max=3    direction=ul

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}

