*** Settings ***
Documentation     author: yayun.zhang
...                 contact: yayun.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000786

Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           taf.hw.rf_attenuator    WITH NAME    att
#Library           ../../../../../resources/python_libs/TestCaseRequirement.py
#Library           ../../../../../resources/python_libs/cells.py
#Library           ../../../../../resources/python_libs/systemd.py
#Library           ../../../../../resources/python_libs/verify_rf.py
Variables         ../Resources/786_Case_Commission_Classical/__init__.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
#Resource          .././../5GC000738/Resources/5GC000738_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.analyzer.pcap   WITH NAME    parser
#Library    Attenuation.Attenuation    WITH NAME    atten
#Library    sigspark.SigSpark    WITH NAME    spark

*** Variables ***
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_COAM}         https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_COAM_LOCAL}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI2_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI2_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI2_PWD}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${atten_ip}        ${tl.attenuator[0].ip_addr}
${att_api_port}              ${tl.attenuator[0].port}
${att_api_port_topyoung}              ${tl.attenuator[1].port}
${vendor}                    ${tl.attenuator[0].vendor}
${vendor_topyoung}          ${tl.attenuator[1].vendor}
${max_attenuation_value}     ${127}
${max_attenuation_value_topyoung}     ${120}
${5GRU_ANT9}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU_ANT10}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
${LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${gnb_trunk}    1074
${E1AP}    E1AP_
${gnb_path}    /tmp
${gnb_instance}    ${tl.gnbs[0].instance_id}
${model}    ${tl.attenuator[0].model}
*** Keywords ***
login and load scf
    [Arguments]     ${bts_host}    ${connection}    ${tl_scf_file_name}=${tl_scf_file_name}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_file_name}    timeout=800    is_pdl_checking_needed=${False}
    ...    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Check cell status on air
    [Arguments]     ${bts_host}    ${connection}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Start Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${interface}    ${connection}    ${gnb_index}=${0}
    gNB connections to ssh    gnb_index=${gnb_index}    connection=${connection}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
    sleep    3s
    run keyword if    '${gnb_instance}'=='${gnb_trunk}'
    ...    csn.send command    command=bsh 0:1 tcpdump -i any sctp -w /tmp/${E1AP}${nglogname}   connection=${connection}
    sleep    3s
    [Teardown]    csn.disconnect    connection=${connection}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${connection}    ${gnb_index}=${0}
    gNB connections to ssh    gnb_index=${gnb_index}    connection=${connection}
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=${connection}
    sleep    3
    csn.send command    command=bsh 1:0 killall tcpdump     connection=${connection}
    sleep    3
    run keyword if    '${gnb_instance}'=='${gnb_trunk}'
    ...    csn.download_file   remote_path=/tmp/${nglogname}   local_path=${epc_log_path}${E1AP}${nglogname}   connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=${connection}

gNB connections to ssh
    [Arguments]    ${connection}    ${gnb_index}=${0}
    csn.Connect To    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               alias=${connection}

Check phone attach successfully on SA env
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}    ${ue_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${ue_index}

locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Make a voice call on UE
    Make a call on UE(dial +6688 on UE)
    End a call on UE

Make a call on UE(dial +6688 on UE)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 580 2220 580 700    connection=cygwin
    sleep   2s
    #####make a call on UE with +6688#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688    connection=cygwin
    sleep   30s

End a call on UE
    #####hang up with +6688#####
    csn.send_command    command=adb shell input keyevent 6    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

Prepare env with UE
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=huawei    ue_index=${ue_index}

Common Suite Setup for COAM
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=All test suite log will save in this VM IP:${test_pc} Path:${epc_log_path}
    ...    append=True

Check IE wireshark log for VONR setup
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    1

Check IE wireshark log for RLF
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${f1ap_cause}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//f1ap.radioNetwork
    should be equal    ${f1ap_cause[0]}    12

Check IE wireshark log for UE release
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_cause}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.radioNetwork
    should be equal    ${ngap_cause[0]}    0

Check IE wireshark log for UE_Radio_Capability
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_voiceOverNR}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.voiceOverNR
    should be equal    ${nr_rrc_voiceOverNR[0]}    0

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Common Suite Teardown for COAM
    [Arguments]     ${bts_host}=${LOCAL_MASTER_IP}    ${connection}=gnb1
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
#    COAM Save snapshot via rest api    connection=${connection}    timeout=900
    Run Keyword And Ignore Error    unlocked LTE cell
    Run Keyword And Ignore Error    Unlock The Second gNB
    Run Keyword And Ignore Error    Unlock gnb1 cell2
    coam.teardown    connection=${connection}

Check IE wireshark log for VONR Release
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_nas}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[0]}    0

Enable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    5GC000786_common_keyword.gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    run keyword if    '${enb_instance}'=='${diffTL_enb}[1]'    Modify RD flag of rdUeContextRequest for trunk
    ...    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}    ELSE
    ...    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

Modify RD flag of rdUeContextRequest
    [Arguments]    ${before_value}    ${after_value}    ${file}     ${ALIAS_ASIK}=${ALIAS_ASIK}
    csn.Execute    command=rm -rf /tmp/cpue && mkdir /tmp/cpue    connection=${ALIAS_ASIK}
    ${output}    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE_ABINO/addons/ && ls cp-ue_*.txz    connection=${ALIAS_ASIK}
    ${filename}=    Remove String    ${output}    \r\n
    csn.Execute    command=tar -xvf /ffs/run/swpool/5G/CPUENODE_ABINO/addons/${filename} -C /tmp/cpue   connection=${ALIAS_ASIK}
    csn.Execute    command=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/5G/CPUENODE_ABINO/addons/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE_ABINO/addons/ && crasign ${filename} && rm /ffs/run/HashContainer*
    ...    connection=${ALIAS_ASIK}
    #csn.Execute    command=reboot    connection=${ALIAS_ASIK}
    csn.Disconnect    connection=${ALIAS_ASIK}
    #Sleep    3min

Modify RD flag of rdUeContextRequest for trunk
    [Arguments]    ${before_value}    ${after_value}    ${file}     ${ALIAS_ASIK}=${ALIAS_ASIK}
    csn.Execute    command=rm -rf /tmp/cpue && mkdir /tmp/cpue    connection=${ALIAS_ASIK}
    ${output}    csn.Execute    command=cd /ffs/run/swpool/CPLANE-5G/sm6-snowfish/ && ls cp-ue_*.txz    connection=${ALIAS_ASIK}
    ${filename}=    Remove String    ${output}    \r\n
    csn.Execute    command=tar -xvf /ffs/run/swpool/CPLANE-5G/sm6-snowfish/${filename} -C /tmp/cpue   connection=${ALIAS_ASIK}
    csn.Execute    command=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/CPLANE-5G/sm6-snowfish/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /ffs/run/swpool/CPLANE-5G/sm6-snowfish/ && crasign ${filename} && rm /ffs/run/HashContainer*
    ...    connection=${ALIAS_ASIK}
    #csn.Execute    command=reboot    connection=${ALIAS_ASIK}
    csn.Disconnect    connection=${ALIAS_ASIK}

Adjust Attenuation to 100
    Adjust the Attenuation Value    ports=${5GRU_ANT9}    value=30
    Adjust the Attenuation Value    ports=${5GRU_ANT10}    value=30
    sleep    15s
    Adjust the Attenuation Value    ports=${5GRU_ANT9}    value=50
    Adjust the Attenuation Value    ports=${5GRU_ANT10}    value=50
    sleep    15s
    Adjust the Attenuation Value    ports=${5GRU_ANT9}    value=70
    Adjust the Attenuation Value    ports=${5GRU_ANT10}    value=70
    sleep    15s
    Adjust the Attenuation Value    ports=${5GRU_ANT9}    value=90
    Adjust the Attenuation Value    ports=${5GRU_ANT10}    value=90
    sleep    20s

Adjust the Attenuation Value to normal
    Adjust the Attenuation Value    ports=${5GRU_ANT9}    value=10
    Adjust the Attenuation Value    ports=${5GRU_ANT10}    value=10
    Adjust the Attenuation Value    ports=${5GRU_ANT9}    value=0
    Adjust the Attenuation Value    ports=${5GRU_ANT10}    value=0

Lock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
    coam.lock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.teardown    connection=gnb2

Unlock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
    coam.unlock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.teardown    connection=gnb2

Disable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    5GC000786_common_keyword.gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    run keyword if    '${enb_instance}'=='${diffTL_enb}[1]'    Modify RD flag of rdUeContextRequest for trunk
    ...    before_value=rdUeContextRequest=True    after_value=rdUeContextRequest=False
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}    ELSE
    ...    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=True    after_value=rdUeContextRequest=False
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Prepare gNB with cell on air
    [Arguments]
    Get gnb release info
    Run keyword if    '${release_info}' == '${branch}[0]' or '${release_info}' == '${branch}[1]'
    ...    login and load scf    bts_host=${LOCAL_MASTER_IP}
    ...    tl_scf_file_name=${gnb_scf_${release_info}}    connection=Local gnb1    ELSE
    ...    login and load scf    bts_host=${LOCAL_MASTER_IP}
    ...    tl_scf_file_name=${tl_scf_file_name}    connection=Local gnb1
    Run Keyword And Ignore Error    locked LTE cell
    Run Keyword And Ignore Error    Lock The Second gNB
    wait until keyword succeeds    10 min    20 sec    Check cell status on air    bts_host=${LOCAL_MASTER_IP}    connection=Local gnb1
    Set wireshark interface

Lock gnb1 cell2
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

Unlock gnb1 cell2
    unLock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

Lock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    coam.connect to   bts_host=${bts_host}
    ...               bts_port=${port}    name=${alias}
    coam.lock_cell    dist_name=/${administrativeState_distname}
    ...               connection=${alias}
    coam.teardown          connection=${alias}

unLock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    coam.connect to   bts_host=${bts_host}
    ...               bts_port=${port}    name=${alias}
    coam.unlock_cell    dist_name=${administrativeState_distname}
    ...               connection=${alias}
    coam.teardown          connection=${alias}

Prepare gNB with cell on air status
    ${L3call_status}    run keyword and return status    Prepare gNB with cell on air
    should be equal       ${L3call_status}    True
    set suite variable    ${L3call_status}

Check 2nd UE attach successfully on SA env
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

Make a VoNR call separately
    [Arguments]    ${phone_number}=18001006209
#    Get VoNR and ViNR pointer variable
    Make a VoNR call    phone_number=${phone_number}
    answer VoNR call    ue_index=${1}

Make a ViNR call separately
    Make a ViNR call
    answer ViNR call    ue_index=${1}

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006209
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    20s

answer VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin${ue_index}
    sleep    5s

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

#Get VoNR and ViNR pointer variable
#    run keyword if    '${brand}'=='HUAWEI'
#    ...    Get VoNR and ViNR pointer variable with mate30 pro
#
#Get VoNR and ViNR pointer variable with mate30 pro
#    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
#    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
#    Set Suite Variable    ${answer_ViNR_button}    828 2147
#    Set Suite Variable    ${switch_to_VoNR}    914 1746
#    Set Suite Variable    ${trigger_button}    735 1805
#    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
#    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

Get VoNR and ViNR pointer variable
    run keyword if    '${brand}'=='HUAWEI' and '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Get VoNR and ViNR pointer variable with mate30 pro
    run keyword if    '${brand}'=='HUAWEI' and '${enb_instance}'=='${diffTL_enb_ID}[3]'
    ...    Get VoNR and ViNR pointer variable with mate30 pro on TL351
    run keyword if    '${brand}'=='HUAWEI' and '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Get VoNR and ViNR pointer variable with mate30 pro on TL42

Get VoNR and ViNR pointer variable with mate30 pro
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    836 2149
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728


Get VoNR and ViNR pointer variable with mate30 pro on TL351
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    828 1952
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

Get VoNR and ViNR pointer variable with mate30 pro on TL42
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    759 2151
    Set Suite Variable    ${switch_to_VoNR}    908 1735
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

Check IE wireshark log for VONR setup(UE to UE)
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    1
    should be equal    ${ngap_fiveQI[1]}    1

Check IE wireshark log for UE_ICS_5QI5
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    5

Check IE wireshark log for UE_Radio_Capability_CheckRequest
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_voiceOverNR}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.voiceOverNR
    should be equal    ${nr_rrc_voiceOverNR[0]}      0

Check IE wireshark log for UE_Radio_Capability_CheckResponse
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_IMSVoiceSupportIndicator}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.IMSVoiceSupportIndicator
    should be equal    ${ngap_IMSVoiceSupportIndicator[0]}      0

786 UEs attach
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}
    power_ue.Prepare UE    ue_type=huawei
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    50s

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${index00}    ${index01}    ${value}
    ${time1} =    Get message time    logname=${logname}    message_filter=${message_filter}    index=${index00}
    ${time2} =    Get message time    logname=${logname}    message_filter=${message_filter1}    index=${index01}
    ${time_dif1} =    evaluate  float(${time2})-float(${time1})
    ${time_differ1} =    convert_to_number    ${time_dif1}	0
    should be true    ${time_differ1}>=${value}
    [Return]    ${time_differ1}

Get message time
    [Arguments]    ${logname}    ${message_filter}    ${index}=${index0}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    @{frame_time}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//frame.time_epoch
    #    ${timelist} =   Evaluate    ${frame_time}[${index}].split('|')
    ${timestamp}=    convert_to_number    ${frame_time}[${index}]
#    ${timestamp} =     Caculate the wireshark timevalue to seconds    input_value=${timelist}   index=${index0}
    [Return]    ${timestamp}

Caculate the wireshark timevalue to seconds
    [Arguments]    ${input_value}    ${index}
    ${list} =    Evaluate    ${input_value}[${index}].split(' ')
    ${list_0} =    Evaluate    ${list}[-2].split(':')
    ${msg_time_sec} =    EVALUATE  float(${list_0}[0])*3600+float(${list_0}[1])*60+float(${list_0}[2])*1
    [Return]    ${msg_time_sec}

Check UE exist
    Run Keyword And Ignore Error    close Pioneer
    Check UE device exist
    Check UE device exist    ue_index=${1}

Prepare env with UEs
    power_ue.Prepare UE    ue_type=huawei
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}

Check phone attach successfully on SA env two times
    ${UE_status}    run keyword and return status     Check phone attach successfully on SA env
    run keyword if     '${UE_status}'=='False'    Check phone attach successfully on SA env

Set wireshark interface
    wait until keyword succeeds    5 min    10 sec    gNB connections to ssh    connection=Local gNB
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=Local gNB
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Set suite variable  ${interface}    br1
                  ...  ELSE    Set suite variable  ${interface}   fp0
    sleep    3s
    csn.disconnect      connection=Local gNB
    [Return]   ${interface}

set and check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked    ${new_value}=Unlocked    ${despite_errors}=True
    set value of parameter administrativeState on MO SNSSAI    new_value=${new_value}    despite_errors=${despite_errors}
    check value of parameter administrativeState on MO SNSSAI    value=${value}

set value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    selenium_coam.set_parameter_value  dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state
    ...    abbr=administrativeState    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    ${administrativeState_value}=    selenium_coam.get_parameter_value    dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state    abbr=administrativeState
    Should Be Equal    ${administrativeState_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

close Pioneer
    [Arguments]    ${ue_index}=${0}
    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    ue_index=${ue_index}
    csn.Execute       taskkill /F /IM Pioneer.exe       connection=cygwin

check value of parameter actVoNR
    [Arguments]    ${value}=true
    ${sw_version}    Get sagnb version for selenium
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}    version=${sw_version}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actVoNR_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1
    ${actVoNR_value}=    selenium_coam.get_parameter_value    dist_name=${actVoNR_distname}
    ...    filter_param=Activate voice over NR call support in the NR cell.    abbr=actVoNR
    Should Be Equal    ${actVoNR_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

Set automatic rotation on UEs
    Set automatic rotation
    Set automatic rotation    ue_index=${1}

set value of parameter drbInactivityTimerSA
    [Arguments]    ${new_value}=600seconds    ${despite_errors}=False
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${drbInactivityTimerSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${drbInactivityTimerSA_distname}
    ...    filter_param=Stand alone UE DRB inactivity timer
    ...    abbr=drbInactivityTimerSA    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter srbInactivityTimerSA
    [Arguments]    ${new_value}=60seconds    ${despite_errors}=False
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${srbInactivityTimerSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${srbInactivityTimerSA_distname}
    ...    filter_param=Stand alone UE SRB inactivity timer
    ...    abbr=srbInactivityTimerSA    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Trigger HUAWEI UE IDLE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data disable    connection=cygwin${ue_index}
    sleep    10s

Trigger HUAWEI UE out of IDLE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data enable    connection=cygwin${ue_index}
    sleep    10s

adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}     ${att_port_3}=${att_port_3}
    ...             ${att_port_4}=${att_port_4}     ${atten_ip}=${atten_ip}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    15s

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    set suite variable    ${release_info}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Get sagnb version for selenium
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${sw_version}     set variable    ${info.split('_')[1]}
    set suite variable    ${sw_version}
    [Return]    ${sw_version}
    [Teardown]   csn.Disconnect   connection=release_info
