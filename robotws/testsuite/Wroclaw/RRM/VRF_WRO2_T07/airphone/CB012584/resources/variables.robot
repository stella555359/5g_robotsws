*** Settings ***
Documentation
...    :copyright: Nokia
...    :author: Wojciech Bednarz, Sylwester Sowa, Krzysztof Wojnar
...    :contact: wojciech.bednarz@nokia.com; sylwester.sowa@nokia.com; krzysztof.wojnar@nokia.com
...    :maintainer: Wojciech Bednarz, Sylwester Sowa, Krzysztof Wojnar
...    :contact: wojciech.bednarz@nokia.com; sylwester.sowa@nokia.com; krzysztof.wojnar@nokia.com


*** Variables ***
${GOLDEN_SCF_VDU}=            ${CURDIR}/../../configs/xml/golden_scf_vdu.xml
${GOLDEN_SCF_VCU}=            ${CURDIR}/../../configs/xml/golden_scf_vcu.xml
&{COUNTERS_INCREMENTING_A}=          SA_RRC_ESTAB_NEME_FAIL_OVLDU=M55124C00023
&{COUNTERS_INCREMENTING_C}=          RRC_ESTAB_NEME_FAIL_OVLDU_UP=M55166C00020
...                                  RRC_RESUME1_NEME_FAIL_OVLDU_UP=M55166C00021
...                                  RRC_NEME_FAIL_SIG_OVLDU_UP=M55166CRD50001
&{OVL_PARAMS_VDU_ON_SCHED}=            gnbOvlProtMode=cloud    /duOvlHa/ovlSaRrcRej=true    actOvlProtL2Sched=true
&{OVL_PARAMS_VCU_ON}=                  gnbOvlProtMode=cloud          /cuOvlHa/0/ovlNsaAddRej=enabled
&{OVL_PARAMS_VDU_OFF_SCHED}=           actOvlProtL2Sched=false    gnbOvlProtMode=disabled    /duOvlHa/ovlSaRrcRej=false
&{OVL_PARAMS_VCU_OFF}=                 gnbOvlProtMode=disabled       /cuOvlHa/0/ovlNsaAddRej=disabled
&{OVL_PARAMS_VDU_ON_SIG}=              gnbOvlProtMode=cloud    /duOvlHa/ovlSaRrcRej=true    actOvlProtL2Sig=true
&{OVL_PARAMS_VDU_OFF_SIG}=             gnbOvlProtMode=cloud    /duOvlHa/ovlSaRrcRej=true    actOvlProtL2Sig=false
@{COUNTERS_NOT_INCREMENTING_C}=        SA_RRC_ESTAB_NEME_FAIL_OVLDU    SA_RRC_RESUME1_NEME_FAIL_OVLDU
...                                    SA_RRC_ESTAB_NEME_FAIL_OVLCP
@{CPRT_DEFAULT_FLAGS}=      0x5901FA    30    0x5901FB    125000    0x5901FC    30    0x590226    80
...    0x590227    200    0x590221    1000    0x590207    14    0x590208    16
@{CPUE_DEFAULT_FLAGS}=      0x89008E    300    0x89006F    20
${X2AP_SGNB_ADDITION_REJECT}=    (x2ap.SgNBAdditionRequestReject_element) && (x2ap.misc == control-processing-overload)
${X2AP_MODIFICATION_REJECT_OVL}=    (x2ap.SgNBModificationRequestReject_element) && (x2ap.misc == control-processing-overload)
${NGAP_HANDOVER_FAILURE_OVERLOAD}=    (ngap.HandoverFailure_element && ngap.misc == control-processing-overload)
${NGAP_PDU_SESSION_RESOURCE_REJECT_OVL}=    (ngap.PDUSessionResourceSetupResponse_element)
...     && (ngap.PDUSessionResourceFailedToSetupListSURes == 1 && ngap.misc == control-processing-overload)
${NSETAPX_REPORT}=    nsetapx.report_element
${NRRRC_MEASUREMENT_REPORT_PCI_51}=    (nr-rrc.measurementReport_element && nr-rrc.physCellId == 51 && nr-rrc.measQuantityResults.rsrp == 100)
${NRRRC_REJECT_16s}=    (nr-rrc.rrcReject_element && nr-rrc.waitTime == 16)
${F1AP_GNBDU_OVERLOADED_INFORMATION}=    (f1ap.GNBDUStatusIndication_element) && (f1ap.GNBDUOverloadInformation == overloaded)
${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}=    (f1ap.GNBDUStatusIndication_element) && (f1ap.GNBDUOverloadInformation == "not-overloaded")
${F1AP_GNBDU_OVERLOADED_INFORMATION_DU1}=    ip.src == 172.16.1.1 && f1ap.GNBDUOverloadInformation == "overloaded"
${F1AP_GNBDU_OVERLOADED_INFORMATION_DU2}=    ip.src == 172.16.1.2 && f1ap.GNBDUOverloadInformation == "overloaded"
${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION_DU1}=  ip.src == 172.16.1.1 && f1ap.GNBDUOverloadInformation == "not-overloaded"
${F1AP_CU_OVERLOADED_INFORMATION}=    (f1ap.NetworkAccessRateReduction_element) && (f1ap.uACReductionIndication == 100)
${F1AP_CU_NOT_OVERLOADED_INFORMATION}=    (f1ap.NetworkAccessRateReduction_element) && (f1ap.uACReductionIndication == 0)
${DEFAULT_S1_MME_SCTP}=       sctp
${RANNIC_DISTNAME}=           MRBTS-1/EQM-1/APEQM-1/RNICMOD-1
${SSH_OCP_CON_DETAILS}=       ${tl.cloud_hostings[1].master_node.ssh_connection_details}
${SSH_OCP_CON_DETAILS_VCU}=   ${tl.cloud_hostings[0].master_node.ssh_connection_details}
${VDU_IP_ADDR}=               ${SSH_OCP_CON_DETAILS.addr}
${VDU_IP_USERNAME}=           ${SSH_OCP_CON_DETAILS.username}
${VDU_IP_PASSWORD}=           ${SSH_OCP_CON_DETAILS.password}
${VDU_IP_PORT}=               ${SSH_OCP_CON_DETAILS.port}
${VCU_IP_ADDR}=               ${SSH_OCP_CON_DETAILS_VCU.addr}
${VCU_IP_USERNAME}=           ${SSH_OCP_CON_DETAILS_VCU.username}
${VCU_IP_PASSWORD}=           ${SSH_OCP_CON_DETAILS_VCU.password}
${VCU_IP_PORT}=               ${SSH_OCP_CON_DETAILS_VCU.port}
&{HOPS_OCP_VCU}=              host=${VCU_IP_ADDR}    user=${VCU_IP_USERNAME}    password=${VCU_IP_PASSWORD}
&{HOPS_OCP_VDU}=              host=${VDU_IP_ADDR}    user=${VDU_IP_USERNAME}    password=${VDU_IP_PASSWORD}
${NAMESPACE}=                 ${tl.cloud_hostings[1].namespace}
${UTE_PART}=                  ute-
${CPRT_PART}=                 -cprt-0
${CPUE_PART}=                 -cpue-0
${CPRT_POD}=                  ${UTE_PART}${NAMESPACE}${CPRT_PART}
${CPUE_POD}=                  ${UTE_PART}${NAMESPACE}${CPUE_PART}
${L2RT_PART}=                 -l2rt-a-0
${L2RT_POD}=                  ${UTE_PART}${NAMESPACE}${L2RT_PART}
@{UPLANE_FLAGS}=              0x58093B=50    0x58093C=50    0x58093D=9    0x58093E=1    0x58093F=100
@{UPLANE_DEFAULT_FLAGS}=      0x58093B=4    0x58093C=5    0x58093D=150    0x58093E=100    0x58093F=0
${TOPOLOGY}=                  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

${ACT_OVL_SA_RRC_REJ_TRUE_VDU}=      ${CURDIR}/configs/activate_ovl_prot_mode_vdu.json
${DEACT_OVL_SA_RRC_REJ_TRUE_VDU}=    ${CURDIR}/configs/deactivate_ovl_prot_mode_vdu.json
${CREATE_OVL_SA_RRC_REJ_TRUE_VCU}=   ${CURDIR}/configs/create_rrc_timers_vcu.json
${DELETE_OVL_SA_RRC_REJ_TRUE_VCU}=   ${CURDIR}/configs/delete_rrc_timers_vcu.json
${TOPOLOGY_CONFIG}=                  /home/ute/testline_init_results/execution/configs/topology_configs/node_1
