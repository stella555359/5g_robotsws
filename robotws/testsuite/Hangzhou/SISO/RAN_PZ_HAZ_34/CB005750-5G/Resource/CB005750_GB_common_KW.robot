*** Settings ***
Documentation     author: annie.hu
...               Group: HGZ_SG5
...               contact: annie.hu@nokia-sbell.com



Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot



*** Variables ***
#Variables         /home/ute/TAF/${testline_name}/TLDelta.py


*** Keywords ***
KPI_SiteresetViaWebUI
    [Arguments]      ${case_name}  ${retry_times}=3
    KW.CaseStatusInit    retry_times=${retry_times}
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    Loop_SiteresetViaWEBUI    loop=${i+1}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${CASE_INPUT_CB005750['CB005750_HA_KPI1a']['KPI1a_MAX']}
        log to console     Case loop ${i+1} END
        Get common info     case_result=${reset_status}    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Run Keyword And Ignore error    WEBUI.Collect snapshot
    END
    Get_CaseStatusFinnal    case_avg=${CASE_INPUT_CB005750['CB005750_HA_KPI1a']['KPI1a_AVG']}    max_loop=${retry_times}


Get_CaseStatusFinnal
    [Arguments]        ${case_avg}=${0}    ${max_loop}=${0}
    ${avg}    run keyword if     ${CaseAVGLoop}>0   Evaluate    ${CaseSUM}/${CaseAVGLoop}
    should be true    ${avg}<=${case_avg}


Loop_SiteresetViaWEBUI
    [Arguments]    ${loop}
    #[Timeout]    ${CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']} minutes
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    ${timestartTmp}   Get Current Date
    ${timestart}      convert date    ${timestartTmp}    epoch
    COAM_Admin.ResetSite     timeout=1800
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800 	    pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

