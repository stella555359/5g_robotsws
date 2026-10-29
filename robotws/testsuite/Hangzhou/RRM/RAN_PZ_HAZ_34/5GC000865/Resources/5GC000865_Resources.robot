*** Settings ***
Documentation     author: Gao Ge
...               contact: ge.gao@nokia-sbell.com

Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          ../../5GC000900/Resources/5GC000900_PowerUE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           taf.ue    WITH NAME    ute_ue
Library           ute_ue
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ../../5GC000638/Resources/coam_close.py
#Variables         ${CFGFILE_ON_GIT}/5GC000865/Delta_SCF.py
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py

*** Variables ***
#${UE_TYPE}                  huawei_sigspark
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}

&{NEA0}    filter_param=Null ciphering algorithm  abbr=nea0   new_value=0
&{NEA1}    filter_param=SNOW 3G-based algorithm  abbr=nea1_128   new_value=0
&{NEA2}    filter_param=AES-based algorithm  abbr=nea2_128   new_value=0
&{NEA3}    filter_param=ZUC-based algorithm  abbr=nea3_128   new_value=0
&{NIA1}    filter_param=SNOW 3G-based algorithm  abbr=nia1_128   new_value=0
&{NIA2}    filter_param=AES-based algorithm  abbr=nia2_128   new_value=0
&{NIA3}    filter_param=ZUC-based algorithm  abbr=nia3_128   new_value=0

#${CFGFILE_ON_GIT}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/${GoldenSCF}

#${TL_DeltaPath}           ${CFGFILE_PATH}/TLDelta.py
#${DeltaPath}            ${CFGFILE_PATH}/5GC000865/Delta_SCF.py
${initial_S1_SCF}        ${LOG_PATH}/TestLineSCF1Cell_Both.xml

${IMSI}                     ${tl.ues[0].imsi}

${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

#TL207_gNB1
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${ASIK_IP}

#TL20702_gNB2
${WEBUI_IP1}                 ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME1}           ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD1}           ${tl.gnbs[1].cu.oam_http_connection_details.password}
${WEBUI_URL1}                https://${tl.gnbs[1].cu.oam_http_connection_details.addr}

${PB_PORT}                  4001
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}              ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}            ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PB_5GRU2_IP}              ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
${PB_5GRU2_PORT}            ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}

${UL_TP}                    5
${DL_TP}                    10

##################define these variable for convenient############################
${ALIAS_ASIK}     		asik
${ALIAS_ASIK_SLAVE}    	asik_slave
${ALIAS_UTE}     		ute
${ALIAS_ENBCTLPC}    	ENB_PC
${ALIAS_SHP}      		SHP
${ALIAS_E500}     		E500
${ALIAS_PRISMA}    		Prisma
${ALIAS_REAL_EPC_SERVER}    Real_EPC
${ALIAS_LONER}    		LONER
${ALIAS_ASP_1A}    		ASP_1A
${AlIAS_QC}       		Qualcomm
${UE_alias}       		UE_1
${ALIAS_5GC}      		5gc
########################END of alias Define#######################################

*** Keywords ***
TC.5GC000865_B_5GC000866_B_6_Configure AES_Integration protection and ciphering for DL Data (DRB) transfer
    Set Agorism Values  nia2_value=1    nea2_value=1
    Modify Ciphering and Integration value for gNB
    Wireshark.Action.Capture    filename=NG_UE_capabilityB6.pcap    conn=${ALIAS_ASIK}
    sleep    5s
    Run Keyword And Continue On Failure  SigSpark_UE attach and ULDL traffic
    Run Keyword And Continue On Failure  SigSpark_UE detach
    Wireshark.Action.Stop_And_Download    filename=NG_UE_capabilityB6.pcap    conn=${ALIAS_ASIK}

*** Keywords ***
Setup My suite
    TestSuite.Start
    Import Variables    ${CFGFILE_PATH}/5GC000865/Delta_SCF.py
    set suite variable    ${TL_DeltaPath}           ${CFGFILE_PATH}/TLDelta.py
    set suite variable    ${DeltaPath}            ${CFGFILE_PATH}/5GC000865/Delta_SCF.py
    set suite variable    ${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}
#    Refine PA Port
    log to console  \nTest Suite Begin To Start
    Setup Suite
    Return From Keyword If    '${testline_name}' == '7_5_UTE402T211'
    #Lock_gNB2_cell
#    Adjust RU1 Attenuation to ${0}
##    Adjust GNB2_RU1 Attenuation to ${127}
    PA.AdjustAttenuationValueByGroups
    gNB.FormatBTSID
    GNB.SwconfigReplace  file_path=${CFGFILE_PATH}/5GC000865

	gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

	gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.ModifySCF    InputFile=${initial_S1_SCF}    OutputFile=${LOG_PATH}/865_S1_SA_SCF.xml
    ...     ParameterToDelete=${PARAMS_TO_DELETE_865}    ParamterToModify=${PARAMS_TO_MODIFY_865}
    GNB.Commissioning   scf_file=865_S1_SA_SCF.xml   file_path=${LOG_PATH}
#    Conn.ResetCache

Teardown My Suite
    TestSuite.Stop
    Return From Keyword If    '${testline_name}' == '7_5_UTE402T211'
    Recover Cipher and Integration Setting
    #Unlock_gNB2_cell
#    Adjust RU1 Attenuation to ${0}
##    Adjust GNB2_RU1 Attenuation to ${127}
    PA.AdjustAttenuationValueByGroups
    Conn.ResetCache

Recover Cipher and Integration Setting
    Set Agorism Values  nia3_value=9    nea3_value=9
    Modify Ciphering and Integration value for gNB

Modify Ciphering and Integration value for gNB
    [Arguments]  ${dist_name}=${MRBTS_ID}/${NRBTS_ID}   ${change_list}=@{ALG_CHANGE_LIST}
    COAM_WebEM.Login
    FOR    ${item}    IN    @{change_list}
        selenium_coam.set_parameter_value    dist_name=${dist_name}  filter_param=${item}[filter_param]  abbr=${item}[abbr]
    ...    new_value=${item}[new_value]
    END
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    COAM_WebEM.Logout

Set Agorism Values
    [Arguments]   ${nea0_value}=0   ${nea1_value}=0   ${nea2_value}=0   ${nea3_value}=0    ${nia1_value}=0  ${nia2_value}=0  ${nia3_value}=0
    Set To Dictionary    ${NEA0}    new_value=${nea0_value}
    Set To Dictionary    ${NEA1}    new_value=${nea1_value}
    Set To Dictionary    ${NEA2}    new_value=${nea2_value}
    Set To Dictionary    ${NEA3}    new_value=${nea3_value}
    Set To Dictionary    ${NIA1}    new_value=${nia1_value}
    Set To Dictionary    ${NIA2}    new_value=${nia2_value}
    Set To Dictionary    ${NIA3}    new_value=${nia3_value}
    ${change_list}=    create list    ${NEA0}   ${NEA1}   ${NEA2}   ${NEA3}   ${NIA1}   ${NIA2}   ${NIA3}
    Set Suite Variable    ${ALG_CHANGE_LIST}     ${change_list}
    Log    ${ALG_CHANGE_LIST}

Case Setup For 865
    TestCase.Start
    Log to console    \nCase setup
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=0
    Clear UE info from AMF    ue_imsi=${IMSI}
    Run Keyword And Ignore Error    Start BTSlogs Collection

#Clear UE info from AMF
#   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
#   Connect to 5GC
#   ${imsi_presence}=    ssh.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
#   ...    connection=${ALIAS_5GC}
#   run keyword unless   '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
#   ...    ssh.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
#   run keyword unless   '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
#   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
#   Disconnect from 5GC

#Start BTSlogs Collection
#    [Documentation]    collect syslogs from ute VM.
#    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
#    btslog.create_btslog_collector
#    ...   name=btslog
#    ...   btslog_path=/opt/btslog/btslog
#    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
#    ...   log_dir=/tmp/btslog2
#    btslog.Set Global Alias     btslog
#    core.setup_collectors      names=btslog
#    core.start_collectors      names=btslog

Case Teardown For 865
    TestCase.Stop
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    run    command=killall firefox
    Run Keyword And Ignore Error    gNB.Connect
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Run Keyword And Ignore Error    Wireshark.StopCapturingALLlogs
    Run Keyword And Ignore Error     Collect Snapshot
    Run Keyword And Ignore Error     Stop BTSlogs Collection and get logs
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     Kill Xvfb in UTE
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
    Conn.ResetCache

Wireshark.StopCapturingALLlogs
    ASIK.Connect   alias=${ALIAS_ASIK}
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}
    ASIK.Disconnect    alias=${ALIAS_ASIK}

ASIK.Connect
    [Arguments]   ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

#Stop BTSlogs Collection and get logs
#    core.teardown_collectors      names=btslog
#    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
#    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz SYSLOG_combine.LOG
#    run    command=cp /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz ${LOG_PATH}

Wireshark.Action.Capture
    [Arguments]   ${filename}    ${conn}    ${listen_port}=fp0    ${log_dir}=/tmp
    ASIK.Connect   alias=${conn}
    Wireshark.StartCaptureLog    listen_port=fp0    log_dir=/tmp     filename=${filename}    connection=${conn}
    sleep    2

#Wireshark.StartCaptureLog
#    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
#    ssh.send command    tcpdump -s 0 -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}

SigSpark_UE attach and ULDL traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${apn_address}=${SA_APN}   ${ue_mode}=SA
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${ue_index}    power_reset=True
    sleep    10s
    power_ue.UE Attach    ue_type=${ue_type}     ue_index=${ue_index}    power_reset=True
    sleep    5s
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=10MKbits/sec    duration=600
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul     throughput=5MKbits/sec    duration=600
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    sleep    30
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=2

SigSpark_UE detach
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${apn_address}=${SA_APN}   ${ue_mode}=SA
    Run Keyword And Ignore Error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    Run Keyword And Ignore Error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True

Wireshark.Action.Stop_And_Download
    [Arguments]   ${conn}    ${filename}    ${log_dir}=/tmp
    sleep    2
    Wireshark.StopCapturinglogs    alias=${conn}
    sleep    2
    Wireshark.DownloadLogToUTE    filename=${filename}   connection=${conn}
    sleep    5
    ASIK.Disconnect    alias=${conn}

Wireshark.StopCapturinglogs
    [Arguments]    ${alias}
    ssh.execute        command=ps -ef|grep -i tcpdump     connection=${alias}
    ssh.send command        command=killall -2 tcpdump     connection=${alias}
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${alias}


#Wireshark.DownloadLogToUTE
#    [Arguments]    ${filename}   ${log_dir}=/tmp    ${connection}=${ALIAS_ASIK}
#    [Timeout]    5min
#    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${log_dir}/${filename}   connection=${connection}
