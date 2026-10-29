*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI121143/resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Test Setup          Test Setup
Test Teardown       Test Teardown
*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT302/ue_config.yaml
&{CONFIGURATION}         pyro_port=9092    com_port=COM3    python=python
${CODES}    +CGPADDR:
${GNB_1_CELL_1_ALIAS}       GNB_1_CELL_1
${GNB_1_CELL_2_ALIAS}       GNB_1_CELL_2
${GNB_1_CELL_3_ALIAS}       GNB_1_CELL_3
${GNB_2_CELL_1_ALIAS}       GNB_2_CELL_1
${GNB_2_CELL_2_ALIAS}       GNB_2_CELL_2

*** Test Cases ***
[1][1.0] CNI-121143_B1_PCI_Res_Failure_No_NR_CGI
    CNI-121143_B1_PCI_Res_Failure_No_NR_CGI
