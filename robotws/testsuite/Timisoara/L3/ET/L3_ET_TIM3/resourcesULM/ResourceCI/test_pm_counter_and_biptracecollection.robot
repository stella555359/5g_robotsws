*** Settings ***
Documentation   This Test case is for verifying the functionality
...             of the common keywords for pm counter collection and
...             evaluation as well as for BIP trace collection to save execution time.
...             TODO: Check for simplification of the keyword usage.

Resource    ../ute_workarounds.robot
Resource    ../pmcounters.robot
Resource    ../wts_ue.robot
Resource    ../testline.robot
Resource    ../reporting.robot
Library     OperatingSystem
Library     Collections
Library     gnbtl.py
Library     ../python/PcapAnalysis.py
Library     ../python/BipTraceDissectors.py
Library     ../python/MCSharkDissectors.py
Library     taf.ul.gnb.bip.collection   ${tl}    WITH NAME    bip_collection


Suite Setup     Run Keywords
                ...             UTE Cloud Workaround
                ...     AND     Log To Console    \nBring Airphone TL to on Air status
                ...     AND     Bring Airphone TL to on Air status


*** Test Cases ***
Test PM Counters
    [TAGS]      PM
    Log To Console    \nWait until the next Measurement Period starts
    Wait until the next Measurement Period starts

    Log To Console    \nWait until the current Measurement Period stops
    Wait until the current Measurement Period stops

    Log To Console    \nCollect PM Counter
    ${pm_counter_dir}=    Collect PM Counter
    Log To Console    \nPM Counters stored at ${pm_counter_dir}

    Directory Should Exist    ${pm_counter_dir}
    Directory Should Not Be Empty       ${pm_counter_dir}

    Log   Branch Release should be detected automatically
    ${csv_file}=    Convert PM files to CSV    ${pm_counter_dir}

    File Should Exist    ${csv_file}           msg=Converted PM Counter File - CSV file does not exist!
    File Should Not Be Empty    ${csv_file}    msg=The converted csv pm counter file is empty!

    Set Loglevel   TRACE
    ${expected_pm_counter_list}=    Create List
    ...   M55601C00001  >=  1       Cell Availability denominator
    ...   M55601C00002  >=  1       Samples when the cell is available


    Verify PM Counter Reference Table   pm_dir=${pm_counter_dir}
    ...                                 distname_suffix=1
    ...                                 reference_table=${expected_pm_counter_list}

    Verify PM Counter Reference Table   pm_dir=${pm_counter_dir}
    ...                                 distname_suffix=1
    ...                                 reference_table=${expected_pm_counter_list}

    @{pi_list}=         Create List         M55601C00001   M55601C00002
    ${counter_dict}=    Get Counter Value   pi_dir=${pm_counter_dir}
    ...                                     pi_list=${pi_list}
    ...                                     dist_name=MRBTS-1/NRBTS-1/NRCELL-1

    ${counter_list}=    Get Dictionary Items    ${counter_dict}

    FOR     ${counter}  ${value}    IN  @{counter_list}
        Check PM counter value equal        expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value not equal    not_expected_value=${value+1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value bigger than  expected_value=${value-1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value equal or bigger than  expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value equal or bigger than  expected_value=${value-1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value smaller than  expected_value=${value+1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value equal or smaller than  expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value equal or smaller than  expected_value=${value+1}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        Check PM counter value in range               expected_value=${value}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        ...     abs_tolerance=0  rel_tolerance=0
        Check PM counter value in range               expected_value=${value+2}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        ...     abs_tolerance=2  rel_tolerance=0
        Check PM counter value in range               expected_value=${value-2}
        ...     pm_files_location=${pm_counter_dir}  pi_id=${counter}  moc=MRBTS-1/NRBTS-1/NRCELL-1
        ...     abs_tolerance=2  rel_tolerance=0
    END

Test Collection of Bip Traces
    [TAGS]      BIP   ONLINEREP

    ${bip_trace_list}=   Execute Bip Collection   5 sec
    Analyse the collected bip trace    ${bip_trace_list}
    [Teardown]  Run Keywords
    ...         Report Test Result Without Result Arg
    ...   AND   Report Test Result


*** Keywords ***
Execute Bip Collection
    [Arguments]   ${duration}=1 sec
    ${comu_type}    testline.Get Common Unit Type
    Run Keyword If       '${comu_type}'=='ASIM'    Use Mirror Script

    Start Bip Trace
    Ue Register
    Sleep   ${duration}
    Ue Deregister
    ${bip_trace_list}=   Stop Bip Trace   target_dir=/tmp
    [Return]   ${bip_trace_list}


Analyse the collected bip trace
    [Arguments]    ${bip_trace_list}
    FOR     ${trace}    IN  @{bip_trace_list}
        File Should Not Be Empty    ${trace}    Failure: BIP trace is empty!
    END
    ${gnb_sw_version}=    Get gNB SW version

    Update MCShark Dissector   ${gnb_sw_version}

    ${uldata_prachreceivereq_fields}=   Create Dictionary    prachPrbOffset   UlData_prachReceiveReqSubcell_t.prachPrbOffset

    ${test_data}=    Create Dictionary   uldata_prachreceivereq    ${uldata_prachreceivereq_fields}

    ${bip_trace}=     Get From List   ${bip_trace_list}   0
    ${bip_data}=   Create Analysis Data    pcap_file=${bip_trace}   test_data=${test_data}

    Should Not be Empty   ${bip_data}    BIP Trace is empty - no BIP Trace detected. PrachReceiveReq should be present.
    ${amount_of_prach_reseive_req}=    Get Length    ${bip_data}
    Should Be True     ${amount_of_prach_reseive_req} > 10    Not enouth Prach Receive Reqs found!


Report Test Result
    Online Reporting to ReP   [1]BipTraceCollectionEvaluation
    ...                       tsResult=${TEST_STATUS}
    ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc


Report Test Result Without Result Arg
    Online Reporting to ReP   [1]BipTraceCollectionEvaluation
    ...                       qcFilePath=testsuite/Ulm/resources/Common/ResourceCI/bipcollectionevaluation.qc
