*** Settings ***
Documentation   This is a keyword file for CB008127, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library     taf.config.wts     WITH NAME    wts

*** Variables ***

${ue1_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EB800FF800E003FE000E10001DB8000400000003
...             80004000000001546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E000100000000000841C4D
...             0000000020268E800007008089EC4600060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A00695550F0007000B000000040080118B130
...             001020304050607080B101112131921252627284A0

${ue2_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3E8E003FE003800FF80038400076E000100000000
...             E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000400000003800040000000000210713
...             400000000809A3A00001C020227B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C000000100200462C4C
...             0004080C1014181C202C4044484C648494989CA128

${ue3_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EB800FF800E003FE000E14001DB8000400000003
...             800040000000000800100001546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E00010000000
...             0000841C4D0000000020268E800007008089EC4600060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A00695550F0007000B000000040
...             080118B130001020304050607080B101112131921252627284A0

${ue4_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000
...             E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000400000003800040000000000210713
...             400000000809A3A00001C020227B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C000000100200462C4C
...             0004080C1014181C202C4044484C648494989CA128

${ue5_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3ECE003FE003800FF80038400076E000100000000
...             E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000400000003800040000000000210713
...             400000000809A3A00001C020227B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C000000100200462C4C
...             0004080C1014181C202C4044484C648494989CA128

${ue6_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EEE003FE003800FF80038400076E000100000000
...             E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000400000003800040000000000210713
...             400000000809A3A00001C020227B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C000000100200462C4C
...             0004080C1014181C202C4044484C648494989CA128

${ue7_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EB800FF800E003FE000E10101DB8000400000003
...             80004000000000108000000000000001546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E000
...             100000000000841C4D0000000020268E800007008089EC4600060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A00695550F0007000B0
...             00000040080118B130001020304050607080B101112131921252627284A0

${ue8_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EB800FF800E003FE000E10101DB8000400000003
...             80004000000000108000000000000021546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E000
...             100000000000841C4D0000000020268E800007008089EC4600060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A00695550F0007000B0
...             00000040080118B130001020304050607080B101112131921252627284A0

${ue9_cap_nr}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EB800FF800E003FE000E10101DB8000400000003
...             80004000000000108000000000000041546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E000
...             100000000000841C4D0000000020268E800007008089EC4600060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A00695550F0007000B0
...             00000040080118B130001020304050607080B101112131921252627284A0


${ue7_cap_nr_t13}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EB800FF800E003FE000E10101DB8000400000003
...             80004000000000108000000000000001546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E000
...             100000000002001C2800000000713000000801C4D0000040071380000180380510132026C04E1F0000110200880440220111EC4600060005038280381804C00E
...             000D07C0000000000001CA9A0002000012CB2A00695550F0007000B0001800400801000801002001002004002004008D58980008101820283038405880889098
...             C90929313942519680


${ue7_nr_cap_t16_start}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603805546C4CD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E00010000000005513137582028680965944C44003D6C10101070EF1C39061C00103278FAE003FE003800FF80038404
...             076E000100000000E0001000000000042000000000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB
...             8000400000003800040000000000210713400000002809901360270F800003804044F6230003000281C1401C0C026007000683E0000000000000E54D00010000
...             0965950034AAA878003800580000002004008C58980008101820283038405880889098C9092931394250


${ue7_nr_cap_t16}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001544C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EB800FF800E003FE000E10101DB8000400000003
...             80004000000000108000000000000001546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E000
...             100000000002001C2800000000713000000801C4D0000040071380000180380510132026C04E1F0000110200880440220111EC4600060005038280381804C00E
...             000D07C0000000000001CA9A0002000012CB2A00695550F0007000B0001800400801000801002001002004002004008C58980008101820283038405880889098
...             C9092931394250


${ue4_nr_cap_MFBI}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603805546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000038400076E000100000000E0001
...             00000000000841C4C0000000020260E800007008089EC4600060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A00695550F0007000B00
...             0000040080118B130001020304050607080B101112131921252627284A


${ue7_nr_cap_MFBI}   SEPARATOR=
...             E1A00000074E5A031E000385A0000F04983200021E1A0018806804C060180E00D513133582028680965944C44003D6C10101070EF1C39061C00103278FAE003F
...             E003800FF80038404076E000100000000E0001000000000042000000000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800
...             002800000E10001DB8000400000003800040000000000210713000000001809901388400000E010113D88C000C000A070500703009801C001A0F800000000000
...             0395340004000025965400D2AAA1E000E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940


${ue7_nr_cap_t22}   SEPARATOR=
...             E1A00000074E5A031E000385A0000F04983200021E1A0018806804C060180E015513167582028680965944C44003D6C10101070EF1C39061C00103278FAE003F
...             E003800FF80038404076E000100000000E00010000000000420000000000000005513133582028680965944C44003D6C10101070EF1C39061C00103278FAE003
...             FE003800FF80038404076E000100000000E0001000000000042000000000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA80
...             0002800000E10001DB8000400000003800040000000000600716400000001C4C0000020071380000180280B3013202710800003C06022011008807B118001800
...             140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C0006001002004002004008004008010008010023162600020406080
...             A0C0E10162022242632424A4C4E50940


${ue4_nr_cap_t23}   SEPARATOR=
...             E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003F
...             E003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E100
...             01DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3ECE003FE003800FF80038400076E000100000000
...             E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB800040000000380004000000000080070A
...             000000001C4C00000200713400001001C4E00000600E014404C809B01387C0000440802201100880447B118001800140E0A00E06013003800341F00000000000
...             0072A68000800004B2CA801A55543C001C002C0006001002004002004008004008010008010023162600020406080A0C0E10162022242632424A4C4E5094




*** Keywords ***
Update Wts File For TC CB008127
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load Wts Cfg             ${wtsconfig}

    wts.Insert    set GNB_XN_ADDR="10.0.1.2"    after    set GNB_X2_ADDR="10.0.1.2"
    wts.Insert    set GNB3_XN_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert    set GNB3_NG_ADDR="10.0.1.4"   after    set GNB3_XN_ADDR="10.0.1.3"

    wts.Modify    set_gnb id=2   xn=$GNB_XN_ADDR gnb_id=0x01:22

    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x03:28     after   set_cell id=2 gnb=2
    wts.Modify    set_gnb id=3   daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=200 nrci=0x01 tdd_cell=on    after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890 nr_arfcn=633364:633364 gscn=7847 mandatory_for_activation=off
    wts.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=xn_based    after   set_cell id=1 gnb=3
    wts.Insert    set_cell id=2 gnb=3 pci=16:1 tac=200 nrci=0x02 tdd_cell=on    after   set_cell id=1 gnb=3
    wts.Modify    set_cell id=2 gnb=3   proxy=$GNB3_XN_ADDR:9999|$GNB3_XN_ADDR:8891 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off

    wts.Modify    ue_param id=1    ue_nr_capabilities=${ue1_cap_nr}
    wts.Modify    set_ue simulated id=1   release=17
    wts.Modify    ue_param id=2    ue_nr_capabilities=${ue2_cap_nr}
    wts.Modify    set_ue simulated id=2   release=17
    wts.Modify    ue_param id=3    ue_nr_capabilities=${ue3_cap_nr}
    wts.Modify    set_ue simulated id=3   release=17
    wts.Modify    ue_param id=4    ue_nr_capabilities=${ue4_cap_nr}
    wts.Modify    set_ue simulated id=4   release=17
    wts.Modify    ue_param id=5    ue_nr_capabilities=${ue5_cap_nr}
    wts.Modify    set_ue simulated id=5   release=17
    wts.Modify    ue_param id=6    ue_nr_capabilities=${ue6_cap_nr}
    wts.Modify    set_ue simulated id=6   release=17
    wts.Modify    ue_param id=7    ue_nr_capabilities=${ue7_cap_nr}
    wts.Modify    set_ue simulated id=7   release=17
    wts.Modify    ue_param id=8    ue_nr_capabilities=${ue8_cap_nr}
    wts.Modify    set_ue simulated id=8   release=17
    wts.Modify    ue_param id=9    ue_nr_capabilities=${ue9_cap_nr}
    wts.Modify    set_ue simulated id=9   release=17

    wts.Insert    set_qosflow id=4 5qi=7                   after   set_qosflow id=3
    wts.Insert    set_qosflow id=5 5qi=8                   after   set_qosflow id=4
    wts.Insert    set_qosflow id=6 5qi=9                   after   set_qosflow id=5

    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4,5,6

    wts.Save Wts Cfg              ${resultBaseDir}/basic_wts_CB008127.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008127.cfg


Upload Wts Cfg File
    [Documentation]    [PRIVATE]    upload wts cfg file
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${wts_file}=${resultBaseDir}/basic_wts_CB008127.cfg
    Log To Console    \nupload wts file ${wts_file}
    Upload Customized WTS Config    config_path=${wts_file}


Update Wts File For TC CB008127 Steering
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 steering
    ...       :Autor: Sylvia Schneider
    Update Wts File For TC CB008127
    Log To Console    \nupdate wts with steering specific params
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127.cfg
    wts.Modify    set_cell id=2 gnb=2    nr_arfcn=647666:647666 gscn=7995
    wts.Save Wts Cfg              ${resultBaseDir}/basic_wts_CB008127_steering.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008127_steering.cfg


Update Wts File For TC CB008127 T8
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 t8
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts for t8
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127.cfg
    wts.Modify    gnb_param id=3     sa_ho=ng_based
    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_t8.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_t8.cfg


Update Wts File For TC CB008127 T15
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 t15
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts for t15
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127.cfg
    wts.Modify    gnb_param id=3     srb1_rlc_sn_field_size=size_12
    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_t15.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_t15.cfg


Update Wts File For TC CB008127 T9
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 t9
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts for t9
    wts.Load Wts Cfg              ${resultBaseDir}/basic_wts_CB008127_steering.cfg
    wts.Modify    gnb_param id=3     sa_ho=ng_based
    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_t9.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_t9.cfg


Update Wts File For TC CB008127 InterRAT
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 interRAT
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load Wts Cfg             ${wtsconfig}

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

    wts.Modify    ue_param id=1    ue_nr_capabilities=${ue1_cap_nr}
    wts.Modify    set_ue simulated id=1   release=17
    wts.Modify    ue_param id=2    ue_nr_capabilities=${ue2_cap_nr}
    wts.Modify    set_ue simulated id=2   release=17
    wts.Modify    ue_param id=3    ue_nr_capabilities=${ue3_cap_nr}
    wts.Modify    set_ue simulated id=3   release=17
    wts.Modify    ue_param id=4    ue_nr_capabilities=${ue4_cap_nr}
    wts.Modify    set_ue simulated id=4   release=17
    wts.Modify    ue_param id=5    ue_nr_capabilities=${ue5_cap_nr}
    wts.Modify    set_ue simulated id=5   release=17
    wts.Modify    ue_param id=6    ue_nr_capabilities=${ue6_cap_nr}
    wts.Modify    set_ue simulated id=6   release=17
    wts.Modify    ue_param id=7    ue_nr_capabilities=${ue7_cap_nr}
    wts.Modify    set_ue simulated id=7   release=17
    wts.Modify    ue_param id=8    ue_nr_capabilities=${ue8_cap_nr}
    wts.Modify    set_ue simulated id=8   release=17
    wts.Modify    ue_param id=9    ue_nr_capabilities=${ue9_cap_nr}
    wts.Modify    set_ue simulated id=9   release=17

    wts.Insert    set_qosflow id=4 5qi=7                   after   set_qosflow id=3
    wts.Insert    set_qosflow id=5 5qi=8                   after   set_qosflow id=4
    wts.Insert    set_qosflow id=6 5qi=9                   after   set_qosflow id=5

    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4,5,6

    wts.Delete    sim_debug_log level=4 mme=1
    wts.Delete    sim_debug_log level=4 pgw=1
    wts.Delete    sim_debug_log level=4 sgw=1
    wts.Delete    trace enb=1 protocol=x2 on
    wts.Delete    trace uec=1 protocol=x2 on

    wts.Save Wts Cfg              ${resultBaseDir}/basic_wts_CB008127_interRAT.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008127_interRAT.cfg


Update Wts File For TC CB008127 InterRAT T13
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 interRAT t13
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127_interRAT.cfg
    wts.Modify    ue_param id=7    ue_nr_capabilities=${ue7_cap_nr_t13}
    wts.Modify    set_qosflow id=1     5qi=5
    wts.Modify    set_qosflow id=2     5qi=1
    wts.Delete    set_qosflow id=3

    wts.Modify    set_qosrule id=1    qos_flow=1
    wts.Modify    set_qosrule id=2    qos_flow=2
    wts.Modify    nwslice_set id=1    qos_flows=1,2,4,5,6 qos_rules=1,2

    wts.Save Wts Cfg              ${resultBaseDir}/basic_wts_CB008127_interRAT_t13.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008127_interRAT_t13.cfg


Update Wts File For TC CB008127 2bands
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 2bands
    ...       :Autor: Sylvia Schneider
    Update Wts File For TC CB008127
    Log To Console    \nupdate wts with 2bands specific params
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127.cfg
    wts.Modify    set_cell id=2 gnb=2    nr_arfcn=508020:508020 gscn=6351
    wts.Modify    ue_param id=7          ue_nr_capabilities=${ue7_nr_cap_t16_start}
    wts.Save Wts Cfg              ${resultBaseDir}/basic_wts_CB008127_2bands.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008127_2bands.cfg


Update Wts File For TC CB008127 2bands T18
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 2bands t18
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts for 2bands t18
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127_2bands.cfg
    wts.Modify    gnb_param id=3     sa_ho=ng_based
    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_2bands_t18.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_2bands_t18.cfg


Update Wts File For TC CB008127 2bands T19
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 2bands t19
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts for 2bands t19
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127_2bands.cfg
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

    wts.Delete    sim_debug_log level=4 mme=1
    wts.Delete    sim_debug_log level=4 pgw=1
    wts.Delete    sim_debug_log level=4 sgw=1
    wts.Delete    trace enb=1 protocol=x2 on
    wts.Delete    trace uec=1 protocol=x2 on

    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_2bands_t19.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_2bands_t19.cfg


Update Wts File For TC CB008127 2bands T23
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 2bands t23
    ...       :Autor: Sylvia Schneider
    Update Wts File For TC CB008127 2bands T19
    Log To Console    \nupdate wts for 2bands t23 based on t19
    wts.Load Wts Cfg             ${resultDir}/basic_wts_CB008127_2bands_t19.cfg
    wts.Insert    nwslice_set id=2 qos_flows=1,2,3,4,5,6 qos_rules=1,2 snssai=0x01:0xD143A6 ue=all amf=1      after   nwslice_set id=1
    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_2bands_t23.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_2bands_t23.cfg


Update Wts File For TC CB008127 MFBI
    [Documentation]    [PRIVATE]    Update wts file for TC CB008127 MFBI
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts with MFBI specific params
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127.cfg
    wts.Modify    set_cell id=1 gnb=2   mapped_MFBI=77
    wts.Modify    set_cell id=2 gnb=2   mapped_MFBI=77
    wts.Modify    ue_param id=4         ue_nr_capabilities=${ue4_nr_cap_MFBI}
    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_MFBI.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_MFBI.cfg


Update Wts File For TC CB008127 2bands MFBI
    [Documentation]    [PRIVATE]    update wts cfg file for CB008127 2bands MFBI
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts for 2bands t22
    wts.Load Wts Cfg             ${resultBaseDir}/basic_wts_CB008127_2bands.cfg
    wts.Modify    set_cell id=1 gnb=2   mapped_MFBI=77
    wts.Modify    set_cell id=2 gnb=2   mapped_MFBI=90
    wts.Modify    ue_param id=7         ue_nr_capabilities=${ue7_nr_cap_MFBI}
    wts.Save Wts Cfg              ${resultDir}/basic_wts_CB008127_2bands_MFBI.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008127_2bands_MFBI.cfg

