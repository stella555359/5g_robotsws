*** Settings ***
Documentation  Test suite onap
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_LWG_1ASIB_2ABIA_1ABIL_1FRGU_2FXCB_1AHOLA

Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_A_13_Suppression_of_zero_values.robot



*** Variables ***
${SCF_ID}                01
${VM_WITH_PANO_IP}       10.5.20.171
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   UTE.debian12
${VES_PORT}              30510
${HW_LOCATION_CODE}      Timisoara
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1456/commissioning
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1456
${COMMISSIONING_PATH}    SEPARATOR=
    ...    /home/ute/testline_configuration/10_18_UTESRANCLOUD1456/node1/
    ...    BTS_CLOUD_SRAN_LWG_1ASIB_2ABIA_1ABIL_1FRGU_2FXCB_1AHOLA_SBTS25R2_ONAP.xml



*** Test Cases ***

[1]Automated__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Tags]     QC_160151
    [Setup]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    ...    AND    Set Library Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    [Timeout]    14400
    TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Teardown]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Tags]     QC_160149
    [Setup]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    ...    AND    Set Library Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Timeout]    14400
    TC__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Teardown]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Tags]     QC_160148
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Tags]     QC_160150
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Teardown
    ...    AND    Restore Resource Search Order




