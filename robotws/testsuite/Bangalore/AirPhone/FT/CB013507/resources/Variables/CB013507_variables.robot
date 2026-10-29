*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***
${CFG_GNB_SCF_DELTA_JSON}          scf_basic_call.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_basic_call.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_auto.cfg
${Log_Path}                        /home/ute/logs
${CB013507_GNB_SCF_DELTA_JSON}        CB013507_gNB_TC01_SCF.xml
${CB013507_GNB_TC01_SCF}            ${CURDIR}/../../config/gnb/CB013507_gNB_TC01_SCF.xml
${CB013507_TC01_AP_IPHY}            ${CURDIR}/../../config/ap/CB013507_TC01_iphy.xml
${CB013507_TC01_WTS_CFG}            ${CURDIR}/../../config/wts/CB013507_WTS_TC01_CFG.cfg

${CB013507_GNB_SCF_FR2_TDD_DELTA_JSON}            CB013507_gNB_FR2_SCF.xml
${CB013507_GNB_FR2_TDD_SCF}                  ${CURDIR}/../../config/gnb/CB013507_gNB_FR2_SCF.xml
${CB013507_FR2_TDD_AP_IPHY}              ${CURDIR}/../../config/ap/CB013507_FR2_iphy.xml
${CB013507_FR2_TDD_WTS_CFG}              ${CURDIR}/../../config/wts/CB013507_FR2_WTS_CFG.cfg

${CB013507_TC01_val_req}           LMF-1: ECID Measurement Initiation Request sent
${CB013507_TC01_val_res}           LMF-1: Received ECID Measurement Response with NRPPATransactionID
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5 trf_id=1
${CM_UE_1_DL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE2_DTYPE_INTERNAL}           set_pdu_param ue=2 pdu=1 trf_type=internal
${CM_UE_2_REGISTER}                ue_register id=2
${CM_UE_2_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
${CM_UE_2_UL_DATA}                 trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=5 trf_id=1
${CM_UE_2_DL_DATA}                 trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=5 trf_id=1
${CM_UE_2_DEREG}                   ue_deregister id=2 ue_deregister_type=switch_off
${IMF_CMD_CB013507_UE1_TC01}           lmf_send_ecid_meas_req id=1 ue=1 nrppa_transaction_id=1 lmf_ue_measurement_id=1
...                                    report_characteristics=OnDemand meas_qty=NR_Timing_Advance
${IMF_CMD_CB013507_UE2_TC01}           lmf_send_ecid_meas_req id=1 ue=2 nrppa_transaction_id=1 lmf_ue_measurement_id=1
...                                    report_characteristics=OnDemand meas_qty=NR_Timing_Advance
${CB013507_UE_TA_NR_CMD1_TC02_PR1}           ue_ta_nr profile_id=1 ue_p_delay_initial=100
${CB013507_UE_TA_NR_CMD2_TC02_PR1}           ue_ta_nr profile_id=1
${CB013507_UE_TA_NR_CMD3_TC02_PR1}           ue_testmode_set_nr id=1 testmode=ta action=activate profile_id=1
${CB013507_UE_TA_NR_CMD1_TC02_PR2}           ue_ta_nr profile_id=2 ue_p_delay_initial=292
${CB013507_UE_TA_NR_CMD2_TC02_PR2}           ue_ta_nr profile_id=2
${CB013507_UE_TA_NR_CMD3_TC02_PR2}           ue_testmode_set_nr id=2 testmode=ta action=activate profile_id=2
${CM_UE_52_DTYPE_INTERNAL}           set_pdu_param ue=52 pdu=1 trf_type=internal
${CM_UE_52_REGISTER}                ue_register id=52
${CM_UE_52_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=52 nwslice=1 gw=1
${CM_UE_52_UL_DATA}                 trf_data_start ue=52 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_52_DL_DATA}                 trf_data_start ue=52 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
${CM_UE_52_DEREG}                   ue_deregister id=52 ue_deregister_type=switch_off
${IMF_CMD_CB013507_UE52_TC01}           lmf_send_ecid_meas_req id=1 ue=52 nrppa_transaction_id=1 lmf_ue_measurement_id=1
...                                    report_characteristics=OnDemand meas_qty=NR_Timing_Advance
${CM_UE_52_DL_BEARER}              bearer_stats ue=52 pdu=1 qfi=1 dir=dl
${CM_UE_52_UL_BEARER}              bearer_stats ue=52 pdu=1 qfi=1 dir=ul
${SIM_FLUSH}                       sim_log_set flush

${CM_UE53_DTYPE_INTERNAL}           set_pdu_param ue=53 pdu=1 trf_type=internal
${CM_UE_53_REGISTER}                ue_register id=53
${CM_UE_53_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=53 nwslice=1 gw=1
${CM_UE_53_UL_DATA}                 trf_data_start ue=53 pdu=1 qfi=1 dir=ul mbps=5 trf_id=1
${CM_UE_53_DL_DATA}                 trf_data_start ue=53 pdu=1 qfi=1 dir=dl mbps=5 trf_id=1
${IMF_CMD_CB013507_UE53_TC01}           lmf_send_ecid_meas_req id=1 ue=53 nrppa_transaction_id=1 lmf_ue_measurement_id=1
...                                    report_characteristics=OnDemand meas_qty=NR_Timing_Advance
${CM_UE_53_DEREG}                   ue_deregister id=53 ue_deregister_type=switch_off
${CB013507_UE_53_TA_NR_CMD1_TC02_PR1}           ue_ta_nr profile_id=53 ue_p_delay_initial=100
${CB013507_UE_53_TA_NR_CMD2_TC02_PR1}           ue_ta_nr profile_id=53
${CB013507_UE_53_TA_NR_CMD3_TC02_PR1}           ue_testmode_set_nr id=53 testmode=ta action=activate profile_id=53



${FILE PATH_CSV_CHECK}                    /home/ute/logs/CB013507_TC01_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_SCN1.csv
${COLUMN_initialTa_2}                      UlData_detectedPrachPreambles_t.initialTa
${COLUMN_initialUlEcidTAdv_1}                 UlData_detectedPrachPreambles_t.initialUlEcidTAdv
${FILTER_CB013507_1}                     UlData_detectedPrachPreambles_t.initialTa
${FILTER_CB013507_2}                     UlData_detectedPrachPreambles_t.initialUlEcidTAdv
${FILTER_CB013507_3}                     UlData_detectedPrachPreambles_t.initialUlEcidTAdv

${FILTER_B005}                     uldata_puschreceiverespps || uldata_puschreceivereq
${BIP_CSV_NAME}                    BIP_L1L2_filter_SCN1.csv
${BIP_CSV_CB013507_1}              BIP_L1L2_filter_initialUlEcidTAdv.csv
${BIP_CSV_CB013507_2}              BIP_L1L2_filter_initialTa.csv
${BIP_CSV_CB013507_NR_TADA_BEFORE}              BIP_L1L2_filter_NR_TADA_Before.csv
${BIP_CSV_CB013507_NR_TADA_AFTER}               BIP_L1L2_filter_NR_TADA_After.csv
${CB013507_CSV_PATH_Delay_After_TC02}           /home/ute/logs/CB013507_TC02_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_NR_TADA_After.csv
${CB013507_CSV_PATH_Delay_After_TC05}           /home/ute/logs/CB013507_TC05_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_NR_TADA_After.csv
${CB013507_CSV_PATH_Delay_After_TC06}           /home/ute/logs/CB013507_TC06_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_NR_TADA_After.csv
${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2
