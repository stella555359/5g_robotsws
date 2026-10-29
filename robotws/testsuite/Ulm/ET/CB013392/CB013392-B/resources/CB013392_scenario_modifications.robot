*** Settings ***
Documentation    Scenario specific keywords for CB013392-B subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                   WITH NAME    wts
Library    ./../libraries/CB013392_B_B1_commissioning.py    WITH NAME    b_b1_commissioning
Library    ./../libraries/CB013392_B_B2_commissioning.py    WITH NAME    b_b2_commissioning
Library    ./../libraries/CB013392_B_B3_commissioning.py    WITH NAME    b_b3_commissioning
Library    ./../libraries/CB013392_B_B5_commissioning.py    WITH NAME    b_b5_commissioning
Library    ./../libraries/CB013392_B_B7_commissioning.py    WITH NAME    b_b7_commissioning
Library    ./../libraries/CB013392_B_B8_commissioning.py    WITH NAME    b_b8_commissioning
Library    ./../libraries/CB013392_B_B9_commissioning.py    WITH NAME    b_b9_commissioning
Library    ./../configurations/cell_configuration.py        WITH NAME    cell_modifier
Library    ./../../libraries/CB013392_tools.py              WITH NAME    tools_CB013392

Resource   ./../../../../resources/Common/commissioning.robot
Resource   ./../resources/CB013392_B_KWs.robot
Resource   ./../resources/CB013392_B_Inter_gNB_Setup.robot



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
    IF   'B_B1_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B B1 TC01 Blind SCell Addition Incoming HO
    ...    ELSE IF   'B_B2_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B_B2_TC01_IntragNB_A1_SCell_addition_DL_CA
    ...    ELSE IF   'B_B3_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B_B3_TC01_IntragNB_A1_DL_SCell_change_to_DL_SCell_CA
    ...    ELSE IF   'B_B5_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B_B5_TC01_IntergNB_A1_SCell_addition_DL_CA
    ...    ELSE IF   'B_B6_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B_B6_TC01_IntergNB_A2_SCell_release_DL_CA
    ...    ELSE IF   'B_B7_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B_B7_TC01_IntragNB_A2_SCell_release_DL_CA
    ...    ELSE IF   'B_B8_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B_B8_TC01_IntragNB_A1_partial_SCell_release_3CC_DL_CA
    ...    ELSE IF   'B_B9_TC01' in '${scenario_name}'   Run Keyword And Continue On Failure   B_B9_TC01_IntragNB_A1_ULDL_SCell_change_to_DL_SCell_CA


Run Feature Specific Keywords After Attach Before Traffic Is Started
    log    This is a MANDATORY keywork for the TEAL Framework and is allowed to do NOTHING


Run Feature Specific Keywords During Traffic Before Detach
    [Arguments]  ${traffic_duration}
    sleep    ${traffic_duration}    reason=wait for traffic


Run Feature Specific Keywords After Traffic Before Detach
    log    This is a MANDATORY keywork for the TEAL Framework and is allowed to do NOTHING


Run Feature Specific Keywords After Detach
    log    This is a MANDATORY keywork for the TEAL Framework and is allowed to do NOTHING


#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make Necessary Changes To SCF
    Save IPHY File

    IF    'B B5' in '${SUITE_NAME}' or 'B B6' in '${SUITE_NAME}'    Perform FULL Commissioning In Order To Enable Inter-gNB Functionality

    ${scf_path}=  gnb.Get SCF From gNB
    ${scf_content}=  Get File    ${scf_path}
    Log To Console    ${SUITE_NAME} is the current suite name
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${commissioning_data}=
    ...        IF    'B B1' in '${SUITE_NAME}'    b_b1_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...   ELSE IF    'B B2' in '${SUITE_NAME}'    b_b2_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...   ELSE IF    'B B3' in '${SUITE_NAME}'    b_b3_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...   ELSE IF    'B B5' in '${SUITE_NAME}'    b_b5_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...   ELSE IF    'B B6' in '${SUITE_NAME}'    b_b5_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...   ELSE IF    'B B7' in '${SUITE_NAME}'    b_b7_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...   ELSE IF    'B B8' in '${SUITE_NAME}'    b_b8_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    ...   ELSE IF    'B B9' in '${SUITE_NAME}'    b_b9_commissioning.Get Data For Commissioning    scf_data=${scf_content}
    commissioning.Commission Managed Object List  managed_objects=${commissioning_data}  gnb_id=${0}
    ...    skip_parameter_relation_errors=${False}


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
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    'B B5' in '${SUITE_NAME}' or 'B B6' in '${SUITE_NAME}'    Run Keyword And Continue On Failure    Add Simulated GNB
    Remove Nwslices    # Needed for TMO TLs
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts.Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}


Remove Nwslices
    FOR  ${id}  IN RANGE   2  21  # numbers from 2 to 20
        wts.Delete    set_nwslice id=${id}
    END


#-----------For iphy.xml Changes-----------------------------------------------------------------------------------------------------[150 characters]
Save IPHY File
    ${ap_alias}    connect.Connect To Airphone Common Unit
    ssh.Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/iphy_orig.xml    connection=${ap_alias}
