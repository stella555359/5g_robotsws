*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB009189-B in 5G23R1 program

Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library     taf.sw.dcap.rd		WITH NAME	DCAP
Library     taf.analyzer.pcap    WITH NAME    cap
Library     taf.pdu  WITH NAME   pdu
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     ./opt_csv_data.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

*** Variables ***
${cell_id}    ${1}
${cellgroup_id}    ${0}
${btsid}      ${tl.gnbs[0].instance_id}
${bts_host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
${gnb_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${enb_instance}             ${tl.enbs[0].instance_id}
${enbcell_dist}             MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enbcell_para2}            defaultLnRelGnbCellId
${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}
${testline_name}    7_5_UTE5G402T902
${package_web_service_SBTS}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
### DCAP INFO ###
${DCAP_host}                ${tl.test_pc[1].default_ssh_connection_details.addr}
${DCAP_port}                ${tl.test_pc[1].default_ssh_connection_details.port}

${file_name}    VoNR.pcap
${tshark_path}      /usr/bin/tshark
${command_template_with_Y}    {tshark_path} -r ${log_path}/${file_name} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml
${TEST_LOG_DIRECTORY}    /home/ute/casetest/bbttss/

*** Keywords ***
L3 call setup
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=${UE_TYPE}     ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${reset_sol}=none
    ...    ${4G_check}=${False}    ${data_transfer_direction}=ul    ${duration}=30s    ${iperf_port}=default    ${dltp}=${0}    ${ultp}=${0}
    log to console    L3 call setup and check \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}    reset_sol=${reset_sol}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    Log To Console    \n ###UE Start traffic ###
    run keyword if    '${data_transfer_direction}'=='ul'
    ...    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=${ul_throughput}    duration=600    iperf_type=via_command
    ...    iperf_port=${iperf_port}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}    duration=600
    ...    iperf_port=${iperf_port}
    ...    ELSE IF    '${data_transfer_direction}'=='both'
    ...    Run Keywords    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}    duration=1200
    ...    iperf_port=${iperf_port}   AND
    ...    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=${ul_throughput}    duration=1200    iperf_type=via_command
    ...    iperf_port=${iperf_port}
    ...    ELSE    Fail    msg=data_transfer_direction should be ul, dl or both
    Log To Console    \n ### Start Check Tput ###
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}   duration=${duration}   ignore_time=1s
    ${list_of_cell_ids}    create list
    #wait until keyword succeeds     2min    1s
    #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...      username=Nemuadmin
    #...      password=nemuuser
    #...      name=COAM
    ${nrcellid}    Get parameter value    class_name=NRCELL_A    pattern=nrCellIdentity    connection=COAM    num_MO=${cell_id}
    append to list    ${list_of_cell_ids}   ${nrcellid}
    run keyword if    '${data_transfer_direction}'=='ul'
    ...    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${ultp}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...    power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${dltp}
    ...    ELSE IF    '${data_transfer_direction}'=='both'
    ...    Run Keywords    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${ultp}    AND
    ...    power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${dltp}
    ...    ELSE    Fail    msg=data_transfer_direction should be ul, dl or both
    #[Teardown]     run keyword and ignore error      admin_cli.teardown    connection=COAM

L3 call stop
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

Get parameter value
    [Arguments]   ${class_name}=NRDRB_MAC_A    ${pattern}=maxUlHarqTxDrb    ${connection}=COAM    ${num_MO}=1
    @{MOs}    admin_cli.get_managed_objects    class_name=${class_name}    connection=${connection}
    FOR    ${MO}    IN    @{MOs}
        ${result}=    Run Keyword And Return Status    should contain    ${MO['distName']}    ${class_name}-${num_MO}
        ${target_MO}=    Set Variable If    ${result}    ${MO}
        Exit For Loop If    ${target_MO} != None
    END
    &{dict_pattern}=    admin_cli.get_parameters    dist_name=${target_MO['distName']}    pattern=${pattern}    connection=${connection}
    #&{dict_pattern}=    admin_cli.get_parameters    dist_name=${MOs[${target_cell}]['distName']}  pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Suite Teardown with SCF
    Modify HBTE Channel Vaules    value=0
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='24R3'    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    ...   ELSE IF    '${RELEASE}'=='24R1'     Scf commission and wait on-air    scf_name=SCF_SBTS24R1.xml

Get program version
    [Documentation]    Author: Ding Binmei
    ...                Description: Change the implementation to get program info from GNB.
    ...                Retrun with ${program_version}, valid output: 19A, 19B, 20B, master, ...
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    ${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    [Return]    ${program_version}

Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    log to console    step1:scf commission and wait for on-air
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${scf_file_path}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}


##### modify Enb configuration #####
Connect to eNB
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${enb_index}=${0}
    admin_cli.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}


Modify the parameter on enblte and scip errors
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    admin_cli.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte
    ...                                            skip_parameter_relation_errors=True

Connect and Modify the parameter on enblte scip errors
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte and scip errors    ${dist_name}     ${parameter}    ${value}
    admin_cli.teardown    connection=enblte

Configure correct defaultLnRelGnbCellId for anchor cell
    run keyword and ignore error     Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}
    ...    parameter=${enbcell_para2}    value=1
##### end ######

Connect To DCAP
    log to console     DCAP ip and port is ${DCAP_host} and ${DCAP_port}
    wait until keyword succeeds     3min    5s
    ...    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=${None}
    ...     password=${None}     rd_version=dcapv3    secure=True

Capture Log From DCAP
    [Arguments]  ${log_tye}=L2Ps_Component    ${bts_mr_id}=922
    Make gnb On DCAP Server
    ${gnb_custom_profile}=     Create List     ${log_tye}
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
    ...     duration=1
    set test variable    &{output}
    sleep   1min

Make gnb On DCAP Server
    [Arguments]    ${bts_mr_id}=922
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
    ${rm_old_file}=    catenate    rm -rf ${TEST_LOG_DIRECTORY}dcap_log; rm ${TEST_LOG_DIRECTORY}*.pcap
    ${dcap_tmp_log_path}    catenate    mkdir ${TEST_LOG_DIRECTORY}dcap_log
    ${unzip_file}    catenate    unzip ${original_file_ path} -d ${TEST_LOG_DIRECTORY}dcap_log
    ${specific_file}    catenate    find ${TEST_LOG_DIRECTORY}dcap_log -name *L2_COMPONENT.pcap|tail -n 1 | xargs cp -t ${TEST_LOG_DIRECTORY}
    ${result}=   Run   ${rm_old_file};${dcap_tmp_log_path};${unzip_file};${specific_file}
    ${log_file}=    Run    find ${TEST_LOG_DIRECTORY} -maxdepth 1 -name *.pcap
    set suite variable    ${log_file}

Decode Log File And Convet File Format
    ${ttidecoder_path}    Download TTI Decoder Tool
    ${target_csvs}    TTI Decoder Run Pcap to CSV     inputfile_path=${log_file}     ttidecoder_path=${ttidecoder_path}
    Set Test Variable    ${target_csvs}

Download TTI Decoder Tool
    ${release}    Get gnb release    host=${gnb_addr}    username=${gnb_username}    password=${gnb_password}
    ${release}    Run keyword if   '${release}'=='TRUNK'      set variable   SBTS00
    ...   ELSE   set variable   ${release}
    ${coam_version}    _Get_gnb_version
    @{version_split}    split string    ${coam_version}    _
    ${coam_version}=   Run Keyword If   "${version_split}[-3]"=="9999"
    ...   Replace String    ${coam_version}    ${version_split}[-5]    SBTS00
    ...   ELSE  Set Variable   ${coam_version}
    Create Directory    /home/ute/Downloads
    Set Suite Variable   ${ttidecoder_path}   ${TEST_LOG_DIRECTORY}ttitrace-${coam_version}
    Run    rm -rf ${TEST_LOG_DIRECTORY}ttitrace-*
    ${version_path_list}    	Get Regexp Matches    ${AF_PATH}   \\d+.\\d+.\\d+
    ${package_download_path}    run keyword if  ${release.count('SBTS')} > 0    Set Variable
    ...   ${package_web_service_SBTS}/${release}/${coam_version}/${coam_version}_tti-dec_qemux86-64-static.txz
    ...   ELSE    Set Variable    ${package_web_service}/${version_path_list[0]}/${coam_version}/${coam_version}_tti-dec_qemux86-64-static.txz
    Log    \n Start to Download Package From WFT!    INFO
    Run   rm -f wget-log*
    Run   wget -b ${package_download_path} -P ${TEST_LOG_DIRECTORY}
    Wait Until Keyword Succeeds   10m   1m   Wait Until wget process done
    ...  ${coam_version}_tti-dec_qemux86-64-static.txz
    OperatingSystem.File Should Exist   ${TEST_LOG_DIRECTORY}${coam_version}_tti-dec_qemux86-64-static.txz
    Log To Console    Download Package Finished!
    Run   mkdir ${ttidecoder_path}
    Run   tar xJvf ${TEST_LOG_DIRECTORY}${coam_version}_tti-dec_qemux86-64-static.txz -C ${ttidecoder_path}
    [Return]   ${ttidecoder_path}

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
#    Run   pyenv local 3.6.8
    ${output}    Run
    ...  cd ${TEST_LOG_DIRECTORY};pip3 install pandas --proxy=http://10.144.1.10:8080
    Should Not Contain any   ${output}    error   fail   Error
    #sleep   5min
    ${output}    Run
    ...  cd ${TEST_LOG_DIRECTORY};python3 ${ttidecoder_path}/tti-dec-bin/TtiTraceDecoder.py ${ttidecoder_path}/tti-dec-bin/${inputfile} excelCsv
    Should Not Contain any   ${output}    error   fail   Error
    #sleep   5min
#    Run   pyenv local 2.7.13
    ${csvfile}    Run    cd ${TEST_LOG_DIRECTORY};ls | grep csv
    @{csvfiles}  	Split String	${csvfile}	 \n
    ${csvfiles_path}    Create List
    FOR   ${csvfile}  IN   @{csvfiles}
        File Should Not Be Empty    ${TEST_LOG_DIRECTORY}/${csvfile}
        Append to list    ${csvfiles_path}     ${TEST_LOG_DIRECTORY}/${csvfile}
    END
    [Return]    @{csvfiles_path}

Check MaxHarqNum
    [Arguments]      ${tti_dire}=ul    ${bear_num}=single    ${num_MO}=1    ${equal}=true
    log to console    Check MaxHarqNum from TTI trace
    #wait until keyword succeeds     2min    1s
    #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...      username=Nemuadmin
    #...      password=nemuuser
    #...      name=COAM
    ${maxDlHarqTxDrb}    Get parameter value    class_name=NRDRB_MAC_A    pattern=maxDlHarqTxDrb    connection=COAM    num_MO=${num_MO}
    ${maxUlHarqTxDrb}    Get parameter value    class_name=NRDRB_MAC_A    pattern=maxUlHarqTxDrb    connection=COAM    num_MO=${num_MO}
    ${target_csv}=    set variable    ${TEST_LOG_DIRECTORY}changed_csv_file.csv
    Create File          	${target_csv}
    ${log_file}=    Run    find ${TEST_LOG_DIRECTORY} -maxdepth 1 -name *${tti_dire}*.csv|tail -n 1
    ${column_filter}=    set variable if    '${tti_dire}'=='ul'    ulFdSchedData.maxHarqTxNum    dlFdSchedData.maxHarqTxNum
    #${buffer_byte}=    set variable if    '${tti_dire}'=='ul'    ulFdSchedData.rrmBufferedDataUlTotal_bytes    dlFdSchedData.maxHarqTxNum
    delete_unexpect_rnti_row    ${log_file}    ${target_csv}    ${column_filter}
    ${maxharqnum}=    get_specified_column_from_csv_file   ${target_csv}    ${column_filter}
    ${maxharqnum}    remove duplicates    ${maxharqnum}
    #${maxharqnum}=    get_specified_column_from_csv_file   /home/ute/casetest/9189/ttiTrace_ul.csv    ulFdSchedData.maxHarqTxNum
    ${maxHarqTxDrb}=    Set Variable If    '${tti_dire}'=='ul'    ${maxUlHarqTxDrb}    ${maxDlHarqTxDrb}
    @{single_maxharqnum}    Create List    ${maxHarqTxDrb}
    ${maxharqnum}=    Evaluate    list(map(float, @{maxharqnum}))
    ${maxharqnum}=    Evaluate    list(map(int, @{maxharqnum}))
    ${single_maxharqnum}=    Evaluate    list(map(int, @{single_maxharqnum}))
    #${maxharqnum}    run keyword if    '${bear_num}'=='single'    Clear TTI csv Column    ${maxharqnum}

    Run Keyword If    '${equal}' == 'true'    should be equal    ${maxharqnum}    ${single_maxharqnum}
    ...    ELSE    should not be equal    ${maxharqnum}    ${single_maxharqnum}
    #[Teardown]     run keyword and ignore error      admin_cli.teardown    connection=COAM

_Get_gnb_version
    [Arguments]   ${host}=${gnb_addr}   ${username}=${gnb_username}   ${password}=${gnb_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${version}   csn.Execute    cd /ffs/run;ls TargetBD*.xml  connection=release_info
    ${version}    Fetch From Right    ${version}    TargetBD_
    ${version}    Fetch From Left    ${version}    .
    [Return]    ${version}
    [Teardown]   csn.Disconnect   connection=release_info

Check Counters
    [Arguments]    ${counter_list}    ${counter_id}=M55306C06001    ${num_count}=${0}    ${counter_path}=BTS/CELLS/NRCELL-2/NMOCU
    #wait until keyword succeeds     2min    1s
    #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...      username=Nemuadmin
    #...      password=nemuuser
    #...      name=COAM
    ${miNrPdcpCellNrpmqap}    Get NIDD parameter value    class_name=NRPMRNL_A    pattern=miNrPdcpCellNrpmqap    connection=COAM
    ${miNrF1UInterfaceCUpmqap}    Get NIDD parameter value    class_name=NRPMRNL_A    pattern=miNrF1UInterfaceCUpmqap    connection=COAM
    ${num_miNrPdcpCellNrpmqap}    Fetch From Left    ${miNrPdcpCellNrpmqap}    min
    ${num_miNrPdcpCellNrpmqap}   Convert To Integer   ${num_miNrPdcpCellNrpmqap}
    ${num_miNrF1UInterfaceCUpmqap}    Fetch From Left    ${miNrF1UInterfaceCUpmqap}    min
    ${num_miNrF1UInterfaceCUpmqap}   Convert To Integer   ${num_miNrF1UInterfaceCUpmqap}
    ${sleep_time}=   Set Variable If    ${num_miNrPdcpCellNrpmqap}>${num_miNrF1UInterfaceCUpmqap}
    ...    ${miNrPdcpCellNrpmqap}    ${miNrF1UInterfaceCUpmqap}
    sleep    ${sleep_time}
    FOR    ${counter_id}    IN    @{counter_list}
        ${sb1_dlcounter} =    Get the Counter value from COAM    counter_id=${counter_id}    timeout=${120}
        ...    dic_path=${counter_list}[${counter_id}]    min_len=${0}
        log to console    ${counter_id}=${sb1_dlcounter}
        should be true    ${sb1_dlcounter} > ${num_count}
    END
   #[Teardown]     run keyword and ignore error      admin_cli.teardown    connection=COAM

Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all    ${min_len}=1    ${timeout}=${120}
    log to console    ${counter_id}    ${dic_path}
    #wait until keyword succeeds     2min    1s
    #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...      username=Nemuadmin
    #...      password=nemuuser
    #...      name=COAM1
    ${counter_value} =    wait until keyword succeeds     10x    30s
    ...    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${dic_path}    date=${date}    timeout=${timeout}
    ${len}    get length    ${counter_value}
    should be true    ${len} > ${min_len}
    [Return]    ${counter_value[0]}
    #[Teardown]     run keyword and ignore error      admin_cli.teardown    connection=COAM1

Modify HBTE Channel Vaules
    [Arguments]    ${value}=63    ${ru_id}=0    ${gnb_id}=0
    ${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
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
    #Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

Adjust PA
    [Arguments]    ${target_cell_PA_value}=0
    ${target_cell}=    Evaluate    ${cell_id}-1
    ${cell_list}    Create List    0    1    2
    Remove From List    ${cell_list}    ${target_cell}
    Modify HBTE Channel Vaules    value=${target_cell_PA_value}    ru_id=${target_cell}    gnb_id=0
    Modify HBTE Channel Vaules    value=60    ru_id=${cell_list[0]}    gnb_id=0
    Modify HBTE Channel Vaules    value=60    ru_id=${cell_list[1]}    gnb_id=0

Precondition
	robot_common_operations.Common Case Setup
    log to console    \n in precondition stage
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=COAM
    ## open 9189-B
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-${cell_id}
    ...    parameter=actServiceAwareConfig    operation=update    value=true    skip_parameter_relation_errors=True    connection=COAM
    ## change cellgroup level maxharq
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRCELLGRP-${cellgroup_id}
    ...    parameter=maxUlHarqTx    operation=update    value=5    skip_parameter_relation_errors=True    connection=COAM
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRCELLGRP-${cellgroup_id}
    ...    parameter=maxDlHarqTx    operation=update    value=5    skip_parameter_relation_errors=True    connection=COAM
    ## adjust PA to make cell1 available
    #Adjust PA
    #[teardown]  admin_cli.teardown    connection=COAM

Start Capture wireshark log
    [Arguments]    ${gnb_index}=0    ${file_name}=${file_name}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIB
    csn.Execute    command=rm -rf /tmp/${file_name}    connection=ASIB
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ASIB
    #Should be empty    ${output}
    ${cmd}=    catenate    tcpdump -i br1 -w /tmp/${file_name} &>/dev/null &
    csn.send command    command=${cmd}    connection=ASIB
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIB
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIB

Stop Capture wireshark log
    [Arguments]    ${enb_index}=0
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIB
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}'    connection=ASIB
    #Should not be empty    ${output}
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'|xargs kill -9    connection=ASIB
    Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIB

Download wireshark Log To TestPC
    [Arguments]    ${enb_index}=0
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIB
    csn.Download file    remote_path=/tmp/${file_name}    local_path=${log_path}/${file_name}   connection=ASIB
    csn.execute    command=rm -rf /tmp/${file_name}     connection=ASIB
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIB

Download BIP Log
    [Arguments]       ${log_path}=${CURDIR}   ${download_type}=Download
    Log To Console    \n ###download bip log to testPC ###
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    download_type=${download_type}
    Set Suite Variable      ${list_log_path_local}
    [Return]    ${list_log_path_local}

Check VoNR Success
    ####Check wireshark log for PDUSessionResourceModifyRequest ok####
    ${all_packets}=    cap.Load Pcap File    pcap_file=${log_path}/${file_name}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.fiveQI==1
    Log To Console    check PDUSessionResourceModifyRequest
    ${filtered_packets}=    cap.Filter Packets By Expression
    ...    filter_expression=${Code26_0}    pcap_parser=test6
    ${5qi}=    cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${5qi[0]}    1
    ####Check wireshark log for PDUSessionResourceModifyResponse ok####
    ${all_packets}=    load_pcap_file    pcap_file=${log_path}/${file_name}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${criticality} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
    Should Be Equal    ${criticality[0]}    0

Make VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    Log To Console    \n ### VoNR Call Steup ###
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

Stop VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

Teardown
	robot_common_operations.Common Case Teardown
    log to console    \n in teardown stage
    Run   rm ${TEST_LOG_DIRECTORY}*.zip; rm ${TEST_LOG_DIRECTORY}*.txz; rm ${TEST_LOG_DIRECTORY}*.csv
    admin_cli.teardown    connection=COAM
    run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
