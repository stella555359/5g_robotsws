*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Sebastian Sliwakowski
...              :contact: sebastian.sliwakowski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot

Library      ta5g_tshark
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_ue_mobility
Variables    ta5g_global_var
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_B_B23.cfg
${SCFC}=    scfc_b23.xml
${UE_ID}=                  1

${Act_Deact_A4_meas}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==1 &&
...    nr-rrc.measId==7 &&
...    nr-rrc.freqBandIndicatorNR==257 &&
...    nr-rrc.measIdToRemoveList==6

${A4_Imm_Deactivation}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToRemoveList==1 && nr-rrc.gapUE==0 && nr-rrc.MeasObjectId == 7 && nr-rrc.MeasId == 7

${Second_A4_Confirmation}=
...    nr-rrc.measIdToAddModList == 6 && nr-rrc.gapUE == 1 && !nr-rrc.reportConfigToAddModList == 2

*** Test Cases ***
CB006733-B_B23_CB008696_interaction_-_Deactivation_of_A4_measurements_for_FR1_CA_SCell_Addition_on_UE_Inactivity_timer_expiration
    Attach Ue With Pdu And Wait Till Inactivity Timer Expires Then Start Traffic Before A4retryTimer And A4fr1SuperTimer Expires
    Verify Deactivated A4 Measurements Where Inter-freq A4 for Idle Mode Steering Are Activated In The Same Rrc Conf Message    ${Act_Deact_A4_meas}
    Verify If A4 measurements for Idle mode steering are deactivated After Starting Data Traffic    ${A4_Imm_Deactivation}
    Verify If A4 measurements for FR1 CA SCell Addition are activated again at the UE   ${Second_A4_Confirmation}
[Teardown]    Add Scout Data Info To Testcase
