*** Settings ***
Documentation     author: Wang Sujuan
...               contact: sujuan.wang@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC001008-FDD
#Library         taf.collectors.core   WITH NAME   core
Library         taf.collectors.btslog  WITH NAME   btslog
Resource    ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}/5GC001008/Delta_SCF.py
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py

*** Variables ***
#If GNB1 is used
#${CFGFILE_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF}        ${CFGFILE_ON_GIT}/GoldenSCF1Cell_both.xml
#${GoldenSCF_PATH}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${TestLineSCF}            ${CFGFILE_PATH}/TestLineSCF1Cell_Both.xml
${MRBTS_ID}        ${tl.gnbs[0].instance_id}
${NRBTS_ID}        ${tl.gnbs[0].global_bts_id}
${LOG_PATH}             ${OUTPUT DIR}/Logs
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
${ALIAS_UTE}                ute
${ALIAS_5GC}                5gcore
${ASIK_LMP_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#${PB_5GRU_2_IP}     ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
#${PB_5GRU_2_PORT}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
${distname_id_1}     ${tl.gnbs[0].instance_id}/${tl.gnbs[0].global_bts_id}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${BBU_TYPE}        asik
${SST}       129
${SD}        1
${tac}      270
${UE_alias}        UE_0
${PC_1_SCF}    ${CFGFILE_PATH}/5GC001008/FDD_1008_PC_1.xml
${CPIF_LOG_NAME}    CPIF_add_SNSSAI.pcap
${D_SCF}    ${CFGFILE_PATH}/5GC001008/FDD_1008_PD_10.xml
${O_SCF}          ${CFGFILE_PATH}/5GC001008/FDD_1008_O.xml

*** Keywords ***
TC.5GC001008_PC_1_Ngsetupfailure alarm raised when none slice in common with AMF
    #before modify snssai should lock cell and snssai Administrative state = locked
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    Modify SNSSAI Administrative state Parameters
    COAM_WebEM.Logout

    gNB.ModifySCFAndCommission    InputFile=${TestLineSCF}    OutputFile=${PC_1_SCF}
    ...                  ParamterToModify=${PARAMS_TO_MODIFY_1008_PC_1}
    sleep    5min
    Check SNSSAI status on webUI    status=disabled
    Check SNSSAI Administrative status on webUI    status=Unlocked
    Check NG Status Inactive
    Check Alarm Info    alarmid=7116    faultid=7317    alarmname=NgSetupStopRetry

    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    Modify SNSSAI Administrative state Parameters
    COAM_WebEM.Logout

TC.5GC001008_EA_2_Online SNSSAIs addtion and it is supported by AMF
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    Modify SNSSAI Administrative state Parameters
    COAM_WebEM.Logout   
    #gNB is only configured with 1 snssai
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${TestLineSCF}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Run Keyword And Continue On Failure    Check And Update AMFConf
    Run Keyword And Continue On Failure    Start collect cpif logs
    Add SNSSAI parameter
    sleep    10s
    Run Keyword And Continue On Failure    Stop capturing cpif log
    #check SNSSAI by Wireshark
    Wireshark Check SNSSAI parameter    filename=${CPIF_LOG_NAME}
    Check SNSSAI status on webUI    dist_name=${distname_id_1}/SNSSAI-2    status=enabled

TC.5GC001008_PD_10_Verify MEAS_PERIOD_NR_PDCP_SLICE when gNB configured with sst=1 sd=null and AMF configured with sst=1 sd = 0xffffff
    #before modify snssai shue lock cell and snssai Administrative state = locked
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    Modify SNSSAI Administrative state Parameters
    COAM_WebEM.Logout

    gNB.ModifySCFAndCommissionAndCheckOnair    InputFile=${TestLineSCF}    OutputFile=${D_SCF}
    ...    ParamterToModify=${PARAMS_TO_MODIFY_1008_PD_10}    ParamterToDelete=${PARAMS_TO_REMOVE_1008_PD_10}
    sleep    10min
    Check MEAS_PERIOD_NR_PDCP_SLICE from gNB

TC.5GC001008_O_4_cell remain unlocked after one of the slice in the TAC change from unlock to lock
    #before modify snssai should lock cell and snssai Administrative state = locked
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    Modify SNSSAI Administrative state Parameters
    COAM_WebEM.Logout

    #gNB need configured with 2 snssai  sst = 129  sd =1 and defalt one
    GetSCFFromGoldenSCFAndDelta    InputFile=${TestLineSCF}    OutputFile=${O_SCF}
    ...                  ParamterToAdd=${PARAMS_TO_ADD_1008_O_4}
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${O_SCF}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

    Run Keyword And Continue On Failure    Check And Update AMFConf
    Check cell staus on webUI    status=notBarred
    Start collect cpif logs
    Modify SNSSAI-1 Administrative state    NewValue=Locked
    Check SNSSAI status on webUI    status=disabled
    Stop capturing cpif log
    Wireshark check message
    Check cell status on UE    status=notBarred    log_file=1008_O_cell_status.xml
Check SNSSAI Administrative status on webUI
    [Arguments]    ${dist_name}=${distname_id_1}/SNSSAI-1   ${status}=Unlocked
    Check parameter should be correct for gNB    value=${status}    url=${WEBUI_URL}
    ...    dist_name=${dist_name}    filter_param=Administrative state

Check Alarm Info
     [Arguments]   ${alarmid}=${alarmid}    ${faultid}=${faultid}    ${alarmname}=${alarmname}
    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Set test variable    ${alarm_info}
    ${length}    Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        Set test variable    ${i}
        ${res_check}    run keyword and return status    Check alarm via webui
    ...    alarmid=${alarmid}    faultid=${faultid}    alarmname=${alarmname}
        ${res}=    Run Keyword And Ignore error    should be true    '${res_check}' == 'True'
        Run Keyword If    ${res} == ('PASS', None)    Exit For Loop
    END
    Run keyword if    ${res} != ('PASS', None)    Fail    alarm check fail
    COAM_WebEM.Logout

Check alarm via webui
    [Arguments]    ${alarmid}=${alarmid}    ${faultid}=${faultid}    ${alarmname}=${alarmname}
    ${alarm_id}    Set Variable    ${alarm_info[${i}]['Alarm ID']}
    ${fault_id}    Set Variable    ${alarm_info[${i}]['Fault ID']}
    ${alarm_name}    Set Variable    ${alarm_info[${i}]['Fault name']}
    run keyword and ignore error    should contain    container=${alarm_id}    item=${alarmid}
    Run Keyword And Continue On Failure    should contain    container=${fault_id}    item=${faultid}
    Run Keyword And Continue On Failure    should contain    container=${alarm_name}    item=${alarmname}

Check NG Status Inactive
    [Arguments]    ${Status}=Active
    COAM_WebEM.Login
    ${state}    run keyword and return status    selenium_coam.get_amf_info
    Run Keyword If    '${state}'=='False'    Run Keywords    COAM_WebEM.Logout
    ...    AND    pass execution    test passed
    ${output}    selenium_coam.get_amf_info
    ${values}    get dictionary values   ${output}
    COAM_WebEM.Logout
    should not be equal    ${values[-1]}    ${Status}

Teardown EA_2 case
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    COAM_WebEM.Logout
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${TestLineSCF}
    Teardown 1008 case

Add SNSSAI parameter
    COAM_WebEM.Login
    sleep    5s
    #add SNSSAI-2
    selenium_coam.add_object    object_name=${NRBTS_ID}    object_class_name=SNSSAI    id_value=2
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SNSSAI-2    filter_param=Slice Service Type    new_value=${SST}
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SNSSAI-2    filter_param=Slice Differentiator    new_value=${SD}
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SNSSAI-2    filter_param=Administrative state    new_value=Unlocked
    selenium_coam.add_element    dist_name=${distname_id_1}/SNSSAI-2    filter_param=List of NRPLMN distinguished names
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SNSSAI-2    filter_param=List of NRPLMN distinguished names
    ...    new_value=${distname_id_1}/NRPLMN-1    node_index=${0}
    #add SNSSAI-2 IN TRACKINGAREA-210
    selenium_coam.add_element    dist_name=${distname_id_1}/TRACKINGAREA-${tac}    filter_param=List of SNSSAI distinguished names
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/TRACKINGAREA-${tac}    filter_param=List of SNSSAI distinguished names
    ...    new_value=${distname_id_1}/SNSSAI-2    node_index=${1}

    selenium_coam.validate_plan
    sleep    5s
    ${output}    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    sleep    5s
    COAM_WebEM.Logout
    [Return]    ${output}

Check parameter should be correct for gNB
    [Arguments]    ${value}    ${url}    ${dist_name}    ${filter_param}
    COAM_WebEM.Login
    sleep    5s
    ${Para_value}=    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    COAM_WebEM.Logout
    Should Be Equal    ${Para_value}    ${value}

Teardown EA_O case
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    COAM_WebEM.Login
    COAM_WEBEM.LockAllCell
    COAM_WebEM.Logout
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${TestLineSCF}
    Teardown 1008 case

Start collect cpif logs
    [Arguments]    ${filename}=${CPIF_LOG_NAME}
    Run Keyword And Ignore Error    Conn.Disconnect  alias=${ALIAS_ASIK}
    wait until keyword succeeds   10min   10s    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Wireshark.StartCaptureLogFromContainer    filename=${filename}    nodename=CPIF

Stop capturing cpif log
    [Arguments]    ${filename}=${CPIF_LOG_NAME}
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    wireshark.DownloadLogToUTEFromContainer    filename=${filename}    nodename=CPIF
    Conn.Disconnect  alias=${ALIAS_ASIK}

Check SNSSAI status on webUI
    [Arguments]    ${dist_name}=${distname_id_1}/SNSSAI-1   ${status}=enabled
    Check parameter should be correct for gNB    value=${status}    url=${WEBUI_URL}
    ...    dist_name=${dist_name}    filter_param=Operational state

Modify SNSSAI-1 Administrative state
    [Arguments]    ${DistName}=${distname_id_1}/SNSSAI-1    ${FilterParam}=Administrative state    ${NewValue}=Locked
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
    COAM_WEBEM.ModifyParameters    DistName=${DistName}    FilterParam=${FilterParam}    NewValue=${NewValue}
    COAM_WebEM.ValidateAndActiveParameters
    selenium_coam.logout

COAM_WEBEM.ModifyParameters
    [Arguments]    ${DistName}    ${FilterParam}   ${NewValue}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${DistName}    filter_param=${FilterParam}    new_value=${NewValue}

Wireshark check message
    [Arguments]    ${filename}=${CPIF_LOG_NAME}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=f1ap.GNBDUConfigurationUpdate_element
    ${status}    Run Keyword And Return Status    Wireshark.CheckExpression    expression=ngap.sST == 01 && ngap.sD == d1:43:a5
    Should Be Equal    ${status}    ${False}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=ngap.RANConfigurationUpdate_element
    ${status}    Run Keyword And Return Status    Wireshark.CheckExpression    expression=ngap.sST == 01 && ngap.sD == d1:43:a5
    Should Be Equal    ${status}    ${False}

GetSCFFromGoldenSCFAndDelta
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    [Arguments]        ${InputFile}
        ...            ${OutputFile}
        ...            ${ParamterToAdd}

    run keyword and ignore error    gNB.Add objects to scf    input_scf=${InputFile}
    ...           output_scf=${OutputFile}    parameters_lists=${ParamterToAdd[0]}

    run keyword and ignore error    gNB.Add elements to object    input_scf=${OutputFile}
    ...           output_scf=${OutputFile}    parameters_lists=${ParamterToAdd[1]}

    run keyword and ignore error    gNB.Add lists to object    input_scf=${OutputFile}
    ...           output_scf=${OutputFile}    parameters_lists=${ParamterToAdd[2]}

    run keyword and ignore error    gNB.Add elements to list    input_scf=${OutputFile}
    ...           output_scf=${OutputFile}    parameters_lists=${ParamterToAdd[3]}

Wireshark Check SNSSAI parameter
    [Arguments]    ${filename}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=ngap.RANConfigurationUpdate_element
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    ngap.sST == 81 && ngap.sD == 00:00:01
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=f1ap.GNBDUConfigurationUpdate_element
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    f1ap.sST == 81 && f1ap.sD == 00:00:01

Check MEAS_PERIOD_NR_PDCP_SLICE from gNB
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55328C00001    target_value=300
    COAM_WebEM.Logout

COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true     ${values[-1]}==${target_value}

Modify SNSSAI Administrative state Parameters
    [Arguments]    ${DistName}=${distname_id_1}/SNSSAI-1    ${FilterParam}=Administrative state    ${NewValue}=Locked
    COAM_WEBEM.ModifyParameters    ${DistName}    ${FilterParam}    ${NewValue}
    Run Keyword And Ignore Error    COAM_WEBEM.ModifyParameters    ${distname_id_1}/SNSSAI-2
    ...    FilterParam=Administrative state    NewValue=Locked
    COAM_WebEM.ValidateAndActiveParameters
    
COAM_WEBEM.LockAllCell
    [Arguments]   ${timeout}=60
    ${cell_count}=    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${cell_count}
        COAM_WEBEM.LockUnlcokCell   cell_idx=${i+1}    action=lock
    END
#    : FOR    ${i}    IN RANGE    ${cell_count}
#    \    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${i+1}
#    \    run keyword if    ${cell_info}!="None"and'${cell_info['Status']['Administrative state']}'=="Unlocked"
#        ...                selenium_coam.lock_cell    cell_idx=${i+1}    timeout=${timeout}
#    \    Sleep  2 mins

Setup 1008 case suite
    TestSuite.Start
    Import Variables    ${CFGFILE_PATH}/5GC001008/Delta_SCF.py
    Create Directory    ${LOG_PATH}
    set suite variable     ${TestLineSCF}            ${CFGFILE_PATH}/TestLineSCF1Cell_Both.xml
    set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    ${outputfile}    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
    ...             TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTS_ID=${NRBTS_ID}
    set suite variable   ${TestLineSCF}    ${outputfile}


Teardown Suite
    TestSuite.Stop
Teardown 1008 case
    [Arguments]   ${connection}=COAM
    Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    #Run Keyword And Ignore Error    Backup current SCF
    gNB Connect
    Run Keyword And Ignore Error    kill GNB wireshark process
    Run Keyword And Ignore Error    Clean GNB wireshark log
    Run Keyword And Ignore Error    kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
    TestCase.Stop
Setup Case
    [Arguments]
    TestCase.Start
    Run Keyword And Ignore Error    Start BTSlogs Collection

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf BTSLOG_TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    btslog.Set Global Alias    alias=btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    run keyword and ignore error    core.stop_collectors      names=btslog
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run keyword and ignore error    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

gNB Connect
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}

Commission GNB with retry for 1RU
    [Arguments]    ${scf_file}
    ${commission_check}    run keyword and return status    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900
    Run keyword if    ${commission_check}== True    Log    continue next steps
    Run keyword if    ${commission_check}== False    run keywords     Power.ResetgNB    model=HBTE
                      ...    AND    Power.Reset5GRU    model=HBTE
                      ...    AND    Check HW status
                      ...    AND    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900

Commission GNB with retry for 2RU
    [Arguments]    ${scf_file}
    ${commission_check}    run keyword and return status    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900
    Run keyword if    ${commission_check}== True    Log    continue next steps
    Run keyword if    ${commission_check}== False    run keywords     Power.ResetgNB    model=HBTE
                      ...    AND    Power.Reset5GRU    model=HBTE
                      ...    AND    Power.Reset5G_RU2
                      ...    AND    Check HW status
                      ...    AND    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900

Power.Reset5G_RU2
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}     Action=power_off
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}     Action=power_on

Collect logs
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB.log
    Run Keyword And Ignore Error    gnb.collectlog    logName=${gNB_logName}
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    Collect snapshot via webui

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Check HW status
    gNB Connect
    wait until keyword succeeds    11x    2min    gNB CheckHWStatus
    sleep    3min

gNB CheckHWStatus
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${fct_status}    ${fsp_status}    get_gnb_status.check_board_status_on_asik    connection=${alias}
    log  ${fct_status}
    log  ${fsp_status}
    Should Be Equal    ${fct_status}    ready
    Should Be Equal    ${fsp_status}    ready
Clean GNB wireshark log
    [Arguments]
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /ffs/run/config/toor4nsn/1008*.pcap   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

kill GNB wireshark process
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    ${container}    gnb.get_container_id    nodename=CPIF
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n ${container} -- killall -2 tcpdump    connection=${ALIAS_ASIK}

Connect to 5GC
    csn.connect to    hostname=${5GC_IP}    username=${5GC_USERNAME}    password=${5GC_PASSWORD}    alias=${ALIAS_5GC}
Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Check And Update AMFConf
    [Arguments]   ${testslice}=Testslice213    ${sst}=${SST}    ${sd}=${SD}
    Connect to 5GC
    ${test_slice_presence}=    csn.execute    command=cmm snssai list | grep ${testslice}    connection=${ALIAS_5GC}
    run keyword if   '${test_slice_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
    ...    Send AMFConfUpdate from AMF by adding slice    testslice=${testslice}    sst=${sst}    sd=${sd}
    Disconnect from 5GC

Send AMFConfUpdate from AMF by adding slice
    [Arguments]   ${testslice}=Testslice213    ${sst}=${SST}    ${sd}=${SD}
    csn.execute    command=cmm snssai create --name ${testslice} --sliceServiceType ${sst} --sliceDifferentiator 00000${sd}
    ...    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssaiListItem create --snssaiListName Snssai1 --snssaiName ${testslice}    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssaiToDnn create --snssaiToDnnListName DNN1 --snssaiName ${testslice} --dataNetworkName wap1.nokia.com
    ...    connection=${ALIAS_5GC}
    ${test_slice_presence}=    csn.execute    command=cmm snssai list | grep ${testslice}    connection=${ALIAS_5GC}
    log    ${test_slice_presence}

Check cell status on UE
    [Arguments]   ${status}=barred    ${log_file}=1008_cell_status.xml
    ${ue_type}    ue.translate_power_ue_type_from_testline
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}
    spark.Start Log     ue_alias=${UE_alias}
    Run Keyword And Ignore Error    spark.Power Off    ue_alias=${UE_alias}
    Run Keyword And Ignore Error    spark.Power On    ue_alias=${UE_alias}
    sleep   10s
    spark.Stop Log     logname=${LOG_PATH}/${log_file}    ue_alias=${UE_alias}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    spark.Read Log     logname=${LOG_PATH}/${log_file}
    ${res}    spark.Get Expected Val     msg=NR MasterInformationBlock    expression=cellBarred
    Should Be Equal    ${res}    ${status}

Check cell staus on webUI
    [Arguments]    ${dist_name}=${distname_id_1}/NRCELL-1   ${status}=notBarred
    Check parameter should be correct for gNB    value=${status}    url=${WEBUI_URL}
    ...    dist_name=${dist_name}    filter_param=Cell Barred

