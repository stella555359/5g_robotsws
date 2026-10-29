*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB012328only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,05.02.2026,keerthi.chittoor@nokia.com

*** Variables ***
${TC_DIR_CB012328_X}                     /home/ute/logs/CB012328_X/
${TC_DIR_CB012328_X_B02}                 /home/ute/logs/CB012328_XB02/
${Log_Path}                              /home/ute/logs/
${CFG_CB012328_X_SCF}                   CFG_CB012328_X_SCFC.xml
${CB012328_X_AP_IPHY}                   ${CURDIR}/../../config/ap/CB012328_X_AP_IPHY.xml
${CFG_CB012328_X_WTS}                   ${CURDIR}/../../config/wts/CB012328_X_WTS.cfg

${CM_for_sib1}                        gnb_param id=4 sib1_period=40
${CM_for_sib2}                        gnb_param id=4 sib2_period=40
${CM_for_sib5}                        gnb_param id=4 sib5_period=40
${CM_for_UE_LOC_CHANGE}               ue_change_location id=1 enb=4 cell=4
${CM_for_UE_HIST_INFO}                ue_history_information_list_add_ngran id=1 gnb_id=4 cell_type=medium
...                                   nrcgi=311:489|0x03 time_ue_stayed_in_cell=100
${CM_for_UE_HIST_INFO_1}              ue_history_information_list id=1 action=commit
${CM_for_UE_HIST_INFO_2}              ue_enb_param id=1 ue_history_list=1
${CM_for_UE_MEAS_DISP}                ue_cfg_meas_disp id=1

${CM_UE_1_REGISTER}                   ue_register id=1
${CM_UE_1_PDU_1_DTYPE_INTERNAL}       set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_PDU_1_SESSION}              ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_NRDC_ESTABLISHMENT}         ue_measurement_send_nr id=1 meas_id=3 phycell_id=52 nrsrp_nr=60 event=A4
${CM_UE_1_PDU_1_UL_DATA}              trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_1_PDU_1_DL_DATA}              trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10 trf_id=1
${CM_UE_1_PDU_2_DTYPE_INTERNAL}       set_pdu_param ue=1 pdu=2 trf_type=internal
${CM_UE_1_PDU_2_SESSION}              ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=1
${CM_UE_1_PDU_2_UL_DATA}              trf_data_start ue=1 pdu=2 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_1_PDU_2_DL_DATA}              trf_data_start ue=1 pdu=2 qfi=1 dir=dl mbps=10 trf_id=1
${CM_UE_1_PDU_2_MOD_QOS2_ADD}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=2 by=amf
${CM_UE_1_PDU_2_MOD_QOS3_ADD}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=3 by=amf
${CM_UE_1_PDU_2_MOD_QOS3_DEL}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_del=3 by=amf
${CM_UE_1_PDU_1_UL_DATA_STOP}         trf_data_stop ue=1 pdu=1 qfi=1 dir=ul trf_id=1
${CM_UE_1_PDU_1_DL_DATA_STOP}         trf_data_stop ue=1 pdu=1 qfi=1 dir=dl trf_id=1
${CM_UE_1_PDU_2_UL_DATA_STOP}         trf_data_stop ue=1 pdu=2 qfi=1 dir=ul trf_id=1
${CM_UE_1_PDU_2_DL_DATA_STOP}         trf_data_stop ue=1 pdu=2 qfi=1 dir=dl trf_id=1
${CM_UE_1_DEREG}                      ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE_1_NRDC_ESTABLISHMENT_1}       ue_measurement_send_nr id=1 meas_id=4 phycell_id=52 nrsrp_nr=60 event=A4
${CM_UE_1_NRDC_ESTABLISHMENT_2}       ue_measurement_send_nr id=1 meas_id=5 phycell_id=52 nrsrp_nr=60 event=A4
${CM_UE_1_NRDC_ESTABLISHMENT_3}       ue_measurement_send_nr id=1 meas_id=6 phycell_id=52 nrsrp_nr=60 event=A4
${CM_UE_1_NRDC_ESTABLISHMENT_9}       ue_measurement_send_nr id=1 meas_id=9 phycell_id=52 nrsrp_nr=60 event=A4
${CM_UE_1_A3_MEAS_SRC_TO_TGT}         ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19
...                                   phycell_id=50 nrsrp_nr=100
${CM_UE_1_A3_MEAS_TGT_TO_SRC}         ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19
...                                   phycell_id=55 nrsrp_nr=100
${CM_UE_1_UE_NR_RRC_RECONF}           ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=2
...                                   cell=1 cause=otherFailure crnti=target nth=1 num_reestablishment_reqs=1
${CM_UE_1_GNB_XN_HO}                  gnb_xn_handover_preparation_param id=4 reestab_info=1:valid

${VAL_SIB1}                           SystemInformationBlockType1-NR updated
${VAL_REG}                            Received REGISTRATION COMPLETE
${VAL_PDU_1_SESSION}                  UE-1 PDU SESSION ID-1 setup/reestablishment complete.
${VAL_PDU_2_SESSION}                  UE-1 PDU SESSION ID-2 setup/reestablishment complete.
${VAL_NRDC_SESSION}                   Received PDUSessionResourceModifyIndication
${VAL_PDU_2_MOD_QOS2_ADD}             Added QosFlow with QFI:2 5QI:5 SEID:2 SUPI:311489021645400 PDUSessionId:2.
${VAL_PDU_2_MOD_QOS3_ADD}             Added QosFlow with QFI:3 5QI:1 SEID:2 SUPI:311489021645400 PDUSessionId:2.
${VAL_SN_take_back}                   SN-terminated split bearer takeback is successful at SN
${VAL_XN_HO_AT_SRC}                   GNB-4: UE1: XN Handover Successfully completed at Source
${VAL_XN_HO_AT_TGT}                   Inter-eNB handover from EXT_ENB-2.1 to ENB-4.4 performed
${VAL_UE1_DEREG_REL}                  AMF-1: UE CONTEXT RELEASE COMPLETE
