*** Settings ***
Documentation    Scenario specific keywords for CB008127 subfeatures

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    taf.config.wts                                   WITH NAME    wts
Library    ./../libraries/CB013392_C_B1_commissioning.py    WITH NAME    c_b1_commissioning
Library    ./../libraries/CB013392_C_B2_commissioning.py    WITH NAME    c_b2_commissioning
Library    ./../libraries/CB013392_C_B4_commissioning.py    WITH NAME    c_b4_commissioning
Library    ./../libraries/CB013392_C_B7_commissioning.py    WITH NAME    c_b7_commissioning
Library    ./../libraries/CB013392_C_B8_commissioning.py    WITH NAME    c_b8_commissioning
Library    ./../libraries/CB013392_C_B10_commissioning.py   WITH NAME    c_b10_commissioning
Library    ./../configurations/cell_configuration.py        WITH NAME    cell_modifier
Library    ./../../libraries/CB013392_tools.py              WITH NAME    tools_CB013392

Resource   ../../../../resources/Common/commissioning.robot
Resource   ./../resources/CB013392_C_KWs.robot



*** Keywords ***
#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]
Get UE IDs from SingleUE Scenario
    ${attached_ue_list}=    template.Get UE IDs Configured For Scenario    scenario_name=${scenario_name}
    Sort List  ${attached_ue_list}
    ${ue_id}=      Set Variable    ${attached_ue_list}[0]
    Set Test Variable    ${ue_id}


Run Scenario Specific Keywords Before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature Specific Keywords Before Attach
    tools_CB013392.Initialize Egate  # IMPORTANT to have it here
    IF    'C_B7_TC01' in '${scenario_name}'    Run Keyword And Continue On Failure    C B7 TC01 Enable Link To 2nd ENB


Run Feature Specific Keywords After Attach Before Traffic Is Started
    IF    'C_B2_TC01' in '${scenario_name}'    Run Keyword And Continue On Failure    C B2 TC01 Incoming HO
    ...    ELSE IF    'C_B4_TC01' in '${scenario_name}'    Run Keyword And Continue On Failure    C B4 TC01 ENB Initiated Intra ENB HO
    ...    ELSE IF    'C_B7_TC01' in '${scenario_name}'    Run Keyword And Continue On Failure    C B7 TC01 ENB Initiated Inter ENB HO
    ...    ELSE IF    'C_B8_TC01' in '${scenario_name}'    Run Keyword And Continue On Failure    C B8 TC01 Activation After A1
    ...    ELSE IF    'C_B10_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure    C B10 TC01 Wait For A4 Configuration
    ...    ELSE IF    'C_B10_TC02' in '${scenario_name}'   Run Keyword And Continue On Failure    C B10 TC02 Wait And Send A1


Run Feature Specific Keywords During Traffic Before Detach
    [Arguments]  ${traffic_duration}
    Sleep    ${traffic_duration}    reason=Wait for traffic


Run Feature Specific Keywords After Traffic Before Detach
    Get UE IDs from SingleUE Scenario
    IF    'C B01' in '${SUITE_NAME}'    tools_CB013392.Get UE Meas Disp  ue_id=${ue_id}


Run Feature Specific Keywords After Detach
    RETURN



#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]

Make Necessary Changes To SCF
    Save IPHY File
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${scf_path}=  gnb.Get SCF From gNB
    ${scf_content}=  Get File    ${scf_path}
    Log To Console    ${SUITE_NAME} is the current suite name
    IF    'C B8' in '${SUITE_NAME}'   cell_modifier.Change Cell Settings For AEQE

    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${commissioning_data}=
    ...  IF    'C B01' in '${SUITE_NAME}'   c_b1_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...         ELSE IF    'C B2' in '${SUITE_NAME}'    c_b2_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...         ELSE IF    'C B4' in '${SUITE_NAME}'    c_b4_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...         ELSE IF    'C B7' in '${SUITE_NAME}'    c_b7_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...         ELSE IF    'C B8' in '${SUITE_NAME}'    c_b8_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...         ELSE IF    'C B10' in '${SUITE_NAME}'   c_b10_commissioning.Get Data For Commissioning   scf_data=${scf_content}
    commissioning.Commission Managed Object List  ${commissioning_data}  skip_parameter_relation_errors=False


Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    gnb.Get DistNames From Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  Create List  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
    ...                                 miNrHighRlcReport     miNrLowRlcReport     miNrMacPduTput     miNrPDCP1Report      miNrPDCP2Report
    ...                                 miNrPDCPCell          miNrRlfPerCell       miNrX2CB           miNrX2CC             miNrX2UInterface
    ...                                 miNrUlHarq            miNrDlHarq           miNrXnCCInterface
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=     gnb.Get DistNames From Local SCF File  scf_path=${original_gnb_scf}  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.Modify Scf Element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


#-----------For basic_setup.cfg Changes----------------------------------------------------------------------------------------------[150 characters]
Update Basic Configuration File
    wts.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    Modify Basic_setup.cfg For PowerCoordination
    Remove Nwslices    # Needed for TMO TLs
    IF         'C B4' in '${SUITE_NAME}'       Modify Basic_setup For ENB Mobility on TMO
    ...         ELSE IF    'C B7' in '${SUITE_NAME}'       Modify Basic_setup For ENB Mobility On TMO
    wts.Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
