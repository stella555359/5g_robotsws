*** Settings ***
Suite Teardown    Common Suite Teardown    debug
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_Anne
...               SBTS00    SBTS24R3    Pz4_12    CB008927    RAN_5G    RAN_5G_TDD
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_resource.robot

*** Variables ***
${WTS_DIR}                        /opt/iphy/latest
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF_ST20}                  CB008927_ST_20_scfc.xml
${WTS_LOCAL}                      ${CURDIR}/Config
${IPHY_FILE_ST20}                 ${WTS_LOCAL}/iphy_8927_ST20.xml
${WTS_CFG_ST20}                   basic_setup_8927_I_ST20.cfg
${RD}                             0x580839=1;0x580345=1;0x58090b=1;0x580954=1
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB008927_20_TDD_RAT1_NBR_Scheduling_2200_multiple_ues
    [Documentation]
    ...    Precondition:
    ...     - Setup FR1 TDD cell in FD BF (NRBTS.actFdmScheduling ,NRBTS,actFdmEnhancedScheduling )
    ...     -  Set the preconditions for the TDD cell, as per
    ...          USCB008927-H#E1: Start PRB Randomization with one dedicated BWP in the cell with multiple PDSCH sub areas.
    ...     - Several UEs belonging to the single dedicated BWPs, with different radio conditions (to trigger HARQ retransmission) as mentioned below:
    ...     - With full buffer traffic scenario that fulfill the largest PDSCH sub-area within the dedicated BWP with FDM PDSCH grants.
    ...     - With sporadic traffic (ping, small FTP file), to validate the startPrb randomization algorithm in the dedicated BWP
    ...        and the CORESET#0 within the largest BWP with FDM PDSCH grant
    ...     - Mixed traffic (VoNR + FTP)
    ...     - act beamforming =false
    ...     - NRBTS.actFdmScheduling is TRUE, NRBTS.actFdmEnhancedScheduling is TRUE and NRBTS.NRCELL.actIncreasedFdmUsersPerSlot is TRUE
    ...     - actNonVoNRGBRService = TRUE
    ...     - NRCELL.actVoNR=TRUE
    ...     - NRCELL.actEnhancedVoNR to TRUE.
    ...     - For Voice session: 5QI-1 discardTimer = 100
    ...    Test Steps:
	...     1 Enable NBR feature (NRCELL.actNbrForNonGbrBearers = TRUE) in the cell.
    ...       NRDRB_MAC.nbrDl are set to values larger than the throughput achieved for the non-GBR bearers  // Dedicated for NBR
    ...     2 Set up Non-GBR bear for 5Ues（NBR), VONR for 5Ues, NON-VONR GBR for 5 Ues,  5 Ues with VONR+NON-GBR
    ...     3 start traffic
    ...     4 decrease the CQI for non-gbr with nbr
    ...    Check point：
    ...     The GBR service would be scheduled priority before NBR (Note: small tolerance would be allowed for multi-UEs
    ...         with multi-bearers scenarios as inaccurate buffer management)
    ...      - For NBR bearers of near cell UEs (UEs with good channel condition), configured NBR rate is achieved.
    ...      - For NBR bearers of cell-edge UEs (UEs with worse channel condition), configured NBR rate might not be achieved.
    ...         However, their achieved Throughput shall be higher as compared to NBR being disabled.

    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_ST20}
    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCF_ST20}    iphy_file=${IPHY_FILE_ST20}    swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
    ...        AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Create Test Directory

    # ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}

    Start GNB Syslog    ${TEST_LOG_DIRECTORY}/attach

    # Attach UE 1~20
    FOR    ${id}    IN RANGE    1    21
        Run Keyword    SA Attach    ue_id=${id}
        Sleep    1s
    END

    # Set UE 1 ~ 10 with VONR  (QOS-3: 5QI-5, QOS-4: 5QI-1)
    Log To Console    \n Set UE 1 ~ 10 with VONR
    FOR    ${id}    IN RANGE    1    11
        Config 5QI-5 for UE    ${id}
        Config 5QI-1 for UE    ${id}
    END

    # Set UE 11 ~ 15 with 5QI-7 (QOS-2: 5QI-7)
    FOR    ${id}    IN RANGE    11    16
        Config 5QI-7 for UE    ${id}
    END

    # Set UE 16 ~ 20 with 5QI-2 (QOS-5: 5QI-2)
    Log To Console    \n Set UE 16 ~ 20 with 5QI-7
    FOR    ${id}    IN RANGE    16    21
        Config 5QI-7 for UE    ${id}
        Log To Console    \n start 5QI-2 Setup for UE-${id}...
    END

    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}/attach

    # Start Traffic for UE 1~5 with VONR (qfi=3) only traffic
    FOR    ${id}    IN RANGE    1    6
        Log To Console    \n Start VONR only traffic for UE-${id}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${id} pdu\=1 qfi\=3 dir=dl trf_id=\1 rtp_codec=amr_12_2
        Sleep    1s
    END

    # Start Traffic for UE 6~10 with VONR (qfi=3) and non-GBR traffic (qfi=1)
    FOR    ${id}    IN RANGE    6    11
        Log To Console    \n Start VONR traffic for UE-${id}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${id} pdu\=1 qfi\=3 dir=dl trf_id=\1 rtp_codec=amr_12_2
        Sleep    1s
        Log To Console    \n Start non-GBR traffic for UE-${id}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${id} pdu\=1 qfi\=1 dir=dl trf_id=\1 mbps=140
        Sleep    1s
    END

    # Start Traffic for UE 11~15 with NBR (qfi=2) traffic
    FOR    ${id}    IN RANGE    11    16
        Log To Console    \n Start NBR traffic for UE-${id}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${id} pdu\=1 qfi\=2 dir=dl trf_id=\1 mbps=140
        Sleep    1s
    END

    # Start Traffic for UE 16~20 with GBR (qfi=2) traffic
    FOR    ${id}    IN RANGE    16    21
        Log To Console    \n Start GBR traffic for UE-${id}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${id} pdu\=1 qfi\=2 dir=dl trf_id=\1 mbps=2
        Sleep    1s
    END

    # Start log capturing for 1 seconds
    Log To Console    \n Start log capturing
    # Start Log Capture    log_dir=mue
    # Sleep    1s
    # Stop Log Capture    log_dir=mue
    Capture Ttitrace for duration '1s' to log dir 'mue'

    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path 'mue'

    [Teardown]     Run Keywords    SA 5G Detach    ue_id=1-20
    ...            AND    Common Test Teardown    debug


*** Keywords ***
SA Attach
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${trf_type}='internal'
    # Set UEC Reordering Timer
    SA 5G Attach    ue_id=${ue_id}
    Sleep    1s
    Run Keyword If    ${trf_type}=='internal'    SA Set Traffic Type To internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    Run keyword Unless    ${trf_type}=='internal'    SA Set Traffic Type To external    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    1s
    ${output}    SA 5G PDU Session Setup    ${ue_id}    pdu_id=${pdu_id}
    Sleep    1s

SA Set Traffic Type To external
    [Arguments]    ${ue_id}    ${pdu_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=external

Start capture Ttitrace
    common_Log_capture.Start Ttitrace With Streaming Mode

Start Log Capture
    [Arguments]    ${log_dir}
    Start GNB Syslog    ${TEST_LOG_DIRECTORY}/${log_dir}
    Start Gnb BIP Log
    Start capture Ttitrace

Stop Log Capture
    [Arguments]    ${log_dir}
    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}/${log_dir}
    common_Log_capture.Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/${log_dir}
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/${log_dir}

Config 5QI-5 for UE
        [Arguments]    ${id}
        Log To Console    \n start 5QI-5 Setup for UE-${id}...
        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=3 by=amf
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ${command}
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
        ...    timeout=1minutes
        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
        Log To Console    ${output}

Config 5QI-1 for UE
        [Arguments]    ${id}
        Log To Console    \n start 5QI-1 Setup for UE-${id}...
        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=4 by=amf
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ${command}
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
        ...    timeout=1minutes
        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
        Log To Console    ${output}

Config 5QI-7 for UE
        [Arguments]    ${id}
        Log To Console    \n start 5QI-7 Setup for UE-${id}...
        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=2 by=amf
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ${command}
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
        ...    timeout=1minutes
        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
        Log To Console    ${output}

Config 5QI-2 for UE
        [Arguments]    ${id}
        Log To Console    \n start 5QI-2 Setup for UE-${id}...
        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=5 by=amf
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ${command}
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
        ...    timeout=1minutes
        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
        Log To Console    ${output}
