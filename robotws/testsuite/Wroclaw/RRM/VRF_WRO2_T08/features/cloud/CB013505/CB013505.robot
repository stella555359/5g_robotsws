*** Settings ***
Documentation
...    author: Rafał Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB013505/resources/test_specific_keywords.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB013505/resources/test_constants.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml

*** Test Cases ***
TC01_USCB013505_SR_A_B1_EPIC_Feature_Activation
    [Setup]   Run Keywords    Setup                                                AND
    ...                       Setup Elt                                            AND
    ...                       taf.ue.Require UE    UE_1    capabilities=REAL_UE    AND
    ...                       taf.ue.Detach UE     UE_1
    TC01_USCB013505_SR_A_B1_EPIC_Feature_Activation
    Analyze Elt Log On    ${OUTPUT_DIR}/elt_log_on.json
    Analyze Elt Log Off    ${OUTPUT_DIR}/elt_log_off.json
    [Teardown]   Run Keywords
    ...          Teardown Tracing                AND
    ...          Setup Feature State    false    false    AND
    ...          taf.ue.Detach UE    UE_1


*** Keywords ***
TC01_USCB013505_SR_A_B1_EPIC_Feature_Activation
    taf.ue.Attach UE    UE_1
    Sleep    5s
    Log To Console    \nUE attached! Feature Off, Starting tput...
    taf.ue.Start Data Transfer
    ...     dt_name=DT_DL_attach
    ...     ue_alias=UE_1
    ...     direction=dl
    ...     duration=120s
    ...     throughput=800Mbits/sec
    ...     protocol=udp
    ...     packet_size=1400
    Sleep    60s
    Gather ELT Logs    elt_log_off.json
    Log To Console    ELT logs gathered
    taf.ue.Await Data Transfer Finish    dt_name=DT_DL_attach
    Stop UTF Tracing
    taf.ue.Detach UE    UE_1
    Start UTF Tracing
    Setup Feature State    true    true
    Sleep    10s
    taf.ue.Attach UE    UE_1
    Sleep    5s
    Log To Console    \nUE attached! Feature ON, Starting tput...
    taf.ue.Start Data Transfer
    ...     dt_name=DT_DL_attach
    ...     ue_alias=UE_1
    ...     direction=dl
    ...     duration=120s
    ...     throughput=800Mbits/sec
    ...     protocol=udp
    ...     packet_size=1400
    Sleep    60s
    Gather ELT Logs    elt_log_on.json
    Log To Console    ELT logs gathered
    taf.ue.Await Data Transfer Finish    dt_name=DT_DL_attach
    Stop UTF Tracing
    [Teardown]    Attenuate Source Cell
