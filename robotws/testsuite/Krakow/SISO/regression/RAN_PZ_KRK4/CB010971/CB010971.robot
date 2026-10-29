*** Settings ***
Documentation
...    author: Szymon Misiolek
...    contact: szymon.misiolek@nokia.com
...    Description: CB010971 testsuite

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     ./resources/CB010971_keywords.py    WITH NAME    10971_keywords


Test Timeout  24 hours

#Suite Setup         Common Suite Setup
Suite Setup         Run Keywords
...                 gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
...                 AND    Common Suite Setup With Commissioning    prefix_tag=CB010971    asir_hub=${True}
Suite Teardown      Common Suite Teardown
#Test Setup          Common Preconditions
#Test Teardown       Common Postconditions


*** Variables ***

${gnb_id}           ${tl.gnbs[0].dus[0].global_bts_id}
#${TEST_QC_ID}       66105      #trunk QC ID
@{additional_allowed_alarms}
...    WiFi Configuration Issue


*** Test Cases ***
CB009077_E_15_Storing_location_into_Black_Box_NVM_after_SW_update

    Check Snapshot 10971
#    ...    should_be_reported=${SHOULD_BE_REPORTED}
#    ...    should_be_reported=${False}
