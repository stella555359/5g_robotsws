*** Settings ***
Documentation    author: wang sujuan
...               contact: sujuan.wang@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC0002056

Library           ../../5GC000638/Resources/coam_close.py
#Library           ../../../../../resources/python_libs/Attenuation.py
Library    taf.hw.rf_attenuator    WITH NAME    atten
#Library           Attenuation.Attenuation    WITH NAME    atten
Library           taf.hw.rf_attenuator    WITH NAME    PA
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_PATH}/TLDelta.py

*** Variables ***
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${UE1_TYPE}                   ${tl.ues[1].capabilities[-1]}
${UPDATE_FILE_PATH}         /opt/ute/tmp/
${Local_CFGFILE_PATH}       /home/ute/TAF/cfgfile/
#${CFGFILE_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${lua_script_path}       ${Local_CFGFILE_PATH}luashark/generated_luashark/luashark.lua
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                     ${tl.ues[1].imsi}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${MRBTS_ID}                    ${tl.gnbs[0].instance_id}
${NRBTS_ID}                    ${tl.gnbs[0].global_bts_id}

${EGATE_CFG_NAME}           ${tl.core.cfg_filename}
${WTS_FILE_PATH}            ${tl.core.dir_path}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${UE_alias}                 UE_0
${ALIAS_5GC}                5gc

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${RU_TYPE}                  ${tl.gnbs[0].dus[0].rus[0].radio_type}
${AEQA_IP}                  ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${PB_PORT}                  4001
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${dist_name}                MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}

${atten_ip}                 ${tl.attenuator.ip_addr}
${PA_TYPE}                  ${tl.attenuator.vendor}
${PA_INFO}                  ${tl.attenuator}
#${PA_PORTS}                 ${tl.attenuator.attenuator_ports}
####GNB1####
${5GRU1_ANT1}    ${1}
${5GRU1_ANT2}    ${2}
${5GRU2_ANT1}    ${3}
${5GRU2_ANT2}    ${4}
${5GRU3_ANT1}    ${5}
${5GRU3_ANT2}    ${6}

####GNB2####
${5GGNB2_RU1_ANT1}    ${7}
${5GGNB2_RU1_ANT2}    ${8}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}                abil                                               ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_LONER}              loner                                               ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
########################END of alias Define#######################################

*** Keywords ***
###--------Precondition robot-------###
Setup Suite For 2056
    Run Keyword And Ignore Error    TestSuite.Start
    Run Keyword And Ignore Error    Create Log Directories
    gNB.FormatBTSID
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
    Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    ${outputfile_1cell}    gNB.Generate TL SCF
	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
	...                  TestLineSCF_cell_num=${1}    cell_type=Both
	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${Original_CFGFILE_1Cell}    ${outputfile_1cell}
	${outputfile_2cell}    gNB.Generate TL SCF
	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
	...                  TestLineSCF_cell_num=${2}    cell_type=Both
	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${Original_CFGFILE_2Cell}    ${outputfile_2cell}
    Run Keyword And Ignore Error    PA_Adjust Attenuation Ports To Same Value
    ...    ports=${PA_PORTS}    value=${120}    attenuator=${PA_INFO}
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[0]}    value=${0}    attenuator=${PA_INFO}
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[1]}    value=${0}    attenuator=${PA_INFO}
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver

Teardown Suite For 2056
    Run Keyword And Ignore Error    TestSuite.Stop

Setup Case For 2056
    Run Keyword And Ignore Error    TestCase.Start

Teardown Case For 2056
    COAM_WebEM.Login
    Run Keyword And Ignore error    Stop UE Traffic   ue_index=${0}
    Run Keyword And Ignore error    Stop UE Traffic   ue_index=${1}
    Run Keyword And Ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
    Run Keyword And Ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${1}
    Run Keyword And Ignore Error
    ...    spark.Stop Log     logname=${LOG_PATH}/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_UE0.xml
    ...                       ue_alias=UE_0
    Run Keyword And Ignore Error
    ...    spark.Stop Log     logname=${LOG_PATH}/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_UE1.xml
    ...                       ue_alias=UE_1

    Run Keyword And Ignore Error    Unlock Cell   cell_idx=1
    Run Keyword And Ignore Error    Unlock Cell   cell_idx=2
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    #gNB.Connect
    Run Keyword And Ignore Error    kill GNB wireshark process
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Collect logs
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs
    Run Keyword And Ignore Error    kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
    log to console    CASE DONE
    Run Keyword And Ignore Error    TestCase.Stop


###--------wireshark---------###
Wireshark.Capture_NG_Log
    [Arguments]   ${filename}    ${listen_port}=br1     ${filter}=sctp    ${log_dir}=/tmp    ${connection}=${ALIAS_ASIK}
    ssh.send command    tcpdump -s 0 -n -i ${listen_port} ${filter} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}

ASIK.Connect
    [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  Conn.Disconnect    alias=${alias}

ModifyParametersToSCF
    [Documentation]   Modify Parameters in ${modify_parameters_lists} to ${input_scf}
    [Arguments]    ${input_scf}    ${output_scf}    ${modify_parameters_lists}
    ${exist}=    run keyword and return status    File Should Exist    ${CFGFILE_PATH}5GC002056-742/Delta.py
    run keyword if    ${exist}    commissioning.modify_scf    input_scf=${input_scf}
    ...    output_scf=${output_scf}    parameters_lists=${modify_parameters_lists}

SetParameterValue
    [Arguments]    ${dist_name}    ${filter_param}    ${new_value}    ${abbr}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}    new_value=${new_value}    abbr=${abbr}

GetParameterValue
    [Arguments]    ${dist_name}   ${filter_param}    ${abbr}
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    abbr=${abbr}
    [Return]       ${value}

#COAM.ValidateAndActiveParameters
#    ${error}    selenium_coam.validate_plan
#    log    ${error}
#    Run Keyword And Ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=True

ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

Check Certain Alarm from Active Alarms
     [Arguments]     ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}
    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Set test variable    ${alarm_info}
    ${length}    Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        ${res}    run keyword and return status    Check Certain Alarm  alarm_id=${alarm_info[${i}]['Alarm ID']}
        ...    fault_id=${alarm_info[${i}]['Fault ID']}   fault_name=${alarm_info[${i}]['Fault name']}   target_alarm_id=${target_alarm_id}
        ...    target_fault_id=${target_fault_id}    target_fault_name=${target_fault_name}
        Run Keyword If    ${res}    Exit For Loop
    END
    run keyword if  not ${res}   Fail    Alarm ${target_alarm_id} not found!
    COAM_WebEM.Logout

Check Certain Alarm
    [Arguments]   ${alarm_id}    ${fault_id}    ${fault_name}   ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}
    run keyword and ignore error    should contain   container=${alarm_id}   item=${target_alarm_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_id}   item=${target_fault_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_name}   item=${target_fault_name}

Lock Cell
    [Arguments]   ${cell_idx}=1    ${timeout}=300
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked"    run keywords
    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    ...    AND    Sleep  5s
    ${cell_info}=    selenium_coam.get_cell_info  cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Locked"

Unlock Cell
    [Arguments]   ${cell_idx}=1    ${timeout}=300
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"    run keywords
    ...    selenium_coam.unlock_cell    cell_idx=${cell_idx}   timeout=${timeout}
    ...    AND    Sleep  5s
    ${cell_info}=    selenium_coam.get_cell_info   cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Unlocked"

Close Wireshark on ute
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      alias=${ALIAS_UTE}
    sleep  2s

GNB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}
    COAM_Admin.commission    scf_file=${file_path}/${scf_file}

SetTestVariables
    [Arguments]    ${mcs}=0    ${ul}=6    ${dl}=22
    Set Test Variable    ${mcs}
    Set Test Variable    ${UL_TPUT}    ${ul}
    Set Test Variable    ${DL_TPUT}    ${dl}
    ${expect_ul}    Evaluate    ${UL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_ul}
    ${expect_dl}    Evaluate    ${DL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_dl}

GNB.SwconfigIsReplaced
    [Arguments]    ${file_path}=${CFGFILE_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${file_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

kill GNB wireshark process
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n 0xe004 -- killall -2 tcpdump    connection=${ALIAS_ASIK}

kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

Collect logs
    #${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB.log
    #Run Keyword And Ignore Error    gnb.collectlog    logName=${gNB_logName}
    #Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    gNB.CollectSnapshot

Adjust Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${atten_ip}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    PA.setup_attenuator    attenuator=${PA_INFO}
    PA.set_attenuation     port=${ports}    value=${value}
    PA.read_attenuation    port=${ports}

Adjust ${RU} Attenuation to ${value}
#    log to console  ${PA_TYPE}
    Run keyword If    '${PA_TYPE}'=='TOPYOUNG'    Adjust Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    Run keyword If    '${PA_TYPE}'=='HBTE'        Adjust Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}=${PA_INFO}
    PA.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA.set_attenuation    port=${ports[${i}]}    value=${value}
        PA.read_attenuation    port=${ports[${i}]}
    END

One_UE Call with traffic
    [Arguments]   ${ue_index}=${0}    ${duration}=600
    ${apn_address}     Set variable if  ${ue_index}==${0}    ${SA_APN}    ${NSA_APN}
    ${ue_mode}    Set variable if  ${ue_index}==${0}    SA    NSA
    gNB.Connect
    power_ue.Prepare UE   ue_type=${UE_TYPE}    ue_index=${ue_index}
    spark.Power Off    ue_alias=UE_${ue_index}
    Run Keyword And Continue On Failure    Wireshark.Capture_NG_Log
    ...    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG.pcap
    ...    listen_port=${NGAP_port}
    ${UE_Attach}    run keyword and return status     spark.Power On    ue_alias=UE_${ue_index}
    run keyword if    ${UE_Attach}    Run Keyword And Continue On Failure    power_ue.Start traffic  ue_type=${UE_TYPE}
    ...    direction=dl    throughput=10MKbits/sec    duration=${duration}    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    run keyword if    ${UE_Attach}    Run Keyword And Continue On Failure    power_ue.Start traffic  ue_type=${UE_TYPE}
    ...    direction=ul    throughput=5MKbits/sec    duration=${duration}    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    Run Keyword And Continue On Failure    Wireshark.StopCaptureNGLog
    Run Keyword And Continue On Failure    Wireshark.DownloadLogToUTE
    ...    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG.pcap
    sleep  60s
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5    ue_index=${ue_index}
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=3    ue_index=${ue_index}
    Wireshark.ReadLog    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG.pcap
    ...    filter=ngap || x2ap
    ${SA_status}   Run Keyword And Return Status    Wireshark.CheckExpression    expression=ngap.procedureCode == 14
	${NSA_status}   Run Keyword And Return Status    Wireshark.CheckExpression    expression=x2ap.procedureCode == 28
	should be true    ${SA_status} or ${NSA_status}

Dual_UE Call with_traffic
    [Arguments]
    run keyword and ignore error    5GC.DeleteIMSI
    ...    imsi=${IMSI}  AMF_IP=${5GC_IP}  AMF_USERNAME=${5GC_USERNAME}  AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_5GC}
    run keyword and ignore error    5GC.DeleteIMSI
    ...    imsi=${IMSI1}  AMF_IP=${5GC_IP}  AMF_USERNAME=${5GC_USERNAME}  AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_5GC}
    One_UE Call with traffic    ue_index=${0}
    One_UE Call with traffic    ue_index=${1}
    run keyword and ignore error    Stop UE Traffic    ue_index=${0}
    run keyword and ignore error    Stop UE Traffic    ue_index=${1}

Stop UE Traffic
    [Arguments]   ${ue_index}=${0}
    ${apn_address}     Set variable if  ${ue_index}==${0}    ${SA_APN}    ${NSA_APN}
    ${ue_mode}    Set variable if  ${ue_index}==${0}    SA    NSA
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
