*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot

# Suite Setup       Common MultiBTS Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# Test Teardown     Common MultiBTS Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM

Force Tags        RAN_VRF_HAZ1

Test Timeout      120 minutes

*** Variables ***
${wait_time}    1000

${rule1}    Catenate
...         Distname: All;
...         Counter: M55110C00001;
...         Counter rule: delta_value(M55110C00001)<=10
${rule2}    Catenate
...         Distname: All;
...         Counter: M55110C00001;
...         Counter rule: delta_precent(M55110C00001)<=2
${rule_list}    Create List    ${rule1}    ${rule2}

${counter_rule_folder}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test/Counter_Operation_Rule


*** Test Cases ***
TC01_Counter_Operation_Wrong_Operation
    [Tags]    TC01
    ${case_result}    ${out}    Run Keyword And Ignore Error    Counter Operation    operation=asdf
    ...                                                                              product_type=gnb
    ...                                                                              bts_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC02_Counter_Operation_Wrong_Product_Type
    [Tags]    TC02
    ${case_result}    ${out}    Run Keyword And Ignore Error    Counter Operation    operation=start_collect_counter
    ...                                                                              product_type=asdf
    ...                                                                              bts_index=0
    ...                                                                              counter_rule=${rule_list}
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC03_Counter_Operation_No_Counter_Rule
    [Tags]    TC03
    ${case_result}    ${out}    Run Keyword And Ignore Error    Counter Operation    operation=start_collect_counter
    ...                                                                              product_type=gnb
    ...                                                                              bts_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC04_Counter_Operation_List_Counter_Rule
    [Tags]    TC04
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55110C00001;
    ...         Counter rule: delta_value(M55110C00001)<=10
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55110C00001;
    ...         Counter rule: delta_precent(M55110C00001)<=2
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    Sleep    60s
    ${result}    Counter Operation    operation=collect_counter
    Log To Console    \nCounter Rule Collect Result is: ${result}

TC05_Counter_Operation_Txt_Counter_Rule
    [Tags]    TC05
    Counter Operation    operation=start_collect_counter
    ...                  product_type=gnb
    ...                  bts_index=0
    ...                  counter_rule=${counter_rule_folder}/counter_rule.txt
    Log To Console    \nStart to collect counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Log To Console    \nStill need to wait ${rest_time}s
    END
    ${result}    Counter Operation    operation=collect_counter
    Log To Console    \nCounter Rule Collect Result is: ${result}

    Log To Console    \nStart to collect and check counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Log To Console    \nStill need to wait ${rest_time}s
    END
    ${result}    Counter Operation    operation=collect_counter_and_check_rule
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

TC06_Counter_Operation_Txt_Counter_Rule_Compare
    [Tags]    TC06
    Counter Operation    operation=start_collect_counter
    ...                  product_type=gnb
    ...                  bts_index=0
    ...                  counter_rule=${counter_rule_folder}/counter_rule.txt
    Log To Console    \nStart to collect counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result1}    Counter Operation    operation=collect_counter
    Log To Console    \nCounter Rule Collect Result1 is: ${result1}

    Log To Console    \nStart to collect counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result2}    Counter Operation    operation=collect_counter
    Log To Console    \nCounter Rule Collect Result2 is: ${result2}

    ${compare_result}    Counter Operation    operation=compare
    ...                  before_counter_value=${result1}
    ...                  after_counter_value=${result2}
    Log To Console    \nCounter Rule Compare Result is: ${compare_result}


