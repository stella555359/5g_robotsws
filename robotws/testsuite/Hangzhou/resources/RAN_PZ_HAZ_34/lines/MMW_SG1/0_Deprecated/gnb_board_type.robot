*** Settings ***
Documentation
...   This is for different gnb board type, eg, ASIB
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot


*** Keywords ***
# WARN  deprecated, please donot use it
Connect to Capacity Unit Slave case
    [Documentation]    Author: Wang Yixiang
    ...    connection is different with ASIK and ASIB
    [Arguments]    ${alias}=ABIL Slave    ${hw_slot}=1    ${master_alias}=ASIK Master
    Connect to Capacity Unit Slave    hw_slot=${hw_slot}    alias=${alias}    asik_alias=${master_alias}

# WARN  deprecated, please donot use it
Connect to Capacity Unit Master case
    [Documentation]    Author: Wang Yixiang
    ...    connection is different with ASIK and ASIB
    [Arguments]    ${alias}=ABIL Master    ${master_alias}=ASIK Master
    Connect to Capacity Unit Master    alias=${alias}    asik_alias=${master_alias}

# WARN  deprecated, please donot use it
Connect to Capacity Unit Loner case
    [Documentation]    Author: Wang Yixiang
    ...    connection is different with ASIK and ASIB
    [Arguments]    ${alias}=ABIL Loner    ${master_alias}=ASIK Master
    Connect to Capacity Unit Loner    alias=${alias}    asik_alias=${master_alias}
