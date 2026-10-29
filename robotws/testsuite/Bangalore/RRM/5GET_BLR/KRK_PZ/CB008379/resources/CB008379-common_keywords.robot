*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <michal.szymakowski@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

#Resource    ../../../resources/Robot/common_settings.robot
Resource    ../../../resources/KRK/Robot/common_settings.robot
#Resource    ../../resources/verifiers.robot
Resource    ../../../resources/KRK/Robot/verifiers.robot
Resource    CB008379-verify_imports.robot
Resource    CB008379_setups_and_teardowns.robot
Resource    CB008379-repeat_test_case.robot
#Resource    ../../resources/yaml_config_paths.robot
Resource    ../../../resources/KRK/Robot/yaml_config_paths.robot

#Library     ../../../resources/PCMD/verifier_msg_for_pcmd.py
Library     ../../../resources/KRK/PCMD/verifier_msg_for_pcmd.py
#Library     ../../../resources/Python/floating_counters.py
Library     ../../../resources/KRK/Python/floating_counters.py
#Library     ../../../resources/Python/utilities.py
Library     ../../../resources/KRK/Python/utilities.py
#Library     ../../resources/python/mock_stop_egate.py
Library     ../../../resources/KRK/Python/mock_stop_egate.py
Library     taf.ul.ue.sim.env_setup

*** Variables ***
# mapping in &{5QI_TO_EGATE_QOS_FLOW_ID} reflects mapping in DevKr/CB008379/config/SA_FDD_1c_1eNBsim_1gNBsim.lua in opposite direction
# &{5QI_TO_EGATE_QOS_FLOW_ID}=  5QIX=lua_qosflow_idX  5QIY=lua_qosflow_idY  ...
&{5QI_TO_EGATE_QOS_FLOW_ID}=  1=1  2=2  3=3  4=4  71=5  72=6  76=7  128=8  212=9  254=10  5=11  6=12  7=13  8=14  9=15  170=16
${5QI_VoNR}=  1
# mapping in &{5QI_TO_EGATE_QOS_FLOW_ID} reflects mapping in NRDRB-5QI-s
# &{5QI_TO_NRDRB}=  NRDRB_5QI_X.fiveqiValueList[0]=NRDRB_5QI_X.nrDrbDN  NRDRB_5QI_Y.fiveqiValueList[0]=NRDRB_5QI_Y.nrDrbDN  ...
&{5QI_TO_NRDRB}=  1=15  2=16  3=17  4=18  71=19  72=20  76=21  128=22  170=23  212=24  254=25  5=10  6=11  7=12  8=13  9=14

${yaml_enable_intraho}=              ${CURDIR}/../../resources/yaml_config/intra_gnb_ho.yaml
${GBR_config_yaml_path}=             ${CURDIR}/../config/yaml_config/GBR_5QI_1_2_3_4_71_72_76_128_170_212_254.json
${all_um_GBR_config_yaml_path}=      ${CURDIR}/../config/yaml_config/ALL_UM_GBR_5QI_1_2_3_4_71_72_76_128_170_212_254.yaml
${NRPMQAP_profiles_yaml_path}=       ${CURDIR}/../config/yaml_config/NRPMQAP_counter_profiles.yaml
${GBR_admission_control_yaml_path}=  ${CURDIR}/../config/yaml_config/gbr_admission_control_parameters.yaml
${yaml_drx}=                         ${CURDIR}/../../resources/yaml_config/DRX_config.yaml
${discard_timer_yaml_path}=          ${CURDIR}/../config/yaml_config/discard_timer_scheduling_weight.yaml
${BWP_config_yaml_path}=             ${CURDIR}/../config/yaml_config/bwp_dedicated_AP_LO.yaml
${lock_3_4_5_6_7_8_cells}=           ${CURDIR}/../config/yaml_config/NRCELL3_8_lock.yaml

@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
...                             ${gNBSim_path}                      ${FDD_golden_SCF_fix_yaml_path}
...                             ${NRPMQAP_profiles_yaml_path}
#...                             ${GBR_config_yaml_path}
#...                             ${all_um_GBR_config_yaml_path}
${cause_not_supported_5QI_value}          not-supported-5QI-value
${cause_invalid_qos_combination}          invalid-qos-combination
${cause_radio_resources_not_available}    radio-resources-not-available
${cause_unspecified}                      unspecified

*** Keywords ***
Run Setup
    [Arguments]        ${f1ap}=${False}      ${admission_control}=${False}    ${intra_gnb_ho}=${False}
    ...                ${gbr_mixed_mode}=${True}        ${fdm_scheduling_for_load_reporting}=${False}
    ...                ${inter_rat_ho}=${False}         ${drx}=${False}       ${discard_timer}=${False}
    ...                ${inter_gnb_intra_freq_ho}=${False}    ${multiple_BWP}=${False}      ${change_GSCN}=${False}
    ...                ${reset_tl}=${False}
    Log To Console    Setup started
    Reliable emss setup         bts_id=1
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Reach onAir state
    ...    admission_control=${admission_control}
    ...    intra_gnb_ho=${intra_gnb_ho}
    ...    gbr_mixed_mode=${gbr_mixed_mode}
    ...    fdm_scheduling_for_load_reporting=${fdm_scheduling_for_load_reporting}
    ...    inter_rat_ho=${inter_rat_ho}
    ...    drx=${drx}
    ...    discard_timer=${discard_timer}
    ...    inter_gnb_intra_freq_ho=${inter_gnb_intra_freq_ho}
    ...    multiple_BWP=${multiple_BWP}
    ...    change_GSCN=${change_GSCN}
    ...    reset_tl=${reset_tl}
    Setup egate  egate_port=20000  alias=default    save_egate=${True}
    Setup devices aliases
    Run Keyword if  ${f1ap} != ${False}
    ...    Enable internal mirroring for alias  gNB2

Reach onAir state
    [Arguments]         ${admission_control}=${False}       ${intra_gnb_ho}=${False}
    ...                 ${gbr_mixed_mode}=${True}           ${fdm_scheduling_for_load_reporting}=${False}
    ...                 ${inter_rat_ho}=${False}            ${drx}=${False}        ${discard_timer}=${False}
    ...                 ${inter_gnb_intra_freq_ho}=${False}    ${multiple_BWP}=${False}     ${change_GSCN}=${False}
    ...                 ${reset_tl}=${False}
#    Deconfigure
    ${pmqap_counter_interval}       get variable value          ${PMQAP_INTERVAL}        5min
    Set         pmqap_counter_interval      ${pmqap_counter_interval}
    ${cm_topology}     get_topology_label_from_multiple_ute_sources
    ${cm_variant}       get_variant_from_multiple_ute_sources
    Run Keyword if  ${change_GSCN} != ${False}
    ...     Run keywords
    ...     execute wts command     sed -i --follow-symlinks 's/<GSCN>.*<\\/GSCN>/<GSCN>${gscn}<\\/GSCN>/g' /ffs/run/simmode/iphy.xml
    ...     AND     Log to console      Changed GSCN to ${gscn}
    Run Keyword if  ${gbr_mixed_mode} == ${True}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${GBR_config_yaml_path}
    ...     AND     Log to console      Applied GBR config: 1,2,3->UM, rest AM
    Run Keyword if  ${gbr_mixed_mode} != ${True}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${all_um_GBR_config_yaml_path}
    ...     AND     Log to console      Applied GBR config: all GBR -> UM
    Run Keyword if  ${admission_control} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${GBR_admission_control_yaml_path}
    ...     AND     Log to console      Applied admission control config
    Run Keyword if  ${intra_gnb_ho} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${yaml_enable_intraho}
    ...     AND     Log to console      Applied intra-gnb HO config
    Run Keyword if  ${inter_rat_ho} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${inter_rat_ho_yaml_path}
    ...     AND     Log to console      Applied Inter RAT HO config
    Run Keyword if  ${fdm_scheduling_for_load_reporting} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${fdm_scheduling}
    ...     AND     Log to console      Applied increased FDM scheduling to have smooth load reports
    ...     AND     Log to console      Time domain scheduling should be close to reported bitrate usage
    ...     AND     Log to console      It requires RAT reset, reach onAir should handle waiting for RMODs up
    Run Keyword if  ${drx} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${yaml_drx}
    ...     AND     Log to console      Applied DRX config
    Run Keyword if  ${discard_timer} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${discard_timer_yaml_path}
    ...     AND     Log to console      Applied discard timer and scheduling weight config
    Run Keyword if  ${inter_gnb_intra_freq_ho} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${inter_gnb_intra_freq_ho_yaml_path}
    ...     AND     Log to console      Applied inter gnb intra freq ho config
    Run Keyword if  ${multiple_BWP} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${BWP_config_yaml_path}
    ...     AND     Log to console      Applied multiple BWP config
#    Run Keyword if  '${cm_topology}'=='CLOUD_5G_O_E_AP_LOO' and '${cm_variant}'=='SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD'
#    ...     Run keywords
#    ...     append to list      ${yaml_paths_to_configure}      ${lock_3_4_5_6_7_8_cells}
#    ...     AND     Log to console      Lock the cells 2-8 on new ASOE variant
    Configure       ${yaml_paths_to_configure}
    Run Keyword if  ${reset_tl} != ${False}
    ...     Run keywords
    ...  Trigger site reset
    ...  AND  Wait for testline ICMP Echo replies and SSH services
    ...  AND  Sleep  60
    ...  AND  Check radios availability
    Wait for gnb to reach configured state
    discover bts
    Verify that CB008379 GBR MOCs were configured
    Configure        {'MOC': 'NRCELL', 'actVoNR': 'true', 'actNonVoNRGbrService': 'true'}
    Log To Console    Before Reach OnAir
    Run keyword and ignore error      get_lua_for_topology
    ${LUA_CFG_FILE}=      get variable value          ${LUA}        ${LUA_CFG}
    Add 5GC    config=${LUA_CFG_FILE}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Log To Console    After Reach OnAir

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Verify that CB008379 GBR MOCs were configured
    @{MOC_list}      get_existing_objects_of_given_type    NRDRB
    ${MOC_list_length}    Get length    ${MOC_list}
    Should be equal as strings    ${MOC_list_length}    25
    @{MOC_list}      get_existing_objects_of_given_type    NRDRB_PDCP
    ${MOC_list_length}    Get length    ${MOC_list}
    Should be equal as strings    ${MOC_list_length}    4
    @{MOC_list}      get_existing_objects_of_given_type    NRDRB_MAC
    ${MOC_list_length}    Get length    ${MOC_list}
    Should be equal as strings    ${MOC_list_length}    5
    @{MOC_list}      get_existing_objects_of_given_type    NRDRB_5QI
    ${MOC_list_length}    Get length    ${MOC_list}
    Should be equal as strings    ${MOC_list_length}    16
    @{MOC_list}      get_existing_objects_of_given_type    NRPMQAP
    ${MOC_list_length}    Get length    ${MOC_list}
    Should be equal as strings    ${MOC_list_length}    6



Verify PM counters for DRBs admissions are incremented successfully: requests:${req:\d+}, successes:${succ:\d+}
    Verify counter value on NRCELL-1 for M55138C01001 - SA_GBR_DRB_REQ equals ${req}
    Verify counter value on NRCELL-1 for M55138C01002 - SA_GBR_DRB_SUCC equals ${succ}


Run Test Teardown
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5
    Detach and kill UE6
    Detach and kill UE7
    Detach and kill UE8
    Detach and kill UE9

Attach UE-${ue_id:\d+} to gNB${gnb_id:[1-3]} cell${cell_id:[1-2]} with ICS and PDU session setup after ICS
    Attach UE${ue_id} to gNB${gnb_id} cell${cell_id} with ICS and PDU session setup after ICS

    Verify that AMF1 NGAP InitialContextSetup does not contain any PDU session
    Verify in RRCReconfiguration that UE${ue_id} 1 DRBs were added
    Verify in NGAP that QoS flows for 5QIs [5] were successfully added to new PDU session

Attach UE-${ue_id:\d+} to gNB${gnb_id:[1-3]} cell${cell_id:[1-2]} with ICS during single PDU session setup
    Attach UE${ue_id} to gNB${gnb_id} cell${cell_id} with ICS during PDU session setup

    Verify that UE${ue_id} attach with 1 PDU session 5QI5 QoS flow was completed successfully
    Verify in RRCReconfiguration that UE${ue_id} 1 DRBs were added

Attach UE${ue_id:\d+} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS during PDU session setup
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

    Attach UE${ue_id} without ICS to gNB${gnb_id} cell${cell_id}
    Run keyword and continue on failure
    ...   Add to UE${ue_id} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

    Verify that UE${ue_id} attach with setup default 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow was completed successfully
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were added

Attach UE${ue_id:\d+} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS without PDU session setup
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

    Attach UE${ue_id} with ICS to gNB${gnb_id} cell${cell_id}
    Run keyword and continue on failure
    ...   Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

Attach UE${ue_id:\d+} with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS during PDU session setup
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Attach UE${ue_id} without ICS to gNB${gnb_id} cell${cell_id}
    Run keyword and continue on failure
    ...   Add to UE${ue_id} initial PDU session with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_id} QoS flow

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Verify that UE${ue_id} attach with setup default 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_id} QoS flow was completed successfully
    Verify in RRCReconfiguration that UE${ue_id} 3 DRBs were added

Attach UE${ue_id:\d+} with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS without PDU session setup
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Attach UE${ue_id} with ICS to gNB${gnb_id} cell${cell_id}
    Run keyword and continue on failure
    ...   Add to UE${ue_id} initial PDU session with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_id} QoS flow

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Attach UE${ue_id:\d+} with one PDU session and traffic to real gNB then HO to sim gNB${gnb_id} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Set up inter gNB Handover for UE${ue_id}
    start_observing_measurements      UE_${ue_id}       technology=5G
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    UE${ue_id} triggers Inter-gNB Handover from real gNB2 to simulated gNB3 by sending A5 measurement
    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    Sleep  10

Attach UE${ue_id:\d+} with one PDU session without traffic to real gNB then HO to sim gNB${gnb_id} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Set up inter gNB Handover for UE${ue_id}
    start_observing_measurements      UE_${ue_id}       technology=5G
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow

    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    UE${ue_id} triggers Inter-gNB Handover from real gNB2 to simulated gNB3 by sending A5 measurement
    Sleep  10

Attach emergency call UE${ue_id:\d+} without ICS to gNB${gnb_id:\d+} cell${cell_id:\d+}
    Set up emergency ICS for UE${ue_id}
    Execute egate command   cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=off
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command   cmd=ue_register id=${ue_id} registration_type=EmergencyRegistration
    Sleep  2

Emergency UE${ue_id:\d+} attach to gNB${gnb_id:\d+} cell${cell_id:\d+}
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Set up inter gNB Handover for UE${ue_id}
    start_observing_measurements      UE_${ue_id}      technology=5G

    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialUEMessage
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation

    Attach emergency call UE${ue_id} without ICS to gNB${gnb_id} cell${cell_id}

    Add to UE${ue_id} initial PDU session with ICS

    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation

Fail adding to UE${ue_id:\d+} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    # copied from Add to UE${ue_id} (initial|second|third) PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetupFailure due to cause radio-resources-not-available

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${current_gw_id} nwslice=1
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    Sleep  2
    Execute egate command  cmd=smf_param id=1 reset

    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetupFailure due to cause radio-resources-not-available

Fail adding to UE${ue_id:\d+} ${session_type:(second|third)} PDU session including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup with cause radio-resources-not-available

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup with cause radio-resources-not-available
    Verify that gNB failed to add QoS flows for 5QIs in PDU Session Setup with cause=${cause_radio_resources_not_available}

    Execute egate command  cmd=smf_param id=1 reset

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}

    Add to UE${ue_id} ${session_type} PDU session after ICS

    Execute egate command  cmd=smf_param id=1 reset

    Verify in NGAP that QoS flows for 5QIs [5,${5qi_id}] were successfully added to new PDU session
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were added

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}

    Add to UE${ue_id} ${session_type} PDU session with ICS

    Execute egate command  cmd=smf_param id=1 reset

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    ${QoS_FLOW_ID_VoNR}           Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5QI_VoNR}
    ${QoS_FLOW_ID_GBR_nonVoNR}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}

    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID_VoNR},${QoS_FLOW_ID_GBR_nonVoNR}

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    Execute egate command  cmd=smf_param id=1 reset


Add to UE${ue_id} PDU${pdu_id} session QoS flows with DRX update with 5QI from list [${qos_add}] and delete QoS flows with 5QI from list [${qos_del}]
    @{qos_to_add_list}=   Split To List       ${qos_add}
    @{qos_to_del_list}=   Split To List       ${qos_del}
    ${length_of_qos_to_add_list}=  Get length    ${qos_to_add_list}
    ${length_of_qos_to_del_list}=  Get length    ${qos_to_del_list}

    ${qos_ids_add}=    Set Variable
    ${qos_ids_del}=    Set Variable

    FOR  ${5qi}  IN  @{qos_to_add_list}
        ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
        ${qos_ids_add}=   Add To String    ${qos_ids_add}    ${qos_flow_id}
    END

    FOR  ${5qi}  IN  @{qos_to_del_list}
        ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
        ${qos_ids_del}=   Add To String    ${qos_ids_del}    ${qos_flow_id}
    END

    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

    Run Keyword If    ${length_of_qos_to_add_list} > 0 and ${length_of_qos_to_del_list} > 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_ids_add} qosflows_to_del=${qos_ids_del}

    Run Keyword If    ${length_of_qos_to_add_list} > 0 and ${length_of_qos_to_del_list} == 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_ids_add}

    Run Keyword If    ${length_of_qos_to_add_list} == 0 and ${length_of_qos_to_del_list} > 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_ids_del}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    Verify in NGAP that QoS flows for 5QIs [${qos_add}] were successfully added to PDU${pdu_id} session
    Verify in NGAP that QoS flows for 5QIs [${qos_del}] were successfully released from PDU${pdu_id} session

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    Verify that in 1 out of 2 RRCReconfiguration UE${ue_id} ${length_of_qos_to_add_list} DRBs were added
    Verify that in 1 out of 2 RRCReconfiguration UE${ue_id} ${length_of_qos_to_del_list} DRBs were released

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session with 1 nonGBR 5QI${nongbr_5qi:\d+} and 1 GBR 5QI${gbr_5qi:\d+} QoS flow
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${GBR_QoS_FLOW_ID}       Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${gbr_5qi}
    ${NONGBR_QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${nongbr_5qi}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${GBR_QoS_FLOW_ID},${NONGBR_QoS_FLOW_ID}

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

    Run Keyword and Continue on Failure    # TODO:   remove ...Continue on Failure when not needed (e.g. EXCEPT FLOW is updated)
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    Execute egate command  cmd=smf_param id=1 reset

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Add QoS flows to UE${ue_id:\d+} PDU${pdu_id:\d+} session for 5QI GBR [${5qi_add}] and delete QoS flows for 5QI GBR [${5qi_del}]
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [6] and delete QoS flows with 5QI from list [${5qi_del}]
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${5qi_add}] and delete QoS flows with 5QI from list [6]
    Run 5MBps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI3
    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI3

Enable including capabilities in ICS for UE${ue_id}
    Execute egate command   cmd=amf_ue_ics_param id=1 ue=${ue_id} include_ue_capabilities=on

Trigger UE${ue_id:\d+} idle mode exit
    Execute egate command  cmd=ue_im_exit id=${ue_id}
    Sleep  5

Set NG based handover for simulated gNB${gnb_id:\d+}
    Execute egate command   cmd=gnb_param id=${gnb_id} sa_ho=ng_based

Set indirect data forwarding for AMF${amf_id:\d+} to ${value:off|on}
    Execute egate command   cmd=amf_param id=${amf_id} intra5gs_data_forwarding=${value}

Set GBR data forwarding for XN Handover to ${value:off|on} for simulated gNB${gnb_id:\d+}
    Execute egate command   cmd=gnb_param id=${gnb_id} gbr_data_forwarding_HO=${value} pdcp_config=2:len_18,4:len_18,72:len_18,76:len_18,212:len_18

Set forwarding tunnel type for NG Handover to ${value:pdu|drb} for simulated gNB${gnb_id:\d+}
    Execute egate command   cmd=gnb_param id=${gnb_id} ng_forwarding_tunnel_type=${value}

Modify existing 5QI${5qi:\d+} for UE${ue_id:\d+} ${type:(initial|second|third)} PDU session by ${by:(amf|ue)} - set DL and UL GFBR to ${rate:\d+}kbps
    ${by}    Convert To Lowercase    ${by}
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${rate} gfbr_ul=${rate}
    Sleep  1
    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${type}
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_modify=${QoS_FLOW_ID} by=${by}

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification
    Verify in NGAP that 5QI${5qi} QoS flow GFBR was successfully modified to ${rate}kbps

Modify existing 5QI${5qi:\d+} for UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_modify=${QoS_FLOW_ID} by=amf

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification

Set data forwarding to ${data_forwarding:True|False} for UE${ue_id:\d+}
    Execute egate command   cmd=amf_param id=${ue_id} intra5gs_data_forwarding=${data_forwarding}

Set command for handover preparation failure for UE${ue_id:\d+}
    Execute egate command   cmd=amf_ue_ng_handover_param id=1 ue=${ue_id} action=ho_preparation_failure cause=MISC_unspecified

Set actNonVoNRGBRService flag to ${boolean:True|False}
    ${actual}=    Get object attributes    NRCELL-1    actNonVoNRGBRService    enb_id=1
    Run keyword if    ${actual['actnonvonrgbrservice']}!=${boolean}
    ...    Edit object attributes
    ...    object_name=NRCELL-1
    ...    actNonVoNRGBRService=${boolean}
    ...    bts_id=1

Set actNonVoNRGBRService parameter for both cells
    Configure  [{'MOC': 'NRCELL', 'ID': '1', 'actNonVoNRGbrService': 'true'}, {'MOC': 'NRCELL', 'ID': '2', 'actNonVoNRGbrService': 'true'}]

Set for 5QI${5qi:\d+} GFBR to ${gfbr:\d+}Mbps and MFBR to ${mfbr:\d+}Mbps
    ${gfbr}=  Evaluate  ${gfbr} * 1000
    ${mfbr}=  Evaluate  ${mfbr} * 1000
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${gfbr} gfbr_ul=${gfbr}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} mfbr_dl=${mfbr} mfbr_ul=${mfbr}
    Sleep  0.1

Set for 5QI${5qi:\d+} ${direction:(DL|UL)} GFBR to ${gfbr:\d+}Mbps and MFBR to ${mfbr:\d+}Mbps
    ${gfbr}=  Evaluate  ${gfbr} * 1000
    ${mfbr}=  Evaluate  ${mfbr} * 1000
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Run Keyword if  "${direction}" == "DL"
    ...     Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${gfbr} mfbr_dl=${gfbr}
    Run Keyword if  "${direction}" == "UL"
    ...     Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_ul=${mfbr} mfbr_ul=${mfbr}
    Sleep  0.1

Set for UE${ue_id:\d+} 5QI${5qi:\d+} GFBR to ${gfbr:\d+}Mbps and MFBR to ${mfbr:\d+}Mbps for DL
    ${gfbr}=  Evaluate  ${gfbr} * 1000
    ${mfbr}=  Evaluate  ${mfbr} * 1000
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${gfbr}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} mfbr_dl=${mfbr}
    Execute egate command   cmd=modify_pdu_session_ue ue=${ue_id} pdu=1 qosflows_to_modify=${QoS_FLOW_ID} by=amf
    Sleep     0.1

Set for UE${ue_id:\d+} 5QI${5qi:\d+} GFBR to ${gfbr:\d+}Mbps and MFBR to ${mfbr:\d+}Mbps for UL
    ${gfbr}=  Evaluate  ${gfbr} * 1000
    ${mfbr}=  Evaluate  ${mfbr} * 1000
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_ul=${gfbr}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} mfbr_ul=${mfbr}
    Execute egate command   cmd=modify_pdu_session_ue ue=${ue_id} pdu=1 qosflows_to_modify=${QoS_FLOW_ID} by=amf
    Sleep  1

Set for 5QI${5qi:\d+} GFBR DL to ${gfbr_dl:\d+}kbps GFBR UL to ${gfbr_ul:\d+}kbps and MFBR to ${mfbr:\d+}kbps
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${gfbr_dl} gfbr_ul=${gfbr_ul}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} mfbr_dl=${mfbr} mfbr_ul=${mfbr}
    Sleep  0.1

Set for all 5QIs GFBR to ${gfbr:\d+}Mbps and MFBR to ${mfbr:\d+}Mbps
    FOR  ${5qi}  IN    2  3  4  71  72  76  128  212  254
        Set for 5QI${5qi} GFBR to ${gfbr}Mbps and MFBR to ${mfbr}Mbps
    END

Set for all 5QIs ${direction:(DL|UL)} GFBR to ${gfbr:\d+}Mbps and MFBR to ${mfbr:\d+}Mbps
    FOR  ${5qi}  IN    2  3  4  71  72  76  128  212  254
        Set for 5QI${5qi} ${direction} GFBR to ${gfbr}Mbps and MFBR to ${mfbr}Mbps
    END

Set nrarfcn parameter for NRCELL-2
    Configure  [{'MOC': 'NRCELL', 'ID': '1', 'nrarfcn': '636662'}]

Set up emergency ICS for UE${ue_id:\d+}
    Execute egate command   cmd=ue_param id=${ue_id} nr_usage_setting=voice_centric
    Execute egate command   cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

Try to add to UE${ue_id:\d+} PDU${pdu_id:\d+} session QoS flows with 5QI from list [${qos_add:\d+}] and fail with cause=${cause:\S+}
    @{qos_to_add_list}=   Split To List       ${qos_add}
    ${length_of_qos_to_add_list}=  Get length    ${qos_to_add_list}

    ${qos_ids_add}=    Set Variable

    FOR  ${5qi}  IN  @{qos_to_add_list}
        ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
        ${qos_ids_add}=   Add To String    ${qos_ids_add}    ${qos_flow_id}
    END

    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_ids_add}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration

    Verify that gNB failed to add QoS flows for 5QIs with cause=${cause}

Try to attach UE${ue_id:\d+} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} and fail with cause=${cause:\S+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetupFailure

    Attach UE${ue_id} without ICS to gNB${gnb_id} cell${cell_id}
    Try add to UE${ue_id} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow and fail

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetupFailure

    Verify that gNB sends InitialContextSetupFailure with cause=${cause}
    Detach and kill UE${ue_id}

Try add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow and fail
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=Received Initial Context Setup Failure from GNB

    Execute egate command  cmd=smf_param id=1 reset

    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration

Try add to UE${ue_id:\d+} initial PDU session including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow and fail
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${current_gw_id} nwslice=1
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    Verify that gNB failed to add QoS flows for 5QIs in PDU Session Setup with cause=${cause_radio_resources_not_available}
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command  cmd=smf_param id=1 reset

Try add to UE${ue_id:\d+} ${session_type:(initial|second)} PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow and fail
    EXPECT FLOW[timeout=6]: AMF1 NGAP pDUSessionResourceSetup

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1

    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    PASS FLOW[timeout=6]: AMF1 NGAP pDUSessionResourceSetup
    Execute egate command  cmd=smf_param id=1 reset

Free bandwidth resources by releasing 5QI${5qi} in background UE${ue_id:\d+}
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi}]

Free bandwidth resources by releasing 5QI${5qi} in background UEs [${bkg_ues}]
    @{bkg_ues_list}=   Split to list    ${bkg_ues}

    FOR  ${bkg_ue}  IN  @{bkg_ues_list}
        Free bandwidth resources by releasing 5QI${5qi} in background UE${bkg_ue}
    END

    Sleep  20    # give time for traffic reporting to kick in

Free bandwidth resources by performing intra-gNB HO for background UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification for HO
    Perform intra-frequency intra-gNB handover from gNB2 cell1 to cell2 for UE${ue_id}
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModification for HO
    Log to console    After UE${ue_id} HO to cell2...

Free bandwidth resources by performing intra-gNB HO for background UEs [${bkg_ues}]
    @{bkg_ues_list}=   Split to list    ${bkg_ues}

    FOR  ${bkg_ue}  IN  @{bkg_ues_list}
        Free bandwidth resources by performing intra-gNB HO for background UE${bkg_ue}
    END


Free bandwidth resources by changing UL and DL GFBR to ${rate:\d+}kbit on 5QI${5qi:\d+} QoS Flow by ${by:(amf|ue)} on background UEs[${bkg_ues}]
    @{background_ues_list}=    Split to list    ${bkg_ues}

    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Modify existing 5QI${5qi} for UE${bkg_ue} initial PDU session by ${by} - set DL and UL GFBR to ${rate}kbps
    END

Free bandwidth resources by detaching background UEs [${bkg_ues}]
    Stop 20Mbps UL and DL traffic and kill background UEs[${bkg_ues}]

Setup background UEs[${background_ues}] on gNB${gnb_id:\d+} cell${cell_id:\d+} with ${dir:(DL|UL)} ${Mbitrate:\d+}Mbps traffic on 5QI${5qi:\d+}
    @{background_ues_list}=    Split to list    ${background_ues}
    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Log to console    Before attach bkg_ue${bkg_ue} and running traffic...
        Attach UE${bkg_ue} with 1 nonGBR and 1 GBR 5QI${5QI} to gNB${gnb_id} cell${cell_id} with ICS without PDU session setup
        Run ${Mbitrate}Mbps ${dir} traffic on UE${bkg_ue} PDU1 QFI2 and wait 1 seconds
    END

    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Run keyword and continue on failure
        ...    Verify ${Mbitrate}Mbps ${dir} traffic on PDU-1 QFI-2 for UE${bkg_ue}
    END

Setup background UEs[${bkg_ues}] on gNB${gnb_id:\d+} cell${cell_id:\d+} then batch run ${dir:(DL|UL)} ${rate:\d+}Mbps traffic on 5QI${5qi:\d+}
    @{background_ues_list}=    Split to list    ${background_ues}
    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Log to console    Before attach bkg_ue${bkg_ue}...
        Attach UE${bkg_ue} with 1 nonGBR and 1 GBR 5QI${5QI} to gNB${gnb_id} cell${cell_id} with ICS without PDU session setup
    END

    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Run ${rate}Mbps ${dir} traffic on UE${bkg_ue} PDU1 QFI2 and wait 2 seconds
    END

    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Verify ${rate}Mbps ${dir} traffic on PDU-1 QFI-2 for UE${bkg_ue}
    END

Modify DL and UL GFBR=${gfbr:\d+} and MFBR=${mfbr:\d+} for 5QI${5qi:\d+}
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Execute egate command  cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${gfbr} gfbr_ul=${gfbr} mfbr_ul=${mfbr} mfbr_dl=${mfbr}

    ${NRDRB_ID}    Get From Dictionary    ${5QI_TO_NRDRB}   ${5qi}
    Configure    {'MOC': 'NRDRB', 'ID':'${NRDRB_ID}', 'maxDataRateGBRUL':'${mfbr}', 'maxDataRateGBRDL':'${mfbr}'}
    Discover bts    bts_id=1

Stop ${Mbitrate}Mbps UL and DL traffic and kill background UEs[${background_ues}]
    @{background_ues_list}=    Split to list    ${background_ues}

    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Run keyword and ignore error
        ...    Stop ${Mbitrate}Mbps UL and DL traffic on UE${bkg_ue} PDU1 QFI2
        Detach and kill UE${bkg_ue}
    END

Stop ${Mbitrate:\d+}Mbps ${dir:(UL|DL)} traffic and kill background UEs[${background_ues}]
    @{background_ues_list}=    Split to list    ${background_ues}

    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Run keyword and ignore error
        ...    Stop ${Mbitrate}Mbps ${dir} traffic on UE${bkg_ue} PDU1 QFI2
        Detach and kill UE${bkg_ue}
    END

Try to perform intra-frequency intra-gNB handover from gNB${gnb_id} cell${src_cell} to cell${tgt_cell} for UE${ue_id:\d+} and fail
    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=3]: gNB2 F1AP uEContextModification for HO

    UE${ue_id} triggers Intra-gNB Handover from gNB${gnb_id} cell${src_cell} to cell${tgt_cell} by sending A3 measurement

    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=3]: gNB2 F1AP uEContextModification for HO

Change NIDD parameters DL and UL GFBR=${gfbr:\d+}Mbps for 5QI${5qi:\d+}
    ${gfbr}=  Evaluate  ${gfbr} * 1000
    ${NRDRB_ID}    Get From Dictionary    ${5QI_TO_NRDRB}   ${5qi}
    Configure        {'MOC': 'NRDRB', 'ID': '${NRDRB_ID}', 'maxDataRateGBRDL': '${gfbr}', 'maxDataRateGBRUL': '${gfbr}'}

Set parameter NRCELL${cell_id:\d+}.addGbrTrafficHo=${value:\d+}
    Configure    {'MOC': 'NRCELL', 'ID': '${cell_id}', 'addGbrTrafficHo': '${value}'}
    Discover bts    bts_id=1

Modify actGBRAdmissionControl to EnhancedVoNR
    Configure  [{'MOC':'NRCELL', 'ID':'1', 'actNonVoNRGbrService':'false', 'actGBRAdmissionControl':'EnhancedVoNR'}]
    Discover bts    bts_id=1

Modify existing 5QI${5qi:\d+} for UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session and fail with cause=${cause:\S+}
#    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification,bearerContextModification with setup and rollback
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_modify=${QoS_FLOW_ID} by=amf

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration
#    On failure
#    ...     PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification,bearerContextModification with setup and rollback
    Verify that gNB failed to add QoS flows for 5QIs with cause=${cause}

Teardown repeat keyword if failed
    Run keyword and ignore error        Detach and kill UEs from 1 to 80
    Run keyword and ignore error        stop observing measurements

Attach UE${ue_id:\d+} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} to gNB${gnb_id:\d+} ${bwp_type:(large|small)} BWP cell${cell_id:\d+}
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_id} to gNB${gnb_id} cell${cell_id} with ICS during PDU session setup
    Verify that UE${ue_id} is configured with ${bwp_type} BWP profile after ICS to NRCELL-${cell_id}

Attach background ${bwp:(large|small)} BWP UE${ue_id:\d+} to cell${cell_id:\d+} and run ${trf_rate:\d+}Mbps DL traffic on 5QI${5qi_id:\d+} GBR bearer
    Log to console      Attaching background ${bwp} BWP UE${ue_id}
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_id} to gNB2 ${bwp} BWP cell${cell_id}
    Run ${trf_rate}Mbps DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    Run Keyword And Continue On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${trf_rate}Mbps DL traffic on UE${ue_id} PDU1 QFI2
