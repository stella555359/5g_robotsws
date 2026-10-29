*** Settings ***
Resource    ../test_resources/CM_LTE_Cell_reconfiguration_to_different_antenna_port.robot

*** Test Cases ***
CM_LTE_Cell_reconfiguration_to_different_antenna_port
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CM_LTE_Cell_reconfiguration_to_different_antenna_port

