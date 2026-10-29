*** Settings ***
Documentation    ...
Suite Teardown    Common Suite Teardown    debug
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_resource.robot

*** Variables ***
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                        CB008927_16_ST_scfc.xml
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${IPHY_FILE}                        ${WTS_LOCAL}/iphy_8927_I_ST16.xml
${WTS_CFG}                        CB008927_16_ST.cfg
${RD}                                   0x580839=1;0x580345=1;0x58090b=1;0x58057b = 2097152;0x5808ff = 2
${ttiPath1}                           ttitrace1
${ttiPath2}                           ttitrace2
${ttiPath3}                           ttitrace3
${ttitraceFilter}                    generate_ttitrace_profile_CB008927.txt
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008927_16_TDD_RAT1_enabled_MCS_with_MSG2_MSG4_SRB1_and_DCI_1_1_in_same_slot
    [Documentation]
    ...    Precondition:
    ...      CB008927 is enabled: NRBTS/NRCELL.actRat1Alloc = true
    ...      NRBTS/actFdmScheduling = true, NRBTS/NRCELL/actFdmSchedulingInitialBWP = true, actbeamforming=true,
    ...      rdEnablePropMcsCalcBasedOn2Prbs = true
    ...    Test Steps:
    ...      Step1: attach 15 UEs,5 UES send full DL/UL traffic , 5UEs ping service , 5UEs send small DL/UL traffic.
    ...      Step2: send  various CQI to Ues.
    ...      Step3: continued detach and attach 5 Ues, and paging other ues.
    ...    Check point:
    ...      1. For RA-Msg2/SRB0/msg4 users, the MCS index is scaled between MCS indices SI_mcs (calculated a per SystemInformationTarget ) and 19.
    ...      2. Check RAT1 PM counters.
    [Tags]    case_I_ST16    TA_Susie    Manual_Abby
    [Setup]    Prepare TL w gNB_xml '${FULL_SCF}' AP_xml '${IPHY_FILE}' AP_cfg'${WTS_CFG}'
    Set egate rrc log 'off'
    #step1
    Start GNB Syslog    ${TEST_LOG_DIRECTORY}
    Log To Console    \nOnlinechange ....
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actEmfTestMode    true
    Sleep    10s
    Lock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
    Unlock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
    Wait Until Keyword Succeeds    3min    15sec    Verify BTS Is OnAir
    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}
    Check Selected Candidate
    Log To Console    \n1CB010944end ....
    UE '1'-'5' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '1'-'5' PDU ID '1' TRF ID '1' QFI ID '1' with '260'mbps
    Start ul Trafficon on UE '1'-'5' PDU ID '1' TRF ID '1' QFI ID '1' with '67'mbps
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '200'mbps on UE '1' of PDU ID '1'
    UE '6'-'10' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '6'-'10' PDU ID '1' TRF ID '1' QFI ID '1' with '1'mbps
    Start ul Trafficon on UE '6'-'10' PDU ID '1' TRF ID '1' QFI ID '1' with '1'mbps
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '0.5'mbps on UE '6' of PDU ID '1'
    UE '11'-'15' Attach to Cell '1' and setup external PDU Session '1'
    Get UeIp From Egate and Ping the latest '5' UE
    #step2
    Send Various CQI To UEs
    #step3
    Paging from AMF on UE '1'
    #UE '16'-'20' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Multi UE Attach
    SA 5G UE '16'-'20' Detach
    Get and Check PM Counter in path'pm01'
    Check MCS For Each UE
    [Teardown]    run keywords      run keyword and ignore error    SA 5G UE '1'-'15' Detach
    ...      AND    Common Test Teardown    debug

*** Keywords ***
Send Various CQI To UEs
    [Arguments]    ${profile_id}=2    ${cqi}=6,8,15,11,13,12,4,10,9,7,5,2,1,3,14    ${start_ue_num}=1    ${end_ue_num}=5
    Log To Console    \nChange CQI ...
    ${cmd1}    Set Variable
    ...    csi_override_testmode_nr profile_id=${profile_id} cqi_mode=varying cqi=${cqi}
    ute_wtssim.Execute Egate Command    ${cmd1}
    FOR    ${ue_ids}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    ${cmd2}    Set Variable
    ...    ue_testmode_set_nr id=${ue_ids} scell=0 testmode=csi_override profile_id=${profile_id} action=activate
    ute_wtssim.Execute Egate Command    ${cmd2}
    END

Get and Check PM Counter in path'${path}'
    #<p name="miNrUlHarqOne">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${TEST_LOG_DIRECTORY}/${path}/test_pmcounter.gz
    ${PRB_USED_PDSCH_RAT1}=
    ...    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55308C00093    cell_id=1
    log    M55308C00093=${PRB_USED_PDSCH_RAT1}    WARN
    Log To Console    M55308C00093=${PRB_USED_PDSCH_RAT1}
    should be true    ${PRB_USED_PDSCH_RAT1}>0

Multi UE Attach
    [Arguments]    ${first_ue}=16    ${last_ue}=20    ${pdu_id}=1    ${slice}=1
    Log To Console    ${pdu_id}  ${slice}
    FOR    ${id}    IN RANGE    ${first_ue}    ${last_ue}+1
        Start capture Ttitrace
        ute_wtssim.Execute Egate Command    cmd=ue_register id\=${id}
        ...    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID
        ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue\=${id} pdu\=1 trf_type\=internal
        ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${id} nwslice\=1 gw\=${id}
        ...    pass_regexp=Initial Context Setup Successful for UE with AMF UE ID
        Stop capture Ttitrace and convert to Excelcsv to log dir 'ttitrace${id}'
    END

Check MCS For Each UE
    [Arguments]    ${first_ue}=16    ${last_ue}=20    ${dciformat}=DL_10_MSG2    ${mcs}=0.0
    FOR    ${id}    IN RANGE    ${first_ue}    ${last_ue}+1
        ${list}    Ttitrace Filter Source Column Return Other Column    ${TEST_LOG_DIRECTORY}/ttitrace${id}/output_dl.csv
        ...    dlFdSchedData.dciFormat     ["${dciformat}"]    include    dlFdSchedData.rrmDlUsedMcs    yes
        Should Contain    ${list}    ${mcs}
    END
Get beamPatternId From Syslog
    [Arguments]    ${syslog_path}    ${id}=1
    ${content}=    OperatingSystem.Get File    ${syslog_path}
    ${PatternIdregex}=    Set Variable    "beamPatternId":\\s*"(\\d+)"
    ${PatternId_list}=    String.Get Regexp Matches    ${content}    ${PatternIdregex}
    ${Index}=    Evaluate    ${id}-1
    ${PatternId}=    Set Variable    ${PatternId_list}[${Index}]
    ${PatternId_Value}=    Evaluate    re.search(r'${PatternIdregex}', '${PatternId}').group(1)    modules=re
    [Return]    ${PatternId_Value}

Get CandidateId From Syslog
    [Arguments]    ${syslog_path}
    ${content}=    OperatingSystem.Get File    ${syslog_path}
    ${CandidateIdregex}=    Set Variable    Find beam candidate with nrBeamEmfKey:1, beamPatternId:(\\d+)
    ${CandidateId_list}=    String.Get Regexp Matches    ${content}    ${CandidateIdregex}
    ${CandidateId_1}=    Set Variable    ${CandidateId_list}[0]
    ${CandidateId_1_Value}=    Evaluate    re.search(r'${CandidateIdregex}', '${CandidateId_1}').group(1)    modules=re
    [Return]    ${CandidateId_1_Value}

Check Selected Candidate
    [Arguments]    ${syslog_path}=${TEST_LOG_DIRECTORY}/syslog_captured.txt    ${id}=1
    OperatingSystem.Run    cp ${TEST_LOG_DIRECTORY}/GNB_syslog/Gnb_syslog_* ${syslog_path}
    ${content}=    OperatingSystem.Get File    ${syslog_path}
    ${PatternId}    Get beamPatternId From Syslog    ${syslog_path}
    ${CandidateId}    Get CandidateId From Syslog    ${syslog_path}
    Log To Console    ${id}
    Should Be True    ${CandidateId}==${PatternId}

Lock Cell
    [Arguments]    ${cell_name}
    Setup Admin
    Block Cell    dist_name=${cell_name}
    Sleep    30s    reason=wait for cell lock
    Teardown Admin

Unlock Cell
    [Arguments]    ${cell_name}
    Setup Admin
    UnBlock Cell    dist_name=${cell_name}
    Sleep    30s    reason=wait for cell unlock
    Teardown Admin