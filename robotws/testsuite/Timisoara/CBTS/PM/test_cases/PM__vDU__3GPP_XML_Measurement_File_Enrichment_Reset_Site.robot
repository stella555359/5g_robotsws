*** Settings ***
Documentation  This suite contains PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site TC

Resource  ../test_resources/PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.robot


*** Test Cases ***
PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Setup]  TC Setup
    TC__PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Teardown]  TC Teardown
