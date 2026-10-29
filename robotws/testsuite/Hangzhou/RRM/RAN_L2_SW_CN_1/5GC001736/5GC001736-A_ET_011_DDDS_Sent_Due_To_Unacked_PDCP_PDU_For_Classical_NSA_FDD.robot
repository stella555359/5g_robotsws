*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    ${SWCONFIG_PARAM}    scf_file=${DELTA_FILE}
#...               AND    Set Suite Variable    ${VENDOR_PATH}    ${SUITE_LOG_DIRECTORY}/vendor.xml
#...               AND    Modify Vendor File And Do Full Commission    params_dict=${VENDOR_PARAMS_DICT}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Modify Text File    ${WTS_DIR}/${WTS_CFG}    ${OLD_CFG_PARAMS}    ${NEW_CFG_PARAMS}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
##Force Tags        CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4    SBTS22R2
##...               master_classicalbts_all    STATE_CONFIGURED    CRT    FR1
##...               Owner_molyang    CN1    PRI-High    5G00    QCD_MN_5G    QCP_5G    5G_RAN    21A_classicalbts
#Resource          5GC001736_Common_Keywords.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}         0x45005a=1
#${SCF_PATH}               ${CURDIR}/config
#${DELTA_FILE}             Delta_Configuration_scf_NSA_actDDDSPeriodOptimization_actDddsReduction.json
#${UE_ID}                  1
#${PROFILE_ID}             1
#${GNB_ID}                 2
#${CELL_ID}                1
#${BEARER_ID}              2
#@{OLD_CFG_PARAMS}         plmn=[0-9]+:[0-9]+
#@{NEW_CFG_PARAMS}         plmn=302:610
#@{LOG_NAME_LIST}          btslog    snapshot
#&{VENDOR_PARAMS_DICT}    dddsPeriod=20
#${DL_DATA_SEND_MBPS}      150
#${DL_DATA_DURATION_S}     20
#${DL_DATA_EXPECT_MBPS}    200
#${INI_PATH}               ${CURDIR}${/}config${/}A2A
#${TTI_DAT_FILE_NAME}      *L2TraceHi_DU.dat
#${TTI_CSV_FILE_NAME}      itf_L2Log_Du_Hi_Events_Tx_DuFlowControlData_t_sorted.csv
#${TTI_DECODE_PY_PATH}     ${CURDIR}/config/Tti_Decode
#
#*** Test Cases ***
#5GC001736-A_ET_011_DDDS_Sent_Due_To_TooManyAckedRlcPdu _For_Classical_NSA_FDD
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${DL_DATA_SEND_MBPS}    1
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${DL_DATA_SEND_MBPS}    2
#    Sleep    ${DL_DATA_DURATION_S}
#    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    dl    ${DL_DATA_EXPECT_MBPS}
#    Run Keyword And Ignore Error    Collect GNB Snapshot Via Aashell    log_dir=${test_log_directory}
#    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    dl
#    Tti Decode To Csv
#    Check A2A    5GC001736-A_ET_011
#
