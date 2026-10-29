*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Modify IPHY XML File    ${param_dict}
#...               AND    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Add Multi UE NSA    ue_ids=13-18
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${DELTA_REC_FILE}
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    RAN_5G_TDD    CRT    RAN_5G    FR1
#...               Owner_K3CHEN    SBTS00    SBTS23R1    SBTS22R4
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ./FGCR8181_Resource.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/resources/config
#${DELTA_FILE}                   Delta_Conf_FGCR8181_80M.json
#${DELTA_REC_FILE}               Delta_Recov_FGCR8181.json
#${UE_ID}                        1
#${PROFILE_ID}                   1
#${GNB_ID}                       2
#${CELL_ID}                      2
#${BEARER_ID}                    2
#@{LOG_NAME_LIST}                snapshot
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${LOCAL_WTS_DIR}                ${CURDIR}/resources/wts
#${WTS_DIR}                      /opt/wts/latest
#${WTS_CFG}                      basic_setup.cfg
#&{PARAM_DICT}                   NumberOfSubCellsDL=2    NumberOfSubCellsUL=2
#
#*** Test Cases ***
#FGCR8181_BA_ET_05_FDM_UL_DL_Multiple_Ues_Full_Buffer_TDD_FR1_80MHz
#    MultiUE Attach With NSA    11    14
#    MultiUE Attach With NSA    15    18    2
#    MultiUE Do Traffic With NSA    11    18    150    20
#    MultiUE Check Tput    11    18    ${BEARER_ID}    dl    1
#    MultiUE Check Tput    11    18    ${BEARER_ID}    ul    1
#    common_log_capture.Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=get BIP and TTI data
#    common_log_capture.Stop Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/
#    Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv    ${OUTPUT_DIR}/ttitrace_streaming/output_dl_formated.csv
#    Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv    ${OUTPUT_DIR}/ttitrace_streaming/output_ul_formated.csv
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/8181_80M${/}8181_80M.ini    i    save_log_directory=${OUTPUT_DIR}/ttitrace_streaming
