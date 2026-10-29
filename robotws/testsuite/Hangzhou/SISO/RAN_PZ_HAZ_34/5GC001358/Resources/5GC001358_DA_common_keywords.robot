*** Settings ***
Documentation
...    author: fangmin.wu
...    contact:fangmin.wu@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : 5GC001358-DA

#Library     Collections
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_group_id.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
*** Variables ***
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
###UE##
${SN}                       ${tl.ues[0].serial_number}
${ue_type}                  ${tl.ues[0].capabilities[1]}
${SAVE LOG DIRECTORY}    /home/ute/Downloads/
*** Keywords ***
Change parameter value
    [Arguments]    ${para_name}    ${para_value}
    coam.perform_parameter_recommissioning      dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...                                         parameter=${para_name}
    ...                                         operation=update
    ...                                         value=${para_value}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM

Get parameter value
    [Arguments]    ${para}
    ${bts_info}=  coam.get_current_scf_content    connection=GNB_OAM
    ${value}    get lines containing string    ${bts_info}    ${para}
    ${value}    remove string    ${value}    <p name="${para}">    </p>    ${SPACE}
    ${value}    fetch from left    ${value}    ${\n}
    [Return]    ${value}
Lock all RUs and check all status
#    [Arguments]  ${ru_index_list}    ${cell_list}
    log to console  \n**Lock all RUs and check all status***
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
    END
    wait until keyword succeeds    2min    20sec    Cell status Should Be Disabled    cell_list=${cell_list}
    sleep    1min
    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300

UnLock all RUs and check all status
#    [Arguments]     ${ru_index_list}    ${cell_list}
    log to console  \n**UnLock all RUs and check all status***
    UnLock all RUs
    wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_list}
    Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300

Cell status Should Be Disabled
    [Arguments]  ${cell_list}  ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    log to console  \n**Cell status Should Be Disabled***
    FOR  ${cell_idx}  IN  @{cell_list}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_idx}
        ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
        ...                                      cell_group_idx=${cell_group_idx}
        ...                                      timeout=${timeout}
        ...                                      connection=${connection}
        Should Be Equal As Strings   ${subcell_status["operationalState"]}    Disabled
        Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}    Dependency
    END

Cell status Should Be enabled
    [Arguments]  ${cell_list}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    log to console    \n**Cell status Should Be enabled**
    FOR  ${cell_idx}  IN  @{cell_list}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_idx}
        ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
        ...                                      cell_group_idx=${cell_group_idx}
        ...                                      timeout=${timeout}
        ...                                      connection=${connection}
        Should Be Equal As Strings   ${subcell_status["operationalState"]}   Enabled
        Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}  Online
    END

Get X2 link shutdown waiting time
    [Arguments]  ${connection}=GNB_OAM
    log to console  \n***Get X2 link shutdown waiting time ***
    ${nrbts_objects}    coam.get_managed_objects    class_name=NRBTS_A    connection=${connection}
    ${get_time}   coam.get_parameters    dist_name=${nrbts_objects[0]['distName']}    pattern=shutdownNogNBCellTmr     connection=${connection}
    ${X2_link_shutdown_time}    get from dictionary    ${get_time}    shutdownNogNBCellTmr
    set test variable  ${X2_link_shutdown_time}

Selenium Login And Disable Screen Lock
    coam navigate to login page via webui
    selenium_coam.disable_screen_lock

Wait until cell is on air status
    [Arguments]  ${timeout}=15 min    ${connection}=GNB_OAM
    log    ${timeout}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair

UnLock all RUs
     FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
     END

Power UE Precondition
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}    ${gnb_index}=${0}
     Log To Console    \n ###UE attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
