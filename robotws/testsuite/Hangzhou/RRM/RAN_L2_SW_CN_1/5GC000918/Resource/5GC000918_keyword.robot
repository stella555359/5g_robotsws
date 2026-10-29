*** Settings ***
Resource           ../../CUDU_L2/common_setup_teardown.robot
*** Variables ***
${Asik_HOST}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_USER}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ASIK_PWD}       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${WEBUI_HOST}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_ABIL_addr}    fsp-1-1a
${Loner_addr}     192.168.253.22
${GNB_ABIL_addr}    192.168.253.20
${slave_addr}    192.168.253.21
${Loner_username}    toor4nsn
${Loner_password}    oZPS0POrRieRtu
${bip_script}    ${CURDIR}/../../../CUDU_L2/scripts/BIP/
${file1}    gnbMirroring.sh
${file2}    gnbMirroringConfig.sh
${file3}    gulp
${UE_ID}      1
${PROFILE_ID_1}        1
${PROFILE_ID_2}        2
${scf_path}    ${CURDIR}
${LOG_PATH}       ${OUTPUT DIR}
${download_dir}    ${OUTPUT DIR}/tmp/
${bippath}    /tmp
${log_name}    tcpdumpL2L1_filtering_off.pcap0
${1}    beam_control_testmode_nr
${2}    ueBeamIndexInitial
*** Keywords ***

Init testline config file
    Suite Setup Update GNB
    Suite Setup Copy WTS Config Files From QT
    Full Commission SCF File With Admin    /home/ute/testline_init_results/configs/scfc.xml
    Reboot TL And Check Configured
    Start WTS And Check OnAir

Reboot TL And Check Configured for 918
    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
    ...            It with try ${MAX_REBOOT_TIME} times to make sure the testline can be reboot successfully.
    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TIME} times...
    FOR    ${index}    IN RANGE    1    ${MAX_REBOOT_TIME}+1
         Log To Console    ===============Reboot Time: ${index}==============
         Hard Reboot Testline
         ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
         Exit For Loop If    '${res}'=='True'

    END
Common Suite Setup
    Suite Setup Update GNB
    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Reboot Testline and Check 918 Cell Onair
    Reboot TL And Check Configured for 918
    Start WTS And Check OnAir for 918

Start WTS And Check OnAir for 918
    [Documentation]    This keyword is to start WTS, wait for onAir
    Run Keyword And Ignore Error    clean edaemon and egate
    Start UTE WTS
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
    sleep    5s
    Verify Cell Setup
	
5G Attach and Get Throughput
    NSA 5G Attach    ue_id=11    gnb_id=2    cell_id=1    bearer_id=2
    NSA Start DL Traffic    ue_id=11    bearer_id=2    mbps=10    trf_id=1
    NSA Start UL Traffic    ue_id=11    bearer_id=2    mbps=10    trf_id=1
    ${dl_tp}=    NSA Get UE Average Traffic    ue_id=11    bearer_id=2    dir=dl
    ${ul_tp}=    NSA Get UE Average Traffic    ue_id=11    bearer_id=2    dir=ul
    log    DL Troughput is ${dl_tp}    console=True 
    log    UL Troughput is ${ul_tp}    console=True

capture bip
    [Arguments]    ${save_log_name}
    Run Keyword And Ignore Error    common_log_capture.Teardown All Connections
    Start Gnb BIP Log
    Sleep    10s
    Stop Gnb BIP Log    ${OUTPUT_DIR}
    OperatingSystem.Run And Return Rc And Output    mv ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap* ${OUTPUT_DIR}/${save_log_name}

Connect to gNB_ASIK
    [Arguments]    ${alias}=gNB_ASIK
    ssh.Connect to    hostname=${Asik_HOST}    username=${ASIK_USER}    password=${ASIK_PWD}    alias=${alias}

Connect to GNB_loner
    [Arguments]    ${alias}=GNB_loner    ${proxy}=gNB_ASIK
    ssh.connect_to    hostname=${Loner_addr}    username=${Loner_username}    password=${Loner_password}    alias=${alias}    proxy=${proxy}

connect to host
    [Arguments]    ${alias}=testPC
    ssh.connect_to    hostname=${tl.test_pc.default_ssh_connection_details.addr}    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=${alias}

Connect to ASIK_slave
    [Arguments]    ${alias}=ASIK_slave    ${proxy}=gNB_ASIK
    ssh.connect_to    hostname=${slave_addr}    username=${Loner_username}    password=${Loner_password}    alias=${alias}    proxy=${proxy}
	
Convert BIP To CSV By MCShark For DlData_SsBlockSendReq
    [Arguments]    ${logname}
    ${filter}=    Set Variable    dldata_ssblocksendreq
    @{csv_title_list}=    Create List   3gpp.slot    3gpp.subcellid    DlData_SsBlockSendReq_t.patternId_item
    ...    DlData_SsBlockSendReq_t.ceAxCIndex_item
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${logname}    ${LOG_PATH}/ssblock.csv    ${filter}    ${csv_title_list}

Convert BIP To CSV By MCShark For DlData_PdschSendReq
    [Arguments]    ${logname}
    ${filter}=    Set Variable    dldata_pdschsendreq
    @{csv_title_list}=    Create List    3gpp.subcellid    DlData_PdschGrant.patternId_item 
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${logname}    ${LOG_PATH}/pdsch.csv    ${filter}    ${csv_title_list}
	
UE Beamforming Switch
    [Arguments]    ${ue_id}=${UE_ID}    ${profile_id}=2
    ${CMD_TESTMODE_SWITCH}    Set Variable
    ...   ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=switch scell=0
    Log To Console    ******Beam Control UE${ue_id} Switch to Profile ${profile_id} ******
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_SWITCH}
	
Capture Bip For 918
    [Arguments]    ${save_log_name}
    Run Keyword And Ignore Error    common_log_capture.Teardown All Connections
    Start Gnb BIP Log
    Sleep    10s
    Stop Gnb BIP Log    ${OUTPUT_DIR}
    OperatingSystem.Run And Return Rc And Output    mv ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap ${OUTPUT_DIR}/${save_log_name}

UE Beamforming Profile And Association For 32 Beams
    [Arguments]    ${ue_id}=1
    ${CMD_BC_PRF_1}    Set Variable
    ...    ${1} profile_id=1 ${2}=0,5,10,15,16,21,26,31 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50 beamType=Analog  
    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    ${1} profile_id=1
    ${CMD_BC_PRF_2}    Set Variable
    ...    ${1} profile_id=2 ${2}=5,0,10,15,16,21,26,31 ssbeam_bestbeam=5 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120 beamType=Analog
    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    ${1} profile_id=2
    ${CMD_BC_PRF_3}    Set Variable
    ...    ${1} profile_id=3 ${2}=10,0,5,15,16,21,26,31 ssbeam_bestbeam=10 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125 beamType=Analog
    ${CMD_BC_PRF_3_DSP}    Set Variable
    ...    ${1} profile_id=3
    ${CMD_BC_PRF_4}    Set Variable
    ...    ${1} profile_id=4 ${2}=15,0,5,10,16,21,26,31 ssbeam_bestbeam=15 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120 beamType=Analog
    ${CMD_BC_PRF_4_DSP}    Set Variable
    ...    ${1} profile_id=4
    ${CMD_BC_PRF_5}    Set Variable
    ...    ${1} profile_id=5 ${2}=16,0,5,10,15,21,26,31 ssbeam_bestbeam=16 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139 beamType=Analog
    ${CMD_BC_PRF_5_DSP}    Set Variable
    ...    ${1} profile_id=5
    ${CMD_BC_PRF_6}    Set Variable
    ...    ${1} profile_id=6 ${2}=21,0,5,10,15,16,26,31 ssbeam_bestbeam=21 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70 beamType=Analog
    ${CMD_BC_PRF_6_DSP}    Set Variable
    ...    ${1} profile_id=6
    ${CMD_BC_PRF_7}    Set Variable
    ...    ${1} profile_id=7 ${2}=26,0,5,10,15,16,21,31 ssbeam_bestbeam=26 ssbeam_rsrp_best=-46 ssbeam_rsrp_avg=-100 beamType=Analog
    ${CMD_BC_PRF_7_DSP}    Set Variable
    ...    ${1} profile_id=7
    ${CMD_BC_PRF_8}    Set Variable
    ...    ${1} profile_id=8 ${2}=31,0,5,10,15,16,21,26 ssbeam_bestbeam=31 ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-100 beamType=Analog
    ${CMD_BC_PRF_8_DSP}    Set Variable
    ...    ${1} profile_id=8
    ${CMD_TESTMODE_ATTACH_1}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_3}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_4}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_5}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_6}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_7}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_8}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_1}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    Log To Console    ******Beam Control Profile 1 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    Log To Console    ******Beam Control Profile 2 Display: ******
    Log To Console    ${output}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_3_DSP}
    Log To Console    ******Beam Control Profile 3 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_4_DSP}
    Log To Console    ******Beam Control Profile 4 Display: ******
    Log To Console    ${output}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_5_DSP}
    Log To Console    ******Beam Control Profile 5 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_6_DSP}
    Log To Console    ******Beam Control Profile 6 Display: ******
    Log To Console    ${output}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_7_DSP}
    Log To Console    ******Beam Control Profile 7 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_8_DSP}
    Log To Console    ******Beam Control Profile 8 Display: ******
    Log To Console    ${output}
