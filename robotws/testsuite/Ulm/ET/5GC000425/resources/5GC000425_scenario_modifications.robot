*** Settings ***
Documentation    Scenario specific keywords for 5GC000425-Y subfeatures

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ./../libraries/throughput_analysis.py                WITH NAME   throughput_analysis
Library    Collections
Library    ./../../L2/libraries/ScfChanges.py                   WITH NAME   scf_changes


Resource   ./../../../resources/Common/commissioning.robot

*** Keywords ***

#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}
    log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    RETURN


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    ${test_case_list}=     Get Required Tests for Scenario    scenario_name=${scenario_name}
    IF    'DL_RLC_PDU' in '${test_case_list}[0]' or 'DL_PDCP_SDU' in '${test_case_list}[0]'
    ...    run keyword and continue on failure    Reset EGATE
    IF    'UL_RLC_PDU' in '${test_case_list}[0]'
    ...    run keyword and continue on failure    Kill UE at mme
    sleep    ${traffic_duration}    reason=wait for traffic


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN


#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    ${scf_conent}=  OperatingSystem.Get File    ${original_gnb_scf}
    scf_changes.Load Scf    ${scf_conent}
        Set SW POSTFIX Variable
        Activate 5GC000425 Feature
        Change Reporting Interval  interval_duration=${pm_reporting_interval}
        IF    '${SW_POSTFIX}'=='MMWV_SA'    Workaround for CB008285
    ${scf_changes}  scf_changes.Get Modifications For Commissioning
    commissioning.Commission Managed Object List  managed_objects=${scf_changes}  gnb_id=${0}  skip_parameter_relation_errors=${False}


Perform Commissioning on Classical BTS
    [Arguments]  ${scf_file}
    ${oam_alias}=  connect . Setup OAM http session
    admin . Perform Commissioning    scf_file=${scf_file}
    ...                              connection=${oam_alias}
    ...                              skip_parameter_relation_errors=True
    ...                              timeout=600
    connect . Teardown OAM http session


Activate 5GC000425 Feature
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+                              p_name=nsaInactivityTimer          value=7200
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+                              p_name=actIpThpt                   value=true
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+                p_name=actDl256Qam                 value=false
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+                p_name=actUl256Qam                 value=false
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+                              p_name=actEnhancedLinkAdaptation   value=false
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELLGRP-[0-9]+             p_name=maxDlHarqTx                 value=1
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB_PDCP-[0-9]+        p_name=pdcpBufDiscardEnabled       value=false

Change Reporting Interval
    [Arguments]    ${interval_duration}
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
    ...                                 miNrHighRlcReport     miNrLowRlcReport     miNrMacPduTput     miNrPDCP1Report      miNrPDCP2Report
    ...                                 miNrPDCPCell          miNrRlfPerCell       miNrX2CB           miNrX2CC             miNrX2UInterface
    ...                                 miNrUlHarq            miNrDlHarq           miNrXnCCInterface
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRPMRNL-[0-9]+    p_name=${pname}    value=${interval_duration}
    END


Workaround for CB008285
    [Documentation]  WA for "T300 expiration"
    scf_changes.Add Robot Change    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+    p_name=actRrcReconfigAtBeamSwitch    value=true


Update Basic Configuration File
    RETURN


Kill UE at ${node}
    [Documentation]  ${node} is either "uec" for DL or "mme" for UL
    ${attached_ue_list}=    Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    sort list  ${attached_ue_list}
    sleep  3s
    FOR  ${ue_id}  IN  @{attached_ue_list}
        wts_ue . Send Egate Command and verify output    ue_kill id=${ue_id} at=${node}
    END


Reset Egate
    sleep  5s   reason=Let some User Data being successfully transmitted
    wts_ue . Send Egate Command and verify output    reset
    sleep  3s
    wts_ue . Send Egate Command and verify output    cfg file=basic_setup.cfg
    sleep  30s
    wts_ue . Send Egate Command and verify output    enb_x2_link_up enb=1 target=2


Set SW POSTFIX Variable
    ${ue_type}=    set variable if    'WV SA' in '${SUITE_NAME}'    SA    NSA
    ${SW_POSTFIX}=    set variable    ${SW_WAVELENGTH}_${ue_type}
    set suite variable    ${SW_POSTFIX}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
