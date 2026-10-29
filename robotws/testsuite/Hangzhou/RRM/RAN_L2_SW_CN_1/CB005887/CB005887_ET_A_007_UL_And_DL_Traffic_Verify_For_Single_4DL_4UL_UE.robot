*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Import Testline Variables
#...               AND    Set AP RD Parameters Per gNB Release Build
#...               AND    Full Commission With SCF File          scf_file=${DELTA_FILE}
#...               AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Commissioned
#...               AND    Wait Until Keyword Succeeds    60sec    10sec    Check GNB EIF Ping OK
#...               AND    Suite Setup Update GNB    swconfig_param_AP=${RD_PARAM_AP}    iphy_file=${IPHY_FILE}    swconfig_param=${RD_PARAM}
#...               AND    Hard Reboot TL If Coam Site Not Ready
#...               AND    Change Testline From Fullstack To L1bypass
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Delete AP RD Parameters
#...               AND    Common Suite Teardown
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown
#Force Tags        STATE_CONFIGURED    CRT    7_5_UTE5GCLOUD5887_10.57.212.226    RAN_5G_TDD    RAN_5G    FR2    Owner_melwu
#...               master_classicalbts_all    RAN_5G_CRT     SBTS00
#Resource          ./CB005887_Resource.robot
#
#*** Variables ***
#${RD_PARAM}          0x20109=1;0x5800f4=4;0x580194=1  #1:MetricBased
#${SCF_PATH}          ${CURDIR}/resources/config
#${DELTA_FILE}        ${CURDIR}/resources/config/5GC005887_4D4U.xml
#${IPHY_FILE}         ${CURDIR}/resources/wts/iphy.xml
#${UE_ID}             16
#${PROFILE_ID}        1
#${GNB_ID}            2
#${FIRST_CELL_ID}     1
#${SECOND_CELL_ID}    2
#${BEARER_ID}         2
#@{LOG_NAME_LIST}     btslog    snapshot
#${COUNT}             0
#${LOCAL_WTS_DIR}     ${CURDIR}/resources/wts
#${WTS_CFG}           basic_local_AEUD.cfg
#${WTS_AP_XML}        Airphone.xml
#${DL_PEAK}           700
#${UL_PEAK}           300
#${CC_NUM}            4
#
#*** Test Cases ***
#CB005887_ET_A_007_UL_And_DL_Traffic_Verify_For_Single_4DL_4UL_UE
#    Config Endc Parameter
#    NSA LTE Attach    ${ue_id}    ${profile_id}
#    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${FIRST_CELL_ID}    ${bearer_id}
#    NSA Verify If Attach Passed
#    NSA Start Large Dl Traffic
#    Egate Console Confirm Scell Activated Success
#    Sleep    30s    reason=wait for dl traffic stable
#    Check NSA CA UE Secondary Cells UL Or DL Throughput    ${ue_id}    dl    ${DL_PEAK}    ${CC_NUM}
#    NSA Start Large Ul Traffic
#    Sleep    30s    reason=wait for ul traffic stable
#    Check NSA CA UE Secondary Cells UL Or DL Throughput    ${ue_id}    ul    ${UL_PEAK}    ${CC_NUM}
#
