*** Settings ***
Documentation
...  author/contact: adam.proszek@nokia.com

Library        testsuite.Wroclaw.SyVe.SISO.resources.CommonTests.FullCommissioningTest

Test Setup       prepare testline
Test Teardown    cleanup the setup and collect logs if the test fails

*** Test Cases ***
COMMISSIONING_TEST
    FOR    ${i}    IN RANGE    10
        perform commissioning test   ${SCF_FILE}
        wait for all cells on air
    END

