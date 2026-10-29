*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup For Common Setting
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB006137
#Resource          resources/CB006137_BC_resource.robot
#
#*** Variables ***
##CB006137_ET_BC006
#${FULL_SCF}                Conf_CB006137_BC005.xml
#${WTS_CFG}                 basic_setup_6137_BC43_BC51.cfg
#${WTS_LOCAL}               ${CURDIR}/config/WTS
#${SCF_PATH}                ${CURDIR}/config
#${SWCONFIG_PARAM}          0x580591=0;0x58056B=1;0x58057b=0x2B000080;0x58057f=0x10;0x580307=0x5FE;0x580641=1;0x58057a=3;0x58063d=2000;0x580611=1
#${SCELL_PCI}               52
#${RSRP}                    105
#${RSRQ}                    105
#${2CC_UE_ID}               1
#@{2CC_UE_ID_LIST}          1
#${2CC_UL_DATA}             40
#${2CC_DL_DATA}             10
#@{2CC_EXP_UL_TPUT_LIST}    10    10
#@{2CC_EXP_DL_TPUT_LIST}    1    0
#${BIP_CSV_NAME}            5GBipL2L1_filtering_off.csv
#${FILTER}                  dldata_pdcchsendreq
#@{COLUMN_NAME}             dci.dci01.TPCforScheduledPUSCH
#${PREFERENCE}              preferences
#
#*** Test Cases ***
#CB006137-ET-BC006_Single_UE__UL_CA__Call__with_PUSCH_uplink_closed_loop_power_control_with_Pcell_suspend_and_resume_on_ABIO
#    [Tags]    Owner_melwu
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF}    swconfig_param=${SWCONFIG_PARAM}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${wts_cfg}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${wts_cfg}
#    SA UE Attach    ${2CC_UE_ID}
#    Scell Addition With CoverbaseA1 Rsrp And ULDL TPUT Value    ${2CC_UE_ID}    ${RSRP}    ${RSRQ}    ${SCELL_PCI}
#    SA Start DL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_DL_DATA}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_UL_DATA}    trf_id=1
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_ID_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Start Gnb BIP Log
#    Modify Sinr To Trigger TPC Change
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Convert Multi BIP Logs To Csv By MCShark    ${TEST_LOG_DIRECTORY}    5GBipL2L1_filtering_off    ${FILTER}    ${COLUMN_NAME}
#    ...    ${CURDIR}/resources/${PREFERENCE}
#    Verify TPC Value Large
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#
#*** Keywords ***
#Modify Sinr To Trigger TPC Change
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-500
#    ute_wtssim.Execute Egate Command
#    ...    cmd=cell_testmode_set_nr gnb=1 cell_id=1 testmode=ul_cell_noise profile_id=1 action=activate
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-300
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate scell=0
#
#Verify TPC Value Large
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006137_BC005.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}
