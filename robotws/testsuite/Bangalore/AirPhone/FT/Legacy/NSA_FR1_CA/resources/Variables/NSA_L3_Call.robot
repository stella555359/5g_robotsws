*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Bindiya
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***


${CFG_GNB_SCF_DELTA_JSON}          SCF.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_nsa.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_setup_2cells.cfg
${Log_Path}                        /home/ute/logs
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE1_X2LINK}                   enb_x2_link_up enb=1 target=2
${CM_UE_1_ATTACH}                  ue_attach id=${UE_ID}
${SET_ENDC}                        enb_endc_param id=1 serving_cell_index_range_scg=5:31
${BEARER_SPLIT}                    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_UE_1_DL_DATA}                 trf_data_start ue=${UE_ID} id=2 dir=dl trf_id=2 mbps=20
${CM_UE_1_UL_DATA}                 trf_data_start ue=${UE_ID} id=2 dir=ul trf_id=1 mbps=20
${CM_UE_DETTACH}                   ue_detach id=${UE_ID} ue_detach_type=automatic
${CM_UE_1_DEREG}                   ue_deregister id=${UE_ID} ue_deregister_type=switch_off
${VAL_NSA_REG}                     UE performed Registration type INITIAL_REGISTRATION
${VAL_DUAL_CON}                    Successfully reconfigured dual connectivity
${VAL_UE11_DETTACH}                NAS DETACH PROCEDURE IS COMPLETED
${Location_Update}                 ue_change_location id=${UE_ID} enb=1 cell=2
${VER_Location}                    location updated
${ENDC_ON}                         enb_cell_param id=1 enb=1 allow_endc=on
${LTE_HO_11}                       ue_ho id=${UE_ID} ho_mode=INTRA_LTE enb=1 cell=1
${VER_HO}                          Intra-eNB handover from ENB-1.2 to ENB-1.1 performed
${A1_measurement}                  ue_measurement_send_nr id=11 meas_id=3  event=A1 phycell_id=51 srsrp_nr=40
${Scell_activation}                SCellIndex 6  activated successfully at airphone
${VER_A2}                          sCellToReleaseList
${A2_measurement}                  ue_measurement_send_nr id=${UE_ID} meas_id=4 event=A2 scell=6 scell_rsrp=60
