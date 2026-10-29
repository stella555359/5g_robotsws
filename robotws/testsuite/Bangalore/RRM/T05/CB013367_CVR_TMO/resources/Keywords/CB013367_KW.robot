*** Settings ***
Documentation     This contains keywords used for CB013367 automation cases.
...               :author Prajwali Joshi

Library         Collections
Library         ute_wtssim
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         ta5g_commissioning              WITH NAME    tcom
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
Resource        ${CURDIR}/../../../../T12/resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../../T12/resources/Keywords/HO_KW.robot
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
${iphy}                 ${CURDIR}/../../config/ap_iphy/new_iphy.xml
${TOPOLOGY}     		CLOUD_5G_I_LO_AP_LO
${RI_MONITORING_PERIOD}		5m
${CELL_NOISE_TESTMODE}      ul_cell_noise
${scf}       ${CURDIR}/../../config/gnb_scf/
${PATTERN_51_CIO}       \\s*physCellId\\s+(\\d+),\\s*cellIndividualOffset\\s*\\{\\s*rsrpOffsetSSB\\s+(dB-[\\d\\-]+)\\s*\\}

${PATTERN_53_NO_CIO_A}     \\s*ssbFrequency\\s+125290,\\s+ssbSubcarrierSpacing\\s+kHz15,
${PATTERN_53_NO_CIO_B}     \\s+smtc1\\s+\\{\\s+periodicityAndOffset\\s+sf20\\s+:\\s+0,\\s+duration\\s+sf1\\s+\\},\\s+
${PATTERN_53_NO_CIO_C}     referenceSignalConfig\\s+\\{\\s+ssb-ConfigMobility\\s+\\{\\s+deriveSSB-IndexFromCell\\s+TRUE\\s+\\}\\s+\\},
${PATTERN_53_NO_CIO_D}     \\s+quantityConfigIndex\\s+1,\\s+offsetMO\\s+\\{\\s+\\},\\s+freqBandIndicatorNR\\s+71

${text}=    Catenate    SEPARATOR=\n
    ...    ssbFrequency 125290,
    ...    ssbSubcarrierSpacing kHz15,
    ...    smtc1
    ...    {
    ...      periodicityAndOffset sf20 : 0,
    ...      duration sf4
    ...    },
    ...    referenceSignalConfig
    ...    {
    ...      ssb-ConfigMobility
    ...      {
    ...        deriveSSB-IndexFromCell TRUE
    ...      }
    ...    },
    ...    quantityConfigIndex 1,
    ...    offsetMO
    ...    {
    ...    },
    ...    freqBandIndicatorNR 71
${text1}=    Catenate    SEPARATOR=\n
   ...            physCellId 51,
   ...            cellIndividualOffset
   ...            {
   ...              rsrpOffsetSSB dB-4
   ...            }
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

Setup Remote Interfernce
    [Documentation]    This Keyword is to start remote interference for a cell
	[Arguments]     ${profile_id}      ${start_symbol_position}		${num_of_symbols}    ${noise_power_values}
	Remote Interference Testmode Nr		profile_id=${profile_id}	start_symbol_position=${start_symbol_position}
	...		num_of_symbols=${num_of_symbols}	noise_power_values=${noise_power_values}

Activate Cell TestMode
    [Documentation]    This Keyword is to activate UE specific testmode commands
    [Arguments]     ${gNBID}      ${CELL_ID}	${Testmode_name}    ${action}    ${Profile_Id_number}
    Cell Testmode Set Nr      gnb=${gNBID}      cell_id=${CELL_ID}		testmode=${Testmode_name}
	...		action=${action}       profile_id=${Profile_Id_number}

Check If RI Alarm Is Present
    [Documentation]    Checking for RI Alarm
    ta5g_enb.Verify If Admin Fault Is Up    fault_id=7525

Wait For 2 RI Monitoring Periods
    [Documentation]    Waiting for 10 min for RI monitoring Period
    Sleep    5m

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
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=udp
        ...    mbps=2    dir=dl    trf_id=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over UDP   timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
        Log to Console    ${output}
        sleep    5s
        Pass Lua File       ${LUA_FILE}
        Log To Console    Running UL Traffic for UE:${UE_ID}
        wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1   protocol=udp
        ...    mbps=2    dir=ul    trf_id=1
        Pass Lua File       ${LUA_FILE}
        Sleep   5s
        ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over UDP   timeout=30
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

Trigger A2 meas
    [Documentation]   This keyword triggers the A2 measurement for multiple UEs
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        ue_measurement_send_nr   id=${UE_ID}   meas_id=1     event=A2    srsrp_nr=15     srsrq_nr=15
        ...     phycell_id=51    nrsrp_nr=90     nrsrq_nr=90
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=rrcReconfigurationComplete   timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
        Log To Console    ${\n} ${output} for ${UE_ID}
        Sleep   1s
    END

Trigger A2 meas for CIO
    [Documentation]   This keyword triggers the A2 measurement for the CIO configuration for NRCELL-1 RIM impacted cell
    [Arguments]             ${UE_ID}
        ue_measurement_send_nr   id=${UE_ID}    phycell_id=51    meas_id=1     event=A2    srsrp_nr=15
        ...          srsrq_nr=15    nrsrp_nr=90     nrsrq_nr=90
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${PATTERN_51_CIO}    timeout=120
        ${pattern}=    Set Variable   ${PATTERN_51_CIO}
        ${matches}=    Get Regexp Matches    ${text1}    ${pattern}
        Log    ${matches}
        Log To Console    ${matches} for UE ${UE_ID}
        Sleep   1s

Trigger A2 meas for NO CIO
    [Documentation]   This keyword triggers the A2 measurement for the no CIO configuration for NRCELL-3
    [Arguments]             ${UE_ID}
        ue_measurement_send_nr   id=${UE_ID}    phycell_id=51    meas_id=1     event=A2    srsrp_nr=15
        ...          srsrq_nr=15    nrsrp_nr=90     nrsrq_nr=90
        ${output}   wtsrunner.Read Wtsemu Output Until Re
        ...     expected= ${PATTERN_53_NO_CIO_A}${PATTERN_53_NO_CIO_B}${PATTERN_53_NO_CIO_C}${PATTERN_53_NO_CIO_D}
        ...     timeout=120
        ${pattern}=    Set Variable   ${PATTERN_53_NO_CIO_A}${PATTERN_53_NO_CIO_B}${PATTERN_53_NO_CIO_C}${PATTERN_53_NO_CIO_D}
        ${matches}=    Get Regexp Matches    ${text}    ${pattern}
        Log    ${matches}
        Sleep   1s


Verify HO not triggered
    [Documentation]   This keyword verifies that a handover (HO) is not triggered for multiple UEs
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        ${nrsrp}    Evaluate     (${UE_ID} + 10)
        ${nrsrq}    Set Variable    ${nrsrp}
        sleep   5s
        ue_measurement_send_nr       id=${UE_ID}    nrsrp_nr=${nrsrp}      nrsrq_nr=${nrsrq}    srsrp_nr=15
        ...    srsrq_nr=15      phycell_id=51       meas_id=8    event=A5
        Pass Lua File       ${LUA_FILE}
        ${output}    Run Keyword And Expect Error    *read timed out.*    Read WTS Output Until Pattern Matches
         ...     Intra-eNB handover from EXT_ENB-2.4 to EXT_ENB-2.1    30
        Should Match Regexp    ${output}    .*read timed out.*
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

Data validation before HO
    [Documentation]     These keywords are related to testing and validation of data traffic in a network before handover
    Log To Console      \n Verifying packet count before HO
    Verify packet count in Multiple UEs in DL UL direction      41      43      1
    Verify packet count in Multiple UEs in DL UL direction      41      43      2
    Verify packet count in Multiple UEs in DL UL direction      41      43      3
    Pass Lua File       ${LUA_FILE}
    Log To Console      \n Verifying bytes sent before HO
    Verify bytes sent in Multiple UEs in DL UL direction before HO      41     43     1
    Verify bytes sent in Multiple UEs in DL UL direction before HO      41     43     2
    Verify bytes sent in Multiple UEs in DL UL direction before HO      41     43     3

Data validation after HO
    [Documentation]      These keywords are related to testing and validation of data traffic in a network after handover
    Log To Console      \n Verifying packet count after HO
    Verify packet count in Multiple UEs in DL UL direction      41      43      1
    Verify packet count in Multiple UEs in DL UL direction      41      43      2
    Verify packet count in Multiple UEs in DL UL direction      41      43      3
    Pass Lua File       ${LUA_FILE}
    Log To Console      \n Verifying bytes sent after HO
    Verify bytes sent in Multiple UEs in DL UL direction after HO      41     43     1
    Verify bytes sent in Multiple UEs in DL UL direction after HO      41     43     2
    Verify bytes sent in Multiple UEs in DL UL direction after HO      41     43     3
    Pass Lua File       ${LUA_FILE}
    Compare Dicts Value Greater     ${DL_BYTES_DICT}    ${DL_BYTES_DICT_AFTER_HO}
    Compare Dicts Value Greater     ${UL_BYTES_DICT}    ${UL_BYTES_DICT_AFTER_HO}

Verify HO triggered
    [Documentation]    This keyword Simulates a Handover (HO) scenario in a cellular network by sending measurement reports
    ...                for a range of UE IDs, triggering a handover and verifying that the handover is successfully triggered
    [Arguments]             ${Start_UE}     ${End_UE}
    ${End_UE}          Evaluate    ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        ${nrsrp}    Evaluate    10 + (${UE_ID} + 5)
        ${nrsrq}    Set Variable    ${nrsrp}
        ${measID}   Display Measurement Configuration for UE    ${UE_ID}     A5
        Pass Lua File       ${LUA_FILE}
        ue_measurement_send_nr       id=${UE_ID}    nrsrp_nr=${nrsrp}      nrsrq_nr=${nrsrq}    meas_id=8   srsrp_nr=15
        ...    srsrq_nr=15      phycell_id=51       event=A5
        ${output}    wtsrunner.Read Wtsemu Output Until Re       expected=Intra-eNB handover from EXT_ENB-\\d+\\.\\d+ to EXT_ENB  timeout=120
        ${pattern}=    Set Variable   Intra-eNB handover from EXT_ENB-\\d+\\.\\d+ to EXT_ENB
        ${matches}=    Get Regexp Matches    ${text2}    ${pattern}
        Log    ${\n} ${matches} event triggered, successfull HO for UE ${UE_ID}
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

Teardown for CB013367_A2_59
    [Documentation]    This keyword is to bring down the test environment for CB013367_A2_59
    slog.Stop Syslog
    GNB Delta Commission    ${scf}/reverse_delta.json
    ue_deregister    id=all      ue_deregister_type=switch_off
    sleep   120s
    Wait Coam Site to be Ready
    RAT Block Unblock

Teardown for CB013367_B3_20
    [Documentation]    This keyword is to bring down the test environment for CB013367_A2_59
    slog.Stop Syslog
    GNB Delta Commission    ${scf}/reverse_delta.json
    ue_deregister    id=all      ue_deregister_type=switch_off
    sleep   120s
    Wait Coam Site to be Ready
    RAT Block Unblock

Prepare For Test Case CB013367_A2_59
    [Documentation]     This keyword loads all required configurations like scf, cfg
    ${Log_Path}      Create Log Directory    CB013367_A2_59
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
	Create Basic Interface On UTE
    GNB Delta Commission    ${scf}/delta_tmo.json
    Site Reset For Gnb
    Sleep   540s
    Wait Coam Site to be Ready
    Start UTE WTS      CB013367_basic_setup.cfg
    Basic Bring Up
    slog.Start Syslog     ${Log_Path1}     CB013367_A2_59.LOG

Prepare For Test Case CB013367_B3_20
    [Documentation]     This keyword loads all required configurations like scf, cfg
    ${Log_Path}      Create Log Directory    CB013367_B3_20
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
	Create Basic Interface On UTE
    GNB Delta Commission    ${scf}/delta_tmo.json
    Site Reset For Gnb
    Sleep   540s
    Wait Coam Site to be Ready
    Start UTE WTS      CB013367_basic_setup.cfg
    Basic Bring Up
    slog.Start Syslog     ${Log_Path2}     CB013367_B3_20.LOG

Site Reset For Gnb
    [Documentation]     This keyword is used to Site Reset
    admin.Setup Admin
    admin.reset_site      reset_coverage=Site     wait_for_reconnection=True    graceful_cell_shutdown=True
    [Teardown]      admin.Teardown Admin

