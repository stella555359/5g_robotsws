*** Settings ***
Documentation     CB008927
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown    2    check_tl=False
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot


*** Variables ***
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF_15}                    CB008927_11_ST_scfc.xml
${FULL_SCF_29}                    CB008927_29_ET_scfc.xml
${WTS_LOCAL}                      ${CURDIR}/Config
${IPHY_FILE_15}                   ${WTS_LOCAL}/iphy_2T_2F_CA04.xml
${IPHY_FILE_29}                   ${WTS_LOCAL}/iphy_29_ET.xml
${WTS_CFG_15}                     CB008927_11_ST_AP.cfg
${WTS_CFG_29}                     basic_setup_8927_I_ET29.cfg
${RD}                             0x580839=1;0x580345=1;0x58090b=1;0x580954=1
${ttiPath1}                       ttitrace1
${ttiPath2}                       ttitrace2
${ttitraceFilter}                 generate_ttitrace_profile_CB008927.txt
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB008927_29_TDD_RAT1_UE_have_multiple_DRBs_with_5QI2
    [Documentation]
    ...    Precondition:
    ...      CB008927 is enabled: NRBTS/NRCELL.actRat1Alloc = true
    ...      NRBTS/actFdmScheduling = true, NRBTS/NRCELL/actFdmSchedulingInitialBWP = true, actNonVoNRGBRService = true
    ...      NRBTS/NRCELL/actVoNR = true, NRBTS/NRCELL/actEnhancedVoNR = true,
    ...      For Voice session: 5QI-1 discardTimer = 100
    ...    Test Steps:
    ...      Step1: attach 20 UES and start full buffer traffic data DL and UL.
    ...      Step2: set up 5QI1 and 5QI2 bear for 10 UES.
    ...    Check point:
    ...      1. There should be no 5QI-1 or 5QI-2 packets discarded.
    ...      2. The users are scheduled such that the PRB allocations of each of its configured bearers are contiguous.
    ...      3. Check counters.

    [Tags]    case_I_ET29    Manual_MikeMa    TA_lilidong
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_29}
    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCF_29}    iphy_file=${IPHY_FILE_29}    swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
    ...        AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Common Test Setup 2

#    20 UES send full DL/UL traffic
    UE '1'-'20' Attach to Cell '1' and setup PDU Session '1' with 5QI6
    UE '1'-'10' add 5QI2
    UE '11'-'20' add 5QI5 and 5QI1
    UE '11'-'20' START DL traffic 5QI1 and 5QI6
    UE '11'-'20' START UL traffic 5QI1 and 5QI6
    UE '1'-'10' START DL traffic 5QI2 and 5QI6
    UE '1'-'10' START UL traffic 5QI2 and 5QI6

    Start capture Ttitrace
    Sleep    1s
    Stop capture Ttitrace and convert to Excelcsv to log dir '${ttiPath1}'
    Check PM Counter For Discarded Packets


*** Keywords ***
SA 5G PDU Session Setup
    [Arguments]    ${ue_id}    ${pdu_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${matchlines}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}

#    BuiltIn.Sleep   1s

Start UTE WTS with cfg file '${WTS_CFG}'
    Start UTE WTS    ${WTS_CFG}

Set egate rrc log '${flag}'
    ute_wtssim.Execute Egate Command    cmd=trace uec\=1 protocol\=rrc,nr_rrc ${flag}

UE '${sid}'-'${eid}' Attach to Cell '1' and setup PDU Session '${pdu_id}' with 5QI6
        ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA 5G Attach    ${ue_id}
        SA Set Traffic Type To Internal    ${ue_id}    ${pdu_id}
        SA 5G PDU Session Setup    ${ue_id}    ${pdu_id}
    END

UE '${sid}'-'${eid}' add 5QI2
        ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA 5G Add 5QI2    ${ue_id}
    END

UE '${sid}'-'${eid}' add 5QI5 and 5QI1
        ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA 5G Add 5QI5    ${ue_id}
        SA 5G Add 5QI1    ${ue_id}
    END


SA 5G Add 5QI2
    [Arguments]    ${ue_id}
    Log To Console    start 5G 5QI2 setup...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    partial_match=${true}
    Log To Console    ${output}

SA 5G Add 5QI5
    [Arguments]    ${ue_id}
    Log To Console    start 5G 5QI5 setup...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    partial_match=${true}
    Log To Console    ${output}

SA 5G Add 5QI1
    [Arguments]    ${ue_id}
    Log To Console    start 5G 5QI1 setup...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    partial_match=${true}
    Log To Console    ${output}

SA Start DL 5QI2 AND 5QI6 Internal
  [Arguments]    ${ue_id}
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=2 dir=dl
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes

SA Start UL 5QI2 AND 5QI6 Internal
  [Arguments]    ${ue_id}
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=2 dir=ul
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 mbps=10 dir=ul
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes

SA Start DL 5QI1 AND 5QI6 Internal
  [Arguments]    ${ue_id}
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=dl rtp_codec=amr_12_2 trf_id=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes

SA Start UL 5QI1 AND 5QI6 Internal
  [Arguments]    ${ue_id}
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=ul rtp_codec=amr_12_2 trf_id=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 mbps=10 dir=ul
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes

UE '${sid}'-'${eid}' START DL traffic 5QI2 and 5QI6
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Start DL 5QI2 AND 5QI6 Internal    ${ue_id}
    END

UE '${sid}'-'${eid}' START UL traffic 5QI2 and 5QI6
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Start UL 5QI2 AND 5QI6 Internal    ${ue_id}
    END

UE '${sid}'-'${eid}' START DL traffic 5QI1 and 5QI6
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Start DL 5QI1 AND 5QI6 Internal    ${ue_id}
    END

UE '${sid}'-'${eid}' START UL traffic 5QI1 and 5QI6
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Start UL 5QI1 AND 5QI6 Internal    ${ue_id}
    END

Start capture Ttitrace
    common_Log_capture.Start Ttitrace With Streaming Mode

Stop capture Ttitrace and convert to Excelcsv to log dir '${log_dir}'
#   Sleep    5s    wait for a while.
    common_Log_capture.Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/${log_dir}
    common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${TEST_LOG_DIRECTORY}/${log_dir}

Check PM Counter For Discarded Packets
    Wait Until PM Counter Update    5min    0
    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55320C06001    BTS/MRBTS-1/NRBTS-1/PDCP2    -1    1
    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55320C06002    BTS/MRBTS-1/NRBTS-1/PDCP2    -1    1
    ${M55310C02001_value}    Get PM Counter Latest Value From Admin    M55310C02001    CELLS/NRCELL-1/NLRLC    1
    ${M55310C02002_value}    Get PM Counter Latest Value From Admin    M55310C02002    CELLS/NRCELL-1/NLRLC    1
    Should Be True    ${M55310C02001_value} > 0
    Should Be True    ${M55310C02002_value} > 0

