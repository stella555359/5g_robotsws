# 1980 Jan  7  21:21:35.526  [AD]  0xB889  NR5G MAC RACH Attempt
Nr5gMacRachAttemptSuccess = \
  [
    {
      'Rach Result': 'SUCCESS'}
  ]

# 1980 Jan  7  21:21:35.526  [AD]  0xB889  NR5G MAC RACH Trigger
Nr5gMacRachTriggerReason =\
  [
    {
      'Rach Reason': 'CONNECTION_REQUEST'}
  ]

# 1980 Jan  9  14:51:24.390  [1C]  0xB0C0  LTE RRC OTA Packet  --  DL_DCCH / RRCConnectionReconfiguration
MeasGapSetup = \
  [
    {
      'criticalExtensions': {
        'c1': {
          'rrcConnectionReconfiguration-r8': {
            'measConfig': {
              'measGapConfig': {
                'setup': {
                  'gapOffset': {
                    'gp0': '19'}}}}}}}}
  ]

# 1980 Feb 13  01:57:47.180  [0C]  0xB821  NR5G RRC OTA Packet  --  UL_DCCH / MeasurementReport
measRepPCell3 = \
  [
    {
      'criticalExtensions': {
        'measurementReport': {
          'measResults': {
            'measId': '3'}}}}
  ]

# 1980 Feb 13  01:57:47.180  [0C]  0xB821  NR5G RRC OTA Packet  --  UL_DCCH / MeasurementReport
measRepPCell6 = \
  [
    {
      'criticalExtensions': {
        'measurementReport': {
          'measResults': {
            'measId': '6'}}}}
  ]

# 1980 Apr 20  22:15:33.670  [7F]  0xB821  NR5G RRC OTA Packet  --  DL_DCCH / RRCReconfiguration
dlBwpId1 = \
  [
    {
      'criticalExtensions': {
        'rrcReconfiguration': {
          'nonCriticalExtension': {
            'masterCellGroup': {
              'CONTAINING': {
                'spCellConfig': {
                  'spCellConfigDedicated': {
                    'downlinkBWP-ToAddModList': [{
                      'bwp-Id': '1'}]}}}}}}}}
  ]

# 1980 Apr 20  22:15:33.670  [7F]  0xB821  NR5G RRC OTA Packet  --  UL_DCCH / RRCReconfiguration
ulBwpId1 = \
  [
    {
      'criticalExtensions': {
        'rrcReconfiguration': {
          'nonCriticalExtension': {
            'masterCellGroup': {
              'CONTAINING': {
                'spCellConfig': {
                  'spCellConfigDedicated': {
                    'uplinkConfig': {
                      'uplinkBWP-ToAddModList': [{
                        'bwp-Id': '1'}]}}}}}}}}}
  ]

# 1980 Apr 20  22:15:33.670  [7F]  0xB821  NR5G RRC OTA Packet  --  DL_DCCH / RRCReconfiguration
dlBwpId2 = \
  [
    {
      'criticalExtensions': {
        'rrcReconfiguration': {
          'nonCriticalExtension': {
            'masterCellGroup': {
              'CONTAINING': {
                'spCellConfig': {
                  'spCellConfigDedicated': {
                    'downlinkBWP-ToAddModList': [{
                      'bwp-Id': '2'}]}}}}}}}}
  ]

# 1980 Apr 20  22:15:33.670  [7F]  0xB821  NR5G RRC OTA Packet  --  UL_DCCH / RRCReconfiguration
ulBwpId2 = \
  [
    {
      'criticalExtensions': {
        'rrcReconfiguration': {
          'nonCriticalExtension': {
            'masterCellGroup': {
              'CONTAINING': {
                'spCellConfig': {
                  'spCellConfigDedicated': {
                    'uplinkConfig': {
                      'uplinkBWP-ToAddModList': [{
                        'bwp-Id': '2'}]}}}}}}}}}
  ]

# 1980 Feb 13  23:58:15.364  [A1]  0xB821  NR5G RRC OTA Packet  --  UL_DCCH / RRCConfiguration Complete
rrcConfComp = \
  [
    {
      'criticalExtensions': {
        'rrcReconfigurationComplete': {
        }
      }
    }
  ]
