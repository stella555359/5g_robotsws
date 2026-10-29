** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

*** Variables ***
${CFG_GNB_SCF_DELTA_JSON}           SCF_Power_saving_off.xml
${NG_HO_TC02_IPHY}                  ${CURDIR}/../../config/ap/iphy_power_saving_off.xml
${NG_HO_TC02_SCF}                   ${CURDIR}/../../config/gnb/SCF_Power_saving_off.xml
${NG_HO_TC02_CFG}                   ${CURDIR}/../../config/wts/basic_12299.cfg
${CB012299_D_IPHY}                  ${CURDIR}/../../config/ap/iphy_d_contiguous_carriers.xml
${CB012299_D_SCF}                   scf_12299_d_pcell_scell_contiguous_carriers.xml
${CB012299_D_CFG}                   ${CURDIR}/../../config/wts/basic_12299_Scell_contiguous.cfg
${CB012299_C_IPHY}                  ${CURDIR}/../../config/ap/iphy_C.xml
${CB012299_C_SCF}                   SCF_C.xml
${CB012299_C_CFG}                   ${CURDIR}/../../config/wts/basic_12299_C.cfg
${CB012299_D_limited_bwp_SCF}                   scf_12299_d_limited_bwp.xml



${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2


${Log_Path}                        /home/ute/logs
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${UE_DEREGISTER}                   ue_deregister id=1 ue_deregister_type=switch_off
&{COUNTER_CHECKS}        M55166C00025=NUM_RU_ATT_RCFG_BWP       M55166C00001=NRRC_RRC_RECONF_BWP1_SENT        M55139C04511=GNB_DU_SCELL_ADM_BWP1_SUCC


${ReconfigurationFailure}          ue_rrc_reestablish id=1 gnb=2 cell=1 cause=reconfigurationFailure
${HandoverFailure}                 ue_rrc_reestablish id=1 gnb=2 cell=1 cause=handoverFailure
${otherFailure}                    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure
${spare1}                          ue_rrc_reestablish id=1 gnb=2 cell=1 cause=spare1


${VAL_RECONFIGURATION_FAILURE}     reestablishmentCause reconfigurationFailure
${VAL_HO_FAILURE}                  reestablishmentCause handoverFailure
${VAL_OTHER_FAILURE}               reestablishmentCause otherFailure
${VAL_SPARE1}                      reestablishmentCause spare1

${VAL_UE1_SCELL_1_ACTIVATED}       SCellIndex 1 activated successfully at airphone
${DATA TRF 1}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=100 dir=dl
${DATA TRF 2}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=2 mbps=100 dir=dl
${DATA TRF 3}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=3 mbps=100 dir=dl
${DATA TRF 4}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=4 mbps=100 dir=dl
${DATA TRF 5}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=5 mbps=100 dir=dl
${DATA TRF 6}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=6 mbps=100 dir=dl
${DATA TRF 7}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=7 mbps=100 dir=dl
${DATA TRF 8}                      trf_data_start ue=1 pdu=1 qfi=1 trf_id=8 mbps=100 dir=dl
${CM_UE_1_STATS}                   ue_stats_nr id=1 scell=0-1 type=pdsch
