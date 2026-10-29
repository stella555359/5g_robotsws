*** Settings ***
Force Tags
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         Setup Suite for CB007078
Suite Teardown      Teardown Suite for CB007078
Resource          Resource/CB007078_Resources.robot

*** Variables ***


*** Test Cases ***
[1]CB007078_N_11_Message check for internal plan update for CPNRT
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case for CB007078
    [Teardown]  Teardown case for CB007078
     TC.CB007078_N_11_Message check for internal plan update for CPNRT

[1]CB007078_I_06_Message check between NRTS and Cplan for delta plan activation procedure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case for CB007078
    [Teardown]  Teardown case for CB007078
    TC.CB007078_I_06_Message check between NRTS and Cplan for delta plan activation procedure

[1]CB007078_F_03_Message check between NRTS and Cplan for initial configuration procedure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case for CB007078
    [Teardown]  Teardown case for CB007078
    TC.CB007078_F_03_Message check between NRTS and Cplan for initial configuration procedure

[1]CB007078_M_10_Message check for internal plan update for CPNB
    [Tags]    CRT_TRUNK
    [Setup]    Setup case for CB007078
    [Teardown]  Teardown case for CB007078
    TC.CB007078_M_10_Message check for internal plan update for CPNB

[1]CB007078_DGJKL_Message check for internal plan update
    [Tags]    CRT_TRUNK
    [Setup]    Setup case for CB007078
    [Teardown]  Teardown case for CB007078
    TC.CB007078_DGJKL_Message check for internal plan update

[1]CB007078_OPQ_HA_check
    [Tags]    CRT_TRUNK
    [Setup]    Setup case for CB007078
    [Teardown]  Teardown case for CB007078
    TC.CB007078_OPQ_HA_check