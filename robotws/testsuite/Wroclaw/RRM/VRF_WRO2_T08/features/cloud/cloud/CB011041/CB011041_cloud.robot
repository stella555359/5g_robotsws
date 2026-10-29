*** Settings ***
Documentation
...    author: Michal Halucha
...    contact: michal.halucha@nokia.com

Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB011041/resources/test_specific_keywords.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB011041/resources/test_constants.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml

*** Test Cases ***
CB011041_PMO_A2_Alt1_CR_Counter_update_for_RAN_Paging_due_to_DL_cplane_msg
    [Setup]   Setup
    Start Tracing
    Trigger Attach
    Sleep  230s
    Stop Tracing
    Unzip Results
#    Analyze Emil Logs
    Analyze Syslog
    Sleep    300s
    Collect And Verify Vdu Pm Counters    ${vdu_pm_counters_dict}
    Collect And Verify Vcu Pm Counters    ${vcu_pm_counters_dict}
    [Teardown]   Run Keywords
    ...          Trigger Detach
    ...          Teardown UTF
