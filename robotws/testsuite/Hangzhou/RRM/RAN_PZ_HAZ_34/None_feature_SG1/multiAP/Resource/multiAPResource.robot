*** Settings ***
Documentation    author: hongyan yuan
...               contact:
...               squad group: SG_01
...               feature : non feature testing

Library           json
Resource          ../../../5GC000496_C/Resources/L3Call.robot
Resource          ../../../Globe_Lab_LTE/Resources/basic_keywords/ue.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ute_wtssim
Library           ute_syslog
Library           process_data_in_file.ExcelReader     WITH NAME    excelreader
Library           taf.sw.scout    WITH NAME   scout
Library           DateTime
Library           OperatingSystem
Library           Process

#Variables         CaseConfiguration.py

*** Variables ***
#${scout_testline_name}      VRF4_SG1_MultiUE_AP1
${api_key}                  e4de17a9d8d540e88e2e5740b805df7b
#${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}

#${CFGFILE_PATH}             /home/ute/TAF/cfgfile/
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${PB_PORT}                  5000
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_DU_Vendor}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${AP_LMP_IP}                ${tl.ues[0].l1.common_units[0].lmp_connection.addr}
${AP_USERNAME}              ${tl.ues[0].l1.common_units[0].lmp_connection.username}
${AP_PASSWORD}              ${tl.ues[0].l1.common_units[0].lmp_connection.password}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_MTKPC}              MTKPC                                               ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
${ALIAS_AP}                 AP                                                  ##
########################END of alias Define#######################################
#-------Multi AP Configuration------------------
*** Keywords ***
TC.Main
    KW.PrepareEnvAndStartTest
    Timer.Start
    #12hours:15min*48;16200s:270min*60
    FOR  ${i}   IN RANGE    ${48}
        KW.CheckTLAndRestartTestIFAbnormal
        ${duration}    Timer.Stop
        run keyword if   ${duration}>16200   run keywords    Generate kpi report    report_name=VRF4_SG1_Degraded_KPIs
        ...    AND   Exit For Loop
    END

KW.PrepareEnvAndStartTest
    KW.AirphoneUEJob    operation=Stop
    KW.WTSStopAll
    KW.PowerCycleAll
    sleep    60s
    KW.WTSStartAll
    Wait until keyword succeeds    20 min   30 sec   COAM_WebEM.VerifyAllCellsAreOnline
    KW.AirphoneUEJob    operation=Start

KW.CheckTLAndRestartTestIFAbnormal
    Sleep   15min
    Wait until keyword succeeds    15min    30s    COAM_WebEM.Login
    ${res}  selenium_coam.get_bts_counters_info   counter_id=M55127C00001
    ${values}    get dictionary values   ${res}
    ${status}   run keyword and return status   Should Not Be Equal   ${values[-1]}   0
    run keyword and ignore error    COAM_WebEM.Logout
    Run keyword if    '${status}'!='True'   run keywords   KW.PrepareEnvAndStartTest   AND   Timer.Start

KW.AirphoneUEJob
    [Arguments]    ${op}    ${jID}=0
    FOR    ${AP}   IN    @{TLConfig["APs"]}
      run  curl -X 'GET' 'http://${TLConfig["RTMServerIP"]}:11000/api/MultiUEManager/${op}ControlPC?ip=${AP["WTSIP"]}&jID=${jID}' -H 'accept: */*'
    END

KW.PowerCycleAll
    FOR    ${PB}   IN    @{TLConfig["PBs"]}
        Power.ResetgNB    pdu_ip=${PB["ip"]}    Port_Number=${PB["port"]}    model=${PB["model"]}
    END

KW.WTSStartAll
    FOR    ${AP}   IN    @{TLConfig["APs"]}
        epc.setup_edaemon    ${AP["eDaemonPort"]}    host_ip=${AP["WTSIP"]}    tool_dir=${AP["WTSDir"]}    alias=${AP["eDaemonAlias"]}
        ...      ssh_user=${AP["username"]}    ssh_pass=${AP["password"]}
        epc.start_edaemon_process    alias=${AP["eDaemonAlias"]}
        epc.setup egate    egate_port=${AP["eGatePort"]}    host_ip=${AP["WTSIP"]}    tool_dir=${AP["WTSDir"]}
        ...    alias=${AP["alias"]}      ssh_user=${AP["username"]}    ssh_pass=${AP["password"]}
        epc.start egate process    cfg_file=${AP["WTSDir"]}/${AP["egateFile"]}    timeout=10    alias=${AP["eGateAlias"]}
        sleep    5s
    END

KW.WTSStopAll
    FOR    ${AP}   IN    @{TLConfig["APs"]}
        Conn.ConnectToDev    IP=${AP["WTSIP"]}    USERNAME=${AP["username"]}    PASSWORD=${AP["password"]}    alias=WTSUTE
        Conn.Execute    cmd=sudo killall egate    alias=WTSUTE
        Conn.Execute    cmd=sudo killall edaemon    alias=WTSUTE
        Conn.Disconnect    alias=WTSUTE
    END

Generate kpi report
    [Arguments]     ${report_name}
    #${collect_log_start_time1}    get current time
    #sleep   240min
    Log To Console    genarate KPI report...
    ${collect_log_start_time1}    get current time
    run keyword and ignore error     Generate kpi report in Scout   report_name_1=${report_name}
       ...   collect_log_start_time=${collect_log_start_time1}

Generate kpi report in Scout
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Param: ${scout_testline_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    [Arguments]     ${collect_log_start_time}   ${alias}=scout  ${report_name_1}=Airphone_
    log to console   ${report_name_1}
    log to console   ${collect_log_start_time}
    ${gnb_version}       COAM_Admin.GetActiveSoftwareVersion
    ${new_timestamp}    Add Time to Date   ${collect_log_start_time}    -4 hours
    #Collect gnb logs
    sleep    5min
    ${report_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${report_date}    Get Substring    ${report_time}    0    10
    ${kpi_report_name}   Catenate    SEPARATOR=_   PZ4_SG01   ${report_date}   ${testline_name}   ${gnb_version}
    scout.setup_scout    scout_testline_name=${scout_testline_name}    api_key=${api_key}    alias=${alias}    timeout=180
    ${report}    scout.generate kpi report    report_name=${kpi_report_name}
    ...                                       template_id=2049
    ...                                       start_time=${new_timestamp}
    ...                                       end_time=${collect_log_start_time}
    ...                                       alias=${alias}
    log to console    ${report}
    set suite variable    ${id}    ${report[0]["id"]}
    ${name}   Run Keyword And Ignore error    set suite variable    ${name}        ${report}[name]
    ${cmd1}   set variable    curl -X 'GET' 'https://scout.nsn-rdnet.net/future/api/v1/kpis_reports/${id}/export_to_excel/
    ${cmd2}   set variable    ?apitoken=${api_key}' -H 'accept: application/vnd.api+json'
    ${url}    ${filename}    wait until keyword succeeds     20min    1min    GenreateReport    cmd=${cmd1}${cmd2}
    ${toolcenter}   set variable    toolscenter.eecloud.dynamic.nsn-net.net
    run    curl -X 'GET' 'http://${toolcenter}/api/rtm/addReport/?url=${url.strip()}&filename=${filename}' -H 'accept: */*'
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}

GenreateReport
    [Arguments]   ${cmd}
    ${ret}    Run    ${cmd}
    log to console    ${ret}
    should be true     ${ret.count('already exist as excel file')}>0
    #should contain    ${ret}    already exist as excel file
    ${ret}     ${dumy}    Split String From Right	 string=${ret}   separator=}     max_split=1
    ${dumy}     ${ret}    Split String 	 string=${ret}   separator={     max_split=1
    ${ret}    set variable    {${ret}}
    ${res}    Evaluate        json.loads('''${ret}''')                   json
    ${pre}    ${filename}    Split String	 string=${res["errors"][0]["detail"]}   separator=:     max_split=1
    ${url}    ${filename}    Split String From Right	 string=${filename}   separator=/     max_split=1
    [Return]   ${url}    ${filename}

get current time
    ${current_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${new_time}  DateTime.Subtract Time From Date  ${current_time}  8hours
    ${new_timestamp}=    DateTime.Convert Date    ${new_time}    result_format=%Y-%m-%d %H:%M:%S.%f
    [Return]     ${new_timestamp}

KW.SuiteSetup
    [Documentation]
    [Arguments]    ${AdaptConfigurationPath}=${False}
    run keyword if     ${AdaptConfigurationPath}     run keyword and ignore error    UTECloud.ForceAdaptCommissionFiles
    TestSuilt.Start
    Conn.ResetCache

KW.SuiteTeardown
    #TestSuite.Stop
    KW.AirphoneUEJob    operation=Stop
    log to console    SuiteTeardown