*** Settings ***
Documentation    
...    author: tluo
...    contact: tina.luo@nokia-sbell.com
...    squad group: RAN_PZ_MMW_CN_2_SG03
...    Feature :  5GC001358



Library       Process
Library         String
Library         Collections
Library         ./Regex_6014.py
Library         taf.transport.ssh                      WITH NAME   ssh
Library         taf.sbts.oam.coam.admin                 WITH NAME   admin
Library         XML    use_lxml=Truee

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000980/Resources/5GC000980_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
#Resource      ../../../../../testsuite/RRM/Hangzhou/5GC000496_C/Resources/L3Call.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot

*** Variables ***
${RECOVERY_TIMEOUT}        10 min
${first_angle}    15
${second_angle}    0
${third_angle}    5
${SCF_with_ALD}     SCF_with_ALD.xml
${SCF_without_ALD}     SCF_without_ALD.xml
${External_Driver_ALD_file_one}      ALD_SW_2_0_16.zip
${External_Driver_ALD_file_second}      ALD_SW_2_0_20.zip
${ICMP_loop}     20000
${ICMP_rate}     1000
${TCP_loop}      960000
${TCP_rate}      16000
${SSH_loop}      9000
${SSH_rate}      10
${UDP_loop}      960000
${UDP_rate}      16000
${S_loop}        100
${ST_loop}       500
${S_rate}        10
${Counter_file}  TL935_AZQG_ICMP_counters.zip
${set_subnet_mask_py}   set_subnet_mask.py
&{ICMP_rule}   destination-unreachable=ICMP(type=3, code=1)
...            time-exceeded=ICMP(type=8, code=0)
...            echo-request=ICMP(type=0, code=0)
...            echo-reply=ICMP(type=11, code=0)
${RU}      ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${SCF}    SCF_with_PM5min.xml
${asik_addr}                ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
Suite preparation
    [Documentation]    author: Liu Zheng
    Run Keyword And Ignore Error    run process    pkill -9 firefox    shell=True
    COAM Create log directory    is_set_to_test_case_level=${False}
    #--------------
    Log To Console    \n *** Commssion gNB with ALD***
# #  ${Golden_SCF_Path}    Get Golden SCF Path
#    ${tl_scf_dir_path}     String.Replace String     ${Golden_SCF_Path}    SCF_SBTS00.xml    5GC0001358_ALD
	Connect to gnb coam via ssl
#    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}/${SCF_with_ALD}    timeout=500    is_pdl_checking_needed=${False}
#    Wait Until Keyword Succeeds  360  5  COAM Check All Cells Onair     connection=GNB_OAM
    5GC001358_C_common_keywords.Recommission With Backup SCF File    SCF=${SCF_with_ALD}
    #--------------
    ${status}    run keyword and return status    Wait until ALD AND RETU status normal    timeout=2 min    download_dir=${SUITE_LOG_PATH}
    run keyword if    '${status}' == 'False'    WA for ALD cases due to dip adjustment lever hw miss    download_dir=${SUITE_LOG_PATH}
    Wait until cluster is on cell on air status
  #  [Teardown]    Run keyword and ignore error    Tear down all SISO connections


Case preparation for ALD case
    [Documentation]    author: Liu Zheng
    COAM Create log directory
    ${status}    run keyword and return status    Wait until ALD AND RETU status normal    timeout=2 min    download_dir=${TS_CASE_LOG_PATH}
    run keyword if    '${status}' == 'False'    run keywords
    ...    WA for ALD cases due to dip adjustment lever hw miss    download_dir=${TS_CASE_LOG_PATH}    AND
    ...    COAM Wait For Gnb Ready And Cell Setup
    Connect to gnb coam via ssl

Suite env recovery
    [Documentation]    author: Liu Zheng
    Suite teardown common

WA for ALD cases due to dip adjustment lever hw miss
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    Reset ALD via webUI    reset_type=software    ald_index=1    download_dir=${download_dir}
    sleep    30s
    ${retu_status}    run keyword and return status    Check RETU Status    administrative_state=Unlocked
    ...    availability_status=Online    operational_state=Enabled    procedural_status=-    download_dir=${download_dir}
    Run keyword if    '${retu_status}'=='False'    Reset ALD via webUI    reset_type=software
    ...    ald_index=1    download_dir=${download_dir}

RETU status should be normal
    Wait Until Keyword Succeeds   2 min  5 sec    Check RETU Status    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=initializing
    Wait Until Keyword Succeeds   3 min  5 sec    Check RETU Status    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=-

Wait until ALD AND RETU status normal
    [Arguments]    ${timeout}=${5} min   ${download_dir}=${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds   ${timeout}  5 sec    Check ALD Status    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=-    download_dir=${download_dir}
    Wait Until Keyword Succeeds   ${timeout}  5 sec    Check RETU Status    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=-    download_dir=${download_dir}

Enable HDLC communication For RET Port
    [Arguments]    ${mrbts_id}=${BTS_ID}    ${rmod_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Enable HDLC communication
    &{hdLCcommunication_param}    Create Dictionary    abbr=hdlcCommunicationAllowed
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_index}/RSL-1
    ...    filter_param=HDLC communication enabled
    ...    new_value=true
    @{hdLCcommunication_param}    Create List    ${hdLCcommunication_param}
    COAM Update several parameters via webUI   parameters_to_update_via_webui=${hdLCcommunication_param}
    ...    download_dir=${download_dir}

Disable HDLC communication For RET Port
    [Arguments]    ${mrbts_id}=${BTS_ID}    ${rmod_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Disable HDLC communication
    &{hdLCcommunication_param}    Create Dictionary    abbr=hdlcCommunicationAllowed
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_index}/RSL-1
    ...    filter_param=HDLC communication enabled
    ...    new_value=false
    @{hdLCcommunication_param}    Create List    ${hdLCcommunication_param}
    COAM Update several parameters via webUI   parameters_to_update_via_webui=${hdLCcommunication_param}
    ...    download_dir=${download_dir}

Get Runtime Object of RSL
    [Arguments]    ${ald_index}=1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connectison=${connection}
    ${bts_info} =    Get BTS Information via rest api    connection=${connection}
    @{ports}    Set Variable    ${bts_info["radioModules"]["rmod"][0]["ports"]}
    ${port_num} =    Get Length    ${ports}
    ${status} =    Set Variable    ${False}
    ${running_object} =    Set Variable    ${SPACE}
    FOR    ${port}   IN   @{ports}
       Exit For Loop If    ${port_num}==${0}
       ${running_object} =    Set Variable    ${port["id"]["runtime"]}
       ${status} =    Run Keyword And Return Status    Should Contain    ${port["id"]["configuration"]}    RSL-${ald_index}
       Exit For Loop If    ${status}
    END
    Run Keyword If    ${status}==${False}    Fail    ALD-${ald_index} is not present on gnb.
    [Return]    ${running_object}

Get Runtime Object of ALD
    [Arguments]    ${ald_index}=1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${bts_info} =    Get BTS Information via rest api    connection=${connection}
    @{alds}    Set Variable    ${bts_info["alds"]}
    ${ald_num} =    Get Length    ${alds}
    ${status} =    Set Variable    ${False}
    ${running_object} =    Set Variable    ${SPACE}
    FOR    ${ald}   IN    @{alds}
       Exit For Loop If    ${ald_num}==${0}
       ${running_object} =    Set Variable    ${ald["id"]["runtime"]}
       ${status} =    Run Keyword And Return Status    Should Contain    ${ald["id"]["configuration"]}    ALD-${ald_index}
       Exit For Loop If    ${status}
    END
    Run Keyword If    ${status}==${False}    Fail    ALD-${ald_index} is not present on gnb.
    [Return]    ${running_object}

Recommission With Backup SCF File
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${SCF}    ${is_pdl_checking_needed}=${True}    ${timeout}=900    ${connection}=GNB_OAM
    ${tl_scf_dir_path}     String.Replace String     ${Golden_SCF_Path}    SCF_SBTS00.xml    5GC0001358_ALD
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${tl_scf_dir_path}/${SCF}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.
    Wait Until Keyword Succeeds  360  5  COAM Check All Cells Onair     connection=GNB_OAM

Login WebUI
    Log To Console    Login WebUI
    run keyword and ignore error   WEBUI Logout
    Wait Until Keyword Succeeds    10min    5s    WEBUI Login

Check Operational State of ALD
    Log To Console    Check Operational State of ALD
    ${ald_operational_state}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/ALD_R-1
    ...    filter_param=Operational state   abbr=operationalState    timeout=60
    set suite variable    ${ald_operational_state}
    should be equal    ${ald_operational_state}   enabled
    sleep    2s

Check configDN of ALD with config
    Log To Console    Check configDN of ALD
    ${ald_configDN}    Get configDN of ALD
    should be equal    ${ald_configDN}    MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-1
    sleep    2s

Check configDN of ALD without config
    Log To Console    Check configDN of ALD
    ${ald_configDN}    Get configDN of ALD
    Should Be Empty    ${ald_configDN}
    sleep    2s

Get configDN of ALD
    Log To Console    Get configDN of ALD
    ${ald_configDN}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/ALD_R-1
    ...    filter_param=Distinguished name of paired configured managed object   abbr=configDN    timeout=60
    set suite variable    ${ald_configDN}
    sleep    2s
    [Return]    ${ald_configDN}

Check Operational State of RETU
    Log To Console    Check Operational State of RETU
    ${ret_operational_state}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/ALD_R-1/RETU_R-1
    ...    filter_param=Operational state   abbr=operationalState    timeout=60
    set suite variable    ${ret_operational_state}
    should be equal    ${ret_operational_state}   enabled
    sleep    2s

Check configDN of RETU with config
    Log To Console    Check configDN of RETU
    ${ret_configDN}    Get configDN of RETU
    should be equal    ${ret_configDN}    MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-1/RETU-1
    sleep    2s

Check configDN of RETU without config
    Log To Console    Check configDN of RETU
    ${ret_configDN}    Get configDN of RETU
    Should Be Empty    ${ret_configDN}
    sleep    2s

Get configDN of RETU
    Log To Console    Get configDN of RETU
    ${ret_configDN}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/ALD_R-1/RETU_R-1
    ...    filter_param=Distinguished name of paired configured managed object   abbr=configDN    timeout=60
    set suite variable    ${ret_configDN}
    sleep    2s
    [Return]    ${ret_configDN}

Upgrade ALD SW
    [Documentation]    xulijun
    [Arguments]      ${file_path}=${External_Driver_ALD_file}
    Log to console    Info: ready to Upgrade ALD SW
    COAM Navigate to login page via webUI   # download_dir =${TS_CASE_LOG_PATH}
    ${package_download_status}    selenium_coam.load_software_package_from_local_drive      /home/ute/Downloads/${file_path}
    set test variable    ${package_download_success}    software package load success
    should be equal    ${package_download_status}    ${package_download_success}
    selenium_coam.software_update
    selenium_coam.check_software_update_progress
    [Teardown]    selenium_coam.logout
    
Connect to TP
    ${Test_PC_connection}=  ssh.Connect to  10.68.86.229
    ...             username=root
    ...             password=nokia123
    ...             alias=Test_PC_connection
    Log to console     Logging to PC succesfull
    ${Test_PC_connection}=  Set Suite Variable  ${Test_PC_connection}

Connect to GNB
    ${gnb}=  ssh.Connect to  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...             username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             alias=gnb
    Log to console  Logging to gnb succesfull
    [Return]  ${gnb}

Checking connection to RU
    [Arguments]  ${Test_PC_connection}  ${RU_IP}  ${gnb}
    ${RU_status}=  Run Keyword And Return Status  Connect to AZQG  ${Test_PC_connection}
    Run Keyword if   '${RU_status}' == 'False'  Reconfigure DHCP on BTS  ${Test_PC_connection}  ${RU_IP}  ${gnb}
    ${RU_connection}=  Connect to AZQG  ${Test_PC_connection}
    ${RU_connection}=  Set Suite Variable  ${RU_connection}
    [Return]  ${RU_connection}

Connect to AZQG
    [Arguments]  ${Test_PC_connection}
    Log to console  Connecting to RU
    ${a}=  ssh.execute  command=sed -i '/${RU} /d' ./.ssh/known_hosts  connection=${Test_PC_connection}
    ${RU_connection}=  ssh.Connect to  ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
    ...             username=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...             password=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...             proxy=${Test_PC_connection}
    ...             alias=RU
    [Return]  ${RU_connection}

Verification NF tables ingress ICMP
    [Arguments]  ${RU_connection}  ${test_type}
    Log to console  Verification NF tables ingress ICMP
    ${nft_output_1}=  ssh.execute     nft list chain netdev pre_filter arb0p0 |grep 'icmp type'  connection=${RU_connection}
    Should Match Regexp  ${nft_output_1}   icmp type != {.*${test_type}.*} jump arb0p0-DISCARD
    ${nft_output_2}=  ssh.execute    nft list chain netdev pre_filter arb0p0 |grep 'ip protocol icmp'  connection=${RU_connection}
    Should Contain   ${nft_output_2}  limit rate over 100/second burst 16 packets jump arb0p0-DISCARD-RATE-LIMIT

Verification NF tables ingress TCP
    [Arguments]  ${RU_connection}
    Log to console  Verification NF tables ingress TCP
    ${nft_output}=  ssh.execute    nft list chain netdev pre_filter arb0p0 |grep 'tcp limit rate'  connection=${RU_connection}
    Should Contain  ${nft_output}  limit rate over 4000/second burst 32 packets jump arb0p0-DISCARD-RATE-LIMIT

Verification NF tables ingress UDP
    [Arguments]  ${RU_connection}
    Log to console    Verification NF tables ingress UDP
    ${nft_output}  ssh.execute  nft list chain netdev pre_filter arb0p0 |grep 'udp limit rate'  connection=${RU_connection}
    Should Contain  ${nft_output}  limit rate over 4000/second burst 10 packets jump arb0p0-DISCARD-RATE-LIMIT

Verification NF tables egress
    [Arguments]  ${RU_connection}  ${test_type}
    Log to console     Verification NF tables egress
    ${nft_output}=  ssh.execute    nft list chain ip filter arb0p0.295-OUTPUT |grep 'icmp type'  connection=${RU_connection}
    Should Match Regexp  ${nft_output}
    ...          icmp type {.*${test_type}.*} limit rate over 100/second burst 10 packets jump arb0p0.295-DISCARD-RATE-LIMIT

Checking Pre-Counter on RU
    [Arguments]  ${RU_connection}  ${Test_PC_connection}  ${Spliting_type}
    Log to console  Checking Pre-Counter on RU
    ${b}  Set variable  ccsShell.sh log -n 0x1011 -l runtime -z ${Counter_file}
    ssh.execute   command=${b}  connection=${RU_connection}
    sleep   5s
    ssh.Download File     remote_path=/ram/${Counter_file}  local_path=/home/ute/Downloads/${Counter_file}  connection=${RU_connection}
    Run  unzip -pqo /home/ute/Downloads/${Counter_file} 1011_runtime.zip > /tmp/1011_runtime.zip
    Run  unzip -pqo /tmp/1011_runtime.zip runtime_DEFAULT.log.xz > /tmp/runtime_DEFAULT.log.xz
    ${log_output}=  Run   xzgrep '\\[FW\\] discarded' /tmp/runtime_DEFAULT.log.xz | tail -1
    ${Pre-counter}=  Run Keyword  ${Spliting_type}  ${log_output}
    ssh.execute    rm ${Counter_file}  connection=${RU_connection}
    Log to console     Pre-Counters are fetched, it is ${Pre-counter}
    [Return]   ${Pre-counter}

Checking Post-Counter on RU
    [Arguments]  ${RU_connection}  ${Test_PC_connection}  ${Spliting_type}
    Log to console  Checking Post-Counter on RU
    ssh.execute    ccsShell.sh log -n 0x1011 -l runtime -z ${Counter_file}  connection=${RU_connection}
    sleep   5s
    ssh.Download File     remote_path=/ram/${Counter_file}   local_path=/home/ute/Downloads/${Counter_file}  connection=${RU_connection}
    Run  unzip -pqo /home/ute/Downloads/${Counter_file} 1011_runtime.zip > /tmp/1011_runtime.zip
    Run  unzip -pqo /tmp/1011_runtime.zip runtime_DEFAULT.log.xz > /tmp/runtime_DEFAULT.log.xz
    ${log_output}=  Run   xzgrep '\\[FW\\] discarded' /tmp/runtime_DEFAULT.log.xz | tail -1
    ${Post-counter}=  Run Keyword  ${Spliting_type}  ${log_output}
    ssh.execute    rm ${Counter_file}  connection=${RU_connection}
    Log to console     Post-Counters are fetched, it is ${Post-counter}
    [Return]  ${Post-counter}

Verification droped packets
    [Arguments]  ${Pre-counter}  ${Post-counter}  ${LOW_limit}  ${UP_limit}
    Log to console     Verification droped packets
    ${Packets}=  Evaluate  ${Post-counter} - ${Pre-counter}
    ${Droped_Packets}=  Absolute Value  ${Packets}
    Should be True  ${LOW_limit} < ${Droped_Packets} < ${UP_limit}

Verification droped packets in Stateless
    [Arguments]  ${Pre-counter}  ${Post-counter}  ${LOW_limit}  ${UP_limit}
    Log to console     Verification droped packets
    ${Packets}=  Evaluate  ${Post-counter} - ${Pre-counter}
    ${Droped_Packets}=  Absolute Value  ${Packets}
    Should be True  ${LOW_limit} <= ${Droped_Packets} < ${UP_limit}

Reconfigure DHCP on BTS
    [Arguments]  ${Test_PC_connection}  ${RU_IP}  ${gnb}
    Log to console  Reconfigure DHCP on BTS
    ssh.Upload File    remote_path=/tmp/set_subnet_mask.py   local_path=${CURDIR}/${set_subnet_mask_py}  connection=${gnb}
    ssh.execute    chmod +x /tmp/set_subnet_mask.py  connection=${gnb}
    ssh.execute    python3 /tmp/set_subnet_mask.py  connection=${gnb}
    Log to console  Reboot RU
    Perform RU Reset
    ssh.execute    rm /tmp/set_subnet_mask.py  connection=${gnb}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds  360  5  COAM Check All Cells Onair     connection=GNB_OAM
    ${ping_output}  ssh.execute  ping -c 1 -W 2 ${RU_IP} 2>&1 1>/dev/null; echo $?  connection=${Test_PC_connection}
    Should contain  ${ping_output}  0

Scapy execution on TestPC
    [Arguments]  ${Test_PC_connection}  ${loop}  ${rate}  ${RU_IP}  ${RU_Mac}  ${RU_IF}  ${Test_PC_Mac}  ${type}  ${SRC_IP}=172.22.56.3
    Log to console  Scapy execution on TestPC
    ${S1}  Set Variable  echo 'sendpfast ((Ether(src=\"${Test_PC_Mac}\", dst=\"${RU_Mac}\")/IP(src=\"${SRC_IP}\", dst=\"${RU_IP}\")/${type})
    ${S2}  Set Variable  , pps=${rate}, iface=\"${RU_IF}\", loop=${loop}, parse_results=1)' | scapy -H 2>/dev/null
    ${Scapy_output}  ssh.execute  command=${S1}${S2}  connection=${Test_PC_connection}
    Should contain  ${Scapy_output}  successful': ${loop}
    Sleep  15s

Hping3 execution on TestPC
    [Arguments]  ${Test_PC_connection}
    Log to console  Hping3 execution on TestPC
    ${Hping3_output}  ssh.execute  command=hping3 172.22.48.162 -c 6000 -i u100000 --destport 22 --syn -q  connection=${Test_PC_connection}
    Should contain  ${Hping3_output}  tramitted
    Sleep  15s

Gathering scapy parameters and checking connection to RU
    [Arguments]  ${Test_PC_connection}
    Log to console  Checking connection to RU
    ${gnb}  Connect to GNB
    ${RU_IP_output}  ssh.execute
    ...  command=lxc-attach --set-var COLUMNS=250 -n 0x1018 -- tail -20 /var/tmp/radio-dhcpd/dhcp.leases | egrep 'lease'
    ...  connection=${gnb}
    ${RU_IP}  Get IP after lease  ${RU_IP_output}
    ${ping_output}  ssh.execute
    ...  command=lxc-attach --set-var COLUMNS=250 -n 0x1018 -- ping -c 1 -W 2 ${RU_IP} 2>&1 1>/dev/null; echo $?
    ...  connection=${gnb}
    Should contain  ${ping_output}  0
    Checking connection to RU  ${Test_PC_connection}  ${RU_IP}  ${gnb}
    Log to console  Gathering scapy parameters
    ${output}  ssh.execute  command=ip n | grep ${RU_IP}    connection=${Test_PC_connection}
    ${RU_Mac0}  ssh.execute  command=cat /var/lib/radio-dhcpd/lease_list.csv | awk -F, '{ print $4 }'  connection=${gnb}
    ${RU_Mac}  Fetch from left  ${RU_Mac0}  \r
    ${RU_IF}   Get string after dev  ${output}
    ${Test_PC_Mac0}  ssh.execute  command=cat /sys/class/net/${RU_IF}/address  connection=${Test_PC_connection}
    ${Test_PC_Mac}  Fetch from left  ${Test_PC_Mac0}  \r
    ${RU_IP}=  Set Suite Variable  ${RU_IP}
    ${RU_Mac}=  Set Suite Variable  ${RU_Mac}    ${RU_IF}=  Set Suite Variable  ${RU_IF}
    ${Test_PC_Mac}=  Set Suite Variable  ${Test_PC_Mac}

Firewall Test Teardown
    ssh.disconnect    connection=${RU_connection}
    ssh.disconnect    connection=${Test_PC_connection}

5GC002452_Preconditions
    [Arguments]    ${is_pdl_checking_needed}=${True}    ${timeout}=900    ${connection}=GNB_OAM
    ${tl_scf_dir_path}     String.Replace String     ${Golden_SCF_Path}    SCF_SBTS00.xml    5GC002452
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${tl_scf_dir_path}/${SCF}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.
    Wait Until Keyword Succeeds  20min  30s  COAM Check All Cells Onair     connection=GNB_OAM
    sleep   30min

Check quantity of RD files on BTS for 5GC001358
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    csn.Send Command    ls /tmp |grep RD.BTS    connection=ASIK Master
    ${files}=    csn.read_output    connection=ASIK Master
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    Should Be True    ${num_of_files}>2
    [Teardown]    csn.disconnect    connection=ASIK Master

Get snapshot and return parsed RD files for 5GC001358
    admin.connect_to    bts_host=${asik_addr}     bts_port=${443}
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${snapshot_path}    /home/ute/Downloads/s${time}/Snapshot_${time}.zip
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    admin.get_snapshot    target_file_name=${snapshot_path}  timeout=2700
    OperatingSystem.Run    unzip ${snapshot_path} -d ${unzipped}
    ${files}=    OperatingSystem.Run    ls /home/ute/Downloads/s${time}/ | grep _1011_part_
    ${RD_files_list}    Get correct file with PM for 5GC001358   ${files}
    ${parsed_files}=    Extract and parse RD files for 5GC001358    ${RD_files_list}    ${unzipped_PM}
    [Return]     ${parsed_files}

Extract and parse RD files for 5GC001358
    [Arguments]    ${RD_files_list}    ${unzipped_PM}
    FOR    ${file}    IN    @{RD_files_list}
        Run    gzip -d ${unzipped_PM}/${file}
        ${extracted_file}    Fetch From Left    ${file}    .gz
        ${parsed_files}    XML.Parse Xml    ${unzipped_PM}/${extracted_file}
    END
    [Return]    ${parsed_files}

Get correct file with PM for 5GC001358
    [Arguments]     ${files}
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    ${second_file}    evaluate    ${num_of_files} - 1
    ${third_file}    evaluate    ${num_of_files} - 2
    @{three_last_files}    create list   ${num_of_files}    ${second_file}   ${third_file}
    @{RD_files_list}    create list
    FOR    ${no}    IN    @{three_last_files}
        ${PM_file}=    Get Lines Containing String    ${files}    _1011_part_${no}
        OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
        ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep RD.BTS.*xml.gz
        @{RD_files_split_list}=    Split String    ${RD_files}    \n
        ${PMfile}=    get length    ${RD_files_split_list}
        Run Keyword If    ${PMfile}>1    Append to List    ${RD_files_list}    @{RD_files_split_list}
        Exit for loop if    ${RD_files_list}
    END
    [Return]    ${RD_files_list}

Check counters from SFP monitoring- file iteration for 5GC001358
    [Arguments]    ${parsed_files}    ${MOD_SFP_dict}    ${measurementType}
    FOR    ${file}    IN    @{parsed_files}
       ${MOD_list}    Get Dictionary Keys    ${MOD_SFP_dict}
       Check counters from SFP monitoring- MOD iteration for 5GC001358    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    END

Check counters from SFP monitoring- MOD iteration for 5GC001358
    [Arguments]    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    FOR    ${MOD}    IN    @{MOD_list}
       @{SFP_list}    Get From Dictionary    ${MOD_SFP_dict}    ${MOD}
       Check counters from SFP monitoring- SFP iteration for 5GC001358    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measurementType}    ${SFP_list}
    END

Check counters from SFP monitoring- SFP iteration for 5GC001358
    [Arguments]    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measT}    ${SFP_list}
    FOR    ${SFP}    IN    @{SFP_list}
       ${TEMPERATURE}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_TEMPERATURE
       ${XCVR_TX_SUPPLY_VOLTAGE}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_SUPPLY_VOLTAGE
       ${XCVR_TX_BIAS_CURRENT}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_BIAS_CURRENT
       ${XCVR_TX_PWR}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_PWR
       ${XCVR_RX_OPT_PWR}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_RX_OPT_PWR
       Should Be True    -128<=${TEMPERATURE}<=128
       Should Be True    0<=${XCVR_TX_SUPPLY_VOLTAGE}<=100
       Should Be True    0<=${XCVR_TX_BIAS_CURRENT}<1000
       Should Be True    -100<=${XCVR_TX_PWR}<=100
       Should Be True    -100<=${XCVR_RX_OPT_PWR}<=100
    END
