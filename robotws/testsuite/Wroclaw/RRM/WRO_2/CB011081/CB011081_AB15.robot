*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/ta_messaging_robot_keywords.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     ../keywords/traffic.robot
Resource     Keywords_CB011081.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_ue_mobility
Variables    ta5g_global_var
Variables    CB011081_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_AB15.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create SA Aliases    ue_id=${UE_ID}    gNB_id=${GNB_ID}

Test Teardown    Run Keywords    Stop DL and UL traffic on PDU for UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
...              AND    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
...              AND    Add Scout Data Info To Testcase

*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_AB15.cfg
${SCFC}=              full_scfc_CB011081_AB15.xml
${UE_ID}=                  3
${PCELL_ID}=               3
${GNB_ID}=                 2
${PHYSCELL_ID}=            53
${PDU_ID}=                 1
${GW_ID}=                  1
${A1_MEAS_ID}=             1
${SRSRP_NR}=               90
${SRSRQ_NR}=               95
${A1_CMD}=
...    id=${UE_ID} meas_id=3 event=A1 srsrp_nr=20
...    scell=1 scell_rsrp=9
...    scell=2 scell_rsrp=9
...    scell=3 scell_rsrp=9
...    scell=4 scell_rsrp=95
...    scell=5 scell_rsrp=9
@{SCELL_INDEX_UL}=    2
@{6CC_SCELLS_INDEXES}=    0    1    2    3    4    5
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_AFTER_PCELL_CHANGE}=     f1ap.SCell_ToBeSetupMod_List == 5
${F1AP_SCELL_TO_ADD_MOD_LIST_AFTER_PCELL_CHANGE}=          ((((((nr-rrc.sCellToAddModList == 5) && (nr-rrc.physCellId == 52))
...                                                        && (nr-rrc.physCellId == 53)) && (nr-rrc.physCellId == 54)) && (nr-rrc.physCellId == 55))
...                                                        && (nr-rrc.physCellId == 57)) && (f1ap.SelectedBandCombinationIndex == 00:01)
${RRCRECONFIGURATION_BEFORE_PCELL_CHANGE}=                 ((nr-rrc.measObjectToAddModList == 5) && (nr-rrc.reportConfigToAddModList == 1))
...                                                        && (nr-rrc.measIdToAddModList == 3)
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB011081_AB15_A1_SCell_Measurement_based_UL_overload_preventive_inter-frequency_HO_PCell_change_to_configured_SCell_for_SA_UE_in_6CC_CA
    [Setup]    Enable Tshark Verification

    Attach UE And Expect Establishing PDU Session And Verify A1 Measurement Configuration for PCell   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}

    Trigger and Verify A1 Based SCell Addition   ue_id=${UE_ID}    gNB_id=${GNB_ID}    meas_id_a1=${A1_MEAS_ID}
    ...    srsrp_a1=${SRSRP_NR}    srsrq_a1=${SRSRQ_NR}    filters=${A1_measurement_for_SCell_Addition}

    Start Specific Data DL Traffic    ue_id=${UE_ID}   pdu_id=${PDU_ID}    mbps_per_trf_id=150    last_trf_id=5
    Start Specific Data UL Traffic    ue_id=${UE_ID}   pdu_id=${PDU_ID}    mbps_per_trf_id=150    first_trf_id=6    last_trf_id=8

    Trigger A1 Based PCell Change    ue_id=${UE_ID}    gnb_id=${GNB_ID}    A1_cmd=${A1_CMD}

    Verify UE Successful Blind SCell Addition after A1 PCell Change


*** Keywords ***
Data Transfer is successful after handover on TDD Cell
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${6CC_SCELLS_INDEXES}
    ...    expected_throughput=1    direction=dl    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${SCELL_INDEX_UL}
    ...    expected_throughput=1    direction=ul    margin=95%    selection_type=maximum

Attach UE And Expect Establishing PDU Session And Verify A1 Measurement Configuration for PCell
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}

    Set 2 expected RRC Reconfiguration Request and Complete messages for UE3
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}

    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Verify that 2 RRC Reconfiguration Request and Complete messages occured for UE3
    Verify A1 Measurement Configuration for PCell   ue_id=${UE_ID}    filters=${A1_measurement_configuration_for_PCell_FDD_AB15}

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
