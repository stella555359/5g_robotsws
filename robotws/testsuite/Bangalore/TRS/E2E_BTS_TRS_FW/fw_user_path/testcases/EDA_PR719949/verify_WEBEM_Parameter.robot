*** Settings ***
Documentation
...				[Author]         "Pooja K"
...				[Maintenance]    "TRS I & V Tools Bangalore Team"
...				[Precondition]   " "

...				[Description] 	  SSH status is wrong on secondary core when connection between SMOD broken


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        resources/kw.robot

Suite setup    Run Keywords    setup oamops
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Teardown oamops
...            AND    Teardown Oamops    dut=chained_bts    alias=secondary


*** Variables ***
${index}                    1
${length}                   1

*** Test Cases ***
[1][SMTRS-31040][LDT][Trunk][Fullrack] SSH status is wrong on secondary core when connection between SMOD broken
    Run Keywords        Suite Setup Preconditions
    FOR    ${index}    IN RANGE    ${length}
       Continue Keyword Execution On Failure     ${True}
       Poweroff_BTS    RRB1        ${RRB1['PrimaryBTSPortID']}
       Sleep   120
       Verify rechability of SecondaryBTS
       Sleep   120
       Change Rnd Port Security    enable=True     timeout=300     alias=secondary
       Sleep   60
       Change Ethernet Port Security   disable=True     timeout=300     alias=secondary
       Sleep   60
       Change Ssh Access   enable=True     timeout=300     alias=secondary
       Sleep   20
       Change Rnd Port Security    disable=True     timeout=300     alias=secondary
       Sleep   60
       Change Ethernet Port Security   enable=True     timeout=300     alias=secondary
       Sleep   60
       Change Ssh Access   disable=True     timeout=300     alias=secondary
       Sleep   60
       Poweron_BTS        RRB1    ${RRB1['PrimaryBTSPortID']}
       Sleep    120
       verify BTS basic status
    END
