*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO    SANSA_FS_ECPRI_CMWV_FDD+TDD
...             5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...   The aim of the feature is to support  35Mhz Cell BW (FR1-FDD)

Resource         ./resources_keywords.resource

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts_8152_TC22.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               2
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${st_ue_id}            2
${en_ue_id}            2
${value}               0
${file_path}     /opt/iphy/latest/egate_console.log
${trf_id_num}          3
${expected_pcell_thp}    200
${expected_scell_1_thp}    220
${expected_scell_2_thp}    200
${expected_scell_3_thp}    0
${scell_1_lbwp}    36300|sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s28875
${SCFC}=                   Bangalore/RRM/ET/CB008152/CB008152_B_TC22_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008152/CB008152_B_TC22_iphy.xml

*** Test Cases ***
[1]CB008152_B_B2_TC22_DL_CA_3T+1F_1F+3T_with_35MHz_FDD_cell
    [Documentation]      support for 35Mhz Cell BW (FR1-FDD)
    ...                  Cell#1 --> RMOD_4 --> FDD,n25, 35MHz ,PCI:51
    ...                  Cell#3 --> RMOD_1 --> FDD,n71, 35MHz ,PCI:53
    ...                  Cell#4 --> RMOD_3 --> TDD,n41, 10MHz ,PCI:54
    ...                  Cell#5 --> RMOD_3 --> TDD,n41, 50MHz ,PCI:55
    ...                  Cell#6 --> RMOD_2 --> TDD,n77, 40MHz ,PCI:56
    ...                  Cell#7 --> RMOD_2 --> TDD,n77, 40MHz ,PCI:57
    ...                  Cells are up with NRCELL.maxNumSCellsDlFr1 not configured.
    ...                  UE_2 --> Attach to cell#4(TDD) , scell -->Any 2 cells from cell#3,5,6
    ...                  UE_3 --> Attach to cell#1(FDD) , scell --> Any 2 cells from cell#4,5,6
    ...                  Online modification of NRCELL.maxNumSCellsDlFr1 to 3
    ...                  UE_4 --> Attach to cell#4(TDD) , scell --> cell#3,5,6 (FDD,2TDD)  (3T,F)
    ...                  UE_1 --> Attach to cell#1(FDD) , scell --> cell#4,5,6 (3TDD)

    set test variable      ${LOG_PATH}
    Attach SA Ue And Verify Scell Addition With A1 Measurement On High Data Traffic    2    3    ${scell_1_lbwp}
    sleep  20s
    ${varg_expected_thp} =	Create List    1     3    ${expected_pcell_thp}    ${expected_scell_1_thp}
    ...    ${expected_scell_2_thp}     #SA/NSA , noofcc , exp_thp
    Verify DL THP For pcell_scells    2   2    ${varg_expected_thp}
    Start log   ttitrace    biptaf
    sleep   100ms
    Stop Log   ttitrace    biptaf    test_scenario=DL_data_3cc
    Verify UL THP for single cell config     2      0      250
    Detach UE    2    2
    Attach SA Ue And Verify Scell Addition With A1 Measurement On High Data Traffic    3    1    ${scell_1_lbwp}
    sleep   20s
    ${varg_expected_thp} =	Create List    1     3    30    260    205         #SA/NSA , noofcc , exp_thp
    Verify DL THP For pcell_scells    3    3    ${varg_expected_thp}
    Start log   ttitrace    biptaf
    sleep   100ms
    Stop Log   ttitrace    biptaf    test_scenario=DL_data_3cc_2
    Verify UL THP for single cell config     3      0      5
    Detach UE    3    3
    Perform SCF Delta Commissioning with Delta_scf_B_TC22.json
    Attach SA Ue And Verify Scell Addition With A1 Measurement On High Data Traffic    1    3    6325
    sleep  10s
    ${varg_expected_thp} =	Create List    1     4    180    30    245    200     #SA/NSA , noofcc , exp_thp
    Verify DL THP For pcell_scells    1    1    ${varg_expected_thp}
    Verify UL THP for single cell config     1      0      250
    Detach UE    1    1
    Attach SA Ue And Verify Scell Addition With A1 Measurement On High Data Traffic    4    1    24474
    sleep   20s
    ${varg_expected_thp} =	Create List    1     4    30    180    245    200     #SA/NSA , noofcc , exp_thp
    Verify DL THP For pcell_scells    4    4    ${varg_expected_thp}
    Verify UL THP for single cell config     4      0      5
    Detach UE    4    4


*** Keywords ***
Flush Egate UTE
    wtsrunner.sim_log_set    file=egate_output.log


Trigger A1 Measurement and verify Scell added successfully 4CC
    [Arguments]     ${ue_id}    ${meas_id}     ${loc_BW}=
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}     event=A1     srsrp_nr=127      srsrq_nr=127
    ...    ssinr_nr=127
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*activated successfully.*  timeout=15
    Get Lines Matching Regexp    ${output}    CellIndex \\d+ activated successfully  partial_match=${TRUE}
#    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}    locationAndBandwidth\\s${loc_BW}
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s${loc_BW}
    Log to Console    ${output}


Attach SA Ue And Verify Scell Addition With A1 Measurement On High Data Traffic
    [Arguments]     ${ue_id}    ${meas_id}     ${loc_BW}
    log to console   UE attach trigerring now...
    UE Register should be Successful     ue_id=${ue_id}
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 3CC      ${ue_id}
	Trigger A1 Measurement and verify Scell added successfully 4CC    ${ue_id}    ${meas_id}     ${loc_BW}
	MultiUE Trigger UL Traffic for SA    ${ue_id}    ${ue_id}    Traffic_rate=mbps     ul_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}
    MultiUE Trigger UL Traffic for SA    ${ue_id}    ${ue_id}    Traffic_rate=mbps     ul_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=2       qfi_id=${qfi_id}











