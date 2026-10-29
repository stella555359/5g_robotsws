*** Settings ***
Documentation     This contains keywords used for CB008472 automation cases.
...               :author Rashmi Singh

Library         Collections
Library         ute_wtssim
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         ta5g_commissioning              WITH NAME    tcom
Library			taf.ul.alarms_watchdog
Variables       ta5g_global_var
Library         ta5g_enb
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../../T12/resources/PythonLib/UTILS.py
Library         traffic_validation.py
Resource        ${CURDIR}/../../../../T12/resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../ute/ute_wts_runner.robot
Resource        ${CURDIR}/../Keywords/common_keywords.robot



*** Variables ***
${host_index}
${AP_IP}                192.168.200.1
${AP_USERNAME}          toor4nsn
${AP_PASSWORD}          oZPS0POrRieRtu
${VLAN_ID}              ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}       MRBTS-1
${VLANIF_DISTNAME}      ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DELTACONFIGDIR}       ${CURDIR}/../../config/gnb_scf
${iphy}                 ${CURDIR}/../../config/ap_iphy/new_iphy.xml
${TOPOLOGY}     		CLOUD_5G_I_LO_AP_LO
${scf}       ${CURDIR}/../../config/gnb_scf/
${text2}=   Intra-cell handover
${LOG_PATH}			${OUTPUT_DIR}/CB008472

*** Keywords ***

Trigger VoNR Data
    [Documentation]    This Keyword is to start traffic in uplink and downlink for VoNR UEs for 5QI 1,5
	[Arguments]      ${ue_id}
    ...    ${pdu_id}=${PDU_SESION_ID}
    ...    ${TRF_ID}=${TRF_ID}
    ...    ${qfi_id}=${QFI_ID}
    ...    ${rtp_codec}=${RTP_COD}
	Log To Console    \nRunning VoNR DL/UL Traffic for ${rtp_codec}...
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl
    ...    trf_id=${TRF_ID}    rtp_codec=${rtp_codec}
    Pass Lua File       ${LUA_FILE}
	${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Downlink Internal traffic Receiver*
    ...         timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    TCP DL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_DL_traffic_data_is_started_successfully
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=ul    trf_id=${TRF_ID}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Uplink Internal traffic*      timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    TCP UL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_UL_traffic_data_is_started_successfully
    Pass Lua File       ${LUA_FILE}

AP Reboot
    [Documentation]     This KW can be used to do a soft-reboot to the AP
    ssh.Connect To      ${AP_IP}   ${AP_USERNAME}     ${AP_PASSWORD}     alias=AP_coam
    ssh.Execute     command=reboot      connection=AP_coam
    [Teardown]      ssh.Disconnect      connection=AP_coam

Register Multiple UEs
    [Documentation]    This Keyword is to register multiple SA UEs.
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        Log To Console      Starting Registration for SA UE: ${UE_ID}
        Enable Internal TG   ${UE_ID}    1
        wtsrunner.Ue Register   id=${UE_ID}
        Sleep   10s
        Pass Lua File       ${LUA_FILE}
        ${output}    Run Keyword And Ignore Error      Read WTS Output Until Pattern Matches
        ...         ${UE_register_complete_pattern}    ${Timeout_SA}
        Run Keyword If      ${output}!='PASS'
        ...     wtsrunner.ue_register   id=${UE_ID}
        Sleep   10s
        wtsrunner.Ue Pdu Session Setup    pdu=1    ue=${UE_ID}   nwslice=1   gw=1
        Sleep   15s
        Pass Lua File       ${LUA_FILE}
    END

Start data in Multiple UEs
    [Documentation]     This keyword starts data traffic in the downlink (DL) and uplink (UL) directions for multiple UEs
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        Log To Console    Running DL Traffic for UE:${UE_ID}
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
        ...    mbps=2    dir=dl    trf_id=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
        Log to Console    ${output}
        sleep    5s
        Pass Lua File       ${LUA_FILE}
        Log To Console    Running UL Traffic for UE:${UE_ID}
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
        ...    mbps=2    dir=ul    trf_id=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
        Log to Console    ${output}
        sleep    5s
        Pass Lua File       ${LUA_FILE}
    END

Verify bytes sent in Multiple UEs in DL UL direction
    [Documentation]    This keyword verifies the number of bytes sent in the downlink (DL) and uplink (UL) directions for multiple UEs
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in DL direction
        bearer_stats    ue=${UE_ID}     pdu=1   qfi=1   dir=dl
        Pass Lua File       ${LUA_FILE}
        Sleep   2s
        ${output}    Read WTS Output Until Pattern Matches      Data packets sent   60
        ${bytes_count}    check_bytes_sent   ${output}
        ${num1}    Convert To Number    ${bytes_count}
        ${stored_bytes_count_DL}[${UE_ID}]    Set Variable    ${num1}
        sleep    2s
        Pass Lua File       ${LUA_FILE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in UL direction
        bearer_stats    ue=${UE_ID}     pdu=1   qfi=1   dir=ul
        Pass Lua File       ${LUA_FILE}
        Sleep   2s
        ${output}    Read WTS Output Until Pattern Matches      Data packets sent    60
        ${bytes_count}    check_bytes_sent   ${output}
        ${num2}    Convert To Number    ${bytes_count}
        Set Variable    ${stored_bytes_count_UL}    ${num2}
        sleep    2s
        Pass Lua File       ${LUA_FILE}
     END


Data validation before HO
    [Documentation]     These keywords are related to testing and validation of data traffic in a network before handover
    Log To Console      \n Verifying packet count before HO
    Verify packet count in Multiple UEs in DL UL direction      1      2      1
    Verify packet count in Multiple UEs in DL UL direction      1      2      2
    Verify packet count in Multiple UEs in DL UL direction      1      2      3
    Pass Lua File       ${LUA_FILE}
    Log To Console      \n Verifying bytes sent before HO
    Verify bytes sent in Multiple UEs in DL UL direction before HO      1     2     1
    Verify bytes sent in Multiple UEs in DL UL direction before HO      1     2     2
    Verify bytes sent in Multiple UEs in DL UL direction before HO      1     2     3

Data validation after HO
    [Documentation]      These keywords are related to testing and validation of data traffic in a network after handover
    Log To Console      \n Verifying packet count after HO
    Verify packet count in Multiple UEs in DL UL direction      1      2      1
    Verify packet count in Multiple UEs in DL UL direction      1      2      2
    Verify packet count in Multiple UEs in DL UL direction      1      2     3
    Pass Lua File       ${LUA_FILE}
    Log To Console      \n Verifying bytes sent after HO
    Verify bytes sent in Multiple UEs in DL UL direction after HO      1     2     1
    Verify bytes sent in Multiple UEs in DL UL direction after HO      1     2     2
    Verify bytes sent in Multiple UEs in DL UL direction after HO      1     2     3
    Pass Lua File       ${LUA_FILE}
    Compare Dicts Value Greater     ${DL_BYTES_DICT}    ${DL_BYTES_DICT_AFTER_HO}
    Compare Dicts Value Greater     ${UL_BYTES_DICT}    ${UL_BYTES_DICT_AFTER_HO}


Initiate VoNR SA UEs
    [Documentation]    This Keyword is to start traffic in uplink and downlink for VoNR UEs
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}      Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        Log To Console      Starting VoNR traffic for SA UE: ${UE_ID}
        wtsrunner.ue_pdu_session_modify      ue=${UE_ID}       pdu=1    qosflows_to_add=5   by=amf
        Sleep   2s
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=2   mbps=2    dir=dl    trf_id=1
        Sleep   2s
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=2    mbps=2   dir=ul    trf_id=1
        Sleep   2s
        wtsrunner.ue_pdu_session_modify      ue=${UE_ID}        pdu=1       qosflows_to_add=6       by=amf
        Sleep   2s
        Trigger VoNR Data   ${UE_ID}   1   1   3  amr_wb_18_25
        Sleep   2s
    END

Teardown for CB008472
    [Documentation]    This keyword is to bring down the test environment for CB008472
    Syslog_Alarm_Stop
    Collect Snapshot
    GNB Delta Commission    ${scf}/reverse_delta.json
    ue_deregister    id=all      ue_deregister_type=switch_off
    sleep   120s
    Wait Coam Site to be Ready
    RAT Block Unblock


Prepare For Test Case CB008472
    [Documentation]     This keyword loads all required configurations like scf, cfg
    ${Log_Path}      Create Log Directory    CB008472
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
	Create Basic Interface On UTE
	Add RD Parameters Directly On GNB      ${SW_FlAG}
    GNB Delta Commission    ${scf}/delta_tmo.json
    Site Reset For Gnb
    Sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS      CB008472_basic_setup.cfg
    Basic Bring Up
    Syslog_Alarm_Setup


Site Reset For Gnb
    [Documentation]     This keyword is used to Site Reset
    admin.Setup Admin
    admin.reset_site      reset_coverage=Site     wait_for_reconnection=True    graceful_cell_shutdown=True
    [Teardown]      admin.Teardown Admin


Stop pcap collection in gNB 8472
    [Documentation]     This keyword is used to stop pcap collection
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}

Perform PDU Session Setup and Release
    [Documentation]    This Keyword is to register multiple SA UEs.
    [Arguments]             ${Start}     ${End}
    ${i}      Evaluate    ${End}+1
    FOR    ${i}    IN RANGE    ${Start}     ${End}
        Log To Console      Starting Registration for iteration: ${i}
        pdu session setup and release for different UEs    1    2
    END

Verify Intra-HO
    [Documentation]    This keyword Simulates a Handover (HO) scenario in a cellular network by PDU session release
    ...                for a range of UE IDs, triggering a handover and verifying that the handover is successfully triggered
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}      Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        wtsrunner.Ue Pdu Session Setup    ue=${UE_ID}     pdu=2     nwslice=1   gw=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        wtsrunner.ue_pdu_session_release    ue=${UE_ID}    pdu=2    by=amf
        sleep    5s
        ${output}    wtsrunner.Read Wtsemu Output Until       expected=UE${UE_ID}: Intra-cell handover    timeout=120
        Pass Lua File       ${LUA_FILE}
    END

verify pcap drb_ID
    [Documentation]    This Keyword is to verify drb_id assigned
    [Arguments]             ${file_path}      ${drb_filter}    ${count_of_messages}
    Get Fields From Pcap        ${file_path}      e1ap.System_BearerContextModificationResponse && e1ap.dRB_ID      e1ap.dRB_ID
    Count Of Messages Matching Filter Should Be Equal     ${file_path}        ${drb_filter}
    ...        BearerContextModificationResponse        ${count_of_messages}

pdu session setup and release for different UEs
   [Documentation]    This Keyword is to start pdu session setup and release for multiple UEs
   [Arguments]             ${Start_UE}     ${End_UE}
   ${End_UE}      Evaluate    ${End_UE}+1
   FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
         wtsrunner.Ue Pdu Session Setup    ue=${UE_ID}      pdu=2   nwslice=1   gw=1
         Pass Lua File       ${LUA_FILE}
         Sleep   5s
         wtsrunner.ue_pdu_session_release    ue=${UE_ID}    pdu=2    by=amf
         Pass Lua File       ${LUA_FILE}
         Sleep   5s
   END

Verify packet count in Multiple UEs in DL UL direction
    [Documentation]     This keyword verifies the packet count in the downlink (DL) and uplink (UL) directions for multiple UEs
    [Arguments]             ${Start_UE}     ${End_UE}      ${QFI_ID}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in DL direction for ${QFI_ID}
        bearer_stats    ue=${UE_ID}      qfi=${QFI_ID}    pdu=1   dir=dl
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    Read WTS Output Until Pattern Matches      Silence packets sent   60
        ${packet_count}    check_received_packets    ${output}
        ${num1}    Convert To Number    ${packet_count}
        ${num2}    Convert To Number    0
        Should Not Be Equal As Numbers    ${num1}    ${num2}
        sleep    5s
        Pass Lua File       ${LUA_FILE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in UL direction for ${QFI_ID}
        bearer_stats    ue=${UE_ID}       qfi=${QFI_ID}     pdu=1   dir=ul
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    Read WTS Output Until Pattern Matches      Silence packets sent    60
        ${packet_count}    check_received_packets    ${output}
        ${num1}    Convert To Number    ${packet_count}
        ${num2}    Convert To Number    0
        Should Not Be Equal As Numbers    ${num1}    ${num2}
        sleep    5s
        Pass Lua File       ${LUA_FILE}
     END

Verify bytes sent in Multiple UEs in DL UL direction before HO
    [Documentation]   This keyword verifies the number of bytes sent in the downlink (DL) and uplink (UL)
    ...               directions for multiple UEs before handover (HO) event
    [Arguments]             ${Start_UE}     ${End_UE}    ${QFI_ID}
    ${End_UE}    Evaluate    ${End_UE}+1
    &{DL_BYTES_DICT}=    Create Dictionary
    &{UL_BYTES_DICT}=    Create Dictionary
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in DL direction for ${QFI_ID}
        bearer_stats    ue=${UE_ID}      qfi=${QFI_ID}     pdu=1   dir=dl
        Pass Lua File       ${LUA_FILE}
        Sleep   2s
        ${output}    Read WTS Output Until Pattern Matches      Data packets sent   60
        ${bytes_count}    check_bytes_sent   ${output}
        ${num1}    Convert To Number    ${bytes_count}
        ${UE_ID_STR} =  Convert To String  ${UE_ID}
        Set To Dictionary  ${DL_BYTES_DICT}  ${UE_ID_STR}=${num1}
        Sleep    2s
        Pass Lua File       ${LUA_FILE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in UL direction for ${QFI_ID}
        bearer_stats    ue=${UE_ID}       qfi=${QFI_ID}      pdu=1   dir=ul
        Pass Lua File       ${LUA_FILE}
        Sleep   2s
        ${output}    Read WTS Output Until Pattern Matches      Data packets sent    60
        ${bytes_count}    check_bytes_sent   ${output}
        ${num2}    Convert To Number    ${bytes_count}
        ${UE_ID_STR} =  Convert To String  ${UE_ID}
        Set To Dictionary  ${UL_BYTES_DICT}  ${UE_ID_STR}=${num2}
        Sleep    2s
        Pass Lua File       ${LUA_FILE}
    END
    LOG TO CONSOLE    ${DL_BYTES_DICT}
    SET GLOBAL VARIABLE    ${DL_BYTES_DICT}
    LOG TO CONSOLE    ${UL_BYTES_DICT}
    SET GLOBAL VARIABLE    ${UL_BYTES_DICT}

Verify bytes sent in Multiple UEs in DL UL direction after HO
    [Documentation]   This keyword verifies the number of bytes sent in the downlink (DL) and uplink (UL)
     ...              directions for multiple UEs after a handover (HO) event
    [Arguments]             ${Start_UE}     ${End_UE}    ${QFI_ID}
    ${End_UE}    Evaluate    ${End_UE}+1
    &{DL_BYTES_DICT_AFTER_HO}=    Create Dictionary
    &{UL_BYTES_DICT_AFTER_HO}=    Create Dictionary
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in DL direction for ${QFI_ID}
        bearer_stats    ue=${UE_ID}      qfi=${QFI_ID}    pdu=1    dir=dl
        Pass Lua File       ${LUA_FILE}
        Sleep   2s
        ${output}    Read WTS Output Until Pattern Matches      Data packets sent   60
        ${bytes_count}    check_bytes_sent   ${output}
        ${num1}    Convert To Number    ${bytes_count}
        ${UE_ID_STR} =  Convert To String  ${UE_ID}
        Set To Dictionary  ${DL_BYTES_DICT_AFTER_HO}  ${UE_ID_STR}=${num1}
        Sleep    2s
        Pass Lua File       ${LUA_FILE}
        LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in UL direction for ${QFI_ID}
        bearer_stats    ue=${UE_ID}      qfi=${QFI_ID}   pdu=1   dir=ul
        Pass Lua File       ${LUA_FILE}
        Sleep   2s
        ${output}    Read WTS Output Until Pattern Matches      Data packets sent    60
        ${bytes_count}    check_bytes_sent   ${output}
        ${num2}    Convert To Number    ${bytes_count}
        ${UE_ID_STR} =  Convert To String  ${UE_ID}
        Set To Dictionary  ${UL_BYTES_DICT_AFTER_HO}  ${UE_ID_STR}=${num2}
        Sleep    2s
        Pass Lua File       ${LUA_FILE}
    END
    LOG TO CONSOLE    ${DL_BYTES_DICT_AFTER_HO}
    SET GLOBAL VARIABLE    ${DL_BYTES_DICT_AFTER_HO}
    LOG TO CONSOLE    ${UL_BYTES_DICT_AFTER_HO}
    SET GLOBAL VARIABLE    ${UL_BYTES_DICT_AFTER_HO}

Compare Dicts Value Greater
    [Documentation]     This keyword is used for compare DL and UL data before and after HO
    [Arguments]    ${dict_a}    ${dict_b}
    FOR    ${key}    IN    @{dict_a.keys()}
        ${value_a}=    Get From Dictionary    ${dict_a}    ${key}
        ${value_b}=    Get From Dictionary    ${dict_b}    ${key}
        ${is_greater}=    Evaluate    int(${value_b}) > int(${value_a})
        Run Keyword If    ${is_greater}    Log TO CONSOLE   ${key}: ${value_b} > ${value_a}
        ...    ELSE    Log TO CONSOLE   ${key}: ${value_b} <= ${value_a}    WARN
    END

Syslog_Alarm_Setup
    slog.Start Syslog     ${LOG_PATH}/${TEST NAME}   SYSLOG_1.LOG
    Log to Console    \nSyslog started
    Monitor Alarm
    taf.ul.alarms_watchdog.get_active_alarms


Monitor Alarm
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms
    ${allowed_alarms}=      Accepted_alarm_list
    Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=oam
	Log to console	Alarm monitoring started

Accepted_alarm_list
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled
    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled
    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled
    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443
    ${allowed_alarm_6}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4592
    ...                    fault_name=BTS Reset Cause
    ${allowed_alarm_7}=    Create alarm
    ...                    alarm_id=7107
    ...                    fault_id=6203
    ...                    fault_name=Transport layer connection failure in X2 interface
    ${allowed_alarm_8}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4459
    ...                    fault_name=User Account has Default Password
    ${allowed_alarm_9}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=8000
    ...                    fault_name=Failure in connection between BTS and 3rd party tool
	${allowed_alarm_10}=   Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61510
    ...                    fault_name=Automatic BTS Operator Certificate retrieval unsuccessful
    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}
    ...                    ${allowed_alarm_6}
    ...                    ${allowed_alarm_7}
    ...                    ${allowed_alarm_8}
    ...                    ${allowed_alarm_9}
	...                    ${allowed_alarm_10}
    [Return]    ${allowed_alarms}

Syslog_Alarm_Stop
    Log to Console    \n Teardown is started
	syslog validation for error prints
	Collect Syslog Results                destination=${LOG_PATH}/${TEST NAME}
    check_detected_alarms
    taf.ul.alarms_watchdog.get_active_alarms
    stop_watching_alarms

syslog validation for error prints
    Count Syslog Messages       ERR/
    Count Syslog Messages       Fatal
    ${ERR}   	Count syslog messages       regexp=ERR/
    ${Fatal}	Count syslog messages       regexp=Fatal
    Run keyword If	"${ERR}" != "0"		LOG		Error prints are present	WARN	console=yes
    Run keyword If	"${Fatal}" != "0"	LOG		Fatal prints are present	ERROR	console=yes

Collect Snapshot
	Log to console		Snapshot collection started
    Snapshot Collection     ${LOG_PATH}     Snapshot.zip

Register UE
    [Documentation]    This Keyword is to register SA UE.
    [Arguments]             ${UE_ID}
    Log To Console      Starting Registration for SA UE: ${UE_ID}
    Enable Internal TG   ${UE_ID}    1
    wtsrunner.Ue Register   id=${UE_ID}
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    ${output}    Run Keyword And Ignore Error      Read WTS Output Until Pattern Matches
    ...         ${UE_register_complete_pattern}    ${Timeout_SA}
    Run Keyword If      ${output}!='PASS'
    ...     wtsrunner.ue_register   id=${UE_ID}
    Sleep   10s
    wtsrunner.Ue Pdu Session Setup    pdu=1    ue=${UE_ID}   nwslice=1   gw=1
    Sleep   15s
    Pass Lua File       ${LUA_FILE}

Set UE location and source GNB SIB periodicity
    ute_wtssim.execute_egate_command	cmd=gnb_param id=3 sib1_period=40
    Sleep   5s
	ute_wtssim.execute_egate_command	cmd=gnb_param id=3 sib2_period=40
	Sleep   5s
	ute_wtssim.execute_egate_command	cmd=gnb_param id=3 sib5_period=40
	Sleep   5s
	Pass Lua File       ${LUA_FILE}
	ute_wtssim.execute_egate_command	cmd=ue_change_location id=1 enb=3 cell=1
	Sleep   5s

Start Egate
	ute_wtssim.Setup Egate		egate_port=20000
    ute_wtssim.Setup Edaemon	edaemon_port=22222

Start data in UE
    [Documentation]     This keyword starts data traffic in the downlink (DL) and uplink (UL) directions for multiple UEs
    [Arguments]             ${UE_ID}
    Log To Console    Running DL Traffic for UE:${UE_ID}
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
    ...    mbps=2    dir=dl    trf_id=1
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s
    Pass Lua File       ${LUA_FILE}
    Log To Console    Running UL Traffic for UE:${UE_ID}
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
    ...    mbps=2    dir=ul    trf_id=1
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s
    Pass Lua File       ${LUA_FILE}

Teardown for CB008472_2
    [Documentation]    This keyword is to bring down the test environment for CB008472
    Syslog_Alarm_Stop
    Collect Snapshot_post
    Link SCOUT SCF To Configuration ID For Reporting
    GNB Delta Commission    ${scf}/reverse_delta_xn.json
    ue_deregister    id=all      ue_deregister_type=switch_off
    sleep   120s
    Wait Coam Site to be Ready

Prepare For Test Case CB008472_2
    [Documentation]     This keyword loads all required configurations like scf, cfg
    ${Log_Path}      Create Log Directory    CB008472
#    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
	Create Basic Interface On UTE
	Add RD Parameters Directly On GNB      ${SW_FlAG}
    GNB Delta Commission    ${scf}/delta_tmo_xn.json
    Site Reset For Gnb
    Sleep   60s
    Wait Coam Site to be Ready
    Start UTE WTS      CB008472_xn_basic_setup.cfg
    Basic Bring Up
    Collect Snapshot_pre
    Syslog_Alarm_Setup

Perform multiple PDU Session Setup
    [Documentation]    This Keyword is to register multiple SA UEs.
    [Arguments]             ${Start}     ${End}
    ${i}      Evaluate    ${End}+1
    FOR    ${i}    IN RANGE    ${Start}     ${End}
        Log To Console      Starting Registration for iteration: ${i}
        wtsrunner.set_pdu_param    ue=1   pdu=${i}    trf_type=internal
        sleep   5s
        Pass Lua File       ${LUA_FILE}
        wtsrunner.ue_pdu_session_setup     ue=1    pdu=${i}    nwslice=1   gw=1
        sleep   5s
        Pass Lua File       ${LUA_FILE}
    END

Perform and verify XN HO
    Log to Console		\n Triggereing Xn HO from RANSIM
    ute_wtssim.execute_egate_command
    ...     cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100

    ute_wtssim.execute_egate_command     cmd=ue_history_information_list id=1 action=commit
    Sleep   5s
    ute_wtssim.execute_egate_command     cmd=ue_enb_param id=1 ue_history_list=1
#    Pass Lua File       ${LUA_FILE}
	wtsrunner.ue_measurement_send_nr	id=1	meas_id=3	event=A3	srsrp_nr=10	srsrq_nr=10	phycell_id=51	nrsrp_nr=49	nrsrq_nr=49
	Sleep   5s
#	Pass Lua File       ${LUA_FILE}
	wtsrunner.Read_Wtsemu_Output_Until		expected=GNB-3: UE1: XN Handover Successfully completed at Source		timeout=20
	Log to Console		\n Xn HO from RANSIM successful

Verify Intracell_HO
        wtsrunner.ue_pdu_session_release    ue=1    pdu=2    by=amf
        sleep    5s
        ${output}    wtsrunner.Read Wtsemu Output Until       expected=UE1: Intra-cell handover    timeout=120
        Pass Lua File       ${LUA_FILE}

pdu session release for pdu2
         wtsrunner.ue_pdu_session_release    ue=1    pdu=2    by=amf
         Pass Lua File       ${LUA_FILE}
         Sleep   5s

Verify Data Before HO
    [Documentation]     This keyword verifies the packet count in the downlink (DL) and uplink (UL) directions for UEs
    [Arguments]             ${UE_ID}     ${QFI_ID}
    LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in DL direction for ${QFI_ID}
    bearer_stats    ue=${UE_ID}      qfi=${QFI_ID}    pdu=1   dir=dl
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    Read WTS Output Until Pattern Matches      Silence packets sent   60
    ${packet_count}    check_received_packets    ${output}
    ${num1}    Convert To Number    ${packet_count}
    ${num2}    Convert To Number    0
    Should Not Be Equal As Numbers    ${num1}    ${num2}
    sleep    5s
    Pass Lua File       ${LUA_FILE}
    LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in UL direction for ${QFI_ID}
    bearer_stats    ue=${UE_ID}       qfi=${QFI_ID}     pdu=1   dir=ul
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    Read WTS Output Until Pattern Matches      Silence packets sent    60
    ${packet_count}    check_received_packets    ${output}
    ${num1}    Convert To Number    ${packet_count}
    ${num2}    Convert To Number    0
    Should Not Be Equal As Numbers    ${num1}    ${num2}
    sleep    5s
    Pass Lua File       ${LUA_FILE}

Verify Data After HO
    [Documentation]     This keyword verifies the packet count in the downlink (DL) and uplink (UL) directions for UEs
    [Arguments]             ${UE_ID}     ${QFI_ID}
    LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in DL direction for ${QFI_ID}
    bearer_stats    ue=${UE_ID}      qfi=${QFI_ID}    pdu=1   dir=dl
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    Read WTS Output Until Pattern Matches      Silence packets sent   60
    ${packet_count}    check_received_packets    ${output}
    ${num1}    Convert To Number    ${packet_count}
    ${num2}    Convert To Number    0
    Should Not Be Equal As Numbers    ${num1}    ${num2}
    sleep    5s
    Pass Lua File       ${LUA_FILE}
    LOG TO CONSOLE     \n Bearer stats for UE '${UE_ID}' in UL direction for ${QFI_ID}
    bearer_stats    ue=${UE_ID}       qfi=${QFI_ID}     pdu=1   dir=ul
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    Read WTS Output Until Pattern Matches      Silence packets sent    60
    ${packet_count}    check_received_packets    ${output}
    ${num1}    Convert To Number    ${packet_count}
    ${num2}    Convert To Number    0
    Should Not Be Equal As Numbers    ${num1}    ${num2}
    sleep    5s
    Pass Lua File       ${LUA_FILE}

Collect Snapshot_pre
	Log to console		Snapshot collection started
    Snapshot Collection     ${LOG_PATH}     pre_Snapshot.zip

Collect Snapshot_post
	Log to console		Snapshot collection started
    Snapshot Collection     ${LOG_PATH}     post_Snapshot.zip

Teardown for CB008472_3
    [Documentation]    This keyword is to bring down the test environment for CB008472
    Run Keyword And Ignore Error    Syslog_Alarm_Stop
#    Collect Snapshot_post
#    Link SCOUT SCF To Configuration ID For Reporting
    GNB Delta Commission    ${scf}/reverse_ca_tmon.json
    ue_deregister    id=all      ue_deregister_type=switch_off
    sleep   120s
    Wait Coam Site to be Ready

Prepare For Test Case CB008472_3
    [Documentation]     This keyword loads all required configurations like scf, cfg
    ${Log_Path}      Create Log Directory    CB008472
#    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
	Create Basic Interface On UTE
	Add RD Parameters Directly On GNB      ${SW_FlAG}
    GNB Delta Commission    ${scf}/delta_ca_tmon.json
#    Site Reset For Gnb
    Sleep   60s
    Wait Coam Site to be Ready
    Start UTE WTS           basic_setup_ca.cfg
    Basic Bring Up
#    Collect Snapshot_pre
    Syslog_Alarm_Setup

Verify Intracell_HO and scell addition afterwards
        wtsrunner.ue_pdu_session_release    ue=1    pdu=2    by=amf
        sleep    5s
        ${output}    wtsrunner.Read Wtsemu Output Until       expected=UE1: Intra-cell handover    timeout=120
        sleep    10s
        Pass Lua File       ${LUA_FILE}
        ${output}    wtsrunner.Read Wtsemu Output Until Re        expected=SCe\\s+llIndex\\s+\\d+\\s+activated\\s+successfully\\s+at\\s+airphone
        ...      timeout=180
        Pass Lua File       ${LUA_FILE}

pdu session setup for pdu2
   [Documentation]    This Keyword is to start pdu session setup and release for multiple UEs
   wtsrunner.Ue Pdu Session Setup    ue=1      pdu=2   nwslice=1   gw=1
   Pass Lua File       ${LUA_FILE}
   Sleep   5s

Register UE and verify blind scell addition
    [Documentation]    This Keyword is to register SA UE.
    [Arguments]             ${UE_ID}
    Log To Console      Starting Registration for SA UE: ${UE_ID}
    Enable Internal TG   ${UE_ID}    1
    wtsrunner.Ue Register   id=${UE_ID}
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    ${output}    Run Keyword And Ignore Error      Read WTS Output Until Pattern Matches
    ...         ${UE_register_complete_pattern}    ${Timeout_SA}
    Run Keyword If      ${output}!='PASS'
    ...     wtsrunner.ue_register   id=${UE_ID}
    Sleep   10s
    wtsrunner.Ue Pdu Session Setup    pdu=1    ue=${UE_ID}   nwslice=1   gw=1
    Sleep   5s
    Pass Lua File       ${LUA_FILE}
    ${output}    wtsrunner.Read Wtsemu Output Until Re        expected=SCe\\s+llIndex\\s+\\d+\\s+activated\\s+successfully\\s+at\\s+airphone
    ...      timeout=180
    Pass Lua File       ${LUA_FILE}

pdu session setup and release for UE
   [Documentation]    This Keyword is to start pdu session setup and release for multiple UEs
   [Arguments]             ${Start}     ${End}
   ${i}      Evaluate    ${End}+1
   FOR    ${i}    IN RANGE    ${Start}     ${End}
         wtsrunner.Ue Pdu Session Setup    ue=1      pdu=2   nwslice=1   gw=1
         Pass Lua File       ${LUA_FILE}
         Sleep   5s
         wtsrunner.ue_pdu_session_release    ue=1    pdu=2    by=amf
         Pass Lua File       ${LUA_FILE}
         Sleep   5s
   END


Start high data traffic in UE
    [Documentation]     This keyword starts data traffic in the downlink (DL) and uplink (UL) directions for multiple UEs
    [Arguments]             ${UE_ID}
    Log To Console    Running DL Traffic for UE:${UE_ID}
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
    ...    mbps=150    dir=dl    trf_id=1
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
    ...    mbps=150    dir=dl    trf_id=2
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
    ...    mbps=150    dir=dl    trf_id=3
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
    ...    mbps=150    dir=dl    trf_id=4
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s
    Pass Lua File       ${LUA_FILE}
    Log To Console    Running UL Traffic for UE:${UE_ID}
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
    ...    mbps=2    dir=ul    trf_id=1
    Pass Lua File       ${LUA_FILE}
    Sleep   5s
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s
    Pass Lua File       ${LUA_FILE}