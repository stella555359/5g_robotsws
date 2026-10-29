*** Settings ***
Documentation  This suite contains COMPA__SBTS_SOAM_rollback_to_FDSW TC

Resource  ../test_resources/COMPA__SBTS_SOAM_rollback_to_FDSW.robot


*** Test Cases ***
COMPA__SBTS_SOAM_rollback_to_FDSW
    [Setup]  TC Setup
    TC__COMPA__SBTS_SOAM_rollback_to_FDSW
    [Teardown]  TC Teardown
