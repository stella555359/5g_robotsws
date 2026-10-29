*** Variables ***

*** Keywords ***
#Beamforming Keywords
Create Beamforming Profile for association of 2 Beams and activate
    [Arguments]    ${ue_id}=1
    Log to Console    Setting Beamcontrol Test Mode
    wtsrunner.beam_control_testmode_nr     profile_id=1     ueBeamIndexInitial=0,1     ssbeam_bestbeam=0      ssbeam_rsrp_best=-44
    ...   ssbeam_rsrp_avg=-50
    wtsrunner.beam_control_testmode_nr     profile_id=2     ueBeamIndexInitial=1,0     ssbeam_bestbeam=1      ssbeam_rsrp_best=-45
    ...   ssbeam_rsrp_avg=-120
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control     action=activate     profile_id=1     beamaction=attach
    Log to console    UE ${ue_id} beamforming profile is attached

Create Beamforming Profile for association of 4 Beams and activate
    [Arguments]    ${ue_id}=1
    Log to Console    Setting Beamcontrol Test Mode
    wtsrunner.beam_control_testmode_nr     profile_id=1     ueBeamIndexInitial=0,1,2,3     ssbeam_bestbeam=0      ssbeam_rsrp_best=-44
    ...   ssbeam_rsrp_avg=-50
    wtsrunner.beam_control_testmode_nr     profile_id=2     ueBeamIndexInitial=2,0,1,3     ssbeam_bestbeam=2      ssbeam_rsrp_best=-45
    ...   ssbeam_rsrp_avg=-120
    wtsrunner.beam_control_testmode_nr     profile_id=3     ueBeamIndexInitial=3,0,1,2     ssbeam_bestbeam=3      ssbeam_rsrp_best=-50
    ...   ssbeam_rsrp_avg=-125
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control     action=activate     profile_id=1     beamaction=attach
    Log to console    UE ${ue_id} beamforming profile is attached

Create Beamforming Profile for association of 4 Beams and activate MUE
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    Log to Console    Setting Beamcontrol Test Mode
    wtsrunner.beam_control_testmode_nr     profile_id=1     ueBeamIndexInitial=0,1,2,3     ssbeam_bestbeam=0      ssbeam_rsrp_best=-44
    ...   ssbeam_rsrp_avg=-50
    wtsrunner.beam_control_testmode_nr     profile_id=2     ueBeamIndexInitial=2,0,1,3     ssbeam_bestbeam=2      ssbeam_rsrp_best=-45
    ...   ssbeam_rsrp_avg=-120
    wtsrunner.beam_control_testmode_nr     profile_id=3     ueBeamIndexInitial=3,0,1,2     ssbeam_bestbeam=3      ssbeam_rsrp_best=-50
    ...   ssbeam_rsrp_avg=-125
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control     action=activate     profile_id=1     beamaction=attach
    END
    Log to console    UE ${ue_id} beamforming profile is attached

Create Beamforming Profile for association of 8 Beams and activate
    [Arguments]    ${ue_id}=1
    Log to Console    Setting Beamcontrol Test Mode
    wtsrunner.beam_control_testmode_nr     profile_id=1      ueBeamIndexInitial=0,1,2,3,4,5,6,7      ssbeam_bestbeam=0
    ...     ssbeam_rsrp_best=-44     ssbeam_rsrp_avg=-50
    wtsrunner.beam_control_testmode_nr     profile_id=2      ueBeamIndexInitial=1,0,2,3,4,5,6,7      ssbeam_bestbeam=1
    ...     ssbeam_rsrp_best=-45    ssbeam_rsrp_avg=-120
    wtsrunner.beam_control_testmode_nr     profile_id=3      ueBeamIndexInitial=2,0,1,3,4,5,6,7      ssbeam_bestbeam=2
    ...     ssbeam_rsrp_best=-50     ssbeam_rsrp_avg=-125
    wtsrunner.beam_control_testmode_nr     profile_id=4      ueBeamIndexInitial=3,0,1,2,4,5,6,7      ssbeam_bestbeam=3
    ...     ssbeam_rsrp_best=-55     ssbeam_rsrp_avg=-120
    wtsrunner.beam_control_testmode_nr     profile_id=5      ueBeamIndexInitial=4,0,1,2,3,5,6,7      ssbeam_bestbeam=4
    ...     ssbeam_rsrp_best=-60     ssbeam_rsrp_avg=-139
    wtsrunner.beam_control_testmode_nr     profile_id=6      ueBeamIndexInitial=5,0,1,2,3,4,6,7      ssbeam_bestbeam=5
    ...     ssbeam_rsrp_best=-65     ssbeam_rsrp_avg=-70
    wtsrunner.beam_control_testmode_nr     profile_id=7      ueBeamIndexInitial=6,0,1,2,3,4,5,7      ssbeam_bestbeam=6
    ...     ssbeam_rsrp_best=-46     ssbeam_rsrp_avg=-100
    wtsrunner.beam_control_testmode_nr     profile_id=8      ueBeamIndexInitial=7,0,1,3,2,4,5,6      ssbeam_bestbeam=7
    ...     ssbeam_rsrp_best=-48     ssbeam_rsrp_avg=-100
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control     action=activate     profile_id=1     beamaction=attach

Beamcontrol Beam Switch
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=2     ${scell_idx}=0     ${best_beam}=1
    Log to Console    Changing Beam
    wtsrunner.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control      action=activate      profile_id=${beam_profile_id}
    ...      beamaction=switch    scell=${scell_idx}
    Run Keyword and continue on failure    Check best beam     beam_profile_id=${beam_profile_id}    best_beam=${best_beam}

Beamcontrol Beam Recovery
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=1     ${scell_idx}=0     ${best_beam}=0
    Log to Console    Changing Beam
    wtsrunner.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control      action=activate      profile_id=${beam_profile_id}
    ...      beamaction=recovery    scell=${scell_idx}
    Run Keyword and continue on failure    Check best beam      beam_profile_id=${beam_profile_id}       best_beam=${best_beam}

Check best beam
    [Arguments]    ${best_beam}      ${beam_profile_id}=1
    wtsrunner.beam_control_testmode_nr      profile_id=${beam_profile_id}
    ${beam_check}       wtsrunner.read_wtsemu_output_until_re      expected=csirs_sinr_avg   timeout=15
    ${output}         Get Regexp Matches    ${beam_check}    ssbeam_bestbeam +(\\d+)    1
    ${result}        Convert To Number     ${output[0]}
    Should Be Equal As Numbers      ${result}          ${best_beam}

#Beam refinement
Create Beam refinement profile and activate
   [Arguments]    ${ue_id}=1
   Log to Console    Setting Beamcontrol Test Mode for refined beams
   wtsrunner.beam_control_testmode_nr      profile_id=1      ueBeamIndexInitial=0,1     csirs_bestbeam=2      csirs_rsrp_best=-44
   ...    csirs_rsrp_avg=-50
   wtsrunner.beam_control_testmode_nr      profile_id=2      ueBeamIndexInitial=1,0     csirs_bestbeam=5      csirs_rsrp_best=-45
   ...    csirs_rsrp_avg=-120
   wtsrunner.ue_testmode_set_nr     id=${ue_id}    testmode=beam_control     action=activate     profile_id=1      beamaction=attach

Beamcontrol Beam Switch on refined beams
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=2     ${scell_idx}=0     ${best_beam}=5
    Log to Console    Changing Beam
    wtsrunner.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control      action=activate      profile_id=${beam_profile_id}
    ...      beamaction=switch    scell=${scell_idx}
    Run Keyword and continue on failure    Check best beam refined beam     beam_profile_id=${beam_profile_id}    best_beam=${best_beam}

Beamcontrol Beam Recovery to refined beams
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=1     ${scell_idx}=0     ${best_beam}=2
    Log to Console    Changing Beam
    wtsrunner.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control      action=activate      profile_id=${beam_profile_id}
    ...      beamaction=recovery    scell=${scell_idx}
    Run Keyword and continue on failure    Check best beam refined beam      beam_profile_id=${beam_profile_id}       best_beam=${best_beam}

Check best beam refined beam
    [Arguments]    ${best_beam}      ${beam_profile_id}=1
    wtsrunner.beam_control_testmode_nr      profile_id=${beam_profile_id}
    ${beam_check}       wtsrunner.read_wtsemu_output_until_re      expected=csirs_sinr_avg   timeout=15
    ${output}         Get Regexp Matches    ${beam_check}    csirs_bestbeam +(\\d+)    1
    ${result}        Convert To Number     ${output[0]}
    Should Be Equal As Numbers      ${result}          ${best_beam}

#CA keywords
GET UE PDSCH Stats
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Log to Console    ${output}
    should contain    ${output}    Average
    [Return]      ${output}

Get PDSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PDSCH UE stats for given CC
    #Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pdsch    scell=${scell_idx}
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    GET UE PDSCH Stats
    Get Lines Matching Regexp    ${output}    NR PDSCH Throughput    partial_match=${TRUE}
    [Return]      ${output}

Get AVG DL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps
    ${pdsch_ue_stats}    Get PDSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pdsch_ue_stats}    ${unit}
	Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Verify There is No TPUT On Scell
	[Arguments]    ${ue_id}=1    ${scell_idx}=1
	${pdsch_ue_stats}    Get PDSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${pattern}    run    command=re.compile(r'\d')
	${scell_tput}    avg_dl_data.verify_there_is_no_tput_on_scell    ${pdsch_ue_stats}
	Log to Console    ${scell_tput}

#Handover keywords
Establish Xn Link To gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    wtsrunner.gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true
	${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=20
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   30s
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=GNB-${gnb}: XnAP Link with GNB-2   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    GNB-${gnb}: XnAP Link with GNB-2   partial_match=${TRUE}
    Log to Console    ${output}

Get Configured Measurements of UE${ue_id}
    BuiltIn.Log    Get configured Measurements...    console=${True}
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UE${ue_id} NR MEASUREMENT IDENTITIES:   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UE${ue_id} NR MEASUREMENT IDENTITIES:   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ... 	   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=PATH_SWITCH_REQUEST_ACK Received   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    PATH_SWITCH_REQUEST_ACK Received   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A2 Measurement
    [Arguments]     ${ue_id}    ${meas_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}     event=A2     srsrp_nr=7      srsrq_nr=7
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A1 Measurement and verify Scell added successfully
    [Arguments]     ${ue_id}    ${meas_id}     ${loc_BW}=
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}     event=A1     srsrp_nr=80      srsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*activated successfully.*  timeout=15
    Get Lines Matching Regexp    ${output}    CellIndex \\d+ activated successfully  partial_match=${TRUE}
#    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}    locationAndBandwidth\\s${loc_BW}
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s${loc_BW}
    Log to Console    ${output}


Trigger A1 Measurement and verify Scell change successfully
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}    ${loc_BW}=
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A1     srsrp_nr=100      srsrq_nr=40  phycell_id=${phycell_id}
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*activated successfully.*  timeout=15
    Get Lines Matching Regexp    ${output}    CellIndex 2 activated successfully  partial_match=${TRUE}
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s${loc_BW}
    Log to Console    ${output}

Trigger A5 RsrpAndRsrq measurement from real gNB to simulated gNB
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr     id=${ue_id}     meas_id=${meas_id}      event=A5     srsrp_nr=11      srsrq_nr=11
    ...  	phycell_id=${phycell_id}    nrsrp_nr=30      nrsrq_nr=30
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A5 RsrpAndRsrq measurement from simulated gNB to real gNB
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}     meas_id=${meas_id}     event=A5     srsrp_nr=11       srsrq_nr=11
	...     phycell_id=${phycell_id}    nrsrp_nr=30     nrsrq_nr=30
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger Ng A3 RsrpAndRsrq Measurement from real gnb to simulated gNB
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ... 	   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    from EXT_ENB-2.1 to ENB-3.1   partial_match=${TRUE}
    Log to Console    ${output}
