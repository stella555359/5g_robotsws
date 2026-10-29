*** Settings ***
Documentation   This is a keyword file for CB008146-E, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library         taf.config.wts    WITH NAME    wts

*** Variables ***

${wts_GNB_XN_ADDR}                    10.0.1.2
${wts_GNB3_XN_ADDR}                   10.0.1.3
${wts_GNB3_NG_ADDR}                   10.0.1.4
${wts_GNB3_CELL3_ADDR}                10.0.1.5
${wts_GNB3_CELL4_ADDR}                10.0.1.6
${wts_GNB3_CELL5_ADDR}                10.0.1.7

${cap1_2cell}   SEPARATOR=
...             E1A01000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C0010327
...             8FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286809659
...             44C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA80
...             00028000001041C4D0000000070A000000001809B00A014058080440230FF5555502C03000281C040703005807000683E0000000000000E54D
...             000100000965950034AAA8081C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12986B4

${cap51}        SEPARATOR=
...             E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F11B586368E9315047F2CA49940E04
...             16C9824060C78C7FE618F28581C0E1E0227009C00100388C00000000841808DCB8280301804800E07C0390400000290400000A90400001292
...             500001A601F036F2A6F032B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA48480002A9652401740E2E9545D03
...             89A55134AA22BB102401E0068040200000000000801002100

${cap52}        SEPARATOR=
...             E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600941F11B586368E9315047F2CA49940E04
...             16C9824060C78C7FE618F28581C0E1E0227009C0283E026B0C6D1D262A08FE59493281C082D930480C18F18FFCC31E50B0381C3C045551554
...             0400711800000001C040000000060234004E5C140180C02400703E01C8200000148200000548200000949280000D300F81B795378195BA401
...             41000009652404000065949010000296524040000E594941000049652424000154B29200BA07174AA2E81C4D2A89A55115D881200F0034020
...             10000000000040080108

${cap53}        SEPARATOR=
...             E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600941F11B586368E9315047F2CA49940E04
...             16C9824060C78C7FE618F28581C0E1E0227009C0283E026B0C6D1D262A08FE59493281C082D930480C18F18FFCC31E50B0381C3C045551554
...             0400711800000001C040000000060234004E5C140180C02400703E01C8200000148200000548200000949280000D300F81B795378195BA401
...             41000009652404000065949010000296524040000E594941000049652424000154B29200BA07174AA2E81C4D2A89A55115D881200F0034020
...             1000000000004008010A2280

${cap54}        SEPARATOR=
...             EFA01000574F5E13020002C2A00241220C00130707006201A0130080C45018053382B506C4DD608C21A08107CA0702CB64C550D0E7C471E81
...             9F604F8C73E618F28581C0E1E0B8002F800E000BE0007D001C0014006CA0000A00000A836276B04610D04083E5038165B262A86873E238F40
...             CFB027C639F30C7942C0E070F05C0003C0070000F0003E000E000A0541B133582308682041F281C0B2D931543439F11C7A067D813E31CF986
...             3CA1607038782E000BE0038002F8001E4007001B280002800003A0D85181AC1184341020F940E0596C98AA1A1CF88E3D033EC09F18E7CC31E
...             50B0381C3C170005F001C0017C000F8003800281506C27D608C21A08107CA0702CB64C550D0E7C471E819F604F8C73E618F28581C0E1E1380
...             02F800E000BE00078001C0A83612EB04610D04083E5038165B262A86873E238F40CFB027C639F30C7942C0E070F09C00100007000400003C0
...             00E0541B06F582308682041F281C0A2D931542439F604F88E3C639F30C7942C0E070F04FE8000003FA0000001E000702A0D805AC118434102
...             0F940E0516C98AA121CFB027C471E31CF9863CA16070387827F4000001FD0000000F000381506C00D608C21A08107CA07028B64C55090E7D8
...             13E238F18E7CC31E50B0381C3C13FB000000FEC00000078001C0A836236B04610D04083E5038145B262A84873EC09F11C78C73E618F28581C
...             0E1E09FC0000007F00000003C000E0541B107582308682041F281C0A2D931542439F604F88E3C639F30C7942C0E070F04FEC000003FB00000
...             01E000702A0D831AC1184341020F940E0516C98AA121CFB027C471E31CF9863CA16070387827F6000001FD8000000F000381506C13D608C21
...             A08107CA07028B64C55090E7D813E238F18E7CC31E50B0381C3C13F8000000FE000000078001C0A83605EB04610D04083E5038145B262A848
...             73EC09F11C78C73E618F28581C0E1E09F80000007E00000003C000E0541B01F582308682041F281C0A2D931542439F604F88E3C639F30C794
...             2C0E070F04FE0000003F80000001E000702A0D80DAC1184341020F940E0516C98AA121CFB027C471E31CF9863CA16070387827F6000001FD8
...             000000F000381506C04D608C21A08107CA07028B64C55090E7D813E238F18E7CC31E50B0381C3C13F8000000FE000000078001C0A83600EB0
...             4610D04083E5038145B262A84873EC09F11C78C73E618F28581C0E1E09FC0000007F00000003C000E0540B41378E3087000A8F3F141C08FDB
...             31552003C78010E208308A8147EFE40DC6E307400180A81681EF1C610E00151E7E283811FB662AA40078F0021C4106115028FDFC81B8DC60E
...             800301502D01DE38C21C002A3CFC507023F6CC554800F1E00438820C22A051FBF90371B8C1D000602A05A01BC718438005479F8A0E047ED98
...             AA9001E3C0087104184540A3F7F206E37183A000C001081C460000000881D000000020801808D04002C019014089B1CF870A24ED8E7C31E82
...             60070007838280381804A00E000C0480080C05042000000107013440073E618F28581814108004000C81C04D4000438820422A0407C1D0040
...             00000020000040100080200802000008010000060080000400400002802000018010008000000200001C01000010008000090040000500200
...             002C0100001924A0040D034B925000069724A00C0D0340D034B9250040681A069724A0180D0340D0340D0340D2E4940201A0681A0681A5C92
...             8070340D0340D0340D0340D2E4940001A9C928010340D4E4940101A0681A9C928070340D0340D0340D0340D4E4940181A0681A06A724A0000
...             D0E4940381A0681A0681A0681A068724A00C0D0340D03430379535953594B591B5829582B583358195933580B58115809581B5BA403C10000
...             09652504000065949410000296524040000E594901000049652404000165949010000696524040001E5949010000896524040002659490100
...             00A96524040102C0B96525040002E5949410000C96524040000C59490100005165240314AAAE95555298BA551548E2A82C55068AA071549A2
...             A80C55028AAED452A8A1204901DA05028140A05028140A05028140A050280402010080402010080402010080402010000080040400800080E
...             018314060C82848C8




*** Keywords ***

Create ips for simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs on VM eth3
    Log To Console    ${wts_GNB3_XN_ADDR}, ${wts_GNB3_NG_ADDR}, ${wts_GNB3_CELL3_ADDR}, ${wts_GNB3_CELL4_ADDR} and ${wts_GNB3_CELL5_ADDR}
    Configure IP on VM    ip=${wts_GNB3_XN_ADDR}       interface=eth3
    Configure IP on VM    ip=${wts_GNB3_NG_ADDR}       interface=eth3
    Configure IP on VM    ip=${wts_GNB3_CELL3_ADDR}    interface=eth3
    Configure IP on VM    ip=${wts_GNB3_CELL4_ADDR}    interface=eth3
    Configure IP on VM    ip=${wts_GNB3_CELL5_ADDR}    interface=eth3


Update wts file for TC CB008146E plmn1
    [Documentation]    [PRIVATE]    update wts cfg file for plmn1 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn1 ${mcc_SCF}:${mnc_SCF}
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert    set GNB_XN_ADDR="${wts_GNB_XN_ADDR}"   after   set GNB_NG_ADDR="${wts_GNB_XN_ADDR}"
    wts.Insert    set GNB3_XN_ADDR="${wts_GNB3_XN_ADDR}"   after    set GNB_XN_ADDR="${wts_GNB_XN_ADDR}"
    wts.Insert    set GNB3_NG_ADDR="${wts_GNB3_NG_ADDR}"   after    set GNB3_XN_ADDR="${wts_GNB3_XN_ADDR}"
    wts.Insert    set GNB3_CELL3_ADDR="${wts_GNB3_CELL3_ADDR}"   after   set GNB3_NG_ADDR="${wts_GNB3_NG_ADDR}"
    wts.Insert    set GNB3_CELL4_ADDR="${wts_GNB3_CELL4_ADDR}"   after   set GNB3_CELL3_ADDR="${wts_GNB3_CELL3_ADDR}"
    wts.Insert    set GNB3_CELL5_ADDR="${wts_GNB3_CELL5_ADDR}"   after   set GNB3_CELL4_ADDR="${wts_GNB3_CELL4_ADDR}"
    wts.Insert    set PLMN="${mcc_SCF}:${mnc_SCF}"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Modify    set_amf_region   	plmn=$PLMN
    wts.Modify    set_gnb id=2    plmn=$PLMN gnb_id=0x1:22 plmnList=${mcc_SCF}:${mnc_SCF},${mcc_SCF}:388 xn=$GNB_XN_ADDR
    wts.Insert    set_gnb id=3 type=simulated plmn=$PLMN ng=$GNB3_NG_ADDR gnb_id=0x26:22   after   set_cell id=1 gnb=2
    wts.Modify    set_gnb id=3    daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1
    wts.Modify    set_gnb id=3    plmnList=${mcc_SCF}:${mnc_SCF},${mcc_SCF}:388 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=${fiveGsTac_SCF} nrci=0x01 tdd_cell=off   after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890
    wts.Modify    set_cell id=1 gnb=3   nr_arfcn=135760:126380 mandatory_for_activation=off gscn=1582
    wts.Insert    set_cell id=2 gnb=3 pci=15:1 tac=${fiveGsTac_SCF} nrci=0x02 tdd_cell=off   after   set_cell id=1 gnb=3
    wts.Modify    set_cell id=2 gnb=3   proxy=$GNB3_CELL3_ADDR:9999|$GNB3_CELL3_ADDR:8892 nr_arfcn=137200:128000
    wts.Modify    set_cell id=2 gnb=3   mandatory_for_activation=off gscn=1600
    wts.Insert    set_cell id=3 gnb=3 pci=15:2 tac=${fiveGsTac_SCF} nrci=0x03 tdd_cell=off   after   set_cell id=2 gnb=3
    wts.Modify    set_cell id=3 gnb=3   proxy=$GNB3_CELL4_ADDR:9999|$GNB3_CELL4_ADDR:8893 nr_arfcn=167500:176500
    wts.Modify    set_cell id=3 gnb=3   mandatory_for_activation=off gscn=2204
    wts.Insert    set_cell id=4 gnb=3 pci=16:1 tac=${fiveGsTac_SCF} nrci=0x04 tdd_cell=on   after   set_cell id=3 gnb=3
    wts.Modify    set_cell id=4 gnb=3	proxy=$GNB3_CELL5_ADDR:9999|$GNB3_CELL5_ADDR:8894 nr_arfcn=2071591:2071591
    wts.Modify    set_cell id=4 gnb=3	    mandatory_for_activation=off gscn=22446
    wts.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true   after   set_cell id=4 gnb=3
    wts.Modify    set_ue simulated id=51    suci=0:$PLMN:0000:0:0:021645450
    wts.Modify    set_ue simulated id=52    suci=0:$PLMN:0000:0:0:021645451
    wts.Modify    set_ue simulated id=53    suci=0:$PLMN:0000:0:0:021645452
    wts.Modify    set_ue simulated id=54    suci=0:$PLMN:0000:0:0:021645453

    wts.Modify    ue_param id=51    ue_nr_capabilities=${cap51}
    wts.Modify    ue_param id=52    ue_nr_capabilities=${cap52}
    wts.Modify    ue_param id=53    ue_nr_capabilities=${cap53} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=54    ue_nr_capabilities=${cap54}

    wts.Modify    set_nwslice id=1    ue=all
    wts.Insert    set_nwslice id=2 snssai=0x01:0xD143A6 ue=52 amf=1    after   set_nwslice id=1

    wts.Modify    debug_log     level=0
    wts.Modify    sim_debug_log level=4 mme=1      level=1
    wts.Modify    sim_debug_log level=4 uec=1      level=1
    wts.Modify    sim_debug_log level=4 pgw=1      level=1
    wts.Modify    sim_debug_log level=4 sgw=1      level=1

    wts.Delete    trace enb=1 protocol=x2 on
    wts.Delete    trace uec=1 protocol=x2 on

    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg


Update wts file for TC CB008146E plmn2
    [Documentation]    [PRIVATE]    update wts cfg file for plmn2 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn2 ${mcc_SCF}:388
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg
    wts.Delete    set PLMN="${mcc_SCF}:${mnc_SCF}"
    wts.Insert    set PLMN="${mcc_SCF}:388"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008146E_plmn2.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008146E_plmn2.cfg


Update wts file for TC CB008146E plmn1 voice
    [Documentation]    [PRIVATE]    update wts cfg file for plmn1 voice usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn1 voice
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg
    wts.Modify    set_qosflow id=1     5qi=5 default=on
    wts.Modify    set_qosflow id=2     5qi=1 default=off
    wts.Modify    set_qosflow id=3     5qi=2 default=off
    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008146E_plmn1_voice.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008146E_plmn1_voice.cfg


Update wts file for TC CB008146E 2 cell config
    [Documentation]    [PRIVATE]    update wts cfg file for 2 cell config
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg for 2 cell config
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Modify    set_gnb id=2    gnb_id=0x1:22 plmnList=311:489,311:388 nssai=0x1:0xd143a5,0x1:0xd143a6
    wts.Modify    set_cell id=1 gnb=2     nr_arfcn=647666:647666 nrci=0x01 gscn=7995
    wts.Modify    ue_param id=1   ue_nr_capabilities=${cap1_2cell}
    wts.Modify    ue_param id=2   ue_nr_capabilities=${cap1_2cell}
    wts.Insert    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 ue=1    after   set_nwslice id=1
    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008146E_2cell.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008146E_2cell.cfg


Load wts file
    [Documentation]    [PRIVATE]    load wts file for special configuration
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${file_usage}
    ${file_name}    Set Variable If
                    ...   '${file_usage}'=='plmn1'          basic_wts_CB008146E_plmn1.cfg
                    ...   '${file_usage}'=='plmn2'          basic_wts_CB008146E_plmn2.cfg
                    ...   '${file_usage}'=='plmn1 voice'    basic_wts_CB008146E_plmn1_voice.cfg
                    ...   ${True}                           basic_wts_CB008146E_2cell.cfg
    Upload Customized WTS Config    config_path=${resultBaseDir}/${file_name}


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

