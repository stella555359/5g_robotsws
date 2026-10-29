*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R1
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Mikolaj Kasian
...              :contact: mikolaj.kasian@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/logging.robot
Resource     feature_keywords.robot
Library      ta5g_iphy
Library      ta5g_delta
Library      testsuite/Wroclaw/RRM/WRO_2/resources/common_functions.py
Library      taf.ul.ettf.setups

Suite Setup     Run Keywords    Log To Console    Setup is going with Delta Commissioning
...            AND              Set Custom SCTP RTO Min Time
...            AND              Enable C-Plane Debug Logs    with_reboot=${FALSE}
...            AND              Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${SCFC_FEATURE_PRECONDITION}
...            AND              Wait For Testline Icmp Echo Replies And Ssh Services
...            AND              Start Default Logging
...            AND              With Simulator Configuration    config=${BASIC_SETUP}
...            AND              Verify X2 link Status    is_available=True

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${BASIC_SETUP}=                   ${CURDIR}/config/egate_4cells_TDD_and_FDD.cfg
${SCFC_FEATURE_PRECONDITION}=     delta_config_9205_A_B1.json
${NSA_UE_1}=                      101

*** Test Cases ***
CB009205-A_B1_Configuration_A1_measurement_for_steering_UE_to_preferred_NR_layer_during_SgNB_Addition_procedure_RSRP_case_wo_DRX
    [Setup]    Wait For Next Full Pm Interval
    Add Scout Data Info To Testcase
    Attach UE In NSA Mode And Verify Success    ue_id=${NSA_UE_1}    cell_id=1    gNB_id=2
    Wait Over Potential a4RetryTimer Period
    Verify A1 Measurement Configuration For UE
    Verify A4 Measurement Absence For UE
    Verify Counters For Robustness Purpose

    [Teardown]    Detach UE    ue_id=${NSA_UE_1}
