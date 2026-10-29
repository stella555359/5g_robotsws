*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Force Tags         Classical    IPV4    IPV6    FR1    Owner_suqian    PRI-High    5GC001695    RAN_5G    SBTS00    SBTS23R1    SBTS22R4
#...                CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    RAN_5G_TDD    CONFIGS_0.300/custom_config.yaml
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Update Aic GNB    VCU_SCFC_PATH=${VCU_SCFC_PATH}    VDU_SCFC_PATH=${VDU_SCFC_PATH}
#...               AND    Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#
#*** Variables ***
#${VCU_SCFC_PATH}    ${CURDIR}/Config/Actual_vCU.xml
#${VDU_SCFC_PATH}    ${CURDIR}/Config/Actual_vDU1.xml
#${GNB_INDEX}        0
#${LOCAL_WTS_DIR}    ${CURDIR}/Config
#${WTS_CFG}          basic_setup.cfg
#${LOG_PATH}       ${OUTPUT DIR}
#${ENB_ID}           1
#${GNB_ID}           2
#${UE_ID}            11
#
#*** Test Cases ***
#
#5GC001695_A003 Transmission of 6 SSPBCH Blocks with Basic Beam set #3#3 during cell setup for 64TRX RRU
#    [Tags]    case3    CRT
#    Start Vran40 BIP Log    L1BIPRT
#    Sleep    10s
#    Stop Vran40 BIP Log    L1BIPRT
#    #Download MCShark To UTE    vDUCNF_${VDU_SW_VERSION}
#    Convert BIP To CSV By MCShark For DlData_SsBlockSendReq
#    A2A_Check_CSV_Table    ${CURDIR}/Resources/A003.ini    ${LOG_PATH}/ssblock.csv
#
#*** Keywords ***
#
#Convert BIP To CSV By MCShark For DlData_SsBlockSendReq
#    ${filter}=    Set Variable    dldata_ssblocksendreq
#    @{csv_title_list}=    Create List   3gpp.slot    DlData_SsBlockSendReq_t.patternId_item
#    ...    DlData_SsBlockSendReq_t.ceAxCIndex_item
#    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/l1up.pcap    ${LOG_PATH}/ssblock.csv    ${filter}    ${csv_title_list}
