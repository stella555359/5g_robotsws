*** Settings ***
Documentation    Scenario specific keywords for Feature CB008409-B

# imports
Library    ../../../../L2/libraries/template_functions.py    WITH NAME  template
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Variables ***
${legacyBler}             800,800,800,800,800,800,800,100

${target_bler}            100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0           # the first Tx must be realistic to control LA
${retx_target_bler1}      95,95,95,95,95,95,95,95,95,95,95,95,95,95,95       # not a realistic distribution but we need many reTx
${retx_target_bler2}      90,90,90,90,90,90,90,90,90,90,90,90,90,90,90
${retx_target_bler3}      85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
${retx_target_bler4}      95,95,95,95,95,95,95,95,95,95,95,95,95,95,95       # up to now only 3rd reTx is in use
${retx_target_bler5}      95,95,95,95,95,95,95,95,95,95,95,95,95,95,95
${retx_target_bler6}      95,95,95,95,95,95,95,95,95,95,95,95,95,95,95
${retx_target_bler7}      95,95,95,95,95,95,95,95,95,95,95,95,95,95,95
${retx_target_bler8}      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


${target_mcs_rank1}       2
${target_mcs_rank2}       2
${target_mcs_rank3}       2
${target_mcs_rank4}       2
${cqi}              15,15,15,14,14,15,13,15,15,14,14,14,13,15,15,15
${ri}               0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0
${cqi_period_list}  1,1,1,1,1,1,1,1,1,1,1,1,1,4,3,3
${ri_period_list}   1,1,1,1,1,1,1,1,1,1,1,1,1,4,3,3

*** Keywords ***

#-----------For Test Execution -----------------#
Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
   IF  'Dd_TC02_TC03' in '${scenario_name}'
        Set test variable    ${profile_id}    ${2}
        wts_ue.Configure NR BLER testmode  profile_id=${profile_id}  dl_bler=${legacyBler}
        Set test variable    ${BLER_testmode}    bler
   ELSE
        # new adv_bler testmode
        Set test variable    ${profile_id}    ${1}
        wts_ue.Configure NR Advanced BLER testmode  profile_id=${profile_id}  target_bler_profile_id=1
        ...    target_bler=${target_bler}  retx_target_bler1=${retx_target_bler1}  retx_target_bler2=${retx_target_bler2}
        ...    retx_target_bler3=${retx_target_bler3}
        ...    target_mcs=5  rank=1  p_target_bler_profile_id=1
        Set test variable    ${BLER_testmode}    adv_bler
   END


Run Feature specific keywords after attach before traffic is started
    ${attached_ue_list}=    Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    sort list  ${attached_ue_list}
    Set test variable    ${attached_ue_list}
    ${string_attached_ue_list}=    Catenate    SEPARATOR=,    @{attached_ue_list}
    Set test variable    ${string_attached_ue_list}

    ${dict_attached_ue_list_per_cell}=  template.Get_Attach_List_Per_Cell  scenario_name=${scenario_name}  ue_type=all  with_auto_attach=True
    FOR    ${cell_id}    ${ue_ids}    IN    &{dict_attached_ue_list_per_cell}
        ${string_ue_ids}=    Catenate    SEPARATOR=,    @{ue_ids}
        Set Test Variable    ${string_attached_ue_list_per_cell_${cell_id}}    ${string_ue_ids}
    END


    wts_ue.Associate UEs to testmode    ue_id=${string_attached_ue_list}   profile_id=${profile_id}    scell=primary    testmode=${BLER_testmode}
    ...    action=activate


Run Feature specific keywords during traffic before detach
    [Arguments]  @{varargs}

    IF  'online_modify' in '${scenario_name}'
        Sleep    5s
        Execute Online Modification for B14    numTxThreshForPowerBoost=4    powerBoostScalingFactor=11
        ...    scf_name=SCFC_before_FirstOnlineModify    target_scf=SCFC_after_FirstOnlineModify
    END

    IF  'B4' in '${scenario_name}'
        Sleep    8s    #first 8s is only with low voice data for triggering schedule UEs in PS BWP
    #..    start high data rate to trigger schedule UEs in full BandWidth
        Start Kbps Traffic in DL    ue_id=${string_attached_ue_list}    qfi_id=1    trf_id=1    kbps=100
        Start Kbps Traffic in UL    ue_id=${string_attached_ue_list}    qfi_id=1    trf_id=1    kbps=100
    END

    IF  'B12_B13_B16' in '${scenario_name}' or 'Dd_TC02_TC03' in '${scenario_name}'
        Send measurementReport to trigger SRB traffic
    ELSE
        FOR    ${ue}    IN    @{attached_ue_list}
            Send Egate Command and verify output    cmd=ue_rrc_reestablish id=${ue}
            ...    pass_regexp=rrcReconfigurationComplete
            Log to console  ue_rrc_reestablish for UE${ue}
        END
    END


Run Feature specific keywords after traffic before detach
    wts_ue.Associate UEs to testmode    ue_id=${string_attached_ue_list}    profile_id=${profile_id}   scell=primary    testmode=${BLER_testmode}
    ...    action=deactivate


Run Feature specific keywords after detach
    IF  'online_modify' in '${scenario_name}'
    ...    Execute Online Modification For B14    numTxThreshForPowerBoost=2    powerBoostScalingFactor=20
    ...                                           scf_name=SCFC_before_SecondOnlineModify    target_scf=SCFC_after_SecondOnlineModify

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Send measurementReport to trigger SRB traffic
    # this need NRel and Measurement config in SCF
    FOR    ${index}    IN RANGE    ${3}
        Send Egate Command And Verify output
        ...    cmd=ue_measurement_send_nr id=${string_attached_ue_list_per_cell_1} meas_id=1 event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
        Sleep  3.5s    reason=wait command to be executed
        Log To Console  ue_measurement_send_nr id=${string_attached_ue_list_per_cell_1} meas_id=1 event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
        Send Egate Command And Verify output
        ...    cmd=ue_measurement_send_nr id=${string_attached_ue_list_per_cell_3} meas_id=1 event=A3 srsrp_nr=30 phycell_id=52 nrsrp_nr=80
        Sleep  3.5s    reason=wait command to be executed
        Log To Console  ue_measurement_send_nr id=${string_attached_ue_list_per_cell_3} meas_id=1 event=A3 srsrp_nr=30 phycell_id=52 nrsrp_nr=80
        Send Egate Command And Verify output
        ...    cmd=ue_measurement_send_nr id=${string_attached_ue_list_per_cell_1} meas_id=1 event=A3 srsrp_nr=30 phycell_id=51 nrsrp_nr=80
        Sleep  3.5s    reason=wait command to be executed
        Log To Console  ue_measurement_send_nr id=${string_attached_ue_list_per_cell_1} meas_id=1 event=A3 srsrp_nr=30 phycell_id=51 nrsrp_nr=80
        Send Egate Command And Verify output
        ...    cmd=ue_measurement_send_nr id=${string_attached_ue_list_per_cell_3} meas_id=1 event=A3 srsrp_nr=30 phycell_id=53 nrsrp_nr=80
        Sleep  3.5s    reason=wait command to be executed
        Log To Console  ue_measurement_send_nr id=${string_attached_ue_list_per_cell_3} meas_id=1 event=A3 srsrp_nr=30 phycell_id=53 nrsrp_nr=80
     END


Execute Online Modification for B14
    [Arguments]     ${numTxThreshForPowerBoost}    ${powerBoostScalingFactor}    ${scf_name}    ${target_scf}
    ${param1}=    Create Dictionary  value=${numTxThreshForPowerBoost}  dist_name=MRBTS-1/NRBTS-1/NRCELL-3
    ...    p_name=numTxThreshForPowerBoost  list_name=dlRetxPowerBoostCtl
    ${param2}=    Create Dictionary  value=${powerBoostScalingFactor}  dist_name=MRBTS-1/NRBTS-1/NRCELL-3
    ...    p_name=powerBoostScalingFactor  list_name=dlRetxPowerBoostCtl
    ${param_list}=    Create List  ${param1}  ${param2}
    ${target_dir}=    testline.Get Testcase Log Directory
    ${current_gnb_scf}=    gnb.Get SCF from gNB    gnb_id=${0}    target_dir=${configuration_directory}  scf_name=${scf_name}.xml
    ${delta_scf}=    Generate Delta Commissioning File
    ...    parameters_list=${param_list}    scf_path=${current_gnb_scf}    target_local_path=${target_dir}/${target_scf}.xml
    Execute delta commissioning    delta_scf_template=${delta_scf}   resultDir=/tmp/


Start Kbps Traffic in DL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${kbps}  ${seconds}=${EMPTY}
    &{kwargs}=    create dictionary    kbps=${kbps}    pdu=1    qfi=${qfi_id}
    IF    '${seconds}' != '${EMPTY}'   Set To Dictionary    ${kwargs}    seconds    ${seconds}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=dl
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Start Kbps Traffic in UL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${kbps}  ${seconds}=${EMPTY}
    &{kwargs}=    create dictionary    kbps=${kbps}    pdu=1    qfi=${qfi_id}
    IF    '${seconds}' != '${EMPTY}'   Set To Dictionary    ${kwargs}    seconds    ${seconds}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=ul
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}
