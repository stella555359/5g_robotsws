*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_Aic    RAN_5G    CRT    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA    team-SG02    owner-keyun.ma    release-24R2
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T
${MULTI_CPIF_FLAG}    True
${REDUNDANT_MODE_CU_FLAG}    True
@{FAULTS_EXCLUDED_CHECKING}    7308

@{PARAMS_IN_SCF_CU}    @{AMFs}    @{XnLink}

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
...    NRBTS:actIncXn=true

@{DU_CELL1}
...    NRDU-1:remotef1CplaneIpAddr=172.16.1.101

@{DU_CELL2}
...    NRDU-2:remotef1CplaneIpAddr=172.16.1.102

@{PM_Counters_06}
...    NRBTS-1:${XN_SETUP_FAIL_CONFUSION}=4

${XN_SETUP_FAIL_CONFUSION}    M55126C00020


*** Test Cases ***
CB009021-CR-BB-B6_ET_06_Subsequent XN setup request from peer
    [Documentation]
    ...    1. 10.0.1.10 - cpif
    ...       10.0.1.11 - cpifa1
    ...       10.0.1.12 - cpifa2
    ...       10.0.1.13 - cpifa3
    ...    2. Test Case Steps:
    ...         a. Trigger Xn links is up
    ...         b. GNBSim3 send XN setup request to same CPIFA1
    ...         c. GNBSim3 send XN setup Request to other CPIF/CPIF2
    ...         d. GNBSim5 send XN setup Request to other CPIF1/CPIF3
    ...         e. Check counters
    ...    3. Expected Results:
    ...         a: Xnlink setup correctly from GNBSim-3
    ...         b: GNBSim3 send XN setup request to same CPIFA1 successful
    ...         c: GNBSim3 send XN setup Request to CPIF/CPIF2, XN setup shall be rejected
    ...         d: GNBSim5 send XN setup Request to CPIF1/CPIF3, XN setup shall be rejected
    ...         e: M55126C00020 should be 4
    [Tags]    06
    Clear Counter Files Cu Aic    wait=False
    Trigger Xn links is up
    GNBSim3 send XN setup request to same CPIFA1
    GNBSim3 send XN setup Request to other CPIF and CPIF2
    GNBSim5 send XN setup Request to other CPIF1 and CPIF3
    check counters cu aic    ${PM_Counters_06}
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
    Update Cfg Aic    gnb_param id=2 xn_listening_socket=1 send_xn_setup=off sib1_period=3000
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.20 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.20 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3}
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=3000
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.11.21 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.21 nssai=0x1:0xd143a5 amf=1-4
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=127:2 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9998 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb5}
    Update Cfg Aic    ${set_gnb5_cell1}
    Update Cfg Aic    gnb_param id=5 xn_listening_socket=on send_xn_setup=off sib1_period=3000

Trigger Xn links is up
    Execute Egate Command    gnb_xn_setup_param id=3 action=delayed_rsp nth=1 time_to_wait=v60s
    Execute Egate Command    gnb_xn_setup_param id=5 action=delayed_rsp nth=1 time_to_wait=v60s
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Execute Egate Command    gnb_param id=5 xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2 xn_link_addr=10.0.12.11 duplicate_xn_setup_error=yes    is up

GNBSim3 send XN setup request to same CPIFA1
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2 xn_link_addr=10.0.12.11 duplicate_xn_setup_error=yes    is up

GNBSim3 send XN setup Request to other CPIF and CPIF2
    GNBSim3 send XN setup Request to other CPIF    xn_link_addr=10.0.12.10    #cpif
    GNBSim3 send XN setup Request to other CPIF    xn_link_addr=10.0.12.12    #cpif2
GNBSim3 send XN setup Request to other CPIF
    [Arguments]    ${xn_link_addr}=10.0.12.10
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2 xn_link_addr=${xn_link_addr} duplicate_xn_setup_error=yes
    ...    pass_regexp=Duplicate Xn link will be dropped
GNBSim5 send XN setup Request to other CPIF1 and CPIF3
    GNBSim5 send XN setup Request to other CPIF    xn_link_addr=10.0.12.11    #cpif1
    GNBSim5 send XN setup Request to other CPIF    xn_link_addr=10.0.12.13    #cpif3
GNBSim5 send XN setup Request to other CPIF
    [Arguments]    ${xn_link_addr}=10.0.12.11
    Execute Egate Command    gnb_xn_link_up gnb=5 target=2 xn_link_addr=${xn_link_addr} duplicate_xn_setup_error=yes
    ...    pass_regexp=Received XnAP:XnSetupFailure
