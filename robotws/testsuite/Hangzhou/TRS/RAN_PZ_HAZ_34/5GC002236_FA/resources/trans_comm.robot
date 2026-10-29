*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   TRANS common keyword

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME     coam


Library     trans/translib.py      WITH NAME    translib

Library     String
Library     Collections
Library     OperatingSystem
Library     Process
Library     XML
Library     DateTime
Library     Telnet

Resource    trans_fm.robot
Resource    trans_genmo.robot
Resource    trans_pm.robot
Resource    trans_wireshark.robot
Resource    trans_switch.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Variables  ./trans/translib.py


*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${TRANS_PARA}                   ${NONE}

${DU_SWITCH_IP}
${DU_SWITCH_USERNAME}
${DU_SWITCH_PASSWORD}
${DU_SWITCH_EN_PASSWORD}

${DU_OAM_INTERFACE}    fp0

######## static assigned value ############


######## automatically assigned value ############
${ROOT_CLASS_NAME}      MRBTS
${DU_BTS_ID}               ${tl.gnbs[0].global_bts_id}    #automatically assigned
${DU_NRBTS_ID}             1
${DU_MRBTS_VER}
${DU_NRBTS_VER}
${DU_EQM_VER}
${DU_MNL_VER}
${DU_TNL_VER}

${DU_TNL_OAM}              1
${DU_MNLENT}               1

@{DU_ALL_VM}               OAM
@{CU_ALL_VM}               OAM   CPIF  CPRT   UPUE

############### UTE info ###########
${LOCAL_IP}                      #UTE IP (ipv4)
${LOCAL_IP_GATEWAY}              #UTE IP gateway (ipv4)
${LOCAL_IP6_ADDRESS}             #UTE IP (ipv6)

############### transport related configuration #################################
${PM_FILE_LOCATION}
${PM_FILE_PATTERN}
${DU_PM_FILE_LOCATION}   /tmp/
${DU_PM_FILE_PATTERN}    PM\\.BTS-\\d+\\.\\d+\\.\\d+.ANY.xml.gz
${CU_PM_FILE_LOCATION}   /tmp/
${CU_PM_FILE_PATTERN}    PM\\.BTS-\\d+\\.\\d+\\.\\d+.ANY.xml.gz

${DU_SCF_BACKUP_FILE}
${CU_SCF_BACKUP_FILE}

${BOOLEAN_TRUE}
${BOOLEAN_FALSE}

############### transport tools #################################
&{TOOLS_INFO}     work_folder_root=/tmp/opt/
...    work_folder_tool=/tmp/opt/tools/trans_test/
...    work_folder_data=/tmp/opt/tools/trans_data/
...    cmd_arp_test_m=arp_test_m
...    icmp_test=icmp_test
...    pmtu=pmtu
...    send_ether_frame=send_ether_frame

${SIMULATOR4DU_IF}
${SIMULATOR4DU_IFV6}

############### debug Purpose value #################################
${TRANS_DBG}            0

*** Keyword ***
TRANS Common Setup
    [Documentation]  TRANS Common Setup
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | TRANS Common Setup |
    Set Library Search Order   trans_comm   trans_genmo   trans_fm   trans_wireshark   trans_switch  translib   ssh   coam
    TRANS Test Common Setup
    Run Keyword And Ignore Error    Get TA PC Local IP
    _Install Packages
    Run Keyword And Ignore Error    _Init_Global_Variable
    Run Keyword And Ignore Error   _Init_BTS_Info_Variable
    _Disp_BTS_Info
    Run Keyword And Ignore Error  _Init_Timezone_Info
    Run Keyword And Ignore Error   _Init_Tools


TRANS Common Teardown
    [Documentation]  TRANS Common Teardown, called by 'suite teardown'
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | TRANS Common Teardown |
    TRANS Test Common Teardown


TRANS Test Common Setup
    FOR  ${keyword}  IN   firefox   geckodriver
        ${out}   Run Process   ps -ef | grep ${keyword} | grep -v grep | awk '{print $2}' | xargs kill -9   shell=True
    END
    ${res}=    Run Keyword And Ignore Error    Get System Time From BTS
    ${START_TIME}=    Get Time    exclude_millis=yes
    ${START_TIME}=    Set Variable If    '${res[0]}'=='PASS'    ${res[1]}    ${START_TIME}
    Set Suite Variable    ${START_TIME}


TRANS Test Common Teardown
    [Documentation]  TRANS Test Common Teardown, called by 'test teardown'
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | TRANS Test Common Teardown |
    Run Keyword And Ignore Error   Rest Logout DU
    Run Keyword And Ignore Error  Switch Close All Connections
    Run Keyword And Ignore Error  selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  WEBUI Logout
    Run Keyword And Ignore Error  selenium_coam.Disable_Virtual_Display
    FOR  ${keyword}  IN   firefox   geckodriver
        ${out}   Run Process   ps -ef | grep ${keyword} | grep -v grep | awk '{print $2}' | xargs kill -9   shell=True
    END


_Init_Global_Variable
#     ${result}   ${DU_OAM_IP}   Run Keyword And Ignore Error
#    ...   Set Variable   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#    Set Suite Variable   ${DU_OAM_IP}

    ${result}  ${DU_OAM_SSH_USERNAME}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    Set Suite Variable   ${DU_OAM_SSH_USERNAME}

    ${result}  ${DU_OAM_SSH_PASSWORD}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Set Suite Variable   ${DU_OAM_SSH_PASSWORD}

#    ${result}  ${DU_OAM_WEBUI_URL}        Run Keyword And Ignore Error
#    ...   Set Variable  https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
#    Set Suite Variable   ${DU_OAM_WEBUI_URL}

    ${result}  ${DU_OAM_WEBUI_USER}      Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.username}
    Set Suite Variable   ${DU_OAM_WEBUI_USER}

    ${result}  ${DU_OAM_WEBUI_PASSWORD}   Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    Set Suite Variable   ${DU_OAM_WEBUI_PASSWORD}

    ${result}  ${UTE_USERNAME}       Run Keyword And Ignore Error
    ...   Set Variable    ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable   ${UTE_USERNAME}

    ${result}  ${UTE_PASSWORD}        Run Keyword And Ignore Error
    ...   Set Variable  ${tl.test_pc.default_ssh_connection_details.password}
    Set Suite Variable   ${UTE_PASSWORD}

    ${BOOLEAN_TRUE}  Convert To Boolean  True
    Set Suite Variable   ${BOOLEAN_TRUE}

    ${BOOLEAN_FALSE}  Convert To Boolean  False
    Set Suite Variable   ${BOOLEAN_FALSE}

    #
    # it's a WA, please see https://jira3.int.net.nokia.com/browse/TALIB-846,
    # this jira has blocked a few transport TA cases design and debug
    # one of other WAs is to declare a global python variable, 'TRANS_PARA = _trans_para'
    # i don't know which WA is better, please give me suggestion if you like to replace current WA with new one.
    # P.S.:
    # 1/ this issue was posted in Microsoft Team on October 17, 2019. Nearly 3 months passed, but it's not solved.
    # 2/ this issue was submitted in Jira system(jira id:TALIB846) on November 27, 2019. Exactly 1.5 months passed, but it's not solved.
    # i think TAF team does not have time to solved it because there are other higher priority tasks for them.
    # So we Hangzhou team should use WA(Walk Around) to get rid of this issue, otherwise it impacts our transport TA project schedule too much.
    # In future, when TAF team fix this TALIB-846, i will switch to latest solution.
    # If any questions, we can have a mail to discuss or face to face dicussion. Nokia company emphasizes that 5G project is very important,
    # so that we should find way to push 5G TA project forward by Hangzhou team ourselves, by everyone of Hangzhou team.
    # And it's not right if it is blocked by a specifical person.
    #
    ${result}   ${TRANS_PARA}   Run Keyword And Ignore Error    Set Variable  ${tl._trans_para}
    Set Suite Variable   ${TRANS_PARA}

    Run Keyword If  """${TRANS_PARA}"""=="""${NONE}"""   _Disp_Global_Variable
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""

    ${result}  ${DU_SWITCH_IP}    Run Keyword And Ignore Error
    ...   Set Variable  ${TRANS_PARA["du_switch"]["switch1"]["du_switch_ip"]}
    ${DU_SWITCH_IP}  Set Variable If  """${result}"""=="""FAIL"""   ${EMPTY}    ${DU_SWITCH_IP}
    Set Suite Variable   ${DU_SWITCH_IP}

    ${result}  ${DU_SWITCH_USERNAME}    Run Keyword And Ignore Error
    ...   Set Variable  ${TRANS_PARA["du_switch"]["switch1"]["username"]}
    ${DU_SWITCH_USERNAME}  Set Variable If  """${result}"""=="""FAIL"""   ${EMPTY}    ${DU_SWITCH_USERNAME}
    Set Suite Variable   ${DU_SWITCH_USERNAME}

    ${result}  ${DU_SWITCH_PASSWORD}    Run Keyword And Ignore Error
    ...   Set Variable  ${TRANS_PARA["du_switch"]["switch1"]["password"]}
    ${DU_SWITCH_PASSWORD}  Set Variable If  """${result}"""=="""FAIL"""   ${EMPTY}    ${DU_SWITCH_PASSWORD}
    Set Suite Variable   ${DU_SWITCH_PASSWORD}

    ${result}  ${DU_SWITCH_EN_PASSWORD}    Run Keyword And Ignore Error
    ...   Set Variable  ${TRANS_PARA["du_switch"]["switch1"]["en_password"]}
    ${DU_SWITCH_EN_PASSWORD}  Set Variable If  """${result}"""=="""FAIL"""   ${EMPTY}    ${DU_SWITCH_EN_PASSWORD}
    Set Suite Variable   ${DU_SWITCH_EN_PASSWORD}

    _Disp_Global_Variable


_Disp_Global_Variable
    Log To Console  DU_OAM_IP:${DU_OAM_IP}
    Log To Console  DU_OAM_SSH_USERNAME:${DU_OAM_SSH_USERNAME}
    Log To Console  DU_OAM_SSH_PASSWORD:${DU_OAM_SSH_PASSWORD}
    Log To Console  DU_OAM_WEBUI_URL:${DU_OAM_WEBUI_URL}
    Log To Console  DU_OAM_WEBUI_USER:${DU_OAM_WEBUI_USER}
    Log To Console  DU_OAM_WEBUI_PASSWORD:${DU_OAM_WEBUI_PASSWORD}
    Log To Console  UTE_USERNAME:${UTE_USERNAME}
    Log To Console  UTE_PASSWORD:${UTE_PASSWORD}
    Log To Console  DU_SWITCH_IP:${DU_SWITCH_IP}
    Log To Console  DU_SWITCH_USERNAME:${DU_SWITCH_USERNAME}
    Log To Console  DU_SWITCH_PASSWORD:${DU_SWITCH_PASSWORD}
    Log To Console  DU_SWITCH_EN_PASSWORD:${DU_SWITCH_EN_PASSWORD}


_Init_BTS_Info_Variable
    [Teardown]    Run Keyword And Ignore Error    Rest Logout DU
    Rest Login DU
    ${SCF_BACKUP_DIR}    Get A Directory  scfbackup
    ${DU_SCF_BACKUP_FILE}   Get A File    ${SCF_BACKUP_DIR}    scf_backup.xml

    # coam.Get_Current_Scf_File  local_dir_path=${SCF_BACKUP_DIR}   file_name=scf_backup.xml   timeout=60
     coam.Get_Current_Scf_File  local_dir_path=${SCF_BACKUP_DIR}   file_name=scf_backup.xml   timeout=60
    Set Suite Variable   ${DU_SCF_BACKUP_FILE}

    ${DU_BTS_ID}  Get MRBTS Id   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_BTS_ID}

    ${DU_NRBTS_ID}  Get NRBTS Id   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_NRBTS_ID}

    ${DU_MRBTS_VER}  Get MRBTS Version   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_MRBTS_VER}

    ${DU_NRBTS_VER}  Get NRBTS Version   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_NRBTS_VER}

    ${DU_EQM_VER}  Get EQM Version   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_EQM_VER}

    ${DU_MNL_VER}  Get MNL Version   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_MNL_VER}

    ${DU_TNL_VER}  Get TNL Version   scf_path=${DU_SCF_BACKUP_FILE}

    Get Existing Fault Id List
    Get Existing History Fault Id List


_Disp_BTS_Info
    Log To Console  DU_BTS_ID:${DU_BTS_ID}
    Log To Console  DU_NRBTS_ID:${DU_NRBTS_ID}
    Log To Console  DU_MRBTS_VER:${DU_MRBTS_VER}
    Log To Console  DU_NRBTS_VER:${DU_NRBTS_VER}
    Log To Console  DU_EQM_VER:${DU_EQM_VER}
    Log To Console  DU_MNL_VER:${DU_MNL_VER}
    Log To Console  DU_TNL_VER:${DU_TNL_VER}
    Log To Console  DU_TNL_OAM:${DU_TNL_OAM}
    Log To Console  DU_MNLENT:${DU_MNLENT}


_Init_Timezone_Info
    [Teardown]  Run Keyword And Ignore Error  TAF Disconnect From DU OAM
    Taf Connect To Du Oam
    ${out}    ssh.Execute   command=date +"%Z"
    ${TIMEZONE_NAME}  Get Lines Matching Regexp   ${out}   \\S+

    ${out}    ssh.Execute   command=date +"%z"
    ${TIMEZONE_DIFFERENCE}  Get Lines Matching Regexp   ${out}   \\S\\d{4,4}
    ${TIMEZONE_DIFFERENCE}  Set Variable  ${TIMEZONE_DIFFERENCE[0:3]}

    Log To Console  TIMEZONE_NAME:${TIMEZONE_NAME}
    Log To Console  TIMEZONE_DIFFERENCE:${TIMEZONE_DIFFERENCE}

    Set Suite Variable  ${TIMEZONE_NAME}
    Set Suite Variable  ${TIMEZONE_DIFFERENCE}


_Init_Tools
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""

    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #Tools download: from tools repostory to UTE
    Log To Console  Tools: Repostory ---> UTE
    Download File From Remote To Local   remote_ip=${tools_repository["ip"]}
     ...   username=${tools_repository["username"]}
     ...   password=${tools_repository["password"]}
     ...   remote_folder=${tools_repository["repo_tool_folder"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   local_folder_root=${TOOLS_INFO["work_folder_root"]}

    Download File From Remote To Local   remote_ip=${tools_repository["ip"]}
     ...   username=${tools_repository["username"]}
     ...   password=${tools_repository["password"]}
     ...   remote_folder=${tools_repository["repo_data_folder"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}
     ...   local_folder_root=${TOOLS_INFO["work_folder_root"]}

    ${result}  ${simulator4DU}    Run Keyword And Ignore Error
    ...   Set Variable  ${TRANS_PARA["simulator4DU"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #from UTE to simulator4DU
    Log To Console  Tools: UTE ---> simulator4DU
    Upload File From Local To Remote   remote_ip=${simulator4DU["ip"]}
     ...   username=${simulator4DU["username"]}
     ...   password=${simulator4DU["password"]}
     ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}

    Upload File From Local To Remote   remote_ip=${simulator4DU["ip"]}
     ...   username=${simulator4DU["username"]}
     ...   password=${simulator4DU["password"]}
     ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}

    #from UTE to OAM
    Log To Console  Tools: UTE ---> OAM
    Upload File From Local To Remote   remote_ip=${DU_OAM_IP}
     ...   username=${DU_OAM_SSH_USERNAME}
     ...   password=${DU_OAM_SSH_PASSWORD}
     ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}

    Upload File From Local To Remote   remote_ip=${DU_OAM_IP}
     ...   username=${DU_OAM_SSH_USERNAME}
     ...   password=${DU_OAM_SSH_PASSWORD}
     ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}

    ${SIMULATOR4DU_IF}  _Get Interface Name Of Simulator4DU   ${simulator4DU["service_ip"]}
    ${SIMULATOR4DU_IFV6}  _Get Interface Name Of Simulator4DU   ${simulator4DU["service_ipv6"]}
    Set Suite Variable   ${SIMULATOR4DU_IF}
    Set Suite Variable   ${SIMULATOR4DU_IFV6}


Download File From Remote To Local
    [Arguments]  ${remote_ip}  ${username}    ${password}   ${remote_folder}    ${local_folder}   ${local_folder_root}
    [Teardown]  ssh.Disconnect
    Wait Until Keyword Succeeds    10x     2s   Host Should Be Pingable   target_ip=${remote_ip}

    #create local folder if not exists
    ${run_code}  ${out}     Run And Return RC And Output   command=sudo mkdir -p ${local_folder}
    ${run_code}  ${out}     Run And Return RC And Output   command=sudo chmod 777 -R ${local_folder_root}

    ${local_version_file_name}   OperatingSystem.Join Path   ${local_folder}   version.repo
    ${local_version}   _Get Version Number Of Local   file_name=${local_version_file_name}

    ssh.Connect_To    hostname=${remote_ip}    username=${username}    password=${password}
    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote Repo   file_name=${remote_version_file_name}

    Return From Keyword If    ${local_version}>=${remote_version}

    ${out}   ssh.Execute  command=ls ${remote_folder}
    ${lines}  Split String   ${out}
    FOR  ${file}  IN  @{lines}
         ${remote_folder_tmp}   OperatingSystem.Join Path   ${remote_folder}     ${file}
         ${local_folder_tmp}   OperatingSystem.Join Path   ${local_folder}     ${file}
         Log To Console   ${file} ${remote_ip}:${remote_folder}-->UTE:${local_folder}
         ssh.Download File   remote_path=${remote_folder_tmp}   local_path=${local_folder_tmp}
    END


Upload File From Local To Remote
    [Arguments]  ${remote_ip}  ${username}    ${password}   ${remote_folder}    ${local_folder}
    [Teardown]  ssh.Disconnect
    Wait Until Keyword Succeeds    10x     2s   Host Should Be Pingable   target_ip=${remote_ip}

    ${local_version_file_name}   OperatingSystem.Join Path   ${local_folder}   version.repo
    File Should Exist   ${local_version_file_name}
    ${local_version}   _Get Version Number Of Local   file_name=${local_version_file_name}

    ssh.Connect_To    hostname=${remote_ip}    username=${username}    password=${password}
    #create remote folder if not exists
    ${out}    ssh.Execute   command=mkdir -p ${remote_folder}

    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote    file_name=${remote_version_file_name}

    Return From Keyword If    ${remote_version}>=${local_version}

    ${run_code}   ${out}   Run And Return RC And Output  command=ls ${local_folder}
    ${lines}  Split String   ${out}
    FOR  ${file}  IN  @{lines}
         ${remote_folder_tmp}   OperatingSystem.Join Path   ${remote_folder}     ${file}
         ${local_folder_tmp}   OperatingSystem.Join Path   ${local_folder}     ${file}
         Log To Console  ${file} UTE:${remote_folder}-->${remote_ip}:${remote_folder}
         ssh.Upload File   local_path=${local_folder_tmp}    remote_path=${remote_folder_tmp}
    END

    ${out}    ssh.Execute   command=chmod 777 -R ${remote_folder}


Host Should Be Pingable
    [Arguments]  ${target_ip}
    [Documentation]   Check whether Host is Pingable or not from current running UTE server. If it's pingable, do nothing.
    ...    If it's not pingable, report FAIL.
    ...    BK-Area:TRANS-Connection
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | target_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    | ${rtn} | Host Should Be Pingable | 10.97.120.118 |
    ${bIpV6Address}    Set Variable If    ":" in """${target_ip}"""    1      0
    ${cmd}    Set Variable If   ${bIpV6Address}==1   sudo ping6 ${target_ip} -c 2
    ...   sudo ping ${target_ip} -c 2
    ${run_code}   ${out}    Run And Return RC And Output    command=${cmd}
    Should Be True   ${run_code}==0


_Get Version Number Of Local
    [Arguments]    ${file_name}
    Process.Run Process    command=touch ${file_name}   shell=True
    ${run_code}  ${out}     Run And Return RC And Output   command=cat ${file_name}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


_Get Version Number Of Remote Repo
    [Arguments]    ${file_name}
    ${out}   ssh.Execute   command=ls ${file_name}
    Should Be True  """No such file""" not in """${out}"""
    ${out}   ssh.Execute  command=cat ${file_name}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


_Get Version Number Of Remote
    [Arguments]    ${file_name}
    ${out}   ssh.Execute   command=touch ${file_name}
    ${out}   ssh.Execute  command=cat ${file_name}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0
    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


Get TA PC Local IP
    [Documentation]    Get TA PC Local IP
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    IP address of UTE
    ...    Example
    ...    | Get TA PC Local IP |
    ${var_exist}    Run Keyword And Ignore Error    Variable Should Exist    ${LOCAL_IP}

    ${ips}  Run Keyword If    "${var_exist[0]}"!="PASS"   Get Local IP
    ...   ELSE IF   "${LOCAL_IP}"=="${EMPTY}"    Get Local IP
    ...   ELSE   set variable   ${ips}

    #${LOCAL_IP}  Set Variable If   "${LOCAL_IP}"=="${EMPTY}"    ${ips[0]}   ${LOCAL_IP}
    #${LOCAL_IP6_ADDRESS}  Set Variable If    "${LOCAL_IP}"=="${EMPTY}"   ${ips[1]}   ${LOCAL_IP6_ADDRESS}
    ${LOCAL_IP}  Set Variable   ${ips[0]}
    ${LOCAL_IP6_ADDRESS}    Set Variable  ${ips[1]}

    Set Suite Variable    ${LOCAL_IP}
    Set Suite Variable    ${LOCAL_IP6_ADDRESS}

    ${out}  Run Process  ip route    shell=True   stderr=STDOUT
    ${LOCAL_IP_GATEWAY}  Get Default Gateway From Content  ${out.stdout}
    Set Suite Variable   ${LOCAL_IP_GATEWAY}

    log to console  LOCAL_IP:${LOCAL_IP}
    log to console  LOCAL_IP_GATEWAY:${LOCAL_IP_GATEWAY}
    log to console  LOCAL_IP6_ADDRESS:${LOCAL_IP6_ADDRESS}


Get Local IP
    [Documentation]    get local eth0 or eth3 interface ip
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    IP address of eth0 or eth3
    ...    Example
    ...    | Get Local IP |
    ${rtn}   ${ipv4}  ${ipv6}    Get Local IP By Interface    intf=eth0
    Return From Keyword If  '${rtn}'=='True'   ${ipv4}   ${ipv6}

    ${rtn}   ${ipv4}  ${ipv6}    Get Local IP By Interface    intf=eth1
    Log To Console   ${ipv4} ${ipv6}
    Return From Keyword If  '${rtn}'=='True'   ${ipv4}   ${ipv6}

    ${rtn}   ${ipv4}  ${ipv6}    Get Local IP By Interface    intf=eth3
    Log To Console   ${ipv4} ${ipv6}
    Return From Keyword If  '${rtn}'=='True'   ${ipv4}   ${ipv6}

    [Return]    ${ipv4}   ${ipv6}


Get Local IP By Interface
    [Arguments]    ${intf}=eth0
    [Documentation]    get ip list of local interface
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | intf | optional | interface name of linux,default is eth0 |
    ...    *RETURN VALUE*
    ...    IP address of eth0 or eth3
    ...    Example
    ...    | Get Local IP by Interface |
    ${rtn}   Set Variable   False
    ${stdout}    Run    ip addr show ${intf}

    ${reg_exp4}    Set Variable    (\\d+\\.\\d+\\.\\d+\\.\\d+)
    ${reg_exp6}    Set Variable   inet6\\s+(2a\\S+)/\\d+.+

    ${matches}   Get Regexp Matches    ${stdout}    ${reg_exp4}   1
    ${ip_addr4}    Set Variable If    ${matches}    ${matches[0]}
    ${rtn}    Set Variable If    ${matches}   True

    ${matches}    Get Regexp Matches    ${stdout}    ${reg_exp6}   1
    ${ip_addr6}    Set Variable If    ${matches}    ${matches[0]}

    [Return]   ${rtn}  ${ip_addr4}   ${ip_addr6}


Get System Time From BTS
    [Teardown]   Run Keyword And Ignore Error   ssh.Disconnect    connection=myconn
    [Documentation]    Get System Time from BTS
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    | ${system_time} | Get System Time from BTS |
    ...    System time which formatted "%Y-%m-%d %H:%M:%S"
    ...    | Log | ${system_time} |
     ssh.Connect_To    hostname=${DU_OAM_IP}   username=${DU_OAM_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}   alias=myconn
    ${ret}   ssh.Execute   command=date +"%Y-%m-%d %H:%M:%S"   connection=myconn
    ${bts_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    [Return]    ${bts_time[0]}


_Install Packages
    ${cmd}  Set Variable   sudo apt list --installed | grep tshark
    ${out}   Run Process   ${cmd}  shell=True
    Run Keyword If  ${out.rc}!=0  Log To Console  Please install tshark in UTE firstly(Linux command: sudo apt-get install tshark --yes)
    Should Be True   ${out.rc}==0

    #${cmd}  Set Variable   sudo apt-get install tshark --yes
    #${out}   Run Process   ${cmd}  shell=True


Get A Directory
    [Arguments]  @{paths}
    [Documentation]   Get A Directory
    ...    BK-Area:TRANS-Wireshark
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | please see examples |
    ...    *RETURN VALUE*
    ...    string
    ...    Example
    ...    | ${modified_scf_path} | Get A Directory  | BackupSCF |
    ${rtn}   TRANS Get A Directory   @{paths}
    #${rtn}   TRANS Get A Directory   path=@{paths}   #error to call python kw like this style
    [Return]  ${rtn}

Get A File
    [Arguments]  @{paths_or_filename}
    [Documentation]   Get A File
    ...    BK-Area:TRANS-Wireshark
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | please see examples |
    ...    *RETURN VALUE*
    ...    string
    ...    Example
    ...    | ${modified_scf_path} | Get A File  | BackupSCF | modified_scf.xml |
    ${rtn}  TRANS Get A File   @{paths_or_filename}
    #${rtn}  TRANS Get A File   path=${paths_or_filename}  #error to call python kw like this style
    [Return]  ${rtn}


Analyze Pcap2txt
    [Arguments]  ${src}   ${dest}    ${filter}=${EMPTY}
    [Documentation]    Convert wireshark pcap file to TXT file according to filter
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | the pcap file to be converted in UTE server |
    ...    | dest | Yes | the target TXT file to be generated in UTE server |
    ...    | filter | No | filter used to generate targe TXT file |
    ...    *RETURN VALUE*
    ...    Wireshark stored path of destination
    ...    Example
    ...    | Analyze pcap2txt  |   ${local_file}  |    ${txt_file} |                |
    ...    | ${txt_file}               |   Get A File     |   Wireshark    |  mypcapfile_filter.txt |
    ...    | Analyze pcap2txt  |   ${local_file}  |    ${txt_file} |  icmp          |

    OperatingSystem.File Should Exist    ${src}
    ${cmd}   Set Variable If   '${filter}'==''   tshark -r ${src} -V -Q 2>/dev/null >${dest}
    ...    tshark -r ${src} -V -Q -Y "${filter}" 2>/dev/null >${dest}
    ${rc}   ${out}   Run And Return Rc And Output    ${cmd}


Analyze Pcap2xml
    [Arguments]  ${src}   ${dest}    ${filter}=${EMPTY}
    [Documentation]    Convert wireshark pcap file to TXT file according to filter
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | the pcap file to be converted in UTE server |
    ...    | dest | Yes | the target TXT file to be generated in UTE server |
    ...    | filter | No | filter used to generate targe TXT file |
    ...    *RETURN VALUE*
    ...    Wireshark stored path of destination
    ...    Example
    ...    | ${xml_file}               |  Get A File      |  Wireshark  |   mypcapfile.xml |
    ...    | Analyze pcap2xml  |   ${local_file}  |   ${xml_file}  |                 |

    OperatingSystem.File Should Exist    ${src}
    ${cmd}    Set Variable If    '${filter}'==''    tshark -r "${src}" -T pdml -V -Q 2>/dev/null > "${dest}"
    ...    tshark -r "${src}" -T pdml -V -Q -Y "${filter}" 2>/dev/null >${dest}
    ${rc}    Run Process    ${cmd}   shell=True
    
    
TAF Connect To DU OAM
    [Arguments]  ${alias}=default
    [Documentation]   TAF Connect To DU OAM
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | myalias  |  no | aliase name |
    ...    *RETURN VALUE*
    ...    connection instance
    ...    Example
    ...    | TAF Connect To DU OAM   |
    ssh.Connect_To    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=${alias}


TAF Connect To Simulator4DU
    [Arguments]  ${alias}=default
    [Documentation]   TAF Connect To Simulator4DU
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | myalias  |  no | aliase name |
    ...    *RETURN VALUE*
    ...    connection instance
    ...    Example
    ...    | TAF Connect To Simulator4DU  |
    ${simulator4DU}     Set Variable  ${TRANS_PARA["simulator4DU"]}
    ssh.Connect_To    hostname=${simulator4DU["ip"]}  username=${simulator4DU["username"]}  password=${simulator4DU["password"]}  alias=${alias}


TAF Disconnect From DU OAM
    [Arguments]  ${alias}=default
    [Documentation]   TAF Disconnect From DU OAM
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | myalias  |  no | aliase name |
    ...    *RETURN VALUE*
    ...    connection instance
    ...    Example
    ...    | TAF Disconnect From DU OAM  |
    ssh.Disconnect   connection=${alias}


TAF Disconnect From Simulator4DU
    [Arguments]  ${alias}=default
    [Documentation]   TAF Disconnect From Simulator4DU
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | myalias  |  no | aliase name |
    ...    *RETURN VALUE*
    ...    connection instance
    ...    Example
    ...    | TAF Disconnect From Simulator4DU |
    ssh.Disconnect   connection=${alias}


Get Host Type
    [Arguments]  ${alias}=default
    [Documentation]    Get Host Type from host. Please use it after keyword connect to ssh host.
    ...    *AUTHOR* xiaqing.chen@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    Nonte
    ...    *RETURN VALUE*
    ...    host type, e.g, OAM, CCP, UES, CES, CPIF, DB,SN,RAP, FSMr3RAP, COMPUTE, OTHER
    ...    Example
    ...    | Get Host Type |
    ${res}     ssh.Execute     command=hostname   connection=${alias}
    ${res}    Set Variable    ${res.upper()}
    ${host_type}    Run Keyword If    "OAM" in """${res}"""    Set Variable    OAM
    ...    ELSE IF    "CCP" in """${res}"""    set variable    CCP
    ...    ELSE IF    "UES" in """${res}"""    set variable    UES
    ...    ELSE IF    "CES" in """${res}"""    set variable    CES
    ...    ELSE IF    "CPIF" in """${res}"""    set variable    CPIF
    ...    ELSE IF    "DB" in """${res}"""    set variable    DB
    ...    ELSE IF    "SN" in """${res}"""    set variable    SN
    ...    ELSE IF    "FCTJ" in """${res}"""    set variable    DU
    ...    ELSE IF    "FCT-" in """${res}"""    set variable    DU
    ...    ELSE IF    "COMPUTE-" in """${res}"""    set variable    COMPUTE
    ...    ELSE    set variable    OTHER
    [Return]    ${host_type}


Parse Ipv4 Address
    [Arguments]  ${content}
    [Documentation]    get ip4 address
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0 |
    ...    *RETURN VALUE*
    ...    IPv4 address
    ...    Example
    ...    | ${ipv6address} | Parse ipv4 address |   ${out} |
    ${matches}    Get Regexp Matches    ${content}    inet (\\d+.\\d+.\\d+.\\d+)/([0-9]{1,3}).+brd.+   1    2
    ${ip4_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip4_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    [Return]    ${ip4_addr}     ${ip4_mask_len}


Parse Ipv6 Address
    [Arguments]  ${content}
    [Documentation]    get ip6 address
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0 |
    ...    *RETURN VALUE*
    ...    IPv6 address
    ...    Example
    ...    | ${ipv6address} | Parse ipv6 address |   ${out} |
    ${matches}    Get Regexp Matches    ${content}    inet6 ([23]\\S+)/([0-9]{1,3}).+scope global   1    2
    ${ip6_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip6_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    [Return]    ${ip6_addr}     ${ip6_mask_len}


Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    ...    the case will fail.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | retry            | No | retry, e.g, 300s, 5 min,etc. default is 200s |
    ...    | retry_interval | No | retry_interval, e.g, 10s, 20s,etc. default is 10s |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Wait Until BTS Should Be Normal |
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair


Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | No    | default value is 'default' |
    ...    | cell_type | No  | lte or nr, default value is nr |
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | Gnb Cell Should Be Onair WebUI |  |
    ${status}       coam.Get_Bts_Statuses   connection=${alias}

    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${operationalState}    Enabled

    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked

    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir

    #cell info
    ${cell_status}      coam.Get_Cells_Info   cell_type=${cell_type}

    ${Status}    Get From Dictionary    ${cell_status[0]}    status

    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${tmp}    Enabled

    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
    Should Be Equal    ${tmp}    Online

    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked

    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked

    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active


WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | virtual_disable | No    | default is True |
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | WEBUI Login |  |
    Log To Console  START:WEBUI Login
#    Run Keyword If     ${virtual_enable}     Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Log To Console  Try to logout before login...
    Run Keyword And Ignore Error    selenium_coam.Logout
    Log To Console  Logout successfully...
    Log To Console  Try to login...
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     coam.connect_to    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    Log To Console  END:WEBUI Login!


WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | virtual_disable | No    | default is True |
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | WEBUI Logout |  |
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    1s
    Log To Console  END:WEBUI Logout!


Get TNL Number
    [Arguments]   ${vm}=OAM
    [Documentation]   Get TNL number for node
    ...    *AUTHOR* hongping.rao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | vm | Man.      | VNF node name, e.g. OAM, UES, CCP, CES, CPIF, RAP |
    ...    *RETURN VALUE*
    ...   TNL number , e.g, 1, 2, 3, 4, 5 or 6
    ...    Example
    ...    | ${index} | Get TNL Number | OAM  |
    ${index}=    Run Keyword If   '${vm.lower()}'=='oam'  Set Variable   ${DU_TNL_OAM}
    ...           ELSE     Fail    vm parameter is incorrect!
    [Return]   ${index}


Print A Dictionary
    [Arguments]  ${one_dict}
    [Documentation]   Print A Dictionary's keys/values
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | one_dict | yes      |  |
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | Print A Dictionary | ${my_dict_var}   |
    ${length}   Get Length  ${one_dict}
    Run Keyword If  ${length}==0   Log To Console  Dictionary is empty, can't be printed!
    Return From Keyword If  ${length}==0

    FOR   ${key}  IN  @{one_dict.keys()}
        Log To Console  ${key}->${one_dict["${key}"]}
    END


Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   Rest Login DU
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | ip_address | No      | alias, default value is ${DU_OAM_IP} |
    ...    | alias      | No      | alias, default value is 'default' |
    ...    | username | No      | alias, default value is ${DU_OAM_WEBUI_USER} |
    ...    | password | No      | alias, default value is ${DU_OAM_WEBUI_PASSWORD} |
    ...    *RETURN VALUE*
    ...   connection instance
    ...    Example
    ...    |  Rest Logout DU |   |
    ...    |  Rest Logout DU | myalias   |
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}    coam.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}


Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | No      | alias, default value is 'default' |
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | Rest Logout DU |   |
    ...    | Rest Logout DU | myalias   |
     coam.Teardown  connection=${alias}



Send CTRL_C
    [Arguments]  ${alias}=default
    [Documentation]    it sends CTRL+C key message and interrupt current running command
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via hran_network library.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    No return value.
    ...    Example
    ...    | Send CTRL_C |
    ${crtl_c}    Evaluate    chr(int(3))
    ${out}   ssh.Write Input    data=${crtl_c}     connection=${alias}
    ${out}   ssh.Write Input    data=sync   flush=${True}   connection=${alias}
    Sleep    1.3s
    [Return]  ${out}


Get Sudo
    [Arguments]  ${alias}=default
    [Documentation]    it sends CTRL+C key message and interrupt current running command
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via hran_network library.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    No return value.
    ...    Example
    ...    |  Get Sudo |
    ssh.Send Command    command=which sudo ; echo $?    get_pty=${TRUE}   connection=${alias}
    Sleep  0.5
    ${out}   ssh.Read Output    connection=${alias}
    ${lines}   Split String   ${out}
    ${exit_code}   Set Variable  ${lines[-1]}
    ${exit_code}   Evaluate  ${exit_code.strip()}
    ${rtn}   Set Variable If  "${exit_code}"=="1"  ${EMPTY}   sudo
    [Return]  ${rtn}


Connect To DU Switch
    [Documentation]   Connect to RAP Switch
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    Connection id
    ...    Example
    ...    | ${switch_conn} | Connect To DU Switch |
    ${conn}  Connect To Switch   switch_ip=${DU_SWITCH_IP}
       ...  switch_user=${DU_SWITCH_USERNAME}    switch_password=${DU_SWITCH_PASSWORD}   switch_en_password=${DU_SWITCH_EN_PASSWORD}

    [Return]    ${conn}


Get Full Command Path For Simulator
    [Arguments]  ${command}
    ${full_cmd}    OperatingSystem.Join Path     ${TOOLS_INFO["work_folder_tool"]}   ${command}
    [Return]  ${full_cmd}



_Get Interface List Of Simulator4DU
    [Arguments]  ${alias}=default
    [Teardown]  Run Keyword And Ignore Error   TAF Disconnect From Simulator4DU
    ${interface_list}   Create List
    TAF Connect To Simulator4DU

    ${out}   ssh.Send Command  command=cat /proc/net/dev   connection=${alias}
    ${out}   ssh.Read Output    connection=${alias}
    ${lines}  Set Variable   ${out.split('\n')}

    FOR  ${line}  IN  @{lines}
        ${line}  Set Variable  ${line.strip()}
        Continue For Loop If  ${line.__len__()}==0
        ${tokens}  Split String  ${line}
        Continue For Loop If  ${tokens.__len__()} < 16
        ${tokens_0}   Set Variable  ${tokens[0]}
        Continue For Loop If   "${tokens_0}"=="lo:"
        ${start_with_face}   Set Variable  ${tokens_0.startswith('face')}
        Continue For Loop If   """${start_with_face}"""=="True"
        ${interface}   Set Variable   ${tokens_0.split(':')[0]}
        Append To List  ${interface_list}   ${interface}
    END
    [Return]  ${interface_list}


_Get Interface Name Of Simulator4DU
    [Arguments]  ${ip}  ${alias}=default
    [Teardown]  Run Keyword And Ignore Error   TAF Disconnect From Simulator4DU
    ${interface_list}   _Get Interface List Of Simulator4DU    alias=${alias}

    TAF Connect To Simulator4DU

    #${out}   ssh.Send Command  command=cat /proc/net/dev   connection=${alias}
    #${out}   ssh.Read Output    connection=${alias}
    #${lines}  Set Variable   ${out.split('\n')}

    ${found}   Set Variable  0
    ${interface}  Set Variable  ${None}
    FOR  ${interface}  IN  @{interface_list}
        ${out}   ssh.Send Command  command=ip addr show dev ${interface}   connection=${alias}
        ${out}   ssh.Read Output    connection=${alias}
        ${matched}  Check Pattern Exist  ${out}   .*${ip}.*
        ${found}  Set Variable If  ${matched}==1   1   0
        Exit For Loop If  ${matched}==1
    END

    ${interface}   Set Variable If  ${found}==1   ${interface}
    [Return]  ${interface}


Get Mac Of OAM
    [Arguments]  ${interface}
    [Teardown]  Run Keyword And Ignore Error  TAF Connect To DU OAM
    TAF Connect To DU OAM
    ${out}   ssh.Send Command  command=ifconfig ${interface}
    ${out}   ssh.Read Output
    ${lines}  Set Variable   ${out.split('\n')}

    ${mac}  Set Variable  ${EMPTY}
    ${mac_pattern}    Set Variable    ether\\s+([0-9a-f]+\\:[0-9a-f]+\\:[0-9a-f]+\\:[0-9a-f]+\\:[0-9a-f]+\\:[0-9a-f]+)
    FOR  ${line}  IN  @{lines}
        ${matches}   Get Regexp Matches    ${line}    ${mac_pattern}   1
        ${mac}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
        Exit For Loop If   ${matches}
    END
    [Return]  ${mac}


Get Default Gateway From Content
    [Arguments]  ${content}
    ${route}  Set Variable  ${EMPTY}
    ${matches}  Get Regexp Matches  ${content}   default via (\\d+\\.\\d+\\.\\d+\\.\\d+)\\s+.*  1
    ${route}   Set Variable If  ${matches}   ${matches[0]}
    [Return]  ${route}

Change Counter Generation to 5min
    Log To Console  Change Counter Generation to 5min
    Wait Until Keyword Succeeds  2x  10s   Change PM Collect Interval   interval=5
    Get Current PM File    interval=5
    Wait For Get Next PM Generated   interval=5
    Check File Generated Interval Should Be Expected    expected=5

Get Current PM File
    [Arguments]  ${interval}=5
    Log To Console   Get Current PM File For ${interval} Minutes Interval
    Sync To PM Timer Clock   estimated_traffic_generating_duration=${interval}   PM_collecting_interval=${interval}
    Get PM File For Current   CounterCollectionInterval=${interval}
    ${PM_FILE_TIMESTAMP_MIN_1}  Set Variable     ${TRANS_LOCAL_PM_FILE_TIMESTAMP}
    Set Test Variable   ${PM_FILE_TIMESTAMP_MIN_1}
    Log To Console      ${PM_FILE_TIMESTAMP_MIN_1}
    Sleep  2m

Wait For Get Next PM Generated
    [Arguments]   ${interval}=5
    Log To Console  Get Next PM File For ${interval} Minutes Interval
    Get Next Counters And Verify Them   counter_table_name=${LIST_COUNTER_INFO_CHK_EXISTENCE}    CounterCollectionInterval=${interval}
    ${PM_FILE_TIMESTAMP_MIN_2}  Set Variable     ${TRANS_LOCAL_PM_FILE_TIMESTAMP}
    Set Test Variable   ${PM_FILE_TIMESTAMP_MIN_2}
    Log To Console      ${PM_FILE_TIMESTAMP_MIN_2}

Check File Generated Interval Should Be Expected
    [Arguments]  ${expected}=15
    Log To Console  Check File Generated Interval Should Be Expected:${expected}min
    Two Timestamps Interval Should Be N Minutes   timestamp1=${PM_FILE_TIMESTAMP_MIN_2}    timestamp2=${PM_FILE_TIMESTAMP_MIN_1}
    ...   N_minutes=${expected}   N_delta_seconds=31