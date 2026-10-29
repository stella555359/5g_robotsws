*** Settings ***
Documentation
...               Contact Person: Paweł Wiśniewsi
...               Editor: Wiktor Jarosiński
...               Edit Reason: RobotFramework5.0 Migration
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pdml.py
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot

*** Variables ***
${5G_ID}    ${tl.gnbs[0].instance_id}

*** Keywords ***
Perform commissioning 5GC000534D
    [Arguments]         ${actBeamforming}=true
    ...                 ${basicBeamSet}=beamSet_2
    ...                 ${leftEdgeAngle}=60
    ...                 ${nrBtsBeamRefinementP2}=false
    ...                 ${rightEdgeAngle}=60
    ...                 ${numberOfTransmittedSsBlocks}=2 beams
    ...                 ${chBw}=80MHz

    Log to console      __Perform commissioning with given parameters.
    &{beamSet}       Create dictionary   basicBeamSet=${basicBeamSet}
    ...                                     leftEdgeAngle=${leftEdgeAngle}
    ...                                     nrBtsBeamRefinementP2=${nrBtsBeamRefinementP2}
    ...                                     rightEdgeAngle=${rightEdgeAngle}
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}   Get from list  ${nrbts_dist}   0
    ${cell_dists}       Get cells distname list
    ${nrcellgrp_dists}      Get list of specific object dist name  class_name=NRCELLGRP_A
    Initialise delta store
    FOR    ${cell_dist}    IN    @{cell_dists}
        ${cell_path}     Set variable     ${nrbts_path}/${cell_dist}
        Add param to delta       ${cell_path}         actBeamforming       value=${actBeamforming}
        Add list parameters to delta   ${cell_path}      beamSet      &{beamSet}
        Add param to delta  ${cell_path}      chBw    value=${chBw}
    END
    FOR    ${nrcellgrp_dist}    IN    @{nrcellgrp_dists}
        Add param to delta  ${nrcellgrp_dist}  numberOfTransmittedSsBlocks  value=${numberOfTransmittedSsBlocks}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    600 sec    15 sec    Verify all cells are onair with admin

Verify bip logs beamset 2
    [Arguments]         ${pcap_file_path}
    log to console        __convert pcap to pdml
    Run Keyword And Ignore error  Convert pcap to pdml   ${pcap_file_path}
    ${pdml_file_path}     pdml_path_from_pcap_path  ${pcap_file_path}
    log to console        __beamset_2_checking
    ${beamset2_status}   beamset_2_checking  ${pdml_file_path}
    Run keyword if      ${beamset2_status}
    ...                 Log to console  Beamset_2 pattern has been met in BIP logs
    ...                 ELSE  FAIL  msg=Beamset_2 pattern has not been met

Check dlChBw
    [Arguments]    ${freq}
    Connect with runtime release
    ${1st_c_id}    Get global cell id of first cell
    ${cb}  coam.get_parameters  /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-${5G_ID}/NRCELL_L-${1st_c_id}  connection=coam
    ${band}      Set variable   ${cb['ulChBw']}
    should be equal as strings   ${freq}    ${band}
    [Teardown]    coam.Teardown     connection=coam

Verify bip logs beamset 6
    [Arguments]         ${pcap_file_path}
    log to console        __convert pcap to pdml
    Run Keyword And Ignore error  Convert pcap to pdml   ${pcap_file_path}
    ${pdml_file_path}     pdml_path_from_pcap_path  ${pcap_file_path}
    log to console        __beamset_6_checking
    ${beamset2_status}   beamset_6_checking  ${pdml_file_path}
    Run keyword if      ${beamset2_status}
    ...                 Log to console  Beamset_6 pattern has been met in BIP logs
    ...                 ELSE  FAIL  msg=Beamset_6 pattern has not been met

Verify bip logs sspbch_checking
    [Arguments]         ${pcap_file_path}
    log to console        __convert pcap to pdml
    Run Keyword And Ignore error  Convert pcap to pdml   ${pcap_file_path}
    ${pdml_file_path}     pdml_path_from_pcap_path  ${pcap_file_path}
    log to console        __beamset_2_sspbch_checking
    ${beamset2_status}   beamset_2_sspbch_checking   ${pdml_file_path}
    Run keyword if      ${beamset2_status}
    ...                 Log to console  beamset_2_sspbch_checking pattern has been met in BIP logs
    ...                 ELSE  FAIL  msg=beamset_2_sspbch_checking pattern has not been met

Verify SgNB addition
    [Arguments]         ${pcap_file_path}
    log to console        __convert pcap to pdml
    Run Keyword And Ignore error  Convert pcap to pdml   ${pcap_file_path}
    ${pdml_file_path}     pdml_path_from_pcap_path  ${pcap_file_path}
    log to console        __SgNB_addition_to_NSA_cell_check
    ${beamset_status}   SgNB_addition_to_NSA_cell_check   ${pdml_file_path}
    Run keyword if      ${beamset_status}
    ...                 Log to console  SgNB_addition_to_NSA_cell_chec pattern has been met in pcap logs
    ...                 ELSE  FAIL  msg=SgNB_addition_to_NSA_cell_chec pattern has not been met

Verify bip logs beamset_4_l3call_best_beam_check and l3call_best_beam_check
    [Arguments]         ${pcap_file_path}
    log to console        __convert pcap to pdml
    Run Keyword And Ignore error  Convert pcap to pdml   ${pcap_file_path}
    ${pdml_file_path}     pdml_path_from_pcap_path  ${pcap_file_path}
    log to console        __beamset_4_l3call_best_beam_check
    ${beamset_status}   beamset_4_l3call_best_beam_check   ${pdml_file_path}
#    ${l3call}           l3call_best_beam_check    ${pdml_file_path}   0x01    0x08    0x0f
    Run keyword if      ${beamset_status}
    ...                 Log to console  Pattern has been met in BIP logs
    ...                 ELSE  FAIL  msg=Pattern has not been met

Verify bip logs beamset_6_l3call_best_beam_check and l3call_best_beam_check
    [Arguments]         ${pcap_file_path}
    log to console        __convert pcap to pdml
    Run Keyword And Ignore error  Convert pcap to pdml   ${pcap_file_path}
    ${pdml_file_path}     pdml_path_from_pcap_path  ${pcap_file_path}
    log to console        __beamset_6_l3call_best_beam_check
    ${beamset_status}   beamset_6_l3call_best_beam_check   ${pdml_file_path}
#    ${l3call}           l3call_best_beam_check    ${pdml_file_path}   0x02    0x07    0x11
    Run keyword if      ${beamset_status}  # AND   ${l3call}
    ...                 Log to console  Pattern has been met in BIP logs
    ...                 ELSE  FAIL  msg=Pattern has not been met
