*** Settings ***
Documentation
...    author: Tomasz Sobania
...    contact: tomasz.sobania@nokia.com

Library        taf.ue
Library        taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    admin
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB012220/resources/test_specific_keywords.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB012220/resources/test_constants.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml


*** Test Cases ***
[1]CB012220_A_4_Cell_setup_UE_setup_and_data_transmission_in_SA_mode_and_real_radio_condition
    [Setup]   Run Keywords    Setup                                                AND
    ...                       Setup Elt                                            AND
    ...                       taf.ue.Require UE    UE_1    capabilities=REAL_UE    AND
    ...                       taf.ue.Detach UE     UE_1
    CB012220_A_4 Main Scenario
    Analyze Elt Log    ${OUTPUT_DIR}/elt_log.json
    [Teardown]   Run Keywords
    ...          Teardown                    AND
    ...          Teardown ELT                AND
    ...          taf.ue.Detach UE    UE_1


*** Keywords ***
CB012220_A_4 Main Scenario
    taf.ue.Attach UE    UE_1
    Sleep    2s
    Log To Console    \nUE attached! Starting tput...
    taf.ue.Start Data Transfer
    ...     dt_name=DT_DL_attach
    ...     ue_alias=UE_1
    ...     direction=dl
    ...     duration=30s
    ...     throughput=500Mbits/sec
    ...     protocol=udp
    ...     packet_size=1400
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL_attach
    ...     ue_alias=UE_1
    ...     direction=ul
    ...     duration=30s
    ...     throughput=500Mbits/sec
    ...     protocol=udp
    ...     packet_size=1400
    Sleep    5s
    Gather ELT Logs
    Log To Console    ELT logs gathered, closing tput, analyzing logs...
    [Teardown]    Run Keywords    taf.ue.Stop Data Transfer    dt_name=DT_DL_attach    AND
    ...                           taf.ue.Stop Data Transfer    dt_name=DT_UL_attach    AND
    ...                           Attenuate Source Cell

