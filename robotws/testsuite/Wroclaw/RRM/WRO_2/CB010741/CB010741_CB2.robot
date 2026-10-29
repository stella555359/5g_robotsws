*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS26R2
...    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB010741_Keywords_And_Variables.robot
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

Test Teardown    Deregister Ue Without Confirmation   ue_id=1


*** Test Cases ***
CB010741_C_B2_UL_buffer_triggered_SCell_Upgrade_when_SCell_is_configured_already_as_DL_only__A1_A4_measurement_based
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}

    Attach UE And Establish PDU Session
    Trigger A1 Measurement
    Trigger A4 Measurement
    Start DL Tput
    Verify that SCell is configured already as DL only
    Start UL Tput After A4SupervisionTimer expiration
    Verify Messages UL Buffer Triggered SCell Upgrade

    Verify Counters for CB010741

    [Teardown]    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND                Add Scout Data Info To Testcase
