** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

*** Variables ***
${CFG_GNB_SCF_DELTA_JSON}           SCF_TC02.xml
${NG_HO_TC02_IPHY}                  ${CURDIR}/../../config/ap/iphy_TC02.xml
${NG_HO_TC02_SCF}                   ${CURDIR}/../../config/gnb/SCF_TC02.xml
${NG_HO_TC02_CFG}                   ${CURDIR}/../../config/wts/basic_setup_ng_TC02.cfg
${XN_HO_TC02_IPHY}                  ${CURDIR}/../../config/ap/XNHO_iphy.xml
${XN_HO_TC02_SCF}                   XNHO_scf.xml
${XN_HO_TC02_CFG}                   ${CURDIR}/../../config/wts/XNHO_cfg.cfg



${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2


${Log_Path}                        /home/ute/logs
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${UE_DEREGISTER}                   ue_deregister id=1 ue_deregister_type=switch_off

${UE_LOC_UPDATE}                     ue_change_location id=1 enb=3 cell=1
${SEND_SIB1_TO_RANSIM}               gnb_param id=3 sib1_period=40
${SEND_SIB2_TO_RANSIM}               gnb_param id=3 sib2_period=40
${SEND_SIB5_TO_RANSIM}               gnb_param id=3 sib5_period=40
${SEND_UE_HISTORY_INFO}        ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x03 time_ue_stayed_in_cell=100
${COMMIT_UE_HISTORY_INFO}            ue_history_information_list id=1 action=commit
${DL_DATA}                           trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5
${UL_DATA}                           trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5
${HO_PREPARATION}                    ue_gnb_src_scg_cfg_param id=1 gnb=3 include_source_scg_config=source_scg_nr_config
${HO_PREPARATION_no_nr}              ue_gnb_src_scg_cfg_param id=1 gnb=3 include_source_scg_config=source_scg_config
${HO_PREPARATION_EUTRA}              ue_gnb_src_scg_cfg_param id=1 gnb=5 include_source_scg_config=source_scg_eutra_config
${CHECK MEAS REPORT}                 ue_cfg_meas_disp id=1
${TRIGGER HO}                        ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=10 srsrq_nr=10 phycell_id=50 nrsrp_nr=30 nrsrq_nr=20

${VAL_UE_LOC_CHANGE}                 location updated to eNB-3 cell 1
${VAL_SIB1}                          eNB 3 cell 2: SystemInformationBlockType1-NR updated
${VAL_SIB2}                          eNB 3 cell 2: SystemInformationBlockType2-NR updated
${VAL_SIB5}                          eNB 3 cell 2: SystemInformationBlockType5-NR updated
${VAL_UE_HISTORY_COMMIT}             UE History List: 1 was committed
${VAL_INTER_GNB_HO}                  Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

#XNHO

${UE_LOC_UPDATE_XN}                     ue_change_location id=1 enb=5 cell=1
${SEND_SIB1_TO_RANSIM_XN}               gnb_param id=5 sib1_period=40
${SEND_SIB2_TO_RANSIM_XN}               gnb_param id=5 sib2_period=40
${SEND_SIB5_TO_RANSIM_XN}               gnb_param id=5 sib5_period=40
${SEND_UE_HISTORY_INFO_XN}     ue_history_information_list_add_ngran id=1 gnb_id=5 cell_type=medium nrcgi=311:489|0x03 time_ue_stayed_in_cell=100
${COMMIT_UE_HISTORY_INFO_XN}            ue_history_information_list id=1 action=commit
${UE_HISTORY_INFO}                   ue_enb_param id=1 ue_history_list=1
${HO_PREPARATION_XN}                    ue_gnb_src_scg_cfg_param id=1 gnb=5 include_source_scg_config=source_scg_nr_config
${HO_PREPARATION_no_nr_XN}              ue_gnb_src_scg_cfg_param id=1 gnb=5 include_source_scg_config=source_scg_config
${HO_PREPARATION_EUTRA_XN}              ue_gnb_src_scg_cfg_param id=1 gnb=5 include_source_scg_config=source_scg_eutra_config
${TRIGGER HO XN}          ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=10 srsrq_nr=10 phycell_id=50 nrsrp_nr=30 nrsrq_nr=20

${VAL_UE_LOC_CHANGE_XN}                 location updated to eNB-5 cell 1
${VAL_SIB1_XN}                          eNB 5 cell 1: SystemInformationBlockType1-NR updated
${VAL_SIB2_XN}                          eNB 5 cell 1: SystemInformationBlockType2-NR updated
${VAL_SIB5_XN}                          eNB 5 cell 1: SystemInformationBlockType5-NR updated
${VAL_INTER_GNB_HO_XN}                  Inter-eNB handover from ENB-5.1 to EXT_ENB-2.1 performed
