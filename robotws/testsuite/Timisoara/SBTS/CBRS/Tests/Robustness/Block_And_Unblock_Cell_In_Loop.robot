*** Settings ***
Documentation
...  Block and unblock of randomly picked cell from all available cells on eNB in loops.
...
...  Author Katarzyna K?dziela
...  katarzyna.kadziela@nokia.com
...
...  Block randomly picked cell.
...  Verify cell status by checking fault list in every iteration.
...  Unblock picked cell.


Library    ute_fsmaccess
Resource    ./../../Resources/cbrs_common_keywords.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition


*** Variables ***
${NUMBER_OF_LOOPS}   2
${ALIAS}   RAT_1ST
${CONTINUE_ON_FAIL}  TRUE

*** Test Cases ***

Block And Unblock Cell In Loop
    [Setup]    Test Precondition

    Kill All SAS Processes
    Start SAS Process

    FOR    ${loop_nr}    IN RANGE    1    ${NUMBER_OF_LOOPS}+1
        Log To Console With Time    \n------------------- Block and Unblock Cell: ${loop_nr}/${NUMBER_OF_LOOPS} -------------------
        IF  ${CONTINUE_ON_FAIL}
            Run Keyword And Continue On Failure    Perform Block Unblock Of Randomly Picked Cells
        ELSE
            Perform Block Unblock Of Randomly Picked Cells
        END

        Wait Until Keyword Succeeds    2x    30s    Run Keywords
        ...    Wait Until BTS Is Not Busy    AND
        ...    Check Cells    admin_alias=${ALIAS}

        Wait Until Keyword Succeeds    2x    30s    Run Keywords
        ...    Wait Until BTS Is Not Busy    AND
        ...    Admin Alarms Get And Check    allowed=${enb_allowed_alarms}    alias=${alias}
    END

    [Teardown]    Test Postcondition


