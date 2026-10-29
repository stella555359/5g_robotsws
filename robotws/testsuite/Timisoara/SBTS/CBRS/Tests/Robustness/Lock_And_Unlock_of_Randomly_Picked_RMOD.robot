*** Settings ***
Documentation
...  Block and unblock of randomly picked RMOD from all available RMOD on eNB in loops.
...
...  Author Katarzyna Kądziela
...  katarzyna.kadziela@nokia.com
...
...  Lock randomly picked RMOD.
...  Verify RMOD status by checking if administrativeState=Locked in every iteration.
...  Unlock picked RMOD.


Library    ute_fsmaccess
Resource    ./../../Resources/cbrs_common_keywords.robot


*** Variables ***
${NUMBER_OF_LOOPS}   2
${ALIAS}   RAT_1ST

*** Test Cases ***

Lock And Unlock of Randomly Picked RMOD
    [Setup]    Test Precondition

    Kill All SAS Processes
    Start SAS Process

    FOR    ${loop_nr}    IN RANGE    1    ${NUMBER_OF_LOOPS}+1
        Log To Console With Time  \n------------------- Lock and unlock RMOD: ${loop_nr}/${NUMBER_OF_LOOPS} -------------------
        Run Keywords    Perform Lock/Unlock of Randomly Picked RMOD

        Wait Until Keyword Succeeds    2x    30s    Run Keywords
        ...    Wait Until BTS Is Not Busy    AND
        ...    Check Cells    admin_alias=${ALIAS}

        Wait Until Keyword Succeeds    2x    30s    Run Keywords
        ...    Wait Until BTS Is Not Busy    AND
        ...    Admin Alarms Get And Check    allowed=${enb_allowed_alarms}    alias=${alias}
    END

    [Teardown]      Test Postcondition




