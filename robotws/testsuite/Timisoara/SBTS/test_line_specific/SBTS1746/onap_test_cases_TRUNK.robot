*** Settings ***
Documentation    Onap Test Cases
Force Tags    QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLWG_1746_1ASIM_2ABIA_1ABIO_1FXED_1FRGU_2AHFIB  STATE_COMMISSIONED
Library       XML  use_lxml=True

Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot
Resource    ../../ONAP/test_resources/PANO__5GC001104_A_13_Suppression_of_zero_values.robot

${COMMISSIONING_PATH}    SEPARATOR=
    ...    /home/ute/testline_configuration/10_18_UTESRANCLOUD1746/node1/
    ...    BTS_CLOUD_SRAN_NLWG_1746_1ASIM_2ABIA_1ABIO_1FXED_1FRGU_2AHFIB_SBTS00_ONAP.xml

*** Variables ***
${SCF_ID}                01
${VM_WITH_PANO_IP}       10.5.20.171
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   UTE.debian12
${VES_PORT}              30510
${HW_LOCATION_CODE}      Timisoara
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1746/commissioning
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1746


*** Test Cases ***

[1]Automated__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Tags]     QC_133686
    [Setup]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    ...    AND    Set Library Search Order    PANO__5GC001104_A_13_Suppression_of_zero_values
    [Timeout]    14400
    TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Teardown]    Run Keywords    PANO__5GC001104_A_13_Suppression_of_zero_values.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Tags]     QC_133684
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Linux_mapping
    Run    curl -s -o linux_mapping.sh https://wrgitlab.int.net.nokia.com/adrosa/linux-mapping/-/raw/main/linux_mapping.sh?inline=false
    Run    chmod +x linux_mapping.sh
    Run    ./linux_mapping.sh

