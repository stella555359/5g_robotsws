*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF}    iphy_file=${IPHYFILE}    swconfig_param=0x58056B=1;
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    SBTS00    SBTS23R1
#...               CN1_SQ6    CB006137
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}           ${CURDIR}/config
#${FULL_SCF}           6137_AB_BO_206_705_SCF.xml
#${DELTA_SCF_705}      Delta_6137_AB_BO_705.json
#${IPHY_FILE}          ${CURDIR}/config/WTS/6137_206_705.xml
#${WTS_LOCAL}          ${CURDIR}/config/WTS
#${WTS_CFG}            6137_206_705.cfg
#${WTS_AP_XML}         airphone.xml
#${WTS_DIR}            /opt/wts/latest
#${UE_206_705}         3
#${PCELL_206_705}      51
#${SCELL_206_705}      50
#${DL_TRF}             650
#${UL_TRF}             300
#${DL_PEAK_206_705}    350
#${UL_PEAK_206_705}    120
#${RSRP}               100
#${RSRP_A2}            30
#
#
#
#*** Test Cases ***
#CB006137_ET_AB206_BO_Verify_Ul256Qam_With_Blind_Scell_Addition_And_Activation_With_BF_With_20M_N2_40M_N77
#    SA 5G CA Attach    ${UE_206_705}
#    Check Scell Addition UL And DL    ${UE_206_705}    ${SCELL_206_705}
#    Start ULDL Traffic And Check The Tput    ${UE_206_705}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK_206_705}    ${UL_PEAK_206_705}
#    SA 5G Detach    ${UE_206_705}
#
#CB006137_ET_AB705_BO_Verify_Single_UE_A1MR_Scell_Addition_And_BufferBbased_Activation_By_TCP_And_A2MR_Scell_Release_With_BF_20M_N2_40M_N77
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_705}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    SA 5G CA Attach    ${UE_206_705}
#    Trigger A1 With RSRP And Check Scell Addition    ${UE_206_705}    ${PCELL_206_705}    ${SCELL_206_705}    ${RSRP}    1
#    Trigger A2 Scell Release    ${UE_206_705}    1    ${RSRP_A2}    ${SCELL_206_705}
#    Trigger A1 With RSRP And Check Scell Addition    ${UE_206_705}    ${PCELL_206_705}    ${SCELL_206_705}    ${RSRP}    3
#    Check Scell Actived And Deactived AB705
#    SA 5G Detach    ${UE_206_705}
#
#*** Keywords ***
#Check Scell Actived And Deactived AB705
#    Increase Traffic Step By Step To Active Scell    ${UE_206_705}    total_trf=50    step_trf=5    trf_type=ul
#    Start ULDL Traffic And Check The Tput    ${UE_206_705}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK_206_705}    ${UL_PEAK_206_705}
#    Stop SA Internal Traffic    ${UE_206_705}    ul
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    Stop SA Internal Traffic    ${UE_206_705}    dl
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    #Decrease Traffic Step By Step To Deactive Scell    ${UE_206_705}    20    100
