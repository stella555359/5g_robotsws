*** Settings ***
Resource      ./Resources/CB010240_resource.robot
Force Tags    CLOUD_5G_I_[LO][LO]_AP_[LOO]    SBTS00    CN1_SG09    RAN_5G    CRT

*** Variables ***
${LOCAL_WTS_DIR}                 ${CURDIR}/Resources/wts
${SCF_PATH}                      ${CURDIR}/Config
${SCF_GNB1}                      ${CURDIR}/Config/SBTS23R4/SCF/CB010240_A_SA_FR1_gnb1.xml
${SCF_GNB2}                      ${CURDIR}/Config/SBTS23R4/SCF/CB010240_A_SA_FR1_gnb2.xml
${IPHY_2T2F}                     ${CURDIR}/Resources/wts/iphy_2F_2T_LOLO_LOO.xml
${WTS_CFG_B8A}                   CB010240_A_SA_FR1_intergNB.cfg
@{LOG_NAME_LIST}                 btslog    egatelog
${FORCE_REBOOT}                  ${true}
${SWCONFIG_PARAM}                0x580497=1;0x57000B=0xFFFFEEF0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1
${UE_ID}                         1
@{2T2F_SCELL_PHYSICALID_LIST}    53    60
@{EXP_DL_TPUT_LIST}              3    3    3
@{EXP_ZERO_TPUT}                 0    0    0

*** Test Cases ***
CB010240_ET_A_Interworking_With_Inter_GNB_CA
    [Documentation]
    Import Testline Variables For 2 GNBs
    Create Suite Directory
    Backup And Update Iphy Swconfig File    ${IPHY_2T2F}    ${SWCONFIG_PARAM}
    Add RD Parameters To GNB Swconfig File    ${SWCONFIG_PARAM}    10.0.1.3
    Log To Console    Send scf to gnb2...
    Full Commission SCF File Through Mplane With Admin    ${SCF_GNB2}    1    10.0.1.3
    Log To Console    Send scf to gnb1...
    Full Commission SCF File Through Mplane With Admin    ${SCF_GNB1}    1    10.0.1.2
    Reboot TL And Check Configured For 2 GNBs
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_B8A}
    Sleep    60s    Wait for interGNB communication interface established stable
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY}
    ...    log_name=Gnb2_syslog    ip=10.0.1.3    alias=Gnb2_syslog
    Suite Setup Start WTS And Check OnAir    log=${false}    gnb_num=2
    Sleep    60s    Wait for interGNB communication interface established stable
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    Start Ttitrace With Streaming Mode    names=l2stream3_ttitrace_2    host=10.0.1.3
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Run Keyword And Continue On Failure    Check SA All Scell PhysicalID With UE ID    ${UE_ID}    ${2t2f_scell_physicalid_list}    2
    SA Start DL Traffic Internal    ${UE_ID}    1    300
    Sleep    20s    reason=Wait For DL Transmission
    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${exp_Dl_tput_list}    3
    SA Stop Data Traffic Internal    ${UE_ID}    1
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${UE_ID}    1    Dl    ${exp_zero_tput}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_gnb2
    ...    names=l2stream3_ttitrace_gnb2    host=10.0.1.3
    Wait Until PM Counter Update
    [Teardown]    Run Keywords    ute_syslog.Collect Syslog Results    alias=Gnb2_syslog    unzip=False
    ...    destination=${TEST_LOG_DIRECTORY}/Gnb2_syslog.tar.gz
    ...    AND    Save Coam SnapShot    log_dir=${TEST_LOG_DIRECTORY}/GNB2    bts_host=10.0.1.3
    ...    AND    Common Test Teardown 2

