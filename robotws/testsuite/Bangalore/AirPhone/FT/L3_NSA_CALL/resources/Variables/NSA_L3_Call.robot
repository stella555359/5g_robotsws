*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Bindiya
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
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE1_X2LINK}                   enb_x2_link_up enb=1 target=2
${CM_UE_1_ATTACH}                  ue_attach id=11
${SET_ENDC}                        enb_endc_param id=1 serving_cell_index_range_scg=5:31
${BEARER_SPLIT}                    ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_UE_1_DL_DATA}                 trf_data_start ue=11 id=2 dir=dl trf_id=2 mbps=20
${CM_UE_1_UL_DATA}                 trf_data_start ue=11 id=2 dir=ul trf_id=1 mbps=20
${CM_UE_DETTACH}                   ue_detach id=11 ue_detach_type=automatic
${CM_UE_1_DEREG}                   ue_deregister id=11 ue_deregister_type=switch_off
${VAL_NSA_REG}                     UE performed Registration type INITIAL_REGISTRATION
${VAL_DUAL_CON}                    Successfully reconfigured dual connectivity
${VAL_UE11_DETTACH}                SgNBReleaseRequestAcknowledge
