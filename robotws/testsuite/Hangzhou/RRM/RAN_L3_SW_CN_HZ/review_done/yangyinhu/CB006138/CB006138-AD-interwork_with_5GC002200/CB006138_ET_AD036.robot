*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CXT    master_classicalbts_all    STATE_CONFIGURED
...               FR1    CN2    team-SG2    owner-cathy.mao    owner-dandan.chen    release-SBTS22R1
...               PRI-Medium    CB006138-AD    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource         ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/4cell

@{PARAMS_IN_SCF}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actLteNrDss=false
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:msg1FrequencyStart=12
...    NRBTS-1/NRCELL-11:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-12:msg1FrequencyStart=13
...    NRBTS-1/NRCELL-12:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-12:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-12:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-12:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-1:type0CoresetConfigurationIndex=10
...    NRBTS-1/NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRBTS-1/NRCELL-1:nrCellType=8DL4UL
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:csirsPower=6
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRBTS-1/NRCELL-1:actAperCsi=true
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-1:pucchModeSelect=longPucch
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

${CA_SUPPORT_LIST}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa

@{VALID_SCELL_ADD_AD036}
...    NRBTS-1:actMeasBasedSCellAddition=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:weightForSCellSelection=100
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=160ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=40ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2:actCDrx=true
...    NRCELL-2:weightForSCellSelection=90
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:actCDrx=true
...    NRCELL-11:weightForSCellSelection=80
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp


${TDD_SCELL_FOR_NRCELL1}    NRCELL-2
${FDD_SCELL_FOR_NRCELL1}    NRCELL-11


&{CELLS_SSBFREQ}
...     NRCELL-1=509790
...     NRCELL-2=527790
...     NRCELL-11=127950
...     NRCELL-12=125050


*** Test Cases ***
CB006138-ET-AD036_Pcell_csi-rs_is_upgraded_after_scell_change_TTF
    [Documentation]
    ...    1. This user scenario validates the of successful configuration of TDD+TDD+FDD 3CC CA for a
    ...       UE when 5GC002200 is enabled in PCell in SA mode,and scell change interworking for FR1 TDD-FR1 TDD 2CC CA.
    ...    2. Precondition:
    ...         a. a1ThresholdSCellAddSsbRsrpFDD=75, a1ThresholdSCellAddSsbRsrpTDD=95
    ...         b. a2ThresholdSCellRelSsbRsrpTDD=30
    ...
    ...         maxNumbersimultaneousNZP-CSI-RS-ActBWP-AllCC=4    totalnumberportsimultaneousNZP-CSI-RS-perCC=64
    ...         maxnumbersimultaneousNZP-CSI-RS-perCC=4    simultaneousCSI-ReportsAllCC=5
    ...    3. Test Case Steps:
    ...         step1. make SA UE-81 register to cell 1 and PDU session setup
    ...         Expect result: UE attach sucessul and PDU session is ok
    ...         step2. UE add scell(T+F) covbased A1 with rsrp=100
    ...         Expect result: scell_2 and scell_11 can be added successful
    ...         step3. UE release scell(TDD) covbased A2 with rsrp=20
    ...         Expect result: scell_2 can be released successful
    ...         step4. scell change from FDD_cell_11 to TDD_cell_2 covbased A1 is triggered with rsrp=100
    ...         Expect result: scell change can be successful
    [Tags]    CB006138-AD0036
    [Timeout]    60 min
    Before_ue_attach_AD036
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=1
    Triggered Scell Addition by A1    pcell=NRCELL-1
    Check Two Scell Added Successfully    NRCELL-1    ${TDD_SCELL_FOR_NRCELL1}    ${FDD_SCELL_FOR_NRCELL1}
    Verify Throuput on TTF_CA    ue_id=81    pdu_gw_id=1
    Release Scell    scell=NRCELL-2    scell_index=1
    Verify Throuput After Release TDD_Scell In TTF_CA    ue_id=81    pdu_gw_id=1
    Start RRC Log       AD036_scell_change
    Triggered Scell Change by A1    pcell=NRCELL-1
    Check Scell Change To TDD Successfully    scell=${TDD_SCELL_FOR_NRCELL1}
    Verify Throuput After Scell Change From FDD To TDD In TF_CA    ue_id=81    pdu_gw_id=1
    Release Scell    scell=NRCELL-2    scell_index=1
    Check WireShark Log    ${CURDIR}${/}a2a_AD036${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::32
    Release Ues    ue_type=all


*** Keywords ***

Verify Throuput on TTF_CA
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 10
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify Throuput After Release TDD_Scell In TTF_CA
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell2_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify Throuput After Scell Change From FDD To TDD In TF_CA
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>100

Before_ue_attach_AD036
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD036}
    ${final_uecap}    catenate    SEPARATOR=    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080
    ...     C4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E619F28581C0E1E0B801FF800E000BE00
    ...     05800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B00
    ...     0E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571
    ...     F11B582308682041F280C2AB64C55850E7C471E30000000000067C000000007809FC0000007F00000002C0038022F0F134003882
    ...     0000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C460
    ...     00E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850
    ...     001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058
    ...     158B89A001C46000E140000040B02B0F11800388C00000C2C0AC3C28000E140000060B02B170A000388C001C28000008160401C0
    ...     468051013602083A6984614489B1CF870A244D867C0851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C0890
    ...     2040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E042810
    ...     3619F022408103619F000C888C6318C6318C6318C6318CF413003C00281C1401C0C01D00E000C0480080C07C1200400000002000
    ...     00401000000008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002000
    ...     024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA068
    ...     2000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA480
    ...     80004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D1540
    ...     62A8145526AAA0F1414178095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610
    ...     080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C018202004010080100435
    ...     43E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A
    Execute Egate Command    ue_change_location id=81 enb=2 cell=1
    Execute Egate Command    ue_param id=81 ue_nr_capabilities=${final_uecap}
    Clear Counter Files
    Start RRC Log    AD036

Check Two Scell Added Successfully
    [Arguments]    ${pcell}    ${scell1}    ${scell2}
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

Check Scell Change To TDD Successfully
    [Arguments]    ${scell}
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}


UE Attach and L3 Normal Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}

Start Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=6
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=7
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Triggered Scell Addition by A1
    [Arguments]    ${pcell}    ${ue_id}=81    ${rsrp}=100    ${rsrq}=30    ${scell_num}=2
    Execute Egate Command    ue_disp
    ${pcell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${pcell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_ssbfreq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

Triggered Scell Change by A1
    [Arguments]    ${pcell}    ${ue_id}=81    ${rsrp}=100    ${rsrq}=30    ${scell_num}=1
    Execute Egate Command    ue_disp
    ${pcell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${pcell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_ssbfreq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully


Release Scell
    [Arguments]      ${scell}    ${scell_index}=1    ${ue_id}=81
    ${ssbfreq}     Get From Dictionary    ${CELLS_SSBFREQ}     ${scell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${ssbfreq}    A2
    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
    ...    scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
