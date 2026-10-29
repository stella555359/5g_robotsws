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
##Force Tags        CLOUD_5G_KL_AP_NSA_FS_CMWV_FDD    SBTS00    SBTS23R1    SBTS22R4    SBTS22R2    CRT    FR1
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
#&{VENDOR_PARAMS_DICT}    dddsPeriod=40
#${DL_DATA_SEND_MBPS}      25
#${DL_DATA_DURATION_S}     20
#${DL_DATA_EXPECT_MBPS}    20
#
#*** Test Cases ***
#5GC001736-B_ET_002_Single_DRB_Max_throughput_With_UDP_For_Classical_NSA_FDD_When_DDDS_Period_40ms
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${DL_DATA_SEND_MBPS}
#    Sleep    ${DL_DATA_DURATION_S}
#    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    dl    ${DL_DATA_EXPECT_MBPS}
#
