*** Settings ***
Documentation    ...
#Suite Setup    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    ...        AND      Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND      Suite Setup Start WTS And Check OnAir
#Test Setup     Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Run Keywords    Detach All UEs
#    ...        AND     Stop Edaemon Egate
#    ...        AND     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_peafu    CN1_SQ6    SBTS00    SBTS23R3
#Library            taf.transport.ssh    WITH NAME    csn
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/Config/
#${FULL_SCFC}                 SCF_CB009169_ET_BE.xml
#${IPHY_XML}                  ${CURDIR}/Resources/wts/iphy_CB009169_ET_BC102_BC503.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/Resources/wts
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG}                   CB009169_ET_Reset.cfg
#${EGATE_FILE}                /opt/iphy/latest/egate_console.log
#${CU_ADDR}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${CU_USERNAME}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#${CU_PASSWORD}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#
#
#*** Test Cases ***
#CB009169_ET_BE801_T_F_80Mhz_10Mhz_1UE_5G_L2_LO_5G_L2_PS_Reset_ABIO
#    Two UE Attach
#    Start DLUL Traffic For 2UEs
#    Check Tput For 2UEs
#    Trigger L2RT auto reset
#    Wait Until Keyword Succeeds    3min    5s    Check If Alarm Appeared    4383
#    Verify UE1 Detach
#    Verify UE6 Is Normal
#    Wait Until Keyword Succeeds    3min    5s    Check If Alarm Disappeared    4383
#    Wait Until Keyword Succeeds    5min    10s    Verify All Cells Are OnAir
#    UE1 Attach To Cell 11
#
#
#
#*** Keywords ***
#Two UE Attach
#    SA Single UE Attach    1
#    SA Single UE Attach    6
#
#Start DLUL Traffic For 2UEs
#    SA Start DL Traffic Internal    ue_id=1    pdu_id=1    mbps=500
#    SA Start UL Traffic Internal    ue_id=1    pdu_id=1    mbps=10
#    SA Start DL Traffic Internal    ue_id=6    pdu_id=1    mbps=500
#    SA Start UL Traffic Internal    ue_id=6    pdu_id=1    mbps=10
#
#Check Tput For 2UEs
#    Wait Until Keyword Succeeds    1min    5s   Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    400
#    Wait Until Keyword Succeeds    1min    5s   Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    5
#    Wait Until Keyword Succeeds    1min    5s   Check CA UE Pcell Scell Cell TPut On Target    6    dl    pcell    0    400
#    Wait Until Keyword Succeeds    1min    5s   Check CA UE Pcell Scell Cell TPut On Target    6    ul    pcell    0    5
#
#Connect to ABIO
#    csn.connect_to    hostname=${CU_ADDR}    username=${CU_USERNAME}    password=${CU_PASSWORD}    alias=ABIO
#
#Trigger L2RT auto reset
#    Log To Console    L2RT reset...
#    Connect to ABIO
#    ${pidinfo}   csn.Execute    command=bsh 1:0 lxc-attach -n 0x2732 -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'
#    ...          connection=ABIO
#    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO
#
#Trigger L3SW auto reset
#    Log To Console    L3SW reset...
#    Connect to ABIO
#    ${pidinfo}   csn.Execute    command=bsh 1:0 lxc-attach -n 0x2735 -- kill -9 36
#    ...          connection=ABIO
#    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO
#
#Verify UE1 Detach
#    Log To Console    wait for UE1 detach...
#    Wait Until Keyword Succeeds    60s    5s    Check Egate Log With Message    ${EGATE_FILE}
#    ...    UE1: detached
#
#Verify UE6 Is Normal
#    Log To Console    check UE6 status...
#    Check CA UE Pcell Scell Cell TPut On Target    6    dl    pcell    0    400
#    Check CA UE Pcell Scell Cell TPut On Target    6    ul    pcell    0    8
#
#UE1 Attach To Cell 11
#    SA Single UE Attach    1
#
#Detach All UEs
#    SA 5G Detach    1
#    Run Keyword And Ignore Error    SA 5G Detach    6
#
#
#
