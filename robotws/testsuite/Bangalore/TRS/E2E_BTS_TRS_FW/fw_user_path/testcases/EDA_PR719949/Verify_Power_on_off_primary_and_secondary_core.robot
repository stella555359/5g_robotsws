*** Settings ***
Documentation
...				[Author]         "Pooja K"
...				[Maintenance]    "TRS I & V Tools Bangalore Team"
...				[Precondition]   "Primary and secondary core's should be in sync"

...				[Description] 		Power_on and Power_off on primary and secondary core & verify unexpected alarms after reset


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        resources/kw.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown        Teardown Oamops


*** Variables ***
${index}                    1
${length}                   1

*** Test Cases ***
[1][1.0][SMTRS-30307][PR706671]Implement to Cover specific power off on primary& secondary core and verify the core or unexpected alarms after reset

       verify BTS basic status
       Verify power_on_off on PM & SN core
