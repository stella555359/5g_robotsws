*** Settings ***

*** Variables ***

*** Keyword ***
Check PCMD Record In vDU
    [Arguments]  ${file_list}
    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}

    @{msg_list_1}  create list  startRecordingSession
    ...  ueCtxSetupRecord
    ...  timingAdvanceRecord
    ...  ulSchedulingRecord
    ...  dlSchedulingRecord
    ...  beamUsageRecord
    ...  dlRbRlcMeasRecord
    ...  ulRbRlcMeasRecord
    ...  stopRecordingSession


    @{msg_list_2}  create list  endMarker
    ...  recordCollectionDuration
    ...  timeOfUeSched
    ...  numOf1stMacPduTx
    ...  numOfBad1stMacPduTx
    ...  numOfBadLastMacPduTx
    ...  numOfPuschTxWithRank1
    ...  numOfPuschTxWithRank2
    ...  numOfPdschTxWithRank1
    ...  numOfPdschTxWithRank2
    ...  numOfPdschTxWithRank3
    ...  numOfPdschTxWithRank4
    ...  avgTb0WbCqi
    ...  sumOfWbCqi
    ...  numOfWbCqiSamples
    ...  numOfTotalBeamChanges
    ...  numOfFailedBeamChanges
    ...  numOfTotalBeamRecoveries
    ...  numOfSuccessfulBeamRecoveries
    ...  beamUsageHistoryList
    ...  numOfWbCqiSamples
    ...  drb-Id
    ...  dataCollectionDuration
    ...  timeOfUePduTx
    ...  sumOfRlcPduTxBytes
    ...  timeOfUePduRx
    ...  sumOfRlcPduRxBytes

    Check PCMD MSG In Emil TXT File   ${txt_file}   @{msg_list_1}
    Check PCMD MSG In Emil TXT File   ${txt_file}   @{msg_list_2}

Check PCMD Record In vCU
    [Arguments]  ${file_list}
    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}

    @{msg_list_1}  create list  startRecordingSession
    ...  ueDuConnectivityRecord
    ...  ueSetupRecord
    ...  pduSessionResourceInfoRecord
    ...  stopRecordingSession


    @{msg_list_2}  create list  startRecordingSession
    ...  rrcSetupRequest
    ...  rrcSetup
    ...  rrcSetupComplete
    ...  InitialUEMessage
    ...  DownlinkNASTransport
    ...  dlInformationTransfer
    ...  ulInformationTransfer
    ...  UplinkNASTransport
    ...  InitialContextSetupRequest
    ...  securityModeCommand
    ...  ueCapabilityEnquiry
    ...  securityModeComplete
    ...  ueCapabilityInformation
    ...  UERadioCapabilityInfoIndication
    ...  rrcReconfiguration
    ...  rrcReconfigurationComplete
    ...  InitialContextSetupResponse
    ...  PDUSessionResourceSetupRequest
    ...  PDUSessionResourceSetupResponse
    ...  PDUSessionResourceReleaseCommand
    ...  PDUSessionResourceReleaseResponse
    ...  UEContextReleaseCommand
    ...  UEContextReleaseComplete
    ...  rrcRelease
    ...  stopRecordingSession

    @{msg_list_3}  create list  measurementReport
	...  intragNBHoSrcRecord
	...  intragNBHoTgtRecord

    Check PCMD MSG In Emil TXT File   ${txt_file}   @{msg_list_1}
    Check PCMD MSG In Emil TXT File   ${txt_file}   @{msg_list_2}
    Check PCMD MSG In Emil TXT File   ${txt_file}   @{msg_list_3}
