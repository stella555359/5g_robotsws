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
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
#Resource          .././../5GC000738/Resources/5GC000738_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library           taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap   WITH NAME    parser
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py
Library    sigspark.SigSpark    WITH NAME    spark
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot

*** Variables ***
${interface}    any
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_COAM_LOCAL}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM_LOCAL_1}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
${LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
${gnb_path}    /tmp/
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${TS_CASE_LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
####TL341####
${atten_ip}        ${tl.attenuator[0].ip_addr}
${att_port1_341}    ${tl.attenuator[0].attenuator_ports[1]}
${att_port2_341}    ${tl.attenuator[0].attenuator_ports[2]}
${att_port3_341}    ${tl.attenuator[0].attenuator_ports[3]}
${att_port4_341}    ${tl.attenuator[0].attenuator_ports[4]}
${att_port5_341}    ${tl.attenuator[0].attenuator_ports[5]}
${att_port6_341}    ${tl.attenuator[0].attenuator_ports[6]}
${att_port7_341}    ${tl.attenuator[0].attenuator_ports[7]}
${att_port8_341}    ${tl.attenuator[0].attenuator_ports[8]}
${att_port9_341}    ${tl.attenuator[0].attenuator_ports[9]}
${att_port10_341}    ${tl.attenuator[0].attenuator_ports[10]}
${att_port11_341}    ${tl.attenuator[0].attenuator_ports[11]}
${att_port12_341}    ${tl.attenuator[0].attenuator_ports[12]}

####TL344####
${att_port_1}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port1_gnb1_ru1}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port2_gnb1_ru1}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port9_gnb1_ru2}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port10_gnb1_ru2}               ${tl.attenuator[0].attenuator_ports[4]}


${HBTE_eNB_att_port13}    ${tl.attenuator[0].attenuator_ports[13]}
${HBTE_eNB_att_port14}    ${tl.attenuator[0].attenuator_ports[14]}
${HBTE_eNB_att_port15}    ${tl.attenuator[0].attenuator_ports[15]}

###TL242###
${TL242_att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${TL242_att_port_6}                ${tl.attenuator[0].attenuator_ports[7]}
${TL242_att_port_7}                ${tl.attenuator[0].attenuator_ports[1]}
${TL242_att_port_8}                ${tl.attenuator[0].attenuator_ports[2]}
${TL242_att_port_13}                ${tl.attenuator[0].attenuator_ports[6]}
${TL242_att_port_14}                ${tl.attenuator[0].attenuator_ports[6]}
${TL242_att2_port_5}                ${tl.attenuator[0].attenuator_ports[4]}
${TL242_att2_port_6}                ${tl.attenuator[0].attenuator_ports[3]}
${att_api_port}              ${tl.attenuator[0].port}
${att_api_port_topyoung}              ${tl.attenuator[1].port}
${vendor}                    ${tl.attenuator[0].vendor}
${vendor_topyoung}          ${tl.attenuator[1].vendor}
${max_attenuation_value}     ${127}
${max_attenuation_value_topyoung}     ${120}
@{att_connection_port}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${11}    ${15}    ${16}
${4GRU_ANT11}    ${tl.attenuator[1].attenuator_ports[13].port_no}
${tl_scf_dir_path}     /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}        /opt/workspace/CIT/Master/Case_Logs/
${serial_number}       ${tl.ues[0].serial_number}
${distname_id_3}      MRBTS-${tl.gnbs[2].instance_id}/NRBTS-${tl.gnbs[2].instance_id}
${SUT_IP}         ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.addr}
${SUT_NAME}       ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.username}
${SUT_PWD}        ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.password}
${tshark_path}      /usr/bin/tshark
${command_template_with_f1rrc}    {tshark_path} -r {pcap_file} -Y  \"f1ap or nr-rrc or ngap or e1ap\"  -T pdml
${AP_PDU_IP}    ${tl.ues[3].pdu.pdu.addr}
${AP_PDU_PORT}    ${tl.ues[3].pdu.port_no}
${model}    ${tl.attenuator[0].model}
@{branch}    SBTS23R4_ENB_0000    SBTS24R1_ENB_0000    SBTS23R3_ENB_0000
*** Keywords ***
adjust the HBTE attenuation single port value
    [Arguments]     ${ports}    ${value}    ${atten_ip}=${tl.attenuator[0].ip_addr}
    ...              ${vendor}=${tl.attenuator[0].vendor}    ${attenuator_port}=${tl.attenuator[0].port}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    att.setup_attenuator    ip_addr=${atten_ip}    port=${attenuator_port}
    ...     attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value_topyoung}
    ...     vendor=${vendor}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port_1}    att.read_attenuation    port=${ports}
    should be equal    ${value_port_1}    ${value}

Adjust the Attenuation Value local
    [Arguments]      ${ports}    ${value}    ${atten_ip}=${tl.attenuator[0].ip_addr}
    @{att_connection_port}   Create list    ${ports}
    att.setup_attenuator    ip_addr=${atten_ip}   port=${att_api_port_topyoung}
    ...    attenuation_port_numbers=${att_connection_port}      max_attenuation=${max_attenuation_value_topyoung}
    ...    vendor=${vendor_topyoung}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port}    att.read_attenuation    port=${ports}
    should be equal    ${value_port}    ${value}


#login and load scf
#    [Arguments]     ${bts_host}    ${connection}    ${tl_scf_file_name}=${tl_scf_file_name}    ${pdl_checking}=${False}
#    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
#    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_file_name}    timeout=800    is_pdl_checking_needed=${pdl_checking}
#    ...    connection=${connection}
#    [Teardown]    coam.teardown    connection=${connection}

Check cell status on air
    [Arguments]     ${bts_host}    ${connection}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}    ${gnb_index}=${0}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=gnb${gnb_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

Start Capture Wireshark Logs on gNB without SCTP
    [Arguments]     ${nglogname}    ${interface}    ${gnb_index}=${0}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}/${nglogname}   connection=gnb${gnb_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${gnb_index}=${0}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb${gnb_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=gnb${gnb_index}
    sleep    3
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

gNB connections to ssh
    [Arguments]    ${connection}    ${gnb_index}=${0}
    csn.Connect To    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               alias=${connection}

Check phone attach successfully on SA env
    [Arguments]    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Trigger HUAWEI UE connect    ue_index=${0}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

locked LTE cell
    [Arguments]    ${enb_index}=${0}    ${enb_cell_id}=${1}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${enb_cell_id}
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

unlocked LTE cell
    [Arguments]    ${LNcell_id}=${1}
    Run Keyword And Ignore Error     Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-${LNcell_id}
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
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####hang up with +6688#####
    log to console    \n *** End a call on UE
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

Prepare env with UE
    power_ue.Prepare UE    ue_type=huawei
    [Teardown]         Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

#Common Suite Setup for COAM
#    COAM Create log directory    ${False}
#    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
#    Create directory    ${epc_log_path}
#    set_suite_documentation    doc=All test suite log will save in this VM IP:${test_pc} Path:${epc_log_path}
#    ...    append=True

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
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    COAM Save snapshot via rest api    connection=gnb${gnb_index}    timeout=900
    #unlocked LTE cell
    #Unlock The Second gNB    2ndgnb_index=${2ndgnb_index}
    coam.teardown    connection=gnb${gnb_index}

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
    wait until keyword succeeds    1min   10s    5GC002481_common_keyword.gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

Modify RD flag of rdUeContextRequest
    [Arguments]    ${before_value}    ${after_value}    ${file}     ${ALIAS_ASIK}=${ALIAS_ASIK}
    csn.Execute    command=rm -rf /tmp/cpue && mkdir /tmp/cpue    connection=${ALIAS_ASIK}
    ${output}    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && ls cp_ue_*.txz    connection=${ALIAS_ASIK}
    ${filename}=    Remove String    ${output}    \r\n
    csn.Execute    command=tar -xvf /ffs/run/swpool/5G/CPUENODE/addons/${filename} -C /tmp/cpue   connection=${ALIAS_ASIK}
    csn.Execute    command=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/5G/CPUENODE/addons/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && crasign ${filename} && rm /ffs/run/HashContainer*    connection=${ALIAS_ASIK}
    #csn.Execute    command=reboot    connection=${ALIAS_ASIK}
    csn.Disconnect    connection=${ALIAS_ASIK}
    #Sleep    3min

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin
    sleep    5s

Set automatic rotation on UEs
    Set automatic rotation
    Set automatic rotation    ue_index=${1}    rotation_value=1


Adjust Attenuation to 100
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT9}    value=${35}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${35}
    sleep    15s
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT9}    value=${55}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${55}
    sleep    15s
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT9}    value=${75}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${75}
    sleep    15s
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT9}    value=${95}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${95}
    sleep    20s

Adjust the Attenuation Value to normal
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT9}    value=${15}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${15}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT9}    value=${5}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${5}

Lock The Second gNB
    [Arguments]     ${2ndgnb_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${2ndgnb_index}].cu.oam_http_connection_details.addr}
    ...               connection=gnb${2ndgnb_index}
    coam.lock_cell    dist_name=MRBTS-${tl.gnbs[${2ndgnb_index}].instance_id}/NRBTS-${tl.gnbs[${2ndgnb_index}].instance_id}/NRCELL-1
    ...               connection=gnb${2ndgnb_index}
    coam.teardown    connection=gnb${2ndgnb_index}

Unlock The Second gNB
    [Arguments]     ${2ndgnb_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${2ndgnb_index}].cu.oam_http_connection_details.addr}
    ...               connection=gnb${2ndgnb_index}
    coam.unlock_cell    dist_name=MRBTS-${tl.gnbs[${2ndgnb_index}].instance_id}/NRBTS-${tl.gnbs[${2ndgnb_index}].instance_id}/NRCELL-1
    ...                 connection=gnb${2ndgnb_index}
    coam.teardown    connection=gnb${2ndgnb_index}

Disable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    5GC002481_common_keyword.gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=True    after_value=rdUeContextRequest=False
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Prepare gNB with cell on air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    login and load scf    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}
    ...                   tl_scf_file_name=${tl_scf_file_name}
    wait until keyword succeeds    10 min    20 sec    Check cell status on air
    ...                   bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}

Prepare gNB with cell on air status
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    Prepare gNB with cell on air    gnb_index=${gnb_index}
    ...    tl_scf_file_name=${tl_scf_file_name}

Check 2nd UE attach successfully on SA env
    [Arguments]    ${gnb_index}=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Trigger HUAWEI UE connect    ue_index=${1}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

Make a VoNR call separately
    [Arguments]    ${phone_number}=18001006306
    Get VoNR and ViNR pointer variable
    Make a VoNR call    phone_number=${phone_number}
    answer VoNR call    ue_index=${1}

Adjust gNB1_RU Attenuation to 5
    ${atten_ip} =    set variable     ${tl.attenuator[1].ip_addr}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT5}    value=${5}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT6}    value=${5}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value   ports=${5GRU_ANT7}    value=${5}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT8}    value=${5}    atten_ip=${atten_ip}

Turn gNB1_TDDRU Attenuation to value
    [Arguments]     ${value}=${5}
    ${atten_ip} =    set variable     ${tl.attenuator[1].ip_addr}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT5}    value=${value}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT6}    value=${value}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT7}    value=${value}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT8}    value=${value}    atten_ip=${atten_ip}

Adjust eNB1_RU Attenuation to 5
    ${atten_ip} =    set variable     ${tl.attenuator[1].ip_addr}
    adjust the HBTE attenuation single port value    ports=${4GRU_ANT3}    value=${5}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${4GRU_ANT4}    value=${5}    atten_ip=${atten_ip}

Adjust eNB1_RU Attenuation to 120
    Adjust the HBTE attenuation value    value_1=${120}     value_2=${120}     value_3=${120}
    ...    value_4=${120}    att_port_1=${att_port9_341}
    ...    att_port_2=${att_port10_341}     att_port_3=${att_port11_341}
    ...    att_port_4=${att_port12_341}    atten_ip=${atten_ip}

Adjust gNB2_RU Attenuation to 14
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT9}    value=${40}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${40}    atten_ip=${atten_ip}

Adjust gNB2_RU Attenuation to 0
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation single port value   ports=${5GRU_ANT9}    value=${0}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU_ANT10}    value=${0}    atten_ip=${atten_ip}

Adjust gNB2_RU2 Attenuation to 18
    ${atten_ip} =    set variable     ${tl.attenuator[2].ip_addr}
    adjust the HBTE attenuation single port value    ports=${5GRU2_ANT3}    value=${18}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU2_ANT4}    value=${18}    atten_ip=${atten_ip}

Adjust gNB2_RU2 Attenuation to 120
    Adjust the HBTE attenuation value    value_1=${0}     value_2=${0}     value_3=${120}
    ...    value_4=${120}    att_port_1=${att_port5_341}
    ...    att_port_2=${att_port6_341}     att_port_3=${att_port7_341}
    ...    att_port_4=${att_port8_341}    atten_ip=${atten_ip}

Adjust gNB2_RU2 Attenuation to 5
    ${atten_ip} =    set variable     ${tl.attenuator[2].ip_addr}
    adjust the HBTE attenuation single port value    ports=${5GRU2_ANT3}    value=${0}    atten_ip=${atten_ip}
    adjust the HBTE attenuation single port value    ports=${5GRU2_ANT4}    value=${0}    atten_ip=${atten_ip}

Adjust gNB1_RU Attenuation to 120
    Adjust the HBTE attenuation value    value_1=${120}     value_2=${120}     value_3=${120}
    ...    value_4=${120}    att_port_1=${att_port1_341}
    ...    att_port_2=${att_port2_341}     att_port_3=${att_port3_341}
    ...    att_port_4=${att_port4_341}    atten_ip=${atten_ip}

Make a ViNR call separately
    Make a ViNR call
    answer ViNR call    ue_index=${1}

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+86${phone_number}
    ...    connection=cygwin
    sleep    20s

answer VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin
    sleep    5s

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin


answer ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin

Make a VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    Log to console      Make a VoNR and ViNR call
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    sleep   2s
    #####make VoNR and ViNR call together#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL tel:+86${phone_number}
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_T}    connection=cygwin
    sleep    5s

Make a VoNR and ViNR call together
    [Arguments]    ${phone_number}=18001006306    ${MOT_index}=${0}   ${MPT_index}=${1}
    Log to console     Make a VoNR and ViNR call together
    Get VoNR and ViNR pointer variable
    Make a VoNR and ViNR call    phone_number=${phone_number}    ue_index=${MOT_index}
    answer ViNR call    ue_index=${MPT_index}


hang up VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin

Get VoNR and ViNR pointer variable
    run keyword if    '${brand}'=='HUAWEI'
    ...    Get VoNR and ViNR pointer variable with mate30 pro

Get VoNR and ViNR pointer variable with mate30 pro
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    828 1985
    Set Suite Variable    ${switch_to_VoNR}    900 1726
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728
    Set Suite Variable    ${swap_answer_ViNR_button}     580 2000 920 2000

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI_COAM}=${WEBUI_COAM}
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}

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
    [Arguments]    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Trigger HUAWEI UE connect    ue_index=${0}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Trigger HUAWEI UE connect    ue_index=${1}
    power_ue.Verify attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

786 UE attach
    [Arguments]    ${gnb_index}=${0}    ${ue_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${ue_index}    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Trigger HUAWEI UE connect    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=huawei    ue_index=${ue_index}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin
    sleep    30s

Check DL TP
    [Arguments]    ${dl_expect_throughput}    ${ul_expect_throughput}
    ...    ${cellid}=1    ${gnb_index}=${1}    ${ue_type}=${UE_TYPE}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid}    Create list  ${nrcellid}
    ${tput_log}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index}
    power_ue.Check Tput    direction=DL    cells=${nrcellid}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${dl_expect_throughput}
    power_ue.Check Tput    direction=UL    cells=${nrcellid}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${ul_expect_throughput}


#COAM Get nrcellid with lcrid
#    [Arguments]   ${lcrid}    ${gnb_index}=${0}
#    Connect to gnb coam via ssl    gnb_index=${gnb_index}
##    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
##    FOR  ${key}    IN    @{cell_info}
##        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${key}
##        ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
##        exit for loop if    '${nrCellId}'!='None'
##    END
##    [Return]    ${nrCellId}
#    @{paras}=    Create List    nrCellIdentity    lcrId
#    @{paras_info}   coam.get_parameter_by_class   class_name=NRCELL    parameter_list=@{paras}    timeout=60    connection=GNB_OAM
#    FOR    ${i}    IN    @{paras_info}
#        IF    ${i}[parameters][lcrId] == ${lcrid}
#            ${nrCellIdentity}=    Set Variable    ${i}[parameters][nrCellIdentity]
#        END
#    END
#    [Return]    ${nrCellIdentity}
#    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    FOR    ${key}  IN   @{cell_from_cellgrp}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${key}
        ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
        ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
    ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${index00}    ${index01}    ${value}
    ${time1} =    Get message time    logname=${logname}    message_filter=${message_filter}    index=${index00}
    ${time2} =    Get message time    logname=${logname}    message_filter=${message_filter1}    index=${index01}
    ${time_dif1} =    Subtract Time From Time    ${time2}     ${time1}
    ${time_differ1} =    convert_to_number    ${time_dif1}	0
    should be true    ${time_differ1}>=${value}
    [Return]    ${time_differ1}

Get message time
    [Arguments]    ${logname}    ${message_filter}    ${index}=${index0}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    @{frame_time}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//frame.time
    ${timestamp}=    Get Substring    string=${frame_time}[${index}]    start=13    end=-14
    [Return]    ${timestamp}

Caculate the wireshark timevalue to seconds
    [Arguments]    ${input_value}    ${index}
    ${list} =    Evaluate    ${input_value}[${index}].split(' ')
    ${list_0} =    Evaluate    ${list}[-2].split(':')
    ${msg_time_sec} =    EVALUATE  float(${list_0}[0])*3600+float(${list_0}[1])*60+float(${list_0}[2])*1
    [Return]    ${msg_time_sec}

Check UE1 exist
    [Arguments]   ${ue_index}= ${0}
    Check ADB devices and restart ADB service    ue_index=${ue_index}
    Check UE device exist     ue_index=${ue_index}

Check UE exist
    Check ADB devices and restart ADB service    ue_index=${0}
    Check UE device exist
    Check ADB devices and restart ADB service    ue_index=${1}
    Check UE device exist    ue_index=${1}

Reboot UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...             ${cpc_alias}=cygwin
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${cpc_alias}
    sleep   5s
    ADB Service Restart     serial_number=${serial_number}    cpc_alias=${cpc_alias}
    csn.send_command   command=adb -s ${serial_number} reboot     connection=${cpc_alias}      timeout=5
    Sleep   5s
    [Teardown]         Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

Prepare env with UEs
    power_ue.Prepare UE    ue_type=huawei
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}
    [Teardown]         Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

Check phone attach successfully on SA env two times
    [Arguments]    ${gnb_index}=${0}
    ${UE_status}    run keyword and return status     Check phone attach successfully on SA env    gnb_index=${gnb_index}
    run keyword if     '${UE_status}'=='False'    Check phone attach successfully on SA env    gnb_index=${gnb_index}

Set wireshark interface
    [Arguments]    ${gnb_index}=${0}
    wait until keyword succeeds    5 min    10 sec    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=gnb${gnb_index}
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Set suite variable  ${interface}    br1
                  ...  ELSE    Set suite variable  ${interface}   fp0
    sleep    3s
    csn.disconnect      connection=gnb${gnb_index}
    [Return]   ${interface}

COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    #selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
       ${cur_para_value}    selenium_coam.get_parameter_value
       ...    dist_name=${cur_para_to_update['dist_name']}
       ...    abbr=${cur_para_to_update['abbr']}
       ...    filter_param=${cur_para_to_update['filter_param']}
       Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
       ...    Log to console    current value is ${cur_para_value}, no need to update
       ...    ELSE    run keywords
       ...    selenium_coam.set_parameter_value
       ...    dist_name=${cur_para_to_update['dist_name']}
       ...    abbr=${cur_para_to_update['abbr']}
       ...    filter_param=${cur_para_to_update['filter_param']}
       ...    new_value=${cur_para_to_update['new_value']}    AND
       ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    Run Keyword And Ignore Error   selenium_coam.logout

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
    sleep    1s

Adjust gNB2_RU HBTE Attenuation to 14
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...        value_1=${15}    value_2=${15}   value_3=${15}    value_4=${15}

Adjust gNB2_RU HBTE Attenuation to 28
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...        value_1=${28}    value_2=${28}   value_3=${28}    value_4=${28}

Adjust gNB2_RU HBTE Attenuation to 127
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...        value_1=${127}    value_2=${127}   value_3=${127}    value_4=${127}
    adjust the HBTE attenuation value    att_port_1=${att_port_5}      att_port_2=${att_port_6}
    ...     att_port_3=${att_port_7}     att_port_4=${att_port_8}    atten_ip=${atten_ip}
    ...    value_1=${127}      value_2=${127}     value_3=${127}    value_4=${127}

Adjust gNB2_RU HBTE Attenuation to 35
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...        value_1=${55}    value_2=${55}   value_3=${55}    value_4=${55}

Adjust gNB2_RU HBTE Attenuation to value
    [Arguments]     ${value}=${5}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${value}   value_3=${value}    value_4=${value}

Adjust gNB2_RU HBTE Attenuation to 0
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...        value_1=${0}    value_2=${0}   value_3=${0}    value_4=${0}

Adjust gNB2_RU2 HBTE Attenuation to 18
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_5}      att_port_2=${att_port_6}
    ...     att_port_3=${att_port_7}     att_port_4=${att_port_8}    atten_ip=${atten_ip}
    ...    value_1=${35}     value_2=${35}    value_3=${35}     value_4=${35}

Adjust gNB2_RU2 HBTE Attenuation to 5
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_5}      att_port_2=${att_port_6}
    ...     att_port_3=${att_port_7}     att_port_4=${att_port_8}    atten_ip=${atten_ip}
    ...    value_1=${3}    value_2=${3}    value_3=${3}    value_4=${3}

Adjust gNB1_RU HBTE Attenuation to 120
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port1_gnb1_ru1}      att_port_2=${att_port2_gnb1_ru1}
    ...     att_port_3=${att_port9_gnb1_ru2}     att_port_4=${att_port10_gnb1_ru2}    atten_ip=${atten_ip}
    ...    value_1=${127}    value_2=${127}    value_3=${127}    value_4=${127}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...            value_1=${5}    value_2=${5}   value_3=${5}    value_4=${5}
    adjust the HBTE attenuation value    att_port_1=${att_port_5}      att_port_2=${att_port_6}
    ...     att_port_3=${att_port_7}     att_port_4=${att_port_8}    atten_ip=${atten_ip}
    ...    value_1=${120}      value_2=${120}     value_3=${120}    value_4=${120}


Adjust HBTE Attenuation to 100
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...            value_1=${35}    value_2=${35}   value_3=${35}    value_4=${35}
    sleep    15s
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...            value_1=${35}    value_2=${55}   value_3=${55}    value_4=${55}
    sleep    15s
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...            value_1=${75}    value_2=${75}   value_3=${75}    value_4=${75}
    sleep    15s
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...            value_1=${95}    value_2=${95}   value_3=${95}    value_4=${95}
    sleep    20s

Adjust the HBTE Attenuation Value to normal
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...            value_1=${15}    value_2=${15}   value_3=${15}    value_4=${15}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...            value_1=${5}    value_2=${5}   value_3=${5}    value_4=${5}


Adjust eNB1_RU Attenuation to 5 for trunk
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${HBTE_eNB_att_port13}      att_port_2=${HBTE_eNB_att_port14}
    ...     att_port_3=${HBTE_eNB_att_port15}     att_port_4=${HBTE_eNB_att_port15}    atten_ip=${atten_ip}
    ...    value_1=${5}    value_2=${5}    value_3=${5}    value_4=${5}

Adjust eNB1_RU Attenuation to 120 for trunk
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${HBTE_eNB_att_port13}      att_port_2=${HBTE_eNB_att_port14}
    ...     att_port_3=${HBTE_eNB_att_port15}     att_port_4=${HBTE_eNB_att_port15}    atten_ip=${atten_ip}
    ...    value_1=${127}    value_2=${127}    value_3=${127}    value_4=${127}

Adjust gNB1_RU HBTE Attenuation to 5
    ${atten_ip} =    set variable     ${tl.attenuator[2].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port1_gnb1_ru1}      att_port_2=${att_port2_gnb1_ru1}
    ...     att_port_3=${att_port9_gnb1_ru2}     att_port_4=${att_port10_gnb1_ru2}    atten_ip=${atten_ip}
    ...    value_1=${5}    value_2=${5}    value_3=${127}    value_4=${127}

Adjust gNB1_RU HBTE Attenuation to 20
    ${atten_ip} =    set variable     ${tl.attenuator[2].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port1_gnb1_ru1}      att_port_2=${att_port2_gnb1_ru1}
    ...     att_port_3=${att_port9_gnb1_ru2}     att_port_4=${att_port10_gnb1_ru2}    atten_ip=${atten_ip}
    ...    value_1=${20}    value_2=${20}    value_3=${127}    value_4=${127}

Adjust gNB1_RU HBTE Attenuation to value
    [Arguments]     ${value}=${38}
    ${atten_ip} =    set variable     ${tl.attenuator[2].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port1_gnb1_ru1}      att_port_2=${att_port2_gnb1_ru1}
    ...     att_port_3=${att_port9_gnb1_ru2}     att_port_4=${att_port10_gnb1_ru2}    atten_ip=${atten_ip}
    ...    value_1=${value}    value_2=${value}    value_3=${127}    value_4=${127}

Adjust gNB1_RU HBTE Attenuation to 15
    ${atten_ip} =    set variable     ${tl.attenuator[2].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port1_gnb1_ru1}      att_port_2=${att_port2_gnb1_ru1}
    ...     att_port_3=${att_port9_gnb1_ru2}     att_port_4=${att_port10_gnb1_ru2}    atten_ip=${atten_ip}
    ...    value_1=${38}    value_2=${38}    value_3=${127}    value_4=${127}

Adjust gNB1_RU HBTE Attenuation to 80
    ${atten_ip} =    set variable     ${tl.attenuator[2].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port1_gnb1_ru1}      att_port_2=${att_port2_gnb1_ru1}
    ...     att_port_3=${att_port9_gnb1_ru2}     att_port_4=${att_port10_gnb1_ru2}    atten_ip=${atten_ip}
    ...    value_1=${80}    value_2=${80}    value_3=${127}    value_4=${127}

close Pioneer
    [Arguments]    ${ue_index}=${0}
    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    ue_index=${ue_index}
    csn.Execute       command=taskkill /F /IM Pioneer.exe       connection=cygwin

enable svc date
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    Connect to control pc via cygwin
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    #####disable data#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell svc data enable
    ...    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

open pionner
    [Arguments]    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=schtasks /run /tn Pioneer2
    ...    connection=cygwin
    sleep    85s

Check MOS from csv
    [Arguments]    ${csv_num}=${1}
    ${num}    Run    more ${LOG_PATH}UE${csv_num}.csv |grep 20|wc -l
    should be true    ${num} > 2
    FOR  ${i}    IN RANGE    2   ${num}+1
        ${rc}    ${content}     OperatingSystem.Run And Return Rc And Output
            ...    cat ${LOG_PATH}UE${csv_num}.csv |sed -n "${i}p" | cut -d "," -f 5 |sed 's/\"//g'
        run keyword and continue on failure    should be true    ${content} > 3
        ${i}    evaluate    ${i}+1
    END

Prepare test plan
    [Arguments]    ${TestPlansLocation}=${TestPlansLocation}
    open pionner
    Run Keyword And Ignore Error    spark.require_platform    ue_alias=UE_0
    sleep    10s
    Run Keyword And Ignore Error    spark.disconnect_ues     ue_alias=UE_0
    close Pioneer
    open pionner
    spark.create_test_plan    ue_alias=UE_0    testplanslocation=${TestPlansLocation}
    Run Keyword And Ignore Error    Run    rm -rf ${LOG_PATH}UE*

ADB Service Restart
    [Documentation]  Use adb command to recover adb service
    [Arguments]    ${serial_number}    ${cpc_alias}
    log to console     \nInfo:Reboot ADB Service on ${cpc_alias}!
    csn.execute    command=sudo adb -s ${serial_number} kill-server    connection=${cpc_alias}
    csn.execute    command=sudo adb -s ${serial_number} start-server    connection=${cpc_alias}
    sleep   2s

Check adb devices status
    [Documentation]  check phone status by serial number
    ...    :param serial_number: the serial number of phone
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...             ${cpc_alias}=cygwin
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${cpc_alias}
    sleep   5s
    ADB Service Restart     serial_number=${serial_number}    cpc_alias=${cpc_alias}
    csn.send_command   command=adb devices  connection=${cpc_alias}      timeout=5
    Sleep   2s
    ${result}    csn.read_output    connection=${cpc_alias}
    ${device_line}    Get lines Containing String    string=${result}    pattern=${serial_number}
    ...    case_insensitive=False
    ${device_status}    Get Substring    string=${device_line}    start=-6
    ${return_value}=    Set variable if    '${device_status}' == 'device'    PASS    FAIL
    [Return]    ${return_value}

Check ADB devices and restart ADB service
    [Documentation]   Sometimes ue is adb offline. Reboot adb service first, then reboot UEPC as a workaround.
    [Arguments]   ${ue_index}
    wait until keyword succeeds   5m   30s      Check adb devices status     ue_index=${ue_index}

Reset UE Control PC
    [Documentation]  To reset te UE control pc which is windows system.
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect      connection=cpc_${ue_index}
    sleep    180s

Remove Xn Config
    #[arguments]     ${connection}=gnb${gnb_index}
    #${C_NRBTS_id} =    set variable     ${tl.gnbs[${gnb_index}].instance_id}
    #selenium_coam.enable_virtual_display
    #selenium_coam.login    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    #...           username=${WEBUI_NAME}    password=${WEBUI_PWD}
    #${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    #Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    #sleep    5s
    #selenium_coam.remove_object    object_name=MRBTS-${C_NRBTS_id}/NRBTS-${C_NRBTS_id}/XNLINK-1
    #selenium_coam.remove_object    object_name=MRBTS-${C_NRBTS_id}/NRBTS-${C_NRBTS_id}/NRADJGNB-1
    #selenium_coam.validate_plan
    #selenium_coam.activate_plan     activate_plan_despite_errors=True
    #sleep    65s
    #Run Keyword And Ignore Error   selenium_coam.logout
    #Run Keyword And Ignore Error   selenium_coam.disable_virtual_display
    Connect to gnb coam via ssl    connection=gnb0    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    Run Keyword And Ignore Error    COAM delete objects via rest api     objects_to_delete_via_api=${LNADJGNB1_OBJ_TO_DELETE}
    ...                   connection=gnb0
    Connect to gnb coam via ssl    connection=gnb1    bts_host=${tl.gnbs[1].cu.oam_http_connection_details.addr}
    Run Keyword And Ignore Error    COAM delete objects via rest api     objects_to_delete_via_api=${LNADJGNB2_OBJ_TO_DELETE}
    ...                   connection=gnb1
    [Teardown]     Teardown for Remove Xn Config

Teardown for Remove Xn Config
    Run Keyword And Ignore Error    coam.teardown    connection=gnb0
    Run Keyword And Ignore Error    coam.teardown    connection=gnb1

Trigger HUAWEI UE connect
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data enable    connection=cygwin
    sleep    10s

Prepare Test Env for 21B
    #Run Keyword And Ignore Error    5GC002481_common_keyword.locked LTE cell    enb_index=${2}    enb_cell_id=${211}
    #Run Keyword And Ignore Error    5GC002481_common_keyword.Lock The Third gNB
    Run Keyword And Ignore Error    5GC002481_common_keyword.Check UE1 exist    ue_index=${0}

Turn gNB2_FDD_Cell1 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${TL242_att_port_5}      att_port_2=${TL242_att_port_6}
    ...     att_port_3=${TL242_att_port_5}     att_port_4=${TL242_att_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${value}   value_3=${value}    value_4=${value}

Turn gNB2_FDD_Cell2 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${TL242_att_port_7}      att_port_2=${TL242_att_port_8}
    ...     att_port_3=${TL242_att_port_7}     att_port_4=${TL242_att_port_8}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${value}   value_3=${value}    value_4=${value}

Turn LTE_Cells HBTE Attenuation to 120
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${TL242_att_port_13}      att_port_2=${TL242_att_port_14}
    ...     att_port_3=${TL242_att_port_13}     att_port_4=${TL242_att_port_14}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}

Turn gNB1_TDD_Cell1 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${TL242_att2_port_5}      att_port_2=${TL242_att2_port_6}
    ...     att_port_3=${TL242_att2_port_5}     att_port_4=${TL242_att2_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${120}   value_3=${value}    value_4=${120}

Change the PA value to trigger HO for D_09
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${20}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${4}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${16}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${6}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${12}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${8}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${6}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${13}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${0}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${16}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${18}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${20}
    Turn gNB1_TDD_Cell1 HBTE Attenuation to value    value=${22}


Change the PA value to trigger HO for D_01
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${18}
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${2}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${6}
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${3}
    sleep    5s
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${5}
    sleep    7s
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${5}
    sleep    8s
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${10}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${3}
    sleep    7s
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${15}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${1}

Change the PA value to trigger HO for D_07
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${5}
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${20}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${10}
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${10}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${15}
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${5}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${20}
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${3}
    Turn gNB2_FDD_Cell1 HBTE Attenuation to value    value=${25}
    Turn gNB2_FDD_Cell2 HBTE Attenuation to value    value=${0}

clear UTE memery cache
    [Arguments]     ${alias}=ute_cache
    csn.Connect to    hostname=${SUT_IP}
    ...             username=${SUT_NAME}    password=${SUT_PWD}    alias=${alias}
    sleep     10s
    Log To Console     before clear UTE memery cache
    ${cache_status}    OperatingSystem.Run     free -m
    Log To Console     ${cache_status}
    sleep     5s
    Run Keyword And Ignore Error    csn.send command
    ...    command=echo 3 > /proc/sys/vm/drop_caches    connection=${alias}
    sleep     5s
    Log To Console     after clear UTE memery cache
    ${cache_status2}    OperatingSystem.Run     free -m
    Log To Console     ${cache_status2}
   [Teardown]     csn.disconnect    connection=${alias}

Power off the UE PDU
    PDU.Setup Pdu    model=${MODEL}    host=${AP_PDU_IP}   alias=pdu_alias
    PDU.Power Off    port=${AP_PDU_PORT}   pdu_device=pdu_alias
    Sleep    3s

Power on the UE PDU
    PDU.Setup Pdu    model=${MODEL}    host=${AP_PDU_IP}    alias=pdu_alias
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    Sleep    3s

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

#Get sagnb release
#    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#    set suite variable    ${release_info}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info
