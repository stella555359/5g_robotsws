*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot

# Suite Setup       Common Suite Setup For AIC
# Suite Teardown    Common Suite Teardown For AIC
# Test Setup        Common Test Setup For AIC
# Test Teardown     Common Test Teardown For AIC

Force Tags        RAN_VRF_HAZ1

Test Timeout      120 minutes

*** Variables ***
${wait_time}    300

${counter_rule_folder}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test/Counter_Operation_Rule

*** Test Cases ***
TC01_Counter_Operation_Wrong_Operation_Vdu
    [Tags]    TC01
    ${case_result}    ${out}    Run Keyword And Ignore Error    Counter Operation    operation=asdf
    ...                                                                              product_type=vdu
    ...                                                                              bts_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC02_Counter_Operation_Wrong_Operation_Vcu
    [Tags]    TC02
    ${case_result}    ${out}    Run Keyword And Ignore Error    Counter Operation    operation=asdf
    ...                                                                              product_type=vCU
    ...                                                                              bts_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC03_Counter_Operation_Wrong_Product_Type
    [Tags]    TC03
    ${case_result}    ${out}    Run Keyword And Ignore Error    Counter Operation    operation=start_collect_counter
    ...                                                                              product_type=asdf
    ...                                                                              bts_index=0
    ...                                                                              counter_rule=${rule_list}
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC04_Counter_Operation_No_Counter_Rule
    [Tags]    TC04
    ${case_result}    ${out}    Run Keyword And Ignore Error    Counter Operation    operation=start_collect_counter
    ...                                                                              product_type=vcu
    ...                                                                              bts_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC05_Counter_Operation_List_Counter_Rule
    [Tags]    TC05    Counter
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C09014;
    ...         Counter rule: delta_value(M55125C09014)<=10
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C09014,M55113C00001;
    ...         Counter rule: M55125C09014!=M55113C00001
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list}
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result}    Counter Operation    operation=collect_counter    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result is: ${result}

TC06_Counter_Operation_Txt_Counter_Rule
    [Tags]    TC06    Counter
    Counter Operation    operation=start_collect_counter
    ...                  product_type=vcu
    ...                  bts_index=0
    ...                  counter_rule=${counter_rule_folder}/counter_rule_cloud.txt
    Log To Console    \nStart to collect counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result}    Counter Operation    operation=collect_counter    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result is: ${result}

    Log To Console    \nStart to collect and check counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

TC07_Counter_Operation_Txt_Counter_Rule_Compare
    [Tags]    TC07    Counter
    Counter Operation    operation=start_collect_counter
    ...                  product_type=vcu
    ...                  bts_index=0
    ...                  counter_rule=${counter_rule_folder}/counter_rule_cloud.txt
    Log To Console    \nStart to collect counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result1}    Counter Operation    operation=collect_counter    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result1 is: ${result1}

    Log To Console    \nStart to collect counters,wait for ${wait_time}s...
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result2}    Counter Operation    operation=collect_counter    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result2 is: ${result2}

    ${compare_result}    Counter Operation    operation=compare
    ...                  before_counter_value=${result1}
    ...                  after_counter_value=${result2}
    Log To Console    \nCounter Rule Compare Result is: ${compare_result}


