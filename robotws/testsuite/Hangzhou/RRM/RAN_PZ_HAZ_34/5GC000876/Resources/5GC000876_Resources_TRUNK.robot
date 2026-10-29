*** Settings ***
Documentation    author: Cheng Jiajing
...               contact: jiajing.1.cheng@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000876
Resource          ../../5GC000496_C/Resources/L3Call.robot
#Variables         ${CFGFILE_PATH}/Delta_SCF.py
#Variables         ${CFGFILE_ON_GIT}/5GC000876/Delta_SCF.py
Library           ../../5GC000638/Resources/coam_close.py
Library           ../../5GC000742/Resources/MTKUE_extend.py
Resource         ../../5GC000752/Resources/MTKPC_common_keyword.robot
Library           MTKUE_extend.MTKUE    WITH NAME   MTKUE
Library           taf.transport.ssh		WITH NAME	csn
Library           taf.ul.messaging.mtk      WITH NAME    mtk_msg
Library           taf.ue.rpc.mtk      WITH NAME    mtk_rpc
Library           taf.ue    WITH NAME    ute_ue
Library           ute_ue
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.hw.rf_attenuator    WITH NAME    PA
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py

*** Variables ***
#${CFGFILE_ON_GIT}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}

#${DeltaPath}            ${CFGFILE_PATH}/5GC000876/Delta_SCF.py
#${TL_DeltaPath}          ${CFGFILE_PATH}/TLDelta.py
${initial_S1_SCF}         ${LOG_PATH}/TestLineSCF1Cell_Both.xml
${initial_S11_SCF}        ${LOG_PATH}/TestLineSCF2Cell_Both.xml
${initial_S111_SCF}       ${LOG_PATH}/TestLineSCF3Cell_Both.xml

${UPDATE_FILE_PATH}    /opt/ute/tmp/
#${CFGFILE_PATH}    /home/ute/TAF/cfgfile/876_900/
#${lua_script_path}    /home/ute/TAF/cfgfile/luashark/generated_luashark/luashark.lua
${Original_CFGFILE}      /home/ute/TAF/cfgfile/876_900/Configuration_scf_TL206_3Cell.xml

${IPERF_PORT}       ${tl.appserver.port}


${MRBTS}    ${tl.gnbs[0].instance_id}
${NRBTS}    ${tl.gnbs[0].global_bts_id}

${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

${EGATE_CFG_NAME}    ${tl.core.cfg_filename}
${WTS_FILE_PATH}    ${tl.core.dir_path}
${ASIK_IP}        ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${ASIK_IP2}        ${tl.gnbs[1].du.airscale.common_units[0].lmp_connection.addr}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${RU_TYPE}        ${tl.gnbs[0].du.rus[0].radio_type}
${AEQA_IP}        ${tl.gnbs[0].du.rus[0].default_ssh_connection_details.addr}    # 192.168.254.34
${UTE_IP}         ${tl.core.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.core.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.core.default_ssh_connection_details.password}

${PB_PORT}        4001
${PB_ASIK_IP}     ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}     ${tl.gnbs[0].du.rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}    ${tl.gnbs[0].du.rus[0].pdu_port.port_no}

#${IMSI_UE1}           262038001006039
#${AMF_IP}             10.110.149.10
#${AMF_USERNAME}       cmm
#${AMF_PASSWORD}       Nokia@2019!
#${AF_PATH}           1

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${APN2_IP}                  ${tl.test_pc.default_ssh_connection_details.addr}
${APN2_USERNAME}            ${tl.test_pc.default_ssh_connection_details.username}
${APN2_PASSWORD}            ${tl.test_pc.default_ssh_connection_details.password}

${IMSI}           ${tl.ues[0].imsi}

#${UE_TYPE}          huawei_sigspark  #L8K5T19918002820  460028001006044  com8

#${UE_TYPE_2}        huawei_sigspark_2  #L8K5T19923005943  460028001006029   com40

${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}

## Attenuator parameter ##
${PA_INFO}            ${tl.attenuator}

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

${filter}   (((sctp)&&!(sctp.chunk_type==4))&&!(sctp.chunk_type==5))&&!(sctp.srcport==29211)
${cell3_blacklist}   f1ap.procedureCode == 12 && nr-rrc.blackCellsToAddModList == 1 && nr-rrc.start == 53
${HO_cell3_blacklist}   f1ap.procedureCode == 12 && nr-rrc.blackCellsToAddModList == 1 && nr-rrc.start == 53
${cell1_to_cell2_measurement}    nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52 && nr-rrc.servCellId == 0
${cell2_to_cell1_measurement}    nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52 && nr-rrc.servCellId == 0
${second_rrc_configuraiton}    f1ap.procedureCode == 12 && nr-rrc.physCellId==52
${RRC_complete_target_cell}    nr-rrc.c1 == 1
${cell2_to_cell1_3_measurement}   nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 53 && nr-rrc.servCellId == 0
${second_rrc_configuraiton_cell3}    f1ap.procedureCode == 12 && nr-rrc.physCellId==53
${second_rrc_configuraiton52to51}    f1ap.procedureCode == 12 && nr-rrc.physCellId==51
${gnb1_cell2_to_gnb1_cell1_measurement}   nr-rrc.physCellId == 52 && nr-rrc.physCellId == 51 && nr-rrc.servCellId == 0
${source_gnb1_second_rrc_configuraiton}    f1ap.procedureCode == 12 && nr-rrc.physCellId==51
${target_gnb1_pathSwithRequest}   ngap.pDUSessionID == 1
${PDU_SETUP_ACCEPT}     nas_5gs.sm.message_type == 0xc2
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
${ALIAS_APN1}               APN1                                                ##
${ALIAS_APN2}               APN2                                                ##
${ALIAS_5GC}                5gc                                                 ##
${ALIAS_AMF}                AMF                                                 ##
########################END of alias Define#######################################

*** Keywords ***
###########################Case Level Keywords###################
TC.5GC000876_D_018_maxNumOfNonGBRBearersSA, 1 more DRB rejected
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.ModifySCF    InputFile=${initial_S1_SCF}    OutputFile=${LOG_PATH}/876_D_018_SCF.xml
    ...     ParameterToDelete=${PARAMS_TO_DELETE_876_D_018}    ParamterToModify=${PARAMS_TO_MODIFY_876_D_018}
    COAM_Admin.commission         scf_file=${LOG_PATH}/876_D_018_SCF.xml    timeout=900
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    Run Keyword And Continue On Failure   Process.ConnectCellSearchAndAttach_876_D_018
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    wait until keyword succeeds    6x    4min    Process.CheckCountersOf876D18
    Run Keyword And Ignore Error   COAM_WebEM.Logout

###########################Case Level Keywords End###################
Process.ConnectCellSearchAndAttach_876_D_018
    [Documentation]     1. 1 UE , set maxNumOfNonGBRBearersSA to 0 ,maxNumOfRrcSA =2
    ...                    ATTACH successfully , FAILed to set up PDU
#    ...                 2. Delete IMSI
    ...                 3. reserve MTK to make sure MTK is available
    ...                 4. SA UE attach successfully
    ...                 5. PDU reject
    ...                 6. save cpif wireshark and snapshot
    ...                 7. detach
#    5GC.DeleteIMSI   imsi=${IMSI_UE1}  AMF_IP=${AMF_IP}
#    ...              AMF_USERNAME=${AMF_USERNAME}   AMF_PASSWORD=${AMF_PASSWORD}  alias=${ALIAS_AMF}
#    Adjust RU1 Attenuation to ${0}
#    Run Keyword And Ignore Error    Adjust RU2 Attenuation to ${127}
#    Run Keyword And Ignore Error    Adjust RU3 Attenuation to ${127}
##    Adjust GNB2_RU1 Attenuation to ${60}
    Run Keyword And Continue On Failure    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Run Keyword And Ignore Error   ASIK.Connect
    Run Keyword And Ignore Error   Wireshark.StartCaptureLogFromContainer    container=0xe004    nodename=CPIF    filename=Attach.pcap
#    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}    power_reset=True
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${ue_type}    power_reset=True
    sleep    10s
    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${ue_type}    power_reset=True
    sleep    5s
    Run Keyword And Ignore Error   Wireshark.StopCapturinglogFromContainer    container=0xe004    nodename=CPIF
    Run Keyword And Ignore Error   wireshark.DownloadLogToUTEFromContainer    nodename=CPIF       filename=Attach.pcap
    Run Keyword And Ignore Error   Wireshark.StartCaptureLogFromContainer    container=0xe004    nodename=CPIF    filename=PDU.pcap
    Run Keyword And Ignore Error   power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl
    ...   throughput=10MKbits/sec    apn_address=${SA_APN}    ue_mode=SA
    ${pdu_result}    Run keyword and return status   power_ue.Check throughput    ue_type=${UE_TYPE}
    ...   direction=dl    throughput=5
    Run Keyword And Continue On Failure   should be true    ${pdu_result} == False
    Run Keyword And Ignore Error   power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    apn_address=${SA_APN}    ue_mode=SA
    Run Keyword And Ignore Error   Wireshark.StopCapturinglogFromContainer    container=0xe004    nodename=CPIF
    Run Keyword And Ignore Error   wireshark.DownloadLogToUTEFromContainer    nodename=CPIF       filename=PDU.pcap
    Run Keyword And Ignore Error   ASIK.Disconnect
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True

Process.CheckCountersOf876D18
    COAM_WEBEM.CheckBTSConutersWithUPandLowerValue   #SGNB_SA_RAC_REJ_DUE_TO_NGBR
    ...       counter_id=M55138C00007    up_value=50000    lower_value=0    full_path=${Full_Path_876}

COAM_WEBEM.CheckBTSConutersWithUPandLowerValue
    [Arguments]    ${counter_id}   ${up_value}   ${lower_value}    ${full_path}=None
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}    full_path=${full_path}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true    ${values[-1]} > ${lower_value}
    should be true    ${values[-1]} < ${up_value}

Refine PA Port
#    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuator_ports}
#    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuation_port_numbers}
    Set Suite Variable     ${5GRU1_ANT1}    ${PA_PORT[0]}
    Set Suite Variable     ${5GRU1_ANT2}    ${PA_PORT[1]}
    Set Suite Variable     ${5GRU2_ANT1}    ${PA_PORT[2]}
    Set Suite Variable     ${5GRU2_ANT2}    ${PA_PORT[3]}
    Set Suite Variable     ${5GRU3_ANT1}    ${PA_PORT[4]}
    Set Suite Variable     ${5GRU3_ANT2}    ${PA_PORT[5]}
    Set Suite Variable     ${5GGNB2_RU1_ANT1}    ${PA_PORT[6]}
    Set Suite Variable     ${5GGNB2_RU1_ANT2}    ${PA_PORT[7]}

##interHO ,intra HO can refer to 5GC000704

Wireshark filter verify
    [Arguments]    ${filename}    ${filter}
    Wireshark.ReadLog   filename=${filename}   filter=${filter}
    Wireshark.CheckExpression    expression=${filter}

## modify PA ##
Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    PA.setup_attenuator    attenuator=${PA_INFO}
    PA.set_attenuation     port=${ports}    value=${value}
    PA.read_attenuation    port=${ports}

ASIK.Connect
    [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

Wireshark.Action.Close
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

Process.ModifyAndCommissionAndCheckOnAir
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    [Arguments]       ${original_cfgfile}
        ...            ${modified_cfgfile}
        ...            ${parameters_to_modify}
    ModifyParametersToSCF   input_scf=${original_cfgfile}    output_scf=${modified_cfgfile}
    ...                     modify_parameters_lists=${parameters_to_modify}
    COAM_Admin.commission         scf_file=${modified_cfgfile}    timeout=900
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady

Process.PrintTLInformation
    log many    ${EGATE_CFG_NAME}    ${WTS_FILE_PATH}    ${ASIK_IP}    ${AEQA_IP}
    log many    ${UTE_IP}    ${UTE_USERNAME}    ${UTE_PASSWORD}
    log many    ${PB_PORT}    ${PB_ASIK_IP}    ${PB_ASIK_PORT}
    log many    ${PB_5GRU_IP}    ${PB_5GRU_PORT}

ModifyParametersToSCF
    [Documentation]   Modify Parameters in ${modify_parameters_lists} to ${input_scf}
    [Arguments]    ${input_scf}    ${output_scf}    ${modify_parameters_lists}
    ${exist}=    run keyword and return status    OperatingSystem.File Should Exist    ${CFGFILE_PATH}/Delta_SCF.py
    run keyword if    ${exist}    commissioning.modify_scf    input_scf=${input_scf}
    ...    output_scf=${output_scf}    parameters_lists=${modify_parameters_lists}

KW.MultiRunCases
    [Arguments]   ${keyword}    ${times}=2
    FOR    ${i}    IN RANGE    ${times}
         ${res}    Run Keyword And Ignore error    ${keyword}
         Return From Keyword if   '${res[0]}'=='PASS'
    END
    Fail  Run '${keyword}' failed after retry '${times}' times

COAM.SetParameterValue
    [Arguments]    ${distname}    ${paraname}    ${value}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${paraname}    new_value=${value}

ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

gNB.EnableDebugLog
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=cp /user/toor4nsn/wa/cp_runtime.ini /rom/   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}


Setup suite
    Run Keyword And Ignore Error     Import Variables     ${CFGFILE_PATH}/Delta_SCF.py
    Import Variables     ${CFGFILE_PATH}/5GC000876/Delta_SCF.py
    TestSuite.Start
    Run Keyword And Ignore Error    basic.checkvariablevalid  var=Full_Path_876
    ...    default_value=CELLS/NRCELL-1/RSACU/SGNB_SA_RAC_REJ_DUE_TO_NGBR
    log    ${Full_Path_876}
    set suite variable   ${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}
    set suite variable   ${DeltaPath}            ${CFGFILE_PATH}/5GC000876/Delta_SCF.py
    set suite variable   ${TL_DeltaPath}          ${CFGFILE_PATH}/TLDelta.py
    PA.AdjustAttenuationValueByGroups
#    Refine PA Port
#    Adjust RU1 Attenuation to ${0}
#    Adjust RU2 Attenuation to ${127}
#    Run Keyword And Ignore Error    Adjust RU3 Attenuation to ${127}
#    Adjust GNB2_RU1 Attenuation to ${127}
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    Set Suite Variable   ${CASE_ECECUTED}    NO
    Set Suite Variable    ${TargetCounter}  0
    gNB.FormatBTSID
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    GNB.SwconfigReplace  file_path=${CFGFILE_PATH}/5GC000876

	gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${2}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${3}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
    Conn.ResetCache

Teardown Suite
    TestSuite.Stop

Setup case
    TestCase.Start
    Start BTSlogs Collection

Teardown case
    TestCase.Stop
#    Adjust RU1 Attenuation to ${0}
#    Adjust RU2 Attenuation to ${127}
#    Run Keyword And Ignore Error    Adjust RU3 Attenuation to ${127}
##    Adjust GNB2_RU1 Attenuation to ${127}
    PA.AdjustAttenuationValueByGroups
    Run Keyword And Ignore Error   ASIK.Connect
    Run Keyword And Ignore Error   Wireshark.StopCapturinglogFromContainer
    Run Keyword And Ignore Error   ASIK.Disconnect
    Run Keyword And Ignore Error    Collect snapshot via webui
    Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    #Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error   Conn.ResetCache

GNB.SwconfigReplace
    [Arguments]    ${file_path}=${CFGFILE_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${file_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

