*** Settings ***
Documentation    Scenario specific keywords for Feature CB008409-C_scenario_modifications

Resource   ../../../../resources/Common/commissioning.robot

*** Variables ***
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
${target_bler}      50,100,100,100,100,100,80,10,0.5,0,0,0,0,0,0
${target_mcs}       4
${cqi}              5,5,5,4,4,15,3,8,8,0,0,3,3,15,3,3
${ri}               0,0,0,1,1,1,1,0,1,1,0,0,0,0,0,0
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
    ## we need csi already at registration defined defined by TIEL in json work to late
    ${cmd}    Catenate    csi_override_testmode_nr profile_id=3 cqi=${cqi} cqi_mode=varying cqi_period_list=${cqi_period_list}
    ...    ri_mode=varying ri=${ri} ri_period_list=${ri_period_list} pmi=0,1,2,3 pmi_mode=varying pmi_period=1
    Send Egate Command and verify output     cmd=${cmd}

    Send Egate Command and verify output
    ...    cmd=bler_testmode_nr profile_id=3 target_mcs=${target_mcs} target_bler=${target_bler}
    ${attached_ue_list}=    Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    sort list  ${attached_ue_list}
    FOR  ${ue_id}  IN  @{attached_ue_list}
        wts_ue.Associate UEs to testmode    ue_id=${ue_id}    profile_id=3    scell=primary    testmode=csi_override    action=activate
        wts_ue.Associate UEs to testmode    ue_id=${ue_id}    profile_id=3    scell=primary    testmode=bler    action=activate
    END


Run Feature specific keywords after attach before traffic is started
    ${attached_ue_list}=    Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    Set Test Variable  ${attached_ue_list}
    sort list  ${attached_ue_list}


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
	${one_third_traffic_duration}=  Evaluate  ${traffic_duration} / 3
	Sleep  ${one_third_traffic_duration}
    IF  'TC04' in '${scenario_name}'
        Perform HR DRB addition and start of traffic
        Sleep  ${one_third_traffic_duration}
        Perfom stop traffic on HR DRB and delete it
        Sleep  ${one_third_traffic_duration}
    ELSE IF  'TC03' in '${scenario_name}'
        Execute Online Modification for TC03
        Sleep  ${one_third_traffic_duration}
        Recover Online Modification for TC03
    END
    Sleep  ${one_third_traffic_duration}


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
### Additional  5qi=7 is assigned to HR bearer on gnb SCF
Perform HR DRB addition and start of traffic
    FOR  ${ue_id}  IN  @{attached_ue_list}
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
        Log   ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf executed   console=True
        wts_ue . Start data traffic in egate    ue_id=${ue_id}    direction=dl    protocol=udp    ack_mode=off    trf_id=4
        ...    cl_trf_stats=on    mbps=2    pdu=1    qfi=2
        wts_ue . Start data traffic in egate    ue_id=${ue_id}    direction=ul    protocol=udp    ack_mode=off    trf_id=5
        ...    cl_trf_stats=on    mbps=2    pdu=1    qfi=2
    END


Perfom stop traffic on HR DRB and delete it
    FOR  ${ue_id}  IN  @{attached_ue_list}
        wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=dl    trf_id=4
        wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=ul    trf_id=5
        sleep   1s   #and let the last data packets get through before release
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=4 by=amf
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
        Log   ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=4 by=amf executed    console=True
    END
#-------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Execute Online Modification for TC03
    ${param1}=    Create Dictionary  value=3  dist_name=MRBTS-1/NRBTS-1/NRCELL-3  p_name=allowedCqiIncrement  list_name=dlCqiRestriction
    ${param_list}=    Create List  ${param1}
    ${target_dir}=    testline.Get Testcase Log Directory
    ${current_gnb_scf}=    gnb.Get SCF from gNB    gnb_id=${0}    target_dir=${configuration_directory}  scf_name=SCFC_before_OnlineModify.xml
    ${delta_scf}=    Generate Delta Commissioning File
    ...    parameters_list=${param_list}    scf_path=${current_gnb_scf}    target_local_path=${target_dir}/online_scf.xml
    ${starttime_specialphase_TC03}=    DateTime.Get Current Date  UTC
    Set suite variable    ${starttime_specialphase_TC03}
    commissioning.Execute Delta Commissioning    delta_scf_template=${delta_scf}    resultDir=/tmp/    gnb_id=${0}
    ...    skip_parameter_relation_errors=False    timeout=180


Recover Online Modification for TC03
    ${param1}=    Create Dictionary  value=1  dist_name=MRBTS-1/NRBTS-1/NRCELL-3  p_name=allowedCqiIncrement  list_name=dlCqiRestriction
    ${param_list}=    Create List  ${param1}
    ${target_dir}=    testline.Get Testcase Log Directory
    ${current_gnb_scf}=    gnb.Get SCF from gNB    gnb_id=${0}    target_dir=${configuration_directory}  scf_name=SCFC_after_OnlineModify.xml
    ${delta_scf}=    Generate Delta Commissioning File
    ...    parameters_list=${param_list}    scf_path=${current_gnb_scf}    target_local_path=${target_dir}/after_online_scf.xml
    commissioning.Execute Delta Commissioning    delta_scf_template=${delta_scf}    resultDir=/tmp/    gnb_id=${0}
    ...    skip_parameter_relation_errors=False    timeout=180
    ${endtime_specialphase_TC03}=    DateTime.Get Current Date  UTC
    Set suite variable    ${endtime_specialphase_TC03}
