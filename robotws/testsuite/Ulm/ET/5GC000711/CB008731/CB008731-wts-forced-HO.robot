*** Settings ***
Documentation   This is a keyword file for CB008731-force-HO, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library     taf.config.wts     WITH NAME    wts

*** Variables ***

${t1_cap}    SEPARATOR=
...          E1200000074E5A031E00038520001E09306400043C2C006201A0130180600807546C28D6080A1A0259651311000F5B0404041C3BC70E4187000
...          40C9E3ECE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C001032
...          78FB3800FF800E003FE000E10001DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3E
...          CE003FE003800FF80038400076E000100000000E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FB280
...          0002800000E10001DB80004000000038000400000000000E014404C809B013BD88C000C000A070500703009801C001A0F800000000000039534
...          0004000025965400D2AAA1E000E0016006AC4C0004080C1014181C202C4044484C648494989CA12B028



${new_ue1_cap}  SEPARATOR=
...          E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E4187000
...          40C9E3ECE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C001032
...          78FB3800FF800E003FE000E10001DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3E
...          CE003FE003800FF80038400076E000100000000E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FB280
...          0002800000E10001DB800040000000380004000000000080070A000000001C4C00000200713400001001C4E00000600E014404C809B01387C00
...          00440802201100880447B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C000600100200
...          4002004008004008010008010023562600020406080A0C0E10162022242632424A4C4E50958140


*** Keywords ***
Update wts file for TC CB008731 force HO
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 forced-HO part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts forced-HO part
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}

    wts.Insert    set GNB_XN_ADDR="10.0.1.2"    after    set GNB_X2_ADDR="10.0.1.2"
    wts.Insert    set GNB3_XN_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert    set GNB3_NG_ADDR="10.0.1.4"   after    set GNB3_XN_ADDR="10.0.1.3"
    wts.Insert    set GNB4_NG_ADDR="10.0.1.5"   after    set GNB3_NG_ADDR="10.0.1.4"
    wts.Insert    set GNB4_XN_ADDR="10.0.1.6"   after    set GNB4_NG_ADDR="10.0.1.5"

    wts.Modify    set_gnb id=2   xn=$GNB_XN_ADDR gnb_id=0x01:22
    wts.Modify    set_cell id=1 gnb=2    mapped_MFBI=77
    wts.Modify    set_cell id=2 gnb=2    nr_arfcn=508020:508020 gscn=6351 mapped_MFBI=90

    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x03:22     after   set_cell id=2 gnb=2
    wts.Modify    set_gnb id=3   daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=200 nrci=0x01 tdd_cell=on    after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890 nr_arfcn=633364:633364 gscn=7847 mandatory_for_activation=off
    wts.Insert    set_cell id=2 gnb=3 pci=16:1 tac=200 nrci=0x02 tdd_cell=on    after   set_cell id=1 gnb=3
    wts.Modify    set_cell id=2 gnb=3   proxy=$GNB3_XN_ADDR:9999|$GNB3_XN_ADDR:8891 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    wts.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=B2 sa_ho=xn_based    after   set_cell id=2 gnb=3

    wts.Insert    set_gnb id=4 type=simulated plmn=311:489 ng=$GNB4_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT     after   gnb_param id=3
    wts.Modify    set_gnb id=4      gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none xn=$GNB4_XN_ADDR
    wts.Insert    set_cell id=1 gnb=4 pci=3:2 earfcn=2000:20000 tac=200 proxy=$GNB4_NG_ADDR:12219      after   set_gnb id=4
    wts.Modify    set_cell id=1 gnb=4      nrci=0x1 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts.Insert    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false      after   set_cell id=1 gnb=4

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t1_cap}
    wts.Modify    set_ue simulated id=1   release=17


    wts.Insert    set_qosflow id=4 5qi=7                   after   set_qosflow id=3
    wts.Insert    set_qosflow id=5 5qi=8                   after   set_qosflow id=4
    wts.Insert    set_qosflow id=6 5qi=9                   after   set_qosflow id=5

    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4,5,6

    wts.Delete   set_enb id=1
    wts.Delete   enb_param id=1
    wts.Delete   set_cell id=1 enb=1
    wts.Delete   enb_endc_param id=1

    wts.Delete   mme_pool_area id=1
    wts.Delete   set_mme id=1
    wts.Delete   set_sgw id=1
    wts.Delete   set_pgw id=1


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

    wts.Delete    sim_debug_log level=4 mme=1
    wts.Delete    sim_debug_log level=4 pgw=1
    wts.Delete    sim_debug_log level=4 sgw=1
    wts.Delete    trace enb=1 protocol=x2 on
    wts.Delete    trace uec=1 protocol=x2 on

    wts.Save wts cfg              ${resultBaseDir}/basic_wts_8731_force_HO.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_8731_force_HO.cfg

    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_8731_force_HO.cfg
