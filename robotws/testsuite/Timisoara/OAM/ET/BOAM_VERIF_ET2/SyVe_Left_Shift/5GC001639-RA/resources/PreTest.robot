*** Settings ***
Resource    ../../resources/pretest_posttest.robot
#Resource    wrappers.robot
Resource    ../../CommonKeywords/logs_collecting/gather_logs_for_test_analysis.robot
Resource    ../../CommonKeywords/custom_commissionings.robot
Resource    ../../resources/admin.robot

*** Keywords ***
1639-RA Suite Preconditions
    Suite Preconditions
    Set mrbtsId variable

1639-RA Suite Postconditions
    Suite Postconditions

1639-RA Test Preconditions
    Test Preconditions

1639-RA Test Postconditions
    Test Postconditions

