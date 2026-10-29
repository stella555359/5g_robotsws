*** Settings ***
Documentation     author: Qian Jianwu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: jianwu.qian@nokia-sbell.com

Library     taf.analyzer.pcap    WITH NAME    cap
Library    taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***
${scf_path}    ${commissionings_path}/HGZ/${testline_name}
${iqlog_save_path}    /home/ute/dir/
${local_rotta_path}    /home/ute/rotta/
${iqlog_rename}   test.tgz
${l1sw_download_url}    https://artifactory-espoo2.int.net.nokia.com/artifactory/l1sw-release-local
${analyze_path}    /home/ute/test
${result_path}    ${analyze_path}/result/
${check_message_type_fcp}    ecpri.type == 0x02
${check_message_type_iq}    ecpri.type == 0x00
${BBMOD_trunk}    BBMOD_R-1(ABIO)
${BBMOD_not_trunk}    BBMOD_R-1(ABIO)
${slave_ip}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${IQ_conf_copy}    cp /etc/snapshot.conf /usr/lib64/python/
${IQ_conf_recopy}    cp /usr/lib64/python/snapshot.conf /etc/
${IQ_sed1}    sed -i 's/numUlSubCellId = 0/numUlSubCellId = 1/g' /usr/lib64/python/snapshot.conf
${IQ_sed2}    sed -i 's/ulSubCellId1 = 1/ulSubCellId1 = 0/g' /usr/lib64/python/snapshot.conf
${IQ_sed3}    sed -i 's/numDlSubCellId = 0/numDlSubCellId = 1/g' /usr/lib64/python/snapshot.conf
${IQ_sed4}    sed -i 's/dlSubCellId1 = 1/dlSubCellId1 = 0/g' /usr/lib64/python/snapshot.conf
${IQ_msgsend}   python3 /usr/lib64/python/syscom_msgsend.py
${IQ_copy}    scp ${ssh_username}@${slave_ip}:/ram/L1Log/Snapshot/slot_1/soc_1/*.bin /tmp/

*** Keywords ***
Common Suite Setup For 8017
    [Arguments]    ${timeout}=20min
	Run Keyword And Ignore Error    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
	${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
	Scf commition and wair for on-air    scf_name=${scf_path}/SCF_8T8R_${stream}.xml
    ...     is_pdl_checking_needed=${False}
    [Teardown]    coam.teardown    connection=GNB_OAM

Save IQ Capture
    [Arguments]    ${enable_capture_on_event}=True    ${PhycialCellId}=${51}
    ...    ${NRCellId}=${1}    ${SubCellId}=${0}    ${sfn_value}=65535    ${slot_value}=0
    ...    ${capture_mode}=Start a new scheduled capture
    ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
    run    command=mkdir ${iqlog_save_path}/${current_time}
    run    command=rm -rf /home/ute/L1IQData*
    run    command=rm -rf ${analyze_path}/*
    ${stream}    get stream from version    ${Active_SW_version}
    ${ul}=    Run Keyword If   '${stream}'=='SBTS22R4'   Create List    [PCI: ${PhycialCellId}]NRCELL_R-${NRCellId}: Subcell ${SubCellId}
    ...   ELSE IF   '${stream}'=='SBTS23R1'   Create List   [PCI: ${PhycialCellId}]NRCELL-${NRCellId}: Subcell ${SubCellId}
    ...   ELSE   Create List    [BBMOD_R-1(ABIO)] [PCI: ${PhycialCellId}]NRCELL-${NRCellId}: Subcell ${SubCellId}
    ${dl}=    Run Keyword If   '${stream}'=='SBTS22R4'   Create List    [PCI: ${PhycialCellId}]NRCELL_R-${NRCellId}: Subcell ${SubCellId}
    ...   ELSE IF   '${stream}'=='SBTS23R1'   Create List    [PCI: ${PhycialCellId}]NRCELL-${NRCellId}: Subcell ${SubCellId}
    ...   ELSE   Create List    [BBMOD_R-1(ABIO)] [PCI: ${PhycialCellId}]NRCELL-${NRCellId}: Subcell ${SubCellId}
    ${BBMOD}    set variable if    'stream'=='SBTS00'    ${BBMOD_trunk}    ${BBMOD_not_trunk}
    set test variable    ${BBMOD}
    ${stream}    get stream from version    ${Active_SW_version}
	Web Login With Version    version=${stream}
	Run Keyword And Ignore Error   Run Keyword If   '${stream}'=='SBTS00'
    ...   selenium_coam.configure_iq_capture   ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}
    ...   enable_capture_on_event=${enable_capture_on_event}
    ...   ELSE   selenium_coam.configure_iq_capture    bbmod=${BBMOD}   ul_subcell_index_list=${ul}
    ...   dl_subcell_index_list=${dl}    enable_capture_on_event=${enable_capture_on_event}
	sleep    30s
	Run Keyword And Ignore Error   Run Keyword If   '${stream}'=='SBTS00'
	...    selenium_coam.save_iq_capture    sfn_value=${sfn_value}    slot_value=${slot_value}
	...    capture_mode=${capture_mode}
	...    ELSE    selenium_coam.save_iq_capture    bbmod=${BBMOD}    sfn_value=${sfn_value}    slot_value=${slot_value}
	...    capture_mode=${capture_mode}
	sleep    300s
	run    command=mv /home/ute/L1IQData* ${iqlog_save_path}/${current_time}/${iqlog_rename}
	run    command=cp ${iqlog_save_path}/${current_time}/${iqlog_rename} ${analyze_path}
	${Iqfile_name} =   run    command=tar -vxf ${analyze_path}/${iqlog_rename} -C ${analyze_path}
	run    command=tar -vxf ${analyze_path}/${Iqfile_name} -C ${analyze_path}
	run    command=rm -rf ${analyze_path}/*Events.bin
	run    command=rm -rf ${analyze_path}/PSMLog*
    [Teardown]  run keywords    selenium logout and close browser

Get Current L1SW Version
    [Arguments]
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=gNB_target
    csn.send command    command=bsh 1:1 cat /etc/l1sw/build-info.json | grep branch     connection=gNB_target
    ${branch}=    csn.read output    connection=gNB_target
    ${url_branch}    Return L1SW stream    l1sw_version=${branch}
    set suite variable      ${url_branch}
    csn.send command    command=bsh 1:1 cat /etc/l1sw/build-info.json | grep label     connection=gNB_target
    ${build_label}=    csn.read output    connection=gNB_target
    @{temp_string}    split string    ${build_label}    separator="
    ${url_build}    set variable    ${temp_string}[3]
    set suite variable      ${url_build}
    [Teardown]    csn.disconnect    connection=gNB_target

Return L1SW stream
    [Arguments]  ${l1sw_version}
    ${sbts_22R3}    run keyword and return status      Should Contain Any   ${l1sw_version}    22r3
    return from keyword if    ${sbts_22R3}    22r3
    ${sbts_22R4}    run keyword and return status      Should Contain Any   ${l1sw_version}    22r4
    return from keyword if    ${sbts_22R4}    22r4
    ${sbts_23R1}    run keyword and return status      Should Contain Any   ${l1sw_version}    23r1
    return from keyword if    ${sbts_23R1}    23r1
    ${sbts_trunk}    run keyword and return status      Should Contain Any   ${l1sw_version}    23r2    master
    return from keyword if    ${sbts_trunk}    master

Download L1SW Package
    [Arguments]    ${download_local_path}=${analyze_path}
    Get Current L1SW Version
    ${download_url}    set variable    ${l1sw_download_url}/${url_branch}/${url_build}/${url_build}.loki.debug.tgz
    ${download_cmd}=    Catenate    wget ${download_url} -P ${analyze_path}
    run    command=${download_cmd}
    sleep    60s
    ${tar_cmd}=   Catenate    tar -vxf ${analyze_path}/${url_build}.loki.debug.tgz -C ${analyze_path}
    run    command=${tar_cmd}

Analyze IQ file
    [Arguments]
    ${tool_path}    set variable    /home/ute/test/debug/loki/snapshot_tool/SnapshotAnalyzer.py
    ${file_path}    set variable    ${analyze_path}/*.bin
    ${analyze_cmd}=    Catenate    python ${tool_path} --template ${analyze_path}/debug/loki/snapshot_tool/TEMPLATE
    ...  --iqdata ${file_path} --output ${result_path}
    run    command=${analyze_cmd}
    sleep    10s

Read Wireshark Log
    [Arguments]    ${filename}    ${filter}=${None}
    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}

Get Element Value From Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    [Return]    ${value}

FCP Message Check Point
    [Arguments]
    ${DL_PCAP}=    run    command=ls ${result_path} | grep -i dl
    cap.Read Cap    cap_file=${result_path}/${DL_PCAP}
    ${DL_status} =    run_keyword_and_return_status    cap.Check Expression    ${check_message_type_fcp}
    should be equal    ${DL_status}    ${True}
    ${UL_PCAP}=    run    command=ls ${result_path} | grep -i 5G_UL
    cap.Read Cap    cap_file=${result_path}/${UL_PCAP}
    ${UL_status} =    run_keyword_and_return_status    cap.Check Expression    ${check_message_type_fcp}
    should be equal    ${UL_status}    ${True}

IQ Message Check Point
    [Arguments]
    ${IQ_log}=    run    command=ls ${result_path} | grep -i IqSamples
    cap.Read Cap    cap_file=${result_path}/${IQ_log}
    ${IQ_status} =    run_keyword_and_return_status    cap.Check Expression    ${check_message_type_iq}
    should be equal    ${IQ_status}    ${True}

Web Login With Version
    [Arguments]    ${version}
    #selenium_coam.Enable Virtual Display
    selenium_coam.Login  url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    download_dir=/home/ute
    ...    timeout=60
    ...    version=${version}
    selenium_coam.Disable Message Box
    selenium_coam.Disable Screen Lock

IQ Capture By SSH
    [Arguments]    ${time}=${20}
    ssh.Connect_to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=middle
    SSH.Force Reconnect    middle
    ssh.Connect_to    ${slave_ip}     ${ssh_username}    ${ssh_password}    alias=target    proxy=middle
    ssh.Send Command    command=${IQ_conf_copy}     connection=target
	sleep    10s
    ssh.Send Command    command=${IQ_sed1}     connection=target
	sleep    10s
    ssh.Send Command    command=${IQ_sed2}     connection=target
	sleep    10s
    ssh.Send Command    command=${IQ_sed3}     connection=target
	sleep    10s
    ssh.Send Command    command=${IQ_sed4}     connection=target
	sleep    10s
    ssh.Send Command    command=${IQ_conf_recopy}     connection=target
	sleep    10s
    ssh.Send Command    command=${IQ_msgsend} 124D 2     connection=target
    sleep    ${time}s
    csn.send command    command=${IQ_msgsend} 124D 1     connection=target
    sleep    60s
    ssh.Disconnect    target
    ssh.Send Command    command=${IQ_copy}     connection=middle
	sleep    20s
    ssh.Download File    remote_path=/tmp/124D_IqSamples.bin    local_path=${analyze_path}/124D_IqSamples.bin
    ...    connection=middle
    ssh.Download File    remote_path=/tmp/5G_DL_124D_Fcp.bin    local_path=${analyze_path}/5G_DL_124D_Fcp.bin
    ...    connection=middle
    ssh.Download File    remote_path=/tmp/5G_UL_124D_Fcp.bin    local_path=${analyze_path}/5G_UL_124D_Fcp.bin
    ...    connection=middle
    [Teardown]    ssh.Disconnect    middle
