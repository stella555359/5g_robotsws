*** Settings ***
Documentation    Scenario specific keywords for CB013392-B subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                       WITH NAME    wts
Library    ../libraries/CB013392_robustness_tools.py            WITH NAME    cni_tools
Library    ../libraries/CB013392_robustness_commissioning.py    WITH NAME    rob_commissioning

Resource   ../../../resources/Common/commissioning.robot


*** Keywords ***
#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario Specific Keywords Before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}


Run Feature Specific Keywords Before Attach
    Log    This is a MANDATORY keywork for the TEAL Framework and is allowed to do NOTHING


Run Feature Specific Keywords After Attach Before Traffic Is Started
    Run Keyword And Continue On Failure    Prepare Variables For Results robustness_scenario
    Run Keyword And Continue On Failure    cni_tools.Trigger A1 Fdd Scell Addition And HOs
    Run Keyword And Continue On Failure    cni_tools.Trigger A2 Scell Release


Run Feature Specific Keywords During Traffic Before Detach
    [Arguments]  ${traffic_duration}
    Sleep    ${traffic_duration}    reason=wait for traffic


Run Feature Specific Keywords After Traffic Before Detach
    RETURN
    Log    This is a MANDATORY keywork for the TEAL Framework and is allowed to do NOTHING


Run Feature Specific Keywords After Detach
    RETURN
    Log    This is a MANDATORY keywork for the TEAL Framework and is allowed to do NOTHING


#-----------Keywords ----------------------------------------------------------------------------------------------------------------[150 characters]
Prepare Variables For Results ${scenario}
    # SA UEs
    ${ue_list}=   Get List Of Attached UEs    ${scenario}    sa
    ${cnt}=       Get Length    ${ue_list}
    ${SA_CA_UES}=    Get Slice From List    ${ue_list}    0    ${cnt/2}    # first 30 SA UEs
    ${SA_HO_UES}=    Get Slice From List    ${ue_list}    ${cnt/2}         # last 30 SA UEs
    Set Test Variable  ${SA_CA_UES}
    Set Test Variable  ${SA_HO_UES}
    # NSA UEs
    ${NSA_HO_UES}=   Get List Of Attached UEs    ${scenario}    nsa
    Set Test Variable  ${NSA_HO_UES}
    cni_tools.Initialize Egate


Get List Of Attached UEs
    [Arguments]  ${scenario_name}  ${sa_nsa}
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=${sa_nsa}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    RETURN    ${attached_ues_list}


#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make Necessary Changes To SCF
    Log To Console    ${SUITE_NAME} is the current suite name
    Save IPHY File
    ${scf_path}=  gnb.Get SCF From gNB
    ${scf_content}=  Get File    ${scf_path}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${commissioning_data}=    rob_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    commissioning.Commission Managed Object List  managed_objects=${commissioning_data}  gnb_id=${0}   skip_parameter_relation_errors=${False}


#-----------For iphy.xml Changes-----------------------------------------------------------------------------------------------------[150 characters]
Save IPHY File
    ${ap_alias}    connect.Connect To Airphone Common Unit
    ssh.Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/iphy_orig.xml    connection=${ap_alias}


Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get DistNames From Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  Create List  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
    ...                                 miNrHighRlcReport     miNrLowRlcReport     miNrMacPduTput     miNrPDCP1Report      miNrPDCP2Report
    ...                                 miNrPDCPCell          miNrRlfPerCell       miNrX2CB           miNrX2CC             miNrX2UInterface
    ...                                 miNrUlHarq            miNrDlHarq           miNrXnCCInterface
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=     Get DistNames From Local SCF File  scf_path=${original_gnb_scf}  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


#-----------For basic_setup.cfg Changes----------------------------------------------------------------------------------------------[150 characters]
Update Basic Configuration File
    wts.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    Remove Nwslices
    Adapt Tracing        # too many traces can crash egate, see PR848714
    Change MeNB Power Coordination
    wts.Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}


Remove Nwslices
    FOR  ${id}  IN RANGE   2  21  # numbers from 2 to 20
        wts.Delete    set_nwslice id=${id}
    END


Adapt Tracing
    # ${change}  set variable  earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off proxy=$DAEMON_IP:12221
    wts.Modify  trace uec=1 protocol=rrc on          modification=protocol=rrc off
    wts.Modify  trace uec=1 protocol=nr_rrc on       modification=protocol=nr_rrc off
    wts.Modify  sim_trace uec=1 protocol=nr_rrc on   modification=protocol=nr_rrc off
    wts.Modify  sim_trace uec=1 protocol=all on      modification=protocol=all off


Change MeNB Power Coordination
    ${NSA_HO_UES}=   Get List Of Attached UEs    robustness_scenario    nsa
    ${nsa_count}=    Get Length  ${NSA_HO_UES}
    ${nsa_ues_used}=    Evaluate    101+${nsa_count}
    FOR  ${id}  IN RANGE   101  ${nsa_ues_used}
        wts.Insert    ue_enb_endc_param id=${id} p_max_nr=23 p_max_eutra=23    after    set_bearer
    END