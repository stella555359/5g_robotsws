*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library     taf.config.wts     WITH NAME    wts

*** Variables ***
${cap_voice}    SEPARATOR=
...             E1A00000074E5A031E000382A003C1260C80008783803100D0098040603806546C28D6080A1A025965130701EB608080838778E1C830E000819
...             3C7D5C0013C0070004F000A8D899AC10143404B2CA260E03D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582028680965
...             944C1C07AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898380F5B0404041C3BC70E418700040C9E3EAA
...             00000A000000210713400000000809A16003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA8
...             4801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA128CB4

${cap_ca}       SEPARATOR=
...             E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C4
...             71E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E238F189
...             1C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F
...             28581C0E1E0B801FF800E007FE00078001C0A836236B04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FF
...             C00001FFF000000F0003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F
...             13400389A0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E2300071180
...             0001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001
...             058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C0410B42EC1F0A244D8E7C3851226C73E1C28913639F0E14
...             489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0448102
...             06C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187FAAAAA826007C005038280381804A00E000C0580080C070500703E0900
...             2000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C01000800000020000200100
...             0012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652
...             504000065949410000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A9652
...             4040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012A050281
...             40A05028140A05028140A05028140A0502800304040300601002004202004010080100420100200404030060100C018202018030080600C2010
...             02004040300601002004402018030080600C0201803040400802010020086AC7C0004080C10181C282C30344044484C5060646C70747C849498
...             9CA0A4A8B4BD05D55555554982D0



*** Keywords ***

Update wts file for TC 711A voice
    [Documentation]    [PRIVATE]    update wts cfg file for 711-A voice TC
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_711A.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${cap_voice} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=2    ue_nr_capabilities=${cap_voice} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=3    ue_nr_capabilities=${cap_voice} nr_usage_setting=voice_centric
    wts.Modify    set_qosflow id=1     5qi=5 default=on
    wts.Modify    set_qosflow id=2     5qi=1 default=off
    wts.Modify    set_qosflow id=3     5qi=2 default=off
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_711A_voice.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_711A_voice.cfg


Update wts file for TC 711A 2gnb
    [Documentation]    [PRIVATE]    update wts cfg file for 711-A t8
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_711A.cfg
    wts.Insert    set GNB3_XN_ADDR="10.0.1.6"   after    set GNB4_XN_ADDR="10.0.1.5"
    wts.Insert    set GNB3_NG_ADDR="10.0.1.7"   after    set GNB3_XN_ADDR="10.0.1.6"

    wts.Insert   set_gnb id=3 type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x26:28 daemon=$DAEMON_IP:$DAEMON_PORT  after  set_cell id=2 gnb=2
    wts.Modify   set_gnb id=3    x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert   set_cell id=1 gnb=3 pci=16:0 tac=100 nrci=0x01 tdd_cell=on proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890   after  set_gnb id=3
    wts.Modify   set_cell id=1 gnb=3    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    wts.Insert   set_cell id=2 gnb=3 pci=16:1 tac=788 nrci=0x02 tdd_cell=on proxy=$GNB3_XN_ADDR:9999|$GNB3_NG_ADDR:8891   after  set_cell id=1 gnb=3
    wts.Modify   set_cell id=2 gnb=3    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    wts.Insert   gnb_param id=3 xn_listening_socket=1 send_xn_setup=false   after    set_cell id=2 gnb=3
    wts.Insert   gnb_make_plmnset dual_conn=off gnb=3 cell=1 plmn_set_id=1 tac=100 plmn_id_list=311:489   after    gnb_param id=3
    wts.Insert   gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x1:0xd143a5   after    gnb_make_plmnset
    wts.Insert   gnb_make_plmnset dual_conn=off gnb=3 cell=2 plmn_set_id=1 tac=788 plmn_id_list=311:489   after    gnb_set_nwslice_per_plmn
    wts.Insert   gnb_set_nwslice_per_plmn gnb=3 cell=2 plmn_set_id=1 plmn=311:489 nssai=0x1:0xd143a5
    ...   after    gnb_make_plmnset dual_conn=off gnb=3 cell=2
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_711A_2gnb.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_711A_2gnb.cfg


Update wts file for TC 711A 2bands
    [Documentation]    [PRIVATE]    update wts cfg file for 711-A t15
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_711A.cfg
    wts.Modify    set_cell id=2 gnb=2   nr_arfcn=508020:508020 gscn=6351
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_711A_2bands.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_711A_2bands.cfg


Update wts file for TC 711A ca
    [Documentation]    [PRIVATE]    update wts cfg file for 711-A t16, t17
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_711A.cfg
    wts.Modify    set_cell id=1 gnb=2   nr_arfcn=636666:636666 gscn=7880
    wts.Modify    set_cell id=2 gnb=2   nr_arfcn=647666:647666 gscn=7995

    wts.Modify    ue_param id=1    ue_nr_capabilities=${cap_ca}
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_711A_ca.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_711A_ca.cfg
