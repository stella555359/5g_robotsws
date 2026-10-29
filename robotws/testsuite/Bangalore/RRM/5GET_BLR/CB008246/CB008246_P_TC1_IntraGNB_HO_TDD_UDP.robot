*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CONFIGS_Bangalore/Bangalore/RRM/ET/CB008246/CB008246_P_TC1_IntraGNB_HO_TDD_UDP.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      The aim of the Test case is to verify successful IntergNB Handover for HR capable UE
...             TEST SET NAME:     CB008246-P High reliability support for SA, Handover and Re-establishment
...             TESTING SPLIT:     See CB008246-P testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-P CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Suite setup from scratch
#...                 AND      Prepare TL with all config files
#...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
...                 AND     Configure in VM for RANK-4
...                 AND     Add RD Parameters To GNB Swconfig File      0x590004=4  #rdDlMimoLayerCapabilityRadParam
...                 AND     Perform SCF Delta Commissioning with Delta_P_TC1_IntraGNB_HO_TDD_UDP.json
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Stop Log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB008246_P_TC1_IntraGNB_HO_TDD_UDP_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB008246_P_TC1_IntraGNB_HO_TDD_UDP_iphy.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg_P_TC1_IntraGNB_HO_TDD_UDP.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}        test_case

*** Test Cases ***
[1][1.0] TC1_P_TDD_HR_DRB_activated_during_IntragNB_HO_with_betaoffset_supported

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    Start traffic for UE   1
    Trigger IntraGnb HO from cell-1 to cell-2    1
    ${path_cprt_cell-1_to_cell-2}    Stop Log      cprt       test_scenario=cprt_cell-1_to_cell-2
    sleep       10s
    Trigger IntraGnb HO from cell-2 to cell-1
    ${path_cprt_cell-2_to_cell-1}    Stop Log      cprt      test_scenario=cprt_cell-2_to_cell-1
    Decode all collected ttitraces
    Verify CB008246 Parameters     ${path_cprt_cell-1_to_cell-2}[cprt]    nr-rrc.pdsch_Config     nr-rrc.mcs_Table
    Verify Beta offset in Egate Log       ${LOG_PATH}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***

Verify Beta offset in Egate Log
    [Arguments]    ${path}
    ${exp_value}     Set Variable      11,11,6,13,139,6,3,11,611,8,6,13,13
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${path}
    Run     cat ${path}/egate_console.log |grep -i 'betaOffsetACK\\|betaOffsetCSI' |awk '{print $1, $2}'
    ${betaoffset}    Run     cat ${path}/egate_console.log |grep -i 'betaOffsetACK\\|betaOffsetCSI' |awk '{print $2}'
    ${betaoffset}    Remove String    ${betaoffset}    \n
    Should Match    ${betaoffset}    ${exp_value}

HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    Start log       cprt
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=4

Start traffic for UE
    [Arguments]    ${UE_id}
    MultiUE Trigger DL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=1       qfi_id=1

Trigger IntraGnb HO from cell-1 to cell-2
    [Arguments]    ${ue_id}=1
    log to console   IntraGnb cell-1 to cell-2 HO trigerring now...
    Start Log      ttitrace
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=3 event=A3   srsrp_nr=30   srsrq_nr=30
    ...       phycell_id=51   nrsrp_nr=40   nrsrq_nr=40
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}
    sleep       3s
    ${path_ttitrace_cell-1_to_cell-2}    Stop log      ttitrace    test_scenario=ttitrace_cell-1_to_cell-2
    [Return]         ${path_ttitrace_cell-1_to_cell-2}

Trigger IntraGnb HO from cell-2 to cell-1
    log to console   IntraGnb cell-2 to cell-1 HO trigerring now...
    Start Log      cprt
    Start Log      ttitrace
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=3 event=A3   srsrp_nr=30   srsrq_nr=30
    ...       phycell_id=50   nrsrp_nr=60   nrsrq_nr=60
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}
    sleep       3s
    ${path_ttitrace_cell-2_to_cell-1}    Stop log      ttitrace    test_scenario=ttitrace_cell-2_to_cell-1
    [Return]         ${path_ttitrace_cell-2_to_cell-1}

Decode all collected ttitraces
    Decode TTI Trace    ttitrace_cell-1_to_cell-2
    sleep       5s
#    Decode TTI Trace    ttitrace_cell-2_to_cell-1
#    sleep       5s


