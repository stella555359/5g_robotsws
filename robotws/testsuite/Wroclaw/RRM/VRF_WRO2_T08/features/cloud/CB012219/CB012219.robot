*** Settings ***
Documentation
...    author: Adam Kropiwnicki
...    contact: adam.kropiwnicki@nokia.com

Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB012219/resources/test_specific_keywords.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB012219/resources/test_constants.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml

*** Test Cases ***
[1]CB012219_K_2_Integrity_Protection_including_the_highest_data_rate_supported_by_UE_with_AES_IP_algorithm
    [Setup]   Setup
    Start Tracing
    Run UE Traffic
    Stop Tracing
    Check ELT log for integrity protection algorithm
    Unzip Results
    Find Syslog Files From Utf
    Merge Syslog
    Verify Syslog    ${A_1}
    [Teardown]   Run Keywords
    ...          Detach
    ...          Teardown ELT
    ...          Teardown DCAP
