*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Run Keywords    Detach All UE
#...               AND    Common Test Teardown
##Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
##...               CN1_SQ6    CB008015    SBTS00    SBTS23R1    SBTS22R4    SBTS22R3
#Resource          ../5GC001167/5GC001167_Resource.robot
#Resource          resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}                ${CURDIR}/config
#${SCF_FILE}                Configuration_scf_CB008015_D_007.xml
#${IPHY_FILE}               ${CURDIR}/config/wts/iphy_3F_D_007.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/config/wts
#${WTS_CFG}                 basic_l1by_sa_call_fdd_cmwv_3F_D_007.cfg
#${LOCKED_CELL}             MRBTS-1/NRBTS-1/NRCELL-1
#${EXPECT_TPUT_DL_ALL}      200
#${EXPECT_TPUT_DL_CELL}     30
#${SCELL_NUMS}              2
#${UE_ID1}                  1    #pcell1+scell2+scell3
#${UE_ID2}                  2    #pcell2+scell1+scell3
#${CELL_LOCK_MESSAGE_SA}    Received NG Reset from GNB-2
#${CELL_ON_AIR_MESSAGE}     eNB 2 cell 1: SystemInformationBlockType1-NR
#
#*** Test Cases ***
#CB008015_D_007_SA_Lock_FDD_Cell_Configured_Blind_Scell_Addition_Method_Ungracefully
#    CB008015_lib.Set Reordering Timer    ${reordering_window_size}    ${reordering_timer}
#    Two SA UE Register
#    Verify Scells Are Activation    ${SCELL_NUMS}
#    Start Two UE DL And UL Traffic
#    Verify Two UE DL And UL Traffic
#    Lock Cell    ${LOCKED_CELL}
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_LOCK_MESSAGE_SA}    1
#    Unlock Cell    ${LOCKED_CELL}
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_ON_AIR_MESSAGE}    2
#    Log To Console    check ue reattach
#    Two SA UE Register
#    Verify Scells Are Activation    ${SCELL_NUMS}
#    Start Two UE DL And UL Traffic
#    Verify Two UE DL And UL Traffic
#
#*** Keywords ***
#Two SA UE Register
#    FOR    ${ue_id}    IN    ${UE_ID1}    ${UE_ID2}
#    \    SA Attach    ${ue_id}
#
#Start Two UE DL And UL Traffic
#    Log To Console    start DL and UL Traffic
#    FOR    ${trf_id}    IN RANGE    1    5
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID1} pdu\=${pdu_id} dir=dl mbps\=170 trf_id\=${trf_id}
#    FOR    ${trf_id}    IN RANGE    1    5
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID2} pdu\=${pdu_id} dir=dl mbps\=170 trf_id\=${trf_id}
#    FOR    ${ue_id}    IN    ${UE_ID1}    ${UE_ID2}
#    \    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    20s    reason=Wait For Data Transmission
#
#Verify Two UE DL And UL Traffic
#    FOR    ${ue_id}    IN    ${UE_ID1}    ${UE_ID2}
#    \    Log To Console    Verify ue${ue_id} Traffic
#    \    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${EXPECT_TPUT_DL_ALL}
#    \    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    \    SA Check 3CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${EXPECT_TPUT_DL_CELL}
#
#Detach All UE
#    SA 5G Detach    ${UE_ID1}
#    SA 5G Detach    ${UE_ID2}
#
