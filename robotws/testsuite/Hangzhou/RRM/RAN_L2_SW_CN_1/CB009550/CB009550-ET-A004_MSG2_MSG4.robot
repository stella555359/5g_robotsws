*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    swconfig_param=${RD_PARAM}
#...               iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    SBTS00    CRT
#...               FR1    Owner_naliu    CN1_SQ6    RAN_5G_FDD
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./CB009550_resource.robot
#
#*** Variables ***
#${RD_PARAM}          0x58057a=0x1F;0x58057b=0x10000
#${SCF_PATH}          ${CURDIR}/resources/config
#${SCF_FILE}          SCF_CB009550_Enable.xml
#${WTS_LOCAL}         ${CURDIR}/resources/config/WTS
#${WTS_CFG}           CB009550-A.cfg
#${IPHY_FILE}         ${CURDIR}/resources/config/WTS/iphy-A004.xml
#${PROFILE_ID}        1
#${GNB_ID}            2
#${CELL_ID}           1
#${BEARER_ID}         2
#@{OLD_CFG_PARAMS}    plmn=[0-9]+:[0-9]+
#@{NEW_CFG_PARAMS}    plmn=302:610
#@{LOG_NAME_LIST}     btslog
#${COUNT}             0
#${UE_1}              1
#${UE_2}              2
#${UE_3}              3
#${UE_4}              4
#${UE_1_DL_TRF}       220
#${UE_1_UL_TRF}       150
#@{UE_LIST_DETACH}    1    2
#${MSG3_RETR_NUM}     5
#${TARGET_TP_DL}      220
#${TARGET_TP_UL}      100
#${TPUT_RATE}         0.2
#${A2A_PATH}          A2A_04
#&{COUNTER1_INFO}    counter_id=M55308C10001    counter_path=CELLS/NRCELL-1/NCELA    min_value=20000000
#&{COUNTER2_INFO}    counter_id=M55308C10002    counter_path=CELLS/NRCELL-1/NCELA    min_value=20000000
#&{COUNTER3_INFO}    counter_id=M55308C00010    counter_path=CELLS/NRCELL-1/NCELA    min_value=14000
#&{COUNTER4_INFO}    counter_id=M55308C00011    counter_path=CELLS/NRCELL-1/NCELA    min_value=14000000
#&{COUNTER5_INFO}    counter_id=M55308C00036    counter_path=CELLS/NRCELL-1/NCELA    min_value=5000
#&{COUNTER6_INFO}    counter_id=M55308C00037    counter_path=CELLS/NRCELL-1/NCELA    min_value=5000000
#@{COUNTER_LIST}    ${COUNTER1_INFO}    ${COUNTER2_INFO}    ${COUNTER3_INFO}    ${COUNTER4_INFO}    ${COUNTER5_INFO}    ${COUNTER6_INFO}
#
#
#
#*** Test Cases ***
#CB009550-ET-A004_Verify_MSG2_MSG4_and_PDSCH_FDM_with_SA_FDD_20M
#    SA Single UE Attach    ${UE_1}
#    Start SA UE Internal Trf DLUL    ${UE_1}    ${UE_1_DL_TRF}    ${UE_1_UL_TRF}
#    Check SA UE DLandUL Internal Avg L3 Tput    ${UE_1}    ${TARGET_TP_DL}    ${TARGET_TP_UL}    ${TPUT_RATE}
#    Trigger MSG3 Retran    ${UE_2}    ${MSG3_RETR_NUM}
#    Start Ttitrace With Streaming Mode
#    Multi UE Attach
#    Stop Ttitrace
#    Check SA UE DLandUL Internal Avg L3 Tput    ${UE_1}    ${TARGET_TP_DL}    ${TARGET_TP_UL}    ${TPUT_RATE}
#    Decode Ttitrace Log    ${OUTPUT_DIR}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}${A2A_PATH}${/}CB009550_A_ttitrace_ini_dedicated_FDM.ini
#    ...    i    save_log_directory=${output_dir}/ttitrace_streaming
#    PM Counter Check
#
#*** Keywords ***
#Multi UE Attach
#    common_SA_ue_command.SA 5G Attach    ue_id=${UE_2}
#    common_SA_ue_command.SA 5G Attach    ue_id=${UE_3}
#    common_SA_ue_command.SA 5G Attach    ue_id=${UE_4}
#PM Counter Check
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Sleep     ${time}
#    Check Multi PM Counters Latest Value From Admin    ${COUNTER_LIST}
