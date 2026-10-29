*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test cases

Resource          ../PA_Operation.robot

Force Tags        RAN_VRF_HAZ1

Test Timeout      30 minutes



*** Test Cases ***
TC01_No_Source_No_Target_List
    [Tags]    CRT    TC01
    ${case_result}    Run Keyword And Ignore Error    PA Operation    source=none    target=none
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC02_Source_List_Only_Increase_Value
    [Tags]    CRT    TC02
    ${source_pa_port_list}     Create List     1    2    17    18    35
    ${source_pa_value_list}    Create List     23    61
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=none

TC03_Target_List_Only_Increase_Value
    [Tags]    CRT    TC03
    ${target_pa_port_list}     Create List    37   38    39    53    54    55
    ${target_pa_value_list}    Create List    13    59
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=none    target=&{target}

TC04_Source_List_Only_Decrease_Value
    [Tags]    CRT    TC04
    ${source_pa_port_list}     Create List     1    2    17    18    35
    ${source_pa_value_list}    Create List     59    26
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=none

TC05_Target_List_Only_Decrease_Value
    [Tags]    CRT    TC05
    ${target_pa_port_list}     Create List    37-39   53    54-55
    ${target_pa_value_list}    Create List    59    26
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=none    target=&{target}

TC06_Source_Target_List_Both
    [Tags]    CRT    TC06
    ${source_pa_port_list}     Create List     1    18
    ${source_pa_value_list}    Create List     0    40
    ${target_pa_port_list}     Create List    37    54
    ${target_pa_value_list}    Create List    63    30
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=&{target}

TC07_Source_Target_List_Both
    [Tags]    CRT    TC07
    ${source_pa_port_list}     Create List     1    18
    ${source_pa_value_list}    Create List     50    10
    ${target_pa_port_list}     Create List    37    54
    ${target_pa_value_list}    Create List    10    62
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=&{target}

TC08_Source_List_Value_OutofRang
    [Tags]    CRT    TC08
    ${source_pa_port_list}     Create List     1    2    17    18    35
    ${source_pa_value_list}    Create List     784    25
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=none

TC09_Target_List_Value_OutofRange
    [Tags]    CRT    TC09
    ${target_pa_port_list}     Create List    37   38    39    53    54    55
    ${target_pa_value_list}    Create List    278    33
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=none    target=&{target}

TC10_Target_List_Value_OutofRange
    [Tags]    CRT    TC10
    ${source_pa_port_list}     Create List     1    18
    ${source_pa_value_list}    Create List     273    40
    ${target_pa_port_list}     Create List    37    54
    ${target_pa_value_list}    Create List    63    765
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=&{target}

TC11_Target_List_Only_Decrease_Value
    [Tags]    CRT    TC11
    ${source_pa_port_list}     Create List     1-2    17-18    35
    ${source_pa_value_list}    Create List     50    10
    ${target_pa_port_list}     Create List    37-39   53    54-55
    ${target_pa_value_list}    Create List    10    62
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}
    PA Operation    source=&{source}    target=&{target}

TC12_Get Port And Value
    [Tags]    CRT    TC12
    PA Operation    operation=Get PA Port And Value
    ...             product_type=vdu
    ...             bts_index=${0}
    ...             du_index=${0}
    ...             ru_index=${0}
    ...             att_index=${0}

TC13_Initialize PA Value
    [Tags]    CRT    TC13
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters    pa_port=5-8;1,2;9;    pa_value=0;127;127;
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${10}
    PA Operation    operation=Initialize PA Value    source=&{source}



