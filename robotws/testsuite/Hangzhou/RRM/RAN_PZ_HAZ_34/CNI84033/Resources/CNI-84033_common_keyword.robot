*** Settings ***
Documentation     author: Cai Wenjuan
...               contact: wenjuan.cai@nokia-sbell.com
...               this feature need to verify TDD SA, TDD NSA, FDD SA, FDD NSA
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
Library           taf.ue.rpc.mtk    WITH NAME	rpc_mtk
Library           taf.ul.messaging.mtk      WITH NAME    mtk_msg

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                    ${tl.ues[1].imsi}
#${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
#${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}


${Original_CFGFILE}         ${LOG_PATH}/TestLineSCF1Cell_Both.xml

${UE_alias}                 UE_0

${TLDelta_PATH}              ${CFGFILE_PATH}
${initial_S1_SCF}            ${LOG_PATH}/TestLineSCF1Cell_Both.xml

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}


####ipsl###
${IPSL_CONFIG_CPC}           C:/Tools/2037_ipsl
${IPSL_TOOL_DIR}             c:/IpslTools
${IPSL_COMPILER_FLAGS}       /pDIA05IGX /its /b

${IPSL_IP}                  ${tl.ues[0].ssh_connection_details.addr}
${IPSL_USERNAME}            ${tl.ues[0].ssh_connection_details.username}
${IPSL_PASSWORD}            ${tl.ues[0].ssh_connection_details.password}
##################define these variable for convenient############################
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
${ALIAS_UTE}                ute
${ALIAS_REAL_EPC_SERVER}    Real_EPC
${ALIAS_LONER}              LONER
${ALIAS_ASP_1A}             ASP_1A
${ALIAS_5GC}                5gc
${ALIAS_ENBCTLPC}           ENB_PC
${ALIAS_SHP}                SHP
########################END of alias Define#######################################

*** Keywords ***
###################################Case Level  Keywords###########################
TC.Scheduling_of_5G_UEs_with_multiple_non-GBR_bearers_for_SA_mode
    [Documentation]  Main test Steps:
    ...   1) actNonGbrServiceDiff = false
    ...      actFdmScheduling = true
    ...      maxNumPdschAllocationPerSlot = 2
    ...      schedulWeight = 1 for 5qi 6
    ...      schedulWeight = 3 for 5qi 7
    ...   2) wait untill cell on air
    ...   3) SA L3 call and DL data with Huawei SigSpark for UE1 and UE2
    ...   4) Verifiy throughput, DL scheduling of UE1-5QI 6 and UE2-5QI 7 will be 1:1
    ...   5) change actNonGbrServiceDiff = true
    ...   6) detach attach UE2 and DL data again
    ...   7) Verify throughput, DL scheduling of UE1-5QI 6 and UE2-5QI 7 will be 1:3
    gNB.GenerateCaseSCF   InputFile=${LOG_PATH}/TestLineSCF.xml   OutputFile=${LOG_PATH}/CNI_84033_Case1_SCF.xml
    ...    ResourceFolder=${CURDIR}
    ...    ParamterToModify=PARAMS_TO_MODIFY_CNI_84033_Case1
    ...    ParameterToDelete=PARAMS_TO_DELETE_CNI_84033_Case1
    ...    ListToAdd=PARAMS_TO_ADD_CNI_84033_Case1
    COAM_Admin.commission    scf_file=${LOG_PATH}/CNI_84033_Case1_SCF.xml
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    Set To Dictionary      ${TLCommonConfig["MultiUECFG"]}     ue_index_for_call=${CNI84033_TDD_UE["ue_index_for_call"]}
    log    ${TLCommonConfig["MultiUECFG"]["ue_index_for_call"]}
    MultiUE.L3CallWithoutDetach   UECFG=${TLCommonConfig['MultiUECFG']}
    COAM_WebEM.Login
    log to console    Change actNonGbrServiceDiff to ture
    COAM_WebEM.ModifyAndActiveParameters  DistName=${MRBTS_ID}/${NRBTS_ID}
    ...      FilterParam=Activate non-GBR service differentiation     NewValue=true
    COAM_WebEM.Logout
    COAM_WebEM.VerifyAllCellsAreOnline   cell_idx =1
    log to console    UE2 De-register
    Run Keyword And Ignore Error    spark.power off    ue_alias=UE_${TLCommonConfig['MultiUECFG']["ue_index_for_call"][1]}
    sleep    3s
    Run Keyword And Ignore Error    spark.power on    ue_alias=UE_${TLCommonConfig['MultiUECFG']["ue_index_for_call"][1]}
    Change traffic checking value
    log to console    ul dl  traffic start in UE1 and UE2...
    Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${TLCommonConfig['MultiUECFG']}
    sleep    5s
    Run Keyword And Continue On Failure    MultiUE.CheckDLThoughput     UECFG=${TLCommonConfig['MultiUECFG']}
    Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${TLCommonConfig['MultiUECFG']}
    Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${TLCommonConfig['MultiUECFG']}
    sleep    5s
    Run Keyword And Continue On Failure    MultiUE.CheckULThoughput     UECFG=${TLCommonConfig['MultiUECFG']}
    Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${TLCommonConfig['MultiUECFG']}
    Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${TLCommonConfig['MultiUECFG']}
    log to console    recover locked cell to unlocked
    Run Keyword And Ignore Error   Online Modify Parameters Locked cell to Unlocked   NRCELL-id=NRCELL-1

TC.Scheduling_of_5G_UEs_with_multiple_non-GBR_bearers_for_NSA_mode
    [Documentation]    Main test Steps:
    ...   1) actMultiDrbNSA = true
    ...      actNonGbrServiceDiff = true
    ...      schedulWeight of qci 7 70 128 = 2 : 4 : 1
    ...      no dedicated NRDBR_QCI for qci 128, so qci 128 will use default profile NRDBR-1
    ...   2) prepare IPSL server
    ...   3) attach NSA UE1 with qci 7 70 128 and start DL traffic
    ...   4) check DL traffic, DL scheduling of qci 7 70 128 corresponds to 2 : 4 : 1  (it's cannot be checked in spark, so skip)
    ...   5) modify scheduling weight of qci 7 70 128 = 1 : 3 : 3
    ...   6) attach UE2 and establish with qci 7 70 128 and start UL/DL traffic
    ...   7) DL scheduling of UE1 and UE2 corresponds to 2 : 4 : 1 : 1 : 3 : 3
    ...   8) UL scheduling of UE1 to UE2 is (2 + 4 + 1) ：(1 + 3 + 3) = 7 : 7
    gNB.GenerateCaseSCF   InputFile=${LOG_PATH}/TestLineSCF.xml   OutputFile=${LOG_PATH}/CNI_84033_Case2_SCF.xml
    ...    ResourceFolder=${CURDIR}
    ...    ParamterToModify=PARAMS_TO_MODIFY_CNI_84033_Case2
    ...    ParameterToDelete=PARAMS_TO_DELETE_CNI_84033_Case2
    ...    ListToAdd=PARAMS_TO_ADD_CNI_84033_Case2
    COAM_Admin.commission    scf_file=${LOG_PATH}/CNI_84033_Case2_SCF.xml
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Run Keyword And Continue On Failure    COAM_WebEM.CheckX2StatusUntilReady
    Run Keyword And Continue On Failure    IPSL server preparation without replace files    ipsl_config_dir=${IPSL_CONFIG_CPC}
    log to console  UE1 UE2 attach ...
    Change NSA Call None GBR UE Parameter
#    Set To Dictionary      ${TLCommonConfig["MultiUECFG"]}      ue_index_for_call=${CNI84033_FDD_UE["ue_index_for_call"]}
    log    ${TLCommonConfig["MultiUECFG"]["ue_index_for_call"]}
    MultiUE.L3CallWithoutDetach   UECFG=${TLCommonConfig['MultiUECFG']}
    log to console  modify qci scheduling weight...
    Change QCI Scheduling Weight and Enable QCI 128
    log to console  UE4 attach and UE3 UE4 start traffic...
    Change Check Value After UE2 detach Attach
    log to console  UE4 detach attach...
    Run Keyword And Ignore Error    spark.power off    ue_alias=UE_${TLCommonConfig['MultiUECFG']["ue_index_for_call"][1]}
    sleep    10s
    Run Keyword And Ignore Error    spark.power on    ue_alias=UE_${TLCommonConfig['MultiUECFG']["ue_index_for_call"][1]}
    Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}
    sleep    5s
    Run Keyword And Continue On Failure    MultiUE.CheckDLThoughput     UECFG=${UECFG}
    Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}
    Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}
    sleep    5s
    Run Keyword And Continue On Failure    MultiUE.CheckULThoughput     UECFG=${UECFG}
    Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}
    Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}


TC.Scheduling_of_5G_UEs_with_GBR_bearers
    [Documentation]
    ...    Main test Steps:
    ...   1) actNonVoNRGbrService  = true
    ...      5QI-1 discardTimer = 100ms
    ...      5QI-2 discardTimer = 150ms
    ...      core network provided 5QI-1 GBR-QosInformation:guaranteedFlowBitRateUL/DL = 50 Kbps
    ...      core network provided 5QI-2 GBR-QosInformation:guaranteedFlowBitRateUL/DL = 20 Mbps
    ...      core netword provided 5QI-2 call 51225 port
    ...   2) UE1 attach with non-GBR traffic with full buffer data, eg: dl 600M qic6
    ...   3) UE2 attach with 5QI-1 voice bearer and 5QI-2 video bearer
    ...   4) 5QI-1 voice call setup ok checked by ng pcap PDUsessionresourcemodifyrequest message
    ...   5) 5QI-1 ims call with AT command and traffic will above 3K
    ...   6) traffic in 5QI-2 video call will no packets discarded. eg: dl 15M, check result will 15M
    ...   7) when traffic exceed GFBR data of 5QI-2, the packets will at least 20M but will not exceed 30M
    gNB.GenerateCaseSCF   InputFile=${LOG_PATH}/TestLineSCF.xml   OutputFile=${LOG_PATH}/CNI_84033_Case3_SCF.xml
    ...    ResourceFolder=${CURDIR}
    ...    ParamterToModify=PARAMS_TO_MODIFY_CNI_84033_Case3
    ...    ParameterToDelete=PARAMS_TO_DELETE_CNI_84033_Case3
    ...    ListToAdd=PARAMS_TO_ADD_CNI_84033_Case3
    COAM_Admin.commission    scf_file=${LOG_PATH}/CNI_84033_Case3_SCF.xml
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    log to console  UE1 None-GBRs brearer UE2 GBRs brearer attach ...
    Change UE1 UE2 GRB Call check Value
    MultiUE.L3CallWithoutDetach   UECFG=${TLCommonConfig['MultiUECFG']}
    log to console  make VONR call on UE2...
    Change UE2 VONR traffic value
    Make VONR L3 call   ue_index=${TLCommonConfig['MultiUECFG']['ue_index_for_call'][1]}
    log to console  change UE2 QCI-2 traffic value to exceed GFBR...
    Change UE2 QCI-2 traffic value
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}

TC.SA_UE_context_preemption_at_Initial_Context_Setup
    [Documentation]
    ...    Main test Steps:
    ...   CB008698 enabled actUserPreemption
    ...   current number of SA UE contexts is above NRCELL.maxNumOfRrcSA
    ...   resources from NRCELL.numOfRadioResReservForTempUse are not fully used
    ...   counter PEAK_NUM_UE_CTX_TEMP_POOL is set to the current number of UE contexts
    ...   which used resources from numOfRadioResReservForTempUse pool or from numOfRadioResReservForTempUse and numOfRadioResReservForEmergency pools
    ...   if allowEmergencyReservForTempUse is set to true
    ...   Contention Based RA and RRC connection establishment.
    ...   Note that PUCCH resources are allocated at RRC connection setup phase from the NRCELL.numOfRadioResReservForTempUse pool
    ...   1) set maxNumOfUsersNRCell=1 and maxNumOfRrcSA =1 and fix related parameters on webem.
    ...      allowEmergencyReservForTempUse=false
    ...      numOfRadioResReservForTempUse=2
    ...      numOfRadioResReservForEmergency=0
    ...   2) start to capture NGAP wireshark packets
    ...   3) SA UE1 attach with prioritylevelARP = 7 which is preconfigured in core network
    ...   4) SA UE2 attach with prioritylevelARP = 5 which is preconfigured in core network
    ...   5) stop capturing wireshark aand check, UE should receive RR release message, and waitTime IE is
    ...      set with value NRBTS.timerRejectWait
    COAM_Admin.commission    scf_file=${CFGFILE_PATH}/SCF_SBTS00.xml
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Online Modify Parameters for precondition
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=preemption_ng.pcap
    sleep    5s
    Change Preemption UE Parameter
    MultiUE.L3Call   UECFG=${TLCommonConfig_FDD['MultiUECFG']}
    sleep    5s
    gNB.Connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=preemption_ng.pcap
    sleep    5s
    Wireshark.ReadLog    filename=preemption_ng.pcap    filter=ngap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=ngap.procedureCode == 42 && ngap.radioNetwork == 46
    log to console    recover locked cell to unlocked
    Run Keyword And Ignore Error   Online Modify Parameters Locked cell to Unlocked   NRCELL-id=NRCELL-2

MultiUE.CheckDLThoughput
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    log to console     start to check dl traffic ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        log to console     start to check UE_${ue_index}'s DL traffic ...
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        run keyword if    '${UECFG['${ue_index}']['dl']['target_throughput']}'=='0'
        ...    Continue For Loop
        Run Keyword And Continue On Failure    MultiUE._CheckUEThoughput
        ...    UECFG=${UECFG}
        ...    ue_index=${ue_index}
        ...    check_tput_on_ue=${UECFG['${ue_index}']['check_tput_on_ue']}
        ...    direction=dl
    END
    log to console     dl traffic check completed...

MultiUE.CheckULThoughput
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    log to console     start to check ul traffic ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        log to console     start to check UE_${ue_index}'s UL traffic ...
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        run keyword if    '${UECFG['${ue_index}']['ul']['target_throughput']}'=='0'
        ...    Continue For Loop
        Run Keyword And Continue On Failure    MultiUE._CheckUEThoughput
        ...    UECFG=${UECFG}
        ...    ue_index=${ue_index}
        ...    check_tput_on_ue=${UECFG['${ue_index}']['check_tput_on_ue']}
        ...    direction=ul
    END
    log to console     ul traffic check completed...

MultiUE._CheckUEThoughput
    [Arguments]    ${direction}  ${UECFG}=NULL   ${check_tput_on_ue}=false    ${ue_index}=0

    ${target_avg_percent}    Set Variable if    '${direction}' == 'dl'
        ...   ${UECFG['${ue_index}']['target_avg_percent_dl']}    ${UECFG['${ue_index}']['target_avg_percent_ul']}

    ${target_throughput}    Set Variable if    '${direction}' == 'dl'
    ...   ${UECFG['${ue_index}']['dl']['target_throughput']}     ${UECFG['${ue_index}']['ul']['target_throughput']}
    ${tput_log}    power_ue.Collect Tput
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}
    ...    duration=${UECFG['${ue_index}']['check_throughput_duration']}
    ...    ue_index=${ue_index}
    ...    ue_alias=UE_${ue_index}

    ${output}=   Power_ue.Check Tput
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    log=${tput_log}   direction=${direction}
    ...    cells=UE_${ue_index}
    ...    target_throughput=${target_throughput}
    ...    target_avg_percent=${target_avg_percent}
    ...    min_percent=${UECFG['${ue_index}']['target_min_percent']}
    ...    ue_index=${ue_index}

    ${result}=    Convert To String    ${output}
    Should Not Contain    ${result}    False

IPSL server preparation without replace files
    [Documentation]    start IPSL server and verify server status.
    [Arguments]    ${ipsl_config_dir}    ${ipsl_alias}=ipsl    ${ipsl_listen_port}=13868
    ...    ${ipsl_tool_dir}=${IPSL_TOOL_DIR}    ${ipsl_compiler_flags}=${IPSL_COMPILER_FLAGS}
    ...    ${ipsl_srv_ip}=${IPSL_IP}    ${ipsl_user}=${IPSL_USERNAME}    ${ipsl_pw}=${IPSL_PASSWORD}
    ...    ${wait_time_for_connection_setup}=5min

    connect to IPSL server    ipsl_srv_ip=${ipsl_srv_ip}    ipsl_user=${ipsl_user}    ipsl_pw=${ipsl_pw}    ipsl_alias=${ipsl_alias}
#    Stop IPSL server process first   ipsl_alias=${ipsl_alias}
#    compile files and start IPSL server    ipsl_config_dir=${ipsl_config_dir}    ipsl_tool_dir=${ipsl_tool_dir}
    wait until keyword succeeds  2min    3s    Verify IPSL server process is started    ipsl_alias=${ipsl_alias}
    wait until keyword succeeds   ${wait_time_for_connection_setup}    3s
    ...    Verify IPSL server status    ipsl_alias=${ipsl_alias}    ipsl_listen_port=${ipsl_listen_port}
#    Run Keyword if  ${result}!='PASS'     Stop IPSL server process first   ipsl_alias=${ipsl_alias}
#    ...    compile files and start IPSL server    ipsl_config_dir=${ipsl_config_dir}    ipsl_tool_dir=${ipsl_tool_dir}

Stop IPSL server process first
    [Documentation]
    ...    Stop IPSL server process
    [Arguments]    ${ipsl_alias}=ipsl
    ${is_ips_started}    ssh_common_commands.is_process_exist    process_name=ips32    connection=${ipsl_alias}    is_checking_on_windows=True
    return from keyword if    '${is_ips_started}'=='${False}'
    ssh.send_command    command=taskkill /IM ips32.exe /F /T    connection=${ipsl_alias}
    sleep   10s
    ssh.send_command    command=tasklist | findstr ips32.exe    connection=${ipsl_alias}
    ${result}    ssh.read_output    connection=${ipsl_alias}
    should be empty    ${result}

one_ue_start_L3CALL
     [Arguments]    ${UECFG}   ${ue_index}=0
      power_ue.Prepare UE
      ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
      ...    detach_request=${UECFG['${ue_index}']['detach_request']}
      ...    power_reset=${UECFG['${ue_index}']['power_reset']}
     Run Keyword And Ignore Error    spark.power off    ue_alias=UE_${ue_index}
     sleep    3s
     Run Keyword And Ignore Error    spark.power on    ue_alias=UE_${ue_index}
     log to console    dl  traffic started ...
     Run Keyword And Continue On Failure   power_ue.Start traffic
     ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
     ...    throughput=${UECFG['${ue_index}']['dl']['target_throughput']}Mbps/sec
     ...    duration=${UECFG['${ue_index}']['check_throughput_duration']}
     ...    apn_address=${UECFG['${ue_index}']['apn']}
     ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
     ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
     ...    multidrb_QoS_dest=${UECFG['${ue_index}']['multidrb_QoS_dest']}
     ...    iperf_type=${UECFG['${ue_index}']['iperf_type']}
     ...    protocol=${UECFG['${ue_index}']['protocol']}
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

MultiUE.L3CallWithoutDetach
    [Documentation]   Do call loop for multi ue. if no ${UECFG} defined, other parameters list is used
    ...    Otherwise, UEs and configuration in ${UECFG} is used.
    ...    And you can also use multiUE keyword seperately in your case.
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
        Run Keyword And Continue On Failure    MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}
        sleep    10s
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5
        Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5s
        Run Keyword And Continue On Failure    MultiUE.CheckDLThoughput     UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5s
        Run Keyword And Continue On Failure    MultiUE.CheckULThoughput     UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    END
    log     ${default_ue_index}
    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}

y

Change traffic checking value
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    target_avg_percent_dl=${SCHEDULING_ON["0"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    target_min_percent=${SCHEDULING_ON["0"]["target_min_percent"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    target_avg_percent_ul=${SCHEDULING_ON["0"]["target_avg_percent_ul"]}

    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    target_avg_percent_dl=${SCHEDULING_ON["1"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    target_min_percent=${SCHEDULING_ON["1"]["target_min_percent"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    target_avg_percent_ul=${SCHEDULING_ON["1"]["target_avg_percent_ul"]}

Change NSA Call None GBR UE Parameter
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}          ue_mode=NSA
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}     apn=${NSA_Before["0"]["apn"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}     target_avg_percent_dl=${NSA_Before["0"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}     target_avg_percent_ul=${NSA_Before["0"]["target_avg_percent_ul"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}     iperf_port=${NSA_Before["0"]["iperf_port"]}

    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}          ue_mode=NSA
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}     apn=${NSA_Before["1"]["apn"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}     target_avg_percent_dl=${NSA_Before["1"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}     target_avg_percent_ul=${NSA_Before["1"]["target_avg_percent_ul"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}     iperf_port=${NSA_Before["1"]["iperf_port"]}

Change Check Value After UE2 detach Attach
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}     target_avg_percent_dl=${NSA_After["0"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}     target_min_percent=${NSA_After["0"]["target_min_percent"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}     target_avg_percent_ul=${NSA_After["0"]["target_avg_percent_ul"]}

    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}     target_avg_percent_dl=${NSA_After["1"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}     target_min_percent=${NSA_After["1"]["target_min_percent"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}     target_avg_percent_ul=${NSA_After["1"]["target_avg_percent_ul"]}

Change QCI Scheduling Weight and Enable QCI 128
    [Documentation]   change qci 7 70 128 scheduling weight to 1 : 3 : 3
    ...    qci128 map to NRDRB-9 and it's scheduling weight already configured in the first step generate scf file
    COAM_WebEM.Login
    log to console    Change qci 7 70 128 scheduling weight to 1 : 3 : 3
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRDRB-2
    ...    abbr=Scheduling weight    value=1
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRDRB-8
    ...    abbr=Scheduling weight    value=3
    Wait Until Keyword Succeeds    3 times    30s
    ...   selenium_coam.set_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDRB_QCI-8
    ...   filter_param=List of QCI values   new_value=128
    ...   node_index=${0}
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout

Change UE1 UE2 GRB Call check Value
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    target_avg_percent_ul=${GBRTLCommonConfig["0"]["target_avg_percent_ul"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    target_avg_percent_dl=${GBRTLCommonConfig["0"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]["dl"]}    target_throughput=${GBRTLCommonConfig["0"]["dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]["ul"]}    target_throughput=${GBRTLCommonConfig["0"]["ul"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["0"]}    iperf_port=${GBRTLCommonConfig["0"]["iperf_port"]}

    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    target_avg_percent_ul=${GBRTLCommonConfig["1"]["target_avg_percent_ul"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    target_avg_percent_dl=${GBRTLCommonConfig["1"]["target_avg_percent_dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]["dl"]}    target_throughput=${GBRTLCommonConfig["1"]["dl"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]["ul"]}    target_throughput=${GBRTLCommonConfig["1"]["ul"]}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    iperf_port=${GBRTLCommonConfig["1"]["iperf_port"]}

Make VONR L3 call
   [Arguments]    ${ue_index}=0
   spark.send AT command CPE     param=ATD006688;     ue_alias=UE_${ue_index}
   ${Vonr_call_status}    Run Keyword And Continue On Failure   spark.get Vonr call status on ue
   ...      ue_alias=UE_${ue_index}   param={"LastEventIndex":0}
   run keyword if    '${Vonr_call_status}'=='True'  Run Keyword And Continue On Failure    MultiUE._CheckUEThoughput
   ...    UECFG=${TLCommonConfig['MultiUECFG']}
   ...    ue_index=${ue_index}
   ...    check_tput_on_ue=${TLCommonConfig['MultiUECFG']['${1}']['check_tput_on_ue']}
   ...    direction=dl
   ...    ELSE  Fail    VONR call failed
   spark.send AT command CPE     param=ATH     ue_alias=UE_${ue_index}


Change UE2 VONR traffic value
   Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]["dl"]}    target_throughput=${GBR_VONR_data["1"]["dl"]}
   Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    target_avg_percent_dl=${GBR_VONR_data["1"]["target_avg_percent_dl"]}

Change UE2 QCI-2 traffic value
   Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]["dl"]}    target_throughput=${GBR_exceed_GFBR_data["1"]["dl"]}
   Set To Dictionary    ${TLCommonConfig["MultiUECFG"]["1"]}    target_avg_percent_dl=${GBR_exceed_GFBR_data["1"]["target_avg_percent_dl"]}

Change Preemption UE Parameter
    Set To Dictionary    ${TLCommonConfig_FDD["MultiUECFG"]}      ue_index_for_call=${preemTLCommonConfig_FDD["ue_index_for_call"]}

    Set To Dictionary    ${TLCommonConfig_FDD["MultiUECFG"]["2"]["dl"]}    target_throughput=${preemTLCommonConfig_FDD["0"]["dl"]}
    Set To Dictionary    ${TLCommonConfig_FDD["MultiUECFG"]["2"]["ul"]}    target_throughput=${preemTLCommonConfig_FDD["0"]["ul"]}

    Set To Dictionary    ${TLCommonConfig_FDD["MultiUECFG"]["3"]["dl"]}    target_throughput=${preemTLCommonConfig_FDD["1"]["dl"]}
    Set To Dictionary    ${TLCommonConfig_FDD["MultiUECFG"]["3"]["ul"]}    target_throughput=${preemTLCommonConfig_FDD["1"]["ul"]}

Online Modify Parameters for precondition
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    abbr=Activate UE context preemption	    value=true
#    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
#    ...    abbr=Maximum number of SA and NSA users in a New Radio cell	    value=1
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Maximum number of users in a New Radio cell    value=1
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Maximum number of RRC connected users in a New Radio cell for SA    value=1
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Maximum number of RRC connected users configured with carrier aggregation in a New Radio cell    value=1
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Maximum number of secondary cell allocations in a cell	    value=1
     COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Maximum number of users in a NR cell for NSA operation		    value=1
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Allow emergency radio resources for temporary use during preemption    value=false
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Number of radio resources reserved for temporary use    value=2
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Number of radio resources reserved for emergency calls    value=0
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Prefer NSA preemption	    value=true
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
    ...    abbr=Maximum number of users in a NR cell for NR-DC-SN operation	    value=1
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
    ...    abbr=Administrative state	    value=Locked
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout


Online Modify Parameters Locked cell to Unlocked
   [Arguments]    ${NRCELL-id}=NRCELL-1
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${NRCELL-id}
    ...    abbr=Administrative state	    value=Unlocked
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout

###############################Suite Setup Case Setup################################################
Setup The Suite
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    run    command=cp ${CFGFILE_PATH}/SCF_SBTS00.xml ${LOG_PATH}/TestLineSCF.xml
    Conn.ResetCache

Teardown The Suite
    TestSuite.Stop

Setup Case
    [Arguments]
    TestCase.Start
    Run Keyword And Ignore Error    Start BTSlogs Collection


Teardown Case
    TestCase.Stop
    Run Keyword And Ignore Error     Stop BTSlogs Collection and get logs
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    run    command=killall firefox
    Conn.ResetCache

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf BTSLOG_TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    run keyword and ignore error    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    run keyword and ignore error    btslog.Set Global Alias     btslog
    run keyword and ignore error    core.setup_collectors      names=btslog
    run keyword and ignore error    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz ${LOG_PATH}
