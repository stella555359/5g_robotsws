*** Settings ***
Suite Setup    Setup BTS env and set keyword prority
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      Flora Du
...   contact:     Flora.du@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     XXXXXXXX

Force Tags    release-SBTS23R3    testline-7_5_UTE5G402T2458    UE_TYPE-Spark_X65_8UE

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot
Variables     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Template/multi_spark/resource/Spark_8UEs.py

*** Variables ***


${EMIL_FLAG}    False

*** Test Cases ***
MultiUEs attach and check tput
    set test variable    ${UECFG}   ${TLCommonConfig["MultiUECFG"]}
    set test variable    ${ue_type}    huawei_sigspark
    FOR    ${ue}    IN    @{UECFG['ue_index_for_call']}
        log to console      Set variable according to TLCommonConfig
        ${detach_request}  set variable    ${UECFG['${ue}']["detach_request"]}
        ${power_reset}     set variable    ${UECFG['${ue}']["power_reset"]}
        ${ue_mode}         set variable    ${UECFG['${ue}']["ue_mode"]}
        ${apn}             set variable    ${UECFG['${ue}']['apn']}
        ${ul_tp}           set variable    ${UECFG['${ue}']['ul']['target_throughput']}
        ${ul_dur}          set variable    ${UECFG['${ue}']['ul']['duration']}
        ${dl_tp}           set variable    ${UECFG['${ue}']['dl']['target_throughput']}
        ${dl_dur}          set variable    ${UECFG['${ue}']['dl']['duration']}
        ${tg_percent}      set variable    ${UECFG['${ue}']['target_percent']}
        ${attach_mode}     set variable    ${UECFG['${ue}']["attach_mode"]}
        ${apn_address}     set variable    ${UECFG['${ue}']["apn_address"]}
        ${dt_name}         set variable    ${UECFG['${ue}']["dt_name"]}
        log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_${ue}_prepare
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue}    get_spark_license=False
        sleep    3s
        log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_${ue}_attach
        spark ue attach by power off and power on    ue_alias=UE_${ue}
        sleep    3s
        log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_${ue}_send_traffic
        power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${dl_dur}
        ...                        ue_index=${ue}    ue_mode=${ue_mode}    apn_address=${apn_address}    dt_name=${dt_name}
        power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${ul_dur}
        ...                        ue_index=${ue}    ue_mode=${ue_mode}    apn_address=${apn_address}    dt_name=${dt_name}
        sleep    5s
        log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_traffic_check_on_UEside
        Check Tput for one UE     ue=${ue}
        #Check throughput on gNB    direction=ul    throughput=${ul_tp}    ue_index=${ue}
        #Check throughput on gNB    direction=dl    throughput=${dl_tp}    ue_index=${ue}
    END
    [Teardown]    Run Keyword And Ignore Error   All UEs Stop traffic and detach UE


*** Keywords ***
spark ue attach by power off and power on
    [Arguments]    ${ue_alias}
    spark.power_off    ue_alias=${ue_alias}
    sleep    2s
    spark.power_off    ue_alias=${ue_alias}
    sleep    2s
    spark.power_on    ue_alias=${ue_alias}
    sleep    2s
    spark.power_on    ue_alias=${ue_alias}
    sleep    2s

Check throughput on gNB
    [Arguments]    ${direction}    ${throughput}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}
    ...    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${8}    ${cellid}=${EMPTY}    ${log_type}=Aasyslog    &{kwargs}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2Lo   log_name=data_${direction}.txt
    ${Tput_cell}    run keyword if    '${direction}' == 'dl'    Caculate DL throughput on gnb L2Lo with re
    ...                                                                                       dl_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    ...    ELSE IF    '${direction}' == 'ul'    Caculate UL throughput on gnb L2Lo with re    ul_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    [Return]    ${Tput_cell}
    [Teardown]    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

Check Tput for one UE
    [Arguments]     ${ue}    ${ue_type}=huawei_sigspark    ${Expected_Throughput_DL}=5    ${Expected_Throughput_UL}=1
    [Documentation]    check_tput
    ...                :param  n: The ue_index of Dingli
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expected_Throughput_DL}
    ...                                                          ue_index=${ue}
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${Expected_Throughput_UL}
    ...                                                          ue_index=${ue}

All UEs Stop traffic and detach UE
    [Arguments]    ${ue_type}=huawei_sigspark 
    [Documentation]    stop_DLUL_traffic
    log to console      "Stop all UE traffic and detach"
    FOR    ${ue}    IN    @{UECFG['ue_index_for_call']}
        ${ue_mode}         set variable    ${UECFG['${ue}']["ue_mode"]}
        ${apn_address}     set variable    ${UECFG['${ue}']["apn_address"]}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        sleep    1s
        power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue}   power_reset=Flase
        sleep    2s
    END
