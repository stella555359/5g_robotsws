*** Settings ***
Documentation    This is for Qualcomm 8250 and Sumsung s20 UEs.
...              KWs with prefix "Qualcomm" is for 8250.
...              KWs with prefix "Commercial" is for S20.
...              KWs with prefix "_" are private robot KWs.
...              Please do not modify the file without notification to author
...              Author: Lingting Sun
...              Contact: lingting.sun@nokia-sbell.com
...              Squard: AIC PCI Pallas






*** Variables ***
${QPSTexe}    "/cygdrive/c/Program Files (x86)/Qualcomm/QPST/bin/QPSTConfig.exe"



*** Keywords ***
Qualcomm UE Pre-condition
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    [Documentation]  TThis keyword is the precondition for Qualcomm ue attach,
    ...    action contain QPST start to avoid UE crash and airplane mode turn on
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
	...    modified by:        <19-May-2022>, <exuan>, <Modify wait until keyword succeeds>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  cap_index  | No |  the index from tl.ues.capabilities[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Qualcommn UE Pre-condition  |  |
    ${android_log_check}      set variable     True
    _Clean Iptabls On App Server    ue_index=${ue_index}
    wait until keyword succeeds  2min  2s  _Require UE By Index    ue_index=${ue_index}    cap_index=${cap_index}
    Is UE Connected To Control PC   ${ue_index}
    ${android_log_check}      set variable     False
    [Teardown]   run keyword if   "${android_log_check}" == "True"   run keywords   Start Catch UE Android Logs
    ...  AND   Stop Catch UE Android Logs And Save It


#_Require UE By Index
#    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
#    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
#    ...    It will read the testline tl.ues all parameter in ue_pool
#    ...    It is strongly suggested to put this keyword into the suite setup.
#    ...    If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
#    ...    Important: this keyword support multi ue , but need to config the tl.ues[xx].capability[] at least with one different value.
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    |  cap_index  | No |  the index from tl.ues.capabilities[]  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  _Require ue by index  |  |
#    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[${cap_index}]}
#    ute_ue.require Ue    ue_alias=UE_${ue_index}    capabilities=${ue_cap}


#Is UE Connected To Control PC
#    [Arguments]  ${ue_index}=${0}
#    [Documentation]  Check the UE device is connect to control pc normally.
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
#	...    modified by:        <19-May-2022>, <exuan>, <Modify wait until keyword succeeds>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  Is UE connected to control PC  |  |
#    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
#    Connect To Control PC   ${ue_index}
#    Wait Until Keyword Succeeds   2min  2s  _Is ADB Device Connected   alias=cpc_${ue_index}    serial_number=${SN}
#    [Teardown]      Run Keyword And Ignore Error     tafssh.disconnect    connection=cpc_${ue_index}


#_Is ADB Device Connected
#    [Arguments]  ${alias}    ${serial_number}
#    [Documentation]  Check the UE device connection status.
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  alias  | Yes |  the connection alias |
#    ...    |  serial_number  | Yes |  the ue serial number |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  _Is ADB device connected  |  |
#    ${result}  tafssh.execute   command=adb devices   connection=${alias}
#    log to console   ${result}
#    Should contain   ${result}   ${serial_number}
#    should not contain  ${result}   connecting


#Connect To Control PC
#    [Arguments]  ${ue_index}=${0}
#    [Documentation]  Connect To Control PC
#    ...   *Author*: lingting.sun@nokia-sbell.com
#    ...   *History Change*
#    ...   | date | who | what and how |
#    ...   | 2022-4-6 | hongysun | update documentation |
#    ...   *Arguments Description*
#    ...   | Input Parameters | Man. | Description |
#    ...   | ue_index | No | the index from tl.ues[], ${0} in default |
#    ...   *Return*
#    ...   None
#    ...   *Example*
#    ...   | Connect To Control PC |
#    Wait Until Keyword Succeeds    2min    20s
#    ...   tafssh.Connect to   ${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...                       ${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...                       ${tl.ues[${ue_index}].ssh_connection_details.password}   alias=cpc_${ue_index}


#Ue Detach By Index
#    [Arguments]  ${ue_index}=${0}
#    [Documentation]  When with UE_CAPABILITIES is REAL_ANDORID_UE,
#    ...    the keyword will send adb command to turn on the airplane mode.
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  Qualcommn UE Pre-condition  |  |
#    ...    |  Ue detach by index  |  |
#    ${detach_result}  run keyword and return status  ute_ue.detach_ue    UE_${ue_index}
#    ${tips}   set variable  Please check "service_call_attach, service_call_detach" are in __init__.py，you can refer to
#    ...  the 7_5_UTE5GAIC001T00108，if you UE android version12, please set the two parameters=17，below android12, can ignore this
#    run keyword if   "${detach_result}" == "False"   Fail   ${tips}


#Android UE Recover
#    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
#    [Documentation]  This keyword is the recovery action if ue attach failed
#    ...    action contain UE reboot and airplane mode turn on.
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    |  cap_index  | No |  the index from tl.ues.capabilities[]  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  Android UE Recover |  |
#    Is UE Connected To Control PC    ${ue_index}
#    ADB Reboot UE By Index    ${ue_index}
#    wait until keyword succeeds    10 min    10s    Is UE Connected To Control PC    ${ue_index}


#ADB Reboot UE By Index
#    [Arguments]  ${ue_index}=${0}
#    [Documentation]  Use adb command to reboot the android ue device
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  ADB Reboot UE by index  |  |
#    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
#    Connect To Control PC Interactively    ${ue_index}
#    issh.Execute     command=adb -s ${SN} reboot  check_result=${False}   alias=cpc_${ue_index}
#    [Teardown]      Run Keyword And Ignore Error    issh.disconnect   alias=cpc_${ue_index}


#Get UE MODEL
#    [Arguments]    ${ue_index}=${0}
#    [Documentation]  After UE attach success, can use this keyword to get the UE MODEL.
#    ...    author: tina.luo@nokia-sbell.com
#    ...    modified by:        <09-SEP-2020>, <tluo>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  Get UE MODEL |  |
#    ${MODEL}    Get Ue Info    UE_${ue_index}    DEVICE_MODEL
#    [return]  ${MODEL}


Qualcomm UE Attach To GNB
    [Arguments]  ${ue_index}=${0}   ${gnb_index}=0    ${vdu_index}=0    ${duration}=20s
    [Documentation]  This keyword is to perform UE attach and check the attach status.
    ...    and also one time reattach as WA for not success with ute_ue lib connect issue.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    modified by:        <09-SEP-2020>, <tluo>, <Initial creation>
    ...    modified by:        <17-SEP-2020>, <lutu>, <add qualccomm atatch verify>
    ...    modified by:        <17-May-2021>, <shojiao>, <comments qualccomm atatch method>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  duration  | No |  waiit for ADB log catch,  20s in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Qualcommn UE Pre-condition  |  |
    ...    |  Qualcomm UE Attach to GNB  |  |
    ${android_log_check}      set variable     True
    ${model}    Get UE MODEL    ${ue_index}
    run keyword if    'SM-G991U' in '${model}'   _Samsung UE Attach TDD    ${ue_index}
    ...  ELSE IF  'SM-G986U' in '${model}' or 'QUALCOMM' in '${model}'   Samsung UE Attach    ${ue_index}
    ...  ${gnb_index}    ${vdu_index}
    ${android_log_check}      set variable     False
    [Teardown]   run keyword if   "${android_log_check}" == "True"   run keywords   Start Catch UE Android Logs
    ...  AND   Stop Catch UE Android Logs And Save It



Start Catch UE Android Logs
    [Arguments]     ${ue_index}=${0}
    [Documentation]  Catch the UE android log.
    ...    author: luofei.tu@nokia-sbell.com
    ...    modified by:        <6-Apr-2022>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index        | No   |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Start Catch UE Android logs |  ${0}  |
    Connect To Control PC Interactively    ${ue_index}
    ${serial_number} =    set variable    ${tl.ues[${ue_index}].serial_number}
    ${out_put}  issh.Execute   command=rm /tmp/*Android*  check_result=${False}  alias=cpc_${ue_index}
    sleep   5s
    ${out_put1}  issh.Execute   command=adb -s ${serial_number} logcat -c  check_result=${False}  alias=cpc_${ue_index}
    Sleep  3s
    issh.Execute
    ...   command=nohup adb -s ${serial_number} logcat -b all > /tmp/Android.log &
    ...   check_result=${False}
    ...   alias=cpc_${ue_index}
    Log  INFO:Start to catch UE Android logs  console=true
    [Teardown]      Run Keyword And Ignore Error    issh.disconnect   alias=cpc_${ue_index}


Stop Catch UE Android Logs And Save It
    [Arguments]     ${ue_index}=${0}
    [Documentation]  Stop catch UE Android log and save it.
    ...    author: luofei.tun@nokia-sbell.com
    ...    modified by:        <6-Apr-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index        | No   |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Stop catch UE ADB logs and save it |  ${0}  |
    Connect To Control PC Interactively    ${ue_index}
    set test variable     ${local_file_path}     ${OUTPUT DIR}/${TEST_NAME} _Android.log
    ${out_put}  issh.Execute  command=adb kill-server logcat  check_result=${False}  alias=cpc_${ue_index}
    sleep   3s
    issh.download_file  remote_path=/tmp/Android.log  local_path=${local_file_path}   alias=cpc_${ue_index}
    Log  INFO:Stop to catch UE Android logs  console=true
    [Return]  ${local_file_path}
    [Teardown]      Run Keyword And Ignore Error    issh.disconnect   alias=cpc_${ue_index}



Samsung UE Attach
    [Arguments]  ${ue_index}=${0}   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  This keyword is to perform Samsung UE attach and check the attach status.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <28-Jan-2021>, <lingtsun>, <Initial creation>
    ...    modified by:        <13-Apr-2021>, <huilxu>, <add some l2rt log to verify>
    ...    modified by:        <13-Apr-2021>, <luofei.tu>, <add sleep >
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Samsung UE Attach |  |
    log to console    \nInfo:---------UE_${ue_index} Begin Attach ---------!
    UE Detach By Index   ${ue_index}
    sleep  10s
    wait until keyword succeeds   3x   2s    Ue Attach By Index   ${ue_index}
    sleep  180s
    wait until keyword succeeds   5min   5sec    _UE Attach Result Check TDD   ${ue_index}

#Ue Attach By Index
#    [Arguments]  ${ue_index}=${0}
#    [Documentation]  This keyword's behavior are different when using different plugins.
#    ...    If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
#    ...    author: lingting.sun@nokia-sbell.com
#    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  Qualcommn UE Pre-condition  |  |
#    ...    |  Ue attach by index |  |
#    ute_ue.attach_ue    UE_${ue_index}


Connect To PA
    [Arguments]    ${pa_index}=${0}
    ...    ${attenuation_port_numbers}=${1}    ${max_attenuation_value}=${127}
    [Documentation]  Get PA port value
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-May-2020>, <lingtsun>, <Initial creation>
    ...    modified by:        <19-May-2023>, <lingzhao>,Add Parameter Description For TOPYOUNG
    ...    | Input Parameters              | Man. | Description |
    ...    |  ${pa_index}  | No |  the index from tl.attenuators[],  ${0} in default  |
    ...    |  ${attenuation_port_numbers}  | NO   |  port numbers, int or list, TOPYOUNG support list only, default is 1  |
    ...    |  ${max_attenuation_value}     | NO   |  maximum port value, default is 127  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Connect To PA |  HBTE_0  |
    ${ip_addr}    set variable    ${tl.attenuators[${pa_index}].ip_addr}
    ${api_port}    set variable    ${tl.attenuators[${pa_index}].port}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    att.setup_attenuator    alias=${vendor}_${pa_index}    ip_addr=${ip_addr}    port=${api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}    max_attenuation=${max_attenuation_value}    vendor=${vendor}


Get PA Port Value
    [Arguments]    ${attenuator_port}    ${pa_index}=${0}
    [Documentation]  Get PA port value
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-May-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ${attenuator_port}   | Yes |  The PA port to set db value |
    ...    |  ${pa_index}  | No |  the index from tl.attenuators[],  ${0} in default  |
    ...    *RETURN VALUE*
    ...    port_value
    ...    Example
    ...    |  Get PA Port Value |  HBTE_0  |  1  |
    ${attenuator_port}=    Convert To Integer    ${attenuator_port}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    ${port_value}    att.read_attenuation    port=${attenuator_port}    attenuator_device=${vendor}_${pa_index}
    [return]  ${port_value}


Set PA Power Value
    [Arguments]    ${attenuator_port}    ${db_value}    ${pa_index}=${0}
    [Documentation]  Set PA port db value
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-May-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ${attenuator_device}  | Yes |  PA alias, Such as HBTE_0 |
    ...    |  ${attenuator_port}   | Yes |  The PA port to set db value |
    ...    |  ${pa_index}          | No |  the index from tl.attenuators[],  ${0} in default  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Set PA Power Vlaue |  HBTE_0  |  1  |  ${20}  |
    ${attenuator_port}=    Convert To Integer    ${attenuator_port}
    ${db_value}=    Convert To Integer    ${db_value}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    att.set_attenuation     port=${attenuator_port}    value=${db_value}    attenuator_device=${vendor}_${pa_index}


Start DL Data Transmission And Check Throughput
    [Documentation]      This keyword is to start DL data transmission and check throughput.
	...    author: alisha.wu@nokia-sbell.com
	...    modified by:        <26-Oct-2020>, alisha.wu@nokia-sbell.com, <Initial creation>
	...    | Input Parameters | Man. | Description |
    ...    |  ${DURATION}     | Yes   |  the duration for DL data transmission  |
	...    |  ${DL_DATA_TRANSFER}     | Yes   |  bandwidth to send at in bits/sec or packets per second  |
	...    |  ${DL_DATA}     | Yes   |  the ideal througput that ue have  |
	...    *RETURN VALUE*
	...    None
	...    Example
    ...    |  Start DL Data Transmission And Check Throughput    100    100    90 |
    [Arguments]    ${DURATION}    ${DL_DATA_TRANSFER}    ${DL_DATA}    ${cell_index}=0
    ${pods_info}=    vDU Get Pods Full Info
    ${pods_name_list}=    Get Dictionary Keys    ${pods_info}
    FOR  ${pod}  IN  @{pods_name_list}
       run keyword if    '-up-' in '${pod}'   set test variable   ${pod_name}   ${pod}
    END
    FOR  ${container}  IN  @{AIC_VDU_PODS['up']}
       run keyword if    'l2rt' in '${container}'   set test variable   ${container_name}   ${container}
    END
    log to console  Start DL Traffic and check throughput
    Start DL Traffic and check throughput
    ...   pod_name=${pod_name}   duration=${DURATION}   container_name=${container_name}
    ...   dl_data_transfer=${DL_DATA_TRANSFER}  dl_data=${DL_DATA}    cell_index=${cell_index}

Start DL Traffic and check throughput
    [Documentation]      This keyword is to start DL traffic and check throughput.
	...    author: alisha.wu@nokia-sbell.com
	...    modified by:        <26-Oct-2020>, alisha.wu@nokia-sbell.com, <Initial creation>
	...    modified by:        <18-Mar-2021>, huilin.xu@nokia-sbell.com, <modify it to be compatible with multi-cell>
	...    | Input Parameters | Man. | Description |
    ...    |  ${pod_name}     | Yes   |  VDU pod name that contain '-up-'  |
	...    |  ${duration}     | Yes   |  the duration for DL data transmission   |
	...    |  ${container_name}     | Yes   |  the container name that contain 'l2rt' |
	...    |  ${dl_data_transfer}     | Yes   |  bandwidth to send at in bits/sec or packets per second  |
	...    |  ${dl_data}    | Yes   |  the ideal througput that ue have  |
	...    *RETURN VALUE*
	...    None
	...    Example
    ...    | Start DL Traffic and check throughput    po-cran2-up-0    100    ctr-cran2-l2rt    100     90|
    [Arguments]    ${pod_name}    ${duration}  ${container_name}  ${dl_data_transfer}
    ...   ${dl_data}   ${deviation}=30%  ${deviation_1}=0.05  ${cell_index}=0
    start data transfer  dt_name=DT_DL   ue_alias=UE_0    direction=DL   duration=${duration}
    ...    throughput=${dl_data_transfer}   protocol=udp   packet_size=1024
    sleep    20s
    run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=DT_DL
    vDU Cluster Login With Tenant
    Collect vDU K8S Logs In Given Pod    ${pod_name}    L2RT_DL    ${container_name}    duration=60s

    ${cell_id_dict}    vDU Get Global Cells ID Dict
    ${global_cell_id}     Get Dictionary Values    ${cell_id_dict[${cell_index}]}
    ${dl_tput}=    get_dl_tput_from_l2_log    ${SUITE_LOG_DIRECTORY}/kubelog/${container_name}.log    ${global_cell_id[0]}
    run keyword and continue on failure    Await Data Transfer Finish    dt_name=DT_DL
    run keyword and continue on failure
    ...     Verify Average Throughput With Deviation     dt_name=DT_DL  tput=${dl_data_transfer}  deviation=${deviation}
    should be true  ${dl_tput}>=${dl_data}*(1-${deviation_1})


vDU Get Global Cells ID Dict
   [Arguments]  ${vdu_index}=0    ${gnb_index}=0
   [Documentation]      Get all avaiable cells id list.
    ...  author: lingting.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  vDU Get Cells ID list  | 0 |
    vDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cells_dict}    vdu.get_vdu_cell_id
    [Return]   ${cells_dict}
    [teardown]  vDU Rest Logout


Connect To Control PC Interactively
    [Arguments]        ${ue_index}=0
    [Documentation]  Connect To Control PC Interactively
    ...    author: shan-eric.wu@nokia-sbell.com
    ...    modified by:  <24-Mar-2021>, <shwu>, <Initial creation>
    ...    modified by:  <14-Apr-2022>, <lutu>, <add Wait Until Keyword Succeeds >
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No | Get username IP and password from ini.py, then SSH to ue control pc |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    |  Connect To Control PC Interactively  |
    ${ip}  set variable  ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${password}  set variable   ${tl.ues[${ue_index}].ssh_connection_details.password}
    ${username}  set variable   ${tl.ues[${ue_index}].ssh_connection_details.username}
    Wait Until Keyword Succeeds    5min    10s     issh.connect_to
    ...   ip=${ip}
    ...   port=22
    ...   username=${username}
    ...   password=${password}
    ...   prompt=\\$
    ...   timeout=30
    ...   width=200
    ...   alias=cpc_${ue_index}


#_Clean Iptabls On App Server
#    [Arguments]    ${ue_index}=${0}
#    ${alias}    Connect To Iperf Server
#    ${output}=   tafssh.execute    command=sudo iptables --list    connection=${alias}
#    ${is_iptabls}=   utils.Is Iptables Exist   ${output}
#    run keyword if   ${is_iptabls}==True  run keywords  log to console   clean iptables on app server   AND
#    ...  tafssh.execute    command=sudo iptables -F   connection=${alias}


_Samsung UE Attach TDD
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword is to perform Samsung UE attach and check the attach status.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <28-Jan-2021>, <lingtsun>, <Initial creation>
    ...    modified by:        <13-Apr-2021>, <huilxu>, <add some l2rt log to verify>
    ...    modified by:        <13-Apr-2022>, <luofei.tu>, <add sleep >
    ...    modified by:        <6-May-2022>, <luofei.tu>, <add   _Attach Result Check TDD>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Samsung UE Attach |  |
    log to console    \nInfo:---------UE_${ue_index} Begin Attach ---------!
    UE Detach By Index   ${ue_index}
    wait until keyword succeeds   3x   2s    Ue Attach By Index   ${ue_index}
    sleep  100s
    wait until keyword succeeds   1min   10sec    _UE Attach Result Check TDD   ${ue_index}
#    wait until keyword succeeds   5min  10sec  _UE Attached Successfully TDD    ${ue_index}

#_Get Attached UEIP
#    [Arguments]  ${ue_index}=${0}
#     [Documentation]  This keyword is to perform Get Samsung UE attach IP INFO.
#    ...    author: luofei.tu@nokia-sbell.com
#    ...    modified by:        <6-May-2022>, <lutu>, <Initial creation>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  _Get Attached UEIP |  |
#    ${ue_ip}    ute_ue.log Ue Info   UE_${ue_index}   IP
#    [Return]   ${ue_ip}

_UE Attach Result Check TDD
    [Arguments]  ${ue_index}=${0}
     [Documentation]  This keyword is to perform  check the Samsung UE attach status.
    ...    author: luofei.tu@nokia-sbell.com
    ...    modified by:        <6-May-2022>, <lutu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _UE Attach Result Check TDD|  |
    ${ue_attach_result}   run keyword and return status   get Ue Info  UE_${ue_index}    5G_STATE
    ${ue_attach_ip}     run keyword and ignore error    _Get Attached UEIP   ${ue_index}
    @{ue_attach_ip_list}      Collections.Convert To List     ${ue_attach_ip}
    run keyword if    '${ue_attach_ip_list}[0]' == 'PASS' and '${ue_attach_result}' == '${True}'
    ...  log to console    \nInfo:UE_${ue_index} Status ---------Attach Successful ${ue_attach_ip}---------!
    ...  ELSE   run keywords  log to console  \nInfo:UE_${ue_index} Status ------ Attach Fail will try to adb reboot -----!
    ...  AND  _ADB Reboot UE By Index  ${ue_index}  AND  wait until keyword succeeds   1min   10s   _Get Attached UEIP   ${ue_index}


Data Transfer Preparation
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   Get cell to lwrt mapping and nrcell to global cell mapping, and set as test variable
	...    author: lingting.sun@nokia-sbell.com
	...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
	...    | Input Parameters | Man. | Description |
   	...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
   	...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
	...    *RETURN VALUE*
	...    None
	...    Example
    ...    | Data Transfer Preparation | gnb_index=0 | vdu_index=0|
    ${cell_to_l2rt_mapping}   wait until keyword succeeds   2X  40s   Get Cell To L2RT Mapping
    ...   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable   ${cell_to_l2rt_mapping}
    ${cell_id_list}   vDU Get Global Cells ID Dict    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_id_dict}   create dictionary
    FOR  ${item}  IN  @{cell_id_list}
       ${local_cell_id}  Get Dictionary Keys  ${item}
       ${global_cell_id}  Get Dictionary values  ${item}
       set to dictionary    ${cell_id_dict}    ${local_cell_id[0]}    ${global_cell_id[0]}
    END
    set test variable    ${cell_id_dict}
    log to console   ${cell_id_dict}
    ${l2rt_container_name}   Get Full Container Name By Container Abbreviation   ctr_abbr=l2rt
    set test variable    ${l2rt_container_name}



UE Data Transfer With T-put Check For Single Cell
    [Arguments]   ${direction}  ${transfer_duration}  ${throughput}   ${expected_tput}   ${ue_index}=${0}   ${cell_index}=1
    ...   ${protocol}=udp  ${packet_size}=1024  ${interval}=20s
    ...   ${gnb_index}=0    ${vdu_index}=0   ${log_collection_duration}=60s
    [Documentation]      This keyword is to perform DL/UL data transfer and check throughput for specific cell, before that,
    ...    pls use kw Data Transfer Preparation to get the must have informations, see example:
	...    author: lingting.sun@nokia-sbell.com
	...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
	...    | Input Parameters | Man. | Description |
    ...    |  ${direction}}     | Yes   |  the direction of Data Transfer, DL or UL is supported |
	...    |  ${transfer_duration}     | Yes   |  the duration for data transmission, such as 2min |
	...    |  ${throughput}    | Yes   |  bandwidth to send at in bits/sec or packets per second, such as 160Mbits/sec  |
	...    |  ${expected_tput}     | Yes   |  the expected t-put(Mbits/sec support only), such as 50  |
	...    |  ${ue_index}   | No   |  ue index, default is ${0}  |
	...    |  ${cell_index}   | no   |  nrcell id, default is  1  |
   	...    |  ${protocol}   | no   |  default is udp  |
   	...    |  ${packet_size}   | no  |  default is  1024  |
   	...    |  ${interval}   | no  |  the interval from data transfer started and collect l2rt log, default is 20s |
   	...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
   	...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
   	...    |  ${log_collection_duration}   | no   | l2rt log collection duration, default is 60s |
	...    *RETURN VALUE*
	...    None
	...    Example
    ...    | Data Transfer Preparation | gnb_index=0 | vdu_index=0|
    ...    | UE Data Transfer With T-put Check For Single Cell | DL | 2min | 160Mbits/sec|  expected_tput=50 | cell_index=2 |
    ${dt_name}=   Start UE Data Transfer  direction=${direction}   duration=${transfer_duration}   throughput=${throughput}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
    sleep    ${interval}
    run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name}
    ${log_dir}   ${global_cell_id}=   Collect L2RT Log    cell_index=${cell_index}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...   log_collection_duration=${log_collection_duration}
    ${log_path}    set variable   ${log_dir}${l2rt_container_name}.log
    ${tput}=   _Get T-put for Specific Cell   direction=${direction}   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}   l2rt_container_name=${l2rt_container_name}
    stop_data_transfer  ${dt_name}
#    run keyword and continue on failure    should be true   ${tput}>${expected_tput}  msg=${tput} is not as expected
    should be true   ${tput}>${expected_tput}  msg=${tput} is not as expected
    [Teardown]   stop_data_transfer  ${dt_name}



Start UE Data Transfer
    [Arguments]   ${direction}  ${duration}  ${throughput}   ${ue_index}=${0}
    ...   ${protocol}=udp  ${packet_size}=1024
    log to console   Start ${direction} data transfer for UE_${ue_index}
    ${dt_name}   set variable   DT_${direction}_UE_${ue_index}
    wait until keyword succeeds   3X  10s  start data transfer  dt_name=${dt_name}   ue_alias=UE_${ue_index}
    ...   direction=${direction}   duration=${duration}
    ...   throughput=${throughput}   protocol=${protocol}   packet_size=${packet_size}
    [Return]   ${dt_name}


Collect L2RT Log
    [Arguments]   ${cell_index}=1  ${gnb_index}=0    ${vdu_index}=0   ${log_collection_duration}=60s
    log to console   Start to collect l2rt log of Cell_${cell_index}
    ${global_cell_id}    ${pod_name}   _Get Global Cell Index And L2rt Located Pod Of Specific Cell
    ...   cell_to_l2rt_mapping=${cell_to_l2rt_mapping}   cell_id_dict=${cell_id_dict}   cell_index=${cell_index}
    ${log_path}   Collect vDU K8S Logs In Given Pod   pod_name=${pod_name}   kubelog_file_name=l2rt_${pod_name}
    ...   container_name=${l2rt_container_name}   duration=${log_collection_duration}
    ...   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]   ${log_path}    ${global_cell_id}


_Get Global Cell Index And L2rt Located Pod Of Specific Cell
    [Arguments]    ${cell_to_l2rt_mapping}   ${cell_id_dict}  ${cell_index}=1   ${gnb_index}=0    ${vdu_index}=0
    ${local_cell_id}   set variable    NRCELL-${cell_index}
    ${global_cell_id}   set variable    ${cell_id_dict['${local_cell_id}']}
    ${res}    Run Keyword And Return Status    Dictionary Should Contain Key   ${cell_to_l2rt_mapping}   ${global_cell_id}
    run keyword if    '${res}'=='False'   Data Transfer Preparation    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${pod_name}    set variable   ${cell_to_l2rt_mapping['${global_cell_id}']}
    [Return]   ${global_cell_id}    ${pod_name}


_Get T-put for Specific Cell
    [Arguments]    ${direction}    ${log_path}  ${global_cell_id}   ${l2rt_container_name}
    ${tput}=   run keyword if   '${direction}'=="UL"
    ...  get_ul_tput_from_l2_log   log_path=${log_path}    cell_id=${global_cell_id}
    ...  ELSE IF   '${direction}'=="DL"  get_dl_tput_from_l2_log    log_path=${log_path}    cell_id=${global_cell_id}
    log to console  ${direction}_throughput of cell_${global_cell_id}: ${tput}
    [Return]  ${tput}


UE Data Transfer Parallel With T-put Check For Multi Cell
    [Arguments]   ${direction}  ${transfer_duration}  ${throughput}   ${expected_tput_list}   ${cell_list}   ${ue_list}
    ...   ${protocol}=udp  ${packet_size}=1024  ${interval}=20s
    ...   ${gnb_index}=0    ${vdu_index}=0   ${log_collection_duration}=60s
    [Documentation]      This keyword is to perform DL/UL data transfer parallel and check throughput for multi cell, before that,
    ...    pls use kw Data Transfer Preparation to get the must have informations, see example:
	...    author: lingting.sun@nokia-sbell.com
	...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
	...    | Input Parameters | Man. | Description |
    ...    |  ${direction}}     | Yes   |  the direction of Data Transfer, DL or UL is supported |
	...    |  ${transfer_duration}     | Yes   |  the duration for data transmission, such as 2min |
	...    |  ${throughput}    | Yes   |  bandwidth to send at in bits/sec or packets per second, such as 160Mbits/sec  |
	...    |  ${expected_tput_list}    | Yes   |  the expected t-put(Mbits/sec support only) list, such as [50, 40]  |
	...    |  ${ue_list}  | Yes  |  ue list, such as [0. 1]  |
	...    |  ${cell_list}   | Yes   |  nrcell id list, such as  [1, 2]  |
   	...    |  ${protocol}   | no   |  default is udp  |
   	...    |  ${packet_size}   | no  |  default is  1024  |
   	...    |  ${interval}   | no  |  the interval from data transfer started and collect l2rt log, default is 20s |
   	...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
   	...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
   	...    |  ${log_collection_duration}   | no   | l2rt log collection duration, default is 60s |
	...    *RETURN VALUE*
	...    None
	...    Example
    ...    | ${expected_tput_list}  | create list |   0  |  0 |
    ...    | ${cell_list}  | create list |   1  | 2 |
    ...    | ${ue_list}   | create list |   1  | 2 |
    ...    | Data Transfer Preparation | gnb_index=0 | vdu_index=0|
    ...    | UE Data Transfer Parallel With T-put Check For Multi Cell | DL | 2min | 160Mbits/sec |
    ...   expected_tput_list=${expected_tput_list} | cell_list=${cell_list} |  ue_list=${ue_list} |
    ${dt_name_list}   create list
    FOR  ${ue_index}  IN  @{ue_list}
        ${dt_name}=   Start UE Data Transfer  direction=${direction}   duration=${transfer_duration}   throughput=${throughput}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
        append to list    ${dt_name_list}     ${dt_name}
    END
    sleep    ${interval}
    FOR  ${dt_name}  IN  @{dt_name_list}
       run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name}
    END
    ${length}=    Get Length   ${cell_list}
    FOR    ${index}    IN RANGE    0    ${length}
       ${log_dir}   ${global_cell_id}=   Collect L2RT Log    cell_index=${cell_list[${index}]}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...   log_collection_duration=${log_collection_duration}
       ${log_path}    set variable   ${log_dir}${l2rt_container_name}.log
       ${tput}=   _Get T-put for Specific Cell   direction=${direction}   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}   l2rt_container_name=${l2rt_container_name}
       run keyword and continue on failure    should be true    ${tput}>${expected_tput_list[${index}]}
    END
    Stop Data Transfer for multi UE    dt_name_list=${dt_name_list}
   [Teardown]   Stop Data Transfer for multi UE    dt_name_list=${dt_name_list}


Stop Data Transfer for Multi UE
    [Arguments]   ${dt_name_list}
    FOR  ${dt_name}  IN  @{dt_name_list}
       stop_data_transfer  ${dt_name}
    END


UE Data Transfer Bidirection With T-put Check For Single Cell
    [Arguments]    ${transfer_duration}  ${throughput_DL}   ${expected_tput_DL}   ${throughput_UL}   ${expected_tput_UL}
    ...   ${ue_index}=${0}   ${cell_index}=1
    ...   ${protocol}=udp  ${packet_size}=1024  ${interval}=20s
    ...   ${gnb_index}=0    ${vdu_index}=0   ${log_collection_duration}=20s
    [Documentation]      This keyword is to perform bidirection(DL and DL at the same time) data transfer and
    ...    check throughput for specific cell, before that,
    ...    pls use kw Data Transfer Preparation to get the must have informations, see example:
	...    author: lingting.sun@nokia-sbell.com
	...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
	...    | Input Parameters | Man. | Description |
	...    |  ${transfer_duration}     | Yes   |  the duration for data transmission, such as 2min |
	...    |  ${throughput_DL}   | Yes   |  bandwidth to send at in bits/sec or packets per second for DL, such as 160Mbits/sec  |
	...    |  ${expected_tput_DL}     | Yes   |  the expected DL t-put(Mbits/sec support only), such as 150  |
	...    |  ${throughput_UL}   | Yes   |  bandwidth to send at in bits/sec or packets per second for UL, such as 160Mbits/sec  |
	...    |  ${expected_tput_UL}     | Yes   |  the expected UL t-put(Mbits/sec support only), such as 30  |
	...    |  ${ue_index}   | No   |  ue index, default is ${0}  |
	...    |  ${cell_index}   | no   |  nrcell id, default is  1  |
   	...    |  ${protocol}   | no   |  default is udp  |
   	...    |  ${packet_size}   | no  |  default is  1024  |
   	...    |  ${interval}   | no  |  the interval from data transfer started and collect l2rt log, default is 20s |
   	...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
   	...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
   	...    |  ${log_collection_duration}   | no   | l2rt log collection duration, default is 20s |
	...    *RETURN VALUE*
	...    None
	...    Example
    ...    | Data Transfer Preparation | gnb_index=0 | vdu_index=0|
    ...    | UE Data Transfer Bidirection With T-put Check For Single Cell | transfer_duration=2min | throughput_DL=160Mbits/sec |
    ...    expected_tput_DL=50 | throughput_UL=160Mbits/sec | expected_tput_UL=30 | ue_index=0 | cell_index=2 |
    ${dt_name_DL}=   Start UE Data Transfer  direction=DL   duration=${transfer_duration}   throughput=${throughput_DL}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
    ${dt_name_UL}=   Start UE Data Transfer  direction=UL   duration=${transfer_duration}   throughput=${throughput_UL}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
    sleep    ${interval}
    run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name_DL}
    run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name_UL}
    ${log_dir}   ${global_cell_id}=   Collect L2RT Log    cell_index=${cell_index}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...   log_collection_duration=${log_collection_duration}
    ${log_path}    set variable   ${log_dir}${l2rt_container_name}.log
    ${tput_DL}=   _Get T-put for Specific Cell   direction=DL   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}   l2rt_container_name=${l2rt_container_name}
    ${tput_UL}=   _Get T-put for Specific Cell   direction=UL   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}   l2rt_container_name=${l2rt_container_name}
    stop_data_transfer  ${dt_name_DL}
    stop_data_transfer  ${dt_name_UL}
    run keyword and continue on failure    should be true   ${tput_DL}>${expected_tput_DL}  msg=${tput_DL} is not as expected
    run keyword and continue on failure    should be true   ${tput_UL}>${expected_tput_UL}  msg=${tput_DL} is not as expected
    [Teardown]    Run Keywords   stop_data_transfer  ${dt_name_DL}   AND   stop_data_transfer  ${dt_name_UL}


UE Data Transfer Bidirection Parallel With T-put Check For Multi Cell
    [Arguments]   ${transfer_duration}  ${throughput_DL}   ${expected_tput_DL_list}  ${throughput_UL}   ${expected_tput_UL_list}
    ...   ${cell_list}   ${ue_list}
    ...   ${protocol}=udp  ${packet_size}=1024  ${interval}=20s
    ...   ${gnb_index}=0    ${vdu_index}=0   ${log_collection_duration}=20s
    [Documentation]      This keyword is to perform DL/UL data transfer parallel and check throughput for multi cell, before that,
    ...    pls use kw Data Transfer Preparation to get the must have informations, see example:
	...    author: lingting.sun@nokia-sbell.com
	...    modified by:        <07-Mar-2023>, lingting.sun@nokia-sbell.com, <Initial creation>
	...    | Input Parameters | Man. | Description |
    ...    |  ${direction}}     | Yes   |  the direction of Data Transfer, DL or UL is supported |
	...    |  ${transfer_duration}     | Yes   |  the duration for data transmission, such as 2min |
	...    |  ${throughput_DL}   | Yes   |  bandwidth to send at in bits/sec or packets per second for DL, such as 160Mbits/sec  |
	...    |  ${expected_tput_DL_list}     | Yes   |  the expected DL t-put(Mbits/sec support only) list, such as [150, 150]  |
	...    |  ${throughput_UL}   | Yes   |  bandwidth to send at in bits/sec or packets per second for UL, such as 160Mbits/sec  |
	...    |  ${expected_tput_UL}     | Yes   |  the expected UL t-put(Mbits/sec support only) list, such as [30, 30]  |
	...    |  ${ue_list}  | Yes  |  ue list, such as [0. 1]  |
	...    |  ${cell_list}   | Yes   |  nrcell id list, such as  [1, 2]  |
   	...    |  ${protocol}   | no   |  default is udp  |
   	...    |  ${packet_size}   | no  |  default is  1024  |
   	...    |  ${interval}   | no  |  the interval from data transfer started and collect l2rt log, default is 20s |
   	...    |  ${gnb_index}   | no   |  gnn index, default is 0  |
   	...    |  ${vdu_index}   | no  |  vdu index, default is 0 |
   	...    |  ${log_collection_duration}   | no   | l2rt log collection duration, default is 20s |
	...    *RETURN VALUE*
	...    None
	...    Example
    ...    | ${expected_tput_list}  | create list |   0  |  0 |
    ...    | ${cell_list}  | create list |   1  | 2 |
    ...    | ${ue_list}   | create list |   1  | 2 |
    ...    | Data Transfer Preparation | gnb_index=0 | vdu_index=0|
    ...    | UE Data Transfer Bidirection Parallel With T-put Check For Multi Cell | DL | 2min | 160Mbits/sec |
    ...   expected_tput_list=${expected_tput_list} | cell_list=${cell_list} |  ue_list=${ue_list} |
    ${dt_name_DL_list}   create list
    ${dt_name_UL_list}   create list
    FOR  ${ue_index}  IN  @{ue_list}
        ${dt_name_DL}=   Start UE Data Transfer  direction=DL   duration=${transfer_duration}   throughput=${throughput_DL}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
        ${dt_name_UL}=   Start UE Data Transfer  direction=UL   duration=${transfer_duration}   throughput=${throughput_UL}
    ...     ue_index=${ue_index}    protocol=${protocol}   packet_size=${packet_size}
        append to list    ${dt_name_DL_list}    ${dt_name_DL}
        append to list    ${dt_name_UL_list}    ${dt_name_UL}
    END
    sleep    ${interval}
    FOR  ${dt_name_DL}  IN  @{dt_name_DL_list}
       run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name_DL}
    END
    FOR  ${dt_name_UL}  IN  @{dt_name_UL_list}
       run keyword and continue on failure     Check Data Transfer Is Alive   dt_name=${dt_name_UL}
    END
    ${length}=    Get Length   ${cell_list}
    FOR    ${index}    IN RANGE    0    ${length}
       ${log_dir}   ${global_cell_id}=   Collect L2RT Log    cell_index=${cell_list[${index}]}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...   log_collection_duration=${log_collection_duration}
       ${log_path}    set variable   ${log_dir}${l2rt_container_name}.log
       ${tput_DL}=   _Get T-put for Specific Cell   direction=DL   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}   l2rt_container_name=${l2rt_container_name}
       ${tput_UL}=   _Get T-put for Specific Cell   direction=UL   log_path=${log_path}
    ...   global_cell_id=${global_cell_id}   l2rt_container_name=${l2rt_container_name}
       run keyword and continue on failure    should be true    ${tput_DL}>${expected_tput_DL_list[${index}]}
       run keyword and continue on failure    should be true    ${tput_UL}>${expected_tput_UL_list[${index}]}
    END
    Stop Data Transfer for multi UE    dt_name_list=${dt_name_DL_list}
    Stop Data Transfer for multi UE    dt_name_list=${dt_name_UL_list}
   [Teardown]   Run Keywords    Stop Data Transfer for multi UE    dt_name_list=${dt_name_DL_list}   AND
   ...   Stop Data Transfer for multi UE    dt_name_list=${dt_name_UL_list}


Get UE Attached Global Cell Id
    [Arguments]    ${ue_index}=${0}
    [Documentation]  After UE attach success, can use this keyword to get the UE attached global cell id.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <09-Mar-2023>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Get UE Attached Global Cell Id |  |
    ${attached_cell_id}    Get Ue Info    UE_${ue_index}    CELL_ID
    [return]  ${attached_cell_id}
