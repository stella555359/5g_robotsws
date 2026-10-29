*** Settings ***
Documentation    Scenario specific keywords for CB013392 subfeatures

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                   WITH NAME    wts
Library    ./../../CB013392-E/libraries/CB013392_E_B1_commissioning.py    WITH NAME    e_b1_commissioning
Library    ./../../CB013392-B/configurations/cell_configuration.py        WITH NAME    cell_modifier
Library    ./../../libraries/CB013392_tools.py                            WITH NAME    tools_CB013392

Resource   ./../../../../resources/Common/commissioning.robot
Resource   ./../resources/CB013392_E_KWs.robot


*** Keywords ***


#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}


Run Feature specific keywords before attach
    IF    'E_B1_TC01' in '${TEST NAME}'
    ...    run keyword and continue on failure    E B1 Loop Test Steps


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    sleep    ${traffic_duration}    reason=wait for traffic


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN

#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make necessary changes to SCF
    ${scf_path}=  Get SCF from gNB
    ${scf_content}=  Get File    ${scf_path}
    Log To Console    ${SUITE_NAME} is the current suite name
    cell_modifier.Change_Cell_Settings_for_TMO_in_CB013392_B
    ${commissioning_data}=
    ...   IF    'E B1' in '${SUITE_NAME}'     e_b1_commissioning.Get Data For Commissioning    scf_data=${scf_content}

    commissioning.Commission Managed Object List  ${commissioning_data}  skip_parameter_relation_errors=False


Perform Commissioning on Classical BTS
    [Arguments]  ${scf_file}
    ${oam_alias}=  connect . Setup OAM http session
    admin . Perform Commissioning    scf_file=${scf_file}
    ...                              connection=${oam_alias}
    ...                              skip_parameter_relation_errors=True
    ...                              timeout=600
    connect . Teardown OAM http session


Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
    ...                                 miNrHighRlcReport     miNrLowRlcReport     miNrMacPduTput     miNrPDCP1Report      miNrPDCP2Report
    ...                                 miNrPDCPCell          miNrRlfPerCell       miNrX2CB           miNrX2CC             miNrX2UInterface
    ...                                 miNrUlHarq            miNrDlHarq           miNrXnCCInterface
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm



#-----------For basic_setup.cfg Changes----------------------------------------------------------------------------------------------[150 characters]
Update Basic Configuration File
    wts . Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts . Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
