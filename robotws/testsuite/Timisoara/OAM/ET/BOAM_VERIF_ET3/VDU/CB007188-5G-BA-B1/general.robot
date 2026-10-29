*** Settings ***
Documentation
...    Author: Andrada Bugiu
...    Maintainer: Andrada Bugiu (andrada.bugiu@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: DOORS
...    Feature Description: CB007188-5G-BA-B1
...    Execution command:  robot -L TRACE -b debug.log general.robot

Resource   ./resources/CB007188-5G-BA-B1.robot
Resource   ./resources/xpath_7188-5G-BA-B1.robot

Suite Setup  run keyword  Login vDU
Suite Teardown  run keyword and ignore error  Run Keywords  Delete DeltaPlan  Logout vDU

*** Test Cases ***

[1][1.0] 3. NRCELL.dlMimoMode parameter modification with cell locking
    [Tags]  CRT
    Modify parameter with object locking
    Check object locking

[1][1.0] 4. NRCELL.dlMimoMode parameter modification with vDU reset
    [Tags]  CRT
    Delete DeltaPlan
    Modify parameter with vDU reset
    Check vdu reset
