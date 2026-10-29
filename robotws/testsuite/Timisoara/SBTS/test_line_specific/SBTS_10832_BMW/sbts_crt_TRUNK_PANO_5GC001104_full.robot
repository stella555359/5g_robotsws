*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_N_1ASIL_1AHLOA    SBTS00
Library           XML  use_lxml=True
Resource          ../../ONAP/PANO__5GC001104_A_13_Suppression_of_zero_values.robot
Resource          ../../ONAP/PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.robot

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8087_Paracopter/commissioning/SCF_01_TRUNK.xml
${VM_WITH_PANO_IP}       10.44.157.22
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   Ut3pa5s#1be1
${VES_PORT}              30510
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8087_Paracopter/commissioning

*** Test Cases ***
[1]Automated__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Setup]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    ...    AND    Set Library Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    [Timeout]    14400
    TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Teardown]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Setup]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    ...    AND    Set Library Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Timeout]    14400
    TC__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Teardown]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

