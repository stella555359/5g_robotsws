*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008472 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,12.12.2025,keerthi.chittoor@nokia.com

*** Variables ***
${TC_DIR_CB008472_A}                     /home/ute/logs/CB008472_A/
${TC_DIR_CB008472_B}                     /home/ute/logs/CB008472_B/
${Log_Path}                              /home/ute/logs/
${CFG_CB008472_A_SCF}                   CFG_CB008472_A_SCFC.xml
${CB008472_A_AP_IPHY}                   ${CURDIR}/../../config/ap/CB008472_A_AP_IPHY.xml
${CFG_CB008472_A_WTS}                   ${CURDIR}/../../config/wts/CB008472_A_WTS.cfg
${CFG_CB008472_B_SCF}                   CFG_CB008472_B_SCFC.xml
${CB008472_B_AP_IPHY}                   ${CURDIR}/../../config/ap/CB008472_B_AP_IPHY.xml
${CFG_CB008472_B_WTS}                   ${CURDIR}/../../config/wts/CB008472_B_WTS.cfg

${CM_UE_1_REGISTER}                   ue_register id=1
${CM_UE_1_PDU_1_DTYPE_INTERNAL}       set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_PDU_1_SESSION}              ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_NRDC_ESTABLISHMENT}         ue_measurement_send_nr id=1 meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4
${CM_UE_1_PDU_1_UL_DATA}              trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_1_PDU_1_DL_DATA}              trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10 trf_id=1
${CM_UE_1_PDU_1_MOD_QOS2_ADD}         ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
${CM_UE_1_PDU_1_MOD_QOS3_ADD}         ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 by=amf
${CM_UE_1_PDU_1_MOD_QOS4_ADD}         ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=4 by=amf
${CM_UE_1_PDU_1_MOD_QOS5_ADD}         ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=5 by=amf
${CM_UE_1_PDU_1_MOD_QOS6_ADD}         ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=6 by=amf
${CM_UE_1_PDU_2_DTYPE_INTERNAL}       set_pdu_param ue=1 pdu=2 trf_type=internal
${CM_UE_1_PDU_2_SESSION}              ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=1
${CM_UE_1_PDU_2_UL_DATA}              trf_data_start ue=1 pdu=2 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_1_PDU_2_DL_DATA}              trf_data_start ue=1 pdu=2 qfi=1 dir=dl mbps=10 trf_id=1
${CM_UE_1_PDU_2_MOD_QOS2_ADD}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=2 by=amf
${CM_UE_1_PDU_2_MOD_QOS3_ADD}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=3 by=amf
${CM_UE_1_PDU_2_MOD_QOS4_ADD}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=4 by=amf
${CM_UE_1_PDU_2_MOD_QOS5_ADD}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=5 by=amf
${CM_UE_1_PDU_2_MOD_QOS6_ADD}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=6 by=amf
${CM_UE_1_PDU_3_DTYPE_INTERNAL}       set_pdu_param ue=1 pdu=3 trf_type=internal
${CM_UE_1_PDU_3_SESSION}              ue_pdu_session_setup pdu=3 ue=1 nwslice=1 gw=1
${CM_UE_1_PDU_3_MOD_QOS4_ADD}         ue_pdu_session_modify ue=1 pdu=3 qosflows_to_add=4 by=amf
${CM_UE_1_PDU_3_MOD_QOS5_ADD}         ue_pdu_session_modify ue=1 pdu=3 qosflows_to_add=5 by=amf
${CM_UE_1_PDU_3_UL_DATA}              trf_data_start ue=1 pdu=3 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_1_PDU_3_DL_DATA}              trf_data_start ue=1 pdu=3 qfi=1 dir=dl mbps=10 trf_id=1
${CM_UE_1_PDU_1_MOD_QOS2_DEL}         ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2 by=amf
${CM_UE_1_PDU_2_MOD_QOS6_DEL}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_del=6 by=amf
${CM_UE_1_PDU_3_RELEASE}              ue_pdu_session_release ue=1 pdu=3 by=amf
${CM_UE_1_PDU_2_MOD_QOS2_DEL}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_del=2 by=amf
${CM_UE_1_PDU_2_MOD_QOS3_DEL}         ue_pdu_session_modify ue=1 pdu=2 qosflows_to_del=3 by=amf
${CM_UE_1_PDU_1_UL_DATA_STOP}         trf_data_stop ue=1 pdu=1 qfi=1 dir=ul trf_id=1
${CM_UE_1_PDU_1_DL_DATA_STOP}         trf_data_stop ue=1 pdu=1 qfi=1 dir=dl trf_id=1
${CM_UE_1_PDU_2_UL_DATA_STOP}         trf_data_stop ue=1 pdu=2 qfi=1 dir=ul trf_id=1
${CM_UE_1_PDU_2_DL_DATA_STOP}         trf_data_stop ue=1 pdu=2 qfi=1 dir=dl trf_id=1
${CM_UE_1_PDU_3_UL_DATA_STOP}         trf_data_stop ue=1 pdu=3 qfi=1 dir=ul trf_id=1
${CM_UE_1_PDU_3_DL_DATA_STOP}         trf_data_stop ue=1 pdu=3 qfi=1 dir=dl trf_id=1
${CM_UE_1_DEREG}                       ue_deregister id=1 ue_deregister_type=switch_off

${VAL_SIB1}                           SystemInformationBlockType1-NR updated
${VAL_REG}                            Received REGISTRATION COMPLETE
${VAL_PDU_1_SESSION}                  UE-1 PDU SESSION ID-1 setup/reestablishment complete.
${VAL_PDU_2_SESSION}                  UE-1 PDU SESSION ID-2 setup/reestablishment complete.
${VAL_PDU_3_SESSION}                  UE-1 PDU SESSION ID-3 setup/reestablishment complete.
${VAL_NRDC_SESSION}                   Received PDUSessionResourceModifyIndication
${VAL_PDU_1_MOD_QOS2_ADD}             Added QosFlow with QFI:2 5QI:5 SEID:1 SUPI:311489021645400 PDUSessionId:1.
${VAL_PDU_1_MOD_QOS3_ADD}             Added QosFlow with QFI:3 5QI:1 SEID:1 SUPI:311489021645400 PDUSessionId:1.
${VAL_PDU_1_MOD_QOS4_ADD}             Added QosFlow with QFI:4 5QI:7 SEID:1 SUPI:311489021645400 PDUSessionId:1.
${VAL_PDU_1_MOD_QOS5_ADD}             Added QosFlow with QFI:5 5QI:8 SEID:1 SUPI:311489021645400 PDUSessionId:1.
${VAL_PDU_1_MOD_QOS6_ADD}             Added QosFlow with QFI:6 5QI:9 SEID:1 SUPI:311489021645400 PDUSessionId:1.
${VAL_PDU_2_MOD_QOS2_ADD}             Added QosFlow with QFI:2 5QI:5 SEID:2 SUPI:311489021645400 PDUSessionId:2.
${VAL_PDU_2_MOD_QOS4_ADD}             Added QosFlow with QFI:3 5QI:7 SEID:2 SUPI:311489021645400 PDUSessionId:2.
${VAL_PDU_2_MOD_QOS5_ADD}             Added QosFlow with QFI:4 5QI:8 SEID:2 SUPI:311489021645400 PDUSessionId:2.
${VAL_PDU_2_MOD_QOS6_ADD}             Added QosFlow with QFI:5 5QI:9 SEID:2 SUPI:311489021645400 PDUSessionId:2.
${VAL_PDU_3_MOD_QOS4_ADD}             Added QosFlow with QFI:2 5QI:7 SEID:3 SUPI:311489021645400 PDUSessionId:3.
${VAL_PDU_3_MOD_QOS5_ADD}             Added QosFlow with QFI:3 5QI:8 SEID:3 SUPI:311489021645400 PDUSessionId:3.
${VAL_PDU_1_MOD_QOS2_DEL}             Deleted QoSFlow with QFI 2 SEID 1
${VAL_PDU_2_MOD_QOS6_DEL}             Deleted QoSFlow with QFI 5 SEID 2
${VAL_PDU_3_RELEASE}                  Successfully released PDU Session with ID 3
${KEY_REFRESH}                        Intra-cell handover (key refresh) performed at EXT_ENB-2.1
${NRDC_RELEASE}                       SN-terminated split bearer takeback is successful at SN
${VAL_UE1_DEREG_REL}                  AMF-1: UE CONTEXT RELEASE COMPLETE
