*** Settings ***
Documentation    Suite description
...          stability cases

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/robustness_stability_test_lib/stability.robot

Suite Setup       Stability Suite Precondition
Suite Teardown    Suite Postcondition

Test Timeout       168h

*** Test Cases ***
Stability Ru lock And Unlock All
    [Setup]    Stability Testcase Basic Precondition    case_name=stabilityRuLocck&Unlock
    FOR    ${i}    IN RANGE    ${repetition}
        Ru lock And Unlock All
    END
    [Teardown]    Stability Testcase Basic Postcondition

Stability Cell Block And Unblock All
    [Setup]    Stability Testcase Basic Precondition    case_name=stabilityCellLocck&Unlock
    FOR    ${i}    IN RANGE    ${repetition}
        Cell Block And Unblock All
    END
    [Teardown]    Stability Testcase Basic Postcondition

Stability Site Reset
    [Setup]    Stability Testcase Basic Precondition    case_name=stabilitySiteReset
    FOR    ${i}    IN RANGE    ${repetition}
        Site Reset
    END
    [Teardown]    Stability Testcase Basic Postcondition

Stability BBMOD Reset
    [Setup]    Stability Testcase Basic Precondition    case_name=stabilityBbmodReset
    FOR    ${i}    IN RANGE    ${repetition}
        BBMOD Reset
    END
    [Teardown]    Stability Testcase Basic Postcondition

Stability Bts Power Reset
    [Setup]    Stability Testcase Basic Precondition    case_name=stabilityBtsPowerReset
    FOR    ${i}    IN RANGE    ${repetition}
        Bts Power Reset
    END
    [Teardown]    Stability Testcase Basic Postcondition

Stability SISO_Recovery RF module reset
    [Setup]    Stability Testcase Basic Precondition    case_name=stabilityRfReset
    FOR    ${i}    IN RANGE    ${repetition}
        SISO_Recovery RF module reset
    END
    [Teardown]    Stability Testcase Basic Postcondition

