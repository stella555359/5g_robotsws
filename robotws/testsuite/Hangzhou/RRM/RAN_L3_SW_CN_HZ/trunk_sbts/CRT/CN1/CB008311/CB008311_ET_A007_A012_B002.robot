*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-zora.wang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{same frequency}
...    @{NRREL}
...    @{ANR_gnb}
...    @{8290_enable}
...    @{HO_related}
...    @{8311_enable}

@{HO_related}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:sMeasConfigSsbRsrp=10
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2|a3OffsetSsbRsrp=10|a3TimeToTriggerSsbRsrp=ms0

@{ANR_gnb}
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1

...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-2:actCDrx=true
...    NRCELL-2:drxProfileNrAnr:drxControl=intraNRSA


@{NRREL}
#...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
#...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
#...    NRCELL-1/NRREL-2:gNbId=1
#...    NRCELL-1/NRREL-2:gNbIdLength=22
#...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
#...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
#...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
#...    NRCELL-1/NRREL-2:removeNotAllowed=false
#...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:gNbId=1
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:lcrId=4
...    NRCELL-2/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=85
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-1:weightForSCellSelection=70
...    NRCELL-2:weightForSCellSelection=70
...    NRCELL-3:weightForSCellSelection=60
...    NRCELL-4:weightForSCellSelection=60
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=40
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL-12:dlSCellConfigLevel=15
...    NRCELL-12:dlSCellConfigLevelNum=25

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633000
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1562
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=7

@{8311_scell_active}
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
...    PhysCellId: 53
...    SCellIndex 1 activated successfully at airphone

@{8311_NSA_scell_active}
...    reported successful RA
...    SgNB Modification Confirm
...    pcid:61
...    scellIdx:8

@{OnlineParamChange_B002}
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1

@{OnlineParam_B002_recover}
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind

${ue_id}    81
${pdu_id}    1

${ue_nr_cap_SA_UE81}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F1800000000000000000081
...    C3C04FFF800003FFE00000260001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040
...    0000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26
...    800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E140
...    00711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602087A05D83E14489B1CF870A24
...    4D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003E00281C1401C0C02500700060
...    240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008
...    000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D60256
...    04560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E594901000089652
...    404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A
...    2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C201002004040300
...    60100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C
...    30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB008311-ET-A007_2CC_FT_NSA_Buffer_based_one_shot_SCell_Addition_with_blind_SCell_Addition_Method_intra_gNB_intra_DU_PSCell_Change_with_SRB3
    [Documentation]
    ...    1. This user scenario Verify_sThe purpose of this test case is to check following scenarios:L3 call can be setup successfully.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...    FDD cell11/cell12 configure to same frequency.
    ...    Configure CA Relations: Cell11-Cell3, Cell12-Cell4.
    ...    3. Test Case Steps:
    ...         1) UE attach to cell 11 successfully, no scell cell 3 Addition.gNB-CU performs prerequisite checks prior
    ...            to activating DL buffer monitoring for SCell Addition.The gNB-CU sends a private unacknowledged
    ...            F1AP message to the gNB-DU to activate DL data buffer monitoring.
    ...         2) High DL non-GBR data rate starts, DL buffer overflows,and cannot be drained by the serving cell.
    ...            gNB configures TDD cell3 as scell.
    ...         3) gNB initiates PSCell Change to FDD NRcell 12.no scell addition due to dlSCellConfigLevel and dlSCellConfigLevelNum
    ...            greater than Nrcell 11.The gNB-CU sends a private unacknowledged F1AP message to the gNB-DU to activate DL data
    ...            buffer monitoring. Then high DL non-GBR data rate starts, DL buffer overflows,and cannot be drained by the serving cell.
    ...            gNB configures TDD cell4 as scell.
    ...         4) NSA UE Detach From gNB.
    [Tags]    QC_281917    A007    CA_LABEL-FT(10MHz_FDD_n71+80MHz_TDD_n41)
    NSA UE Attach To Target Cell 11
    Send Throuput For NSA
    Verify Throuput on Pscell and Scell For NSA
    Intrafreq Handover to Cell 2    ue_id=91    carrierfreq=125050    target_phycell_id=61    pass_regexp=${8311_NSA_scell_active}
    Send Throuput For NSA to active scell
    Verify Throuput on Pscell and Scell For NSA    scell_dl=350
    UE Detach From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_A007${/}a2a.ini    wait_string=UEContextReleaseComplete::1

CB008311-ET-A012_2CC_TT_SA_Intra_gNB_Intra_DU_handover_SA_Mode
    [Documentation]
    ...    1. This user scenario Verify_sThe purpose of this test case is to check following scenarios:L3 call can be setup successfully.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...    FDD cell11/cell12 configure to same frequency.
    ...    Configure CA Relations: Cell1-Cell3, Cell2-Cell4. Intrafreq Handover NRREL :cell1-cell2
    ...    3. Test Case Steps:
    ...         1) UE registers successfully and PDU session is setup successfully on cell 1,no scell cell 3 Addition.
    ...            gNB-CU performs prerequisite checks prior to activating DL buffer monitoring for SCell Addition.
    ...         2) High DL non-GBR data rate starts.The gNB-DU sends private unacknowledged F1AP message to the gNB-CU to inform
    ...            the gNB-CU of the DL buffer overflow condition. DL buffer overflows,and cannot be drained by the serving cell.
    ...            GNB configures TDD cell3 as scell.
    ...         3) A3 MR to trigger intra-gNB intra-DU handover from TDD NRcell 1 to TDD NRcell 2 .GNB-CU performs prerequisite
    ...            checks prior to activating DL buffer monitoring for SCell Addition.The gNB-CU sends a private unacknowledged
    ...            F1AP message to the gNB-DU to activate DL data buffer monitoring. DL buffer overflows,and cannot be drained by the serving cell.
    ...            GNB configures TDD cell4 as scell.
    ...         4) SA UE Deregister From gNB.
    [Tags]    QC_279024    A012    CA_LABEL-TT(80MHz_TDD_n78+80MHz_TDD_n41)
    #SA UE Attach To NRcell 1
    #Send Throuput
    #Verify Throuput on Pscell and Scell
	#UE Deregister From gNB
	Update UE capa for UE81
	SA UE Attach To NRcell 1
    Send Throuput
    Verify Throuput on Pscell and Scell
    Intrafreq Handover to Cell 2
    Verify Throuput on Pscell and Scell
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_A012${/}a2a.ini    wait_string=UEContextReleaseComplete::3

CB008311-ET-B002_2CC_TF_TT_SA_Buffer-based one shot SCell Addition not started for SCell change
    [Documentation]
    ...    1. This user scenario check following scenarios:UE is eligible for SCell Change, A1 report for SCell change is received.
    ...       Buffer monitoring is NOT started and SCell change is performed immediately.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...    FDD cell11/cell12 configure to same frequency.
    ...    Configure CA Relations: Cell1-Cell3, Cell1-Cell 11.
    ...    3. Test Case Steps:
    ...         1) UE registers successfully and PDU session is setup successfully on cell 1.
    ...         2) UE sends A1 MR for FDD scell addition. gNB-CU performs DL buffer monitoring activation checks pass.
    ...           gNB-CU sends private F1AP message to gNB-DU to activate DL data buffer monitoring.
    ...         3) High DL data rate starts and buffer overflow happens at gNB-DU.DL buffer overflows,and cannot be drained by the serving cell.
    ...            gNB configures FDD Cell 11 as scell at the UE.
    ...         4) UE1 sends A1 MR for scell change. gNB-CU proceeds to perform Band Combination and SCell admission control of TDD SCell (Cell3).
    ...            AC checks pass. gNB-CU does NOT initiate DL buffer monitoring during SCell change. Buffer monitoring is NOT started and
    ...            SCell change is performed immediately. scell change from FDD CELL 11 to TDD CELL3.
    ...         5) SA UE Deregister From gNB.
    [Tags]    QC_279045    B002    CA_LABEL-TF(80MHz_TDD_n78+10MHz_FDD_n71)    CA_LABEL-TT(80MHz_TDD_n78+80MHz_TDD_n41)
    OnlineParamChange    ${OnlineParamChange_B002}
    SA UE Attach To NRcell 1
    Trigger ScellAdd
    Send Throuput
    Verify Throuput on Pscell and Scell    scell_dl=50
    Trigger ScellAdd    srsrp_nr=90    pass_reg=SCellIndex 2 activated successfully    #A1 scell change
    Verify Throuput on Pscell and Scell    scell_id=2
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_B002${/}a2a.ini    wait_string=UEContextReleaseComplete::3
    [Teardown]    B002_Teardown

*** Keywords ***
Test Teardown
    UE Detach From gNB

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F
	
	
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Update UE capa for UE81	
	Update UE capa    ${ue_nr_cap_SA_UE81}    81

B002_Teardown
    OnlineParamChange    ${OnlineParam_B002_recover}
    Common Test Teardown And Stop Capture Logs

Sa Ue Attach
    [Arguments]    ${ue_id}=81    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=81    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    ...    fail_regexp=sCellIndex 1

SA UE Attach To NRcell 1
    Sa Ue Attach     cell_id=1
    Setup pdu session with no scelladd

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=300    ${scell_dl}=300    ${ul}=6    ${pcell_id}=0    ${scell_id}=1
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell For NSA
    [Arguments]    ${ue_id}=91    ${pcell_dl}=40    ${scell_dl}=200    ${ul}=6    ${pcell_id}=8    ${scell_id}=9
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Intrafreq Handover to Cell 2
    [Arguments]    ${ue_id}=81    ${carrierfreq}=632736    ${target_phycell_id}=51    ${pass_regexp}=${8311_scell_active}
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}    pass_regexp=${pass_regexp}

NSA UE Attach To Target Cell 11
    [Arguments]    ${cell_id}=11    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA    fail_regexp=SCellIndex 9 activated successfully at airphone

Send Throuput For NSA
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Send Throuput For NSA to active scell
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
	Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=6    UE ${ue_id}: UDP DL
    sleep    10s    #sleep for stable traffic

UE Detach From gNB
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=632736    ${srsrp_nr}=81    ${srsrq_nr}=81    ${ue_id}=81    ${pass_reg}=measurementReport
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_reg}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
