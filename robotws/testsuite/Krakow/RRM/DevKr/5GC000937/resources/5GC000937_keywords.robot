*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Library     5GC000937_BWP_verifiers.py
Library     5GC000937_alarms_verifiers.py
Library     taf.ul.ue.sim.env_setup

*** Keywords ***
Prepare test suite
    [Arguments]    ${ute_ca}=${False}

    Run Keyword if  ${ute_ca} != ${False}
    ...    Prepare TL with config files

    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Reliable emss setup         bts_id=1
    Enable internal mirroring for alias  gNB2

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCFC}
     Add simulator    sim_type=airphone    config=${AP_XML}
     Configure environment    rmod_detection_timeout=420s
     Log To Console    After Configure ENV

Prepare test environment A4
    Create UEs alias
    ...  alias=UE
    ...  id_type=wts_5g
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Cleanup after test A4
    Release PDU1 session and deregister UE1
    Release PDU2 session and deregister UE2
    Release PDU3 session and deregister UE3
    Release PDU11 session and deregister UE11
    Release PDU14 session and deregister UE14

Release PDU${pdu_id:\d+} session and deregister UE${ue_id:\d+}
    Execute egate command  cmd=ue_kill id=${ue_id}

Attach UE${ue_id:\d+} and setup PDU session
    Attach UE
    ...  ue_id=${ue_id}
    ...  pass_regexp=UE${ue_id}: UE performed UNKNOWN_ATTACH_TYPE
    Execute egate command
    ...  cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...  pass_regexp=Initial Context Setup Successful for UE with AMF UE ID
    Sleep  1

Attach UE${ue_id:1[0-5]} with only ${BWP_IE:bwp-SwitchingDelay|bwp-SameNumerology} configured
    Expect UE${ue_id} RRCSetup flow
    Expect UE${ue_id} ICS flow with ${BWP_IE} set
    Expect UE${ue_id} RRCReconfiguration flow with Full BWP
    Attach UE${ue_id} and setup PDU session

Attach UE-${ue_id:[1-9]} with full BWP capabilities
    Expect UE${ue_id} RRCSetup flow
    Expect UE${ue_id} ICS flow with full BWP capabilities set
    Expect UE${ue_id} RRCReconfiguration flow with Power Saving BWP
    Attach UE${ue_id} and setup PDU session

Attach UE${ue_id:\d+} with full BWP capabilities to gNB2 NRCELL-${nrcell_id:[1-2]}
    Expect UE${ue_id} RRCSetup flow
    Expect UE${ue_id} ICS flow with full BWP capabilities set
    Expect UE${ue_id} RRCReconfiguration flow with Power Saving BWP
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=${nrcell_id}
    Attach UE${ue_id} and setup PDU session

Expect UE${ue_id:\d+} RRCSetup flow
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetupReq
    ...     UE_${ue_id}:NR-RRC_RRCSetup as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete as RRCSetupCompl
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=10

Expect UE${ue_id:\d+} RRCReconfiguration flow with Power Saving BWP
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (Verify Power Saving BWP on CSI and BWP To Add Mod List) as RRCReconf
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfCompl
    ...     alias=UE${ue_id}_RRC_reconf
    ...     overall_timeout=10

Expect UE${ue_id:\d+} RRCReconfiguration flow with full BWP
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (Verify Full BWP on CSI and BWP To Add Mod List) as RRCReconf
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfCompl
    ...     alias=UE${ue_id}_RRC_reconf
    ...     overall_timeout=10

Expect UE${ue_id:\d+} RRCReconfiguration flow to cell with enabled power saving
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (Verify Power Saving BWP on CSI and BWP To Add Mod List During HO) as RRCReconf
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfCompl
    ...     alias=UE${ue_id}_RRC_reconf
    ...     overall_timeout=10

Expect UE${ue_id:\d+} RRCReconfiguration flow to cell with disabled power saving
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (Verify Full BWP on CSI and BWP To Add Mod List During HO) as RRCReconf
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfCompl
    ...     alias=UE${ue_id}_RRC_reconf
    ...     overall_timeout=10

Expect UE${ue_id:1[0-5]} ICS flow with ${BWP_IE:bwp-SwitchingDelay|bwp-SameNumerology} set
    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitialUEMsg
    ...     AMF1:NGAP_InitialContextSetupRequest as ICSReq
    ...     AMF1:NGAP_UERadioCapabilityInfoIndication as UECapabilityInfo
    ...     AMF1:NGAP_InitialContextSetupResponse as ICSResp
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=10

Expect UE${ue_id:[1-9]} ICS flow with full BWP capabilities set
    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitialUEMsg
    ...     AMF1:NGAP_InitialContextSetupRequest as ICSReq
    ...     AMF1:NGAP_UERadioCapabilityInfoIndication as UECapabilityInfo
    ...     AMF1:NGAP_InitialContextSetupResponse as ICSResp
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=10

Attach 3 UEs with full BWP capabilities
    Attach UE-1 with full BWP capabilities
    Attach UE-2 with full BWP capabilities
    Attach UE-3 with full BWP capabilities

Verify that all 3 UEs did configure power saving BWP during attach
    Verify that UE1 did configure power saving BWP during attach
    Verify freqHopping c_SRS value
    ...     flow_alias=UE1_RRC_reconf
    ...     message_alias=RRCReconf
    Verify that UE2 did configure power saving BWP during attach
    Verify that UE3 did configure power saving BWP during attach

Verify that UE${ue_id:1[0-5]} did not configure power saving BWP during attach
    Flow occurred as expected    alias=UE${ue_id}_RRC_attach
    Flow occurred as expected    alias=UE${ue_id}_RRC_reconf
    Flow occurred as expected    alias=UE${ue_id}_NGAP_attach
    Check ue capabilities  UE${ue_id}_NGAP_attach   UECapabilityInfo

Verify that UE${ue_id:[1-9]} did configure power saving BWP during attach
    Flow occurred as expected    alias=UE${ue_id}_RRC_attach
    Flow occurred as expected    alias=UE${ue_id}_RRC_reconf
    Flow occurred as expected    alias=UE${ue_id}_NGAP_attach
    Check ue capabilities  UE${ue_id}_NGAP_attach   UECapabilityInfo

Set gscn to ${gscn_value} and send configuration to gNB
    Set    NRCELL-1.gscnOrSsPbchArfcn    ${gscn_value}    bts_id=1
    Configure    ${CURDIR}/../config/SBTS22R1/5GC000937_gscn_setting    bts_id=1
    Sleep  1

Reboot gNB and check radios availability
    Trigger site reset
    Check radios availability
    Sleep  1

Verify that cell activation failed and 7516 alarm with IncorrectCellParameterConfiguration fault was raised
    Log to console  Trying to get active alarms from BTS
    Wait until keyword succeeds  60 sec  10 sec
    ...    Verify that 7516 alarm with Incorrect Cell Parameter Configuration fault was raised
    Sleep  1

Verify that 7516 alarm with Incorrect Cell Parameter Configuration fault was raised
    ${result}  Verify that alarm 7516 with Incorrect cell parameter configuration fault is active
    Pass Execution If  '${result}'=='True'  Alarm 7516 found
    Fail  Alarm 7516 not found

Cleanup after test A2
    Set gscn to 7857 and send configuration to gNB
    Lock all cells
    Unlock all cells

Attach UE1 to cell-${nrcell_id}
    Sleep  30s
    Execute egate command  cmd=ue_change_location id=1 enb=2 cell=${nrcell_id}
    Attach UE1 and setup PDU session

Change iphy file
    [Arguments]  ${iphy_file}
    Update and put IPHY xml    input_filepath=${iphy_file}
    Trigger site reset
    Sleep  150s
    Trigger site reset
    Check radios availability

Cleanup after test A5
    Set NRCELL-1 parameter actPowerSavingBwp to TRUE
    Release PDU1 session and deregister UE1
    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1

Detach UE1
    Execute egate command  cmd=deregister_ue id=1 by=amf
    Sleep  1s
    Execute egate command  cmd=kill_ue id=1

Expect F1AP flow with ${bwp_type:Power Saving|normal} BWP configuration
    Expect Message Flow
    ...     gNB2:F1AP_UEContextModificationRequest (HandoverPreparationInformation is present) as HO_init
    ...     gNB2:F1AP_UEContextModificationResponse
    ...     alias=F1AP_HO_flow
    ...     overall_timeout=10

Run CRT setup
    Log To Console    Setup started
    Reach Onair    lua_cfg=${LUA_CFG}
#    Setup egate  egate_port=20000   alias=default
    Setup devices aliases
    Enable internal mirroring for alias  gNB2

Run local setup
    Log To Console    Setup started
    Change iphy file   iphy_file=${iphy_file}
    Reach Onair    lua_cfg=${LUA_CFG}
    Setup devices aliases
    Enable internal mirroring for alias  gNB2

Set NRCELL-1 parameter actPowerSavingBwp to FALSE
    Send Delta Commissioning    input_filepath=${CURDIR}/../config/SBTS22R1/delta_937_actPowerSavingBwp_disabled.json
    Sleep  60s

Set NRCELL-1 parameter actPowerSavingBwp to TRUE
    Send Delta Commissioning    input_filepath=${CURDIR}/../config/SBTS22R1/delta_937_actPowerSavingBwp_enabled.json

Setup devices aliases
    Create ues alias
    ...   alias=UE
    ...   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

UE${ue_id:\d+} triggers handover to gNB2 NRCELL-${nrcell_id:[1-2]} where actPowerSavingBwp is disabled
    Expect F1AP flow with Power Saving BWP configuration
    Expect UE1 RRCReconfiguration flow to cell with disabled power saving
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 phycell_id=${phy_cell_id}[${nrcell_id}] nrsrp_nr=40

UE${ue_id:\d+} triggers handover to gNB2 NRCELL-${nrcell_id:[1-2]} where actPowerSavingBwp is enabled
    Expect F1AP flow with Power Saving BWP configuration
    Expect UE1 RRCReconfiguration flow to cell with enabled power saving
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 phycell_id=${phy_cell_id}[${nrcell_id}] nrsrp_nr=40

Verify that power saving configuration is not present in Handover Preparation IE over F1 interface
    Flow occurred as expected   alias=F1AP_HO_flow
    Decode HandoverPreparationInformation IE and verify it
    ...   flow_alias=F1AP_HO_flow
    ...   message_alias=HO_init
    ...   pwr_svg_status_in_source=disabled

Verify that power saving configuration is present in Handover Preparation IE over F1 interface
    Flow occurred as expected   alias=F1AP_HO_flow
    Decode HandoverPreparationInformation IE and verify it
    ...   flow_alias=F1AP_HO_flow
    ...   message_alias=HO_init
    ...   pwr_svg_status_in_source=enabled

Verify that UE${ue_id:[1-9]} ${result:configured|did not configure} power saving BWP after HO
    Flow occurred as expected   alias=UE${ue_id}_RRC_reconf
