*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB012971 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,05.08.2025,vadivelan.manickavasagam@nokia.com

*** Variables ***
${Log_Path}                        ${OUTPUT_DIR}
${TC_DIR_CB012971_A_02}            ${OUTPUT_DIR}/CB012971_A_TC_02_2UE_CORRELATION/
${TC_DIR_CB012971_A_04}            ${OUTPUT_DIR}/CB012971_A_TC_04_40Mhz_CORRELATION/
${TC_DIR_CB012971_A_06}            ${OUTPUT_DIR}/CB012971_A_TC_06_2symbo_SRS_CORRELATION/
${TC_DIR_CB012971_C_02}            ${OUTPUT_DIR}/CB012971_C_TC_00_4R2UE_PAIR/

${CFG_CB012971_A_TC_02_GNB_SCF}    ${CURDIR}/../../CB012971_A/config/SBTS26R1/CB012971_A_TC_02_GNB_SCF.xml
${CFG_CB012971_A_TC_04_GNB_SCF}    ${CURDIR}/../../CB012971_A/config/SBTS26R1/CB012971_A_TC_04_GNB_SCF_40Mhz.xml
${CFG_CB012971_C_TC_00_GNB_SCF}    ${CURDIR}/../../CB012971_C/config/SBTS26R1/CB012971_C_TC_02_GNB_SCF.xml

${CFG_CB012971_A_TC_02_IPHY}       ${CURDIR}/../../config/ap/CB012971_A_TC_02_IPHY.xml
${CFG_CB012971_A_TC_02_WTS}        ${CURDIR}/../../config/wts/CB012971_A_TC_02.cfg
${CFG_CB012971_A_TC_04_WTS}        ${CURDIR}/../../config/wts/CB012971_A_TC_04_chbw40Mhz.cfg

${BSR_FILE_CB012971_AVQL}          ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip

${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${FILTER_B005}                     uldata_puschreceiverespps || uldata_puschreceivereq
${BIP_CSV_NAME}                    BIP_L1L2_filter_SCN1.csv

${VAL_UL_SB_SRS_ENABLED}           ulCellUeSetupReq.payload().dlSubbandBeamforming().dlSubbandBfAct() 1
${VAL_UL_SB_SRS_SIZE_2}              dlSubbandBeamforming().bfSubbandSize() 2
${VAL_40Mhz_Carrier_BW}            carrierBandwidth 106

${VAL_UE2_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE
${VAL_SIB1}                        SystemInformationBlockType1-NR updated
${VAL_REG}                         Received REGISTRATION COMPLETE
${VAL_PDU_SESSION}                 Initial Context Setup Successful
${VAL_UE1_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE

${VAL_UE1_REG_COMPLETE}            AMF UE NGAP ID 1, UE now in NG RM Registered state
${VAL_UE2_REG_COMPLETE}            AMF UE NGAP ID 2, UE now in NG RM Registered state
${VAL_UE3_REG_COMPLETE}            AMF UE NGAP ID 3, UE now in NG RM Registered state
${VAL_UE4_REG_COMPLETE}            AMF UE NGAP ID 4, UE now in NG RM Registered state
${VAL_UE5_REG_COMPLETE}            AMF UE NGAP ID 5, UE now in NG RM Registered state
${VAL_UE6_REG_COMPLETE}            AMF UE NGAP ID 6, UE now in NG RM Registered state
${VAL_UE7_REG_COMPLETE}            AMF UE NGAP ID 7, UE now in NG RM Registered state
${VAL_UE8_REG_COMPLETE}            AMF UE NGAP ID 8, UE now in NG RM Registered state
${VAL_UE9_REG_COMPLETE}            AMF UE NGAP ID 9, UE now in NG RM Registered state
${VAL_UE10_REG_COMPLETE}           AMF UE NGAP ID 10, UE now in NG RM Registered state

${VAL_UE1_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 1
${VAL_UE2_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 2
${VAL_UE3_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 3
${VAL_UE4_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 4
${VAL_UE5_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 5
${VAL_UE6_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 6
${VAL_UE7_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 7
${VAL_UE8_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 8
${VAL_UE9_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 9
${VAL_UE10_PDU_SESSION}            Initial Context Setup Successful for UE with AMF UE ID 10

${CM_UE_1_DL_STATS}                ue_stats_nr id=1 type=pdsch
${CM_UE_2_DL_STATS}                ue_stats_nr id=2 type=pdsch
${CM_UE_3_DL_STATS}                ue_stats_nr id=3 type=pdsch
${CM_UE_4_DL_STATS}                ue_stats_nr id=4 type=pdsch
${CM_UE_5_DL_STATS}                ue_stats_nr id=5 type=pdsch
${CM_UE_6_DL_STATS}                ue_stats_nr id=6 type=pdsch
${CM_UE_7_DL_STATS}                ue_stats_nr id=7 type=pdsch
${CM_UE_8_DL_STATS}                ue_stats_nr id=8 type=pdsch

${CM_UE_1_UL_STATS}                   ue_stats_nr id=1 type=pusch
${CM_UE_2_UL_STATS}                   ue_stats_nr id=2 type=pusch
${CM_UE_3_UL_STATS}                   ue_stats_nr id=3 type=pusch
${CM_UE_4_UL_STATS}                   ue_stats_nr id=4 type=pusch
${CM_UE_5_UL_STATS}                   ue_stats_nr id=5 type=pusch
${CM_UE_6_UL_STATS}                   ue_stats_nr id=6 type=pusch
${CM_UE_7_UL_STATS}                   ue_stats_nr id=7 type=pusch
${CM_UE_8_UL_STATS}                   ue_stats_nr id=8 type=pusch
${CM_UE_9_UL_STATS}                   ue_stats_nr id=9 type=pusch
${CM_UE_10_UL_STATS}                  ue_stats_nr id=10 type=pusch

${CB012971_POS_PROFILE1_CMD}             ul_ue_beam_pos_nr profile_id=1 mode=FIXED  num_subband_info=2 correlation=1,1
                                         ...      num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...       srs_transmit_power_per_port=-550,-550 azimuth=-70,-70 zenith=0,0
${CB012971_POS_PROFILE2_CMD}             ul_ue_beam_pos_nr profile_id=2 mode=FIXED num_subband_info=2 correlation=1,1i
                                         ...       num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...       srs_transmit_power_per_port=-550,-550 azimuth=-53,-53 zenith=0,0
${CB012971_POS_PROFILE3_CMD}             ul_ue_beam_pos_nr profile_id=3 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...       num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=-36,-36 zenith=0,0
${CB012971_POS_PROFILE4_CMD}             ul_ue_beam_pos_nr profile_id=4 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...     num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=-23,-23 zenith=0,0
${CB012971_POS_PROFILE5_CMD}             ul_ue_beam_pos_nr profile_id=5 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...     num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=-6,-6 zenith=0,0
${CB012971_POS_PROFILE6_CMD}             ul_ue_beam_pos_nr profile_id=6 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...      num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=11,11 zenith=0,0
${CB012971_POS_PROFILE7_CMD}             ul_ue_beam_pos_nr profile_id=7 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...      num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=38,38 zenith=0,0
${CB012971_POS_PROFILE8_CMD}             ul_ue_beam_pos_nr profile_id=8 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...      num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=55,55 zenith=0,0
${CB012971_POS_PROFILE9_CMD}             ul_ue_beam_pos_nr profile_id=9 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...      num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=50,50 zenith=0,0
${CB012971_POS_PROFILE10_CMD}             ul_ue_beam_pos_nr profile_id=10 mode=FIXED num_subband_info=2 correlation=1,1
                                         ...      num_interfered_bf_subband=10,5 interfered_srs_subband=15,10
                                         ...      srs_transmit_power_per_port=-550,-550 azimuth=70,70 zenith=0,0

${CB012971_UE1_PROFILE1_POS_CMD_ACT}     ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=1
${CB012971_UE2_PROFILE2_POS_CMD_ACT}     ue_testmode_set_nr id=2 testmode=ue_ul_beam_position action=activate profile_id=2
${CB012971_UE3_PROFILE3_POS_CMD_ACT}     ue_testmode_set_nr id=3 testmode=ue_ul_beam_position action=activate profile_id=3
${CB012971_UE4_PROFILE4_POS_CMD_ACT}     ue_testmode_set_nr id=4 testmode=ue_ul_beam_position action=activate profile_id=4
${CB012971_UE5_PROFILE5_POS_CMD_ACT}     ue_testmode_set_nr id=5 testmode=ue_ul_beam_position action=activate profile_id=5
${CB012971_UE6_PROFILE6_POS_CMD_ACT}     ue_testmode_set_nr id=6 testmode=ue_ul_beam_position action=activate profile_id=6
${CB012971_UE7_PROFILE7_POS_CMD_ACT}     ue_testmode_set_nr id=7 testmode=ue_ul_beam_position action=activate profile_id=7
${CB012971_UE8_PROFILE8_POS_CMD_ACT}     ue_testmode_set_nr id=8 testmode=ue_ul_beam_position action=activate profile_id=8

${CB012971_CQI4_PROFILE5_CMD}            csi_override_testmode_nr profile_id=5 cqi_mode=fixed cqi=4
                                         ...     ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB012971_UE1_PROFILE1_SRS_CMD_ACT}     ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=1
${CB012971_UE2_PROFILE2_SRS_CMD_ACT}     ue_testmode_set_nr id=2 testmode=ue_ul_beam_position action=activate profile_id=2
${CB012971_UE1_PROFILE5_CQI_CMD_ACT}     ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=5
${CB012971_UE2_PROFILE5_CQI_CMD_ACT}     ue_testmode_set_nr id=2 testmode=csi_override action=activate profile_id=5
${CB012971_CQI15_PROFILE6__CMD}          csi_override_testmode_nr profile_id=6 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CM_UE1TO4_DTYPE_INTERNAL}           set_pdu_param ue=1-4 pdu=1 trf_type=internal
${CM_UE_1TO4_DL_DATA_TRFID_1}         trf_data_start ue=1-4 pdu=1 qfi=1 dir=dl mbps=170 trf_id=1
${CM_UE_1TO4_DL_DATA_TRFID_2}         trf_data_start ue=1-4 pdu=1 qfi=1 dir=dl mbps=170 trf_id=2
${CM_UE_1TO4_DL_DATA_TRFID_3}         trf_data_start ue=1-4 pdu=1 qfi=1 dir=dl mbps=170 trf_id=3
${CM_UE_1TO4_DL_DATA_TRFID_4}         trf_data_start ue=1-4 pdu=1 qfi=1 dir=dl mbps=170 trf_id=4
${CM_UE_1TO4_DL_DATA_TRFID_5}         trf_data_start ue=1-4 pdu=1 qfi=1 dir=dl mbps=170 trf_id=5
${CM_UE_1TO4_DL_DATA_TRFID_6}         trf_data_start ue=1-4 pdu=1 qfi=1 dir=dl mbps=170 trf_id=6
${CM_UE_1TO4_DL_DATA_TRFID_7}         trf_data_start ue=1-4 pdu=1 qfi=1 dir=dl mbps=170 trf_id=7

${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA_TRFID_1}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_1_DL_DATA_TRFID_1}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=1
${CM_UE_1_DL_DATA_TRFID_2}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=2
${CM_UE_1_DL_DATA_TRFID_3}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=3
${CM_UE_1_DL_DATA_TRFID_4}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=4
${CM_UE_1_DL_DATA_TRFID_5}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=5
${CM_UE_1_DL_DATA_TRFID_6}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=6
${CM_UE_1_DL_DATA_TRFID_7}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=7
${CM_UE_1_DL_DATA_TRFID_8}         trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=170 trf_id=8

${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE2_DTYPE_INTERNAL}           set_pdu_param ue=2 pdu=1 trf_type=internal
${CM_UE_2_REGISTER}                ue_register id=2
${CM_UE_2_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
${CM_UE_2_UL_DATA_TRFID_1}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_2_DL_DATA_TRFID_1}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=1
${CM_UE_2_DL_DATA_TRFID_2}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=2
${CM_UE_2_DL_DATA_TRFID_3}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=3
${CM_UE_2_DL_DATA_TRFID_4}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=4
${CM_UE_2_DL_DATA_TRFID_5}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=5
${CM_UE_2_DL_DATA_TRFID_6}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=6
${CM_UE_2_DL_DATA_TRFID_7}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=7
${CM_UE_2_DL_DATA_TRFID_8}         trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=170 trf_id=8

${CM_UE_2_DEREG}                   ue_deregister id=2 ue_deregister_type=switch_off
${CM_UE3_DTYPE_INTERNAL}           set_pdu_param ue=3 pdu=1 trf_type=internal
${CM_UE_3_REGISTER}                ue_register id=3
${CM_UE_3_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=3 nwslice=1 gw=1
${CM_UE_3_UL_DATA_TRFID_1}         trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_3_DEREG}                   ue_deregister id=3 ue_deregister_type=switch_off
${CM_UE4_DTYPE_INTERNAL}           set_pdu_param ue=4 pdu=1 trf_type=internal
${CM_UE_4_REGISTER}                ue_register id=4
${CM_UE_4_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=4 nwslice=1 gw=1
${CM_UE_4_UL_DATA_TRFID_1}         trf_data_start ue=4 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_4_DEREG}                   ue_deregister id=4 ue_deregister_type=switch_off
${CM_UE5_DTYPE_INTERNAL}           set_pdu_param ue=5 pdu=1 trf_type=internal
${CM_UE_5_REGISTER}                ue_register id=5
${CM_UE_5_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=5 nwslice=1 gw=1
${CM_UE_5_UL_DATA_TRFID_1}         trf_data_start ue=5 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_5_DEREG}                   ue_deregister id=5 ue_deregister_type=switch_off
${CM_UE6_DTYPE_INTERNAL}           set_pdu_param ue=6 pdu=1 trf_type=internal
${CM_UE_6_REGISTER}                ue_register id=6
${CM_UE_6_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=6 nwslice=1 gw=1
${CM_UE_6_UL_DATA_TRFID_1}         trf_data_start ue=6 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_6_DEREG}                   ue_deregister id=6 ue_deregister_type=switch_off
${CM_UE7_DTYPE_INTERNAL}           set_pdu_param ue=7 pdu=1 trf_type=internal
${CM_UE_7_REGISTER}                ue_register id=7
${CM_UE_7_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=7 nwslice=1 gw=1
${CM_UE_7_UL_DATA_TRFID_1}         trf_data_start ue=7 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_7_DEREG}                   ue_deregister id=7 ue_deregister_type=switch_off
${CM_UE8_DTYPE_INTERNAL}           set_pdu_param ue=8 pdu=1 trf_type=internal
${CM_UE_8_REGISTER}                ue_register id=8
${CM_UE_8_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=8 nwslice=1 gw=1
${CM_UE_8_UL_DATA_TRFID_1}         trf_data_start ue=8 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_8_DEREG}                   ue_deregister id=8 ue_deregister_type=switch_off
${CM_UE9_DTYPE_INTERNAL}           set_pdu_param ue=9 pdu=1 trf_type=internal
${CM_UE_9_REGISTER}                ue_register id=9
${CM_UE_9_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=9 nwslice=1 gw=1
${CM_UE_9_UL_DATA}                 trf_data_start ue=9 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_9_DEREG}                   ue_deregister id=9 ue_deregister_type=switch_off
${CM_UE10_DTYPE_INTERNAL}           set_pdu_param ue=10 pdu=1 trf_type=internal
${CM_UE_10_REGISTER}                ue_register id=10
${CM_UE_10_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=10 nwslice=1 gw=1
${CM_UE_10_UL_DATA}                 trf_data_start ue=10 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_10_DEREG}                   ue_deregister id=10 ue_deregister_type=switch_off
${CM_UE11_DTYPE_INTERNAL}           set_pdu_param ue=11 pdu=1 trf_type=internal
${CM_UE_11_REGISTER}                ue_register id=11
${CM_UE_11_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=11 nwslice=1 gw=1
${CM_UE_11_UL_DATA}                 trf_data_start ue=11 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_11_DEREG}                   ue_deregister id=11 ue_deregister_type=switch_off
${CM_UE12_DTYPE_INTERNAL}           set_pdu_param ue=12 pdu=1 trf_type=internal
${CM_UE_12_REGISTER}                ue_register id=12
${CM_UE_12_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=12 nwslice=1 gw=1
${CM_UE_12_UL_DATA}                 trf_data_start ue=12 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_12_DEREG}                   ue_deregister id=12 ue_deregister_type=switch_off
${CM_UE13_DTYPE_INTERNAL}           set_pdu_param ue=13 pdu=1 trf_type=internal
${CM_UE_13_REGISTER}                ue_register id=13
${CM_UE_13_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=13 nwslice=1 gw=1
${CM_UE_13_UL_DATA}                 trf_data_start ue=13 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_13_DEREG}                   ue_deregister id=13 ue_deregister_type=switch_off
${CM_UE14_DTYPE_INTERNAL}           set_pdu_param ue=14 pdu=1 trf_type=internal
${CM_UE_14_REGISTER}                ue_register id=14
${CM_UE_14_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=14 nwslice=1 gw=1
${CM_UE_14_UL_DATA}                 trf_data_start ue=14 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_14_DEREG}                   ue_deregister id=14 ue_deregister_type=switch_off
${CM_UE15_DTYPE_INTERNAL}           set_pdu_param ue=15 pdu=1 trf_type=internal
${CM_UE_15_REGISTER}                ue_register id=15
${CM_UE_15_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=15 nwslice=1 gw=1
${CM_UE_15_UL_DATA}                 trf_data_start ue=15 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_15_DEREG}                   ue_deregister id=15 ue_deregister_type=switch_off
${CM_UE16_DTYPE_INTERNAL}           set_pdu_param ue=16 pdu=1 trf_type=internal
${CM_UE_16_REGISTER}                ue_register id=16
${CM_UE_16_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=16 nwslice=1 gw=1
${CM_UE_16_UL_DATA}                 trf_data_start ue=16 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_16_DEREG}                   ue_deregister id=16 ue_deregister_type=switch_off
