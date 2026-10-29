*** Settings ***
Documentation  This suite contains PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site TC

Resource  ../test_resources/PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.robot


*** Test Cases ***
PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Setup]  TC Setup
    TC__PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Teardown]  TC Teardown
