*** Settings ***
Documentation   This is a keyword file for CB008127, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library     taf.config.wts     WITH NAME    wts

*** Variables ***

${ue3_nr_cap}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000
...             E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB800040000000380004000000000080070A
...             000000001C4C00000200713400001001C4E00000600E014404C809B01387C0000440802201100880447B118001800140E0A00E06013003800341F00000000000
...             0072A68000800004B2CA801A55543C001C002C0006001002004002004008004008010008010023562600020406080A0C0E10162022242632424A4C4E509465A0

${ue4_nr_cap}   SEPARATOR=
...             29A00000010B802400C28D608C21A081074844006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E1BFF005BFF00480589BAC1184341020E9
...             08800DAD931563439F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C2DFFFFEDFFFFE02E0F0A000389A0000002C040802805101360260F200002808CFF55
...             55508C000F800A070500703009401C00180B0010180E0A00E07C03000000030000000040000000C000004050140AE50D642D6145606560CD646D654D64CD602D
...             606D604500C000006000000400000600010140502B4A2AE90D550A8BA071541A2A91C552A8AA4D15406AA81D55028A1E000E0014000108080100202004008404
...             00801010020004AC04000D28CB40

${ue5_nr_cap}   SEPARATOR=
...             E1A1000000280C07814060139680C78000E1480007824C1900010F0B0018806804C060180E01D51B0A3582028680965944C44003D6C10101070EF1C39061C001
...             03278FAB800FF800E003FE000E10001DB800040000000380004000000001546C4CD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003
...             800FF80038400076E000100000000E00010000000005513137582028680965944C44003D6C10101070EF1C39061C00103278FAE003FE003800FF80038404076E
...             000100000000E0001000000000042000000000000010551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000
...             40000000380004000000000080070A000000001C4C00000200713400001001C4E00000600E014404C809B01387C0000440802201100880447B118001800140E0
...             A00E06013003800341F000000000000052AA0002000012CB2A00695550F0007000B0001800400801000801002001002004002004008D58980008101820283038
...             405880889098C9092931394253A5B52800004940800060



*** Keywords ***

upload wts cfg file
    [Documentation]    [PRIVATE]    upload wts cfg file
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${wts_file}=${resultBaseDir}/basic_wts_CB008127.cfg
    Log To Console    \nupload wts file ${wts_file}
    Upload Customized WTS Config    config_path=${wts_file}


Update wts file for TC CB008127-F common
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127-F common
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}

    wts.Insert    set GNB_XN_ADDR="10.0.1.2"    after    set GNB_X2_ADDR="10.0.1.2"
    wts.Insert    set GNB3_XN_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert    set GNB3_NG_ADDR="10.0.1.4"   after    set GNB3_XN_ADDR="10.0.1.3"
    wts.Insert    set GNB4_NG_ADDR="10.0.1.5"   after    set GNB3_NG_ADDR="10.0.1.4"
    wts.Insert    set GNB4_XN_ADDR="10.0.1.6"   after    set GNB4_NG_ADDR="10.0.1.5"

    wts.Delete   set_enb id=1
    wts.Delete   enb_param id=1
    wts.Delete   set_cell id=1 enb=1
    wts.Delete   enb_endc_param id=1

    wts.Delete   mme_pool_area id=1
    wts.Delete   set_mme id=1
    wts.Delete   set_sgw id=1
    wts.Delete   set_pgw id=1

    wts.Modify    set_gnb id=2   xn=$GNB_XN_ADDR gnb_id=0x01:22

    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x03:28     after   set_cell id=2 gnb=2
    wts.Modify    set_gnb id=3   daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=200 nrci=0x01 tdd_cell=on    after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890 nr_arfcn=633364:633364 gscn=7847 mandatory_for_activation=off
    wts.Insert    set_cell id=2 gnb=3 pci=16:1 tac=200 nrci=0x02 tdd_cell=on    after   set_cell id=1 gnb=3
    wts.Modify    set_cell id=2 gnb=3   proxy=$GNB3_XN_ADDR:9999|$GNB3_XN_ADDR:8891 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    wts.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=xn_based    after   set_cell id=2 gnb=3

    wts.Insert    set_gnb id=4 type=simulated plmn=311:489 ng=$GNB4_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT     after   gnb_param id=3
    wts.Modify    set_gnb id=4      gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none xn=$GNB4_XN_ADDR
    wts.Insert    set_cell id=1 gnb=4 pci=3:2 earfcn=2000:20000 tac=200 proxy=$GNB4_NG_ADDR:12219      after   set_gnb id=4
    wts.Modify    set_cell id=1 gnb=4      nrci=0x1 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts.Insert    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false      after   set_cell id=1 gnb=4

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

    wts.Modify    ue_param id=3    ue_nr_capabilities=${ue3_nr_cap}
    wts.Modify    set_ue simulated id=3   release=17
    wts.Modify    ue_param id=4    ue_nr_capabilities=${ue4_nr_cap}
    wts.Modify    set_ue simulated id=4   release=17
    wts.Modify    ue_param id=5    ue_nr_capabilities=${ue5_nr_cap}
    wts.Modify    set_ue simulated id=5   release=17 red_cap=true

    wts.Modify    set_qosflow id=1    5qi=6
    wts.Modify    set_qosflow id=2    5qi=5
    wts.Modify    set_qosflow id=3    5qi=1

    wts.Modify    set_qosrule id=1   qos_flow=2
    wts.Modify    set_qosrule id=2   qos_flow=3

    wts.Modify    nwslice_set id=1      qos_flows=1,2,3

    wts.Delete    sim_debug_log level=4 mme=1
    wts.Delete    sim_debug_log level=4 pgw=1
    wts.Delete    sim_debug_log level=4 sgw=1
    wts.Delete    trace enb=1 protocol=x2 on
    wts.Delete    trace uec=1 protocol=x2 on

    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008127_F_common.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008127_F_common.cfg


Update wts file for TC CB008127-F t3
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127-F t3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts for t3
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008127_F_common.cfg

    wts.Modify    set_qosflow id=1    default=off
    wts.Modify    set_qosflow id=2    default=on

    wts.Save wts cfg              ${resultDir}/basic_wts_CB008127_F_t3.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_F_t3.cfg
