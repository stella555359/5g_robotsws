*** Settings ***
Library     BuiltIn
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem

Library     taf.transport.ssh       WITH NAME    csn
Library     taf.collectors.btslog   WITH NAME    btslog
Library     taf.collectors.core     WITH NAME    core
Library     taf.sbts.oam.coam.admin    WITH NAME    coam

Resource    L3Call.robot
Resource    LogCollection.robot

# Resource    ../../common/taf_coam.robot
Resource    ../../common/L3_Call.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

# Variables   ../../libraries/global_vars.py


*** Variables ***


*** Keyword ***
Common Setup
    Log To Console   ${EMPTY}

Common Teardown
    Log To Console   ${EMPTY}
