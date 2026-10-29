*** Settings ***
Documentation
...    author: winnie he
...    contact: winnie.he@nokia-sbell.com
...    file operation
Library             taf.rfrl.common_resources.reporting_portal.bts_metadata
*** Variables ***
${SEND_REP_PYTHON_CODE_PATH}    ${CURDIR}${/}python/send_rep/UploadTCDataToRep.py
*** Keywords ***
Get UTE Execution Id
    [Arguments]    ${execution_index}=${UTE_EXECUTION_INDEX}
    [Documentation]    This kw is used to get ute execution id
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Return Value | Description |
    ...    | ute execution id | the internal id from scout |
    ...
    ...    Example
    ...    | ${execution_id} | Get UTE Execution Id |
    ...
    File Should Exist    ${UTE_EXECUTION_JSON}
    ${context}    OperatingSystem.Get File    ${UTE_EXECUTION_JSON}
    &{context_dict}    json.Loads    ${context}
    [Return]    ${context_dict}[CM_EXECUTION_ID]-${execution_index}

Get SCF Internal Id By Scout
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

Get Team Name By suite path
    [Documentation]    This kw is used to get teamname from scout by testline id
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
    ${matches}    Get Regexp Matches    ${SUITE SOURCE}    RAN_PZ_HAZ_1${/}HAZ\\d+
    Should Not Be Empty    ${matches}
    ${match}    Split String    ${matches}[0]    ${/}
    [Return]    ${match}[-1]


Send ReP With Scf Id
    [Arguments]    ${qc_id}    ${scf_id}=${None}    ${bts_id}=${TESTLINE_NAME}
    ...    ${case_name}=${TEST NAME}    ${case_result}=pass    ${sw}=${ACTIVE_SW_VERSION}
    ...    ${pass_number}=${1}    ${run_number}=${1}
    ...    ${testline}=${None}    ${execution_index}=${UTE_EXECUTION_INDEX}
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
    ...    | Send ReP With Scf Id | qc_id=256752 | bts_id=6141 | case_name=OAM_Stability_4G_Site_reset_ENDC_call |
    ...    | sw=SBTS00_ENB_9999_220325_000007 |
    ...
    ${stats}    ${execution_id}    Run Keyword If    '${scf_id}'=='${None}'
    ...    Run Keyword And Ignore Error    Get UTE Execution Id
    ...    execution_index=${execution_index}
    ${scf_id}    Run Keyword If    '${scf_id}'=='${None}' and '${stats}'=='PASS'
    ...    Set Variable    ${execution_id}
    ...    ELSE   Set Variable    ${scf_id}
    ${scout_scf_id}    Run Keyword If    '${stats}'=='PASS'
    ...    Wait Until Keyword Succeeds    3x    1min
    ...    Get SCF Internal Id By Scout    bts_id=${bts_id}    no_ute=${False}
    ...    ELSE
    ...    Wait Until Keyword Succeeds    3x    1min
    ...    Get SCF Internal Id By Scout    bts_id=${bts_id}    no_ute=${True}
    ${scf_id}    Run Keyword If    '${scf_id}'=='${None}' and '${stats}'!='PASS'
    ...    Set Variable    ${scout_scf_id}
    ...    ELSE   Set Variable    ${scf_id}
    ${pass_rate}    Evaluate    100*${pass_number}/${run_number}
    ${send_cmd}    Catenate    python ${SEND_REP_PYTHON_CODE_PATH} '${case_name}' '${case_result}'
    ...    '${sw}' '${qc_id}' '${pass_rate}%(${pass_number}/${run_number})' '${scf_id}'
    ...    'None'    'None'    '${testline}'
    Log To Console    ${send_cmd}
    ${ret}    OperatingSystem.Run   ${send_cmd}
    Log To Console    ${ret}
    ${rep_link}    Set Variable    https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?file_hash
    Should Contain    ${ret}    ${rep_link}=

#############    For KPI calculate ###############
Calculate KPI
    [Arguments]    ${kpi_list}    ${result_save_name}=kpi     ${need_average}=${False}
    ...    ${kpi_params}=${None}    ${connection}=COAM
    ...    ${all_ims}=${None}
    [Documentation]    This kw is used to calculate the KPI
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | kpi_list | yes | the kpi need calculate,like kpi1a, kpi1b, kpi1c |
    ...    | result_save_name | No | save result result name |
    ...    | need_average | No | need average value or others |
    ...    | kpi_params | No | for specific kpi that need input params |
    ...    | disconnect_ims | No | for kpi4 uuf that need disconnected ims logs |
    ...    Example
    ...    | ${kpi3_param} | create dictionary | start_point_timestamp=${kpi_cal_starttime} |
    ...    | ${kpi_params} | create dictionary | kpi3=${kpi3_param} |
    ...    | Calculate KPI | kpi_list=@{SBTS_Cold_Reset_WO_HWF_KPI} | kpi_params=${kpi_params} |
    ...
    ${timestamp}    Get TimeStamp With Date
    coam.collect_infomodel_log_from_current_session
    ...    target_file_name=${TEST_LOG_DIRECTORY}${/}KPI_calculate_${timestamp}.ims2
    ...    connection=${connection}
    ${ims_file_paths}    Run Keyword If    "${all_ims}"!="${None}"
    ...    Set Variable    ${all_ims}
    ...    ELSE    Set Variable    ${TEST_LOG_DIRECTORY}${/}KPI_calculate_${timestamp}.ims2
    Run Keyword If    "${all_ims}"!="${None}"
    ...    Append To List    ${ims_file_paths}    ${TEST_LOG_DIRECTORY}${/}KPI_calculate_${timestamp}.ims2
    oam_kpi.calculate_kpis    kpi_names=${kpi_list}
    ...    ims_file_path=${ims_file_paths}
    ...    kpi_params=${kpi_params}
    oam_kpi.save_results_to_file  file_path=${TEST_LOG_DIRECTORY}${/}${result_save_name}.json
    ${kpi_results}    Run Keyword If    ${need_average}    oam_kpi.get_average_results
    ...    ELSE    oam_kpi.get_results
    [Return]    ${kpi_results}
    [Teardown]    oam_kpi.clear_results

_Get Disconnect IMS Before Upgrade
    [Arguments]    ${connection}=COAM    ${last_connected_ims_path}=${TEST_LOG_DIRECTORY}
    ${files}    List Files In Directory    path=${last_connected_ims_path}
    ...    pattern=admin_api_${connection}_disconnect_at_*.ims2
    [Return]    ${last_connected_ims_path}${/}${files}[0]

Multi Bts Configuration Id Report
    [Timeout]    3 minutes
    [Arguments]    ${bts_params}=${None}
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
    ...    | Multi Bts Configuration Id Report | testline_name=6141 |
    ...
    Run Keyword If    '${bts_params}'!='${None}'
    ...    Add BTS Metadata To Report    bts_params=${bts_params}
    ${BTS_PARAMS}    Run Keyword If    "10_5_" in '${TESTLINE_NAME}'
    ...    __Get Scout Line Name For Sites By TL
    ...    ELSE
    ...    __Get Scout Line Name For Sites By Hostname
    Add BTS Metadata To Report    bts_params=${BTS_PARAMS}

__Get Scout Line Name For Sites By TL
    [Arguments]    ${testline}=${TESTLINE_NAME}
    ${BTS_PARAMS}    Create List
    ${gnb_numbers}    Get Length    ${tl.gnbs}
    FOR    ${index}    IN RANGE    ${gnb_numbers}
        ${gnb_name}    Set Variable    ${tl.gnbs[${index}].global_bts_id}
        ${testline_gnb_name}    Run Keyword If    '${gnb_name}' in '${testline}'
        ...    Set Variable    ${gnb_name}
        ${testline_gnb_name}    Convert To String    ${testline_gnb_name}
        Exit For Loop If    '${testline_gnb_name}' == '${gnb_name}'
    END
    FOR    ${index}    IN RANGE    ${gnb_numbers}
        ${gnb_name}    Set Variable    ${tl.gnbs[${index}].global_bts_id}
        ${gnb_name}    Convert To String    ${gnb_name}
        ${name}    Replace String    ${testline}    ${testline_gnb_name}    ${gnb_name}
        ${oam_info}    get_site_info    product_type=gnb    info_type=oam
        ...    bts_index=${index}    du_index=${0}
        COAM_Admin.Login    bts_host=${oam_info.addr}
        ...    username=${oam_info.username}
        ...    password=${oam_info.password}
        ...    alias=scoutname_fetch_bts${index}
        ${BTS_PARAM}    Create Dictionary    admin_connection=scoutname_fetch_bts${index}
        ...    scout_bts_name=${name}
        Append To List    ${BTS_PARAMS}    ${BTS_PARAM}
    END
    Return From Keyword If    ${gnb_numbers} == 1   ${BTS_PARAMS}[0]
    [Return]    ${BTS_PARAMS}
    [Teardown]    __Teardown For Scout

__Teardown For Scout
    ${gnb_numbers}    Get Length    ${tl.gnbs}
    FOR    ${index}    IN RANGE    ${gnb_numbers}
        Run Keyword And Ignore Error    COAM_Admin.Logout    alias=scoutname_fetch_bts${index}
        Run Keyword And Ignore Error    csn.disconnect    connection=ssh_scoutname_fetch_bts${index}
    END

__Get Scout Line Name For Sites By Hostname
    ${gnb_numbers}    Get Length    ${tl.gnbs}
    ${BTS_PARAMS}    Create List
    FOR    ${index}    IN RANGE    ${gnb_numbers}
        ${sshinfo}    Set Variable    ${tl.test_pcs[${index}].default_ssh_connection_details}
        csn.Connect To    hostname=${sshinfo.addr}   username=${sshinfo.username}    password=${sshinfo.password}
        ...    alias=ssh_scoutname_fetch_bts${index}
        ${name}    csn.execute    echo `hostname` | sed 's/-/_/g' | tr -d '\r\n'    connection=ssh_scoutname_fetch_bts${index}
        ${stat}    ${ret}    Run Keyword And Ignore Error    scout.setup_scout    ${name}
        ${name}    Run Keyword If    '${stat}' == 'FAIL'
        ...    Replace String Using Regexp    ${name}    _(\d+)$    -${index}
        ...    ELSE    Set Variable    ${name}
        ${stat}    ${ret}    Run Keyword And Ignore Error    scout.setup_scout    ${name}
        ${name}    Run Keyword If    '${stat}' == 'FAIL'
        ...    Replace String Using Regexp    ${name}    _(\d+)$    ${EMPTY}
        ...    ELSE    Set Variable    ${name}
        ${stat}    ${ret}    Run Keyword And Ignore Error    scout.setup_scout    ${name}
        ${oam_info}    get_site_info    product_type=gnb    info_type=oam
        ...    bts_index=${index}    du_index=${0}
        COAM_Admin.Login    bts_host=${oam_info.addr}
        ...    username=${oam_info.username}
        ...    password=${oam_info.password}
        ...    alias=scoutname_fetch_bts${index}
        ${BTS_PARAM}    Create Dictionary    admin_connection=scoutname_fetch_bts${index}
        ...    scout_bts_name=${name}
        Append To List    ${BTS_PARAMS}    ${BTS_PARAM}
    END
    Return From Keyword If    ${gnb_numbers} == 1   ${BTS_PARAMS}[0]
    [Return]    ${BTS_PARAMS}
    [Teardown]    __Teardown For Scout