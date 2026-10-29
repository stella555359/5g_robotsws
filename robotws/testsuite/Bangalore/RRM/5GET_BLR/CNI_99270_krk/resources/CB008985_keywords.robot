*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../resources/KRK/Robot/common_settings.robot
Resource    ../../resources/KRK/Robot/verifiers.robot
Resource    ../../resources/KRK/Robot/yaml_config_paths.robot
Resource    ../../resources/KRK/Robot/ssh.robot

Library     ./CB008985_CSI_verifiers.py
Library     ./CB008985_beam_counters_verifiers.py
Library     ../../resources/KRK/Python/mock_stop_egate.py
Library     ../../resources/KRK/Python/floating_counters.py
Library     SIB_from_each_subcell_verifier.py
Library     taf.ul.ue.sim.env_setup

*** Variables ***
${CP_RT_rdTRSSlotAligned}        0x59008A=1 # rdTRSSlotAligned
${CP_RT_rdNewTddCellSlotModel}   0x420062=1 # rdNewTddCellSlotModel

@{SWCONFIG_FLAGS_LIST}          ${CP_RT_rdTRSSlotAligned}  ${CP_RT_rdNewTddCellSlotModel}
@{AP_SWCONFIG_FLAGS_LIST}       0x70697=0

@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}           ${SIB_config_yaml_path}
...                             ${PCMD_enable_yaml_path}

${beamUsageRecord}              ${CURDIR}/beamUsageRecord.yaml

${beamProfile_1}  beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5,6,7
...               ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
${beamProfile_2}  beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5,6,7
...               ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
${beamProfile_3}  beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5,6,7
...               ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125
${beamProfile_4}  beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5,6,7
...               ssbeam_bestbeam=3 ssbeam_rsrp_best=-52 ssbeam_rsrp_avg=-128

&{CA_cell_type_to_msg_number_in_flow}    PCell=2    SCell=3

*** Keywords ***
Prepare test suite
    [Arguments]    ${ute_ca}=${False}

    Run Keyword if  ${ute_ca} != ${False}
    ...    Prepare TL with config files

    Reliable emss setup         bts_id=1
    Configure       ${yaml_paths_to_configure}
    Setup devices aliases
    Reach onAir state
    Setup egate  egate_port=20000  alias=default
    Enable internal mirroring for alias    gNB2
    Create multi beam profiles for subcells with testmode

Prepare TL with config files
    Log To Console    Configure ENV with SCFC/AP.xml/LUA
    Add gNB configuration    scfc=${SCFC}
    Add simulator    sim_type=airphone    config=${AP_XML}
    Configure environment    rmod_detection_timeout=420s
    Log To Console    After Configure ENV

Run Setup
    [Arguments]        ${reset_tl}=${False}

    Log To Console    Setup started
    Reliable emss setup         bts_id=1
    Configure       ${yaml_paths_to_configure}

    Setup devices aliases

    ${run_update}    Get variable value      ${configure}    "True"   # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Reach onAir state
    ...    reset_tl=${reset_tl}
    Run Keyword if  ${run_update} != "True"
    ...    Setup egate  egate_port=20000  alias=default

    Enable internal mirroring for alias    gNB2
    Create multi beam profiles for subcells with testmode

Reach onAir state
    [Arguments]         ${reset_tl}=${False}

    Run Keyword if  ${reset_tl} != ${False}
    ...     Run keywords
    ...  Connect using ssh to    gNB_CLASSICAL_OAM
    ...  AND  Connect using ssh to    AP
    ...  AND  Backup and modify swconfig file    parameters_list=@{SWCONFIG_FLAGS_LIST}
    ...  AND  Modify AP swconfig file    parameters_list=@{AP_SWCONFIG_FLAGS_LIST}    connection=AP
    ...  AND  Delete HashContainer files    gNB_CLASSICAL_OAM
    ...  AND  Trigger site reset
    ...  AND  Wait for testline ICMP Echo replies and SSH services
    ...  AND  Sleep  60
    ...  AND  Check radios availability

    Wait for gNB to reach configured state
    Discover BTS

    Log To Console    Before Reach OnAir

    @{NRCELL_list}                  get_existing_objects_of_given_type    NRCELL
    ${NRCELL_list_length}           Get length    ${NRCELL_list}
    ${NRCELL_list_length_for_loop}  Evaluate  ${NRCELL_list_length} + 1
    Set suite variable              ${NRCELL_list_length_for_loop}

    Expect SIB1 will be sent from all configured supercells on each subcell
    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Verify that SIB1 was sent from all configured supercells on each subcell

    Log To Console    After Reach OnAir

Setup devices aliases
    Create UEs alias    alias=UE    id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.32
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Create cells alias     alias=NRCELL    cells_type=wts_5g

Create multi beam profiles for subcells with testmode
    [Documentation]    Note: Beam is treated as subcell in these commands
    Execute egate command    cmd=${beamProfile_1}
    Execute egate command    cmd=${beamProfile_2}
    Execute egate command    cmd=${beamProfile_3}
    Execute egate command    cmd=${beamProfile_4}

Expect SIB1 will be sent from all configured supercells on each subcell
    FOR  ${cell_id}  IN RANGE    1  ${NRCELL_list_length_for_loop}
        &{numOfSuperSubCells_dict}    get_object_attributes    NRCELL-${cell_id}    numOfSuperSubCells
        ${numOfSuperSubCells}    Get from dictionary    ${numOfSuperSubCells_dict}    numofsupersubcells
        ${cell_id_str}    Convert to string    ${cell_id}
        EXPECT FLOW[timeout=3600]: NRCELL_2_${cell_id_str} NR-RRC ${numOfSuperSubCells}*SIB1
    END

Verify that SIB1 was sent from all configured supercells on each subcell
    FOR  ${cell_id}  IN RANGE    1  ${NRCELL_list_length_for_loop}
        &{numOfSuperSubCells_dict}    get_object_attributes    NRCELL-${cell_id}    numOfSuperSubCells
        ${numOfSuperSubCells}    Get from dictionary    ${numOfSuperSubCells_dict}    numofsupersubcells
        ${cell_id_str}    Convert to string    ${cell_id}
        PASS FLOW[timeout=3600]: NRCELL_2_${cell_id_str} NR-RRC ${numOfSuperSubCells}*SIB1
    END

Verify that supercell NRCELL-1 is onAir
    Object attributes should be    NRCELL-1    operationalState=enabled

Verify that supercell NRCELL-${supercell_id:\d+} broadcast SIB1 messages from all ${subcells_count:\d+} subcells
    ${flow}=    Get flow name
    ...     ${subcells_count}*SIB1
    ...     device=NRCELL_2_${supercell_id}
    ...     protocol=NR-RRC

    verify_sib1_was_sent_from_each_subcell     flow_alias=${flow}    subcells_count=${subcells_count}

Attach UE${ue_id:\d+} to gNB2 NRCELL-${supercell_id:\d+} subcell_${subcell_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification

    Execute egate command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${subcell_id} beamaction=attach
    Attach UE${ue_id} to gNB2 cell${supercell_id} with ICS during PDU session setup

    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification

Trigger subcell switch for UE${ue_id:\d+} from NRCELL-${supercell_id:\d+} subcell_${from:\d+} to subcell_${to:\d+}
    [Documentation]
    ...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1059090147
    ...  Note: This has to be used after some traffic on subcell_${from:\d+}

    EXPECT FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    EXPECT FLOW[timeout=7]: gNB2 X2AP meNBinitiatedSgNBRelease
    EXPECT FLOW[timeout=7]: gNB2 X2AP sgNBinitiatedSgNBRelease

    ${ue_id}     Convert To Integer   ${ue_id}
    ${egate_supercell_id}      Evaluate  ${supercell_id} - 1
    ${egate_subcell_id_from}   Evaluate  ${from} - 1
    ${egate_subcell_id_to}     Evaluate  ${to} - 1

    Run keyword if    ${ue_id} <= 10   # SA UE
    ...  Execute egate command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${to} beamaction=switch scell=${egate_supercell_id}
    ...  pass_regexp=Switching Beam via MAC CE for pdcch. Old Beam: ${egate_subcell_id_from} New Beam: ${egate_subcell_id_to}

    Run keyword if    ${ue_id} == 11   # NSA UE11
    ...  Execute egate command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${to} beamaction=switch scell=${UE11}[${supercell_id}]
    ...  pass_regexp=Switching Beam via MAC CE for pdcch. Old Beam: ${egate_subcell_id_from} New Beam: ${egate_subcell_id_to}

    Run keyword if    ${ue_id} == 12   # NSA UE12
    ...  Execute egate command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${to} beamaction=switch scell=${UE12}[${supercell_id}]
    ...  pass_regexp=Switching Beam via MAC CE for pdcch. Old Beam: ${egate_subcell_id_from} New Beam: ${egate_subcell_id_to}

    Run keyword if    ${ue_id} > 12   # NSA UE
    ...  Execute egate command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${to} beamaction=switch scell=8
    ...  pass_regexp=Switching Beam via MAC CE for pdcch. Old Beam: ${egate_subcell_id_from} New Beam: ${egate_subcell_id_to}

    FAIL FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    FAIL FLOW[timeout=7]: gNB2 X2AP meNBinitiatedSgNBRelease
    FAIL FLOW[timeout=7]: gNB2 X2AP sgNBinitiatedSgNBRelease

Trigger SgnbAddition procedure for UE${ue_id:\d+} with NRCELL_${supercell_id:\d+} subcell_${subcell_id:\d+} on gNB2
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${subcell_id} beamaction=attach scell=8

    Trigger SgnbAddition procedure for UE${ue_id} with NRCELL_${supercell_id} on gNB2

Trigger NGAP: PAGING from AMF1 on supercell for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP paging
    EXPECT FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

    Execute egate command    cmd=amf_paging_start id=1 ue=${ue_id}

    PASS FLOW[timeout=10]: AMF1 NGAP paging
    PASS FLOW[timeout=10]: gNB2 NGAP initialContextSetup
    PASS FLOW[timeout=10]: gNB2 NGAP pDUSessionResourceSetup

Trigger A1 measurement for UE${ue_id:[1-9]} with result greater than TDD threshold
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    Execute egate command
    ...   cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach scell=1

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=60 phycell_id=50 nrsrp_nr=60
    ...   pass_regexp=SCellIndex 1 activated successfully at airphone

    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

Trigger A6 measurement for UE${ue_id:[1-9]} for SCell Swap
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=A6 srsrp_nr=51 phycell_id=52 nrsrp_nr=50 scell=1 scell_rsrp=10 scell_rsrq=10
    ...   pass_regexp=SCellIndex 2 activated successfully at airphone

    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Trigger A1 measurement in NSA mode for UE${ue_id:[1-9]+} with result greater than TDD threshold
    EXPECT FLOW[timeout=10]: gNB2 X2AP rRCTransfer
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: gNB2 X2AP sgNBinitiatedSgNBModification

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=60 phycell_id=50 nrsrp_nr=60
    ...   pass_regexp=SCellIndex 9 activated successfully at airphone

    PASS FLOW[timeout=10]: gNB2 X2AP rRCTransfer
    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: gNB2 X2AP sgNBinitiatedSgNBModification

Trigger A2 measurement for UE${ue_id:[1-9]} with result lower than SCell Release threshold for SCELL-${sid:\d+}
    ${pci}    Evaluate    ${sid} + 50
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=60 phycell_id=${pci} nrsrp_nr=60 scell=${sid} scell_rsrp=10 scell_rsrq=10
    ...  pass_regexp=CONTEXT SETUP.*scellIdx:0

    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Trigger A2 measurement for UE${ue_id:[1-9]+} in NSA mode with result lower than SCell Release threshold for NRCELL-${scell_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 X2AP rRCTransfer
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: gNB2 X2AP sgNBinitiatedSgNBModification

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=60 phycell_id=52 nrsrp_nr=60 scell=9 scell_rsrp=10 scell_rsrq=10
    ...   pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity

    PASS FLOW[timeout=10]: gNB2 X2AP rRCTransfer
    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: gNB2 X2AP sgNBinitiatedSgNBModification

Verify that UE${ue_id:\d+} is in ACTIVE state in subcell_${subcell_id:\d+}
    EXPECT FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    EXPECT FLOW[timeout=7]: gNB2 X2AP meNBinitiatedSgNBRelease
    EXPECT FLOW[timeout=7]: gNB2 X2AP sgNBinitiatedSgNBRelease
    FAIL FLOW[timeout=7]: gNB2 NGAP uEContextRelease
    FAIL FLOW[timeout=7]: gNB2 X2AP meNBinitiatedSgNBRelease
    FAIL FLOW[timeout=7]: gNB2 X2AP sgNBinitiatedSgNBRelease

Verify gNB sent NR-RRC: DL_PCCH on all ${subcells_count:\d+} subcells on NRCELL-1
    FOR    ${subcell_id}    IN RANGE    ${subcells_count}
        Verify egate content    expected_pattern=PhyCellId:50.*LocalCellId:${subcell_id}.*Paging Received
    END

Verify that UE${ue_id:\d+} configured ${meas_type:A1|A2|A6} measurement during ${proc:Initial Context Setup|SCell Addition}
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query   (
    ...                                   reportConfigToAddModList contains (
    ...                                      reportConfigNR contains (
    ...                                         eventId contains (
    ...                                           event${meas_type} is present)
    ...                                         )
    ...                                     )
    ...                                   )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow}

Verify that UE${ue_id:\d+} configured ${meas_type:A2|A6} measurement during NSA SCell Addition
    ${flow}=     Get Flow Name
    ...     procedure=sgNBinitiatedSgNBModification
    ...     device=gNB2
    ...     protocol=X2AP

    Verify That Message Fulfills Query   (
    ...                                   reportConfigToAddModList contains (
    ...                                      reportConfigNR contains (
    ...                                         eventId contains (
    ...                                           event${meas_type} is present)
    ...                                         )
    ...                                     )
    ...                                   )
    ...     message_alias=SgNBModificationRequired
    ...     flow_alias=${flow}

Verify that UE${ue_id:\d+} configured ${meas_type:A1|A6} measurement during SgnbAddition
    ${flow}=     Get Flow Name
    ...     procedure=sgNBAdditionPreparation
    ...     device=gNB2
    ...     protocol=X2AP

    Verify That Message Fulfills Query   (
    ...                                   reportConfigToAddModList contains (
    ...                                      reportConfigNR contains (
    ...                                         eventId contains (
    ...                                           event${meas_type} is present)
    ...                                         )
    ...                                     )
    ...                                   )
    ...     message_alias=SgNBAdditionRequestAcknowledge
    ...     flow_alias=${flow}

Verify that blind SCell addition NRCELL-${scell_id:\d+} is successful for UE${ue_id:\d+}
    ${flow}=    Get flow name
    ...     procedure=5*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(SCell-ToBeSetupMod-List) eq 1
    ...     message_alias=UEContextModificationRequest_3
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     length(sCellToAddModList) eq 1
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}

Verify that blind NSA SCell addition NRCELL-${scell_id:\d+} is successful for UE${ue_id:\d+}
    ${flow}=    Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(SCell-ToBeSetup-List) eq 1
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     length(sCellToAddModList) eq 1
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}

Verify that covBasedA1 SCell addition NRCELL-${scell_id:\d+} is successful for UE${ue_id:\d+}
    ${flow}=    Get flow name
    ...     procedure=3*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(SCell-ToBeSetupMod-List) eq 1
    ...     message_alias=UEContextModificationRequest_1
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     length(sCellToAddModList) eq 1
    ...     message_alias=UEContextModificationResponse_1
    ...     flow_alias=${flow}

Verify that SCell NRCELL-${scell_id:\d+} is not configured for UE${ue_id:\d+}
    ${flow}=    Get flow name
    ...     procedure=2*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     sCellToAddModList is not present
    ...     message_alias=UEContextModificationResponse_2
    ...     flow_alias=${flow}

Verify that SCell NRCELL-${scell_id:\d+} is not configured in NSA mode for UE${ue_id:\d+}
    ${flow}=    Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     sCellToAddModList is not present
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}

Verify that UE${ue_id:\d+} released NRCELL-${scell_id:\d+} SCell
    ${flow}=    Get flow name
    ...     procedure=3*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(sCellToReleaseList) eq 1
    ...     message_alias=UEContextModificationResponse_1
    ...     flow_alias=${flow}

Verify that SCell Change from NRCELL-${from_scell:\d+} to NRCELL-${to_scell:\d+} is successful for UE${ue_id:\d+}
    ${flow}=    Get flow name
    ...     procedure=3*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     sCellToAddModList contains (sCellIndex eq 2)
    ...     message_alias=UEContextModificationResponse_1
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     length(sCellToReleaseList) eq 1
    ...     message_alias=UEContextModificationResponse_1
    ...     flow_alias=${flow}

Verify that NSA SCell Change from NRCELL-${from_scell:\d+} to NRCELL-${to_scell:\d+} is successful for UE${ue_id:\d+}
#TODO: remove or try SCell Change

    ${flow}=    Get flow name
    ...     procedure=meNBinitiatedSgNBModificationPreparation
    ...     device=gNB2
    ...     protocol=X2AP

    Verify That Message Fulfills Query
    ...     sCellToAddModList contains (sCellIndex eq 2)
    ...     message_alias=SgNBModificationRequestAcknowledge
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     length(sCellToReleaseList) eq 1
    ...     message_alias=SgNBModificationRequestAcknowledge
    ...     flow_alias=${flow}

Verify that CSI-SSB resources are properly allocated for UE${ue_id:\d+} by supercell which has ${numberOfTransmittedSsBlocks:\d+} beams
    ${flow}=    Get flow name
    ...     procedure=2*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${nzp_CSI_RS_ResourceSetToAddModList_length}     Evaluate  ${numberOfTransmittedSsBlocks} + 1
    Verify That Message Fulfills Query
    ...     length(nzp-CSI-RS-ResourceSetToAddModList) eq ${nzp_CSI_RS_ResourceSetToAddModList_length}
    ...     message_alias=UEContextModificationResponse_2  # _2 means that 2nd UEContextModificationResponse contains IEs to verify
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-SSB-ResourceSetToAddModList is present)
    ...     message_alias=UEContextModificationResponse_2
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     length(csi-SSB-ResourceList) eq ${numberOfTransmittedSsBlocks}
    ...     message_alias=UEContextModificationResponse_2
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10)
    ...     message_alias=UEContextModificationResponse_2
    ...     flow_alias=${flow}

    verify_that_ue_has_csi_ssb_resources_configured_by_supercell     flow_alias=${flow}    message_alias=UEContextModificationResponse_2

Verify that CSI-SSB resources are properly allocated for UE${ue_id:\d+} by supercell in NSA mode which has ${numberOfTransmittedSsBlocks:\d+} beams
    ${flow}=    Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    ${nzp_CSI_RS_ResourceSetToAddModList_length}     Evaluate  ${numberOfTransmittedSsBlocks} + 1
    Verify That Message Fulfills Query
    ...     length(nzp-CSI-RS-ResourceSetToAddModList) eq ${nzp_CSI_RS_ResourceSetToAddModList_length}
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-SSB-ResourceSetToAddModList is present)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     length(csi-SSB-ResourceList) eq ${numberOfTransmittedSsBlocks}
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}

    verify_that_ue_has_csi_ssb_resources_configured_by_supercell     flow_alias=${flow}    message_alias=UEContextSetupResponse

Verify that CSI-SSB resources are properly allocated for UE${ue_id:\d+} in NSA mode by PCell only
    ${flow}=    Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (length(nzp-CSI-RS-ResourceSetToAddModList) eq 3)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (csi-SSB-ResourceSetToAddModList is present)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (length(csi-SSB-ResourceList) eq 2)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}

    verify_that_ue_has_csi_ssb_resources_configured_by_supercell  flow_alias=${flow}  message_alias=UEContextSetupResponse

Verify that CSI-SSB resources are properly allocated for UE${ue_id:\d+} in NSA mode by PCell and SCell
    ${flow}=    Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (length(nzp-CSI-RS-ResourceSetToAddModList) eq 3)
    ...     and
    ...     sCellConfigDedicated contains (length(nzp-CSI-RS-ResourceSetToAddModList) eq 3)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (csi-SSB-ResourceSetToAddModList is present)
    ...     and
    ...     sCellConfigDedicated contains (csi-SSB-ResourceSetToAddModList is present)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (length(csi-SSB-ResourceList) eq 2)
    ...     and
    ...     sCellConfigDedicated contains (length(csi-SSB-ResourceList) eq 2)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10))
    ...     and
    ...     sCellConfigDedicated contains (csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}

    verify_that_ue_has_csi_ssb_resources_configured_by_supercell  flow_alias=${flow}  message_alias=UEContextSetupResponse

    Verify That Message Has Fields
    ...     spCellConfigDedicated..csi-MeasConfig..setup..csi-ReportConfigToAddModList is present
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}

    Verify That Message Has Fields
    ...     sCellConfigDedicated..csi-MeasConfig..setup..csi-ReportConfigToAddModList is not present
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow}

Verify that CSI-SSB resources are properly allocated for UE${ue_id:\d+} by ${cell:PCell|SCell} which has ${numberOfTransmittedSsBlocks:\d+} beams
    ${msg_number}    Get From Dictionary    ${CA_cell_type_to_msg_number_in_flow}   ${cell}

    ${flow}=    Get flow name
    ...     procedure=5*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${nzp_CSI_RS_ResourceSetToAddModList_length}     Evaluate  ${numberOfTransmittedSsBlocks} + 1
    Verify That Message Fulfills Query
    ...     length(nzp-CSI-RS-ResourceSetToAddModList) eq ${nzp_CSI_RS_ResourceSetToAddModList_length}
    ...     message_alias=UEContextModificationResponse_${msg_number}  # _3 means that 3rd UEContextModificationResponse contains IEs to verify
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-SSB-ResourceSetToAddModList is present)
    ...     message_alias=UEContextModificationResponse_${msg_number}
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     length(csi-SSB-ResourceList) eq ${numberOfTransmittedSsBlocks}
    ...     message_alias=UEContextModificationResponse_${msg_number}
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10)
    ...     message_alias=UEContextModificationResponse_${msg_number}
    ...     flow_alias=${flow}

    Run keyword if    '${cell}' == 'PCell'
    ...  verify_that_ue_has_csi_ssb_resources_configured_by_supercell  flow_alias=${flow}  message_alias=UEContextModificationResponse_${msg_number}

    Run keyword if    '${cell}' == 'SCell'
    ...  Verify That Message Has Fields
    ...     sCellConfigDedicated..csi-MeasConfig..setup..csi-ReportConfigToAddModList is not present
    ...     message_alias=UEContextModificationResponse_${msg_number}
    ...     flow_alias=${flow}

    Run keyword if    '${cell}' == 'SCell'
    ...  Verify That Message Fulfills Query
    ...     length(csi-ReportConfigToAddModList) eq 2    # spCellConfigDedicated...csi-ReportConfigToAddModList
    ...     message_alias=UEContextModificationResponse_${msg_number}
    ...     flow_alias=${flow}

Verify that CSI-SSB resources are properly allocated for UE${ue_id:\d+} after ${meas:A1|A6} measurement by PCell and SCell with ${beams:\d+} beams
    ${flow}=    Get flow name
    ...     procedure=3*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${nzp_CSI_RS_ResourceSetToAddModList_length}     Evaluate  ${beams} + 1
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (length(nzp-CSI-RS-ResourceSetToAddModList) eq ${nzp_CSI_RS_ResourceSetToAddModList_length})
    ...     and
    ...     sCellConfigDedicated contains (length(nzp-CSI-RS-ResourceSetToAddModList) eq ${nzp_CSI_RS_ResourceSetToAddModList_length})
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (csi-SSB-ResourceSetToAddModList is present)
    ...     and
    ...     sCellConfigDedicated contains (csi-SSB-ResourceSetToAddModList is present)
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (length(csi-SSB-ResourceList) eq ${beams})
    ...     and
    ...     sCellConfigDedicated contains (length(csi-SSB-ResourceList) eq ${beams})
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10))
    ...     and
    ...     sCellConfigDedicated contains (csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq 10))
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}

    verify_that_ue_has_csi_ssb_resources_configured_by_supercell  flow_alias=${flow}  message_alias=UEContextModificationResponse_3

    Verify That Message Has Fields
    ...     spCellConfigDedicated..csi-MeasConfig..setup..csi-ReportConfigToAddModList is present
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}

    Verify That Message Has Fields
    ...     sCellConfigDedicated..csi-MeasConfig..setup..csi-ReportConfigToAddModList is not present
    ...     message_alias=UEContextModificationResponse_3
    ...     flow_alias=${flow}
