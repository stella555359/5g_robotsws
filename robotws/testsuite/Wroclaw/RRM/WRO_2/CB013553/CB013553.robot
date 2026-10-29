*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../CB013553/Keywords_CB013553.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB013553_variables.robot
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_ue_mobility
Library      ta5g_pm_counters
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/ngap.py
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/f1ap.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy.xml
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=scf.xml
...            AND             Check Radios Availability
...            AND             Reach Onair      lua_cfg=${CURDIR}/config/egate_TMOUS.lua    mplane_cells=@{mplane_cells}
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Run Keywords    Release Multiple UEs Without Confirmation    number_of_ues=2
...           AND                Add Scout Data Info To Testcase

*** Test Cases ***
USCB013553_Multi_UEs_6CC_with_verification_PM_counters
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE And Establish PDU Session    ue_id=${UE1_ID}    cell_id=${PCELL1_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW1_ID}
    Trigger A1 Measurement    ue_id=${UE1_ID}    meas_id=${UE1_A1_MEAS_ID}    srsrp_nr=90    srsrq_nr=95
    Start UL Tput on UE1
    Verify SCell Addition Messages For 6CC For TDD PCell
    Verify ULTxSwitching On TDD PCell and FDD Scell

    Attach UE And Establish PDU Session    ue_id=${UE2_ID}    cell_id=${PCELL7_ID}    pdu_id=${PDU_PCELL_7}    gw_id=${GW7_ID}
    Trigger A1 Measurement    ue_id=${UE2_ID}    meas_id=${UE2_A1_MEAS_ID}    srsrp_nr=90    srsrq_nr=95
    Start UL Tput on UE2
    Verify SCell Addition Messages For 6CC For FDD PCell
    Verify ULTxSwitching On FDD PCell and TDD Scell

    Verify Counters for CB013553

    [Teardown]    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
