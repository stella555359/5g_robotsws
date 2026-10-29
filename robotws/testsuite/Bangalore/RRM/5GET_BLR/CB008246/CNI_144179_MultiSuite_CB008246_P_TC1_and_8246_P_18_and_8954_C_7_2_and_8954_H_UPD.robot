*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_FDD    RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors 8246_P_TC1: Rahul Kumar Singh, rahul.kumar_singh@nokia.com
...              :maintainer 8246_P_TC1: Rahul Kumar Singh, rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      The aim of the Test case is to verify successful IntergNB Handover for HR capable UE
...             TEST SET NAME:     CB008246-P High reliability support for SA, Handover and Re-establishment
...             TESTING SPLIT:     See CB008246-P testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-P CFAM
...
...              :authors 8246_P_18: Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...              :maintainer 8246_P_18: Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:      CB008246 P18 NSA FDD add HR DRB
...             TEST SET NAME:     CB008246-P High reliability DRB release and add High reliability DRB
...             TESTING SPLIT:     See CB008246-P testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-P CFAM
...				Objective: SgNB addition with one or more non-GBR High Reliability DRBs
...				Procedure: Bearer 2 and Bearer 3 is added

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library          ta5g_enb
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd
Library            ../CB008954/python/CB008954_validation.py
Library         ../CB008954/python/increase_buffer_size.py

Suite Teardown   Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
#Suite_1
${SCFC_TC_P1}=        ${CURDIR}/config/SCF/CB008246_P_TC1_IntraGNB_HO_TDD_UDP_scf.xml
${AP_XML_TC_P1}=      ${CURDIR}/config/SCF/CB008246_P_TC1_IntraGNB_HO_TDD_UDP_iphy.xml

${wts_cfg_file_TC_P1}    ${CURDIR}/config/wts/basic_cfg_P_TC1_IntraGNB_HO_TDD_UDP.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TEST_NAME}        test_case
#Suite_2
${SCFC_TC_P18}=        ${CURDIR}/config/SCF/CB008246_P18_NSA_SgnbModification_FDD_scf.xml
${AP_XML_TC_P18}=      ${CURDIR}/config/SCF/CB008246_P18_NSA_SgnbModification_FDD_iphy.xml

${wts_cfg_file_TC_P18}    ${CURDIR}/config/wts/basic_cfg_P18_NSA_SgnbModification_FDD.cfg

${st_ue_id}      1
${en_ue_id}      1
${nsa_st_ue_id}    11
${nsa_en_ue_id}    11
#Suite_3
${wts_cfg_file_TC_8954_C7_2}      ${CURDIR}${/}../CB008954/config/wts/basic_setup_APoABIO_32_UEs_60_80_100.cfg
${IPHY_FILE_TC_8954_C7_2}         ${CURDIR}${/}../CB008954/config/wts/iphy_2cell_8941.xml
${RD_PARAM_8124}     0x420068=6;0x420062=1;0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;0x580587=16;0x580588=16;
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/
${port}     22
#Suite_4
${wts_cfg_file_TC_8954_H_UPD}      ${CURDIR}${/}../CB008954/config/wts/basic_setup_APoABIO_32_UEs_20_80_100_upd_RJIO.cfg
${IPHY_FILE_TC_8954_H_UPD}         ${CURDIR}${/}../CB008954/config/wts/iphy_2cell_upd.xml
${MAX_UE_UL_SCH_SLOT_BWP1}      M55308C28004
${MAX_UE_UL_SCH_SLOT_BWP2}      M55308C28008
${MAX_UE_UL_SCH_SLOT_BWP3}      M55308C00084
${MAX_UE_DL_SCH_SLOT_BWP1}      M55308C28002
${MAX_UE_DL_SCH_SLOT_BWP2}      M55308C28006
${MAX_UE_DL_SCH_SLOT_BWP3}      M55308C00082


*** Test Cases ***
[1][1.0] TC1_P_TDD_HR_DRB_activated_during_IntragNB_HO_with_betaoffset_supported
    [Tags]    TC01
    [Setup]    Run keywords    Suite setup from scratch
    ...                 AND     Configure in VM for RANK-4
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x590004=4  #rdDlMimoLayerCapabilityRadParam
    ...                 AND     Perform SCF Delta Commissioning with Delta_P_TC1_IntraGNB_HO_TDD_UDP.json
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    ...          ${wts_cfg_file_TC_P1}
    ...                 AND     Start Log    btslog
    ...                 AND     Check gNB Bulid

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
    ...         AND        Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND        Stop Log    btslog
    ...                 AND        Link SCOUT SCF to Configuration ID for Reporting

#    Below TC is Removed from Regression
#[1][1.0] TC18_P_NSA_FDD_HR_DRB_activated_during_SgNB_Modification
#   [Tags]  TC02
#    [Setup]    Run keywords   BuiltIn.Set Suite Variable    ${SCFC}
#    ...            ${CURDIR}/config/SCF/CB008246_P18_NSA_SgnbModification_FDD_scf.xml
#    ...     AND    BuiltIn.Set Suite Variable     ${AP_XML}
#    ...            ${CURDIR}/config/SCF/CB008246_P18_NSA_SgnbModification_FDD_iphy.xml
#    ...                 AND     Prepare TL with all config files
#    ...                 AND     Suite setup from scratch
#    ...                 AND     Change dl_ul arfcn in CFG File   ${wts_cfg_file_TC_P18}       349000   431760
#    ...                 AND     gnb.Perform gNB reboot
#    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
#    ...            ${wts_cfg_file_TC_P18}
#    ...                 AND     Start Log    btslog
#    ...                 AND     Check gNB Bulid

#    log to console   UE attach trigerring now...
#    X2AP Link Should be UP
#    start log   cprt
#	${crnti}=      MultiUE Attach for NSA     11    11    1
#    Sgnb Modification to add bearer id 3    11
#    Start traffic for NSA UE    11    2
#    sleep       30s
#    Start traffic for NSA UE    11    3
#    sleep       30s
#    ${path}    Stop log    cprt
#    Validate that the NSA traffic is normal
#    Verify CB008246 Parameters     ${path}[cprt]    nr-rrc.pdsch_Config     nr-rrc.mcs_Table
#    MultiUE Detach for NSA   11   11
#
#    [Teardown]  Run Keywords   Log To console  TCTeardown
#    ...         AND        Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#    ...                 AND        Stop Default Logging    output_dirpath=${LOG_PATH}
#    ...                 AND        Stop Log    btslog      snapshot     sosreport
#    ...                 AND        Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954_C_IWK_7_2_Activation_of_3_BWPs_aligned_at_the_bottom_of_the_5G_cell_with_PRB_blanking_CB009915_CB006878_5GC00937_CB008941_enabled
    [Tags]     TC03
    [Setup]    Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     update_gscn    ${IPHY_FILE_TC_8954_C7_2}    50     7859
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE_TC_8954_C7_2}    frag=${1}
    ...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM_8124}
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                         scfc_filename=both_edge_blank.xml
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    180s
    ...                 AND     Load CFG Config     ${wts_cfg_file_TC_8954_C7_2}
    ...                 AND     Check gNB Bulid

    [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 80,90,100 MHZ

    Start_capture_testcase_default_logging

    ${prbs}    Create List    79    79    160    216
    set test variable      ${LOG_PATH}

    Increase Buffer Size for VM and IPHY
    ${small_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${7}
    MultiUE Trigger UL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     ul_rate=5   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s

    Validate UL Traffic For MultiUE for SA    1  7     5
    Validate DL Traffic For MultiUE for SA    1  7     20

    ${second_bwp_rnti}    MultiUE Register should be Successful     ${8}    ${15}
    MultiUE Trigger UL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     ul_rate=5   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1

    sleep    60s
    Validate UL Traffic For MultiUE for SA    1    15     5
    Validate DL Traffic For MultiUE for SA    1    15     20


    ${large_bwp_rnti}    MultiUE Register should be Successful     ${16}    ${23}
    MultiUE Trigger UL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     ul_rate=5   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     dl_rate=30   pdu_id=1   trf_id=1   qfi_id=1

    sleep    60s
    Validate UL Traffic For MultiUE for SA    16     23     5
    Validate DL Traffic For MultiUE for SA    16     23     30

    sleep    60s
    Start Log         ttitrace
    sleep    1s
    ${scen3}     Stop Log     ttitrace         test_scenario=mix
    Decode TTI Trace   mix
    ${small_bwp_id}    Set variable    ${3}
    ${second_bwp_id}   Set Variable    ${2}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${ps_bwp_id}       Set Variable    ${4}
    ${small_bwp_size}    Set Variable    ${162}
    ${second_bwp_size}    Set Variable    ${217}
    ${large_bwp_size}    Set Variable    ${273}
    ${blanked_prb_lower}    Set Variable    ${25}
    ${blanked_prb_upper}    Set Variable    ${30}
    ${ret}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData
    ...     ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}
    ...     large_bwp_ues=${large_bwp_rnti}
    ...     second_bwp_ues=${second_bwp_rnti}   small_bwp_ues=${small_bwp_rnti}   lower_blanked=${blanked_prb_lower}
    ...     upper_blanked=${blanked_prb_upper}
    should contain    ${ret}     pass
    MultiUE Trigger UL Traffic for SA    ${1}  ${7}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${7}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${8}  ${15}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${8}  ${15}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${16}  ${23}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${16}  ${23}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    # All UE should swicth to PS BWP RNTIs
    ${ps_bwp_rntis}   Combine Lists     ${small_bwp_rnti}    ${second_bwp_rnti}
    ...     ${large_bwp_rnti}
    sleep    60s

    Validate UL Traffic For MultiUE for SA    1    15     0.010
    Validate DL Traffic For MultiUE for SA    1    15     0.010
    Start Log         ttitrace
    sleep    1s
    ${switch}     Stop Log     ttitrace         test_scenario=psbwp
    Decode TTI Trace   psbwp
    ${ret}    validate_bwps    ${switch}[ttitrace]/output_dl_formated.csv    dlFdSchedData
    ...      ${ps_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...      ${106}    ${second_bwp_size}    ${large_bwp_size}
    ...      small_bwp_ues=${ps_bwp_rntis}
    should contain    ${ret}     pass



    MultiUE Trigger UL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     ul_rate=4   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     ul_rate=4   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     ul_rate=4   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1

    sleep    60s


    Validate UL Traffic For MultiUE for SA    1    23     4
    Validate DL Traffic For MultiUE for SA    1    23     20


    Start Log         ttitrace
    sleep    1s
    ${switch1}     Stop Log     ttitrace         test_scenario=psbwp_out
    Decode TTI Trace   psbwp_out

    ${ret}    validate_bwps    ${switch1}[ttitrace]/output_dl_formated.csv    dlFdSchedData
    ...     ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}
    ...     large_bwp_ues=${large_bwp_rnti}
    ...     second_bwp_ues=${second_bwp_rnti}   small_bwp_ues=${small_bwp_rnti}   lower_blanked=${blanked_prb_lower}
    ...     upper_blanked=${blanked_prb_upper}
    should contain    ${ret}     pass

    [Teardown]     Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954_H_UPD001_IWK_CB008238_with_Multiple_UEs_served_with_Three_dedicated_BWPs_dedicated_with_Micro_DTX_optimized_scheduler_for_FR1_TDD
    [Tags]    TC04
    [Setup]    Run keywords   BuiltIn.Set Suite Variable    ${SCFC}
    ...            /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1/scfc.xml
    ...                 AND    BuiltIn.Set Suite Variable     ${AP_XML}
    ...            /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1/iphy.xml
    ...                 AND     Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Update bsr package
    ...                 AND     Perform SCF Delta Commissioning with Cb008954_H_UPD001_RJIO.json
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    180s
    ...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file_TC_8954_H_UPD}
    ...                 AND     Check gNB Bulid

    [Documentation]   This scenario is to verify the DTX with 3 dedicated BWPS 20,80,100 MHZ

    Increase Buffer Size for VM and IPHY
    Wait until the next Measurement Period starts
    ${small_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${1}
    ${second_bwp_rnti}    MultiUE Register should be Successful     ${2}    ${2}
    ${large_bwp_rnti}    MultiUE Register should be Successful     ${3}    ${3}

    MultiUE Trigger UL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1

    Start Log         ttitrace
    sleep    2s
    ${scen3}     Stop Log     ttitrace         test_scenario=mix
    Decode TTI Trace   mix

    ${small_bwp_id}    Set variable    ${2}
    ${second_bwp_id}   Set Variable    ${3}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${51}
    ${second_bwp_size}    Set Variable    ${245}
    ${large_bwp_size}    Set Variable    ${273}
    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData
    ...     ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    large_bwp_ues=${large_bwp_rnti}

    ${rnti_list}=    Combine Lists    ${second_bwp_rnti}    ${large_bwp_rnti}    ${small_bwp_rnti}

    verify_dtx    ${scen3}[ttitrace]/output_dl_formated.csv    ${rnti_list}

    sleep    600s
    ${Counters}    Create Dictionary     ${MAX_UE_UL_SCH_SLOT_BWP1}=${1}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP1}=${1}     ${MAX_UE_UL_SCH_SLOT_BWP2}=${1}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP2}=${1}     ${MAX_UE_DL_SCH_SLOT_BWP3}=${1}
    ...       ${MAX_UE_UL_SCH_SLOT_BWP3}=${1}

    Verify Counters    ${Counters}
    [Teardown]     Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting


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
    MultiUE Trigger DL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps
    ...       dl_rate=20   pdu_id=1      trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps
    ...       ul_rate=10   pdu_id=1      trf_id=1       qfi_id=1

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

#TC_P18_Keywords
Start traffic for NSA UE
    [Arguments]    ${UE_id}    ${bear_id}
    MultiUE DL Traffic Start for NSA     ${UE_id}      ${UE_id}      mbps    10     id=${bear_id}   trf_id=1
    MultiUE UL Traffic Start for NSA     ${UE_id}      ${UE_id}      mbps    10     id=${bear_id}    trf_id=1
    sleep       4s

Sgnb Modification to add bearer id 3
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to add different QCI other than the one added as a default.
    wtsrunner.bearer_add    ue=${UE_ID}  id=3  filter=0  precedence=0
    sleep       5s
    wtsrunner.enb_ue_dc_modify   ue=${UE_ID}  bearer_to_add=3  by=enb  cause=RN_CauseRadioNetwork_unspecified
    ...                          type=split_scg

Validate that the NSA traffic is normal
    log to console   NSA traffic validation ongoing...
    Run keyword and Ignore Error    MultiUE Validate DL Traffic For NSA     11     11    2    10
    Run keyword and Ignore Error    MultiUE Validate UL Traffic For NSA     11     11    2    10
    Run keyword and Ignore Error    MultiUE Validate DL Traffic For NSA     11     11    3    10
    Run keyword and Ignore Error    MultiUE Validate UL Traffic For NSA     11     11    3    10

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Read Dynamic PUSCH
    [Arguments]     ${file}


    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    pscell

    ${longPucchNumPuschPrb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item
    ...                                              endPacket=${1}


    ${longPucchStartPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item
    ...                                              endPacket=${1}


    ${longPucchNumDynPuschPrb}   analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item
    ...                                              endPacket=${1}

    ${longPucchStartDynPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item
    ...                                              endPacket=${1}

    ${longPucchNumDynPuschPrb_ded_ps}      Create List

    ${longPucchStartDynPuschPrb}           Create List

    FOR   ${prb}   IN   @{longPucchStartDynPuschPrb_item}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchStartDynPuschPrb}    ${tmp[1]}
    END

    FOR   ${prb}   IN   @{longPucchNumDynPuschPrb}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchNumDynPuschPrb_ded_ps}    ${tmp[1]}
    END

    set test variable    ${longPucchNumDynPuschPrb_ded_ps}   ${longPucchNumDynPuschPrb_ded_ps}
    set test variable    ${longPucchStartDynPuschPrb}   ${longPucchStartDynPuschPrb}
    set test variable    ${longPucchStartPuschPrb_item}   ${longPucchStartPuschPrb_item}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size    ${AP_ASIK.ip}    ${port}    ${AP_ASIK.username}    ${AP_ASIK.password}

Verify Counters
    [Arguments]  ${counters}
     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     ${counter_ids}=   Get Dictionary Keys    ${counters}
     FOR   ${counter_id}  IN  @{counter_ids}
        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
        Validate PM Counters_pcell_scell_UPD   ${PM_dir_1}   ${counter_id}  ${e_value}
     END

Read Dynamic PUSCH Local
    [Arguments]     ${file}


    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    pscell

    ${longPucchNumPuschPrb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item
    ...                                              endPacket=${1}



    ${longPucchStartPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item
    ...                                              endPacket=${1}


    ${longPucchNumDynPuschPrb}   analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item
    ...                                              endPacket=${1}

    ${longPucchStartDynPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                              packetName=itf_l2_ps_cell_cellsetupreq
    ...                                              path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item
    ...                                              endPacket=${1}

    ${longPucchNumDynPuschPrb_ded_ps}      Create List

    ${longPucchStartDynPuschPrb}           Create List

    FOR   ${prb}   IN   @{longPucchStartDynPuschPrb_item}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchStartDynPuschPrb}    ${tmp[1]}
    END

    FOR   ${prb}   IN   @{longPucchNumDynPuschPrb}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchNumDynPuschPrb_ded_ps}    ${tmp[1]}
    END

    set test variable    ${longPucchNumDynPuschPrb_ded_ps}   ${longPucchNumDynPuschPrb_ded_ps}
    set test variable    ${longPucchStartDynPuschPrb}   ${longPucchStartDynPuschPrb}
    set test variable    ${longPucchStartPuschPrb_item}   ${longPucchStartPuschPrb_item}

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin
