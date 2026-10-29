*** Settings ***
Documentation    :copyright: Nokia
...              :authors: XXX
...              :contact: XXX
Variables    ta5g_global_var

Resource       CB008225_basic_keywords.robot
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../../resources/robot/common_log_collection.robot
Resource        ../../resources/ECEcommon/common_setup_teardown.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Resource         ../../resources/robot/TTI_Traces.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library          String
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
#Library           XML    use_lxml=True    WITH NAME    Myxml
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ./python/CplaneOverloadSetter.py
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library         ta5g_cell_operations
Library         taf.analyzer.pcap    WITH NAME    parser
Library    		taf.ccs.aashell   WITH NAME    cli
Library        taf.ul.hanging_resources

*** Variables ***

@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ngap}		ngap.RAN_UE_NGAP_ID
${e1ap}		e1ap.GNB_CU_CP_UE_E1AP_ID
${f1ap}		f1ap.GNB_DU_UE_F1AP_ID
${pcode}	f1ap.procedureCode

@{bearerstatus}       0       1
@{srb_identity}       1       2       1      2
@{ngbr_drb_identity}       4       4
@{gbr_drb_identity}       4       5       4       5

*** Keywords ***
Perform CPLANE OVL activation via R&D mechanism
    Set Overload High Threshold to 0
    Sleep  10

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}
    log to console      ${timeout}
Modify NIDD parameters
    [Documentation]      This Keyword modify NIDD parameter as per the requirement of the feature
    [Arguments]      ${paramName}='None'      ${paramValue}='None'       ${operation}=update      ${paramDst}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramName=${paramName}         paramValue=${paramValue}        operation=${operation}
    ...                             paramDst=${paramDst}
    sleep               60s
    [Teardown]          admin.Teardown admin

Configure UTE ETH3 IPs
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

Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner and collect SIB1 output     ${wts_cfg_file}
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup
    set suite variable    ${cell_sys_log}

Get MCShark Version
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${sw_version}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    ${list_version}    Split String    ${sw_version}    _
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
    ...    SBTS00_${rest}      ${sw_version}
    ${list_version}    Split String    ${new_version}    _
    ${rest}    ${last}    Split String From Right    ${new_version}    _    1
    ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${new_version}
    [Return]    ${latest_version}

Download MCShark To UTE
    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
    set suite variable     ${wireshark_version}
    ${sw_version}    Get MCShark Version
    ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}    Run    find /home/ute/ -name mcshark-3.6*buster.so
    ${is_present}  Run   ls /home/ute/.local/lib/wireshark/plugins/3.6/epan/mcshark-${wireshark_version}*buster.so
    set suite variable     ${MCShark}
    ${is_MCShark_exist}    Run keyword and return status    Should contain    ${is_present}    No such file or directory
    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
    ...  ELSE         log to console    version allready present

Download MCShark If Have
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/
    log to console    download mcshark successfully to UTE

############################## CB008225 Keywrd ######################################

Sleep till inactivity timer expiry
    Log to Console          Wait ${inactivity_timer}s for UE to move inactive state
	Set Suite Variable      ${inactivity_timer}
    sleep   ${inactivity_timer}s
    sleep   ${delta}s       #add extra delta

Start WTS Using WTS_Runner and collect SIB1 output
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    ${sib1_output}      wtsrunner.read_wtsemu_output_until_re    expected=SystemInformationBlockType3-NR updated    timeout=200
    Set Suite Variable     ${sib1_output}
    sleep    60s
    Log to Console    Cell onair successful
    [Return]    ${sib1_output}

Read EgateLog RRCInactive_IE from SIB1
    [Arguments]      ${output}
    Log to Console    Verifying SIB1 content from Egate log
    Create File	    ${OUTPUT_DIR}/sib1.txt	    ${output}
    ${useFullResumeID}=    Run     cat ${OUTPUT_DIR}/sib1.txt |grep -i useFullResumeID |awk '{print $2}'
    Should Contain    ${useFullResumeID}   true
    ${ranac}=    Run     cat ${OUTPUT_DIR}/sib1.txt |grep -i ranac |awk '{print $2}'|sed 's/,//g'
    Should Not Be Empty     ${ranac}
    Log to Console    useFullResumeID:${useFullResumeID} ranac:${ranac}

Verify RRCInactive_IE from SIB1
    [Arguments]    ${file}
    Log to Console       Verifies the SIB1 IE captured in CPRT logs
    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    f1ap.GNBDUConfigurationUpdate_element

    ${useFullResumeID}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc
    ...                                                path=.*useFullResumeID$
    ...                                                endPacket=${1}
    ${ranac}      analyzer.get_unique           pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc
    ...                                                path=.*ranac$
    ...                                                endPacket=${1}

    Should Contain    ${useFullResumeID}   0
    Should Not Be Empty     ${ranac}
    Log to Console    useFullResumeID:${useFullResumeID} ranac:${ranac}

Stop MultiUE Data Traffic for SA with timestamp
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${qos_profile}      ${state}=${EMPTY}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    ${data_stop_time}        Create Dictionary
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	IF  '${state[${ue_idx}]}' == 'active'       Continue For loop
    Log to Console    \nStopping Data Traffic...
    ${idx}     Set Variable    ${qos_profile[${ue_idx}]}
    ${output}      ${time}        Stop Data Traffic QFIwise        ${ue_idx}       qfi_id=${idx}
    ...        pdu=${Pdu_session_ID}      trfid=${TRF_ID}
    Set To Dictionary       ${data_stop_time}     ${ue_idx}      ${time[${2}]}
    Log to Console    ${output}
    sleep   1s
	END
	[Return]    ${data_stop_time}
    log to console      ${state}
    log to console      ${qos_profile}
Stop Data Traffic QFIwise
    [Arguments]      ${ue_idx}       ${qfi_id}     ${pdu}=${Pdu_session_ID}      ${trfid}=${TRF_ID}
    ${idx}=     Set Variable    ${2}
    FOR     ${Q_id}   IN    @{qfi_id}
    ${t_idx}=       Set Variable If      '${Q_id}' == '1'   ${Q_id}     ${idx}
    wtsrunner.trf_data_stop     ue=${ue_idx}  pdu=${pdu}   qfi=${t_idx}   trf_id=${trfid}
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Stopped*    timeout=10
    ${output1}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    ${time}         Get Lines Matching Regexp    ${output}     UPF-1: Stop       partial_match=${TRUE}
    ${time}    Split String      ${time}      ${SPACE}
    END
	[Return]      ${output1}   ${time}

Check MultiUE UE State Display
    [Arguments]     ${start_ue_id}    ${end_ue_id}		${state}=${EMPTY}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=opc_key    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    ${state[${ue_idx}]}    partial_match=${TRUE}
    Log to Console    ${output}
    Should Contain    ${output}   ${state[${ue_idx}]}
    Log to Console    UE: ${ue_idx} moved to ${state[${ue_idx}]} state
    END
    log to console      ${state}
MultiUE Trigger CN Paging
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword Trigger AMF Paging
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    Paging attempt UE:${ue_idx}
    wtsrunner.amf_paging_param   id=1   default_drx=128    max_paging_retries=1
    wtsrunner.amf_paging_start   id=1   ueid=${ue_idx}
    Log to Console    Reading Paging-Message
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=setup/reestablishment complete      timeout=30
    ${output1}         Get Lines Matching Pattern    ${output}    *reestablishment complete     partial_match=${TRUE}
    Log to Console    UE:${ue_idx} ${output1}
#    ${output1}      wtsrunner.read_wtsemu_output_until    expected=rrcSetupRequest    timeout=10
    ${output2}         Get Lines Matching Regexp    ${output}    5G-S-TMSI =    partial_match=${TRUE}
    Log to Console    ${output2}
	END

Check MultiUE RRC State
    [Arguments]    ${start_ue_id}   ${end_ue_id}        ${state}=${EMPTY}
    [Documentation]    This keyword Check MultiUE RRC State from Egate
    ${full_rnti_list}     Create List
    ${inactivity_stop_time}       Create Dictionary
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	IF  '${state[${ue_idx}]}' == 'active'       Continue For loop
    Log to Console    Getting UE:${ue_idx} state
    ${full_rnti}      ${time}   Run Keyword If  '${state[${ue_idx}]}' == 'inactive'
    ...     Check MultiUE RRC State Inactive      ${ue_idx}
    Set To Dictionary       ${inactivity_stop_time}     ${ue_idx}      ${time[${2}]}
    Append To List	  ${full_rnti_list}	    ${full_rnti}
    Run Keyword If  '${state[${ue_idx}]}' == 'idle'
    ...      Check MultiUE RRC State Idle         ${ue_idx}
	END
    [Return]    ${full_rnti_list}      ${inactivity_stop_time}
    log to console      ${state}
Check MultiUE RRC State Inactive
    [Arguments]    ${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UE${ue_idx}: Is INACTIVE     timeout=200
    ${output1}         Get Lines Matching Regexp    ${output}    UE${ue_idx}: Is INACTIVE    partial_match=${TRUE}
    Create File	    ${OUTPUT_DIR}/inactive${ue_idx}.txt	    ${output}
    ${time}    Split String      ${output1}      ${SPACE}
    ${rnti}         Get Lines Matching Regexp    ${output}    UE${ue_idx}: fullI_RNTI    partial_match=${TRUE}
    ${temp_rnti}=    Split String    ${rnti}      [
    ${value}=    Split String    ${temp_rnti[${1}]}    ]
    ${full_rnti}      Set Variable      ${value[${0}]}
    Log to Console    UE ${ue_idx} ${output1} ${rnti}
    [Return]    ${full_rnti}     ${time}

Check MultiUE RRC State Idle
    [Arguments]    ${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=IS IDLE      timeout=400
    ${output1}         Get Lines Matching Regexp    ${output}    IS IDLE    partial_match=${TRUE}
    Create File	    ${OUTPUT_DIR}/inactive${ue_idx}.txt	    ${output}
    Log to Console    UE ${ue_idx} ${output1}

Set Core Network Assistance info
    [Arguments]    ${ue_idx}
    Log to Console     Setting Core Network Assistance Info
    wtsrunner.amf_ue_ics_param       id=1         ue=${ue_idx}
    ...     trace_activation=on    trace_plmn=311:489     trace_ref_id=1     trace_rec_session_ref_id=1
    ...     trace_depth=minimum     ifaces_to_trace=NG-C     tce_ip=10.0.1.1
    ...     core_network_assistance_info=on     ue_identity_index_value=1     ue_specific_drx=64
    ...     periodic_registration_update_timer=1:1min       plmn_id=311:489     tac_id=200
#    ${output}=      Read WTS Output For Pattern And Print matching Lines    supported    ${Timeout_SA}
#    Log to Console    ${output}

MultiUE Register should be Successful with CNAI
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}       ${cnai}=${EMPTY}
	...		${subscriber_trace}=False
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Run Keyword If  '${cnai[${ue_idx}]}' == 'on'       Set Core Network Assistance info    ${ue_idx}
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
	Run Keyword if		'${subscriber_trace}'=='True'			Start Subscriber Trace
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}=  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${bearer_list}       Create List
    Create File     ${OUTPUT_DIR}/bearer.txt        ${output}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List     ${bearer_list}        ${bearer_id}
    Set To Dictionary   ${ue_to_bearer_list}    ${ue_idx}       ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}         ${ue_to_bearer_list}

MultiUE Register should be Successful with CNAI Multi Slice
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}       ${cnai}=${EMPTY}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Run Keyword If  '${cnai[${ue_idx}]}' == 'on'       Set Core Network Assistance info    ${ue_idx}
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=1    trf_type=internal
#    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${slice_id}     Get From Dictionary         ${nw_id}       ${ue_idx}
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${ue_idx}    nwslice=${slice_id}    gw=${ue_idx}
    ${output}=  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${bearer_list}       Create List
    Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List	   ${bearer_list}        ${bearer_id}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}         ${ue_to_bearer_list}

Trigger RRC Resume
    [Arguments]     ${start_ue_id}       ${end_ue_id}       ${state}        ${trigger}      ${qos}=ngbr
    ${cause_list}     Create Dictionary
    FOR     ${id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    IF  '${state[${id}]}' == 'active' or '${state[${id}]}' == 'idle'       Continue For loop
    Log to Console          UE ${id} triggered ${trigger[${id}]}
    Run Keyword If  '${trigger[${id}]}' == 'dldata_ranpaging'        Trigger DL Data       ue_idx=${id}         qos=${qos[${id}]}
    Run Keyword If  '${trigger[${id}]}' == 'dlnas_ranpaging'         Trigger DL AMF Signalling       ue_idx=${id}
    Run Keyword If  '${trigger[${id}]}' == 'uldata'                  Trigger UL Data       ue_idx=${id}
    Run Keyword If  '${trigger[${id}]}' == 'ulnas'                   Trigger UL NAS Signalling       ue_idx=${id}
    Run Keyword If  '${trigger[${id}]}' == 'emergency'               Trigger Emergency       ue_idx=${id}
    ${cause}        Set Variable If     '${trigger[${id}]}' == 'emergency'          0
    ...         '${trigger[${id}]}' == 'ulnas'          3
    ...         '${trigger[${id}]}' == 'uldata'          4
    ...         '${trigger[${id}]}' == 'dlnas_ranpaging'          2
    ...         '${trigger[${id}]}' == 'dldata_ranpaging'          2
    Set To Dictionary       ${cause_list}     ${id}      ${cause}
    END
    [Return]        ${cause_list}
    log to console      ${state}
Trigger UL NAS Signalling
    [Arguments]        ${ue_idx}
    wtsrunner.ue_nr_rrc_resume_request_param      id=${ue_idx}         cause=mo_Signalling
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=2    trf_type=internal
    wtsrunner.ue_pdu_session_setup     ue=${ue_idx}      pdu=2       nwslice=1      gw=1
    ${output}   Read WTS Output For Pattern And Print matching Lines      UE-${ue_idx}.*\nPDU SESSION ID-2 setup/reestablishment complete*.
    ...         ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    .*UE${ue_idx}: UE performed resume procedure*.
    Print Matching Lines from Output File    ${output}    .*Setup QosFlow with QFI:1 5QI:6*.
    wtsrunner.trf_data_start     ue=${ue_idx}     pdu=2   qfi=1    dir=dl    trf_id=1     mbps=10
    ${output1}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: Started Downlink Internal traffic*.       ${Timeout_SA}
    wtsrunner.trf_data_start     ue=${ue_idx}     pdu=2   qfi=1    dir=ul    trf_id=1     mbps=10
    ${output2}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: Started Uplink Internal*.       ${Timeout_SA}
    Log to Console          UE ${ue_idx} Resume Successful

Trigger UL Data
    [Arguments]        ${ue_idx}
    wtsrunner.ue_nr_rrc_resume_request_param         id=${ue_idx}         cause=mo_Data
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=1    trf_type=internal       trf_profile_ul=1
    wtsrunner.ue_nr_rrc_resume        id=${ue_idx}
    ${output}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: UE performed resume procedure*.     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    .*UE${ue_idx}: Started Uplink Internal*.
    Log to Console          UE ${ue_idx} Resume Successful
    sleep   5s
    wtsrunner.trf_data_stop     ue=${ue_idx}  pdu=1
    ${output1}   wtsrunner.read_wtsemu_output_until_re     expected=Stopping Uplink Internal*    timeout=10
    wtsrunner.bearer_stats_clear     ue=${ue_idx}  pdu=1

Trigger DL Data
    [Arguments]        ${ue_idx}        ${qos}=ngbr
    wtsrunner.ue_nr_rrc_resume_request_param         id=${ue_idx}         cause=mt_Access
    Run Keyword If  '${qos}' == 'gbr'
    ...     wtsrunner.trf_data_start     ue=${ue_idx}     pdu=1   qfi=2    dir=dl    trf_id=1     mbps=10
    ...   ELSE         wtsrunner.trf_data_start     ue=${ue_idx}     pdu=1   qfi=1    dir=dl    trf_id=1     mbps=10
    ${output}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: Started Downlink Internal traffic*.    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    .*UE${ue_idx}: UE performed resume procedure*.
    Log to Console          UE ${ue_idx} Resume Successful with DL data for ${qos} DRB
    sleep   5s
    wtsrunner.trf_data_stop     ue=${ue_idx}  pdu=1
    ${output1}   wtsrunner.read_wtsemu_output_until_re     expected=Stopped*    timeout=10
    wtsrunner.bearer_stats_clear     ue=${ue_idx}  pdu=1

Trigger DL AMF Signalling
    [Arguments]        ${ue_idx}
    wtsrunner.ue_nr_rrc_resume_request_param         id=${ue_idx}         cause=mt_Access
    wtsrunner.ue_pdu_session_modify       ue=${ue_idx}      pdu=1       qosflows_to_add=5      by=amf
    ${output}   Read WTS Output For Pattern And Print matching Lines      .*Added QosFlow with QFI:2 fiveQI:3*.     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    .*UE${ue_idx}: UE performed resume procedure*.
    Print Matching Lines from Output File    ${output}       .*UE${ue_idx}: Ue ${ue_idx} PduId 1 Created FiveQi:Qfi mapping fiveQi 3 qfi 2*.
    wtsrunner.trf_data_start     ue=${ue_idx}     pdu=1   qfi=2    dir=dl    trf_id=1     mbps=10
    ${output1}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: Started Downlink Internal traffic*.     ${Timeout_SA}
    wtsrunner.trf_data_start     ue=${ue_idx}     pdu=1   qfi=2    dir=ul    trf_id=1     mbps=10
    ${output2}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: Started Uplink Internal*.       ${Timeout_SA}
    Log to Console          UE ${ue_idx} Resume Successful

Trigger Emergency
    [Arguments]        ${ue_idx}
    wtsrunner.amf_param             release_old_ue_context=on         id=${ue_idx}
    wtsrunner.ue_nr_rrc_resume_request_param         id=${ue_idx}         cause=emergency
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=1    trf_type=internal     trf_profile_ul=1
    wtsrunner.ue_nr_rrc_resume        id=${ue_idx}
    ${output}   Read WTS Output For Pattern And Print matching Lines      UE-${ue_idx}.*\nPDU SESSION ID-1 setup/reestablishment complete*.
    ...        ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    .*PDU SESSION ID-1 setup/reestablishment complete*.
    Print Matching Lines from Output File    ${output}    .*Setup QosFlow with QFI:*.
    Log to Console          UE ${ue_idx} Fallback Successful

Trigger_ue_nr_rrc_resume
	[Arguments]        ${ue_idx}
	wtsrunner.ue_nr_rrc_resume        id=${ue_idx}
    ${output}   Read WTS Output For Pattern And Print matching Lines      .*resume*.     ${Timeout_SA}
    Log to Console          UE ${ue_idx}

Trigger Fallback
	[Arguments]     ${start_ue_id}       ${end_ue_id}       ${cause}        ${action}
	${cause_list}     Create Dictionary
    FOR     ${id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	wtsrunner.amf_param             release_old_ue_context=on         id=${id}
	Set_action_rrc_resume_request		${id}		${cause}	${action[${id}]}
    Comment		Set cause as 8, for rna_update
	Set To Dictionary       ${cause_list}     ${id}      8
	END
	[Return]	${cause_list}

Set_action_rrc_resume_request
	[Arguments]        ${ue_idx}	${cause}	${action}
	wtsrunner.ue_nr_rrc_resume_request_param         id=${ue_idx}         cause=${cause}		action=${action}
#	wtsrunner.ue_nr_rrc_resume        id=${ue_idx}
#    ${output}   Read WTS Output For Pattern And Print matching Lines      UE-${ue_idx}.*\nPDU SESSION ID-1 setup/reestablishment complete*.
#    ...      ${Timeout_SA}

############################## CB008225 Verification Keywrd ######################################
Fetch filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None        ${filterName}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterName}        filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Get UE_ID
    [Arguments]     ${curr_list}
    ${dict}     Create Dictionary
    ${x}        Set Variable        ${0}
    FOR	    ${idx}   IN RANGE    1	  ${ue_count}+1
    ${curr_id}=    Split String    ${curr_list[${x}]}     :
    ${id}=    Remove String    ${curr_id}[${1}]    ${SPACE}
    Set To Dictionary       ${dict}     ${idx}      ${id}
    ${x}=     Evaluate    ${x}+${1}
    END
    [Return]    ${dict}

Get Modified Full_I_RNTI value
    [Arguments]    ${curr_list}         ${idx}
    ${temp_id}=    Split String    ${curr_list[${0}]}     [
    ${temp_id}=    Split String    ${temp_id[${0}]}      :
    ${fullrnti_dec}=    Remove String    ${temp_id[${1}]}    ${SPACE}
    ${fullrnti_hex}=    Convert To Integer        0x${fullrnti_dec}
    ${fullrnti_hex}=    Convert To String        ${fullrnti_hex}
    [Return]    ${fullrnti_dec}         ${fullrnti_hex}
    log to console      ${idx}
Set UE Assistance info and Verify UE state
    [Arguments]    ${start_ue_id}       ${end_ue_id}      ${uai_state}         ${state}=${EMPTY}
    ${full_rnti_list}     Create List
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#   IF  '${state[${ue_idx}]}' == 'active'       Continue For loop
    Log to Console    Getting UE:${ue_idx} state
    wtsrunner.ue_assistance_send_nr       ue_id=${ue_idx}       PreferredRRCState=${uai_state}
    ${output}=      wtsrunner.read_wtsemu_output_until_re   expected=.*UE${ue_idx}: Is INACTIVE.*      timeout=20
    ${output1}         Get Lines Matching Regexp    ${output}    preferredRRC-State-r16   partial_match=${TRUE}
    Log to Console    ${ue_idx}: ${output1}
    ${output2}         Get Lines Matching Regexp    ${output}    UE${ue_idx}: Is*    partial_match=${TRUE}
    Log to Console    ${output2}
    ${full-rnti}         Get Lines Matching Regexp    ${output}    UE${ue_idx}: fullI_RNTI    partial_match=${TRUE}
    ${temp_rnti}=    Split String    ${full-rnti}      [
    ${value}=    Split String    ${temp_rnti[${1}]}    ]
    Append to list       ${full_rnti_list}      ${value[${0}]}
    Log to Console    ${full-rnti}
    Should Contain         ${output1}     ${uai_state}
    Should Contain         ${output2}     INACTIVE
    END
    [Return]    ${full_rnti_list}
    log to console      ${state}

Verify Inactivity Timer
    [Arguments]     ${start_ue_id}       ${end_ue_id}            ${state}
    ...        ${inactivity_start}         ${inactivity_stop}        ${delta}        ${inactivity_timer}
    FOR     ${id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    IF  '${state[${id}]}' == 'active' or '${state[${id}]}' == 'idle'       Continue For loop
    ${inactivity_timer_cal}     Get Time Difference       ${id}     ${inactivity_start}         ${inactivity_stop}        ${delta}
    ${result}         Evaluate    (${inactivity_timer} + 1.0) >= ${inactivity_timer_cal} >= (${inactivity_timer} - 1.0)
    Should Be True    ${result}    msg=UE ${id} RRC Inactivity Timer ${inactivity_timer_cal} sec Verification failed
    Log to Console          UE ${id} RRC Inactivity Timer ${inactivity_timer_cal} sec Verified
    END
    [Return]    ${inactivity_timer_cal}
    log to console      ${state}
    log to console      ${delta}
Get Time Difference
    [Arguments]    ${id}      ${ue_time1}       ${ue_time2}           ${delta}
    ${time1}   Replace String    ${ue_time1[${id}]}     '        ${EMPTY}
    ${time2}   Replace String    ${ue_time2[${id}]}     '        ${EMPTY}
    log to console  ${time1} ${time2}
    ${diff}    DateTime.Subtract Time From Time    ${time2}       ${time1}
#    ${timer}     Evaluate    int(${diff})
    [Return]     ${diff}
    log to console      ${delta}
Check SIB-NR updated
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=SystemInformationBlockType1-NR updated     timeout=200
    ${output1}         Get Lines Matching Regexp    ${output}    SystemInformationBlockType1-NR updated    partial_match=${TRUE}
    Log to Console    ${output1}

Fetch UE ID from pcap
    [Arguments]       ${pcap_file}        ${filter_exp}        ${IE_path}
    ${packet}        set variable                  ${filter_exp}
    ${pdmlFile}=   Fetch filtered PDML file from pcap       ${pcap_file}         ${packet}       filterName=${packet}
    Log to Console       Fetch ${IE_path} from pcap logs
    ${UE_ID}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=${IE_path}
    ...                                                endPacket=-${1}
    Should Not Be Empty         ${UE_ID}
    ${UE_ID_list}       Get UE_ID      ${UE_ID}
    Log to Console      ${UE_ID_list}
    [Return]    ${UE_ID_list}

Fetch RAN_CU_DU UE ID from pcap
    [Arguments]         ${pcap_file}        ${split}
    ${RAN_UE_ID_list}       Fetch UE ID from pcap      ${pcap_file}	     ngap.InitialUEMessage_element		ngap.RAN_UE_NGAP_ID
    Set Test Variable        ${ID1}      ${RAN_UE_ID_list}
    ${Before_Resume_UE_ID_list}       Fetch UE ID from pcap      ${pcap_file}	     nr-rrc.rrcSetupRequest_element		f1ap.GNB_DU_UE_F1AP_ID
    Set Test Variable        ${ID2}      ${Before_Resume_UE_ID_list}
    Run Keyword If  '${split}' != 'C' and '${split}' != 'B'       Fetch Resume ID         ${pcap_file}
    log to console      ${split}
Fetch Resume ID
    [Arguments]         ${pcap_file}
    ${After_Resume_UE_ID_list}        Fetch UE ID from pcap      ${pcap_file}	     nr-rrc.rrcResumeRequest1_element		f1ap.GNB_DU_UE_F1AP_ID
    Set Test Variable        ${ID3}       ${After_Resume_UE_ID_list}

Verify MultiUE Cplane messages from pcap
    [Arguments]         ${pcap_file}     ${start_ue_id}      ${end_ue_id}        ${qos_profile}        ${full_rnti_list}
    ...       ${state}           ${split}=B           ${cause_list}=${EMPTY}        ${activityNotify}=uE       ${uai_set}=false		${cipher}=off
    Set Test Variable         ${ue_count}        ${end_ue_id}
    Fetch RAN_CU_DU UE ID from pcap      ${pcap_file}          ${split}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Run Keyword If  '${state[${ue_idx}]}' == 'inactive' and '${uai_set}' == 'false' and '${split}' == 'C'
    ...     Verify Inactive UE Cplane messages split-C           ${pcap_file}           ${qos_profile}
    ...      ${full_rnti_list}        ${activityNotify}         idx=${ue_idx}
    Run Keyword If  '${state[${ue_idx}]}' == 'inactive' and '${uai_set}' == 'false' and '${split}' == 'B'
    ...       Verify Inactive UE Cplane messages           ${pcap_file}             ${qos_profile}
    ...        ${full_rnti_list}        ${activityNotify}         ${split}      idx=${ue_idx}
    Run Keyword If  '${state[${ue_idx}]}' == 'inactive' and '${uai_set}' == 'false' and '${split}' == 'resume' and '${cipher}' != 'on'
    ...       Verify InactivetoActive UE Cplane messages           ${pcap_file}          ${qos_profile}
    ...        ${full_rnti_list}        ${activityNotify}      ${cause_list}         ${split}       idx=${ue_idx}
	Run Keyword If  '${state[${ue_idx}]}' == 'inactive' and '${uai_set}' == 'true' and '${split}' == 'resume'
    ...       Verify InactivetoActive UAI_UE Cplane messages           ${pcap_file}          ${qos_profile}
    ...        ${full_rnti_list}        ${activityNotify}      ${cause_list}         ${split}       idx=${ue_idx}
    Run Keyword If  '${state[${ue_idx}]}' == 'inactive' and '${uai_set}' == 'false' and '${split}' == 'fallback'
    ...       Verify InactivetoFallback UE Cplane messages         ${pcap_file}         ${qos_profile}
    ...        ${full_rnti_list}         ${activityNotify}         ${cause_list}           ${split}        idx=${ue_idx}
    Run Keyword If  '${state[${ue_idx}]}' == 'inactive' and '${uai_set}' == 'true' and '${split}' != 'resume'
    ...     Verify Cplane messages for UAI UE       ${pcap_file}       ${UE_ID}
    ...            ${qos_profile}         ${full_rnti_list}         ${activityNotify}         idx=${ue_idx}
    Run Keyword If  '${state[${ue_idx}]}' == 'active'
    ...     Verify Active UE Cplane messages      ${pcap_file}       ${UE_ID}       ${full_rnti_list}          idx=${ue_idx}
	Run Keyword If  '${state[${ue_idx}]}' == 'inactive' and '${uai_set}' == 'false' and '${split}' == 'resume' and '${cipher}' == 'on'
    ...       Verify Inactive UE Cplane messages with ciphering           ${pcap_file}          ${qos_profile}
    ...        ${full_rnti_list}        ${activityNotify}      ${cause_list}         ${split}       idx=${ue_idx}
    Run Keyword If  '${state[${ue_idx}]}' == 'idle'
    ...     Verify Idle UE Cplane messages           ${pcap_file}         ${UE_ID}
    ...      ${qos_profile}          ${full_rnti_list}        ${activityNotify}         idx=${ue_idx}
    END
    log to console      ${qos_profile}
    log to console      ${full_rnti_list}
    log to console      ${split}
Verify InactivetoActive UAI_UE Cplane messages
    [Arguments]    ${pcap_file}         ${qos_profile}        ${full_rnti_list}         ${activityNotify}
    ...         ${cause_list}       ${split}        ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}||${f1ap}==${ID3[${idx}]}||${pcode}==18
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    ${ue_state}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.preferredRRC_State_r16
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${ue_status}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ...                                                endPacket=-${1}
    ...                                                kind=show
#    Should Be Equal            ${ue_status}         ${bearerstatus}
    Should Contain            ${ue_status}         0        1
    ${fullIrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.fullI_RNTI
    ...                                                endPacket=-${1}
    ${resumeIdentity}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeIdentity
    ...                                                endPacket=-${1}
    ${rrcresumecasuse}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeCause
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain         ${rrcresumecasuse}          ${cause_list[${idx}]}
    ${fullconfig}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.fullConfig
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain            ${fullconfig}         0
    ${srb_id}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.rrcResume_element.*nr-rrc.srb_Identity
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Be Equal       ${srb_id}         ${srb_Identity}
    ${drb_id}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.rrcResume_element.*drb_Identity
    ...                                                endPacket=-${1}
    ...                                                kind=show
#    Should Be Equal      ${drb_id}      ${drb_identity}      ##add gbr logic
    ${rrcResumeComplete}    analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc.rrcResumeComplete_element
    ...                                                path=nr-rrc.rrcResumeComplete_element
    ...                                                pkt_count=${1}
    ${timer}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*Inactivity_Timer
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain X Times        ${timer}         ${inactivity_timer}        1    #check with ul nas
    ${fullrnti_dec}         ${fullrnti_hex}     Get Modified Full_I_RNTI value     ${fullIrnti}      ${idx}
    ${fullrnti_dec1}         ${fullrnti_hex1}     Get Modified Full_I_RNTI value     ${resumeIdentity}      ${idx}
#    Should Contain          ${full_rnti_list}        ${fullrnti_hex}
    Log to Console   UE${idx} move from RRC Inactive to Active Mode
    Log to Console   Full-I-RNTI ${fullrnti_hex} verified
    IF  '${cause_list[${idx}]}' != '2'         RETURN
    ${pagingrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.Paging_element
    ...                                                path=f1ap.iRNTI
    ...                                                startPacket=${idx}
    ...                                                endPacket=${idx}
    ${fullrnti_dec2}         ${fullrnti_hex2}     Get Modified Full_I_RNTI value       ${pagingrnti}      ${idx}
    ${pagingcell}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.Paging_element
    ...                                                path=f1ap.PagingCell_list.*nRCellIdentity
    ...                                                startPacket=${idx}
    ...                                                endPacket=${idx}
    ...                                                kind=show
    log to console      ${state}
    log to console      ${qos_profile}
    log to console      ${activityNotify}
    log to console      ${full_rnti_list}
    log to console      ${split}
Verify InactivetoActive UE Cplane messages
    [Arguments]    ${pcap_file}         ${qos_profile}        ${full_rnti_list}         ${activityNotify}
    ...         ${cause_list}       ${split}        ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}||${f1ap}==${ID3[${idx}]}||${pcode}==18
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    ${ue_state}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.${activityNotify}_Activity$
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${ue_status}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain            ${ue_status}         0        1
    ${fullIrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.fullI_RNTI
    ...                                                endPacket=-${1}
    ${resumeIdentity}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeIdentity
    ...                                                endPacket=-${1}
    ${rrcresumecasuse}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeCause
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain         ${rrcresumecasuse}          ${cause_list[${idx}]}
    ${fullconfig}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.fullConfig
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain            ${fullconfig}         0
    ${srb_id}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.rrcResume_element.*nr-rrc.srb_Identity
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Be Equal       ${srb_id}         ${srb_Identity}
    ${drb_id}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.rrcResume_element.*drb_Identity
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${rrcResumeComplete}    analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc.rrcResumeComplete_element
    ...                                                path=nr-rrc.rrcResumeComplete_element
    ...                                                pkt_count=${1}
    ${timer}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*Inactivity_Timer
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${drb_cn}    Get Length      ${qos_profile[${idx}]}
    ${drb_identity}       Set Variable If  '${drb_cn}' == '1'         ${ngbr_drb_identity}
    ...         '${drb_cn}' == '2'         ${gbr_drb_identity}
    Should Be Equal      ${drb_id}      ${drb_identity}
    ${cn}       Set Variable If  '${cause_list[${idx}]}' == '3'         3
    ...         '${cause_list[${idx}]}' == '2' and '${activityNotify}' == 'dRB'         3
    ...         '${cause_list[${idx}]}' == '4' and '${activityNotify}' == 'dRB' and '${drb_cn}' == '2'         2
    ...         '${cause_list[${idx}]}' != '3'          1
    Should Contain X Times        ${timer}         ${inactivity_timer}        ${cn}
    ${drb_count}     Run Keyword If  '${activityNotify}' == 'uE'	    Set Variable         ${1}
    ...   ELSE       Get Length      ${qos_profile[${idx}]}
    ${ue_state}     Run Keyword If  '${activityNotify}' == 'dRB' and '${drb_count}' > '1'      Get Slice From List   ${ue_state}      ${drb_count}
    ...   ELSE      Set Variable         ${ue_state}
    ${state_len}        Get Length      ${ue_state}
    Run Keyword If  '${state_len}' < '4'         Should Contain X Times        ${ue_state}         1           ${drb_count}
    ${fullrnti_dec}         ${fullrnti_hex}     Get Modified Full_I_RNTI value     ${fullIrnti}      ${idx}
    ${fullrnti_dec1}         ${fullrnti_hex1}     Get Modified Full_I_RNTI value     ${resumeIdentity}      ${idx}
    Should Contain          ${full_rnti_list}        ${fullrnti_hex}       ${fullrnti_hex1}
    Log to Console   UE${idx} move from RRC Inactive to Active Mode
    Log to Console   Full-I-RNTI ${fullrnti_hex} verified
    IF  '${cause_list[${idx}]}' != '2'         RETURN
    ${pagingrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.Paging_element
    ...                                                path=f1ap.iRNTI
    ...                                                startPacket=${idx}
    ...                                                endPacket=${idx}
    ${fullrnti_dec2}         ${fullrnti_hex2}     Get Modified Full_I_RNTI value       ${pagingrnti}      ${idx}
    Should Contain          ${full_rnti_list}        ${fullrnti_hex2}
    ${pagingcell}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.Paging_element
    ...                                                path=f1ap.PagingCell_list.*nRCellIdentity
    ...                                                startPacket=${idx}
    ...                                                endPacket=${idx}
    ...                                                kind=show
    Should Contain          ${pagingcell}         00:00:04:00:10
    log to console      ${qos_profile}
    log to console      ${activityNotify}
    log to console      ${full_rnti_list}
    log to console      ${split}
Verify InactivetoFallback UE Cplane messages
    [Arguments]        ${pcap_file}         ${qos_profile}        ${full_rnti_list}         ${activityNotify}
    ...               ${cause_list}          ${split}        ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}||${f1ap}==${ID3[${idx}]}||${pcode}==18
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    ${ue_state}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.${activityNotify}_Activity$
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${ue_status}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain            ${ue_status}         0        1
    ${fullIrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.fullI_RNTI
    ...                                                endPacket=-${1}
    ${resumeIdentity}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeIdentity
    ...                                                endPacket=-${1}
    ${rrcresumecasuse}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeCause
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain         ${rrcresumecasuse}          ${cause_list[${idx}]}
	${rrcResumeComplete}    analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc.rrcResumeRequest1_element
    ...                                                path=nr-rrc.rrcResumeRequest1_element
    ...                                                pkt_count=${1}
	${rrcsetup_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc.rrcSetup_element
    ...                                                path=nr-rrc.rrcSetup_element
    ...                                                pkt_count=${1}
    Should Be Equal           ${rrcsetup_count}        ${2}
    ${rrcsetupcom_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc.rrcSetupComplete_element
    ...                                                path=nr-rrc.rrcSetupComplete_element
    ...                                                pkt_count=${1}
    Should Be Equal           ${rrcsetupcom_count}          ${2}
	${rrcResumeComplete}   analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.rrcResumeComplete_element
    Should Be Equal           ${rrcResumeComplete}         ${0}
    Log to Console   UE${idx} move from RRC Inactive to Active Mode due to fallback
    log to console      ${qos_profile}
    log to console      ${activityNotify}
    log to console      ${split}
    log to console      ${full_rnti_list}
Verify Inactive UE Cplane messages
    [Arguments]    ${pcap_file}         ${qos_profile}        ${full_rnti_list}         ${activityNotify}
    ...       ${split}         ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    ${ue_state}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.${activityNotify}_Activity$
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${ue_status}    analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${fullIrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.fullI_RNTI
    ...                                                endPacket=-${1}
#    ...                                                kind=show
##Verification string showname="dRB-Activity: not-active (1)  showname="BearerContextStatusChange: suspend (0)
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    ${drb_count}     Run Keyword If  '${activityNotify}' == 'uE'	    Set Variable         ${1}
    ...   ELSE       Get Length      ${qos_profile[${idx}]}
    ${ue_state}     Run Keyword If  '${activityNotify}' == 'dRB' and '${drb_count}' > '1'      Get Slice From List   ${ue_state}      ${drb_count}
    ...   ELSE      Set Variable         ${ue_state}
#    From BearerContextInactivityNotification -> dRB-Activity: not-active (1)   active (0)
    Should Contain X Times        ${ue_state}         1           ${drb_count}
#    From BearerContextModificationRequest -> BearerContextStatusChange: suspend (0)  resume (1)
    Should Be Equal            ${ue_status}         0
    ${fullrnti_dec}         ${fullrnti_hex}=     Get Modified Full_I_RNTI value     ${fullIrnti}      ${idx}
    Should Contain          ${full_rnti_list}        ${fullrnti_hex}
    Log to Console   UE${idx} in RRC Inactive Mode
    Log to Console   Full-I-RNTI ${fullrnti_hex}
    log to console      ${qos_profile}
    log to console      ${activityNotify}
    log to console      ${full_rnti_list}
    log to console      ${split}
Verify Cplane messages for UAI UE
    [Arguments]    ${pcap_file}        ${UE_ID}       ${qos_profile}        ${full_rnti_list}
    ...         ${activityNotify}          ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    ${ue_state}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.preferredRRC_State_r16
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${ue_status}    analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${fullIrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.fullI_RNTI
    ...                                                endPacket=-${1}
#    ...                                                kind=show
##Verification string showname="dRB-Activity: not-active (1)  showname="BearerContextStatusChange: suspend (0)
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    ${drb_count}     Run Keyword If  '${activityNotify}' == 'uE'	    Set Variable         ${1}
    ...   ELSE       Get Length      ${qos_profile[${idx}]}
    ${ue_state}     Run Keyword If  '${activityNotify}' == 'dRB' and '${drb_count}' > '1'      Get Slice From List   ${ue_state}      ${drb_count}
    ...   ELSE      Set Variable         ${ue_state}
## preferredRRC-State-r16: inactive (1)
    Should Contain X Times        ${ue_state}         1           ${drb_count}
## preferredRRC-State-r16: outOfConnected (3)
#    Should Contain X Times        ${ue_state}         3           ${drb_count}
## preferredRRC-State-r16: connected (2)
#    Should Contain X Times        ${ue_state}         2           ${drb_count}
## preferredRRC-State-r16: idle (0)
#    Should Contain X Times        ${ue_state}         0           ${drb_count}

    Should Be Equal            ${ue_status}         0
    ${fullrnti_dec}         ${fullrnti_hex}=     Get Modified Full_I_RNTI value     ${fullIrnti}      ${idx}
    Should Contain          ${full_rnti_list}        ${fullrnti_hex}
    Log to Console   UE${idx} in RRC Inactive Mode
    Log to Console   Full-I-RNTI ${fullrnti_hex}
    log to console      ${split}
    log to console      ${full_rnti_list}
    log to console      ${UE_ID}

Verify Idle UE Cplane messages
    [Arguments]    ${pcap_file}        ${UE_ID}         ${qos_profile}        ${full_rnti_list}
    ...        ${activityNotify}          ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${ue_state}    analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.${activityNotify}_Activity$
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ${release}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.rrcRelease_element$
    ...                                                endPacket=-${1}
    ${drb_count}     Run Keyword If  '${activityNotify}' == 'uE'	    Set Variable         ${1}
    ...   ELSE       Get Length      ${qos_profile[${idx}]}
    Should Contain X Times        ${ue_state}         1           ${drb_count}
    Should Be Equal           ${path_count}         ${0}
    Should Contain       ${release}         rrcRelease
    Log to Console   UE${idx} in RRC Idle Mode
    log to console      ${qos_profile}
    log to console      ${full_rnti_list}
    log to console      ${UE_ID}
Verify Active UE Cplane messages
    [Arguments]    ${pcap_file}        ${UE_ID}        ${full_rnti_list}          ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    Should Be Equal           ${path_count}         ${0}
    Log to Console   UE${idx} in RRC Connected Mode
    log to console      ${full_rnti_list}
    log to console      ${UE_ID}
Verify Inactive UE Cplane messages split-C
    [Arguments]    ${pcap_file}        ${qos_profile}        ${full_rnti_list}       ${activityNotify}       ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}||${pcode}==18
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    ${ue_state}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.${activityNotify}_Activity$
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${ue_status}    analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${pagingrnti}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.Paging_element
    ...                                                path=f1ap.iRNTI
    ...                                                startPacket=${idx}
    ...                                                endPacket=${idx}
    ${fullrnti_dec2}         ${fullrnti_hex2}     Get Modified Full_I_RNTI value       ${pagingrnti}      ${idx}
    ${rel_cause}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.radioNetwork
    ...                                                endPacket=-${1}
    ...                                                kind=show
##Verification string showname="dRB-Activity: not-active (1)  showname="BearerContextStatusChange: suspend (0)
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    ${drb_count}     Run Keyword If  '${activityNotify}' == 'uE'	    Set Variable         ${1}
    ...   ELSE       Get Length      ${qos_profile[${idx}]}
    ${ue_state}     Run Keyword If  '${activityNotify}' == 'dRB' and '${drb_count}' > '1'      Get Slice From List   ${ue_state}      ${drb_count}
    ...   ELSE      Set Variable         ${ue_state}
#    From BearerContextInactivityNotification -> dRB-Activity: not-active (1)   active (0)
    Should Contain X Times        ${ue_state}         1           ${drb_count}
#    From BearerContextModificationRequest -> BearerContextStatusChange: suspend (0)  resume (1)
    Should Be Equal            ${ue_status}         0
	List Should Contain Value            ${rel_cause}         40
	Should Contain          ${full_rnti_list}        ${fullrnti_hex2}
    Log to Console   UE${idx} is Released
    log to console      ${qos_profile}
    log to console      ${full_rnti_list}
Verify silent release of ue
    [Arguments]     ${start_ue_id}       ${end_ue_id}
	${context_release_time}		Create Dictionary
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=UE CONTEXT RELEASE COMPLETE    timeout=10
    ${output1}         Get Lines Matching Regexp    ${output}    UE CONTEXT RELEASE COMPLETE   partial_match=${TRUE}
    ${time}    Split String      ${output1}      ${SPACE}
    Set To Dictionary       ${context_release_time}     ${ue_idx}      ${time[${2}]}
	END
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=PDN    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    INACTIVE    partial_match=${TRUE}
    Log to Console    ${output}
    Log to Console    UE: ${ue_idx} in inactive state
    END
    [Return]    ${context_release_time}

Verify Cplane messages of silent release UE
	[Arguments]    ${pcap_file}         ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}||${pcode}==18
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextReleaseCommand
	Should Not Be Equal           ${path_count}         ${0}
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextReleaseComplete
	Should Not Be Equal           ${path_count}         ${0}
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.UEContextReleaseRequest
	Should Not Be Equal           ${path_count}         ${0}
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.UEContextReleaseComplete
	Should Not Be Equal           ${path_count}         ${0}

############################## CB008225 Split J Keywrd ######################################
Update_tce_ip_in_delta_file
    [Arguments]     ${file_path}
    ${command}     Set Variable     sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${eth0_ip}      Run     ${command}
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=TCE_VM_IP    replace_with=${eth0_ip}
	Set Global Variable			${eth0_ip}		${eth0_ip}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Start Subscriber Trace
    [Arguments]     ${ue_id}=${start_ue_id}          ${trace_session_id}=1       ${tce_ip}=0.0.0.0
    wtsrunner.ng_ue_trace_start         id=${ue_id}                 tce_ip=${tce_ip}            trace_depth=maximum
    ...             ifaces_to_trace=NG-C,Xn-C,Uu,F1-C,E1            trace_plmn=311:489         trace_rec_session_ref_id=${trace_session_id}
    ...             trace_ref_id=${trace_session_id}

Stop Subscriber Trace
    [Arguments]    ${ue_id}=${start_ue_id}    ${trace_session_id}=1
     wtsrunner.ng_ue_trace_stop     id=${ue_id} trace_plmn=311:489 trace_ref_id=${trace_session_id} trace_rec_session_ref_id=${trace_session_id}

Extract_trace_message_from_pcap_on_tce_port
    [Arguments]    ${pcap_filepath}     ${filter}   ${pcap_file}    ${pdml_file}
    ${options}  Set variable  -o ntrstr.defragment:TRUE -o ntrstr.port:49148
    ${result}    Run    tshark ${options} -Y ${filter} -r ${pcap_filepath}/${pcap_file} -T pdml > ${pcap_filepath}/${pdml_file}

verify_subscribertraces_on_tce
    [Arguments]      ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
    ...     filter="nsetapx.data == 0 || ngap"
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nr-rrc.c1
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rrcResumeRequest1*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nsetapx.traceId
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${attrib_value}     Remove Duplicates       ${attrib_value}
    ${no_of_trace_id}       Get Length  ${attrib_value}
    Should not be equal as integers     ${no_of_trace_id}       1
    ${packet_before_fallback}     Set Variable        nsetapx.data || nsetapx.traceId == ${attrib_value}[0]
    ${packet_after_fallback}     Set Variable        nsetapx.data || nsetapx.traceId == ${attrib_value}[1]
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=${packet_before_fallback}
    ...                                                 endPacket=-${1}
    Should contain Match      ${attrib_value}     *InitialContextSetupResponse*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=${packet_after_fallback}
    ...                                                 endPacket=-${1}
    Should contain Match      ${attrib_value}     *InitialContextSetupResponse*

Verify_pcmd_traces_on_tce
    [Arguments]    ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
	...		filter="nsetapx.data == 1"
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.ueDuConnectivityRecord
    ...                                                path=nsetapx.result
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *success*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.ueSetupRecord
    ...                                                path=nsetapx.result
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *success*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.ueSetupRecord
    ...                                                path=nsetapx.trigger
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rrcResume*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.rrcSetupRecord
    ...                                                path=nsetapx.resumeCause
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *mtAccess*

verify_celltraces_on_tce
    [Arguments]    ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
	...		filter="nsetapx.data == 0"
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nr-rrc.c1
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rrcResumeRequest1*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nr-rrc.criticalExtensions
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rrcResume
	${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nr-rrc.criticalExtensions
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rrcResumeComplete

verify_mdt_on_tce
	[Arguments]    ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
    ...   filter="nsetapx"
	${path_count}      analyzer.count_path     pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nsetapx.ueMeasRecord
	Should Not be Equal			${path_count}		0

Verify_pcmd_traces_on_tce_rna_update
    [Arguments]    ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
    ...     filter="nsetapx.data == 1"
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.ueDuConnectivityRecord
    ...                                                path=nsetapx.result
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *success*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.ueSetupRecord
    ...                                                path=nsetapx.result
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *success*
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.ueSetupRecord
    ...                                                path=nsetapx.trigger
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rnaUpdate*

verify_celltraces_on_tce_rna_update
    [Arguments]    ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
	...		filter="nsetapx.data == 0"
    ${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nr-rrc.c1
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rrcResumeRequest1*
	${attrib_value}     analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.data
    ...                                                path=nr-rrc.criticalExtensions
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *rrcRelease
	Should contain Match      ${attrib_value}     *suspendConfig is present*

Filterring of Message ID BearerModifyReq in Sherpa csv
    [Documentation]     Verify the presence of a given Message ID in a cvs file issued from sherpa.
    [Arguments]         ${Sherpa_message_ID_to_filter}
    ${sherpa_csv_files}            OperatingSystem.List Files In Directory    ${Sherpa_logs_local_path}/
    ${MSGID}=    Run    command=cd ${Sherpa_logs_local_path}/&& ls|grep --color=auto -E "${Sherpa_message_ID_to_filter}" micro__ControlFlows.csv
    should not be empty   ${MSGID}
    Log to console      ${MSGID}

Create_dictionary_of_resources
	[Arguments]     ${file}		${content}=${EMPTY}
	Create File		${file}		${content}
    ${file_content}=    OperatingSystem.Get File    ${file}
    ${lines}=    Split To Lines    ${file_content}
    ${new_lines}=    Create List
    ${resource_dictionary1}=    Create Dictionary
    ${resource_dictionary2}=    Create Dictionary
    FOR    ${line}    IN    @{lines}
    ${status}       Run keyword and Return Status   Should Contain  ${line}    numOfResources
    ${status1}       Run keyword and Return Status   Dictionary Should not contain Key   ${resource_dictionary1}         ${key}[1]
    ${value}    Split String From Right    ${line}     max_split=1
    Run Keyword If    '${status}'=='True' and '${status1}'=='True'   Set To Dictionary   ${resource_dictionary1}     ${key}[1]  ${value}[1]
    ...     ELSE IF  '${status}'=='True' and '${status1}'=='False'    Set to Dictionary   ${resource_dictionary2}    ${key}[1]  ${value}[1]
    ${key}      Split String From Right    ${line}     max_split=1
    END
    [Return]     ${resource_dictionary1}            ${resource_dictionary2}

Silent Release Resource Validation
	[Arguments]		${cpnrtaft}		${cpnrtb4}	${cprtaft}		${cprtb4}	${cpnbaft}		${cpnbb4}
	${cpnrt_l2lo_aft}   ${cpnrt_l2hi_aft}   Create_dictionary_of_resources	    ${OUTPUT_DIR}/cpnrtaft.txt	    ${cpnrtaft}
	${cpnrt_l2lo_b4}   ${cpnrt_l2hi_b4}   Create_dictionary_of_resources      ${OUTPUT_DIR}/cpnrtb4.txt	    ${cpnrtb4}
    Dictionaries Should Be Equal        ${cpnrt_l2lo_aft}   ${cpnrt_l2lo_b4}
    Dictionaries Should Be Equal        ${cpnrt_l2hi_aft}   ${cpnrt_l2hi_b4}
    ${cprt_l2lo_aft}   ${cprt_l2hi_aft}   Create_dictionary_of_resources      ${OUTPUT_DIR}/cprtaft.txt      ${cprtaft}
    ${cprt_l2lo_b4}   ${cprt_l2hi_b4}   Create_dictionary_of_resources      ${OUTPUT_DIR}/cprtb4.txt     ${cprtb4}
    Dictionaries Should Be Equal        ${cprt_l2lo_aft}   ${cprt_l2lo_b4}
    Dictionaries Should Be Equal        ${cprt_l2hi_aft}   ${cprt_l2hi_b4}
    Create File     ${OUTPUT_DIR}/cpnbaft.txt     ${cpnbaft}
    Create File     ${OUTPUT_DIR}/cpnbb4.txt     ${cpnbb4}
    ${cpnrtchecklis}    Create List     activeUes   maxNumOfBearerGroups    rohcMaxSupportedCtx    allocatedNumOfBearers
    ...     allocatedNumOfPduSessions
    compare_resources_matching_string   ${OUTPUT_DIR}/cpnrtaft.txt  ${OUTPUT_DIR}/cpnrtb4.txt   ${cpnrtchecklis}
    ${cprtchecklist}	Create List		allocatedDrbNumber	allocatedSrbNumber	nbOfActiveSRBs	nbOfActiveDRBs	nbOfActiveUEs	nbOfTemporaryUEs
    ...     tempUeCount	bearerCount	ueCount
    compare_resources_matching_string   ${OUTPUT_DIR}/cprtaft.txt  ${OUTPUT_DIR}/cprtb4.txt   ${cprtchecklist}
	${cpnbchecklist}    Create List     admittedNsaUsers    admittedSaUsers     admittedNrdcUsers   countFreeSrbIndex
    ...     numberOfActiveUeSa  numberOfActiveUeNsa numberOfActiveUeNrdc
    compare_resources_matching_string   ${OUTPUT_DIR}/cpnbaft.txt  ${OUTPUT_DIR}/cpnbb4.txt   ${cpnbchecklist}

compare_resources_matching_string
    [Arguments]     ${file1}    ${file2}     ${comparestring}
    ${file_content1}=    OperatingSystem.Get File    ${file1}
    ${lines1}=    Split To Lines    ${file_content1}
    ${file_content2}=    OperatingSystem.Get File    ${file2}
    ${lines2}=    Split To Lines    ${file_content2}
    FOR     ${i}    IN      @{comparestring}
    ${file1resource}    Get Lines Containing String     ${file_content1}   ${i}
    ${file2resource}    Get Lines Containing String     ${file_content2}   ${i}
    Should Match    ${file1resource}    ${file2resource}
    END

Get current resources
    [Arguments]     ${topology}
    ${i}    Run Keyword If   '${topology}'=='ASOE'  Set Variable     1   ELSE    Set Variable    2
    cli.create_aashell_cli    name=aashell
    cli.setup    aashell
    ${cpnrt_output}=    cli.execute_aashell_command    aashell    command=getResourcesUsage @cp-nrt #0x${i}516
    ${cpnrt_output}=    sort_resources_usage    ${cpnrt_output}
    ${cprt_output}=    cli.execute_aashell_command    aashell    command=getResourcesUsage @Cprt #0x${i}515
    ${cprt_output}=     sort_resources_usage    ${cprt_output}
    ${cpnb_output}=    cli.execute_aashell_command    aashell    command=getResourcesUsage @cp_nb #0x${i}513
    ${cpnb_output}=    sort_resources_usage    ${cpnb_output}
    Builtin.Log     ${cpnrt_output}
    Builtin.Log     ${cprt_output}
    Builtin.Log     ${cpnb_output}
    [Teardown]    cli.teardown   aashell
    [Return]    ${cpnrt_output}     ${cprt_output}      ${cpnb_output}

Verify MultiUE release Cplane messages from pcap
    [Arguments]    ${pcap_file}          ${start_ue_id}      ${end_ue_id}
    Set Test Variable         ${ue_count}        ${end_ue_id}
    ${RAN_UE_ID_list}       Fetch UE ID from pcap      ${pcap_file}	     ngap.InitialUEMessage_element		ngap.RAN_UE_NGAP_ID
    Set Test Variable        ${ID1}      ${RAN_UE_ID_list}
    ${Before_Resume_UE_ID_list}       Fetch UE ID from pcap      ${pcap_file}	     nr-rrc.rrcSetupRequest_element		f1ap.GNB_DU_UE_F1AP_ID
    Set Test Variable        ${ID2}      ${Before_Resume_UE_ID_list}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	Verify Cplane messages of silent release UE		${pcap_file}		${ue_idx}
	END

Verify Inactive UE Cplane messages with ciphering
	[Arguments]    ${pcap_file}         ${qos_profile}        ${full_rnti_list}         ${activityNotify}
    ...         ${cause_list}       ${split}        ${idx}=${ue_idx}
    ${packet}        set variable
    ...         ${ngap}==${ID1[${idx}]}||${e1ap}==${ID1[${idx}]}||${f1ap}==${ID2[${idx}]}||${f1ap}==${ID3[${idx}]}||${pcode}==18
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    Log to Console       Verifies UE ${idx} RAN_UE_NGAP_ID:${ID1[${idx}]} Cplane Packets
    ${cnai}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*CoreNetworkAssistanceInformationForInactive_element$
    ...                                                endPacket=-${1}
    Should Contain           ${cnai}         CoreNetworkAssistanceInformationForInactive
    ${ue_state}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.${activityNotify}_Activity$
    ...                                                endPacket=-${1}
    ...                                                kind=show
    ${ue_status}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.BearerContextStatusChange
    ...                                                endPacket=-${1}
    ...                                                kind=show
#    Should Be Equal            ${ue_status}         ${bearerstatus}
    Should Contain            ${ue_status}         0        1
	${resumeIdentity}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeIdentity
    ...                                                endPacket=-${1}
    ${rrcresumecasuse}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nr-rrc.resumeCause
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain         ${rrcresumecasuse}          ${cause_list[${idx}]}
    log to console      ${full_rnti_list}
    log to console      ${split}
    log to console      ${qos_profile}
Add routes
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3

