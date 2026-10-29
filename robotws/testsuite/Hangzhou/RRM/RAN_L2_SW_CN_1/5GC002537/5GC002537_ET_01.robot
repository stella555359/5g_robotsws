*** Settings ***
Documentation    ...
#Documentation     this case is to verify ul srs ports number be changed depend on ulsinr profile of AP
#...               Author: qiqi.luo@nokia-sbell.com
#...               swconfig 0x580019 means L2PS UL rank, rank1 is 1, rank2 is 2
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}    swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    FR1    Owner_haifewan    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/config
#${DELTA_FILE}            5GC002537_ET_01_60M_1208.json
#${UE_ID}                 11
#${PROFILE_ID}            1
#${GNB_ID}                2
#${CELL_ID}               1
#${BEARER_ID}             2
##@{LOG_NAME_LIST}         ${EMPTY}
#${SLOT1}                 uldata_puschreceivereq.subcellsarray.subcells.grantsarray.grants.numOfLayers == 0x01
#${SLOT2}                 uldata_puschreceivereq.subcellsarray.subcells.grantsarray.grants.numOfPrb == 0x005d
#@{BIP_LOG_FILTER}        ${SLOT1}    ${SLOT2}
#${SWCONFIG_PARAM}        0x580019=1;0x580011=0;0x580012=0;0x580013=0;0x580014=0;
#${FILTER}                SEPARATOR=${EMPTY}    (UlData_puschReceiveReqGrant_t.numOfPrb == 93) ||
#...                      (UlData_puschReceiveReqGrant_t.numOfLayers == 1)
#@{CSV_TITLE_LIST}        UlData_puschReceiveReqGrant_t.numOfPrb    UlData_puschReceiveReqGrant_t.numOfLayers
#${CHECK_POINT_REGEXP}    "UlData_PuschReceiveReq\\s*","93","1"
#
#*** Test Cases ***
#5GC002537_ET_01_Disable_FDM_Single_UE_MCS0_Rank1_NSA_60M_1208
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    Start Gnb BIP Log
#    Sleep    2s    reason=Capture BIP log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    ${bip_log}    Set Variable    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap
#    Download MCShark To UTE
#    Convert BIP To CSV By MCShark    ${bip_log}    ${OUTPUT_DIR}/bip_log.csv    ${FILTER}    ${CSV_TITLE_LIST}
#    ${csv_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/bip_log.csv
#    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${CHECK_POINT_REGEXP}
#    Should Be True    ${check_status}
#
