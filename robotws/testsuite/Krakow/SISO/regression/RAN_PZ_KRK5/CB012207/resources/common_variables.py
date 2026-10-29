TPUT_MATRIX = {
    'linux_congestion': 'Reno',
    'parallel_streams': '4',
    'buffer_client': None,
    'buffer_server': None,
    'size_packet': '1320B',
    'interval': '1',
    'NRCELL-901': {
        'DL': {
            'tput': '4000 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': 8,
        },
        'UL': {
            'tput': '500 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '4',
        },
        'global_cell_id': '1',
        'real_cell_id': '1248788481',
    },
    'NRCELL-901_220': {
        'DL': {
            'tput': '4000 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': 8,
        },
        'UL': {
            'tput': '500 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '4',
        },
        'bts_id': 1,
        'global_cell_id': '1',
        'real_cell_id': '1248788481',
    },
    'NRCELL-801': {
        'DL': {
            'tput': '2000 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': 8,
        },
        'UL': {
            'tput': '500 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '4',
        },
        'bts_id': 1,
        'global_cell_id': '1',
        'real_cell_id': '1248329729',
    },
    'NRCELL-801_220': {
        'DL': {
            'tput': '2000 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': 8,
        },
        'UL': {
            'tput': '500 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '4',
        },
        'bts_id': 1,
        'global_cell_id': '1',
        'real_cell_id': '1248329729',
    },
    'NRCELL-801_2': {
        'DL': {
            'tput': '3000 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'tput_target': '2300 Mbits/sec',
        },
        'UL': {
            'tput': '300 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'tput_target': '240 Mbits/sec',
        },
        'bts_id': 1,
        'global_cell_id': '1',
        'real_cell_id': '1248329729',
    },
    'NRCELL-801_4': {
        'DL': {
            'tput': '10 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
        },
        'UL': {
            'tput': '10 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',

        },
        'bts_id': 1,
        'global_cell_id': '1',
        'real_cell_id': '1248329729',
    },
    'NRCELL-803_2': {
        'DL': {
            'tput': '3000 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'tput_target': '2300 Mbits/sec',
        },
        'UL': {
            'tput': '300 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'tput_target': '240 Mbits/sec',
        },
        'bts_id': 1,
        'global_cell_id': '3',
        'real_cell_id': '1248329731',
    },

}


pcap_messages = {
    'xnlink_creation': [
        # Request and Response from GNB0
        {
            'display_filter': 'xnap.gnb_ID and ip.src_host == 10.84.150.192',
            'field_name': 'xnap.gnb_ID',
            'field_values':
                ['gnb-ID: 04a680 [bit length 22, 2 LSB pad bits, 0000 0100  1010 0110  1000 00.. decimal value 76192]'],
            'nr_of_packets': 1
        },
        # Request and Response from GNB1
        {
            'display_filter': 'xnap.gnb_ID and ip.src_host == 10.84.150.220',
            'field_name': 'xnap.gnb_ID',
            'field_values':
                ['gnb-ID: 04a6f0 [bit length 22, 2 LSB pad bits, 0000 0100  1010 0110  1111 00.. decimal value 76220]'],
            'nr_of_packets': 1
        }
    ],
    'adding_cell': [
        # Message NGRANNodeConfigurationUpdate
        {
            'display_filter': 'xnap.served_Cells_ToAdd_NR',
            'field_name': 'xnap.served_Cells_ToAdd_NR',
            'field_values': ['served-Cells-ToAdd-NR: 1 item'],
            'nr_of_packets': 1
        },
        {
            'display_filter': 'xnap.nrPCI',
            'field_name': 'xnap.nrPCI',
            'field_values': ['nrPCI: 904'],
            'nr_of_packets': 1
        },
        {
            'display_filter': 'xnap.nrARFCN',
            'field_name': 'xnap.nrARFCN',
            'field_values': ['nrARFCN: 2062507'],
            'nr_of_packets': 1
        },
        {
            'display_filter': 'xnap.nr_frequency_band',
            'field_name': 'xnap.nr_frequency_band',
            'field_values': ['nr-frequency-band: 257'],
            'nr_of_packets': 1
        },
        {
            'display_filter': 'xnap.eNDC_Support',
            'field_name': 'xnap.eNDC_Support',
            'field_values': ['eNDC-Support: not-supported (1)'],
            'nr_of_packets': 1
        },
        # Message NGRANNodeConfigurationUpdateAcknowledge
        {
            'display_filter': 'xnap.RespondingNodeTypeConfigUpdateAck',
            'field_name': 'xnap.RespondingNodeTypeConfigUpdateAck',
            'field_values': ['RespondingNodeTypeConfigUpdateAck: gNB (1)'],
            'nr_of_packets': 1
        }
    ],
    'removing_cell': [
        # Message NGRANNodeConfigurationUpdate
        {
            'display_filter': 'xnap.served_Cells_ToDelete_NR',
            'field_name': 'xnap.served_Cells_ToDelete_NR',
            'field_values': ['served-Cells-ToDelete-NR: 1 item'],
            'nr_of_packets': 1
        },
        {
            'display_filter': 'xnap.NR_Cell_Identity',
            'field_name': 'xnap.NR_Cell_Identity',
            'field_values': ['0000 0100 1010 0110 1111 0000 0000 0000 0100 .... = nr-CI: 0x04a6f0004'],
            'nr_of_packets': 1
        },
        # Message NGRANNodeConfigurationUpdateAcknowledge
        {
            'display_filter': 'xnap.RespondingNodeTypeConfigUpdateAck',
            'field_name': 'xnap.RespondingNodeTypeConfigUpdateAck',
            'field_values': ['RespondingNodeTypeConfigUpdateAck: gNB (1)'],
            'nr_of_packets': 1
        }
    ],
    'mobility_profiles': [
        {
            'display_filter': 'xnap.indexToRatFrequencySelectionPriority',
            'field_name': 'xnap.indexToRatFrequencySelectionPriority',
            'field_values': ['indexToRatFrequencySelectionPriority: 100'],
            'nr_of_packets': 1
        },
    ],
    'ecid': [
        {
            'display_filter': '((nrppa)\
                              && (nrppa.ReportCharacteristics == 0)\
                              && (nrppa.measurementQuantitiesValue == 11)\
                              && (nrppa.measurementQuantitiesValue == 6)\
                              && (nrppa.measurementQuantitiesValue == 7)\
                              && (nrppa.measurementQuantitiesValue == 0))\
                              && !(nsetapx.traceActivationType == 0)',
            'field_name': 'nrppa.ReportCharacteristics',
            'field_values': ['ReportCharacteristics: onDemand (0)'],
            'nr_of_packets': 1
        },
        {
            'display_filter': '((nrppa)\
                               && (nrppa.NRPPA_PDU == 1)\
                               && (nrppa.nG_RANcell == 1)\
                               && (nrppa.ResultSS_RSRP == 3)\
                               && (nrppa.ResultSS_RSRQ == 3)\
                               && (nrppa.sS_RSRP_PerSSB == 8)\
                               && (nrppa.sS_RSRQ_PerSSB == 8))\
                               && !(nsetapx.traceActivationType == 0)',
            'field_name': 'nrppa.nG_RANcell',
            'field_values': ['nG-RANcell: nR-CellID (1)'],
            'nr_of_packets': 1
        },
        {
            'display_filter': '((nrppa)\
                               && (nrppa.NRPPA_PDU == 1)\
                               && (nrppa.nG_RANcell == 1)\
                               && (nrppa.ResultSS_RSRP == 3)\
                               && (nrppa.ResultSS_RSRQ == 3)\
                               && (nrppa.sS_RSRP_PerSSB == 8)\
                               && (nrppa.sS_RSRQ_PerSSB == 8))\
                               && (nsetapx.traceActivationType == 0)',
            'field_name': 'nsetapx.traceActivationType',
            'field_values': ['traceActivationType: mba (0)'],
            'nr_of_packets': 1
        },
    ],
}

bip_messages = {
    'dlDMRS_no_additional': [
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsConfigType',
            'field_values': ['dlDmrsConfigType (l1_common_dlDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsLen',
            'field_values': ['dlDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsMappingType',
            'field_values': ['dlDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_A (0)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsAddPos',
            'field_values': ['dlDmrsAddPos (Uint8): 0'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsTypeAPos',
            'field_values': ['dlDmrsTypeAPos (Uint8): 2'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlPtrsFlag',
            'field_values': ['dlPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsConfigType',
            'field_values': ['ulDmrsConfigType (l1_common_ulDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsLen',
            'field_values': ['ulDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsMappingType',
            'field_values': ['ulDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_B (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsAddPos',
            'field_values': ['ulDmrsAddPos (Uint8): 0'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulPtrsFlag',
            'field_values': ['ulPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        },
    ],
    'dlDMRS_one_additional': [
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsConfigType',
            'field_values': ['dlDmrsConfigType (l1_common_dlDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsLen',
            'field_values': ['dlDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsMappingType',
            'field_values': ['dlDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_A (0)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsAddPos',
            'field_values': ['dlDmrsAddPos (Uint8): 1', 'dlDmrsAddPos (Uint8): 2'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsTypeAPos',
            'field_values': ['dlDmrsTypeAPos (Uint8): 2'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlPtrsFlag',
            'field_values': ['dlPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsConfigType',
            'field_values': ['ulDmrsConfigType (l1_common_ulDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsLen',
            'field_values': ['ulDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsMappingType',
            'field_values': ['ulDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_B (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsAddPos',
            'field_values': ['ulDmrsAddPos (Uint8): 0'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and 3gpp.rnti != 65521 and \
                               uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulPtrsFlag',
            'field_values': ['ulPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw and \
                               DlData_PdschGrantL1sw.mcs > 4",
            'field_name': 'DlData_PdschGrantL1sw.numOfDmrsCdmGroupWithoutData',
            'field_values': ['numOfDmrsCdmGroupWithoutData (Uint8): 1'],
        },
    ],
    'ulDMRS_no_additional': [
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsConfigType',
            'field_values': ['dlDmrsConfigType (l1_common_dlDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsLen',
            'field_values': ['dlDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsMappingType',
            'field_values': ['dlDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_A (0)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsAddPos',
            'field_values': ['dlDmrsAddPos (Uint8): 0'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsTypeAPos',
            'field_values': ['dlDmrsTypeAPos (Uint8): 2'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlPtrsFlag',
            'field_values': ['dlPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsConfigType',
            'field_values': ['ulDmrsConfigType (l1_common_ulDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsLen',
            'field_values': ['ulDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsMappingType',
            'field_values': ['ulDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_B (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsAddPos',
            'field_values': ['ulDmrsAddPos (Uint8): 0'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulPtrsFlag',
            'field_values': ['ulPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        }
    ],
    'ulDMRS_one_additional': [
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsConfigType',
            'field_values': ['dlDmrsConfigType (l1_common_dlDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsLen',
            'field_values': ['dlDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsMappingType',
            'field_values': ['dlDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_A (0)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsAddPos',
            'field_values': ['dlDmrsAddPos (Uint8): 0'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlDmrsTypeAPos',
            'field_values': ['dlDmrsTypeAPos (Uint8): 2'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and dldata_pdschsendreql1sw",
            'field_name': 'DlData_PdschGrantL1sw.dlPtrsFlag',
            'field_values': ['dlPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsConfigType',
            'field_values': ['ulDmrsConfigType (l1_common_ulDmrsConfigType_t): DMRS_CONFIG_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsLen',
            'field_values': ['ulDmrsLen (l1_common_dmrsLen_t): NR_SYMBOLS_1 (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsMappingType',
            'field_values': ['ulDmrsMappingType (l1_common_dmrsMappingType_t): DMRS_MAPPING_TYPE_B (1)'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulDmrsAddPos',
            'field_values': ['ulDmrsAddPos (Uint8): 1'],
        },
        {
            'display_filter': "3gpp.rnti != 65535 and 3gpp.rnti != 65521 and uldata_puschreceivereq",
            'field_name': 'UlData_puschReceiveReqGrant_t.ulPtrsFlag',
            'field_values': ['ulPtrsFlag (l1_common_PtrsFlag): PTRS_ON (1)'],
        }
    ]
}

COUNTERS = {
    'Xn_counters_76192': {
        'M55126C00032': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NXNCB']['M55126C00032']",
            "value": 1,
            "condition": ">="
        },
        'M55126C00033': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NXNCB']['M55126C00033']",
            "value": 1,
            "condition": ">="
        },
    },
    'Xn_counters_76220': {
        'M55126C00029': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NXNCB']['M55126C00029']",
            "value": 1,
            "condition": ">="
        },
        'M55126C00030': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NXNCB']['M55126C00030']",
            "value": 1,
            "condition": ">="
        },
    },
    'Periodic_measurements_source': {
        'M55113C01001': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NF1CC']['M55113C01001']",
            "value": 1,
            "condition": ">="
        },
        'M55113C01002': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NF1CC']['M55113C01002']",
            "value": 1,
            "condition": ">="
        },
        'M55117C01001': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRDU-1']['NF1CD']['M55117C01001']",
            "value": 1,
            "condition": ">="
        },
        'M55117C01009': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRDU-1']['NF1CD']['M55117C01009']",
            "value": 1,
            "condition": ">="
        },
        'M55117C01010': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRDU-1']['NF1CD']['M55117C01010']",
            "value": 1,
            "condition": ">="
        },
        'M55143C00001': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NXNCC']['M55143C00001']",
            "value": 1,
            "condition": ">="
        },
        'M55143C00004': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NXNCC']['M55143C00004']",
            "value": 1,
            "condition": ">="
        },
        'M55143C00005': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NXNCC']['M55143C00005']",
            "value": 0,
            "condition": "=="
        },
        'M55143C00006': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NXNCC']['M55143C00006']",
            "value": 0,
            "condition": "=="
        },
    },
    'Periodic_measurements_target': {
        'M55113C01001': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NF1CC']['M55113C01001']",
            "value": 1,
            "condition": ">="
        },
        'M55113C01002': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NF1CC']['M55113C01002']",
            "value": 1,
            "condition": ">="
        },
        'M55117C01001': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRDU-1']['NF1CD']['M55117C01001']",
            "value": 1,
            "condition": ">="
        },
        'M55117C01009': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRDU-1']['NF1CD']['M55117C01009']",
            "value": 0,
            "condition": ">="
        },
        'M55117C01010': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRDU-1']['NF1CD']['M55117C01010']",
            "value": 0,
            "condition": ">="
        },
        'M55143C00001': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NXNCC']['M55143C00001']",
            "value": 0,
            "condition": "=="
        },
        'M55143C00004': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NXNCC']['M55143C00004']",
            "value": 0,
            "condition": "=="
        },
        'M55143C00005': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NXNCC']['M55143C00005']",
            "value": 1,
            "condition": ">="
        },
        'M55143C00006': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NXNCC']['M55143C00006']",
            "value": 1,
            "condition": ">="
        },
    },
    'Intra-gNB HO': {
        'M55147C00001': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NMOCU']['M55147C00001']",
            "value": 0,
            "condition": ">="
        },
        'M55153C00001': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NMOCU']['M55153C00001']",
            "value": 0,
            "condition": ">="
        },
        'M55153C00002': {
            "formula": "response['BTS']['MRBTS-76220']['NRBTS-76220']['NRCELL-1']['NMOCU']['M55153C00002']",
            "value": 0,
            "condition": ">="
        },
    },
    'Mobility Profiles': {
        'M55157C00034': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NRMOP']['M55157C00034']",
            "value": 1,
            "condition": ">="
        },
    },
    'CB008285_B_008_1': {
        'M55119C00001': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NNGCB']['M55119C00001']",
            "value": 1,
            "condition": ">="
        },
        'M55119C00002': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NNGCB']['M55119C00002']",
            "value": 1,
            "condition": ">="
        }
    },
    'CB008285_B_008_2': {
        'M55119C00501': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NNGCB']['M55119C00501']",
            "value": 1,
            "condition": ">="
        }
    },
    'Xnlink_locked': {
        'M55126C00008': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NXNCB']['M55126C00008']",
            "value": 1,
            "condition": ">="
        }
    },
    'Intra_freq_intra_gnb_HO_based_on_A3': {
        'M55147C00001': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NMOCU']['M55147C00001']",
            "value": 1,
            "condition": ">="
        },
        'M55153C00001': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NRCI-1248329731']['MCC-001']\
                       ['MNC-01']['NRREL']['M55153C00001']",
            "value": 1,
            "condition": ">="
        },
        'M55153C00002': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NRCI-1248329731']['MCC-001']\
                       ['MNC-01']['NRREL']['M55153C00002']",
            "value": 1,
            "condition": ">="
        },
    },
    'Ecid': {
        'M55125C00024': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NNGCC']['M55125C00024']",
            "value": 1,
            "condition": ">="
        },
        'M55125C00025': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NNGCC']['M55125C00025']",
            "value": 1,
            "condition": ">="
        },
        'M55113C00013': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NF1CC']['M55113C00013']",
            "value": 0,
            "condition": "=="
        },
        'M55113C00014': {
            "formula": "response['BTS']['MRBTS-76192']['NRBTS-76192']['NRCELL-1']['NF1CC']['M55113C00014']",
            "value": 0,
            "condition": "=="
        },
    }
}

additional_alarms = {
    'scf_load': ['No Xn link available'],
}
