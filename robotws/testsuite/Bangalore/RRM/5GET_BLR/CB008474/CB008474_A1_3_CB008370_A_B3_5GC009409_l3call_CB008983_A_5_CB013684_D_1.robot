*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO      OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
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
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB008983/resources/CB008983_Resource.robot
Resource         ../CB009409/resources/CB009409_common_resources.robot
Resource         ../CB013684/CB013684_D_1_NSA_UEs_Successful_CFRA_Rach_Setups_in_different_Beams.robot
Resource         ../CB008370/CB008370-A_B3_TC11_Activation_of_the_feature_with_multiple_UEs.robot
Library          taf.sbts.oam.coam.admin    WITH NAME    admin
Resource         MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_8474.lua
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

[1]CB013684_D_1_NSA_UEs_Successful_CFRA_Rach_Setups_in_different_Beams
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
    [Setup]    Run keywords        BuiltIn.Set Suite Variable     ${AP_XML}       ${CURDIR}/config/SCF/iphy_MP_APLO_2RU.xml
#   ...                 AND   Prepare TL with all config files
    ...                 AND    Suite setup from scratch
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with CB008474_GMC.json
    ...                 AND     Sleep     120s
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with gbr_changes.json
    ...                 AND     Sleep     120s
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with RRC_Inactive_8474.json
    ...                 AND     Sleep     120s
    ...                 AND     Prepare TL with IPHY file change
    ...                 AND    Load CFG and verify cell status   ${wts_cfg_file}    1    2
    ...                 AND    5GC000937_Keywords.Check gNB Bulid
    ...                 AND    sleep    240s
    ...                 AND    Start_capture_testcase_default_logging
    Set test variable      ${LOG_PATH}
    ${SW_VERSION_TOTAL}  Set Variable      ${GNB_SW_VERSION}
    Set Suite Variable    ${SW_VERSION_TOTAL}
    log to console   Suite setup successful ...
    wts_sim_keywords.NSA X2AP Link Should be UP    1     2
    ${SC1}    Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell    test_scenario=UEs_Attach1
    Initiate Bi-directional Data to SA And NSA UEs
    Stop Bi-directional Data and Detach SA And NSA UEs
    Perform Delta-Commissioning to Update Diffrent prachConfigurationIndex To PRACH_format_C2_15_kHz Cell
    Wait until the next Measurement Period starts
    ${SC2}    Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell    test_scenario=UEs_Attach2
    Initiate Bi-directional Data to SA And NSA UEs
    Run Keyword And Continue On Failure    Validate PRACH Counters
    Stop Bi-directional Data and Detach SA And NSA UEs
    Attempt Multi-UE PRACH Procedure at Different cell range     test_scenario=UEs_Attach3
    Start_Fetching_Counter_Values
    MultiUe MultiDBR registration Should Be Successful
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    15    30    Traffic_rate=mbps   dl_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    Sleep   30s
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    15    30    Traffic_rate=mbps   ul_rate=1   pdu_id=1
	...    trf_id=1   qfi_id=1
    MultiUe_MultiDRB_Wrapper_Keyword.Start Multi UE DL traffic with multiple trafficID     start_ue=31   end_ue=36
    ...    Traffic_rate=mbps    dl_trf_id=1    qfi_id=1    dl_rate_DL=170
    MultiUe_MultiDRB_Wrapper_Keyword.Start Multi UE UL traffic with multiple trafficID     start_ue=31   end_ue=36
    ...    Traffic_rate=mbps    ul_trf_id=1    qfi_id=1    ul_rate_UL=100
    Verify The Counter DL UL    0    0
    Stop_Fetching_Counter_Values
    Run Keyword And Continue On Failure    Collect_Counter_Logs      ${host}     ${user}      ${password}
    ...     ${target_dir}    ${counter_json_file}         ${git_path}



    [Teardown]    Run keywords    wts_sim_keywords.Clean edaemon and egate
    ...       AND      Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
#    ...             AND     run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
#    ...             AND     run keyword if test failed    Run Keyword and Ignore Error    Get Sos Report
    ...             AND       Check resource hanging
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
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
    ${DLG_06}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01006    local_moid=NRCELL-1
    ${DLG_01}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C01001    local_moid=NRCELL-1
    ${DLG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01002    local_moid=NRCELL-1
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DLG_04}=   convert to integer    ${DLG_04}
    ${DL_Primary}    Evaluate    ${DLG_04}+${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*8/300000000
    ${ULG_06}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C03006    local_moid=NRCELL-1
    ${ULG_01}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03001    local_moid=NRCELL-1
    ${ULG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03002    local_moid=NRCELL-1
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
    [Arguments]   ${test_scenario}
    Start log    btslog   cprt   biptaf
    Register Multiple UEs     start_ue=1   end_ue=2
    Attach Multiple NSA UEs    start_ue=41   end_ue=42    target_cell=1
    ${SC}    Stop log   btslog    cprt    biptaf     test_scenario=${test_scenario}
    [Return]     ${SC}


Multiple Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell
    Register Multiple UEs     start_ue=1   end_ue=5
    Attach Multiple NSA UEs    start_ue=41   end_ue=45    target_cell=1
    Trigger UE De-Registartion for Multiple UEs    start_ue=1   end_ue=5
    Trigger UE-Detach for Multiple UEs    start_ue=41   end_ue=45

Initiate Bi-directional Data to SA And NSA UEs
    Trigger DL Data for SA Multiple UEs   start_ue=1   end_ue=2   Traffic_rate=mbps   data_rate=20
    Trigger UL Data for SA Multiple UEs   start_ue=1   end_ue=2   Traffic_rate=mbps   data_rate=10
    Trigger DL Data for NSA Multiple UEs    start_ue=41   end_ue=42   Traffic_rate=mbps   data_rate=20
    Trigger UL Data for NSA Multiple UEs    start_ue=41   end_ue=42   Traffic_rate=mbps   data_rate=10

Validate Bi-directional Data of SA And NSA UEs
    sleep    60s
    Validate DL Traffic For MultiUE SA    start_ue_id=1    end_ue_id=2    dl_rate=20
    Validate UL Traffic For MultiUE SA    start_ue_id=1    end_ue_id=2    ul_rate=10
    Validate DL Traffic For MultiUE NSA    start_ue_id=41    end_ue_id=42   dl_rate=20
    Validate UL Traffic For MultiUE NSA    start_ue_id=41    end_ue_id=42   ul_rate=10

Stop Bi-directional Data and Detach SA And NSA UEs
    Trigger DL Data Stop for SA Multiple UEs    start_ue=1   end_ue=2
    Trigger UL Data Stop for SA Multiple UEs    start_ue=1   end_ue=2
    Trigger UE De-Registartion for Multiple UEs    start_ue=1   end_ue=2
    Trigger UE-Detach for Multiple UEs    start_ue=41   end_ue=42

Set E_TA_NR_Profile For Multiple UEs
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=2   end_ue=2    profile_id=1    delay=100
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=3   end_ue=3    profile_id=2    delay=500
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=4   end_ue=4    profile_id=3    delay=700
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=5   end_ue=5    profile_id=4    delay=950
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=42   end_ue=42    profile_id=5    delay=400
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=43   end_ue=43    profile_id=6    delay=600
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=44   end_ue=44    profile_id=7    delay=850
    Set And Activate UE_TA_NR_Profile For Multiple UEs    start_ue=45   end_ue=45    profile_id=8    delay=250

Trigger TA_NRTADV Report For Multiple UEs
    Start log   btslog    cprt
    Trigger TA_NRTADV Report    ue_id=1    trx_id=1
    Trigger TA_NRTADV Report    ue_id=2    trx_id=2
    Trigger TA_NRTADV Report    ue_id=41    trx_id=3
    ${SC3}    Stop log   cprt  btslog   test_scenario=TA_NRTADV

Attempt Multi-UE PRACH Procedure at Different cell range
    [Arguments]   ${test_scenario}
    Set E_TA_NR_Profile For Multiple UEs
    Start log    btslog   cprt   biptaf
    FOR    ${index}    IN RANGE     5
        log to console    Loop iteration: ${index}
        Multiple Attach SA And NSA UEs to PRACH_format_C2_15_kHz Cell
    END
    ${SC}    Stop log   btslog    cprt    biptaf     test_scenario=${test_scenario}

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
