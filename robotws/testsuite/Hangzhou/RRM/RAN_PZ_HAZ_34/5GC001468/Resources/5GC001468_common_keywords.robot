*** Settings ***
Library     DateTime
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    ./../../5GC000749/Resources/5GC000749_common_keywords.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    taf.analyzer.pcap     WITH NAME    cap

Documentation
...   author: Huang Hai
...   contact: hai.2.huang@nokia-sbell.com
...   squad group: SG_03
...   feature : 5GC001468

*** Variables ***
${gnb_path}    /tmp
${connection}    gnb
${epc_log_path}    /tmp

${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${ALIAS_ASIK}    ASIK
${fct_addr}     ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${ALIAS_5GC}      5gc
${IMSI}              460023032993580
${gNB_CPUE_PATH}    /tmp/node_CPUE20/tmp
${CPUE_LOG}    startup_cp_ue.log
${gNB_CPUE_LOG_XZ_PATH}    /ffs/run/logs/CPUE20_aasyslog/
${gNB_CPUE_LOG_XZ}    startup_cp_ue.log.xz
${f1_sctp_port}    38472
${x2_sctp_port}    38422
@{Xpath}        .//ngap.emergencyFallbackRequestIndicator
        ...     .//ngap.emergencyServiceTargetCN
        ...     .//ngap.UEContextModificationResponse_element//ngap.protocolIEs
        ...     .//ngap.UEContextReleaseRequest_element//ngap.radioNetwork
        ...     .//ngap.UEContextReleaseCommand_element//ngap.radioNetwork
        ...     .//ngap.UEContextModificationFailure_element//ngap.protocolIEs
        ...     .//ngap.UEContextModificationFailure_element//ngap.radioNetwork
        ...     .//ngap.InitialContextSetupFailure_element//ngap.protocolIEs
@{counter_id}   M55124C03501    M55125C03004    M55125C03007    M55125C03005
        ...     M55125C03008    M55124C01502    M55125C03006    M55125C03009
        ...     M55125C03001    M55125C03002    M55125C02501    M55125C02502
        ...     M55125C03003
@{full_path}    CELLS/NRCELL-1/NRRCC/NR_RRC_RELEASE_REDIR_EF_LTE
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_MOD_REQ_RECD
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_MOD_REQ_EF_RECD
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_MOD_RESP_SENT
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_MOD_RESP_EF_SENT
        ...     CELLS/NRCELL-1/NRRCC/NRRCC_RRC_RELEASE_REDIR_LTE
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_MOD_FAIL_SENT
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_MOD_FAIL_EF_SENT
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_REQ_EF_RECD
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_RESP_EF_SENT
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_REQ_RECD
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_RESP_SENT
        ...     CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_FAIL_EF_SENT

*** Keywords ***
Connect to 5GC
    csn.connect to    hostname=${5GC_IP}   username=${5GC_USERNAME}    password=${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi} | head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   ${imsi_presence}=    csn.execute   command=cmm subscriber delete --imsi ${ue_imsi} | head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   Disconnect from 5GC

Check phone attach successfully on SA env For 1468
    [Arguments]    ${5Gstatus}=PASS   ${gnb_index}=${0}    ${hwcheck_index}=${5}    ${abil_index}=${5}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}    hwcheck_index=${hwcheck_index}
    ...    abil_index=${abil_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    abil_index=${abil_index}
    ...    5Grach_ed=${5Grach_ed}    4G_check=False

Make an emergency call on UE
    [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
    Make a call on UE dial 911 on UE
    End an emergency call on UE

Make a call on UE dial 911 on UE
    [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
#    Connect to control pc via cygwin
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
    sleep   2s
    #####make a call on UE with 911#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:911    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 66    connection=cygwin
    sleep   30s

End an emergency call on UE
    [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
    csn.send_command    command=adb -s ${serial_number} shell input tap 584 2000    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

Trigger HUAWEI UE IDLE
    [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data disable    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

Trigger HUAWEI UE reboot
    [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} reboot    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

Trigger HUAWEI UE connect
    [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data enable    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

Start to collect the S1 log on eNB
    [Arguments]     ${S1_log_name}    ${port}
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    csn.send command    command=tcpdump -i ${port} sctp -w /tmp/${S1_log_name}   connection=ENB

Stop and download S1 Logs on eNB
    [Arguments]     ${S1_log_name}
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    sleep    30
    csn.send command    command=killall tcpdump     connection=ENB
    sleep    5
    csn.download_file   remote_path=/tmp/${S1_log_name}   local_path=${epc_log_path}${S1_log_name}   connection=ENB

Check PM counter updated
    [Arguments]    ${counter_id}    ${full_path}
    ${res}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
    ${values}    get dictionary values   ${res}
    ${counter_value}=    Get couter value    counter_result=${values}
    ${counter_value}=    Convert To Integer    ${counter_value}
    should be equal    ${counter_value}    ${1}

Check PM counters for A004
    sleep    10s
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55124C03501    full_path=${full_path}[0]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55125C03001    full_path=${full_path}[8]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55125C03002    full_path=${full_path}[9]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55124C01502    full_path=${full_path}[5]
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

#check IE gNB wireshark log for 1468A04
#    [Arguments]     ${logname}    ${message_filter}
#    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
#    ${Message_Type} =    Catenate    ${message_filter}
#    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Message_Type}
#    ${1468A04}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Message_Type}
#    ${Indicator}=    get_field_value_by_xpath    pdml_list=${1468A04}        xpath=@{Xpath}[0]
#    should be equal    ${Indicator[0]}    0
#    ${TargetCN} =    get_field_value_by_xpath    pdml_list=${1468A04}        xpath=@{Xpath}[1]
#    should be equal    ${TargetCN[0]}     1
#    ${UCRReq} =    get_field_value_by_xpath    pdml_list=${1468A04}     xpath=@{Xpath}[3]
#    should be equal    ${UCRReq[0]}     41
#    ${UCRResp} =    get_field_value_by_xpath    pdml_list=${1468A04}    xpath=@{Xpath}[4]
#    should be equal    ${UCRResp[0]}     41

check IE gNB wireshark log for 1468A04
    [Arguments]     ${logname}    ${message_filter}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${Message_Type} =    Catenate    ${message_filter}
    filter_packets_by_expression    filter_expression=${Message_Type}
    ${1468A04}=    filter_packets_by_expression    filter_expression=${Message_Type}
    ${Indicator}=    get_field_value_by_xpath     xpath=${Xpath}[0]
    should be equal    ${Indicator[0]}    0
    ${TargetCN} =    get_field_value_by_xpath     xpath=${Xpath}[1]
    should be equal    ${TargetCN[0]}     1
    ${UCRReq} =    get_field_value_by_xpath       xpath=${Xpath}[3]
    should be equal    ${UCRReq[0]}     41
    ${UCRResp} =    get_field_value_by_xpath      xpath=${Xpath}[4]
    should be equal    ${UCRResp[0]}     41

Check PM counters for B001
    sleep    10s
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55124C03501    full_path=${full_path}[0]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55125C03004    full_path=${full_path}[1]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55125C03007    full_path=${full_path}[2]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55125C03005    full_path=${full_path}[3]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55125C03008    full_path=${full_path}[4]
    wait until keyword succeeds    5min    1min
    ...    Check PM counter updated    counter_id=M55124C01502    full_path=${full_path}[5]
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

#check IE wireshark log for 1468B01
#    [Arguments]     ${logname}    ${message_filter}
#    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
#    ${Message_Type} =    Catenate    ${message_filter}
#    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Message_Type}
#    ${1468B01}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Message_Type}
#    ${Indicator}=    get_field_value_by_xpath    pdml_list=${1468B01}        xpath=@{Xpath}[0]
#    should be equal    ${Indicator[0]}    0
#    ${TargetCN} =    get_field_value_by_xpath    pdml_list=${1468B01}        xpath=@{Xpath}[1]
#    should be equal    ${TargetCN[0]}     1
#    ${ModifyResp} =    get_field_value_by_xpath    pdml_list=${1468B01}      xpath=@{Xpath}[2]
#    should be equal    ${ModifyResp[0]}     2
#    ${UCRReq} =    get_field_value_by_xpath    pdml_list=${1468B01}          xpath=@{Xpath}[3]
#    should be equal    ${UCRReq[0]}     41
#    ${UCRResp} =    get_field_value_by_xpath    pdml_list=${1468B01}         xpath=@{Xpath}[4]
#    should be equal    ${UCRResp[0]}     41

check IE wireshark log for 1468B01
    [Arguments]     ${logname}    ${message_filter}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${Message_Type} =    Catenate    ${message_filter}
    filter_packets_by_expression     filter_expression=${Message_Type}
    ${1468B01}=    filter_packets_by_expression     filter_expression=${Message_Type}
    ${Indicator}=    get_field_value_by_xpath        xpath=${Xpath}[0]
    should be equal    ${Indicator[0]}    0
    ${TargetCN} =    get_field_value_by_xpath    xpath=${Xpath}[1]
    should be equal    ${TargetCN[0]}     1
    ${ModifyResp} =    get_field_value_by_xpath    xpath=${Xpath}[2]
    should be equal    ${ModifyResp[0]}     2
    ${UCRReq} =    get_field_value_by_xpath    xpath=${Xpath}[3]
    should be equal    ${UCRReq[0]}     41
    ${UCRResp} =    get_field_value_by_xpath   xpath=${Xpath}[4]
    should be equal    ${UCRResp[0]}     41
