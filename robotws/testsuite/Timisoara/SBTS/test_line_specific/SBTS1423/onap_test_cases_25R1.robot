*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLWG_10423_2ASIL_2ABIA_1ABIO_1ABIQ_1ABIN_1ABIP_2FXDB_1FRGU_1FRME_2FXED_3AHEGB 
Library       XML  use_lxml=True

Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_A_13_Suppression_of_zero_values.robot


*** Variables ***
${SCF_ID}                01
${VM_WITH_PANO_IP}       10.5.20.171
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   UTE.debian12
${VES_PORT}              30510
${HW_LOCATION_CODE}      Timisoara
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1423/commissioning
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1423
${COMMISSIONING_PATH}    SEPARATOR=
    ...    /home/ute/testline_configuration/10_18_UTESRANCLOUD1423/node1/
    ...    BTS_CLOUD_SRAN_NLWG_10423_2ASIL_2ABIA_1ABIO_1ABIQ_1ABIN_1ABIP_2FXDB_1FRGU_1FRME_2FXED_3AHEGB_ONAP_25R1.xml


*** Test Cases ***

[1]Automated__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Tags]     QC_89370
    [Setup]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    ...    AND    Set Library Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    [Timeout]    14400
    TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Teardown]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Tags]     QC_89371
    [Setup]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    ...    AND    Set Library Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Timeout]    14400
    TC__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Teardown]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Tags]     QC_89372
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Tags]     QC_89374
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Tags]     QC_89373
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.TC Teardown
    ...    AND    Restore Resource Search Order

