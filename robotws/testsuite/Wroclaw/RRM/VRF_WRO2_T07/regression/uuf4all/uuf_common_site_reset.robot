*** Settings ***
Documentation
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   Test suite for basic UUF site reset in loop:
...   - add  0x4F0214=0  flag to swconfig file,
...   - perform site reset of gNB,
...   - gather logs: snapshot, syslog,
...   - check HW state, faults, crashes in syslog,
...   - if iteration is failed it will try to recover gNB by performing site reset.
...   Number of Test Iteration, and additional custom allowed faults can be set by sending them as variables to pybot:
...   - -v TEST_ITERATION:X where X is number of iteration
...   - -v CUSTOM_FAULTS_ID:X,Y,Z where X,Y,Z are Faults ID
...   -  e.g. -v TEST_ITERATION:40 -v CUSTOM_FAULTS_ID:4011,1898 will change number of test iteration to 40 and
...   Faults with ID 4011 and 1898 will be added as allowed.

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T07/regression/uuf4all/uuf4all_resources.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Force Tags    CA_VRF_WRO2   STATE_SW_UPLOADED   CRT
...           RAN_5G    RAN_5G_FDD    RAN_5G_FDD_CD    RAN_5G_FDD_MP    RAN_5G_FDD_MP_CUSTOMER   RAN_5G_MP
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIB_ABIO_3xAZQO_ENB
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1_3xAHCA_ENB

Test Teardown    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

*** Variables ***
${RP_CA}                       VRF_RRM
${RP_LOCATION}                 VRF_WRO2
${RP_ORGANIZATION}             VRF_WRO2_T07
${TEST_ITERATION}              35
@{CRITICAL_FAULTS}             10
@{CUSTOMERS_LIST}              Generic
${SHOULD_BE_REPORTED}          ${True}
${QC_ID}                       45792
${QC_DOMAIN}                   MN_RAN
${QC_PROJECT}                  RAN_VRF

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         critical_alarms=@{CRITICAL_FAULTS}     custom_allowed_alarms=${CUSTOM_ALARMS}


@{NODES}                    ${GNB1}

*** Test Cases ***
UUF4ALL_ACTIVATION_RESET_TEST
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST
    ...         nodes_details=@{NODES}
    ...         test_nodes_details=&{GNB1}
    ...         iterations_per_node=${TEST_ITERATION}
    ...         report=${SHOULD_BE_REPORTED}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${QC_ID}
