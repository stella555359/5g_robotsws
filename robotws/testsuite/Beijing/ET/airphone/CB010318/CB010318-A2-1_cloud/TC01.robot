*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh

*** Variables ***
${CMD_OPEN_CP_DEBUG}    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
${BIP_NAME}             5GBipL2L1_filtering_off
${BIP_NAME_COVERT}      5GBipL2L1_filtering_off_filter

*** Keywords ***
10318_TC01
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0,5
    ...    ssbeam_rsrp_best=-44,-48 ssbeam_rsrp_avg=-50
    ${CMD_TESTMODE_ATTACH_1}    Set Variable
    ...    ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_2}    Set Variable
    ...    ue_testmode_set_nr id=2 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_3}    Set Variable
    ...    ue_testmode_set_nr id=3 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_4}    Set Variable
    ...    ue_testmode_set_nr id=4 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_5}    Set Variable
    ...    ue_testmode_set_nr id=5 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_6}    Set Variable
    ...    ue_testmode_set_nr id=6 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_7}    Set Variable
    ...    ue_testmode_set_nr id=7 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_8}    Set Variable
    ...    ue_testmode_set_nr id=8 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_9}    Set Variable
    ...    ue_testmode_set_nr id=9 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_10}    Set Variable
    ...    ue_testmode_set_nr id=10 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_11}    Set Variable
    ...    ue_testmode_set_nr id=11 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_12}    Set Variable
    ...    ue_testmode_set_nr id=12 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_13}    Set Variable
    ...    ue_testmode_set_nr id=13 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_14}    Set Variable
    ...    ue_testmode_set_nr id=14 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_15}    Set Variable
    ...    ue_testmode_set_nr id=15 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_16}    Set Variable
    ...    ue_testmode_set_nr id=16 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_TESTMODE_ATTACH_17}    Set Variable
    ...    ue_testmode_set_nr id=17 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ${CMD_SA_UE_REGISTER_1}    Set Variable
    ...    ue_register id=1
    ${CMD_SA_UE_REGISTER_2}    Set Variable
    ...    ue_register id=2
    ${CMD_SA_UE_REGISTER_3}    Set Variable
    ...    ue_register id=3
    ${CMD_SA_UE_REGISTER_4}    Set Variable
    ...    ue_register id=4
    ${CMD_SA_UE_REGISTER_5}    Set Variable
    ...    ue_register id=5
    ${CMD_SA_UE_REGISTER_6}    Set Variable
    ...    ue_register id=6
    ${CMD_SA_UE_REGISTER_7}    Set Variable
    ...    ue_register id=7
    ${CMD_SA_UE_REGISTER_8}    Set Variable
    ...    ue_register id=8
    ${CMD_SA_UE_REGISTER_9}    Set Variable
    ...    ue_register id=9
    ${CMD_SA_UE_REGISTER_10}    Set Variable
    ...    ue_register id=10
    ${CMD_SA_UE_REGISTER_11}    Set Variable
    ...    ue_register id=11
    ${CMD_SA_UE_REGISTER_12}    Set Variable
    ...    ue_register id=12
    ${CMD_SA_UE_REGISTER_13}    Set Variable
    ...    ue_register id=13
    ${CMD_SA_UE_REGISTER_14}    Set Variable
    ...    ue_register id=14
    ${CMD_SA_UE_REGISTER_15}    Set Variable
    ...    ue_register id=15
    ${CMD_SA_UE_REGISTER_16}    Set Variable
    ...    ue_register id=16
    ${CMD_SA_UE_REGISTER_17}    Set Variable
    ...    ue_register id=17
    ${CMD_PDU_PARAM_1}    Set Variable
    ...    set_pdu_param ue=1 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_2}    Set Variable
    ...    set_pdu_param ue=2 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_3}    Set Variable
    ...    set_pdu_param ue=3 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_4}    Set Variable
    ...    set_pdu_param ue=4 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_5}    Set Variable
    ...    set_pdu_param ue=5 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_6}    Set Variable
    ...    set_pdu_param ue=6 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_7}    Set Variable
    ...    set_pdu_param ue=7 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_8}    Set Variable
    ...    set_pdu_param ue=8 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_9}    Set Variable
    ...    set_pdu_param ue=9 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_10}    Set Variable
    ...    set_pdu_param ue=10 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_11}    Set Variable
    ...    set_pdu_param ue=11 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_12}    Set Variable
    ...    set_pdu_param ue=12 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_13}    Set Variable
    ...    set_pdu_param ue=13 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_14}    Set Variable
    ...    set_pdu_param ue=14 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_15}    Set Variable
    ...    set_pdu_param ue=15 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_16}    Set Variable
    ...    set_pdu_param ue=16 pdu=1 trf_type=internal
    ${CMD_PDU_PARAM_17}    Set Variable
    ...    set_pdu_param ue=17 pdu=1 trf_type=internal
    ${CMD_PDU_SESSION_SETUP_1}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=1 nwslice=1
    ${CMD_PDU_SESSION_SETUP_2}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=2 nwslice=1
    ${CMD_PDU_SESSION_SETUP_3}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=3 nwslice=1
    ${CMD_PDU_SESSION_SETUP_4}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=4 nwslice=1
    ${CMD_PDU_SESSION_SETUP_5}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=5 nwslice=1
    ${CMD_PDU_SESSION_SETUP_6}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=6 nwslice=1
    ${CMD_PDU_SESSION_SETUP_7}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=7 nwslice=1
    ${CMD_PDU_SESSION_SETUP_8}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=8 nwslice=1
    ${CMD_PDU_SESSION_SETUP_9}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=9 nwslice=1
    ${CMD_PDU_SESSION_SETUP_10}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=10 nwslice=1
    ${CMD_PDU_SESSION_SETUP_11}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=11 nwslice=1
    ${CMD_PDU_SESSION_SETUP_12}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=12 nwslice=1
    ${CMD_PDU_SESSION_SETUP_13}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=13 nwslice=1
    ${CMD_PDU_SESSION_SETUP_14}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=14 nwslice=1
    ${CMD_PDU_SESSION_SETUP_15}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=15 nwslice=1
    ${CMD_PDU_SESSION_SETUP_16}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=16 nwslice=1
    ${CMD_PDU_SESSION_SETUP_17}    Set Variable
    ...    ue_pdu_session_setup pdu=1 gw=1 ue=17 nwslice=1
    ${CMD_5QI5_SETUP_1}    Set Variable
    ...    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_2}    Set Variable
    ...    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_3}    Set Variable
    ...    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_4}    Set Variable
    ...    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_5}    Set Variable
    ...    ue_pdu_session_modify ue=5 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_6}    Set Variable
    ...    ue_pdu_session_modify ue=6 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_7}    Set Variable
    ...    ue_pdu_session_modify ue=7 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_8}    Set Variable
    ...    ue_pdu_session_modify ue=8 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_9}    Set Variable
    ...    ue_pdu_session_modify ue=9 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_10}    Set Variable
    ...    ue_pdu_session_modify ue=10 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_11}    Set Variable
    ...    ue_pdu_session_modify ue=11 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_12}    Set Variable
    ...    ue_pdu_session_modify ue=12 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_13}    Set Variable
    ...    ue_pdu_session_modify ue=13 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_14}    Set Variable
    ...    ue_pdu_session_modify ue=14 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_15}    Set Variable
    ...    ue_pdu_session_modify ue=15 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_16}    Set Variable
    ...    ue_pdu_session_modify ue=16 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI5_SETUP_17}    Set Variable
    ...    ue_pdu_session_modify ue=17 pdu=1 qosflows_to_add=2 by=amf
    ${CMD_5QI1_SETUP_1}    Set Variable
    ...    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_2}    Set Variable
    ...    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_3}    Set Variable
    ...    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_4}    Set Variable
    ...    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_5}    Set Variable
    ...    ue_pdu_session_modify ue=5 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_6}    Set Variable
    ...    ue_pdu_session_modify ue=6 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_7}    Set Variable
    ...    ue_pdu_session_modify ue=7 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_8}    Set Variable
    ...    ue_pdu_session_modify ue=8 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_9}    Set Variable
    ...    ue_pdu_session_modify ue=9 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_10}    Set Variable
    ...    ue_pdu_session_modify ue=10 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_11}    Set Variable
    ...    ue_pdu_session_modify ue=11 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_12}    Set Variable
    ...    ue_pdu_session_modify ue=12 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_13}    Set Variable
    ...    ue_pdu_session_modify ue=13 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_14}    Set Variable
    ...    ue_pdu_session_modify ue=14 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_15}    Set Variable
    ...    ue_pdu_session_modify ue=15 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_16}    Set Variable
    ...    ue_pdu_session_modify ue=16 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_5QI1_SETUP_17}    Set Variable
    ...    ue_pdu_session_modify ue=17 pdu=1 qosflows_to_add=3 by=amf
    ${CMD_UL_TRAFFIC_1}    Set Variable
    ...    trf_data_start ue=1 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_2}    Set Variable
    ...    trf_data_start ue=2 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_3}    Set Variable
    ...    trf_data_start ue=3 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_4}    Set Variable
    ...    trf_data_start ue=4 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_5}    Set Variable
    ...    trf_data_start ue=5 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_6}    Set Variable
    ...    trf_data_start ue=6 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_7}    Set Variable
    ...    trf_data_start ue=7 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_8}    Set Variable
    ...    trf_data_start ue=8 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=10
    ${CMD_UL_TRAFFIC_9}    Set Variable
    ...    trf_data_start ue=9 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=1
    ${CMD_UL_TRAFFIC_10}    Set Variable
    ...    trf_data_start ue=10 pdu=1 qfi=3 trf_id=4 burst=1 size=42 kbps=20 dir=ul
    ${CMD_UL_TRAFFIC_11}    Set Variable
    ...    trf_data_start ue=11 pdu=1 qfi=3 trf_id=4 burst=1 size=42 kbps=50 dir=uL
    ${CMD_UL_TRAFFIC_12}    Set Variable
    ...    trf_data_start ue=11 pdu=1 qfi=3 trf_id=4 burst=1 size=42 kbps=70 dir=ul
    ${CMD_UL_TRAFFIC_13}    Set Variable
    ...    trf_data_start ue=13 pdu=1 dir=ul trf_id=2 burst=1 size=42 kbps=1
    ${CMD_UL_TRAFFIC_14}    Set Variable
    ...    trf_data_start ue=14 pdu=1 qfi=3 trf_id=4 burst=1 size=42 kbps=30 dir=ul
    ${CMD_UL_TRAFFIC_15}    Set Variable
    ...    trf_data_start ue=15 pdu=1 qfi=3 trf_id=4 burst=1 size=800 dir=ul
    ${CMD_UL_TRAFFIC_16}    Set Variable
    ...    trf_data_start ue=16 pdu=1 qfi=3 trf_id=4 burst=1 size=1000 dir=ul
    ${CMD_UL_TRAFFIC_17}    Set Variable
    ...    trf_data_start ue=17 pdu=1 qfi=3 trf_id=4 burst=1 size=1400 dir=ul
    ${CMD_UE_DISPLAY}    Set Variable
    ...    ue_disp type=all
    Log To Console    UE Beamforming Profile And Association
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_3}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_4}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_5}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_6}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_7}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_8}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_9}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_10}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_11}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_12}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_13}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_14}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_15}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_16}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_17}
    Sleep    1s
    Log To Console    attach UE1-4
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_1}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_2}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_3}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_4}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_3}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_4}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_3}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_4}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_3}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_4}
    Sleep    1s
    Log To Console    attach UE5-8
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_5}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_6}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_7}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_8}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_5}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_6}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_7}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_8}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_5}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_6}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_7}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_8}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_5}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_6}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_7}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_8}
    Sleep    1s
    Log To Console    attach VONR UE9-12
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_9}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_10}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_11}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_12}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_9}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_10}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_11}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_12}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_9}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_10}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_11}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_12}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_9}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_10}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_11}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_12}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_9}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_10}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_11}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_12}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_9}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_10}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_11}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_12}
    Sleep    1s
    Log To Console    attach VONR UE13-16
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_13}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_14}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_15}
    Sleep    0.5s
    ute_wtssim.Execute Egate Command    cmd=${CMD_SA_UE_REGISTER_16}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_13}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_14}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_15}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_PARAM_16}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_13}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_14}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_15}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PDU_SESSION_SETUP_16}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_13}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_14}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_15}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI5_SETUP_16}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_13}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_14}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_15}
    ute_wtssim.Execute Egate Command    cmd=${CMD_5QI1_SETUP_16}
    Sleep    1s
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_13}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_14}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_15}
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_TRAFFIC_16}
    Sleep    1s
    Log To Console    display all UE connections
    ute_wtssim.Execute Egate Command    cmd=${CMD_UE_DISPLAY}
