*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup 8015    iphy_file=${IPHY_FILE}    swconfig_param=0x58056B=1;
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    SBTS22R4
#...               CN1_SQ6    CB006137
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}           ${CURDIR}/config
#${FULL_SCF}           6137_full_AB_BO_206_504_705_scfc.xml
#${DELTA_SCF_504}      Delta_6137_AB_BO_504.json
#${DELTA_SCF_705}      Delta_6137_AB_BO_705.json
#${IPHY_FILE}          ${CURDIR}/config/WTS/iphy_4F_2T.xml
#${WTS_LOCAL}          ${CURDIR}/config/WTS
#${WTS_CFG}            basic_6137.cfg
#${WTS_AP_XML}         airphone.xml
#${WTS_DIR}            /opt/wts/latest
#${UE_206_705}         8
#${PCELL_206_705}      53
#${SCELL_206_705}      55
#${DL_TRF}             650
#${UL_TRF}             300
#${DL_PEAK_206_705}    350
#${UL_PEAK_206_705}    120
#${UE_504}             9
#${PCELL_504}          54
#${SCELL_504}          52
#${RSRP}               100
#${DL_PEAK_504}        415
#${UL_PEAK_504}        65
#${RSRP_A2}            30
#
#*** Test Cases ***
#CB006137_ET_AB206_BO_Verify_Ul256Qam_With_Blind_Scell_Addition_And_Activation_With_BF_With_20M_N2_40M_N77
#    [Setup]    Test Setup 8015    scf_file=${FULL_SCF}
#    SA Attach    ${UE_206_705}
#    Check Scell Addition UL And DL    ${UE_206_705}    ${SCELL_206_705}
#    Start ULDL Traffic And Check The Tput    ${UE_206_705}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK_206_705}    ${UL_PEAK_206_705}
#    SA 5G Detach    ${UE_206_705}
#    [Teardown]    Test Teardown 8015
#
#CB006137_ET_AB504_BO_Verify_Single_UE_A1MR_Scell_Addition_And_BufferBased_Activation_By_DLUL_Data_With_BF
#    [Setup]    Test Setup 8015    scf_file=${FULL_SCF}    delta_scf=${DELTA_SCF_504}
#    Set Reordering Timer    500    300
#    SA Attach    ${UE_504}
#    Trigger A1 With RSRP And Check Scell Addition    ${UE_504}    ${PCELL_504}    ${SCELL_504}    ${RSRP}    1
#    Check Scell Actived And Deactived AB504
#    SA 5G Detach    ${UE_504}
#    [Teardown]    Test Teardown 8015
#
#CB006137_ET_AB705_BO_Verify_Single_UE_A1MR_Scell_Addition_And_BufferBbased_Activation_By_TCP_And_A2MR_Scell_Release_With_BF_20M_N2_40M_N77
#    [Setup]    Test Setup 8015    scf_file=${FULL_SCF}    delta_scf=${DELTA_SCF_705}
#    Set Reordering Timer    500    300
#    SA Attach    ${UE_206_705}
#    Trigger A1 With RSRP And Check Scell Addition    ${UE_206_705}    ${PCELL_206_705}    ${SCELL_206_705}    ${RSRP}    1
#    Trigger A2 Scell Release    ${UE_206_705}    1    ${RSRP_A2}    ${SCELL_206_705}
#    Trigger A1 With RSRP And Check Scell Addition    ${UE_206_705}    ${PCELL_206_705}    ${SCELL_206_705}    ${RSRP}    3
#    Check Scell Actived And Deactived AB705
#    SA 5G Detach    ${UE_206_705}
#    [Teardown]    Test Teardown 8015
#
#*** Keywords ***
#Check Scell Actived And Deactived AB504
#    Increase Traffic Step By Step To Active Scell    ${UE_504}    total_trf=50    step_trf=5    trf_type=ul
#    Start ULDL Traffic And Check The Tput    ${UE_504}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK_504}    ${UL_PEAK_504}
#    Stop SA Internal Traffic    ${UE_504}    dl
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    Stop SA Internal Traffic    ${UE_504}    ul
#    Sleep    5s    reason=wait scell status is stable
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    #Decrease Traffic Step By Step To Deactive Scell    ${UE_504}    20    100
#
#Check Scell Actived And Deactived AB705
#    Increase Traffic Step By Step To Active Scell    ${UE_206_705}    total_trf=50    step_trf=5    trf_type=ul
#    Start ULDL Traffic And Check The Tput    ${UE_206_705}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK_206_705}    ${UL_PEAK_206_705}
#    Stop SA Internal Traffic    ${UE_206_705}    ul
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    Stop SA Internal Traffic    ${UE_206_705}    dl
#    ${scell_status}    Check Scell Active Status    scell_active_status=deactived
#    #Decrease Traffic Step By Step To Deactive Scell    ${UE_206_705}    20    100
