*** Settings ***
Documentation
...   Author: rong.nie@nokia-sbell.com
...   Contact: rong.nie@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    600 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CNI118106_KeyWord.robot
Library       taf.ccs.aashell           WITH NAME    cli

*** Variables ***
@{PARAMS_IN_SCF}
...  @{Emergency_Call_Related_Parameters}
...  @{5QI1}
...  @{5QI5}
...  @{5QI1_5QI2}
#...  @{NRCELL1_A3RSRQ}
#...  @{NRCELL2_A3RSRQ}
#...  @{TAC_300}
@{Emergency_Call_Related_Parameters}
...  NRCELL-1:actVoNR=true
...  NRBTS:cipherPrefL:nea0=1
...  NRBTS:cipherPrefL:nea1_128=0
...  NRBTS:cipherPrefL:nea2_128=9
...  NRBTS:cipherPrefL:nea3_128=0
...  NRBTS:integrityProtPrefL:nia1_128=0
...  NRBTS:integrityProtPrefL:nia2_128=9
...  NRBTS:integrityProtPrefL:nia3_128=0

...  NRCELL-1:actEmergencyCall=true
...  NRCELL-1:actEnhancedVoNR=true
...  NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...  NRCELL-1:emergencyCallLimServ=true
...  NRCELL-1:maxGBRTrafficLimit=30
...  NRCELL-1:maxNumOfGBRBearersSA=5
...  NRCELL-1:maxNumOfNonGBRBearersSA=500
...  NRCELL-1:n310VoNR=n3
...  NRCELL-1:t310VoNR=500ms
...  NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...  NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...  NRDU-1:numOfDrbsReservForEmergency=2
...  NRBTS:tRLFindForDUVoNR=500ms
...  NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...  NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...  NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...  NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...  NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...  NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...  NRBTS-1/SNSSAI-2:sd=13714342
...  NRBTS-1/SNSSAI-2:sst=1
...  NRBTS:ngCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...  TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...  TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...  NRCELL-1:arpPrioEmergencyCall=1
...  NRCELL-1:emergencyCallFails=false
...  NRCELL-1:numOfRadioResReservForEmergency=1
...  NRBTS:rrcReestabTypeSA=viaRRCSetup

...  NRBTS:actIntraFreqHoSA=true
...  NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...  NRCELL-2:actEmergencyCall=true
...  NRCELL-2:actEnhancedVoNR=true
...  NRCELL-2:actGBRAdmissionControl=EnhancedVoNR
...  NRCELL-2:emergencyCallLimServ=true
...  NRBTS-1/NRCELL-2:actVoNR=true
...  NRBTS-1/NRCELL-2:maxGBRTrafficLimit=30
...  NRBTS-1/NRCELL-2:maxNumOfGBRBearersSA=10
...  NRBTS-1/NRCELL-2:maxNumOfNonGBRBearersSA=500
...  NRBTS-1/NRCELL-2:n310VoNR=n3
...  NRBTS-1/NRCELL-2:t310VoNR=500ms
...  NRBTS-1/NRCELL-2:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...  NRBTS-1/NRCELL-2:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...  NRBTS-1/NRCELL-2:arpPrioEmergencyCall=6
...  NRBTS-1/NRCELL-2:emergencyCallFails=false
...  NRBTS-1/NRCELL-2:numOfRadioResReservForEmergency=1
@{5QI1}
...  NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...  NRBTS-1/NRDRB-15:dscp=0
...  NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...  NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...  NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRBTS-1/NRDRB-15:numSduDiscard=1
...  NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...  NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...  NRBTS-1/NRDRB-15:resType=GBR
...  NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...  NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...  NRBTS-1/NRDRB-15:schedulWeight=1
...  NRBTS-1/NRDRB-15:discardTimer=150ms
...  NRBTS-1/NRDRB-15:actDddsReduction=false
...  NRDRB-15:maxDataRateGbrUl=1000
...  NRDRB-15:maxDataRateGbrDl=1000
...  NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...  NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...  NRBTS-1/NRDRB_MAC-3:lcgid=4
...  NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...  NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false

@{5QI5}
...  NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...  NRBTS-1/NRDRB_MAC-4:lcgid=1
...  NRBTS-1/NRDRB_MAC-4:schedulPrio=4

@{5QI1_5QI2}
...  NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...  NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{UE_ID_LIST}    ${1}  ${2}  ${3}  ${4}  ${5}  ${6}
*** Test Cases ***
CNI118106 Setup NonGBR SA Call
    [Tags]    QC_68481       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Aashell outputs show those internal counters which impact the result of admission control in CP-RT.
    ...    Purpose of this CNI to add those internal counters to Aashell outputs.
#    [Setup]    Case Precondition
#    UE Register And PDU Session Setup for NonGBR
#    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE3
#    Get aashell command output
#    UE Deregister From gNB    ue_id=3
#    Get aashell command output
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

CNI118106 Setup VoNR Call
    [Tags]    QC_68480       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Aashell outputs show those internal counters which impact the result of admission control in CP-RT.
    ...    Purpose of this CNI to add those internal counters to Aashell outputs.
#    [Setup]    Case Precondition
#    UE Register And PDU Session Setup    ue_id=3    ue_gw=3
#    UE PDU Session Modify   ue_id=3  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
#    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE3
#    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE3
#    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE3
#    Get aashell command output
#    UE Deregister From gNB    ue_id=3
#    Get aashell command output
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False


CNI118106 Setup Emergency call
    [Tags]    QC_68475       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Aashell outputs show those internal counters which impact the result of admission control in CP-RT.
    ...    Purpose of this CNI to add those internal counters to Aashell outputs.

    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

CNI118106 Setup NSA call
    [Tags]    QC_68462       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Aashell outputs show those internal counters which impact the result of admission control in CP-RT.
    ...    Purpose of this CNI to add those internal counters to Aashell outputs.

    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False


CNI118106 Robustness_Setup Multi-UEs call
    [Tags]    QC_68465       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Aashell outputs show those internal counters which impact the result of admission control in CP-RT.
    ...    Purpose of this CNI to add those internal counters to Aashell outputs.

    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False


*** Keywords ***
Kill agate and start egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
#    Airphone Edaemon Egate Setup
#    Airphone Cfg Configuration    wts_cfg_name=${CURDIR}/config/basic_setup_118106_MUE.cfg
    Sleep    5s




