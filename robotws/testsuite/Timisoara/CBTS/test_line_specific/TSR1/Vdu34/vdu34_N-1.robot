*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_1vDU34_O_AHBCC  STATE_COMMISSIONED
Library           XML  use_lxml=True
Documentation  This suite contains CloudBTS TC

Resource    ../../../PM/test_resources/PM__vDU__Check_PM_File_On_Pano_Server.robot
Resource    ../../../PM/test_resources/PM__vDU__Break_Connection_To_Pano.robot
Resource    ../../../PM/test_resources/PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.robot
Resource    ../../../PM/test_resources/PM__vCU__Check_PM_File_On_Pano_Server.robot
Resource    ../../../PM/test_resources/PM__vCU__Break_Connection_To_Pano.robot
Resource    ../../../PM/test_resources/PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.robot
Resource    ../../../PM/test_resources/PM__vCU__Sum_NR_Counters_Suppression.robot
Resource    ../../../PM/test_resources/PM__vDU__Sum_NR_Counters_Suppression.robot



*** Variables ***
${ADDITIONAL_IGNORED_ALARMS}  [['fault_id', '4639', 'fault_name', 'Problem sending VES event to SMO/ONAP VES Endpoint']]


*** Test Cases ***
[1]PM__vDU__Check_PM_File_On_Pano_Server
    [Tags]     QC_209068
    [Timeout]    14400
    [Setup]    PM__vDU__Check_PM_File_On_Pano_Server.TC Setup
    TC__PM__vDU__Check_PM_File_On_Pano_Server
    [Teardown]    PM__vDU__Check_PM_File_On_Pano_Server.TC Teardown


[1]PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Tags]     QC_209067
    [Timeout]    14400
    [Setup]    PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.TC Setup
    TC__PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Teardown]    PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.TC Teardown


[1]PM__vDU__Break_Connection_To_Pano
    [Tags]     QC_209066
    [Timeout]    14400
    [Setup]    PM__vDU__Break_Connection_To_Pano.TC Setup
    TC__PM__vDU__Break_Connection_To_Pano
    [Teardown]    PM__vDU__Break_Connection_To_Pano.TC Teardown



[1]PM__vCU__Check_PM_File_On_Pano_Server
    [Tags]     QC_209068
    [Timeout]    14400
    [Setup]    PM__vCU__Check_PM_File_On_Pano_Server.TC Setup
    TC__PM__vCU__Check_PM_File_On_Pano_Server
    [Teardown]    PM__vCU__Check_PM_File_On_Pano_Server.TC Teardown


[1]PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Tags]     QC_209067
    [Timeout]    14400
    [Setup]    PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.TC Setup
    TC__PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Teardown]    PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.TC Teardown


[1]PM__vCU__Break_Connection_To_Pano
    [Tags]     QC_209066
    [Timeout]    14400
    [Setup]    PM__vCU__Break_Connection_To_Pano.TC Setup
    TC__PM__vCU__Break_Connection_To_Pano
    [Teardown]    PM__vCU__Break_Connection_To_Pano.TC Teardown


PM__vCU__Sum_NR_Counters_Suppression
    [Tags]     QC_222535
    [Setup]    PM__vCU__Sum_NR_Counters_Suppression.TC Setup
    TC__PM__vCU__Sum_NR_Counters_Suppression
    [Teardown]    PM__vCU__Sum_NR_Counters_Suppression.TC Teardown

PM__vDU__Sum_NR_Counters_Suppression
    [Tags]     QC_222535
    [Setup]    PM__vDU__Sum_NR_Counters_Suppression.TC Setup
    TC__PM__vDU__Sum_NR_Counters_Suppression
    [Teardown]    PM__vDU__Sum_NR_Counters_Suppression.TC Teardown
