*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    CN1_SQ6
#...               CB009169
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config
#${FULL_SCF}                 9169_BC_703_SCF.xml
#${IPHY_FILE}                ${CURDIR}/Resources/wts/9169_2T_3F_iphy.xml
#${WTS_LOCAL}                ${CURDIR}/Resources/wts
#${WTS_CFG}                  CB009169_BC_703.cfg
#${WTS_AP_XML}               airphone.xml
#${WTS_DIR}                  /opt/wts/latest
#${DL_TRF}                   1200
#${UL_TRF}                   150
#${UE}                       1
#${PCELL}                    60
#${SCELL}                    52
#${RSRP}                     120
#${PCELL_DL_PEAK}            470
#${PCELL_UL_PEAK}            59
#${SCELL_1_DL_PEAK}          39
#${SCELL_2_DL_PEAK}          183
#${SCELL_2_UL_PEAK}          57
#${SCELL_3_DL_PEAK}          380
#
#*** Test Cases ***
#CB009169_ET_BC703_2TDD_2FDD_DL4CC_UL2CC_A1_ScellAdd_BufferBaseScellAct_Uplink_Bad_RLQ
#    SA 5G CA Attach    ${UE}
#    Trigger A1 Scell Addition    ${UE}    ${RSRP}    ${PCELL}
#	  Start SA UE Big UL Traffic Internal    ${UE}    ${UL_TRF}
#	  Check SA Scell PhysicalID With UE ID     ${UE}    ${SCELL}    2
#    Check All Cell UL Tput    ${PCELL_UL_PEAK}    ${SCELL_2_UL_PEAK}
#    Start SA UE Big DL Traffic Internal    ${UE}    ${DL_TRF}
#    Sleep    5s      reason=waitting for cell active
#	  Verify Scells Are Activation    4
#    Check All Cell ULDL Tput
#	  Check Scell Suspend When Bad UL RLQ
#    SA 5G Detach    ${UE}
#
#
#
#*** Keywords ***
#Check Scell Suspend When Bad UL RLQ
#    Delete RD BTS Counter xml
#    Set PHR Testmode    phr_start=10    phr_min=0    phr_max=23    phr_step_size=5    phr_period=10    pc_max=23
#    CUDU_L2 Send Action To GNB    ${UE}    testmode=phr_override    action=activate    profile_id=1    scell=2
#    Sleep      2s      reason=waitting for cell throughput is stable
#    Set BLER Testmode     profile_id=30     ul_bler=200,200,200,200,200,200,200,200
#    CUDU_L2 Send Action To GNB    ${UE}    testmode=bler    action=activate    profile_id=30    scell=2
#	  Wait Until Keyword Succeeds    1min    6s    Verify Scell UL Tput Is Zero
#    Check All Cell DL Tput    ${PCELL_DL_PEAK}    ${SCELL_1_DL_PEAK}    ${SCELL_2_DL_PEAK}    ${SCELL_3_DL_PEAK}
#  	CUDU_L2 Send Action To GNB    ${UE}    testmode=bler    action=deactivate    profile_id=30    scell=2
#    Sleep      1s      reason=waitting for cell throughput is stable
#    Set PHR Testmode    phr_start=30    phr_min=0    phr_max=30    phr_step_size=5    phr_period=10    pc_max=23
#    CUDU_L2 Send Action To GNB    ${UE}    testmode=phr_override    action=activate    profile_id=1    scell=2
#	  Check All Cell ULDL Tput
#    Sleep    5m    reason=waitting for RD counter file creation
#  	Save RD BTS Counter xml And Gunzip    log_dir=${TEST_LOG_DIRECTORY}
#  	Check RD Counter Max Value From RD BTS xml    SCELL_UL_SUSPEND_RLQ    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3    NCADU    max_value=1
#    Check RD Counter Max Value From RD BTS xml    SCELL_UL_RECOV_RLQ    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3    NCADU    max_value=1
#
#Check All Cell ULDL Tput
#    Check All Cell UL Tput    ${PCELL_UL_PEAK}    ${SCELL_2_UL_PEAK}
#	  Check All Cell DL Tput    ${PCELL_DL_PEAK}    ${SCELL_1_DL_PEAK}    ${SCELL_2_DL_PEAK}    ${SCELL_3_DL_PEAK}
#
#
#Check All Cell UL Tput
#    [Arguments]    ${pcell_ul_tput}=0    ${scell_ul_tput}=0
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    ul    pcell    0    ${pcell_ul_tput}
#	  Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    ul    scell    2    ${scell_ul_tput}
#
#Check All Cell DL Tput
#    [Arguments]    ${pcell_dl_tput}=0    ${scell_1_dl_tput}=0    ${scell_2_dl_tput}=0    ${scell_3_dl_tput}=0
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    dl    pcell    0    ${pcell_dl_tput}
#	  Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    dl    scell    1    ${scell_1_dl_tput}
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    dl    scell    2    ${scell_2_dl_tput}
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    dl    scell    3    ${scell_3_dl_tput}
#
#
#Verify Scell UL Tput Is Zero
#    log to console    Verify scell ul tput is 0
#    ${ul_tput}     Get CA Cell Average Throughput    ${UE}    ul    scell    2
#    Should Be True    ${ul_tput}==${0}
