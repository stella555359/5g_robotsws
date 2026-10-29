*** Settings ***
Force Tags    QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NL_10340_1ASOE_2FRHC  STATE_COMMISSIONED
Library       XML  use_lxml=True

Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site.robot
Resource    ../../ONAP/test_resources/PANO__CB007010_G_Check_PM_files.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_A_13_Suppression_of_zero_values.robot


*** Variables ***
${SCF_ID}                01
${VM_WITH_PANO_IP}       10.5.20.171
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   ute
${VES_PORT}              30510
${HW_LOCATION_CODE}      Timisoara
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1340/commissioning
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1340


*** Test Cases ***
[1]CB007010-G_Check_PM_files
    [Tags]     QC_803492
    [Setup]    Run Keywords    PANO__CB007010_G_Check_PM_files.TC Setup
    ...    AND    Modify Resource Search Order    PANO__CB007010_G_Check_PM_files
    ...    AND    Set Library Search Order    PANO__CB007010_G_Check_PM_files
    [Timeout]    14400
    TC__PANO__CB007010_G_Check_PM_files
    [Teardown]    Run Keywords    PANO__CB007010_G_Check_PM_files.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Tags]     QC_803494
    [Setup]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    ...    AND    Set Library Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    [Timeout]    14400
    TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Teardown]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Tags]     QC_803493
    [Setup]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    ...    AND    Set Library Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Timeout]    14400
    TC__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Teardown]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    [Tags]     QC_803499
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Tags]     QC_803495
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    [Tags]     QC_803496
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Tags]     QC_803497
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Tags]     QC_803498
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.TC Teardown
    ...    AND    Restore Resource Search Order

