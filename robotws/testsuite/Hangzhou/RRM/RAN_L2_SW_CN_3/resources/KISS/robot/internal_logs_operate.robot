*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library     BuiltIn
Library     OperatingSystem
Library     String
Library     taf.transport.ssh    WITH NAME    SSH
Library     taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    VDU
Resource    base.robot
Resource    common_airphone.robot
Resource    common_gnb.robot

*** Variables ***
${TCPDUMP_NAME}      common_tcpdump
${BIP_CMD}           tcpdump -i
${FILES_BASE_LINK}             http://files.ute.nsn-rdnet.net/builds/enb/base
${FILES_BASE_LINK_BRANCHES}    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public/System_Release

*** Keywords ***
_Start BIP Log On ASIK Or ASIB
    [Arguments]    ${script_path}=${SCRIPT_PATH}/shell    ${duration}=infinite
    _Clear The BIP File Dir In GNB
    Log To Console    INFO:Start GNB BIP Log...
    Modify File Parameter    ${script_path}/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=([0-9]+|[a-z]+)   CAPTURING_TIME_SECONDS=${duration}
    Modify File Parameter    ${script_path}/gnbMirroring.sh    tcpdumpL2L1    5GBipL2L1
    Run keyword Unless     &{GNBMIRRORINGCONFIGS}==&{EMPTY}    Modify File List Paramters    ${script_path}/gnbMirroringConfig.sh
    ...    ${GNBMIRRORINGCONFIGS}
    Run Keyword If    '${ASP_BOARD_TYPE[0]}'=='ABIO'    _Modify BIP Script File For ABIO    ${script_path}
    Run Keyword If    '${ASP_BOARD_TYPE[0]}'=='ABIO'    Set Gnb Side SEI1 Port
    OperatingSystem.Run    sshpass -p ${GNB_ASIK.password} scp ${script_path}/* ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/config/scripts/
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=BIP_ASIK_Start
    SSH.Execute    command=chmod +x /ffs/run/config/scripts/*.sh    connection=BIP_ASIK_Start
    ${exec_script}      set variable if
	...    '${ASP_BOARD_TYPE[0]}'=='ABIO' and '${L1_TYPE}'=='L1b'     ABIO_BIP_mirroring.sh 1
	...    '${FCT_BOARD_TYPE}'=='ASIB' and '${L1_TYPE}'=='L1b'     bip_asib_abil.sh
	...     gnbMirroring.sh
	${sh_cmd}    Set Variable    sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &
    Run Keyword If    '${duration}'!='infinite'    SSH.Send Command    command=timeout ${duration} ${sh_cmd}    connection=BIP_ASIK_Start
    Run Keyword If    '${duration}'=='infinite'    SSH.Send Command    command=${sh_cmd}    connection=BIP_ASIK_Start
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    filtering_off    ${BIP_CMD}    BIP_ASIK_Start
    SSH.Disconnect    connection=BIP_ASIK_Start
    Log To Console   INFO:bip start success...

_upload_sh_to_gnb_and_execute_sh
    [Arguments]    ${script_path}=${SCRIPT_PATH}/shell    ${duration}=infinite
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=BIP_ASIL_Start
    ${sh_path}    Set Variable    /ffs/run/config/scripts/bip_ASIL_ABIO.sh
    SSH.upload_file     local_path=${script_path}/bip_ASIL_ABIO.sh      remote_path=${sh_path}	connection=BIP_ASIL_Start
    Process.Start Process    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} timeout ${duration} sh ${sh_path}   shell=True

_Start BIP Log On ASIL
    [Arguments]    ${script_path}=${SCRIPT_PATH}/shell    ${duration}=infinite
    Log To Console    Start bip log on ASIL...
    Run Keyword If    '${duration}'!='infinite'     _upload_sh_to_gnb_and_execute_sh      ${script_path}    ${duration}
	${cmd}    Set Variable    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} <${script_path}/bip_ASIL_ABIO.sh
    Run Keyword If    '${duration}'=='infinite'     Process.Start Process    ${cmd}   shell=True
    ${cmd}    Set Variable    tcpdump -i nac_eth2 -w /tmp/5GBip
    Wait Until Keyword Succeeds    20s    2s    _Verify Process Is Running On Gnb    filtering_off    ${cmd}

_Stop BIP Log On ASIK Or ASIB
    [Arguments]    ${log_dir}
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=BIP_ASP_End
    Wait Until Keyword Succeeds    6s    0.1s    Kill And Verify Process Stop Success    filtering_off    ${BIP_CMD}    BIP_ASP_End
    Run Keyword If                '${log_dir}'!='${TEST_LOG_DIRECTORY()}'    Create Directory    ${log_dir}
    ${bip_counts}    _Copy BIP Files And Return Count    ${log_dir}
    SSH.Disconnect    connection=BIP_ASP_End
    [Return]    ${bip_counts}

_Stop BIP Log On ASIL
    [Arguments]    ${log_dir}
    ${cmd}    Set Variable    tcpdump -i nac_eth2 -w /tmp/5GBip
    Wait Until Keyword Succeeds    6s    2s    _Kill Process On Gnb    filtering_off    ${cmd}
    Run Keyword If    '${log_dir}'!='${TEST_LOG_DIRECTORY()}'    Create Directory    ${log_dir}
    ${bip_counts}    _Copy BIP Files And Return Count    ${log_dir}
    [Return]    ${bip_counts}

_Copy BIP Files And Return Count
    [Arguments]    ${path}
    [Documentation]    This keyword is to copy BIP file to ${path} and return the count
    Log    copy bip files to ${path}...
    OperatingSystem.Run    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/tmp/*filtering_off.pcap* ${path}
    ${count}    OperatingSystem.Count Items In Directory    ${path}    pattern=*filtering_off.pcap*
    [Return]    ${count}

_Clear The BIP File Dir In GNB
    [Documentation]    This keyword is to clear bip files in gnb /ffs/run/config/scripts if exists.
    ...    As well as the log files /tmp/*filtering_off*
    ...    Notice: just available in keyword Start GNB BIP Log
    ...    Examples:
    ...    | _Clear The BIP File Dir In GNB |
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=ClearBip_ASIK
    SSH.Execute    command=rm /tmp/*filtering_off*    connection=ClearBip_ASIK
    SSH.Execute    command=rm -rf /ffs/run/config/scripts    connection=ClearBip_ASIK
    SSH.Execute    command=mkdir /ffs/run/config/scripts    connection=ClearBip_ASIK
    SSH.Disconnect    connection=ClearBip_ASIK
    Log To Console    clear default bip scripts done...

_Modify BIP Script File For ABIO
    [Arguments]    ${script_path}=${SCRIPT_PATH}/shell
    [Documentation]    This keyword is to modify BIP scripts for ABIO
    ...    Examples:
    ...    | _Modify BIP Script File For ABIO | ./BIP |
    ${gnb_pos}    Get GNB Position
    ${fsp_slot_id}    Set Variable If    '${gnb_pos}'=='right_side'    5    1
    Modify File Parameter    ${script_path}/gnbMirroringConfig.sh    BB_BOARD_TYPE='[A-Z]+'    BB_BOARD_TYPE='ABIO'
    ${ul_mirror_regexp}    Set Variable    lfs-nw_switch-mirror-tool\\.sh -p 0 -d ethsei02 -f L1_L2_UL -b \\"C1B2\\(1\\)\\" -s \\d -l eths2
    ${new_ul_mirror}    Set Variable    lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B2(1)" -s ${fsp_slot_id} -l eths2
    ${dl_mirror_regexp}    Set Variable    lfs-nw_switch-mirror-tool\\.sh -p 0 -d ethsei02 -f L1_L2_DL -b \\"C1B2\\(1\\)\\" -s \\d -l eths2
    ${new_dl_mirror}    Set Variable    lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B2(1)" -s ${fsp_slot_id} -l eths2
    Modify File Parameter    ${script_path}/gnbMirroring.sh    ${ul_mirror_regexp}    ${new_ul_mirror}
    Modify File Parameter    ${script_path}/gnbMirroring.sh    ${dl_mirror_regexp}    ${new_dl_mirror}

_Copy GNB Files And Return Status
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy GNB log to ${log_dir}
    ...    Examples:
    ...    | ${count}= | _Copy GNB Files And Return Status | /tmp |
    OperatingSystem.Run    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/tmp/gnbL3.pcap ${log_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/gnbL3.pcap
    [Return]    ${res}

_Copy WTS Files And Return Status
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy WTS log to ${log_dir}
    ...    Examples:
    ...    | ${count}= | _Copy WTS Files And Return Status | /tmp |
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:/tmp/wts.pcap ${log_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/wts.pcap
    [Return]    ${res}

_Check Suscess Msg Exist
    [Arguments]    ${file_path}    ${success_msg}
    [Documentation]    This keyword is to check a msg exsit in a file
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | the file path need to check |
    ...    | ${success_msg} | Yes | the message need to check |
    ...    Examples:
    ...    | _Check Suscess Msg Exist | ${TEMPDIR}${/}stop_stdout.txt | You can now start your tests in egate |
    ${ret}    OperatingSystem.Grep File    ${file_path}    ${success_msg}
    Should Not Be Empty    ${ret}

_Download GNB Luashark Tool
    [Documentation]     Download GNB Luashark tool and unzip.
    ...    Examples:
    ...    | _Download GNB Luashark Tool |
    ${url}=    _Get Base Downalod URL Address
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${sub_link}    Set Variable If    '${sw_list[2]}'=='9999'    ${SW_VERSION_TOTAL}    '${sw_list[2]}'!='9999'    ${SOFTWARE_INFO}
    ${file_name}    Set Variable If    '${sw_list[2]}'=='9999'    ${sub_link}_luashark.zip    luashark-${SW_VERSION_TOTAL}.zip
    @{path}=    Split String    ${GNB_LUA_SHARK_STORE_PATH}    /
    OperatingSystem.Run    sudo chmod 777 -R /${path[1]}
    ${status}    ${value}    Run Keyword And Ignore Error    Directory Should Exist    ${GNB_LUA_SHARK_STORE_PATH}
    Run Keyword If    '${status}'=='PASS'    Remove Directory    ${GNB_LUA_SHARK_STORE_PATH}    ${True}
    Create Directory    ${GNB_LUA_SHARK_STORE_PATH}
    OperatingSystem.Run     wget -P ${GNB_LUA_SHARK_STORE_PATH} -q "${url}/${SW_VERSION_TOTAL}/${file_name}"
	OperatingSystem.Run     unzip ${GNB_LUA_SHARK_STORE_PATH}/${file_name} -d ${GNB_LUA_SHARK_STORE_PATH}
	OperatingSystem.Run     rm ${GNB_LUA_SHARK_STORE_PATH}/${file_name}

_Download AP Luashark Tool
    [Documentation]     Download AP Luashark tool and unzip.
    ...    Examples:
    ...    | _Download GNB Luashark Tool |
    @{path}=    Split String    ${AP_LUA_SHARK_STORE_PATH}    /
    OperatingSystem.Run    sudo chmod 777 -R /${path[1]}
    ${status}    ${value}    Run Keyword And Ignore Error    Directory Should Exist    ${AP_LUA_SHARK_STORE_PATH}
    Run Keyword If    '${status}'=='PASS'    Remove Directory    ${AP_LUA_SHARK_STORE_PATH}    ${True}
    Create Directory    ${AP_LUA_SHARK_STORE_PATH}
    OperatingSystem.Run     wget -P ${AP_LUA_SHARK_STORE_PATH} -q "${AP_LUA_SHARK_TOOL_LINK}/${WTS_VERSION}/airphone-luasharks_${WTS_VERSION}.zip"
	OperatingSystem.Run     unzip ${AP_LUA_SHARK_STORE_PATH}/airphone-luasharks_${WTS_VERSION}.zip -d ${AP_LUA_SHARK_STORE_PATH}
	OperatingSystem.Run     rm ${AP_LUA_SHARK_STORE_PATH}/airphone-luasharks_${WTS_VERSION}.zip

_Get Base Downalod URL Address
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${base_url}=    Set Variable If    '${sw_list[1]}'=='ENB'    ${FILES_BASE_LINK}    '${sw_list[1]}'!='ENB'    ${FILES_BASE_LINK_BRANCHES}
    Log    ${base_url}
    [Return]    ${base_url}

_Download Ttitrace Decode Tool From File Server
    ${url}=    _Get Base Downalod URL Address
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${sub_link}    Set Variable If    '${sw_list[1]}'=='ENB'    ${SW_VERSION_TOTAL}    '${sw_list[1]}'!='ENB'    ${SOFTWARE_INFO}
    OperatingSystem.Run     wget -P ${TEST_LOG_DIRECTORY()} -q "${url}/${SW_VERSION_TOTAL}/${sub_link}_tti-dec.deb"
    [Return]    ${TEST_LOG_DIRECTORY()}${sub_link}_tti-dec.deb

_Download Ttitrace Decode Tool From WFT
    #${base_url}    Set Variable    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
    ${base_url}    Set Variable    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    #${branches}    Set Variable If    '${sw_list[2]}'=='9999'    SBTS00     '${sw_list[2]}'=='0000'    ${sw_list[0]}
    ${branches}    Set Variable If    '${sw_list[2]}'=='9999'    SBTS00    '${sw_list[2]}'=='9990'    SBTS00
    ...    '${sw_list[2]}'=='0000'    ${sw_list[0]}
    ${sub_link}    Set Variable If    '${sw_list[1]}'=='ENB'    ${SW_VERSION_TOTAL}    '${sw_list[1]}'!='ENB'    ${SOFTWARE_INFO}
    OperatingSystem.Run     wget -P ${TEST_LOG_DIRECTORY()} -q "${base_url}/${branches}/${SW_VERSION_TOTAL}/${sub_link}_tti-dec.deb"
    [Return]    ${TEST_LOG_DIRECTORY()}${sub_link}_tti-dec.deb

_Get EIF3 IP Of Control PC
    ${ret}=    Run    ip addr
    ${eth3_ip}=    String.Get Regexp Matches    ${ret}    inet (?P<eth3>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth3    eth3
    [Return]    @{eth3_ip}[0]

_Get EIF Info From Control PC
    ${ret}=    Run    ip addr
    ${eth0_ip}=    String.Get Regexp Matches    ${ret}    inet (?P<eth0>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth0    eth0
    ${eth3_ip}=    String.Get Regexp Matches    ${ret}    inet (?P<eth3>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth3    eth3
    ${eth0_ip}=    Set Variable    ${eth0_ip}[0]
    ${eth3_ip}=    Set Variable If    "${eth3_ip}"=="[]"    none    ${eth3_ip}[0]
    Log    eth0_ip=${eth0_ip},eth3_ip=${eth3_ip}
    ${web_card}=    Set Variable If    "${eth3_ip}"=="none"    eth0    eth3
    ${dest_ip}=    Set Variable If    "${web_card}"=="eth0"    ${eth0_ip}    ${eth3_ip}
    Log    web_card=${web_card},dest_ip=${dest_ip}
    [Return]    ${web_card}    ${dest_ip}

_Start GNB BIP By Admin Method
    [Arguments]    ${interface}=L1-L2    ${destination}=Local    ${mirroring_time}=600
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 rm -rf /tmp/CCSPacketCapture/*
    COAM.Setup Admin    timeout=120
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Start

_Stop Gnb BIP By Admin Method
    [Arguments]    ${log_dir}   ${interface}=L1-L2    ${destination}=Local    ${mirroring_time}=600
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Stop
    ${files}     _Collect GNB BIP By Admin Method    ${log_dir}
    [Teardown]    COAM.Teardown
    [Return]    ${files}

_Collect GNB BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}
    Run    mkdir -p ${log_path}
    ${ret}    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ls /tmp/CCSPacketCapture |grep .pcap
    log     ${ret}

    Run Keyword If    '.pcap' not in '''${ret}'''    Fail    no pcap file exist in /tmp/CCSPacketCapture!
    ${bip_files}     Split To Lines    ${ret}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/CCSPacketCapture/* ${log_path}
    ${ret}=    Run    ls -1 ${log_path} |grep .pcap
    ${f_path}      create list
    FOR     ${f}    IN    @{bip_files}
          append to list     ${f_path}     ${log_path}/${f}
    END
    Run    ls -1 ${log_path}
    Run    mergecap -a -w ${log_path}/tcpdump_L2L1_bip_filtering_off.pcap0 ${log_path}/mirroring_L2L1*
    ${bip_file}=    Set Variable    ${log_path}/tcpdump_L2L1_bip_filtering_off.pcap0
    OperatingSystem.File Should Exist    ${bip_file}
    Log To Console    bip log:${bip_file}
    [Return]    ${f_path}

_start gnb bip with trace
    [Arguments]     ${duration}=infinite
    ${keys}      Get Dictionary Keys     ${GNBMIRRORINGCONFIGS}
    ${para}      Set Variable
    FOR     ${k}     IN     @{keys}
           ${value}     Get From Dictionary     ${GNBMIRRORINGCONFIGS}      ${k}
           ${k}  Convert To Lowercase  ${k}
           Run Keyword If    '${k}'=='capturing_time_seconds'    Continue For Loop
           ${para}      Catenate    --${k}=${value} ${para}
    END
    ${para}      Catenate    ${para} --capturing_time_seconds=${duration}
    Configure Bip Collection   l1_type=${L1_TYPE}
    ...                        gNB_common_unit=${FCT_BOARD_TYPE}
    ...                        gNB_capacity_units=${ASP_BOARD_TYPE}
    ...                        use_script=${True}
    ...                        script_parameters=${para}

    Start Bip Trace

_stop gnb bip with trace
    [Arguments]    ${log_dir}
    Run Keyword If    '${log_dir}'!='${TEST_LOG_DIRECTORY()}'    Create Directory    ${log_dir}
    ${ret}    Stop Bip Trace   target_dir=${log_dir}
   	[return]     ${ret}

_VDU Start Uplane Trace
    [Arguments]    ${target_component}    ${cell_id_list}=All    ${trace_type}=Component
    [Documentation]   Start uplane Trace
    ...   | Input Parameters    | Man. | Description |
    ...   | target_component    | yes | which component trace: L2HiRlc/L2Lo/L2Ps|
    ...   | cell_id_list        | No  | which cell, it is a list, default is All |
    ...   | trace_type          | yes | which trace type:Component/Sherpa |
    ...
    ...   *RETURN VALUE*
    ...   return trace_id
    ${nr_cell_dn_list}=    _VDU Get Cell Dist Name    ${cell_id_list}
    VDU OAM Login    VDU
    ${oper_id}=     VDU.Start Uplane Trace Stream    ${trace_type}    ${target_component}    ${nr_cell_dn_list}
    ...             vdu_connection=vdu_admin
    sleep    10s
    ${active_trace}    VDU.Get Active Trace Streams    vdu_connection=vdu_admin
    [Return]    ${active_trace[0]['trace_id']}
    [Teardown]    VDU OAM Logout    VDU

_VDU Stop Uplane Trace
    [Arguments]    ${trace_id}
    VDU OAM Login    VDU
    ${oper_id}=     VDU.Stop Uplane Trace Stream    ${trace_id}    vdu_connection=vdu_admin
    sleep    3s
    [Teardown]    VDU OAM Logout    VDU

_VDU Download TtiTrace Decode Tool
    ${tool_base_repo}    Set Variable    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/vDUCNF00
    ${VDU_SW_VERSION}=    Get VDU SW Version
    ${decoder_tool_name}=    Set Variable    vDUCNF00_${VDU_SW_VERSION}_tti-dec.deb
    ${tool_url}=    Set Variable    ${tool_base_repo}/vDUCNF00_${VDU_SW_VERSION}/${decoder_tool_name}
    Set Test Variable    ${ttiTrace_dir}    /home/ute/${VDU_SW_VERSION}
    ${rc}    ${output}    Run and Return RC and Output    wget --no-check-certificate ${tool_url} -P ${ttiTrace_dir}
    ${rc}    ${output}    Run and Return RC and Output    cd ${ttiTrace_dir} && chmod +x ${decoder_tool_name}
    ${rc}    ${output}    Run and Return RC and Output    pip install numpy pandas
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    ${rc}    ${output}    Run and Return RC and Output    cd ${ttiTrace_dir} && sudo dpkg -i ${decoder_tool_name}
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    update numpy
	Sleep     5

_VDU Start Collect All Bip Log
    [Arguments]    ${log_save_path}
    _VDU Start Collect Single Bip Log    l2hi    ${log_save_path}    l2nrt
    _VDU Start Collect Single Bip Log    l2rt    ${log_save_path}    l2rt

_VDU Start Collect Single Bip Log
    [Arguments]    ${container_name}    ${log_save_path}    ${pod_filter}
    VDU Get Pods    ${pod_filter}
    VDU Master Login
    ${cmd}=    Set Variable    kubectl exec -it ${VDU_PODS} -n ${NAMESPACE_VDU} -c ctr-${NAMESPACE_VDU}
    SSH.Execute      ${cmd}-${container_name} -- bash -c "rm ${log_save_path}*.pcap"    connection=vdu_master
    Sleep    1
    SSH.Send Command    ${cmd}-${container_name} -- bash -c "hal-cli pdump port all path ${log_save_path}"    connection=vdu_master
    Sleep     5
    [Teardown]    VDU Master Logout

_VDU Stop And Download All Bip Log
    [Arguments]    ${log_save_path}
    _VDU Stop And Download Single Bip Log    l2hi    ${log_save_path}    l2nrt
    _VDU Stop And Download Single Bip Log    l2rt    ${log_save_path}    l2rt

_VDU Stop And Download Single Bip Log
    [Arguments]    ${container_name}    ${log_save_path}    ${pod_filter}
    VDU Get Pods    ${pod_filter}
    VDU Master Login
    _VDU Stop Single Bip Log    ${container_name}    vdu_master    ${pod_filter}
    SSH.Execute    rm -rf /tmp/biplog; mkdir /tmp/biplog    vdu_master
    _VDU Download Single Bip Log    ${container_name}    vdu_master    ${log_save_path}    ${pod_filter}
    [Teardown]    VDU Master Logout

_VDU Stop Single Bip Log
    [Arguments]    ${container_name}    ${connection}    ${pod_filter}
    Log To Console    ${pod_filter}
    ${stop_cmd}=    Set Variable    kubectl -n ${NAMESPACE_VDU} exec -ti ${VDU_PODS} -c ctr-${NAMESPACE_VDU}
    SSH.Execute    ${stop_cmd}-${container_name} -- bash -c "pgrep dpdk|xargs kill -9"    connection=${connection}
    Sleep    3

_VDU Download Single Bip Log
    [Arguments]    ${container_name}    ${connection}    ${log_save_path}    ${pod_filter}
    Log To Console    ${pod_filter}
    ${ls_cmd}=    Set Variable    kubectl -n ${NAMESPACE_VDU} exec -ti ${VDU_PODS} -c ctr-${NAMESPACE_VDU}
    ${log}=   SSH.Execute    ${ls_cmd}-${container_name} -- bash -c "ls tmp/*.pcap"     connection=${connection}
    @{logs}=    Split String    ${log}
    ${len}=    Get Length    ${logs}
    Return From Keyword If    '${len}'=='0'
    ${cp_pre}=     Set Variable    kubectl cp -c ctr-${NAMESPACE_VDU}
    For    ${log_path}    IN    @{logs}
        ${log_name}=    Fetch From Right    ${log_path}    /
        SSH.Execute    ${cp_pre}-${container_name} ${NAMESPACE_VDU}/${VDU_PODS}:${log_path} /tmp/biplog/${log_name}     connection=${connection}
        SSH.Download File    /tmp/biplog/${log_name}    ${log_save_path}/${log_name}    connection=${connection}
    END
