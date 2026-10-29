*** Settings ***
Variables    ta5g_global_var

Documentation
...				Keyword resources

Resource          ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../../../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../../../resources/robot/Setup_Env.robot
Resource       ../../../resources/robot/common_log_collection.robot
Resource        ../../../resources/ECEcommon/common_file_operation.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
#Library        taf.collectors.core   WITH NAME   CORE
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
#Library         ./python/increase_buffer_size.py
Resource        ../../../resources/robot/wts_sim_keywords.robot


*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

${pdu_mod_with_5qi-5}     Added QosFlow with QFI:2 fiveQI:5
${pdu_mod_with_5qi-1}     Added QosFlow with QFI:3 fiveQI:1

#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3    4   5   6   7   8   9   10  11  12  13  14  15

*** Keywords ***

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

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
    ${sib1_output}      wtsrunner.read_wtsemu_output_until_re    expected=cell 1: SystemInformationBlockType1-NR updated
    ...                                   timeout=400
    Set Suite Variable     ${sib1_output}
    sleep    60s
    Create File      /home/ute/sib_output.txt       ${sib1_output}
    Log to Console    Cell onair successful
    [Return]    ${sib1_output}

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Add PDU Session
    [Arguments]   ${start_ue_id}     ${endue_id}    ${pdu_profile}      ${nw_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Execute Egate Command   cmd=set_pdu_param ue=${ue_idx} pdu=${pdu_profile} trf_type=internal
    ${add_pdu}     SET VARIABLE    ue_pdu_session_setup pdu=${pdu_profile} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
    sleep   1s
    ${output}       Execute Egate Command And Wait For Data   ${add_pdu}
    ...     pass_regexp=PDU SESSION ID-${pdu_profile} setup/reestablishment comple   timeout=60
    END

ADD Multi PDU Session
    [Arguments]     ${start_pdu_id}    ${end_pdu_id}
    FOR     ${pdu_id}   IN RANGE    ${start_pdu_id}    ${end_pdu_id}+1
    Add PDU Session     ${start_ue_id}     ${endue_id}    ${pdu_id}      ${nw_id}
    sleep   1s
    END

Inject PDU Error
     [Arguments]   ${start_ue_id}    ${end_ue_id}    ${pdu_profile}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${tmp1}     Set Variable    pdu=${pdu_profile} abnormal_scenario=none
    ${pdu_error}      Set Variable    upf_ue_pdu_inject_error_ind ue=${ue_idx} id=1 ${tmp1}
    sleep   1s
    Execute Egate Command And Wait For Data    ${pdu_error}
    ...    pass_regexp=Successfully released PDU Session with ID ${pdu_profile}      timeout=60
    sleep   3s
    END

Inject Multiple PDU Error
    [Arguments]     ${start_pdu_id}    ${end_pdu_id}
    FOR     ${pdu_id}   IN RANGE    ${start_pdu_id}    ${end_pdu_id}+1
    Inject PDU Error    ${start_ue_id}    ${end_ue_id}    ${pdu_id}
    sleep   1s
    END

Multi PDU Traffic
     [Arguments]     ${start_pdu_id}    ${end_pdu_id}     ${ul_rate}      ${dl_rate}
     FOR     ${pdu_id}   IN RANGE    ${start_pdu_id}    ${end_pdu_id}+1
     MultiUE Trigger UL Traffic for SA    ${start_ue_id}  ${endue_id}  Traffic_rate=mbps   ul_rate=${ul_rate}
     ...                                   pdu_id=${pdu_id}   trf_id=1   qfi_id=1
     sleep   1s
     MultiUE Trigger DL Traffic for SA    ${start_ue_id}  ${endue_id}  Traffic_rate=mbps   dl_rate=${dl_rate}
     ...                                   pdu_id=${pdu_id}   trf_id=1   qfi_id=1
     sleep   1s
     END

UE state should be active
    [Arguments]   ${start_ue_id}     ${endue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Execute Egate Command   cmd=ue_disp id=${ue_idx}     pass_regexp=ACTIVE    timeout=60
    END

Verify Specific PDU Traffic
    [Arguments]    ${ue_idx}    ${pdu}

    ${dl_data}    Execute Egate Command    cmd=qfi_stats ue=${ue_idx} pdu=${pdu} qfi=1 dir=dl
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/dl.txt    ${dl_data}
    ${avg}    OperatingSystem.Run    cat /tmp/dl.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${mavg}    Evaluate    ${avg}*0.000001
    Log To Console    \n The average dl tput is: ${mavg}M \n
    Should Be True    ${mavg} > ${140}

Validate error msg in syslog
    [Arguments]     ${file}
    ${Reqmsg}   run     command=sudo cat ${file} | grep -i "Fatal" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Be Empty    ${Reqmsg}

Trigger Xn HO and HO Prepration Timeout
    [Arguments]     ${start_ue_id}     ${gnb_id}    ${meas_id}
    ${cmd}   set variable   gnb_xn_handover_preparation_param id=${gnb_id} action=force_failure time_to_wait=v1s nth=1
    Execute Egate Command    ${cmd}
    sleep   1s
    ${tmp2}    set variable    nrsrp_nr=30 nrsrq_nr=20
    ${cmd1}   set variable   ue_measurement_send_nr id=${start_ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=52 ${tmp2}
    sleep   3s
    ${output}    Execute Egate Command And Wait For Data   ${cmd1}
    ...     pass_regexp=HandoverPreparationFailure for XnHANDOVER_REQUEST   timeout=60
    sleep   1s

Generalised MultiUE Register should be Successful VoNR Suported
    [Documentation]
    ...        This KW is meant to support VONR QFI addition based on user requirement. By
    ...        By default VoNR support will be Off. To Enable VoNR, one of 3 values need to give
    ...        1.   during InitialContextSetup with 5QI1 and 5QI-5
    ...        2.   pdusessionModify with 5QI1 and 5QI-5 on PDU-1
    ...        3.   pdusessionEstablishment with 5QI1 and 5QI-5 on PDU-2

    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${trf_type}=internal    ${vonr_supp}=False    ${isEpsFb}=False    ${iseme}=False    ${start_gw}=${1}
    ...     ${ue_cap}=None
    ${crnti_list}       Create List
    ${gw}   Set Variable    ${start_gw}
    BuiltIn.Log        ${iseme}
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    #Command Variable Definition
    ${cmd1}     Set Variable    smf_param id=1 additional_qosflows_to_activate=2,3
    ${cmd2}     Set Variable    ue_pdu_session_modify ue=${ue_idx} pdu=1 qosflows_to_add=2 by=ue
    ${cmd3}     Set Variable    ue_pdu_session_modify ue=${ue_idx} pdu=1 qosflows_to_add=3 by=ue
    ${cmd4}     Set Variable    set_pdu_param ue=${ue_idx} pdu=2 trf_type=${trf_type}
    ${cmd5}     Set Variable    smf_param id=1 reset

    ${efb1}     Set Variable    amf_param id=1 send_ics_registration=off
    ${efb2}     Set Variable    amf_ue_ics_param id=1 outer_NAS_PDU_type=configuration_update_command
    ${efb3}     Set Variable    amf_param id=1 voice_fallback=off
    ${efb4}     Set Variable    amf_param id=1 voice_fallback=on

    Start log       cprt
    Run Keyword if    ${isEpsFb}==1    Run Keywords
    ...    Execute Egate Command  ${cmd5}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command  ${efb3}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command  ${efb1}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command  ${efb2}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command  ${cmd1}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command  ${efb4}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    ELSE IF    ${isEpsFb}==2 or ${isEpsFb}==3    Run Keywords
    ...    Execute Egate Command  ${cmd5}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command  ${efb3}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command  ${efb4}  timeout=${EGATE_COMMAND_TIMEOUT}

    ${rrc_rel}  Set Variable    UE${ue_idx}: Redirected carrier info is present in RRC Release
    ${rrc_state}  Set Variable    UE${ue_idx}: IS IDLE
    ${pattern1}    Set Variable if  ${isEpsFb}==1 and ${vonr_supp}==1   (\?\:${rrc_rel}|${rrc_state})
    ...    (\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})

    ${pattern2}    Set Variable if  ${isEpsFb}==2 and ${vonr_supp}==2   (\?\:${rrc_rel}|${rrc_state})
    ...    ${pdu_mod_with_5qi-1}

    ${pattern3}    Set Variable if  ${isEpsFb}==3 and ${vonr_supp}==3   (\?\:${rrc_rel}|${rrc_state})
    ...    (\?\:Setup QosFlow with QFI|PDUSessionId:2)

    Run Keyword if  ${vonr_supp}==1
    ...    Execute Egate Command  ${cmd1}  timeout=${EGATE_COMMAND_TIMEOUT}
	${ue_reg_cmd}	SET VARIABLE if     '${ue_cap}'=='None' 	ue_register id=${ue_idx}
	...     ue_register id=${ue_idx} ue_nr_capabilities=${ue_cap}
	${output}		Execute Egate Command And Wait For Data  ${ue_reg_cmd}
	...                                   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}

	${set_pdu_param_cmd}	Set Variable	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=${trf_type}
    ${pdu_setup_cmd}	Set Variable	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${gw}
	Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=${pattern1}      timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,
    ...                                   pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    Run Keyword if  ${vonr_supp}==1
    ...    Execute Egate Command    ${cmd5}    timeout=${EGATE_COMMAND_TIMEOUT}
    #Update GW
    ${gw}   Evaluate    ${gw}+${1}

    Run Keyword if  ${vonr_supp}==2
    ...    Run Keywords
    ...    Execute Egate Command And Wait For Data    ${cmd2}
    ...    pass_regexp=${pdu_mod_with_5qi-5}     timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command And Wait For Data    ${cmd3}
    ...    pass_regexp=${pattern2}      timeout=${EGATE_COMMAND_TIMEOUT}

    ${cmd6}     Set Variable if  '${vonr_supp}'=='3'    ue_pdu_session_setup pdu=2 ue=${ue_idx} nwslice=1 gw=${gw}
    ${output3}   Run Keyword if  '${vonr_supp}'=='3'
    ...    Run Keywords
    ...    Execute Egate Command    ${cmd5}    timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command    ${cmd1}    timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command    ${cmd4}    timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    Execute Egate Command And Wait For Data    ${cmd6}
    ...    pass_regexp=${pattern3}       timeout=${EGATE_COMMAND_TIMEOUT}

    ${gw1}  Evaluate    ${gw}+${1}
    ${gw}     Set Variable if  '${vonr_supp}'=='3'    ${gw1}    ${gw}
    ${path_cprt}     Stop log    cprt   test_scenario=UE_${ue_idx}/cprt_PduSessionSetup
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    log to console      ${path_cprt}
#    ${next_gw}      Evaluate    ${gw}+${1}
    [Return]      ${crnti_list}    ${gw}

Drop Xn Link
    [Arguments]     ${target_gNB}
    Execute Egate Command   cmd=link_drop link=xn by=gnb:${target_gNB} to=gnb:2

Establish Xn Link To gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    Execute Egate Command    cmd=gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true
    sleep   5
    Execute Egate Command     cmd=gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   10s

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin
