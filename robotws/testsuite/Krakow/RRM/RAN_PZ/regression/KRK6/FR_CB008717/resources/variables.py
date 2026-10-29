ue_attach_awaited_message_8CC_request = 'UEContextSetupRequest'
ue_attach_awaited_message_8CC_response = 'UEContextSetupResponse'
expected_scells_8CC = [1261731910, 1261731911, 1261731912, 1261731913, 1261731914, 1261731915, 1261731916, 1261731917]
expected_items_UEContextSetupResponse = [
    'SelectedBandCombinationIndex',
    'SelectedFeatureSetEntryIndex',
    'DUtoCURRCInformation',
    'sCellToAddModList',
    'CellGroupConfig',
    'sCellIndex',
    'sCellConfigCommon',
    'sCellConfigDedicated',
    'SCellConfig'
]
expected_items_RRCReconfiguration = [
    'sCellIndex',
    'sCellConfigCommon',
    'sCellConfigDedicated',
    'SCellConfig',
    'csi-ReportConfigToAddModList',
    'csi-MeasConfig: setup (1)',
    'ReportConfigToAddModList',
    'csi-ResourceConfigId',
    'CellGroupConfig',
    'SCellConfig',
    'sCellConfigDedicated',
    'downlinkBWP-ToAddModList: 1 item',
    'bwp-Dedicated',
    'pdcch-Config: setup (1)',
    'controlResourceSetToAddModList',
    'CellGroupConfig',
    'SCellConfig',
    'sCellConfigCommon',
    'downlinkConfigCommon',
    'scs-SpecificCarrierList: 1 item',
    'offsetToCarrier',
]
ue_detach_awaited_message = 'UEContextReleaseComplete'
