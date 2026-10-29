*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_1vDU34_O_AHBCC  STATE_COMMISSIONED
Library           XML  use_lxml=True
Documentation  This suite contains CloudBTS TC

Resource    ../../../PM/test_resources/PM__vCU__Check_PM_File_On_Pano_Server.robot
Resource    ../../../PM/test_resources/PM__vCU__Break_Connection_To_Pano.robot
Resource    ../../../PM/test_resources/PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.robot


*** Variables ***
${ADDITIONAL_IGNORED_ALARMS}  [['fault_id', '4639', 'fault_name', 'Problem sending VES event to SMO/ONAP VES Endpoint']]


*** Test Cases ***
[1]PM__vCU__Check_PM_File_On_Pano_Server
    [Tags]     QC_127521
    [Timeout]    14400
    [Setup]    PM__vCU__Check_PM_File_On_Pano_Server.TC Setup
    TC__PM__vCU__Check_PM_File_On_Pano_Server
    [Teardown]    PM__vCU__Check_PM_File_On_Pano_Server.TC Teardown


[1]PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Tags]     QC_127520
    [Timeout]    14400
    [Setup]    PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.TC Setup
    TC__PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Teardown]    PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.TC Teardown


[1]PM__vCU__Break_Connection_To_Pano
    [Tags]     QC_127522
    [Timeout]    14400
    [Setup]    PM__vCU__Break_Connection_To_Pano.TC Setup
    TC__PM__vCU__Break_Connection_To_Pano
    [Teardown]    PM__vCU__Break_Connection_To_Pano.TC Teardown


