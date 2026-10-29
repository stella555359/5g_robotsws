*** Settings ***
Documentation  This suite contains ONAP__5GC001556_3GPP_XML_measurement_file_enrichment TC

Resource  ../test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot

*** Test Cases ***
ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Setup]  TC Setup
    [Teardown]  TC Teardown
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
