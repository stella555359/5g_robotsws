*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_5G    CRT    RAN_Aic    CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...    team-SG2    owner-lingyan.zhou   release-SBTS24R2    CB008542
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot


*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
#${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/3cells_2T1F_AZQJ

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG_AP}    ${EnableSrsBasedBeamForming}=1
${EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SCF_CU}
...    @{PARAMS_FOR_BOTH}
...    @{PARAMS_FOR_CU}
...    @{NRREL_CU}

@{PARAMS_IN_SCF_DU1}
...    @{PARAMS_FOR_BOTH}
...    @{PARAMS_FOR_DU}

@{PARAMS_FOR_BOTH}
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS-1:actConnRrcPooling=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRDU-1:actInterNumerologyCa=true
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations

@{PARAMS_FOR_CU}
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:weightForSCellSelection=100    #chbw 100m
...    NRCELL-2:weightForSCellSelection=100    #chbw 100m
...    NRCELL-3:weightForSCellSelection=90    #chbw 20m
...    NRCELL-4:weightForSCellSelection=30    #chbw 20m
...    NRCELL-1:nrarfcn=633000
...    NRCELL-2:nrarfcn=648000
...    NRCELL-4/NRCELL_FDD-1:nrarfcnDl=175800
...    NRCELL-4/NRCELL_FDD-1:nrarfcnUl=166800

@{NRREL_CU}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-10:lcrId=1
...    NRCELL-3/NRREL-10:gNbId=1
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-10:removeNotAllowed=false
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:sCellOperationalMode=dlOnly

@{PARAMS_FOR_DU}
...    NRBTS-1:actSlowPrbPooling=true
...    NRBTS-1:actScheUePooling=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1:gscnOrSsPbchArfcn=7840          #ssbFrequency=632736
...    NRCELL-1:nrarfcn=633000
...    NRCELL-2:gscnOrSsPbchArfcn=8000          #ssbFrequency=648096
...    NRCELL-2:nrarfcn=648000
...    NRCELL-4:gscnOrSsPbchArfcn=2196          #ssbFrequenchy=175710
...    NRCELL-4/NRCELL_FDD-1:nrarfcnDl=175800
...    NRCELL-4/NRCELL_FDD-1:nrarfcnUl=166800

#...    NRCELL-1:actBeamforming=true
#...    NRCELL-1:nrCellType=4DL2UL
#...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
#...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
#...    NRCELL-2:actBeamforming=true
#...    NRCELL-2:nrCellType=4DL2UL
#...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
#...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8

${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

@{PM_Counters_CU_Check_BA010}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=2
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=2
...    NRCELL-3:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_DU_Check_BA010}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-3:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-3:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=3

${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
#The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
#The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
#RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
#Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
#Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
#Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
#Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for NSA
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
#Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
#The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
#The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
#The number of successful radio admissions for the Scell
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
#The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
#The number of successful radio admitted NSA users


${UE_NR_CAPA_N78_N5}      SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670FC24026C830E7CC31E50B038260300C47006A8D89BAC1184341020E9068030B64C55110E7
...    C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0005C0000E0541B013582308682041E20D00656C98AB121CF88E3D813E312
...    38F21CFA8E7CC31E50B0381C3C27FFC00001FFF0000017000038002B0F1340038080000042C0801800901345D0003C030A244D8E7C3014046
...    7A0B800F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A00
...    8004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03395359535829581
...    95833582B594B5933580B581B58095811583B40D04000025949410000196525040000A5949010000396524040001259490100005965240400
...    01A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA5515416
...    2A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05000108080600C02004008404
...    008020100C0186A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${UE_MRDC_CAPA_N4_N78_N5}
...    A11FF80BC4C0C0389A001C0400000016220401003800901345D00042031274489B1CF8601402318011000040202004010080600C2000080404008010100C0180

@{endc_cell2_setup_and_add_scell3_blindly}
...    pcid:51, scellIdx:1
...    pcid:60, scellIdx:2
...    reported successful RA
...    SCellIndex 2 activated successfully

@{endc_cell1_setup}
...    pcid:50, scellIdx:1
...    reported successful RA
...    SNStatusTransfer


*** Test Cases ***
CB008542-ET-BA010_Verify_NSA_TF_2CC_scell_selection_based_on_different_weighted_cell_bandwidth_and_same_cell_load_within_unlocked_cells
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.US CB008542-BA#B4: Single UE EN-DC connection setup and DL/UL data scheduling in NSA option 3X without
    ...           BF and A1/A2 measurement based SCell Addition/Release
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-2 has NRREL as scell: NRCELL1, NRCELL3 .
    ...                        NRCELL-1 has NRREL as scell: NRCELL2, NRCELL3, NRCELL4.
    ...         a. CA NSA UE11 attach to NR Cell 2 and scell addition blind to NR Cell 3.
    ...         b. UE11 detach
    ...         c. CA NSA UE11 attach to NR Cell 1 and scell addtion coverbasedA1 to NR Cell 3.
    ...         d. CA NSA UE11 scell release_NR Cell 3 as A2 event. Trigger A1 event to add scell NR Cell 3.
    ...         e. CA NSA UE11 scell release_NR Cell 3 as A2 event.
    ...    3. Expected Results:
    ...         Step a: UE11 scell added successfully. Traffic is normal.
    ...         Step c: UE11 scell added successfully. Traffic is normal. A2 of scell release is configured to UE.
    ...         Step d: UE11: scell released_NRCELL 3. A1 of scell addition is configured to UE. After A1 event, scell added successfully.
    ...         Step g: UE11: scell released_NRCELL 3.
	[Tags]    BA010    QC_349650
	Clear Counter Files
    Lock Cell1
    NSA UE CA blind scell add and release successfully
    Unlock Cell1
    Cells Should Be Onair Du
    NSA UE Coverbased Scell add same cell and release successfully
	Check Wireshark Log Aic    ${CURDIR}${/}a2a_BA010${/}a2a.ini    wait_string=UEContextReleaseComplete::4
	Check Counters

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    ue_param id=31 ue_nr_capabilities=${UE_NR_CAPA_N78_N5} dual_conn=eutra_nr ue_eutra_nr_capabilities=${UE_MRDC_CAPA_N4_N78_N5}

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_CU_Check_BA010}
    Check Counters Du Aic    ${PM_Counters_DU_Check_BA010}

NSA UE CA blind scell add and release successfully
	NSA UE attach    ue_id=31    enb_cell=1    gnb_cell=2    endc_setup_succ=${endc_cell2_setup_and_add_scell3_blindly}
	Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell and Scell    ue_id=31    min_dl=600
	NSA UE Detach From GNB    ue_id=31

NSA UE Coverbased Scell add same cell and release successfully
    NSA UE attach    ue_id=31    enb_cell=1    gnb_cell=1    endc_setup_succ=${endc_cell1_setup}
	Add gNB Cell1 As Scell By A1    ue_id=31    carrierfreq=632736    srsrp_nr=120    srsrq_nr=120
	Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell and Scell    ue_id=31    min_dl=600
	Release gNB Cell1 Scell By A2    ue_id=31    carrierfreq=176210
	Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell    ue_id=31    min_dl=500
	Add gNB Cell1 As Scell By A1    ue_id=31    carrierfreq=632736    srsrp_nr=90    srsrq_nr=90
	Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell and Scell    ue_id=31    min_dl=600
	Release gNB Cell1 Scell By A2    ue_id=31    carrierfreq=176210
	Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell    ue_id=31    min_dl=500
	NSA UE Detach From GNB    ue_id=31

NSA UE attach
    [Arguments]    ${ue_id}    ${enb_cell}    ${gnb_cell}    ${endc_setup_succ}
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${enb_cell}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${gnb_cell} bearer=2 type=split_scg
    ...    pass_regexp=${endc_setup_succ}
    Send Throuput    ${ue_id}

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=11    ${carrierfreq}=636576    ${srsrp_nr}=120    ${srsrq_nr}=120
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${TF_2CC_Success}     create list
    ...    sCellToAddModList
    ...    pcid:60, scellIdx:2
    ...    SCellIndex 2 activated successfully
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...   pass_regexp=${TF_2CC_Success}

Release gNB Cell1 Scell By A2
    [Arguments]    ${ue_id}=11    ${carrierfreq}=176210
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${scell_release_success}    create list
    ...    sCellToReleaseList
    ...    Successfully reconfigured dual connectivity
    ...    SgNBModificationConfirm
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=2 scell_rsrp=7 scell_rsrq=7
    ...   pass_regexp=${scell_release_success}

Stop Traffic
    [Arguments]    ${ue_id}=11
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=11
    Stop Traffic    ${ue_id}
    Execute Egate Command  ue_detach id=${ue_id}    UE${ue_id}: detached

Send Throuput
    [Arguments]    ${ue_id}=11
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    pass_regexp=UE${ue_id}: Started
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    pass_regexp=UE${ue_id}: Started
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    pass_regexp=UE${ue_id}: Started
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    pass_regexp=UE${ue_id}: Started
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=6    pass_regexp=UE${ue_id}: Started
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    pass_regexp=UE ${ue_id}: UDP UL TRF

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=11    ${min_dl}=235    ${min_ul}=8
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${min_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${min_ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=11    ${min_dl}=400    ${min_ul}=8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-10 type=pdsch    Throughput
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0
    Should Be True    ${pcell_tput}+ ${scell_tput}> ${min_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${min_ul}
