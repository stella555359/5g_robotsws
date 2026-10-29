*** Settings ***
Documentation     This contains keywords used for CB012623 automation cases.
...               :author Vicky Raina

Library         Collections
Library         ute_wtssim
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         ta5g_commissioning              WITH NAME    tcom
Variables       ta5g_global_var
Library         ta5g_enb
Library		taf.ul.alarms_watchdog
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../../T12/resources/PythonLib/UTILS.py
Library         traffic_validation.py
Resource        ${CURDIR}/../../../../T12/resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../ute/ute_wts_runner.robot
Resource        ${CURDIR}/../Keywords/common_keywords.robot


*** Variables ***
${AP_IP}                192.168.200.1
${AP_USERNAME}          toor4nsn
${AP_PASSWORD}          oZPS0POrRieRtu
#${VLAN_ID}              ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}       MRBTS-1
${VLANIF_DISTNAME}      ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DELTACONFIGDIR}       ${CURDIR}/../../config/gnb_scf
${iphy}                 ${CURDIR}/../../config/ap_iphy/new_iphy.xml
${TOPOLOGY}     		CLOUD_5G_I_LO_AP_LO
${RAD_PARAMETER}        0x8900A9=500
${RI_MONITORING_PERIOD}		5m
${CELL_NOISE_TESTMODE}      ul_cell_noise
${scf}       ${CURDIR}/../../config/gnb_scf/
${DL_BLER}                 600
${SLOT_TYPE}				1
${SLOTS_SSB}				14
${SSB_PERIOD}				20

${text2}=   Intra-eNB handover from EXT_ENB-2.4 to EXT_ENB-2.1
*** Keywords ***
Full Commision Scf And Iphy
    [Documentation]    This keyword is used to change SCF and IPHY file
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy Xml
    ...      input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'     Full Commission With SCF File For UTE
    ...    ${scf}

Commision Iphy
    [Documentation]    This keyword is used to change RMOD type
    [Arguments]   ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy Xml
    ...      input_filepath=${iphy}

Activate Cell TestMode
    [Documentation]    This Keyword is to activate UE specific testmode commands
    [Arguments]     ${gNBID}      ${CELL_ID}	${Testmode_name}    ${action}    ${Profile_Id_number}
    Cell Testmode Set Nr      gnb=${gNBID}      cell_id=${CELL_ID}		testmode=${Testmode_name}
	...		action=${action}       profile_id=${Profile_Id_number}

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
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_DL_traffic_data_is_started_successfully
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=ul    trf_id=${TRF_ID}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Uplink Internal traffic*      timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_UL_traffic_data_is_started_successfully
    Pass Lua File       ${LUA_FILE}

AP Reboot
    [Documentation]     This KW can be used to do a soft-reboot to the AP
    ssh.Connect To      ${AP_IP}   ${AP_USERNAME}     ${AP_PASSWORD}     alias=AP_coam
    ssh.Execute     command=reboot      connection=AP_coam
    [Teardown]      ssh.Disconnect      connection=AP_coam
Setup UL BLER Testmode
    [Documentation]    This Keyword is to set up ul bler testmode command
    [Arguments]     ${profile_id}    ${bler_value}
    Bler Testmode Nr    profile_id=${profile_id}    ul_bler=${bler_value}
    bler_testmode_nr     profile_id=1
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
        ...    mbps=70    dir=dl    trf_id=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
        Log to Console    ${output}
        sleep    5s
        Pass Lua File       ${LUA_FILE}
        Log To Console    Running UL Traffic for UE:${UE_ID}
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=tcp
        ...    mbps=10    dir=ul    trf_id=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over TCP   timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
        Log to Console    ${output}
        sleep    5s
        Pass Lua File       ${LUA_FILE}
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
Syslog_Alarm_Stop
    Log to Console    \n Teardown is started
	syslog validation for error prints
	Collect Syslog Results                destination=${Log_Path1}/
    check_detected_alarms
    taf.ul.alarms_watchdog.get_active_alarms
    stop_watching_alarms
syslog validation for error prints
    Count Syslog Messages       ERR/L2-PS
    Count Syslog Messages       Fatal
    Count Syslog Messages	WRN/L2-PS
    ${ERR}   	Count syslog messages       regexp=ERR/L2-PS
    ${Fatal}	Count syslog messages       regexp=Fatal
    ${WRN}   	Count syslog messages       regexp=WRN/L2-PS
    Run keyword If	"${ERR}" != "0"		LOG		Error prints are present	WARN	console=yes
    Run keyword If	"${Fatal}" != "0"	LOG		Fatal prints are present	ERROR	console=yes
    Run keyword If	"${WRN}" != "0"	LOG		WRN prints are present	WRN	console=yes
Collect Snapshot_post
	Log to console		Snapshot collection started
    Snapshot Collection     ${Log_Path1}     post_Snapshot.zip
Teardown for CB012623_A
    [Documentation]    This keyword is to bring down the test environment for CB012623_A Test Case
    Syslog_Alarm_Stop
	Collect Snapshot_post
    ue_deregister    id=all      ue_deregister_type=switch_off
    sleep   120s
    Wait Coam Site to be Ready
Teardown for CB012623_B
    [Documentation]    This keyword is to bring down the test environment for CB012623_B Test Case
    Syslog_Alarm_Stop
	Collect Snapshot_post
    ue_deregister    id=all      ue_deregister_type=switch_off
    sleep   120s
    Wait Coam Site to be Ready
Collect Snapshot_pre
	Log to console		Snapshot collection started
    Snapshot Collection     ${Log_Path1}     pre_Snapshot.zip

Syslog_Alarm_Setup
    slog.Start Syslog     ${Log_Path1}/   SYSLOG_1.LOG
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
Prepare For Test Case CB012623_A
    [Documentation]     This keyword loads all required configurations like scf, cfg
    ${Log_Path1}      Create Log Directory    CB012623_A
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path1}
	Create Basic Interface On UTE
    GNB Delta Commission    ${scf}/deltaA.json
    Site Reset For Gnb
    Sleep   540s
    Wait Coam Site to be Ready
    Start UTE WTS      CB012623_basic_setup.cfg
    Basic Bring Up
	Collect Snapshot_pre
	Syslog_Alarm_Setup
Prepare For Test Case CB012623_B
    [Documentation]     This keyword loads all required configurations like scf, cfg
    ${Log_Path1}      Create Log Directory    CB012623_B
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path1}
	Create Basic Interface On UTE
    GNB Delta Commission    ${scf}/deltaB.json
    Site Reset For Gnb
    Sleep   540s
    Wait Coam Site to be Ready
    Start UTE WTS      CB012623_basic_setup.cfg
    Basic Bring Up
	Collect Snapshot_pre
	Syslog_Alarm_Setup

Add UE BLER Testmode And Activate
    [Documentation]    This Keyword helps to create BLER Testmode and then Activate
    ...                the specific requested UE with same profile.testmode and action are hardcoded as
    ...                This is the specific requirement from the Keyword. Hence to be used for Same purpose only.
    ...                ${UEID}  :   UE for which pathloss has to be activated.
    ...                ${ProfId}:   Profile Ids that will be used for Activating or Deactivating
	[Arguments]     ${Start_UE}     ${End_UE}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
    wtsrunner.BLER TESTMODE NR      profile_id=${UEID}      dl_bler=${DL_BLER}      dl_bler_slot_type=${SLOT_TYPE}
	...    dl_slots_for_ssb_im=${SLOTS_SSB}      period_for_ssb_im=${SSB_PERIOD}
    sleep	5s
    wtsrunner.UE Testmode Set NR    id=${UEID}    testmode=bler
    ...    profile_id=${UEID}     action=activate
    sleep	5s
    END
Site Reset For Gnb
    [Documentation]     This keyword is used to Site Reset
    admin.Setup Admin
    admin.reset_site      reset_coverage=Site     wait_for_reconnection=True    graceful_cell_shutdown=True
    [Teardown]      admin.Teardown Admin