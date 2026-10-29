*** Settings ***
Documentation       Place for MTK attach_detach and UL_DL throughput
...                 author: Zhang Haijun
...                 contact: haijun.zhang@nokia-sbell.com
Library           taf.ue  WITH NAME   ute_ue
Library           taf.pdu  WITH NAME   pdu
Library           taf.ul.messaging.mtk      WITH NAME    mtk
Library           OperatingSystem
Library       taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource      taf/rfrl/common_resources/robot/connection_alias_store.robot



*** Keywords ***
Reserve ue for tests
    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
    ...  It requires that robot variable ABSTRACT_LIB_CONFIG defined.
    ...  It is strongly suggested to put this keyword into the suite setup.
    ...  If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...  :param UE_CAPABILITIES:  REAL_MEDIATEK_UE.
    ...  :param UE_alias:  It is a name to distingush ue.
    [Arguments]    ${UE_alias}=UE_0    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}

UE.Power_Reset
    [Documentation]  Power reset phone by PB
    ...     :param ue_pdu_ip: the PB ip address to power cycle the ue.
    ...     :param ue_pdu_port: The PB ip address to power cycle the ue.
    ...                     This is a workround, It need make a special cable link with two USB and one Type-C.
    ...                     One USB with power supply(red and black in general) and anothor with data transfer(white and green in general)
    [Arguments]  ${ue_pdu_ip}   ${ue_pdu_port}
    pdu.setup_pdu    model=FACOM
    ...              host=${ue_pdu_ip}
    ...              alias=pdu_devices_connect
    pdu.power_off    port=${ue_pdu_port}    pdu_device=pdu_devices_connect
    sleep    10s
    pdu.power_on    port=${ue_pdu_port}    pdu_device=pdu_devices_connect
    sleep    40s

Ue attach
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...   If UE_CAPABILITIES is REAL_MEDIATEK_UE, the keyword send AT command and wait until
    ...    OTA message "5GMM_REGISTRATION_COMPLETE" from MTK within 120 seconds.
    [Arguments]  ${UE_alias}=UE_0    ${gnb_index}=${0}    ${du_index}=0    ${timeout}=5
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ute_ue.attach_ue    ${UE_alias}    timeout=${timeout}
    ${result}    mtk.get_latest_messages_in_flow    flow_alias=MTK_OTA_MESSAGE
    FOR    ${item}    IN    @{result}
         ${flag}    Evaluate    "NR_RRCReconfigurationComplete" in """${item}"""
         exit for loop if   ${flag}
    END
    should be true   ${flag}
    ${result}    Fetch From Right    ${item}    PCI[
    ${PCI}    Fetch From Left    ${result}    ]
    log to console    attached to cell ${PCI}
    [Return]    ${PCI}

Ue detach
    [Arguments]  ${UE_alias}=UE_0
    Log to console      MTK detach starts...
    ute_ue.detach_ue    ${UE_alias}

Data Transfer
    [Documentation]  This keyword will setup PDU session first,than setup the data transfer in the backgroud.
    ...  :param DT_Name:  It is a label use to seprate from other data transfer.
    ...  :param dirction:  when it is dl, start DL data transfer; when it is ul, start UL data transfer.
    ...  :param Expected_Tput:  It should be the data throughput that you will perform.
    ...  :param Duration:  The time duration that the data transfer will keep.
    ...  :param Data_Type:  It is the data type which can be set to udp or tcp.
    ...  :packet_size: -l  option in the iperf command.
    [Arguments]  ${DT_Name}=dt1    ${UE_alias}=UE_0    ${direction}=dl
    ...   ${Expected_Tput}=20Mbits/sec    ${Duration}=180s    ${Data_Type}=udp
    ...   ${Packet_Size}=1400   ${process_num}=1
    ute_ue.start_data_transfer
    ...   dt_name=${DT_Name}  ue_alias=${UE_alias}
    ...   direction=${direction}  throughput=${Expected_Tput}
    ...   duration=${Duration}  protocol=${Data_Type}
    ...   packet_size=${Packet_Size}    parallel_streams=${process_num}

Download uepc log on ue control pc
    [Documentation]    Author: Ding Binmei
    ...                Description: Collect ue pc log on ue control pc for debugging purpose
    [Arguments]     ${local_log_folder_on_ute}=${TS_CASE_LOG_PATH}    ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Wait until keyword succeeds    1 min    2 sec    Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ${pyro_server_log_path}    Join path    ${tl.ues[${ue_index}].server_dir}    workspace/server_debug.log
    ${local_log_path}    Join path    ${local_log_folder_on_ute}    server_debug.log
    ssh.Download file    remote_path=${pyro_server_log_path}    local_path=${local_log_path}    connection=${cpc_alias}
    [Return]    ${local_log_path}
    [Teardown]    Run keyword and ignore error    ssh.disconnect    connection=${cpc_alias}

Kill ELT process on ue control pc if exists
    [Documentation]  Author: Ding Binmei
    ...              Description: This keyword can be executed before step of reserve ue.
    ...    If ELT is started by manual, reserve ue step will be stucked. This is a WA for solving this issue, to let TA continue
    ...    even if manual testers forget to close the ELT app on windows
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    ${cmd_check_if_elt_process_started}    Set variable    ps -Wef|grep -i ELT
    Wait until keyword succeeds    1 min    2 sec    Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ${is_process_exists}    ssh_common_commands.is_process_exist    process_name=ELT\\.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    ${cmd_kill_elt_process}    Set variable if    ${is_process_exists}    TASKKILL /F /IM ELT.exe /T
    Run keyword if    ${is_process_exists}
    ...    Run keywords    Log to console    ELT process exists, start to kill    AND
    ...    ssh.execute    command=${cmd_kill_elt_process}    connection=${cpc_alias}    AND
    ...    Sleep    1s
    ${is_process_exists_check_after_kill}    Run keyword if    ${is_process_exists}
    ...    ssh_common_commands.is_process_exist    process_name=ELT.exe    connection=${cpc_alias}    is_checking_on_windows=${True}
    ...    ELSE    Set variable    ${is_process_exists}
    Should not be true    ${is_process_exists_check_after_kill}    msg=ELT process is not killed successfully on ue control pc
    [Teardown]    Run keyword and ignore error    ssh.disconnect    connection=${cpc_alias}

Precondition for MTK ue attach
    [Documentation]  Author: Ding Binmei
    ...              Description: Precondtion for mtk ue
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    ${ue_capbilities}    Set variable    ${tl.ues[${ue_index}].capabilities[${cap_index}]}
    Kill ELT process on ue control pc if exists    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    MTK_common_keywords.Reserve ue for tests    UE_alias=UE_${ue_index}    UE_CAPABILITIES=${ue_capbilities}
    mtk.Setup    pyro_ip=${tl.ues[${ue_index}].ssh_connection_details.addr}    pyro_port=${tl.ues[${ue_index}].server_port}
    mtk.create_message_flow_alias    flow_alias=MTK_OTA_MESSAGE    message_type=ota_text

Verify ue attach success for NSA env
    [Documentation]  Author: Ding Binmei
    ...              Description: Add verification for NSA ue attach. Verify the message flow
    @{attach_expected_messages}    Create list    MSG_ACTIVATE_DEFAULT_EPS_BEARER_CONTEXT_ACCEPT    EMM_Attach_Complete
    ...    ERRC_RRCConnectionReconfigurationComplete
    mtk.expect_messages_in_flow    awaited_messages=${attach_expected_messages}    flow_alias=MTK_OTA_MESSAGE
