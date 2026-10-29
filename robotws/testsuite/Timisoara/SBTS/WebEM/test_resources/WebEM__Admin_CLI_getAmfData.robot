*** Settings ***
Documentation
    ...  This test case gets AmfData via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Check getAmfData command via ADMIN CLI to be send with error code 0.
    ...  Check all parameters to be present in CLI response.
    ...  actCli parameter is changed to be false.


Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_getAmfData
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28566
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28566 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS25  FEATURE-CB010545

    Step1: Change ActCli Parameter To Be true
    Step2: Sending GetAmfData Command Via ADMIN CLI
    Step3: Check Output From GetAmfData Command
    Step4: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  Step${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Sending GetAmfData Command Via ADMIN CLI
    Log  \nStep2: Sending GetAmfData Command Via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Log  \nSending command via Admin CLI for getSwVersionStatus...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"getAmfData"}}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    Set Test Variable  ${REQUEST_MESSAGE}


Step3: Check Output From GetAmfData Command
    Log  \nStep3: Check Output From GetAmfData Command  console=true
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}  btsName  msg=In request message for getAmfData command is not btsName parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}  btsId  msg=In request message for getAmfData command is not btsId parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}  currentTime  msg=In request message for getAmfData command is not currentTime parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}  amfInfos  msg=In request message for getAmfData command is not amfInfos parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}[amfInfos]  SERVEDAMF-1  msg=In amfInfos for getAmfData command is not SERVEDAMF-1 parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1]  amfName
    ...  msg=In ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1] for getAmfData command is not amfName parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1]  ngLinkStatus
    ...  msg=In ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1] for getAmfData command is not ngLinkStatus parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1]  amfIPAddress
    ...  msg=In ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1] for getAmfData command is not amfIPAddress parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1]  amfIPAddressResolved
    ...  msg=In ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1] for getAmfData command is not amfIPAddressResolved parameter!
    Dictionary Should Contain Key  ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1]  details
    ...  msg=In ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1] for getAmfData command is not details parameter!
    ${details_dir}  Set Variable  ${REQUEST_MESSAGE}[amfInfos][SERVEDAMF-1][details]
    Dictionary Should Contain Key  ${details_dir}  guAMI  msg=In ${details_dir} for getAmfData command is not guAMI parameter!
    Dictionary Should Contain Key  ${details_dir}  localCuIpAddr  msg=In ${details_dir} for getAmfData command is not localCuIpAddr parameter!
    Dictionary Should Contain Key  ${details_dir}  relativeAMFCapacity
    ...  msg=In ${details_dir} for getAmfData command is not relativeAMFCapacity parameter!
    Dictionary Should Contain Key  ${details_dir}  defaultAMF  msg=In ${details_dir} for getAmfData command is not defaultAMF parameter!
    ${guAMI_list}  Set Variable  ${details_dir}[guAMI]
    FOR  ${item}  IN  @{guAMI_list}
      Dictionary Should Contain Key  ${item}  amfPointer  msg=In guAMI for getAmfData command is not amfPointer parameter!
      Dictionary Should Contain Key  ${item}  amfRegionID  msg=In guAMI for getAmfData command is not amfRegionID parameter!
      Dictionary Should Contain Key  ${item}  amfSetID  msg=In guAMI for getAmfData command is not amfSetID parameter!
      Dictionary Should Contain Key  ${item}  guamiStatus  msg=In guAMI for getAmfData command is not guamiStatus parameter!
      Dictionary Should Contain Key  ${item}  mcc  msg=In guAMI for getAmfData command is not mcc parameter!
      Dictionary Should Contain Key  ${item}  mnc  msg=In guAMI for getAmfData command is not mnc parameter!
      Dictionary Should Contain Key  ${item}  mncLength  msg=In guAMI for getAmfData command is not mncLength parameter!
    END
    ${nrplmn_list}  Get Matches  ${details_dir}  NRPLMN_SUPPORT-*
    FOR  ${nrplmn}  IN  @{nrplmn_list}
      Dictionary Should Contain Key  ${details_dir}[${nrplmn}]  mcc  msg=In ${nrplmn} for getAmfData command is not mcc parameter!
      Dictionary Should Contain Key  ${details_dir}[${nrplmn}]  mnc  msg=In ${nrplmn} for getAmfData command is not mnc parameter!
      Dictionary Should Contain Key  ${details_dir}[${nrplmn}]  mncLength  msg=In ${nrplmn} for getAmfData command is not mncLength parameter!
      Dictionary Should Contain Key  ${details_dir}[${nrplmn}]  snssaiAMFNumber
      ...  msg=In ${nrplmn} for getAmfData command is not snssaiAMFNumber parameter!
      Dictionary Should Contain Key  ${details_dir}[${nrplmn}]  snssaiAMFList  msg=In ${nrplmn} for getAmfData command is not snssaiAMFList parameter!
      Dictionary Should Contain Key  ${details_dir}[${nrplmn}][snssaiAMFList][0]  sd  msg=In snssaiAMFList for getAmfData command is not sd parameter!
      Dictionary Should Contain Key  ${details_dir}[${nrplmn}][snssaiAMFList][0]  sst
      ...  msg=In snssaiAMFList for getAmfData command is not sst parameter!
      Log  \nParameters for ${nrplmn} are check  console=true
    END
    Log  \nAll parameters are present  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
