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


${cap81}        SEPARATOR=
...             E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F11B586368E9315047F2CA49940E04
...             16C9824060C78C7FE618F28581C0E1E0227009C00100388C00000000841808DCB8280301804800E07C0390400000290400000A90400001292
...             500001A601F036F2A6F032B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA48480002A9652401740E2E9545D03
...             89A55134AA22BB102401E0068040200000000000801002100

${cap82}        SEPARATOR=
...             E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600941F11B586368E9315047F2CA49940E04
...             16C9824060C78C7FE618F28581C0E1E0227009C0283E026B0C6D1D262A08FE59493281C082D930480C18F18FFCC31E50B0381C3C045551554
...             0400711800000001C040000000060234004E5C140180C02400703E01C8200000148200000548200000949280000D300F81B795378195BA401
...             41000009652404000065949010000296524040000E594941000049652424000154B29200BA07174AA2E81C4D2A89A55115D881200F0034020
...             10000000000040080108

${cap83}        SEPARATOR=
...             E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600941F11B586368E9315047F2CA49940E04
...             16C9824060C78C7FE618F28581C0E1E0227009C0283E026B0C6D1D262A08FE59493281C082D930480C18F18FFCC31E50B0381C3C045551554
...             0400711800000001C040000000060234004E5C140180C02400703E01C8200000148200000548200000949280000D300F81B795378195BA401
...             41000009652404000065949010000296524040000E594941000049652424000154B29200BA07174AA2E81C4D2A89A55115D881200F0034020
...             1000000000004008010A2280

${cap84}        SEPARATOR=
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

Create IPs For Simulated GNB
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs on VM eth3
    Log To Console    ${wts_GNB3_XN_ADDR}, ${wts_GNB3_NG_ADDR}, ${wts_GNB3_CELL3_ADDR}, ${wts_GNB3_CELL4_ADDR} and ${wts_GNB3_CELL5_ADDR}
    Configure IP On VM    ip=${wts_GNB3_XN_ADDR}       interface=eth3
    Configure IP On VM    ip=${wts_GNB3_NG_ADDR}       interface=eth3
    Configure IP On VM    ip=${wts_GNB3_CELL3_ADDR}    interface=eth3
    Configure IP On VM    ip=${wts_GNB3_CELL4_ADDR}    interface=eth3
    Configure IP On VM    ip=${wts_GNB3_CELL5_ADDR}    interface=eth3


Update WTS File For TC CB008146E plmn1
    [Documentation]    [PRIVATE]    update wts cfg file for plmn1 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn1 ${mcc_SCF}:${mnc_SCF}
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load WTS CFG             ${wtsconfig}
    wts.Insert    set GNB_XN_ADDR="${wts_GNB_XN_ADDR}"   after   set GNB_NG_ADDR="${wts_GNB_XN_ADDR}"
    wts.Insert    set GNB3_XN_ADDR="${wts_GNB3_XN_ADDR}"   after    set GNB_XN_ADDR="${wts_GNB_XN_ADDR}"
    wts.Insert    set GNB3_NG_ADDR="${wts_GNB3_NG_ADDR}"   after    set GNB3_XN_ADDR="${wts_GNB3_XN_ADDR}"
    wts.Insert    set GNB3_CELL3_ADDR="${wts_GNB3_CELL3_ADDR}"   after   set GNB3_NG_ADDR="${wts_GNB3_NG_ADDR}"
    wts.Insert    set GNB3_CELL4_ADDR="${wts_GNB3_CELL4_ADDR}"   after   set GNB3_CELL3_ADDR="${wts_GNB3_CELL3_ADDR}"
    wts.Insert    set GNB3_CELL5_ADDR="${wts_GNB3_CELL5_ADDR}"   after   set GNB3_CELL4_ADDR="${wts_GNB3_CELL4_ADDR}"
    wts.Insert    set PLMN="310:260"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Modify    set_amf_region   	plmn=$PLMN
    wts.Modify    amf_param id=1   	nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    wts.Modify    set_gnb id=2    plmn=$PLMN gnb_id=0x1:22 plmnList=310:260,311:490 xn=$GNB_XN_ADDR
    wts.Insert    set_gnb id=3 type=simulated plmn=$PLMN ng=$GNB3_NG_ADDR gnb_id=0x26:22   after   set_cell id=1 gnb=2
    wts.Modify    set_gnb id=3    daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1
    wts.Modify    set_gnb id=3    plmnList=310:260,311:490 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=${fiveGsTac_SCF} nrci=0x01 tdd_cell=off   after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890
    wts.Modify    set_cell id=1 gnb=3   nr_arfcn=135600:126400 mandatory_for_activation=off gscn=1565
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
    wts.Modify    set_ue simulated id=81    suci=0:$PLMN:0000:0:0:021645081
    wts.Modify    set_ue simulated id=82    suci=0:$PLMN:0000:0:0:021645082
    wts.Modify    set_ue simulated id=83    suci=0:$PLMN:0000:0:0:021645083
    wts.Modify    set_ue simulated id=84    suci=0:$PLMN:0000:0:0:021645084
    FOR   ${cell_id}    IN RANGE   1   13
       ${nrci}    Convert To Hex   ${cell_id}   prefix=0x  length=2
       wts.Modify    set_cell id=${cell_id} gnb=2      nrci=${nrci}
    END

    wts.Modify    ue_param id=81    ue_nr_capabilities=${cap81}
    wts.Modify    ue_param id=82    ue_nr_capabilities=${cap82}
    wts.Modify    ue_param id=83    ue_nr_capabilities=${cap83} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=84    ue_nr_capabilities=${cap84}

    FOR   ${id}   IN RANGE   2   21
       wts.Delete    set_nwslice id=${id}
    END

    wts.Modify    set_nwslice id=1    ue=all
    wts.Insert    set_nwslice id=2 snssai=0x01:0xD143A6 ue=83 amf=1    after   set_nwslice id=1

    wts.Modify    debug_log     level=0
    wts.Modify    sim_debug_log level=4 mme=1      level=1
    wts.Modify    sim_debug_log level=4 uec=1      level=1
    wts.Modify    sim_debug_log level=4 pgw=1      level=1
    wts.Modify    sim_debug_log level=4 sgw=1      level=1

    wts.Delete    trace enb=1 protocol=x2 on
    wts.Delete    trace uec=1 protocol=x2 on

    wts.Save WTS CFG              ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg


Update WTS File For TC CB008146E plmn2
    [Documentation]    [PRIVATE]    update wts cfg file for plmn2 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn2 311:490
    wts.Load WTS CFG             ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg
    wts.Delete    set PLMN="310:260"
    wts.Insert    set PLMN="311:490"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Save WTS CFG              ${resultBaseDir}/basic_wts_CB008146E_plmn2.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008146E_plmn2.cfg


Update WTS File For TC CB008146E plmn1 voice
    [Documentation]    [PRIVATE]    update wts cfg file for plmn1 voice usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn1 voice
    wts.Load WTS CFG             ${resultBaseDir}/basic_wts_CB008146E_plmn1.cfg
    wts.Modify    set_qosflow id=5     5qi=5 default=on
    wts.Modify    set_qosflow id=6     5qi=1 default=off
    wts.Modify    set_qosflow id=1     5qi=6 default=off
    wts.Save WTS CFG              ${resultBaseDir}/basic_wts_CB008146E_plmn1_voice.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008146E_plmn1_voice.cfg


Load WTS File
    [Documentation]    [PRIVATE]    load wts file for special configuration
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${file_usage}
    Run Keyword   Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_CB008146E_${file_usage}.cfg


Check WTS In Active State
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    Check WTS State
    Log To Console    check if wts in active state ended


check WTS State
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate

