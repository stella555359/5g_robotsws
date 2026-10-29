*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com  jingmin.he@nokia-sbell.com
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource   ./enb.robot
Resource   ./bip.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_and_calculate_tput.py
Library   taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Library   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library   taf.ue.tm500.asc   WITH NAME   e500_asc
Library   taf.ul.mobile.ui.android   WITH NAME   android_ui
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/cpe.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/L3CALL/atcmd_l3call.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/L3CALL/sigspark.robot

Resource   ./Inseego.robot
Resource   ./l3call.robot

*** Variables ***
${ue_index}   ${0}
${ue_info}   ${tl.ues[${ue_index}]}
${tm500_alias}   e500
${sync_script}   /opt/hwmt/python/sendommessage.sh
${sync_cmd_param}   -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out -t execute --action
${E500_NAME}    tm500
${E500_GROUP}   Units-1
${E500_init}   ${0}
${LKC_LOGIN_USER}           dali.wang@nokia-sbell.com
${LKC_LOGIN_PWD}            Nokia!123
${LKC_CLIENT_ALIAS}         lkc
${LKC_CLIENT_PATH}          /cygdrive/c/Users/tester/Desktop/QPM_LK1.3\\(Hangzhou\\)/QPM_LK1.3\\(Hangzhou\\)
@{ue_type_list}     nokia_fastmile     mtk

*** Keywords ***
Call Setup and check tput
    [Timeout]   1h
    [Documentation]   Common L3Call Keyword for UE reserve, UE attach and DL traffic.
    [Arguments]   ${ue_index}=${ue_index}   ${port}=${EMPTY}
    ...   ${duration}=180   ${tput}=100   ${tput_expect}=${tput}   ${bip_request}=${false}    ${ue_reboot}=${False}
    ...   ${4G_check}=${false}    ${traffic_stop}=${true}   ${method}=normal   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    ...   ${direction}=dl   ${actImgGeneration}=${True}    ${dl_deviation}=0.98   ${ul_deviation}=0.98   ${actCarrierAggregation}=${False}
    ...   ${process_num}=1    ${Technology}=NR    ${ue_lock}=${False}    ${band}=N48    ${arfcn}=641952    ${pci}=765
    ...   ${min_percent}=0.85     ${power_reset}=False     ${apn_address}=dxdata2    ${cell_list}=None
    ...   ${check_source}=spark
    #${nr_cell_id}    Get Enb nrCellId
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ue_type}    set variable if   ${ue_type.count('honor')}>0 or ${ue_type.count('HONOR')}>0    huawei    ${ue_type}
    set suite variable    ${ue_type}
    set suite variable    ${ue_${ue_index}_type}     ${ue_type}
    ${port}    Get Variable Value    ${tl.ues[${ue_index}].iperf_details.port}
    ...    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ${bip_log}   Run keyword if   '${ue_type}'=='askey'   Start Askey L3call    ue_index=${ue_index}    traffic_stop=${traffic_stop}
    ...    duration=${duration}    ue_type=${ue_type}   Send_Tput=${tput}  Expect_Tput=${tput_expect}
    ...    peak_ul=${peak_ul}   ul_expect=${ul_expect}   method=${method}    direction=${direction}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}
    ...    ELSE IF   '${ue_type}' in ${ue_type_list}
    ...    Start CPE L3CALL    ue_index=${ue_index}    traffic_stop=${traffic_stop}    ue_reboot=${ue_reboot}
    ...    duration=${duration}    ue_type=${ue_type}   Send_Tput=${tput}  Expect_Tput=${tput_expect}
    ...    peak_ul=${peak_ul}   ul_expect=${ul_expect}   method=${method}    direction=${direction}   process_num=${process_num}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}    actCarrierAggregation=${actCarrierAggregation}   Technology=${Technology}
    ...    ue_lock=${ue_lock}    band=${band}   arfcn=${arfcn}    pci=${pci}   min_percent=${min_percent}
    ...    ELSE IF   ${ue_type.count('atcmd')}>0
    ...    Start ATCMD L3CALL    ue_index=${ue_index}    traffic_stop=${traffic_stop}    ue_reboot=${ue_reboot}
    ...    duration=${duration}    ue_type=${ue_type}   Send_Tput=${tput}  Expect_Tput=${tput_expect}
    ...    peak_ul=${peak_ul}   ul_expect=${ul_expect}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}    actCarrierAggregation=${actCarrierAggregation} \
    ...    min_percent=${min_percent}
    ...    ELSE IF   ${ue_type.count('sigspark')}>0
    ...    Start Spark L3CALL    ue_index=${ue_index}    traffic_stop=${traffic_stop}    ue_reboot=${ue_reboot}
    ...    duration=${duration}    ue_type=${ue_type}   Send_Tput=${tput}  Expect_Tput=${tput_expect}
    ...    peak_ul=${peak_ul}   ul_expect=${ul_expect}   method=${method}    direction=${direction}   process_num=${process_num}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}    actCarrierAggregation=${actCarrierAggregation}
    ...    min_percent=${min_percent}
    ...    power_reset=${power_reset}     apn_address=${apn_address}
    ...    ELSE   Start Android UE L3 Call  port=${port}   tput=${tput}   tput_expect=${tput_expect}   ue_index=${ue_index}
    ...    bip_request=${bip_request}    traffic_stop=${traffic_stop}    duration=${duration}
    ...    method=${method}   peak_ul=${peak_ul}   ul_expect=${ul_expect}   4G_check=${4G_check}   direction=${direction}
    ...    actImgGeneration=${actImgGeneration}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}
    ...    min_percent=${min_percent}    cell_list=${cell_list}    check_source=${check_source}
    Run Keyword If   '${tput}'=='0'   Sleep   5s
    [Return]   cpc_${ue_index}   ${ue_type}   ${bip_log}
    [Teardown]   Run Keyword If   ${traffic_stop}   run keyword and ignore error     power_ue.UE Detach
    ...   ue_type=${ue_type}   ue_index=${ue_index}     power_reset=${power_reset}

Start Askey L3call
    [Arguments]    ${ue_index}=${ue_index}    ${traffic_stop}=${true}    ${duration}=90
    ...    ${ue_type}=askey    ${Send_Tput}=200M     ${Expect_Tput}=50
    ...    ${peak_ul}=120   ${ul_expect}=${peak_ul}    ${method}=normal
    ...   ${direction}=DL    ${dl_deviation}=0.95    ${ul_deviation}=0.95
    Set Suite Variable   ${ue_${ue_index}_type}   ${ue_type}
    wait until keyword succeeds    3x    10s    ASKEY Attach and Verify    ue_index=${ue_index}    ue_type=${ue_type}    method=${method}
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    Run Keyword If   '${method}'=='PEAK'   _Start_Peak_Traffic_Testing_ASKEY
    ...   ue_type=${ue_${ue_index}_type}   dl_throughput=${Send_Tput}   ul_throughput=${peak_ul}   ue_index=${ue_index}
    ...   dl_expect=${Expect_Tput}   ul_expect=${ul_expect}   cell_list=${cell_id_list}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}
    ...   ELSE    _start_traffic_with_tp_check_askey    ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}  cell_list=${cell_id_list}
    ...   Send_Tput=${Send_Tput}   Expect_Tput=${Expect_Tput}
    ...   traffic_stop=${traffic_stop}    duration=${duration}     direction=${direction}
    ...   dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}
    [Return]   ${cell_id_list}
    [Teardown]   run keyword and ignore error   AT Teardown

_start_traffic_with_tp_check_askey
    [Arguments]   ${cell_list}    ${ue_index}=${ue_index}    ${traffic_stop}=${true}    ${duration}=90
    ...    ${ue_type}=askey    ${Send_Tput}=200M     ${Expect_Tput}=50
    ...    ${peak_ul}=120   ${ul_expect}=${peak_ul}    ${method}=normal
    ...   ${direction}=DL    ${dl_deviation}=0.95   ${ul_deviation}=0.95
    LOG    ${ue_type}
    LOG    ${ul_expect}
    LOG    ${method}
    Run Keyword If   '${direction}'=='DL'
    ...   Wait Until Keyword Succeeds   10m   60s   _start_dl_traffic_with_tp_check_askey
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}  cell_list=${cell_list}
    ...   Send_Tput_DL=${Send_Tput}   Expect_Tput_DL=${Expect_Tput}    traffic_stop=${traffic_stop}    duration=${duration}
    ...   dl_deviation=${dl_deviation}
    ...   ELSE IF   '${direction}'=='UL'
    ...   Wait Until Keyword Succeeds   10m   60s   _start_ul_traffic_with_tp_check_askey
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}  cell_list=${cell_list}
    ...   ul_tput=${Send_Tput}   Expect_Tput_UL=${Expect_Tput}    traffic_stop=${traffic_stop}    duration=${duration}
    ...   ul_deviation=${ul_deviation}

ASKEY Attach and Verify
    [Arguments]    ${ue_index}=${ue_index}    ${ue_type}=askey    ${method}=normal
    run keyword if  not ${ue_${ue_index}_required}   UE precondition ASKEY   ue_index=${ue_index}   ue_type=${ue_type}   method=${method}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_${ue_index}_type}
    power_ue.Verify attach    ue_type=${ue_${ue_index}_type}    5Grach_ed=${5Grach_ed}    4G_check=${False}

Start CPE L3CALL
    [Arguments]    ${ue_index}=${ue_index}    ${traffic_stop}=${true}    ${duration}=90    ${ue_reboot}=${False}
    ...    ${ue_type}=nokia_fastmile    ${Send_Tput}=200M     ${Expect_Tput}=50
    ...    ${peak_ul}=120   ${ul_expect}=${peak_ul}    ${method}=normal    ${Technology}=NR
    ...    ${direction}=DL    ${dl_deviation}=0.95    ${ul_deviation}=0.95   ${actCarrierAggregation}=${False}    ${process_num}=1
    ...    ${ue_lock}=${False}    ${band}=N48    ${arfcn}=641952    ${pci}=765   ${min_percent}=0.85
    Set Suite Variable   ${ue_${ue_index}_type}   ${ue_type}
    wait until keyword succeeds    3x    10s    CPE Attach and Verify   ue_index=${ue_index}    ue_type=${ue_type}    method=${method}
    ...   ue_reboot=${ue_reboot}    Technology=${Technology}   ue_lock=${ue_lock}    band=${band}   arfcn=${arfcn}    pci=${pci}
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    ${cell_id_list}   set variable if  ${actCarrierAggregation}    ${nrcellid_list}    ${cell_id_list}
    Run Keyword If   '${method}'=='PEAK'   _Start_Peak_Traffic_Testing_CPE
    ...   ue_type=${ue_${ue_index}_type}   dl_throughput=${Send_Tput}   ul_throughput=${peak_ul}   ue_index=${ue_index}
    ...   dl_expect=${Expect_Tput}   ul_expect=${ul_expect}   cell_list=${cell_id_list}    duration=${duration}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}    min_percent=${min_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    traffic_stop=${traffic_stop}
    ...   process_num=${process_num}    Technology==${Technology}
    ...   ELSE    _start_traffic_with_tp_check_CPE    ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}  cell_list=${cell_id_list}
    ...   Send_Tput=${Send_Tput}   Expect_Tput=${Expect_Tput}    Technology==${Technology}
    ...   traffic_stop=${traffic_stop}    duration=${duration}     direction=${direction}
    ...   actCarrierAggregation=${actCarrierAggregation}   process_num=${process_num}
    ...   dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}
    [Return]   ${cell_id_list}
    [Teardown]  Run Keyword If   ${traffic_stop}   CPE L3CALL Teardown    ue_index=${ue_index}    ue_lock=${ue_lock}   band=${band}


CPE L3CALL Teardown
    [Arguments]   ${ue_index}    ${ue_lock}    ${band}
    run keyword if   ${ue_lock}     Unlock band and PCI from CPE    ue_index=${ue_index}   band=${band}
    run keyword and ignore error   power_ue.UE Detach    ue_type=${ue_${ue_index}_type}


CPE Attach and Verify
    [Arguments]    ${ue_index}=${ue_index}    ${ue_type}=nokia_fastmile    ${method}=normal    ${ue_reboot}=${False}
    ...   ${Technology}=NR     ${ue_lock}=${False}    ${band}=N48    ${arfcn}=641952    ${pci}=765
    ${log_type}    set variable if   ${Technology.count('NR')}>0    Aasyslog   iperf
    UE precondition CPE   ue_index=${ue_index}   ue_type=${ue_type}   method=${method}    ue_reboot=${ue_reboot}
    run keyword if   ${ue_lock}    CPE Lock Opration   band=${band}   arfcn=${arfcn}    pci=${pci}   ue_index=${ue_index}
    power_ue.UE Attach
    ...   ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}   log_type=${log_type}
    [Teardown]     run keyword if  not ${KEYWORD STATUS.count('PASS')}>0
    ...    CPE L3CALL Teardown     ue_index=${ue_index}   ue_lock=${ue_lock}   band=${band}



Start Android UE L3 Call
    [Arguments]   ${ue_index}=${ue_index}   ${port}=${tl.ues[${ue_index}].iperf_details.port}
    ...   ${duration}=180   ${tput}=100   ${tput_expect}=${tput}   ${bip_request}=${false}   ${abil_index}=1
    ...   ${4G_check}=${false}    ${traffic_stop}=${true}   ${method}=normal   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    ...   ${direction}=DL   ${actImgGeneration}=${True}    ${dl_deviation}=0.95    ${ul_deviation}=0.95
    ...   ${min_percent}=0.85    ${cell_list}=None    ${check_source}=spark
    LOG    ${port}
    LOG    ${abil_index}
    Run Keyword and Ignore Error   Restart adb server and wait until status ready   ue_index=${ue_index}
    run keyword if  not ${ue_${ue_index}_required}   UE precondition   ue_index=${ue_index}
    Run Keyword If   ${bip_request}   Run Keyword and Continue on Failure   Start BIP Collection New
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
    Attach and Retry if Failed   ue_type=${ue_type}   ue_index=${ue_index}   4G_check=${4G_check}
    Return From Keyword If   $tput=='0'
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    ${cell_id_list}    Set Variable If   '${nr_cellid}'=='${EMPTY}'   ${cell_list}    ${cell_id_list}
    Run Keyword If   '${method}'=='PEAK'   Start Peak Traffic Testing UL DL both
    ...   ue_type=${ue_type}   dl_throughput=${tput}   ul_throughput=${peak_ul}   ue_index=${ue_index}
    ...   dl_expect=${tput_expect}   ul_expect=${ul_expect}   cell_list=${cell_id_list}    traffic_stop=${traffic_stop}
    ...   dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}  duration=${duration}   min_percent=${min_percent}
    ...   check_source=${check_source}
    ...   ELSE  _Direction_Start Traffic With Throughput Check
    ...   ue_type=${ue_type}   direction=${direction}    throughput=${tput}      expect=${tput_expect}
    ...   ue_index=${ue_index}       cell_list=${cell_id_list}    traffic_stop=${traffic_stop}    duration=${duration}
    ...   actImgGeneration=${actImgGeneration}   dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}
    ...   min_percent=${min_percent}
    ${bip_log}   Run Keyword If   ${bip_request}   Stop BIP Collection New
    [Return]   ${cell_id_list}   ${bip_log}

_Direction_Start Traffic With Throughput Check
    [Arguments]   ${ue_type}   ${direction}   ${throughput}   ${expect}
    ...  ${ue_index}=${0}    ${traffic_stop}=${true}    ${duration}=90s   ${actImgGeneration}=${True}
    ...   ${cell_list}=${EMPTY}   ${dl_deviation}=0.95    ${ul_deviation}=0.95   ${min_percent}=0.85
    run keyword if  '${direction.lower()}'=='dl'   Wait Until Keyword Succeeds   10m   60s   Start Traffic With Throughput Check
    ...   ue_type=${ue_type}    direction=${direction}   throughput=${throughput}   expect=${expect}
    ...   cell_list=${cell_list}       traffic_stop=${traffic_stop}    duration=${duration}  ue_index=${ue_index}
    ...   actImgGeneration=${actImgGeneration}   target_avg_percent=${dl_deviation}   min_percent=${min_percent}
    ...   ELSE   Wait Until Keyword Succeeds   10m   60s   Start Traffic With Throughput Check
    ...   ue_type=${ue_type}   direction=${direction}   throughput=${throughput}   expect=${expect}
    ...   cell_list=${cell_list}    traffic_stop=${traffic_stop}    duration=${duration}   ue_index=${ue_index}
    ...   actImgGeneration=${actImgGeneration}   target_avg_percent=${ul_deviation}   min_percent=${min_percent}


UE ${retry}attach Verify
    run keyword if  not '${retry}'==''    Log   First attach failure, try reattach
    ...   level=WARN   console=True
    ${5Grach_ed}    Get 5GRACH success times on ASIK
    Run Keyword If   '${retry}'==''    Run Keyword and Ignore Error   ute_ue.attach_ue    ue_alias=UE_${ue_index}
    ...   ELSE   Run Keyword and Ignore Error   Ue reattach with index   ue_index=${ue_index}
    wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    ${5Grach_ing}    Get 5GRACH success times on ASIK
    verify_5G_new_attach_available    before=${5Grach_ed}     after=${5Grach_ing}
    Sleep   10s
    ${ue_ip}   Wait Until Keyword Succeeds   2m   10s   Get Android UE IP   ue_index=${ue_index}
    Log to console   UE IP address: ${ue_ip}
    [Return]   ${ue_ip}

Get 5GRACH success times on ASIK
    [Documentation]  This keyword help to check the 5G RACH status in gnb l2lo side
    wait until keyword succeeds    1 min    10 sec    csn.Connect to
    ...   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK
    ${output} =    csn.execute    command=journalctl -b | grep "flow control start" |grep -v grep    connection=ASIK
    run keyword and ignore error    csn.disconnect    connection=ASIK
    @{list}    split string    ${output}    \n
    [Return]    ${list}

Change UE Network Mode And APN
    [Documentation]
    ...   Change UE Network Mode to "SA" or "NSA".
    ...   Change UE APN to "dxdata1" or "wap1.nokia.com" or "wap2.nokia.com"
    ...   First, need to add "core=_realcore" in the Testline init file. E.G. 7_5_UTE5G402T807
    [Arguments]   ${network_mode}=NSA   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    Run Keyword If   '${mode_status}'=='1'   power_ue.UE Attach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    ${ue_type}   translate_power_ue_type_from_testline   ue_index=${ue_index}

    ${cpc_addr}   Set Variable   ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${cpc_username}   Set Variable   ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${cpc_password}   Set Variable   ${tl.ues[${ue_index}].ssh_connection_details.password}
    ${ue_sn}   Set Variable   ${tl.ues[${ue_index}].serial_number}

    csn.Connect To   hostname=${cpc_addr}   username=${cpc_username}   password=${cpc_password}   alias=CPC
    ${build_num}   csn.Execute   command=adb -s ${ue_sn} shell getprop ro.huawei.build.display.id   connection=CPC
    csn.Disconnect   connection=CPC
    # LIO-AN00 11.0.0.990(SP12C00E175R7P11log)
    # EVR-AN00 10.0.0.990(SP10C00E110R2P9log)
    # CDY-AN95 3.1.1.193(C00E190R4P6)
    ${build_num}   Split String   ${build_num}   ${SPACE}

    ${build_num}   Split String   ${build_num[-1]}   (
    ${build_num}   Split String From Right   ${build_num[0]}   .   1
    ${build_num}   Set Variable   ${build_num[0]}

    ${ui_version}   Set Variable If
    ...   '${ue_type}'=='honor'   Magic UI ${build_num}
    ...   '${ue_type}'=='huawei'   EMUI ${build_num}
    ...   Not Support

    Log To Console   ${ui_version}
    Return From Keyword If   '${ui_version}'=='Not Support'

    android_ui.setup
    ...   ui_version=${ui_version}
    ...   host=${cpc_addr}
    ...   username=${cpc_username}
    ...   password=${cpc_password}
    ...   port=22
    ...   serial_number=${ue_sn}
    ...   alias=ANDROID_UI

    ${NSA_status}   Run Keyword And Return Status   Set Suite Variable   ${NSA_apn}   ${tl.core.pdns[0].apn}
    ${SA_status}   Run Keyword And Return Status   Set Suite Variable   ${SA_apn}   ${tl.core.pdns[1].apn}
    ${NSA_apn}   Set Variable If
    ...   not ${NSA_status}   dxdata1
    ...   ${NSA_apn}
    ${SA_apn}   Set Variable If
    ...   not ${SA_status}   wap1.nokia.com
    ...   ${SA_apn}
    android_ui.switch_apn   apn_name=${${network_mode}_apn}   mobile=ANDROID_UI

    @{NSA_network_mode_list}   Create List
    ...   NSA mode
    ...   NSA mode (default)
    @{SA_network_mode_list}   Create List
    ...   SA mode
    ...   SA+NSA mode
    FOR   ${network_mode}   IN   @{${network_mode}_network_mode_list}
        ${status}   Run Keyword And Return Status   android_ui.switch_network_mode   mode_name=${network_mode}   mobile=ANDROID_UI
        Exit For Loop If   ${status}
    END

    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    Run Keyword If   '${mode_status}'=='0'   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=CPC   AND
    ...   Run Keyword And Ignore Error   android_ui.teardown   mobile=ANDROID_UI
