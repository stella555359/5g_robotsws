*** Settings ***
Documentation    Author: xiang.5.li@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

#Old usage: Resource           ${EXECDIR}/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_log_capture.robot
Resource           ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/hangzhou/common_log_capture.robot

*** Variables ***
${GNB_MIRRORING_TOOL}     ${EXECDIR}/testsuite/Beijing/ET/airphone/tools/bip_mirroring



*** Keywords ***
_keywords_all
    Start Airphone BIP Log By gnbMirroring BJ
    Start GNB BIP Log By gnbMirroring BJ
    Stop BIP Log On GNB FCT BJ
    Stop Airphone BIP Log BJ
    Start To Capture Logs Via gnb logs
    Stop And Dowonload Via gnb logs
    Copy SCF to Test Folder
    Start X2 Pcap Log bj


Start Airphone BIP Log By gnbMirroring BJ
    [Arguments]   ${exec_script}=bip_mirroring_ASIL.sh   ${slot}=1   ${alias}=apBip
    [Documentation]     This keyword for FullStack gNB: ASIL + ABIO
    Clear The BIP File Dir On FCT    ${AP.ip}
    Log To Console    INFO:Start Airphone BIP log On ASIL or ABIO...
#    Modify File Parameter    ${GNB_MIRRORING_TOOL}/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=[0-9]+    CAPTURING_TIME_SECONDS=${duration}
#    Modify File Parameter    ${GNB_MIRRORING_TOOL}/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=2
#    Modify File Parameter    ${GNB_MIRRORING_TOOL}/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=50
#    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
#    Modify BIP Script File To Adapt Frame    192.168.200.1
    OperatingSystem.Run    sshpass -p ${AP.password} scp ${GNB_MIRRORING_TOOL}/* ${AP.username}@${AP.ip}:/ffs/run/config/scripts/
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${AP.ip}    ${AP.username}    ${AP.password}    alias=${alias}
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} ${slot} ap_bip 1>/dev/null 2>&1 &    connection=${alias}
#    ${start_bip_log}    SSH.Execute    command=sh /ffs/run/config/scripts/${exec_script} ${slot} ap_bip    connection=BIP_AP
    Set Suite Variable     ${BIP_CMD}         tcpdump -vvv -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    ap_bip    ${BIP_CMD}    ${alias}
    Log To Console    INFO:airphone bip start success...


Start GNB BIP Log By gnbMirroring BJ
    [Arguments]    ${exec_script}=bip_mirroring_ASIL.sh   ${slot}=5   ${alias}=gnbBip
    [Documentation]     This keyword for FullStack, AP: ASIL + ABIO
    ...                 cd /ffs/run/config/scripts
    ...                 root@fct-0a:/ffs/run/config/scripts >./bip_mirroring_ASIL.sh 1 ap_bi1
    Clear The BIP File Dir On FCT
    Log To Console    INFO:Start GNB BIP log By gnbMirroring...
#    Modify File Parameter    ${GNB_MIRRORING_TOOL}/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=[0-9]+    CAPTURING_TIME_SECONDS=${duration}
#    Modify File Parameter    ${GNB_MIRRORING_TOOL}/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=2
#    Modify File Parameter    ${GNB_MIRRORING_TOOL}/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=50
#    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
#    Modify BIP Script File To Adapt Frame
    OperatingSystem.Run    sshpass -p ${GNB.password} scp ${GNB_MIRRORING_TOOL}/* ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=${alias}
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} ${slot} gnb_bip 1>/dev/null 2>&1 &    connection=${alias}
    Set Suite Variable     ${BIP_CMD}         tcpdump -vvv -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    gnb_bip    ${BIP_CMD}    ${alias}
    Log To Console   INFO:gnb bip start success...

Clear The BIP File Dir On FCT BJ
    [Arguments]   ${ip}=${GNB.ip}
    [Documentation]    This keyword is to clear bip files in gnb /ffs/run/config/scripts if exists.
    ...    As well as the log files /tmp/5GBipL2L1_filtering_off*
    ...    Notice: just available in keyword Start Gnb BIP Log
    ...
    ...    Examples:
    ...    | Clear The BIP File Dir On FCT |
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} rm /tmp/*_bip*
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} rm -rf /ffs/run/config/scripts
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} mkdir /ffs/run/config/scripts
    Log To Console    clear default bip scripts done...

Stop BIP Log On GNB FCT BJ
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}/gnb_bip    ${alias}=gnbBip
    Log To Console    INFO:Stop GNB BIP log...
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    gnb_bip   ${BIP_CMD}    ${alias}
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    OperatingSystem.Run      mkdir -p ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count BJ   ${log_dir}    ${GNB.ip}    gnb_bip.pcap*
    Log To Console   INFO:bip end success...
    Clear The BIP File Dir On FCT    ${GNB.ip}
    SSH.Disconnect    connection=${alias}
    [Return]    ${bip_counts}

Stop Airphone BIP Log BJ
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}/ap_bip    ${alias}=apBip
    Log To Console    INFO:Stop Airphone BIP log...
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    ap_bip    ${BIP_CMD}    ${alias}
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    OperatingSystem.Run      mkdir -p ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count BJ   ${log_dir}    ${AP.ip}   ap_bip.pcap*
    Log To Console   INFO:bip end success...
    Clear The BIP File Dir On FCT    ${AP.ip}
    SSH.Disconnect    connection=${alias}
    [Return]    ${bip_counts}

Copy BIP Files And Return Count BJ
    [Arguments]    ${path}    ${ip}=${GNB.ip}    ${pattern}=gnb_bip.pcap*
    Log To Console    copy bip files to ${path}...
    Wait Until Keyword Succeeds    10 s    2 s    Verify Bip Log Exist BJ    ${ip}    ${pattern}
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB.username}@${ip}:/tmp/${pattern} ${path}
    ${count}    OperatingSystem.Count Items In Directory    ${path}    ${pattern}
    [Return]    ${count}

Verify BIP Log Exist BJ
    [Arguments]    ${ip}=${GNB.ip}    ${pattern}=gnb_bip.pcap*
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} ls -al /tmp/${pattern}
    Should Be True    "${rc}"=="0"

Verify Keywords Of File On VM
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                Description: Check the file on UTE whether contain the specific words
    ...                             Need to push the script gnb_logs(such as:gnb_logs_2.17) to /home/ute/gnb_logs on UTE
    ...                             For success to start bip: Wait for Press <Enter> again to stop and dump logs...
    ...                             For success to stop bip: Log file downloaded:
    [Arguments]    ${success_words}=Press a key to stop trace
    ...            ${path}=/home/ute/gnb_logs    ${filename}=tool.log    ${connection}=logsTool
    ${output}    SSH.Execute    command=cat ${path}/${filename}    connection=${connection}
    Log    ${output}
    Should Contain   ${output}    ${success_words}

Start To Capture Logs Via gnb logs
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                use gnb_logs script
    ...                Description: Check the file on UTE whether contain the specific words
    ...                default the gnb_logs path: /home/ute/gnb_logs/gnb_logs
    ...                refer to:C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_34\5GC000704\Resources\5GC000704_common_keyword.robot
    [Arguments]    ${alias}=logsTool
    ...            ${path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${command_suf}=-b
    ...            ${success_words}=Press a key to stop trace
    ...            ${filename}=tool*.log
    Log To Console     Start gnb_logs for ${path} ${gnb_ip} ${command_suf}
    SSH.connect to     hostname=${TLPC_IP}    username=${TLPC_SSH_UE}    password=${TLPC_SSH_PWD}    alias=${alias}
    SSH.Send Command    command=rm -rf ${path}/*.zip    connection=${alias}
    SSH.Send Command    command=rm -rf ${path}/${filename}    connection=${alias}
    SSH.Send Command    command=chmod 777 ${path}/gnb_logs    connection=${alias}
    ${connection}    SSH.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Set Suite Variable    ${bip_channel}    ${channel}
    Call Method    ${channel}    send    cd ${path};./gnb_logs ${gnb_ip} ${command_suf}\n
#    SSH.Send Command    command=cd ${path};./gnb_logs ${gnb_ip} ${command_suf}    connection=${alias}
    Wait Until Keyword Succeeds   3 min  10 sec   Verify Keywords Of File On VM    success_words=${success_words}
    ...                                                                            path=${path}
    ...                                                                            filename=${filename}
    ...                                                                            connection=${alias}

Stop And Download Via gnb logs
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                use gnb_logs script
    ...                refer to:C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_34\5GC000704\Resources\5GC000704_common_keyword.robot
    [Arguments]    ${alias}=logsTool
    ...            ${path}=/home/ute/gnb_logs
    ...            ${success_words}=Tool finished running.
    #    ...            ${success_words}=Duration seconds:
    ...            ${filename}=tool.log
    ...            ${log_dir_ute}=${TEST_LOG_DIRECTORY}
    Log To Console     stop gnb logs ${bip_channel}
    Call Method    ${bip_channel}    send    \n
#    SSH.Send Command    command=\n    connection=${alias}
    Sleep    2 sec
    Wait Until Keyword Succeeds   3 min  10 sec   Verify Keywords Of File On VM    success_words=${success_words}
    ...                                                                            path=${path}
    ...                                                                            filename=${filename}
    ...                                                                            connection=${alias}
    ${tmp_log_name}    SSH.Execute    command=cd ${path};ls -l | grep *.zip | awk '{print $9}'    connection=${alias}
    ${log_name}    Fetch From Left    ${tmp_log_name}    \r\n
    SSH.Execute    command=cp ${path}/${log_name} ${log_dir_ute}    connection=${alias}
    ${log_full_path_ute}     join path    ${log_dir_ute}    ${log_name}
    [Return]    ${log_full_path_ute}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Call Method    ${bip_channel}    close    AND
    ...                           Run Keyword And Ignore Error    SSH.Send Command    command=rm ${path}/*.zip    connection=${alias}    AND
    ...                           Run Keyword And Ignore Error    SSH.Execute    command=rm ${path}/${filename}    connection=${alias}    AND
    ...                           Run Keyword And Ignore Error    SSH.Disconnect    connection=${alias}

Start To Capture Logs Via gnb logs on Gnb
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                use gnb_logs script
    ...                Description: Check the file on UTE whether contain the specific words
    ...                default the gnb_logs path: /user/toor4nsn
    ...                refer to:C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_34\5GC000704\Resources\5GC000704_common_keyword.robot
    [Arguments]    ${alias}=logsTool
    ...            ${path}=/user/toor4nsn/gnb_logs
    ...            ${gnb_index}=0
    ...            ${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${gnb_username}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${gnb_pw}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...            ${capture_ip}= ${gnb_ip}
    ...            ${command_suf}=-b
    ...            ${success_words}=Press a key to stop trace
    ...            ${filename}=tool.log
    Log To Console     Start gnb_logs for ${path} ${capture_ip} ${command_suf}
    SSH.connect to     hostname=${gnb_ip}    username=${gnb_username}    password=${gnb_pw}    alias=${alias}
    SSH.Send Command    command=rm -rf ${path}/*.zip    connection=${alias}
    SSH.Send Command    command=rm -rf ${path}/${filename}    connection=${alias}
    SSH.Send Command    command=chmod 777 ${path}/gnb_logs    connection=${alias}
    ${connection}    SSH.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Set Suite Variable    ${bip_channel}    ${channel}
    Call Method    ${channel}    send    cd ${path};./gnb_logs ${capture_ip} ${command_suf}\n
#    SSH.Send Command    command=cd ${path};./gnb_logs ${gnb_ip} ${command_suf}    connection=${alias}
    Wait Until Keyword Succeeds   3 min  10 sec   Verify Keywords Of File On VM    success_words=${success_words}
    ...                                                                            path=${path}
    ...                                                                            filename=${filename}
    ...                                                                            connection=${alias}

Stop And Download Via gnb logs on Gnb
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                use gnb_logs script
    ...                refer to:C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_34\5GC000704\Resources\5GC000704_common_keyword.robot
    [Arguments]    ${alias}=logsTool
    ...            ${path}=/user/toor4nsn/gnb_logs
#    ...            ${success_words}=Duration seconds:
    ...            ${success_words}=Tool finished running.
    ...            ${filename}=tool.log
    ...            ${log_dir_ute}=${TEST_LOG_DIRECTORY}
    Log To Console     stop gnb logs ${bip_channel}
    Call Method    ${bip_channel}    send    \n
#    SSH.Send Command    command=\n    connection=${alias}
    Sleep    2 sec
    Wait Until Keyword Succeeds   20 min  30 sec   Verify Keywords Of File On VM    success_words=${success_words}
    ...                                                                            path=${path}
    ...                                                                            filename=${filename}
    ...                                                                            connection=${alias}
    ${tmp_log_name}    SSH.Execute    command=cd ${path};ls -l | grep *.zip | awk '{print $9}'    connection=${alias}
    ${log_name}    Fetch From Left    ${tmp_log_name}    \r\n
#    SSH.Execute    command=cp ${path}/${log_name} ${log_dir_ute}    connection=${alias}
    OperatingSystem.Run
        ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:${path}/${log_name} ${log_dir_ute}/${log_name}
    ${log_full_path_ute}     join path    ${log_dir_ute}    ${log_name}
    [Return]    ${log_full_path_ute}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Call Method    ${bip_channel}    close    AND
    ...                           Run Keyword And Ignore Error    SSH.Send Command    command=rm ${path}/*.zip    connection=${alias}    AND
    ...                           Run Keyword And Ignore Error    SSH.Execute    command=rm ${path}/${filename}    connection=${alias}    AND
    ...                           Run Keyword And Ignore Error    SSH.Disconnect    connection=${alias}

Unzip Emil File
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                use to unzip xxx.zip file, such as Emil log (gNB_10.0.1.2_20220524_051638_Emil.zip) catch by gnb_logs's tool.
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    Log To Console    unzip zip file...
    ${zip_folder}    OperatingSystem.Run    cd ${log_dir};basename -s .zip $(ls -l BTS-*.zip | awk '{print $9}')
    log to console     Emil log folder: ${zip_folder}
    OperatingSystem.Run    unzip ${log_dir}/BTS-*.zip -d ${log_dir}
    ${emil_path}    Set Variable        ${log_dir}/${zip_folder}/
    Log To Console     emil log directory: ${emil_path}
    [Return]    ${emil_path}

Unzip Emil File with Name
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                use to unzip xxx.zip file, such as Emil log (gNB_10.0.1.2_20220524_051638_Emil.zip) catch by gnb_logs's tool.
    ...    | Input Parameters | Man. | Description |
    ...    | log_dir | No | default=TEST_LOG_DIRECTORY |
    ...    | name    | Yes | such as: BIP, Emil, SYSLOG|
    ...    Example:
    ...    | Unzip Emil File with Name | name=Eiml |
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}    ${name}=Emil
    Log To Console    unzip zip file...
    ${zip_folder}    OperatingSystem.Run    cd ${log_dir};basename -s .zip $(ls -l BTS-*${name}.zip | awk '{print $9}')
    log to console     Emil log folder: ${zip_folder}
    OperatingSystem.Run    unzip ${log_dir}/BTS-*${name}.zip -d ${log_dir}
    ${emil_path}    Set Variable        ${log_dir}/${zip_folder}/
    Log To Console     emil log directory: ${emil_path}
    [Return]    ${emil_path}

Unzip Emil File with Full Path
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                use to unzip xxx.zip file, such as Emil log (gNB_10.0.1.2_20220524_051638_Emil.zip) catch by gnb_logs's tool.
    ...    | Input Parameters | Man. | Description |
    ...    | log_path | Yes | log absolutly path |
    ...    Example:
    ...    | Unzip Emil File with Full Path | log_path=/home/ute/result/log/xxx.zip |
    [Arguments]    ${log_path}=None
#    Log To Console    unzip zip file...
#    ${zip_folder}    OperatingSystem.Run    cd ${log_dir};basename -s .zip $(ls -l gNB_*${name}.zip | awk '{print $9}')
    log to console     Emil log folder: ${log_path}
    ${rest}  ${name}=     Split String From Right    ${log_path}    /    1
    ${file_rest}   ${file_type}           Split String     ${name}    .    1
    OperatingSystem.Run    unzip ${log_path} -d ${TEST_LOG_DIRECTORY}
    ${emil_path}    Set Variable        ${TEST_LOG_DIRECTORY}/${file_rest}/
    Log To Console     emil log directory: ${emil_path}
    [Return]    ${emil_path}

Copy SCF to Test Folder
    [Documentation]    author:xiang.5.li@nokia-sbell.com
    ...                Copy SCF file from ${OUTPUT_DIR} to ${TEST_LOG_DIRECTORY}
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    Log To Console    move scf file: ${log_dir}SCF_running.xml, SCF_before_suite.xml...
    OperatingSystem.Run    cp ${OUTPUT_DIR}/SCF_*.xml ${TEST_LOG_DIRECTORY}

Start X2 Pcap Log bj
    [Documentation]    This keyword is to start x2 pcap log and save in /ffs/run/logs/x2.pcap on GNB ASIK.
    ...    ${X2AP_CMD} = tcpdump -i any -s 2000 -w /ffs/run/logs/x2.pcap   Hangzhou
    ...    ${X2AP_CMD} = tcpdump -i br0 -w /ffs/run/logs/x2.pcap   Beijing
    ...    Examples:
    ...    | Start X2 Pcap Log |
    [Arguments]    ${X2AP_CMD}=tcpdump -i br0 -w /ffs/run/logs/x2.pcap
    Log To Console    Clear The X2 Pcap Log
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=X2PCAP_START
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=X2PCAP_STOP
    Run Keyword And Ignore Error    SSH.Execute    rm -rf /ffs/run/logs/x2.pcap    connection=X2PCAP_START
    SSH.Execute    ls /tmp    connection=X2PCAP_START
    Kill Process If Existed    x2.pcap     ${X2AP_CMD}    X2PCAP_START
    Log To Console    start x2 pcap logs...
    SSH.Send Command    command=${X2AP_CMD}    connection=X2PCAP_START
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    x2.pcap    ${X2AP_CMD}    X2PCAP_STOP
    Log To Console    x2 log ongoing

Stop X2 Pcap Log bj
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop x2 pcap log and copy log to ${log_dir},
    ...    the default value is ${TEST_LOG_DIRECTORY}
    ...
    ...    Examples:
    ...    | Stop X2 Pcap Log    ${output_dir} |
    ...
    Log To Console    stop x2 pcap log by pkill
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    x2.pcap    ${X2AP_CMD}    X2PCAP_STOP
    Log To Console    x2 pcap log capture stoped
    ${res}    Copy X2 Pcap Files And Return Count    ${log_dir}
    Run Keyword If    '${res}'!='True'    Log To Console    'seems x2.pcap not existed'

Start Ttitrace With Streaming Mode bj
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    Run Keyword If    "${NR_PHY_CELL_IDS}"=="[]"    Get PhysCellId Of GNB
    #${nr_phy_cell_ids}    Set Variable    [50, 51]
    Log To Console       TtiTrace for cells:${NR_PHY_CELL_IDS}&${pysical_cell_ids}
    ${localIpAddr}=    Get Mplane IP Of GNB    #10.0.1.2 for ute
    ${gnb_eif_eth_num_on_control_pc}    ${gnb_eif_ip_addr_on_control_pc}=    Get ETH Info For GNB EIF Interface On Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${NR_PHY_CELL_IDS}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${gnb_eif_eth_num_on_control_pc} udp and dst ${gnb_eif_ip_addr_on_control_pc} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=${gnb_eif_ip_addr_on_control_pc}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}

Stop Ttitrace bj
    [Arguments]    ${names}=l2stream3_ttitrace    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
    CORE.stop_collectors
    ...  names=${names}
    CORE.collect_collectors
    ...  names=${names}    target_dir=${log_dir}
    CORE.teardown_collectors
    ...  names=${names}
