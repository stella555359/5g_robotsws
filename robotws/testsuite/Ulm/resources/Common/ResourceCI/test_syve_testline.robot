*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in SyVe/resources/syve_testline.robot for classical deployments.


Library     taf.sbts.oam.coam.admin     WITH NAME   admin
Resource    ../../../SyVe/resources/syve_testline.robot

Suite Teardown   Teardown All Admin Sessions


*** Test Cases ***
Test Save current loads
    [TAGS]      SYVE
    Save Current Loads

*** Keywords ***
Teardown All Admin Sessions
    admin.Teardown All Aliases For Admin

