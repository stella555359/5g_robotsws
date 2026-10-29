*** Settings ***
Documentation
...   Test suite for regression testing of feature  CNI-130230
...   author: Julia Luszcz
...   author/contact: julia.luszcz@nokia.com


*** Keywords ***
Lane_blocking_using_FR_5GC000955_in_a_loop
    [Arguments]    ${lanes_dict}    ${iterations}=${20}
    FOR  ${iter}    IN RANGE    ${iterations}
        Lock Unlock All Lanes One by One   ${lanes_dict}
    END
