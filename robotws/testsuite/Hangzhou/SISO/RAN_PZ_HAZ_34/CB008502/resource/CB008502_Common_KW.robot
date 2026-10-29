*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../../CB006277/resource/resources_l3call.robot
Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot

*** Variables ***

*** Keywords ***
BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI
    [Arguments]
    General_gnb_can_be_on_air_with_Given_Information    frame_structure=1208_GP1_A1    prach_index=92
 	...    band=40
    Modify CABLINK Link Speed to eCpri10
    ${cell_list}    create list    ${1}
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}


Modify CABLINK Link Speed to eCpri10
    [Arguments]
    log to console  Modify CABLINK Link Speed to eCpri10
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${object_list}    selenium_coam.get_object_name_list    object_name=CABLINK-
    ${object_num}   Get Length   ${object_list}
    set test variable   ${change_counter}   ${0}
    FOR  ${object_id}  IN RANGE    1   ${object_num+1}
            ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${object_id}
            ...   filter_param=Link speed    abbr=linkSpeed
            Run Keyword If    '${currect_status}'=='eCpri25'   Run keywords    selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${object_id}
            ...    filter_param=Link speed    abbr=linkSpeed
            ...    new_value=eCpri10    node_index=${0}  AND
            ...    set test variable   ${change_counter}   ${change_counter+1}
    END
    Run Keyword If    ${change_counter}>0   Run keywords   selenium_coam.validate_plan   AND
    ...   selenium_coam.activate_plan   AND
    ...   Sleep  5min   AND
    ...   Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
