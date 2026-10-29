*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       #Common Suite Setup
##Test Setup       Common Test Setup
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG06_SM1    CB009169    owner_qiaren
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${SCFC_FILE}             CB005934_ET_803_scfc.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts
#${WTS_DIR}               /opt/iphy/latest
#${IPHY_6F}               ${CURDIR}/Config/wts/iphy_6F_803.xml
#${SWCONFIG_PARAM_GNB}    0x89003B=1
##${SWCONFIG_PARAM_AP}    0x70690=1;
#${WTS_CFG}               5934_A803.cfg
#${WTS_AP_XML}            airphone.xml
#${UE_ID}                 2
#${4CC_4F_SCELL}          ('1', '50', '71'), ('2', '51', '25'), ('3', '61', '41')
#&{GNB_ASIK}              ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#@{4CC_DL_TPUT_LIST}      38    180    180    280
#@{2CC_UL_TPUT_LIST}      75    50
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB005934_ET_A803_FDD_DL_4CC_A6_Based_Scell_Swap_While_UE_OH_State
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_6F}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    #...    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ue_id=${UE_ID}    pdu_id=1
#    Trigger A1 Scell Addition    ue_id=${UE_ID}    phycell_id=50    srsrp_nr=120    meas_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=900
#    Verify Scells Are Activation    cell_nums=4
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${4CC_DL_TPUT_LIST}    4
#    #Capture Logs And Check TTitrace    log_id=1
#    Send Send Assistance Information And Check Scell Active Status    2    ${UE_ID}    2    1    1    deactivated
#    Trigger A6 Event For Scell Swap    ${UE_ID}    5    1    55
#    Send Send Assistance Information And Check Scell Active Status    3    ${UE_ID}    3    1    4    activated
#    Wait Until Keyword Succeeds    1min    5s    Check Pcell Scell TP On Target After Scell Swap    ${UE_ID}    ${4CC_DL_TPUT_LIST}
#    #Capture Logs And Check TTitrace    log_id=4
#
#*** Keywords ***
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_id}
#    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_id}
#    CUDU L2 Capture And Decode TTitrace    log_id=${log_id}    duration=3
#    CUDU L2 Check DTXNACK Rate    log_id=${log_id}
#    CUDU L2 Check UL DTXCRC Rate    log_id=${log_id}
#
#Send Send Assistance Information And Check Scell Active Status
#    [Arguments]    ${log_id}    ${ue_id}    ${reducedCCsDL}    ${reducedCCsUL}    ${cell_nums}    ${scell_active_status}=activated
#    #Start Ttitrace With Streaming Mode
#    Send OAI To GNB    ${ue_id}    yes    ${reducedCCsDL}    ${reducedCCsUL}
#    Check Scell Active Status From Egate    ${cell_nums}    ${scell_active_status}
#    #Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    #Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    #CUDU L2 Check UL DTXCRC Rate    ${log_id}
#    #CUDU L2 Check DTXNACK Rate    ${log_id}
#
#Check Scell Active Status From Egate
#    [Arguments]    ${scell_nums}    ${scell_active_status}=activated
#    ${loop}    Evaluate    ${scell_nums}+1
#    Log To Console    \nverify Scell Activation or Deactivation Info...
#    FOR    ${id}    IN RANGE    1    ${loop}
#    Check Scell Status    ${id}    ${scell_active_status}
#    END
#
#Check Scell Status
#    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${egate_file}=/opt/iphy/latest/egate_console.log.001
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
#    ${content}    OperatingSystem.Get File    path=${egate_file}
#    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
#    ${check_rst}    Get Length    ${match_list}
#    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    failed
#    [Return]    ${scell_status}
#
#Trigger A6 Event For Scell Swap
#    [Arguments]    ${UE_ID}    ${meas_id}    ${scell_index}    ${target_scell_id}
#    Log To Console    Trigger A6 Event For Scell Swap
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A6
#    ...    scell=${scell_index} scell_rsrp=60 phycell_id=${target_scell_id} nrsrp_nr=80
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Sleep    5s    reason=wait for traffic stable
#
#Check Pcell Scell TP On Target After Scell Swap
#    [Arguments]    ${ue_id}    ${exp_dl_tput_list}
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=2    target_tp=${exp_dl_tput_list[2]}
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=3    target_tp=${exp_dl_tput_list[3]}
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=4    target_tp=${exp_dl_tput_list[1]}
