*** Settings ***
Documentation    author:Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC002479
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
#Library           ReadJason.py
Library           ../../5GC000638/Resources/coam_close.py
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py

Library           OperatingSystem
Library           DateTime
Library           ute_wtssim
Library           ute_syslog
Library           ute_admin
Library           urllib
Library           Collections
Library           Process
Library           String
Library           Telnet
#Library           SeleniumLibrary
#Variables         /home/ute/TAF/cfgfile/2479_Loop_times.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                    ${tl.ues[1].imsi}
${link_to_Artifact}       https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
${YAFT_PATH}              /opt/ute/YAFT
${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/

${PROGRAM}                  ${None}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}


${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${PB_PORT}                  5000

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${MRBTS_ID}                 MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                 NRBTS-${tl.gnbs[0].global_bts_id}

${4G_WEBUI_IP}              ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${5G_WEBUI_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${BTSMOD}                   5GOnly
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
TC.CB005752_5G_B_14_Call setup KPI checking in two cells
    [Arguments]  ${retry_times}=10
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    ${attach_successful}     ${attach_failed}    L3 Call with traffic    retry_times=10  traffic_time=250  duration=400
     ...    dl_throughput=10MKbits/sec   ul_throughput=5MKbits/sec
    ${attach success rate}  Evaluate   round(100*${attach_successful}/(${attach_successful}+${attach_failed}),2)
    Log To Console   L3 CaLL has been setup for ${retry_times} times and attach success rate is ${attach success rate}%
    Should Be True   ${attach success rate} >=90
    [Return]   ${attach success rate}

TC.CB005752_5G_B_12_Single UE tput testing with beamforming enabled
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    MultiUE.L3Call for 5752   UECFG=${TLCommonConfig['MultiUECFG']}

MultiUE.L3Call for 5752
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    ...    ${power_reset}=false    ${ue_mode}=SA    ${apn}=wap1nokiacom    ${iperf_port}=default
    ...    ${multidrb_QoS_dest}=null   ${check_tput_on_ue}=false    ${target_avg_percent}=0.8
    ...    ${target_min_percent}=0.5    ${check_throughput_duration}=120    ${call_loop}=1
    ...    ${cell_index_list}=1    ${dl_target_throughput}=5    ${ul_target_throughput}=5
    ...    ${ue_index}=0    ${detach_request}=true    ${protocol}=udp
    ${UECFG}=    run keyword if     "${UECFG}"=="NULL"   MultiUE._L3CallBuildParameters
    ...    power_reset=${power_reset}    ue_mode=${ue_mode}    apn=${apn}    iperf_port=${iperf_port}
    ...    multidrb_QoS_dest=${multidrb_QoS_dest}   check_tput_on_ue=${check_tput_on_ue}    target_avg_percent=${target_avg_percent}
    ...    target_min_percent=${target_min_percent}    check_throughput_duration=${check_throughput_duration}    call_loop=${call_loop}
    ...    cell_index_list=${cell_index_list}    dl_target_throughput=${dl_target_throughput}    ul_target_throughput=${ul_target_throughput}
    ...    ue_index=${ue_index}    detach_request=${detach_request}    protocol=${protocol}
    ...    ELSE    set variable    ${UECFG}
    set suite variable    ${UECFG}    ${UECFG}
    ${maxloop}    MultiUE._GetUECallMaxLoop    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    log     ${default_ue_index}
    FOR  ${i}    IN RANGE    ${maxloop}
#        run keyword and ignore error           MultiUE.ClearUEInfoFromAMF   UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}
#        Run Keyword And Continue On Failure    Change Network Mode    UECFG=${UECFG}
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5
        Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        #MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        log     ttt${default_ue_index}
    END
#    run keyword and ignore error     revert original Network Mode   UECFG=${UECFG}
    log     ${default_ue_index}
    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}


revert original Network Mode
    [Arguments]    ${UECFG}=NULL
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    ue_mode=${original ue_1_mode}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    ue_mode=${original ue_2_mode}
    Change Network Mode    UECFG=${UECFG}

Change Network Mode
    [Arguments]    ${UECFG}=NULL
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        ${UE_mode}   Set Variable      ${TLCommonConfig["MultiUECFG"]['${ue_index}']["ue_mode"]}
        Run Keyword If   '${UE_mode}'=='5G_NSA'    Run Keywords
        ...               spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+GTSET="5GSACTR",0    AND
        ...               Sleep    5s     AND
        ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=10    AND
        ...               Sleep    5s     AND
        ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=17    AND
        ...               Sleep    5s
        Run Keyword If   '${UE_mode}'=='SA'    Run Keywords
        ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",1    AND
        ...               Sleep    5s     AND
        ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=10    AND
        ...               Sleep    5s     AND
        ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=14    AND
        ...               Sleep    5s
    END


L3 Call with traffic
    [Arguments]    ${traffic_time}=20  ${duration}=300   ${dl_throughput}=10MKbits/sec   ${ul_throughput}=5MKbits/sec   ${retry_times}=3
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    First UE start to attach
        ${result2}    run keyword and return status     one_ue_start_L3CALL   ue_index=${1}   ue_type=${UE_TYPE}
        ...   dl_throughput=${dl_throughput}   ul_throughput=${ul_throughput}   traffic_time=${traffic_time}  duration=${duration}
        log to console   Second UE start to attach
        ${result3}    run keyword and return status     one_ue_start_L3CALL   ue_index=${0}   ue_type=${UE_TYPE}
        ...   dl_throughput=${dl_throughput}   ul_throughput=${ul_throughput}   traffic_time=${traffic_time}  duration=${duration}
        run keyword and ignore error      collect attach result   result2=${result2}   result3=${result3}
        log to console      L3 call has been completed for ${i+1} times
    END
    [Return]    ${attach_successful}   ${attach_failed}


collect attach result
   [Arguments]   ${result2}   ${result3}
    run keyword if    '${result2}'=='True' and '${result3}'=='True'    Evaluate attach_successful_num
    ...    ELSE IF    '${result2}'!='True' or '${result3}'!='True'    Evaluate attach_failed_num
    [Return]    ${attach_successful}   ${attach_failed}

Evaluate attach_successful_num
     ${result}   Set Variable   ${0}
     ${result}   Evaluate   ${attach_successful}+1
     Set test Variable    ${attach_successful}    ${result}

Evaluate attach_failed_num
     ${result1}   Set Variable   ${0}
     ${result1}   Evaluate   ${attach_failed}+1
     Set test Variable    ${attach_failed}    ${result1}


one_ue_start_L3CALL
     [Arguments]    ${ue_index}=${0}   ${ue_type}=${UE_TYPE}   ${traffic_time}=20  ${duration}=300    ${peak_TP}=0  ${power_reset}=True
      ...     ${dl_throughput}=10MKbits/sec   ${ul_throughput}=5MKbits/sec
     power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}  reset_sol=${True}
     Run Keyword And Ignore Error    spark.power off    ue_alias=UE_${ue_index} 
     sleep    3s
     Run Keyword And Ignore Error    spark.power on    ue_alias=UE_${ue_index}
     ${result}    run keyword and return status    GetAttachvalue    ue_type=${UE_TYPE}  ue_index=${ue_index}
     should be true    '${result}'=='True'
     log to console  traffic started ...
     Run Keyword And Continue On Failure  single_ue.start traffic    ue_type=${UE_TYPE}  ue_index=${ue_index}   duration=${duration}
      ...    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
     sleep    ${traffic_time}s
     log to console    UE traffic completed ...
     Run Keyword And Continue On Failure   single_ue.check traffic   ue_index=${ue_index}   ue_type=${UE_TYPE}
      ...       peak_TP=${peak_TP}
      log to console    start to stop traffic and detach UE ...
     Run Keyword And Ignore error   power_ue.Stop traffic   ue_type=${ue_type}     direction=dl      ue_index=${ue_index}
      ...            apn_address=DXDATA2    ue_mode=NSA
     sleep  20s
     Run Keyword And Ignore error  power_ue.Stop traffic    ue_type=${ue_type}     direction=ul       ue_index=${ue_index}
      ...             apn_address=DXDATA2    ue_mode=NSA
     sleep  20s
     Run Keyword And Ignore error    power_ue.UE Detach     ue_type=${ue_type}     power_reset=True      ue_index=${ue_index}
     log to console    UE detach completed ...
     sleep  20s



single_ue.start traffic
    [Arguments]    ${ue_type}=${UE_TYPE}   ${ue_index}=${0}  ${duration}=10  ${dl_throughput}=10MKbits/sec  ${ul_throughput}=5MKbits/sec
    log to console  DL traffic started ...
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}   duration=${duration}
     ...  ue_mode=NSA   direction=dl     throughput=${dl_throughput}  apn_address=DXDATA2
    log to console  UL traffic started ...
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}   duration=${duration}
     ...  ue_mode=NSA   direction=ul     throughput=${ul_throughput}   apn_address=DXDATA2


single_ue.check traffic
    [Arguments]    ${peak_TP}=0  ${ue_index}=${0}   ${ue_type}=${UE_TYPE}
    run keyword if    "${peak_TP}" == "0"    single_ue.check throughput   ue_type=${UE_TYPE}  ue_index=${ue_index}
    ...    ELSE IF    "${peak_TP}" == "1"    single_ue.check throughput   ue_type=${UE_TYPE}  ue_index=${ue_index}  check_dl_TP=600  check_ul_TP=40

single_ue.check throughput
    [Arguments]    ${ue_index}=${0}   ${ue_type}=${UE_TYPE}  ${check_dl_TP}=5  ${check_ul_TP}=2
    power_ue.Check throughput    ue_type=${UE_TYPE}  ue_index=${ue_index}   throughput=${check_dl_TP}   start_offset=${0}   direction=dl
    power_ue.Check throughput    ue_type=${UE_TYPE}  ue_index=${ue_index}   throughput=${check_ul_TP}   start_offset=${0}  direction=ul

GetAttachvalue
    [Arguments]   ${ue_type}=${UE_TYPE}    ${ue_index}=${0}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}    power_reset=True
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${ue_index}   ue_type=${UE_TYPE}    power_reset=True  attach_mode=5G_NSA
    sleep    1s
    ${Rach_status}    run keyword and return status    power_ue.Verify attach    ue_index=${ue_index}
    ...    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    should be true    '${Rach_status}'=='True'




Setup case for two CELL L3 call
    #run keyword and ignore error    Start BTSlogs Collection
    Set test Variable    ${attach success rate}   ${0}
    Set test Variable    ${attach_successful}    ${0}
    Set test Variable    ${attach_failed}        ${0}
    Set test Variable    ${original ue_1_mode}   ${TLCommonConfig["MultiUECFG"]["0"]["ue_mode"]}
    Set test Variable    ${original ue_2_mode}   ${TLCommonConfig["MultiUECFG"]["1"]["ue_mode"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    ue_mode=${CASE_INPUT_CB005752["0"]["ue_mode"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}        apn=${CASE_INPUT_CB005752["0"]["apn"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]["dl"]}         target_throughput=${CASE_INPUT_CB005752["0"]["dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]["ul"]}         target_throughput=${CASE_INPUT_CB005752["0"]["ul"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    ue_mode=${CASE_INPUT_CB005752["0"]["ue_mode"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}        apn=${CASE_INPUT_CB005752["0"]["apn"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]["dl"]}         target_throughput=${CASE_INPUT_CB005752["0"]["dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]["ul"]}         target_throughput=${CASE_INPUT_CB005752["0"]["ul"]}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    TestCase.Start


Teardown case for two CELL L3 call
    #Run Keyword And Ignore Error    Collect snapshot via webui
    #Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    run    command=killall firefox
    Run Keyword And Ignore Error    coam_close.force_close_coam_webdriver
    Conn.ResetCache


suite setup for 5752
    TestSuite.Start
    gNB.GenerateTestLineSCFs
    run    command=cp ${CFGFILE_PATH}/TL1109_golden.xml ${LOG_PATH}/TestLineSCF2Cell.xml
    gNB.GenerateCaseSCF   InputFile=${LOG_PATH}/TestLineSCF2Cell.xml   OutputFile=${LOG_PATH}/CaseSCF.xml   ResourceFolder=${CURDIR}
    ...   ParamterToModify=PARAMS_TO_MODIFY_5752_B_12    ParameterToDelete=PARAMS_TO_DELETE_5752_B_12
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    gNB.CommissionWithRetry   scf_file=${LOG_PATH}/CaseSCF.xml    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
     ...    RUmodel=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}


