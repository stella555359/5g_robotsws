*** Settings ***
Resource    ../../resources/pretest_posttest.robot

*** Keywords ***
1546-CA Suite Preconditions
     Suite Preconditions

1546-CA Suite Postconditions
    Suite Postconditions

1546-CA Test Preconditions
    Test Preconditions
    SYSTEM Get Time From Various Time Sources    #temporary in order to monitor/check time difference issue
    ${time_offset}    SYSTEM Get Local Timezone Time Offset
    Set Suite Variable    ${time_offset}

1546-CA Test Postconditions
    Test Postconditions
