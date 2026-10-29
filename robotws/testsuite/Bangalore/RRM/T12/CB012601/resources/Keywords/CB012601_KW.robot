*** Settings ***
Documentation     This contains keywords used for CB012601 automation cases.
...               :author Tom Toby

Library         Collections
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Variables       ta5g_global_var
Library         ta5g_enb
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../ute/ute_wts_runner.robot
Resource        ${CURDIR}/../Keywords/common_keywords.robot


*** Variables ***
${AP_IP}                192.168.200.1
${AP_USERNAME}          toor4nsn
${AP_PASSWORD}          oZPS0POrRieRtu
${VLAN_ID}              ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}       MRBTS-1
${VLANIF_DISTNAME}      ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DELTACONFIGDIR}       ${CURDIR}/../../config/gnb_scf
${APCONFIGDIR}          ${CURDIR}/../../config/ap_iphy
${TOPOLOGY}     		CLOUD_5G_I_LO_AP_LO
${RAD_PARAMETER}        0x580161=15
${RI_MONITORING_PERIOD}		5m
${CELL_NOISE_TESTMODE}      ul_cell_noise


*** Keywords ***
Get UEcontext Release Cause
    [Documentation]    This Keyword is to verify UE context release due to redirection triggered
    ...                when uplink radio conditions are bad
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]          ${PCAP_FILE}
    ${NGAP_CONTEXT_RELEASE}          Get Fields From Pcap     ${PCAP_FILE}
    ...     (ngap.procedureCode == 42)         ngap.radioNetwork
    @{NGAP_CONTEXT_RELEASE_LIST}      Split String                 ${NGAP_CONTEXT_RELEASE}
    ${NGAP_CONTEXT_RELEASE_CAUSE}           Convert To Integer       @{NGAP_CONTEXT_RELEASE_LIST}
    [Return]             	${NGAP_CONTEXT_RELEASE_CAUSE}

Change BaduplinkAlgo Online
    [Documentation]    This Keyword is to update 'NRBTS/NRCEL/actBadUplinkRadioRedirect'
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]         ${CELL_ID}			${CB_VALUE}
    admin.Setup Admin
    Online NIDD Parameter Change    paramName=actBadUplinkRadioRedirect            paramValue=${CB_VALUE}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    admin.Teardown Admin

Change UlBler Threshold Redirect Online
    [Documentation]    This Keyword is to update ul bler thresholds for redirection on a cell
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]         ${CELL_ID}			${DATA_Value}		${VONR_VALUE}
    admin.Setup Admin
    Online NIDD Parameter Change    paramName=ulBler/ulBlerThresholdRedirectData            paramValue=${DATA_Value}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
	Online NIDD Parameter Change    paramName=ulBler/ulBlerThresholdRedirectVoNR            paramValue=${VONR_VALUE}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    admin.Teardown Admin

Setup UL BLER Testmode
    [Documentation]    This Keyword is to set up ul bler testmode command
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]     ${profile_id}    ${bler_value}
    Bler Testmode Nr    profile_id=${profile_id}    ul_bler=${bler_value}

Setup UL Cell Noise Testmode
    [Documentation]    This Keyword is to set up ul cell noise testmode command
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]     ${profile_id}    ${noise_pusch}
    Ul Cell Noise Testmode NR    profile_id=${profile_id}    noise_pusch=${noise_pusch}

Activate UE TestMode
    [Documentation]    This Keyword is to activate UE specific testmode commands
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]     ${UEID}      ${Testmode_name}    ${action}    ${Profile_Id_number}
    Ue Testmode Set Nr      id=${UEID}      testmode=${Testmode_name}
    ...            action=${action}       profile_id=${Profile_Id_number}

Setup Remote Interfernce
    [Documentation]    This Keyword is to start remote interference for a cell
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
	[Arguments]     ${profile_id}      ${start_symbol_position}		${num_of_symbols}    ${noise_power_values}
	Remote Interference Testmode Nr		profile_id=${profile_id}	start_symbol_position=${start_symbol_position}
	...		num_of_symbols=${num_of_symbols}	noise_power_values=${noise_power_values}

Activate Cell TestMode
    [Documentation]    This Keyword is to activate UE specific testmode commands
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]     ${gNBID}      ${CELL_ID}	${Testmode_name}    ${action}    ${Profile_Id_number}
    Cell Testmode Set Nr      gnb=${gNBID}      cell_id=${CELL_ID}		testmode=${Testmode_name}
	...		action=${action}       profile_id=${Profile_Id_number}

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

Check If RI Alarm Is Present
    [Documentation]    Checking for RI Alarm
    ta5g_enb.Verify If Admin Fault Is Up    fault_id=7525

Wait For 2 RI Monitoring Periods
    [Documentation]    Waiting for 10 min for RI monitoring Period
    Sleep    10m

Register Multiple VoNR SA UEs
    [Documentation]    This Keyword is to Register & start traffic in uplink and downlink for VoNR UEs
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}      Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        Log To Console      Starting Registration for VoNR SA UE: ${UE_ID}
        Pass Lua File       ${LUA_FILE}
        Enable Internal TG   ${UE_ID}    1
        wtsrunner.Ue Register   id=${UE_ID}
        Sleep   10s
        Pass Lua File       ${LUA_FILE}
        ${output}    Run Keyword And Ignore Error      Read WTS Output Until Pattern Matches
        ...         ${UE_register_complete_pattern}    ${Timeout_SA}
        Run Keyword If      ${output}!='PASS'
        ...     wtsrunner.ue_register   id=${UE_ID}
        Sleep   10s
        wtsrunner.Smf Param     additional_qosflows_to_activate=2,3       id=1
        wtsrunner.Ue Pdu Session Setup    pdu=1    ue=${UE_ID}   nwslice=1   gw=1
        Sleep   15s
        Trigger VoNR Data   ${UE_ID}   1   1   2   amr_wb_18_25
        Sleep   5s
        Trigger VoNR Data   ${UE_ID}   1   1   3   amr_wb_18_25
        Sleep   5s
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   mbps=2    dir=dl    trf_id=${UE_ID}
        Sleep   5s
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1    mbps=50   dir=ul    trf_id=${UE_ID}
        Sleep   5s
    END

Register Multiple SA UEs
    [Documentation]    This Keyword is to register multiple SA UEs and start traffic in uplink and downlink
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
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
        Log To Console    Running DL/UL Traffic for UE:${UE_ID}
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1
        ...    mbps=2    dir=dl    trf_id=${UE_ID}
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1
        ...    mbps=50   dir=ul    trf_id=${UE_ID}
        Pass Lua File       ${LUA_FILE}
    END

Trigger VoNR Data
    [Documentation]    This Keyword is to start traffic in uplink and downlink for VoNR UEs for 5QI 1,5
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
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
    ...         timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_DL_traffic_data_is_started_successfully
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=ul    trf_id=${TRF_ID}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Uplink Internal traffic*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_UL_traffic_data_is_started_successfully
    Pass Lua File       ${LUA_FILE}

AP Reboot
    [Documentation]     This KW can be used to do a soft-reboot to the AP
    ...                Modified Date: 1-April-2024
    ...                Last Modified by: tom.toby@nokia.com
    ssh.Connect To      ${AP_IP}   ${AP_USERNAME}     ${AP_PASSWORD}     alias=AP_coam
    ssh.Execute     command=reboot      connection=AP_coam
    [Teardown]      ssh.Disconnect      connection=AP_coam

Prepare For Test Case CB012601
    ${Log_Path}      Create Log Directory    CB012601_1
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
	Create Basic Interface On UTE
    Add RD Parameters Directly On GNB      ${RAD_PARAMETER}
    Full Commision Scf And Iphy      ${DELTACONFIGDIR}/CB012601_SCF.xml
    ...      ${APCONFIGDIR}/CB012601_RU_iphy.xml
    Sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS      CB012601_basic_setup.cfg
