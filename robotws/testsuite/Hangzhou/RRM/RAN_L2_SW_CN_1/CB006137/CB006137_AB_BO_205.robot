*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x58056B=1;
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    SBTS00    SBTS23R1    SBTS22R4
#...               CN1_SQ6    CB006137
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/config
#${FULL_SCF}          6137_AB_BO_205.xml
#${DELTA_SCF_504}     Delta_6137_AB_BO_504.json
#${WTS_LOCAL}         ${CURDIR}/config/WTS
#${WTS_CFG}           basic_setup_ulca.cfg
#${IPHY_FILE}         ${CURDIR}/config/WTS/iphy_2cell_band66_77.xml
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
#    SA Attach    ${UE_ID}
#    Check Scell Addition UL And DL    ${UE_ID}    ${SCELL_ID}
#    Check Scell Active Status
#    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TPUT}    ${UL_TPUT}    ${DL_PEAK}    ${UL_PEAK}
#    SA 5G Detach    ${UE_ID}
#
#CB006137_ET_AB504_BO_Verify_Single_UE_A1MR_Scell_Addition_And_BufferBased_Activation_By_DLUL_Data_With_BF
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_504}
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
