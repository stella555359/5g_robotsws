*** Settings ***
Documentation     author: Ming Lu
...               Group: HGZ_SG1
...               contact: ming.lu@nokia-sbell.com

Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           ../../../../SISO/RAN_PZ_HAZ_34/5GC001278/Library/get_bts_info.py    WITH NAME    lib\
Library           taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           XML   WITH NAME    ParseXML
Library           taf.sw.dcap.rd                        WITH NAME    rd
Library           Process
Library           ../../5GC000638/Resources/coam_close.py


*** Variables ***
#${SHERPA_LOG_PATH}          /home/ute/sherpa_log/


${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}
${IMSI2}                     ${tl.ues[1].imsi}

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${PA_INFO}                  ${tl.attenuator}

${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${dist_name}                ${MRBTS_ID}/${NRBTS_ID}

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
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####

TC.5GC000732_A_03_RRC_Reestablishment_to_The_Same_Serving_Cell_Counters_Update
    KW.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/732_A_03_SCF.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_732_A_03    parameters_to_delete=PARAMS_TO_DELETE_732_A_03
    ...    mo_to_add=ADD_MOS_732_A_03    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_732_A_03
    ...    list_to_add=LIST_TO_ADD_732_A_03
    KW.Adjust PA to default
    KW.One_UE_L3Call_With_Traffic_And_CPIFlog
    KW.Start Collect CPIF   log_filename=CPIF_732_A03_rrcReestab.pcap
    KW.Adjust PA_A03_rrcRelease
    sleep    1s
    KW.Adjust PA to default
    KW.Stop Collect CPIF and Download  log_filename=CPIF_732_A03_rrcReestab.pcap
    KW.Check_Throughput
    UE.One_UE_Stop_traffic_and_Detach
    Wait Until Keyword Succeeds    15min    1min    KW.Check_rrcReestab_Counter



TC.5GC000732_F_02_RRC_Reestablishment_To_The_Serving_Cell_Interaction_With_DRX_And_Measurement_Gap
    KW.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/732_F_02_SCF.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_732_F_02    parameters_to_delete=PARAMS_TO_DELETE_732_F_02
    ...    mo_to_add=ADD_MOS_732_F_02    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_732_F_02
    ...    list_to_add=LIST_TO_ADD_732_F_02
    KW.Adjust PA before attach
    KW.One_UE_L3Call_With_Traffic_And_CPIFlog    cpif_logname=CPIF_732_F02_MG.pcap
    KW.Adjust PA_F02_rrcRelease
    KW.Adjust PA_F02_rrcReestab
    KW.Check_Throughput
    UE.One_UE_Stop_traffic_and_Detach
    KW.Check MG enable    filename=CPIF_732_F02_MG.pcap
    Wait Until Keyword Succeeds    15min    1min    KW.Check_rrcReestab_Counter

####Case Level Keywords#####
KW.One_UE_L3Call_With_Traffic_And_CPIFlog
    [Arguments]   ${attach_mode}=5G_SA   ${dl_throughput}=10Mbits/sec   ${ul_throughput}=100Mbits/sec   ${dl_duration}=1800
    ...    ${ul_duration}=1800    ${cell_index}=${0}    ${dltarget_throughput}=5     ${ultarget_throughput}=10
    ...    ${direction}=bi    ${check_tput}=${True}   ${cpif_logname}=UE_attach.pcap
    [Teardown]      Run Keyword And Ignore Error    KW.Stop Collect CPIF and Download    log_filename=${cpif_logname}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...   detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...   power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Run Keyword And Ignore Error    power_ue.UE Detach     ue_type=${UE_TYPE}
    ...   power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    KW.Start Collect CPIF   log_filename=${cpif_logname}
    power_ue.UE Attach     ue_type=${UE_TYPE}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    ...    attach_mode=${attach_mode}
    Run keyword if    '${direction}' == 'bi'    run keywords
    ...    power_ue.Start traffic    ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}     duration=${dl_duration}
    ...    AND    power_ue.Start traffic    ue_type=${UE_TYPE}   direction=ul   throughput=${ul_throughput}  duration=${ul_duration}
    ...    ELSE IF    '${direction}' == 'ul'
    ...    power_ue.Start traffic    ue_type=${UE_TYPE}   direction=ul   throughput=${ul_throughput}  duration=${ul_duration}
    ...    ELSE IF    '${direction}' == 'dl'
    ...    power_ue.Start traffic    ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}     duration=${dl_duration}
    Run keyword if     '${check_tput}' == '${True}'    KW.Check_Throughput    cell_index=${cell_index}
    ...    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
    ...    dltarget_throughput=${dltarget_throughput}   ultarget_throughput=${ultarget_throughput}


KW.Check_Throughput
    [Arguments]   ${dl_throughput}=5Mbits/sec   ${ul_throughput}=100Mbits/sec
    ...    ${ul_duration}=1800    ${cell_index}=${0}    ${dltarget_throughput}=5     ${ultarget_throughput}=10
    ${tput_log}    power_ue.Collect Tput   ue_type=${UE_TYPE}
    ${target_cell_id}    KW.Get NR Cell Indentities
    ${list_of_cell_ids}    Create list    ${target_cell_id}
    ...     dltarget_throughput=${dltarget_throughput}   ultarget_throughput=${ultarget_throughput}
    ${ul}    ${dl}   Power_ue.Check Bi Tput   ue_type=${UE_TYPE}   cells=${list_of_cell_ids}    log=${tput_log}
    ...     dltarget_throughput=${dltarget_throughput}   ultarget_throughput=${ultarget_throughput}


KW.Get NR Cell Indentities
#    [Arguments]   ${cell_index}=${0}
    ${CellIndexs}   Create List    1
    ${nrCellIdentity_list}   gNB.GetCellIDbyIndex    cell_index_list=${CellIndexs}
#    Connect to gnb coam via ssl    connection=GNB_OAM
#    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
#    COAM Teardown gnb connections   connection=GNB_OAM
#    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
#    ${nrCellIdentity_list}    Create List
#    FOR    ${item}    IN     @{cell_id_list}
#        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
#        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
#    END
#    [Return]    ${nrCellIdentity_list}[${cell_index}]
    [Return]    ${nrCellIdentity_list}

KW.Adjust PA to default
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU_PA_Ports}
    ...    value=${CASE_INPUT_5GC000732['5GC000732']['PA_Value_default']}   attenuator=${PA_INFO}
    ...    logging_message=Setting PA values for RU to default value 0.


KW.PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}   ${logging_message}=Adjusting PA values
    log to console    ${logging_message}
    PA_.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA_.set_attenuation     port=${ports[${i}]}    value=${value}
        PA_.read_attenuation    port=${ports[${i}]}
    END


KW.Adjust PA_A03_rrcRelease
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU_PA_Ports}
    ...    value=${CASE_INPUT_5GC000732['5GC000732_A_03']['PA_Value_2']}   attenuator=${PA_INFO}
    ...    logging_message=Setting PA values for RU to let rrcRlease enable.

KW.Adjust PA before attach
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU_PA_Ports}
    ...    value=${CASE_INPUT_5GC000732['5GC000732_F_02']['PA_Value_3']}    attenuator=${PA_INFO}
    ...    logging_message=Setting PA values for RU to default value to let MG enable.

KW.Adjust PA_F02_rrcRelease
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU_PA_Ports}
    ...    value=${CASE_INPUT_5GC000732['5GC000732_F_02']['PA_Value_2']}   attenuator=${PA_INFO}
    ...    logging_message=Setting PA values for RU to let rrcRelease enable.

KW.Adjust PA_F02_rrcReestab
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU_PA_Ports}
    ...    value=${CASE_INPUT_5GC000732['5GC000732_F_02']['PA_Value_1']}   attenuator=${PA_INFO}
    ...    logging_message=Setting PA values for RU to let rrcReestab enable.

KW.Check_rrcReestab_Counter
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55124C00505
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55124C00512
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55124C00516
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55127C00503
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55127C00512
    COAM_WebEM.Logout

COAM_Admin.CheckBTSConterWithTraget
    [Arguments]    ${counter_id}    ${target_value}=0
    ${date}   Get Current Date   exclude_millis=True
    ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    should be true    ${values[-1]}>${target_value}

Setup Suite
    TestSuite.Start
    Create Log Directories
    set suite variable    ${OAM_TYPE}    COAM
    Import Variables        ${CURDIR}/CaseSCFDelta.py
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${DeltaPath}                ${CURDIR}/CaseSCFDelta.py
    ${outputfile}    gNB.GenerateTestLineSCFs
    set suite variable    ${Original_CFGFILE}    ${outputfile}
#    PA.AdjustAttenuationValueByGroups
    Conn.ResetCache
    set suite variable     ${5GRU_PA_Ports}       ${CASE_INPUT_5GC000732['5GC000732']['5GRU_PA_Ports']}



Teardown Suite
    TestSuite.Stop
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU_PA_Ports}
    ...    value=${CASE_INPUT_5GC000732['5GC000732']['PA_Value_default']}   attenuator=${PA_INFO}
    ...    logging_message=Set back PA values for RU.



Setup case
    TestCase.Start
    log to console     Case Start

Teardown case
#    log     ${TEST STATUS}
#    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.CollectSnapshot
#    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    run keyword and ignore error  UE.One_UE_Stop_traffic_and_Detach
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
#    Run Keyword And Ignore Error    force_close_coam_webdriver
    run keyword and ignore error    gNB.Connect
    run keyword and ignore error
    ...  ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2
    ...                     connection=${ALIAS_ASIK}
    run keyword and ignore error    gNB.Disconnect
    Conn.ResetCache
    TestCase.Stop


KW.ModifyAndCommissionAndCheckOnair
    [Documentation]    1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
    ...               ${modified_cfgfile}
    ...               ${parameters_to_modify}='NULL'
    ...               ${parameters_to_delete}='NULL'
    ...               ${mo_to_add}='NULL'
    ...               ${list_parameter_to_modify}='NULL'
    ...               ${list_to_add}='NULL'
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.GenerateCaseSCF    InputFile=${original_cfgfile}
    ...                    OutputFile=${modified_cfgfile}
    ...                    ResourceFolder=${CURDIR}
    ...                    ParamterToModify=${parameters_to_modify}
    ...                    ParameterToDelete=${parameters_to_delete}
    ...                    MOsToAdd=${mo_to_add}
    ...                    ListParamterToModify=${list_parameter_to_modify}
    ...                    ListToAdd=${list_to_add}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}     model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

KW.Start Collect CPIF
    [Arguments]   ${log_filename}
    conn.connect   ${ALIAS_ASIK}
    run keyword and continue on failure    Wireshark.StartCaptureLogFromContainer   nodename=CPIF    filename=${log_filename}
    ...    log_dir=/ffs/run/logs
    conn.disconnect   ${ALIAS_ASIK}

KW.Stop Collect CPIF and Download
    [Arguments]   ${log_filename}
    conn.connect   ${ALIAS_ASIK}
    run keyword and continue on failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    run keyword and continue on failure    Wireshark.DownloadLogToUTE   filename=${log_filename}    log_dir=/ffs/run/logs
    conn.disconnect   ${ALIAS_ASIK}

KW.Check MG enable
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc && f1ap.procedureCode == 12
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression= nr-rrc.gapUE == 1