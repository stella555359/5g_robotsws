*** Settings ***
Documentation     author: Qian Jianwu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: jianwu.qian@nokia-sbell.com

Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot

*** Variables ***
${TS_CASE_LOG_PATH}     /home/ute/dir/
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${scf_path}    ${commissionings_path}/HGZ/${testline_name}
${8T8R_scf_name}      SCF_8T8R_SBTS00.xml
${WEBUI_ADDR}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}

*** Keywords ***
Common Case Setup For 8538
    log to console    \n***Common Case Setup For 8538***
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}

Common Case Teardown For 8538
    log to console    \n***Common Case Teardown For 8538***
    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM selenium logout

Scf Commition And Wair For On-air
    [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}
    log to console    \n***Scf commition and wair for on-air***
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air

Change Single Parameter Online
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}    ${connection}=GNB_OAM
    log to console    \n***Change Single Parameter Online***
    coam.perform_parameter_recommissioning       ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=${connection}

Change Multiple Parameter Online
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}
    log to console    \n***Change Multiple Parameter Online***
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END
    selenium_coam.validate_plan
    run keyword if  ${is_activate}==True    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Perform RU Reset via WebEM
    [Arguments]    ${ru_index}=${1}
    Log To Console    \n***Perform RU Reset via WebEM***
    ${ru_index}  Convert To Integer    ${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    20min    1min    COAM Check GNB cell on air
    [Teardown]    coam.teardown    connection=GNB_OAM

Start Capture Syslog
    [Arguments]   ${name}=SYSLOG
    ...           ${path}=/tmp/btslog2
    btslog.Create btslog collector
    ...                         name=${name}
    ...                         log_dir=${path}
    btslog.Setup collectors     names=${name}
    btslog.Start collectors     names=${name}
    btslog.Set suite alias      ${name}

Stop Capture Syslog
    [Arguments]   ${name}=SYSLOG
    ...           ${path}=/tmp/btslog2
    btslog.Stop collectors      names=${name}
    btslog.Collect collectors   names=${name}
    btslog.Teardown collectors  names=${name}
    Remove directory   ${path}   recursive=${True}

Get RU Startup Time From Syslog
    [Documentation]
    [Arguments]   ${path}=/tmp/btslog2    ${system_reset}=${False}
    ${start_keyword}    set variable if    '${system_reset}'=='True'    "Shutting down"    "RESET_IND-1 appeared"
    ${syslog_start}    Run    grep -i ${start_keyword} ${path}/*.LOG
	${syslog_end}    Run    grep -i "Radio Module detected" ${path}/*.LOG
	@{start}    split string    ${syslog_start}    separator=
	@{end}    split string    ${syslog_end}    separator=
	${start_time}    split string    ${start}[2]    separator=.
	${end_time}    split string    ${end}[2]    separator=.
	${start_time_split}    split string    ${start_time}[0]    separator=:
	${end_time_split}    split string    ${end_time}[0]    separator=:
	${start_hour}    set variable    ${start_time_split}[0]
	${start_minute}    set variable    ${start_time_split}[1]
	${start_second}    set variable    ${start_time_split}[2]
	${start_hour}    convert to integer    ${start_hour}
	${start_minute}    convert to integer    ${start_minute}
	${start_second}    convert to integer    ${start_second}
	${RU_start_time}    evaluate    ${start_hour}*3600+${start_minute}*60+${start_second}
	${end_hour}    set variable    ${end_time_split}[0]
	${end_minute}    set variable    ${end_time_split}[1]
	${end_second}    set variable    ${end_time_split}[2]
	${end_hour}    convert to integer    ${end_hour}
	${end_minute}    convert to integer    ${end_minute}
	${end_second}    convert to integer    ${end_second}
	${RU_end_time}    evaluate    ${end_hour}*3600+${end_minute}*60+${end_second}
	${startup_time}    evaluate    ${RU_end_time}-${RU_start_time}
	[Return]    ${startup_time}

Get RU Current Time From Terminal
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    csn.Connect to   hostname=${bts_host}   username=${username}   password=${password}   alias=${connection}
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP   ru_alias=RU_1   asik_alias=ASIK Master   connection=${connection}
    ${active_info}   csn.Execute   command=date    connection=RU_1
    @{date_info}    split string    ${active_info}    separator=
    ${time_info}    split string    ${date_info}[3]    separator=:
    ${time_info_hour}    set variable    ${time_info}[0]
	${time_info_minute}    set variable    ${time_info}[1]
	${time_info_second}    set variable    ${time_info}[2]
	${time_info_hour}    convert to integer    ${time_info_hour}
	${time_info_minute}    convert to integer    ${time_info_minute}
	${time_info_second}    convert to integer    ${time_info_second}
	${RU_time}    evaluate    ${time_info_hour}*3600+${time_info_minute}*60+${time_info_second}
	[Return]    ${RU_time}
    [Teardown]   Run Keywords   csn.Disconnect   connection=RU_1
    ...   AND   csn.Disconnect   connection=GNB_OAM

Get RU Active Time From Syslog
    [Documentation]
    [Arguments]   ${path}=/tmp/btslog2
	${syslog_end}    Run    grep -i "Radio Module detected" ${path}/*.LOG
	@{end}    split string    ${syslog_end}    separator=
	${end_time}    split string    ${end}[6]    separator=T
	${end_time_2}    split string    ${end_time}[1]    separator=.
	${end_time_split}    split string    ${end_time_2}[0]    separator=:
	${end_hour}    set variable    ${end_time_split}[0]
	${end_minute}    set variable    ${end_time_split}[1]
	${end_second}    set variable    ${end_time_split}[2]
	${end_hour}    convert to integer    ${end_hour}
	${end_minute}    convert to integer    ${end_minute}
	${end_second}    convert to integer    ${end_second}
	${RU_end_time}    evaluate    ${end_hour}*3600+${end_minute}*60+${end_second}
	[Return]    ${RU_end_time}
