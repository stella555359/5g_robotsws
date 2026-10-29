SR_GD_B3_TC05 = {
    "UPlane": "Updating uplane carriers",
    "Shutdown req": "Send ShutdownReq.",
    "Shutdown resp": "Received ShutdownResp.",
    "Graceful Shutdown candidate": r"Cell with nrCellIdentity: \d+ subscribes for GracefulShutdownResp",
    "Schedule": r"Shutdown scheduled for cell with nrCellIdentity: \d+",
    "Success": r"Shutdown succeeded for cell with nrCellIdentity: \d+",
}
MB_B4 = {
    "overload state": "Measurement Report was discarded due to overload protection state",
    "Supervision timer": "SupervisionTimer started.",
    "Retry timer": "RetryTimer started.",
    "SNAddition": "SNodeAdditionRequest sent",
    "SNAddition resp": "NR-DC SNodeAddition - MN Side: entering End state",
}
B2_MFBI = {
    "MFBI": "IsActMultiFreqBandIndicatorNr :=true, targetCellId :=833258054, nativeBand :=25, selectedBand := 2",
    "Counter": "Add counter 3613524471 on cellId :=833258054",
    "Bands": r"bandListForCurrentCell: \[25, 2\]",
    "Band Combinations": "Check bands in selectedBandCombinationIndex 6",
    "Match": "Match bandNR 2, continue",
    "MFBI2": "IsActMultiFreqBandIndicatorNr :=true, targetCellId :=833258054, nativeBand :=25, selectedBand := 2"
}
XN_HO_AND_UERADIOCAPABILITYINFOINDICATION_FIELD_PCAP_FLOW = \
    ["HandoverRequest", "HandoverRequestAcknowledge", "PathSwitchRequest",
     "PathSwitchRequestAcknowledge", "UERadioCapabilityInfoIndication", "includeNR-DC: true"]
NG_HO_AND_SNODE_ADDITION_PCAP_FLOW = \
    ["HandoverRequest", "HandoverRequestAcknowledge", "DownlinkRANStatusTransfer", "HandoverNotify",
     "UERadioCapabilityInfoIndication", "includeNR-DC: true", "SNodeAdditionRequest",
     "SNodeAdditionRequestAcknowledge", "SNodeReconfigurationComplete"]
REESTABLISHMENT_WITH_A2_REDIRECT = ["rrcReestablishmentRequest", "RRCReEstablishment ", "UEContextModificationRequest",
                                    "eventA2", "eventA4", "SNodeAdditionRequest", "SNodeReconfigurationComplete"]
MB_B2_A2 = {
    "A2": r"Received measId: \d+, measConfigContext: \(MeasId, MeasType\) "
          r"(\[measId:\d+, measurementType:(?:IntraFreqPeriodicForMdt|A2Redirection|A4NrdcPscellAddition)\]){3}",
    "Retry": "RetryTimer started",
    "Retry_end": "RetryTimer expired",
    "Supervision": "SupervisionTimer started",
    "retry2": "RetryTimer started"
}
NGCONFIGURATION_TAC_UPDATE = ["NGRANNodeConfigurationUpdate", "tac: 7151", "sd: d143a0", "sd: d143a7",
                              "served-Cells-ToModify-NR: 2 items", "NGRANNodeConfigurationUpdateAcknowledge"]
XNSETUPS = ["XnSetupRequest", "XnSetupFailure", "radioNetwork: cell-not-available", "XnSetupRequest", "XnSetupResponse"]
MA_B1 = {"timer": "Timers are now subscribed.",
         "sup_start": "SupervisionTimer started.",
         "sup_stop": "SupervisionTimer expired.",
         "meas_not_started_4": "MeasActBlockTimer not started. Supervisions without coverage so far: 4",
         "retry_start": "RetryTimer started.",
         "retry_stop": "RetryTimer expired.",
         "meas_started": "MeasActBlockTimer started.",
         "meas_stop": "MeasActBlockTimer expired."
         }
SHUTDOWN_XN_LINK = ['SHUTDOWN', 'SHUTDOWN_ACK', 'SHUTDOWN_COMPLETE']
DYNAMIC_REMOVAL = ['UEContextModificationRequest', 'measObjectId: 2', 'ssbFrequency: 2268379', 'measObjectId: 3',
                   'ssbFrequency: 2266651', 'reportConfigId: 2', 'eventA4', 'measIdToAddModList: 3 items', 'measId: 2',
                   'measObjectId: 2', 'reportConfigId: 2', 'NGRANNodeConfigurationUpdate',
                   'served-Cells-ToDelete-NR: 1 item', 'UEContextModificationRequest', 'measIdToAddModList: 2 items']
