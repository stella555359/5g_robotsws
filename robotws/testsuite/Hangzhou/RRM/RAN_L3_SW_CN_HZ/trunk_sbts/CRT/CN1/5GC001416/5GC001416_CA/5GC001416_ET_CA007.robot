*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-yili.chen@nokia-sbell.com  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{MFBI_activation}
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRCELL1}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{MFBI_NRNSPMAX_Profile}
...    @{csiconfig}
...    @{enableBeamforming}
...    @{adaptrelationerror}

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{MFBI_NRCELL1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=636668
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7881
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min

@{adaptrelationerror}

...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams


...    NRBTS/NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS-1/NRSYSINFO_PROFILE-1:systemInformationTargetRate=0
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1:actEcpriMasterClock=true
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRCELL:type0SearchSpaceConfigurationIndex=5


...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{csiconfig}
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=0
...    NRCELL-2:periodicCsiAcquisition:csirsPower=3
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL:actUeCsirsCoexistCellCsirs=true

@{enableBeamforming}
...    NRCELL:beamSet:basicBeamSet=beamSet_4
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=8DL4UL
...    NRCELL:beamSet:lowerEdgeAngle=135
...    NRCELL:beamSet:upperEdgeAngle=80

@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

@{bandlist1}
...  MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77, 48

@{bandlist3}
...  MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=48

${UE1_NR_Capa}  #CA03_04_07
...    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E00751B13303582308682041D2011B5B262AC6873E238F40CFB007C624
...    71E439F51CF9867CA160703878AE007FE0038002F8000A00E000841C4C000000006026C04C0500E010113D82C03000281C0C0381802C0380034
...    1F000000000000072A68000800004B2CA801A5554040E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940
${UE1_RESULT}    Initial Context Setup Successful
${UE1_RESULT1}    800C04D80980
${UE1_RESULT2}    Initial Context Setup Successful
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77'},
#csi-RS-IM-ReceptionForFeedback {
#maxConfigNumberNZP-CSI-RS-PerCC 8,
#maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC 64,
#maxConfigNumberCSI-IM-PerCC n8,
#maxNumberSimultaneousNZP-CSI-RS-PerCC 4,
#totalNumberPortsSimultaneousNZP-CSI-RS-PerCC 64

${UE2_NR_Capa}  #CA07_1
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A3617EB04050D012CB2898183D6C101010
...    70EF1C39061C00103278FAB80027800E0009E0000841C2F000000006026C02F07007008089EC260060005038280381803C01C001A0F80000000
...    00000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE2_RESULT}    Initial Context Setup Successful
${UE2_RESULT1}    801404D809900BC0
${UE2_RESULT2}    Initial Context Setup Successful
#Description': 'supportedBandListNR:n48,supportedBandCombinationList:n48,appliedFreqBandListFilter:n78,n48'},

${UE3_NR_Capa}  #CA07_2
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C10101
...    070EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F800000
...    0000000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE3_RESULT}    Initial Context Setup Failure
${UE3_RESULT1}    800C04D805E0
${UE3_RESULT2}    cause RAN radio resources not available
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77'},

${SGNB_SA_ADMISSION_REQ}    M55138C00001
#The number of radio admission requests for SA user. Updated in the CU when RRC resources are requested for new setup.
${SGNB_SA_ADMISSION_SUCC}    M55138C00002
#The number of admitted radio admission requests for SA user. Updated in the CU when RRC resources are admitted for new setup.
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501
#Number of SA user radio admission requests where request is on the alternative band
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502
#Number of SA user admitted radio admission requests where admission is done on the alternative band
@{PM_Counters_Check_1}
...    NRCELL-1:${SGNB_SA_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_SA_ADMISSION_SUCC}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=1

@{PM_Counters_Check_2}
...    NRCELL-1:${SGNB_SA_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_SA_ADMISSION_SUCC}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=0

*** Test Cases ***
5GC001416-ET-CA007-Check_Online_modify_the_alternative_bands_of_one_cell_with_active_UE_on_it
    [Documentation]
    ...    Check_Online_modify_the_alternative_bands_of_one_cell_with_active_UE_on_it
    ...    EDA_PR683334_check interworking with 5GC002200 CSIRS resource for alternative_bands
    [Tags]    QC_60792
    Clear Counter files
    register ue with ue_cap    ue_id=1    pdu_id=1
    Check WireShark Log    ${CURDIR}${/}a2a_CA007${/}a2a.ini
    Check Counters    ${PM_Counters_Check_1}
    Clear Counter files
    Delta Commission Parameters    ${bandlist1}
    register ue with ue_cap    ue_id=2    pdu_id=2
    Check Counters    ${PM_Counters_Check_1}
    Clear Counter files
    Delta Commission Parameters    ${bandlist3}
    register ue with ue_cap    ue_id=3    pdu_id=3
    Check Counters    ${PM_Counters_Check_2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=636668:636668 gscn=7881 mandatory_for_activation=off
    Update Cfg    ${cell1}

register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    capabilityRequestFilter '${UE${ue_id}_RESULT1}'H    #lengacy
    Should Contain    ${ret1}    ueCapabilityInformation
    Should Contain    ${ret1}    ${UE${ue_id}_RESULT2}
