*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

#Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter  WITH NAME  coam_parameter
#Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_group_id.py
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot


*** Keywords ***
# Step SiSo keywords
# ${mrbtsID} and ${nrbtsID} set suite variable in SISO Coam Suite Setup
Download SCF Download Via Rest Api
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    [Arguments]    ${scf_dir_path}=${OUTPUT DIR}    ${connection}=GNB_OAM
    ${scf_path}    COAM Download scf from cluster    scf_dir_path=${scf_dir_path}    connection=${connection}
    [Return]    ${scf_path}

COAM Wait gnb And Cells ready
    [Arguments]   ${timeout}=10 min    ${connection}=GNB_OAM    ${gnb_type}='NSA'    ${gnb_index}=0
    coam wait for gnb ready and cell setup    timeout=${timeout}    connection=${connection}     gnb_type=${gnb_type}
    ...    gnb_index=${gnb_index}
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair    connection=${connection}

Get Cell Nband
    [Arguments]    ${cell_id}=1    ${connection}=GNB_OAM
    ${output}    coam.get_cells_info    connection=${connection}
    FOR  ${cell}  IN  @{output}
        ${nband}    set variable     ${cell['band']}
        return from keyword if    ${cell['globalCellId']}==${cell_id}    ${nband}
    END

Get bbmod name
    [Arguments]    ${cell_id}=1    ${connection}=GNB_OAM
    ${modDNList}    get_modDNList_via_admin    cell_id=${cell_id}    connection=${connection}
    ${output}=    coam.get_fbb_info    timeout=30    connection=${connection}
    FOR    ${bbmod}    IN    @{output}
        ${bbmod_configuration}    set variable    ${bbmod['id']['configuration']}
        ${productName}    set variable    ${bbmod['productName']}
        return from keyword if    '${bbmod_configuration}'=='${modDNList[0]}'    ${productName}
    END

Get gNB CU type
    [Arguments]  ${connection}=GNB_OAM
    ${NRBTS_A_objects}    coam.get_managed_objects    class_name=NRBTS_A    connection=${connection}
    ${gNb_CuType_d}   coam.get_parameters    dist_name=${NRBTS_A_objects[0]['distName']}    pattern=gNbCuType     connection=${connection}
    ${gNb_CuType}    Get From Dictionary    ${gNb_CuType_d}    gNbCuType
    [Return]  ${gNb_CuType}

update swconfig for gNB
    [Arguments]    ${connection}=GNB_OAM
    log to console    \n update /ffs/run/swconfig.txt
    ${asik_addr_temp}   set variable if      '${testline_name}' == 'null'    192.168.255.129    ${asik_addr}
    ${FSM_TYPE}    COAM Get FSM Type    connection=${connection}
    @{rest}    String.split string    string=${Active_SW_version}    separator=.
    ${flag_path}   set variable if      '${FSM_TYPE}' == 'ASIB'    ${rest}[0].${rest}[1]_ASIB    ${rest}[0].${rest}[1]
    ${BASE_PATH}     Get Substring  ${CURDIR}  0  -57
    ${swconfig_path}   Set Variable    ${BASE_PATH}/custom-config/${flag_path}/swconfig.txt
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${swconfig_path}
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass -p ${asik_password} scp ${swconfig_path} ${asik_username}@${asik_addr_temp}:/ffs/run/   shell=yes
    csn.connect_to    ${asik_addr_temp}    ${asik_username}    ${asik_password}    alias=OAM
    csn.execute    command=chmod 777 /ffs/run/swconfig.txt    connection=OAM
    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=OAM
    log to console    \n ${swconfig_output}
    csn.execute    command=crasign /ffs/run/swconfig.txt    connection=OAM
    [Teardown]  run keywords  COAM Teardown gnb connections    AND    csn.disconnect    connection=OAM

Commissioning SCF And Check On Air
    [Arguments]  ${scf_path}    ${timeout}=15    ${connection}=GNB_OAM    ${gnb_index}=0
    Log to console    +++Commissioning SCF And Check On Air+++
    Log to console    SCF Path:${scf_path}
    COAM Commission with scf file  scf_file_path=${scf_path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    ...    connection=${connection}
    sleep    300s
    COAM Wait gnb And Cells ready    timeout=${timeout} min    gnb_type='${gNb_CuType}'
    ...                              connection=${connection}    gnb_index=${gnb_index}

Unexpect History Alarm Should Not Exist
    [Documentation]   Auther: zhihao.shi@nokia-sbell.com
    ...               Description: check unexpect history alarm exist or not ,if yes, save it to file
    ...               :param allowed_faults<list>: list contains dictionary, dict keys can be only faultId or faultId with source
    ...                    eg. [{"faultId":7300}]
    ...                        [{"faultId":61524,"source":"/SMOD_R-1"}]
    ...                        [{"faultId":61524,"source":"CABINET-1/SMOD_R-1"},{"faultId":7300}]
    ...               :param log_path<str>: saved alarm to path , default is testcase log path.
    ...               :param connection<str>：coam admin connection , default is GNB_OAM
    [Arguments]   ${allowed_faults}
    ...           ${file_path}=${TS_CASE_LOG_PATH}
    ...           ${connection}=GNB_OAM
    ${history_alarms_list}    coam.get_historic_alarms    connection=${connection}    timeout=100    load_history=${True}
    ${history_alarms_num}     Get Length    ${history_alarms_list}
    ${unexpect_alarms}    Create List
    FOR  ${alarm}  IN  @{history_alarms_list}
       Exit For Loop If   ${history_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       Run Keyword If   ${status}==${False}    Append To List    ${unexpect_alarms}   ${alarm}
       Run Keyword If   ${status}==${False}    Log to console    Unexpect History Alarm : ${alarm['faultId']}
    END
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    Set variable    ${file_path}/unexpect_history_alarms_${timestamp}.txt
    ${alarm_num}   Get Length   ${unexpect_alarms}
    Run Keyword If  ${alarm_num}!=${0}    Run   command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    FOR  ${alarm}  IN  @{unexpect_alarms}
        Exit For Loop If  ${alarm_num}==${0}
        run    command=echo "${alarm}">>${unexpect_alarm_file}
    END
    Run Keyword If   ${alarm_num}!=${0}   fail   ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}

get current bts configuration
    [Arguments]  ${connection}=GNB_OAM
    ${ru_index_list}  Get All RU Index
    ${ru_num}   Get Length   ${ru_index_list}
    ${cell_index_list}  Get All Cell Id   ru_index=${1}
    ${cell_num}   Get Length   ${cell_index_list}
    ${nrcell_objects}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}
    ${nrCellType_d}   coam.get_parameters    dist_name=${nrcell_objects[0]['distName']}    pattern=nrCellType     connection=${connection}
    ${nrCellType}    get from dictionary    ${nrCellType_d}    nrCellType
    ${nrCellType}    Replace string    ${nrCellType}    L    -
    ${nrCellType}    Get Substring    ${nrCellType}    0    -1
    ${configuration}    set variable    ${ru_num}S-${cell_num}CC-${nrCellType}
    Log to console    BTS Current Configuration:${configuration}
    [Return]   ${configuration}

Gnb should be onair with cell up
    [Arguments]    ${connection}=GNB_OAM
    log to console  \n***Gnb should be onair with cell up***
    COAM Check GNB cell on air    connection=${connection}
    Verify all cells should be onair    connection=${connection}

Save Coam Snapshot
    [Arguments]    ${target_dir}=${OUTPUT DIR}     ${coverage}=Full    ${force}=${True}     ${timeout}=1500    ${connection}=GNB_OAM
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_path}      Set Variable    ${target_dir}/Snapshot_${time_stamp}.zip
    ${log_status}         Run Keyword And Return Status    coam.Get Snapshot
    ...                   target_file_name=${snapshot_path}
    ...                   coverage=${coverage}
    ...                   force=${force}
    ...                   connection=${connection}
    ...                   timeout=${timeout}
    Run Keyword If        ${log_status}    Log To Console    Collecting Snapshot [DONE]

Save Coam im snapshot
    [Arguments]    ${target_dir}=${OUTPUT DIR}     ${timeout}=300    ${connection}=GNB_OAM
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_path}      Set Variable    ${target_dir}/Snapshot_${time_stamp}.ims2
    ${log_status}         Run Keyword And Return Status    coam.collect_im_snapshot
    ...                   target_file_name=${snapshot_path}
    ...                   connection=${connection}
    ...                   timeout=${timeout}
    Run Keyword If        ${log_status}    Log To Console    Collecting im Snapshot [DONE]

Get List of NR Cell ID
    Get nr cell id mapping if not exist
    ${info}   get dictionary values    ${nr_cell_id_mapping}
    ${list_of_cell_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_cell_ids}   ${cur_nridentiity}
    END
    [Return]    ${list_of_cell_ids}

Lock all RUs SISO
    [Arguments]    ${ru_index_list}    ${connection}=GNB_OAM
    log to console  \n***Lock all RUs***
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru  ru_index=${ru_index}
        sleep  30
    END
    connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}    connection=${connection}
    END

Unlock all RUs SISO
    [Arguments]      ${ru_index_list}    ${connection}=GNB_OAM
    log to console  \n***Unlock all RUs***
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.unlock_ru  ru_index=${ru_index}
        sleep  30
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds  5min  20sec  RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
    END
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=${connection}

Get RU type
    [Arguments]  ${ru_index}=1
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
    ${ru_type}   set variable  ${ru_info}[productName]
    [Return]  ${ru_type}

Get X2 link shutdown waiting time
    [Arguments]  ${connection}=GNB_OAM   ${timeout}=10
    ${nrbts_objects}    coam.get_managed_objects    class_name=NRBTS_A    connection=${connection}    timeout=${timeout}
    ${get_shutdownNogNBCellTmr}   coam.get_parameters    dist_name=${nrbts_objects[0]['distName']}
    ...    pattern=shutdownNogNBCellTmr     connection=${connection}
    ${shutdown_no_gnb_cell_time}    get from dictionary    ${get_shutdownNogNBCellTmr}    shutdownNogNBCellTmr
    ${get_x2LinkSupervisionTmr}   coam.get_parameters    dist_name=${nrbts_objects[0]['distName']}
    ...    pattern=x2LinkSupervisionTmr     connection=${connection}
    ${X2_link_shutdown_time}    get from dictionary    ${get_x2LinkSupervisionTmr}    x2LinkSupervisionTmr
    ${X2_link_shutdown_time}   Evaluate  ${X2_link_shutdown_time} + ${shutdown_no_gnb_cell_time}
    log to console  \nX2 link shutdown waiting time(shutdownNogNBCellTmr+x2LinkSupervisionTmr):${X2_link_shutdown_time} mins
    set test variable  ${X2_link_shutdown_time}

Get Cell Numbers
    [Documentation]  get cell numbers
    [Arguments]  ${connection}=GNB_OAM
    ${cells_info}=    coam.get_cells_info    connection=${connection}
    ${cell_nums}    Get Length    ${cells_info}
    [Return]  ${cell_nums}

Get RMODs info
    [Arguments]  ${connection}=GNB_OAM
    ${hw_info}   coam.get_detected_hw_info   timeout=20    connection=${connection}
    ${rmod_info}   Create Dictionary
    FOR    ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        ${SFP}=    Get RMOD SFP info    ${rmod}
        Set To Dictionary   ${rmod_info}    ${rmod['id']['configuration']}=${SFP}
    END
    [Return]   ${rmod_info}

Get RMOD SFP info
    [Arguments]    ${rmod}
    ${rmod_SFP_info_list}   Create List
    ${ports}=    Get From Dictionary    ${rmod}    ports
    ${numb_of_ports}=    Get Length    ${ports}
    FOR   ${sfp}    IN RANGE    ${numb_of_ports}
        ${rmod_SFP_info}=    Fetch From Right    ${ports[${sfp}]['id']['internal']}    SFP_R-
        ${SFP_length}    Get Length    ${rmod_SFP_info}
        Run Keyword If    ${SFP_length}>1    Continue For Loop
        ${rmod_SFP_info}=    Catenate    SEPARATOR=    SFP-    ${rmod_SFP_info}
        Append To List    ${rmod_SFP_info_list}    ${rmod_SFP_info}
    END
    [Return]   ${rmod_SFP_info_list}

Get dlMimoMode Value Via API
    [Documentation]   Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}    ${connection}=GNB_OAM
    ${result}    coam.get_parameters_for_all    class_name=NRCEL    connection=${connection}
    FOR    ${item}    IN    @{result}
        ${value}    set variable if    '${item['configurationId']}'=='${cell_id}'    ${item['dlMimoMode']}    ${None}
        exit for loop if    '${value}' !='${None}'
    END
    [Return]     ${value}

COAM get ru port type
    [Arguments]    ${connection}=GNB_OAM
    ${resp}  coam.get_detected_hw_info    connection=${connection}
    @{port_list}  set variable  ${resp['radioModules']['rmod'][0]['ports']}
    ${port_type}   Set Variable    TEMP
    FOR    ${port}    IN    @{port_list}
        ${port_type}    Set variable    ${port['label']}
         Exit For Loop If  '${port_type}'=='PHYANT' or '${port_type}'=='ANT1'
    END
    [Return]  ${port_type}

Get All BBmod Index
    [Documentation]   Author:lanwen.cai@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    ${bbmod_info}    coam.get_fbb_info     connection=${connection}
    ${bbmod_nums}    get length    ${bbmod_info}
    ${bbmod_index_list}    create list
    FOR  ${bbmod}  IN  @{bbmod_info}
        ${bbmod_id_configuration}  set variable  ${bbmod['id']['configuration']}
        ${bbmod_index}    get regexp matches    ${bbmod_id_configuration}    BBMOD-(.)    1
        append to list    ${bbmod_index_list}    ${bbmod_index[0]}
    END
    Sort List   ${bbmod_index_list}
    [Return]  ${bbmod_index_list}

Get bbmod info by bbmod index
    [Documentation]  Author:lanwen.cai@nokia-sbell.com
    [Arguments]    ${bbmod_index}=1    ${connection}=GNB_OAM
    ${bbmod_index}    Convert to string    ${bbmod_index}
    ${bbmod_info}    coam.get_fbb_info     connection=${connection}
    &{dict_bbmods_info}   Create dictionary
    FOR    ${bbmod}    IN    @{bbmod_info}
        ${status}    Run Keyword And Return Status    Should Contain   '${bbmod}'   BBMOD-${bbmod_index}
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_bbmods_info}    ${bbmod_index}    ${bbmod}
    END
    [Return]  ${dict_bbmods_info['${bbmod_index}']}

Get Release Flag
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    [Return]  ${result}

Get Cell Group Id Via Cell Id
    [Arguments]  ${cell_idx}   ${timeout}=${20}   ${connection}=GNB_OAM
    TRY
        ${cell_info}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_idx}
    EXCEPT
        ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
        ${cell_index}    convert to integer    ${cell_idx}
        ${cell_group_idx}    Get From Dictionary    ${cell_mapping}[${cell_index}]    cell_group_id
    END
    [Return]    ${cell_group_idx}

Cell status Should Be Disabled
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Cell status Should Be Disabled
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${cell_list}  ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    log to console  \n**Cell status Should Be Disabled***
    ${result}    get release flag    connection=${connection}
    ${operationalState}   set variable if      ${result}    Disabled    disabled
    ${availabilityStatus}   set variable if      ${result}    Dependency    dependency
    FOR  ${cell_idx}  IN  @{cell_list}
        ${cell_group_idx}    Get Cell Group Id Via Cell Id    cell_idx=${cell_idx}   timeout=${timeout}    connection=${connection}
        ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
        ...                                      cell_group_idx=${cell_group_idx}
        ...                                      timeout=${timeout}
        ...                                      connection=${connection}
        Should Be Equal As Strings   ${subcell_status["operationalState"]}    ${operationalState}
        Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}    ${availabilityStatus}
    END

Cell status Should Be enabled
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Cell status Should Be enabled
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${cell_list}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    log to console    \n**Cell status Should Be enabled**
    ${result}    get release flag    connection=${connection}
    ${operationalState}       set variable if      ${result}    Enabled    enabled
    FOR  ${cell_idx}  IN  @{cell_list}
        ${cell_group_idx}    Get Cell Group Id Via Cell Id    cell_idx=${cell_idx}   timeout=${timeout}    connection=${connection}
        ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
        ...                                      cell_group_idx=${cell_group_idx}
        ...                                      timeout=${timeout}
        ...                                      connection=${connection}
        Should Be Equal As Strings   ${subcell_status["operationalState"]}    ${operationalState}
        run keyword if    ${result}    Should Be Equal As Strings    ${subcell_status["availabilityStatus"]}  Online
    END

Cell status Should Be Degraded
    [Arguments]   ${cell_list}   ${cell_type}=nr   ${timeout}=10    ${connection}=GNB_OAM
    FOR  ${cell_idx}  IN  @{cell_list}
        Log to console    Check cell ${cell_idx} of ${cell_type} should be degraded
        ${cell_group_idx}    Get Cell Group Id Via Cell Id    cell_idx=${cell_idx}   timeout=${timeout}    connection=${connection}
        ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
        ...                                      cell_group_idx=${cell_group_idx}
        ...                                      timeout=${timeout}
        ...                                      connection=${connection}
        Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}     degraded
    END

get ru log id by synchronization OPT_IF
    [Arguments]  ${connection}=GNB_OAM
    ${links}=    coam.get_sfp_links   timeout=20    connection=${connection}
    ${connected}=    Get From Dictionary    ${links}    connected
    ${numb_of_links}=    Get Length    ${connected}
    ${link_index}    set variable    0
    FOR    ${link}    IN RANGE    ${numb_of_links}
        ${link}    Evaluate  ${link}+1
        ${value}    Get Parameter Via Webem    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/HWTOP_R-1/CABLINK_R-100${link}
	    ...    filter_param=Link Mode Synchronization in Runtime
        ${link_index}    set variable if    '${value}'=='true'    ${link}    0
	    exit for loop if    '${value}'=='true'
    END
    ${pre_log_num}=    Set Variable If
    ...     ${link_index}==1        1811
    ...     ${link_index}==2        1611
    ...     ${link_index}==3        1411
    ...     1211
    ${clks_num}=    Set Variable If
    ...     ${link_index}==1        7
    ...     ${link_index}==2        5
    ...     ${link_index}==3        3
    ...     1
    [Return]  ${pre_log_num}    ${clks_num}

Get BandInfo From SCF
    [Arguments]  ${connection}=GNB_OAM
    ${cells_info}    coam.get_cells_info    connection=${connection}
    ${cell_num}    get length    ${cells_info}
    ${bandlist}    create list
    FOR  ${cell_index}  IN RANGE  ${cell_num}
            ${cellTechnology}    set variable    ${cells_info[${cell_index}]['technology']}
            ${chBw}    run keyword if    '${cellTechnology}'=='TDD'    set variable     ${cells_info[${cell_index}]['chBw'][:-2]}
            ...    ELSE      set variable    ${cells_info[${cell_index}]['chBwDl'][:-2]}
            append to list    ${bandlist}    ${chBw}
    END
    [Return]   ${bandlist}

bbmod Should Be offline
    [Documentation]   Auther: lanwen.cai@nokia-sbell.com
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM
    ${result}    get release flag    connection=${connection}
    ${operationalState}   set variable if      ${result}    Disabled    disabled
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['operationalState']}       ${operationalState}
                                  ...  msg=Current BBmod operationalStatus is not in Disabled status
    ${availabilityStatus}   set variable if      ${result}    Offline    off line
    Should be equal as strings    ${bbmod_status['status']['availabilityStatus']}     ${availabilityStatus}
                                  ...  msg=Current BBmod availabilityStatus is not in Offline status

bbmod Should Be Locked
    [Documentation]   Author:lanwen.cai@nokia-sbell.com
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM
    ${result}    get release flag    connection=${connection}
    ${operationalState}    set variable if      ${result}    Enabled    enabled
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['administrativeState']}    Locked
                                  ...  msg=Current bbmod administrativeState is not in locked status
    Should be equal as strings    ${bbmod_status['status']['operationalState']}       ${operationalState}
                                  ...  msg=Current bbmod operationalState is not in Enabled status
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus']}       configured
                                  ...  msg=Current bbmod proceduralStatus is not in configured status
    run keyword if  ${result}    Should be equal as strings
    ...    ${bbmod_status['status']['availabilityStatus']}     Online
    ...    msg=Current bbmod availabilityStatus is not in Online status

bbmod Should Be unLocked
    [Documentation]   Author:lanwen.cai@nokia-sbell.com
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM
    ${result}    get release flag    connection=${connection}
    ${operationalState}    set variable if      ${result}    Enabled    enabled
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['administrativeState']}    Unlocked
                                  ...  msg=Current bbmod administrativeState is not in locked status
    Should be equal as strings    ${bbmod_status['status']['operationalState']}       ${operationalState}
                                  ...  msg=Current bbmod operationalState is not in Enabled status
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus']}       configured
                                  ...  msg=Current bbmod proceduralStatus is not in configured status
    run keyword if  ${result}    Should be equal as strings
    ...    ${bbmod_status['status']['availabilityStatus']}     Online
    ...    msg=Current bbmod availabilityStatus is not in Online status

Check if QSFP or SFP
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        ${physicalPort}    Check type of link  ${links}    ${dict_of_links}    ${port}
    END
    [Return]    ${physicalPort}

Check type of link
    [Arguments]    ${links}    ${dict_of_links}    ${port}    ${connection}=GNB_OAM
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        ${physicalPort}    coam.Get Parameters        ${links["connected"][${port}]["${direction}"]}    physicalPort
        ...    timeout=20    connection=${connection}
        ${physicalPort}    Get From Dictionary    ${physicalPort}    physicalPort
    END
    [Return]    ${physicalPort}

Get Information about SFP links
    [Arguments]  ${connection}=GNB_OAM
    ${links}=    coam.get_sfp_links   timeout=20    connection=${connection}
    ${connected}=    Get From Dictionary    ${links}    connected
    ${numb_of_links}=    Get Length    ${connected}
    &{SMOD_dict}=    Create Dictionary
    &{BBMOD_dict}=    Create Dictionary
    &{RMOD_dict}=    Create Dictionary
    FOR    ${x}    IN RANGE    ${numb_of_links}
        @{SMOD}=    Create List
        @{BBMOD}=    Create List
        @{RMOD}=    Create List
        Set Suite Variable    ${source}    ${links["connected"][${x}]["source"]}
        Set Suite Variable    ${destination}    ${links["connected"][${x}]["destination"]}
        ${source_SMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    SMOD
        ${source_BBMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    BBMOD
        ${source_RMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${source}    RMOD
        ${destiny_SMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${destination}    SMOD
        ${destiny_BBMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${destination}    BBMOD
        ${destiny_RMOD_match}   ${value}   Run Keyword And Ignore Error   Should Contain   ${destination}    RMOD
        Run Keyword If    '${source_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    source
        Run Keyword If   '${source_BBMOD_match}' == 'PASS'    Append To List    ${BBMOD}    source
        Run Keyword If    '${source_RMOD_match}' == 'PASS'    Append To List    ${RMOD}    source
        Run Keyword If    '${destiny_SMOD_match}' == 'PASS'    Append To List    ${SMOD}    destination
        Run Keyword If   '${destiny_BBMOD_match}' == 'PASS'    Append To List    ${BBMOD}    destination
        Run Keyword If    '${destiny_RMOD_match}' == 'PASS'    Append To List    ${RMOD}    destination
        Set To Dictionary    ${RMOD_dict}    ${x}    ${RMOD}
        Set To Dictionary    ${BBMOD_dict}    ${x}    ${BBMOD}
        Set To Dictionary    ${SMOD_dict}    ${x}    ${SMOD}
        Set Suite Variable    ${source_SMOD_match}    'FAIL'
        Set Suite Variable    ${source_BBMOD_match}    'FAIL'
        Set Suite Variable    ${source_RMOD_match}    'FAIL'
        Set Suite Variable    ${destiny_SMOD_match}    'FAIL'
        Set Suite Variable    ${destiny_BBMOD_match}    'FAIL'
        Set Suite Variable    ${destiny_RMOD_match}    'FAIL'
    END
    [Return]    ${links}    ${SMOD_dict}    ${BBMOD_dict}    ${RMOD_dict}

Get RU Power State
    [Arguments]     ${ru_index}=1   ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
	[Return]    ${ru_status['status']['powerState']}

RU Status Should Be Failed
    [Arguments]  ${ru_index}=1    ${connection}=GNB_OAM
    ${dict_ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
    ${result}    get release flag    connection=${connection}
    ${availabilityStatus}   set variable if      ${result}    Failed    failed
    should match regexp    ${dict_ru_info['status']['availabilityStatus']}    ${availabilityStatus}

Commission 1S1CC SCF If Needed
    ${cell_nums}     Get Cell Numbers
    ${1S1CC_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_1S1CC_
    Run Keyword If   ${cell_nums}!= 1   Commissioning SCF And Check On Air    scf_path=${1S1CC_SCF}

Perform RAC and RAU Power Off
    [Arguments]  ${ru_index_list}
    log to console    \n***Perform RAC and RAU Power Off***
    Perform Site Power Off    model=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    5min    30s    Check SBTS Ping Disable
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        sleep    15s
    END

Perform RAC Power On
    [Arguments]  ${ru_index_list}  ${timeout}=10 min    ${connection}=GNB_OAM   ${retry_interval}=5 sec    ${du_index}=0
    log to console    \n***Perform RAC Power On***
    Perform Site Power On    model=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    5min    30s    Check SBTS Ping Enable
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15min    1min    COAM Check GNB ASIK status
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF testline    du_index=${du_index}
    Run keyword if    ${is_asod_asoe_asof}==${False}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ABIL status    connection=${connection}
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF
    Wait For Expect Fault Present  faultId=10  timeout=20min
    FOR  ${ru_index}  IN  @{ru_index_list}
         RU Should Be Power Off    ru_index=${ru_index}
    END

Get File List On Snapshot
    [Arguments]   ${ru_index}=${1}    ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=GNB_OAM    ${timeout}=600
    log to console    \nGet File List On Snapshot
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=${timeout}   connection=${connection}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    [Return]    ${output}

Get BBOX5 file On Snapshot
    [Arguments]   ${ru_index}=${1}   ${coverage}=Full    ${snapshot_path}=${TS_CASE_LOG_PATH}
    ...    ${connection}=GNB_OAM    ${timeout}=600
    log to console    \nGet BBOX5 file On Snapshot
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=${coverage}
    ...    timeout=${timeout}   connection=${connection}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${stream}    get stream from version    version=${Active_SW_version}    convert_to_trunk=${False}
    ${pattern}   Set Variable If    '${stream}' >= 'SBTS25R2'
    ...    BTS_part(\\d+).zip:[^:]*BTS\\d+_${serial_number}_RMOD_L_\\d+_BBOX5
    ...    BTS_part(\\d).zip:[^:]*BTS_${serial_number}_RMOD_L_[\\d]+_BBOX5
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
	log to console    ${btspart_list}
    ${btspart}   Set Variable    BTS_part${btspart_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}
    ${btspart_output} =    Run    command=cd ${snapshot_unzip_file_path}/${btspart};ls
    ${pattern_bbox5}   Set Variable If    '${stream}' >= 'SBTS25R2'
    ...    (BTS\\d+_${serial_number}_RMOD_L_[\\d]+_BBOX5(?:_all)?)(.*)
    ...    (BTS_${serial_number}_RMOD_L_[\\d]+_BBOX5(?:_all)?)(.*)
    ${bbox5_list} =    Get Regexp Matches    ${btspart_output}    ${pattern_bbox5}    1    2
	log    ${bbox5_list}
    ${bbox5}    Set Variable    ${bbox5_list}[0][0]
	${bbox5_suffix}    Set Variable    ${bbox5_list}[0][1]
	Run Keyword If    '${bbox5_suffix}' == '.zip'
    ...    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}/${bbox5}${bbox5_suffix}
    ...                        ${snapshot_unzip_file_path}/${btspart}/${bbox5}
    ...    ELSE IF    '${bbox5_suffix}' == '.xz'
    ...    Run    command=unxz ${snapshot_unzip_file_path}/${btspart}/${bbox5}${bbox5_suffix}
    ${bbox5_file}    Set Variable If  '${bbox5_suffix}' == '.zip'
    ...    ${snapshot_unzip_file_path}/${btspart}/${bbox5}/BBOX5    ${snapshot_unzip_file_path}/${btspart}/${bbox5}
    ${bbox5_info}    Run    command=cat ${bbox5_file}
    [Return]    ${bbox5_info}

Get Cpri Ecpri Switch Params
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    Wait Until Keyword Succeeds    1min    10s    Connect to gnb coam via ssl
    ${radio_protocol}    get_radio_protocal_via_admin
    ${link_speed}    set variable if    '${radio_protocol}'=='CPRI'    eCpri10    Cpri7
    ${radio_protocol_type}    set variable if    '${radio_protocol}'=='CPRI'    10eCPRI    TDDCPRI
    [Return]  ${link_speed}    ${radio_protocol_type}

Alarm in Given Alarm list Present
    [Arguments]  ${connection}=GNB_OAM
    log to console  \n Check fault 1900 or 4008 on WebUI
    ${alarm_list}    create list    1900    4008
    ${status}    set variable    ${False}
    FOR    ${faultId}    IN    @{alarm_list}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=${faultId}    connection=${connection}
        run keyword if    ${status}    log to console  \n fault ${faultId} raise on WebUI
        exit for loop if    ${status}
    END
    should be true    ${status}

Check Activate Beamforming for RU Enhance
    [Arguments]    ${ru_index}  ${connection}=GNB_OAM
    ${cell_list}    get all cell id    ru_index=${ru_index}    connection=${connection}
    ${get_actBeamforming}    set variable    ${False}
    FOR    ${cell_id}    IN    @{cell_list}
        ${actBeamforming}    get_activate_beamforming_via_admin    cell_id=${cell_id}    connection=${connection}
        ${actBeamforming}    convert to string    ${actBeamforming}
        ${get_actBeamforming}    set variable if    '${actBeamforming.lower()}'=='true'    ${True}    ${get_actBeamforming}
    END
    [Return]    ${get_actBeamforming}

Perform dlMimoMode Value Via API
    [Documentation]   Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}    ${dlMimoMode_value}    ${connection}=GNB_OAM
    run keyword and ignore error    coam_parameter.perform_single_parameter_update    value=${dlMimoMode_value}    parameter=dlMimoMode
    ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}    connection=${connection}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

Modify miNrEcpriUpFCp Parameters via API
    [Arguments]  ${miNrEcpriUpFCp}=5min    ${connection}=GNB_OAM
    log to console  Modify parameter : Measurement interval for NR eCPRI U-Plane & Fast-C-Plane
    run keyword and ignore error    coam_parameter.perform_single_parameter_update    value=${miNrEcpriUpFCp}    parameter=miNrEcpriUpFCp
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1    connection=${connection}

Add Syslog Flag To Swconfig If Not Exist
    [Arguments]    ${alias}=syslog_flag    ${local_path}=/tmp/swconfig.txt
    ${rd_syslog_flag}    Set Variable    0x10041=5
    @{rd_flags}    Create List    ${rd_syslog_flag}
    Remove File    ${local_path}
    Connect to Common Unit Master  alias=${alias}
    ${status}  ${res}  Run Keyword And Ignore Error
    ...    swconf.download_swConfig_file_from_asik_to_test_pc
    ...    localFilePath=${local_path}    remoteFilePath=/ffs/run/swconfig.txt    asik_alias=${alias}
	${file_not_exist}  Run Keyword And Return Status  Should Contain    ${res}    FileNotFoundError
	${size}    Run Keyword If    "${status}"=="PASS"    OperatingSystem.Get File Size    ${local_path}
	Run Keyword If    ${file_not_exist} or ${size}==0     OperatingSystem.Create File
    ...    ${local_path}    ${rd_syslog_flag}    ELSE    OperatingSystem.Get File    ${local_path}
    Run Keyword If    '${status}'=='PASS' or ${file_not_exist}    Run Keywords
    ...               swconf.modify_swConfig_file    ${rd_flags}    ${local_path}    AND
    ...               swconf.upload_swConfig_file_to_asik_and_crasign    ${local_path}    asik_alias=${alias}
    [Teardown]  Run Keyword and Ignore Error    ssh.disconnect  connection=${alias}
