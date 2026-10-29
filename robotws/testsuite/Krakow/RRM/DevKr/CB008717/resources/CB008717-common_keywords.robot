*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    ../../resources/verifiers.robot
Resource    ../../resources/ssh.robot
Resource    ./CB008717-verify_RRC.robot
Resource    ./CB008717-verify_BearerContext.robot
Resource    ./CB008717-verify_UEContextSetup.robot
Resource    ./CB008717-verify_UEContextModification.robot
Resource    ./CB008717-verify_ContextRelease.robot
Resource    ./CB008717-indexToRFSP.robot
Resource    ./UECap_ICS_workaround.robot
Resource    CB008717-setups_and_teardowns.robot
Resource    CB008717-QoSFlow_keywords.robot
Resource    CB008717-get_and_verify_occurence_time.robot
Resource    ta_messaging/single_message_observer.robot

Library     ../../../resources/Python/utilities.py
Library     ../../resources/python/mock_stop_egate.py
Library     taf.ul.ue.sim.env_setup
Library     ta5g_ue_measurements
Library     RADCounters.py
Library     taf.ul.sbts.pmi_ticket_collector

Variables   gnb_randd_parameters.py

*** Variables ***
${LUA_CFG}=                            ${CURDIR}/../config/common/2c_TDD_n78_FR2_n257_NRDC.lua
${yaml_B1a}=                           ${CURDIR}/../config/B/yaml/B1a.yaml
${yaml_5QI_nonGBR_and_GBR}=            ${CURDIR}/../config/common/yaml/GBR_and_nonGBR_5QI.yaml
${yaml_rd_counters}=                   ${CURDIR}/../config/common/yaml/RD_counters_setup.yaml
${yaml_I_B1a}=                         ${CURDIR}/../config/I/yaml/I_B1a.yaml
${yaml_I_B1b}=                         ${CURDIR}/../config/I/yaml/I_B1b.yaml
${yaml_I_B1c}=                         ${CURDIR}/../config/I/yaml/I_B1c.yaml
${yaml_I_B1d}=                         ${CURDIR}/../config/I/yaml/I_B1d.yaml
${yaml_I_B2}=                          ${CURDIR}/../config/I/yaml/I_B2.yaml
${yaml_D_B1b}=                         ${CURDIR}/../config/D/yaml/D_B1b.yaml
${yaml_D_B4b}=                         ${CURDIR}/../config/D/yaml/D_B4b.yaml
${yaml_D_B4c_UE4}=                     ${CURDIR}/../config/D/yaml/D_B4c_UE4.yaml
${yaml_D_B4c_UE5}=                     ${CURDIR}/../config/D/yaml/D_B4c_UE5.yaml
${yaml_D_B4c_default}=                 ${CURDIR}/../config/D/yaml/D_B4c_default.yaml
${yaml_D_B4a}=                         ${CURDIR}/../config/D/yaml/D_B4a.yaml
${yaml_D_B4d}=                         ${CURDIR}/../config/D/yaml/D_B4d.yaml
${yaml_E_B2_2}=                        ${CURDIR}/../config/E/yaml/idleModeSteering.yaml
${yaml_D_EC5a_1}=                      ${CURDIR}/../config/D/yaml/D_EC5a_1.yaml
${yaml_D_EC5a_1_default}=              ${CURDIR}/../config/D/yaml/D_EC5a_1_default.yaml
${yaml_D_EC5a_2}=                      ${CURDIR}/../config/D/yaml/D_EC5a_2.yaml
${yaml_D_EC5a_2_default}=              ${CURDIR}/../config/D/yaml/D_EC5a_2_default.yaml
${yaml_D_EC5b}=                        ${CURDIR}/../config/D/yaml/D_EC5b.yaml
${yaml_D_EC5b_default}=                ${CURDIR}/../config/D/yaml/D_EC5b_default.yaml
${yaml_E_B3a}=                         ${CURDIR}/../config/E/yaml/E_B3a_preemption.yaml
${yaml_E_B3b}=                         ${CURDIR}/../config/E/yaml/E_B3b_preemption_with_redirection.yaml
${yaml_E_B10}=                         ${CURDIR}/../config/E/yaml/E_B10_amf_reselection.yaml
${yaml_DE_NG_HO}=                      ${CURDIR}/../config/DE/yaml/NGHO_enable.yaml
${yaml_DE_InterRAT_HO}=                ${CURDIR}/../../resources/yaml_config/inter_rat_ho.yaml
${yaml_DE_IDs_for_InterRAT_MOCs}=      ${CURDIR}/../config/DE/yaml/interRAT_enable.yaml
${yaml_M_InterRAT_HO}=                 ${CURDIR}/../config/M/yaml/interRAT_enable.yaml
${yaml_PMQAP}=                         ${CURDIR}/../config/DE/yaml/PMQAP.yaml
${yaml_HA_B1d}=                        ${CURDIR}/../config/HA/yaml/HA_B1d.yaml
${yaml_HA_B1d_dafault}                 ${CURDIR}/../config/HA/yaml/HA_B1d_default.yaml
${interaction_with_CB008225}=          ${CURDIR}/../config/DE/yaml/interaction_with_CB008225.yaml
${yaml_JA_B3c}=                        ${CURDIR}/../config/JA/yaml/JA_B3c.yaml

${nrcell2_pci}=  52
${nrcell3_pci}=  53
${nrcell6_pci}=  56
${nrcell7_pci}=  57

&{NRCELL_ID_TO_PHYSCELL_ID}=  2=52  3=53  6=56  7=57

${a4retrytimer_toleration}=    2

*** Keywords ***
Run Setup
    [Arguments]        ${f1ap}=${True}   ${GBR_nonGBR}=${False}   ${ute-ca}=${False}   ${faf}=0
    Log To Console    Setup started
    Setup emss    node_id=1
    ${run_update}    get variable value      ${configure}    "True"    # do not ever change that line!

    Run Keyword if  ${ute-ca} != ${False} and ${run_update} != ${False}
    ...    Prepare TL with config files  faf=${faf}

    Run Keyword if  ${run_update} != ${False} and ${ute-ca} == ${False}
    ...    Full env setup

    Run Keyword if  ${GBR_nonGBR} != ${False} and ${run_update} != ${False}
    ...    Configure       ${yaml_5QI_nonGBR_and_GBR}

    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Run Keyword if  ${f1ap} != ${False}
    ...    Enable internal mirroring for alias  gNB2

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Prepare TL with config files
     [Arguments]        ${faf}
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     ${run_update}    get variable value      ${configure}    "True"    # do not ever change that line!
     ${rad_params}=    Set Variable   0x890057=${faf}
     add gnb configuration    scfc=${SCFC}    rad_params=${rad_params}
     add simulator  sim_type=airphone  config=${AP_XML}
     add 5gc  config=${LUA_CFG}  edaemon_ports=10000
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV

Full env setup
    Log To Console    Configure ENV with LUA
    add 5gc  config=${LUA_CFG}  edaemon_ports=10000
    configure environment       rmod_detection_timeout=300s
    Log To Console    After Configure ENV
    Do not stop egate and daemon

UE${ue_id:\d+} sends A4 measurement id=${measurement_id} for NR-DC PSCell addition
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measurement_id} event=A4 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85
    ...                       nrsrq_nr=31 index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    Verify that MeasurementReport contains measurement results of PSCell for UE${ue_id}

UE${ue_id:\d+} sends A4 measurement id=1 for NR-DC PSCell addition without rsIndexResult
    [Documentation]    This KW triggers A4 measurement without rsIndexResult to check if CFRA preamble is not generated then

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=52 nrsrp_nr=85 nrsrq_nr=31

    Execute egate command
    ...     cmd=${command}
    ...     pass_regexp=UE${ue_id}.*-> UL-DCCH-NR

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    Verify that MeasurementReport contains measurement results of PSCell and rsIndexResults is not present for UE${ue_id}

UE${ue_id:\d+} sends A4 measurement id=${meas_id:\d+} for NR-DC PSCell addition with phycell_id=${pci:\d+} nrsrp_nr=${rsrp:\d+} nrsrq_nr=${rsrq:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 srsrp_nr=19 srsrq_nr=10 phycell_id=${pci}
    ...                       nrsrp_nr=${rsrp} nrsrq_nr=${rsrq} index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    Verify that MeasurementReport contains measurement results of PSCell for UE${ue_id}

UE${ue:\d+} sends A4 measId=${meid:\d+} with CELL-${c1:\d+}: rsrp1=${rp1:\d+} rsrq1=${rq1:\d+} and CELL-${c2:\d+}: rsrp2=${rp2:\d+} rsrq2=${rq2:\d+}
    ${pci1}    Get From Dictionary    ${NRCELL_ID_TO_PHYSCELL_ID}   ${c1}
    ${pci2}    Get From Dictionary    ${NRCELL_ID_TO_PHYSCELL_ID}   ${c2}

    EXPECT FLOW[timeout=10]: UE_${ue} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue} meas_id=${meid} event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=${pci1} nrsrp_nr=${rp1} nrsrq_nr=${rq1} index=0 nrs_result=30:30:0
    ...                       phycell_id=${pci2} nrsrp_nr=${rp2} nrsrq_nr=${rq2}

    Execute egate command
    ...     cmd=${command}

    PASS FLOW[timeout=10]: UE_${ue} NR-RRC MeasurementReport
    Verify that MeasurementReport contains measurement results of PSCell for UE${ue}

UE${ue_id:\d+} sends A4 measurement id=1 for NR-DC PSCell addition during ongoing PDU Session Modification procedure
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=4000
    Execute egate command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=13

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A4 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85
    ...                       nrsrq_nr=31 index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    # Check if Measurement Report is queued
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Verify that MeasurementReport contains measurement results of PSCell for UE${ue_id}

    # Check messagess after the delay ends and pdu session modification complete
    EXPECT FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    PASS FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

UE${ue_id:\d+} sends A4 measurement id=1 for NR-DC PSCell addition during ongoing PDU Session Release procedure with RRCGuard timer expiration
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=4000  # RRCGuardTimer equal 2500ms
    Execute egate command    cmd=ue_pdu_session_release ue=${ue_id} pdu=1

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=5]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A4 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85
    ...                       nrsrq_nr=31 index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    # Check if Measurement Report is queued and ignored and UEContextRelease is triggered
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceRelease
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=5]: gNB2 E1AP bearerContextModification
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Verify that MeasurementReport contains measurement results of PSCell for UE${ue_id}

Trigger AMF Initiated PDU-${pdu_id:\d+} Session Release for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Verify that A4 measurements are not configured for UE1 in RRCReconfiguration message

Set one PDU session with ${nongbr_num:\d+} non-GBR QoS Flow for UE${ue_id:\d+}
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=off
    ...     cmd=smf_param id=1 additional_qosflows_to_activate=3

Set one PDU session with 1 GBR QoS Flow for UE${ue_id:\d+}
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=off
    ...     cmd=smf_param id=1 additional_qosflows_to_activate=5

Verify state of SA and NRDCSN cells
    Object attributes should be    NRCELL-1    cellDepType=SA
    Object attributes should be    NRCELL-1    operationalState=enabled
    Object attributes should be    NRCELL-2    cellDepType=NR-DC-SN
    Object attributes should be    NRCELL-2    operationalState=enabled

Verify state of SA and two NRDCSN cells
    Object attributes should be    NRCELL-1    cellDepType=SA
    Object attributes should be    NRCELL-1    operationalState=enabled
    Object attributes should be    NRCELL-2    cellDepType=NR-DC-SN
    Object attributes should be    NRCELL-2    operationalState=enabled
    Object attributes should be    NRCELL-3    cellDepType=NR-DC-SN
    Object attributes should be    NRCELL-3    operationalState=enabled

Verify state of two SA, NRDCSN and NSA cells
    Object attributes should be    NRCELL-1    cellDepType=SA+NSA
    Object attributes should be    NRCELL-1    operationalState=enabled
    Object attributes should be    NRCELL-2    cellDepType=NR-DC-SN
    Object attributes should be    NRCELL-2    operationalState=enabled
    Object attributes should be    NRCELL-3    cellDepType=NSA
    Object attributes should be    NRCELL-3    operationalState=enabled
    Object attributes should be    NRCELL-4    cellDepType=SA
    Object attributes should be    NRCELL-4    operationalState=enabled

Set expected messages flows for A4 measurement configuration for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows for A4 measurement configuration for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows for NRDC A4 measurements for UE${ue_id:\d+} with sufficient UECaps and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows for NRDC A4 measurements for UE${ue_id:\d+} with sufficient UECaps and gNB${gnb_id:\d+}
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows for A4 measurement configuration with DRX for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 5*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows for A4 measurement configuration with DRX for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 5*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Set expected messages flows for A4 measurement based PSCell addition for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCRelease

Verify expected messages flows for A4 measurement based PSCell addition for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCRelease

Expect that after sending A4 measurement NRDC is not setup and UE${ue_id:\d+} is released
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=5]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that after sending A4 measurement NRDC is not setup and UE${ue_id:\d+} is released
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=5]: gNB2 E1AP bearerContextModification
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected messages flows for A4 measurement based PSCell addition with DRX for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP uEContextRelease

Verify expected messages flows for A4 measurement based PSCell addition with DRX for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: AMF${amf_id} NGAP uEContextReleaseRequest
    FAIL FLOW[timeout=5]: AMF${amf_id} NGAP uEContextRelease

Set expected messages flows for A4 measurement based PSCell addition without DRX for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: gNB${gnb_id} F1AP 4*uEContextModification
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP uEContextRelease

Verify expected messages flows for A4 measurement based PSCell addition without DRX for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: gNB${gnb_id} F1AP 4*uEContextModification
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: AMF${amf_id} NGAP uEContextReleaseRequest
    FAIL FLOW[timeout=5]: AMF${amf_id} NGAP uEContextRelease

Verify messages during NRDC PSCell addition with DRX for UE${ue_id:\d+}
    Verify that UE${ue_id} sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 4 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 4 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 4 contains measGapConfig for gNB2
    Verify that 1 out of 2 RRCReconfiguration contains measConfig removing A4 meas for NRHOIF-1 for UE${ue_id}
    Verify that 1 out of 2 RRCReconfiguration contains measGapConfig=release for UE${ue_id}
    Verify that 1 out of 2 RRCReconfiguration contains cfra for UE${ue_id}
    Verify that 1 out of 2 RRCReconfiguration contains ssb-RSRP=0 for UE${ue_id}
    Verify in 1 out of 2 RRCReconfiguration for UE${ue_id} that SCG contains CGI eq 1 and PCI eq ${nrcell2_pci} for SCG
    Verify in 1 out of 2 ReconfigurationComplete for UE${ue_id} that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 4 contains RRCReconfigurationCompleteIndicator=true for gNB2

    Verify that UEContextModificationRequest_3 of 4 contains DRXCycle for gNB2
    Verify that UEContextModificationResponse_3 of 4 contains drx-Config eq setup for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains drx-Config eq setup for UE${ue_id}

Verify messages during NRDC PSCell addition without DRX for UE${ue_id:\d+}
    Verify that UE${ue_id} sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains measurement results of PSCell for gNB2
    Verify that UEContextSetupRequest contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 2 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 2 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 2 does not contain measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE${ue_id}
    Verify that RRCReconfiguration does not contain measGapConfig for UE${ue_id}
    Verify that RRCReconfiguration contains cfra for UE${ue_id}
    Verify that RRCReconfiguration contains ssb-RSRP=0 for UE${ue_id}
    Verify in RRCReconfiguration for UE${ue_id} that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell2_pci} for SCG
    Verify in ReconfigurationComplete for UE${ue_id} that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB2

Set expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uplinkNASTransport
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (ue_ctx_rel_cmd_contains_rrccontainer_save_cu_ue_id) as UEContextReleaseCommand
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete (ue_ctx_rel_cpl_contains_cu_ue_id_match_ctx_rel_with_rrccontainer) as UEContextReleaseComplete
    ...    alias=F1apUeContextReleaseContainsCuUeIdMatchingIdFromRrcContainerForMasterNode
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (ue_ctx_rel_cmd_does_not_contain_rrccontainer_save_cu_ue_id) as UEContextReleaseCommand
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete (ue_ctx_rel_cpl_contains_cu_ue_id_match_ctx_rel_without_rrccontain) as UEContextReleaseComplete
    ...    alias=F1apUeContextReleaseContainsCuUeIdMatchingIdFromRrcContainerForSecondaryNode
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, gNB${gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uplinkNASTransport
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    flow occurred as expected       alias=F1apUeContextReleaseContainsCuUeIdMatchingIdFromRrcContainerForMasterNode
    flow occurred as expected       alias=F1apUeContextReleaseContainsCuUeIdMatchingIdFromRrcContainerForSecondaryNode
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set expected messages flows to check if A4 measurements are not configured for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check if A4 measurements are not configured for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    FAIL FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Expect that NR-DC procedure fails due to ${max_number:\S+} exceeded on PSCell for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup

Verify that NR-DC procedure fails due to ${max_number:\S+} exceeded on PSCell for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    FAIL FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup

Expect that a4Fr2SupervisionTimer expiry event is performed for UE${ue_id:\d+}, gNB2 and AMF1
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that a4Fr2SupervisionTimer expiry event is performed for UE${ue_id:\d+}, gNB2 and AMF1
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Expect that A4 measurements are not configured for UE${ue_id:\d+} with ICS without PDU session for gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are not configured for UE${ue_id:\d+} with ICS without PDU session for gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Expect that A4 measurements are not configured for UE${ue_id:\d+} with ${cap:(sufficient|insufficient)} UECaps, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Set expected messages flows to check if A4 measurements are not configured for UE${ue_id}, gNB${gnb_id} and AMF${amf_id}

Verify that A4 measurements are not configured for UE${ue_id:\d+} with sufficient UECaps, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    FAIL FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    FAIL FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify that A4 measurements not configured for UE${ue_id:\d+} with sufficient UECaps and A2,A3,A4 not blocked, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    FAIL FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify that A4 measurements are not configured for UE${ue_id:\d+} with insufficient UECaps, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    FAIL FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE${ue_id:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages flows to check if A4 measurements are not configured after ICS with no NRDC eligible PDU for UE${ue_id:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=10]: AMF${amf} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected messages flows to check if A4 not configured after ICS with sufficient caps and no NRDC eligible PDU for UE${ue:\d+}, AMF${amf:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue} NR-RRC RRCReconfigurationComplete

Verify expected messages flows to check if A4 not configured after ICS with sufficient caps and no NRDC eligible PDU for UE${ue:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=10]: AMF${amf} NGAP initialContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue} NR-RRC RRCReconfigurationComplete

Set expected messages flows to check if A4 measurements are not configured after reestablishment for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP 6*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows to check if A4 measurements are not configured after reestablishment for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 F1AP 6*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    Verify that A4 measurements are not configured in 1 out of 6 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE${ue_id} in 1 out of 2 RRCReconfiguration message

Set messages flows to check if A4 measurements are configured and deconfigured after ICS with NRDC eligible PDU for UE${ue_id:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP 6*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify messages flows to check if A4 measurements are configured and deconfigured after ICS with NRDC eligible PDU for UE${ue_id:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=10]: AMF${amf} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP 6*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Set messages flows to check if A4 measurements are configured after ICS with NRDC eligible PDU for UE${ue_id:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify messages flows to check if A4 measurements are configured after ICS with NRDC eligible PDU for UE${ue_id:\d+}, AMF${amf:\d+}
    PASS FLOW[timeout=10]: AMF${amf} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify that UE${ue_id:\d+} was successfully configured NR-DC for NRCELL-${cell_id:\d+} for gNB${gnb_id:\d+}
    ${pci}    Get From Dictionary    ${NRCELL_ID_TO_PHYSCELL_ID}   ${cell_id}

    Verify that UEContextSetupResponse contains physCellId eq ${pci} for gNB${gnb_id}
    Verify in RRCReconfiguration for UE${ue_id} that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${pci} for SCG
    Verify in ReconfigurationComplete for UE${ue_id} that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB${gnb_id}

Verify that UE${ue_id:\d+} was successfully configured NR-DC for gNB${gnb_id:\d+}
    Verify that UE${ue_id} was successfully configured NR-DC for NRCELL-2 for gNB${gnb_id}

Verify that UE${ue_id:\d+} was successfully configured NR-DC for NRCELL-${cell_id:\d+} with DRX for gNB${gnb_id:\d+}
    ${pci}    Get From Dictionary    ${NRCELL_ID_TO_PHYSCELL_ID}   ${cell_id}

    Verify that UEContextSetupResponse contains physCellId eq ${pci} for gNB${gnb_id}
    Verify in 1 out of 2 RRCReconfiguration for UE${ue_id} that SCG contains CGI eq 1 and PCI eq ${nrcell2_pci} for SCG
    Verify in 1 out of 2 ReconfigurationComplete for UE${ue_id} that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 4 contains RRCReconfigurationCompleteIndicator=true for gNB2

    Verify that UEContextModificationRequest_3 of 4 contains DRXCycle for gNB2
    Verify that UEContextModificationResponse_3 of 4 contains drx-Config eq setup for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains drx-Config eq setup for UE${ue_id}

Verify common flow for A4 measurement based NRDC PSCell addition for I-B1f
    Verify that UE9 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextSetupResponse contains physCellId eq ${nrcell2_pci} for gNB2
    Verify that UEContextModificationRequest_1 of 2 contains measConfig related to PCell and band 78 for gNB2
    Verify that UEContextModificationRequest_1 of 2 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_1 of 2 does not contain measGapConfig for gNB2
    Verify that RRCReconfiguration contains measConfig removing A4 measurements related to NRHOIF-1 for UE9
    Verify that RRCReconfiguration does not contain measGapConfig for UE9
    Verify that RRCReconfiguration contains ssb-RSRP=0 for UE9
    Verify in RRCReconfiguration for UE9 that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq ${nrcell2_pci} for SCG
    Verify in ReconfigurationComplete for UE9 that message contains encoded RRCReconfigurationComplete for SCG
    Verify that UEContextModificationRequest_2 of 2 contains RRCReconfigurationCompleteIndicator=true for gNB2

Set expected messages flows for A4 measurements deinstalation after A4SupervisionTimer expiry for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification

Verify expected messages flows for A4 measurements deinstalation after A4SupervisionTimer expiry for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification

Set expected messages flows for A4 measurements instalation after A4SupervisionTimer expiry for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=20]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=20]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=20]: gNB${gnb_id} F1AP uEContextModification

Verify expected messages flows for A4 measurements instalation after A4SupervisionTimer expiry for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    PASS FLOW[timeout=20]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=20]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=20]: gNB${gnb_id} F1AP uEContextModification

Set AMBR params for UE${ue_id:\d+} PDU:${pdu_id:\d+} AMBR-DL:${dl_value:\d+}${dl_unit:\S+} AMBR-UL:${ul_value:\d+}${ul_unit:\S+}
    ${command}    Catenate    smf_ue_pdu_param id=1 ue=${ue_id} pdu=${pdu_id} session_ambr_dl=${dl_value}:${dl_unit}
    ...                       session_ambr_ul=${ul_value}:${ul_unit}

    Execute egate command
    ...     cmd=${command}

    sleep  2

Trigger UE${ue_id:\d+} to enter and exit idle mode
    Execute egate command  cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    Trigger UE${ue_id} to enter idle mode
    Trigger UE${ue_id} idle mode exit
    sleep  2

Trigger Radio Link Failure for UE${ue_id:\d+}
    Execute egate command   cmd=rlf_testmode_nr profile_id=1 num_stop_csi_report=2000 num_stop_dlharq_tx=3000
    Execute egate command   cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1

Trigger simulated UPF to send GTP-U Error Indication to gNB${gnb_id:\d+} for UE${ue_id:\d+}
    Execute egate command   cmd=upf_ue_pdu_inject_error_ind id=1 ue=${ue_id}

Set expected message flows for UE${ue_id:\d+} Context Setup via reestablishment to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP initialULRRCMessageTransfer
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP dLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialUEMessage

Set expected message flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP initialULRRCMessageTransfer
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP dLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialUEMessage

Verify expected messages flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP initialULRRCMessageTransfer
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP dLRRCMessageTransfer
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialUEMessage

Set expected message flows for not optimized UE${ue_id:\d+} ICS after reestablishment via RRC Setup, with gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification

Set expected message flows for RRCReestablishment procedure for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup

Verify expected messages flows for RRCReestablishment procedure for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    FAIL FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup

Set expected message flows for RRCReestablishment procedure without ICS check for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP 3*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected message flows for RRCReestablishment procedure to serving cell without ICS for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    Set expected message flows for RRCReestablishment procedure without ICS check for UE${ue_id}, gNB${gnb_id} and AMF${amf_id}

Verify expected message flows for RRCReestablishment procedure to serving cell without ICS for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    Verify expected messages flows for RRCReestablishment procedure without ICS check for UE${ue_id}, gNB${gnb_id} and AMF${amf_id}

Verify expected messages flows for RRCReestablishment procedure without ICS check for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP 3*bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages flows for not optimized UE${ue_id:\d+} ICS after reestablishment via RRC Setup, with gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected message flows for deletion old UE${ue_id:\d+} Context by gNB${gnb_id:\d+} after reestablishment, with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'unspecified') as UEContextReleaseCommandMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'unspecified') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseMNandSNContext
    ...    overall_timeout=10

Verify expected messages flows for deletion old UE${ue_id:\d+} Context by gNB${gnb_id:\d+} after reestablishment, with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModificationRequired
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification
    Flow occurred as expected       alias=F1apUeContextReleaseMNandSNContext

Set expected message flows for deletion old UE${ue_id:\d+} Context by AMF${amf_id:\d+} after reestablishment, with gNB${gnb_id:\d+}
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (misc eq 'unspecified') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease

Verify expected messages flows for deletion old UE${ue_id:\d+} Context by AMF${amf_id:\d+} after reestablishment, with gNB${gnb_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
    Flow occurred as expected       alias=F1apUeContextReleaseSNContext
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set expected message flows for deletion UE${ue_id:\d+} Context by gNB${gnb_id:\d+} due to detected RLF, with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextRelease

Verify expected messages flows for deletion UE${ue_id:\d+} Context by gNB${gnb_id:\d+} due to detected RLF, with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModificationRequired
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextRelease

Verify in BearerContextInactivityNotification that ActivityInformation is set to ${act_info_val}:${ue_act_val} for UE${ue_id:\d+} and gNB${gnb:\d+}
    ${flow_alias}=     Get Flow Name
    ...     procedure=bearerContextInactivityNotification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (ActivityInformation contains (${act_info_val} eq '${ue_act_val}'))
    ...     message_alias=BearerContextInactivityNotification
    ...     flow_alias=${flow_alias}

Verify in RRCRelease that cellReselectionPriorities IE is included for UE${ue_id:\d+}
    PASS FLOW[timeout=15]: UE_${ue_id} NR-RRC RRCRelease
    ${flow_alias}=      Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (cellReselectionPriorities is present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${flow_alias}

Verify in RRCRelease that cellReselectionPriorities IE is not included for UE${ue_id:\d+}
    ${flow_alias}=      Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (cellReselectionPriorities is not present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${flow_alias}

Get measId matching reportConfig and measObjectId with ${event_id} and NRCELL-${cell_id:\d+} for UE${ue_id:\d+}
    ${cell_id_freq}=  get_arfcnSsbPbch_value_from_cell  ${cell_id}
    Set Test Variable  ${cell_id_freq}
    get_active_measurements     UE_${ue_id}         enable_logging=${True}
    ${report_id}=    Get reportConfigId field value from reportConfig with (${event_id} is present) for UE_${ue_id}
    ${meas_object_id}=    Get measObjectId field value from measObject with (ssbFrequency eq ${cell_id_freq}) for UE_${ue_id}
    ${check_conditions}=     Run Keyword and ignore error
    ...     Get measId field value from measId with ((reportConfigId eq ${report_id}) and (measObjectId eq ${meas_object_id})) for UE_${ue_id}
    Run keyword if  'FAIL' in ${check_conditions}
    ...     Run keywords
    ...     wait_for_next_measurement    ue_alias=UE_${ue_id}
    ...     AND   get_active_measurements     UE_${ue_id}         enable_logging=${True}
    ${meas_id}=   Get measId field value from measId with ((reportConfigId eq ${report_id}) and (measObjectId eq ${meas_object_id})) for UE_${ue_id}
    [Return]        ${meas_id}

UE${ue_id:\d+} has experienced RLF and sends RRC Reestablishment Request
    Execute egate command    cmd=gnb_ue_rrc_reestablish_param ue=${ue_id} gnb_id=2 action=rrcsetup
    Sleep  2
    Execute egate command    cmd=ue_rrc_reestablish id=${ue_id}

UE${ue_id:\d+} sends RRC Reestablishment Request
    Execute egate command    cmd=gnb_ue_rrc_reestablish_param ue=${ue_id} gnb_id=2 action=rrcreestablishment
    Execute egate command    cmd=ue_rrc_reestablish id=${ue_id}

UE${ue_id:\d+} sends RRC Reestablishment Request to NRCELL-${cell_id:\d+}
    Execute egate command    cmd=gnb_ue_rrc_reestablish_param ue=${ue_id} gnb_id=2 action=rrcreestablishment
    Execute egate command    cmd=ue_rrc_reestablish id=${ue_id} cell=${cell_id}

UE${ue_id:\d+} sends A4 measurement with id=${measurement_id} for NR-DC PSCell addition
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measurement_id} event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=52 nrsrp_nr=85 nrsrq_nr=31 index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    Verify that MeasurementReport contains measurement results of PSCell for UE${ue_id}

Trigger AMF Initiated Full Reset
    Execute egate command   cmd=link_ng_reset by=amf:all

Trigger AMF Initiated Partial Reset for UE${ue_id:\d+}
    Execute egate command   cmd=link_ng_reset by=amf:all ue=${ue_id}

Set expected messages flow for AMF Initiated Full Reset for AMF${amf_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP nGReset
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APResetAck
    ...    alias=F1APResetMN_first
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APResetAck
    ...    alias=F1APResetMN_second
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APResetAck
    ...    alias=F1APResetMN_third
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_SN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_SN) as F1APResetAck
    ...    alias=F1APResetSN_first
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_SN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_SN) as F1APResetAck
    ...    alias=F1APResetSN_second
    ...    overall_timeout=10
    EXPECT FLOW[timeout=5]: gNB${gnb_id} F1AP 5*reset

    # 5*F1AP: Reset +  3*E1AP: Reset
    Observe Reset for 8 occurrences for 20s
    Observe ResetAcknowledge for 8 occurrences for 20s

    Register callback
    ...     Reset
    ...     increment_counter_for_e1_or_f1_reset_msgs

    Register callback
    ...     ResetAcknowledge
    ...     decrement_counter_for_e1_or_f1_reset_msgs

Set expected messages flow for AMF Initiated Partial Reset for UE with NRDC for AMF${amf_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP nGReset
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APResetAck
    ...    alias=F1APResetMN_first
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_SN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_SN) as F1APResetAck
    ...    alias=F1APResetSN_first
    ...    overall_timeout=10
    EXPECT FLOW[timeout=5]: gNB${gnb_id} F1AP 2*reset

    # 2*F1AP: Reset + E1AP: Reset
    Observe Reset for 3 occurrences for 20s
    Observe ResetAcknowledge for 3 occurrences for 20s

    Register callback
    ...     Reset
    ...     increment_counter_for_e1_or_f1_reset_msgs

    Register callback
    ...     ResetAcknowledge
    ...     decrement_counter_for_e1_or_f1_reset_msgs

Set expected messages flow for AMF Initiated Partial Reset for UE without NRDC for AMF${amf_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP nGReset
    Expect message flow
    ...    gNB${gnb_id}:F1AP_Reset (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APReset
    ...    gNB${gnb_id}:F1AP_ResetAcknowledge (verify_ue_ctx_reset_match_cu_ue_ctx_for_MN) as F1APResetAck
    ...    alias=F1APResetMN_first
    ...    overall_timeout=10

    Observe Reset for 2 occurrences for 20s
    Observe ResetAcknowledge for 2 occurrences for 20s

    Register callback
    ...     Reset
    ...     increment_counter_for_e1_or_f1_reset_msgs

    Register callback
    ...     ResetAcknowledge
    ...     decrement_counter_for_e1_or_f1_reset_msgs

Set expected message flows for UE${ue_id:\d+} Context Release due to NG-U GTP-U Error with gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (transport eq 'unspecified') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected messages flows for UE${ue_id:\d+} Context Release due to NG-U GTP-U Error with gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModificationRequired
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
    Flow occurred as expected       alias=F1apUeContextReleaseSNContext
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected messages flow for AMF Initiated Full Reset for AMF${amf_id:\d+} and gNB${gnb_id:\d+}
    PASS FLOW[timeout=5]: AMF${amf_id} NGAP nGReset
    flow occurred as expected       alias=F1APResetMN_first
    flow occurred as expected       alias=F1APResetMN_second
    flow occurred as expected       alias=F1APResetMN_third
    flow occurred as expected       alias=F1APResetSN_first
    flow occurred as expected       alias=F1APResetSN_second
    PASS FLOW[timeout=5]: gNB${gnb_id} F1AP 5*reset

    Sleep  10s

    verify_e1_and_f1_messages_for_MN_and_SN

Verify expected messages flow for AMF Initiated Partial Reset for UE with NRDC for AMF${amf_id:\d+} and gNB${gnb_id:\d+}
    PASS FLOW[timeout=5]: AMF${amf_id} NGAP nGReset
    flow occurred as expected       alias=F1APResetMN_first
    flow occurred as expected       alias=F1APResetSN_first
    PASS FLOW[timeout=5]: gNB${gnb_id} F1AP 2*reset

    Sleep    10s    reason=Wait for receiving all Resets

    verify_e1_and_f1_messages_for_MN_and_SN

Verify expected messages flow for AMF Initiated Partial Reset for UE without NRDC for AMF${amf_id:\d+} and gNB${gnb_id:\d+}
    PASS FLOW[timeout=5]: AMF${amf_id} NGAP nGReset
    flow occurred as expected       alias=F1APResetMN_first

    Sleep    10s    reason=Wait for receiving all Resets

    verify_e1_and_f1_messages_for_MN_and_SN

Verify in NGAP Reset that cause:${cause_group:\S+}:${cause:\S+} is present for gNB
    ${flow_alias}=     Get flow name
    ...     procedure=nGReset
    ...     device=AMF1
    ...     protocol=NGAP

    verify_cause_in_reset_msgs
    ...     message_alias=NGReset
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

Verify in F1AP Reset that cause:${cause_group:\S+}:${cause:\S+} is present for gNB
    ${flow_alias}=     Get flow name
    ...     procedure=2*reset
    ...     device=gNB2
    ...     protocol=F1AP

    verify_cause_in_reset_msgs
    ...     message_alias=Reset_1
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

    verify_cause_in_reset_msgs
    ...     message_alias=Reset_2
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

Verify in all F1AP Reset that cause:${cause_group:\S+}:${cause:\S+} is present for gNB
    ${flow_alias}=     Get flow name
    ...     procedure=5*reset
    ...     device=gNB2
    ...     protocol=F1AP

    verify_cause_in_reset_msgs
    ...     message_alias=Reset_1
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

    verify_cause_in_reset_msgs
    ...     message_alias=Reset_2
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

    verify_cause_in_reset_msgs
    ...     message_alias=Reset_3
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

    verify_cause_in_reset_msgs
    ...     message_alias=Reset_4
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

    verify_cause_in_reset_msgs
    ...     message_alias=Reset_5
    ...     flow_alias=${flow_alias}
    ...     cause_group=${cause_group}
    ...     cause=${cause}

Verify in NGAP:Reset that ResetType eq ${interfaceType:\S+}:${resetType:\S+}
    Verify in NGAP:Reset that ResetType contains ${interfaceType}
    ${flow_alias}=     Get flow name
    ...     procedure=nGReset
    ...     device=AMF1
    ...     protocol=NGAP

   Verify That Message Fulfills Query
    ...     ResetType contains (nG-Interface eq ${resetType})
    ...     message_alias=NGReset
    ...     flow_alias=${flow_alias}

Verify in NGAP:Reset that ResetType contains ${interfaceType:\S+}
    ${flow_alias}=     Get flow name
    ...     procedure=nGReset
    ...     device=AMF1
    ...     protocol=NGAP

   Verify That Message Fulfills Query
    ...     ResetType contains ('partOfNG_Interface')
    ...     message_alias=NGReset
    ...     flow_alias=${flow_alias}

Set expected message flows for UE${ue_id:\d+} Context Release due to preemption for gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP dLRRCMessageTransfer
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'release-due-to-pre-emption') as UEContextReleaseCommandMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'unspecified') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release due to user inactivity to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseMNandSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release due to user inactivity with NGAP timeout to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseMNandSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release with ErrorIndocation to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (protocol eq 'normal-release') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseMNandSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected messages flows for UE${ue_id:\d+} Context Release due to user inactivity to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNandSNContext
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected messages flows for UE${ue_id:\d+} Context Release due to user inactivity with NGAP timeout to gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    FAIL FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNandSNContext
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release due to preemption for gNB${gnb_id:\d+} with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextReleaseRequest
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
    Flow occurred as expected       alias=F1apUeContextReleaseSNContext
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release due to AMF reselection failure for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=3]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=3]: AMF2 NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=3]: AMF3 NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=3]: AMF1 NGAP uplinkNASTransport
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (RRCContainer is present) as UEContextReleaseCommandMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (RRCContainer is not present) as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC ULInformationTransfer
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release due to AMF reselection failure for gNB${gnb_id:\d+}
    FAIL FLOW[timeout=3]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    FAIL FLOW[timeout=3]: AMF2 NGAP uEContextReleaseRequest,uEContextRelease
    FAIL FLOW[timeout=3]: AMF3 NGAP uEContextReleaseRequest,uEContextRelease
    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceModify
    FAIL FLOW[timeout=3]: AMF1 NGAP uplinkNASTransport
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    flow occurred as expected       alias=F1apUeContextReleaseMNContext
    flow occurred as expected       alias=F1apUeContextReleaseSNContext
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC ULInformationTransfer
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Attach UE${ue_id:\d+} with QoS flow with higher ARP priority
    Attach UE${ue_id} without ICS to gNB2 cell2
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=6
    Add to UE${ue_id} initial PDU session with ICS
    Execute egate command  cmd=smf_param id=1 reset

Attach UE${ue_id:\d+} without ICS to simulated LTE cell
    Attach UE${ue_id} without ICS to gNB2 cell1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 87
    Perform inter RAT handover to LTE for UE${ue_id}

Expect that PSCell Addition fails due to maxNumOfNrDcSnNonGBRBearers exceeded for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup

Verify that PSCell Addition fails due to maxNumOfNrDcSnNonGBRBearers exceeded for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    FAIL FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup

Expect that PSCell Addition fails due to maxNumOfRrcConUEsPerDU exceeded for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetupFailure
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification

Verify that PSCell Addition fails due to maxNumOfRrcConUEsPerDU exceeded for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetupFailure
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification

UE${ue_id:\d+} sends A4 measurement with id=${measurement_id} for NR-DC PSCell addition for NRHOIF-2
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measurement_id} event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=53 nrsrp_nr=86 nrsrq_nr=31 index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    Verify that MeasurementReport contains measurement results of PSCell for UE${ue_id}

Set PDU session with 2 additional non-GBR QoS Flow for UE${ue_id:\d+}
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=off
    ...     cmd=smf_param id=1 additional_qosflows_to_activate=3,5

Set parameter for UE${ue_id:\d+} to not trigger NGAP response transmission in AMF${amf_id:\d+}
    Execute egate command    cmd=amf_ue_ctx_release_param id=${amf_id} ue=${ue_id} action=no_response nth=1

Set parameter for AMF${amf_id:\d+} to respond with ERROR INDICATION in UE CONTEXT RELEASE REQUEST for UE${ue_id:\d+}
    Execute egate command    cmd=amf_ue_ctx_release_param id=${amf_id} ue=${ue_id} action=error_indication

Set shortened expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uplinkNASTransport
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set in NGAP:UEContextRelease message Cause:${cause:\S+} for UE${ue_id:\d+}
    Execute egate command    cmd=amf_ue_ctx_release_param id=1 ue=${ue_id} action=override_cause nth=1 cause=${cause}

Verify shortened expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, gNB${gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uplinkNASTransport
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Lock NG-C link to AMF${amf_id:\d+}
    Log to console     Lock NG-C link for AMF${amf_id}
    Configure   {'MOC': 'SERVEDAMF', 'ID': '${amf_id}', 'administrativestate': 'Locked'}

Unlock NG-C link to AMF${amf_id:\d+}
    Log to console     Unlock NG-C link for AMF${amf_id}
    Configure   {'MOC': 'SERVEDAMF', 'ID': '${amf_id}', 'administrativestate': 'Unlocked'}

Trigger UE${ue_id:\d+} to send RRC ULInformationTransfer
    Execute egate command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3

Set expected message flows for deletion UE${ue_id:\d+} Context by gNB${gnb_id:\d+} due to PDCP count rollover, with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'unspecified') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseSNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected messages flows for deletion UE${ue_id:\d+} Context by gNB${gnb_id:\d+} due to PDCP count rollover, with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModificationRequired
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
    Flow occurred as expected       alias=F1apUeContextReleaseSNContext
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Set expected message flows for deletion UE${ue_id:\d+} Context by gNB${gnb_id:\d+} due to expiration of RRC Guard Timer, with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextReleaseCommand (radioNetwork eq 'unspecified') as UEContextReleaseCommandSNContext
    ...    gNB${gnb_id}:F1AP_UEContextReleaseComplete as UEContextReleaseCompleteSNContext
    ...    alias=F1apUeContextReleaseSNContext
    ...    overall_timeout=10

Verify expected messages flows for deletion UE${ue_id:\d+} Context by gNB${gnb_id:\d+} due to expiration of RRC Guard Timer, with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    FAIL FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest,uEContextRelease
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
    Flow occurred as expected       alias=F1apUeContextReleaseSNContext

Set expected messages flows for lack of A4 measurement configuration for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification

Verify expected messages flows for lack of A4 measurement configuration for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP 2*uEContextModification
    FAIL FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set delay RRCReconfigurationComplete by ${delay:\d+}ms for UE${ue_id:\d+}
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=${delay}

Deregister UE${ue_id:\d+} from AMF${amf_id:\d+}
    EXPECT FLOW[timeout=3]: AMF${amf_id} NGAP uEContextRelease
    Execute egate command
    ...    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    PASS FLOW[timeout=3]: AMF${amf_id} NGAP uEContextRelease

Verify that AMF${amf_id:\d+} release UE with Cause Group: ${cause_group} and Cause: ${cause}
    ${flow_alias}=      Get Flow Name
    ...     procedure=uEContextRelease
    ...     device=AMF${amf_id}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     (${cause_group} eq ${cause})
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Attach UE${ue_id:\d+} with ICS to simulated gNB${gnb_id:\d+}
    Execute egate command
    ...    cmd=change_ue_location id=${ue_id} cell=1 enb=${gnb_id}
    Sleep  1
    Execute egate command
    ...    cmd=ue_register id=${ue_id}
    Sleep  1
    Execute egate command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1
    Sleep  1

Attach UE${ue_id:\d+} with non eligible NRDC PDU session to simulated gNB${gnb_id:\d+}
    Execute egate command
    ...    cmd=change_ue_location id=${ue_id} cell=1 enb=${gnb_id}
    Sleep  1
    Execute egate command
    ...    cmd=ue_register id=${ue_id}
    Sleep  1
    Execute egate command
    ...    cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=87
    Sleep  1
    Execute egate command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1
    Sleep   1
    Execute egate command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5
    Sleep   5

Configure ue_history for UE${ue_id:\d+} to enable handovers from gNB${gnb_id:\d+}
    Execute egate command
    ...    cmd=ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=234:77|0x01 gnb_id=${gnb_id} time_ue_stayed_in_cell=97

    Execute egate command
    ...    cmd=ue_history_information_list id=${ue_id} action=commit

    Execute egate command
    ...    cmd=ue_enb_param id=${ue_id} ue_history_list=${ue_id}

Set expected messages flows to check incomming XN handover for UE${ue_id:\d+}, gNB${gnb_id:\d+} and gNB3
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP uEContextRelease

Verify that expected message flows for incomming XN handover occured for UE${ue_id:\d+}, gNB${gnb_id:\d+} and gNB3
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP handoverPreparation
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB${gnb_id} NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP uEContextRelease

Set expected messages flows to check failure during incomming XN handover for UE${ue_id:\d+}, gNB${gnb_id:\d+} and gNB3
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP handoverPreparationFailure
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP uEContextRelease

Verify that expected message flows for failure during incomming XN handover occured for UE${ue_id:\d+}, gNB${gnb_id:\d+} and gNB3
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP handoverPreparationFailure
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: gNB${gnb_id} NGAP pathSwitchRequest
    FAIL FLOW[timeout=10]: gNB${gnb_id} XNAP uEContextRelease

Set expected messages flows to check UECapabilityEnquiry request for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=5]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication

Verify that expected message flows for UECapabilityEnquiry request occured for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=5]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication

Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityInformation
    FAIL FLOW[timeout=5]: AMF${amf_id} NGAP uERadioCapabilityInfoIndication

Trigger UE${ue_id:\d+} handover from sim_gNB to gNB${gnb_id:\d+} NRCELL-${cell_id:\d+} with ${caps:(sufficient|insufficient)} UECapabilites
    Run Keyword if   '${caps}' == 'insufficient'    Set insufficient UECaps during XN Handover procedure for UE${ue_id}
    ${pci} =    Evaluate    ${49} + ${cell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${pci} nrsrp_nr=30 nrsrq_nr=30

Trigger UE${ue_id:\d+} handover from sim_gNB to gNB2 NRCELL-${cell_id:\d+}
    ${pci} =    Evaluate    ${49} + ${cell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${pci} nrsrp_nr=30 nrsrq_nr=30

Trigger intra-gNB inter-cell HO to NRCELL-2 for UE${ue_id:\d+}
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Execute egate command
    ...    cmd=ue_ho_nr ue_id=${ue_id} tgt_phycell_id=51 meas_type=A3 tgt_cell_ssb_frequency=425070
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set UE${ue_id:\d+} to ignore RRCReconfiguration
    Execute egate command
    ...    cmd=ue_nr_rrc_reconf_param if_contains=any action=drop id=${ue_id}
    Sleep  1

Clear UE${ue_id:\d+} from ignore RRCReconfiguration
    Execute egate command
    ...    cmd=ue_nr_rrc_reconf_param if_contains=any action=none id=${ue_id}

Verify that A4 measurements are not configured for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF1 in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A4 measurements configured for UE${ue_id:\d+} after inter-cell HO in RRCReconfiguration message
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    ${flow_alias_rrc}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is present
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias_rrc}

Add to UE${ue_id:\d+} initial PDU session after ICS and expect A4 measurement configuration
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Verify that A4 measurements are configured for UE${ue_id:\d+} after first PDU session setup
    ${flow_alias_rrc}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is present
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias_rrc}

Set expected messages flows to check A4 activation after inter-cell HO for UE${ue_id:\d+}
     EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Set expected messages flows to check A4 activation without DRX after inter-cell HO for UE${ue_id:\d+}
     EXPECT FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
     EXPECT FLOW[timeout=3]: gNB2 F1AP 5*uEContextModification
     EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Verify expected messages flows to check A4 activation without DRX after inter-cell HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
     FAIL FLOW[timeout=3]: gNB2 F1AP 5*uEContextModification
     PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Set expected messages flows to check A4 activation with DRX after inter-cell HO for UE${ue_id:\d+}
     EXPECT FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     EXPECT FLOW[timeout=10]: gNB2 F1AP 7*uEContextModification
     EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Verify expected messages flows to check A4 activation with DRX after inter-cell HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     PASS FLOW[timeout=10]: gNB2 F1AP 7*uEContextModification
     PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Set expected messages flows to check A2/A3/A5 activation with DRX after inter-cell HO for UE${ue_id:\d+}
     EXPECT FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     EXPECT FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
     EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest
     EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextRelease

Verify expected messages flows to check A2/A3/A5 activation with DRX after inter-cell HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     PASS FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
     PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest
     FAIL FLOW[timeout=5]: AMF1 NGAP uEContextRelease

Set expected messages flows to check A2/A3/A4/A5 deactivation after inter-cell HO for UE${ue_id:\d+}
     EXPECT FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
#     EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
     EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest
     EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextRelease

Verify expected messages flows to check A2/A3/A5 activation after inter-cell HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
#     PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
     FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest
     FAIL FLOW[timeout=5]: AMF1 NGAP uEContextRelease

Set expected messages flows to check A2/A3/A5 deactivation with DRX after inter-cell HO for UE${ue_id:\d+}
     Set expected messages flows to check A2/A3/A5 activation with DRX after inter-cell HO for UE${ue_id}

Verify expected messages flows to check A2/A3/A5 deactivation with DRX after inter-cell HO for UE${ue_id:\d+}
     Verify expected messages flows to check A2/A3/A5 activation with DRX after inter-cell HO for UE${ue_id}

Set expected messages flows to check outgoing XN handover for UE${ue_id:\d+}, gNB${gnb_id:\d+} and gNB3
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP uEContextRelease

Verify expected messages flows for outgoing XN handover for UE${ue_id:\d+}, gNB${gnb_id:\d+} and gNB3
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP handoverPreparation
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP uEContextRelease

Trigger UE${ue_id:\d+} handover from gNB${gnb_id:\d+} NRCELL-1 to sim_gNB with meas_id eq ${meas_id}
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC MeasurementReport
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=46 nrsrp_nr=30 nrsrq_nr=30
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC MeasurementReport

Get UE${ue_id:\d+} active Meas Id for frequency ${freq} ${event_type} and trigger ${trigger}
    get_ue_measurement_configuration  ue_id=${ue_id}  alias=${ue_id}_meas

    ${meas_id}    get_meas_id_for_measurement_on_frequency  event_type=${event_type}  carrier_freq=${freq}
    ...    alias=${ue_id}_meas  trigger=${trigger}

    [Return]    ${meas_id}

Perform inter-RAT handover from LTE to 5G for UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: UE_${ue_id} RRC MobilityFromEUTRACommand
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease

    Sleep    1
    Trigger inter-RAT handover from LTE to 5G for UE${ue_id} to gNB${gnb_id} cell${cell_id}

    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: UE_${ue_id} RRC MobilityFromEUTRACommand
    PASS FLOW[timeout=10]: AMF1 NGAP handoverNotification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease

    ${flow_alias_rrc}=     Get flow name
    ...     MobilityFromEUTRACommand
    ...     device=UE_${ue_id}
    ...     protocol=RRC

    Verify That Message Fulfills Query
    ...     (spCellConfigDedicated is present)
    ...     message_alias=MobilityFromEUTRACommand
    ...     flow_alias=${flow_alias_rrc}

Set expected messages flows to check incomming NG handover for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} NGAP downlinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: gNB${gnb_id} NGAP handoverNotification

Verify that expected message flows for incomming NG handover occured for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB${gnb_id} NGAP downlinkRANStatusTransfer
    PASS FLOW[timeout=10]: gNB${gnb_id} NGAP handoverNotification

Set UE${ue_id:\d+} InterRAT sufficient NRDC capability in ue_param
    Execute egate command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=InterRATNRDCsufficient_nr_capability capability_file=${CURDIR}/ue_cap.cfg
    Log to console    UE${ue_id} nr_capabilites modified by cmd!

Set UE${ue_id:\d+} InterRAT sufficient NRDC capability with independentGapConfig in ue_param
    Execute egate command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=InterRATNRDCsufficient_nr_capability_indep_GapConfig capability_file=${CURDIR}/ue_cap.cfg
    Log to console    UE${ue_id} nr_capabilites modified by cmd!

Set UE${ue_id:\d+} InterRAT insufficient NRDC capability in ue_param
    Execute egate command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=InterRATNRDCinsufficient_nr_capability capability_file=${CURDIR}/ue_cap.cfg
    Log to console    UE${ue_id} nr_capabilites modified by cmd!

Set UE${ue_id:\d+} InterRAT insufficient NRDC capability with independentGapConfig in ue_param
    Execute egate command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=InterRATNRDCinsufficient_nr_capability_indep_GapConfig capability_file=${CURDIR}/ue_cap.cfg
    Log to console    UE${ue_id} nr_capabilites modified by cmd!

Exit idle mode and expect NRDC A4 activation for UE${ue_id:\d+}
    Set indexToRFSP to 87 for UE${ue_id}
    Set expected messages flows for NRDC A4 measurements for UE${ue_id} with sufficient UECaps and gNB2
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    Trigger UE${ue_id} idle mode exit

Exit idle mode and setup NRDC for UE${ue_id:\d+}
    Exit idle mode and expect NRDC A4 activation for UE${ue_id}
    Verify expected messages flows for NRDC A4 measurements for UE${ue_id} with sufficient UECaps and gNB2
    Set expected messages flows for A4 measurement based PSCell addition for UE${ue_id}, gNB2 and AMF1
    UE${ue_id} sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE${ue_id}, gNB2 and AMF1

Set expected messages flows to check A4 activation with DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 7*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete

Verify expected messages flows to check A4 activation with DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 7*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete

Set expected messages flows to check A4 measurements are NOT configured after incoming inter-gNB XN HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check A4 measurements are NOT configured after incoming inter-gNB XN HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    Verify that A4 measurements are not configured for UE2 in RRCReconfiguration message

Set expected messages flows to check A4 activation without DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Set expected messages flows to check not A4 activation without DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
#    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check A4 activation without DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows to check not A4 activation without DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
#    PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check A4 activation with DRX after incoming intra-gNB NG HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 NGAP downlinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete

Verify expected messages flows to check A4 activation with DRX after incoming intra-gNB NG HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 NGAP downlinkRANStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 NGAP handoverNotification
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 4*RRCReconfigurationComplete

Set expected messages flows to check A4 activation without DRX after incoming intra-gNB NG HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 NGAP downlinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows to check A4 activation without DRX after incoming intra-gNB NG HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 NGAP downlinkRANStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 NGAP handoverNotification
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Set expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 NGAP downlinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 NGAP downlinkRANStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 NGAP handoverNotification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check A2/A3/A5 activation without DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check A2/A3/A5 activation without DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows to check A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Wait for NRDC A4 activation and get measID for UE${ue_id:\d+} and NRCELL-${cell_id:\d+}
    Sleep    2
    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-${cell_id} for UE${ue_id}
    Sleep    2
    [Return]  ${meas_id}

Set expected messages flows to check A4 activation without DRX after interRAT HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
    EXPECT FLOW[timeout=3]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Verify expected messages flows to check A4 activation without DRX after interRAT HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
     PASS FLOW[timeout=10]: gNB2 F1AP 3*uEContextModification
     FAIL FLOW[timeout=3]: gNB2 F1AP 4*uEContextModification
     PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Set expected messages flows to check NOT A4 activation after interRAT HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=5]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration

Verify expected messages flows to check NOT A4 activation after interRAT HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
     PASS FLOW[timeout=10]: gNB2 F1AP uEContextModification
     FAIL FLOW[timeout=5]: gNB2 F1AP 2*uEContextModification
     FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration

Set expected messages flows to check NOT A2/A3/A4/A5 activation after interRAT HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Verify expected messages flows to check NOT A2/A3/A4/A5 activation after interRAT HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
     PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
     FAIL FLOW[timeout=10]: gNB2 F1AP uEContextModification
     FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Trigger inter-RAT handover from LTE to 5G for UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+}
    Execute egate command  cmd=5g_gnb_trigger_inter_rat_handover_to ue=${ue_id} target_gnb=${gnb_id} target_cell=${cell_id} plmn=311:489

Verify that A4 measurements are not configured after inter-RAT HO for UE${ue_id:\d+} in mobilityFromEUTRACommand message
    ${flow_alias_rrc}=     Get flow name
    ...     MobilityFromEUTRACommand
    ...     device=UE_${ue_id}
    ...     protocol=RRC

    Verify That Message Fulfills Query
    ...     eventA4 is not present
    ...     message_alias=MobilityFromEUTRACommand
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are configured after inter-RAT HO for UE${ue_id:\d+} in mobilityFromEUTRACommand message
    ${flow_alias_rrc}=     Get flow name
    ...     MobilityFromEUTRACommand
    ...     device=UE_${ue_id}
    ...     protocol=RRC

    Verify That Message Fulfills Query
    ...     eventA2 is present and eventA3 is present and eventA5 is present
    ...     message_alias=MobilityFromEUTRACommand
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are NOT configured after inter-RAT HO for UE${ue_id:\d+} in mobilityFromEUTRACommand message
    ${flow_alias_rrc}=     Get flow name
    ...     MobilityFromEUTRACommand
    ...     device=UE_${ue_id}
    ...     protocol=RRC

    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     eventA2 is not present and eventA3 is not present and eventA5 is not present
    ...     message_alias=MobilityFromEUTRACommand
    ...     flow_alias=${flow_alias_rrc}

    Verify That Message Fulfills Query
    ...     measConfig is not present
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Set expected messages flows to check no A4 and A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    Set expected messages flows to check A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE${ue_id}
    EXPECT FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification

Verify expected messages flows to check no A4 and A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE${ue_id:\d+}
    Verify expected messages flows to check A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE${ue_id}
    PASS FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification

Set expected messages flows to check no A4 and A2/A3/A5 activation with DRX after first PDU session setup for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected messages flows to check no A4 and A2/A3/A5 activation with DRX after first PDU session setup for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Set expected messages flows to check no A4 and A2/A3/A5 activation without DRX after first PDU session setup for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check no A4 and A2/A3/A5 activation without DRX after first PDU session setup for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Expect that A4 measurements are configured after adding eligible PDU session for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify that A4 measurements are configured after adding eligible PDU session for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check that A4 measurements are not installed after NR-DC eligible PDU session setup for non FWA UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check that A4 measurements are not installed after NR-DC eligible PDU session setup for non FWA UE${ue_id:\d+}
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check that A4 measurements are not installed after ICS with no PDU session setup UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages flows to check that A4 measurements are not installed after ICS with no PDU session setup UE${ue_id:\d+}
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Transfer UE${ue_id:\d+} from FWA to non-FWA by setting RFSP index to ${indexToRFSP:\d+} via NGAP:UEContextModification
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextModification
    Execute egate command
    ...     cmd=ue_ctx_ng_mod id=${ue_id} indexToRFSP=${indexToRFSP}
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextModification

Transfer UE${ue_id:\d+} from FWA to non-FWA by online reconfiguration of identifiedFwaUeList by setting RFSP index to ${indexToRFSP:\d+}
    Configure    ${yaml_HA_B1d}
    Sleep    2

Expect that A4 measurements are not configured ${sec:\d+}s after ${timer:\S+} stops for UE${ue_id:\d+}
    EXPECT FLOW[timeout=${sec}]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=${sec}]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=${sec}]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are not configured ${sec:\d+}s after ${timer:\S+} stops for UE${ue_id:\d+}
    FAIL FLOW[timeout=${sec}]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=${sec}]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=${sec}]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Expect that A4 measurements are not configured after retryTimer expiry for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are not configured after retryTimer expiry for UE${ue_id:\d+}
    FAIL FLOW[timeout=10]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Expect that A4 measurements are configured after retryTimer expiry for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are configured after retryTimer expiry for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    ${flow_alias_rrc}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToAddModList is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Expect takeback will not occure
    EXPECT FLOW[timeout=40]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=40]: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=40]: UE_1 NR-RRC RRCReconfigurationComplete

Verify that takeback did not occure
    FAIL FLOW[timeout=40]: AMF1 NGAP pDUSessionResourceModify
    FAIL FLOW[timeout=40]: UE_1 NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=40]: UE_1 NR-RRC RRCReconfigurationComplete

Add NR-DC eligible PDU sesion for non FWA UE${ue_id:\d+} and expect A4 measurements are not configured
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=5 by=ue

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

    Verify in NGAP that QoS flows for 5QIs [4] were successfully released from PDU1 session

Set expected message flow for reestablishment via RRCSetup with A4 measurements installation for UE${ue_id:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Wait until a4supervisionTimer value passes and retryTimer starts
    Sleep    10

Verify expected message flow for reestablishment via RRCSetup with A4 measurements installation for UE${ue_id:\d+}, AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected message flow for reestablishment via RRCSetup without A4 measurements installation for UE${ue_id:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected message flow for reestablishment via RRCSetup without A4 measurements installation for UE${ue_id:\d+}, AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected message flow for reestablishment without A4 measurements installation for UE${ue_id:\d+}, AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected message flow for reestablishment without A4 measurements installation for UE${ue_id:\d+}, AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set RRCReestablishment to be triggered during handover for UE${ue_id:\d+}
    Execute egate command   cmd=ue_gnb_ho_param id=${ue_id} gnb=3 reestab_info=2:valid include_security_config=on
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish gnb=2 cell=2 cause=handoverFailure
    Execute egate command   cmd=gnb_xn_handover_preparation_param id=3 reestab_info=2:valid
    Sleep    1

Set expected message flow for RRCReestablishment during incoming inter-gNB XN based handover for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 5*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected message flow for RRCReestablishment during incoming inter-gNB XN based handover for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 5*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Set expected message flow for RRCReestablishment during incoming inter-gNB NG based handover for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: AMF1 NGAP downlinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 E1AP 4*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify expected message flow for RRCReestablishment during incoming inter-gNB NG based handover for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverNotification
    PASS FLOW[timeout=10]: AMF1 NGAP downlinkRANStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 E1AP 4*bearerContextModification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 5*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete
