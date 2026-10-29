*** Settings ***
Documentation
...    author: Adam Kropiwnicki
...    contact: adam.kropiwnicki@nokia.com

Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB010751/resources/test_specific_keywords_cloud.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml

*** Test Cases ***
CB010751_CR_Periodic_RNAU_after_Intra-CU_Inter-DU_Inter_NRCELL_reselection_with_the_same_RANAC
    [Setup]  Setup
    Start Tracing
    Attach RedCap UE
    Sleep  5 minutes 20 seconds
    Trigger Cell Reselection
    Stop Tracing
    Check UE Log
    [Teardown]   Run Keywords
    ...          Detach RedCap UE
    ...          Teardown ELT
    ...          Teardown DCAP
