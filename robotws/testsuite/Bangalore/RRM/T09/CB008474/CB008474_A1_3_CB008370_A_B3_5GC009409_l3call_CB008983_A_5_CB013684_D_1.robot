*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO     OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_FDD_65
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation
...  AUTHOR          :   Madhusudhan.y@nokia.com
...  MAINTAINER      :   Madhusudhan.y@nokia.com
...  INTRODUCTION    :   CB008474_Short_PRACH_format_C2_15_kHz_PRACH_SCS__for_FR1_TDD171
...  TEST SET NAME   :   CB008474_A1_3_Multiple_UE_with_PRACH_format_C2_15kHz_SCS_with_4Rx
...  TESTING SPLIT   :   CB008474-A
...  CONTACTS        :   Madhusudhan.y@nokia.com
...  REFERENCES      :   CB008474-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_25058


Suite Setup   Run Keywords        admin.Setup Admin
...                 AND      admin.Get Current SCF File    ${CURDIR}    default_scf.xml   timeout=100s
...                 AND     admin.Teardown Admin

Suite Teardown         Run Keyword and Ignore Error    Get Sos Report

Resource         ./resources/CB008474_Resource.robot
Library          taf.sw.scout    WITH NAME     scout
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../CB008983/resources/CB008983_Resource.robot
Resource         ../CB009409/resources/CB009409_common_resources.robot
#Resource         /home/ute/robotws/testsuite/Bangalore/RRM/T09/CNI-109585/CNI109585_resource.robot
Resource         ../CB013684/CB013684_D_1_NSA_UEs_Successful_CFRA_Rach_Setups_in_different_Beams.robot
Resource         ../CB008370/CB008370-A_B3_TC11_Activation_of_the_feature_with_multiple_UEs.robot
Library          taf.sbts.oam.coam.admin    WITH NAME    admin
Resource         MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot
Library          ta5g_enb
Library          ta5g_pm_counters

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/TMO_basic_setup.cfg
${wts_cfg_file1}        ${CURDIR}/../CB008983/config/basic_setup_MUE.cfg
${wts_cfg_file2}       ${CURDIR}/../CB009409/config/wts/basic_setup_2271_IWK.cfg
${wts_cfg_file3}     ${CURDIR}/../CB013684/config/basic_setup.cfg
${wts_cfg_file4}     ${CURDIR}/../CB008370/config/basic_setup_tc11.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${UE_ID}       1
${QFI_ID1}     1
${TRF_ID1}     1
${Q_O_ADD1}    1
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_ON.csv
${FILTER_B003}    uldata_prachreceiveind || dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq
@{COLUMN_NAME}     3gpp.sfn    3gpp.slot      3gpp.rnti
${st_ue_id}            1
${en_ue_id}            8
${value}               0
${file_path}     /opt/iphy/latest/egate_console.log
${mimolayer}      2
${ss_pbch_power}    10
${overhead}    xOh6
${no_of_ports}    1
${cdm_type}    fd-CDM2
${density}    one
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${sa_st_ue_id}      1
${sa_en_ue_id}      10
${nsa_st_ue_id}      110
${nsa_en_ue_id}      120
${scell_idx}    0
${ul_ue_ip}    72.23.0.1
${dl_ue_ip}    1.2.4.2
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220
${port}    7073
&{Vonr_qos}       2=5    3=1
&{qfi_ids_vonr}        5=2    1=3
&{GBR_qos}        4=2
&{qfi_ids_gbr}    2=2
${start_ue_id_vonr_grb}    6
${end_ue_id_vonr_grb}    20
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_CB008474.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CB008474_Counter_Benchmking_D.xlsx
${AP_XML}            ${CURDIR}/config/SCF/iphy_new.xml

*** Test Cases ***
[1][1]CB008370_A_B3_TC12_Activation_of_the_feature_with_multiple_UEs_rdUseDAfterUForPdcchSharingTdd
    [Tags]   TC05
    [Setup]   Run keywords     Suite setup from scratch
    ...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_TC_11.json
    ...                 AND     5GC000937_Keywords.Check GNB Bulid
    ...                 AND     CB009409_common_resources.Add RadParam to swconfig     "0x58085c=1"      IP=192.168.255.129
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Configure eth3 IP
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_file4}    1    2
    set test variable     ${LOG_PATH}
    CB008370_A_B3_TC12_Activation_of_the_feature_with_multiple_UEs_rdUseDAfterUForPdcchSharingTdd
    [Teardown]    Run Keywords     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...      AND     Stop Default Logging    output_dirpath=${LOG_PATH}
    ...      AND     Link SCOUT SCF to Configuration ID for Reporting
    ...      AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Disable_scf_TC_11.json

[1]5GC009409_L3Call_Validation_With_TCPBoostPUG_FIM_CB002271
    [Tags]   TC01
    [Setup]     Run keywords     Suite setup from scratch
    ...                 AND     CB009409_common_resources.Add RadParam to swconfig     "0x58057f=32"    "0x58057a=3"      IP=192.168.255.129
    ...                 AND     Find Scfc And Send Delta Commissioning     scfc_filename=TC8_CB009409_2271_IWK.json
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     CB009409_common_resources.Check Cell On Air      ${wts_cfg_file2}
    ...                 AND     sleep   10s
    set test variable      ${LOG_PATH}
    MultiUE Register should be Successful with External Trf Type    ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1
    Run Keyword And Continue On Failure  Verify DL Ping Traffic  ${dl_ue_ip}  ${sa_st_ue_id}   ${scell_idx}   ${ping_unit}    ${exp_dl_avg_ping}
    Run Keyword And Continue On Failure  Verify UL Ping Traffic  ${ul_ue_ip}  ${sa_st_ue_id}   ${scell_idx}   ${ping_unit}    ${exp_ul_avg_ping}
    Start Log    btslog
	Multi UE external TCP data
    Sleep    10s
    ${tcpdl_path}    Stop Log        btslog
    Validate AVG DL DATA TRAFFIC in UE STATS    ${sa_st_ue_id}    ${scell_idx}    ${iperf_unit}    ${exp_dl_avg_iperf}
    Stop Iperf Traffic
    Verify TCP PUG elgibility check in syslog        ${tcpdl_path}[btslog]/gnb_syslog.log      ${crnti_list}
    [Teardown]    Run Keywords     Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
    ...    AND       Link SCOUT SCF to Configuration ID for Reporting
    ...    AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...    AND      Prepare TL with SCF change

[1][1.0] CB013684_D_1_NSA_UEs_Successful_CFRA_Rach_Setups_in_different_Beams_2
    [Tags]    TC04
    [Setup]    Run Keywords   Set Suite variable     ${AP_XML}       ${CURDIR}/../CB013684/config/iphy_new.xml
    ...    AND    Suite setup from scratch
    ...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with D1.json
    ...                 AND     Sleep     120s
    ...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with RRC_Inactive_cell2.json
    ...                 AND     Sleep     120s
    ...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with gbr_changes_cell2.json
    ...                 AND     Sleep     120s
    ...                 AND     Prepare TL with IPHY file change
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_file3}   1    2
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    FOR    ${Iter}    IN RANGE    1   2
        Run_CB013684_D_1_NSA    ${Iter}
    END
    [Teardown]   Run Keywords        Link SCOUT SCF to Configuration ID for Reporting
    ...    AND       Check resource hanging
    ...         AND        wts_sim_keywords.Clean edaemon and egate
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
    ...    AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...    AND      Prepare TL with SCF change

[1][1.0] CB008474_A1_3_Multiple_UEs_with_PRACH_format_C2_15kHz_SCS_with_4Rx
    [Tags]    TC02
    [Setup]    Run keywords       Suite setup from scratch
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with MULTILBWP_CHANGES_TMO.json
    ...                 AND    sleep    180s
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with CELL3_FREQ_CHANGES_TMO.json
    ...                 AND    sleep    150s
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with delta_g.json
    ...                 AND    sleep    100s
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with RRC_Inactive.json
    ...                 AND    sleep    100s
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with Vonr_GRB.json
    ...                 AND    sleep    100s
    ...                 AND    Prepare TL with IPHY file change
    ...                 AND    sleep    100s
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with 8474_feature.json
    ...                 AND    sleep    150s
    ...                 AND    Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     wts_sim_keywords.Configure Eth3 IP
    ...                 AND    Load CFG and verify cell status_1   ${wts_cfg_file}    3     3      2
    ...                 AND    sleep    240s
    ...                 AND    Start_capture_testcase_default_logging
    Set test variable      ${LOG_PATH}
    ${TEST_LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${TEST_LOG_PATH}
    log to console   Suite setup successful ...
    Run Keyword and continue on failure    Attach ue and validate bwp switch from large to psbwp    3    3
    Run Keyword and continue on failure    Attach ue with different prach
    Run Keyword and continue on failure    multi UE prach at different cell range
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3



Attach ue with different prach
    Perform Delta-Commissioning to Update Diffrent prachConfigurationIndex To PRACH_format_C2_15_kHz Cell
    Wait until the next Measurement Period starts
    wts_sim_keywords.NSA X2AP Link Should be UP    1     2
    Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell
    Run Keyword And Continue On Failure    Validate PRACH Counters
    Stop Bi-directional Data and Detach SA And NSA UEs

multi UE prach at different cell range
    Attempt Multi-UE PRACH Procedure at Different cell range

Validate PRACH Counters
    Wait For Next Full Pm Interval
    ${pm_counters_8474}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55306C00001     2     RA_ATT_CONT_A_PRMBL_SSB_00
    ...    M55306C03001     2      RA_COMP_CONT_A_PRMBL
    ...    M55306C06001     2       RA_MSG3_RECEP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters_8474}

Load CFG and verify cell status_1
    [Arguments]             ${wts_cfg_file}		${start_cell}	${end_cell}		${enb_id}=2
	wts_sim_keywords.Configure Eth3 IP
	Start wts application and load CFG		${wts_cfg_file}
	sleep    240s
    Wait Until Keyword Succeeds     180s    5s	Verify_sib_mib_for_Cell		${start_cell}	${end_cell}		${enb_id}
    Sleep   20s

Attach ue and validate bwp switch from large to psbwp
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${UE_ID_1}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wts_sim_keywords.UE Register should be Successful     ue_id=${UE_ID_1}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...    traffic_rate=1
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...       traffic_rate=1
    log to console   attach and data trigger complete for all ues ...
    Wait until the next Measurement Period starts
    Run Keyword and continue on failure    Start log  biptaf
    #AP commands to Drop bwp switching DCIs SUE    profile_id=1    num_dci_drop=6     UE_ID=${UE_ID_1}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    log to console    Traffic reduced to kbps ...
    Run Keyword and continue on failure    Stop log   biptaf
    Run Keyword and continue on failure    Validate BWP switch counters
    END

Validate BWP switch counters
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01006    1      INCOM_BWP_SWITCH_CBWP4
    ...    M55351C01007    1      OUTGO_BWP_SWITCH_CBWP1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Verify The Counter DL UL
    [Arguments]    ${DL_rate}    ${UL_rate}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${PM_dir1}=      Get Latest Unpacked Full Pm Counters File
    ${DLG_06}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01006    local_moid=NRCELL-3
    ${DLG_01}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C01001    local_moid=NRCELL-3
    ${DLG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01002    local_moid=NRCELL-3
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DLG_04}=   convert to integer    ${DLG_04}
    ${DL_Primary}    Evaluate    ${DLG_04}+${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*8/300000000
    ${ULG_06}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C03006    local_moid=NRCELL-3
    ${ULG_01}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03001    local_moid=NRCELL-3
    ${ULG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03002    local_moid=NRCELL-3
    ${ULG_06}=   convert to integer    ${ULG_06}
    ${ULG_01}=   convert to integer    ${ULG_01}
    ${ULG_04}=   convert to integer    ${ULG_04}
    ${UL_Primary}    Evaluate    ${ULG_04}+${ULG_06}+${ULG_01}
    ${UL_Primary}    Evaluate    ${UL_Primary}*8/300000000
    Should be True    ${DL_Primary} > ${DL_rate}
    Should be True    ${UL_Primary} > ${UL_rate}

MultiUe MultiDBR registration Should Be Successful
    Register ALL Ues and Send Low data    Start_ue=6    End_ue=36
    Log to console    Adding Vonr Ues
    QosFlow addition should be Successful     6   9      ${Vonr_qos}     ${qfi_ids_vonr}
    QosFlow addition should be Successful     10   14       ${GBR_qos}     ${qfi_ids_gbr}
    Ue RRC Inactive state should be successful    37    40    310    260

Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell
    Register Multiple UEs     start_ue=8   end_ue=9
    Initiate Bi-directional Data to SA
    sleep    10s

Multiple Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell
    wts_sim_keywords.NSA X2AP Link Should be UP    1     2
    Register Multiple UEs     start_ue=10   end_ue=14
    Initiate multi ue Bi-directional Data to SA
    Trigger UE De-Registartion for Multiple UEs    start_ue=10   end_ue=14

Initiate multi ue Bi-directional Data to SA
    Trigger DL Data for SA Multiple UEs   start_ue=10   end_ue=14   Traffic_rate=mbps   data_rate=20
    Trigger UL Data for SA Multiple UEs   start_ue=10   end_ue=14   Traffic_rate=mbps   data_rate=10

Initiate Bi-directional Data to SA
    Trigger DL Data for SA Multiple UEs   start_ue=8   end_ue=9   Traffic_rate=mbps   data_rate=20
    Trigger UL Data for SA Multiple UEs   start_ue=8   end_ue=9   Traffic_rate=mbps   data_rate=10

Initiate multi ue Bi-directional Data to NSA
    Trigger DL Data for NSA Multiple UEs    start_ue=53   end_ue=57   Traffic_rate=mbps   data_rate=20
    Trigger UL Data for NSA Multiple UEs    start_ue=53   end_ue=57   Traffic_rate=mbps   data_rate=10

Initiate Bi-directional Data to NSA
    Trigger DL Data for NSA Multiple UEs    start_ue=51   end_ue=52   Traffic_rate=mbps   data_rate=20
    Trigger UL Data for NSA Multiple UEs    start_ue=51   end_ue=52   Traffic_rate=mbps   data_rate=10

Validate Bi-directional Data of SA And NSA UEs
    sleep    60s
    Validate DL Traffic For MultiUE SA    start_ue_id=8    end_ue_id=9    dl_rate=20
    Validate UL Traffic For MultiUE SA    start_ue_id=8    end_ue_id=9   ul_rate=10

Stop Bi-directional Data and Detach SA And NSA UEs
    Trigger DL Data Stop for SA Multiple UEs    start_ue=8   end_ue=9
    Trigger UL Data Stop for SA Multiple UEs    start_ue=8   end_ue=9
    Trigger UE De-Registartion for Multiple UEs    start_ue=8   end_ue=9

Set E_TA_NR_Profile For Multiple UEs
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=10   end_ue=10    profile_id=1    delay=100
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=11   end_ue=11    profile_id=2    delay=500
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=12   end_ue=12    profile_id=3    delay=700
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=13   end_ue=13    profile_id=4    delay=950

Trigger TA_NRTADV Report For Multiple UEs
    Start log   btslog    cprt
    Trigger TA_NRTADV Report    ue_id=1    trx_id=1
    Trigger TA_NRTADV Report    ue_id=2    trx_id=2
    Trigger TA_NRTADV Report    ue_id=41    trx_id=3
    ${SC3}    Stop log   cprt  btslog   test_scenario=TA_NRTADV

Attempt Multi-UE PRACH Procedure at Different cell range
    Set E_TA_NR_Profile For Multiple UEs
    FOR    ${index}    IN RANGE     5
        log to console    Loop iteration: ${index}
        Multiple Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell
    END

Verify egate and TTI trace
    Verify 1TX config from egate_log     0    ${st_ue_id}    ${en_ue_id}    1
    set test variable      ${crnti_list}
    sleep  10s       reason=Wait for traffic to start
    ${numofLayer}    Create List     RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1
    Log To Console    \nStartingTTICapture
    Capture TTI Traces and Validate numofLayers    ${LOG_PATH}    initial    ${crnti_list}     ${numofLayer}
    Log To Console    \nDoneTTICapture
    Start log    biptaf
    sleep  250ms
    Stop Log    biptaf    test_scenario=DL_UL_datatransfer

Attach Multi Ue and Start Data
    log to console   UE attach trigerring now...
    Start log    btslog    ttitrace    cprt    biptaf
    ${crnti_list}=     WTS_Runner_Keywords.MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    Stop Log   btslog    ttitrace    cprt    biptaf    test_scenario=MUE_attach
    set test variable      ${crnti_list}
    WTS_Runner_Keywords.MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=8
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}
    WTS_Runner_Keywords.MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=15
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}


Validate THP and Dettach UE
    sleep  60s       reason=Wait for traffic to start
    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    65    dl    ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    110    ul    ${st_ue_id}    ${en_ue_id}
    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pusch

    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pdsch
    sleep  3s
    WTS_Runner_Keywords.Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure     WTS_Runner_Keywords.MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Validate CellTHP For SA MultiUE
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${dir}    ${st_ue_id}    ${en_ue_id}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        wtsrunner.bearer_stats  ue=${ue_id}   pdu=1   qfi=1   dir=${dir}
        ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
        ${output}         Get Regexp Matches    ${bearer_stat_dl}    Average data rate +(\\d+)    1
        ${value} =    Evaluate      ${value}+int(${output[0]})
        log to console    Average data rate for UE : ${ue_id} is int(${output[0]})
    END
    ${result}         Evaluate    (${dl_rate} * 1000000 * 1.1) > int(${value}) > (${dl_rate} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${value}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${value}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Multi UE external TCP data
	FOR  ${I}   IN RANGE   ${2}  ${12}
		${port}   evaluate    ${7071}+${I}
		Start TCP Downlink Iperf Data    1.2.4.${I} 	${port}   ${duration}
	END
