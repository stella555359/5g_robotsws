*** Settings ***
Documentation
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource    ./../CUDU_L2/common_SA_ue_command.robot
Resource    ./../CB008927/Resources/CB008927_resource.robot
Test Teardown    Common Test Teardown    2    check_tl=False
Suite Teardown    Common Suite Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    Pz4_12
...                RAN_5G    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT

*** Variables ***
${UE_ID}               1
${PDU_ID}              1
${Egatelog_path}       ${CURDIR}
${LOCAL_WTS_DIR}       ${CURDIR}/Config
${SCF_DIR}             ${CURDIR}/Config

${IPHY_A_B1_3}            ${LOCAL_WTS_DIR}/iphy_10944_A_B1_3.xml
${SCF_A_B1_3}             ${SCF_DIR}/SCF_10944_A_B1_3.xml
${WTS_CFG_A_B1_3}         basic_setup_10944_A_B1_3.cfg
${RD}                     0x4B000F=1
${force_reboot}           ${True}
${filter_B_B1_2}          (dldata_pdschsendreql1sw)
@{column_name_B_B1_2}     3gpp.sfn    3gpp.slot    3gpp.rnti    3gpp.dmrsScramblingSequenceInt
                     ...    DlData_PdschGrantL1sw.startPrb    DlData_PdschGrantL1sw.numOfPrb
${bip_csv}           bip_gnb.csv


*** Test Cases ***

CB010944-B_B1_2_Verify_load_generation_iwk_with_Customer_beam_with_different_targetload_and_EIRP_control_parameters
    [Documentation]
    ...    Precondition:
    ...      CB010944 is disabled: NRBTS/NRCELL.actEmfTestMode = false
    ...      NRCELL.actEirpControl = true, NRCELL.numOfSubSectors = 0sub-sector, NRCELL.targetTotalLoad = 0
    ...      NRCELL.beamSet.basicBeamSet = beamSet_4, NRCELLGRP.numberOfTransmittedSsBlocks = 4, NRCELL.beamSet.nrBtsBeamRefinementP2=true
    ...    Test Steps:
    ...      Step1: To activate the feature, NRCELL.actEmfTestMode shall be set to TRUE.
    ...      Step2: Configure the target beam (up to 5) by NRCELL.emfBeamDNList and activated successfully.
    ...    Check point:
    ...      1. In step1, check feature is activated.
    ...      2. In step2, check used PRB for Artificial Load.

    [Tags]    case_B_B1_2    TA_abbyw
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_A_B1_3}
    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_A_B1_3}    iphy_file=${IPHY_A_B1_3}
    ...               swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Common Test Setup 2

    Start GNB Syslog    ${TEST_LOG_DIRECTORY}
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actEmfTestMode    true
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actRat1Alloc    false
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/Delta_conf_10944_emfBeamDNList.xml
    Delta Commission With SCF File    ${json_file}
    Sleep    10s
    Lock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
    Unlock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
    Wait Until Keyword Succeeds    3min    15sec    Verify BTS Is OnAir
    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}
    Sleep    5s
    ${bip}    Capture BIP for'1' to logDir'BIP_GNB'and convert to csv'${bip_csv}' with filter'${filter_B_B1_2}' and'${column_name_B_B1_2}'
    Verify total PRB
    Check Selected Candidate

*** Keywords ***
Capture BIP for'${time}' to logDir'${dir}'and convert to csv'${name}' with filter'${filter}' and'${column_name}'
    Start Gnb BIP Log    ${time}
    Sleep    2s
    Collect GNB BIP By Admin Method    ${TEST_LOG_DIRECTORY}/${dir}/
    #Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/${dir}/
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${dir}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/${dir}/${name}    ${filter}    ${column_name}
    [Return]    ${TEST_LOG_DIRECTORY}/${dir}/${name}

Collect GNB BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}
    Run    mkdir -p ${log_path}
    Run Keyword And Ignore Error    Run    rm -rf ${log_path}/mirroring_L2L1*
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ls -al /tmp/CCSPacketCapture
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/CCSPacketCapture/* ${log_path}
    Run    ls -1 ${log_path}
    Run    mergecap -a -w ${log_path}/5GBipL2L1_filtering_off.pcap ${log_path}/mirroring_L2L1*
    ${bip_file}=    Set Variable    ${log_path}/5GBipL2L1_filtering_off.pcap
    OperatingSystem.File Should Exist    ${bip_file}
    Log To Console    bip log:${bip_file}
    [Return]    ${bip_file}

Verify total PRB
    Check Log With Au2anlysis    ${CURDIR}${/}Config${/}CB010944_Verify_total_PRB.ini    i
    ...    save_log_directory=${TEST_LOG_DIRECTORY}/BIP_GNB/

Check Feature Activated
    Log To Console    \nCheck 10944 feature is activated...
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${output}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/GNB_syslog/Gnb_syslog_*|grep -i "isAlForEmfEnabled: 1"|wc -l
    Should Be True    ${output}>=1

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
    [Arguments]    ${syslog_path}=${TEST_LOG_DIRECTORY}/syslog_captured.txt
    OperatingSystem.Run    cp ${TEST_LOG_DIRECTORY}/GNB_syslog/Gnb_syslog_* ${syslog_path}
    ${content}=    OperatingSystem.Get File    ${syslog_path}
    ${PatternId}    Get beamPatternId From Syslog    ${syslog_path}
    ${CandidateId}    Get CandidateId From Syslog    ${syslog_path}
    Should Be True    ${CandidateId}==${PatternId}