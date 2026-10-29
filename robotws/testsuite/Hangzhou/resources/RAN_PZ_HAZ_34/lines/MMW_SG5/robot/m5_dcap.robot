# @Time    : 2024/1/25 16:09
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : m5_dcap.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library    taf.sw.dcap.rd    WITH NAME    rd

*** Keywords ***
Start DCAP Containers in UTE
    Start Process    DCAP_Basic_controller    start    alias=dcap_control
    ${result}=    Wait For Process    dcap_control
    Log to console    ${result.stdout}
#    Should contain    ${result.stdout}    UTF Lab health check passed. Have a nice trace
    Wait Until Keyword Succeeds    60s    5s    Check DCAP status

Check DCAP status
    ${DCAP_STATUS}=    Run    DCAP_Basic_controller status
    should contain    ${DCAP_STATUS}    UTF Lab health check passed. Have a nice trace

Connect To UTE Dcap With Alia M5_DCAP
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/23
    ...    Connect to the DCAP which deployed on UTE
    [Arguments]   ${host}=127.0.0.1   ${port}=9443   ${username}=${EMPTY}   ${password}=${EMPTY}   ${alias}=M5_DCAP
    rd.connect_to   host=${host}   port=${port}   username=${username}   password=${password}
    ...   rd_version=dcapv3   secure=${True}   alias=${alias}

Connect To Dcap With Alia M5_DCAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/25 16:11
    ...    testline_configuration: class testline not support dcap now
    [Arguments]   ${host}=10.57.195.96   ${username}=utfuser   ${password}=utfadmin!   ${port}=443   ${alias}=M5_DCAP
    rd.connect_to   host=${host}   port=${port}   username=${username}   password=${password}
    ...   rd_version=dcapv3   secure=${True}   alias=${alias}

Dcap Start Trace Via Custom Profile
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/25 17:03
    [Arguments]    ${custom_profile_list}   ${bts_profile_list}=[]
    ...    ${nr_cells}=${EMPTY}    ${host}=10.57.195.96
    ...    ${port}=443    ${connection}=M5_DCAP    ${is_ute_cloud}=False
    IF    ${is_ute_cloud}
      Connect To UTE Dcap With Alia M5_DCAP
    ELSE
      Connect To Dcap With Alia M5_DCAP    host=${host}    alias=${connection}
    END

    &{bts}    Create Dictionary
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  port=${port}
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}

    Run Keyword If    '${nr_cells}'!='${EMPTY}'
    ...    Set To Dictionary    ${bts}    nrCells    ${nr_cells}

    Run Keyword If    ${bts_profile_list}!=[]    Dcap Start Trace Via Gnb and Bts Profile    bts=${bts}
    ...    gnb_profile_list=${custom_profile_list}
    ...    bts_profile_list=${bts_profile_list}    connection=${connection}
    ...    ELSE    Dcap Start Trace Via Gnb Profile    bts=${bts}    gnb_profile_list=${custom_profile_list}
    ...    connection=${connection}

    Wait Until Keyword Succeeds    10min    60s     Dcap Verify Trace Status Running After Start Trace
    ...    trace_id=${NOW_TRACE_ID}

Dcap Stop Trace Via Trace ID
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/25 17:25
    [Arguments]    ${connection}=M5_DCAP    ${download_trace}=false
    rd.stop_trace    trace_id=${NOW_TRACE_ID}    connection=${connection}
    Wait Until Keyword Succeeds    10min    10s    Dcap Verify Trace Status Ready After Stop Trace
    ...    trace_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_file}  Run Keyword If    '${download_trace}' == 'true'    rd.get_results    result_id=${NOW_TRACE_ID}
    ...    target_dir=${TS_CASE_LOG_PATH}    connection=${connection}    timeout=600
    [Return]    ${dcap_file}

Dcap Start Trace Via Gnb Profile
    [Documentation]    Author: yinhua.zhang@nokia-sbell.com
    [Arguments]    ${bts}    ${gnb_profile_list}    ${connection}

    ${trace_id}    rd.start_trace    bts=${bts}    gnb_custom_profile=${gnb_profile_list}    connection=${connection}
    ...    bip_mirroring_time=1200s
    Set Suite Variable    ${NOW_TRACE_ID}    ${trace_id["tracer_id"]}

Dcap Start Trace Via Gnb and Bts Profile
    [Documentation]    Author: yinhua.zhang@nokia-sbell.com
    [Arguments]    ${bts}    ${gnb_profile_list}    ${bts_profile_list}    ${connection}

    ${trace_id}    rd.start_trace    bts=${bts}    gnb_custom_profile=${gnb_profile_list}    connection=${connection}
    ...    bts_custom_profile=${bts_profile_list}
    Set Suite Variable    ${NOW_TRACE_ID}    ${trace_id["tracer_id"]}

Dcap Verify Trace Status Ready After Stop Trace
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/05/20 14:58
    [Arguments]    ${trace_id}    ${connection}=M5_DCAP
    ${trace_status}    rd.get_trace_info_by_id    trace_id=${trace_id}    connection=${connection}
    Should Be True    '${trace_status['status']}'=='ready'

Dcap Verify Trace Status Running After Start Trace
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/05/20 14:58
    [Arguments]    ${trace_id}    ${connection}=M5_DCAP
    ${trace_status}    rd.get_trace_info_by_id    trace_id=${trace_id}    connection=${connection}
    Should Be True    '${trace_status['status']}'=='running'
