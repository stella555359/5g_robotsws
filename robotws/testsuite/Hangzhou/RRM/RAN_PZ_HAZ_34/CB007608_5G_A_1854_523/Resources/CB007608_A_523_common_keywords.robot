*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Resource          ../../5GC000523_samsung/Resources/5GC000523_common_keyword.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    admin
Resource          ../../5GC001937_Classical/Resources/5GC001937_classical_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_stream_Analysis_MMW4.py
Library           TTI_stream_Analysis_MMW4.TTI_Stream_analysis    WITH NAME    TTI_Stream

*** Variables ***
${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${filename}                 full.zip
${gnb_path}                 /ffs/run/config/toor4nsn/
${host}                     ${tl.test_pc.default_ssh_connection_details.addr}
${username}                 ${tl.test_pc.default_ssh_connection_details.username}
${password}                 ${tl.test_pc.default_ssh_connection_details.password}
${scf_file_path}            ${output_dir}
${ASIK1}                     ASIK1 Master
${ABIL_MASTER_ALIAS1}        ABIL1 Master
${ABIL_SLAVE_ALIAS1}         ABIL1 Slave
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${LUA_SCRIPT_PATH}      /home/ute/Downloads/lua/generated_luashark/luashark.lua

*** Keywords ***
Get Version
    Log To Console    Get Version
    ${conn}    Connect to DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Adjust Enb
    [Arguments]    ${index}=locked  ${alias}=enblte    ${dist_name}=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNADJGNB-1
    ...    ${parameter}=administrativeState
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${index}

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    admin.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    admin.teardown     connection=${alias}

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=   admin.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=update    ${connection}=cOAM_admin
    ...    ${skip_parameter_relation_errors}=${False}     ${should_activate}=${True}
    admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

start tti trace
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    log to console  start capture tti trace
    Create default connection    hw_slot=${hw_slot}
    Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}

Start Traffic and Capture tti trace log
    [Arguments]  ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}   ${ul_duration}=6000   ${dl_duration}=6000
    ...    ${if_ul}=${True}   ${if_dl}=${True}
    attach multi power ue    ue_num=${ue_num}
    start multi power ue traffic ul and dl    ue_num=${ue_num}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    ...    ul_duration=${ul_duration}   dl_duration=${dl_duration}   if_ul=${if_ul}    if_dl=${if_dl}
    CB007608_A_523_common_keywords.start tti trace
    sleep    20s
    Stop TTI trace log capturing
    ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
    ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
    stop multi power ue traffic ul and dl    ue_num=${ue_num}
    [Return]    ${UL_DL_csv_file_path_dict}
    [Teardown]    run keyword and ignore error    detach multi power ue    ue_num=${ue_num}

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/scf_7608.xml
    ...    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    admin.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${False}    connection=${connection}


check rrmUsedMcs and rrmProposedMcs in full traffic
    [Arguments]     ${rrmUsedMcs_list}    ${rrmProposedMcs_list}    ${full_rrmUsedMcs}
    ${total_num}    get length    ${rrmUsedMcs_list}
    ${ratio}    evaluate    float(${full_rrmUsedMcs})/float(${total_num})
    should be true    ${ratio}<0.1

check prb according tbsize in full traffic
    [Arguments]     ${csv_file_dict}
    ${prb_tbsize_dict}    get_ulFdSchedData_numofprb_and_tbsize_19b    file_path_dict=${csv_file_dict}
    ${tb_size_list}     get dictionary keys    ${prb_tbsize_dict}
    FOR    ${tbsize}    IN    @{tb_size_list}
        ${prb}    get from dictionary  ${prb_tbsize_dict}    ${tbsize}
        run keyword if  ${tbsize}>=4040    should be true  ${prb}==66
    END

check prb according tbsize data
    [Arguments]     ${csv_file_dict}
    ${prb_tbsize_dict}    get_ulFdSchedData_numofprb_and_tbsize_19b    file_path_dict=${csv_file_dict}
    ${tb_size_list}     get dictionary keys    ${prb_tbsize_dict}
    FOR    ${tbsize}    IN    @{tb_size_list}
        ${prb}    get from dictionary  ${prb_tbsize_dict}    ${tbsize}
        run keyword if  ${tbsize}<1000    should be true  ${prb}<=16
    END

get_rrmUsedMcs_and_rrmProposedMcs
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}
    ${direction}    convert_to_uppercase    ${direction}
    ${path}    get from dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    ${ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
    ${rrmDlUsedMcs}   ${full_rrmUsedMcs}   get_rrmUsedMcs_19b     file_path=${path}    direction=${direction}
    ${rrmDlProposedMcs}    get_rrmProposedMcs_19b    file_path=${path}     direction=${direction}
    [Return]   ${rrmDlUsedMcs}     ${rrmDlProposedMcs}   ${full_rrmUsedMcs}


Start Traffic and Check tbsize and sfn from tti trace
    [Arguments]  ${ue_num}    ${actProactUlScheduling}    ${sfn_diff_tolerance}    ${UL_DL_csv_file_path_dict}
    ${ratio_ul}    check sfn and tbsize on different actProactUlScheduling    UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}
    ...    actProactUlScheduling=${actProactUlScheduling}    sfn_diff_tolerance=${sfn_diff_tolerance}    direction=UL
    log to console   ${ratio_ul}
    [Return]   ${ratio_ul}

check rrmUsedMcs and rrmProposedMcs in less traffic
    [Arguments]     ${rrmUsedMcs_list}    ${rrmProposedMcs_list}
    FOR  ${item}    IN    @{rrmUsedMcs_list}
          log    ${item}    console=yes
         ${index}    get index from list    ${rrmUsedMcs_list}   ${item}
         run keyword and continue on failure    should be true    ${rrmUsedMcs_list}[${index}]<=${rrmProposedMcs_list}[${index}]
     ...   msg=rrmDlUsedMcs is not less than rrmDlProposedMcs while less traffic
    END

check sfn and tbsize on different actProactUlScheduling
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${actProactUlScheduling}   ${sfn_diff_tolerance}   ${direction}=UL   ${tbsize_threshold}=${4040}
    ${sfn_diff_list}    ${tbsize_list}    Get sfn and tbsize value    UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}   direction=${direction}
    run keyword if   ${actProactUlScheduling}==${True}
    check sfn with actProactUlScheduling    sfn_diff_list=${sfn_diff_list}
    ...    sfn_diff_tolerance=${sfn_diff_tolerance}
    run keyword if   ${actProactUlScheduling}==${False}    check sfn without actProactUlScheduling    sfn_diff_list=${sfn_diff_list}
    ...    sfn_diff_tolerance=${sfn_diff_tolerance}
    ${ratio}    Evaluate Percentage of Small tbsize    tbsize_list=${tbsize_list}    tbsize_threshold=${tbsize_threshold}
    [Return]  ${ratio}

Get sfn and tbsize value
    [Arguments]   ${UL_DL_csv_file_path_dict}    ${direction}=UL
    ${path}    get from dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    ${ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
    ${rnti_list}    ${ue_rnti_number}   get_multi_rntis_from_tti_trace_19b    path=${ul_path}
    ${attach_list}    Get_Attach_ue_rnti    rnti_list=${rnti_list}    ue_rnti_number=${ue_rnti_number}
    ${fdSchedData_event}    get_fdscheddata_event_from_tti_trace_19b    file_path=${path}    rnti=${attach_list[0]}    direction=${direction}
    ${sfn_list}    ${tbsize_list}    get_sfn_tbsize_according_fdscheddata_19b    file_path=${path}    fdSchedData_data=${fdSchedData_event}
    ...    direction=${direction}
    ${sfn_diff_list}    ${tbsize_sub_list}    get_sfn_diff_tbsize_19b    sfn_list=${sfn_list}    tbsize_list=${tbsize_list}
    [Return]   ${sfn_diff_list}    ${tbsize_list}

check sfn with actProactUlScheduling
    [Arguments]   ${sfn_diff_list}   ${sfn_diff_tolerance}=${2}
    FOR    ${item}    IN    @{sfn_diff_list}
         should be true  ${item}<=${sfn_diff_tolerance} or ${item}==${1023}    msg=sfn schedulesing is slow with actProactUlSchedulings
    END

check sfn without actProactUlScheduling
    [Arguments]   ${sfn_diff_list}   ${sfn_diff_tolerance}=${7}
    FOR    ${item}    IN    @{sfn_diff_list}
        should be true  ${item}>${sfn_diff_tolerance}    msg=sfn schedulesing is slow with actProactUlSchedulings
    END

Evaluate Percentage of Small tbsize
    [Arguments]    ${tbsize_list}    ${tbsize_threshold}
    ${small_tbsize_num}    set variable    0
    FOR    ${item}    IN    @{tbsize_list}
        ${small_tbsize_num}    run keyword if  ${item}<${tbsize_threshold}    evaluate    ${small_tbsize_num}+1
        ...     ELSE     set variable    ${small_tbsize_num}
    END
    ${total_num}    get length    ${tbsize_list}
    ${ratio}    evaluate    float(${small_tbsize_num})/float(${total_num})
    [Return]  ${ratio}

check multi ue traffic
    [Arguments]    ${ue_num}
    log to console       Check throughput
    FOR    ${item}    IN    ${ue_num}
        power_ue.Check throughput    ue_index=${item}    ue_type=samsung    direction=UL    throughput=50M
        power_ue.Check throughput    ue_index=${item}    ue_type=samsung    direction=DL    throughput=50M
    END

523 Capture BIP log
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts    capturing_time_seconds=60s    sleep_time=5s
    sleep    10s
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    interface=ethbp1    log_prefix=tcpdump_L2L1
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Csn.Disconnect    connection=ASIK Master
    [Return]    ${bip_log_path}

Check BIP trace
   ${PdcchOLPrecodingOption4X4}    set variable    1
    ${UlData_PuschReceiveRespPs_filter}=    catenate
   ...    DlData_PdschSendReq.grants_item_0.mcs == 0x10
   ${filtered_packets}    Parse Pcap by expression with luashark
   ...    input_file=/home/ute/robotws5g/testsuite/RRM/Hangzhou/CB007608_A_523/log/tcpdump_L2L1_tcpdump_L2L1_bip_filtering_off_20210907-152417.pcap
    [Return]    ${filtered_packets}

Parse Pcap by expression with luashark
    [Documentation]    Author: Yang Mengli
    ...                analysis pcap with expression
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence
    ${filtered_packets}    Run    tshark -r ${input_file} -X lua_script:${LUA_SCRIPT_PATH}
    Should Not Be Empty    ${filtered_packets}
    [Return]    ${filtered_packets}

Check BIP log data not empty
    [Arguments]    ${source}=${bip_log_path}   ${filter}=dldata_csirssendreq
    ...    ${command}=grep startSymbol     ${txt_filename}=bip.txt   ${connection}=ute    ${target}=${OUTPUT_DIR}/bip.txt
    ${data}    Check wireshark log data common    command=${command}    source=${source}    connection=${connection}
    ...    filter=${filter}    target=${OUTPUT_DIR}/${txt_filename}
    should not be empty    ${data}
    log to console    data:${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

Check wireshark log data common
    [Arguments]    ${source}   ${target}   ${filter}   ${command}    ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    523 Convert Pcap To Text    source=${source}    target=${target}    filter=${filter}    connection=${connection}
    csn.Send Command  command=cat ${target} |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect  	connection=${connection}

523 Convert Pcap To Text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    Log To Console    Convert pcap to text
    ssh.execute
    ...    command=tshark -V -r ${source} -T text -Y ${filter} > ${target}
    ...    connection=${connection}
    ssh.await execution end    connection=${connection}    timeout=30min

Connect to ENB with ssh
    [Arguments]    ${hostname}=${enb_ip}    ${username}=${eNB_username}      ${password}=${eNB_password}   ${alias}=enb
    csn.connect_to   hostname=${hostname}
        ...    username=${username}    password=${password}    alias=${alias}

Get BTS Version And Perare SCF
    [Arguments]    ${gNB_ip}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${gNB_ip}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    CB007608_common.Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/${scf_name}_523.xml
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Capture TTI log
    [Timeout]  20min
    [Arguments]    ${log_time}=3    ${bts_ip}=${DU_IP}    ${connection}=GNB_OAM
    ${filter}    set variable    csiSrReportData|dlFdSchedData
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${csv_path}    Capture And Decode TTitrace Log    duration=${log_time}    by_filter=${True}    filter=${filter}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
    [Return]  ${UL_DL_csv_file_path_dict}
