*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Arun Velusamy
...                 :contact  : arun.velusamy@nokia.com
...                 :Feature CB010981 Related all common Variables.


*** Variables ***
${PDU_ID1}			1
${QFI_2}			2
${QFI_3}			3
${QFI_5}			5
${QFI_6}			6
${TP_CNT}			0
${kbps}				kbps
${DELTA}			500
${TIMEOUT1}			200
&{WEBSERVICES}      host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...             user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...             password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...             port=443
${FILTER_BFAF_TRUE}		UlData_puschReceiveReqSubcell_t.csi2EnhancedDetection == True && 3gpp.rnti != 65521
${FILTER_BFAF_FALSE}	UlData_puschReceiveReqSubcell_t.csi2EnhancedDetection != True && 3gpp.rnti != 65521
${FIELD_BFAF}			UlData_puschReceiveReqSubcell_t.csi2EnhancedDetection
${FIELD_dtxCsiPart1}	UlData_UePuschReceiveRespPs_t.dtxCsiPart1
${FIELD_dtxCsiPart2}	UlData_UePuschReceiveRespPs_t.dtxCsiPart2
${FIELD_crc}			UlData_UePuschReceiveRespPs_t.crc
${FIELD_numOfUciCsiPart2Bits}	UlData_UePuschReceiveRespPs_t.numOfUciCsiPart2Bits
${FIELDS}	${FIELD_dtxCsiPart1} -e ${FIELD_dtxCsiPart2} -e ${FIELD_crc} -e ${FIELD_numOfUciCsiPart2Bits}
${FILTER_CB010981}		${FIELD_dtxCsiPart1}== 1 && ${FIELD_dtxCsiPart2} == 0
...						 && 3gpp.rnti != 65521
${ACSI_pattern}			aperiodicTriggerStateList
${initial_cfg_file}		Delta_initial_cfg.json
${TDD_ACSI_file}		Delta_enable_ACSI_TDD.json
${Reqs_enabling_file}	Delta_Reqs_enabling.json
${FAF_activation_file}	Delta_CB010981_FAF_true.json
${FAF_deactivation_file}	Delta_CB010981_FAF_false.json
${PDU_SESS_MODIFY}			Added QosFlow with QFI
${CNT_TP_ENB}			M55113C00019
${CNT_TP_DISB}			M55113C00020
${DFTS_INI_R1_PMQAP}	M55386C00063
@{PMQAP_LIST}			6	5	1