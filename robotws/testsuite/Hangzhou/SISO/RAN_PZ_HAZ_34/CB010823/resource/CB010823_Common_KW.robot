*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Library      taf.selenium.sbts      WITH NAME    sbts_sm
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

*** Keywords ***
Check Diagnostic Report Result
    [Arguments]    ${reports}   ${checkIDs}   ${timestart}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    FOR   ${report}  IN  @{reports}
        log to console  \n${report}
        ${id}=    Get From Dictionary    ${report}    ${Check_ID}
        ${check_point_name}   set variable if  '${stream}'<'SBTS25R1'    ${report['Check point']}   ${report['Check point name']}
        Run Keyword if    '${id}' in ${checkIDs}    Check content of RU diagnostic check report  ${report}
        ...   ${check_point_name}   WebEM   ${timestart}   OK
    END

Get Key value from partial key
    [Arguments]    ${report}   ${partial_key}
    Set Test Variable    ${key_value}   ${None}
    FOR   ${key}  IN  @{report.keys()}
        log to console  \n${key}
        Run Keyword if    '${partial_key}' in '${key}'    Set Test Variable    ${key_value}  ${report['${key}']}
        Exit For Loop If	'${partial_key}' in '${key}'
    END
    [Return]   ${key_value}

Verify RU diagnostic check report in snapshot
    [Arguments]    ${snapshot_path}=${SAVE LOG DIRECTORY}
    log to console    Verify RU diagnostic check report in snapshot
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=Full
    ...    timeout=1500   connection=GNB_OAM
    # ${snapshot_zip_file_path}   set variable   20231019151709/snapshot_20231019152502.zip
    # ${snapshot_unzip_file_path}   set variable   20231019151709/snapshot_20231019152502
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    ${column_release}   set variable if   '${stream}'>'SBTS25R2'    11     10
    ${result}    Get RU diagnostic check result from file
    ...   snapshot_unzip_file_path=${snapshot_unzip_file_path}
    ...   pattern=(BTS[\\d]+_[\\d]+_part_[\\d]+.zip):[^:]*[\\s]+(.*blackbox_DiagnosticReport.*.xz)
    ...   output=${output}   check_point_name=RU Memory usage|RU Temperature sensor   column_num=${column_release}
    Verify List Value Should Be Equal    ${result}    Check point successful
    ${result}    Get RU diagnostic check result from file
    ...   snapshot_unzip_file_path=${snapshot_unzip_file_path}
    ...   pattern=(BTS[\\d]+_[\\d]+_part_[\\d]+.zip):[^:]*[\\s]+(.*[^blackbox]_DiagnosticReport.*.xz)
    ...   output=${output}   check_point_name=RU Memory usage|RU Temperature sensor   column_num=${column_release}
    Verify List Value Should Be Equal    ${result}    Check point successful
    ${result}    Get RU diagnostic check result from file
    ...   snapshot_unzip_file_path=${snapshot_unzip_file_path}
    ...   pattern=(BTS[\\d]+_[\\d]+_part_[\\d]+.zip):[^:]*[\\s]+(.*blackbox_DiagnosticHistoryHistogram.*.xz)
    ...   output=${output}   check_point_name=RU Memory usage|RU Temperature sensor   column_num=8
    Verify List Value Should Morethan ZERO   ${result}    0
    ${result}    Get RU diagnostic check result from file
    ...   snapshot_unzip_file_path=${snapshot_unzip_file_path}
    ...   pattern=(BTS[\\d]+_[\\d]+_part_[\\d]+.zip):[^:]*[\\s]+(.*[^blackbox]_DiagnosticHistoryHistogram.*.xz)
    ...   output=${output}   check_point_name=RU Memory usage|RU Temperature sensor  column_num=8
    Verify List Value Should Morethan ZERO    ${result}    0

Verify List Value Should Be Equal
    [Arguments]    ${result_str}    ${value}
    @{result_list}    string.split string    ${result_str}    separator=\n
    FOR    ${result}  IN  @{result_list}
        Should Be Equal    ${result}    ${value}
    END

Verify List Value Should Morethan ZERO
    [Arguments]    ${result_str}    ${value}
    @{result_list}    string.split string    ${result_str}    separator=\n
    FOR    ${result}  IN  @{result_list}
        Should Be True    ${result}>=${value}
    END


Get RU diagnostic check result from file
    [Arguments]    ${snapshot_unzip_file_path}=${SAVE LOG DIRECTORY}   ${pattern}=None    ${output}=None
    ...   ${check_point_name}=None   ${column_num}=0
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}   1   2
    ${btspart_tuple}   Set Variable    @{btspart_list}[0]
    ${btspart}   Set Variable    ${btspart_tuple}[0]
    ${btspart_name} =   string.Replace String   ${btspart}   .zip   ${EMPTY}   count=1
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}
    ...                 ${snapshot_unzip_file_path}/${btspart_name}
    ${file_name} =   string.Replace String   ${btspart_tuple}[1]   .xz   ${EMPTY}   count=1
    ${file_path}    Set Variable    ${snapshot_unzip_file_path}/${btspart_name}
    Run    xz -d ${file_path}/${btspart_tuple}[1]
    ${result}    Run    cat ${file_path}/${file_name} |grep -E "${check_point_name}"| awk -F ',' '{print $${column_num}}'
    [Return]   ${result}

FULL Diagnostic check from WebEM
    [Arguments]
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    ${timestartTmp}   Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    log to console  \n Activate diagnostic check
    Run Keyword And Ignore Error    sbts_sm.start diagnostic check    scope=Full diagnostic check   timeout=300   allow_service_impact=${False}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    ${reports}    sbts_sm.get report
    ${checkIDs}    create list   41   42
    FOR    ${report}  IN  @{reports.keys()}
        ${v}=    Get From Dictionary    ${reports}    ${report}
        log to console  \n***report key[${report}]***
        # log to console  \n${v}
        Run Keyword if   "${report}"=="RU diagnostic check report"   Check Diagnostic Report Result   reports=${v}
        ...  checkIDs=${checkIDs}  timestart=${timestart}
    END
	Verify RU diagnostic check report in snapshot
	${check_points}    create list   41
	Online Set excludedDiagnosticCheckPoints   check_points=${check_points}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Online Set excludedDiagnosticCheckPoints
    [Arguments]  ${check_points}=${empty}
    log to console  \n Online Set excludedDiagnosticCheckPoints
    Run Keyword And Ignore Error    selenium_coam.remove_element
    ...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Excluded Diagnostic Check Points    abbr=excludedDiagnosticCheckPoints
    ${object_num}   Get Length   ${check_points}
    selenium_coam.add_element
        ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    filter_param=Excluded Diagnostic Check Points    abbr=excludedDiagnosticCheckPoints    timeout=15
    ${object_num}   Get Length   ${check_points}
    FOR  ${index}  IN RANGE  ${object_num}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
            ...    filter_param=Excluded Diagnostic Check Points    new_value=${check_points}[${index}]
            ...    node_index=${index}
    END
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan

RF Diagnostic check online from WebEM
    [Arguments]
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    ${timestartTmp}   robot.libraries.DateTime.Get Current Date
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    log to console  \n Activate diagnostic check
    #    radio_checkpoints = {
#    "RMOD-1 / RMOD_R-1 (AEQY)": [
#        '21 - Radio Module ethernet link',
#        '42 - RU Temperature sensor'
#    ]
#    }
    ${checkpoints}    create list   41 - RU Memory usage   42 - RU Temperature sensor
    &{radio_checkpoints}   create dictionary   RMOD-1 / RMOD_R-1 (AEQE)=${checkpoints}
    Run Keyword And Ignore Error    sbts_sm.start diagnostic check    scope=Customized diagnostic check
    ...   radio_checkpoints=${radio_checkpoints}   timeout=300   allow_service_impact=${False}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    ${reports}    sbts_sm.get report
    ${checkIDs}    create list   41   42
    FOR    ${report}  IN  @{reports.keys()}
        ${v}=    Get From Dictionary    ${reports}    ${report}
        log to console  \n***report key[${report}]***
        # log to console  \n${v}
        Run Keyword if   "${report}"=="RU diagnostic check report"   Check Diagnostic Report Result   reports=${v}
        ...  checkIDs=${checkIDs}  timestart=${timestart}
    END
	Verify RU diagnostic check report in snapshot
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Check content of RU diagnostic check report
    [Arguments]    ${report}   ${check_point}   ${trigger_type}   ${timestart}   ${result}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    ${Last execution time}   set variable if  '${stream}'<'SBTS25R1'    Last execution time   Execution time
    ${timeendTmp}    Get Key value from partial key   ${report}   ${Last execution time}
    ${date_format}   set variable if  '${stream}'<'SBTS25R1'    %Y-%m-%dT%H:%M:%S%z   %d.%m.%Y %H:%M:%S
    ${timeend}   robot.libraries.DateTime.convert date   ${timeendTmp}    epoch   exclude_millis=yes   date_format=${date_format}

    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    should be true   ${duration_time_tmp}>=0
    ${result_25R1}   set variable if  '${result}'=='OK'    Check point successful   Check point failure
    Run Keyword if    '${stream}'<'SBTS25R1'    Run Keywords
    ...   Should be equal as strings    ${report['Check point']}   ${check_point}
    ...   AND   Should be equal as strings    ${report['Last definitive result']}   ${result}
    ...   AND   Should be equal as strings    ${report['Last execution result']}   ${result}
    ...   AND   Should be equal as strings    ${report['Trigger type']}   ${trigger_type}
    ...   ELSE   Run Keywords
    ...   Should be equal as strings    ${report['Check point name']}   ${check_point}
    ...   AND   Should be equal as strings    ${report['Check status']}   ${result_25R1}
    ...   AND   Should be equal as strings    ${report['Trigger type']}   ${trigger_type}

Automatic Execution of Diagnostic check from webEM with cell onAir
    [Arguments]
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    120s
	${timestartTmp}   Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    sleep    60s
    Selenium Login And Disable Screen Lock    version=${stream}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    ${reports}    sbts_sm.get report
    ${checkIDs}    create list   41   42
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    FOR    ${report}  IN  @{reports['RU diagnostic check report']}
        log to console  \n${report}
        ${id}=    Get From Dictionary    ${report}    ${Check_ID}
        Run Keyword if    '${id}' =='41'    Check content of RU diagnostic check report
        ...   ${report}   RU Memory usage   Automatic   ${timestart}   OK
        Run Keyword if    '${id}' =='42'    Check content of RU diagnostic check report
        ...   ${report}   RU Temperature sensor   Automatic   ${timestart}   OK
    END
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Enable Diagnostic Check Schedule without service impact
    [Arguments]   ${time_in_seconds}=600
    log to console  \n Enable Diagnostic Check Schedule without service impact
    Run Keyword And Ignore Error    selenium_coam.remove_element
    ...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Diagnostic Check schedule    abbr=diagnosticCheckSchedule
    Run Keyword And Ignore Error    selenium_coam.validate_plan
    Run Keyword And Ignore Error    selenium_coam.activate_plan
    ${timeZone}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1
    ...    filter_param=Time zone
    ...    abbr=timeZone
    #(GMT+8) Asia/Shanghai
    ${diff_hour_list}=    String.Get Regexp Matches    ${timeZone}    \(GMT(?P<diff_hour>[-+]\\d+)\)    diff_hour
    ${timestartTmp}   robot.libraries.DateTime.Get Current Date   UTC   ${diff_hour_list}[0] hours
    #${timestartTmp}   robot.libraries.DateTime.Get Current Date
    ${add_time} = 	robot.libraries.DateTime.Convert Time 	${time_in_seconds} 	timer 	exclude_milles=false
    ${date}=    robot.libraries.DateTime.Add Time To Date    ${timestartTmp}	${add_time}
    ${checkDay}=    robot.libraries.DateTime.Convert Date    ${date}    result_format=%A

    ${prefix_checkDay}=    set variable if    '${checkDay}'=='Monday'    0 - Monday
    ...    '${checkDay}'=='Tuesday'    1 - Tuesday
    ...    '${checkDay}'=='Wednesday'    2 - Wednesday
    ...    '${checkDay}'=='Thursday'    3 - Thursday
    ...    '${checkDay}'=='Friday'    4 - Friday
    ...    '${checkDay}'=='Saturday'    5 - Saturday
    ...    '${checkDay}'=='Sunday'    6 - Sunday
    ...    Undefined
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${checkDay}=    set variable if  '${stream}'>'SBTS25R1'    ${prefix_checkDay}    ${checkDay}

    ${date}=    robot.libraries.DateTime.Convert Date   ${date}    exclude_millis=yes
    ${timestart}      robot.libraries.DateTime.convert date    ${date}    epoch

    selenium_coam.add_element
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Diagnostic Check schedule    abbr=diagnosticCheckSchedule    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Check Days
    ...    abbr=checkDays
    ...    new_value=${checkDay}   node_index=${0}
    @{split_date}    string.split string    ${date}    separator=${SPACE}
    ${check_time}    set variable    ${split_date}[1]
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Check Time    abbr=checkTime
    ...    new_value=${check_time}    node_index=${0}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    ${time_tmp}=   Convert To Integer  ${time_in_seconds}
    Sleep    ${time_tmp+180}
    ${reports}    sbts_sm.get report
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    FOR    ${report}  IN  @{reports['RU diagnostic check report']}
        log to console  \n${report}
        ${id}=    Get From Dictionary    ${report}    ${Check_ID}
        Run Keyword if    '${id}' =='41'    Check content of RU diagnostic check report
        ...   ${report}   RU Memory usage   Scheduled   ${timestart}   OK
        Run Keyword if    '${id}' =='42'    Check content of RU diagnostic check report
        ...   ${report}   RU Temperature sensor   Scheduled   ${timestart}   OK
    END

Enable Diagnostic Check Schedule with service impact
    [Arguments]   ${time_in_seconds}=600
    log to console  \n Enable Diagnostic Check Schedule with service impact
    Run Keyword And Ignore Error    selenium_coam.remove_element
    ...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Service Impacting Diagnostic Check schedule    abbr=servImpDiagnosticCheckSchedule
    Run Keyword And Ignore Error    selenium_coam.validate_plan
    Run Keyword And Ignore Error    selenium_coam.activate_plan
    selenium_coam.add_element
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Service Impacting Diagnostic Check schedule    abbr=servImpDiagnosticCheckSchedule    timeout=15

    ${timeZone}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1
    ...    filter_param=Time zone
    ...    abbr=timeZone
    #(GMT+8) Asia/Shanghai
    ${diff_hour_list}=    String.Get Regexp Matches    ${timeZone}    \(GMT(?P<diff_hour>[-+]\\d+)\)    diff_hour
    ${timestartTmp}   robot.libraries.DateTime.Get Current Date   UTC   ${diff_hour_list}[0] hours
    ${add_time} = 	robot.libraries.DateTime.Convert Time 	${time_in_seconds} 	timer 	exclude_milles=false
    ${date}=    robot.libraries.DateTime.Add Time To Date    ${timestartTmp}	${add_time}
    ${checkDay}=    robot.libraries.DateTime.Convert Date    ${date}    result_format=%A

    ${prefix_checkDay}=    set variable if    '${checkDay}'=='Monday'    0 - Monday
    ...    '${checkDay}'=='Tuesday'    1 - Tuesday
    ...    '${checkDay}'=='Wednesday'    2 - Wednesday
    ...    '${checkDay}'=='Thursday'    3 - Thursday
    ...    '${checkDay}'=='Friday'    4 - Friday
    ...    '${checkDay}'=='Saturday'    5 - Saturday
    ...    '${checkDay}'=='Sunday'    6 - Sunday
    ...    Undefined
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    #${checkDay}=    set variable if  '${stream}'>'SBTS25R1'    ${prefix_checkDay}    ${checkDay}
    ${checkDay}=    set variable    ${checkDay}
    ${date}=    robot.libraries.DateTime.Convert Date   ${date}    exclude_millis=yes
    @{split_date}    string.split string    ${date}    separator=${SPACE}
    ${startDate}    set variable    ${split_date}[0]
    ${check_time}    set variable    ${split_date}[1]
    ${timestart}      robot.libraries.DateTime.convert date    ${date}    epoch
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Check day
    ...    abbr=checkDay
    ...    new_value=${checkDay}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Check time
    ...    abbr=checkTime
    ...    new_value=${check_time}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Start Date
    ...    abbr=startDate
    ...    new_value=${startDate}    node_index=${0}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    ${time_tmp}=   Convert To Integer  ${time_in_seconds}
    Sleep    ${time_tmp+300}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    ${reports}    sbts_sm.get report
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    FOR    ${report}  IN  @{reports['RU diagnostic check report']}
        log to console  \n${report}
        ${id}=    Get From Dictionary    ${report}    ${Check_ID}
        Run Keyword if    '${id}' =='41'    Check content of RU diagnostic check report
        ...   ${report}   RU Memory usage   Scheduled   ${timestart}   OK
        Run Keyword if    '${id}' =='42'    Check content of RU diagnostic check report
        ...   ${report}   RU Temperature sensor   Scheduled   ${timestart}   OK
    END

Scheduled Execution of Diagnostic check from WebEM
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    Enable Diagnostic Check Schedule without service impact
    Run Keyword And Ignore Error    selenium_coam.remove_element
    ...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Diagnostic Check schedule    abbr=diagnosticCheckSchedule

    Enable Diagnostic Check Schedule with service impact
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    Run Keyword And Ignore Error    selenium_coam.remove_element
    ...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   filter_param=Service Impacting Diagnostic Check schedule    abbr=servImpDiagnosticCheckSchedule
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Execute FRMON COMMAND In RU
    [Arguments]    ${command}   ${sudo}   ${connection}
    ${output}  csn.execute  command=echo ${command}|${sudo} frmonShellClient 127.0.0.1 2000
    ...    connection=${connection}   timeout=30
    Should Contain Any   ${output}    done ok    Path already taken
    Sleep  1s

Trigger Fault 4681 In RU For RU Memory usage
    [Arguments]    ${ru_index}=1
    log to console  \n Trigger Fault 4681 In RU For RU Memory usage
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console  \ncreate file runtime_config.txt under /mnt/runtime/configs and /mnt/runtime
    #csn.Send Command    command=${sudo} su    connection=RU_${ru_index}   timeout=30   get_pty=${False}
    csn.execute    command=${sudo} touch /mnt/runtime/configs/runtime_config.txt   connection=RU_${ru_index}   timeout=30
    csn.execute   command=${sudo} touch /mnt/runtime/runtime_config.txt   connection=RU_${ru_index}   timeout=30

    log to console  \n decode sysmon_primary.bin and save to ca
    #log to console  \n${output}
    ${command}   set variable   / action create ConfigAccess /CI/ConfigAccess /module
    ${output}   csn.execute   command=echo ${command}|${sudo} frmonShellClient 127.0.0.1 2000
    ...   connection=RU_${ru_index}   timeout=30
    Should Contain Any   ${output}    done ok    Path already taken
    Execute FRMON COMMAND In RU   command=/CI/ConfigAccess action fetch DECODED \\"sysmon_primary.bin\\" \\"/ram/sysmon_primary.json\\"
    ...   sudo=${sudo}   connection=RU_${ru_index}
    log to console  \n change memoryTestThreshold 100.0 to 10.0 in /ram/sysmon_primary.json
    ${output}    csn.execute
    ...   command=${sudo} cat /ram/sysmon_primary.json |grep memoryTestThreshold
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n ${output}
    ${output}    csn.execute
    ...   command=${sudo} sed -i -E 's/\"memoryTestThreshold\"\:[[:space:]]+.*/"memoryTestThreshold": 10.0/g' /ram/sysmon_primary.json
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n ${output}

    log to console  \n save /ram/sysmon_primary.json
    ${command}   set variable   /CI/ConfigAccess action store PERMANENT DECODED \\"sysmon_primary.bin\\" \\"/ram/sysmon_primary.json\\"
    ${output}   csn.execute   command=echo ${command}|${sudo} frmonShellClient 127.0.0.1 2000
    ...   connection=RU_${ru_index}   timeout=30
    Should Contain Any   ${output}    done ok    Path already taken

    csn.disconnect    connection=RU_${ru_index}
    Perform RU Reset
    sleep    100s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console  \n remove file runtime_config.txt under /mnt/runtime/configs and /mnt/runtime
    #csn.Send Command    command=${sudo} su    connection=RU_${ru_index}   timeout=30   get_pty=${False}
    csn.execute    command=${sudo} rm -f /mnt/runtime/configs/runtime_config.txt   connection=RU_${ru_index}   timeout=30
    csn.execute   command=${sudo} rm -f /mnt/runtime/runtime_config.txt   connection=RU_${ru_index}   timeout=30
    Change parameter value in json file   sudo=${sudo}   ru_index=1   filename=sysmon_primary
    ...   key_name=memoryTestThreshold   new_value=100.0
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Change parameter value in json file
    [Arguments]    ${sudo}   ${ru_index}=1   ${filename}=sysmon_primary
    ...   ${key_name}=memoryTestThreshold   ${new_value}=100.0
    log to console  \n Create frmon ConfigAccess agent
    csn.execute   command=${sudo} mount -o remount,rw /mnt/factory/   connection=RU_${ru_index}   timeout=30
    ${command}   set variable   / action create ConfigAccess /CI/ConfigAccess /module
    Execute FRMON COMMAND In RU   command=${command}
    ...   sudo=${sudo}   connection=RU_${ru_index}
    log to console  \n Fetch ${filename}.json
    Execute FRMON COMMAND In RU   command=/CI/ConfigAccess action fetch DECODED \\"${filename}.bin\\" \\"/ram/${filename}.json\\"
    ...   sudo=${sudo}   connection=RU_${ru_index}
    log to console  \n Edit and save ${filename}.json, change ${key_name} parameter value

    # Read Json from File
    ${json_string}    csn.execute
    ...   command=${sudo} cat /ram/${filename}.json
    ...   connection=RU_${ru_index}   timeout=30

    ${json_string}    evaluate   json.loads(r'''${json_string}''')    json
    ${old_value}    Get Value From Json    ${json_string}    ${key_name}
    log to console   Before change ${key_name} value: ${old_value}

    # Modify Json value
    ${updated_dict}    Update Value In Json    json_data=${json_string}   key_name=${key_name}   new_value=${new_value}
    ${new_value}    Get Value From Json    json_data=${updated_dict}    key_name=${key_name}
    log to console   After change ${key_name} value: ${new_value}
    ${json_string}    evaluate   json.dumps($updated_dict)   json

    log to console  \n save /ram/${filename}.json
    csn.execute   command=${sudo} -u rfsw sh -c 'echo '\\''${json_string}'\\''>/ram/${filename}.json'
    ...   connection=RU_${ru_index}   timeout=30
    ${output}    csn.execute   command=${sudo} cat /ram/${filename}.json   connection=RU_${ru_index}
    log to console  ${output}

    ${command}   set variable   /CI/ConfigAccess action store PERMANENT DECODED \\"${filename}.bin\\" \\"/ram/${filename}.json\\"
    Execute FRMON COMMAND In RU   command=${command}
    ...   sudo=${sudo}   connection=RU_${ru_index}

Trigger Fault 4681 In RU For RU Temperature sensor
    [Arguments]    ${ru_index}=1
    log to console  \n Trigger Fault 4681 In RU For RU Temperature sensor
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console  \n${sudo}
    #csn.Send Command    command=${sudo} su    connection=RU_${ru_index}   timeout=30   get_pty=${False}
    #${output}=   csn.Read Output     connection=RU_${ru_index}
    #log to console  \n${output}
    ${MADE_alias}   set variable    node_1
    csn.connect to    hostname=192.168.101.2
    ...   username=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...   password=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ...                              alias=${MADE_alias}
    ...                              proxy=RU_${ru_index}
    ...                              port=${22}
    ${sudo}    csn.execute   command=which sudo    connection=${MADE_alias}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${command}   set variable   / action create ConfigAccess /ca /module
    ${output}   csn.execute   command=echo ${command}|${sudo} frmonShellClient 127.0.0.1 2000
    ...   connection=${MADE_alias}   timeout=30
    Should Contain Any   ${output}    done ok    Path already taken
    FOR   ${index}  IN RANGE  1   8   2
        Execute FRMON COMMAND In RU
        ...   command=/ action create ThermometerDevice /CI/thermometerDevice/temp/pa${index}_${index+1} /temp/pa${index}_${index+1}
        ...   sudo=${sudo}   connection=${MADE_alias}
    END
    FOR   ${index}  IN RANGE  1   8   2
        Execute FRMON COMMAND In RU   command=/CI/thermometerDevice/temp/pa${index}_${index+1} action override FAULTY
        ...   sudo=${sudo}   connection=${MADE_alias}
    END
    csn.disconnect    connection=${MADE_alias}

    ${MADE_alias}   set variable    node_2
    csn.connect to    hostname=192.168.101.3
    ...   username=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...   password=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ...                              alias=${MADE_alias}
    ...                              proxy=RU_${ru_index}
    ${command}   set variable   / action create ConfigAccess /ca /module
    ${output}   csn.execute  command=echo ${command}|${sudo} frmonShellClient 127.0.0.1 2000    connection=${MADE_alias}
    ...      timeout=30
    Should Contain Any   ${output}    done ok    Path already taken
    FOR   ${index}  IN RANGE  9   16   2
        Execute FRMON COMMAND In RU
        ...   command=/ action create ThermometerDevice /CI/thermometerDevice/temp/pa${index}_${index+1} /temp/pa${index}_${index+1}
        ...   sudo=${sudo}   connection=${MADE_alias}
    END
    FOR   ${index}  IN RANGE  9   16   2
        Execute FRMON COMMAND In RU   command=/CI/thermometerDevice/temp/pa${index}_${index+1} action override FAULTY
        ...   sudo=${sudo}   connection=${MADE_alias}
    END
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Check 4681 fault in NOK cases
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    Get Ru Running Index From Configuration Index    ru_index=1
    wait until keyword succeeds    1x   20s    run keywords   Trigger Fault 4681 In RU For RU Memory usage   AND
    ...   Check 41 RU Memory usage   stream=${stream}
    wait until keyword succeeds    1x   20s    run keywords   Trigger Fault 4681 In RU For RU Temperature sensor   AND
    ...   Check 42 RU Temperature sensor  stream=${stream}

Check 41 RU Memory usage
    [Arguments]    ${stream}=SBTS24R1
    Trigger Fault 4681 In RU For RU Memory usage
    Selenium Login And Disable Screen Lock    version=${stream}
    sbts_sm.refresh_page
    sleep   10s
    wait until keyword succeeds    2x   20s    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    ${timestartTmp}    Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    log to console  \n Activate diagnostic check
    Run Keyword And Ignore Error    sbts_sm.start diagnostic check    scope=Full diagnostic check   timeout=300   allow_service_impact=${False}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    ${reports}    sbts_sm.get report
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    ${Radio_module}   set variable if  '${stream}'<'SBTS25R1'    Radio module   Target distinguished name
    FOR    ${report}  IN  @{reports['RU diagnostic check report']}
        log to console  \n${report}
        ${id}     Get From Dictionary    ${report}    ${Check_ID}
        ${rmod_name}    Get From Dictionary    ${report}    ${Radio_module}
        Run Keyword if    '${id}' =='41' and 'RMOD_R-${rmod_running_index}' in '${rmod_name}'
        ...   Check content of RU diagnostic check report
        ...   ${report}   RU Memory usage   WebEM   ${timestart}   NOK
        Run Keyword if        '${id}' =='42' and 'RMOD_R-${rmod_running_index}' in '${rmod_name}'
        ...   Check content of RU diagnostic check report
        ...   ${report}   RU Temperature sensor   WebEM   ${timestart}   OK
    END
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Perform RU Reset
    sleep    100s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'

Check 42 RU Temperature sensor
    [Arguments]    ${stream}=SBTS24R1
    Selenium Login And Disable Screen Lock    version=${stream}
    sleep    10min
    sbts_sm.refresh_page
    sleep   10s
    wait until keyword succeeds    2x   20s    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    ${timestartTmp}   Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    log to console  \n Activate diagnostic check
    sbts_sm.start diagnostic check    scope=Full diagnostic check   timeout=300   allow_service_impact=${False}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    ${reports}    sbts_sm.get report
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    ${Radio_module}   set variable if  '${stream}'<'SBTS25R1'    Radio module   Target distinguished name
    FOR    ${report}  IN  @{reports['RU diagnostic check report']}
        log to console  \n${report}
        ${id}=    Get From Dictionary    ${report}    ${Check_ID}
        ${rmod_name}    Get From Dictionary    ${report}    ${Radio_module}
        Run Keyword if    '${id}' =='41' and 'RMOD_R-${rmod_running_index}' in '${rmod_name}'
        ...   Check content of RU diagnostic check report
        ...   ${report}   RU Memory usage   WebEM   ${timestart}   OK
        Run Keyword if        '${id}' =='42' and 'RMOD_R-${rmod_running_index}' in '${rmod_name}'
        ...   Check content of RU diagnostic check report
        ...   ${report}   RU Temperature sensor   WebEM   ${timestart}   NOK
    END
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    120s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'

Check from WebEM CP40 NOK
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    wait until keyword succeeds    3x   20s    Trigger CP40 In RU
    wait until keyword succeeds    3x   20s    Check CP40 NOK   stream=${stream}
    [Teardown]    Recover CP40 In RU

Trigger CP40 In RU
    [Arguments]    ${ru_index}=1
    log to console  \n Trigger Fault CP40
    Connect to Common Unit Master
    Set SW Config on gNB    rad_param=0x48003A   rad_param_value=1   connection=ASIK Master
    csn.disconnect    connection=ASIK Master
    Perform BTS Site Reset
    sleep    120s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'

    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}

    log to console  \n Step2 change the crc32 hash in integrity json for active slot
    ${output}   csn.execute   command=${sudo} SWmanShellCommand -i   connection=RU_${ru_index}   timeout=30
    ${resultRegexp}=    String.Get Regexp Matches    ${output}    it's (\\w+)\\s+   1
    ${active_slot}    set variable if   '${resultRegexp[0]}'=='active'   0   1
    log to console  \n ${output}, active slot:${active_slot}
    set test variable   ${filename_old}   /mnt/runtime/swman/swman-integrity_slot${active_slot}.json
    set test variable   ${filename_backup}   /tmp/swman-integrity_slot${active_slot}.json_bak
    ${output}    csn.execute
    ...   command=${sudo} cp ${filename_old} ${filename_backup}
    ...   connection=RU_${ru_index}   timeout=30
    ${output}    csn.execute
    ...   command=${sudo} cat ${filename_old} |grep digest
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n Before change:${output}
    ${output}    csn.execute
    ...   command=${sudo} sed -i -E '1,/\"digest\"\:[[:space:]]+.*/s/\"digest\"\:[[:space:]]+.*/"digest": "ffffffff"/g' ${filename_old}
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n ${output}
    ${output}    csn.execute
    ...   command=${sudo} cat ${filename_old} |grep digest
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n After change:${output}
    log to console  \n save ${filename_old}
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Recover CP40 In RU
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Set SW Config on gNB    rad_param=0x48003A   rad_param_value=0   connection=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${exist}   csn.File Exists    ${filename_backup}    connection=RU_${ru_index}
    Run Keyword If   ${exist}
    ...   csn.execute
    ...   command=${sudo} cp ${filename_backup} ${filename_old}
    ...   connection=RU_${ru_index}   timeout=30
    ${output}    csn.execute
    ...   command=${sudo} cat ${filename_old} |grep digest
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n Recover change:${output}
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Check CP40 NOK
    [Arguments]    ${stream}=SBTS24R1
    Selenium Login And Disable Screen Lock    version=${stream}
    add fault to the allowed fault list    faultId=${4681}
    sbts_sm.refresh_page
    sleep   10s
    wait until keyword succeeds    2x   20s    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    ${timestartTmp}   Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    log to console  \n Activate diagnostic check
    Run Keyword And Ignore Error    sbts_sm.start diagnostic check    scope=Full diagnostic check   timeout=300   allow_service_impact=${False}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=300
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    ${reports}    sbts_sm.get report
    set test variable  ${result}   FAIL
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    FOR    ${report}  IN  @{reports['RU diagnostic check report']}
        log to console  \n${report}
        ${id}=    Get From Dictionary    ${report}    ${Check_ID}
        Run Keyword if    '${id}' =='40'    Run Keywords   Check content of RU diagnostic check report
        ...   ${report}   RU SW package and NVM integrity   WebEM   ${timestart}   NOK   AND
        ...   set test variable  ${result}   PASS
        Run Keyword if    '${id}' =='41'    Check content of RU diagnostic check report
        ...   ${report}   RU Memory usage   WebEM   ${timestart}   OK
        Run Keyword if    '${id}' =='42'    Check content of RU diagnostic check report
        ...   ${report}   RU Temperature sensor   WebEM   ${timestart}   OK
    END
    should be true  '${result}'=='PASS'
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Set SW Config on gNB
    [Documentation]    :Author: Srihari Janardhan  | This keyword sets the rnd params in the common module
    ...
    ...     :param rad_param:   rad param to set
    ...     :param rad_param_value:     value for rad param
    [Arguments]  ${rad_param}  ${rad_param_value}  ${connection}=ASIK Master
    ssh.Send Command
    ...    command=telnet 0 15007  connection=${connection}
    ssh.Read Output Until
    ...    match=AaShell>${SPACE}
    ...    timeout=3
    ...    connection=${connection}
    ssh.Write Input
    ...    data=rad -mpw ${rad_param} ${rad_param_value}\n
    ...    connection=${connection}
    ssh.Write Input
    ...    data=quit\n
    ...    connection=${connection}
    ssh.Read Output Until
    ...    match=Bye ...
    ...    timeout=3
    ...    connection=${connection}

Trigger CP43 In RU
    [Arguments]    ${ru_index}=1
    log to console  \n Trigger Fault CP43
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}

    log to console  \n Step2: Create file runtime_config.txt under /mnt/runtime/configs and /mnt/runtime
    csn.execute    command=${sudo} touch /mnt/runtime/configs/runtime_config.txt   connection=RU_${ru_index}   timeout=30
    csn.execute   command=${sudo} touch /mnt/runtime/runtime_config.txt   connection=RU_${ru_index}   timeout=30

    log to console  \n Step3: Create frmon ConfigAccess agent
    csn.execute   command=${sudo} mount -o remount,rw /mnt/factory/   connection=RU_${ru_index}   timeout=30
    ${command}   set variable   / action create ConfigAccess /CI/ConfigAccess /module
    Execute FRMON COMMAND In RU   command=${command}
    ...   sudo=${sudo}   connection=RU_${ru_index}

    #Note: some platforms only have sysmon_primary.bin while other have both sysmon_primary.bin and sysmon_secondary.bin
    # (in such case - both should be modified). For this reason the whole process of sysmon config modification or
    # deletion is considered as platform specific.
    Change ddrPostResultPass parameter value in file   sudo=${sudo}  ru_index=1   filename=sysmon_primary
    Run Keyword And Ignore Error    Change ddrPostResultPass parameter value in file   sudo=${sudo}   ru_index=1
    ...   filename=sysmon_secondary
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    Perform RU Reset
    sleep    100s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Change ddrPostResultPass parameter value in file
    [Arguments]    ${sudo}   ${ru_index}=1   ${filename}=sysmon_primary
    log to console  \n Step4: Fetch ${filename}
    Execute FRMON COMMAND In RU   command=/CI/ConfigAccess action fetch DECODED \\"${filename}.bin\\" \\"/ram/${filename}.json\\"
    ...   sudo=${sudo}   connection=RU_${ru_index}
    log to console  \n Step5: Edit and save ${filename}.json, change ddrPostResultPass parameter value
    ${output}    csn.execute
    ...   command=${sudo} cat /ram/${filename}.json |grep -iE \"(POST_TEST_PASS|POST_SLOW_TEST_PASS)\"
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n ${output}
    ${output}    csn.execute
    ...   command=${sudo} sed -i -E 's/\"POST_TEST_PASS\"/"isfail1"/g' /ram/${filename}.json
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n ${output}
    ${output}    csn.execute
    ...   command=${sudo} sed -i -E 's/\"POST_SLOW_TEST_PASS\"/"isfail2"/g' /ram/${filename}.json
    ...   connection=RU_${ru_index}   timeout=30
    log to console  \n ${output}

    log to console  \n save /ram/${filename}.json
    ${command}   set variable   /CI/ConfigAccess action store PERMANENT DECODED \\"${filename}.bin\\" \\"/ram/${filename}.json\\"
    Execute FRMON COMMAND In RU   command=${command}
    ...   sudo=${sudo}   connection=RU_${ru_index}

Recover CP43 In RU
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console  \n remove file runtime_config.txt under /mnt/runtime/configs and /mnt/runtime
    csn.execute    command=${sudo} rm -f /mnt/runtime/configs/runtime_config.txt   connection=RU_${ru_index}   timeout=30
    csn.execute   command=${sudo} rm -f /mnt/runtime/runtime_config.txt   connection=RU_${ru_index}   timeout=30

    log to console  \n Step3: Create frmon ConfigAccess agent
    csn.execute   command=${sudo} mount -o remount,rw /mnt/factory/   connection=RU_${ru_index}   timeout=30
    ${command}   set variable   / action create ConfigAccess /CI/ConfigAccess /module
    Execute FRMON COMMAND In RU   command=${command}
    ...   sudo=${sudo}   connection=RU_${ru_index}

    #Note: some platforms only have sysmon_primary.bin while other have both sysmon_primary.bin and sysmon_secondary.bin
    # (in such case - both should be modified). For this reason the whole process of sysmon config modification or
    # deletion is considered as platform specific.
    Change ddrPostResultPass parameter value by json  sudo=${sudo}  ru_index=1   filename=sysmon_primary
    ...   value1=POST_TEST_PASS   value2=POST_SLOW_TEST_PASS
    Run Keyword And Ignore Error    Change ddrPostResultPass parameter value by json   sudo=${sudo}   ru_index=1
    ...   filename=sysmon_secondary   value1=POST_TEST_PASS   value2=POST_SLOW_TEST_PASS
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
#    Perform RU Reset
#    sleep    100s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Check CP43 ${expect_result}
    [Arguments]
    Selenium Login And Disable Screen Lock    version=${stream}
    add fault to the allowed fault list    faultId=${4681}
    sbts_sm.refresh_page
    sleep   10s
    wait until keyword succeeds    2x   20s    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    ${timestartTmp}    Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    log to console  \n Activate diagnostic check
    Run Keyword And Ignore Error    sbts_sm.start diagnostic check    scope=Full diagnostic check   timeout=900   allow_service_impact=${True}
    ${close_tag}    sbts_sm.Start Up View Window Exists    timeout=500
    Run Keyword if    ${close_tag}    sbts_sm.close start up view window
    Wait Until Keyword Succeeds    8min    30s    Verify all cells should be onair   cell_type=${cell_type}
    # sleep    180s
    ${reports}    wait until keyword succeeds    3x   20s    sbts_sm.get report
    set test variable  ${result}   FAIL
    ${Check_ID}   set variable if  '${stream}'<'SBTS25R1'    ID   Check point
    FOR    ${report}  IN  @{reports['RU diagnostic check report']}
        log to console  \n${report}
        ${id}=    Get From Dictionary    ${report}    ${Check_ID}
        Run Keyword if    '${id}' =='43'    Run Keywords   Check content of RU diagnostic check report
        ...   ${report}   Extended RU DDR tests   WebEM   ${timestart}   ${expect_result}   AND
        ...   set test variable  ${result}   PASS
    END
    should be true  '${result}'=='PASS'
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Check from WebEM CP43 NOK
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    set test variable   ${stream}   ${split_version[0]}
    wait until keyword succeeds    1x   20s    Trigger CP43 In RU By Json
    wait until keyword succeeds    1x   20s    Check CP43 NOK
    #Recover CP43 In RU
    #wait until keyword succeeds    1x   20s    Check CP43 OK
    [Teardown]    Run Keywords    Recover CP43 In RU
    ...           AND    wait until keyword succeeds    1x   20s    Check CP43 OK

Trigger CP43 In RU By Json
    [Arguments]    ${ru_index}=1
    log to console  \n Trigger Fault CP43
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute   command=which sudo    connection=RU_${ru_index}   timeout=30
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}

    log to console  \n Step2: Create file runtime_config.txt under /mnt/runtime/configs and /mnt/runtime
    csn.execute    command=${sudo} touch /mnt/runtime/configs/runtime_config.txt   connection=RU_${ru_index}   timeout=30
    csn.execute   command=${sudo} touch /mnt/runtime/runtime_config.txt   connection=RU_${ru_index}   timeout=30

    log to console  \n Step3: Create frmon ConfigAccess agent
    csn.execute   command=${sudo} mount -o remount,rw /mnt/factory/   connection=RU_${ru_index}   timeout=30
    ${command}   set variable   / action create ConfigAccess /CI/ConfigAccess /module
    Execute FRMON COMMAND In RU   command=${command}
    ...   sudo=${sudo}   connection=RU_${ru_index}

    #Note: some platforms only have sysmon_primary.bin while other have both sysmon_primary.bin and sysmon_secondary.bin
    # (in such case - both should be modified). For this reason the whole process of sysmon config modification or
    # deletion is considered as platform specific.
    Change ddrPostResultPass parameter value by json  sudo=${sudo}  ru_index=1   filename=sysmon_primary
    Run Keyword And Ignore Error    Change ddrPostResultPass parameter value by json   sudo=${sudo}   ru_index=1
    ...   filename=sysmon_secondary
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    #Perform RU Reset
    #sleep    100s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Change ddrPostResultPass parameter value by json
    [Arguments]    ${sudo}   ${ru_index}=1   ${filename}=sysmon_primary
    ...   ${value1}=isfail1   ${value2}=isfail2
    log to console  \n Step4: Fetch ${filename}
    Execute FRMON COMMAND In RU   command=/CI/ConfigAccess action fetch DECODED \\"${filename}.bin\\" \\"/ram/${filename}.json\\"
    ...   sudo=${sudo}   connection=RU_${ru_index}
    log to console  \n Step5: Edit and save ${filename}.json, change ddrPostResultPass parameter value

    # Read Json from File
    ${json_string}    csn.execute
    ...   command=${sudo} cat /ram/${filename}.json
    ...   connection=RU_${ru_index}   timeout=30

    ${json_string}    evaluate   json.loads(r'''${json_string}''')    json
    ${old_value}    Get Value From Json    ${json_string}    ddrPostResultPass
    log to console   Before change ddrPostResultPass value: ${old_value}

    # Modify Json value
    ${new_value}   create list    ${value1}    ${value2}
    ${updated_dict}    Update Value In Json    json_data=${json_string}   key_name=ddrPostResultPass   new_value=${new_value}
    ${new_value}    Get Value From Json    json_data=${updated_dict}    key_name=ddrPostResultPass
    log to console   After change ddrPostResultPass value: ${new_value}
    ${json_string}    evaluate   json.dumps($updated_dict)   json

    log to console  \n save /ram/${filename}.json
    csn.execute   command=${sudo} -u rfsw sh -c 'echo '\\''${json_string}'\\''>/ram/${filename}.json'
    ...   connection=RU_${ru_index}   timeout=30
    ${output}    csn.execute   command=${sudo} cat /ram/${filename}.json   connection=RU_${ru_index}
    log to console  ${output}

    ${command}   set variable   /CI/ConfigAccess action store PERMANENT DECODED \\"${filename}.bin\\" \\"/ram/${filename}.json\\"
    Execute FRMON COMMAND In RU   command=${command}
    ...   sudo=${sudo}   connection=RU_${ru_index}

Get Value From Json
    [Arguments]    ${json_data}    ${key_name}
    Set Test Variable   ${result}   ${None}
    FOR    ${key}    IN    @{json_data.keys()}
        ${value}=    Get From Dictionary   ${json_data}    ${key}
        Run Keyword If    '${key}' == '${key_name}'   Run Keywords   Set Test Variable   ${result}   ${value}   AND
        ...   Exit for Loop
        ${is_dict}=      Evaluate     isinstance($value, dict)
        Run Keyword If    '${is_dict}'=='True'   Run Keyword    Call Method    Get Value From Json   ${value}   ${key_name}
    END
    [Return]    ${result}

Update Value In Json
    [Arguments]    ${json_data}    ${key_name}    ${new_value}
    Log    Traversing and updating JSON...
    FOR    ${key}    IN    @{json_data.keys()}
        ${value}=    Get Value From JSON    ${json_data}    ${key}
        Run Keyword If    '${key}' == '${key_name}'    Set To Dictionary    ${json_data}    ${key}    ${new_value}
        ${is_dict}=      Evaluate     isinstance($value, dict)
        Run Keyword If    '${is_dict}'=='True'    Run Keyword    Call Method    Update Value In Json    ${value}
        ...    ${key_name}    ${new_value}
    END
    [Return]    ${json_data}

Get Ru Running Index From Configuration Index
    [Arguments]    ${ru_index}=1
    Selenium Login And Disable Screen Lock
    ${hw_info}   selenium_coam.get_bts_start_up_view_info   cell='NR cells'
    Set Test Variable    ${rmod_running_index}    ${None}
    FOR    ${item}    IN    @{hw_info['Hardware']}
        Log    ${item}
        ${rmod_index_str}    Evaluate    "RMOD-{}".format(${ru_index})
        Run Keyword If    "${rmod_index_str}" in "${item}"    Get Last Number    ${item}    ${rmod_running_index}
    END
    Return From Keyword    ${rmod_running_index}
    [Teardown]    Selenium Logout And Close Browser

Get Last Number
    [Arguments]    ${item}    ${rmod_running_index}
    ${pattern}    Set Variable    (\\d+)[^\\d]*$
    ${match}    Evaluate    re.search('${pattern}', '${item}')   re
    Run Keyword If    ${match}    Set Test Variable    ${rmod_running_index}    ${match.group(1)}
    Run Keyword If    ${match}    Log    rmod_running_index: ${rmod_running_index}
    # Run Keyword Unless    ${match}    Log    rmod_running_index no found!

Get the real time from GNB
    [Documentation]    Author: Zhang Xuewen
    ...                Description: Get the real time from GNB,return as '2024-07-27 16:11:57+08:00'
    [Arguments]    ${asik_alias}=ASIK Master
    Connect to Common Unit Master
    csn.send command    command=date --rfc-3339=seconds    connection=${asik_alias}
    ${date_time}    csn.read output    connection=${asik_alias}
    ${date_time}    Strip String   ${date_time}
    [Return]    ${date_time}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}