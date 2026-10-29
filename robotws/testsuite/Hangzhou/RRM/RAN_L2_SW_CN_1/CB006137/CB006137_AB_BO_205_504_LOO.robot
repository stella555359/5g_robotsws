*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    SBTS00    SBTS23R1
#...               CN1_SQ6    CB006137
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/config
#${FULL_SCF}          6137_AB_BO_205_AP_LOO_SCF.xml
#${FULL_SCF_504}      CB006137_AB504_FULL_SCF.xml
#${WTS_LOCAL}         ${CURDIR}/config/WTS
#${WTS_CFG}           6137_205_504_AP_LOO.cfg
#${IPHY_FILE}         ${CURDIR}/config/WTS/6137_205_504_AP_LOO_iphy.xml
#${WTS_AP_XML}        airphone.xml
#${WTS_DIR}           /opt/wts/latest
#${UE_ID}             3
#${PCELL_ID}          51
#${SCELL_ID}          50
#${DL_TPUT}           600
#${UL_TPUT}           150
#${DL_PEAK}           519
#${UL_PEAK}           86
#${RSRP}              100
#
#*** Test Cases ***
#CB006137_ET_AB205_BO_Verify_Ul256Qam_With_Blind_Scell_Addition_And_Activation_With_BF_With_10M_N66_60M_N77
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID     ${UE_ID}    ${SCELL_ID}    1
#    Check Scell Active Status
#    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TPUT}    ${UL_TPUT}    ${DL_PEAK}    ${UL_PEAK}
#    SA 5G Detach    ${UE_ID}
#
#CB006137_ET_AB504_BO_Verify_Single_UE_A1MR_Scell_Addition_And_BufferBased_Activation_By_DLUL_Data_With_BF
#    [Setup]    Run Keywords    Full Commission With SCF File    scf_file=${FULL_SCF_504}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}
#    Trigger A1 With RSRP And Check Scell Addition    ${UE_ID}    ${PCELL_ID}    ${SCELL_ID}    ${RSRP}    1
#    Check Scell Actived And Deactived AB504
#    SA 5G Detach    ${UE_ID}
#
#*** Keywords ***
#Check Scell Actived And Deactived AB504
#    Increase Traffic Step By Step To Active Scell    ${UE_ID}    total_trf=50    step_trf=5    trf_type=ul
#    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TPUT}    ${UL_TPUT}    ${DL_PEAK}    ${UL_PEAK}
#    Stop SA Internal Traffic    ${UE_ID}    dl
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    Stop SA Internal Traffic    ${UE_ID}    ul
#    Sleep    5s    reason=wait scell status is stable
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    #Decrease Traffic Step By Step To Deactive Scell    ${UE_ID}    20    100
#
