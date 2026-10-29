*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CNI106658    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_peafu    CN1_SG6    SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 SCF_CNI106658.xml
#${IPHY_XML}                  ${CURDIR}/config/wts/iphy_106658.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/wts/
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG}                   CNI106658.cfg
#${SWCONFIG_PARAM_GNB}        0x58057A=4;0x58057c=1024
#${DELTA_SCFC}                CNI106658.json
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CNI106658_ET_001_Low_Risk_DL_BLER
#    SA Single UE Attach     ue_id=1
#    Start DLUL Traffic
#    Wait Until Keyword Succeeds    2min    30s    Check Tput
#	DL BLER Mode Profile Setting
#    Capture Logs With DL BLER
#	Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${1}
#	Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${2}
#	Save Egate Log    log_path=${TEST_LOG_DIRECTORY}
#	#Save Snapshot Log
#	Check Rank3 In TTitrace    ${TEST_LOG_DIRECTORY}/ttitrace/${2}
#
#
#CNI106658_ET_009_High_Risk_NACK_Storm
#    Testline Prepare
#    SA Single UE Attach     ue_id=1
#	Start DLUL Traffic
#	Wait Until Keyword Succeeds    2min    30s    Check Tput
#	DL BLER Mode Profile Setting
#    Capture Logs With NACK storm
#	Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${1}
#	Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${2}
#	Save Egate Log    log_path=${TEST_LOG_DIRECTORY}
#	#Save Snapshot Log
#	Check Rank3 In TTitrace    ${TEST_LOG_DIRECTORY}/ttitrace/${2}
#
#
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#
#Start DLUL Traffic
#    SA Start DL Traffic Internal    ue_id=1    mbps=1600     pdu_id=1
#    SA Start UL Traffic Internal    ue_id=1    mbps=120     pdu_id=1
#
#
#Check Tput
#    sleep    10s
#	CUDU L2 Capture And Decode TTitrace    log_id=1    duration=1
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=1s    log_subdir=BIP/1
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=1400
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=ul    cell_type=pcell    scell_index=0    target_tp=85
#
#
#DL BLER Mode Profile Setting
#    Set BLER Testmode    profile_id=1    dl_bler=100,0,0,0,0,0,0,0
#	Set BLER Testmode    profile_id=2    dl_bler=150,0,0,0,0,0,0,0
#	Set CQI Testmode    profile_id=11    ri=2
#
#
#Capture Logs With DL BLER
#	Start Ttitrace With Streaming Mode
#	sleep    1s    reason=wait for traffic stable
#	CUDU L2 Send Action To GNB    ue_id=1    testmode=csi_override    action=activate    profile_id=11
#	CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=activate    profile_id=2
#	sleep    1s    reason=wait for traffic stable
#	Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${2}
#
#Capture Logs With NACK storm
#	Start Ttitrace With Streaming Mode
#	CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=activate    profile_id=1
#	#sleep    0.5s    reason=wait for traffic stable
#	#CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=deactivate    profile_id=1
#	Set Bler With Winsize
#	CUDU L2 Send Action To GNB    ue_id=1    testmode=csi_override    action=activate    profile_id=11
#	sleep    2s    reason=wait for traffic stable
#	Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${2}
#
#Save Snapshot Log
#    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
#    [Documentation]    This keyword is to save snapshot log from admin.
#    Log To Console    Save Snapshot Log...
#    Run Keyword And Ignore Error    COAM.Setup Admin
#    COAM.Collect Snapshot    ${log_dir}//Snapshot.zip
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#
#
#Check Rank3 In TTitrace
#    [Arguments]    ${csv_file_path}
#    A2A Check CSV Table    ${CURDIR}/A2A/rank_switch.ini    ${CURDIR}/A2A/rank_switch.csv    ${csv_file_path}
#
#Testline Prepare
#    Run Keyword And Ignore Error    Clean Edaemon And Egate
#	Reboot TL And Check Configured
#	Delta Commission With SCF File     ${DELTA_SCFC}
#    Suite Setup Start WTS And Check OnAir
#
#Set Bler With Winsize
#	ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=5 dl_bler=\200 win_size=65000
#	CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=activate    profile_id=5
