*** Settings ***
Documentation
...    author: Michal Halucha
...    contact: michal.halucha@nokia.com


Resource    ./resources/test_specific_keywords_cloud.robot

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml

*** Test Cases ***
CB010414_parity_CB009010_A_CB009010_A_TC19_Inter_vDU_handover
    [Setup]  Test Setup
    CB010414_parity_CB009010_A_CB009010_A_TC19_Inter_vDU_handover
    [Teardown]    Teardown
