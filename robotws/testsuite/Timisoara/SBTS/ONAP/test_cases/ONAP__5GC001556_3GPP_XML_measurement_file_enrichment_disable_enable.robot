*** Settings ***
Documentation  This suite contains ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable TC

Resource  ../test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable.robot

*** Test Cases ***
ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
    [Setup]  TC Setup
    [Teardown]  TC Teardown
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
