*** Settings ***
Documentation
...    author: gcao
...   Contact: ge.cao@nokia.com
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
#Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/CNI-134214-A
${MULTI_CPIF_FLAG}    True
${REDUNDANT_MODE_CU_FLAG}    True
@{FAULTS_EXCLUDED_CHECKING}    7308


@{PARAMS_IN_SCF_CU}
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    MRBTS-1/NRBTS-1:maxXnNgRanCfUpRetry=5


*** Test Cases ***
CNI-134214_04_GNB XNRANNodeConfigurationUpdate failure shall trigger XNSetup procedure to peer
    [Tags]    QC_284551    QCD_MN_RAN      QCP_RAN_VRF
    ${match_string_gnb3}     set variable      GNB-3: Message:xnap::XnSetupResponse
    ${match_string_gnb4}     set variable      GNB-4: Message:xnap::XnSetupResponse
    ${match_string_gnb5}     set variable      GNB-5: Message:xnap::XnSetupResponse
    Modify Cfg Aic
    #check cell onair
    Modify Cfg for Sending xn Setup On
    Set XNNGRANNodeConfiguration
    Lock Cell1
    Wait Until Keyword Succeeds    15 min    30s     Egate Console Log Should Contain    ${WTS_DIR}${/}egate_console.log    ${match_string_gnb3}
    Wait Until Keyword Succeeds    15 min    30s     Egate Console Log Should Contain    ${WTS_DIR}${/}egate_console.log    ${match_string_gnb4}
    Wait Until Keyword Succeeds    15 min    30s     Egate Console Log Should Contain    ${WTS_DIR}${/}egate_console.log    ${match_string_gnb5}
   [Teardown]    Postcondition

*** Keywords ***
Postcondition
    Unlock Cell1
    Modify Cfg for Sending xn Setup Off
    Common Test Teardown And Stop Capture Logs Aic

Set XNNGRANNodeConfiguration
    Execute Egate Command      gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command      gnb_xn_ngran_conf_update_param id=4 reset
    Execute Egate Command      gnb_xn_ngran_conf_update_param id=5 reset
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 action=send_error_indication cause=CauseProtocol_unspecified nth=1 ntimes=32
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=4 action=force_failure cause=CauseRadioNetworkLayer_unspecified nth=1 ntimes=32
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=5 action=drop nth=1 ntimes=32


Modify Cfg for Sending xn Setup On
    Execute Egate Command        gnb_param id=4 send_xn_setup=on
    Execute Egate Command        gnb_param id=5 send_xn_setup=on
    Execute Egate Command        xn_link_gnb_up gnb=4 target=2
    Execute Egate Command        xn_link_gnb_up gnb=5 target=2

Modify Cfg for Sending xn Setup Off
    Execute Egate Command    gnb_param id=4 send_xn_setup=off
    Execute Egate Command    gnb_param id=4 send_xn_setup=off

Modify Cfg Aic
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.20 gnb_id=0x3:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.20 nssai=0x1:0xd143a5 amf=1
    Update Cfg Aic    ${set_gnb3}
    #sim gnb4
    ${set_gnb4}    catenate    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.11.21 gnb_id=0x4:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.21 nssai=0x1:0xd143a5 amf=1
    Update Cfg Aic    ${set_gnb4}
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.11.22 gnb_id=0x5:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.22 nssai=0x1:0xd143a5 amf=1
    Update Cfg Aic    ${set_gnb5}
    Update Cfg Aic     gnb_param id=3 xn_listening_socket=on send_xn_setup=off
    Update Cfg Aic     gnb_param id=4 xn_listening_socket=on send_xn_setup=off
    Update Cfg Aic     gnb_param id=5 xn_listening_socket=on send_xn_setup=off
    ${set_gnb2_cell1}    catenate    set_cell id=3 gnb=2 pci=17:1 tac=280 nrci=0x03 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...       nr_arfcn=636666:636666 mandatory_for_activation=off gscn=7880
    ${set_gnb2_cell2}    catenate    set_cell id=4 gnb=2 pci=17:2 tac=280 nrci=0x04 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...       nr_arfcn=636666:636666 mandatory_for_activation=off gscn=7880
    Update Cfg Aic     ${set_gnb2_cell1}
    Update Cfg Aic     ${set_gnb2_cell2}
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...       nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=127:1 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999
    ...       nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=127:2 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999
    ...       nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg Aic     ${set_gnb3_cell1}
    Update Cfg Aic     ${set_gnb4_cell1}
    Update Cfg Aic     ${set_gnb5_cell1}


Trigger X2 links is up
    Execute Egate Command    enb_x2_link_up enb=1 target=2 x2_link_addr=10.0.1.10:36422    is up
    Execute Egate Command    enb_x2_link_up enb=11 target=2 x2_link_addr=10.0.1.11:36422    is up
    Execute Egate Command    enb_x2_link_up enb=12 target=2 x2_link_addr=10.0.1.12:36422    is up
    Execute Egate Command    enb_x2_link_up enb=13 target=2 x2_link_addr=10.0.1.13:36422    is up
    ${x2link}    create list    LTEENB-0:x2LinkStatus=available    LTEENB-1:x2LinkStatus=available    LTEENB-2:x2LinkStatus=available
    ...    LTEENB-3:x2LinkStatus=available
    object should exist in cu    ${x2link}

multi NSA UEs attach and do traffic
    FOR    ${ue_id}    IN RANGE    31    35
         nsa ue register    ue_id=${ue_id}
         Traffic Should Be OK    ue_id=${ue_id}    type=nsa
    END

nsa ue register
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA

Trigger ENB1 send X2link setup to CPIF again
    Execute Egate Command    enb_x2_link_up enb=1 target=2 x2_link_addr=10.0.1.10:36422 duplicate_x2_setup_error=on    ${ENB1_UE31}
    object should exist in cu    LTEENB-0:x2LinkStatus=available

Trigger ENB send X2link setup request to other CPIF
    [Arguments]    ${enb_id}=1    ${x2_link_addr}=10.0.1.1
    Execute Egate Command    enb_x2_link_up enb=${enb_id} target=2 x2_link_addr=${x2_link_addr}:36422 duplicate_x2_setup_error=on
    ...    pass_regexp=Duplicate X2 link will be dropped    fail_regexp=Bearer-type change from SCG-split to MCG is successful

X2link drop from ENB1
    Execute Egate Command    link_drop link=x2 by=enb:1 to=gnb:2 msg_type=abort    dropped
    object should exist in cu    LTEENB-0:x2LinkStatus=unavailable
    fm fault should be raised cu    ${fault_7308}

Trigger ENB1 send X2link setup request to CPIFA1
    Execute Egate Command    enb_x2_link_up enb=1 target=2 x2_link_addr=10.0.1.11:36422 duplicate_x2_setup_error=on    is up
    object should exist in cu    LTEENB-7:x2LinkStatus=available

Check all NGlink is Active
    FOR    ${amf_id}    IN RANGE    1    5
        object should exist in cu    SERVEDAMF-${amf_id}:ngLinkStatus=Active
    END

Delete AMF2 and then add AMF2
    delta commission parameters cu    delete:SERVEDAMF-2
    ${add_amf}    create list    SERVEDAMF-2:administrativeState=Unlocked    SERVEDAMF-2:amfIPAddress=10.0.11.2
    delta commission parameters cu    ${add_amf}
    object should exist in cu    SERVEDAMF-2:ngLinkStatus=Active

Set AMF3 ignore all NG Setup Request from gNB
    delta commission parameters cu    SERVEDAMF-3:administrativeState=Locked
    object should exist in cu    SERVEDAMF-3:ngLinkStatus=Inactive
    Execute Egate Command    amf_ng_setup_param id=3 gnb=2 request_ignore=on    sleep_time=2
    delta commission parameters cu    SERVEDAMF-3:administrativeState=Unlocked
    sleep    ${less_than_ngSetupRespTmr}
    object should exist in cu    SERVEDAMF-3:ngLinkStatus=Inactive

Delete AMF3 and Reset the configuration of AMF3
    delta commission parameters cu    delete:SERVEDAMF-3
    Execute Egate Command    amf_ng_setup_param id=3 reset    sleep_time=2

Add AMF3 and NGlink is Active
    ${add_amf}    create list    SERVEDAMF-3:administrativeState=Unlocked    SERVEDAMF-3:amfIPAddress=10.0.11.3
    delta commission parameters cu    ${add_amf}
    object should exist in cu    SERVEDAMF-3:ngLinkStatus=Active

Unlock NRADJGNB-1 and NRADJGNB-5
    ${params}    create list    NRADJGNB-1:administrativeState=Unlocked    NRADJGNB-5:administrativeState=Unlocked
    delta commission parameters cu    ${params}
    object should not exist in cu    XNLINK:xnLinkStatus=available

Delete All Xnlink and NRADJGNB
    ${params}    create list    delete:XNLINK-1    delete:XNLINK-2    delete:XNLINK-3    delete:XNLINK-4
    ...    delete:NRADJGNB-1    delete:NRADJGNB-3    delete:NRADJGNB-5
    delta commission parameters cu    ${params}
    object should not exist in cu    XNLINK-3:xnLinkStatus=conflicting
