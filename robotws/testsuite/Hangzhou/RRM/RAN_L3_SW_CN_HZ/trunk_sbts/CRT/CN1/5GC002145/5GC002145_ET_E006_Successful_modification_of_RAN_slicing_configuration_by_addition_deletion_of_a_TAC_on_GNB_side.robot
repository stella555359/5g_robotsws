*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19B
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:fiveGsTac=1
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:trackingAreaId=300
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300

*** Test Cases ***
5GC002145-ET-E006 Successful modification of RAN slicing configuration by addition_deletion of a TAC on GNB side
    [Documentation]
    ...    This user scenario describes the successful SA slice configuration udpate via new TAC and NG update procedure,
    ...    when slice is supported by the AMF.
    [Tags]    QC_83111
    Setup Xn Link To gNB3
    Lock And Unlock Cell
    Check Configuration Update
    
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_gnb}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=$SERVER_IP:$EDAEMON_PORT
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=2
    Update Cfg    ${set_gnb}
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633508:633508 gscn=7847
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false

Setup Xn Link To gNB3
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2.*is up
    Wait Until Keyword Succeeds    30s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available

Lock And Unlock Cell
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Locked
    Sleep    2s    # wait commission complete
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Locked
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Unlocked
    Sleep    2s    # wait commission complete and cell setup
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Unlocked

Check Configuration Update
    Check WireShark Log    ${CURDIR}${/}a2a_E006${/}a2a.ini    wait_string=NGRANNodeConfigurationUpdateAcknowledge::4    # GNBCUCfgnUpdateAck::4
