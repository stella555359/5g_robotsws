*** Settings ***
Documentation    Scenario specific keywords for CB013392 subfeatures

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                   WITH NAME    wts
Library    ./../libraries/CB013392_A_B1_commissioning.py    WITH NAME    a_b1_commissioning
Library    ./../libraries/CB013392_A_B2_commissioning.py    WITH NAME    a_b2_commissioning
Library    ./../libraries/CB013392_A_B3_commissioning.py    WITH NAME    a_b3_commissioning
Library    ./../libraries/CB013392_A_B5_commissioning.py    WITH NAME    a_b5_commissioning
Library    ./../libraries/CB013392_A_B6_commissioning.py    WITH NAME    a_b6_commissioning
Library    ./../configurations/cell_configuration.py        WITH NAME    cell_modifier
Library    ./../../libraries/CB013392_tools.py              WITH NAME    tools_CB013392

Resource   ./../../../../resources/Common/commissioning.robot
Resource   ./../../../../resources/Common/gnb.robot
Resource   ./../resources/CB013392_A_KWs.robot


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
    IF    'A_B1_TC01' in '${scenario_name}'
        Run Keyword And Continue On Failure    A_B1_TC01_Blind_SCell_Addition
    ELSE IF    'A_B1_TC02' in '${scenario_name}'
        Run Keyword And Continue On Failure    A_B1_TC02_Blind_SCell_Addition_incoming_HO
    ELSE IF    'A_B2' in '${TEST NAME}'
        Run Keyword And Continue On Failure    A_B2_TC01_IntragNB_A1_UL_SCell_addition_power_class
    ELSE IF    'A_B3_TC01' in '${TEST NAME}'
        Run Keyword And Continue On Failure    A_B3_TC01_IntragNB_A1_UL_SCell_change_power_class
    ELSE IF    'A_B5' in '${TEST NAME}'
        Run Keyword And Continue On Failure    A_B5_TC01_IntragNB_A2_UL_SCell_release_power_class
    ELSE IF    'A_B6' in '${TEST NAME}'
        Run Keyword And Continue On Failure    A_B6_TC01_power_limitation_with_pMaxNROwnCell_without_CA
    END


Run Feature Specific Keywords After Attach Before Traffic Is Started
    IF    'A_B3_TC02' in '${TEST NAME}'   Run Keyword And Continue On Failure    A B3 Robustness Test Steps


Run Feature Specific Keywords During Traffic Before Detach
    [Arguments]  ${traffic_duration}
    Sleep    ${traffic_duration}    reason=wait for traffic


Run Feature Specific Keywords After Traffic Before Detach
    RETURN


Run Feature Specific Keywords After Detach
    RETURN


#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make Necessary Changes To SCF
    Update Requested RnD Flags In SW Config File
    ${scf_path}=  gnb.Get SCF From gNB
    ${scf_content}=  Get File    ${scf_path}
    Log To Console    ${SUITE_NAME} is the current suite name

    ${commissioning_data}=  IF    'A B1' in '${SUITE_NAME}'   a_b1_commissioning.Get Data For Commissioning     scf_data=${scf_content}
    ...     ELSE IF    'A B2' in '${SUITE_NAME}'              a_b2_commissioning.Get Data For Commissioning     scf_data=${scf_content}
    ...     ELSE IF    'A B3' in '${SUITE_NAME}'              a_b3_commissioning.Get Data For Commissioning     scf_data=${scf_content}
    ...     ELSE IF    'A B5' in '${SUITE_NAME}'              a_b5_commissioning.Get Data For Commissioning     scf_data=${scf_content}
    ...     ELSE IF    'A B6' in '${SUITE_NAME}'              a_b6_commissioning.Get Data For Commissioning     scf_data=${scf_content}
    commissioning.Commission Managed Object List  ${commissioning_data}    skip_parameter_relation_errors=False


A B3 Robustness Test Steps
    FOR   ${ue_id}    IN RANGE    1   4
        # Trigger A1 event to add FDD scell
        tools_CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}

        # Trigger A1 event to add TDD scell
        tools_CB013392.Trigger A1 Tdd Scell Addition  ${ue_id}

    END


Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    gnb.Get DistNames From Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=   Create List  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
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
    Remove Nwslices    # Needed for TMO TLs
    wts.Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}


Remove Nwslices
    FOR  ${id}  IN RANGE   2  21  # numbers from 2 to 20
        wts.Delete    set_nwslice id=${id}
    END


Update Requested RnD Flags In SW Config File
    @{rd_params}=  Create List
    ...    0x5801CB=0     # rdFakeUeSchedulingEnable; disables fakeUe scheduling, to avoid syslog ERR print
    gnb.Update SW Config File On System Module  param_list=${rd_params}