from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

nr_only = [
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRDRB-6".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nsaDrbParam", "value": [
             {
              "dlDataSplitMode": "dlOverF1U",
              "ulDataPath": "ulOverNr",
              "ulDataSplitThreshold": "infinity",
              "actPrioritizeX2AfterInactivity": "false",
              "actX2DuplicateTxNSA3x": "false",
              "dlDataSplitBufferBuildUpThreshold": "5",
              "dlDataSplitBufferBuildUpThresholdPrioritizeX2": "5",
              "dlDataSplitGainThreshold": "5",
              "dlNumOfCongOrGainDdds": "2",
              "inactivityThresholdForPrioritizeX2": "300",
              "inactivityThresholdForRestartPrioritizeX2": "100",
              "initialDLTrafficRouting": "initDLoverX2U",
              "nsa3xBearerAllowed": "true",
              "prioritizeX2Period": "500",
              "inactPeriodX2PdcpDuplication": "300",
             }

             ], "operation": "update"
          }]},
    {"distName": "MRBTS-{0}/NRBTS-{0}".format(bts_id), "operation": "update",
        "parameters": [
         {"parameterName": "nsaInactivityTimer", "value": "300", "operation": "update"}
     ]},
    ]

nr_lte = [
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRDRB-6".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nsaDrbParam", "value": [
             {
              "dlDataSplitMode": "dlOverF1UX2U",
              "ulDataPath": "ulOverLteNr_PrimaryPathOverNr",
              "ulDataPathForUlSplitNotCapableUe": "ulPrimaryPathOverNr",
              "dlPreferredPath": "F1-U",
              "ulDataSplitThreshold": "b51200",
              "actPrioritizeX2AfterInactivity": "false",
              "actX2DuplicateTxNSA3x": "false",
              "dlDataSplitBufferBuildUpThreshold": "5",
              "dlDataSplitBufferBuildUpThresholdPrioritizeX2": "5",
              "dlDataSplitGainThreshold": "5",
              "dlNumOfCongOrGainDdds": "2",
              "inactivityThresholdForPrioritizeX2": "300",
              "inactivityThresholdForRestartPrioritizeX2": "100",
              "initialDLTrafficRouting": "initDLoverX2U",
              "nsa3xBearerAllowed": "true",
              "prioritizeX2Period": "500",
              "inactPeriodX2PdcpDuplication": "300",
             }

             ], "operation": "update"
          }]},

    {"distName": "MRBTS-{0}/NRBTS-{0}".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nsaInactivityTimer", "value": "300", "operation": "update"}
     ]},
]
