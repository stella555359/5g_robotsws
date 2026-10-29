*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4LAPO
...               DevHZ5_SG4    owner-bob.song    owner-eric.jiang    release-xxx
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_BASIC}
...    @{PARAMS_FOR_HENB}
...    @{PARAMS_FOR_LTE1534_MFBI}
...    @{PARAMS_FOR_REDRT}
...    @{PARAMS_FOR_PMQAP}
@{PARAMS_FOR_REDRT}
...    LNBTS:actRedirect=enabled
...    LNBTS/LNCEL-1:threshold4=18
...    LNCEL-2/REDRT-0:redirRat=eutra
...    LNCEL-2/REDRT-0:redirFreqEutra=2600
...    LNCEL-2/REDRT-0:redirectPrio=3
...    LNCEL-2/REDRT-1:redirRat=eutra
...    LNCEL-2/REDRT-1:redirFreqEutra=3901
...    LNCEL-2/REDRT-1:redirectPrio=2
...    LNCEL-2/REDRT-2:redirRat=eutra
...    LNCEL-2/REDRT-2:redirFreqEutra=1700
...    LNCEL-2/REDRT-2:redirectPrio=1
...    LNCEL-2/REDRT-3:redirRat=eutra
...    LNCEL-2/REDRT-3:redirFreqEutra=2700
...    LNCEL-2/REDRT-3:redirectPrio=4
...    LNCEL-2/REDRT-0:csFallBPrio=1
...    LNCEL-2/REDRT-1:csFallBPrio=2
...    LNCEL-2/REDRT-2:csFallBPrio=3
...    LNCEL-2/REDRT-3:csFallBPrio=4
...    LNCEL-2/REDRT-0:emerCallPrio=1
...    LNCEL-2/REDRT-1:emerCallPrio=2
...    LNCEL-2/REDRT-2:emerCallPrio=3
...    LNCEL-2/REDRT-3:emerCallPrio=4
@{PARAMS_FOR_HENB}
...    LNBTS:actHeNBMobility=true
...    LNBTS/LNHENB-1:enbIdSize=28
...    LNBTS/LNHENB-1:freqEutra=3901
...    LNBTS/LNHENB-1:cellIndOff=0dB
...    LNBTS/LNHENB-1:pciFirst=1
...    LNBTS/LNHENB-1:pciLast=1
...    LNBTS/LNHENB-2:enbIdSize=28
...    LNBTS/LNHENB-2:freqEutra=1700
...    LNBTS/LNHENB-2:cellIndOff=0dB
...    LNBTS/LNHENB-2:pciFirst=2
...    LNBTS/LNHENB-2:pciLast=4
@{PARAMS_FOR_BASIC}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20600
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=2700
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=20700
...    LNBTS/LNCEL-1:enableBetterCellHo=true
...    LNBTS/LNCEL-1:enableCovHo=true
...    LNBTS-1:actFlexQCIARPPMProfiles=true
...    LNBTS-1:actQCIPLMNIDProfiles=false
@{PARAMS_FOR_PMQAP}
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgQCIRange=1
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgPRI=20
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgARPRange
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgUECategory
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:pLMNID
...    LNBTS-1/PMRNL-1/PMQAP-8:cfgQCIRange=8
...    LNBTS-1/PMRNL-1/PMQAP-8:cfgPRI=20
...    LNBTS-1/PMRNL-1/PMQAP-8:cfgARPRange=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-8:cfgUECategory=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-8:pLMNID=${empty}
...    MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    LNBTS-1/PMRNL-1:mtERABPMQAPProfile=15min
...    LNBTS-1/PMRNL-1:mtDataVolThrPMQAPProfile=15min
...    LNBTS-1/PMRNL-1:mtActUsersLatencyPMQAPProfile=15min
...    LNBTS-1/PMRNL-1:mtRLFPMQAPProfile=15min
@{PARAMS_FOR_LTE1534_MFBI}
...    LNBTS:actMFBI=true
...    LNBTS/MFBIPR-0:addFreqBandInd=9
...    LNBTS/MFBIPR-0:addSpectrEmissReq=1
...    LNBTS/MFBIPR-0:eutraCarrierFreq=1700
...    LNBTS/MFBIPR-0:freqBandIndPrio=not-broadcasted
...    LNBTS/MFBIPR-1:addFreqBandInd=26
...    LNBTS/MFBIPR-1:addSpectrEmissReq=1
...    LNBTS/MFBIPR-1:eutraCarrierFreq=2600
...    LNBTS/MFBIPR-1:freqBandIndPrio=not-broadcasted
...    LNBTS/MFBIPR-2:addFreqBandInd=19
...    LNBTS/MFBIPR-2:addSpectrEmissReq=1
...    LNBTS/MFBIPR-2:eutraCarrierFreq=2700
...    LNBTS/MFBIPR-2:freqBandIndPrio=not-broadcasted
@{pm_counters}
...    LNCEL-1:M8006C270=1
...    LNCEL-1:M8006C258=2
...    LNCEL-1:M8008C15=1
...    LNCEL-1:M8009C0=0
...    LNCEL-1:M8013C13=1
...    LNCEL-1:M8013C76=0
...    LNCEL-1:M8016C11=0
...    LNCEL-1:M8016C12=0
...    LNCEL-1:M8016C13=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C0=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C1=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C2=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C3=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C4=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C5=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C6=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C8=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C9=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-8:M8048C10=0
...    LNCEL-2:M8006C270=1
...    LNCEL-2:M8006C258=2
...    LNCEL-2:M8008C15=0
...    LNCEL-2:M8009C0=0
...    LNCEL-2:M8013C13=1
...    LNCEL-2:M8013C76=0
...    LNCEL-2:M8016C11=0
...    LNCEL-2:M8016C12=0
...    LNCEL-2:M8016C13=0
${ue1_eutra_capabilities}    SEPARATOR=
...    C9B8048300412320C1F83F07E0FDFC3F728800801C160000000002E2030100000240000520000B200060FC1F83F07E5040000000
${ue2_eutra_capabilities}    SEPARATOR=
...  C9B80484001040A20204F84F84F84F84FBF87EE5100100382C0000000005C40802000004200008800011400024000204F84F84F84F84F94100
...  000000

*** Test Cases ***
LTE1442_02_Bb Release With Redirect Towards Home eNBs
    [Documentation]    [1][1.0] C-Pln_LTE1442 Release With Redirect Towards Home eNBs
    ...    LTE1442 Open Access Home eNodeB Mobility
    ...    (additionally LTE1534 Multi Frequency Band Indicator is verified by redirecting UE to mapped frequency)
    ...
    ...    PM counter for redirect towards HeNB:
    ...    UE1, which only supports mapped bands, is attached to cell 1.
    ...    UE2, which supports native bands, is attached to cell 2.
    ...    For both Ues additional QCI1 bearers are established to check PM counter for QCI1 bearer release during redirect.
    ...    Cell 2 is defined as HeNB target for eNB.
    ...    First Ue is redirected with A3 event to "HeNB" cell 2.
    ...    Second Ue is redirected with A2 event to "regular" cell 1.
    ...    In cell 1 the PM counter for redirect towards HeNB shall be pegged, in cell 2 not.
    ...
    ...    Additionally the PM counters for LTE3303-C (LTE_ERAB_Statistics_per_PMQAP_Profile M8048C*)
    ...    are verified in this test (no abnormal release)
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    UE1 Redirect From Cell1 To Cell2 Triggered By A3 MR
    Comparison Test UE2 Redirect From Cell2 To Regular Cell 1
    Check Counters    ${pm_counters}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=6CELLs_FDD    ue_count=2
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

UE1 Redirect From Cell1 To Cell2 Triggered By A3 MR
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8))
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    UE_1:RRC_RRCConnectionRelease (rrcConnectionRelease contains (redirectedCarrierInfo contains (eutra eq 3901)))
    ...    alias=UE1_A3   overall_timeout=20
    Execute Uex Command    ue_param id=1 ue_eutra_capabilities=${ue1_eutra_capabilities}
    Execute Uex Command    ue_attach id=1 enb=1 cell=1
    Execute Uex Command    bearer_add ue=1 qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31
    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=2 nrsrp=73 nrsrq=18 srsrp=60 srsrq=18
    Sleep    3s
    Flow Occurred As Expected    alias=UE1_A3

Comparison Test UE2 Redirect From Cell2 To Regular Cell 1
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8))
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    UE_2:RRC_RRCConnectionRelease (rrcConnectionRelease contains (redirectedCarrierInfo contains (eutra eq 1700)))
    ...    alias=UE2_A2   overall_timeout=20
    Execute Uex Command    ue_param id=2 ue_eutra_capabilities=${ue2_eutra_capabilities}
    Execute Uex Command    ue_attach id=2 enb=1 cell=2
    Execute Uex Command    bearer_add ue=2 qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31
    Execute Uex Command    ue_measurement_send id=2 event=A2 srsrp=15 srsrq=14
    Sleep    5s
    Flow Occurred As Expected    alias=UE2_A2
