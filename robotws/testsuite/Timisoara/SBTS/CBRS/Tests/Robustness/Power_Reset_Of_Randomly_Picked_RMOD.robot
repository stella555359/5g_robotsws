*** Settings ***
Documentation
...  Power Reset Of Randomly Picked RMOD from all available on eNB in loops.
...
...  Author Katarzyna Kądziela
...  katarzyna.kadziela@nokia.com
...
...  RMOD Powered Off.
...  Wait for cell service drop.
...  RMOD Powered On again

Library    ute_fsmaccess
Resource    ./../../Resources/cbrs_common_keywords.robot


*** Variables ***
${NUMBER_OF_LOOPS}   2
${ALIAS}   RAT_1ST

*** Test Cases ***

Power Reset Of Randomly Picked RMOD
    [Setup]    Test Precondition

    Kill All SAS Processes
    Start SAS Process

    FOR    ${loop_nr}    IN RANGE    1    ${NUMBER_OF_LOOPS}+1
        Log To Console With Time    \n------------------- Power Reset: ${loop_nr}/${NUMBER_OF_LOOPS} -------------------
        Run Keywords    Perform Power Reset Of Randomly Picked RMOD

        Wait Until Keyword Succeeds    2x    30s    Run Keywords
        ...    Wait Until BTS Is Not Busy    AND
        ...    Check Cells    admin_alias=${ALIAS}

        Wait Until Keyword Succeeds    2x    30s    Run Keywords
        ...    Wait Until BTS Is Not Busy    AND
        ...    Admin Alarms Get And Check    allowed=${enb_allowed_alarms}    alias=${alias}
    END

    [Teardown]    Test Postcondition




