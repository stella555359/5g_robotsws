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
Resource     ../keywords/ue_measurements.robot
Resource     Keywords_CB011081.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Variables    ta5g_global_var
Variables    CB011081_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_lpq.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create SA Aliases    ue_id=${UE_ID}    gNB_id=${GNB_ID}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_basic.cfg
${scfc}=              full_scfc_CB011081_AB4.xml
${UE_ID}=                  3
${PCELL_ID}=               3
${GNB_ID}=                 2
${PHYSCELL_ID}=            53
${PDU_ID}=                 3
${GW_ID}=                  3
${A1_MEAS_ID}=             1
${SRSRP_NR}=               90
${SRSRQ_NR}=               95
${FIRST_TRF_ID}=           1
${LAST_TRF_ID_UL}=         2
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB011081_AB4_A1_PCell_Measurement_based_Scell_Addition_for_6CC_DL_CA_and_2CC_UL_CA_4F2T
    Attach UE And Expect Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify A1 Measurement Configuration At UE    ue_id=${UE_ID}    filters=${A1_measurement_configuration_at_the_UE_during_ICS_for_Scell_Addition}
    Trigger A1 Measurement And Expect SCell Addition Messages Flow For UE    ue_id=${UE_ID}
    ...    gnb_id=${GNB_ID}    meas_id=${A1_MEAS_ID}    srsrp_nr=${SRSRP_NR}    srsrq_nr=${SRSRQ_NR}
    Verify SCell Addition Messages Content After A1 Event Trigger For UE    ue_id=${UE_ID}
    Start Specific Data DL Traffic    ue_id=${UE_ID}   pdu_id=${pdu_id}
    Start Specific Data UL Traffic    ue_id=${UE_ID}   pdu_id=${pdu_id}
    ...    first_trf_id=${FIRST_TRF_ID}    last_trf_id=${LAST_TRF_ID_UL}
    Verify Traffic Is Scheduled On All Cells 6CC DL And 2CC UL    ue_id=${UE_ID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}

    [Teardown]    Add Scout Data Info To Testcase


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
