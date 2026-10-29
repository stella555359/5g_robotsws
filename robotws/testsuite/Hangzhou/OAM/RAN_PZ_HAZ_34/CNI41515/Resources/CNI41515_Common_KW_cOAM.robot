*** Settings ***
Documentation
...    author: Zhu Xinran Li Tao Li Ying
...    contact: xinran.zhu@nokia-sbell.com
...    Description: This case is to test feature CNI-41515 common keyword
...    This case is to be test on ClassicBTS.

Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot

Library           taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.ue  WITH NAME   ute_ue
Library           taf.sbts.oam.coam.admin   WITH NAME    enblte
Library           taf.pdu
Library           String
Library           Process
Library           OperatingSystem
Library           Collections
Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Library    taf.analyzer.pcap     WITH NAME    cap

*** Variables ***
${parameter_actDlDataForwardingX2}  Activate DL data forwarding over X2
${parameter_timerX2DataFwdGuard}  X2 data forwarding guard timer
${ute_tmp_log_dir}    /home/ute/log
@{params_in_swconfig}  0x1003f=1    0x10040=1    0x10041=4
${fct-1-0b}    192.168.253.17
${DL_PORT}                ${tl.ues[0].iperf_details.port}
${iperf_server_ip}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}


*** Keywords ***

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Get MrbtsId And NrbtsId
    wait until keyword succeeds    5min   10s    Check gNB Staus onAir
    ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}  search_text=Operational state
    Run Keyword And Ignore Error    WEBUI Logout

Get MrbtsId And NrbtsId
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min    10s    WEBUI Login
    ${commission_file}    selenium_coam.backup_bts_site_configuration
    sleep  5s
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}

Perform Validate And Activate
    Wait Until Keyword Succeeds    2min    10s    selenium_coam.validate_plan    timeout=40
    sleep    5s
    ${error}    selenium_coam.get_definition_errors
    should be empty    ${error}
    ${error}    selenium_coam.get_relation_errors
    should be empty    ${error}
    run keyword and ignore error  selenium_coam.activate_plan  activate_plan_despite_errors=True
    sleep  5s

Get Validate error
    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
    ${hardware_errors}      selenium_coam.get_hardware_errors    timeout=${120}
    ${errors}    Catenate    ${defination_errors}   ${relation_errors}   ${hardware_errors}
    [Return]    ${errors}

UE Attach And Get UE IP For Android
    [Tags]  19    Classicalbts    implemented    qualcomm   telecom    [flow]Telecom Management
    [Timeout]  30 minutes
    run keyword and continue on failure    Android UE l3 Call and Check RACH Status
    Get 5GRACH success times on gnb side
    ${ue_ip}    Get the UE Ip address
    [Return]    ${ue_ip}

Android UE l3 Call and Check RACH Status
    [Arguments]    ${ue_index}=${0}
    ${5Grach_ed}    ${5Grach_time_ed}    Get 5GRACH success times on gnb side
    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    run keyword if     '${attach_status}'=='False'    Ue reattach with index    ue_index=${ue_index}
    wait until keyword succeeds    2 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    wait until keyword succeeds    2 min    10s    Check 5G RACH Succeed
    ...    before=${5Grach_ed}    before_time=${5Grach_time_ed}

Check 5G RACH Succeed
    [Arguments]    ${before}   ${before_time}
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5GRACH success times on gnb side
    verify 5G rach success    before=${before}     after=${5Grach_ing}
    ...                      before_time=${before_time}    after_time=${5Grach_time_ing}
    sleep   5s

Check DL Throughput Is As Expect
    [Tags]  19B    Classical gNB
    [Timeout]  10 minutes
    [Arguments]  ${Expected_Throughput_DL}=10    ${dl_acceptance}=0.8
    wait until keyword succeeds    1 min    10 sec    csn.Connect to
    ...   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK
    wait until keyword succeeds    1 min    10 sec    Connect to asp1a    proxy=ASIK    alias=fsp1a
    start to record the throughput into log     direction=dl
    sleep   8s
    stop recording the throughput
    download transfer data log      direction=dl    alias=ASIK
    ...                             log_dir=${ute_tmp_log_dir}
    Preprocess dl transfer data log     log_dir=${ute_tmp_log_dir}
    run keyword and ignore error  verify the data transfer thoughput on gNB
    ...                                            direction=dl
    ...                                            log_dir=${ute_tmp_log_dir}
    ...                                            expect=${Expected_Throughput_DL}
    ...                                            ratio=${dl_acceptance}
    run keyword and ignore error    csn.disconnect    connection=fsp1a
    run keyword and ignore error    csn.disconnect    connection=ASIK

Stop DL Iperf And Release UE For Android
    [Timeout]  10 minutes
    Close the iperf process on APPserver    port=${DL_PORT}
    Android UE release

Connect to eNB
    [Arguments]    ${alias}=eNB
    csn.Connect to    hostname=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

Connect to gNB
    [Arguments]    ${alias}=gNB
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

Online Change ActDlDataForwardingX2 And TimerX2DataFwdGuard
    [Arguments]     ${new_value}
    wait until keyword succeeds    5min    10s    WEBUI Login
    ${before_value_actDlDataForwardingX2}    selenium_coam.Get_Parameter_Value
    ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...    filter_param=${parameter_actDlDataForwardingX2}
    Run keyword if    '${new_value}' == 'true'
    ...    Modify ActDlDataForwardingX2 to True And Add TimerX2DataFwdGuard
    ...    before_value=${before_value_actDlDataForwardingX2}
    Run keyword if    '${new_value}' == 'false'
    ...    Modify ActDlDataForwardingX2 to False And Remove TimerX2DataFwdGuard
    ...    before_value=${before_value_actDlDataForwardingX2}
    Perform Validate and Activate
    Run Keyword And Ignore Error    WEBUI Logout

Modify ActDlDataForwardingX2 to True And Add TimerX2DataFwdGuard
    [Arguments]   ${before_value}
    Run keyword if    '${before_value}' != 'true'   RUN KEYWORDS
    ...    selenium_coam.Set_Parameter_Value   dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...    filter_param=${parameter_actDlDataForwardingX2}    new_value=true    AND
    ...    selenium_coam.Set_Parameter_Value   dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...    filter_param=${parameter_timerX2DataFwdGuard}
    ...    ELSE    LOG    Already true!

Modify ActDlDataForwardingX2 to False And Remove TimerX2DataFwdGuard
    [Arguments]   ${before_value}
    Run keyword if    '${before_value}' != 'false'   RUN KEYWORDS
    ...    selenium_coam.Set_Parameter_Value   dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...    filter_param=${parameter_actDlDataForwardingX2}    new_value=false    AND
    ...    selenium_coam.delete_parameter    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...    filter_param=${parameter_timerX2DataFwdGuard}
    ...    ELSE    LOG    Already false!

Check Online Change Parameter Result Should Be Success
    [Arguments]    ${change_parameter_name}    ${new_parameter_value}
    wait until keyword succeeds    5min    10s    WEBUI Login
    ${curent_parameter_value}     selenium_coam.Get_Parameter_Value
    ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...    filter_param=${change_parameter_name}
    should be equal    ${curent_parameter_value}    ${new_parameter_value}
    Run Keyword And Ignore Error    WEBUI Logout

Trigger RMOD lock
    wait until keyword succeeds    5min    10s    WEBUI Login
    selenium_coam.Set_Parameter_Value    dist_name=${mrbts_id}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Administrative state    new_value=Locked
    Perform Validate And Activate
    webui logout

Trigger RMOD unlock
    wait until keyword succeeds    5min    10s    WEBUI Login
    selenium_coam.Set_Parameter_Value    dist_name=${mrbts_id}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Administrative state    new_value=Unlocked
    Perform Validate And Activate
    wait until keyword succeeds    20min   10s    Check gNB Staus onAir
    ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}  search_text=Operational state
    webui logout
#-------------------Wireshark---------------------------------------------------------------------------------
Start Collect Journal Logs For Coam
    Connect to gNB    alias=gNB
    csn.send command     command=journalctl -f > /tmp/journal.log    connection=gNB
    run keyword and ignore error  csn.disconnect    connection=gNB

Stop Collect Journal Logs For Coam
    [Arguments]    ${ute_log_path}=${ute_tmp_log_dir}    ${filename}=journal.log
    Connect to gNB    alias=gNB
    Run Keyword And Ignore Error    csn.execute     command=killall journalctl    connection=gNB
    Run Keyword And Ignore Error    csn.execute     command=chmod 777 /tmp/journal.log    connection=gNB
    csn.download_file   remote_path=/tmp/journal.log    local_path=${ute_log_path}/${filename}
    ...    connection=gNB
    sleep   30s
    Run Keyword And Ignore Error    csn.execute     command=rm /tmp/journal.log    connection=gNB
    run keyword and ignore error  csn.disconnect    connection=gNB

Modify Swconfig File
    [Arguments]    ${local_path}=${ute_tmp_log_dir}
    Run    rm ${local_path}/swconfig*
    Connect to gNB    alias=gNB
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=gNB
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=gNB
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{params_in_swconfig}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${params_in_swconfig}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=gNB
    run keyword and ignore error  csn.disconnect    connection=gNB

