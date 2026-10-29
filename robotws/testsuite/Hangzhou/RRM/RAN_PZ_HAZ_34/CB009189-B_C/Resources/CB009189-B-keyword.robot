*** Settings ***
Documentation     author: shanxu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shangyu.xu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin   WITH NAME    enblte
Library    taf.sw.dcap.rd		WITH NAME	DCAP
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands

Resource   ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource   ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource   taf/rfrl/common_resources/robot/connection_alias_store.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    ./opt_csv_data.py

*** Variables ***
${counter_path}    BTS/CELLS/NRCELL-2/NRACH/RA_MSG3_RECEP    #BTS/CELLS/NRCELL-2/NRACH
${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T920
${btsid}      ${tl.gnbs[0].instance_id}
${bts_host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
${DCAP_host}      ${tl.test_pcs[0].default_ssh_connection_details.addr}
${DCAP_port}      ${tl.test_pcs[0].default_ssh_connection_details.port}
${TEST_LOG_DIRECTORY}       /home/ute/casetest/9189/
${gnb_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${package_web_service_SBTS}    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build



*** Keywords ***
Precondition
    [Arguments]    ${actServiceAwareConfig_expect}=${True}
    log to console    \n in precondition stage
    Check GNB cell on air
    @{MOs}    enblte.get_managed_objects    class_name=NRBTS_A    connection=COAM
    ${dist_name}    Set Variable    ${MOs[0]['distName']}/NRCELL_A-2
    &{dict_pattern}=    enblte.get_parameters    dist_name=${dist_name}   connection=COAM
    set suite variable    &{dict_pattern}
    run keyword if    ${dict_pattern['actServiceAwareConfig']} != ${actServiceAwareConfig_expect}
    ...    Set parameter    key=actServiceAwareConfig    value=${actServiceAwareConfig_expect}    
	...    dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2

	Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Set Test Parameter
    [Arguments]    ${maxDlHarqTxDrb_expect}=${8}    ${maxUlHarqTxDrb_expect}=${8}    ${lcgid_expect}=${1}    ${NRDRB_MAC}=${7}
    log to console    \n in precondition stage
    Check GNB cell on air
    @{MOs}    enblte.get_managed_objects    class_name=NRBTS_A    connection=COAM
    ${dist_name}    Set Variable    ${MOs[0]['distName']}/NRDRB_MAC_A-${NRDRB_MAC}
    &{dict_pattern}=    enblte.get_parameters    dist_name=${dist_name}   connection=COAM
    set suite variable    &{dict_pattern}
    run keyword if    ${dict_pattern['maxDlHarqTxDrb']} != ${maxDlHarqTxDrb_expect}
    ...    Set parameter    key=maxDlHarqTxDrb    value=${maxDlHarqTxDrb_expect}
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRDRB_MAC-${NRDRB_MAC}
    run keyword if    ${dict_pattern['maxUlHarqTxDrb']} != ${maxUlHarqTxDrb_expect}
    ...    Set parameter    key=maxUlHarqTxDrb    value=${maxUlHarqTxDrb_expect}
	...    dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRDRB_MAC-${NRDRB_MAC}
    run keyword if    ${dict_pattern['lcgid']} != ${lcgid_expect}
    ...    Set parameter    key=lcgid    value=${lcgid_expect}    dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRDRB_MAC-${NRDRB_MAC}

    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Check GNB cell on air
    [Documentation]
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Set parameter
    [Arguments]    ${key}    ${value}    ${dist_name}=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    admin_cli.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

L3 call setup for NSA
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot    ue_index=${ue_index}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}    4G_check=True   5Grach_ed=${5Grach_ed_0}

L3 call setdown for NSA
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

L3 call setup
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot    ue_index=${ue_index}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

L3 call setdown
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

Start Traffic DL
    [Arguments]    ${ue_type}=qct_dx50    ${ue_index}=${0}    ${dl_tp}=300M    ${duration}=${30}    ${iperf_port}=default
    ${traffic_duration}  evaluate  ${duration}*10+100
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
    ...    duration=${traffic_duration}    iperf_port=${iperf_port}

Start Traffic UL
    [Arguments]    ${ue_type}=qct_dx50    ${ue_index}=${0}    ${ul_tp}=10M    ${duration}=${30}    ${iperf_port}=default
    ${traffic_duration}  evaluate  ${duration}*10+100
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
    ...    duration=${traffic_duration}    iperf_port=${iperf_port}    iperf_type=via_command

Modify HBTE Channel Vaules
    [Arguments]    ${channels}    ${value}=30    ${ru_id}=0    ${gnb_id}=0
    #${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

Collect TTI Trace
    Connect To DCAP
    Capture Log From DCAP
    ${downloaded_tti_file_path}    DCAP.get_results    result_id=${output}[id]    target_dir=${TEST_LOG_DIRECTORY}
    Extract Specific File From DCAP Log    original_file_path=${downloaded_tti_file_path}

Connect To DCAP
    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=dcapuser
    ...     password=dcapadmin!     rd_version=dcapv3    secure=True

Capture Log From DCAP
    [Arguments]  ${log_tye}=L2Ps_Component    ${bts_mr_id}=920
    Make gnb On DCAP Server
    ${gnb_custom_profile}=     Create List     ${log_tye}
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
    ...     duration=1
    set test variable    &{output}
    sleep   7min

Make gnb On DCAP Server
    [Arguments]    ${bts_mr_id}=920    ${alias}=920
    ${bts_info}    DCAP.get_all_bts_info
    #log to console    ${bts_info}
    ${bts_info_length}    get length    ${bts_info}
    FOR    ${index}    IN RANGE    ${bts_info_length}
        ${is_bts_exist}    set variable if    ${bts_info[${index}]['mr_bts_id']} == ${btsid}    true    false
        Exit For Loop If    '${is_bts_exist}'=='true'
    END
    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts    host=${bts_host}    bts_alias=${alias}
    ...    ELSE    log to console    msg=the specific bts is exist

Extract Specific File From DCAP Log
    [Arguments]  ${original_file_path}
    ${rm_old_file}=    catenate    rm -rf ${TEST_LOG_DIRECTORY}/dcap_log; rm ${TEST_LOG_DIRECTORY}*.pcap
    ${dcap_tmp_log_path}    catenate    mkdir ${TEST_LOG_DIRECTORY}/dcap_log
    ${unzip_file}    catenate    unzip ${original_file_path} -d ${TEST_LOG_DIRECTORY}/dcap_log
    ${specific_file}    catenate    find ${TEST_LOG_DIRECTORY}/dcap_log -name *L2_COMPONENT.pcap|tail -n 1 | xargs cp -t ${TEST_LOG_DIRECTORY}
    ${result}=   Run   ${rm_old_file};${dcap_tmp_log_path};${unzip_file};${specific_file}
    ${log_file}=    Run    find ${TEST_LOG_DIRECTORY} -maxdepth 1 -name *.pcap
    set suite variable    ${log_file}

Decode Log File And Convet File Format
    ${ttidecoder_path}    Download TTI Decoder Tool
    ${target_csvs}    TTI Decoder Run Pcap to CSV     inputfile_path=${log_file}     ttidecoder_path=${ttidecoder_path}
    Set Test Variable    ${target_csvs}

Download TTI Decoder Tool
    [Arguments]
    ${release}    Get gnb release    host=${gnb_addr}    username=${gnb_username}    password=${gnb_password}
    ${release}    Run keyword if   '${release}'=='TRUNK'      set variable   SBTS00
    ...   ELSE   set variable   ${release}
    ${coam_version}    _Get_gnb_version
    ${coam_version}    run keyword if   ${coam_version.count('23R1')} > 0    Replace String   ${coam_version}    23R1   00
    ...   ELSE       Set Variable    ${coam_version}
    Create Directory    /home/ute/Downloads
    Set Suite Variable   ${ttidecoder_path}   ${TEST_LOG_DIRECTORY}/ttitrace-${coam_version}
    Run    rm -rf ${TEST_LOG_DIRECTORY}/ttitrace-*
    ${version_path_list}    	Get Regexp Matches    ${AF_PATH}   \\d+.\\d+.\\d+
    ${package_download_path}    run keyword if  ${release.count('SBTS')} > 0    Set Variable
    ...   ${package_web_service_SBTS}/${release}/${coam_version}_tti-dec_qemux86-64-static.txz
    ...   ELSE    Set Variable    ${package_web_service}/${version_path_list[0]}/${coam_version}_tti-dec_qemux86-64-static.txz
    Log    \n Start to Download Package From WFT!    INFO
    Run   rm -f wget-log*
    Run   wget -b ${package_download_path} -P ${TEST_LOG_DIRECTORY}
    Wait Until Keyword Succeeds   10m   1m   Wait Until wget process done
    ...  ${coam_version}_tti-dec_qemux86-64-static.txz
    OperatingSystem.File Should Exist   ${TEST_LOG_DIRECTORY}/${coam_version}_tti-dec_qemux86-64-static.txz
    Log To Console    Download Package Finished!
    Run   mkdir ${ttidecoder_path}
    Run   tar xJvf ${TEST_LOG_DIRECTORY}/${coam_version}_tti-dec_qemux86-64-static.txz -C ${ttidecoder_path}
    [Return]   ${ttidecoder_path}

_Get_gnb_version
    [Arguments]   ${host}=${gnb_addr}   ${username}=${gnb_username}   ${password}=${gnb_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${version}   csn.Execute    cd /ffs/run;ls TargetBD*.xml  connection=release_info
    ${version}    Fetch From Right    ${version}    TargetBD_
    ${version}    Fetch From Left    ${version}    .
    [Return]    ${version}
    [Teardown]   csn.Disconnect   connection=release_info

Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   Run   cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}

TTI Decoder Run Pcap to CSV
    [Arguments]    ${inputfile_path}    ${ttidecoder_path}
    Run    rm -rf /${ttidecoder_path}/tti-dec-bin/*.csv
    ${inputfile}    Fetch From Right    ${inputfile_path}    /
    Copy File    ${inputfile_path}     ${ttidecoder_path}/tti-dec-bin
    run keyword if  ${inputfile.count('.xz')} > 0    Run   unxz ${ttidecoder_path}/tti-dec-bin/${inputfile}
    ${inputfile}   fetch from left   ${inputfile}    .xz
    ${output}    Run
    ...  cd ${TEST_LOG_DIRECTORY};pip3 install pandas --proxy=http://10.144.1.10:8080
    Should Not Contain any   ${output}    error   fail   Error
    ${output}    Run
    ...  cd ${TEST_LOG_DIRECTORY};python3 ${ttidecoder_path}/tti-dec-bin/TtiTraceDecoder.py ${ttidecoder_path}/tti-dec-bin/${inputfile} excelCsv
    Should Not Contain any   ${output}    error   fail   Error

    ${csvfile}    Run    cd ${TEST_LOG_DIRECTORY};ls | grep csv
    @{csvfiles}  	Split String	${csvfile}	 \n
    ${csvfiles_path}    Create List
    FOR   ${csvfile}  IN   @{csvfiles}
        File Should Not Be Empty    ${TEST_LOG_DIRECTORY}/${csvfile}
        Append to list    ${csvfiles_path}     ${TEST_LOG_DIRECTORY}/${csvfile}
    END
    [Return]    @{csvfiles_path}

Check MaxHarqNum
    [Arguments]      ${tti_dire}=ul    ${bear_num}=single    ${NRDRB_MAC}=7    ${single}=true
    log to console    Check MaxHarqNum from TTI trace
    Check GNB cell on air
    @{MOs}    enblte.get_managed_objects    class_name=NRBTS_A    connection=COAM
    ${dist_name}    Set Variable    ${MOs[0]['distName']}/NRDRB_MAC_A-${NRDRB_MAC}
    &{dict_pattern}=    enblte.get_parameters    dist_name=${dist_name}   connection=COAM
    set suite variable    &{dict_pattern}
    ${maxDlHarqTxDrb}    set variable    ${dict_pattern['maxDlHarqTxDrb']}
    ${maxUlHarqTxDrb}    set variable    ${dict_pattern['maxUlHarqTxDrb']}
    ${maxDlHarqTxDrb}    Convert To Integer    ${maxDlHarqTxDrb}
    ${maxUlHarqTxDrb}    Convert To Integer    ${maxUlHarqTxDrb}
    ${target_csv}=    set variable    ${TEST_LOG_DIRECTORY}changed_csv_file.csv
    Create File          	${target_csv}
    ${log_file}=    Run    find ${TEST_LOG_DIRECTORY} -maxdepth 1 -name '*${tti_dire}*.csv' | tail -n 1
    ${column_filter}=    set variable if    '${tti_dire}'=='ul'    ulFdSchedData.maxHarqTxNum    dlFdSchedData.maxHarqTxNum
    
    delete_unexpect_rnti_row    ${log_file}    ${target_csv}    ${column_filter}
    ${maxharqnum}=    get_specified_column_from_csv_file   ${target_csv}    ${column_filter}
    ${maxharqnum}    remove duplicates    ${maxharqnum}
    #${maxharqnum}=    get_specified_column_from_csv_file   /home/ute/casetest/9189/ttiTrace_ul.csv    ulFdSchedData.maxHarqTxNum
    ${maxHarqTxDrb}=    Set Variable If    '${tti_dire}'=='ul'    ${maxUlHarqTxDrb}    ${maxDlHarqTxDrb}
    @{single_maxharqnum}    Create List    ${maxHarqTxDrb}
    ${maxharqnum}=    Evaluate    list(map(float, @{maxharqnum}))
    ${maxharqnum}=    Evaluate    list(map(int, @{maxharqnum}))
    ${single_maxharqnum}=    Evaluate    list(map(int, @{single_maxharqnum}))
    ${single_maxharqnum}    Set Variable    ${single_maxharqnum}
    ${maxharqnum_type}    Evaluate    type(${maxharqnum})
    ${single_maxharqnum_type}    Evaluate    type(${single_maxharqnum})

    Run Keyword If    '${single}' == 'true'    should be equal    ${maxharqnum}    ${single_maxharqnum}
    ...    ELSE    Should Contain    ${maxharqnum}    ${single_maxharqnum}

Teardown
    log to console    \n in teardown stage
    Run   rm ${TEST_LOG_DIRECTORY}*.zip; rm ${TEST_LOG_DIRECTORY}*.txz; rm ${TEST_LOG_DIRECTORY}*.csv
    admin_cli.teardown    connection=COAM
