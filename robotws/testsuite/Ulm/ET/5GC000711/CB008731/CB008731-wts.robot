*** Settings ***
Documentation   This is a keyword file for CB008731, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library     taf.config.wts     WITH NAME    wts

*** Variables ***
${t1_cap}    SEPARATOR=
...          E1A00380474E5A031E000383A000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261A007AD8202020E1DE38720C380020
...          64F1F570004F001C0013C002A36266B04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89BAC10143404
...          B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB28986801EB608080838778E1C830E0008193C
...          7D54000014000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801
...          A55542C007000B00000004008011AB130001020304050607080B101112131921252627284A32D0

${t2_t3_t6_t8_t9_cap}    SEPARATOR=
...                      e1a00000074e5a031e000380a03c1260c80008780818806804c020301c032a36146b04050d012cb2898087ad8202020e1de38720c38002064f1
...                      f570004f001c0013c002a36266b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a3626eb04050d012cb289
...                      8087ad8202020e1de38720c38002064f1f570004f001c0013c002a36276b04050d012cb2898087ad8202020e1de38720c38002064f1f5500000
...                      5000000108389a00000000404d0103804044f60701800140e020381801c07000683e0000000000000e54d000100000965950034aaa8081c002c
...                      000000100200462c4c0004080c1014181c202c4044484c648494989ca128

${t4_t5_cap}    SEPARATOR=
...             E1A00000074E5A031E000382A003C1260C80008783803100D0098040603806546C28D6080A1A025965130701EB608080838778E1C830E000819
...             3C7D5C0013C0070004F000A8D899AC10143404B2CA260E03D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582028680965
...             944C1C07AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898380F5B0404041C3BC70E418700040C9E3EAA
...             00000A000000210713400000000809A16003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA8
...             4801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA128CB4

*** Keywords ***
Update wts file for TC CB008731 common part
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts common part
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert  set GNB_XN_ADDR="10.0.1.2"    after    set GNB_NG_ADDR="10.0.1.2"
    wts.Insert  set GNB4_NG_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert  set GNB4_S1_ADDR="10.0.1.4"   after    set GNB4_NG_ADDR="10.0.1.3"
    wts.Insert  set GNB4_XN_ADDR="10.0.1.5"   after    set GNB4_S1_ADDR="10.0.1.4"

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

    wts.Insert  set_gnb id=4 type=simulated plmn=311:489 ng=$GNB4_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT     after   set_cell id=2 gnb=2
    wts.Modify  set_gnb id=4   gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none xn=$GNB4_XN_ADDR
    wts.Insert  set_cell id=1 gnb=4 pci=3:2 earfcn=2000:20000 tac=200 proxy=$GNB4_NG_ADDR:12219 nrci=0x1     after   set_gnb id=4
    wts.Modify  set_cell id=1 gnb=4   tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts.Insert  gnb_param id=4 xn_listening_socket=1 send_xn_setup=false     after   set_cell id=1 gnb=4

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

    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg


Update wts file for TC CB008731 voice t1
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 voice t1
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t1_cap} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t1_cap} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t1_cap} nr_usage_setting=voice_centric

    wts.Modify    set_qosflow id=1     5qi=5 default=on
    wts.Modify    set_qosflow id=2     5qi=1 default=off
    wts.Modify    set_qosflow id=3     5qi=2 default=off
    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t1.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t1.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t1.cfg


Update wts file for 8731 t2
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 t2
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}

    wts.Modify    set_qosflow id=1    priority=1
    wts.Modify    set_qosflow id=2    priority=2
    wts.Modify    set_qosflow id=3    priority=3
    wts.Insert    set_qosflow id=4 5qi=7 priority=4   after   set_qosflow id=3
    wts.Insert    set_qosflow id=5 5qi=8 priority=6   after   set_qosflow id=4
    wts.Insert    set_qosflow id=6 5qi=9 priority=5   after   set_qosflow id=5
    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4,5,6
    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t2.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t2.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t2.cfg


Update wts file for 8731 t3
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 t3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}

    wts.Modify    set_qosflow id=1    priority=6 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    wts.Modify    set_qosflow id=2    priority=2 pci=may_trigger_pre_emption pvi=not_pre_emptable
    wts.Modify    set_qosflow id=3    priority=1 pci=may_trigger_pre_emption pvi=not_pre_emptable
    wts.Insert    set_qosflow id=4 5qi=7 priority=5 pci=may_trigger_pre_emption pvi=not_pre_emptable   after   set_qosflow id=3
    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4
    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t3.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t3.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t3.cfg


Update wts file for TC CB008731 voice t4
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 voice t4
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t4_t5_cap} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t4_t5_cap} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t4_t5_cap} nr_usage_setting=voice_centric

    wts.Modify    set_qosflow id=1     5qi=5 default=on
    wts.Modify    set_qosflow id=2     5qi=1 default=off
    wts.Modify    set_qosflow id=3     5qi=2 default=off
    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t4.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t4.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t4.cfg


Update wts file for TC CB008731 voice t5
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 t5
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t4_t5_cap} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t4_t5_cap} nr_usage_setting=voice_centric
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t4_t5_cap} nr_usage_setting=voice_centric

    wts.Modify    set_qosflow id=1    5qi=5
    wts.Modify    set_qosflow id=2    5qi=1 gfbr_ul=800 gfbr_dl=800 mfbr_ul=1000 mfbr_dl=1000 priority=15 qos_flow_type=gbr ue=all
    wts.Modify    set_qosflow id=3    5qi=2 gfbr_ul=24000 gfbr_dl=24000 mfbr_ul=30000 mfbr_dl=30000 priority=15 qos_flow_type=gbr ue=all
    wts.Insert    set_qosflow id=4 5qi=71 gfbr_ul=8000 gfbr_dl=8000 mfbr_ul=10000 mfbr_dl=10000       after   set_qosflow id=3
    wts.Modify    set_qosflow id=4    priority=15 qos_flow_type=gbr ue=all
    wts.Modify    set_qosrule id=1    qos_flow=1
    wts.Modify    set_qosrule id=2    qos_flow=2
    wts.Insert    set_qosrule id=3 proto=udp qos_flow=3   after   set_qosrule id=2
    wts.Insert    set_qosrule id=4 proto=tcp qos_flow=4   after   set_qosrule id=3
    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4 qos_rules=1,2,3,4
    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t5.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t5.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t5.cfg


Update wts file for TC CB008731 t6
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 t6
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}

    wts.Modify    set_cell id=2 gnb=2     nr_arfcn=647666:647666 gscn=7995
    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t6.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t6.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t6.cfg


Update wts file for TC CB008731 t8
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 t8
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}

    wts.Modify    amf_param id=1 ims_voice_3gpp=on 	indirect_data_forwarding=on

    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t8.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t8.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t8.cfg


Update wts file for TC CB008731 t9
    [Documentation]    [PRIVATE]    update wts cfg file for CB008731 t9
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_CB008731_common_updates.cfg

    wts.Modify    ue_param id=1    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=2    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}
    wts.Modify    ue_param id=3    ue_nr_capabilities=${t2_t3_t6_t8_t9_cap}

    wts.Modify    amf_param id=1 ims_voice_3gpp=on 	indirect_data_forwarding=on
    wts.Insert    set_qosflow id=4 5qi=7   after   set_qosflow id=3
    wts.Insert    set_qosflow id=5 5qi=8   after   set_qosflow id=4
    wts.Insert    set_qosflow id=6 5qi=9   after   set_qosflow id=5
    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4,5,6

    wts.Save wts cfg              ${resultDir}/basic_wts_CB008731_t9.cfg
    Log To Console    wts cfg saved as ${resultDir}/basic_wts_CB008731_t9.cfg
    Upload Customized WTS Config    config_path=${resultDir}/basic_wts_CB008731_t9.cfg
