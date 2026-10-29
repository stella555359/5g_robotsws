*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com  jingmin.he@nokia-sbell.com
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library   taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Library   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library   taf.ue.tm500.asc   WITH NAME   e500_asc
Library   taf.ul.mobile.ui.android   WITH NAME   android_ui

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

*** Keywords ***
Call Setup and check tput
    [Documentation]   Common L3Call Keyword for UE reserve, UE attach and DL traffic.
    [Arguments]   ${ue_index}=${ue_index}   ${port}=${tl.ues[${ue_index}].iperf_details.port}
    ...   ${duration}=180   ${tput}=100   ${tput_expect}=${tput}   ${bip_request}=${false}
    ...   ${4G_check}=${false}    ${traffic_stop}=${true}   ${method}=normal   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${bip_log}    Start Android UE L3 Call  port=${port}   tput=${tput}   tput_expect=${tput_expect}   ue_index=${ue_index}
    ...   bip_request=${bip_request}    traffic_stop=${traffic_stop}    duration=${duration}
    ...   method=${method}   peak_ul=${peak_ul}   ul_expect=${ul_expect}   4G_check=${4G_check}
    Run Keyword If   '${tput}'=='0'   Sleep   5s
    [Return]   cpc_${ue_index}   ${ue_${ue_index}_type}   ${bip_log}
    [Teardown]   Run Keyword If   ${traffic_stop}   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Start Android UE L3 Call
    [Arguments]   ${ue_index}=${ue_index}   ${port}=${tl.ues[${ue_index}].iperf_details.port}
    ...   ${duration}=180   ${tput}=100   ${tput_expect}=${tput}   ${bip_request}=${false}   ${abil_index}=1
    ...   ${4G_check}=${true}    ${traffic_stop}=${true}   ${method}=normal   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    Run Keyword and Ignore Error   Restart adb server and wait until status ready   ue_index=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=${4G_check}
    Return From Keyword If   $tput=='0'
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    Run Keyword If   '${method}'=='PEAK'   Start Peak Traffic Testing UL DL both
    ...   ue_type=${ue_${ue_index}_type}   dl_throughput=${tput}   ul_throughput=${peak_ul}   ue_index=${ue_index}
    ...   dl_expect=${tput_expect}   ul_expect=${ul_expect}   cell_list=${cell_id_list}
    ...   ELSE   Wait Until Keyword Succeeds   10m   60s   Start Traffic With Throughput Check
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL   cell_list=${cell_id_list}
    ...   throughput=${tput}   expect=${tput_expect}    traffic_stop=${traffic_stop}    duration=${duration}
    [Return]   ${cell_id_list}

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
