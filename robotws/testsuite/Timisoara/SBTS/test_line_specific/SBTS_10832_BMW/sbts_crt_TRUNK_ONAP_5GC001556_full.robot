*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_N_1ASIL_1AHLOA    SBTS00
Library           XML  use_lxml=True
Resource          ../../ONAP/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot
Resource          ../../ONAP/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable.robot
Resource          ../../ONAP/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.robot
Resource          ../../ONAP/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.robot
Resource          ../../ONAP/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site.robot
Resource          ../../LOGS/LOGS__Snapshot.robot

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8087_Paracopter/commissioning/SCF_01_TRUNK.xml
${VM_WITH_PANO_IP}       10.44.157.22
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   Ut3pa5s#1be1
${VES_PORT}              30510
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8087_Paracopter/commissioning


*** Test Cases ***
[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_reset_site.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    14400
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

