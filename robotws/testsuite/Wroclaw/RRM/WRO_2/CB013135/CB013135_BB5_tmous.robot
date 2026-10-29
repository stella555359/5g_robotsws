*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS25R2    SBTS25R1
...    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../CB013135/Keywords_CB013135.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB013135_variables.robot
Library      taf.ul.ettf.setups
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_ue_mobility
Variables    logging_policy.py
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/ngap.py
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/f1ap.py
Library      ../CB013135/egate_console_log_verifier.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy.xml
...            AND             With Gnb Configuration    commissioning=scf_tmo_13135.xml
...            AND             Reach Onair      lua_cfg=${CURDIR}/config/egate_TMOUS.lua    mplane_cells=@{mplane_cells}


*** Test Cases ***
USCB013135-BB501_Known_BC_with_known_BCS5_indicated_for_FR1_CA_band_combination_interaction_with_CB012149_UL_Tx_Switching
    [Setup]    Enable Tshark Verification

    Attach UE And Establish PDU Session    ue_id=${UE1_ID}    cell_id=${PCELL1_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW1_ID}
    Send Data Traffic    ue_id=${UE1_ID}    pdu_id=${PDU_PCELL_1}
    Trigger A1 Measurement    ue_id=${UE1_ID}    meas_id=${UE1_A1_MEAS_ID}    srsrp_nr=90    srsrq_nr=95
    Verify SCell Addition Messages For 6CC For TDD PCell
    Verify ULTxSwitching On TDD PCell and FDD Scell
    Release UE    ue_id=${UE1_ID}    pdu_id=${PDU_PCELL_1}

    Attach UE And Establish PDU Session    ue_id=${UE2_ID}    cell_id=${PCELL7_ID}    pdu_id=${PDU_PCELL_7}    gw_id=${GW7_ID}
    Send Data Traffic    ue_id=${UE2_ID}    pdu_id=${PDU_PCELL_7}
    Trigger A1 Measurement    ue_id=${UE2_ID}    meas_id=${UE2_A1_MEAS_ID}    srsrp_nr=90    srsrq_nr=95
    Verify SCell Addition Messages For 6CC For FDD PCell
    Verify ULTxSwitching On FDD PCell and TDD Scell
    Release UE    ue_id=${UE2_ID}    pdu_id=${PDU_PCELL_7}

    Verify UE Capability from egate console log    ${egate_console_log_filename}    &{PATTERNS}

    [Teardown]    Add Scout Data Info To Testcase

*** Keywords ***
Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${gw_id}    ${nwslice}=1
    Execute Egate Command    cmd=ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Sleep    3
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}
	Sleep    3

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Verify SCell Addition Messages For 6CC For TDD PCell
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_TDD_PCell}        continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_TDD_PCell}             continue_on_failure=False

Verify SCell Addition Messages For 6CC For FDD PCell
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    number_of_messages=2    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_FDD_PCell}        number_of_messages=2
    ...                                                                                                        continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_FDD_PCell}             continue_on_failure=False

Verify ULTxSwitching On TDD PCell and FDD Scell
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswithing_on_TDD_PCell}    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswitching_on_FDD_SCell}    continue_on_failure=False

Verify ULTxSwitching On FDD PCell and TDD Scell
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswithing_on_FDD_PCell}    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswitching_on_TDD_SCell}    continue_on_failure=False
