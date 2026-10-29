*** Settings ***
Documentation  This suite contains COMPA__FDSW_upgrade_to_SBTS_SOAM TC

Resource  ../test_resources/COMPA__FDSW_upgrade_to_SBTS_SOAM.robot


*** Test Cases ***
COMPA__FDSW_upgrade_to_SBTS_SOAM
    [Setup]  TC Setup
    TC__COMPA__FDSW_upgrade_to_SBTS_SOAM
    [Teardown]  TC Teardown
