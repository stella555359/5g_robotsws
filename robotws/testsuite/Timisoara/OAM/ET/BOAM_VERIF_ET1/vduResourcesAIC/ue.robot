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
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  cap_index  | No |  the index from tl.ues.capabilities[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Qualcommn UE Pre-condition  |  |
    _Require UE By Index    ue_index=${ue_index}    cap_index=${cap_index}
    Is UE Connected To Control PC   ${ue_index}


_Require UE By Index
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
    ...    It will read the testline tl.ues all parameter in ue_pool
    ...    It is strongly suggested to put this keyword into the suite setup.
    ...    If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...    Important: this keyword support multi ue , but need to config the tl.ues[xx].capability[] at least with one different value.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  cap_index  | No |  the index from tl.ues.capabilities[]  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Require ue by index  |  |
    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ute_ue.require Ue    ue_alias=UE_${ue_index}    capabilities=${ue_cap}


Is UE Connected To Control PC
    [Arguments]  ${ue_index}=${0}
    [Documentation]  Check the UE device is connect to control pc normally.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Is UE connected to control PC  |  |
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    Connect To Control PC    ${ue_index}
    _Is ADB Device Connected   alias=cpc_${ue_index}    serial_number=${SN}
    tafssh.disconnect   connection=cpc_${ue_index}


_Is ADB Device Connected
    [Arguments]  ${alias}    ${serial_number}
    [Documentation]  Check the UE device connection status.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | Yes |  the connection alias |
    ...    |  serial_number  | Yes |  the ue serial number |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Is ADB device connected  |  |
    tafssh.send_command   command=adb devices    connection=${alias}    timeout=15
    Sleep   3s
    ${result}    tafssh.read output    connection=${alias}
    Should contain   ${result}   ${serial_number}
    should not contain  ${result}   connecting


Connect To Control PC
    [Arguments]  ${ue_index}=${0}
    [Documentation]  connect the control PC
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Connect to control pc  |  |
    Wait Until Keyword Succeeds    2min    20s
    ...   tafssh.Connect to   ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...                       ${tl.ues[${ue_index}].ssh_connection_details.username}
    ...                       ${tl.ues[${ue_index}].ssh_connection_details.password}   alias=cpc_${ue_index}


Ue Detach By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  When with UE_CAPABILITIES is REAL_ANDORID_UE,
    ...    the keyword will send adb command to turn on the airplane mode.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Ue detach by index  |  |
    ute_ue.detach_ue    UE_${ue_index}


Android UE Recover
    [Arguments]  ${ue_index}=${0}    #${cap_index}=${0}
    [Documentation]  This keyword is the recovery action if ue attach failed
    ...    action contain UE reboot and airplane mode turn on.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  cap_index  | No |  the index from tl.ues.capabilities[]  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Android UE Recover |  |
    Is UE Connected To Control PC    ${ue_index}
    ADB Reboot UE By Index    ${ue_index}
    wait until keyword succeeds    3 min    10s    Is UE Connected To Control PC    ${ue_index}


ADB Reboot UE By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  Use adb command to reboot the android ue device
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  ADB Reboot UE by index  |  |
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    Connect To Control PC    ${ue_index}
    tafssh.execute    command=adb -s ${SN} reboot   connection=cpc_${ue_index}
    tafssh.disconnect   connection=cpc_${ue_index}


Get UE MODEL
    [Arguments]    ${ue_index}=${0}
    [Documentation]  After UE attach success, can use this keyword to get the UE MODEL.
    ...    author: tina.luo@nokia-sbell.com
    ...    modified by:        <09-SEP-2020>, <tluo>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Get UE MODEL |  |
    ${MODEL}    Get Ue Info    UE_${ue_index}    DEVICE_MODEL
    [return]  ${MODEL}


Qualcomm UE Attach To GNB
    [Arguments]  ${ue_index}=${0}   ${gnb_index}=0    ${vdu_index}=0    #${duration}=20s
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
    ...    |  Qualcomm UE Attach to GNB  |  |
    ${model}    Get UE MODEL    ${ue_index}
    Samsung UE Attach    ${ue_index}    ${gnb_index}    ${vdu_index}
    #run keyword if    'QUALCOMM' in '${model}'    Qualcomm UE Attach    ${ue_index}    ${duration}


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
    Ue Attach By Index    ${ue_index}
    sleep  90s
    ${handle}    Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    Get Container Name Prefix

    Android UE Recover    ${ue_index}
    sleep  30s
    ${local_l2rt_file}    End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${number_1}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'UE attached' | wc -l
    run keyword and continue on failure   should be true   ${number_1}==1

    ${out}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'UE attached'
    ${result}  Get Regexp Matches    ${out}    rnti=(\\d+)   1
    ${rnti_number}  Set Variable If  ${result}   ${result[0]}
    log to console   rnti_number is ${rnti_number}

    ${number_2}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'UserDelete::execute: rnti=${rnti_number}' | wc -l
    run keyword and continue on failure   should be true   ${number_2}==0

Is UE Attached To 4G Successfully Via ADB Command
    [Arguments]  ${ue_index}=${0}
    [Documentation]  Verify 4G UE network type normal by ADB command.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Is UE attached to 4G successfully via adb command  |  |
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    tafssh.send command
    ...    command=adb -s ${SN} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}
    ...    timeout=10
    ${result} =    tafssh.read output    connection=cpc_${ue_index}
    Should contain  ${result}  LTE
    Log to console    \nINFO:4G UE ATTACH successfully.


Ue Attach By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...    If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Ue attach by index |  |
    run keyword and return status  ute_ue.attach_ue    UE_${ue_index}


Start UL Traffic Via Iperf From Andriod UE
    [Arguments]    ${ul_port}    ${ul_throughput}    ${ul_length}    ${ue_index}=${0}    #${ul_duration}
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  ul_duration  | Yes |  ul data transfer duration |
    ...    |  ul_port  | Yes |  ul data transfer connection port |
    ...    |  ul_throughput  | Yes|  ul data transfer throughput |
    ...    |  ul_length  | Yes |  buffer length |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Start UL traffic via iperf from andriod UE |  |
    Connect To Control PC    ${ue_index}
    ${appserver_addr} =    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    tafssh.send command
    ...    command=adb shell iperf -c ${appserver_addr} -u -t ${dl_duration} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    ...    connection=cpc_${ue_index}
    [Teardown]    tafssh.disconnect    connection=cpc_${ue_index}


Start DL Traffic Via Iperf on Iperf erver
    [Arguments]     ${dl_duration}    ${dl_port}    ${dl_throughput}    ${dl_length}    ${ue_addr}=${0}
    [Documentation]   This keyword Connect to Iperf server and start the iperf data.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ue_index  | No |  the index from tl.ues[],  ${0} in default |
    ...    |  dl_duration  | Yes |  dl data transfer duration |
    ...    |  dl_port  | Yes |  dl data transfer connection port |
    ...    |  dl_throughput  | Yes|  dl data transfer throughput |
    ...    |  dl_length  | Yes |  buffer length |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Start DL traffic via iperf on Iperf server |  |
    wait until keyword succeeds    1 min    10 sec    Connect To Iperf Server
    tafssh.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs sudo kill -9    connection=APPserver
    tafssh.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_duration} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    [Teardown]    tafssh.disconnect    connection=APPserver


Connect To Iperf Server
    [Arguments]    ${ue_index}=${0}    ${alias}=APPserver
    [Documentation]  connect to iperf server
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <31-Mar-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No |  appserver alias, APPserver in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Connect to Iperf server |  |
    tafssh.Connect to    hostname=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...               username=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ...               alias=${alias}


Connect To PA
    [Arguments]    ${pa_index}=${0}
    ...    ${attenuation_port_numbers}=${1}    ${max_attenuation_value}=${127}
    [Documentation]  Get PA port value
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-May-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters              | Man. | Description |
    ...    |  ${pa_index}  | No |  the index from tl.attenuators[],  ${0} in default  |
    ...    |  ${attenuation_port_numbers}  | NO   |  port numbers, default is 1  |
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
    ...   ${dl_data}   ${deviation}=5%  ${deviation_1}=0.05  ${cell_index}=0
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
   [Arguments]  ${vdu_index}=0
   [Documentation]      Get all avaiable cells id list.
    ...  author: lingting.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  vDU Get Cells ID list  | 0 |
    vDU Rest Login    vdu_index=${vdu_index}
    ${cells_dict}    vdu.get_vdu_cell_id
    [Return]   ${cells_dict}
    [teardown]  vDU Rest Logout


Connect To IPSL PC
    [Arguments]  ${alias}=IPSLserver
    [Documentation]  connect the IPSL PC
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <11-Mar-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No |  the alias for IPSL Server,  IPSLserver in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Connect To IPSL PC  |  |
    Wait Until Keyword Succeeds    2min    20s
    ...   tafssh.Connect to   ${IPSL_SERVER}
    ...                       ${IPSL_USERNAME}
    ...                       ${IPSL_PASSWORD}   alias=${alias}


Kill IPSL Server on PC
    [Arguments]  ${alias}=IPSLserver
    [Documentation]  Kill IPSL Server on PC
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <11-Mar-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No |  the alias for IPSL Server,  IPSLserver in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Kill IPSL Server on PC  |  |
    Connect To IPSL PC
    ${output} =    tafssh.execute    command=taskkill /F /IM ips32.exe    connection=${alias}
    Run Keyword and return status    Should contain  ${output}   has been terminated

Start IPSL Server on PC
    #[Arguments]  ${alias}=IPSLserver
    [Documentation]  Start IPSL Server on PC
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <11-Mar-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No |  the alias for IPSL Server,  IPSLserver in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Start IPSL Server on PC  |  |
    ${check_status}=   Check IPSL Server is existing
    log to console    ${check_status}
    run keyword if     '${check_status}'=='False'     Restart IPSL PC to start IPSL Server


Restart IPSL PC to start IPSL Server
    [Arguments]  ${alias}=IPSLserver
    [Documentation]  Restart IPSL PC to start IPSL Server
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <11-Mar-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No |  the alias for IPSL Server,  IPSLserver in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Restart IPSL PC to start IPSL Server  |  |
    tafssh.execute    command=shutdown -r    connection=${alias}
    sleep     60s
    wait until keyword succeeds   10 times    15sec    Check IPSL PC is up
    wait until keyword succeeds   5 times    15sec      Check IPSL Server is existing


Check IPSL PC is up
    [Documentation]  Check IPSL PC is up
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <11-Mar-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  None  | No |  None |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check IPSL PC is up  |  |
    ${ping_res}   OperatingSystem.Run   command=ping ${IPSL_SERVER} -c 3
    should not match regexp   ${ping_res}   0 received, 100% packet loss

Check IPSL Server is existing
    [Arguments]  ${alias}=IPSLserver
    [Documentation]  Check IPSL Server is existing
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <11-Mar-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No |  the alias for IPSL Server,  IPSLserver in default |
    ...    *RETURN VALUE*
    ...    check_status
    ...    Example
    ...    |  ${check_status}=   Check IPSL Server is existing  |  |
    Connect To IPSL PC
    ${output} =    tafssh.execute    command=tasklist | grep "ips32.exe" | grep -v grep    connection=${alias}
    ${check_status}=    run keyword and return status    Should contain  ${output}   ips32.exe
    [Return]  ${check_status}

Connect to control pc interactively
    [Arguments]        ${ue_index}=0    ${alias}=default
    [Documentation]  Connect to control pc interactively
    ...    author: shan-eric.wu@nokia-sbell.com
    ...    modified by:  <24-Mar-2021>, <shwu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No | Get username IP and password from ini.py, then SSH to ue control pc |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    |  Connect to control pc interactively  |
    ${ip}  set variable  ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${password}  set variable   ${tl.ues[${ue_index}].ssh_connection_details.password}
    ${username}  set variable   ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${alias}   issh.connect_to    ip=${ip}   port=22    username=${username}   password=${password}    prompt=\\$     timeout=30s

Set Attenuation Value For xG All Ports
    [Arguments]    ${xgport_list_obj}      ${db_value}    ${pa_index}
    [Documentation]   Set Attenuation Value For xG All Ports
    ...    author: shan-eric.wu@nokia-sbell.com
    ...    modified by:  <24-Mar-2021>, <shwu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No | Get username IP and password from ini.py, then SSH to ue control pc |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    |  Set Attenuation Value For xG All Ports  ${xgport_list_obj}    127   0  |
    @{xgport_list}    Create List
    FOR     ${ports_object}    IN     @{xgport_list_obj}
        Append To List   ${xgport_list}     ${ports_object.port_no}
    END
    log many     ${xgport_list}
    # set att value
    FOR    ${port_index}    IN     @{xgport_list}
        Set PA Power Value    ${port_index}    ${db_value}    ${pa_index}
    END
    #\    Sleep    1s

Get ADB Devices Infor
    #[Arguments]    ${ue_index}=0    ${alias}=default
    [Documentation]   Get ADB Devices Infor
    ...    author: shan-eric.wu@nokia-sbell.com
    ...    modified by:  <9-June-2021>, <shwu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  alias  | No | Get username IP and password from ini.py, then SSH to ue control pc |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    |  Get ADB Devices Infor  |
    Connect to control pc interactively     alias=${alias_1}
    Run Keyword And Ignore Error     issh.Execute    command=adb devices     alias=${alias_1}
    [Teardown]      Run Keyword And Ignore Error    issh.disconnect  alias=${alias_1}


Samsung UE Trun Off AirPlane Mode
    #[Arguments]    ${ue_index}=0    ${alias}=default
    [Documentation]      This keyword is to recover the Samsung UE via update the airplane mode.
    ...  author: lingting.sun@nokia-sbell.com
    ...    modified by:  <27-Oct-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | No. |specify which vdu needs to be check if the testline configed multi vdus |
    ...       | alias     | No. |UE PC connection alias                                                   |
    ...    *RETURN VALUE*
    ...    Example
    ...    |  Samsung UE Trun Off AirPlane Mode  |
    ${initial_airplane_mode}=    Get Samsung UE AirPlane Mode
    run keyword if    '${initial_airplane_mode}'=='0'    run keywords    Update Samsung UE AirPlane Mode Status
    ...    Get Samsung UE AirPlane Mode
    Update Samsung UE AirPlane Mode Status
    ${final_airplane_mode}    Get Samsung UE AirPlane Mode
    should be equal    ${final_airplane_mode}   0   Failed to turn off Airplane mode!!!!


Get Samsung UE AirPlane Mode
    [Arguments]    ${ue_index}=0    ${alias}=default
    [Documentation]      This keyword is to get the Samsung UE airplane mode.
    ...  author: lingting.sun@nokia-sbell.com
    ...    modified by:  <27-Oct-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...       | ue_index | No. |specify which ue                                                          |
    ...       | alias     | No. |UE PC connection alias                                                   |
    ...    *RETURN VALUE*
    ...    |airplane_mode | 0 is off | 1 is on |
    ...    Example
    ...    |  Get Samsung UE AirPlane Mode  |
    ${SN} =    Get UE Serical Number From Test Line    ${ue_index}
    Connect to control pc interactively    ${ue_index}   alias=${alias}
    ${cmd} =    set variable    adb -s ${SN} shell settings get global airplane_mode_on
    ${output}    issh.Execute    command=${cmd}     alias=${alias}
    ${output}   Get Regexp Matches    ${output}    \\n\\d\\r
    ${aiplane_mod}    Get Regexp Matches    ${output[0]}    \\d
    [Return]    ${aiplane_mod[0]}
    [Teardown]   Disconnect Interactive Connection  alias=${alias}


Update Samsung UE AirPlane Mode Status
    [Arguments]    ${ue_index}=0    ${alias}=default
    [Documentation]      This keyword is to update the Samsung UE airplane mode.
    ...  author: lingting.sun@nokia-sbell.com
    ...    modified by:  <27-Oct-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | No. |specify which vdu needs to be check if the testline configed multi vdus |
    ...       | alias     | No. |UE PC connection alias                                                   |
    ...    *RETURN VALUE*
    ...    Example
    ...    |  Update Samsung UE AirPlane Mode Status  |
    ${SN} =    Get UE Serical Number From Test Line    ${ue_index}
    Connect to control pc interactively    ${ue_index}   alias=${alias}
    issh.Execute    command=adb -s ${SN} shell input keyevent KEYCODE_WAKEUP     alias=${alias}
    issh.Execute    command=adb -s ${SN} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS --activity-clear-task    alias=${alias}
    issh.Execute    command=adb -s ${SN} shell input keyevent KEYCODE_DPAD_UP     alias=${alias}
    issh.Execute    command=adb -s ${SN} shell input keyevent KEYCODE_DPAD_DOWN    alias=${alias}
    issh.Execute    command=adb -s ${SN} shell input keyevent KEYCODE_DPAD_CENTER     alias=${alias}
    issh.Execute    command=adb -s ${SN} shell input keyevent KEYCODE_BACK   alias=${alias}
    sleep   3s
    [Teardown]   Disconnect Interactive Connection  alias=${alias}


Get UE Serical Number From Test Line
    [Arguments]    ${ue_index}=0
    [Documentation]      This keyword is to get the serial number of UE.
    ...  author: lingting.sun@nokia-sbell.com
    ...    modified by:  <27-Oct-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | No. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    |SN |
    ...    Example
    ...    |  Get UE Serial Number  |
    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
    [Return]   ${SN}


Set Power Break Status
    [Arguments]    ${model}   ${pdu_ip}   ${pdu_port}   ${set_status}=off
    [Documentation]      This keyword is to set PB status.
    ...  author: rui.3.li@nokia-sbell.com
    ...    modified by:  <13-12-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | model | YES. |PB model, such as 'TOPYOUNG' |
    ...    | pdu_ip | YES. | PB ip address, such as '10.97.126.240' |
    ...    | pdu_port | YES. | The modifying port of PB, such as '3' |
    ...    | set_status | No. | Modifying status of PB |
    ...    *RETURN VALUE*
    ...    | pdu status after modify |
    ...    Example
    ...    |  Set Power Break Status  | TOPYOUNG | 10.97.126.240 | 3 |
    Log To Console    Power ${set_status} RU
    ${alias}   get unique id
    ${set_status}    Set Variable    ${set_status.upper()}
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=${alias}
    Run Keyword If  '${set_status}'=='OFF'   pdu.Power Off    port=${pdu_port}    pdu_device=${alias}
    ...    ELSE IF  '${set_status}'=='ON'    pdu.Power On     port=${pdu_port}    pdu_device=${alias}
    ...    ELSE   fail   input param error, ${set_status} only in ['off', 'on']
    Sleep    10s
    ${pdu_status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=${alias}
    [Return]    ${pdu_status}


Get Power Break Status
    [Arguments]    ${model}   ${pdu_ip}   ${pdu_port}
    [Documentation]      This keyword is to get PB status.
    ...  author: rui.3.li@nokia-sbell.com
    ...    modified by:  <13-12-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | model | YES. |PB model, such as 'TOPYOUNG' |
    ...    | pdu_ip | YES. | PB ip address, such as '10.97.126.240' |
    ...    | pdu_port | YES. | The modifying port of PB, such as '3' |
    ...    *RETURN VALUE*
    ...    | pdu status |
    ...    Example
    ...    |  Get Power Break Status  | TOPYOUNG | 10.97.126.240 | 3 |
    ${alias}   get unique id
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=${alias}
    ${pdu_status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=${alias}
    [Return]    ${pdu_status}
