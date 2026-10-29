*** Settings ***
Documentation  This suite contains ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name TC

Resource  ../test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name.robot

*** Test Cases ***
ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Setup]  TC Setup
    [Teardown]  TC Teardown
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
