*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_026}    swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
#...               SBTS00    CN1_SQ6    CB009169    Owner_melwu
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
##CB009169_ET_BD026
#${SCF_026}                     CB009169_BD026_scfc.xml
#${WTS_CFG}                     basic_setup_9169_ABIL.cfg
#${WTS_LOCAL}                   ${CURDIR}/Resources/wts
#${SCF_PATH}                    ${CURDIR}/Config
#${WTS_DIR}                     /opt/wts/latest
#${SWCONFIG_PARAM}              0x580692=1
#@{SCELL_PHYSICALID_LIST}       60
#${2CC_UE_ID}                   1
#@{2CC_UE_ID_LIST}              1
#${2CC_DL_DATA}                 900
#${2CC_UL_DATA}                 200
#@{2CC_EXP_DL_TPUT_LIST_026}    650    140
#@{2CC_EXP_UL_TPUT_LIST_026}    65    40
#
#*** Test Cases ***
#CB009169_ET_BD026_UL_CA_Call_With_4Rx_MRC_For_TDD_FR1_Cell_On_ABIL
#    SA 5G CA Attach    ${2CC_UE_ID}
#    Check SA All Scell PhysicalID With UE ID    ${2CC_UE_ID}    ${SCELL_PHYSICALID_LIST}    2
#    SA Start DL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_DL_DATA}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_UL_DATA}    trf_id=1
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2cc_ue_id_list}    ${2cc_exp_ul_tput_list_026}    ${2cc_exp_dl_tput_list_026}    2
#    Save Egate Log    ${test_log_directory}
#    Verify PUCCH Group And PUSCH Configured
#
#*** Keywords ***
#Verify PUCCH Group And PUSCH Configured
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD026_4Rx_MRC.ini    p
#    ...    save_log_directory=${test_log_directory}
