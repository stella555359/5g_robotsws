*** Settings ***
Documentation  This suite contains COMPA__Update_CMP_IPSEC_certificates_on_SBTS TC

Resource  ../test_resources/COMPA__Update_CMP_IPSEC_certificates_on_SBTS.robot


*** Test Cases ***
COMPA__Update_CMP_IPSEC_certificates_on_SBTS
    [Setup]  TC Setup
    TC__COMPA__Update_CMP_IPSEC_certificates_on_SBTS
    [Teardown]  TC Teardown
