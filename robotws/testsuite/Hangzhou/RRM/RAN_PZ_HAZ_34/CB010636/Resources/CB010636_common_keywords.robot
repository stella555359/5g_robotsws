*** Settings ***
Documentation    author：Xia Wu
...              contact: xia.wu@nokia-sbell.com
...              squad group: mmw_SG_03

Library      ./demo.py
Library      ./CB010636_CDE.py
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001349-AA/Resources/get_pm_counter.py
Library           taf.hw.rf_attenuator    WITH NAME    att
Library           taf.sw.dcap.rd		WITH NAME	DCAP
Library           taf.collectors.btslog		WITH NAME	BtsLog
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables        ./BTS_info.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB006443/Resources/All_KW_Interface.robot
*** Variables ***
${EXP_GAP}               400
${expected_tput_dl_T}    200
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_ports_1}              ${tl.attenuator[0].attenuation_port_numbers[0]}
${att_ports_2}              ${tl.attenuator[0].attenuation_port_numbers[1]}
${att_ports_3}              ${tl.attenuator[0].attenuation_port_numbers[2]}
${att_ports_4}              ${tl.attenuator[0].attenuation_port_numbers[3]}
${att_ports_number}         ${tl.attenuator[0].attenuation_port_numbers[0]}
${att_api_port}             ${tl.attenuator[0].port}
${vendor}                   HBTE
${HBTE_max_value}           ${25}    ##no signal
@{att_value}                0    22    127   ##rank4  no signal

#${fsp_hostnames}    asp-1b             #for 904
${GNB_COAM_ALIAS_1}    GNB_OAM_1
${GNB_COAM_ALIAS_2}    GNB_OAM_2
${DU_OAM_IP_1}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_IP_2}        ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_username}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${bts_password}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${host_addr}     ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}    ${tl.test_pc.default_ssh_connection_details.username}
${host_password}    ${tl.test_pc.default_ssh_connection_details.password}
@{selenium_gnb_login}
${btsid_1}      ${tl.gnbs[0].instance_id}
${btsid_2}      ${tl.gnbs[1].instance_id}
${alias_1}    929
${alias_2}    915
&{bts_1}      host=${bts_host_1}    username=Nemuadmin    password=nemuuser    port=443
&{bts_2}     host=${bts_host_2}    username=Nemuadmin    password=nemuuser    port=443
${bts_host_1}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_host_2}    ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${UE_TYPE}          ${tl.ues[0].capabilities[-1]}
${data_tranfer}     500Mbits/sec
${ul_duration}     20
${dl_duration}     20
${dltp}     5
${ultp}     2
${SA_UE_MODE}    SA
${SA_attach_mode}    5G_SA
${SA_nettype}    SA+NSA
${apn_addr}    mdrbnokiacom
${TS_CASE_LOG_PATH}    /home/ute/logs
${DCAP_host}    10.57.195.91
${DCAP_port}     443
#${DCAP_user}      ${None}
#${DCAP_password}      ${None}
${DCAP_user}         utfuser
${DCAP_password}      utfadmin!
${TEST_LOG_DIRECTORY}       /home/ute/logs
#${AF_PATH}    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_0000_240327_000004_release_BTSSM_downloadable_A54.zip
*** Keywords ***
###Common setup####
CB010636_Common Suite Setup for COAM
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    CB010636_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId
    Delete CSV file in UTE
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup

CB010636_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown

CB010636_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     admin_cli.get_sw_version    connection=${GNB_COAM_ALIAS}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

CB010636_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    CB007859_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${GNB_COAM_ALIAS}

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}
    ...      file_name=${scf_name}    connection=${GNB_COAM_ALIAS}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    [Arguments]  ${connection}
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${connection}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Case Setup
    Log To Console    \n *** Case Setup
    ${result1}=    Run    rm -rf ${TEST_LOG_DIRECTORY}/; mkdir ${TEST_LOG_DIRECTORY}/;
    #csn.Connect To     hostname=10.71.218.129    username=mn5gran    password=nokia123@    alias=btspc
    #csn.send command    command=rm -rf C:/TEMP/Logs/*    connection=btspc
    #Set BTSlog collect to true
    Run Keyword And Ignore Error    robot_common_operations.Common case setup    allowed_faults_ids=62003


Connect to DU via ssl
    [Arguments]  ${connection}=${GNB_COAM_ALIAS_1}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    admin_cli.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Case Teardown
    Log To Console    \n *** Case Teardown
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

Site Reset
    [Documentation]    Reset both gNB sites and wait for them to come back online
    Log To Console    \n *** Site Reset for 2 gNB
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_1}    bts_host=${DU_OAM_IP_1}
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_2}    bts_host=${DU_OAM_IP_2}
    Log To Console    Resetting gNB 1...
    admin_cli.Reset Site    connection=${GNB_COAM_ALIAS_1}
    Log To Console    Resetting gNB 2...
    admin_cli.Reset Site    connection=${GNB_COAM_ALIAS_2}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_1}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_2}
    Log To Console    Waiting for sites to complete reset...
    Sleep    180s
    Sleep    30s

Reset BB Module For 2 gNB
    [Documentation]    Reset BB modules for both gNBs serially (multiple BB modules per gNB, ~2min per module)
    Log To Console    \n *** Reset BB Module for 2 gNB (Serial Reset)

    # Reset BB modules for gNB 1 serially
    Log To Console    Getting BB module list for gNB 1...
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_1}    bts_host=${DU_OAM_IP_1}
    ${bbmod_info_list_1}=    admin_cli.get_fbb_info    connection=${GNB_COAM_ALIAS_1}
    ${bbmod_count_1}=    Get Length    ${bbmod_info_list_1}
    Log To Console    Found ${bbmod_count_1} BB modules on gNB 1, resetting serially...
    FOR    ${bbmod_info}    IN    @{bbmod_info_list_1}
        ${bbmod_distname}=    Set Variable    ${bbmod_info['id']['internal']}
        Log To Console    Resetting ${bbmod_distname} on gNB 1...
        admin_cli.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=True
        ...    timeout=300    connection=${GNB_COAM_ALIAS_1}
        Log To Console    Waiting 2 minutes for ${bbmod_distname} to complete reset...
        Sleep    2min
    END
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_1}

    # Reset BB modules for gNB 2 serially
    Log To Console    Getting BB module list for gNB 2...
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_2}    bts_host=${DU_OAM_IP_2}
    ${bbmod_info_list_2}=    admin_cli.get_fbb_info    connection=${GNB_COAM_ALIAS_2}
    ${bbmod_count_2}=    Get Length    ${bbmod_info_list_2}
    Log To Console    Found ${bbmod_count_2} BB modules on gNB 2, resetting serially...
    FOR    ${bbmod_info}    IN    @{bbmod_info_list_2}
        ${bbmod_distname}=    Set Variable    ${bbmod_info['id']['internal']}
        Log To Console    Resetting ${bbmod_distname} on gNB 2...
        admin_cli.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=True
        ...    timeout=300    connection=${GNB_COAM_ALIAS_2}
        Log To Console    Waiting 2 minutes for ${bbmod_distname} to complete reset...
        Sleep    2min
    END
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_2}

    Log To Console    All BB modules have been reset serially

Check cell onair for 2 gNB
    Log To Console    \n *** Check cell onair for 2 gNB
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_1}    bts_host=${DU_OAM_IP_1}
    Wait until keyword succeeds    1min    10s     Check If BTS Is OnAir    connection=${GNB_COAM_ALIAS_1}
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_2}    bts_host=${DU_OAM_IP_2}
    Wait until keyword succeeds    1min    10s     Check If BTS Is OnAir    connection=${GNB_COAM_ALIAS_2}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_1}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_2}

####PM Counter#######
Wait Until PM Counter Update
    log to console    wait for pm counter update
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Enable Counter collect
    Log    \nEnable Counter collect    console=yes
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_1}    bts_host=${DU_OAM_IP_1}
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_2}    bts_host=${DU_OAM_IP_2}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${btsid_1}/MNL-1/MNLENT-1/PMCADM-1
    ...    parameter=reportingIntervalPm
    ...    value=5min
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS_1}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${btsid_2}/MNL-1/MNLENT-1/PMCADM-1
    ...    parameter=reportingIntervalPm
    ...    value=5min
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS_2}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_1}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_2}

Check MAC PM counter
    [Arguments]    ${counter_id}    ${full_path}    ${connection}      ${bts_host}
    Connect to DU via ssl    connection=${connection}    bts_host=${bts_host}
    ${counter_result} =    get_pm_counter_values    counter_id=${counter_id}    connection=${connection}
    ...    dic_path=${full_path}    date=all
    ${counter_value}    Convert To Integer    ${counter_result[-1]}
    [Return]    ${counter_value}

#-------------------------------TTI----------------------------#

Start DCAP Collection
    [Arguments]    ${timeout}=${1200}
    log to console    connect to DCAP
    Connect To DCAP
    Make gnb On DCAP Server    bts_mr_id=${btsid_1}    alias=${alias_1}
    Make gnb On DCAP Server    bts_mr_id=${btsid_2}    alias=${alias_2}
    log to console    Start DCAP Collection
    ${bts}=     Create List     ${bts_1}    ${bts_2}
    ${trace_type}=     Create List     L2Lo_Component    cp_5g
    Capture Log From DCAP    log_tye=${trace_type}    bts=${bts}    timeout=${timeout}
    ${result_id}    Get Dictionary Values    ${output}
    set suite variable    ${result_id}
    Run Keyword and Ignore Error    log to console    Start DCAP START_TRACE_ID is ${result_id}
    sleep    10s

Download DCAP files
    log to console    Get the result from DCAP
    Log to console      \nStopping DCAP trace ID ${result_id} and collecting logs
    DCAP.stop_trace    trace_id=${result_id}[0]
    ${downloaded_tti_file_path}    wait until keyword succeeds    20 times    1min
    ...    DCAP.get_results    result_id=${result_id}[0]    target_dir=${TEST_LOG_DIRECTORY}
    log to console     Extract files
    Extract Specific File From DCAP Log    original_file_path=${downloaded_tti_file_path}

Connect To DCAP
    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=${DCAP_user}
    ...     password=${DCAP_password}     rd_version=dcapv3    secure=True

Capture Log From DCAP
    [Arguments]  ${log_tye}   ${bts}   ${timeout}
    #${gnb_custom_profile}=     Create List     ${log_tye}
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${log_tye}     wait_for_activation=${True}
    ...     duration=${timeout}
    set test variable    &{output}

Make gnb On DCAP Server
    [Arguments]    ${bts_mr_id}    ${alias}
    ${bts_info}    DCAP.get_all_bts_info
    ${bts_info_length}    get length    ${bts_info}
    FOR    ${index}    IN RANGE    ${bts_info_length}
        ${is_bts_exist}    set variable if    ${bts_info[${index}]['mr_bts_id']} == ${bts_mr_id}    true    false
        Exit For Loop If    '${is_bts_exist}'=='true'
    END
    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts    host=${bts_host_1}    bts_alias=${alias}
    ...    ELSE    log to console    msg=the specific bts is exist
    run keyword if    '${is_bts_exist}' != 'true'    DCAP.create_bts    host=${bts_host_2}    bts_alias=${alias}
    ...    ELSE    log to console    msg=the specific bts is exist

_Get_gnb_version
    [Arguments]   ${host}=${bts_host_1}   ${username}=${bts_username}   ${password}=${bts_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${version}   csn.Execute    cd /ffs/run;ls TargetBD*.xml  connection=release_info
    ${version}    Fetch From Right    ${version}    TargetBD_
    ${version}    Fetch From Left    ${version}    .
    [Return]    ${version}
    [Teardown]   csn.Disconnect   connection=release_info

Extract Specific File From DCAP Log
    [Arguments]  ${original_file_path}
    ${dcap_tmp_log_path}    Catenate    mkdir ${TEST_LOG_DIRECTORY}/dcap_log; mkdir ${TEST_LOG_DIRECTORY}/${DU_OAM_IP_1};
     ...    mkdir ${TEST_LOG_DIRECTORY}/${DU_OAM_IP_2}
    ${unzip_file}    Catenate    unzip ${original_file_path} -d ${TEST_LOG_DIRECTORY}/dcap_log
    ${specific_file}    Catenate
    ...     find ${TEST_LOG_DIRECTORY}/dcap_log -name "*L2_COMPONENT.pcap" -o -name "*controlPlane5g*.5gm"|xargs cp -t ${TEST_LOG_DIRECTORY}
    ${result}=    Run    ${dcap_tmp_log_path};${unzip_file};${specific_file}
    ${log_file}=    Run    find ${TEST_LOG_DIRECTORY} -maxdepth 1 -name *.pcap
    ${TEST_P}      set variable    ${TEST_LOG_DIRECTORY}
    ${log_file_pcell}=    Run
    ...      find ${TEST_P}/dcap_log -name *${DU_OAM_IP_1}*.pcap -o -name "*${DU_OAM_IP_1}*.5gm"|xargs mv -t ${TEST_LOG_DIRECTORY}/${DU_OAM_IP_1}
    ${log_file_scell}=    Run
    ...      find ${TEST_P}/dcap_log -name *${DU_OAM_IP_2}*.pcap -o -name "*${DU_OAM_IP_2}*.5gm"|xargs mv -t ${TEST_LOG_DIRECTORY}/${DU_OAM_IP_2}
    set suite variable    ${pcell_file}    ${TEST_LOG_DIRECTORY}/${DU_OAM_IP_1}
    set suite variable    ${scell_file}    ${TEST_LOG_DIRECTORY}/${DU_OAM_IP_2}
    [Return]    ${pcell_file}     ${scell_file}

Decode Log File And Convet File Format
    ${ttidecoder_path}    Download TTI Decoder Tool
    ${target_csvs_pcell}    TTI Decoder Run Pcap to CSV     inputfile_path=${pcell_file}    ttidecoder_path=${ttidecoder_path}
    ${target_csvs_scell}    TTI Decoder Run Pcap to CSV     inputfile_path=${scell_file}     ttidecoder_path=${ttidecoder_path}
    Set Test Variable    ${target_csvs_pcell}
    Set Test Variable    ${target_csvs_scell}
    [Return]   ${target_csvs_pcell}     ${target_csvs_scell}

Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   Run   cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}

Download TTI Decoder Tool
    [Arguments]
    ${release}    Get gnb release    host=${bts_host_1}    username=${bts_username}    password=${bts_password}
    ${release}    Run keyword if   '${release}'=='TRUNK'      set variable   SBTS00
    ...   ELSE   set variable   ${release}
    ${coam_version}    _Get_gnb_version
    #${coam_version}    run keyword if   ${coam_version.count('24R3')} > 0    Replace String   ${coam_version}    24R3    00
    #...   ELSE       Set Variable    ${coam_version}
    ${coam_version_remove}    Fetch From Left     ${coam_version}     _
    ${coam_version_part}      Replace String      ${coam_version}     ${coam_version_remove}     ${release}
    ${coam_version}      Set Variable       ${coam_version_part}
    BuiltIn.Log To Console      TTI decode tool SW version is ${coam_version}
    Create Directory    /home/ute/Downloads
    Set Suite Variable   ${ttidecoder_path}   ${TEST_LOG_DIRECTORY}/ttitrace-${coam_version}
    Run    rm -rf ${TEST_LOG_DIRECTORY}/ttitrace-*
    ${version_path_list}    	Get Regexp Matches    ${AF_PATH}   \\d+.\\d+.\\d+
    ${package_download_path}    run keyword if  ${release.count('SBTS')} > 0    Set Variable
    ...   ${package_web_service_SBTS}/${release}/${coam_version}/${coam_version}_tti-dec.deb
    ...   ELSE    Set Variable    ${package_web_service}/${version_path_list[0]}/${coam_version}/${coam_version}_tti-dec.deb
    Log    \n Start to Download Package From WFT!    INFO
    Run   rm -f wget-log*
    Run   wget -b ${package_download_path} -P ${TEST_LOG_DIRECTORY}
    Wait Until Keyword Succeeds   10m   1m   Wait Until wget process done
    ...  ${coam_version}_tti-dec.deb
    OperatingSystem.File Should Exist   ${TEST_LOG_DIRECTORY}/${coam_version}_tti-dec.deb
    Log To Console    Download Package Finished!
    Run   mkdir ${ttidecoder_path}
    Run   export https_proxy="http://87.254.212.120:8080/"; sudo dpkg -i ${TEST_LOG_DIRECTORY}/${coam_version}_tti-dec.deb
    [Return]   ${ttidecoder_path}

TTI Decoder Run Pcap to CSV
    [Arguments]    ${inputfile_path}    ${ttidecoder_path}
    ${output}    Run
    ...  cd ${TEST_LOG_DIRECTORY};pip3 install pandas --proxy=http://10.144.1.10:8080
    ${log_file_percell}    OperatingSystem.List Files In Directory    ${inputfile_path}    *.pcap
    ${i}    set variable    ${1}
    FOR    ${item}    IN     @{log_file_percell}
        Run    source /opt/tti-dec/venv/bin/activate
        ${output}    Run
        ...  python3 /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py ${inputfile_path}/${item} legacyCsv -o TTI${i}
        Set Test Variable    ${i}    ${${i}+1}
    END
    log to console   ${ttidecoder_path} is not used
    [Return]   ${log_file_percell}

Get Maclength from TTI data
    Log To Console    Get Maclength from TTI data
    [Arguments]    ${inputfile_path}    ${phycellid}
    @{result_list}    create list
    ${csvfile}=    Run    find ${inputfile_path} -name MacSubPduTxAm18.csv
    @{csvfiles}  	Split String	${csvfile}	 \n
    ${csv_data_dict}    getDLCsvCouterSum    ${csvfiles}
    FOR    ${lcid}    IN RANGE    ${5}    ${8}
        ${macLength}    Run keyword and ignore error    getMacLengthByPhysCellIdAndLcId    ${csv_data_dict}    ${phycellid}    ${lcid}
        Append To List    ${result_list}    ${macLength}[-1]
    END
    [Return]   ${result_list}

Get Pcell Maclength from TTI data
    Log To Console    Get Pcell Maclength from TTI data
    ${pcell_result_list}    Get Maclength from TTI data    inputfile_path=${pcell_file}    phycellid=${577}
    ${pcell577_lcid5}    Evaluate    int(${pcell_result_list}[0])
    ${pcell577_lcid6}    Evaluate    int(${pcell_result_list}[1])
    ${pcell577_lcid7}    Evaluate    int(${pcell_result_list}[2])
    Set Suite Variable    ${pcell577_lcid5}
    Set Suite Variable    ${pcell577_lcid6}
    Set Suite Variable    ${pcell577_lcid7}
    log to console    Pcell lcid5/lcid6/lcid7 maclength is ${pcell577_lcid5}/${pcell577_lcid6}/${pcell577_lcid7}

Get Scell1 Maclength from TTI data
    Log To Console    Get Scell1 Maclength from TTI data
    ${scell1_result_list}    Get Maclength from TTI data    inputfile_path=${scell_file}    phycellid=${574}
    ${scell574_lcid5}    Evaluate    int(${scell1_result_list}[0])
    ${scell574_lcid6}    Evaluate    int(${scell1_result_list}[1])
    ${scell574_lcid7}    Evaluate    int(${scell1_result_list}[2])
    Set Suite Variable    ${scell574_lcid5}
    Set Suite Variable    ${scell574_lcid6}
    Set Suite Variable    ${scell574_lcid7}
    log to console    Scell-1 lcid5/lcid6/lcid7 maclength is ${scell574_lcid5}/${scell574_lcid6}/${scell574_lcid7}

Get Scell2 Maclength from TTI data
    Log To Console    Get Scell2 Maclength from TTI data
    ${scell2_result_list}    Get Maclength from TTI data    inputfile_path=${scell_file}    phycellid=${575}
    ${scell575_lcid5}    Evaluate    int(${scell2_result_list}[0])
    ${scell575_lcid6}    Evaluate    int(${scell2_result_list}[1])
    ${scell575_lcid7}    Evaluate    int(${scell2_result_list}[2])
    Set Suite Variable    ${scell575_lcid5}
    Set Suite Variable    ${scell575_lcid6}
    Set Suite Variable    ${scell575_lcid7}
    log to console    Scell-2 lcid5/lcid6/lcid7 maclength is ${scell575_lcid5}/${scell575_lcid6}/${scell575_lcid7}

Get Scell3 Maclength from TTI data
    Log To Console    Get Scell3 Maclength from TTI data
    ${scell3_result_list}    Get Maclength from TTI data    inputfile_path=${scell_file}    phycellid=${576}
    ${scell576_lcid5}    Evaluate    int(${scell3_result_list}[0])
    ${scell576_lcid6}    Evaluate    int(${scell3_result_list}[1])
    ${scell576_lcid7}    Evaluate    int(${scell3_result_list}[2])
    Set Suite Variable    ${scell576_lcid5}
    Set Suite Variable    ${scell576_lcid6}
    Set Suite Variable    ${scell576_lcid7}
    log to console    Scell-3 lcid5/lcid6/lcid7 maclength is ${scell576_lcid5}/${scell576_lcid6}/${scell576_lcid7}


Get Maclength from TTI data for all cell
    [Documentation]     Check CB010636-A
    ${MacSub_TTI_CSV_merged}    CB010636_CDE.merge_csv_list_of_dicts    file_path=${TEST_LOG_DIRECTORY}
    ...      file_name=MacSubPduTxAm18.csv
    ${csv_data_dict}    getDLCsvCouterSum    ${MacSub_TTI_CSV_merged}
    @{channel_id_list}    Create List
    ${PCI_counter_value_dict}    Create Dictionary
    FOR    ${pmqap_id}     IN      @{pmqap_channnel_info.keys()}
        ${channel_id}    set Variable    ${pmqap_channnel_info['${pmqap_id}']}
        Append To List  ${channel_id_list}   ${channel_id}
        Set Suite Variable       ${channel_id_list}
    END
    FOR    ${PCI}     IN      @{cell_info.keys()}
        Log to console     Check CB010636_A
        ${DRB_counter_value_dict}       Get Maclength from TTI data for one cell
        ...      ${csv_data_dict}      ${PCI}      ${channel_id_list}
        Set To Dictionary    ${PCI_counter_value_dict}    ${PCI}    ${DRB_counter_value_dict}
        Set Suite Variable       ${PCI_counter_value_dict}
    END

Get Maclength from TTI data for one cell
     [Arguments]    ${csv_data_dict}      ${PCI}      ${channel_id_list}
     ${DRB_counter_value_dict}    Create Dictionary
     FOR    ${channel_id}     IN      ${channel_id_list}
         ${macLength}    getMacLengthByPhysCellIdAndLcId    ${csv_data_dict}    ${PCI}    ${channel_id}
         Set To Dictionary         ${DRB_counter_value_dict}    ${channel_id}    ${macLength}
         Set Suite Variable       ${DRB_counter_value_dict}
     END

######UE Operation########################

Attach UE and Verify Status
    log to console       UE attach
    [Arguments]    ${attach_mode}
    log to console       Prepare ue 1
    Run keyword and ignore error     power_ue.Prepare UE    ue_type=huawei_sigspark
    ...    get_spark_license=${True}    power_reset=true
    log to console       Attach ue 1
    ${cur_timestamp}    Get current time from GNB
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei_sigspark   attach_mode=${attach_mode}
    ...    pci=${577}    power_reset=true
    log to console       UE attach verify
    sleep   5s
    power_ue.Verify attach    ue_type=huawei_sigspark    5Grach_ed=${5Grach_ed}    4G_check=False
    [Return]   ${cur_timestamp}

Start DL and UL Traffic
    log to console       Start Traffic
    [Arguments]    ${ue_index}    ${ue_mode}   ${apn_address}   ${call_duration}=60
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        ...   throughput=${data_tranfer}    duration=${call_duration}   ue_type=${UE_TYPE}    ue_mode=${ue_mode}
        ...   apn_address=mdrbnokiacom
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        ...   throughput=${data_tranfer}    duration=${call_duration}   ue_type=${UE_TYPE}    ue_mode=${ue_mode}
        ...   iperf_port=40000    apn_address=mdrbnokiacom
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        ...   throughput=${data_tranfer}    duration=${call_duration}   ue_type=${UE_TYPE}    ue_mode=${ue_mode}
        ...   iperf_port=40001    apn_address=mdrbnokiacom
    sleep    63s


Check 4CC DLUL tput
    log to console       Check 4CC DLUL tput
    #[Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    @{Pcell_DL_TP}    create list
    @{Scell1_DL_TP}    create list
    @{Scell2_DL_TP}    create list
    @{Scell3_DL_TP}    create list
    run    mkdir ${TEST_LOG_DIRECTORY}/btslogs
    ${btslogs}    Set Variable    ${TEST_LOG_DIRECTORY}/btslogs
    ${result2}=    Run    sshpass -p 'nokia123@' scp mn5gran@10.71.218.129:C:/TEMP/Logs/* ${btslogs}/.
    Sleep    100s
    ${btsfile}=    OperatingSystem.List Files In Directory    ${btslogs}    SYSLOG_*.LOG
    FOR    ${item}    IN    @{btsfile}
        getTputFromVduSyslog        log_path=${btslogs}/${item}
        ${tbs_cell0}    Get DL TBS    tpfile=${btslogs}/output.txt    cellid=0
        Append To List    ${Pcell_DL_TP}    ${tbs_cell0}
        ${tbs_cell1}    Get DL TBS    tpfile=${btslogs}/output.txt    cellid=1
        Append To List    ${Scell1_DL_TP}    ${tbs_cell1}
        ${tbs_cell2}    Get DL TBS    tpfile=${btslogs}/output.txt    cellid=2
        Append To List    ${Scell2_DL_TP}    ${tbs_cell2}
        ${tbs_cell3}    Get DL TBS    tpfile=${btslogs}/output.txt    cellid=3
        Append To List    ${Scell3_DL_TP}    ${tbs_cell3}
    END
    ${Pcell_sum}    Set Variable    0
    FOR    ${item}    IN    @{Pcell_DL_TP}
        ${Pcell_sum}    Evaluate    ${Pcell_sum} + ${item}
    END
    ${Pcell_average}    Evaluate    ${Pcell_sum} / len(set(${Pcell_DL_TP}))
    Should Be True   ${Pcell_average}>=${expected_tput_dl_T}
    ${Scell1_sum}    Set Variable    0
    FOR    ${item}    IN    @{Scell1_DL_TP}
        ${Scell1_sum}    Evaluate    ${Scell1_sum} + ${item}
    END
    ${Scell1_average}    Evaluate    ${Scell1_sum} / len(set(${Scell1_DL_TP}))
    Should Be True   ${Scell1_average}>=${expected_tput_dl_T}
    ${Scell2_sum}    Set Variable    0
    FOR    ${item}    IN    @{Scell2_DL_TP}
        ${Scell2_sum}    Evaluate    ${Scell2_sum} + ${item}
    END
    ${Scell2_average}    Evaluate    ${Scell2_sum} / len(set(${Scell2_DL_TP}))
    Should Be True   ${Scell2_average}>=${expected_tput_dl_T}
    ${Scell3_sum}    Set Variable    0
    FOR    ${item}    IN    @{Scell3_DL_TP}
        ${Scell3_sum}    Evaluate    ${Scell3_sum} + ${item}
    END
    ${Scell3_average}    Evaluate    ${Scell3_sum} / len(set(${Scell3_DL_TP}))
    Should Be True   ${Scell3_average}>=${expected_tput_dl_T}
    log to console       Pcell TP is ${Pcell_average},Scell1 TP is ${Scell2_sum},Scell2 TP is ${Scell2_average},Scell3 TP is ${Scell3_average}

Get DL TBS
    [Arguments]    ${tpfile}    ${cellid}
    ${output}    Run    cat ${tpfile} | grep NRCELL-${cellid}
    ${tbs}    Set Variable    ${output.split()}[1]
    [Return]    ${tbs}

stop traffic
    [Arguments]    ${ue_mode}   ${apn_address}
    log to console     Stop traffic    console = yes
    Run keyword and ignore error     power_ue.Stop traffic    direction=dl    ue_index=${1}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}

UE Detach
    log to console      UE Detach    console = yes
    Run keyword and ignore error     power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${1}

###########start check TP#######################
Set BTSlog collect to ${value}
    Log    \nSet BTSlog collect    console=yes
    #csn.Connect To     hostname=10.71.218.129    username=mn5gran    password=nokia123@    alias=btspc
    #csn.send command    command=rm -rf C:/TEMP/Logs/*    connection=btspc
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_1}    bts_host=${DU_OAM_IP_1}
    Connect to DU via ssl    connection=${GNB_COAM_ALIAS_2}    bts_host=${DU_OAM_IP_2}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${btsid_1}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actRemoteSyslogTransmission
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS_1}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${btsid_2}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actRemoteSyslogTransmission
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS_2}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_1}
    admin_cli.teardown    connection=${GNB_COAM_ALIAS_2}

####PM Counter Related######################3
Get All Counter Values List
    [Arguments]    ${counter_list}    ${connection}    ${host}

    ${counter_ids}    Evaluate    ','.join(${counter_list})
    Connect to DU via ssl    connection=${connection}    bts_host=${host}
    ${counter_dict}     admin_cli.Get Pm Counters    ${counter_ids}    timeout=5min    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    [Return]    ${counter_dict}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}


Get PM Counter From Dictionary
    [Arguments]    ${counter_dict}    ${bts_id}    ${cell_id}    ${MO_name}    ${counter_ids_list}    ${timestamp_list}
    #${counter_id_value_dict}    Create Dictionary
    #Set Suite Variable    ${counter_id_value_dict}
    #${counter_value_dict_NRPMQAP}    Create Dictionary
    #Set Suite Variable    ${counter_value_dict_NRPMQAP}
    ${counter_value_dict_tmp}    Create Dictionary
    Set Suite Variable    ${counter_value_dict_tmp}
    ${mo_list}    Split String    ${MO_name}    /
    Log to console     ${counter_dict}
	${counter_dict_tmp}    Set Variable    ${counter_dict['BTS']['MRBTS-${bts_id}']['NRBTS-${bts_id}']['NRCELL-${cell_id}']}
    FOR    ${node}    IN    @{mo_list}
        ${counter_dict}    Get From Dictionary    ${counter_dict_tmp}    ${node}
    END
    FOR    ${counter_id}    IN    @{counter_ids_list}
        ${counter_id_value_dict}    Get PM Counter Based On Timestamp    ${counter_id}     ${counter_dict}
         ...    ${timestamp_list}    ${MO_name}
        Set Suite Variable      ${counter_id_value_dict}
    END
    [Return]    ${counter_id_value_dict}

Get PM Counter Based On Timestamp
    [Arguments]    ${counter_id}    ${counter_dict}    ${timestamp_list}    ${MO_name}
        ${counter_value}    set variable    ${0}
        ${is_matched}    RUN KEYWORD AND RETURN STATUS     Should Contain    ${MO_name}    NRPMQAP
        ${NRPMQAP_name}    Run Keyword If    ${is_matched}    Fetch From Left     ${MO_name}    /
        FOR    ${time}    IN    @{timestamp_list}
            ${counter_value_dict}    Get From Dictionary    ${counter_dict}    ${counter_id}
            #${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
            #log to console    time ${time} pmcounter is ${counter_value_dict['${time}']}
            ${counter_value}     Evaluate    ${counter_value}+${counter_value_dict['${time}']}
            Set Suite Variable      ${counter_value}
        END
        Set To Dictionary    ${counter_value_dict_tmp}    ${counter_id}     ${counter_value}
        Run Keyword If    ${is_matched}
        ...        Set To Dictionary         ${counter_value_dict_NRPMQAP}    ${NRPMQAP_name}    ${counter_value_dict_tmp}
        ${counter_id_value_dict}    Run Keyword If    ${is_matched}      Copy Dictionary          ${counter_value_dict_NRPMQAP}
        ...         ELSE    Copy Dictionary          ${counter_value_dict_tmp}
        Set Suite Variable    ${counter_id_value_dict}
        Set Suite Variable    ${counter_value_dict_NRPMQAP}
        #Run Keyword If    ${is_matched}    log to console     counter_value_dict_NRPMQAP is ${counter_value_dict_NRPMQAP}
    [Return]    ${counter_id_value_dict}

Get Multi Cells Multi PM Counters
    [Arguments]    ${counter_info_list}    ${counter_dict}    ${timestamp_list}
    [Documentation]    This keyword is to get the latest counter value for multi cell multi same pm counters.
    ...                    Setup admin once in this keyword.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | YES | a list for counter info, the element should be include cell_id, MO_name and counter_ids_list |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | &{counter_info_1} |  | cell_id=1 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_2} |  | cell_id=2 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_3} |  | cell_id=3 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | @{counter_info_list} |  | ${counter_info_1} | ${counter_info_2} | ${counter_info_3} |
    ...    | ${counter_value_dict} | Get Multi Cells Multi PM Counters | ${counter_info_list} |
    ...    | Should be True | ${counter_value_dict.Cell1.M55136C00001}>1

    ${counter_value_dict}    Create Dictionary
    ${counter_id_value_dict}    Create Dictionary
    ${counter_value_dict_NRPMQAP}    Create Dictionary
    Set Suite Variable    ${counter_value_dict_NRPMQAP}
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${counter_id_value_dict}    Get PM Counter From Dictionary    ${counter_dict}
        ...    ${counter_info.bts_id}    ${counter_info.cell_id}
        ...    ${counter_info.MO_name}    ${counter_info.counter_ids_list}
        ...    ${timestamp_list}
        Set To Dictionary    ${counter_value_dict}    ${counter_info.PCI}    ${counter_id_value_dict}
    END
    [Return]    ${counter_value_dict}

Check PM Counter M55310C02021
    Log to console     Check PM Counter M55310C02021
    Log to console     PCI 577 M55310C02021:${rlcl_counter_dict_577['577']['M55310C02021']}
    Log to console     TTI:${pcell577_lcid7}
    Log to console     PCI 574 M55310C02021:${rlcl_counter_dict_scell['574']['M55310C02021']}
    Log to console     PCI 575 M55310C02021:${rlcl_counter_dict_scell['575']['M55310C02021']}
    Log to console     PCI 576 M55310C02021:${rlcl_counter_dict_scell['576']['M55310C02021']}
    ${gap_M55310C02021}    Evaluate    abs(${pcell577_lcid7}-${rlcl_counter_dict_577['577']['M55310C02021']})
    Run Keyword And Continue On Failure    Should Be True    ${gap_M55310C02021} <= ${exp_gap}
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['574']['M55310C02021']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['575']['M55310C02021']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['576']['M55310C02021']}==0

Check PM Counter M55310C02022
    Log to console     Check PM Counter M55310C02022
    Log to console     PCI 577 M55310C02022:${rlcl_counter_dict_577['577']['M55310C02022']}
    ${TTI_result}      Evaluate     ${pcell577_lcid5}+${pcell577_lcid6}
    Log to console     PCI 577 TTI: ${TTI_result}
    Log to console     PCI 574 M55310C02022:${rlcl_counter_dict_scell['574']['M55310C02022']}
    Log to console     PCI 575 M55310C02022:${rlcl_counter_dict_scell['575']['M55310C02022']}
    Log to console     PCI 576 M55310C02022:${rlcl_counter_dict_scell['576']['M55310C02022']}
    ${gap_M55310C02022}    Evaluate    abs(${TTI_result}-${rlcl_counter_dict_577['577']['M55310C02022']})
    Run Keyword And Continue On Failure    Should Be True     ${gap_M55310C02022} <= ${exp_gap}
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['574']['M55310C02022']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['575']['M55310C02022']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['576']['M55310C02022']}==0

Check PM Counter M55310C02024
    Log to console     Check PM Counter M55310C02024
    Log to console     PCI 577 M55310C02024:${rlcl_counter_dict_577['577']['M55310C02024']}
    Log to console     PCI 574 M55310C02024:${rlcl_counter_dict_scell['574']['M55310C02024']}
    ${TTI1_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}
    Log to console     PCI 574 TTI: ${TTI1_result}
    Log to console     PCI 575 M55310C02024:${rlcl_counter_dict_scell['575']['M55310C02024']}
    ${TTI2_result}     Evaluate     ${scell575_lcid5}+${scell575_lcid6}
    Log to console     PCI 575 TTI: ${TTI2_result}
    Log to console     PCI 576 M55310C02024:${rlcl_counter_dict_scell['576']['M55310C02024']}
    ${TTI3_result}     Evaluate     ${scell576_lcid5}+${scell576_lcid6}
    Log to console     PCI 576 TTI: ${TTI3_result}
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_577['577']['M55310C02024']}==0
    ${gap1_M55310C02024}    Evaluate    abs(${TTI1_result}-${rlcl_counter_dict_scell['574']['M55310C02024']})
    Run Keyword And Continue On Failure    Should Be True     ${gap1_M55310C02024} <= ${exp_gap}
    ${gap2_M55310C02024}    Evaluate    abs(${TTI2_result}-${rlcl_counter_dict_scell['575']['M55310C02024']})
    Run Keyword And Continue On Failure    Should Be True     ${gap2_M55310C02024} <= ${exp_gap}
    ${gap3_M55310C02024}    Evaluate    abs(${TTI3_result}-${rlcl_counter_dict_scell['576']['M55310C02024']})
    Run Keyword And Continue On Failure    Should Be True     ${gap3_M55310C02024} <= ${exp_gap}

Check PM Counter M55310C20001
    Log to console     Check PM Counter M55310C20001
    Log to console     PCI 577 M55310C20001:${rlcl_counter_dict_577['577']['M55310C20001']}
    ${TTI_result}      Evaluate     ${pcell577_lcid5}+${pcell577_lcid6}
    Log to console     PCI 577 TTI: ${TTI_result}
    Log to console     PCI 574 M55310C20001:${rlcl_counter_dict_scell['574']['M55310C20001']}
    Log to console     PCI 575 M55310C20001:${rlcl_counter_dict_scell['575']['M55310C20001']}
    Log to console     PCI 576 M55310C20001:${rlcl_counter_dict_scell['576']['M55310C20001']}
    ${gap_M55310C20001}    Evaluate    abs(${TTI_result}-${rlcl_counter_dict_577['577']['M55310C20001']})
    Run Keyword And Continue On Failure    Should Be True     ${gap_M55310C20001} <= ${exp_gap}
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['574']['M55310C20001']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['575']['M55310C20001']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['576']['M55310C20001']}==0

Check PM Counter M55310C20000
    Log to console     Check PM Counter M55310C20000
    Log to console     PCI 577 M55310C20000:${rlcl_counter_dict_577['577']['M55310C20000']}
    Log to console     PCI 574 M55310C20000:${rlcl_counter_dict_scell['574']['M55310C20000']}
    ${TTI1_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}
    Log to console     PCI 574 TTI: ${TTI1_result}
    Log to console     PCI 575 M55310C20000:${rlcl_counter_dict_scell['575']['M55310C20000']}
    ${TTI2_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}
    Log to console     PCI 575 TTI: ${TTI2_result}
    Log to console     PCI 576 M55310C20000:${rlcl_counter_dict_scell['576']['M55310C20000']}
    ${TTI3_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}
    Log to console     PCI 576 TTI: ${TTI3_result}
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_577['577']['M55310C20000']}==0
    ${gap1_M55310C20000}    Evaluate    abs(${TTI1_result}-${rlcl_counter_dict_scell['574']['M55310C20000']})
    Run Keyword And Continue On Failure    Should Be True     ${gap1_M55310C20000} <= ${exp_gap}
    ${gap2_M55310C20000}    Evaluate    abs(${TTI2_result}-${rlcl_counter_dict_scell['575']['M55310C20000']})
    Run Keyword And Continue On Failure    Should Be True     ${gap2_M55310C20000} <= ${exp_gap}
    ${gap3_M55310C20000}    Evaluate    abs(${TTI3_result}-${rlcl_counter_dict_scell['576']['M55310C20000']})
    Run Keyword And Continue On Failure    Should Be True     ${gap3_M55310C20000} <= ${exp_gap}

Check PM Counter M55310C01022
    Log to console     Check PM Counter M55310C01022
    Log to console     PCI 577 M55310C01022:${rlcl_counter_dict_577['577']['M55310C01022']}
    ${TTI_result}      Evaluate     ${pcell577_lcid5}+${pcell577_lcid6}
    Log to console     PCI 577 TTI: ${TTI_result}
    Log to console     PCI 574 M55310C01022:${rlcl_counter_dict_scell['574']['M55310C01022']}
    Log to console     PCI 575 M55310C01022:${rlcl_counter_dict_scell['575']['M55310C01022']}
    Log to console     PCI 576 M55310C01022:${rlcl_counter_dict_scell['576']['M55310C01022']}
    ${gap_M55310C01022}    Evaluate    abs(${TTI_result}-${rlcl_counter_dict_577['577']['M55310C01022']})
    Run Keyword And Continue On Failure    Should Be True     ${gap_M55310C01022} <= ${exp_gap}
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['574']['M55310C01022']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['575']['M55310C01022']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_scell['576']['M55310C01022']}==0

Check PM Counter M55310C01021
    Log to console     Check PM Counter M55310C01021
    Log to console     PCI 577 M55310C01021:${rlcl_counter_dict_577['577']['M55310C01021']}
    Log to console     PCI 574 M55310C01021:${rlcl_counter_dict_scell['574']['M55310C01021']}
    ${TTI1_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}
    Log to console     PCI 574 TTI: ${TTI1_result}
    Log to console     PCI 575 M55310C01021:${rlcl_counter_dict_scell['575']['M55310C01021']}
    ${TTI2_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}
    Log to console     PCI 574 TTI: ${TTI2_result}
    Log to console     PCI 576 M55310C01021:${rlcl_counter_dict_scell['576']['M55310C01021']}
    ${TTI3_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}
    Log to console     PCI 574 TTI: ${TTI3_result}
    Run Keyword And Continue On Failure    Should Be True     ${rlcl_counter_dict_577['577']['M55310C01021']}==0
    ${gap1_M55310C01021}    Evaluate    abs(${TTI1_result}-${rlcl_counter_dict_scell['574']['M55310C01021']})
    Run Keyword And Continue On Failure    Should Be True     ${gap1_M55310C01021} <= ${exp_gap}
    ${gap2_M55310C01021}    Evaluate    abs(${TTI2_result}-${rlcl_counter_dict_scell['575']['M55310C01021']})
    Run Keyword And Continue On Failure    Should Be True     ${gap2_M55310C01021} <= ${exp_gap}
    ${gap3_M55310C01021}    Evaluate    abs(${TTI3_result}-${rlcl_counter_dict_scell['576']['M55310C01021']})
    Run Keyword And Continue On Failure    Should Be True     ${gap3_M55310C01021} <= ${exp_gap}

Check PM Counter M55349C00022
    Log to console     Check PM Counter M55349C00022
    Log to console     PCI 577 M55349C00022:${rlch_counter_dict_577['577']['M55349C00022']}
    ${TTI_result}      Evaluate     ${pcell577_lcid5}+${pcell577_lcid6}
    Log to console     PCI 577 TTI: ${TTI_result}
    Log to console     PCI 574 M55349C00022:${rlch_counter_dict_scell['574']['M55349C00022']}
    Log to console     PCI 575 M55349C00022:${rlch_counter_dict_scell['575']['M55349C00022']}
    Log to console     PCI 576 M55349C00022:${rlch_counter_dict_scell['576']['M55349C00022']}
    ${gap_M55349C00022}    Evaluate    abs(${TTI_result}-${rlcl_counter_dict_577['577']['M55349C00022']})
    Run Keyword And Continue On Failure    Should Be True     ${gap_M55349C00022} <= ${exp_gap}
    Run Keyword And Continue On Failure    Should Be True     ${rlch_counter_dict_scell['574']['M55349C00022']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlch_counter_dict_scell['575']['M55349C00022']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlch_counter_dict_scell['576']['M55349C00022']}==0

Check PM Counter M55349C00023
    Log to console     Check PM Counter M55349C00023
    Log to console     PCI 577 M55349C00023:${rlch_counter_dict_577['577']['M55349C00023']}
    ${TTI_result}     Evaluate     ${scell574_lcid5}+${scell574_lcid6}+${scell575_lcid5}+${pcell575_lcid6}+${scell576_lcid5}+${scell576_lcid6}
    Log to console     PCI 575 TTI: ${TTI_result}
    Log to console     PCI 574 M55349C00023:${rlch_counter_dict_scell['574']['M55349C00023']}
    Log to console     PCI 575 M55349C00023:${rlch_counter_dict_scell['575']['M55349C00023']}
    Log to console     PCI 576 M55349C00023:${rlch_counter_dict_scell['576']['M55349C00023']}
    ${gap_M55349C00023}    Evaluate    abs(${TTI_result}-${rlcl_counter_dict_577['577']['M55349C00023']})
    Run Keyword And Continue On Failure    Should Be True     ${gap_M55349C00023} <= ${exp_gap}
    Run Keyword And Continue On Failure    Should Be True     ${rlch_counter_dict_scell['574']['M55349C00023']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlch_counter_dict_scell['575']['M55349C00023']}==0
    Run Keyword And Continue On Failure    Should Be True     ${rlch_counter_dict_scell['576']['M55349C00023']}==0

Check PM Counter M55310C02022 And M55310C20001 AND M55310C01022 Should Equal
    Log to console     Check PM Counter M55310C02022 And M55310C20001 AND M55310C01022 Should Equal
    Should Be True   ${counter_M55310C02022}==${counter_M55310C20001}==${counter_M55310C01022}

Check PM Counter M55349C00022 For Pcell
    Log to console     Check PM Counter M55349C00022 For Pcell
    ${counter_M55349C00022_for_scell_1}    Check MAC PM counter    counter_id=${M55349_counter_id}[0]
    ...    full_path=${M55349_PATH_Pcell}    bts_host=${DU_OAM_IP_1}    connection=${GNB_COAM_ALIAS_1}

Check PM Counter M55349C00022 AND M55349C00023 Should Equal
    Log to console     Check PM Counter M55349C00022 AND M55349C00023 Should Equal
    Should Be True   ${counter_M55349C00022}==${counter_M55349C00023}

Check PM Counter M55349C00022 Should Equal Sum of M55310C02024 For Scells
    Log to console     Check PM Counter M55349C00022 Should Equal Sum of M55310C02024 For Scells
    Should Be True   ${counter_M55349C00022}==${counter_M55310C02024_1}+${counter_M55310C02024_2}+${counter_M55310C02024_3}

Check CB010636-A Counter
    Run keyword and ignore error    Get Pcell Maclength from TTI data
    Run keyword and ignore error    Get Scell1 Maclength from TTI data
    Run keyword and ignore error    Get Scell2 Maclength from TTI data
    Run keyword and ignore error    Get Scell3 Maclength from TTI data
    ${result}    Run keyword and ignore error     Check PM Counter M55310C02021
    Log to console     ${result}
    ${result}    Run keyword and ignore error      Check PM Counter M55310C02022
    Log to console     ${result}
    ${result}    Run keyword and ignore error    Check PM Counter M55310C02024
    Log to console     ${result}
    ${result}    Run keyword and ignore error    Check PM Counter M55310C20001
    Log to console     ${result}
    ${result}    Run keyword and ignore error    Check PM Counter M55310C20000
    Log to console     ${result}
    ${result}    Run keyword and ignore error    Check PM Counter M55310C01022
    Log to console     ${result}
    ${result}    Run keyword and ignore error    Check PM Counter M55310C01021
    Log to console     ${result}
    ${result}    Run keyword and ignore error    Check PM Counter M55349C00022
    Log to console     ${result}
    ${result}    Run keyword and ignore error    Check PM Counter M55349C00023
    Log to console     ${result}
