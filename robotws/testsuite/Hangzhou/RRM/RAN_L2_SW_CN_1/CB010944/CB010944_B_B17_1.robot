*** Settings ***
Documentation    ...
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown    2    check_tl=False
Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    Pz4_12    CB010944    CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot

*** Variables ***
${SCF_PATH}          ${CURDIR}/Config
${SCF_B_B17_1}          SCF_10944_B_B17_1.xml
${IPHY_B_B17_1}         ${WTS_LOCAL}/iphy_10944_B_B17_1.xml
${WTS_CFG_B_B17_1}      basic_setup_10944_B_B17_1.cfg
${WTS_LOCAL}         ${CURDIR}/Config
${RD}                0x580839=1;0x580345=1;0x58090b=1
${bip_csv}           bip_gnb.csv
${force_reboot}           ${True}


*** Test Cases ***
CB010944-B_B17_1_Verify_load_generation_iwk_with_CB008927_DL_RAT1
    [Documentation]
    ...    Precondition:
    ...      CB010944 is disabled: NRBTS/NRCELL.actEmfTestMode = false
    ...      CB008927 is enabled: NRBTS/NRCELL.actRat1Alloc = true
    ...      NRCELL.actEirpControl = true, NRCELL.numOfSubSectors = 0sub-sector, NRCELL.targetTotalLoad = 90
    ...      NRCELL.beamSet.basicBeamSet = beamSet_4, NRCELLGRP.numberOfTransmittedSsBlocks = 4, NRCELL.beamSet.nrBtsBeamRefinementP2=false
    ...      NRBTS.NRCELL.actEnhancedPDSCHSchSplSlot=true
    ...      frameStructureType = semiStatic, ulDlDataSlotRatio = 4/6, guardPeriodSymbols = 4,prachConfigurationIndex = 160 (Format B4)
    ...    Test Steps:
    ...      Step1: To activate the feature, NRCELL.actEmfTestMode shall be set to TRUE.
    ...      Step2: Configure the target beam (up to 5) by NRCELL.emfBeamDNList and activated successfully.
    ...    Check point:
    ...      1. In step1, check feature is activated. To avoid syslog async issue, here add lock/unlock cell step to check isAlForEmfEnabled info.
    ...      2. In step2, add only NRBEAM_EMF-1 in this case, check selected beam is the 1st NrBeamEMF informed by system.

    [Tags]    case_B_B17_1    TA_lruan
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_B_B17_1}
    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_B_B17_1}    iphy_file=${IPHY_B_B17_1}
    ...               swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${WTS_LOCAL}
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Common Test Setup 2
    Start GNB Syslog    ${TEST_LOG_DIRECTORY}
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actEmfTestMode    true
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/Delta_conf_10944_emfBeamDNList.xml
    Delta Commission With SCF File    ${json_file}
    Sleep    10s
    Lock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
    Unlock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
    Wait Until Keyword Succeeds    3min    15sec    Verify BTS Is OnAir
    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}
    Check Selected Candidate

*** Keywords ***
Start bip
    Start Gnb BIP Log

Stop bip
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/Gnb_BIP

Check Feature Activated
    Log To Console    \nCheck 10944 feature is activated...
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${output}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/GNB_syslog/Gnb_syslog_*|grep -i "isAlForEmfEnabled: 1"|wc -l
    Should Be True    ${output}>=1

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
