*** Settings ***


Documentation
...            CB010790      DU overload handling
...
...            author:        Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com,
...                           Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com
...            maintainer:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...                           Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
...    Save SCF
...    AND        Add Second ENB Cell to WTS Config    wts_delta=${DELTA_WTS_ENB}    wts_out=${WTS_CFG}
...    AND        Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_CFG}    config=${SUITE_CONFIG}    reboot_after_config=yes
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown         Run Keywords
...           Airphone And Gnb Bip Traces Stop 1
...    AND    Test Case Teardown

*** Variables ***
@{IP_ADDR_SIM_GNB}     eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_CNT}           ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_HO}            ${CURDIR}/configs/delta_HO_SA_NSA.json
${DELTA_INACT}         ${CURDIR}/configs/delta_actRrcInactState_MD.json
@{DELTAS}              ${DELTA_CNT}    ${DELTA_HO}    ${DELTA_INACT}
&{SUITE_CONFIG}        delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_WTS_A3_Xn}     ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_ENB}       ${CURDIR}/configs/wts_sim_enb_cell_2.cfg
${WTS_CFG}             ${OUTPUT DIR}/Logs/wts_modified.cfg

@{DCAP_GNB}             condor5gSyslog    cp_5g
@{DCAP_BTS}             scf
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${DELTA_ovlNsaAddRej}                    ${CURDIR}/configs/delta_ovlNsaAddRej_enabled.json
${DELTA_ovlNsaLteHoRej}                  ${CURDIR}/configs/delta_ovlNsaLteHoRej_enabled.json
${DELTA_du_ovlSaRrcRej}                  ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_ovl_disabled}                    ${CURDIR}/configs/delta_ovl_disabled.json
@{DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}    ${DELTA_du_ovlSaRrcRej}    ${DELTA_ovlNsaAddRej}

&{CONFIG_ovlNsaLteHoRej}                 delta=${DELTA_ovlNsaLteHoRej}
&{CONFIG_du_ovlSaRrcRej}                 delta=${DELTA_du_ovlSaRrcRej}
&{CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}    delta=${DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}

${MO_CELL1}                 PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${MO_NRBTS}                 PLMN-PLMN/MRBTS-1/NRBTS-1

*** Test Cases ***


[1]CB010790-C_3_Handling_of_RRC_resume_during_overload_state_detected_by_gNB-CU
    [Tags]     t3
    [Setup]    Run Keywords
    ...           Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_DU_ovlSaRrcRej}

    Wait for Next PM Counters Interval
    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}

    Airphone And Gnb Bip Traces Start 1

    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    @{should_contain}    Create List    UE performed resume procedure
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    ...    pass_regexp=UE.: Is INACTIVE    should_contain=${should_contain}

    Airphone And Gnb Bip Traces Stop 1

    ${ovl_entry_start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${ovl_entry_start_time}
    @{should_contain}    Create List    waitTime.14|waitTime.15|waitTime.16
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    ...    pass_regexp=RRC Reject was received    should_contain=${should_contain}
    ${ovl_exit_start_time}    Get Start Time For PCAP Verification
    ${pm_filepath}    Get Next XML PM Counters File
    Exit Overload State on gNB-CU
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${ovl_exit_start_time}
    Verify Last Counters In File
    ...  M55166C00019  1  SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Test Case Teardown     oam_logs=yes    sosreport=yes


*** Keywords ***

Save SCF
    Log To Console   \nsave default SCF ${OUTPUT DIR}/SCFC.xml
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.Get Current Scf File
    ...    ${OUTPUT DIR}
    ...    SCFC.xml
    ...    timeout=30
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Reload SCF
    Log To Console   \nreload default SCF ${OUTPUT DIR}/SCFC.xml
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.perform commissioning
    ...    scf_file=${OUTPUT DIR}/SCFC.xml
    ...    skip_parameter_relation_errors=True
    ...    timeout=660
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
