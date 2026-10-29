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
${CB008490_LC_SCF_DELTA_JSON}       cb008490_LC_scf_working.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_basic_call.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_auto.cfg
${CB008490_LC_CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/CB008490_iphy.xml
${CB008490_LC_CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/CB008490_LC_CFG_nrdc.cfg
${Log_Path}                        /home/ute/logs

${vVAL_XN1}                        GNB-2: XnAP Link with GNB-3 (10.0.1.3:38422[0]) is up
${eVAL_XN1}                        GNB-2: XnAP Link with GNB-3 (10.0.1.3:38422\\[0\\]) is up

#${vVAL_XN1}                        XnAuthentication is Successful
#${eVAL_XN1}                        UEC-1: L2: <CELL SETUP> \\[CellId:3\\]\\[PhysCellId:53\\] CellSyncProcedure
#${vVAL_XN1}                        UEC-1: L2: <CELL SETUP> [CellId:3][PhysCellId:53] CellSyncProcedure
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_1_DL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${FILTER_B005}                     uldata_puschreceiverespps || uldata_puschreceivereq
${BIP_CSV_NAME}                    BIP_L1L2_filter_SCN1.csv
${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2
