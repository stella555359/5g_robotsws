mimoMode4x4 = [  # rrcreconfiguration
    {'criticalExtensions': {'rrcReconfiguration': {'secondaryCellGroup': {'CONTAINING': {
        'spCellConfig': {'spCellConfigDedicated': {
            'pdsch-ServingCellConfig': {'setup': {'maxMIMO-Layers': '4'}}}}}}}}}
]

NR5G_MAC_RACH_Attempt_SUCCESS = [
    {'RACH Result': 'SUCCESS'}
]

# Filter dictionnary
PCI_Filter = [{'PCI': 50}]

# Variable for Old Qcat Version
mask_0xB97F_0xB891_0xB868 = {'Version.Component Carrier List.Cells.Detected Beams': ['NR2NR Filtered Tx Beam RSRP L3',
                                                                                     'NR2NR Filtered Tx Beam RSRQ L3',
                                                                                     'SSB Index'],
                             'Version.Component Carrier List': ['Serving Cell PCI', 'Serving SSB']}
#                             'Version.Records': ['Report Quantity', 'Carrier Id', 'Valid RSRP', 'RSRP 1',
#                                                 'RSRP 2', 'RSRP 3', 'RSRP 4', 'Reason']}

mask_rach_test_1668_SB_27_Step1 = {'Version': ['C RNTI', 'Serving Beam SSB Index', 'Tx Beam Index',
                                               'SSB ID', 'RACH Result', 'Contention Type']}

mask_rach_test_1668_SB_27_Step2 = {'Version': ['C RNTI', 'T RNTI', 'Serving Beam SSB Index',
                                               'SSB ID', 'RACH Result', 'Contention Type',
                                               'Num CRC Pass TB', 'Num CRC Fail TB', 'BLER',
                                               'Phychan Bit Mask', 'TX Type']}

# Variables for new Qcat Version
SSB_idx_1668 = ['4', '5', '6', '7', '12', '13', '14', '15', '20', '21', '22', '23', '28', '29', '30', '31', '36', '37',
                '38', '39', '44', '45', '46', '47', '52', '53', '54', '55', '60', '61', '62', '63']

mask_0xB97F_0xB8A7 = {'Version.Component Carrier List.Cells.Detected Beams': ['NR2NR Filtered Tx Beam RSRP L3',
                                                                              'NR2NR Filtered Tx Beam RSRQ L3',
                                                                              'SSB Index'],
                      'Version.Component Carrier List': ['Serving Cell PCI', 'Serving SSB'],
                      'Version.Records.Reports[0]': ['Report Quantity Bitmask', 'Report Type', 'Carrier Id',
                                                     'Num Results', 'SSBRI CRI']}

mask_0xB889_0xB88A = {'Version': ['Num Attempts',
                                  'SSB ID',
                                  'CSI-RS ID',
                                  'RACH Result',
                                  'Contention Type',
                                  'CRNTI',
                                  'C_RNTI',
                                  'Rach Reason',
                                  'Carrier Id',
                                  'Carrier ID',
                                  'RACH Contention']}


# for HO 0xB9BE  NR5G ML1 Search HO Acq Req
#        0xB9BF  NR5G ML1 Search HO Acq Confirm
