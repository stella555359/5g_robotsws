*** Settings ***
Documentation    author: Gao Ge
...               contact: ge.gao@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC0002267

#Resource          ../../5GC002056/Resources/5GC002056_Resources.robot
#Resource          ../../5GC000900/Resources/5GC000900_PowerUE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          ../../5GC000496_C/Resources/L3Call.robot
#Variables         ${CFGFILE_PATH}5GC002267/Delta_SCF.py
#Variables         ${CFGFILE_PATH}/TLDelta.py

*** Variables ***
${Original_CFGFILE}      ${CFGFILE_PATH}TestLineSCF1Cell_Both.xml
#${CFGFILE_for_case02}    ${CFGFILE_PATH}5GC002056-2267/scf_s11_sa_both.xml
#${IMSI}                  ${tl.ues[0].imsi}

${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${UE1_TYPE}                   ${tl.ues[1].capabilities[-1]}
${UPDATE_FILE_PATH}         /opt/ute/tmp/
${Local_CFGFILE_PATH}       /home/ute/TAF/cfgfile/
#${CFGFILE_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}
${TL_DeltaPath}          ${CFGFILE_PATH}/TLDelta.py
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
####Case Level  Keywords#####
TC.5GC002267_A_02_Re-establishment_Count_Update
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Generate 2267_1cell_SA    InputFile=${LOG_PATH}/TestLineSCF1Cell.xml
    gNB.Commission   scf_file=${LOG_PATH}/5GC002267_1cell_SA.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    gNB.connect
    Wireshark.StartCaptureLogFromContainer    filename=NG_2267_A_case2.pcap    nodename=CPIF
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True
    sleep    10s
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}    power_reset=True
    sleep    5s
    Run Keyword And Ignore Error   power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl
    ...    throughput=${CASE_INPUT_5GC002267['DL_TRIFFIC_VALUE']}MKbits/sec   duration=120
    ...    apn_address=${SA_APN}    ue_mode=SA
    Run Keyword And Ignore Error   power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul
    ...    throughput=${CASE_INPUT_5GC002267['UL_TRIFFIC_VALUE']}MKbits/sec   duration=120
    ...    apn_address=${SA_APN}    ue_mode=SA
    sleep    30
    Run Keyword And Ignore Error    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl
    ...    throughput=${CASE_INPUT_5GC002267['DL_TRIFFIC_VALUE']*0.8}
    Run Keyword And Ignore Error    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul
    ...    throughput=${CASE_INPUT_5GC002267['UL_TRIFFIC_VALUE']*0.8}
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS[0]}    value=${CASE_INPUT_5GC002267['PA_VALUE_FOR_RRCReestablish']}
    ...    attenuator=${PA_INFO}
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS[1]}    value=${CASE_INPUT_5GC002267['PA_VALUE_FOR_RRCReestablish']}
    ...    attenuator=${PA_INFO}
    sleep    30
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS[0]}    value=${CASE_INPUT_5GC002267['PA_VALUE_FOR_DEFAULT']}
    ...    attenuator=${PA_INFO}
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS[1]}    value=${CASE_INPUT_5GC002267['PA_VALUE_FOR_DEFAULT']}
    ...    attenuator=${PA_INFO}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    apn_address=${SA_APN}    ue_mode=SA
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    apn_address=${SA_APN}    ue_mode=SA
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    wireshark.DownloadLogToUTEFromContainer   filename=NG_2267_A_case2.pcap     nodename=CPIF
    Wireshark.ReadLog    filename=NG_2267_A_case2.pcap    filter=f1ap
    Wireshark.Check reest request in f1ap
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    Wait Until Keyword Succeeds    5x    1min    Check Reestablishment_Counters
    COAM_WebEM.Logout
    gNB.Disconnect

####Case Level  Keywords#####
#Wireshark.StopCapturingALLlog
#    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}

Generate 2267_1cell_SA
	[Arguments]    ${InputFile}
    gNB.GenerateCaseSCF    InputFile=${InputFile}    OutputFile=${LOG_PATH}/5GC002267_1cell_SA.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=PARAMS_TO_DELETE_2267
	...                    ParamterToModify=PARAMS_TO_MODIFY_2267
	...                    MOsToAdd=MOs_TO_ADD_2267
	...                    ListParamterToModify=LIST_PARAMS_TO_MODIFY_2267
    ...                    ListToAdd=List_TO_ADD_2267
#	gNB.ModifySCF     InputFile=${InputFile}
#    ...               OutputFile=${LOG_PATH}/5GC002267_1cell_SA.xml
#    ...               ParameterToDelete=${PARAMS_TO_DELETE_2267}
#	...               MOsToAdd=${MOs_TO_Add_2267}
#    ...               ParamterToModify=${PARAMS_TO_MODIFY_2267}
#    ...               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_2267}
#    ...               ListToAdd=${LIST_TO_ADD_2267}
	[Return]     ${LOG_PATH}/2267_1cell_SA.xml

Wireshark.Check reest request in f1ap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=nr-rrc.reestablishmentCause == 2

Check Reestablishment_Counters
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55124C00505
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55124C00502


#COAM_Admin.GetBTSConter
#    [Arguments]    ${counter_id}    ${expected_value}=1
#    ${date}   Get Current Date   exclude_millis=True
#    ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}
#    ${values}    get dictionary values   ${res}
#    log  The latest one is: ${values[-1]}
#    should be true    ${values[-1]}==${expected_value}

COAM_Admin.CheckBTSConterWithTraget
    [Arguments]    ${counter_id}    ${target_value}=0
    ${date}   Get Current Date   exclude_millis=True
    ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}      timeout_for_loading_available_counters=60
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true    ${values[-1]}>${target_value}

TestSuite.StartSuit
    [Documentation]    1.set log level
    ...                2.generate TL scf
#    Import Variables    ${CFGFILE_PATH}5GC002267/Delta_SCF.py
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${DIST_NAME}   ${MRBTS_ID}/${NRBTS_ID}
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_PATH}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_PATH}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    gNB.GenerateTestLineSCFs
    [Return]     ${LOG_PATH}/TestLineSCF1Cell.xml

TestSuite.StopSuit
     TestSuite.Stop
##from 2056-resource##
Setup Suite For 2056
    Run Keyword And Ignore Error    TestSuite.Start
    Run Keyword And Ignore Error    Create Log Directories
    gNB.FormatBTSID
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
    Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    gNB.GenerateTestLineSCFs
#    ${outputfile_1cell}    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
#	...                  TestLineSCF_cell_num=${1}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${Original_CFGFILE_1Cell}    ${LOG_PATH}/TestLineSCF1Cell.xml
#	${outputfile_2cell}    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
#	...                  TestLineSCF_cell_num=${2}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${Original_CFGFILE_2Cell}    ${LOG_PATH}/TestLineSCF2Cell.xml
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

kill GNB wireshark process
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n 0xe004 -- killall -2 tcpdump    connection=${ALIAS_ASIK}

PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}=${PA_INFO}
    PA.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA.set_attenuation    port=${ports[${i}]}    value=${value}
        PA.read_attenuation    port=${ports[${i}]}
    END

Stop UE Traffic
    [Arguments]   ${ue_index}=${0}
    ${apn_address}     Set variable if  ${ue_index}==${0}    ${SA_APN}    ${NSA_APN}
    ${ue_mode}    Set variable if  ${ue_index}==${0}    SA    NSA
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}

Unlock Cell
    [Arguments]   ${cell_idx}=1    ${timeout}=300
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"    run keywords
    ...    selenium_coam.unlock_cell    cell_idx=${cell_idx}   timeout=${timeout}
    ...    AND    Sleep  5s
    ${cell_info}=    selenium_coam.get_cell_info   cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Unlocked"

Collect logs
    #${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB.log
    #Run Keyword And Ignore Error    gnb.collectlog    logName=${gNB_logName}
    #Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    gNB.CollectSnapshot

kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9