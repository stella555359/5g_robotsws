*** Settings ***
Documentation
...            CB010790      DU overload handling
...
...            author:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
...               Add Second ENB Cell to WTS Config    wts_delta=${DELTA_WTS_ENB}    wts_out=${WTS_CFG}
...    AND        Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra NSA Bearer    wts_delta=${DELTA_WTS_DRB}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra UE Caps    wts_delta=${DELTA_WTS_CAPS}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_CFG}    config=${SUITE_CONFIG}    reboot_after_config=yes
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Test Case Teardown

*** Variables ***
@{IP_ADDR_SIM_GNB}     eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_CNT}           ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_HO}            ${CURDIR}/configs/delta_HO_SA_NSA.json
${DELTA_A4}            ${CURDIR}/configs/delta_A4meas.json
${DELTA_BEAM}          ${CURDIR}/configs/delta_beam_rrc.json
@{DELTAS}              ${DELTA_CNT}    ${DELTA_HO}    ${DELTA_A4}    ${DELTA_BEAM}
&{SUITE_CONFIG}        delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_WTS_A3_Xn}     ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_ENB}       ${CURDIR}/configs/wts_sim_enb_cell_2.cfg
${DELTA_WTS_DRB}       ${CURDIR}/configs/wts_nsa_bearer.cfg
${DELTA_WTS_CAPS}      ${CURDIR}/configs/wts_ue_caps.cfg
${WTS_CFG}             ${OUTPUT DIR}/Logs/wts_modified.cfg

@{DCAP_GNB}             condor5gSyslog    cp_5g
@{DCAP_BTS}             scf
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${DELTA_ovl_all}          ${CURDIR}/configs/delta_ovl_all_enabled.json
${DELTA_ovl_disabled}     ${CURDIR}/configs/delta_ovl_disabled.json
${DELTA_du_delay_0}       ${CURDIR}/configs/delta_du_delayRrcOvl_0.json
${DELTA_du_delay_1000}    ${CURDIR}/configs/delta_du_delayRrcOvl_1000.json
&{CONFIG_ovl_all}         delta=${DELTA_ovl_all}

${MO_CELL1}                 PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${MO_NRBTS}                 PLMN-PLMN/MRBTS-1/NRBTS-1

*** Test Cases ***
[1]CB010790-B_18_Handling_overload_state_with_different_delayRrcOvlCountermeasures_values
    [Setup]    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovl_all}
    Upload Delta    delta=${DELTA_du_delay_0}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Enter Overload State on gNB-CU
    Perform Countermeasures Testing
    Stop SA L3 Call    ue_id=1
    Exit Overload State on gNB-CU
    Upload Delta    delta=${DELTA_du_delay_1000}
    Start SA L3 Call    ue_id=1
    Enter Overload State on gNB-CU
    Perform Countermeasures Testing
    Stop SA L3 Call    ue_id=1
    Exit Overload State on gNB-CU
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C00023  2  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  M55125C06001  2  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...  M55124C04503  2  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  M55143C00501  2  XN_SA_HO_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-CU

*** Keywords ***
Perform Countermeasures Testing
    Prepare UE History Information    ue_id=2
    SA UE Register    ue_id=2    pass_regexp=UE.: detached    should_contain=RRC Reject was received    fail_regexp=${None}
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    ...    pass_regexp=PDU Session Resource Setup.*unsuccessful due to misc control processing overload
    Sleep    5s    Wait before next procedure
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Change UE Location    ue_id=2    node_id=3    cell_id=1
    Start SA L3 Call    ue_id=2
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=2    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=2
    Change UE Location    ue_id=2    node_id=2    cell_id=1
