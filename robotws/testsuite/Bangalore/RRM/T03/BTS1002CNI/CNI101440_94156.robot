*** Settings ***
Documentation
...                 Author: sahadeb.ghosh@nokia.com

Resource            ./testsuite/Bangalore/RRM/T03/BTS1002CNI/resources/CB101440_inter_cell_Reestablishment.robot
Resource            ./testsuite/Bangalore/RRM/T03/BTS1002CNI/resources/CNI_94156_RRC_establishment_time.robot
Resource            ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library             Process
Library             String
Library             taf.sw.scout    WITH NAME    scout
Library             ute_reporting_portal
Library             BuiltIn
Library             Collections
Library             taf.collectors.btslog    WITH NAME    btslog
Library             taf.collectors.core    WITH NAME    core
Library             testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

Force Tags          CA_VRF_RRM    SBTS00    QCD_MN_RAN    QCP_RAN_VRF


*** Variables ***
${testline}                                                                                                     10_2_UTE5GCLOUD1002
&{CNI-94156_Verification of SA RRC call setup time in FDD or TDD cell}
...                                                                                                             QC_ID_SBTS00=112494
...                                                                                                             QC_ID_SBTS26R2=112494
...                                                                                                             QC_ID_SBTS26R3=112494
...                                                                                                             QC_ID_SBTS26R4=112494
&{CNI-101440_Verification of monitoring of PCMD records for gNB-DU during inter-cell RRC Re-establishment}
...                                                                                                             QC_ID_SBTS00=112493
...                                                                                                             QC_ID_SBTS26R2=112493
...                                                                                                             QC_ID_SBTS26R3=112493
...                                                                                                             QC_ID_SBTS26R4=112493
${OUTPUT_DIR}                                                                                                   /home/ute/results
${btslog_directory}												/tmp/btslog2

*** Test Cases ***
CNI-101440_Verification of monitoring of PCMD records for gNB-DU during inter-cell RRC Re-establishment
    [Tags]    CA_VRF_RRM    CRT    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    QC_112493
    ${out}    set variable    ${OUTPUT_DIR}/PCMD
    set test variable    ${out}
    OperatingSystem.create directory    ${out}
    Empty Directory    ${out}
    CNI-101440_Verification of monitoring of PCMD records for gNB-DU during inter-cell RRC Re-establishment
    [Teardown]    run keywords    Test Teardown

CNI-94156_Verification of SA RRC call setup time in FDD or TDD cell
    [Tags]    CA_VRF_RRM    CRT    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    QC_112494
    ${out}    set variable    ${OUTPUT_DIR}/RRC_Setup_time
    set test variable    ${out}
    OperatingSystem.create directory    ${out}
    Empty Directory    ${out}
    CNI-94156_Verification of SA RRC call setup time in FDD or TDD cell
    [Teardown]    run keywords    Test Teardown


*** Keywords ***
Suite Setup
    Log To Console    \n-- Suite Setup--\n
    log    suite
    ${rep_values}    Create Dictionary
    set suite variable    ${rep_values}

Suite Teardown
    coam.setup admin    alias=rp
    ${sw_release}    coam.get_sw_release_name    connection=rp
    ${build}    coam.get_sw_version    connection=rp
    coam.teardown_all_aliases_for_admin

Test Setup
    Log to console    \n--Test Setup--\n
    Run keyword And Ignore Error    Empty Directory    ${btslog_directory}
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=${btslog_directory}

    core.setup_collectors    names=btslog
    core.set_suite_alias    btslog
    core.start_collectors    names=btslog

Test Teardown
    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog    target_dir=${out}
    core.teardown_collectors    names=btslog
    coam.teardown_all_aliases_for_admin
    Link SCOUT SCF to Configuration ID
    coam.setup admin    alias=rp
    ${sw_release}    coam.get_sw_release_name    connection=rp
    ${build}    coam.get_sw_version    connection=rp
    coam.teardown_all_aliases_for_admin
#    FOR    ${I}    IN    @{rep_values.keys()}
    ute_reporting_portal.Report To Rp
    ...    name=${TEST NAME}
    ...    result=${TEST STATUS}ED
    ...    ca=VRF_BLR1
    ...    testline=${testline}
    ...    build=${build}
    ...    qc_domain=MN_RAN
    ...    tc_execution_id=${TC_ID}
    ...    qc_project=RAN_VRF
    ...    qc_id=${${TEST NAME}}[QC_ID_${sw_release}]
#    END

Link SCOUT SCF to Configuration ID
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...    Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting
    ...    scout_testline_name=10_2_UTE5GCLOUD1002
    ...    node_id=${0}    node_type=enb
    ...    |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...    |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_type}=gnb    ${tl_name_only}=10_2_UTE5GCLOUD1002

    IF    "${node_type}"=="gnb"
        ${node_type_Name}=    Set Variable    gNB
    ELSE IF    "${node_type}"=="enb"
        ${node_type_Name}=    Set Variable    eNB
    ELSE
        ${node_type_Name}=    Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=    Request Scout SCF    ${scout_testline_name}
    ${TC_ID}=    Set Variable    ${external_scf_id}
    Set Suite Variable    ${TC_ID}
    Set Tags    ${TC_ID}

Request Scout SCF
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Wait Until Keyword Succeeds    2min    10s
    ...    Link SCOUT SCF to Configuration ID for Reporting
    ...    scout_testline_name=10_2_UTE5GCLOUD1002 KW.
    [Arguments]    ${scout_testline_name}
    scout.setup_scout    scout_testline_name=${scout_testline_name}
    ${external_scf_id}=    scout.request_scf    use_scout_internal_id=True
    scout.teardown_scout_api
    RETURN    ${external_scf_id}

