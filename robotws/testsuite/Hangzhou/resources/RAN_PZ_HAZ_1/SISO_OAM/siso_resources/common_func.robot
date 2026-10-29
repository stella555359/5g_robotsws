*** Settings ***
Documentation
...    SISO Common Resource files

Library      OperatingSystem
Library      String
Library      json
Library      ./tools/FW.py
Resource     ./pdu.robot


*** Variables ***
${SEND_REP_PYTHON_CODE_PATH}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/tools/upload_to_rep.py


*** Keywords ***
PDU Switch Off Not Needed Hardware
    [Arguments]    ${BTS_CONFIG}=${BTS_CONFIG}
    ${hw_init_types}=         Get Dictionary Keys    ${BTS_CONFIG}
    ${hw_init_sm}=      Run Keyword If  "FSM" in "${hw_init_types}"    Get Dictionary Keys    ${BTS_CONFIG['FSM']}
#    ${hw_init_bbmod}=   Run Keyword If  "EC" in "${hw_init_types}"    Get Dictionary Keys    ${BTS_CONFIG['EC']}
    ${hw_init_fr}=      Get Dictionary Keys    ${BTS_CONFIG['FR']}
    ${hw_init_fhs}=    Run Keyword If  "FHS" in "${hw_init_types}"   Get Dictionary Keys    ${BTS_CONFIG['FHS']}
    Run Keyword If  "FSM" in "${hw_init_types}"    Remove Values From List    ${hw_init_sm}          @{USED_SM_SN_LIST}
#    Run Keyword If  "EC" in "${hw_init_types}"    Remove Values From List    ${hw_init_bbmod}       @{USED_BBMOD_SN_LIST}
    Remove Values From List    ${hw_init_fr}          @{USED_FR_SN_LIST}
    Run Keyword If  "FHS" in "${hw_init_types}"    Remove Values From List    ${hw_init_fhs}         @{USED_FHS_SN_LIST}
    Run Keyword If  "FSM" in "${hw_init_types}"
    ...    Pdu Turn Off All Devices From Serial Number List    ${hw_init_sm}       ${BTS_CONFIG}    FSM
#    Run Keyword If  "EC" in "${hw_init_types}"
#    ...    Pdu Turn Off All Devices From Serial Number List    ${hw_init_bbmod}    ${BTS_CONFIG}    EC
    Run Keyword If  "FHS" in "${hw_init_types}"
    ...    Pdu Turn Off All Devices From Serial Number List    ${hw_init_fhs}      ${BTS_CONFIG}    FHS
    ${rru_off}    Get Variable Value    ${GLO_RRU_PERFORM}    True
    Run Keyword If    "${rru_off}" == "True"    Pdu Turn Off All Devices From Serial Number List    ${hw_init_fr}    ${BTS_CONFIG}    FR

PDU Switch On Needed Hardware
    [Arguments]    ${BTS_CONFIG}=${BTS_CONFIG}
    ${hw_init_types}=         Get Dictionary Keys    ${BTS_CONFIG}
    Run Keyword If  "FSM" in "${hw_init_types}"
    ...    Pdu Turn On All Devices From Serial Number List    ${USED_SM_SN_LIST}       ${BTS_CONFIG}    FSM
#    Pdu Turn On All Devices From Serial Number List    ${USED_BBMOD_SN_LIST}    ${BTS_CONFIG}    EC
    Run Keyword If  "FHS" in "${hw_init_types}"
    ...    Pdu Turn On All Devices From Serial Number List    ${USED_FHS_SN_LIST}      ${BTS_CONFIG}    FHS
    Pdu Turn On All Devices From Serial Number List    ${USED_FR_SN_LIST}       ${BTS_CONFIG}    FR

Set Suite Logs Dir Path
    [Documentation]  ADDS SUITE VARIABLES: ${SUITE_LOGS_DIR_PATH}
    ${suite_logs_dir_path}=    Logging Create Suite Logs Directory    logs_dir_path=${OUTPUT_DIR}/
    Set Suite Variable    ${SUITE_LOGS_DIR_PATH}    ${suite_logs_dir_path}

Set TC Dir Path
    ${test_logs_dir_path}    Normalize Path         ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}
    ${test_logs_dir_path}=    Replace String     ${test_logs_dir_path}    ${SPACE}     _
    Create Directory     ${test_logs_dir_path}
    ${status}    Run Keyword And Return Status    Wait Until Created    ${test_logs_dir_path}   5 seconds
    Set Test Variable    ${TEST_LOGS_DIR_PATH}      ${test_logs_dir_path}
    Set Test Variable    ${TS_CASE_LOG_PATH}        ${test_logs_dir_path}

Logging Create Suite Logs Directory
    [Arguments]    ${logs_dir_path}
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}    Get Time    year month day hour min sec
    ${out_suite_logs_dir_path}    Normalize Path
    ...    ${logs_dir_path}/${year}-${month}-${day}-${hour}-${min}-${sec}_${SUITE_NAME}/
    ${out_suite_logs_dir_path}    Replace String    ${out_suite_logs_dir_path}    ${SPACE}    _
    Create Directory    ${out_suite_logs_dir_path}
    [Return]    ${out_suite_logs_dir_path}

Get RMOD Info
    [Arguments]    ${rmod_list}
    ${fr_sn_list}    Create List
    ${rmod_info}    Create Dictionary
    FOR    ${fr}    IN    @{rmod_list}
        ${sn}    Pop From Dictionary   ${fr}    serialNumber
        Append To List    ${fr_sn_list}    ${sn}
        Set To Dictionary    ${rmod_info}    ${sn}=${fr}
    END
    [Return]    ${fr_sn_list}    ${rmod_info}

Set Fiber Switch Configuration
    [Arguments]    ${config_id}
    ${gg_status}    Run Keyword And Return Status     List Should Contain Value    ${${config_id}}    GG
    Return From Keyword If    "${gg_status}" == "False"
    ${FW_info}    Set Variable    ${tl_config.FW_INFO}
    ${FW_ip}    Set Variable    ${FW_info['IP']}
    ${FW_user_name}    Set Variable  ${FW_info['USERNAME']}
    ${FW_password}    Set Variable  ${FW_info['PASSWORD']}
    ${FW_type}    Set Variable  ${FW_info['TYPE']}
    ${status}    Run Keyword And Return Status    Get From Dictionary    ${FW_INFO}    BREAK_PORTS
    ${FW_break_links}    Set Variable If    ${status}    ${FW_INFO['BREAK_PORTS']}    ${FW_INFO['BBU_PORT']}
    ${links}    Get From Dictionary    ${${config_id}}    GG
    Break Link    ${FW_ip}    ${FW_user_name}    ${FW_password}    ${FW_break_links}    link_type=single    FW_type=${FW_type}
    Connect Link    ${FW_ip}    ${FW_user_name}    ${FW_password}    ${links}    FW_type=${FW_type}

Get Cell Info With PCI
    [Arguments]    ${cell_list}   ${pci}   ${tech}=${EMPTY}
    FOR   ${cell_info}   IN    @{cell_list}
        Continue For Loop If    '${cell_info["phyCellId"]}'!='${pci}'
        Return From Keyword If   '${tech}'=='${EMPTY}' or '${tech}'=='${cell_info["cellTechnology"]}'      ${cell_info}
    END
    Fail

Get Bar Cell For Same RRU And PA
    [Arguments]    ${cell_info}
    ${rf_info}    Set Variable    ${cell_info['RF'][0]}
    ${rf_sn}    Set Variable    ${rf_info['serialNumber']}
    @{one_rf_bar_cell}    Create List
    FOR    ${each_cell}    IN    @{ALL_CELL_LIST}
        Continue For Loop If
        ...    ${each_cell['phyCellId']} == ${cell_info['phyCellId']} or ${each_cell['btsId']} != ${cell_info['btsId']}

        ${each_rf_info}    Set Variable    ${each_cell['RF'][0]}
        Run Keyword If    '${rf_sn}' == '${each_rf_info['serialNumber']}'   Append To List    ${one_rf_bar_cell}
        ...   ${each_cell}
    END
    ${one_pa_bar_cell}    get_bar_cell_by_pa_config    ${GLO_TL_DESCRIPTOR_FILE_PATH}    ${cell_info}
    ...    ${ALL_CELL_LIST}
    ${bar_cell_list}    Combine Lists    ${one_rf_bar_cell}    ${one_pa_bar_cell}
    ${bar_cell_list}    Remove Duplicates    ${bar_cell_list}
    [Return]    ${bar_cell_list}

Remove Cells From Cell List
    [Arguments]   ${cell_list}   ${cell_info}
    FOR    ${pci}   IN    @{cell_info["related_cell"]}
        ${related_cell_info}   Get Cell Info With PCI   ${ALL_CELL_LIST}    ${pci}
        Remove Values From List    ${cell_list}    ${related_cell_info}
    END
    [Return]    ${cell_list}

Check Is Operation Cell
    [Arguments]  ${cell_info}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${cell_tech}     Set Variable    ${cell_info['cellTechnology']}
    ${is_anchor_cell}    Run Keyword And Return Status
    ...   dictionary_should_not_contain_key    ${cell_info}    nrCellId
    ${need_to_operate}    Run Keyword If     '${cell_tech}'=='NB-IoT-FDD' or '${cell_tech}'=='NB-IoT-TDD'
    ...     Set Variable    ${FALSE}
    ...     ELSE IF    '${network_type}'=='NSA' or '${network_type}'=='SA'
    ...     Set Variable    ${TRUE}
    ...     ELSE IF    '${network_type}'=='4G' and ${is_anchor_cell}     Set Variable    ${TRUE}
    ...     ELSE   Set Variable    ${FALSE}
    [Return]    ${need_to_operate}

Remove Cells
    [Arguments]    ${required_cells}    ${remove_cell_list}
    ${required_cells_list}    Split String    ${required_cells}    :
    FOR    ${remove_cell}    IN    @{remove_cell_list}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${required_cells_list}    ${remove_cell["phyCellId"]}
        Run Keyword If    ${status}    Remove Values From List    ${required_cells_list}    ${remove_cell["phyCellId"]}
    END
    ${required_cells}    Catenate    SEPARATOR=:    @{required_cells_list}
    [Return]    ${required_cells}

Get Scout Testline Name
    ${scout_testline_name}    Get Variable Value    ${GLO_SCOUT_TESTLINE_NAME}    ${TL_NAME}
    ${status}    Run Keyword And Return Status    Should Not End With    ${scout_testline_name}    _1
    ${scout_testline_name}    Set Variable If    ${NODE_CFG["${MASTER_BTS_ID}"].fullrack} and ${status}      ${scout_testline_name}_1
    ...    ${scout_testline_name}
    [Return]    ${scout_testline_name}

Get Scount Testline Name List
    ${site_count}    Get Length    ${BTS_LIST}
    ${scout_testline_name}    Get Scout Testline Name
    ${scout_testline_name_list}    Create List    ${scout_testline_name}
    FOR    ${i}    IN RANGE    2    ${site_count}+1
        ${scout_testline_name}    Replace String Using Regexp    ${scout_testline_name}    _1$    _${i}
        Append To List    ${scout_testline_name_list}    ${scout_testline_name}
    END
    [Return]    ${scout_testline_name_list}

Get Scout SCF Internal Id
    [Timeout]    3 minutes
    [Arguments]    ${bts_id}=${TESTLINE_NAME}    ${no_ute}=${True}
    [Documentation]    This kw is used to get scf id from scout by testline id
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | testline_name | yes | use the scout testline id ,usually is bts id |
    ...    | internal | yes | if you use CM single run or auto trigger, please set False |
    ...
    ...    | Return Value | Description |
    ...    | scf_id | the internal id from scout |
    ...
    ...    Example
    ...    | Get SCF Internal Id By Scout | testline_name=6141 |
    ...
    scout.setup_scout    ${bts_id}
    ${scf_id}    scout.request_scf    use_scout_internal_id=${no_ute}
    Log to Console   scf id is: ${scf_id}
    [Return]    ${scf_id}
    [Teardown]    scout.teardown_scout_api

Send Scf Id To ReP
    [Arguments]    ${qc_id}    ${scf_id}=${None}    ${bts_id}=${TESTLINE_NAME}
    ...    ${case_name}=${TEST NAME}    ${case_result}=pass    ${sw}=${ACTIVE_SW_VERSION}
    ...    ${pass_number}=${1}    ${run_number}=${1}
    ...    ${testline}=${None}    ${comment}=${EMPTY}    ${qc_pro}=RAN_VRF
    [Documentation]    This kw is used to send test result to rep with scf id
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | qc_id | yes | qc id of this case,if this is qc file, please input the path |
    ...    | scf_id | yes | get by keyword 'Get SCF Internal Id By Scout' |
    ...    | bts_id | yes | bts id in scout |
    ...    | case_name | yes | update case name |
    ...    | case_result | yes | this test result |
    ...    | sw | yes | the test sw |
    ...    | testline | yes | testline use to combine |
    ...    Example
    ...    | Send Scf Id To ReP | qc_id=256752 | bts_id=6141 | case_name=OAM_Stability_4G_Site_reset_ENDC_call |
    ...    | sw=SBTS00_ENB_9999_220325_000007 |
    ...
    ${scf_id}    Run Keyword If    '${scf_id}'=='${None}'
    ...    Get Scout SCF Internal Id    bts_id=${bts_id}
    ...    ELSE   Set Variable    ${scf_id}
    ${pass_rate}    Evaluate    100*${pass_number}/${run_number}
    ${send_cmd}    Catenate    python ${SEND_REP_PYTHON_CODE_PATH} '${case_name}' '${case_result}'
    ...    '${sw}' '${qc_id}' '${pass_rate}%(${pass_number}/${run_number})' '${scf_id}'
    ...    'None'    'None'    '${testline}'    '${comment}'    '${qc_pro}'
    Log To Console    ${send_cmd}
    ${ret}    OperatingSystem.Run   ${send_cmd}
    Log To Console    ${ret}
    ${rep_link}    Set Variable    https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?file_hash
    #Should Contain    ${ret}    ${rep_link}=

Rep Reporting With Config Id
    [Arguments]    ${case_result}=${TEST STATUS}    ${pass_number}=${1}    ${run_number}=${1}
    ${if_reporting_rep}    Get Variable Value    ${if_reporting_rep}    ${False}
    ${scout_testline_name_list}    Get Scount Testline Name List
    FOR    ${tag}    IN    @{TEST TAGS}
        ${status}    Run Keyword And Return Status    Should Match Regexp    ${tag}    \\d+_\\d+_\\w+\\d+
        Continue For Loop If    not ${status}
        ${testline_list}    create list
        Append To List    ${testline_list}    ${tag}
        Set Test Variable   ${scout_testline_name_list}     ${testline_list}
        Exit For Loop
    END
    FOR    ${scout_testline_name}    IN    @{scout_testline_name_list}
        Run Keyword If    "${if_reporting_rep}"=="False"    Wait Until Keyword Succeeds    5 min    10 sec
        ...    Get Scout SCF Internal Id     ${scout_testline_name}    ${False}
    END
    Return From Keyword If    not ${if_reporting_rep}
    FOR    ${tag}    IN    @{TEST TAGS}
        ${status}    Run Keyword And Return Status    Should Match Regexp    ${tag}    QC_
        Continue For Loop If    not ${status}
        ${qc_id}    Get Regexp Matches    ${tag}    QC_(\\d+)    1
        Exit For Loop
    END
    FOR    ${tag}    IN    @{TEST TAGS}
        ${status}    Run Keyword And Return Status    Should Match Regexp    ${tag}    QCP_
        Continue For Loop If    not ${status}
        ${qc_pro}    Get Regexp Matches    ${tag}    QCP_(\\w+)    1
        Exit For Loop
    END
    Run Keyword If    "${case_result}"=="PASS"    Set Test Variable    ${result}    pass
    Run Keyword If    "${case_result}"=="FAIL"    Set Test Variable    ${result}    not analyzed
    ${comment}    Get Variable Value    ${REP_COMMENT}    ${EMPTY}
    Send Scf Id To ReP     ${qc_id[0]}    bts_id=${scout_testline_name}    case_result=${result}
    ...    sw=${NODE_CFG['${MASTER_BTS_ID}'].software_active}    pass_number=${pass_number}    run_number=${run_number}
    ...    testline=${scout_testline_name}    comment=${comment}    qc_pro=${qc_pro[0]}

Check Is Supported Call Cell
    [Arguments]  ${cell_info}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${cell_tech}     Set Variable    ${cell_info['cellTechnology']}
    ${is_anchor_cell}    Run Keyword And Return Status
    ...   dictionary_should_not_contain_key    ${cell_info}    nrCellId
    ${need_to_operate}    Run Keyword If     '${cell_tech}'=='NB-IoT-FDD' or '${cell_tech}'=='NB-IoT-TDD'
    ...     Set Variable    ${TRUE}
    ...     ELSE IF    '${network_type}'=='NSA' or '${network_type}'=='SA'
    ...     Set Variable    ${TRUE}
    ...     ELSE IF    '${network_type}'=='4G' and ${is_anchor_cell}     Set Variable    ${TRUE}
    ...     ELSE   Set Variable    ${FALSE}
    [Return]    ${need_to_operate}

Get CM Execution Id
    ${content}    OperatingSystem.get file    ${UTE_EXECUTION_JSON}
    ${content_dict}    json.Loads    ${content}
    [Return]    ${content_dict["CM_EXECUTION_ID"]}    ${content_dict["CM_RESERVATION_ID"]}

Get Team Name From Scout
    ${scout_testline_name}    Set Variable    ${TL_NAME}
    ${user}    ${team}    truck_roll.get_tl_owner    ${scout_testline_name}
    ${user_1}    ${team_1}    Run Keyword If    "${user}"==""    truck_roll.get_tl_owner    ${scout_testline_name}_1
    ${team}    Run Keyword If    "${user}"!=""    Set Variable    ${team}
    ...    ELSE IF    "${user_1}"!=""    Set Variable    ${team_1}
    ...    ELSE    Return From Keyword    ${None}
    ${team_num}    Fetch From Right    ${team}    ${SPACE}
    [Return]    ${team_num}

Send Logs To Server And Remove Local Logs
    [Arguments]    ${local_test_result}=/home/ute/test_results
    ${status}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${UTE_EXECUTION_JSON}
    Return From Keyword If    not ${status}
    ${status2}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_test_result}/log.html
    Return From Keyword If    ${status2}
    ${team_num}    Get Team Name From Scout
    ${team_status}    Run Keyword And Return Status    Should Match Regexp    ${team_num}    (6|7|10)
    Run Keyword If    not ${team_status}    Log    message=team name(${team_num}) is error, not 6|7|10.    console=True
    Return From Keyword If    not ${team_status}
    ${team_num}    Set Variable If    "${team_num}"=="6"    8    10
    ${cm_execution_id}    ${cm_reservation_id}    Get CM Execution Id
    ${remote_path}    Set Variable
    ...  /data/logs/HAZ${team_num}/${TL_NAME}/${cm_execution_id}/execution_for_preparation_${cm_reservation_id}
    Log    message=Send Logs To Server: http://10.69.69.233${remote_path}    console=True
    FOR    ${i}    IN RANGE    ${3}
        ${send_logs_status}    Run Keyword And Return Status    Send Logs To Server    ${remote_path}    local_path=${local_test_result}
        Exit For Loop If    ${send_logs_status}
    END
    Should Be True    ${send_logs_status}
    Log    message=The test_results will be removed    level=WARN    	console=yes
    ${all_dir_in_testresult}    OperatingSystem.List Directories In Directory    ${local_test_result}
    FOR    ${d}    IN    @{all_dir_in_testresult}
        Log To Console    ${d}
        ${clear_path}    Join Path    ${local_test_result}    ${d}
        OperatingSystem.Remove Directory    ${clear_path}    recursive=${True}
    END

Send Logs To Server
    [Arguments]    ${remote_path}    ${local_path}=/home/ute/test_results
    csn.connect to    hostname=${LOG_SERVER_INFO.HOST}
    ...               username=${LOG_SERVER_INFO.USERNAME}
    ...               password=${LOG_SERVER_INFO.PASSWORD}
    ...               alias=log_server
    csn.execute    mkdir -p ${remote_path}    connection=log_server
    ${cmd}    catenate    sshpass -p ${LOG_SERVER_INFO.PASSWORD} rsync --timeout=1200 -Lrav ${local_path}
    ...    ${LOG_SERVER_INFO.USERNAME}@${LOG_SERVER_INFO.HOST}:${remote_path}
    ...    --max-size=10GB --no-owner --no-group --no-perms --chmod=ugo=rX
    ${rc}    ${output}    OperatingSystem.Run And Return RC And Output    command=${cmd}
    Should Be Equal As Integers    ${rc}    ${0}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=log_server
