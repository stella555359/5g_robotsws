*** Settings ***
Documentation   This is a keyword file for CB012121-A-B13, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library     taf.config.wts     WITH NAME    wts

*** Variables ***

${nr_cap_UE1_UE2_UE3}    SEPARATOR=
...       E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E4187000
...       40C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C001032
...       78FAB800FF800E003FE000E10001DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3E
...       B800FF800E003FE000E10101DB800040000000380004000000000108000000000000001546C4ED6080A1A0259651311000F5B0404041C3BC70E
...       418700040C9E3EAA00000A0000038400076E000100000000E000100000000002001C2800000000713000000801C4D0000040071380000180380
...       510132026C04E1F0000110200880440220111EC4600060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A00695550F000
...       7000B0001800400801000801002001002004002004008C58980008101820283038405880889098C9092931394250


*** Keywords ***

Create ips for simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs 10.0.1.3 upto 10.0.1.11 and 10.0.1.121 on VM eth3
    FOR    ${ip}   IN RANGE   3   12
      Configure IP on VM    ip=10.0.1.${ip}        interface=eth3
    END
    Configure IP on VM    ip=10.0.1.121      interface=eth3


Load wts file
    [Documentation]    [PRIVATE]    load wts
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${wts_file}
    Upload Customized WTS Config    config_path=${wts_file}


check wts in active state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    check wts state
    Log To Console    check if wts in active state ended


check wts state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    ute_wtssim.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate


Update wts file for CB012121-A-B13
    [Documentation]    [PRIVATE]    Update wts file for CB012121-A-B13
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert  set GNB_XN_ADDR="10.0.1.2"    after    set GNB_NG_ADDR="10.0.1.2"
    wts.Insert  set GNB4_NG_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert  set GNB4_S1_ADDR="10.0.1.4"   after    set GNB4_NG_ADDR="10.0.1.3"
    wts.Insert  set GNB4_XN_ADDR="10.0.1.5"   after    set GNB4_S1_ADDR="10.0.1.4"
    wts.Insert  set GNB3_XN_ADDR="10.0.1.6"   after    set GNB4_XN_ADDR="10.0.1.5"
    wts.Insert  set GNB3_NG_ADDR="10.0.1.7"   after    set GNB3_XN_ADDR="10.0.1.6"
    wts.Insert  set GNB5_XN_ADDR="10.0.1.8"   after    set GNB3_NG_ADDR="10.0.1.7"
    wts.Insert  set GNB5_NG_ADDR="10.0.1.9"   after    set GNB5_XN_ADDR="10.0.1.8"

    wts.Delete  set ENB1_X2_ADDR="10.0.1.137"
    wts.Insert  set ENB1_X2_ADDR="10.0.1.121"    after    set GNB_S1U_ADDR="10.0.1.112"

    wts.Delete  set_enb id=1
    wts.Delete  enb_param id=1
    wts.Delete  set_cell id=1 enb=1
    wts.Delete  enb_endc_param id=1

    wts.Delete  mme_pool_area id=1
    wts.Delete  set_mme id=1
    wts.Delete  set_sgw id=1
    wts.Delete  set_pgw id=1

    wts.Modify  set_gnb id=2    gnb_id=0x1:22 xn=$GNB_XN_ADDR
    wts.Delete  set_cell id=1 gnb=2
    wts.Delete  set_cell id=2 gnb=2
    wts.Delete  set_cell id=3 gnb=2
    wts.Delete  set_cell id=4 gnb=2
    wts.Insert  set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888    after   set_gnb id=2
    wts.Modify  set_cell id=1 gnb=2  nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    wts.Insert  set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on     after   set_cell id=1 gnb=2
    wts.Modify  set_cell id=2 gnb=2  proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=648000:648000 gscn=8008 mandatory_for_activation=off
    wts.Insert  set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    after   set_cell id=2 gnb=2
    wts.Modify  set_cell id=3 gnb=2   nr_arfcn=135760:126380 gscn=1582 eci=0x000021f mandatory_for_activation=off
    wts.Insert  set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    after   set_cell id=3 gnb=2
    wts.Modify  set_cell id=4 gnb=2   nr_arfcn=135760:126380 gscn=1582 eci=0x000021f mandatory_for_activation=off

    wts.Insert   set_gnb id=3 type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x26:28 daemon=$DAEMON_IP:$DAEMON_PORT  after  set_cell id=4 gnb=2
    wts.Modify   set_gnb id=3    x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5

    wts.Insert   set_cell id=1 gnb=3 pci=16:0 tac=100 nrci=0x01 tdd_cell=on proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890   after  set_gnb id=3
    wts.Modify   set_cell id=1 gnb=3    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    wts.Insert   set_cell id=2 gnb=3 pci=16:1 tac=788 nrci=0x02 tdd_cell=on proxy=$GNB3_XN_ADDR:9999|$GNB3_NG_ADDR:8891   after  set_cell id=1 gnb=3
    wts.Modify   set_cell id=2 gnb=3    nr_arfcn=648000:648000 gscn=8008 mandatory_for_activation=off

    wts.Insert   gnb_param id=3 xn_listening_socket=1 send_xn_setup=false                                 after    set_cell id=2 gnb=3
    wts.Insert   gnb_make_plmnset dual_conn=off gnb=3 cell=1 plmn_set_id=1 tac=100 plmn_id_list=311:489   after    gnb_param id=3
    wts.Insert   gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x1:0xd143a5      after    gnb_make_plmnset
    wts.Insert   gnb_make_plmnset dual_conn=off gnb=3 cell=2 plmn_set_id=1 tac=788 plmn_id_list=311:489   after    gnb_set_nwslice_per_plmn
    wts.Insert   gnb_set_nwslice_per_plmn gnb=3 cell=2 plmn_set_id=1 plmn=311:489 nssai=0x1:0xd143a5
    ...   after    gnb_make_plmnset dual_conn=off gnb=3 cell=2

    wts.Insert   set_gnb id=5 type=simulated plmn=311:489 ng=$GNB5_NG_ADDR gnb_id=0x27:28    after   gnb_set_nwslice_per_plmn gnb=3 cell=2
    wts.Modify   set_gnb id=5   daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB5_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert   set_cell id=1 gnb=5 pci=18:0 tac=100 nrci=0x01 tdd_cell=on proxy=$GNB5_NG_ADDR:9999|$GNB5_NG_ADDR:8892   after   set_gnb id=5
    wts.Modify   set_cell id=1 gnb=5   nr_arfcn=510000:510000 gscn=6393 mandatory_for_activation=off
    wts.Insert   set_cell id=2 gnb=5 pci=18:1 tac=788 nrci=0x02 tdd_cell=on proxy=$GNB5_XN_ADDR:9999|$GNB5_NG_ADDR:8893   after   set_cell id=1 gnb=5
    wts.Modify   set_cell id=2 gnb=5   nr_arfcn=527000:527000 gscn=6616 mandatory_for_activation=off

    wts.Insert   gnb_param id=5 xn_listening_socket=1 send_xn_setup=false                                 after   set_cell id=2 gnb=5
    wts.Insert   gnb_make_plmnset dual_conn=off gnb=5 cell=1 plmn_set_id=1 tac=100 plmn_id_list=311:489   after   gnb_param id=5
    wts.Insert   gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x1:0xd143a5
    ...   after   gnb_make_plmnset dual_conn=off gnb=5 cell=1
    wts.Insert   gnb_make_plmnset dual_conn=off gnb=5 cell=2 plmn_set_id=1 tac=788 plmn_id_list=311:489
    ...   after   gnb_set_nwslice_per_plmn gnb=5 cell=1
    wts.Insert   gnb_set_nwslice_per_plmn gnb=5 cell=2 plmn_set_id=1 plmn=311:489 nssai=0x1:0xd143a5
    ...   after   gnb_make_plmnset dual_conn=off gnb=5 cell=2

    wts.Insert  set_gnb id=4 type=simulated plmn=311:489 ng=$GNB4_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT
    ...   after   gnb_set_nwslice_per_plmn gnb=5 cell=2
    wts.Modify  set_gnb id=4   gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none xn=$GNB4_XN_ADDR
    wts.Insert  set_cell id=1 gnb=4 pci=3:2 earfcn=2000:20000 tac=200 proxy=$GNB4_NG_ADDR:12219 nrci=0x1     after   set_gnb id=4
    wts.Modify  set_cell id=1 gnb=4   tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts.Insert  gnb_param id=4 xn_listening_socket=1 send_xn_setup=false     after   set_cell id=1 gnb=4

    wts.Modify  ue_param id=1    ue_nr_capabilities=${nr_cap_UE1_UE2_UE3}
    wts.Modify  ue_param id=2    ue_nr_capabilities=${nr_cap_UE1_UE2_UE3}
    wts.Modify  ue_param id=3    ue_nr_capabilities=${nr_cap_UE1_UE2_UE3}

    FOR   ${ue_id}   IN RANGE   101    111
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END
    FOR   ${ue_id}   IN RANGE   121    131
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END
    FOR   ${ue_id}   IN RANGE   151    161
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END
    FOR   ${ue_id}   IN RANGE   171    181
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END

    wts.Delete  uec_param id=1
    wts.Delete  trace enb=1
    wts.Delete  trace uec=1
    wts.Save wts cfg             ${resultBaseDir}/basic_wts_CB012121-A-B13.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB012121-A-B13.cfg
