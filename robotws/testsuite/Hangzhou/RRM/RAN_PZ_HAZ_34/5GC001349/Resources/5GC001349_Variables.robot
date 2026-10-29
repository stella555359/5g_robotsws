*** Settings ***
Documentation    Common variables for 1349-BC feature

*** Variables ***
##SCF
${BTS_ID}                                ${tl.gnbs[0].instance_id}
${SWCONFIG_DEFAULT_FILE_PATH}            /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${BTS_ID}.txt
${RECOVERY_TIMEOUT}                      1000
${SCF_DEFAULT_FILE_PATH}                 /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${BTS_ID}.xml
${RECOVERY_TIMEOUT_cell}                 150

##x2log
${X2_LIST}               .//nr-rrc.initialUplinkBWP_element/nr-rrc.rach_ConfigCommon
${X2_ELEMENT}            /nr-rrc.setup_element/nr-rrc.rach_ConfigGeneric_element/nr-rrc.prach_ConfigurationIndex
${X2_COMMANPATH}         ${X2_LIST}/${X2_ELEMENT}
${X2_LIST_RSI}           .//nr-rrc.initialUplinkBWP_element/nr-rrc.rach_ConfigCommon
${X2_ELEMENT_RSI}        /nr-rrc.setup_element/nr-rrc.prach_RootSequenceIndex
${X2_COMMANPATH_RSI}     ${X2_LIST_RSI}/${X2_ELEMENT_RSI}
${LUA_SCRIPT_PATH}       /home/ute/luashark_script/generated_luashark/luashark.lua
#${luashark_trunk}        /home/ute/luashark/luashark_script/generated_luashark/luashark.luashark
${luashark_trunk}        /home/ute/luashark_script/generated_luashark/luashark.lua
${luashark_21A}          /home/ute/luashark_script/generated_luashark/luashark.lua
${luashark_path}         /home/ute/luashark_script/generated_luashark/luashark.lua
${X2AP_COMMAND_counter}    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${msg_delete}\" -T pdml
${X2AP_COMMAND_SA_254}        {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${msg}\" -T pdml
${X2AP_COMMAND_SA_49}     {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${msg_49}\" -T pdml
${X2AP_COMMAND_SA_255}     {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${msg_255}\" -T pdml
${TSHARK_PATH}           /usr/bin/tshark
${X2AP_COMMAND_NSA}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${E1AP_COMMAND}          {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
${S1AP_COMMAND}          {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml

##check point
${PRACH_INDEX_0_EXP}                           0
${PRACH_INDEX_1_EXP}                           1
${PRACH_INDEX_2_EXP}                           2
${PRACH_INDEX_3_EXP}                           3
${PRACH_INDEX_4_EXP}                           4
${PRACH_INDEX_5_EXP}                           5
${PRACH_INDEX_6_EXP}                           6
${PRACH_INDEX_7_EXP}                           7
${PRACH_INDEX_9_EXP}                           9
${PRACH_INDEX_12_EXP}                          12
${PRACH_INDEX_14_EXP}                          14
${PRACH_INDEX_17_EXP}                          17
${PRACH_INDEX_19_EXP}                          19
${PRACH_INDEX_97_EXP}                          97
${PRACH_INDEX_98_EXP}                          98
${RSI_exp_short}                             prach-RootSequenceIndex: l139 (1)
${RSI_exp_long}                             prach-RootSequenceIndex: l839 (0)
${MSG1_MSG2_MSG3}   (uldata_prachreceiveind||uldata_puschreceiveresplo||dldata_pdschpayloadtbsendreq
${delete_65535}     ||(dldata_pdcchsendreq&& (DlData_PdcchSendReq.dciInfo_item_15.rnti == 0x63)))
${msg_delete}            ${MSG1_MSG2_MSG3}${delete_65535}
${ATTACH_KPI_EXP}                              0.03
${RETRY_TIME}                                  3
${RETRY_TIME_KPI}                              34.0
${msg}                                 dldata_pdschpayloadtbsendreq && (nr-rrc.hoppingId == 254)
${msg_49}                              dldata_pdschpayloadtbsendreq && (nr-rrc.hoppingId == 191)
${msg_255}                             dldata_pdschpayloadtbsendreq && (nr-rrc.hoppingId == 936)
${asib_interface}                      eths3
