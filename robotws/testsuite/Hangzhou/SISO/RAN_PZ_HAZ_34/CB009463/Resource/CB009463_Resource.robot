*** Settings ***
Documentation    Suite description
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
Resource     ../../../../SISO/RAN_PZ_HAZ_34/CB005845/Resource/CB005845_Resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables    ./TLConfigurationDefault.py
Variables    ./CaseConfiguration.py
*** Variables ***
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

#${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#
#${WEBUI_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
#${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
#${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

&{condition_ru_same}   rf-FRU6=diff
&{condition_PS_diff}     PS=diff
${PA_INFO}             ${tl.attenuator[0]}
*** Keywords ***
TC.01_Attach SR on different PRACH configuration recommison
    [Documentation]   detail steps 4Gonly
    ...       1.commission with correct prach parameters
    ...       2.Call and Capture BIP log
    ...       3.Check Prach Message success and no retry
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC01
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    #Log.StartCaptureBip
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=10
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=10
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall

CommonCase.5GC000584_RU_Module_Certificate_Integrity
    [Documentation]   detail steps
    ...    1. Check RU Cert present and correct.
    Connect to Ru and check if certificate exists
    KW.Check_Integrity_On_RU


CommonCase.General_SiSo_Static_HW_Capabilities_Validation_001
    [Documentation]   detail steps
    ...    1. Modify SCF
    ...    2. load and error displayed
    ...    3. Modify scf
    ...    4. load and error cleared
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    ${CASESCF_TCID}=HWValidation
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=${CASESCF_TCID}
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${casescf}
    selenium_coam.validate_plan
    #${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
#    Should Not Be Empty   ${defination_errors}
#    Should contain    ${defination_errors[0]["Object name"]}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    Should Not Be Empty   ${relation_errors}
#    Should contain    ${relation_errors[0]["Object name"]}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    #Should Not Be Empty   ${hardware_errors}
#    Should contain    ${hardware_errors[0]["Object name"]}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf}
    selenium_coam.validate_plan
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    Should Be Empty   ${defination_errors}
    Should Be Empty   ${relation_errors}
    Should Be Empty   ${hardware_errors}
CommonCase.General_SiSo_RU_capabilities_advertisement_towards_OAM
    [Documentation]   detail steps
    ...    1. collect snapshotlog
    ...    2. check oam start up log , ruSupportsExtType6: boolean=true present
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    gNB.Connect
    ${result}  Conn.Execute  cmd=xz -d /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz    alias=${ALIAS_ASIK}
    ${startup_btsoam}   set variable if  ${result.count("No such file or directory")}>0    /tmp/startup_BTSOM.log
    ...    /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log
    ${result}  Conn.Execute  cmd=cat ${startup_btsoam}|grep "ruSupportsExtType6:"   alias=${ALIAS_ASIK}
    ${result}  Conn.Execute  cmd=cat ${startup_btsoam}|grep "ruSupportsExtType6: boolean = true"   alias=${ALIAS_ASIK}
    Should Not Be Empty   ${result}
    #TODO actual value false
CommonCase.General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
    [Documentation]   detail steps
    ...    1. BTS onair and BTS site/ru reset, poweroff/on
    ...    2. snapshot showing the correct reason
    ...    3. for sw upgrade/watchdog/Management please test manually.
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    ${ru_index}=1
    #1. Site Reset
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.reset_site
    run keyword and ignore error    KW.RestartSAS
    KW.CaseDestroy
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    ${log}    KW.CollectSnapshot
    KW.CheckSnapshotLog    log=${log}    string=Last reset cause: BTS (4)
    #2. RU WebUI Reset
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.reset_ru    ru_index=${ru_index}
    run keyword and ignore error    KW.RestartSAS
    KW.CaseDestroy
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    ${log}    KW.CollectSnapshot
    KW.CheckSnapshotLog    log=${log}    string=Last reset cause: BTS (4)
    #RU Power Reset
    ${index}    Evaluate    ${ru_index}-1
    Power.Reset5GRU    model=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu.vendor}
    run keyword and ignore error    KW.RestartSAS
    KW.CaseDestroy
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    ${log}    KW.CollectSnapshot
    KW.CheckSnapshotLog    log=${log}    string=Last reset cause: PowerOn (1)
KW.CollectSnapshot
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${snapshot_file}   separator=/     max_split=1
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}/.
    Run Keyword And Ignore Error    run    command=rm ${snapshot_file}
    [Return]    ${LOG_PATH}/${SNAPSHOTNAME}

KW.CheckSnapshotLog
    [Arguments]  ${log}    ${string}=Last reset cause: BTS (4)
    run   rm -rf ${LOG_PATH}/SnapShot
    run   unzip ${log} -d ${LOG_PATH}/SnapShot&&cd ${LOG_PATH}/SnapShot&&unzip -o '*.zip'&&unzip '*_L_1_runtime.zip'&&xz -d runtime_DEFAULT.log.xz
    ${result}    run   cat ${LOG_PATH}/SnapShot/runtime_DEFAULT.log|grep '${string}'
    Should Not Be Empty   ${result}
KW.RestartSAS
    [Arguments]  ${ue_index}=0    ${saspath}=/cygdrive/c/sasserver/
    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=UE_PC_${ue_index}
    ${DLPID}  Conn.Execute  cmd=ps -Wef|grep python|awk '{{print $2}}'|xargs /bin/kill -f     alias=UE_PC_${ue_index}
    Conn.Execute  cmd=killall python      alias=UE_PC_${ue_index}
    ssh.send_command    cd ${saspath}&&python -i SAS_Sim.py    connection=UE_PC_${ue_index}
    Wait Until Keyword Succeeds    4min    20sec    ViVi.CheckIperfPresent
    ...    cmd=ps -Wef | grep python    checkpoint=python    alias=UE_PC_${ue_index}
KW.CaseDestroy
    Log to Console    KW.CaseDestroy
    Run Keyword And Ignore error    COAM.Logout
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
KW.GenerateAlarm1901AndClearIt
    [Arguments]  ${ru_index}=1
    Modify Calibration File On RU Unit    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk    ru_index=${ru_index}
    run keyword and ignore error    KW.RestartSAS
    Wait until keyword succeeds    20min    120s    RU Status Should Be Failed    ru_index=${ru_index}
    log to console    \n Check Alarm Exist in RawAlarmHistory
    Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
	Wait until keyword succeeds    20min    120s    Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk
    ...    new_name=calibration_dlpath1    ru_index=${ru_index}
    log to console    \n Check Fault 1901 Absent on WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1901
    log to console    \n Check GNB cell on air
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    [Teardown]  Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${ru_index}
CommonCase.General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
    [Documentation]   detail steps
    ...    Precondition: Enable Fault report on target RU by:
    ...         frmonShellClient 127.0.0.1 2000
    ...         / action create ConfigAccess /ca /module
    ...         /ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"
    ...         vi fault_logger. json add 1247 to fault list and save
    ...         /ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"
    ...         /ca action update
    ...         exit frmon shell comand：crtl+c
    ...         sync and reboot ru.
    ...    1.trigger radio failure
    ...    2. full level snapshot, should contain faultLog.zip
    ...    3. trigger radio fault by a list
    ...    4. Collect log, should conatin faultlog.zip
    ...    5. power reset radio, log still there.
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    #trigger RU fault
    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    KW.GenerateAlarm1901AndClearIt
    run keyword and ignore error    KW.RestartSAS
#    gNB.Connect
#    gNB.ConnectToRU    ru_asias=${ALIAS_RMOD}
#    Conn.Execute  command=rm -rf /tmp/command&&touch /tmp/command    alias=${ALIAS_RMOD}
#    Conn.Execute  command=frmonShellClient 127.0.0.1 2000 /tmp/command   alias=${ALIAS_RMOD}
    #Conn.Execute  command=echo "command" >/tmp/command    alias=${ALIAS_RMOD}
    ${log}    gNB.CollectSnapshot
    run   rm -rf ${LOG_PATH}/SnapShot&&unzip ${log} -d ${LOG_PATH}/SnapShot
    run   rm -rf ${LOG_PATH}/faultlog&&unzip ${LOG_PATH}/SnapShot/*_L_1_faultLogs.zip -d ${LOG_PATH}/faultlog
    ${result}    run   cat ${LOG_PATH}/faultlog/snapshot_status.txt|grep 1247
    should not be empty    ${result}

CommonCase.Initiate_RF_Statistics_diagnostic_test_withoutL3call
    [Documentation]   detail steps
    ...    1. Online Modification and active
    ...    2. check test result, temprature/Eth/uptime
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    ${ru_index}=1    ${celltype}=NR
    ${CellType}    Set Variable If  'celltype'=='NR'    NR    LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${scf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1    object_class_name=RFSTATREQ     id_value=1
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-1
    ...    filter_param=Target Radio Module test identifier   new_value=${ru_index}    abbr=targetRModId
    COAM_WebEM.ValidateAndActiveParameters
    ${result}  COAM_WebEM.GetParameterValue  ${distName}=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-1/RFSTATRES-1   abbr=RF Statistics Result
    should be true    '${result}'=='success'
    ${result}  COAM_WebEM.GetParameterValue  ${distName}=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-1/RFSTATRES-1   abbr=Test outcome
    should be true    '${result}'=='Pass'

CommonCase.BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power
    [Documentation]   detail steps
    ...    1. Set Pmax from min to max and call   17-24
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    ...    ${loop}=${CASE_INPUT_CB008712['Pmax']['count']}
    ...    ${start}=${CASE_INPUT_CB008712['Pmax']['start']}
    ...    ${cellid}=1
    ...    ${celltype}=NR
    ...    ${isCBRS}=false
    run keyword if  '${celltype}'!='NR'    gNB.FormatBTSID    lte=true
    FOR    ${index}    IN RANGE    ${loop}
        Run Keyword And Continue On Failure    COAM_WebEM.Login    version=SBTS22R4
        ${newValue}    Evaluate    ${start}+${1}+${index}
        run keyword if  '${isCBRS}'=='false'
        ...    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
        ...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}    abbr=Maximum output power    value=${newValue}
        ...    ELSE IF    '${isCBRS}'=='true' and '${celltype}'!='NR'
        ...    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
        ...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}/CBSDCEL-0
        ...    abbr=Desired Maximum Output Power    value=${newValue}
        ...    ELSE
        ...    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
        ...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}/NRCBSDCEL-0
        ...    abbr=Desired Maximum Output Power    value=${newValue}
        Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
        Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    3 times    30s    COAM_WebEM.CheckAlarm    id=4008    present=false
        run keyword and ignore error    KW.GetAndCheckAlarms
        Run Keyword And Continue On Failure   COAM_WebEM.Logout
        DoTputCall
    END
    [Teardown]  gNB.FormatBTSID
CommonCase.LTE_Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD_TS2
    [Documentation]   detail steps
    ...    1. Configrue parameter
    ...    2. Check the message flow to SAS simu
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    ...           ${ts2}=${CASE_INPUT_CB008712['CBSD']['TS2']}
    ...           ${celltype}=NR
    run keyword if  '${celltype}'!='NR'    gNB.FormatBTSID    lte=true
    run keyword if  '${celltype}'!='NR'    Set To Dictionary    ${ts2}    version=1.2
    ${CBRS_PREFIX}    Set Variable If  '${celltype}'=='NR'    NR    ${EMPTY}
    set test variable    ${CBRS_PREFIX}    ${CBRS_PREFIX}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_WebEM.Login    version=${CASE_INPUT_CB008712['release']}
    ${res}    run keyword and ignore error    KW.GetAndCheckCBSD    ts=${ts2['server']}    version=${ts2['version']}    state=Registered
#    run keyword if    '${res[0]}'!='PASS'   KW.SetCBSDParameters    ts=${ts2['server']}    version=${ts2['version']}
    DoTputCall
    [Teardown]   gNB.FormatBTSID
CommonCase.LTE_Verify_CBSD_registration_From_TS1_to_TS2
    [Documentation]   detail steps
    ...    1. base scf ts1, Configrue parameter
    ...    2. Check the message flow to SAS simu
    [Arguments]   ${ts1}=${CASE_INPUT_CB008712['CBSD']['TS1']}    ${ts2}=${CASE_INPUT_CB008712['CBSD']['TS2']}
    ...     ${celltype}=NR
    ...     ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    run keyword if  '${celltype}'!='NR'    gNB.FormatBTSID    lte=true
    run keyword if  '${celltype}'!='NR'    Set To Dictionary    ${ts1}    version=1.2
    run keyword if  '${celltype}'!='NR'    Set To Dictionary    ${ts2}    version=1.2
    ${CBRS_PREFIX}    Set Variable If  '${celltype}'=='NR'    NR    ${EMPTY}
    set test variable    ${CBRS_PREFIX}    ${CBRS_PREFIX}
    #${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=CBSD
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${scf}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_WebEM.Login    version=SBTS22R4
    #TODO  what's the parameter to modify and what's to check.
    KW.GetAndCheckCBSD    ts=${ts1['server']}    version=${ts1['version']}    state=Registered
    #KW.SetCBSDParameters    ts=${ts2['server']}    version=${ts2['version']}
    run keyword and ignore error    KW.RestartSAS    saspath=${CASE_INPUT_CB008712['CBSD']['TS2']['path']}
    wait until keyword succeeds   5min   1min    KW.GetAndCheckCBSD    ts=${ts2['server']}    version=${ts2['version']}    state=Registered
    COAM_WebEM.Logout
    DoTputCall
    [Teardown]  gNB.FormatBTSID
KW.SetCBSDParameters
    [Arguments]     ${ts}    ${version}
    COAM_WebEM.SetParameterValue
    #MRBTS-1101/NRBTS-1101/NRCBRSPR-1
    #...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}    abbr=Primary SAS server    value=${ts}
    COAM_WebEM.ValidateAndActiveParameters
    wait until keyword succeeds   5min   1min    KW.GetAndCheckCBSD    ts=${ts}    version=${version}    state=Registered
KW.GetAndCheckCBSD
    [Arguments]     ${ts}    ${version}    ${state}=Registered
    ${result}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CBRS_PREFIX}CBRSPR-1
    ...    abbr=Primary SAS server
    should be true    '${result}'=='${ts}'
    ${result}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CBRS_PREFIX}CBRSPR-1
    ...    abbr=WINNF technical specification version
    should be true    '${result}'=='${version}'
    ${result}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CBRS_PREFIX}CBSD-1
    ...    abbr=CBSD registration state
    should be true    '${result}'=='${state}'

CommonCase.Manual_SiSo_CM_Commissioning_Configuration_reset
    [Documentation]   detail steps
    ...    1. Login to WebUI
    ...    2. reset configuration and check SMOD, RMOD status.
    [Arguments]     ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}  ${ru_index}=1   ${scf_file}=${scf_file}
    COAM_Admin.commission  scf_file=${scf_file}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_WebEM.Login    version=SBTS22R4
    #${scf_backup}    COAM_Admin.BackupSCF
    ${ru_info}       selenium_coam.get_ru_info    ru_index=${ru_index}
    Should Be True   '${ru_info['Status']['Operational state']}'=='enabled'
    Should Be True   '${ru_info['Status']['Usage state']}'=='Active'
    selenium_coam.configuration_reset
    KW.CaseDestroy
#    run keyword and ignore error    COAM_WebEM.Logout
    #TODO Check status
    set suite variable     ${WEBUI_IP}    ${ASIK_IP}
    [Teardown]   KW.Recommission    scf=${scf}

KW.Recommission
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    COAM_Admin.commission    scf_file=${scf}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir
    #get_hw_parameters

CommonCase.Manual_SiSo_CM_Recommissioning
    [Documentation]   detail steps
    ...    1. Login to WebUI
    ...    2. BtsReset parameter online change
    ...    3. Login to WebUI validate and check error
    ...    4. online parameter change. save report
    ...    5. online change to wrong value, avtive is impossible?
    ...    6. undo change, parameter value back
    [Arguments]   ${scf_file}=${scf_file}
    COAM_Admin.commission  scf_file=${scf_file}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    #COAM_WebEM.Login
    #Reset Parameter
    #COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    #...    abbr=Administrative state    value=locked
    #COAM_WebEM.ValidateAndActiveParameters
    #run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.validate_plan
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    Should Be Empty   ${defination_errors}
    Should Be Empty   ${relation_errors}
    Should Be Empty   ${hardware_errors}
    #online setparametervalue
    ${btsname}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}   abbr=BTS name
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}   abbr=BTS name    value=TL1101_AZQC_NR_1cell_TAA
    selenium_coam.validate_plan
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    Should Be Empty   ${defination_errors}
    Should Be Empty   ${relation_errors}
    Should Be Empty   ${hardware_errors}
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}   abbr=BTS name    value=${btsname}
    COAM_WebEM.ValidateAndActiveParameters
    selenium_coam.save_report
    KW.CaseDestroy
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.remove_object    object_name=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    selenium_coam.validate_plan
    ${productCode}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   abbr=Product code planned
    #COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   abbr=Product code planned    value=474157A.101
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
#    Should Be Empty   ${defination_errors}
#    Should Be Empty   ${relation_errors}
    Should Not Be Empty   ${relation_errors}
    #Should Not Be Empty   ${hardware_errors}
    selenium_coam.undo_changes
    ${productCodeAfter}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   abbr=Product code planned
    Should be true    '${productCodeAfter}'=='${productCode}'

TC.SWM_Software_Upgrade
    [Arguments]   ${max_num}=500   ${stream}=${TargetStream}    ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_PS_diff}
    #TC.5GC002479_SWM_Software_Upgrade    max_num=${max_num}   stream=${stream}    status=${status}    conditions=${conditions}
    set suite variable     ${SWM}     ${1}
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    ${TargetBuildVersion}=         Set Variable         ${TARGETSW}
    ${OriginalBuildVersion}=       KW.SWM.FilterGetGNBSWVersion      Target_build=${TargetBuildVersion}   max_num=${max_num}
    ...               stream=${stream}    status=${status}       conditions=${conditions}
    log to console    original=${OriginalBuildVersion}
    log to console    target=${TargetBuildVersion}
    KW.SWM.PrepareOriginalENVbyYAFT    build_version=${OriginalBuildVersion}
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    log to console    package prepared
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to  load software
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}
    ${download_startTime}    KW.TimerStart
    log to console   start to software update with active
    selenium_coam.software_update     is_activate=${True}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${SW_download_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console   download duration is ${SW_download_duration}
    set suite variable     ${SW_download_duration}
    set suite variable     ${SWM}     ${2}
    ${active_startTime}    KW.TimerStart
    log to console    ckeck bts reset
    Wait until keyword succeeds    10min    10s    5GC002479_Resouce.gNB.CheckgNBReset
    log to console    waitAllCellsOnair
    #KW.RestartSAS
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    ${SW_active_duration}     KW.TimerStop    timestart=${active_startTime}
    ${SW_upgrade_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console    active duration is ${SW_active_duration}
    log to console    KPI4 duration is ${SW_upgrade_duration}
    set suite variable     ${SW_active_duration}
    set suite variable     ${SW_upgrade_duration}
    set suite variable     ${SWM}     ${3}
gNB.ConnectToRU
    [Arguments]    ${ru_ip}    ${ru_username}    ${ru_pasword}    ${ru_asias}=${ALIAS_RMOD}    ${proxy}=${ALIAS_ASIK}
    taf.transport.ssh.Connect To    hostname=${ru_ip}
    ...                             username=${ru_username}
    ...                             password=${ru_pasword}
    ...                             proxy=${proxy}
    ...                             alias=${ru_asias}
DoTputCall
    log    DoTputCall
    log    ${TLCommonConfig['MultiUECFG']}
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=157.3M
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}

CommonCase.Manual_SiSo_SM_NR_RAT_reset
    [Documentation]   detail steps
    ...    1. BBMOD reset and wait onair
    ...    2. Do L3Call
    [Arguments]   ${baseband_index}=${TCCB008445_TC65['LTE_cell_id_list']}      ${scf_file}=${scf_file}
    COAM_Admin.commission  scf_file=${scf_file}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_WebEM.Login
    selenium_coam.reset_baseband    baseband_index=${baseband_index}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
#    Run Keyword And Continue On Failure   DoTputCall


CommonCase.Manual_SiSo_STARTUP_BTS_Power_Reset
    [Documentation]   detail steps
    ...    1. Site Power Cycle and wait onair
    ...    2. Do L3Call
    #[Arguments]   ${cell_idx}=${TCCB008445_TC65['LTE_cell_id_list']}
    #    Manual_SiSo_SM_LTE RAT reset    cell_idx=${cell_idx}
    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
#    Run Keyword And Continue On Failure   DoTputCall
CommonCase.Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]   detail steps
    ...    1. Site reset and wait onair
    ...    2. Do L3Call
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.reset_site
    sleep    30s
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
#    Run Keyword And Continue On Failure   DoTputCall

CommonCase.General_SiSo_RU_module_reset_from_GUI
    [Documentation]   detail steps
    ...    1. Site RU Rest and wait onair
    ...    2. Do L3Call
    [Arguments]    ${ru_index}=1
    COAM_WebEM.Login    version=SBTS22R4
    selenium_coam.reset_ru    ru_index=${ru_index}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    Run Keyword And Continue On Failure   DoTputCall

CommonCase.General_SiSo_Cell_block_and_unblock
    [Documentation]   detail steps
    ...    1. block and unblock cell and wait onair
    ...    2. Do L3Call
    [Arguments]    ${cell_idx}=1
    COAM_WebEM.Login    version=SBTS22R4
    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_idx}    action=block
    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_idx}    action=unblock
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    Run Keyword And Continue On Failure   DoTputCall

CommonCase.General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    [Documentation]   detail steps
    ...    1. lock and unlock cell and wait onair
    ...    2. Do L3Call
    [Arguments]    ${cell_idx}=1
    COAM_WebEM.Login    version=SBTS22R4
    COAM_WEBEM.LockUnlcokCell      cell_idx=${cell_idx}      action=lock
    COAM_WEBEM.LockUnlcokCell      cell_idx=${cell_idx}      action=unlock
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    Run Keyword And Continue On Failure   DoTputCall

CommonCase.Manual_SiSo_SM_LTE_cell_lock_unlock_(administrative_state_change)_from_GUI_1CC
    [Documentation]   detail steps
    ...    1. lock and unlock cell and wait onair
    ...    2. Do L3Call
    [Arguments]    ${cell_idx}=1
    gNB.FormatBTSID    lte=true
    COAM_WebEM.Login    version=SBTS22R4
    COAM_WEBEM.LockUnlcokCell_LTE      cell_idx=${cell_idx}      action=lock
    COAM_WEBEM.LockUnlcokCell_LTE      cell_idx=${cell_idx}      action=unlock
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    [Teardown]   gNB.FormatBTSID

COAM_WEBEM.LockUnlcokCell_LTE
    [Documentation]   Lock Cell if cell is unlocked, UnLock cell if cell is locked.
    [Arguments]   ${cell_idx}=1    ${action}=lock    ${timeout}=60    ${checkstatus}=true
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="unlocked" and '${action}'=='lock'
    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    ...    abbr=Administrative state    value=locked
#    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="locked" and '${action}'=='unlock'
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
     ...   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
     ...    abbr=Administrative state    value=unlocked
    COAM_WebEM.ValidateAndActiveParameters
    return from keyword if    '${checkstatus}'=='false'
    ${status}    set variable if    '${action}'=='lock'    locked    unlocked
    Wait Until Keyword Succeeds    3 times    30s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
    ...    status=${status}

CommonCase.Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]   detail steps
    ...    1. lock and unlock RU and wait onair
    ...    2. Do L3Call
    [Arguments]    ${ru_index}=1     ${scf_file}=${scf_file}
    COAM_Admin.commission  scf_file=${scf_file}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
#    DoTputCall
    COAM_WebEM.Login
    selenium_coam.lock_ru        ru_index=${ru_index}
    sleep    60s
    selenium_coam.unlock_ru      ru_index=${ru_index}
    sleep    60s
    COAM_WebEM.Logout
#    DoTputCall

#    COAM_WebEM.Login
#    @{lock_list}   create list    ${ru_index}
#    set test variable    ${X2_link_shutdown_time}    2
#    Lock and Unlock all RUs      lock_list=${lock_list}
#    #selenium_coam.lock_ru        ru_index=${ru_index}
#    #selenium_coam.unlock_ru      ru_index=${ru_index}
#    Run Keyword And Ignore Error     COAM_WebEM.Logout
#    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr

CommonCase.BS-RF__LTE_cell_graceful_shutdown_from_WebEm
    [Arguments]   ${cell_idx}=1
    gNB.FormatBTSID    lte=true
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    wait until keyword succeeds   5x   30s    COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}    action=shuttingdown    checkstatus=true
    wait until keyword succeeds   5x   30s   COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}     action=unlock    checkstatus=true
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds   10x   1min  COAM_Admin.VerifyCellOnAir
    Run Keyword And Continue On Failure   DoTputCall

COAM_WEBEM.shutdownUnlcokCell
    [Documentation]   shuttingdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
    [Arguments]   ${cell_idx}=1    ${action}=shuttingdown    ${timeout}=60    ${checkstatus}=true
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    ${btsstate}    Convert To Lower Case    ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="unlocked" and '${action}'=='shuttingdown'
    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    ...    abbr=Administrative state    value=shutting down
#    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="locked" and '${action}'=='unlock'
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
     ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
     ...    abbr=Administrative state    value=unlocked
    COAM_WebEM.ValidateAndActiveParameters
    return from keyword if    '${checkstatus}'=='false'
    ${status}    set variable if    '${action}'=='shuttingdown'    	locked    unlocked
    Wait Until Keyword Succeeds    10 times    60s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
    ...    status=${status}

COAM_WEBEM.CheckshutdownUnlcokCellStatus
    [Documentation]   shutdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
    [Arguments]   ${cell_idx}=1    ${status}=shuttingdown    ${timeout}=60
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=='${status}'

SCF.GetCaseSCFFromDelta
    [Arguments]   ${InputFile}=NULL    ${TCID}=0
    gNB.GenerateCaseSCF     InputFile=${InputFile}
    ...                     OutputFile=${LOG_PATH}/${TCID}.xml
    ...                     ResourceFolder=${CURDIR}
    ...                     ParameterToDelete=PARAMETER_TO_DELETE_${TCID}
    ...                     MOsToAdd=MOS_TO_ADD_${TCID}
    ...                     ParamterToModify=PARAMETER_TO_MODIFY_${TCID}
    ...                     ListParamterToModify=LIST_PARAMS_TO_MODIFY_${TCID}
    ...                     ListToAdd=LIST_TO_ADD_${TCID}
    [Return]    ${LOG_PATH}/${TCID}.xml

KW.CommonCall
    [Arguments]   ${scf}    ${TCID}=TC01
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=${TCID}
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    DoTputCall

KW.SetUEParameter
    [Arguments]   ${ul}=NULL    ${dl}=NULL    ${ue_index}=0
    run keyword if    '${ul}'!='NULL'
    ...    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['${ue_index}']['ul']}    target_throughput=${ul}
    run keyword if    '${dl}'!='NULL'
    ...    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['${ue_index}']['dl']}    target_throughput=${dl}

TC.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_40MHz+100MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_40M_100M
TC.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_40MHz+40MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_40M_40M
TC.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_20MHz+20MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_20M_20M
TC.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_20MHz+100MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_20M_100M
TC.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_20MHz+40MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_20M_40M
TC.CB008712_NR_General_SiSo_commission_with_2CC_70MHz+80MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_70M_80M
TC.CB008712_NR_General_SiSo_commission_with_2CC_30MHz+60MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_30M_60M
TC.CB008712_NR_General_SiSo_commission_with_2CC_50MHz+90MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=2CC_50M_90M
TC.Peak throughput with UL 64QAM Modulation on different bandwidth
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=TP_64QAM
TC.Peak throughput with DL 256QAM Modulation on different bandwidth_40M PCell_100M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=TP_256QAM_40M_100M
TC.Peak throughput with UL 64QAM Modulation on different bandwidth_40M PCell_100M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=TP_64QAM_40M_100M
TC.Manual_SiSo_CALL_LTE_data_call_1CC_20MHz
    KW.SetUEParameter  ul=100   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=1CC_20M
TC.Manual_SiSo_CALL_LTE_data_call_2CC_10MHz+10MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=2CC_10M_10M
TC.Manual_SiSo_CALL_LTE_data_call_2CC_20MHz+20MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=2CC_20M_20M
TC.Multi Carrier_Commission and Throughpu with DL interference
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=MULTI_TP
TC.Manual_SiSo_CALL_LTE_data_call_2CC_10MHz+20MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=2CC_10M_20M
TC.Peak throughput testing with 20Mhz and multiple attach_detach
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_MULTI_ATTACH
TC.Peak throughput with UL 64QAM Modulation on different bandwidth_20MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_64QAM_20M
TC.Peak throughput with UL 64QAM Modulation on different bandwidth_10MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_64QAM_10M
TC.Peak throughput with DL 256QAM Modulation on different bandwidth_20MHz
    KW.SetUEParameter  ul=90M   dl=1000M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_256QAM_20M

TC.Peak throughput with UL 256QAM Modulation on different bandwidth
    [Arguments]   ${TCID}=TC01   ${ul}=100   ${dl}=100
    KW.SetUEParameter  ul=${ul}   dl=${dl}   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=${TCID}

TC.Peak throughput with DL 256QAM Modulation on different bandwidth
    [Arguments]   ${TCID}=TC01   ${ul}=100   ${dl}=100    ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    KW.SetUEParameter  ul=${ul}   dl=${dl}   ue_index=0
    KW.CommonCall    scf=${scf}   TCID=${TCID}

TC.Peak throughput with DL 256QAM Modulation on different bandwidth_10MHz
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_256QAM_10M
TC.Peak throughput with UL 64QAM Modulation on different bandwidth_20M PCell_20M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_64QAM_20M_20M
TC.Peak throughput with UL 64QAM Modulation on different bandwidth_10M PCell_10M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_64QAM_10M_10M
TC.Peak throughput with UL 64QAM Modulation on different bandwidth_10M PCell_20M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_64QAM_10M_20M
TC.Peak throughput with DL 256QAM Modulation on different bandwidth_20M PCell_20M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_256QAM_20M_20M
TC.Peak throughput with DL 256QAM Modulation on different bandwidth_10M PCell_10M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_256QAM_10M_10M
TC.Peak throughput with DL 256QAM Modulation on different bandwidth_10M PCell_20M SCell
    KW.SetUEParameter  ul=100M   dl=100M   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=TP_256QAM_10M_20M
TC.Manual_SiSo_CALL_LTE_data_call_1CC_20MHz_ASIL+ABIN
    KW.SetUEParameter  ul=10   dl=10   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_NR}    TCID=1CC_20MHz_ASIL_ABIN

TC.Manual_SiSo_SM_LTE_Cell_block_unblock
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    [Arguments]   ${LTE_cell_id_list}=1
    #    Manual_SiSo_SM_LTE Cell_block_unblock    LTE_cell_id_list=${LTE_cell_id_list}
    Run Keyword And Continue On Failure   DoTputCall
    COAM_WebEM.Login
    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${LTE_cell_id_list}    action=block
    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${LTE_cell_id_list}    action=unblock
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Continue On Failure   DoTputCall
TC.Attach_SR_on_different_PRACH_FreqOffset_chagne
    KW.SetUEParameter  ul=100   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}    TCID=PRACH
    
SISO 8712 Suite Setup
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    set suite variable      ${SAVE LOG DIRECTORY}    ${LOG_PATH}
    set suite variable      ${UPDATE_FILE_PATH}    ${LOG_PATH}
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
    set suite variable    ${TARGETSW}    ${version_Target}
    set suite variable    ${TargetStream}     ${StreamTarget}
    set suite variable    ${OldCommissionSCF}    ${CFGFILE_PATH}/${TL_BASE_SCF_NR}
    KW.AdaptCaseInput
    log    ${default_cell_id}
    log    ${CASE_INPUT_CB005845['TC11']['ru_index']}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl

SISO 8712 Suite Teardown
    log to console    \n***SISO Coam Suite Teardown***
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commission
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

SISO 8712 Test Setup
    log to console    \n***SISO Coam Test Setup***
#    log to console    Active_SW_version:${Active_SW_version}
#    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
#    ...    Commission
#    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium.close_browser

SISO 8712 Test Teardown
    log to console    \n***SISO Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
#    run keyword if test failed     Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    run keyword if test failed     Collect_snapshot_by_WEBUI
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Collect_snapshot_by_WEBUI
    [Arguments]    ${loop}=0
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${SAVE LOG DIRECTORY}/snapshot_${filename}_${loop}.zip

KW.Check_Integrity_On_RU
    [Arguments]    ${ru_index}=1
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable  sudo openssl x509 -in /etc/ssl/certs/NokiaRootCA.pem -text -noout
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    Should contain  ${output}  Signature Algorithm: sha256WithRSAEncryption
    Should contain  ${output}  Digital Signature, Certificate Sign, CRL Sign
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master

KW.GetAndCheckAlarms
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459
    COAM_WebEM.Login
    ${active_alarm}    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...    append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    COAM_WebEM.Logout
