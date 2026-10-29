*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Madhu
...              :contact: madhusudhan.y@nokia.com


Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       ../../resources/ECEcommon/common_setup_teardown.robot
Resource       ../../resources/NPS/SENG/robot/PacketSearch.robot
Resource       ../../resources/robot/SetupEnv.robot
Library        luashark_tools.analyzer       WITH NAE       analyzer
Library        taf.sbts.oam.coam.admin               WITH NAE   ute_adm
#Library        taf.collectors.core   WITH NAE   CORE
Library        taf.collectors.btslog  WITH NAE   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAE    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAE    csn
Library        ../../resources/python/BIP_Capture.py
Library        ../../resources/python/CPRT_Capture.py
#Library        ./verify_rnti_bwpid.py
Library           XML    use_lxml=True    WITH NAE    Myxml
Library          taf.wts.runner              WITH NAE    wtsrunner
Library          taf.transport.ssh           WITH NAE    taf_ssh
Library          taf.sw.wtssim

*** Variables ***
${BIP_SCRIPT_PATH}      ${CURDIR}/../../resources/NPS/SENG/config/script
${EBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${EBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}


*** Keywords ***
Set fixed cqi for multiple Es
   [Arguments]    ${start_ue_id}    ${end_ue_id}    ${cqi}     ${cqi_min}=1     ${cqi_max}=15
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    wtsrunner.csi_override_testmode_nr		profile_id=1	 cqi=${cqi}     cqi_mode=fixed      cqi_min=${cqi_min}      cqi_max=${cqi_max}
    ...     cqi_step=1 cqi_period=10
    log to console  ${qfi_id}
    log to console  ${rtp_codec}
    log to console  ${cqi_min}
    log to console  ${cqi_max}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        wtsrunner.ue_testmode_set_nr	id=${ue_idx} 	profile_id=1 	action=activate	 testmode=csi_override
   END
Remove varying cqi for multiple Es
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${cqi_min}=1     ${cqi_max}=15
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
	log to console  ${qfi_id}
	log to console  ${rtp_codec}
	log to console  ${cqi_min}
	log to console  ${cqi_max}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        wtsrunner.ue_testmode_set_nr	id=${ue_idx} 	profile_id=1 	action=deactivate	 testmode=csi_override
   END

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init        ${capture_var_cprt}
    Capture start       ${capture_var_cprt}

Set L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture.Modify BIP Script File    ${BIP_SCRIPT_PATH}
    Capture init        ${capture_var_l1l2}
    Capture start       ${capture_var_l1l2}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop        ${capture_var_cprt}

Stop L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture stop        ${capture_var_l1l2}

Start CPRT Trace Capturing
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set suite variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}

Start L2 BIP Trace Capturing
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set suite variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture  ${CaptureL1L2}

Start Collecting Syslog
    [Arguments]    ${NAE}      ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/
    set suite variable      ${CURENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_${NAE}.log
    ta5g_syslog.Start Syslog  log_dir=${CURENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.255.126
    ...       ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAE}
    log to console  ${VM_IP}
Stop Collecting Syslog
    [Arguments]    ${NAE}
    ${file_path}    ta5g_syslog.Collect Syslog Results    alias=${NAE}
    [Return]      ${file_path}

Start Collecting AP Syslog
    [Arguments]    ${NAE}      ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/
    set suite variable      ${CURENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_${NAE}.log
    ta5g_syslog.Start Syslog  log_dir=${CURENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.200.126
    ...       ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAE}
    log to console  ${VM_IP}

Stop Collecting AP Syslog
    [Arguments]    ${NAE}
    ${file_path}    ta5g_syslog.Collect Syslog Results    alias=${NAE}
    [Return]      ${file_path}

Start Btslog Collect
    [Arguments]      ${names}=${NAE}     ${btslog_dir}=/opt/btslog     ${log_dir}=/tmp/btslog2
    log to console     Starting BTS logger
    btslog.create_btslog_collector    name=${names}    btslog_path=${btslog_dir}/btslog
    ...                               btslog_launcher_path=${btslog_dir}/btslog_launcher
    ...                               log_dir=${log_dir}
    core.setup_collectors      names=${names}
    core.start_collectors      names=${names}
    btslog.Set Suite Alias     ${names}

Stop Btslog Collect
    [Timeout]  3 hours
    [Arguments]               ${names}=${NAE}     ${target_dir}=${LOG_PATH}
    log to console     Stopping BTS logger
    run keyword and ignore error      core.stop_collectors    names=${names}
    run keyword and ignore error      core.collect_collectors      names=${names}    target_dir=${target_dir}
    core.teardown_collectors      names=${names}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Full Commission SCF
    [Arguments]    ${scf_file}
    ute_adm.Setup Admin    alias=cOAM
    ute_adm.Perform Commissioning
    ...    bts_id=1
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    ...    alias=cOAM
    Run Keyword And IgnoreError    ute_adm.Teardown Admin    alias=cOAM

Assign lmpAddr to f1Addr
   [Arguments]    ${gnb_index}=0     ${du_index}=0
   ${tl.gnbs[0].dus[0].f1_m_ip_addr}     set variable
   ...      ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}

Start_capture_testcase_default_logging
    ${EST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${EST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${EST_NAME}

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCAE_GNB.oam}
    ${GNB_SW_ERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_ERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_ERSION}     22R1
    Set Suite variable   ${Branch_22R1}

Configure UE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Fetch AMF and Nglink Status
    Get Classical gNB Nglink Status
    Get AMF Local Ip Status

Get Classical gNB Nglink Status
    Connect to DU1
    Check classical gNB Nglink Status
    [Teardown]    Disconnect from DU

Disconnect from DU
    [Arguments]    ${alias}=default
    coam.teardown     connection=${alias}

Check classical gNB Nglink Status
    [Arguments]        ${admin_alias}=default
    coam.collect_scf     target_file_name=FetchNgLinkStatus.xml      export_type=configurationAndRuntimeObjects      connection=default
    @{NgLinkStatus}    Myxml.GetElements Texts    FetchNgLinkStatus.xml    .//p[@name="ngLinkStatus"]
    log     ${NgLinkStatus}   ${admin_alias}

Dump RMOD BBMOD And Cell Status
    Get cgNB RMOD BBMOD And Cell Status

Get cgNB RMOD BBMOD And Cell Status
    Connect to DU1
    Check classical RMOD BBMOD And Cell Status
    [Teardown]    Disconnect from DU

Check classical RMOD BBMOD And Cell Status
    [Arguments]        ${admin_alias}=default
    coam.collect_scf     target_file_name=RuntimeStatus.xml      export_type=runtimeObjects      connection=default
    Get_cGNB_System_Status
    log to console  ${admin_alias}
Connect to DU1
    [Arguments]    ${alias}=default
    ${conn}=    coam.connect_to
#    ...    bts_host=${DU_IP}
    ...    bts_host=192.168.255.129
    ...    username=${EBEM_USERNAME}
    ...    password=${EBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

MultiE Attach And Do Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${dl_tput}      ${ul_tput}
    : FOR    ${ue_id}    IN RANE    1    ${max_ue_num}+1
    \    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    \   Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    \    SA 5G PDU Session Setup multiue       ${ue_id}
    \    Start DL Traffic        ${ue_id}   ${dl_tput}
    \    Start UL Traffic        ${ue_id}   ${ul_tput}
    \    Display average DL and UL data        ${ue_id}

SA 5G PDU Session Setup multiue
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...   Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...   Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}   Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}
Start DL Traffic
    [Arguments]    ${ue_id}     ${dl_tput}
    ${output}        Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=dl trf_id\=1 kbps\=${dl_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRE}
    Log to Console    ${output}
Start UL Traffic
    [Arguments]    ${ue_id}     ${ul_tput}
    ${output}        Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=ul trf_id\=1 kbps\=${ul_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRE}
    Log to Console    ${output}
Display average DL and UL data
    [Arguments]    ${ue_id}
    sleep   10s
    ${out_dl}=    Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=dl
    Create File       ${OUTPUT_DIR}/dl_data1.txt    ${out_dl}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
    ${out_ul}=    Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=ul
    Create File       ${OUTPUT_DIR}/ul_data1.txt    ${out_ul}
    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG UL : ${average_ul}    WARN
    [Return]    ${average_dl}    ${average_ul}
Detach multiple SA Es
    [Arguments]    ${max_ue_num}
    : FOR    ${ue_id}    IN RANE    1    ${max_ue_num}+1
    \        SA 5G Detach       ${ue_id}
