*** Settings ***
Documentation    author: Liu Geng, Lou Shuhui
...               contact: geng.liu@nokia-sbell.com,shuhui.lou@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000752-Z
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ../../5GC000638/Resources/coam_close.py
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           OperatingSystem
Library           Collections
Library           Process
Library           String
Library           Telnet
Library           DateTime
Library           ute_wtssim
Library           ute_syslog
Library           ute_admin
Library           urllib
Library           requests
Variables         CaseConfiguration.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}

${CFGFILE_PATH}             /home/ute/TAF/cfgfile/
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${5G_AP_LMP_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}
${5G_AP_USERNAME}           ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.username}
${5G_AP_PASSWORD}           ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.password}

${PB_PORT}                  5000

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${IMSI}                     ${tl.ues[0].imsi}

${UL_TP}                    5
${DL_TP}                    10
${FSP_IP}                   192.168.253.20
${FSP_SLAVE_IP}             192.168.253.21
${NRBTSID}                  ${tl.gnbs[0].global_bts_id}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${SOSREPORT_NEEDED}      ture
&{AP}                   hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
${WTS_DIR}              /home/ute/WTS_golden

@{counter return value}  ${EMPTY}

@{UL PDCP SDU volume}   M55319C06001    M55319C06002    M55319C06003    M55319C06004    M55319C06005    M55319C06006
...                     M55319C06007    M55319C06008    M55319C06009    M55319C06010    M55319C06011    M55319C06012
...                     M55319C06013    M55319C06014    M55319C06015    M55319C06016    M55319C06017    M55319C06018
...                     M55319C06019    M55319C06020


@{DL PDCP SDU volume}    M55319C02001    M55319C02002    M55319C02003    M55319C02004    M55319C02005    M55319C02006
...                      M55319C02007    M55319C02008    M55319C02009    M55319C02010    M55319C02011    M55319C02012
...                      M55319C02013    M55319C02014    M55319C02015    M55319C02016    M55319C02017    M55319C02018
...                      M55319C02019    M55319C02020


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
${ALIAS_MTKPC}                MTKPC                                             ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
${ALIAS_AP}                 AP                                                  ##
########################END of alias Define#######################################

*** Keywords ***
TC.L3_Call_with_AirPhone_of_mulit_UE_high_throughput
    [Arguments]  ${WTS_CFG}=multi_UE.lua  ${UE_num}=30  ${time}=60min  ${traffic_mode}=50NSA_Connected_UE_With_Peak_Rate
    Reset HW both side and check status ready
    NSA.Start WTS and verify cell onair on both side   WTS_CFG=${WTS_CFG}
    NSA.UE attach and start traffic    UE_num=${UE_num}   DL_TP=mbps=20  UL_TP=mbps=5
    traffic test time    time=${time}
    NSA.Egate.check UE status    UE_num=${UE_num}
    Run Keyword And Continue On Failure    check traffic at gNB side on WebEM Transport counter for high TP
    ...    UE_num=${UE_num}   traffic_mode=${traffic_mode}
    NSA. stop traffic and UE detach    UE_num=${UE_num}
    [Teardown]    Kill egate and edaemon


TC.L3_Call_with_AirPhone_of_mulit_UE_low_throughput
    [Arguments]  ${WTS_CFG}=multi_UE.lua  ${UE_num}=120  ${time}=60min  ${traffic_mode}=120NSA_Connected_UE_with_ping_data_one_hour
    Reset HW both side and check status ready
    NSA.Start WTS and verify cell onair on both side   WTS_CFG=${WTS_CFG}
    Run Keyword And Continue On Failure    NSA.LTE Attach   UE_num=${UE_num}
    sleep    60s
    Run Keyword And Continue On Failure    NSA.5G Attach    UE_num=${UE_num}
    sleep    60s
    Run Keyword And Continue On Failure    NSA.Egate.start DL traffic    UE_num=${UE_num}  DL_TP=kbps=1
    traffic test time    time=${time}
    NSA.Egate.check UE status    UE_num=${UE_num}
    Run Keyword And Continue On Failure    check UL traffic at gNB side on WebEM Transport counter
    ...    traffic_mode=${traffic_mode}
    Run Keyword And Continue On Failure    NSA.Egate.stop DL traffic    UE_num=${UE_num}
    sleep    20s
    Run Keyword And Continue On Failure    NSA.Egate.UE Detach    UE_num=${UE_num}
    [Teardown]    Kill egate and edaemon


TC.L3_Call_with_AirPhone_of_mulit_UE_and_50UE_attach_and_detach_for_loop
    [Arguments]  ${WTS_CFG}=multi_UE.lua  ${UE_num}=30  ${time}=60  ${DL_TP}=mbps=20  ${UL_TP}=mbps=5
     ...    ${traffic_mode}=50NSA_Connected_UE_with_Medium_data_50NSA_UE_Attach_Detach_one_hour
    Reset HW both side and check status ready
    NSA.Start WTS and verify cell onair on both side   WTS_CFG=${WTS_CFG}
    NSA.UE attach and start traffic       UE_num=${UE_num}   DL_TP=${DL_TP}  UL_TP=${UL_TP}
    Run Keyword And Continue On Failure    UTE.Wireshark.StartCaptureAPLog
    Run Keyword And Continue On Failure    NSA.50UE_attach_and_detach_for_loop    UE_num=${UE_num}  time=${time}
    ...   traffic_mode=${traffic_mode}   more_UE_num=50   loop_times=3000
    Run Keyword And Continue On Failure    NSA. stop traffic and UE detach    UE_num=${UE_num}
    Run Keyword And Continue On Failure    UTE.Wireshark.StopCapturingAPlog
    Run Keyword And Continue On Failure    UTE.Wireshark.DownloadAPLogTologfolder
    Run Keyword And Continue On Failure    Wireshark.Action.Close
    [Teardown]    Kill egate and edaemon


TC.VoNR_AirPhone_of_multi_UEs_and_one_real_UE_register_for_loop
    [Arguments]  ${WTS_CFG}=multi_UE_SA_2cell_golden.lua   ${UE_num}=150  ${TP}=5k  ${time}=60
     ...   ${traffic_mode}=SA_150AP_UEs_and_1real_UE_Attach_Detach_with_low_data_for_100_rounds
    Reset HW both side and check status ready
    SA.Start WTS and verify cell onair on both side   WTS_CFG=${WTS_CFG}
    SA.UEs register for loop    TP=${TP}    UE_num=${UE_num}  time=${time}  traffic_mode=${traffic_mode}
    [Teardown]    Kill egate and edaemon

TC.VoNR_AirPhone_of_multi_150UE_Intra_HO_for_loop
    [Arguments]  ${WTS_CFG}=multi_UE_SA_2cell.lua   ${UE_num}=200  ${TP}=5k
    Reset HW both side and check status ready for ASIL
    SA.Start WTS and verify cell onair on both side   WTS_CFG=${WTS_CFG}
    SA.multi_UE attach and start traffic with lua script      TP=${TP}    UE_num=${UE_num}
    SA.Egate.multi UEs Deregister with lua script     UE_num=${UE_num}
    [Teardown]    Kill egate and edaemon

SA.multi_UE attach and start traffic with lua script
    [Arguments]    ${UE_num}    ${TP}
    Log To Console    \n  SA 5G attach with lua script...
    ${pattern1}    Set Variable     All pdu session setup successful
    ${output1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${WTS_DIR}/pdu_setup_5qi5_5qi1.lua entry\=ue_register_with_pdu_setup(50)
    ...    pass_regexp=${pattern1}    timeout=20min
    ${attach_result1}    String.Get Lines Matching Regexp    ${output1}    ${pattern1}    partial_match=True
    SA.start DL traffic for loop     UE_num=${UE_num}     TP=${TP}
    FOR    ${index}    IN RANGE    8
        Log To Console    \nHO round ${index+1}.
        ${pattern2}    Set Variable    All ues handover successfully
        ${output2}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    script file\=${WTS_DIR}/HO_cell1-cell2.lua entry\=handover_cell1_cell2(200)
        ...    pass_regexp=${pattern2}    timeout=25min
        ${attach_result2}    String.Get Lines Matching Regexp    ${output2}    ${pattern2}    partial_match=True
        Log To Console    \nHO from cell1 to cell2 complete.
         ${pattern3}    Set Variable    All ues handover successfully
         ${output3}    ute_wtssim.Execute Egate Command And Wait For Data
         ...    script file\=${WTS_DIR}/HO_cell2-cell1.lua entry\=handover_cell2_cell1(200)
         ...    pass_regexp=${pattern3}    timeout=25min
         ${attach_result3}    String.Get Lines Matching Regexp    ${output3}    ${pattern3}    partial_match=True
        Log To Console    \nHO from cell2 to cell1 complete.
#         ${flag}     Evaluate     ${index+1}%1
#         ${test_time}     Evaluate     ${index+1}*50
#         Run Keyword If     ${flag}==0     check memory at gNB side on WebEM Transport counter      traffic_mode=multi_150UE_Intra_HO
#         ...   testline=HZ_TL009_Airphone    test_time=${test_time}
     END


SA.UEs register for loop
    [Arguments]  ${TP}  ${UE_num}  ${time}  ${traffic_mode}
    FOR    ${index}    IN RANGE    10
        SA.egate.UEs register for loop    TP=${TP}    UE_num=${UE_num}  time=${time}  traffic_mode=${traffic_mode}
    END

SA.egate.UEs register for loop
    [Arguments]  ${TP}  ${UE_num}  ${time}  ${traffic_mode}
    FOR    ${index}    IN RANGE    10
        Run Keyword And Ignore Error    SA.one real UE L3 CALL  time=${time}
        sleep    5s
        Log To Console    multi AP UEs start to register...
        SA.multi Airphone UEs L3 CALL       TP=${TP}    UE_num=${UE_num}  time=${time}
        ${test_time}    Evaluate   ${index}+1
        Run Keyword And Continue On Failure  check memory at gNB side on WebEM Transport counter
        ...    traffic_mode=${traffic_mode}    test_time=${test_time}
    END

SA.one real UE L3 CALL
    [Arguments]    ${time}=${time}
    Log To Console    real UE start to register...
    one_ue_start_L3CALL   ue_index=${0}  ue_type=${UE_TYPE}    traffic_time=${time}   ul_throughput=60MKbits/sec
      ...       peak_TP=1  duration=400

SA.multi Airphone UEs L3 CALL
    [Arguments]   ${TP}   ${UE_num}  ${time}
    #Run Keyword And Continue On Failure     SA.Egate.multi UE register and setup PDU session    UE_num=${UE_num}
    Run Keyword And Continue On Failure    SA.Egate.multi UE register with lua script       UE_num=${UE_num}
    SA.multi UEs start DL traffic     UE_num=${UE_num}     TP=${TP}
    sleep    ${time}s
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data  cmd=state_sim_disp    pass_regexp=The state is ACTIVE   timeout=10s
    NSA.Egate.check UE status    UE_num=100
    Run Keyword And Ignore Error    SA.stop traffic
    #Run Keyword And Continue On Failure    SA.Egate.multi UE deregister and release PDU session   UE_num=${UE_num}
    Run Keyword And Continue On Failure    SA.Egate.multi UEs Deregister with lua script   UE_num=${UE_num}
    sleep    5s

SA.Egate.multi UE register with lua script
    [Arguments]    ${UE_num}
     Log To Console    SA 5G attach with lua script...
    ${pattern1}    Set Variable     All pdu session setup successful
    ${output1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${WTS_DIR}/register_and_deregister_golden.lua entry\=ue_register_with_pdu_setup(1,${UE_num})
    ...    pass_regexp=${pattern1}    timeout=20min
    ${attach_result1}    String.Get Lines Matching Regexp    ${output1}    ${pattern1}    partial_match=True


SA.Egate.multi UEs Deregister with lua script
    [Arguments]    ${UE_num}
     Log To Console    deregister with lua script...
    ${pattern1}    Set Variable     all UEs deregister successful
    ${output1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${WTS_DIR}/register_and_deregister_golden.lua entry\=ue_deregister_with_pdu_release(1,${UE_num})
    ...    pass_regexp=${pattern1}    timeout=20min
    ${attach_result1}    String.Get Lines Matching Regexp    ${output1}    ${pattern1}    partial_match=True

SA.multi UEs start DL traffic
    [Arguments]     ${UE_num}   ${TP}
    Log To Console    DL traffic startting...
    FOR    ${index}    IN RANGE    ${UE_num}
           wait until keyword succeeds     5min    30sec       ssh.Connect to    ${UTE_IP}    ${UTE_USERNAME}    ${UTE_PASSWORD}
           ...                alias=${ALIAS_UTE}
           ${cmd}    Set Variable    iperf -c ${sub_dl_traffic_IP}${index+1} -u -p 5410 -l 1024B -b ${TP} -i 1 -t 9999 -B ${Customer_IP_addr}
           ssh.send_command  command=${cmd}  connection=${ALIAS_UTE}
           Conn.Disconnect  alias=${ALIAS_UTE}
           Log To Console     \n UL traffic ${index+1} is ok.
    END

SA.start DL traffic for loop
    [Arguments]     ${UE_num}   ${TP}
    Log To Console    DL traffic startting...
    FOR    ${index}    IN RANGE    ${UE_num}
           wait until keyword succeeds     5min    30sec       ssh.Connect to    ${UTE_IP}    ${UTE_USERNAME}    ${UTE_PASSWORD}
           ...                alias=${ALIAS_UTE}
           ${cmd}    Set Variable    iperf -c 10.12.2.${index+1} -u -p 5410 -l 1024B -b ${TP} -i 1 -t 99999 -B 10.0.2.1
           ssh.send_command  command=${cmd}  connection=${ALIAS_UTE}
           Conn.Disconnect  alias=${ALIAS_UTE}
           Log To Console     \n UL traffic ${index+1} is ok.
    END


one_ue_start_L3CALL
     [Arguments]    ${ue_index}=${0}   ${ue_type}=${UE_TYPE}   ${traffic_time}=20  ${duration}=300    ${peak_TP}=1  ${power_reset}=True
      ...     ${ul_throughput}=5MKbits/sec
     log to console  prepare UE ...
     power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}  reset_sol=${True}
     sleep    3s
     Run Keyword And Ignore Error    spark.power off    ue_alias=UE_${ue_index}
     sleep    3s
     Run Keyword And Ignore Error    spark.power on    ue_alias=UE_${ue_index}
     sleep    3s
     log to console  Get attach status ...
     ${result}    run keyword and return status    GetAttachvalue    ue_type=${UE_TYPE}  ue_index=${ue_index}
     should be true    '${result}'=='True'
     sleep    1s
     log to console  UL traffic started ...
     Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}   duration=${duration}
     ...    direction=ul     throughput=${ul_throughput}
     sleep    ${traffic_time}s
     log to console    UE traffic completed ...
     Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}  ue_index=${ue_index}
       ...    throughput=30  start_offset=${0}  direction=ul
     log to console    start to stop traffic and detach UE ...
     Run Keyword And Ignore error  power_ue.Stop traffic    ue_type=${ue_type}     direction=ul       ue_index=${ue_index}
     sleep  10s
     Run Keyword And Ignore Error    spark.power off    ue_alias=UE_${ue_index}
     log to console    UE detach completed ...
     sleep  2s

GetAttachvalue
    [Arguments]   ${ue_type}=${UE_TYPE}    ${ue_index}=${0}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}    power_reset=True
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${ue_index}   ue_type=${UE_TYPE}    power_reset=True
    sleep    1s
    ${Rach_status}    run keyword and return status    power_ue.Verify attach    ue_index=${ue_index}
    ...    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    should be true    '${Rach_status}'=='True'

single_ue.start traffic
    [Arguments]    ${ue_type}=${UE_TYPE}   ${ue_index}=${0}  ${duration}=10  ${dl_throughput}=10MKbits/sec  ${ul_throughput}=5MKbits/sec
    log to console  DL traffic started ...
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}   duration=${duration}
     ...     direction=dl     throughput=${dl_throughput}
    sleep  3s
    log to console  UL traffic started ...
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}   duration=${duration}
     ...    direction=ul     throughput=${ul_throughput}


single_ue.check traffic
    [Arguments]    ${peak_TP}=0  ${ue_index}=${0}   ${ue_type}=${UE_TYPE}
    run keyword if    "${peak_TP}" == "0"    single_ue.check throughput   ue_type=${UE_TYPE}  ue_index=${ue_index}
    ...    ELSE IF    "${peak_TP}" == "1"    single_ue.check throughput   ue_type=${UE_TYPE}  ue_index=${ue_index}  check_dl_TP=50  check_ul_TP=30

single_ue.check throughput
    [Arguments]    ${ue_index}=${0}   ${ue_type}=${UE_TYPE}  ${check_dl_TP}=5  ${check_ul_TP}=2
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}  ue_index=${ue_index}
    ...    throughput=${check_dl_TP}   start_offset=${0}   direction=dl
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}  ue_index=${ue_index}
    ...    throughput=${check_ul_TP}   start_offset=${0}  direction=ul

Reset HW both side and check status ready
    [Arguments]   ${InstallPackage_path}=/opt/transformers.dynamic.nsn-net.net/workspace/CRT/Master/Manual
    #gNB.Configure Airphone DCI link
    #Run Keyword And Ignore Error    gNB.Enable_DebugLog
    Kill egate and edaemon
    Run Keyword And Ignore Error   run     command=sudo rm -r ${InstallPackage_path}/InstallPackageOnly*
    sleep  3s
    Run Keyword And Ignore Error   run     command=sudo rm -r ${WTS_DIR}/*.log.*
    sleep   10s
    Power.ResetgNB    model=HBTE
    sleep   3min
    #check HW ready both gNB and AP side

Reset HW both side and check status ready for ASIL
    [Arguments]   ${InstallPackage_path}=/opt/transformers.dynamic.nsn-net.net/workspace/CRT/Master/Manual
    #Run Keyword And Ignore Error    gNB.Enable_DebugLog
    Kill egate and edaemon
    Run Keyword And Ignore Error   run     command=sudo rm -r ${InstallPackage_path}/InstallPackageOnly*
    sleep  3s
    Run Keyword And Ignore Error   run     command=sudo rm -r ${WTS_DIR}/*.log.*
    sleep   10s
    Power.ResetgNB    model=HBTE
    sleep   3min
    check HW ready both gNB and AP side

NSA.50UE_attach_and_detach_for_loop
    [Arguments]   ${UE_num}=30  ${time}=30  ${traffic_mode}=1  ${brid}=2  ${dir}=dl  ${more_UE_num}=20   ${loop_times}=30
    ${test_time}   Set Variable   0
    Run Keyword And Continue On Failure    NSA.Egate.50UE_attach_and_detach_for_loop   UE_num=${UE_num}
    ...   more_UE_num=${more_UE_num}  loop_times=${loop_times}
    FOR    ${num}    IN RANGE    1      11
#        NSA.Egate.attach success rate  UE_num=${UE_num}
        traffic test time    time=${time}mins
        ${result2}   run keyword and return status   wait until keyword succeeds  3 times   5s  NSA.Egate.check UE status  UE_num=${UE_num}
        exit for loop if   '${result2}' == 'False'
        ${test_time}   Evaluate   ${time}+${test_time}
        Run Keyword And Continue On Failure  check traffic at gNB side on WebEM Transport counter for high TP
        ...    UE_num=${UE_num}   traffic_mode=${traffic_mode}   test_time=${test_time}
        Log To Console    update date for ${num}time...
    END



NSA.Start WTS and verify cell onair on both side
    [Arguments]  ${WTS_CFG}
    Run Keyword And Continue On Failure    Start UTE WTS    ${WTS_CFG}
    NSA.Setup X2 Connection
    Verify AP Cell Setup
    Wait until keyword succeeds   10min   10s    COAM_VerifyOnAirViaFrontendAndBackend

NSA.UE attach and start traffic
    [Arguments]   ${UE_num}  ${DL_TP}  ${UL_TP}
    Run Keyword And Continue On Failure    NSA.LTE Attach   UE_num=${UE_num}
    sleep    30s
    Run Keyword And Continue On Failure    NSA.5G Attach    UE_num=${UE_num}
    sleep    60s
    Run Keyword And Continue On Failure    NSA.Egate.start DL traffic    UE_num=${UE_num}  DL_TP=${DL_TP}
    sleep    10s
    Run Keyword And Continue On Failure    NSA.Egate.start UL traffic    UE_num=${UE_num}   UL_TP=${UL_TP}
    sleep    10s

NSA. stop traffic and UE detach
    [Arguments]   ${UE_num}
    Run Keyword And Continue On Failure    NSA.Egate.stop DL traffic    UE_num=${UE_num}
    sleep    10s
    Run Keyword And Continue On Failure    NSA.Egate.stop UL traffic    UE_num=${UE_num}
    sleep    10s
    Run Keyword And Continue On Failure    NSA.Egate.UE Detach    UE_num=${UE_num}
    sleep    5s

SA.Start WTS and verify cell onair on both side
    [Arguments]  ${WTS_CFG}
    Run Keyword And Continue On Failure    Start UTE WTS    ${WTS_CFG}
    sleep  1min
    Run Keyword And Ignore Error     SA.check NG link setup
    Verify AP Cell Setup
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Log To Console  gNB cell onair now ...

SA.check NG link setup
    Log To Console    start to check NG link ...
    ute_wtssim.Execute Egate Command    sim_log_set flush  timeout=1min
    ${value}    run     command=cat ${WTS_DIR}/egate_console.log |grep NG
    Should Contain   ${value}   NG link is Up
    Log   NG link is Up
    Log   NG Link to gNB=2 is now Active

SA.stop traffic
    [Arguments]
    Log To Console    traffic stopped...
    run     command=ps -ef|grep iperf |grep -v grep |awk '{print $2}' |xargs kill -9

Kill egate and edaemon
    Log To Console    clear egate and edaemon start...
    Run Keyword And Ignore Error   run     command=ps -ef|grep edaemon |grep -v grep |awk '{print $2}' |xargs sudo kill -2
    Run Keyword And Ignore Error   run     command=ps -ef|grep egate |grep -v grep |awk '{print $2}' |xargs kill -2
    Run Keyword And Ignore Error    ute_wtssim.Teardown Edaemon    alias=edaemon
    Run Keyword And Ignore Error    ute_wtssim.Teardown Egate
    Log To Console    clear egate and edaemon done...


traffic test time
    [Arguments]    ${time}
    sleep     ${time}

UTE.connect
    #ssh.connect to    hostname=10.57.240.35   username=ute    password=ute    alias=${ALIAS_UTE}
    ssh.connect to    hostname=${UTE_IP}     username=${UTE_USERNAME}     password=${UTE_PASSWORD}  alias=${ALIAS_UTE}


UTE.disconnect
    [Arguments]    ${connection}=${ALIAS_UTE}
    ssh.disconnect    connection=${connection}

UTE.Wireshark.StartCaptureAPLog
    UTE.connect
    Run Keyword And Ignore Error   ssh.send command  command=sudo tcpdump -i eth3 -w /tmp/AP_trace_log.pcap -vv sctp  connection=${ALIAS_UTE}

UTE.Wireshark.StopCapturingAPlog
    [Arguments]  ${listen_port}=eth3
    Run Keyword And Ignore Error  ssh.send command
    ...    command=sudo ps -ef|grep tcpdump|grep -v grep|grep ${listen_port}|awk '{print $2}'|xargs kill -2
    ...    connection=${ALIAS_UTE}
UTE.Wireshark.DownloadAPLogTologfolder
    [Arguments]    ${filename}=AP_trace_log.pcap
    Run Keyword And Ignore Error   ssh.execute  command=sudo cp /tmp/AP_trace_log.pcap ${LOG_PATH}${/}${filename}   connection=${ALIAS_UTE}
    UTE.disconnect



COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    [return]    ${values[-1]}


COAM_WEBEM.CheckTransportConutersWithConditioanalTraget
    [Arguments]    ${counter_id}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_transport_counters   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    [return]    ${values[-1]}

check memory at gNB side on WebEM Transport counter
    [Arguments]    ${traffic_mode}=1  ${testline}=HZ_TL210_Airphone  ${test_time}=0  ${DL_Tput}=0  ${UL_TP}=0
    ...    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/benchmark/input/?version=
    ${version}    GetgNBSWVersion
    ${ASIK_CPU_LOAD}    gNB.collect ASIK CPU usage
    ${ASIK_MEM}    gNB.collect ASIK Memory usage
    ${ABIL_CPU_LOAD}    gNB.collect ABIL CPU usage
    ${ABIL_MEM}    gNB.collect ABIL Memory usage
    ${TOP}  set variable   ABIL_CPU_LOAD=${ABIL_CPU_LOAD}%&ABIL_MEM=${ABIL_MEM}%&ASIK_CPU_LOAD=${ASIK_CPU_LOAD}%&ASIK_MEM=${ASIK_MEM}%
    ${TOP1}  set variable   traffic_mode=${traffic_mode}&CELL_UL_TPUT=${UL_TP}Mbit/s&CELL_DL_TPUT=${DL_Tput}Mbit/s&SAMPLE_TIME=${test_time}
    #${res}    urllib.urlopen    url=${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    ${toolcenterURL}    set variable    ${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    &{final_data}   create dictionary     Testline=${testline}
    ...    Version=${gnb_version}    Result=${TEST STATUS}
    ...    &{data}
    log dictionary    ${final_data}
    ${res}    requests.post    ${toolcenterURL}    data=${final_data}
    log to console       ${res.read()}

check UL traffic at gNB side on WebEM Transport counter
    [Arguments]    ${traffic_mode}  ${testline}=HZ_TL210_Airphone  ${test_time}=0  ${DL_Tput}=0
    ...    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/benchmark/input/?version=
    ${version}    GetgNBSWVersion
    ${UL_TP}      COAM_Admin.evaluate UL_TPUT
    ${ASIK_CPU_LOAD}    gNB.collect ASIK CPU usage
    ${ASIK_MEM}    gNB.collect ASIK Memory usage
    ${ABIL_CPU_LOAD}    gNB.collect ABIL CPU usage
    ${ABIL_MEM}    gNB.collect ABIL Memory usage
    ${TOP}  set variable   ABIL_CPU_LOAD=${ABIL_CPU_LOAD}%&ABIL_MEM=${ABIL_MEM}%&ASIK_CPU_LOAD=${ASIK_CPU_LOAD}%&ASIK_MEM=${ASIK_MEM}%
    ${TOP1}  set variable   traffic_mode=${traffic_mode}&CELL_UL_TPUT=${UL_TP}Mbit/s&CELL_DL_TPUT=${DL_Tput}Mbit/s&SAMPLE_TIME=${test_time}
    #${res}    urllib.urlopen    url=${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    ${toolcenterURL}    set variable    ${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    &{final_data}   create dictionary     Testline=${testline}
    ...    Version=${gnb_version}    Result=${TEST STATUS}
    ...    &{data}
    log dictionary    ${final_data}
    ${res}    requests.post    ${toolcenterURL}    data=${final_data}
    log to console       ${res.read()}

check traffic at gNB side on WebEM Transport counter for high TP
    [Arguments]    ${UE_num}   ${traffic_mode}  ${testline}=HZ_TL210_Airphone   ${test_time}=0
    ...    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/benchmark/input/?version=
    #${DL_Tput}     NSA.Egate.Verify DL Throughput    UE_num=${UE_num}
    ${DL_Tput}          COAM_Admin.evaluate DL_TPUT
    ${version}          GetgNBSWVersion
    ${UL_TP}            COAM_Admin.evaluate UL_TPUT
    ${ASIK_CPU_LOAD}    gNB.collect ASIK CPU usage
    ${ASIK_MEM}         gNB.collect ASIK Memory usage
    ${ABIL_CPU_LOAD}    gNB.collect ABIL CPU usage
    ${ABIL_MEM}         gNB.collect ABIL Memory usage
    ${TOP}  set variable   ABIL_CPU_LOAD=${ABIL_CPU_LOAD}%&ABIL_MEM=${ABIL_MEM}%&ASIK_CPU_LOAD=${ASIK_CPU_LOAD}%&ASIK_MEM=${ASIK_MEM}%
    ${TOP1}  set variable   traffic_mode=${traffic_mode}&CELL_UL_TPUT=${UL_TP}Mbit/s&CELL_DL_TPUT=${DL_Tput}Mbit/s&SAMPLE_TIME=${test_time}
    #${res}    urllib.urlopen    url=${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    ${toolcenterURL}    set variable    ${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    &{final_data}   create dictionary     Testline=${testline}
    ...    Version=${gnb_version}    Result=${TEST STATUS}
    ...    &{data}
    log dictionary    ${final_data}
    ${res}    requests.post    ${toolcenterURL}    data=${final_data}
    sleep   5s
    log to console       ${res.read()}

gNB.collect ASIK CPU usage
    gNB.Connect
    ${result}    ssh.execute  command=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'
    ...    connection=${ALIAS_ASIK}
    ${ASIK_CPU_LOAD}    Evaluate   round(${result},2)
    log to console       ASIK_CPU_LOAD is ${ASIK_CPU_LOAD}
    gNB.Disconnect
    [Return]   ${ASIK_CPU_LOAD}

gNB.collect ASIK Memory usage
    gNB.Connect
    ${result}    ssh.execute  command=free | grep 'Mem:' | awk -F ' ' '{print $3/$2*100}'   connection=${ALIAS_ASIK}
    #${Mem total}    ssh.execute  command=top -b -n 1 | grep 'KiB Mem :' -A 0| awk -F ' ' '{print $4}'    connection=${ALIAS_ASIK}
    #${Mem used}    ssh.execute  command=top -b -n 1 | grep 'KiB Mem :' -A 0| awk -F ' ' '{print $8}'    connection=${ALIAS_ASIK}
    #${result}   Evaluate    float(${Mem used})*100/float(${Mem total})
    ${ASIK_MEM}    Evaluate   round(${result},2)
    log to console       ASIK_MEM is ${ASIK_MEM}
    gNB.Disconnect
    [Return]   ${ASIK_MEM}

gNB.collect ABIL CPU usage
    gNB_ABIL.Connect
    ${result}    ssh.execute  command=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'
    ...    connection=${ALIAS_ABIL_SLAVE}
    ${ABIL_CPU_LOAD}    Evaluate   round(${result},2)
    log to console       ABIL_CPU_LOAD is ${ABIL_CPU_LOAD}
    gNB_ABIL.Disconnect
    [Return]   ${ABIL_CPU_LOAD}

gNB.collect ABIL Memory usage
    gNB_ABIL.Connect
    ${result}    ssh.execute  command=free | grep 'Mem:' | awk -F ' ' '{print $3/$2*100}'   connection=${ALIAS_ABIL_SLAVE}
    ${ABIL_MEM}    Evaluate   round(${result},2)
    log to console       ABIL_MEM is ${ABIL_MEM}
    gNB_ABIL.Connect
    [Return]   ${ABIL_MEM}

GetgNBSWVersion
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    #${active_5g_rat_version}   Set Variable   ${sw_info['Active 5G RAT version']}
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.Transfer SW Version   ${sw_info['Active SW version']}
    log to console       get gNB SW version completed
        COAM_Admin.Logout
    [Return]   ${active_sw_version}

COAM_Admin.evaluate DL_TPUT
    COAM_WebEM.Login
    ${DL_PDCP_SDU_volume}   Wait until keyword succeeds   5x   4min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget   counter_id=M55319C02009
    ${users_denominator}   Wait until keyword succeeds   5x   4min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55114C00009
    should not be equal    ${DL_PDCP_SDU_volume}   0
    should not be equal    ${users_denominator}    0
    ${result}    Evaluate    8*float(${DL_PDCP_SDU_volume})/${users_denominator}/1000
    ${DL_TP}    Evaluate   round(${result},2)
    log to console      DL_TPUT is ${DL_TP}
    COAM_WebEM.Logout
    [return]    ${DL_TP}

COAM_Admin.evaluate UL_TPUT
    COAM_WebEM.Login
    #check BTS counter value
    ${output}   Wait until keyword succeeds   5x   4min     COAM_WEBEM.CheckTransportConutersWithConditioanalTraget    counter_id=M51321C2
    ${measurement time}    get IP interface statistics measurement interval on WebEM
    ${result}    Evaluate    8*float(${output})/${measurement time}/60/1000/1000
    ${UL_TP}    Evaluate   round(${result},2)
    log to console      UL_TPUT is ${UL_TP}
    COAM_WebEM.Logout
    [return]    ${UL_TP}

get IP interface statistics measurement interval on WebEM
    [Arguments]   ${dist_name}=MRBTS-1/TNLSVC-1/TNL-1/PMTNL-1    ${search_text}=IP interface statistics measurement interval
    ${result}   selenium_coam.get_parameter_value   dist_name=${dist_name}  filter_param=${search_text}
    ...    abbr=ipInterfaceStatisticsInterval  timeout=30
    ${measurement time}    fetch from left    ${result}    min
    [Return]   ${measurement time}

Conn.ConnectABILWithTimeout
    [Arguments]    ${alias}
    Wait Until Keyword Succeeds    10min    30sec    Conn.ConnectABIL   alias=${alias}

Conn.ConnectABIL
    [Arguments]    ${alias}
    Run Keyword If    '${alias}'=='${ALIAS_ABIL}'    ssh.Connect to    ${FSP_IP}   ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...                alias=${ALIAS_ABIL}  proxy=${ALIAS_ASIK}
    ...    ELSE IF     '${alias}'=='${ALIAS_ABIL_SLAVE}'    ssh.Connect to    ${FSP_SLAVE_IP}   ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...                alias=${ALIAS_ABIL_SLAVE}    proxy=${ALIAS_ASIK}
    ...    ELSE    Fail    Unknow alias

gNB_ABIL.Connect
    gNB.Connect
    Conn.ConnectABILWithTimeout  alias=${ALIAS_ABIL}
    Conn.ConnectABILWithTimeout  alias=${ALIAS_ABIL_SLAVE}

gNB_ABIL.Disconnect
    Conn.Disconnect  alias=${ALIAS_ABIL}
    Conn.Disconnect  alias=${ALIAS_ABIL_SLAVE}

check HW ready both gNB and AP side
    Log To Console    start to check gNB and AP HW status...
    Run Keyword And Continue On Failure    Check gNB HW status ready
#    run keyword and ignore error    COAM_WebEM.Login
#    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
#    Wait Until Keyword Succeeds    20min    1min     COAM Check GNB RU status
#    run keyword and ignore error    COAM_WebEM.Logout
    #Run Keyword And Continue On Failure    Check ALL RUs Online
    #Run Keyword And Continue On Failure    Check AP HW status ready
    #Run Keyword And Continue On Failure    check AP container ready
    Log To Console    gNB and AP HW status are ready


Check gNB HW status on WebEM
    Run Keyword And Continue On Failure    Check ASIK is UP
    #Run Keyword And Continue On Failure    Check ABIL is UP
    #Run Keyword And Continue On Failure    Check ABIL is UP


Check ASIK is UP
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    ${P_name_smod}    set variable    ${output_tmp}[Product name]
    run keyword if    '${P_name_smod}' == 'ASIK AirScale Common'    Check ASIK State
    run keyword if    '${P_name_smod}' == 'ASIB AirScale Common'    Check ASIB State
    run keyword if    '${P_name_smod}' == 'ASIL AirScale Common'    Check ASIL State
#    ${output_tmp1}    selenium_coam.get_abil_info
#    ${output1}    set variable    &{output_tmp1}[Status]
#    should be equal      &{output1}[Administrative state]    Unlocked
#    should be equal      &{output1}[Availability status]     Online
#    should be equal      &{output1}[Procedural status]     configured
    run keyword and ignore error    COAM_WebEM.Logout

Check ABIL is UP
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    should be equal      ${output}[Operational status]     enabled
    should be equal      ${output}[Procedural status]     configured
    run keyword and ignore error    COAM_WebEM.Logout

Check ASIK State
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIK}    selenium_coam.get_asik_info
    ${output_1}    set variable    ${output_ASIK}[Status]
    should be equal      ${output_1}[Administrative state]    Unlocked
    should be equal      ${output_1}[Availability status]     Online
    should be equal      ${output_1}[Procedural status]     configured
    run keyword and ignore error    COAM_WebEM.Logout

Check ASIB State
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIB}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_2}    set variable    ${output_ASIB}[Runtime parameters]
    should be equal      ${output_2}[Procedural status]     configured
    should be equal      ${output_2}[Operational state]     enabled
    run keyword and ignore error    COAM_WebEM.Logout

Check ASIL State
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIL}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_2}    set variable    ${output_ASIL}[Runtime parameters]
    should be equal      ${output_2}[Procedural status]     configured
    should be equal      ${output_2}[Operational state]     enabled
    run keyword and ignore error    COAM_WebEM.Logout

Check gNB HW status ready
     [Arguments]
    FOR    ${i}    IN RANGE    5
        Set test variable    ${i}
        ${res_status}    run keyword and return status   recheck gNB status on WebEM
        Run Keyword If        ${res_status}    Exit For Loop
    #    Run Keyword unless    ${res_status}    Reboot gNB Via WebEM
        Continue For Loop If   '${res_status}'=='FALSE'
    END
    Log To Console    gNB HW is ready


recheck gNB status on WebEM
    wait until keyword succeeds    8 min    30s    Check gNB HW status on WebEM

gNB.Enable_DebugLog
    Log To Console  start to enable debug log ...
    gNB.Connect
    ${output}   ssh.execute   command=cp /ffs/fs2/config/toor4nsn/cp_runtime.ini /rom/cp_runtime.ini  connection=${ALIAS_ASIK}
    gNB.Disconnect
    Log To Console  enable debug log done


gNB.Configure Airphone DCI link
    Log To Console  start to configure Airphone DCI link network configuration service ...
    gNB.Connect
    ${output}   ssh.execute   command=cd /ffs/run/config/toor4nsn/DCI_golden/ ; ./deploy.sh  connection=${ALIAS_ASIK}
    gNB.Disconnect
    Log To Console  configuration done
    [Return]   ${output}

Reboot AP Via SSH
    wait until keyword succeeds    5 min    15s   SYSTEM Check If Host Is Pingable
    sleep  10s
    Log To Console    Reboot AP via ssh...
    AP.connect
    ssh.execute  command=reboot   connection=${ALIAS_AP}
    AP.disconnect
    #OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP.password} ssh ${AP.username}@${AP.hostname} 'reboot'
    Log To Console    Reboot AP finished...

Start UTE WTS
    [Arguments]    ${WTS_CFG}
    Log To Console    Starting WTS...
    ${pattern}    Set Variable     SimMode is ready now
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}   ssh_pass=${UTE_PASSWORD}   alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}   ssh_pass=${UTE_PASSWORD}
    ute_wtssim.Start Egate Process
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cfg file\=${WTS_DIR}/${WTS_CFG}    pass_regexp=${pattern}   timeout=5min
    ${Start_UTE_WTS_result}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Wait Until Keyword Succeeds    120s    15s
    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE


NSA.Setup X2 Connection
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
    ...    pass_regexp=${pattern}    timeout=10s
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok


NSA.LTE Attach
    [Arguments]    ${UE_num}
    Log To Console    LTE attach...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ue_attach id\=1-${UE_num} profile\=1
    ...    pass_regexp=UE IS ACTIVE    timeout=3min
    ${output}    String.Get Lines Matching Regexp    ${output}    UE IS ACTIVE    partial_match=True
    Log To Console    \n${output}
    Log    lte_attach_is_ok

NSA.5G Attach
    [Arguments]    ${UE_num}
    Log To Console    5G attach...
    ${pattern}    Set Variable    UE${UE_num}\: Proxy \\(eNB 2 cell 1\\) reported successful RA
    #${pattern}    Set Variable    Multi-UE SgNBAddition is successful
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...  script file\=sgnbaddition_multi.lua entry\=sgnb_addition_multi_ue(${UE_num})
    ...    pass_regexp=${pattern}    timeout=8min
    ${attach_result}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${attach_result}
    Log    ue_attach_is_ok
    [Return]    ${output}

NSA.Egate.start DL traffic
    [Arguments]    ${UE_num}  ${DL_TP}
    Log To Console    DL traffic started...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    trf_data_start ue\=1-${UE_num} id\=2 dir\=dl trf_id\=2 ${DL_TP}  timeout=1min
    Log    DL traffic started
    [Return]    ${output}

NSA.Egate.start UL traffic
    [Arguments]    ${UE_num}  ${UL_TP}
    Log To Console    UL traffic started...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    trf_data_start ue\=1-${UE_num} id\=2 dir\=ul trf_id\=1 ${UL_TP} remote_ip\=4.7.254.208   timeout=1min
    [Return]    ${output}

NSA.Egate.stop DL traffic
    [Arguments]    ${UE_num}
    Log To Console    UL traffic stopped...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    trf_data_stop ue\=1-${UE_num} id\=2 dir\=dl trf_id\=2  timeout=3min
    [Return]    ${output}

NSA.Egate.stop UL traffic
    [Arguments]    ${UE_num}
    Log To Console    UL traffic stopped...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    trf_data_stop ue\=1-${UE_num} id\=2 dir\=ul trf_id\=1  timeout=3min
    [Return]    ${output}

NSA.Egate.UE Detach
    [Arguments]    ${UE_num}
    Log To Console    start to detach UEs...
    FOR    ${ue_id}    IN RANGE    1      ${UE_num}+1   -1
        Run Keyword And ignore error    NSA.single UE Detach   ue_id=${ue_id}
    END
    sleep   5s



NSA.Egate.50UE_attach_and_detach_for_loop
    [Arguments]    ${UE_num}    ${loop_times}=5  ${more_UE_num}=20
    Log To Console    50UE attach and detach start...
    ${Start_UE}      Evaluate   ${UE_num}+1
    ${End_UE}        Evaluate   ${UE_num}+${more_UE_num}
    ute_wtssim.Execute Egate Command
    ...    script file\=multi_ue_script.lua entry\=attach_detach_defined_ues\(${Start_UE},${End_UE},2,2,1,5,${loop_times}\)     timeout=30min

NSA.Egate.check UE status
    [Arguments]    ${UE_num}
    Log To Console    start to check total UE status ..
    ${output}  ute_wtssim.Execute Egate Command And Wait For Data   ue_summary general
        ...   pass_regexp=EGATE\>  timeout=3sec
    ${output}    String.Get Lines Matching Regexp  ${output}  Time Aligned   partial_match=${TRUE}
    ${rc}  ${active_ue_num}   Run And Return Rc And Output   echo \"${output}\" | awk \'{print $4}\'
    Log To Console    active_ue_nums is ${active_ue_num}
    Should be true    ${active_ue_num}>=${UE_num}

NSA.single UE Detach
    [Arguments]    ${ue_id}
    Log To Console    UE${ue_id} start to detach...
    ${pattern1}    Set Variable    UE${ue_id}: Successfully reconfigured dual connectivity
    ${output1}    ute_wtssim.Execute Egate Command And Wait For Data    enb_ue_dc_release ue\=${ue_id} bearer\=2 by\=enb cause\=off
    ...    pass_regexp=${pattern1}    timeout=5s
    ${output1}    String.Get Lines Matching Regexp    ${output1}    ${pattern1}    partial_match=True
    Log To Console    UE${ue_id} sgNBrelease done...
    ${pattern}    Set Variable    UEC-1: UE${ue_id}: detached
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ue_detach id\=${ue_id}
    ...    pass_regexp=${pattern}    timeout=5s
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    UE${ue_id} detach completed...


Evaluate attach_successful_num
     ${result}   Set Variable   ${0}
     ${result}   Evaluate   ${attach_successful}+1
     Set test Variable    ${attach_successful}    ${result}

Evaluate attach_failed_num
     ${result1}   Set Variable   ${0}
     ${result1}   Evaluate   ${attach_failed}+1
     Set test Variable    ${attach_failed}    ${result1}

Verify AP Cell Setup
    Log To Console    verify cell setup...
    Sleep    15s
    Wait Until Keyword Succeeds    180s    5s    Check UTE ASIK AP Cell Setup
    Log    cell_setup_is_ok

Check UTE ASIK AP Cell Setup
    Log To Console    check ute ASIK AP cell setup...
    SSH.Connect To    ${AP.hostname}    ${AP.username}    ${AP.password}
    ${result}    SSH.Execute    grep -i "Cell Setup Completed" /tmp/APL3.log
    Should Contain    ${result}    Cell Setup Completed    ignore_case=True
    Log To Console    ${result}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

COAM.SetParameterValue
    [Arguments]    ${distname}    ${paraname}    ${value}    ${abbr}=${None}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${paraname}    new_value=${value}    abbr=${abbr}

COAM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    selenium_coam.activate_plan    activate_plan_despite_errors=True


SYSTEM Check If Host Is Pingable
    [Arguments]    ${host_ip_address}=${5G_AP_LMP_IP}
	${out_ping_result}=    Run   sudo ping -c 1 -W 10 ${host_ip_address}
    Should Contain    ${out_ping_result}    1 packets transmitted, 1 received    timeout=5
    [Return]    ${out_ping_result}

AP.connect
    [Arguments]    ${hostname}=${5G_AP_LMP_IP}   ${username}=${5G_AP_USERNAME}    ${password}=${5G_AP_PASSWORD}    ${alias}=${ALIAS_AP}
    ssh.connect to    hostname=${hostname}  username=${username}  password=${password}    alias=${alias}

AP.disconnect
    [Arguments]    ${connection}=${ALIAS_AP}
    ssh.disconnect    connection=${connection}



Wireshark.StopCapturingALLlog
    ASIK.Connect   alias=${ALIAS_ASIK}
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}
    ASIK.Disconnect    alias=${ALIAS_ASIK}

Wireshark.Action.Close
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s

Process.GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=${DL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${dTP}    Run Keyword And Continue On Failure  gNB.GetDLThroughput
    ...    ALIAS_ASP_1A=${ALIAS_ASP_1A}  duration=10    location=${16}
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${DLPercent}    Run Keyword And Continue On Failure    Evaluate    ${dTP}*${100}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Run Keyword And Continue On Failure    Should be true    ${DLPercent}>${Percentage}

Process.GetULBlerAndTP
    [Arguments]    ${ULThroughput}=${UL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${uTP}      Run Keyword And Continue On Failure   gNB.GetULThroughput   ${ALIAS_ASP_1A}    10
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${ULPercent}    Run Keyword And Continue On Failure    Evaluate    ${uTP}*${100}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
    #Set Test Variable    ${bler}
    Run Keyword And Continue On Failure     Should be true    ${ULPercent}>${Percentage}



ASIK.Connect
    [Arguments]   ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}


Collect SoSReport Log
    [Arguments]   ${sosreport_new_name}    ${WTS_INSTALL_PATH}=/home/ute/WTS_golden/
    [Documentation]    This keyword is used to capture the SoSReport log which has logs from AP, gNB and WTS
    ...                with AP and gNB snapshots. This is collected in the Suite Log Folder
    ...                 Modified Date: 02-Jun-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    Return From Keyword If    '${SOSREPORT_NEEDED}' == 'False'
    ${sosreport_output}    Run And Expect Command To Pass    command=cd ${WTS_INSTALL_PATH} && ./sosReport.sh -nr -c -s
    ...    msg=Script sosReport.sh
    ${sosreport_file_name}    Get SoSReport Log Filename    ${sosreport_output}
    Run And Expect Command To Pass    command=mv ${WTS_INSTALL_PATH}/${sosreport_file_name} ${LOG_PATH}/${sosreport_new_name}
    ...    msg=File copy
    File Should Exist    ${LOG_PATH}/${sosreport_new_name}

Run And Expect Command To Pass
    [Arguments]    ${command}    ${msg}=
    [Documentation]    This keyword is used to run a command and get its output.
    ...                Keyword will fail if the returncode is other than zero(0)
    ...                 Modified Date: 02-Jun-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${rc}    ${output}    Run and return rc and output    ${command}
    Should Be Equal As Integers   ${rc}    0    msg=${msg} failed execution with error code ${rc}
    [Return]    ${output}

Get SoSReport Log Filename
    [Arguments]    ${output}
    [Documentation]    This keyword is used to get the SoSReport log filename from the script output
    ...                 Modified Date: 02-Jun-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${file_name}    Get Regexp Matches    ${output}    (SosReport.*complete_iphy1.tgz)   1
    ${file_name}    Get From List    ${file_name}    0
    [Return]    ${file_name}

gNB.Power.ResetAndCommission
    [Arguments]    ${scf_file}
    Power.Reset5GRU
    Power.ResetgNB
    Sleep    10min
    wait until keyword succeeds    15min    1min    gNB.VerifyOnAirViaOAMUntilReady
    gNB.Commission    scf_file=${scf_file}    timeout=${2400}

Connect to 5GC
    [Arguments]    ${hostname}=${5GC_IP}   ${username}=${5GC_USERNAME}    ${password}=${5GC_PASSWORD}    ${alias}=${ALIAS_5GC}
    ssh.connect to    hostname=${hostname}  username=${username}  password=${password}    alias=${alias}

Disconnect from 5GC
    [Arguments]    ${connection}=${ALIAS_5GC}
    ssh.disconnect    connection=${connection}



Setup suite
    Create Log Directories
    set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    #gNB.Commission    scf_file=${Original_CFGFILE}    timeout=${2400}
    #Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Conn.ResetCache

Setup case
    Log to console    Case setup
    #Run Keyword And Ignore Error    Start BTSlogs Collection
    Set test Variable   ${attach_successful}   ${0}
    Set test Variable   ${attach_failed}       ${0}
    run    command=ulimit -c unlimited
Teardown case
    [Arguments]   ${sosreport_new_name}
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    run    command=killall firefox
    Run keyword and ignore error    Collect SoSReport Log    sosreport_new_name=${sosreport_new_name}

    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}${/}* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    coam_close.force_close_coam_webdriver
    Run Keyword And Ignore Error    Wireshark.StopCapturingALLlog
    Conn.ResetCache
