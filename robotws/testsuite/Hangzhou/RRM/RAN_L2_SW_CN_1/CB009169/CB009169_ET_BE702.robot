*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_peafu    CN1_SQ6    SBTS00    SBTS23R3
#Library           taf.transport.ssh    WITH NAME    csn
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Config/
#${FULL_SCFC}        SCF_CB009169_ET_BE.xml
#${IPHY_XML}         ${CURDIR}/Resources/wts/iphy_CB009169_ET_BE.xml
#${LOCAL_WTS_DIR}    ${CURDIR}/Resources/wts
#${WTS_AP_XML}       airphone.xml
#${WTS_CFG}          CB009169_ET_Reset.cfg
#${EGATE_FILE}       /opt/iphy/latest/egate_console.log
#${CU_ADDR}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${CU_USERNAME}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#${CU_PASSWORD}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#
#*** Test Cases ***
#CB009169_ET_BE702_T_F_80Mhz_10Mhz_1UE_5G_L2_HI_Reset_ABIO_4times
#    SA Single UE Attach    1
#    Start DLUL Traffic
#    Check Tput
#    Trigger L2HI Auto Reset 3times
#    Trigger L2HI Auto Reset The 4th Time
#
#*** Keywords ***
#Start DLUL Traffic
#    SA Start DL Traffic Internal    ue_id=1    pdu_id=1    mbps=500
#    SA Start UL Traffic Internal    ue_id=1    pdu_id=1    mbps=100
#
#Check Tput
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    400
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    65
#
#Trigger L2HI Auto Reset 3times
#    FOR    ${index}    IN RANGE    1    4
#         Log To Console    ===============Reboot Time: ${index}==============
#         Trigger L2HI Auto Reset
#         Wait Until Keyword Succeeds    3min    5s    Check If Alarm Appeared    4383
#         Verify UE1 Detach
#         Wait Until Keyword Succeeds    3min    5s    Check If Alarm Disappeared    4383
#         Wait Until Keyword Succeeds    5min    10s    Verify All Cells Are OnAir
#         UE1 Attach To Cell 11
#    END
#
#Trigger L2HI Auto Reset The 4th Time
#    Log To Console    L2HI reset the 4th time...
#    Trigger L2HI Auto Reset
#    Verify UE1 Detach
#    Verify BTS Reset
#    Wait Until Keyword Succeeds    5min    30s    Verify All Cells Are OnAir
#    UE1 Attach To Cell 11
#
#Connect To ABIO
#    csn.Connect To    hostname=${CU_ADDR}    username=${CU_USERNAME}    password=${CU_PASSWORD}    alias=ABIO
#
#Trigger L2HI Auto Reset
#    Log To Console    L2HI reset...
#    Connect To ABIO
#    ${pidinfo}    csn.Execute    command=bsh 1:0 lxc-attach -n 0x2733 -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'
#    ...    connection=ABIO
#    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO
#
#Verify UE1 Detach
#    Log To Console    wait for UE1 detach...
#    Wait Until Keyword Succeeds    60s    5s    Check Egate Log With Message    ${EGATE_FILE}
#    ...    UE1: detached
#
#UE1 Attach To Cell 11
#    SA Single UE Attach    1
#
#Verify BTS Reset
#    Log To Console    wait for BTS reset...
#    Wait Until Keyword Succeeds    6min    1min    Check Egate Log With Message    ${EGATE_FILE}
#    ...    All NG links are down
