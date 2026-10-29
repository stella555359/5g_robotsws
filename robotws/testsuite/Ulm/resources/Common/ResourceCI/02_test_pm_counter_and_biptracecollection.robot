*** Settings ***
Documentation   This Test case is for verifying the functionality
...             of the common keywords for pm counter collection and
...             evaluation as well as for BIP trace collection to save execution time.
...             TODO: Check for simplification of the keyword usage.


Library     OperatingSystem
Library     Collections

Library     gnbtl.py
Library     ../python/PcapAnalysis.py
Library     ../python/MCSharkDissectors.py

Resource    ../ute_workarounds.robot
Resource    ../pmcounters.robot
Resource    ../wts_ue.robot
Resource    ../testline.robot
Resource    ../reporting.robot
Resource    ../commissioning.robot
Resource    ../gnb.robot
Resource    ../scf_checks.robot
Resource    ../bip_trace.robot


Suite Setup     Run Keywords
                ...             UTE Cloud Workaround
                ...     AND     Set PM Reporting Interval To 5min
                ...     AND     Log To Console    \nBring Airphone TL to on Air status
                ...     AND     Bring Airphone TL To On Air Status Without Reboot

*** Variables ***
${PM_INTERVAL}  5min



*** Test Cases ***
Test PM Counters
    [TAGS]      PM
    Log To Console    \nWait until the next Measurement Period starts
    pmcounters.Wait Until The Next Measurement Period Starts

    Log To Console    \nWait until the current Measurement Period stops
    pmcounters.Wait Until The Current Measurement Period Stops

    ${tc_result_dir}    testline.Get Testcase Log Directory
    Log To Console    \nCollect PM Counter
    ${pm_counter_dir}=    Collect PM Counter   for_last=${PM_INTERVAL}
    Log To Console    \nPM Counters stored at ${pm_counter_dir}
    Set Suite Variable  ${P_pm_counter_dir}  ${pm_counter_dir}

    OperatingSystem.Directory Should Not Be Empty       ${pm_counter_dir}

    Log   Branch Release should be detected automatically
    Set Loglevel   TRACE

    ${expected_pm_counter_list}=    Create List
    ...   M55601C00001  >=  1                       Cell Availability denominator
    ...   M55601C00002  >=  1                       Samples when the cell is available
    ...   M55601C00002  <=  M55601C00001 + 2000     Comprison between counters

    ${M55601C00001_min}=  Set Variable  ${1}
    ${expected_pm_counter_list_dynamic_var}=    Create List
    ...   M55601C00001  >=  ${M55601C00001_min}     Cell Availability denominator
    ...   M55601C00002  >=  1                       Samples when the cell is available
    ...   M55601C00002  <=  M55601C00001 + 2000     Comprison between counters

    ${expected_pm_counter_list_fail_1}=    Create List
    ...   M55601C00001  >=  1                       Cell Availability denominator
    ...   M55601C00002  >=  1                       Samples when the cell is available
    ...   M55601C00002  >=  M55601C00001 + 2000     Comprison between counters

    ${expected_pm_counter_list_fail_2}=    Create List
    ...   M55601C99999  >=  1                       Counter does not exist
    ...   M55601C99998  >=  1                       This counter does not exist also
    ...   M55601C00002  >=  1                       Samples when the cell is available
    ...   M55601C00002  >=  M55601C00001 + 2000     Comprison between counters

    ${expected_pm_counter_list_distnames}=    Create List
    ...   (NRCELL-1)M55601C00001  >=  1                                               Cell Availability denominator
    ...   (NRCELL-1)M55601C00002  >=  1                                               Samples when the cell is available
    ...   (NRCELL-1)M55601C00002  <=  (NRCELL-2)M55601C00001 + 2000                   Comprison between counters
    ...   (MRBTS-1/NRBTS-1/NRCELL-1)M55601C00002  <=  (NRCELL-2)M55601C00001 + 2000   same as above but longer distname

    ${expected_pm_counter_list_unique_counter_id}=    Create List
    ...   M55800C00503  >=  1                       GPS usable satellites average for external GNSS
    ...   M55800C00502  >=  0                       QZSS usable satellites average for external GNSS
    ...   M55800C00501  >=  0                       Galileo usable satellites average for external GNSS

    pmcounters.Verify PM Counter Reference Table   pm_dir=${pm_counter_dir}
    ...                                            distname_suffix=MRBTS-1/NRBTS-1/NRCELL-1
    ...                                            reference_table=${expected_pm_counter_list}

    # test table with variables
    pmcounters.Verify PM Counter Reference Table   pm_dir=${pm_counter_dir}
    ...                                            distname_suffix=MRBTS-1/NRBTS-1/NRCELL-1
    ...                                            reference_table=${expected_pm_counter_list_dynamic_var}

    # test minimal suffix
    pmcounters.Verify PM Counter Reference Table   pm_dir=${pm_counter_dir}
    ...                                            distname_suffix=-1   # to distinguish NRCELL-1 from NRCELL-11
    ...                                            reference_table=${expected_pm_counter_list}

    # table with distnames. Distname suffix no supported in keyword interface
    pmcounters.Verify PM Counter Reference Table  pm_dir=${pm_counter_dir}
    ...                                           reference_table=${expected_pm_counter_list_distnames}

    # table with unique counter ids. No distname suffix given in keyword interface
    pmcounters.Verify PM Counter Reference Table  pm_dir=${pm_counter_dir}
    ...                                           reference_table=${expected_pm_counter_list_unique_counter_id}

    # multiple matches for each counter
    Run Keyword And Expect Error  *  pmcounters.Verify PM Counter Reference Table  pm_dir=${pm_counter_dir}
    ...                                                                            distname_suffix=NRCELL-[123]
    ...                                                                            reference_table=${expected_pm_counter_list}

    # one invalid condition
    Run Keyword And Expect Error  *  pmcounters.Verify PM Counter Reference Table  pm_dir=${pm_counter_dir}
    ...                                                                            distname_suffix=NRCELL-1
    ...                                                                            reference_table=${expected_pm_counter_list_fail_1}

    # two counter IDs not found
    Run Keyword And Expect Error  *  pmcounters.Verify PM Counter Reference Table  pm_dir=${pm_counter_dir}
    ...                                                                            distname_suffix=NRCELL-1
    ...                                                                            reference_table=${expected_pm_counter_list_fail_2}

    @{pi_list}=         Create List         M55601C00001   M55601C00002
    ${counter_dict}=    pmcounters.Get Counter Value   pi_dir=${pm_counter_dir}
    ...                                                pi_list=${pi_list}
    ...                                                dist_name=MRBTS-1/NRBTS-1/NRCELL-1

    ${counter_list}=    Collections.Get Dictionary Items   ${counter_dict}

    FOR     ${counter}  ${value}    IN  @{counter_list}
        pmcounters.Check PM Counter Value Equal        expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value Not Equal    not_expected_value=${value+1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value Bigger Than  expected_value=${value-1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value Equal Or Bigger Than  expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value Equal Or Bigger Than  expected_value=${value-1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value Smaller Than  expected_value=${value+1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value Equal Or Smaller Than  expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value Equal Or Smaller Than  expected_value=${value+1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        pmcounters.Check PM Counter Value In Range               expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        ...     abs_tolerance=0  rel_tolerance=0
        pmcounters.Check PM Counter Value In Range               expected_value=${value+2}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        ...     abs_tolerance=2  rel_tolerance=0
        pmcounters.Check PM Counter Value In Range               expected_value=${value-2}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        ...     abs_tolerance=2  rel_tolerance=0
        &{pi_expected_dict}=   Create Dictionary    ${counter}=${value-2}
        pmcounters.Analyze PM Counters   regex=MRBTS-1\/NRBTS-1\/NRCELL-1   pi_dir=${pm_counter_dir}
        ...     pi_expected=${pi_expected_dict}   index=0   abs_tol=2   rel_tol=0
        &{pi_expected_dict}=   Create Dictionary    ${counter}=${value+2}
        pmcounters.Analyze PM Counters   regex=MRBTS-1\/NRBTS-1\/NRCELL-1   pi_dir=${pm_counter_dir}
        ...     pi_expected=${pi_expected_dict}   index=0   abs_tol=2   rel_tol=0
    END

    ${csv_file}=    pmcounters.Convert PM Files To CSV    ${pm_counter_dir}

    OperatingSystem.File Should Not Be Empty    ${csv_file}   msg=The converted csv pm counter file is empty!


Test PM Counters Using Locally Stored PM Counter Logs
    [TAGS]      PM
    # using counter files taken from test CB008246_D_TC07_DL_DRB_Switch_ALL_New_Related_PM_Counters_TDD
    # counter files stored in repository

    ${CB008246_reference_table}=   Create List
    ...   M55366C00013 / M55308C01000   >   0.2   average number of UEs configured with High Reliability DRB
    ...   M55366C00013 / M55308C01000   <   0.3   average number of UEs configured with High Reliability DRB
    ...   M55366C00014 / M55308C01000   >   0     average number of UEs with High Reliability mode active in DL
    ...   M55366C00014 / M55308C01000   <   0.2   average number of UEs with High Reliability mode active in DL
    ...   M55367C00013 / M55308C01001   >   0.2   average number of UEs with High Reliability mode active in UL
    ...   M55367C00013 / M55308C01001   <   0.3   average number of UEs with High Reliability mode active in UL
    ...   M55367C00013                  in  (1000, 129177, 50000)   new test to verify <in> operation

    # using measurement period before last should pass the test (meas_index=1)
    pmcounters.Verify PM Counter Reference Table   pm_dir=./gnb_pm_counters/
    ...                                            reference_table=${CB008246_reference_table}
    ...                                            distname_suffix=1
    ...                                            meas_index=1

    # using last measurement period (meas_index=0 or not given) should fail
    Run Keyword And Expect Error  *  pmcounters.Verify PM Counter Reference Table   pm_dir=./gnb_pm_counters/
    ...                                                                             reference_table=${CB008246_reference_table}
    ...                                                                             distname_suffix=1
    ...                                                                             meas_index=0


Test Get PM counter value
    [TAGS]      PM
    Log     This Test case must run together with the test above, otherwise the pm file is missing!

    pmcounters.Get PM Counter Value    pm_files_location=${P_pm_counter_dir}
    ...                                pi_id=M55601C00001      moc=NRCELL-1

    Run Keyword And Expect Error   The counter * wasn't found in the last PM report for MO *!
    ...   pmcounters.Get PM Counter Value     pm_files_location=${P_pm_counter_dir}
    ...                                       pi_id=M55601C00001       moc=NRCELL-0


Test Collection of Bip Traces
    [TAGS]      BIP   ONLINEREP

    ${bip_trace_list}=    Execute Bip Collection   5 sec
    Should Not Be Empty   ${bip_trace_list}        Failure: bip_trace_list is empty!
    Analyse The Collected BIP Trace    ${bip_trace_list}
    [Teardown]  Run Keywords
    ...         Report Test Result Without Result Arg
    ...   AND   Report Test Result


*** Keywords ***
Execute Bip Collection
    [Arguments]   ${duration}=1 sec
    ${log_dir}      testline.Get Testcase Log Directory

    ${collector}   bip_trace.Start BIP Traces
    wts_ue.Ue Register
    Sleep   ${duration}
    wts_ue.Ue Deregister
    ${bip_trace_list}   bip_trace.Stop BIP Traces   collector=${collector}   target_dir=${log_dir}
    RETURN   ${bip_trace_list}


Analyse The Collected BIP Trace
    [Arguments]    ${bip_trace_list}
    FOR     ${trace}    IN  @{bip_trace_list}
        OperatingSystem.File Should Not Be Empty    ${trace}    Failure: BIP trace is empty!
    END
    ${gnb_sw_version}=    testline.Get GNB SW Version

    MCSharkDissectors.Update MCShark Dissector   ${gnb_sw_version}

    ${uldata_prachreceivereq_fields}=   Create Dictionary    prachPrbOffset   UlData_prachReceiveReqSubcell_t.prachPrbOffset

    ${test_data}=    Create Dictionary   uldata_prachreceivereq    ${uldata_prachreceivereq_fields}

    ${bip_trace}=    Collections.Get From List   ${bip_trace_list}   0
    ${bip_data}=     PcapAnalysis.Create Analysis Data    pcap_file=${bip_trace}   test_data=${test_data}

    Should Not Be Empty   ${bip_data}    BIP Trace is empty - no BIP Trace detected. PrachReceiveReq should be present.
    ${amount_of_prach_reseive_req}=    Get Length    ${bip_data}
    Should Be True     ${amount_of_prach_reseive_req} > 10    Not enouth Prach Receive Reqs found!


Report Test Result
    reporting.Online Reporting To ReP   [1]BipTraceCollectionEvaluation
    ...                       tsResult=${TEST_STATUS}
    ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc


Report Test Result Without Result Arg
    reporting.Online Reporting To ReP   [1]BipTraceCollectionEvaluation
    ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc


Set PM Reporting Interval To 5min
   ${scf_file}        gnb.Get SCF From GNB
   scf.Load Scf       ${scf_file}
   ${_}            scf.Get Value From SCF   dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1   p_name=reportingIntervalPm
   ${_}            scf.Get Value From SCF   dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1         p_name=miNrGnss

   ${parameter1}   Create Dictionary   value=${PM_INTERVAL}   dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1   p_name=reportingIntervalPm
   ${parameter2}   Create Dictionary   value=${PM_INTERVAL}   dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1         p_name=miNrGnss
   ${parameter3}   Create Dictionary   value=${PM_INTERVAL}   dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1         p_name=miNrCellAvailability
   ${param_list}   Create List   ${parameter1}   ${parameter2}   ${parameter3}

   ${delta_scf}    commissioning.Generate Delta Commissioning File   ${scf_file}   ${param_list}
   commissioning.Execute Delta Commissioning   ${delta_scf}   resultDir=/tmp

