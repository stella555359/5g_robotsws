*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LOO   VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2    SBTS00

Documentation    :copyright: Nokia
...              :author: Marcin Plawny
...              :maintainer: marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_ue_measurements
Library    ta5g_pm_counters
Library    ta5g_testline_management
Library    ta5g_tshark
Library    taf.sbts.oam.coam.admin    WITH NAME   coam
Library    taf.sw.reporting_portal
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_13507.json    skip_relation_errors=False
...            AND             Check Radios Availability
...            AND             Change RD Parameters In Swconfig File
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Update BSR Package
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../scf_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB013507.cfg    mplane_cells=2
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...           AND             Wait For Next Full Pm Interval
Test Teardown    Teardown

*** Test Cases ***
TC01_USCB013507_A_B2_Resolution_enhancement_for_Timing_Advance_measurement_report_in_FDD_FR1
    [Documentation]    This user scenario verifies the resolution enhancement for UL NR E-CID timing advance (Tadv) measurement report
    Run UE Test Loop    ue_id=3    distance=200    fdd=1
    Verify Tshark For E-CID Measurement Initiation Request

    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55113C00013  5  F1_ECID_MEASINIT_REQ
    ...    M55113C00014  5  F1_ECID_MEASINIT_RESP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

TC02_USCB013507_A_B2_Resolution_enhancement_for_Timing_Advance_measurement_report_in_TDD_FR1
    [Documentation]    This user scenario verifies the resolution enhancement for UL NR E-CID timing advance (Tadv) measurement report
    Run UE Test Loop
    Verify Tshark For E-CID Measurement Initiation Request
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55113C00013  5  F1_ECID_MEASINIT_REQ
    ...    M55113C00014  5  F1_ECID_MEASINIT_RESP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

*** Keywords ***
Verify Tshark For E-CID Measurement Initiation Request
    Verify Tshark
    ...    alias=default_tcpdump_alias
    ...    packet_filter=nrppa.procedureCode == 2 && nrppa.measurementQuantitiesValue == "timingAdvanceNR"
    ...    pass_criteria= ==5
    ...    pcap_file_path=default

Change RD Parameters In Swconfig File
    @{13507_rd_params}=    Create List
    ...    0x890073 = 0    #rdEnableCB007208
    Backup And Modify Swconfig File    parameters_list=${13507_rd_params}

Run UE Test Loop
    [Arguments]    ${ue_id}=1    ${number_of_repetitions}=5    ${distance}=100    ${fdd}=0
    FOR    ${i}    IN RANGE    ${number_of_repetitions}
        ${delay}    Evaluate    (${i}+1)*${distance}
        ${delay_adj}    Evaluate    (${i}+1)*${distance}+${fdd}*12
        ${delay_adj-1}    Evaluate    (${i}+1)*${distance}+${fdd}*12-1
        ${delay_adj+1}    Evaluate    (${i}+1)*${distance}+${fdd}*12+1
        Execute Egate Command    cmd=ue_ta_nr profile_id=1 ue_p_delay_initial=${delay}
        Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ta action=activate profile_id=1
        Attach UE    ue_id=${ue_id}
        Establish PDU Session    ue_id=${ue_id}
        ${cmd} =    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1
        ...                     report_characteristics=OnDemand meas_qty=NR_Timing_Advance
        Execute Egate Command    cmd=${cmd}
        Sleep    1
        Deregister UE    ue_id=${ue_id}
        ${filter} =    Catenate    nrppa.procedureCode == 2 &&
        ...                        (nrppa.NR_TADV == ${delay_adj} || nrppa.NR_TADV == ${delay_adj-1} || nrppa.NR_TADV == ${delay_adj+1})
        Verify Tshark
        ...    alias=default_tcpdump_alias
        ...    packet_filter=${filter}
        ...    pass_criteria= ==1
        ...    pcap_file_path=default
    END

Update BSR Package
    Log To Console    BSR package uploading...
    Run    mkdir ${CURDIR}/BSR
    ${dllink}    Set Variable    https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${file}    Set Variable    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run    sudo wget ${dllink}/${file} --user=holowins --password=cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py -P ${CURDIR}/BSR
    coam.Setup Admin
    ${ret}     coam.Update Software    ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.Teardown Admin

Teardown
    Deregister UE Without Confirmation    ue_id=1,3
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Run Keyword If Test Passed    Find Suspicious Logs
    Add Scout Scf Id To Test Data
