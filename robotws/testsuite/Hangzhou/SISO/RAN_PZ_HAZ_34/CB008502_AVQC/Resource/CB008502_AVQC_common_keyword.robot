*** Settings ***
Documentation    These are common keywords for CB008502 related cases
...              Please do not modify the file without notification to author
...              Contact: shifu.lan@nokia-sbell.com
...              Squard: HZ SG4

Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py


*** Keywords ***
General_SiSo_Online_Modify_LinkSpeed
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify CB008502 L3 call if normal after modifying the linkspeed online.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 03.04.2024 - - Created
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_shifu.lan@nokia-sbell.com
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${60}    ${ue_num_each_call}=1
    ...    ${default_link_speed}=eCpri25    ${link_speed}=eCpri10
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id    ru_index=1
    ${object_list}    get_object_name_list    object_name=CABLINK-
    ${object_num}   Get Length   ${object_list}

    log to console    \nModify the linkSpeed to ${link_speed}
    ${modify_params}  create list
    FOR  ${object_id}  IN RANGE    2   ${object_num+1}
        ${dist_name}    set variable    MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${object_id}
	${item}  create dictionary  dist_name=${dist_name}    filter_param=Link speed    p_name=linkSpeed    value=${link_speed}
	append to list  ${modify_params}  ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

    log to console    \nModify the linkSpeed to ${default_link_speed}
    ${rollback_modify_params}  create list
    FOR  ${object_id}  IN RANGE    2   ${object_num+1}
        ${dist_name}    set variable    MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${object_id}
	${item}  create dictionary  dist_name=${dist_name}    filter_param=Link speed    p_name=linkSpeed    value=${default_link_speed}
	append to list  ${rollback_modify_params}  ${item}
    END
    Modify Parameters On Webem    modify_params=${rollback_modify_params}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    [Teardown]  Selenium Logout And Close Browser

General_SiSo_SFP56_AVQC_Radio_Unit_replacement
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify CB008502 configration if normal after replacing the Radio Unit.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 22.04.2024 - - Created
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_shifu.lan@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${bbmod_index}=${1}
    Selenium Login And Disable Screen Lock
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    Power Off RU    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}

    @{dist_names}  create list  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-2  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-4
    # CABLINK-2 linkspeed change from 25 to 10. https://jiradc.ext.net.nokia.com/browse/WESTLAKE-12106
    @{values}  create list    eCpri25    eCpri10
    Modify Cablinks LinkSpeed    dist_names=${dist_names}    values=${values}
    Sleep    30s
    Wait Until Keyword Succeeds    20min    60s    Check BBMOD if enabled status    bbmod_index=${bbmod_index}

    Power On RU    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_Fault_4679_was_triggered_with_SFP28
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify the fault 4679 if triggered when linkspeed over stability.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 07.05.2024 - - Created
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_shifu.lan@nokia-sbell.com
    [Arguments]    ${bbmod_index}=${1}
    Selenium Login And Disable Screen Lock
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

    @{dist_names}  create list  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-4
    @{values}  create list    eCpri50
    Modify Cablinks LinkSpeed    dist_names=${dist_names}    values=${values}
    Sleep    30s
    Wait Until Keyword Succeeds    20min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=4679
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

    @{values}  create list    eCpri25
    Modify Cablinks LinkSpeed    dist_names=${dist_names}    values=${values}
    Sleep    30s
    Wait Until Keyword Succeeds    20min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Absent    faultId=4679
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}
    [Teardown]    Selenium Logout And Close Browser

Power Off RU
    [Arguments]    ${ru_index}    ${model}
    Perform RU Power Off    ru_index=${ru_index}    model=${model}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}

Power On RU
    [Arguments]    ${ru_index}    ${model}
    Perform RU Power On    ru_index=${ru_index}    model=${model}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Online    ru_index=${ru_index}

Check BBMOD status
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM    ${operationalState}=enabled
                 ...    ${adminState}=unlocked    ${usageState}=active    ${proStatus}=configured
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['operationalState'].lower()}       ${operationalState}
                                  ...  msg=Current bbmod operationalState is not in ${operationalState} status
    Should be equal as strings    ${bbmod_status['status']['administrativeState'].lower()}    ${adminState}
                                  ...  msg=Current bbmod administrativeState is not in ${adminState} status
    Should be equal as strings    ${bbmod_status['status']['usageState'].lower()}       ${usageState}
                                  ...  msg=Current bbmod usageState is not in ${usageState} status
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus'].lower()}       ${proStatus}
                                  ...  msg=Current bbmod proceduralStatus is not in ${proStatus} status

Check BBMOD if enabled status
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM    ${operationalState}=enabled
                 ...    ${adminState}=unlocked    ${proStatus}=configured
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['operationalState'].lower()}       ${operationalState}
                                  ...  msg=Current bbmod operationalState is not in ${operationalState} status
    Should be equal as strings    ${bbmod_status['status']['administrativeState'].lower()}    ${adminState}
                                  ...  msg=Current bbmod administrativeState is not in ${adminState} status
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus'].lower()}       ${proStatus}
                                  ...  msg=Current bbmod proceduralStatus is not in ${proStatus} status

Modify Cablinks LinkSpeed
    [Arguments]    ${dist_names}    ${values}
    Log    Modify the LinkSpeed parameter of Cablink    console=${True}
    ${modify_params}  create list
    FOR  ${dist_name}  ${value}  IN ZIP  ${dist_names}  ${values}
        ${item}  create dictionary  dist_name=${dist_name}  filter_param=Link speed  p_name=linkSpeed  value=${value}
        append to list  ${modify_params}  ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
