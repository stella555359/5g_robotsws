*** Settings ***
Documentation
...
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
${UE_ID}      11
${PROFILE_ID_1}        1
${PROFILE_ID_2}        2
${LOG_PATH}       ${OUTPUT DIR}
${download_dir}    ${OUTPUT DIR}/tmp/
${bippath}    /tmp
${log_name}    tcpdumpL2L1_filtering_off.pcap0
${luashark_conf_path}    ${output_dir}/generated_luashark/luashark.lua
${XP_SCRIPT_PATH}           ${output_dir}/generated_luashark/xpshark.lua
${5_1_120_pattenid_beam0}         DlData_PdcchSendReq.PdcchSendReq.beamId == 0x00
${5_1_120_pattenid_beam1}         DlData_PdcchSendReq.PdcchSendReq.beamId == 0x01
${5_1_90_pattenid_beam0}         DlData_PdcchSendReq.PdcchSendReq.beamId == 0x00
${5_1_90_pattenid_beam1}         DlData_PdcchSendReq.PdcchSendReq.beamId == 0x01

*** Keywords ***

Init testline config file
    Suite Setup Update GNB
    Suite Setup Copy WTS Config Files From QT
    Full Commission SCF File With Admin    /home/ute/testline_init_results/configs/scfc.xml
    Reboot Testline and Check 1695 Cell Onair
    Start WTS And Check OnAir for 1695

Reboot Testline and Check Cell Onair for 1695
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


Modify Airphone Swconfig To Fix ASIB Not Onair Isuue
    [Documentation]    It's workround.
    ${cmd}=    Catenate    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip}
    ...    grep "0x70676" /ffs/run/swconfig.txt
    ${rc}	${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${cmd}=    Catenate    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip}
    ...    sed -i 's/0x70676=2/0x70676=3/' /ffs/run/swconfig.txt
    ${rc}	${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${cmd}=    Catenate    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip}
    ...    grep "0x70676" /ffs/run/swconfig.txt
    ${rc}	${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}

Reboot Testline and Check 1695 Cell Onair
    Reboot Testline and Check Cell Onair for 1695
    Start WTS And Check OnAir for 1695

Start WTS And Check OnAir for 1695
    [Documentation]    This keyword is to start WTS, wait for onAir
    Run Keyword And Ignore Error    clean edaemon and egate
    Start UTE WTS
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
    Verify Cell Setup

UE Beamforming Profile And Association For 6 Beams
    [Arguments]    ${ue_id}=11
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-70
    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    ${CMD_BC_PRF_3}    Set Variable
    ...    beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-80
    ${CMD_BC_PRF_3_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=3
    ${CMD_BC_PRF_4}    Set Variable
    ...    beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-90
    ${CMD_BC_PRF_4_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=4
    ${CMD_BC_PRF_5}    Set Variable
    ...    beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-100
    ${CMD_BC_PRF_5_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=5
    ${CMD_BC_PRF_6}    Set Variable
    ...    beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=2 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-120
    ${CMD_BC_PRF_6_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=6
    ${CMD_TESTMODE_ATTACH_1}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_3}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_4}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_5}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_6}
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

5G Attach and Get Throughput
    NSA 5G Attach    ue_id=11    gnb_id=2    cell_id=1    bearer_id=2
    NSA Start DL Traffic    ue_id=11    bearer_id=2    mbps=10    trf_id=1
    NSA Start UL Traffic    ue_id=11    bearer_id=2    mbps=10    trf_id=1
    ${dl_tp}=    NSA Get UE Average Traffic    ue_id=11    bearer_id=2    dir=dl
    ${ul_tp}=    NSA Get UE Average Traffic    ue_id=11    bearer_id=2    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True

UE Beamforming Switch
    [Arguments]    ${ue_id}=${UE_ID}    ${profile_id}=2
    ${CMD_TESTMODE_SWITCH}    Set Variable
    ...   ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=switch scell=8
    Log To Console    ******Beam Control UE${ue_id} Switch to Profile ${profile_id} ******
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_SWITCH}

Modify Parameter For 90
    #Lock cell via parameters modification
    ${delta_file}    Set Variable    ${CURDIR}/Delta_1695.json
    @{old_params_list}    Create List    "leftEdgeAngle": "[0-9]+"    "rightEdgeAngle": "[0-9]+"
    @{new_params_list}    Create List    "leftEdgeAngle": "45"    "rightEdgeAngle": "45"
    Modify Text File    ${delta_file}    ${old_params_list}    ${new_params_list}
    Delta Commission Json File With Admin    ${delta_file}
    #Unlock cell via parameters modification

capture bip
    [Arguments]    ${save_log_name}
    Run Keyword And Ignore Error    common_log_capture.Teardown All Connections
    Start Gnb BIP Log
    Sleep    5s
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
    [Arguments]       ${log_name}
    ${filter}=    Set Variable    dldata_ssblocksendreql1sw
    @{csv_title_list}=    Create List   3gpp.slot    DlData_SsBlockSendReqL1sw_t.patternId_item
    ...    DlData_SsBlockSendReqL1sw_t.ceAxCIndex_item
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${log_name}    ${LOG_PATH}/ssblock.csv    ${filter}    ${csv_title_list}

Convert BIP To CSV By MCShark For DlData_PdcchSendReq
    [Arguments]       ${log_name}
    ${filter}=    Set Variable    dldata_pdcchsendreql1sw
    @{csv_title_list}=    Create List   3gpp.slot    DlData_PdcchSendReqL1sw_t.beamId
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${log_name}    ${LOG_PATH}/pdcch.csv    ${filter}    ${csv_title_list}