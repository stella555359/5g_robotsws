*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    team-VRF3_8    owner-lola.ren    release-SBTS24R3
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB_CONFIG}    fddtdd_sansa_cmwv/2cell_gnb1_2F_gnb2_2F
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:xnLinkReestabTmr=900
...    @{SIM_NRADJGNB_NRADJNRCELL}
...    @{CB009939_gnb1_forced_active}
...    @{gnb1_CellActivationAlarmTimer}
@{PARAMS_IN_SCF_GNB2}
...    MRBTS-2/NRBTS-2:xnLinkReestabTmr=900
...    @{CB009939_gnb2_standby}
...    @{gnb2_CellActivationAlarmTimer}
@{CB009939_gnb1_forced_active}
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=forced active
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb1_active}
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=active
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb2_standby}
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=standby
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb1_standby}
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=standby
...    MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{CB009939_gnb2_active}
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyRole=active
...    MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1:redundancyGroupId=1
@{GNB1_Disabled_CB009939}
...    delete:MRBTS-1/MNL-1/MNLENT-1/REDUNDANCY-1
@{GNB2_Disabled_CB009939}
...    delete:MRBTS-2/MNL-1/MNLENT-1/REDUNDANCY-1

@{SIM_NRADJGNB_NRADJNRCELL}
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=4
...    NRBTS/NRADJGNB-3:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=4
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=41
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:gNbId=4
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:lcrId=41
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.141
...    NRBTS/XNLINK-2:cPlaneIpAddrCtrl=oamControlled
@{gnb1_CellActivationAlarmTimer}
...    MRBTS-1/NRBTS-1:nsaCellActivationAlarmTimer=10
...    MRBTS-1/NRBTS-1:saCellActivationAlarmTimer=10
@{gnb2_CellActivationAlarmTimer}
...    MRBTS-2/NRBTS-2:nsaCellActivationAlarmTimer=10
...    MRBTS-2/NRBTS-2:saCellActivationAlarmTimer=10
${Wait_For_NR_RAT_Reset}
...    30s

*** Test Cases ***
CB009939-A_ET_05_Pair of redundancy BTSs forced active startup and NG link lock unlock
    [Tags]    
    Verify GNB1 forced active and GNB2 standby after full commission
    Verify NG link lock and Unlock on standby gnb1
    Verify NG link lock and Unlock on standby gnb2
    Verify GNB2 standby to active and GNB1 active to standby
    [Teardown]    Common Test Teardown And Stop Capture Logs and disabled CB009939

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup 2Airphone Env    tl_type=${GNB_CONFIG}

Modify Cfg
    ${sim_gNB4}    catenate    set_gnb id=4 type=simulated plmn=311:489 xn=10.0.1.141 ng=10.0.1.140 gnb_id=0x04:22
    ...    daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none amf=1 nssai=0x1:0xd143a5 xp=10.0.1.141:32742 xpu=10.0.1.141:32742 xp_management=on
    Update Cfg    ${sim_gNB4}
    Update Cfg    gnb_param id=4 send_xn_setup=false sib1_period=40 xn_listening_socket=on
    ${simgNB4_cell11}    catenate    set_cell id=41 gnb=4 pci=20:0 tac=200 nrci=0x0B tdd_cell=off proxy=10.0.1.140:9999
    ...    nr_arfcn=349400:368400 gscn=4605 nr_scs=15kHz bs_channel_bandwidth=10MHz
    Update Cfg    ${simgNB4_cell11}
    
Common Test Teardown And Stop Capture Logs and disabled CB009939    
    Online commission gnb2 disabled and gnb1 disabled
    Wait Until Keyword Succeeds    5min    10s    Check gnb1 operational state and NG X2 XN links active from scf    enabled
    Wait Until Keyword Succeeds    5min    10s    Check gnb1 operational state and NG X2 XN links active from scf    enabled
    Common Test Teardown And Stop Capture Logs
  
Online commission gnb2 disabled and gnb1 disabled
    Log To Console    disable CB009939
    Delta Commission Parameters gnb2    ${GNB2_Disabled_CB009939}
    Delta Commission Parameters    ${GNB1_Disabled_CB009939}
    sleep    ${Wait_For_NR_RAT_Reset}

Online commission gnb2 standby and gnb1 active
    Log To Console    gnb2 standby
    Delta Commission Parameters gnb2    ${CB009939_gnb2_standby}
    Log To Console    gnb1 active
    Delta Commission Parameters    ${CB009939_gnb1_active}
    sleep    ${Wait_For_NR_RAT_Reset}

Online commission gnb1 standby and gnb2 active
    Log To Console    gnb1 standby
    Delta Commission Parameters    ${CB009939_gnb1_standby}
    Log To Console    gnb2 active
    Delta Commission Parameters gnb2    ${CB009939_gnb2_active}
    sleep    ${Wait_For_NR_RAT_Reset}
    
Check gnb1 operational state and NG X2 XN links active from scf
    [Arguments]    ${operationalState}=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-11:operationalState=${operationalState}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-12:operationalState=${operationalState}
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    Object Should Exist    MRBTS-1/NRBTS-1/LTEENB-0:x2LinkStatus=available
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Log To Console    gnb1 State OK

Check gnb2 operational state and NG X2 XN links active from scf
    [Arguments]    ${operationalState}=enabled
    Object Should Exist GNB2    MRBTS-2/NRBTS-2/NRCELL-13:operationalState=${operationalState}
    Object Should Exist GNB2    MRBTS-2/NRBTS-2/NRCELL-14:operationalState=${operationalState}
    Object Should Exist GNB2    MRBTS-2/NRBTS-2/SERVEDAMF-1:ngLinkStatus=Active
    Object Should Exist GNB2    MRBTS-2/NRBTS-2/LTEENB-0:x2LinkStatus=available
    Object Should Exist GNB2    MRBTS-2/NRBTS-2/XNLINK-1:xnLinkStatus=available
    Log To Console    gnb2 State OK

Verify GNB1 forced active and GNB2 standby after full commission
    Check gnb1 operational state and NG X2 XN links active from scf    enabled
    Check gnb2 operational state and NG X2 XN links active from scf    disabled
    
Verify NG link lock and Unlock on standby gnb1
    Online commission gnb1 standby and gnb2 active
    ${delta_parameters}    Create List    NRBTS-1/SERVEDAMF-1:administrativeState=Locked    NRBTS-1:actNgcFlexSaMode=true
    Delta Commission Parameters    ${delta_parameters}    
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
    ${delta_parameters}    Create List    NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked    NRBTS-1:actNgcFlexSaMode=true
    Delta Commission Parameters    ${delta_parameters}
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
    Wait Until Keyword Succeeds    3min    30s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active

Verify NG link lock and Unlock on standby gnb2
    Online commission gnb2 standby and gnb1 active
    ${delta_parameters}    Create List    NRBTS-2/SERVEDAMF-1:administrativeState=Locked    NRBTS-2:actNgcFlexSaMode=true
    Delta Commission Parameters gnb2    ${delta_parameters}    
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist gnb2     MRBTS-2/NRBTS-2/SERVEDAMF-1:administrativeState=Locked
    ${delta_parameters}    Create List    NRBTS-2/SERVEDAMF-1:administrativeState=Unlocked    NRBTS-2:actNgcFlexSaMode=true
    Delta Commission Parameters gnb2    ${delta_parameters}
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist gnb2    MRBTS-2/NRBTS-2/SERVEDAMF-1:administrativeState=Unlocked
    Wait Until Keyword Succeeds    3min    30s    Object Should Exist gnb2    MRBTS-2/NRBTS-2/SERVEDAMF-1:ngLinkStatus=Active
    
Verify GNB2 standby to active and GNB1 active to standby
    Start To Capture Wireshark Log     gnb1_active_to_standby
    Start To Capture Wireshark Log GNB2     gnb2_standby_to_active
    Online commission gnb1 standby and gnb2 active
    Wait Until Keyword Succeeds    5min    10s    Check gnb1 operational state and NG X2 XN links active from scf    disabled
    Wait Until Keyword Succeeds    5min    10s    Check gnb2 operational state and NG X2 XN links active from scf    enabled
    Check WireShark Log    ${CURDIR}${/}a2a_05${/}a2a_gnb1_active_to_standby.ini    name=gnb1_active_to_standby    
    ...    wait_string=NGRANNodeConfigurationUpdateAcknowledge::2
    Check WireShark Log GNB2    ${CURDIR}${/}a2a_05${/}a2a_gnb2_standby_to_active.ini    name=gnb2_standby_to_active
    ...    wait_string=NGRANNodeConfigurationUpdateAcknowledge::2