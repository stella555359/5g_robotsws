*** Settings ***
Documentation     author: Annie Hu
...               Group: HGZ_SG5
...               contact: Annie.hu@nokia-sbell.com


Resource          ../../5GC002118/Resource/5GC002118_common_KW.robot
Variables         ../TestData/frame_structure_variables_modify.py

*** Variables ***
#${frame_structure}             1116_0ms_GP2_A7
#${band}                       100


*** Keywords ***
General_SiSo_E2E_with_data_transfer
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to
    ...    ******************
    ...    History of changes
    ...    ******************
    ${both_name}  ${bandwidth}  split String From Right  ${TEST_NAME}  _  1
    ${pattern_1}   Set Variable     [0-9]+
    @{match_1}    Get Regexp Matches     ${bandwidth}    ${pattern_1}
    set test variable  ${band}  ${match_1[0]}
    ${test_flag}  set variable  PASS
    FOR  ${frame_structure}  IN  @{frame_structure_list_${band}MHz}
        set test variable  ${frame_structure}
        ${status}  run keyword and ignore error  Modify Frame Structure And Check Throughput
        ${test_flag}  set variable  ${status[0]}
    END
    run keyword if  '${test_flag}'=='FAIL'  fail   not all frame structure pass
















