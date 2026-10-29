*** Settings ***
Documentation    Author: changyan.li@nokia-sbell.com
...              \n General_SiSo_Online_Sector_Addition_Deletion.

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot



*** Variables ***


*** Keywords ***
General_SiSo_Online_Sector_Addition_Deletion
	[Arguments]   ${vdu_index}=0   ${gnb_index}=0   ${rmod_id}=1    ${test_name}=default
   [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to perform online sector (with min. one cell) addition and
    ...    - deletion from WebUI under tested configuration (which is capable of adding another sector)..
    ...    - [PARAMETERS]
    ...    - vdu_index: the index of vdu, default value is 0
    ...    - gnb_index: the index of gnb, default value is 0
    ...    - rmod_id: ru id
    ...    - test_name: test name
    ...    - [TEST METHODOLOGY] The test case is executed by following the steps below:
    ...    - 1. Check vDU and vCU all cells reach onair.
    ...    - 2. Get All cell Ids list by rmod_id (at least one cell in gived rmod_id).
    ...    - 3. Delete all cells in RU provided by rmod_id and check all RUs status normal on vDU
    ...    - 4. Check L3 call is ok on all cells.
    ...    - 5. Add all cells in step3 deleted and check all RUs status normal on vDU and cells onair
    ...    - 6. Check L3 call is ok on all cells.
    ...    - 7. check cell list is equal init.
    ...    - [TEST EXPECTED RESULT] The RU should recover and Site should be onair after Radio Power Reset.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    Step1:Check vDU and vCU all cells reach onair
    Step2:Get All cell Ids list by rmod_id    vdu_index=${vdu_index}   gnb_index=${gnb_index}    rmod_id=${rmod_id}
    Step3:Delete all cells in RU provided by rmod_id
    Step4:Check L3 call is ok on all cells after delete cell
    Step5:Add all cells in step3 deleted and check all RUs status normal on vDU and cells onair
    Step6:Check L3 call is ok on all cells
    Step7:Check cell list


Step1:Check vDU and vCU all cells reach onair
    Log To Console    \n****step1:Check vDU and vCU all cells reach onair
    Wait Until Keyword Succeeds    5min    5s    All Cells Should Be Onair For All vDUs
    Log To Console    \n****check cell status should be on air for vCU...
    wait until keyword succeeds     5min    30s    All Cells Should Be Onair For One Specific vCU

Step2:Get All cell Ids list by rmod_id
    [Arguments]   ${vdu_index}=0   ${gnb_index}=0   ${rmod_id}=1
    Log To Console   step2:Get All cell Ids list by rmod_id
    ${conn_alias}   generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${rmod_list}    create list    ${rmod_id}
    ${cell_list}    Get Cloud vDU Specific RU Related Cell id    rmods_id_list=${rmod_list}    alias=${conn_alias}
    set test variable    ${cell_list}
    log to console  cell_list=${cell_list}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Step3:Delete all cells in RU provided by rmod_id
    ${del_vdu_cell_list}    create list
    ${del_vcu_cell_list}    create list
    ${del_vdu_cell_times}    set variable    ${0}
    ${del_vcu_cell_times}    set variable    ${0}

    Log To Console   step3:Delete all cells in RU provided by rmod_id and check all RUs status normal on vDU
    FOR    ${cell_index}    IN    @{cell_list}
        ${del_vdu_cell_dict}    ${vdu_scf_path}     Cloud vDu Delete Cell By Cell Index    deleted_cell_index=${cell_index}
        ${del_vdu_cell_times}    Evaluate    ${del_vdu_cell_times}+1
        ${del_vcu_cell_dict}    ${vcu_scf_path}    Cloud vCU Delete Cell By Cell Index    deleted_cell_index=${cell_index}
        ${del_vcu_cell_times}    Evaluate    ${del_vcu_cell_times}+1
        Append To List     ${del_vdu_cell_list}    ${del_vdu_cell_dict}
        Append To List     ${del_vcu_cell_list}    ${del_vcu_cell_dict}
        Run keyword if    ${del_vdu_cell_times}==1    set test variable    ${vdu_old_scf_path}    ${vdu_scf_path}
        Run keyword if    ${del_vcu_cell_times}==1    set test variable    ${vcu_old_scf_path}    ${vcu_scf_path}
        wait until keyword succeeds     5min    30s    Verify All RU Status Should Be Normal on vDU
    END
    set test variable    ${del_vdu_cell_list}   
    set test variable    ${del_vcu_cell_list}

Step4:Check L3 call is ok on all cells after delete cell
    [Arguments]   ${test_name}=default
    Log To Console   step4:Check tput is ok on all cells after delete cells.
    ${cell_index_list}   vDU Get Cell List From Webem
    Log To Console    cell_index_list=${cell_index_list}
    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}    test_name=${test_name}

Step5:Add all cells in step3 deleted and check all RUs status normal on vDU and cells onair
    Log To Console   step5:Add all cells in step3 deleted and check all RUs status normal on vDU and cells onair.
    FOR    ${cell_index}    IN    @{cell_list}
        ${index}=    Get Index From List    ${cell_list}    ${cell_index}
        Cloud vDU Add Cell By Copy Cell    base_cell_id=${cell_index}    cell_dict=${del_vdu_cell_list[${index}]}
        ...    scfc_load_file=${vdu_old_scf_path}
        Cloud vCU Add Cell By Copy Cell    base_cell_id=${cell_index}    cell_dict=${del_vcu_cell_list[${index}]}
        ...    scfc_load_file=${vcu_old_scf_path}
    END

    Wait Until Keyword Succeeds    10min    10s    All Cells Should Be Onair For All vDUs
    Log To Console    \n****check cell status should be on air for vCU...
    wait until keyword succeeds     10min    30s    All Cells Should Be Onair For One Specific vCU

Step6:Check L3 call is ok on all cells
    [Arguments]   ${test_name}=default
    Log To Console   step5:Check tput is ok on all cells after add cells.
    ${cell_index_list}   vDU Get Cell List From Webem
    Log To Console    cell_index_list=${cell_index_list}
    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}    test_name=${test_name}

Step7:Check cell list
    [Arguments]   ${vdu_index}=0   ${gnb_index}=0   ${rmod_id}=1
    Log To Console   check cell list is equal with init
    ${conn_alias}   generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${rmod_list}    create list    ${rmod_id}
    ${new_cell_list}    Get Cloud vDU Specific RU Related Cell id    rmods_id_list=${rmod_list}    alias=${conn_alias}
    Log To Console   new_cell_list=${new_cell_list}
    Should Be Equal   ${new_cell_list}    ${cell_list}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}
