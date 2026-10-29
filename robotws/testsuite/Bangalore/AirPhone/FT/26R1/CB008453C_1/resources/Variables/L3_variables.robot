*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***
#${CFG_GNB_SCF_DELTA_JSON}          SCF_CB008453_C_ITW1_SCFC_2_AWEUC_8_cells.xml
${CFG_GNB_SCF_DELTA_JSON}          SCF_CB008453_BLIND.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_8453.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/wts_212_UEs_SA.lua
#${SCF_CB008453_BLIND}              ${CURDIR}/../../config/SBTS26R2/SCF_CB008453_BLIND.xml
${Log_Path}                        /home/ute/logs
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=175 trf_id=1
${CM_UE_1_DL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
${CM_UE_1_UL_THRPUT}               ue_stats_nr id=1 scell=primary,secondary type=pusch
${CM_UE_1_DL_THRPUT}               ue_stats_nr id=1 scell=primary,secondary type=pdsch
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${SCELL1_ACTIVATION}               SCellIndex 1 activated successfully at airphone
${SCELL2_ACTIVATION}               SCellIndex 2 activated successfully at airphone
${SCELL3_ACTIVATION}               SCellIndex 3 activated successfully at airphone
${SCELL4_ACTIVATION}               SCellIndex 4 activated successfully at airphone
${SCELL5_ACTIVATION}               SCellIndex 5 activated successfully at airphone
${SCELL6_ACTIVATION}               SCellIndex 6 activated successfully at airphone
${SCELL7_ACTIVATION}               SCellIndex 7 activated successfully at airphone
${CELL_INDEX}                      CellIndex
${FILTER_B005}                     uldata_puschreceiverespps || uldata_puschreceivereq
${BIP_CSV_NAME}                    BIP_L1L2_filter_SCN1.csv
${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2
