*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008985: NR FR1 TDD super cell
...         This feature supports NR FR1 TDD super cell RRM part. The super cell is a logical cell created by several sub-cells.
...         The same Physical Cell ID (PCI) is assigned to each sub-cell of the super cell. Each sub-cell of the super cell operates
...         on the same carrier frequency without resource multiplexing. Benefits for customers are: reduced handover ratio, improved
...         call service quality (i.e. call drop rate)
...
...      == TEST SET NAME ==
...         CB008985 - NR FR1 TDD super cell
...
...      == TESTING SPLIT ==
...         CB008985-A Basic function and performance of supercell
...         CB008985-B High speed supercell support
...         CB008985-C Interworking with other key features
...
...      == CONTACTS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == REFERENCES ==
...         CB008985 CFAM
...
...      == HISTORY ==
...         [12.08.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD
    ...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008985/SA_1_supercell_ABIP_3xAZQP_TDD_ECPRI.yaml

Suite Setup    Run Setup    reset_tl=${False}

Resource    ./resources/CB008985_keywords.robot

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/SANSA_TDD_1c_n_78_1eNBsim_1gNBsim.lua
${endMarker}=             OMIT   # TODO: ta_pcmd implementation

*** Test Cases ***
CB008985-A-B601_NSA_call_continuity_on_subcell_switch
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify TDD FR1 L3 NSA call continuity on one supercell during subcell switch scenarios.
    ...  Additionally PCMD traces will be verified
    ...
    ...  == Precondition: ==
    ...  - eNB1 - simulated eNB with CELL-1 onAir
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE11 NSA - Airphone simulator
    ...  - gNB2 up
    ...  - NRCELL.actSupercell is set to TRUE
    ...  - NRCELL.actBeamforming is set to FALSE
    ...  - NRCELL.pucchModeSelect is set to longPucch
    ...  - NRCELL.dlMimoMode is set to 2DL2UL
    ...  - NRCELL.numOfSuperSubcells is set to 3 (3xCHANNELGROUP configured)
    ...  - NRCELL.rlpDetCsiBsiThreshold is set to 10
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks is set to '3 beams' (set by OAM according to CFAM)
    ...  - NRBTS.actPaging is set to true
    ...  - NRBTS.actCarrierAggregation is set to false
    ...  - NRPMRNL.miNrBeamforming is set to 5min
    ...  - NRBTS.actPCMDReport is set to true
    ...  - NRBTS.actSubscriberTraceReport is set to true
    ...  - NRBTS.actCellTraceReport is set to true
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA+NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 3 simulated AZQP radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16871
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-A US#6: TDD FR1 call continuity during subcell switch
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=864736
    ...
    ...  == HISTORY ==
    ...     [12.08.2022] - TC Create
    ...     [12.12.2022] - PASS: SBTS23R1_ENB_0000_000361_000000

    [Setup]  Prepare test environment B601_NSA
    [Tags]    B601_NSA

    Attach UE11 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE11 with NRCELL_1 subcell_1 on gNB2
    Verify that CSI-SSB resources are properly allocated for UE11 by supercell in NSA mode which has 3 beams

    Run 5Mbps DL traffic on split bearer for UE11 and wait 5 seconds

    Clear PCMD records
    Trigger subcell switch for UE11 from NRCELL-1 subcell_1 to subcell_2 and verify PCMD BeamUsageTraceRecord
    Run keyword and ignore error  Verify 5MBps DL traffic on SCG split bearer for UE11

    Wait until PM counters file is ready and saved

    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=2
    Verify value for BEAM_CHANGE counters for given subcells switch list and unmentioned BEAM_CHANGE are equal zero
    ...  subcells_switch_list=[[1, 2]]
    ...  counter_value=1

    Clear PCMD records
    Trigger subcell switch for UE11 from NRCELL-1 subcell_2 to subcell_3 and verify PCMD BeamUsageTraceRecord
    Run keyword and ignore error  Verify 5MBps DL traffic on SCG split bearer for UE11

    Clear PCMD records
    Trigger subcell switch for UE11 from NRCELL-1 subcell_3 to subcell_2 and verify PCMD BeamUsageTraceRecord
    Run keyword and ignore error  Verify 5MBps DL traffic on SCG split bearer for UE11

    Wait until PM counters file is ready and saved

    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=3
    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=2
    Verify value for BEAM_CHANGE counters for given subcells switch list and unmentioned BEAM_CHANGE are equal zero
    ...  subcells_switch_list=[[2, 3], [3, 2]]
    ...  counter_value=1

    [Teardown]  Cleanup after test B601_NSA


CB008985-A-B601_SA_call_continuity_on_subcell_switch
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify TDD FR1 L3 SA call continuity on one supercell during subcell switch scenarios.
    ...  Additionally will be verified: PCMD traces and paging broadcast for IDLE UEs in supercell.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UE1 SA - Airphone simulator
    ...  - gNB2 up
    ...  - NRCELL.actSupercell is set to TRUE
    ...  - NRCELL.actBeamforming is set to FALSE
    ...  - NRCELL.pucchModeSelect is set to longPucch
    ...  - NRCELL.dlMimoMode is set to 2DL2UL
    ...  - NRCELL.numOfSuperSubcells is set to 3 (3xCHANNELGROUP configured)
    ...  - NRCELL.rlpDetCsiBsiThreshold is set to 10
    ...  - NRCELLGRP.numberOfTransmittedSsBlocks is set to '3 beams' (set by OAM according to CFAM)
    ...  - NRBTS.actPaging is set to true
    ...  - NRBTS.actCarrierAggregation is set to false
    ...  - NRPMRNL.miNrBeamforming is set to 5min
    ...  - NRBTS.actPCMDReport is set to true
    ...  - NRBTS.actSubscriberTraceReport is set to true
    ...  - NRBTS.actCellTraceReport is set to true
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 3 simulated AZQP radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16871
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-A US#6: TDD FR1 call continuity during subcell switch
    ...     AC review:
    ...     - https://collab.ext.net.nokia.com/ui#review:id=864501
    ...
    ...  == HISTORY ==
    ...     [05.08.2022] - TC Create
    ...     [12.12.2022] - PASS: SBTS23R1_ENB_0000_000361_000000

    [Setup]  Prepare test environment B601 SA
    [Tags]    B601_SA

    Attach UE1 to gNB2 NRCELL-1 subcell_1
    Verify that CSI-SSB resources are properly allocated for UE1 by supercell which has 3 beams

    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Clear PCMD records
    Trigger subcell switch for UE1 from NRCELL-1 subcell_1 to subcell_2 and verify PCMD BeamUsageTraceRecord
    Run keyword and ignore error  Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=1
    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=2
    Verify value for BEAM_CHANGE counters for given subcells switch list and unmentioned BEAM_CHANGE are equal zero
    ...  subcells_switch_list=[[1, 2]]
    ...  counter_value=1

    Clear PCMD records
    Trigger subcell switch for UE1 from NRCELL-1 subcell_2 to subcell_3 and verify PCMD BeamUsageTraceRecord
    Run keyword and ignore error  Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Clear PCMD records
    Trigger subcell switch for UE1 from NRCELL-1 subcell_3 to subcell_1 and verify PCMD BeamUsageTraceRecord
    Run keyword and ignore error  Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=3
    Verify DL_SERV_BEAM_ID_BEAM and UL_SERV_BEAM_ID_BEAM are greater than zero for subcell    subcell_id=1
    Verify value for BEAM_CHANGE counters for given subcells switch list and unmentioned BEAM_CHANGE are equal zero
    ...  subcells_switch_list=[[2, 3], [3, 1]]
    ...  counter_value=1

    Stop 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    # below steps covering B401
    Wait for UE1 to enter IDLE state
    Wait until keyword succeeds  10x  10s    Trigger NGAP: PAGING from AMF1 on supercell for UE1
    Verify gNB sent NR-RRC: DL_PCCH on all 3 subcells on NRCELL-1
    Verify that UE1 is in ACTIVE state in subcell_1

    [Teardown]  Cleanup after test B601_SA

*** Keywords ***
Prepare test environment B601_NSA
    Log to console    Prepare test environment B601_NSA
    Wait until PM counters file is ready and saved
    Start PCMD message collection

Prepare test environment B601_SA
    Log to console    Prepare test environment B601_SA
    Set UE IDLE timers on gNB: drbInactivityTimerSA=20 srbInactivityTimerSA=20
    Execute egate command    cmd=amf_paging_param id=1 max_paging_retries=10
    Wait until PM counters file is ready and saved
    Start PCMD message collection

Cleanup after test B601_NSA
    Detach and kill UE11
    Stop PCMD message collection
    Reset PCMD database

Cleanup after test B601_SA
    Detach and kill UE1
    Stop PCMD message collection
    Reset PCMD database

Trigger subcell switch for UE${ue_id:\d+} from NRCELL-${cell_id:\d+} subcell_${from:\d+} to subcell_${to:\d+} and verify PCMD BeamUsageTraceRecord
    [Documentation]
    ...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1059090147
    ...  Note: This has to be used after some traffic on subcell_${from:\d+}

    EXPECT FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    EXPECT FLOW[timeout=7]: gNB2 X2AP meNBinitiatedSgNBRelease
    EXPECT FLOW[timeout=7]: gNB2 X2AP sgNBinitiatedSgNBRelease

    ${ue_id}     Convert To Integer   ${ue_id}
    ${egate_cell_id}      Evaluate  ${cell_id} - 1
    ${egate_subcell_id_from}   Evaluate  ${from} - 1
    ${egate_subcell_id_to}     Evaluate  ${to} - 1

    Run keyword if    ${ue_id} <= 10   # SA UE
    ...  Execute egate command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${to} beamaction=switch scell=${egate_cell_id}
    ...  pass_regexp=Switching Beam via MAC CE for pdcch. Old Beam: ${egate_subcell_id_from} New Beam: ${egate_subcell_id_to}

    Run keyword if    ${ue_id} > 10   # NSA UE
    ...  Execute egate command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${to} beamaction=switch scell=8
    ...  pass_regexp=Switching Beam via MAC CE for pdcch. Old Beam: ${egate_subcell_id_from} New Beam: ${egate_subcell_id_to}

    #"mediumConfigBeamData": {
	#"numOfTotalBeamChanges": 1,
	#"numOfFailedBeamChanges": 1,   # TODO
	#"numOfTotalBeamRecoveries": 0,
	#"numOfSuccessfulBeamRecoveries": 0,
	#"beamIdUsageCount": [
	#	1,
	#	1,
    Run keyword and ignore error  Verify PCMD BeamUsageTraceRecord for UE${ue_id} switch from subcell_${from} to subcell_${to}

    FAIL FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    FAIL FLOW[timeout=7]: gNB2 X2AP meNBinitiatedSgNBRelease
    FAIL FLOW[timeout=7]: gNB2 X2AP sgNBinitiatedSgNBRelease

Verify PCMD BeamUsageTraceRecord for UE${ue_id:\d+} switch from subcell_${source_id:\d+} to subcell_${target_id:\d+}
    Set variable for record yaml    variable=endMarker             value=${endMarker}    yaml_path=${beamUsageRecord}
    Set variable for record yaml    variable=numOfTotalBeamChanges            value=1    yaml_path=${beamUsageRecord}
    Set variable for record yaml    variable=numOfFailedBeamChanges           value=0    yaml_path=${beamUsageRecord}
    Set variable for record yaml    variable=numOfTotalBeamRecoveries         value=0    yaml_path=${beamUsageRecord}
    Set variable for record yaml    variable=numOfSuccessfulBeamRecoveries    value=0    yaml_path=${beamUsageRecord}

    FOR    ${beam_index}    IN RANGE    8
        ${beam_index_to_compare}    Evaluate   ${beam_index} + 1

        Run keyword if    ${beam_index_to_compare} == ${target_id} or ${beam_index_to_compare} == ${source_id}
        ...  Set variable for record yaml    variable=${beam_index}_beam    value=1    yaml_path=${beamUsageRecord}

        Run keyword if    ${beam_index_to_compare} != ${target_id} and ${beam_index_to_compare} != ${source_id}
        ...  Set variable for record yaml    variable=${beam_index}_beam    value=0    yaml_path=${beamUsageRecord}
    END

    Add record for verification
    ...     record_name_with_alias=BeamUsageTraceRecord
    ...     yaml_path=${beamUsageRecord}

    Wait for PCMD records
    ...     record_num=3
    ...     record_name=BeamUsageTraceRecord
    ...     timeout=20

    Perform Records Verification
