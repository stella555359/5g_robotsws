*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     ta5g_ue_measurements
Library     ta_messaging
Library     ta5g_tshark
Library     taf.config.wts    WITH NAME    wts
Library     taf.transport.ssh    WITH NAME    ssh

Documentation
...    This file contains general keywords used for testing Feature CB009017.

*** Variables ***
${UE_ID}=    11
${RRC_Reconfiguration}=
...    ((nr-rrc.criticalExtensions == 0)&&
...    (nr-rrc.eventId == 4)&&
...    (nr-rrc.freqBandIndicatorNR == 78)&&
...    (nr-rrc.ssbFrequency == 636576))
${RRC_Reconf_Complete}=    (x2ap.procedureCode == 28) && (nr-rrc.criticalExtensions == 0)
${TRAFFIC_DURATION}=      20s
${MEAS_DURATION}=      10s

*** Keywords ***
Setup X2 Links And Create Aliases For Gnb2 And Gnb3
    Setup X2 Link    initiator_device=1     complementary_device=2
    Setup X2 Link    initiator_device=1     complementary_device=3
    Create UEs alias
    ...  alias=UE
    ...  id_type=wts_5g
    Create eNB device with alias 'MeNB' identified by ip=10.0.1.137
    Create gNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create gNB device with alias 'gNB3' identified by ip=10.0.1.3
    Enable internal mirroring for alias  gNB2

Enable NSA HO
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_NSA_mobility.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_a5_activation.json

Enforce Full Rrc Reconfiguration
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enforced_actFullRrcConfNsaPscellChange.json

Enable Full Rrc Reconfiguration
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enabled_actFullRrcConfNsaPscellChange.json

Enable Inter Freq Inter Gnb Ho
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_inter_freq_ho_and_nsa_only.json

Disable Full Rrc Reconfiguration
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_disabled_actFullRrcConfNsaPscellChange.json

Modify Nrarfcn For Gnb3
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD}
    wts.Modify    cell_set id=1 gnb=3              nr_arfcn=2071591:2071591
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD}

Attach NSA Ue And Start Data Traffic
    [Arguments]    ${ue_nr_capabilities}
    Execute Egate Command    cmd=ue_param id=${UE_ID} ue_nr_capabilities=${ue_nr_capabilities}
    Attach Ue To Enb    ue_id=${UE_ID}
    Start Gnb Addition Procedure    ue=${UE_ID}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Start Data Traffic    ues=${UE_ID}    bearer_id=2    direction=dl    throughput=50mbps
    Start Data Traffic    ues=${UE_ID}    bearer_id=2    direction=ul    throughput=50mbps
    Sleep    ${TRAFFIC_DURATION}

Verify That Expected Throughput Is Achieved
    Check Bearer Throughput For Single Ue      ue_id=${UE_ID}     bearer_id=2    throughput=50    direction=dl
    Check Bearer Throughput For Single Ue      ue_id=${UE_ID}     bearer_id=2    throughput=50    direction=ul

UE11 sends measurement with eventA5 triggering PSCell change to gNB3
    ${meas_id_eventA5}=  Get Measurement id    EventA5   ue_id=11
    Send Custom UE Measurement NR    id=11 meas_id=${meas_id_eventA5} index=0 nrs_result=68:19:0 event=A5 phycell_id=52 nrsrp_nr=68 srsrp_nr=19
    ...                              pass_regexp=Proxy \\(eNB 3 cell 1\\) reported successful RA    timeout=10

Make that serving cell becomes worse than the threshold
    ${meas_id_eventA2}=  Get Measurement id    EventA2   ue_id=11
    Send Custom UE Measurement NR    id=11 meas_id=${meas_id_eventA2}  event=A2 srsrp_nr=30 srsrq_nr=30   timeout=15
    Sleep      ${MEAS_DURATION}

Get Measurement id
    [Arguments]  ${event_type}=EventA5  ${ue_id}=11  ${matching_line}=0
    ${measurements}=    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}  timeout=10s
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  ${matching_line}
    @{words}=  Split String  ${first_line}
    Log to console  MeasId: ${words}[0] for event: ${words}[2] found for RAT: ${words}[1]
    [Return]  ${words}[0]

Verify RRC Reconfiguration And RRC Reconfiguration Complete
    [Arguments]  ${filter}=${RRC_Reconfiguration}
    Verify Tshark For Given Number Of Messages
    ...    alias=${DEFAULT_S1_MME_ALIAS}
    ...    packet_filter=${filter}
    ...    number_of_messages=2

    Verify Tshark For Single Message
    ...    alias=${DEFAULT_S1_MME_ALIAS}
    ...    packet_filter=${RRC_Reconf_Complete}

Verify successful PSCell change for UE11
    Verify That Expected Throughput Is Achieved
    Verify RRC Reconfiguration And RRC Reconfiguration Complete
    Flow occurred as expected  alias=PSCell_change_UE11
    Flow occurred as expected  alias=PSCell

Expect PSCell change flow for UE11
    Expect message flow
    ...    MeNB:X2AP_SgNBAdditionRequest
    ...    MeNB:X2AP_SgNBReconfigurationComplete
    ...    MeNB:X2AP_SgNBChangeConfirm
    ...    alias=PSCell_change_UE11
    ...    overall_timeout=60

    Expect message flow
    ...    gNB3:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB3:X2AP_SNStatusTransfer
    ...    gNB3:X2AP_SgNBChangeRequired
    ...    gNB3:X2AP_SNStatusTransfer
    ...    alias=PSCell
    ...    overall_timeout=60

Handling Critical Ext And RRCReconf-v1700 IEs in SgNB Change Required
    Execute Egate Command    cmd=ue_gnb_endc_param id=11 rrc_reconf_v1700=4000
    Execute Egate Command    cmd=ue_gnb_endc_param id=11 critical_extn_futr_rrcreconfig=on

Force Full Config
    Execute Egate Command    cmd=gnb_endc_param id=2 force_full_config=on
    Execute Egate Command    cmd=gnb_endc_param id=3 rrc_configuration=full

Force MeNB to not send SgNBreconfiguration complete
    Execute Egate Command    cmd=enb_endc_param id=1 menb_failure_scenario=dont_send_sgnb_reconf_complete
