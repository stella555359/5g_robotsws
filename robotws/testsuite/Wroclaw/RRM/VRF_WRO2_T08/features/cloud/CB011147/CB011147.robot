*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library        taf.ue
Library        taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    admin
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB011147/resources/test_specific_keywords.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB011147/resources/test_constants.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml

*** Test Cases ***
CB011147_A_B2_ALT2_a4RetryTimer_expiry_with_activation_of_RSRP_and_RSRQ
    [Setup]   Test Setup
    A_B2_ALT2_a4RetryTimer_expiry_with_activation_of_RSRP_and_RSRQ
    [Teardown]   Test Teardown


*** Keywords ***
A_B2_ALT2_a4RetryTimer_expiry_with_activation_of_RSRP_and_RSRQ
    Log To Console    "OK"
    Start Tracing
    taf.ue.Attach UE    UE_1
    Log To Console    \nUE attached!
    Sleep    6s
    taf.ue.Detach UE    UE_1
    Stop Tracing
    Unzip Results
    Prepare Emil Logs
    Find Syslog Files From Utf
    Merge Syslog
    Validate Rrcreconfiguration With A4meas    ${OUTPUT_DIR}/elt_log.json


Test Setup
    Setup
    Setup Elt
    taf.ue.Require UE    UE_1    capabilities=REAL_UE
    taf.ue.Detach UE     UE_1


Test Teardown
    Teardown
    Teardown Tracing
    taf.ue.Detach UE    UE_1
