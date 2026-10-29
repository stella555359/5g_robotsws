*** Variables ***
${SCF_path}    /home/ute/TAF/zyy/
${SCF_file_name_2}       gNB2_6112_common.xml
${epc_log_path}       /tmp/
${localFilePath_swconfig_6112_B_16}    /home/ute/TAF/zyy/gNB2_6112_B_16_SW/swconfig.txt
${localFilePath_swconfig_6112}         /home/ute/TAF/zyy/gNB2_6112_SW/swconfig.txt
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${coam2_addr}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${coam2_username}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${coam2_password}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
#A01
${a01interface1}    any
${a01nglogname1}    6112_A_01_UE1_attach.pcap
${a01nglogname2}    6112_A_01_UE2_attach.pcap
${a01nglogname3}    6112_A_01_UE2_call1.pcap
${a01nglogname4}    6112_A_01_UE2_call2.pcap
@{a01gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a01value1}    5    7
@{a01gnb_filter2}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a01value2}    5    7
@{a01gnb_filter3}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{a01gnb_filter4}    ngap.procedureCode == 26 and ngap.fiveQI == 1
#A07
${a07interface1}    any
${a07nglogname1}    6112_A_07_UE1_attach.pcap
${a07nglogname2}    6112_A_07_UE2_attach.pcap
${a07nglogname3}    6112_A_07_UE2_call1.pcap
${a07nglogname4}    6112_A_07_UE2_call2.pcap
@{a07gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a07value1}    5    7
@{a07gnb_filter2}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a07value2}    5    7
@{a07gnb_filter3}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{a07gnb_filter4}    ngap.procedureCode == 26 and ngap.fiveQI == 1
#A09
${a09interface1}    any
${a09nglogname1}    6112_A_09_UE1_attach.pcap
${a09nglogname2}    6112_A_09_UE2_attach.pcap
${a09nglogname3}    6112_A_09_UE2_call1.pcap
${a09nglogname4}    6112_A_09_UE2_call2.pcap
${a09nglogname5}    6112_A_09_UE2_call3.pcap
@{a09gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a09value1}    5    7
@{a09gnb_filter2}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a09value2}    5    7
@{a09gnb_filter3}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{a09gnb_filter4}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{a09gnb_filter5}    ngap.procedureCode == 26 and ngap.fiveQI == 1
#A11
${a11interface1}    any
${a11nglogname1}    6112_A_11_attach.pcap
${a11nglogname2}    6112_A_11_call.pcap
@{a11gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a11value1}    5    7
@{a11gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{a11gnb_filter3}    e1ap.discardTimer == 1
@{a11xpath3}    e1ap.discardTimer
@{a11value3}    1
#B16
${b16interface1}    any
${b16nglogname1}    6112_B_16_UE1.pcap
${b16nglogname2}    6112_B_16_UE2.pcap
@{b16gnb_filter1}    e1ap.procedureCode == 8 and e1ap.id == 16 and e1ap.transportLayerAddressIPv6
...               e1ap.procedureCode == 9 and e1ap.id == 19 and e1ap.transportLayerAddressIPv6
...               e1ap.procedureCode == 9 and e1ap.id == 19 and e1ap.transportLayerAddressIPv6
@{b16xpath1}    e1ap.transportLayerAddressIPv6    e1ap.transportLayerAddressIPv6    e1ap.transportLayerAddressIPv6
@{b16value1}    5    0    0
@{b16gnb_filter2}    e1ap.procedureCode == 8 and e1ap.id == 16 and e1ap.transportLayerAddressIPv6
...               e1ap.procedureCode == 9 and e1ap.id == 19 and e1ap.transportLayerAddressIPv6
...               e1ap.procedureCode == 9 and e1ap.id == 19 and e1ap.transportLayerAddressIPv6
@{b16xpath2}    e1ap.transportLayerAddressIPv6    e1ap.transportLayerAddressIPv6    e1ap.transportLayerAddressIPv6
@{b16value2}    5    1    1
#C03
${c03interface1}    any
${c03nglogname1}    6112_C_03_attach.pcap
${c03nglogname2}    6112_C_03_call.pcap
@{c03gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c03value1}    5    7
@{c03gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
#C10
${c10interface1}    any
${c10nglogname1}    6112_C_10_attach.pcap
${c10nglogname2}    6112_C_10_call.pcap
@{c10gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c10value1}    5    7
@{c10gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
#A14
${a14interface1}    any
${a14nglogname1}    6112_A_14_attach.pcap
${a14nglogname2}    6112_A_14_call.pcap
@{a14gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a14gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{a14gnb_filter3}    f1ap.procedureCode == 7 and nr-rrc.t310 == 8     f1ap.procedureCode == 7 and nr-rrc.n310 == 7
...               f1ap.procedureCode == 7 and nr-rrc.n311 == 0     f1ap.procedureCode == 7 and nr-rrc.t311_v1530 == 6
@{a14gnb_filter4}    e1ap.procedureCode == 9 and e1ap.pDCP_SN_Size_UL == 1      e1ap.procedureCode == 9 and e1ap.pDCP_SN_Size_DL == 1
...               e1ap.procedureCode == 9 and e1ap.dRB_Inactivity_Timer == 30      e1ap.procedureCode == 9 and e1ap.discardTimer == 7
@{a14gnb_filter5}    f1ap.procedureCode == 7 and nr-rrc.rlc_Config == 1 and nr-rrc.sn_FieldLength == 0
@{a14value1}    5    7
@{a14value3}    8    7    0    6
@{a14value4}    1    1    30    7
@{a14value5}    0
#A16
${a16interface1}    any
${a16nglogname1}    6112_A_16_attach.pcap
${a16nglogname2}    6112_A_16_reattach.pcap
@{a16gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{a16gnb_filter2}    e1ap.procedureCode == 8 or e1ap.procedureCode == 9 and e1ap.dRB_Inactivity_Timer == 15
@{a16gnb_filter3}    e1ap.procedureCode == 8 or e1ap.procedureCode == 9 and e1ap.dRB_Inactivity_Timer == 150
@{a16value1}    5    7
@{a16value2}    15
@{a16value3}    150
#B08
${b08interface1}    any
${b08nglogname1}    6112_B_08_attach_on_cell2.pcap
${b08nglogname2}    6112_B_08_vonrcall_on_cell2.pcap
${b08nglogname3}    6112_B_08_vonrho_to_cell1.pcap
@{b08gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{b08value1}    5    7
@{b08gnb_filter2}    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1
...               f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1
@{b08xpath2}    nr-rrc.drx_LongCycleStartOffset    nr-rrc.drx_InactivityTimer    nr-rrc.drx_RetransmissionTimerDL
@{b08value2}    3    6    0
@{b08gnb_filter3}    f1ap.id == 119
@{b08xpath3}    nr-rrc.rrc_TransactionIdentifier
@{b08value3}    0
@{b08gnb_filter4}    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1
...               f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1
@{b08xpath4}    nr-rrc.drx_LongCycleStartOffset    nr-rrc.drx_InactivityTimer    nr-rrc.drx_RetransmissionTimerDL
@{b08value4}    1    4    0
#B15
${b15interface1}    any
${b15nglogname1}    6112_B_15_attach_on_cell2.pcap
${b15nglogname2}    6112_B_15_vonrcall1_on_cell2.pcap
${b15nglogname3}    6112_B_15_vonrcall2_on_cell2.pcap
@{b15gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{b15value1}    5    7
@{b15gnb_filter2}    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1
@{b15xpath2}    nr-rrc.drx_LongCycleStartOffset
@{b15value2}    Nothing
@{b15gnb_filter3}    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1
...               f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1
@{b15xpath3}    nr-rrc.drx_LongCycleStartOffset    nr-rrc.drx_InactivityTimer    nr-rrc.drx_RetransmissionTimerDL
@{b15value3}    3    6    0
#C08
${c08interface1}    any
${c08nglogname1}    6112_C_08_UE1_call_suc.pcap
${c08nglogname2}    6112_C_08_UE2_call_fail.pcap
@{c08gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c08gnb_filter2}    ngap.procedureCode == 26 and ngap.radioNetwork == 22
@{c08value1}    5    7
@{c08value2}    22
#C09
${c09interface1}    any
${c09nglogname1}    6112_C_09_UE1_call_suc.pcap
${c09nglogname2}    6112_C_09_UE2_call_fail.pcap
@{c09gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c09gnb_filter2}    ngap.procedureCode == 26 and ngap.radioNetwork == 22
@{c09value1}    5    7
@{c09value2}    22
#C12
${c12interface1}    any
${c12nglogname1}    6112_C_12_attach_on_cell2.pcap
${c12nglogname2}    6112_C_12_A2config_cell2.pcap
${c12nglogname3}    6112_C_12_A1A3A5config_cell2.pcap
${c12nglogname4}    6112_C_12_A2config2_cell2.pcap
@{c12gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c12value1}    5    7
@{c12gnb_filter2}    nr-rrc.c1 == 0 and nr-rrc.a2_Threshold == 0
@{c12xpath2}    nr-rrc.rsrp
@{c12value2}    75
@{c12gnb_filter3}    nr-rrc.c1 == 0 and nr-rrc.a1_Threshold == 0    nr-rrc.c1 == 0 and nr-rrc.a3_Offset == 0
...               nr-rrc.c1 == 0 and nr-rrc.a5_Threshold1 == 1    nr-rrc.c1 == 0 and nr-rrc.a5_Threshold2 == 1
@{c12xpath3}    nr-rrc.rsrp    nr-rrc.rsrp    nr-rrc.rsrq    nr-rrc.rsrq
@{c12value3}    80    1    120    120
@{c12gnb_filter4}    nr-rrc.c1 == 0 and nr-rrc.a2_Threshold == 0
@{c12xpath4}    nr-rrc.rsrp
@{c12value4}    75
#C13
${c13interface1}    any
${c13nglogname1}    6112_C_13_attach_on_cell2.pcap
${c13nglogname2}    6112_C_13_vonrsetup_on_cell2.pcap
${c13nglogname3}    6112_C_13_vonrho_to_cell1.pcap
@{c13gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c13value1}    5    7
@{c13gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{c13gnb_filter3}    f1ap.id == 119
@{c13xpath3}    nr-rrc.rrc_TransactionIdentifier
@{c13value3}    0
#C19
${c19interface1}    any
${c19nglogname1}    6112_C_19_attach_on_cell2.pcap
${c19nglogname2}    6112_C_19_A2config_cell2.pcap
${c19nglogname3}    6112_C_19_A1B2config_cell2.pcap
${c19nglogname4}    6112_C_19_A2config2_cell2.pcap
@{c19gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c19value1}    5    7
@{c19gnb_filter2}    nr-rrc.c1 == 0 and nr-rrc.a2_Threshold == 0
@{c19xpath2}    nr-rrc.rsrp
@{c19value2}    75
@{c19gnb_filter3}    nr-rrc.c1 == 0 and nr-rrc.b2_Threshold1 == 0    nr-rrc.c1 == 0 and nr-rrc.b2_Threshold2EUTRA == 0
...               nr-rrc.c1 == 0 and nr-rrc.a1_Threshold == 0
@{c19xpath3}    nr-rrc.rsrp    nr-rrc.rsrp    nr-rrc.rsrp
@{c19value3}    60    60    80
@{c19gnb_filter4}    nr-rrc.c1 == 0 and nr-rrc.a2_Threshold == 0
@{c19xpath4}    nr-rrc.rsrp
@{c19value4}    75
#C20
${c20interface1}    any
${c20nglogname1}    6112_C_20_attach_on_cell2.pcap
${c20nglogname2}    6112_C_20_vonrsetup_on_cell2.pcap
${c20nglogname3}    6112_C_20_vonrho_to_lte.pcap
@{c20gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
@{c20value1}    5    7
@{c20gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
@{c20gnb_filter3}    ngap.HandoverType == 1
@{c20xpath3}    ngap.HandoverType
@{c20value3}    1
&{ct_path}   M55308C23001=CELLS/NRCELL-2/NCELA/PRB_USED_PUSCH_5QI1
...          M55308C23002=CELLS/NRCELL-2/NCELA/PRB_USED_PDSCH_5QI1
...          M55308C24001=CELLS/NRCELL-2/NCELA/DL_GRANTS_INIT_TX_5QI1
...          M55308C24002=CELLS/NRCELL-2/NCELA/UL_GRANTS_INIT_TX_5QI1
...          M55308C25001=CELLS/NRCELL-2/NCELA/UL_SCHED_DELAY_5QI1
...          M55308C25002=CELLS/NRCELL-2/NCELA/UL_SCHED_DELAY_5QI1_SAMPLES
...          M55309C11001=CELLS/NRCELL-2/NMSDU/UL_MAC_SDU_VOL_5QI1_PADDING
...          M55310C19001=CELLS/NRCELL-2/NLRLC/DL_RLC_PDU_5QI1_DISCARD_TIMER
...          M55302C00000=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_00
...          M55302C00001=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_01
...          M55302C00002=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_02
...          M55302C00003=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_03
...          M55302C00004=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_04
...          M55302C00005=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_05
...          M55302C00006=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_06
...          M55302C00007=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_07
...          M55302C00008=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_08
...          M55302C00009=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_09
...          M55302C00010=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_10
...          M55302C00011=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_11
...          M55302C00012=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_12
...          M55302C00013=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_13
...          M55302C00014=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_14
...          M55302C00015=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_15
...          M55302C00016=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_16
...          M55302C00017=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_17
...          M55302C00018=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_18
...          M55302C00019=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_19
...          M55302C00020=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_20
...          M55302C00021=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_21
...          M55302C00022=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_22
...          M55302C00023=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_23
...          M55302C00024=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_24
...          M55302C00025=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_25
...          M55302C00026=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_26
...          M55302C00027=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_27
...          M55302C00028=CELLS/NRCELL-2/NULHQ/PUSCH_CP_INITX_64TBL_MCS_28
...          M55138C01001=CELLS/NRCELL-2/RSACU/SA_GBR_DRB_REQ
...          M55138C01002=CELLS/NRCELL-2/RSACU/SA_GBR_DRB_SUCC
...          M55138C01004=CELLS/NRCELL-2/RSACU/SA_GBR_DRB_REL
...          M55139C00501=CELLS/NRCELL-2/RSADU/SA_DU_GBR_DRB_REQ
...          M55139C00502=CELLS/NRCELL-2/RSADU/SA_DU_GBR_DRB_SUCC
...          M55139C00509=CELLS/NRCELL-2/RSADU/SA_DU_GBR_DRB_REL
${int_time_list}    00/05/10/15/20/25/30/35/40/45/50/55
#set as 2DL2UL
${dl_throughput}    750M
${ul_throughput}    130M
#set as fddcell dl/ul peak tput 67M/35M
${dl_expected_throughput}    25
${ul_expected_throughput}    13
${duration}    600
${duration2}    600
${iperf_port}    58830
${deviation}    15

@{b08attenuation_1}   ${0}   ${0}   ${0}   ${0}
@{b08attenuation_2}   ${0}   ${0}   ${20}   ${20}
@{b08attenuation_3}   ${0}   ${0}   ${30}   ${30}
@{b08attenuation_4}   ${0}   ${0}   ${40}   ${40}
@{c12attenuation_1}   ${100}   ${100}   ${15}   ${15}
@{c12attenuation_2}   ${100}   ${100}   ${25}   ${25}
@{c12attenuation_3}   ${100}   ${100}   ${35}   ${35}
@{c13attenuation_1}   ${0}   ${0}   ${0}   ${0}
@{c13attenuation_2}   ${0}   ${0}   ${20}   ${20}
@{c13attenuation_3}   ${0}   ${0}   ${35}   ${35}
@{c13attenuation_4}   ${0}   ${0}   ${45}   ${45}
@{c19attenuation_1}   ${100}   ${100}   ${15}   ${15}
@{c19attenuation_2}   ${100}   ${100}   ${25}   ${25}
@{c19attenuation_3}   ${100}   ${100}   ${35}   ${35}
@{c20attenuation_1}   ${100}   ${100}   ${0}   ${0}
@{c20attenuation_2}   ${100}   ${100}   ${20}   ${20}
@{c20attenuation_3}   ${100}   ${100}   ${35}   ${35}
@{c20attenuation_4}   ${100}   ${100}   ${45}   ${45}

