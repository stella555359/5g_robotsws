*** Settings ***
Variables    ta5g_global_var


Documentation
...				Keyword resources


Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
#Library        taf.collectors.core   WITH NAME   CORE
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library     taf.sbts.oam.coam.admin      WITH NAME    coam


*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22
${ADMIN_CONNECTION}=  admin_connection

#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3    4   5   6   7   8   9   10  11  12  13  14  15

*** Keywords ***
Recover gtpu path failure for 4 paths sa
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.14,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.14,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.14,0

Recover gtpu path failure for 1 paths sa
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep    1s

Recover gtpu path failure for 6 paths sa
    ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.2,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.14,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.14,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.14,0

Trigger gtpu path failure for 3 paths sa
    ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.14,1500
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.14,1500
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.14,1500

Trigger gtpu path failure for 6 paths sa
    ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,1500
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.2,1500
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,1500
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.14,1500
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.14,1500
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.14,1500

Trigger gtpu path failure for 3 paths upf1
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,1500
    sleep    1s

Trigger gtpu path failure for 3 paths upf2
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.40,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.40,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.40,1500

Trigger gtpu path failure for 6 paths
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.40,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.40,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.40,1500

Start traffic
	MultiUE Trigger DL Traffic for SA   71       79    Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=1       qfi_id=1
	MultiUE Trigger UL Traffic for SA   71       79    Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=1       qfi_id=1

#MultiUE Trigger DL Traffic for SA
#    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}
#    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
#    [Documentation]    This keyword starts the DL Traffic for the SA variant
#    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
#    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}

Multi UE Register should be Successful with upfid And send traffic
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${pdu_id}     ${nw_id}      ${gw_id}     ${upf_ID}
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
     UE Register should be Successful with upfid And Fetch RNTI    ${ue_idx}    ${pdu_id}     ${nw_id}      ${gw_id}     ${upf_ID}
     wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${ue_idx}      Traffic_rate=mbps     dl_rate=10     pdu_id=1   trf_id=1
     wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${ue_idx}      Traffic_rate=mbps     ul_rate=10     pdu_id=1   trf_id=1
     END

UE Register should be Successful with upfid And Fetch RNTI
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}     ${upf_ID}=&{1}
    ${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_id}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal upf=${upf_ID}
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nw_id} gw=${gw_id}
	Execute Egate Command    ${set_pdu_param_cmd}    timeout=10s
    ${output}	 Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    ${output1}   Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
	BuiltIn.log   ${output1}
	BuiltIn.Should Match Regexp   ${output1}  spCellConfigDedicated(.|\r|\n)*?pdsch-Config setup(.|\r|\n)*?resourceAllocation resourceAllocationType1
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue_register_is_ok with ${crnti_value}
	[Return]      ${crnti_value}


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
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.5/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.6/24 dev eth3

Configure additional UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.5/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.6/24 dev eth3

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
    ${sib1_output}      wtsrunner.read_wtsemu_output_until_re    expected=cell 1: SystemInformationBlockType1-NR updated     timeout=400
    Set Suite Variable     ${sib1_output}
    sleep    60s
    Create File      /home/ute/sib_output.txt       ${sib1_output}
    Log to Console    Cell onair successful
    [Return]    ${sib1_output}

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Drop Xn Link
    [Arguments]     ${target_gNB}
    Execute Egate Command   cmd=link_drop link=xn by=gnb:${target_gNB} to=gnb:2

Establish Xn Link To gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    Execute Egate Command    cmd=gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true
    sleep   5
    Execute Egate Command     cmd=gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   10s

Check If fault 7706 Appeared and failed paths info
    [Documentation]    This keyword checks if an  fault ID 7706 appeared and fetches additional information.
    [Arguments]    ${severity}
    COAM.Setup Admin    bts_host=192.168.255.129
    @{alarm_history}=    COAM.Get Active Alarms
    ${alarm_found}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarm_history}
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId
        ${alarm_severity}=      Get From Dictionary    ${alarm}    faultSeverity
        ${contains_faultid}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings    ${alarm_fault_id}    7706
        Run Keyword If    '${contains_faultid}' == 'True' and '${alarm_severity}' == '${severity}'
        ...    Exit For Loop
    END
    Run Keyword If    not ${contains_faultid}
    ...    Fail    Alarm with fault ID 7706 did not appear.
    BuiltIn.Log   Alarm Found: fault-7706, alarmAttribute: ${alarm['alarmAttribute'][0]['attributeValue']}
#    Should Contain      ${alarm['alarmAttribute'][0]['attributeValue']}  ${failed_paths}
    ${alarm_time}       Split String    ${alarm['btsObservationTime']}      .
    ${alarm_time}=    DateTime.Convert Date   ${alarm_time[0]}    result_format=%Y%m%d%H%M%S.%f%z
    [TEARDOWN]  COAM.Teardown admin
    [RETURN]    ${alarm_time}      ${alarm}

Check If fault not Appeared
    [Documentation]    This keyword checks if an alarm with the specified fault ID appeared and fetches additional information.
    [Arguments]    ${fault_id}      ${severity}
    COAM.Setup Admin   bts_host=192.168.255.129  timeout=120
    @{alarm_history}=    COAM.Get Active Alarms
    ${alarm_found}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarm_history}
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId
        ${alarm_severity}=      Get From Dictionary    ${alarm}    faultSeverity
        ${contains_faultid}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings    ${alarm_fault_id}    ${fault_id}
        Run keyword If    '${contains_faultid}' == 'True'
        ...     Should Not Be Equal As Strings    ${alarm_severity}       ${severity}
    END
    Run Keyword If    not ${contains_faultid}
    ...    Fail    Alarm with fault ID ${fault_id} did not appear.
    [Teardown]          COAM.teardown admin

 Check If fault 7101 Appeared
    [Documentation]    This keyword checks if an alarm with the specified fault ID appeared and fetches additional information.
    [Arguments]    ${severity}
    COAM.Setup Admin    timeout=120
    @{alarm_history}=    COAM.Get Active Alarms
    ${alarm_found}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarm_history}
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId
        ${contains_faultid}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings    ${alarm_fault_id}    7101
        Run Keyword If    ${contains_faultid}
        ...    Exit For Loop
    END
    Run Keyword If    not ${contains_faultid}
    ...    Fail    Alarm with fault ID 7101 did not appear.
    Should Contain      ${alarm['faultSeverity']}    ${severity}


 Check If fault 7107 Appeared
    [Documentation]    This keyword checks if an alarm with the specified fault ID appeared and fetches additional information.
    [Arguments]    ${severity}
    COAM.Setup Admin    timeout=120
    @{alarm_history}=    COAM.Get Active Alarms
    ${alarm_found}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarm_history}
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId
        ${contains_faultid}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings    ${alarm_fault_id}    7107
        Run Keyword If    ${contains_faultid}
        ...    Exit For Loop
    END
    Run Keyword If    not ${contains_faultid}
    ...    Fail    Alarm with fault ID 7107 did not appear.
    Should Contain      ${alarm['faultSeverity']}    ${severity}


Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin        bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

lock NRCELL-${cell_id:\d+}
    coam.lock_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Unlock NRCELL-${cell_id:\d+}
    coam.unlock_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Check Operational State
    [Arguments]    ${expected_state}    ${target_cell}=None
    coam.setup admin    bts_host=10.0.1.2
    ${status}    ${cell_info}=    Run Keyword And Ignore Error    coam.get_cells_info    cell_type=nr
    Run Keyword If    '${status}' == 'FAIL'    Fail    Keyword failed: ${cell_info}

    ${matched}=    Set Variable    False

    FOR    ${cell}    IN    @{cell_info}
        ${config_id}=    Get From Dictionary    ${cell['id']}    configuration
        Run Keyword If    '${target_cell}' != 'None' and '${config_id}' != '${target_cell}'    Continue For Loop

        ${status_dict}=    Get From Dictionary    ${cell}    status
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState

        Run Keyword If    '${operationalState}' == '${expected_state}'
        ...    Log To Console    \u2714 ${config_id} state is ${operationalState} as expected
        Run Keyword If    '${operationalState}' != '${expected_state}'
        ...    Log To Console    \u274C ${config_id} state is ${operationalState}, expected: ${expected_state}

        ${matched}=    Set Variable    True
        Run Keyword If    '${operationalState}' != '${expected_state}'
        ...    Fail    ${config_id} state is ${operationalState}, expected: ${expected_state}
    END

    Run Keyword If    '${matched}' == 'False'    Fail    Cell ${target_cell} not found in cell_info

Check Availability and operational State of all cells
    [Arguments]    ${expected_avail_state}      ${expected_oper_state}
    coam.setup admin    bts_host=10.0.1.2

    @{all_cell_dn_list}   Create List
    ${nr_cells}   coam.get_cells_info
    FOR   ${nr_cell}   IN   @{nr_cells}
        ${nr_cell_dn}   Set Variable   ${nr_cell["id"]["configuration"]}
        Append To List   ${all_cell_dn_list}   ${nr_cell_dn}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${availabilityStatus}=    Get From Dictionary    ${status_dict}    availabilityStatus
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState
        Should be True      '${availabilityStatus}' == '${expected_avail_state}'
        Should be True      '${operationalState}' == '${expected_oper_state}'
    END
    [Teardown]  coam.teardown admin


Check Only Cells 4 5 6 Are Disabled
    [Arguments]    ${expected_avail_state}    ${expected_oper_state}
    coam.setup admin    bts_host=10.0.1.2

    @{target_cells}    Create List    MRBTS-1/NRBTS-1/NRCELL-4    MRBTS-1/NRBTS-1/NRCELL-5    MRBTS-1/NRBTS-1/NRCELL-6
    ${nr_cells}    coam.get_cells_info
    FOR    ${nr_cell}    IN    @{nr_cells}
        ${nr_cell_dn}    Set Variable    ${nr_cell["id"]["configuration"]}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${availabilityStatus}=    Get From Dictionary    ${status_dict}    availabilityStatus
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState

        ${is_target_cell}=    Run Keyword And Return Status    Should Contain    @{target_cells}    ${nr_cell_dn}
        Run Keyword If    ${is_target_cell}
        ...    Should Be Equal    ${availabilityStatus}    ${expected_avail_state}
        ...    Should Be Equal    ${operationalState}    ${expected_oper_state}
    END

    [Teardown]    coam.teardown admin


Check Only Cells 4 5 6 Are Enabled
    [Arguments]     ${expected_oper_state}
    coam.setup admin    bts_host=10.0.1.2

    @{target_cells}    Create List    MRBTS-1/NRBTS-1/NRCELL-4    MRBTS-1/NRBTS-1/NRCELL-5    MRBTS-1/NRBTS-1/NRCELL-6
    ${nr_cells}    coam.get_cells_info
    FOR    ${nr_cell}    IN    @{nr_cells}
        ${nr_cell_dn}    Set Variable    ${nr_cell["id"]["configuration"]}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState

        ${is_target_cell}=    Run Keyword And Return Status    Should Contain    @{target_cells}    ${nr_cell_dn}
        Run Keyword If    ${is_target_cell}
        ...    Should Be Equal    ${operationalState}    ${expected_oper_state}
    END

    [Teardown]    coam.teardown admin


Check operational State of all cells
    [Arguments]    ${expected_oper_state}
    coam.setup admin    bts_host=10.0.1.2

    @{all_cell_dn_list}   Create List
    ${nr_cells}   coam.get_cells_info
    FOR   ${nr_cell}   IN   @{nr_cells}
        ${nr_cell_dn}   Set Variable   ${nr_cell["id"]["configuration"]}
        Append To List   ${all_cell_dn_list}   ${nr_cell_dn}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState
        Should be True      '${operationalState}' == '${expected_oper_state}'
    END
    [Teardown]  coam.teardown admin

Check Availability State
    [Arguments]    ${expected_state}    ${target_cell}=None
    coam.setup admin    bts_host=10.0.1.2

    @{all_cell_dn_list}   Create List
    ${nr_cells}   coam.get_cells_info   connection=COAM
    FOR   ${nr_cell}   IN   @{nr_cells}
        ${nr_cell_dn}   Set Variable   ${nr_cell["id"]["configuration"]}
        Append To List   ${all_cell_dn_list}   ${nr_cell_dn}
    END

    ${status}    ${cell_info}=    Run Keyword And Ignore Error    coam.get_cells_info    cell_type=nr
    Run Keyword If    '${status}' == 'FAIL'    Fail    Keyword failed: ${cell_info}

    ${matched}=    Set Variable    False

    FOR    ${cell}    IN    @{cell_info}
        ${config_id}=    Get From Dictionary    ${cell['id']}    configuration
        Run Keyword If    '${target_cell}' != 'None' and '${config_id}' != '${target_cell}'    Continue For Loop

        ${status_dict}=    Get From Dictionary    ${cell}    status
        ${availabilityStatus}=    Get From Dictionary    ${status_dict}    availabilityStatus

        Run Keyword If    '${availabilityStatus}' == '${expected_state}'
        ...    Log To Console    \u2714 ${config_id} availability is ${availabilityStatus} as expected
        Run Keyword If    '${availabilityStatus}' != '${expected_state}'
        ...    Log To Console    \u274C ${config_id} availability is ${availabilityStatus}, expected: ${expected_state}

        ${matched}=    Set Variable    True
        Run Keyword If    '${availabilityStatus}' != '${expected_state}'
        ...    Fail    ${config_id} availability is ${availabilityStatus}, expected: ${expected_state}
    END

    Run Keyword If    '${matched}' == 'False'    Fail    Cell ${target_cell} not found in cell_info

Verify monitorTimerForCellDisable
    [Arguments]     ${file_path}        ${expected_value}
    ${timer_start}  OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i "Start monitorTimerForCellDisable" | awk '{print $2}'
    ${timer_end}    OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i "Timeout monitorTimerForCellDisable time" | awk '{print $2}'
    ${timer_start}      Split String    ${timer_start}      .
    ${timer_end}        Split String    ${timer_end}         .
    ${time_diff}    DateTime.Subtract Time from Time     ${timer_end}[0]        ${timer_start}[0]
#    Should Be Equal As Integers       ${time_diff}       ${expected_value}
    ${result}         Evaluate    (${expected_value} + 2.0) >= ${time_diff} >= (${expected_value} - 2.0)
    Should Be True    ${result}

verify number of NG path failed is greater minFailedPath
    [Arguments]     ${file_path}
    ${totalpathfailed}  OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i 'evaluate status' | awk '{print $13}' | head -1
    ${minfailedpath}    OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i 'evaluate status' | awk '{print $14}' | head -1
    ${totalpathfailed}      Split String    ${totalpathfailed}      :
    ${minfailedpath}        Split String    ${minfailedpath}         :
    Should be true      ${totalpathfailed}[1] > ${minfailedpath}[1]

Verify pathRecoveryWaitTimer
    [Arguments]     ${file_path}        ${expected_value}
    ${timer_start}  OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i "pathrecoverywaittimer started" | awk '{print $2}'
    ${timer_end}    OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i "pathrecoverywaittimer timed out" | awk '{print $2}'
    ${timer_start}      Split String    ${timer_start}      .
    ${timer_end}        Split String    ${timer_end}         .
    ${time_diff}    DateTime.Subtract Time from Time     ${timer_end}[0]        ${timer_start}[0]
#    Should Be Equal As Integers       ${time_diff}       ${expected_value}
    ${result}         Evaluate    (${expected_value} + 2.0) >= ${time_diff} >= (${expected_value} - 2.0)
    Should Be True    ${result}


Recover gtpu path failure for 1 path
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep   1s

Recover gtpu path failure for 4 paths
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.40,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.40,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.40,0

Recover gtpu path failure for 6 paths
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.2,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.40,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.40,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.40,0

NSA Multi UE Attach should be Successful Custom
    [Arguments]    ${Start_NSA_UE}    ${END_NSA_UE}     ${Target_Cells}     ${sgw_id}
    FOR  ${UE}  IN RANGE    ${Start_NSA_UE}    ${END_NSA_UE}+1
       NSA LTE Attach should be Successful Custom    ${UE}    ${SGW_ID}
       NSA UE Attach should be Successful Custom    ${UE}    ${Target_Cells}
    END

NSA LTE Attach should be Successful Custom
    [Arguments]    ${NSA_UE_ID}    ${SGW_ID}
    [Documentation]    This keyword creates the LTE Attach and checks the completion message in the output file, including SGW attach.
    ${sgw_attach_cmd}=    Set Variable    ue_mme_param id=${NSA_UE_ID} sgw_id=${SGW_ID}
    ute_wtssim.Execute Egate Command    ${sgw_attach_cmd}       timeout=${Timeout_NSA}
    BuiltIn.Log    sgw_attach_is_ok
    ${ue_attach_cmd}    SET VARIABLE    ue_attach id=${NSA_UE_ID}
    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_attach_cmd}    pass_regexp=${LTE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok

NSA UE Attach should be Successful Custom
    [Arguments]    ${NSA_UE_ID}    ${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Target_Cells} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ute_wtssim.Execute Egate Command And Wait For Data   ${en_dc_start_cmd}		pass_regexp=${UE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    en_dc_start_is_ok

Verify number of S1 path failed is greater minFailedPath
    [Arguments]     ${file_path}
    ${totalpathfailed}  OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i 'evaluate status' | awk '{print $13}' | head -1
    ${minfailedpath}    OperatingSystem.Run     cat ${file_path}/gnb_syslog.log | grep -i 'evaluate status' | awk '{print $14}' | head -1
    ${totalpathfailed}      Split String    ${totalpathfailed}      :
    ${minfailedpath}        Split String    ${minfailedpath}         :
    Should be true      ${totalpathfailed}[1] > ${minfailedpath}[1]

Trigger s1 gtpu path failure for 6 path
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=1 skip_echo_req=10.0.1.133,10.0.1.13,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.13,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=3 skip_echo_req=10.0.1.171,10.0.1.13,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=1 skip_echo_req=10.0.1.133,10.0.1.12,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.12,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=3 skip_echo_req=10.0.1.171,10.0.1.12,150

Recover s1 gtpu path failure for 6 path
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=1 skip_echo_req=10.0.1.133,10.0.1.13,0
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.13,0
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=3 skip_echo_req=10.0.1.171,10.0.1.13,0
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=1 skip_echo_req=10.0.1.133,10.0.1.12,0
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.12,0
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=3 skip_echo_req=10.0.1.171,10.0.1.12,0

Recover S1 Gtpu Path Failure For 1 Path
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.13,0
    sleep   1s

Trigger gtpu path failure for 3 path sgw1
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=1 skip_echo_req=10.0.1.133,10.0.1.13,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.13,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=3 skip_echo_req=10.0.1.171,10.0.1.13,150

Trigger gtpu path failure for 3 path sgw2
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=1 skip_echo_req=10.0.1.133,10.0.1.12,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.12,150
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=3 skip_echo_req=10.0.1.171,10.0.1.12,150

Check Only Cells Are Disabled
    [Arguments]    ${expected_avail_state}    ${expected_oper_state}    @{target_cells}
    coam.setup admin    bts_host=10.0.1.2

    ${nr_cells}=    coam.get_cells_info
    FOR    ${nr_cell}    IN    @{nr_cells}
    ${nr_cell_dn}=    Set Variable    ${nr_cell["id"]["configuration"]}
    ${is_target_cell}=    Run Keyword And Return Status    Should Contain    ${target_cells}    ${nr_cell_dn}

    IF    ${is_target_cell}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${availabilityStatus}=    Get From Dictionary    ${status_dict}    availabilityStatus
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState
        Should Be Equal    ${availabilityStatus}    ${expected_avail_state}
        Should Be Equal    ${operationalState}    ${expected_oper_state}
    END
    END

    [Teardown]    coam.teardown admin

Check Only Cells Are In Enabled State
    [Arguments]    ${expected_oper_state}   @{expected_cells}
    coam.setup admin    bts_host=10.0.1.2

    ${nr_cells}=    coam.get_cells_info
    FOR    ${nr_cell}    IN    @{nr_cells}
        ${nr_cell_dn}=    Set Variable    ${nr_cell["id"]["configuration"]}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState

        ${is_target_cell}=    Run Keyword And Return Status    Should Contain    ${expected_cells}    ${nr_cell_dn}
        IF    ${is_target_cell}
            Should Be Equal    ${operationalState}    ${expected_oper_state}
        END
    END

    [Teardown]    coam.teardown admin

Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}     ${IP}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
        SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
