*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB005876_B1

Library     taf.config.wts        WITH NAME    wts_conf

Resource          ../resources/SQD65/sqd65_keywords.robot

*** Variables ***
${ue_nr_capabilities}=  SEPARATOR=
...   E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A362
...   66B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C001
...   3C002A36276B04050D012CB2898087AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C000
...   0000000001CA9A0002000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40

@{CB005876_NRCELL_PM}
...    M55124C02001    ==    1    Number of Inter-Rat B2 measurement received

@{CB005876_NRBTS_PM}
...    M55337C00005    >=    1    DL_FW_SDU_SNT_PDUSES_QOS_05
...    M55337C00006    >=    1    DL_FW_SDU_SNT_PDUSES_QOS_06
...    M55337C01005    >=    1    DL_FW_VOL_SNT_PDUSES_QOS_05
...    M55337C01006    >=    1    DL_FW_VOL_SNT_PDUSES_QOS_06
...    M55337C00001    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_01
...    M55337C00002    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_02
...    M55337C00003    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_03
...    M55337C00004    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_04
...    M55337C00007    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_07
...    M55337C00008    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_08
...    M55337C00009    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_09
...    M55337C00010    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_10
...    M55337C00011    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_11
...    M55337C00012    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_12
...    M55337C00013    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_13
...    M55337C00014    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_14
...    M55337C00015    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_15
...    M55337C00016    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_16
...    M55337C00017    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_17
...    M55337C00018    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_18
...    M55337C00019    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_19
...    M55337C00020    ==    0    DL_FW_SDU_SNT_PDUSES_QOS_20
...    M55337C01001    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_01
...    M55337C01002    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_02
...    M55337C01003    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_03
...    M55337C01004    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_04
...    M55337C01007    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_07
...    M55337C01008    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_08
...    M55337C01009    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_09
...    M55337C01010    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_10
...    M55337C01011    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_11
...    M55337C01012    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_12
...    M55337C01013    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_13
...    M55337C01014    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_14
...    M55337C01015    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_15
...    M55337C01016    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_16
...    M55337C01017    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_17
...    M55337C01018    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_18
...    M55337C01019    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_19
...    M55337C01020    ==    0    DL_FW_VOL_SNT_PDUSES_QOS_20

*** Keywords ***

Collect and verify PM counters
    ${PM_dir}=    Collect PM Counter
    Verify PM Counter Reference Table     reference_table=${CB005876_NRCELL_PM}  pm_dir=${PM_dir}  distname_suffix=NRCELL-1
    Verify PM Counter Reference Table     reference_table=${CB005876_NRBTS_PM}  pm_dir=${PM_dir}  distname_suffix=NRBTS-1


Prepare WTS Config
    wts_conf.load_wts_cfg    file_path=${tl.core.dir_path}/basic_setup.cfg
    FOR   ${command}       ${id}      IN
    ...   set_enb          id=1
    ...   enb_param        id=1
    ...   set_cell         id=1 enb=1
    ...   enb_endc_param   id=1
    ...   mme_pool_area    id=1
    ...   set_mme          id=1
    ...   set_sgw          id=1
    ...   set_pgw          id=1
          wts_conf.delete  ${command} ${id}
    END
    wts_conf.insert    set ENB1_S1U_ADDR="10.0.1.136"  before  set_amf_region id=1
    wts_conf.modify    set_amf_region id=1     modification=tac_list=7627107,100,788,0,222,200
    wts_conf.modify    amf_param id=1          modification=indirect_data_forwarding=on ims_voice_3gpp=on
    wts_conf.modify    set_cell id=1 gnb=2    modification=tac=0
    wts_conf.insert    set_gnb id=1 type=simulated plmn=311:489 ng=$ENB1_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ...  after  set_cell id=1 gnb=2
    wts_conf.insert    set_cell id=1 gnb=1 pci=3:2 earfcn=1:18001 tac=222 proxy=$SERVER_IP:12219 nrci=0x1 tdd_cell=on  after  set_gnb id=1
    wts_conf.modify    set_cell id=1 gnb=1    modification=bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert    gnb_param id=1 xn_listening_socket=off  after  set_cell id=1 gnb=1
    wts_conf.modify    ue_param id=1    modification=ue_nr_capabilities=${ue_nr_capabilities}
    wts_conf.insert    ue_param id=1 dual_conn=eutra_nr  after  ue_param id=1
    wts_conf.insert    ue_param id=1 nr_usage_setting=voice_centric  after  ue_param id=1
    wts_conf.modify    qosflow_set id=1    modification=5qi=5
    wts_conf.modify    set_qosflow id=2    modification=5qi=1
    wts_conf.modify    set_qosflow id=3    modification=5qi=2
    wts_conf.insert    set_qosflow id=4 5qi=6  after  set_qosflow id=3
    wts_conf.delete    set_qosrule id=1
    wts_conf.delete    set_qosrule id=2
    wts_conf.insert    set_qosrule id=1 proto=udp qos_flow=1  after  set_qosflow id=4
    wts_conf.insert    set_qosrule id=2 proto=udp qos_flow=2  after  set_qosrule id=1
    wts_conf.insert    set_qosrule id=3 proto=udp qos_flow=3  after  set_qosrule id=2
    wts_conf.insert    set_qosrule id=4 proto=udp qos_flow=4  after  set_qosrule id=3
    wts_conf.delete    set_pdu_gateway id=2
    wts_conf.insert    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=1
    wts_conf.modify    nwslice_set id=1    modification=qos_flows=1,2,3,4 qos_rules=1,2,3,4
    FOR   ${command}    ${id}        IN
    ...   uec_param      id=1 reordering_window_size=1000
    ...   sim_debug_log  level=4 mme=1
    ...   sim_debug_log  level=4 uec=1
    ...   sim_debug_log  level=4 pgw=1
    ...   sim_debug_log  level=4 sgw=1
          wts_conf.delete   ${command} ${id}
    END
    wts_conf.modify    set_log    modification=max_file_num=10
    wts_conf.save_wts_cfg    file_path=${tl.core.dir_path}/basic_setup_5876_new.cfg


Delete NSA UE
    [Arguments]  ${ue_id}=11
    FOR   ${command}         ${id}        IN
    ...   set_ue simulated   id=${ue_id}
    ...   ue_param           id=${ue_id}
    ...   set_pdu_gateway    id=${ue_id}
    ...   set_bearer id=2    ue=${ue_id}
          wts_conf.delete    ${command} ${id}
    END


Start data traffic on 2 PDU sessions
    FOR   ${trf_id}    ${pdu}    ${qfi}          IN
    ...   1            1         1
    ...   2            1         2
    ...   3            1         3
    ...   1            2         1
    ...   2            2         2
          Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=${trf_id}   pdu=${pdu}   qfi=${qfi}   mbps=2
    END

Stop data traffic on 2 PDU sessions
    FOR   ${trf_id}    ${pdu}    ${qfi}          IN
    ...   1            1         1
    ...   2            1         2
    ...   3            1         3
    ...   1            2         1
    ...   2            2         2
          Stop data traffic in egate   ue_id=1   direction=dl   trf_id=${trf_id}   pdu=${pdu}   qfi=${qfi}
    END

Trigger inter-RAT Handover
    Send Egate Command and verify output   ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Sleep   3s
    ${meas_id}=    Get Measurement id    event_type=B2
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11
    ...   nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Send Egate Command and verify output   ${cmd}   pass_regexp=Received HandoverNotify

Get Measurement id
    [Arguments]  ${event_type}  ${ue_id}=1
    ${measurements}=    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event_type}
    ${matching_lines}=  Get Lines Containing String  ${measurements}  Event${event_type}
    ${first_line}=  Get Line  ${matching_lines}  0
    @{words}=  Split String  ${first_line}
    RETURN  ${words}[0]
