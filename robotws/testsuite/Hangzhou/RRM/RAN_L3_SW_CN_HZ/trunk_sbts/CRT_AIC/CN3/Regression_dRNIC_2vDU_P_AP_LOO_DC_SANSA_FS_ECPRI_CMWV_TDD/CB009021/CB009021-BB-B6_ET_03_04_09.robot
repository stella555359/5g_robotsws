*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_Aic    RAN_5G    CRT    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA    team-SG2    owner-wen.y.xu    release-SBTS24R2
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T
${MULTI_CPIF_FLAG}    True
${REDUNDANT_MODE_CU_FLAG}    True
@{FAULTS_EXCLUDED_CHECKING}    7308

@{PARAMS_IN_SCF_CU}    @{AMFs}    @{XnLink}    @{NRADJGNB}

@{PARAMS_IN_SCF_DU1}    @{DU_CELL1}

@{PARAMS_IN_SCF_DU2}    @{DU_CELL2}

@{AMFs}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngSetupRespTmr=300
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-1:amfIPAddress=10.0.11.1
...    SERVEDAMF-1:defaultAMF=true
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.11.2
...    SERVEDAMF-3:administrativeState=Unlocked
...    SERVEDAMF-3:amfIPAddress=10.0.11.3
...    SERVEDAMF-4:administrativeState=Unlocked
...    SERVEDAMF-4:amfIPAddress=10.0.11.4

@{XnLink}
...    XNLINK-1:cPlaneIpAddr=10.0.12.20
...    XNLINK-2:cPlaneIpAddr=10.0.12.21
...    XNLINK-3:cPlaneIpAddr=10.0.12.22
...    XNLINK-4:cPlaneIpAddr=10.0.12.23

@{NRADJGNB}
...    NRADJGNB-1:administrativeState=Locked
...    NRADJGNB-1:gNodeBId=7
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJGNB-3:administrativeState=Locked
...    NRADJGNB-3:gNodeBId=3
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:xnLinkRef=2
...    NRADJGNB-3:xnLinkRef2=3
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=489
...    NRADJGNB-3:gnbPlmn:mncLength=3
...    NRADJGNB-5:administrativeState=Locked
...    NRADJGNB-5:gNodeBId=5
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:xnLinkRef=4
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=489
...    NRADJGNB-5:gnbPlmn:mncLength=3

@{DU_CELL1}
...    NRDU-1:remotef1CplaneIpAddr=172.16.1.101

@{DU_CELL2}
...    NRDU-2:remotef1CplaneIpAddr=172.16.1.102

@{PM_Counters_03}
...    NRBTS-1:${ENDC_X2_SETUP_REQUEST_RECEIVED}=9
...    NRBTS-1:${ENDC_X2_SETUP_RESPONSE_SENT}=6

@{PM_Counters_09}
...    NRBTS-1:${XN_SETUP_REQUEST_SENT}=2
...    NRBTS-1:${XN_SETUP_RESPONSE_RECEIVED}=1
...    NRBTS-1:${XN_ERROR_INDICATION_SENT}=1

${ENDC_X2_SETUP_REQUEST_RECEIVED}    M55110C00003    #Number of incoming EN-DC X2 SETUP request received from LTE eNB
${ENDC_X2_SETUP_RESPONSE_SENT}    M55110C00004    #Number of successful EN-DC X2 SETUP procedure (number of EN-DC X2 SETUP response sent to LTE eNB)
${XN_SETUP_REQUEST_SENT}    M55126C00035    #Number of outgoing XN SETUP request sent to remote gNB
${XN_SETUP_RESPONSE_RECEIVED}    M55126C00005    #Number of successful XN SETUP procedure (nb. of XN SETUP response received from remote gNB)
${XN_ERROR_INDICATION_SENT}    M55126C00014    #Number of XN ERROR INDICATION sent to neighboring gNB

@{fault_7308}    fault_id=7308    fault_name=Transport layer connection failure in X2 interface

${less_than_ngSetupRespTmr}    10s
@{ENB1_UE31}
...    is up
...    UE31:.*Bearer-type change from SCG-split to MCG is successful

*** Test Cases ***
CB009021-CR-BB-B6_ET_03_Duplicated X2 link setup handling in multi-CPIF scenario
    [Documentation]
    ...    1. 10.0.1.10 - cpif
    ...       10.0.1.11 - cpifa1
    ...       10.0.1.12 - cpifa2
    ...       10.0.1.13 - cpifa3
    ...    2. Test Case Steps:
    ...         a. Trigger X2 links is up
    ...         b. multi NSA UEs attach and do traffic
    ...         c. Trigger ENB-1 send X2link setup request to CPIF again
    ...         d. Trigger ENB-11 send X2link setup request to CPIFA2
    ...         e. Trigger ENB-12 send X2link setup request to CPIFA3
    ...         f. Trigger ENB-13 send X2link setup request to CPIF
    ...         g. X2link drop from ENB1
    ...         h. Trigger ENB-1 send X2link setup request to CPIFA1
    ...    3. Expected Results:
    ...         a: X2link setup correctly between ENB-1/11/12/13
    ...         b: NSA UEs attach successful and traffic should be ok
    ...         c: NSA UE31 is released due to common bulk release, ENB-1 X2link is recreated
    ...         d~f: X2link setup request is rejected, NSA UE32/33/34 is not impacted
    ...         g: X2link release
    ...         h: X2link setup request is accepted
    [Tags]
    Clear Counter Files Cu Aic    wait=False
    Trigger X2 links is up
    multi NSA UEs attach and do traffic
    Trigger ENB1 send X2link setup to CPIF again    #cpif
    Trigger ENB send X2link setup request to other CPIF    enb_id=11    x2_link_addr=10.0.1.12    #cpifa2
    Trigger ENB send X2link setup request to other CPIF    enb_id=12    x2_link_addr=10.0.1.13    #cpifa3
    Trigger ENB send X2link setup request to other CPIF    enb_id=13    x2_link_addr=10.0.1.10    #cpif
    X2link drop from ENB1
    Trigger ENB1 send X2link setup request to CPIFA1    #cpifa1
    check counters cu aic    ${PM_Counters_03}

CB009021-CR-BB-B6_ET_04_AMF MoC Create and Removal on-line
    [Documentation]
    ...    1. Test Case Steps:
    ...         a. Delete AMF-2 and then add AMF-2
    ...         b. Lock AMF-3
    ...         c. Set AMF-3 ignore all NG Setup Request from gNB
    ...         d. Unlock AMF-3
    ...         e. Delete AMF-3 and reset the configuration of AMF3
    ...         f. add AMF-3
    ...    2. Expected Results:
    ...         a: add AMF-1 back, NGLink is Active
    ...         b: AMF-3 NGlink is Inactive
    ...         c: Set AMF3 ignore all NG Setup Request
    ...         d: AMF3 NGlink is still Inactive
    ...         e: delete AMF-3 and reset the configuration of AMF3
    ...         f: add AMF-3 back, NG Link is Active
    [Tags]
    Check all NGlink is Active
    Delete AMF2 and then add AMF2
    Set AMF3 ignore all NG Setup Request from gNB
    Delete AMF3 and Reset the configuration of AMF3
    Add AMF3 and NGlink is Active

CB009021-CR-BB-B6_ET_09_XN Response shall be rejected if the associated NRADJGNB is Locked
    [Documentation]
    ...    1. Test Case Steps:
    ...         a. Unlock NRADJGNB-5 and then Unlock NRADJGNB-1
    ...         b. Lock NRADJGNB-1 and unlock NRADJGNB-3
    ...    2. Expected Results:
    ...         a: Xn Link Setup Request send to GNB-7. CPIFA1 receive the XN setup Response from GNB-3 and find associated NRADGJNB-3,
    ...            as the administrator state is Locked, XN setup failed.
    ...         b: CPIFA2 receive XNSetupResp from GNB-3 and find associated NRADJGNB-5. XN setup correctly, update NRADJGNB-5.
    ...            - XnLinkRef=2
    ...            And Conflict find in NRADJGNB-3, update XNLINK-3 and XNLINK-4 to conflicting.
    [Tags]
    Clear Counter Files Cu Aic    wait=False
    Unlock NRADJGNB-1 and NRADJGNB-5
    Lock NRADJGNB-1 and Unlock NRADJGNB-3
    check counters cu aic    ${PM_Counters_09}
    Delete All Xnlink and NRADJGNB

*** Keywords ***
Modify Cfg Aic
    #amfs
    Update Cfg Aic    set_amf_region id=1 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf_region id=2 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf_region id=3 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf_region id=4 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.11.1:38412 region=1 set_id=1 pointer=1 type=simulated
    Update Cfg Aic    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.11.2:38412 region=2 set_id=1 pointer=2 type=simulated
    Update Cfg Aic    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.11.3:38412 region=3 set_id=1 pointer=3 type=simulated
    Update Cfg Aic    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.11.4:38412 region=4 set_id=1 pointer=4 type=simulated
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-4 default=on ue=all

    #real gnb2
    ${multiple_cpif}    catenate    set_gnb id=2 xn=10.0.12.10,10.0.12.11,10.0.12.12,10.0.12.13
    ...    ng=10.0.11.10,10.0.11.11,10.0.11.12,10.0.11.13 amf=1-4
    ...    x2=10.0.1.10:36422,10.0.1.11:36422,10.0.1.12:36422,10.0.1.13:36422
    update cfg param aic    ${multiple_cpif}
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.20 gnb_id=0x3:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.20 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3}
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=off
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.11.21 gnb_id=0x5:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.21 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=127:2 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb5}
    Update Cfg Aic    ${set_gnb5_cell1}
    Update Cfg Aic    gnb_param id=5 xn_listening_socket=on send_xn_setup=off

    #LTEENB
    ${set_enb1}    catenate    set_enb id=1 plmn=311:489 s1=10.0.1.136 enb_id_macro=0x12345 daemon=10.0.2.1:22222 x2=10.0.1.1 x2u=10.0.1.135
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb1}
    Update Cfg Aic    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    ${set_enb1_cell}    catenate    set_cell id=1 enb=1 eci=0x1234501 pci=3:2 tac=222 proxy=10.0.2.1:12215|10.0.2.1:8889 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb1_cell}
    Update Cfg Aic    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_enb11}    catenate    set_enb id=11 plmn=311:489 s1=10.0.1.137 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.149 x2u=10.0.1.144
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb11}
    Update Cfg Aic    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    ${set_enb11_cell}    catenate    set_cell id=1 enb=11 eci=0x1234601 pci=3:1 tac=222 proxy=10.0.2.1:12216|10.0.2.1:8888 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb11_cell}
    Update Cfg Aic    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_enb12}    catenate    set_enb id=12 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.150 x2u=10.0.1.145
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb12}
    Update Cfg Aic    enb_param id=12 drb_id_begin=3 endc_capable_qci=all
    ${set_enb12_cell}    catenate    set_cell id=1 enb=12 eci=0x1234701 pci=3:0 tac=222 proxy=10.0.2.1:12217|10.0.2.1:8887 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb12_cell}
    Update Cfg Aic    enb_endc_param id=12 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_enb13}    catenate    set_enb id=13 plmn=311:489 s1=10.0.1.139 enb_id_macro=0x12348 daemon=10.0.2.1:22222 x2=10.0.1.151 x2u=10.0.1.146
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb13}
    Update Cfg Aic    enb_param id=13 drb_id_begin=3 endc_capable_qci=all
    ${set_enb13_cell}    catenate    set_cell id=1 enb=13 eci=0x1234801 pci=4:0 tac=222 proxy=10.0.2.1:12218|10.0.2.1:8886 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb13_cell}
    Update Cfg Aic    enb_endc_param id=13 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    update cfg param aic    set_ue simulated id=31 enb=1
    update cfg param aic    set_ue simulated id=32 enb=11
    update cfg param aic    set_ue simulated id=33 enb=12
    update cfg param aic    set_ue simulated id=34 enb=13

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

Lock NRADJGNB-1 and Unlock NRADJGNB-3
    ${params}    create list    NRADJGNB-1:administrativeState=Locked    NRADJGNB-3:administrativeState=Unlocked
    delta commission parameters cu    ${params}
    ${xnlink}    create list    XNLINK-2:xnLinkStatus=available    NRADJGNB-5:xnLinkRef=2
    object should exist in cu    ${xnlink}
    # below changed by CNI-140449, conflict xnlink will be auto removed.
    Object Should Not Exist in CU    XNLINK-3:xnLinkStatus=conflicting
    Object Should Not Exist in CU    XNLINK-3:xnLinkStatus=available
    Object Should Not Exist in CU    XNLINK-4:xnLinkStatus=conflicting
    Object Should Not Exist in CU    XNLINK-4:xnLinkStatus=available

Delete All Xnlink and NRADJGNB
    ${params}    create list    delete:XNLINK-1    delete:XNLINK-2    delete:XNLINK-3    delete:XNLINK-4
    ...    delete:NRADJGNB-1    delete:NRADJGNB-3    delete:NRADJGNB-5
    delta commission parameters cu    ${params}
    object should not exist in cu    XNLINK-3:xnLinkStatus=conflicting
