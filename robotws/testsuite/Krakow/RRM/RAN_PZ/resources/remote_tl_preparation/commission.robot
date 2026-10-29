*** Settings ***
Documentation
...    Description: Test case for TL commission

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Test Cases ***
TL_COMMISSIONING
    Perform Full Commissioning and Wait for onAir    prefix_tag=${SCF_PREFIX}    asir_hub=${ASIR}
