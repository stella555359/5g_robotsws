*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    mode=debug    collect_config_file=True
#Test Setup        Common Test Setup
#Test Teardown     Run Keywords    Common Test Teardown    mode=debug    AND    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}
#...               AND    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}
#Force Tags        CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    CRT    RAN_5G_TDD
#...               FR1    Owner_suqian    CN1_SQ    PRI-High    RAN_5G    SBTS00    SBTS23R1    SBTS22R4    SBTS22R3
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}            ${CURDIR}/config
#${DELTA_FILE}          Delta_Conf_5GC000533_E.json
#${UE1_ID}              1
#${UE2_ID}              2
#${PROFILE_ID_1}        1
#${PROFILE_ID_2}        2
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       bip
#${COUNT}               0
#${BACKUP_SCF_FILE}     ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml
#${LOG_PATH}            ${OUTPUT DIR}
#
#*** Test Cases ***
#5GC000533_E_Beam_recovery
#    Start GNB AP Syslog    log_dir=${SUITE_LOG_DIRECTORY}
#    UE Beamforming Profile And Association For 2 Beams    ${UE1_ID}
#    SA 5G Attach    ${UE1_ID}
#    SA 5G PDU Session Setup    ${UE1_ID}
#    Tput And Check
#    UE Beamforming Switch    ${UE1_ID}    ${PROFILE_ID_2}
#    Sleep    10s    reason=Wait the beam switch stable...
#    Tput And Check
#    UE Beamforming Recovery    ${UE1_ID}    ${PROFILE_ID_1}
#    Sleep    10s    reason=Wait the beam recovery stable...
#    Tput And Check
#    SA 5G Detach    ${UE1_ID}
#    Collect GNB AP SnapShot Via Aashell    log_dir=${LOG_PATH}
#    Verify Recovery Log from snapshot    ${CURDIR}/gnb_filter_msg.txt    ${SUITE_LOG_DIRECTORY}/l2ps_filtered.txt
#
#*** Keywords ***
#Tput And Check
#    SA Start DLUL Traffic    50    50    10
#    SA Stop DLUL Traffic
#    SA Check Average Traffic Bigger Than Target    dl    10
#    SA Check Average Traffic Bigger Than Target    ul    10
#
#UE Beamforming Profile And Association For 2 Beams
#    [Arguments]    ${ue_id}=1
#    ${CMD_BC_PRF_1}    Set Variable
#    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
#    ${CMD_BC_PRF_1_DSP}    Set Variable
#    ...    beam_control_testmode_nr profile_id=1
#    ${CMD_BC_PRF_2}    Set Variable
#    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
#    ${CMD_BC_PRF_2_DSP}    Set Variable
#    ...    beam_control_testmode_nr profile_id=2
#    ${CMD_TESTMODE_ATTACH}    Set Variable
#    ...   ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
#    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
#    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
#    Log To Console    ******The BC profiles are set******
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
#    Log To Console    ******Beam Control Profile 1 Display: ******
#    Log To Console    ${output}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
#    Log To Console    ******Beam Control Profile 2 Display: ******
#    Log To Console    ${output}
#    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH}
#
#UE Beamforming Switch
#    [Arguments]    ${ue_id}=1    ${profile_id}=2
#    ${CMD_TESTMODE_SWITCH}    Set Variable
#    ...   ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=switch
#    Log To Console    ******Beam Control UE${ue_id} Switch to Profile ${profile_id} ******
#    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_SWITCH}
#
#UE Beamforming Recovery
#    [Arguments]    ${ue_id}=1    ${profile_id}=1
#    ${CMD_TESTMODE_RECOVERY}    Set Variable
#    ...   ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=recovery
#    Log To Console    ******Beam Control UE${ue_id} Recovery to Profile ${profile_id} ******
#    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_RECOVERY}
#
#Verify Recovery Log from snapshot
#    [Arguments]    ${filter_message_file}    ${outlog}
#    OperatingSystem.Run And Return Rc And Output    unzip ${LOG_PATH}/snapShot_gnb.zip -d ${LOG_PATH}/snapShot_gnb
#    sleep    10s
#    OperatingSystem.Run And Return Rc And Output    unzip ${LOG_PATH}/snapShot_gnb/2740_ASP-2740_runtime.zip -d ${LOG_PATH}/snapShot_gnb/pslog/
#    sleep    5s
#    ${content}=    Get File    ${filter_message_file}
#    ${content_list}=    String.Split To Lines    ${content}
#    FOR    ${item}    IN    @{content_list}
#           OperatingSystem.Run And Return Rc And Output    echo -----Filter ${item} to ${outlog}----->>${outlog}
#           ${result}    OperatingSystem.Run And Return Rc And Output    grep '${item}' ${LOG_PATH}/snapShot_gnb/pslog/ASP-2740_runtime.log>>${outlog}
#           ${res_list}    Evaluate    list(${result})
#           Run keyword if    ${res_list}[0]!=0    Fail    msg=Beforming recovery syslog check failure!
#    END
#