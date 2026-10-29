*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_5G    RAN_Aic    CRT    CLOUD_5GC_dRNIC_1vDU_P_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...    team-SG2    owner-lijun.j.jia    owner-teana.wang    release-SBTS24R2
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot


*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
#${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/3cells_2T1F_AZQJ

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF_CU}
...    @{PARAMS_FOR_BOTH}
...    @{NRCELL_FOR_CU}
...    @{NRCELL_NRREL_FOR_CU}
...    @{NRCELL_NRHOIF_FOR_CU}

@{PARAMS_IN_SCF_DU1}
...    @{PARAMS_FOR_BOTH}
...    @{NRCELL_FOR_DU}

@{PARAMS_FOR_BOTH}
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS-1:actConnRrcPooling=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRDU-1:actInterNumerologyCa=true
...    NRCELL-1/NRHOIF-1:ssbFrequency=176210
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations

@{NRCELL_FOR_CU}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=60
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:weightForSCellSelection=50    #chbw:100M
...    NRCELL-3:weightForSCellSelection=60   #chbw:20M
...    NRCELL-4:weightForSCellSelection=50   #chbw:20M
...    NRCELL-1:nrarfcn=633000
...    NRCELL-2:nrarfcn=648000
...    NRCELL-4/NRCELL_FDD-1:nrarfcnDl=175800
...    NRCELL-4/NRCELL_FDD-1:nrarfcnUl=166800


@{NRCELL_NRHOIF_FOR_CU}
...    NRBTS-1:actInterFreqHoSA=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=9
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=5
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none

@{NRCELL_NRREL_FOR_CU}
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:lcrId=4
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly

@{NRCELL_FOR_DU}
...    NRBTS-1:actSlowPrbPooling=true
...    NRBTS-1:actScheUePooling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actGrflShdn=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS-1:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:gscnOrSsPbchArfcn=7840                  #ssbFrequency=632736
...    NRCELL-1:nrarfcn=633000
...    NRCELL-2:gscnOrSsPbchArfcn=8000                  #ssbFrequency=648096
...    NRCELL-2:nrarfcn=648000
...    NRCELL-4:gscnOrSsPbchArfcn=2196
...    NRCELL-4/NRCELL_FDD-1:nrarfcnDl=175800             #ssbFrequenchy=175710
...    NRCELL-4/NRCELL_FDD-1:nrarfcnUl=166800


${UE_NR_CAPA_N5_N78_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B013582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C6
...    39F30C7942C0E070F02E007FE003801FF8002E0000702A0D833AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1
...    607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070
...    F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007F
...    E000B80001C0A836036B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001
...    C00E78380C0820002C040BC3C06000E030000010B0102F170A0003882001C46000004160205E2E02000713400389A00000C2C040BC3C04000
...    E020000040B0102E0F01000380C0000142C040BC3C06000E0C8000060B0102F0F10400389A00001C2C040BC5C28000E208007104000040580
...    8178B850001C46000E230000090B0102F17104003882001C46000014160205E2E20800711800388C00002C2C040BC3C46000E2680000C0B01
...    02F1F060003882001C46000E2600000D0B010200E0234028809B01045D002BC1D0A244D8E7C3851226C73E1C4891226C73E1C4891226C73E1
...    C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C28913639F0E3448
...    91226C73E1854386318C6318C6318C637A0B800F000A070500703009401C0018090010180F810008000000040000080200000801000006008
...    00004004000028020000180100000E00800404010076065654564C5646D604D60C5606D654D02010000096525040000659494100002965250
...    40000E594941000049652504000165949410000696525040001E594941004040125949407503AAA555549AAA91E5502CAA0D5540F2A95650B
...    0024006814001A001012024202014028080500A20100400804008010100200440201C038080200402008010404038070100E01C20201C0380
...    80500A10100A01404038070808010020200801080401002010020040400801100802004020040080801002201002004040080101002004402
...    0040080801002020040084040080101004008606018034028050300200600400818010030020040C040088020043543E00020406080C0E141
...    6181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{PM_Counters_CU_Check}
...     NRCELL-1:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-1:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1
...     NRCELL-1:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

#Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in D
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#Sum of CA UEs in the current cell configured as a SCell, which have 2 configured SCells in DL
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
#Successful RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003
#RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004


*** Test Cases ***
CB006138-ET-AC018_A2_trigger_Pcell_change_RSRP_successful_when_FDD_scell_selected_for_TDD-TDD-FDD
    [Documentation]
    ...    1. The purpose of this test case is to check PCell change to current FDD SCell for SA from TDD cell base on
    ...       RSRP for FR1 TDD-FR1 TDD-FDD 3CC CA config to FDD only
    ...    2. Precondition:
    ...         a. a1ThresholdSCellAddSsbRsrpFDD=75, a1ThresholdSCellAddSsbRsrpTDD=95
    ...         b. weightForSCellSelection: cell_2=50, cell_3=50, cell_4=60
    ...         c. a2MeasPCellSwitchEnabled: rsrp, a2ThresholdPCellSwitchSsbRsrp: 60
    ...    3. Test Case Steps:
    ...         a. make SA UE-1 attach to cell 1
    ...         b. check A1 meas config in RRC Reconfig
    ...         c. A1 measurement report based SCell addition is triggered with rsrp=100
    ...         d. A2 measurement report based PCell change with PCell RSRP below threashold and SCell RSRP is good enough
    ...         e: check the counter: 'M55118C07001', 'M55118C07002', 'M55118C07003', 'M55118C07004'
    ...    4. Expected Results:
    ...         Step a: UE attach to cell 1 success
    ...         Step c: Cell2 and Cell3 as SCell addition success
    ...         Step d: PCell change to Cell_3 success
    ...         Step e: counters updated accordingly
    [Tags]    AC018    QC_349649
    Clear Counter Files
    UE Attach to GNB2 Cell1
    Start Traffic
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=1    min_dl_tput=450
    Scell_2_3 Added Based On High Rsrp
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=3    min_dl_tput=600
    Switch Pcell From cell1 To cell3
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=1    min_dl_tput=250
    Stop Traffic and UE Detach
    Check Counters


*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    ue_param id=1 ue_nr_capabilities=${UE_NR_CAPA_N5_N78_N78}

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_CU_Check}

UE Attach to GNB2 Cell1
    [Arguments]    ${pdu_id}=1
    ${ret}    Execute Egate Command    ue_change_location id=1 enb=2 cell=1    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=1     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=1 pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=1 nwslice=1 gw=${pdu_id}
    ...                      pass_regexp=QoS Routing Table

Scell_2_3 Added Based On High Rsrp
    [Arguments]    ${rsrp}=100    ${rsrq}=30
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=632736    event_type=A1
    ${TTF_3CC_Success}     create list
    ...    sCellToAddModList
    ...    pcid:60, scellIdx:2
    ...    pcid:51, scellIdx:1
    ...    rrcReconfigurationComplete
    ...    SCellIndex 2 activated successfully
    Execute Egate Command
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=${TTF_3CC_Success}

Switch Pcell From cell1 To cell3
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=632736    event_type=A2
    ${egate_cmd}    Catenate    ue_measurement_send_nr id=1 event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=100 scell_rsrq=45 scell=2 scell_rsrp=100 scell_rsrq=45
    ${pcell_switch_success}     create list
    ...    sCellToReleaseList
    ...    rrcReconfigurationComplete
    ...    UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed
    ${ret}    Execute Egate Command     ${egate_cmd}    pass_regexp=${pcell_switch_success}

Start Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=1
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=2
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=3
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=4
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=5
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=10 trf_id=6
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Stop Traffic and UE Detach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=1    ${min_dl_tput}=20    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}
