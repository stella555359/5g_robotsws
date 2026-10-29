*** Settings ***
Documentation    These are common keywords for CB010370 related cases
...              Please do not modify the file without notification to author
...              Contact: shifu.lan@nokia-sbell.com
...              Squard: HZ SG4

Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

*** Variables ***

*** Keywords ***
General_SiSo_Online_Modify_Channel_Bandwidth
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify CB010370 L3 call if normal after modifying the channel bandwidth online.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 02.22.2024 - - Created
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_shifu.lan@nokia-sbell.com
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${60}    ${ue_num_each_call}=1
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id    ru_index=1
    FOR    ${cell_id}    IN    @{cell_list}
	Log To Console    \nModify the chBw to 80MHz in cell ${cell_id}
        ${modify_params}  create list
        ${dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
	${item}  create dictionary  dist_name=${dist_name}    filter_param=Channel bandwidth    p_name=chBw    value=80MHz
	append to list  ${modify_params}  ${item}
	Modify Parameters On Webem    modify_params=${modify_params}
	Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
        run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    END

    Log To Console    \nModify the chBw to 100MHz in cell ${cell_list}
    ${rollback_modify_params}  create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
	${item}  create dictionary  dist_name=${dist_name}    filter_param=Channel bandwidth    p_name=chBw    value=100MHz
	append to list  ${rollback_modify_params}  ${item}
    END
    Modify Parameters On Webem    modify_params=${rollback_modify_params}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    [Teardown]  Selenium Logout And Close Browser

General_SiSo_Online_Cell_addition_deletion
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify CB010370 L3 call if normal after adding and deleting cells online.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 02.22.2024 - - Created
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${60}    ${ue_num_each_call}=1
    ...    ${connection}=GNB_OAM
    Selenium Login And Disable Screen Lock
    Prepare for delete NRPGRP
    Online delete NRPGRP

    @{addition_deletion_cell_list}    create list    ${2}    ${4}    ${6}
    ${scf_path}    ${cell_grp}    ${lcrid_list}    ${addition_deletion_cellgrp_list}     Prepare for Online Cell Addition Deletion
    ...    addition_deletion_cell_list=${addition_deletion_cell_list}
    Online Cells Deletion    ${addition_deletion_cell_list}    ${addition_deletion_cellgrp_list}    ${cell_grp}

    @{cell_list}    get all cell id
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

    Online Cells Addition    ${addition_deletion_cell_list}    ${addition_deletion_cellgrp_list}    ${lcrid_list}    ${cell_grp}    ${scf_path}
    Online_Modify_Channel_Bandwidth    cell_id=${addition_deletion_cell_list[0]}    chBw=80MHz
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    [Teardown]    Selenium Logout And Close Browser

Online_Modify_Channel_Bandwidth
    [Documentation]    shifu.lan@nokia-sbell.com
    [Arguments]    ${cell_id}    ${chBw}
    Log    \nModify the chBw to ${chBw} in cell ${cell_id}    console=${True}
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Channel bandwidth    abbr=chBw    new_value=${chBw}
    Activate Parameters
