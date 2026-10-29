*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 4DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_Aic    RAN_5G    CRT    team-CN3ET    owner-carol.an    release-SBTS24R2
...    CLOUD_5GC_dRNIC_4vDU_P_AP_LO_SWFH    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/4du/2cells
${SOS_REPORT_FLAG}    pass:False,fail:False
${MULTI_CPIF_FLAG}    True
${REDUNDANT_MODE_CU_FLAG}    True
@{FAULTS_EXCLUDED_CHECKING}    7300    7107
@{PARAMS_IN_SCF_CU}    @{xn_parameterscu}    @{AMFs}
@{PARAMS_IN_SCF_DU1}    @{DU_CELL1}
@{PARAMS_IN_SCF_DU2}    @{DU_CELL2}
@{PARAMS_IN_SCF_DU3}    @{DU_CELL3}
@{PARAMS_IN_SCF_DU4}    @{DU_CELL4}
@{FAULTS_EXCLUDED_CHECKING}    4405

@{xn_parameterscu}
...    NRBTS/NRPMRNL:miNrXnInterface=5min
...    NRBTS:actIncXn=true

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

@{DU_CELL1}
...    NRDU-1:remotef1CplaneIpAddr=172.16.1.101
...    MRBTS-1/NRBTS-1/NRCELL-1:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{DU_CELL2}
...    NRDU-2:remotef1CplaneIpAddr=172.16.1.102
...    MRBTS-1/NRBTS-1/NRCELL-2:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{DU_CELL3}
...    NRDU-3:remotef1CplaneIpAddr=172.16.1.103
...    MRBTS-1/NRBTS-1/NRCELL-3:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{DU_CELL4}
...    NRDU-4:remotef1CplaneIpAddr=172.16.1.104
...    MRBTS-1/NRBTS-1/NRCELL-4:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{parameterscu_C02}
...    NRBTS:maxNumX2Links=4
...    NRBTS:actEnhancedX2LinkSupervision=true
...    NRBTS:x2LinkSupervisionTmr=1
...    NRBTS:x2LinkReestabTmr=1

@{teardown_C02}
...    NRBTS:maxNumX2Links=128
...    NRBTS:actEnhancedX2LinkSupervision=true
...    NRBTS:x2LinkSupervisionTmr=1
...    NRBTS:x2LinkReestabTmr=15

@{parameterscu_C19addMOC}
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:gNodeBId=5
...    NRADJGNB-3:xnLinkRef=3
...    NRADJGNB-3:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-3:gnbPlmn:mnc=489|mncLength=3
...    XNLINK-3:cPlaneIpAddr=10.0.12.22
...    XNLINK-3:cPlaneIpAddrCtrl=oamControlled
...    NRADJGNB-4:administrativeState=Unlocked
...    NRADJGNB-4:gNbIdLength=22
...    NRADJGNB-4:gNodeBId=6
...    NRADJGNB-4:xnLinkRef=4
...    NRADJGNB-4:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-4:gnbPlmn:mnc=489|mncLength=3
...    XNLINK-4:cPlaneIpAddr=10.0.12.23
...    XNLINK-4:cPlaneIpAddrCtrl=oamControlled

@{teardown_C19}
...    delete:MRBTS-1/NRBTS-1/XNLINK-1
...    delete:MRBTS-1/NRBTS-1/XNLINK-2
...    delete:MRBTS-1/NRBTS-1/XNLINK-3
...    delete:MRBTS-1/NRBTS-1/XNLINK-4
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Locked
...    MRBTS-1/NRBTS-1/NRADJGNB-2:administrativeState=Locked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Locked
...    MRBTS-1/NRBTS-1/NRADJGNB-4:administrativeState=Locked
...    delete:MRBTS-1/NRBTS-1/NRADJGNB-1
...    delete:MRBTS-1/NRBTS-1/NRADJGNB-2
...    delete:MRBTS-1/NRBTS-1/NRADJGNB-3
...    delete:MRBTS-1/NRBTS-1/NRADJGNB-4

${XN_SETUP_REQUEST_RECEIVED}    M55126C00003
${XN_SETUP_RESPONSE_RECEIVED}    M55126C00005
${XN_SETUP_REQUEST_SENT}    M55126C00035

@{C_19_Counter}
...    NRBTS-1:${XN_SETUP_REQUEST_RECEIVED}=1     #Number of incoming XN setup request

@{C_19_Counter2}
...    NRBTS-1:${XN_SETUP_REQUEST_RECEIVED}=2     #Number of incoming XN setup request
...    NRBTS-1:${XN_SETUP_RESPONSE_RECEIVED}=2     #Number of successful XN setup procedure
...    NRBTS-1:${XN_SETUP_REQUEST_SENT}=2     #Number of outgoing XN SETUP request sent to remote gNB

${x2LinkSupervisionTmr}    60s

*** Test Cases ***
CB009021-CR-C_ET_02_Fault 7324 shall be raised when the X2 connection reach the maxNumX2Links
    [Tags]
    Parameters set and x2 setup
    Trigger 7324 Faultid Cu
    Trigger Cleared 7324 Faultid Cu
    [Teardown]    caseC02_teardown

CB009021-CR-C_ET_19_M55126C00003_and_M55126C00005_and_M55126C00035 shall be handled correclty in multi-cpif scenario
    [Tags]
    Clear Counter files Cu Aic
    Trigger XN setup request from GNBSim1 to CPIF
    Check Counters Cu Aic    ${C_19_Counter}
    Trigger XN setup request from GNBSim2 to CPIFA1
    Online add XNLink MOC to GnbSim3 and GNBSim4
    Check Counters Cu Aic    ${C_19_Counter2}
    [Teardown]    caseC19_teardown

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_amf_region id=1 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf_region id=2 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf_region id=3 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf_region id=4 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.11.1:38412 region=1 set_id=1 pointer=1 type=simulated
    Update Cfg Aic    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.11.2:38412 region=2 set_id=1 pointer=2 type=simulated
    Update Cfg Aic    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.11.3:38412 region=3 set_id=1 pointer=3 type=simulated
    Update Cfg Aic    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.11.4:38412 region=4 set_id=1 pointer=4 type=simulated
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-4 default=on ue=all
    ${multiple_cpif}    catenate    set_gnb id=2 xn=10.0.12.10,10.0.12.11,10.0.12.12,10.0.12.13
    ...    ng=10.0.11.10,10.0.11.11,10.0.11.12,10.0.11.13 amf=1-4
    ...    x2=10.0.1.10:36422,10.0.1.11:36422,10.0.1.12:36422,10.0.1.13:36422
    update cfg param aic    ${multiple_cpif}

    ${set_enb1}    catenate    set_enb id=1 plmn=311:489 s1=10.0.1.136 enb_id_macro=0x12345 daemon=10.0.2.1:22222 x2=10.0.1.137 x2u=10.0.1.135
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb1}
    Update Cfg Aic    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    ${set_enb1_cell}    catenate    set_cell id=1 enb=1 eci=0x1234501 pci=3:2 tac=222 proxy=10.0.2.1:12215|10.0.2.1:8889 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb1_cell}
    Update Cfg Aic    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_enb100}    catenate    set_enb id=100 plmn=311:489 s1=10.0.1.137 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.149 x2u=10.0.1.144
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb100}
    Update Cfg Aic    enb_param id=100 drb_id_begin=3 endc_capable_qci=all
    ${set_enb100_cell}    catenate    set_cell id=1 enb=100 eci=0x1234601 pci=3:0 tac=222 proxy=10.0.2.1:12216|10.0.2.1:8888 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb100_cell}
    Update Cfg Aic    enb_endc_param id=100 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_enb101}    catenate    set_enb id=101 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.150 x2u=10.0.1.145
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb101}
    Update Cfg Aic    enb_param id=101 drb_id_begin=3 endc_capable_qci=all
    ${set_enb101_cell}    catenate    set_cell id=1 enb=101 eci=0x1234701 pci=3:1 tac=222 proxy=10.0.2.1:12217|10.0.2.1:8887 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb101_cell}
    Update Cfg Aic    enb_endc_param id=101 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_enb102}    catenate    set_enb id=102 plmn=311:489 s1=10.0.1.139 enb_id_macro=0x12348 daemon=10.0.2.1:22222 x2=10.0.1.151 x2u=10.0.1.146
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb102}
    Update Cfg Aic    enb_param id=102 drb_id_begin=3 endc_capable_qci=all
    ${set_enb102_cell}    catenate    set_cell id=1 enb=102 eci=0x1234801 pci=4:0 tac=222 proxy=10.0.2.1:12218|10.0.2.1:8886 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb102_cell}
    Update Cfg Aic    enb_endc_param id=102 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_enb103}    catenate    set_enb id=103 plmn=311:489 s1=10.0.1.152 enb_id_macro=0x00036 daemon=10.0.2.1:22222 x2=10.0.1.152 x2u=10.0.1.152
    ...    type=simulated x2_peers=none
    Update Cfg Aic    ${set_enb103}
    Update Cfg Aic    enb_param id=103 drb_id_begin=3 endc_capable_qci=all
    ${set_enb103_cell}    catenate    set_cell id=1 enb=103 eci=0x0003601 pci=4:1 tac=222 proxy=10.0.2.1:12219|10.0.2.1:8885 earfcn=2000:20000
    ...    mapped_earfcn=4200:22200
    Update Cfg Aic    ${set_enb103_cell}
    Update Cfg Aic    enb_endc_param id=103 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.20 gnb_id=0x3:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.20 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3}
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=off

    ${set_gnb4}    catenate    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.11.21 gnb_id=0x4:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.21 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=127:1 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb4}
    Update Cfg Aic    ${set_gnb4_cell1}
    Update Cfg Aic    gnb_param id=4 xn_listening_socket=on send_xn_setup=off

    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.11.22 gnb_id=0x5:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.22 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=127:2 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb5}
    Update Cfg Aic    ${set_gnb5_cell1}
    Update Cfg Aic    gnb_param id=5 xn_listening_socket=on send_xn_setup=off

    ${set_gnb6}    catenate    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.11.23 gnb_id=0x6:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.23 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb6_cell1}    catenate    set_cell id=1 gnb=6 pci=128:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.93:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb6}
    Update Cfg Aic    ${set_gnb6_cell1}
    Update Cfg Aic    gnb_param id=6 xn_listening_socket=on send_xn_setup=off

GNB shall trigger XN setup
    [Arguments]    ${xnlinkID}=1
    ${parameters}    create List    MRBTS-1/NRBTS-1/XNLINK-${xnlinkID}:xnLinkStatus=available
    Object Should Exist In Cu    ${parameters}

Enable_Remote_GNB_XN_SETUP
    [Arguments]    ${remote_gnbID}
    Execute Egate Command    gnb_param id=${remote_gnbID} xn_listening_socket=1 send_xn_setup=on sib1_period=3000

Parameters set and x2 setup
    Delta Commission Parameters Cu    ${parameterscu_C02}
    Execute Egate Command    enb_x2_link_up enb=1 target=2 x2_link_addr=10.0.1.10    pass_regexp=is up
    Execute Egate Command    enb_x2_link_up enb=100 target=2 x2_link_addr=10.0.1.11    pass_regexp=is up
    Execute Egate Command    enb_x2_link_up enb=101 target=2 x2_link_addr=10.0.1.12    pass_regexp=is up
    Execute Egate Command    enb_x2_link_up enb=102 target=2 x2_link_addr=10.0.1.13    pass_regexp=is up

Trigger 7324 Faultid Cu
    ${fault7324}    Create List    fault_id=7324    alarm_name=BASE STATION INFORMATION    fault_name=Maximum of X2 links reached
    Fm Fault Should Be Raised Cu    ${fault7324}
    Execute Egate Command    enb_x2_link_up enb=103 target=2 x2_link_addr=10.0.1.13
    ...    pass_regexp=EN-DC X2 Setup Failure recvd from gNB-2    fail_regexp=is up

Trigger Cleared 7324 Faultid Cu
    Execute Egate Command    link_drop link=x2 by=enb:101 to=gnb:2
    Execute Egate Command    link_drop link=x2 by=enb:102 to=gnb:2
    sleep    ${x2LinkSupervisionTmr}
    Object Should Not Exist in CU    MRBTS-1/NRBTS-1/LTEENB-2:x2LinkStatus=available
    Object Should Not Exist in CU    MRBTS-1/NRBTS-1/LTEENB-3:x2LinkStatus=available
    ${fault7324}    Create List    fault_id=7324
    Fm Fault Should Be Cleared Cu Aic    ${fault7324}
    Execute Egate Command    enb_x2_link_up enb=103 target=2 x2_link_addr=10.0.1.13    pass_regexp=is up
    Execute Egate Command    enb_x2_link_up enb=103 target=2 duplicate_x2_setup_error=true x2_link_addr=10.0.1.13    pass_regexp=is up

Trigger XN setup request from GNBSim1 to CPIF
    Enable_Remote_GNB_XN_SETUP    remote_gnbID=3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2 xn_link_addr=10.0.12.10    is up
    Object Should Exist in CU    NRADJGNB-1:administrativeState=Unlocked
    GNB shall trigger XN setup    xnlinkID=1

Trigger XN setup request from GNBSim2 to CPIFA1
    Enable_Remote_GNB_XN_SETUP    remote_gnbID=4
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2 xn_link_addr=10.0.12.11    is up
    Object Should Exist in CU    NRADJGNB-2:administrativeState=Unlocked
    GNB shall trigger XN setup    xnlinkID=2

Online add XNLink MOC to GnbSim3 and GNBSim4
    Delta Commission Parameters Cu    ${parameterscu_C19addMOC}
    Object Should Exist in CU    NRADJGNB-3:administrativeState=Unlocked
    GNB shall trigger XN setup    xnlinkID=3
    Object Should Exist in CU    NRADJGNB-4:administrativeState=Unlocked
    GNB shall trigger XN setup    xnlinkID=4

caseC02_teardown
    Delta Commission Parameters Cu    ${teardown_C02}
    Common Test Teardown And Stop Capture Logs Aic

caseC19_teardown
    Delta Commission Parameters Cu    ${teardown_C19}
    Common Test Teardown And Stop Capture Logs Aic
