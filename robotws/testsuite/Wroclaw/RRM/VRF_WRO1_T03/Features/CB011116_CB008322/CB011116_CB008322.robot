*** Settings ***
Documentation
...     Test case setup for feature CB011116 with covering feature CB008322

Resource    CB011116_CB008322_resources/CB011116_resources.robot
Resource    CB011116_CB008322_resources/CB008322_resources.robot

Suite Setup    Connect To Admin
Suite Teardown    Close Admin Connection

*** Variables ***
&{ONE_UE_CAPABILITY}    REAL_UE_1=NR_UE1
&{TWO_UES_CAPABILITY}    REAL_UE_1=NR_UE1    REAL_UE_2=NR_UE2

*** Test Cases ***
CB011116
    [Tags]    CB011116
    CB011116 Test Case Scenario

CB008322_G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SRS_POWER
    [Tags]    CB008322_SRS_POWER
    CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SRS_POWER Test Case Scenario

CB008322_G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SCHED_PRB
    [Tags]    CB008322_SCHED_PRB
    CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_SCHED_PRB Test Case Scenario

CB008322_G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_RANK
    [Tags]    CB008322_REL_RANK
    CB008322 G2 Enhancement for dynamic fallback SB_BF_CONF_REL_RANK Test Case Scenario
