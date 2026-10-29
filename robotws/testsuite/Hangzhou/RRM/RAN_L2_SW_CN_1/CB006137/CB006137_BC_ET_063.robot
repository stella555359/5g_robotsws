*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Set CP Debug Log
#...               AND    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    RAN_5G_TDD    RAN_5G    Owner_y7li    CN1_SQ6    CB006137
#...               SBTS00    SBTS23R1    CRT
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          resources/CB006137_BC_resource.robot
#
#*** Variables ***
#${RD_PARAM}                     0x58056B=1;0x580307=0x5FE;0x59004D=1    #CB006137
#${SCF_PATH}                     ${CURDIR}/config
#${DELTA_FILE}                   Delta_TDD_CB006137_BC_063_BOO.json
#${UE_ID}                        1
#${PROFILE_ID}
#${GNB_ID}                       2
#${CELL_ID}                      2
#${BEARER_ID}                    2
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${LOCAL_WTS_DIR}                ${CURDIR}/config
#${WTS_CFG}                      basic_setup_6137_BC_063.cfg
##${WTS_AP_XML}                   wts_ap_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_FS.xml
#${DL_TPUT_TARGET}               400
#${UL_TPUT_TARGET}               50
##${IPHY_FILE}                    ${CURDIR}/resources/wts/Conf_7752-B-SANSA-TDD-iphy.xml
##@{DL UDP Port}                  7070    7072    7074    7076    7078    7080    7082    7084
##@{UL UDP Port}                  7071    7073    7075    7077    7079    7081    7083    7085
#
#*** Test Cases ***
#CB006137-ET-BC063_Single_UE__UL_CA__Call_For_SA_With_UE_Capability_Support_2_UL_MIMO_Layer_On_FDD_Band_And_Work_On_ABIO
#    Multi UE Attach And Do UL DL Traffic     2    5    30    50
#    Trigger Scell Addition With CoverbaseA1 Rsrp Rsrq    2    1    75    60    50
#	Check Scell Addition Successful    2    52
#	sleep    2s
#	Trigger Scell Addition With CoverbaseA1 Rsrp Rsrq    3    1    75    60    50
#	Check Scell Addition Successful    3    52
#	sleep    2s
#	Trigger Scell Addition With CoverbaseA1 Rsrp Rsrq    4    1    75    60    50
#	Check Scell Addition Successful    4    52
#	sleep    2s
#	Trigger Scell Addition With CoverbaseA1 Rsrp Rsrq    5    1    75    60    50
#	Check Scell Addition Successful    5    52
#	sleep    2s
#	Check Mullti UE UL Avg Traffic    2    5
#
#*** Keywords ***
#Check SA UE Average UL Traffic
#    [Arguments]    ${ue_id}=1
#    ${output}    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id\=${ue_id} type=pusch scell=primary,secondary    pass_regexp=CellIndex
#    sleep    1s
#	Should Not Match Regexp    ${output}    CellIndex-1
#	Check Ul Tput On Target Pcell    ${ue_id}    0    1    1
#
#Check Mullti UE UL Avg Traffic
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    Check SA UE Average UL Traffic    ue_id=${UE_ID}
