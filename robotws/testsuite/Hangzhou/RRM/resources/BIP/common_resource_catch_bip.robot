*** Settings ***
Library     String
Library     OperatingSystem
Library     ute_fsmaccess
Library     Collections
Library     taf.transport.ssh    WITH NAME    SSH

*** Variables ***
&{GNB}    ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
${SCRIPT_PATH_L1BYPASS}  ${CURDIR}/bip_shell_script/l1bypass/
${SCRIPT_PATH_FULLSTACK}  ${CURDIR}/bip_shell_script/fullstack/
${SCRIPT_PATH_GNBMIRRORING}  ${CURDIR}/bip_shell_script/gnbmirroring_fullstack/
*** Keywords ***
Start Gnb BIP Log
    [Documentation]    This keyword is to start gnb bip log capture process on different testline types.
    Get L1Bypass Type    #${L1_TYPE}
    Get Control Board Type    #${FCT_BOARD_TYPE}
    Get Base Band Boards Type    #@{ASP_BOARDS_TYPE}
    Run Keyword If    '${L1_TYPE}'=='FS'    Start GNB BIP Log On FullStack
    ${str_fsp_boards}=    Catenate    @{ASP_BOARDS_TYPE}
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIB' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIO'
    ...    Start BIP Log By Shell Script    bip_ASIB_ABIO_l1bypass.sh
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIB' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIO ABIO'
    ...    Start BIP Log By Shell Script    bip_ASIB_2ABIO_l1bypass.sh
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIL' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIO'
    ...    Start BIP Log By Shell Script    bip_ASIL_ABIO_l1bypass.sh
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIB' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIL ABIL ABIL'
    ...    Start BIP Log By Shell Script    bip_ASIB_3ABIL_l1bypass.sh
    
Start GNB BIP Log On FullStack
    [Arguments]    ${duration}=infinite
    Download GNB Mirroring Tool
    Clear The BIP File Dir On FCT
    Log To Console    INFO:Start GNB BIP log On Fullstack...
    Modify File Parameter    ${SCRIPT_PATH_GNBMIRRORING}/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=[0-9]+    CAPTURING_TIME_SECONDS=${duration}
    Modify File Parameter    ${SCRIPT_PATH_GNBMIRRORING}/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH_GNBMIRRORING}/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=2
    Modify File Parameter    ${SCRIPT_PATH_GNBMIRRORING}/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=50
    Modify BIP Script File To Adapt Frame
    OperatingSystem.Run    sshpass -p ${GNB.password} scp ${SCRIPT_PATH}/BIP/* ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    ${exec_script}    Set Variable    gnbMirroring.sh
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=BIP_GNB
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &    connection=BIP_GNB
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB
    Log To Console   INFO:bip start success...

Start BIP Log By Shell Script
    [Arguments]    ${shell_script}    ${shell_script_path}=${SCRIPT_PATH_L1BYPASS}
    [Documentation]    user provide shell script
    ...    GNB_ASIB_1ABIO_L1Bypass:    bip_ASIB_ABIO.sh
    ...    GNB_ASIB_2ABIO_L1Bypass:    bip_ASIB_2ABIO.sh
    ...    GNB_ASIL_1ABIO_L1Bypass:    bip_ASIL_ABIO.sh
    Clear The BIP File Dir On FCT
    Log To Console    INFO:Start GNB BIP log...
    Modify File Parameter    ${shell_script_path}/${shell_script}    tcpdumpL2L1    5GBipL2L1
    Modify File Parameter    ${shell_script_path}/${shell_script}    -C 100    -C 50
    Modify File Parameter    ${shell_script_path}/${shell_script}    -W 20    -W 2
    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} scp ${shell_script_path}/${shell_script} ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    ${exec_script}    Set Variable    ${shell_script} ${slot_id}
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=BIP_GNB
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &    connection=BIP_GNB
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB
    Log To Console   INFO:bip start success...

Stop Gnb BIP Log
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    [Documentation]    This keyword is to stop bip log capture process started by keyword Start Gnb BIP Log
    ...    when durarion=infinite(necessory). It also will copy bip log files to given log_dir and this keyword
    ...    will return the numer of bip files.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | Directory where to put the bip logs in |
    ...
    ...    Examples:
    ...    | Start Gnb BIP Log | duration=infinite |
    ...    | ${bip_counts} | Stop Gnb BIP Log | ${output_dir} |
    ...
    Stop BIP Log On GNB FCT    ${log_dir}


Stop BIP Log On GNB FCT
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Log To Console    INFO:Stop GNB BIP log...
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB
    ${bip_counts}    Copy BIP Files And Return Count    ${log_dir}
    Log To Console   INFO:bip end success...
    [Return]    ${bip_counts}

Kill And Verify Process Stop Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log capture process end success
    ...    Notice: just available in keywords: Stop X2 Pcap Log; Stop Gnb BIP Log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | A string for the whole command |
    ...    | ${connection} | Yes | the connection to execute the command |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill And Verify Process Stop Success | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    Kill Process If Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Not Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Not Contain    ${process}    ${process_msg}

Copy BIP Files And Return Count
    [Arguments]    ${path}    ${ip}=${GNB.ip}
    Log To Console    copy bip files to ${path}...
    Wait Until Keyword Succeeds    10 s    2 s    Verify Bip Log Exist
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB.username}@${ip}:/tmp/5GBipL2L1_filtering_off.pcap* ${path}
    ${count}    OperatingSystem.Count Items In Directory    ${path}    pattern=5GBipL2L1_filtering_off.pcap*
    [Return]    ${count}

Download GNB Mirroring Tool
    [Arguments]    ${local_save_path}=${CURDIR}/GNB_mirroring_repo
    [Documentation]     This keyword will download GNB mirroring tool to replace existed.
    ...    Examples:
    ...    | Download GNB Mirroring Tool |
    OperatingSystem.Run    rm -rf ${local_save_path}
    OperatingSystem.Run    git clone ${GNB_MIRRORING_TOOL_LINK} ${local_save_path}
    OperatingSystem.Run    cp ${local_save_path}/gnbMirroring/gnbMirroringConfig.sh ${CURDIR}/scripts/BIP/
    OperatingSystem.Run    cp ${local_save_path}/gnbMirroring/gnbMirroring.sh ${CURDIR}/scripts/BIP/

Verify Process Start Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log process start success
    ...    Notice: just available in keywords:Start X2 Pcap Log; Start Gnb BIP Log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | A string for the whole command |
    ...    | ${connection} | Yes | the connection to execute the command |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Verify BIP Start Success | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    Judge Process Existed    ${part_proc_msg}    ${process_msg}    ${connection}

Judge Process Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to kill the process with the ${process_msg} if it exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | the msg to filter the related process |
    ...    | ${connection} | Yes | the SSH connection to kill process |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill Process If Existed | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Contain    ${process}    ${process_msg}

Kill Process If Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to kill the process with the ${process_msg} if it exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | the msg to filter the related process |
    ...    | ${connection} | Yes | the SSH connection to kill process |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill Process If Existed | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    ${status}    Run Keyword And Return Status    Judge Process Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    Run Keyword If    '${status}'=='${true}'    SSH.Execute
    ...    command=ps aux|grep '${part_proc_msg}'|awk '{print $2}'|xargs kill -2    connection=${connection}

Verify BIP Log Exist
    [Arguments]    ${ip}=${GNB.ip}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} ls -al /tmp/5GBipL2L1_filtering_off.pcap*
    Should Be True    "${rc}"=="0"

Clear The BIP File Dir On FCT
    [Arguments]   ${ip}=${GNB.ip}
    [Documentation]    This keyword is to clear bip files in gnb /ffs/run/config/scripts if exists.
    ...    As well as the log files /tmp/5GBipL2L1_filtering_off*
    ...    Notice: just available in keyword Start Gnb BIP Log
    ...
    ...    Examples:
    ...    | Clear The BIP File Dir On FCT |
    ...
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} rm /tmp/5GBipL2L1_filtering_off*
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} rm -rf /ffs/run/config/scripts
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} mkdir /ffs/run/config/scripts
    Log To Console    clear default bip scripts done...
    
Get L1Bypass Type
    [Documentation]    Get TL is configured as L1Bypass mode or FS mode
    ...    Examples:
    ...    | ${L1_type}= | Get L1Bypass Type |
    ${output}=    Run    (sleep 2s; echo "tag -a";sleep 2s)|sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 telnet localhost 15007
    ${result}=    Run Keyword And Return Status   should contain  ${output}   L1BypassMap
    Log    ${result}
    ${L1_TYPE}=    Set Variable IF     "${result}" == "True"    L1b    FS
    Set Suite Variable    ${L1_TYPE}    ${L1_TYPE}
    [Return]    ${L1_TYPE}
    
Get Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${FCT_BOARD_TYPE}    ${board_type}
    Log    GNB Control Board Type: ${FCT_BOARD_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get Base Band Boards Type
    [Documentation]    this keyword is used to get base band board Type, ABIL，ABIO，ABIN etc.
    ${frame_id_list}=    Create List    1    2    3
    ${ASP_BOARDS_TYPE}    Create List
    FOR    ${frame_id}    IN    @{frame_id_list}
        ${ret}=    Run Keyword And Return Status    Get Base Band Board Type    ${frame_id}
        Run Keyword If    "${ret}"=="${TRUE}"    Collections.Append To List    ${ASP_BOARDS_TYPE}    ${ASP_BOARD_TYPE}
    END
    Log    GNB Base Band Boards Type: ${ASP_BOARDS_TYPE}     console=${True}
    Set Suite Variable    ${ASP_BOARDS_TYPE}
    [Return]    ${ASP_BOARDS_TYPE}

Get Base Band Board Type
    [Arguments]    ${frame_id}=1
    [Documentation]    this keyword is used to get base band board Type, ABIL，ABIO，ABIN etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    bsh ${frame_id}:0 cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${ASP_BOARD_TYPE}    ${board_type}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}
    
Modify BIP Script File To Adapt Frame
    [Arguments]    ${ip}=192.168.255.1
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${ip} hostname 2>/dev/null
    Run Keyword If    '${gnb_hostname}'=='fct-4a'    Modify BB Slot To Right
    Run Keyword If    '${gnb_hostname}'=='fct-0a'    Modify BB Slot To Left

Modify BB Slot To Right
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_1='true'    BB_SLOT_1='false'
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_5='false'    BB_SLOT_5='true'

Modify BB Slot To Left
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_1='false'    BB_SLOT_1='true'
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_5='true'    BB_SLOT_5='false'

Modify File Parameter
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | No | the file path which need to modify |
    ...    | ${old_value} | No | the value need to be replaced |
    ...    | ${new_value} | No | the new value |
    ...
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    OperatingSystem.Create File    path=${file_path}    content=${content}