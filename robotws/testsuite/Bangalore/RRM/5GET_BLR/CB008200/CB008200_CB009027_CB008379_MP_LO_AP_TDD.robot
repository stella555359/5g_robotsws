*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO
#...   PY27
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN    SBTS00    SBTS23R1    CONFIGURED
#CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
Resource         ./CB008200_Resource.robot
Resource          ./resources/common/common_setup_teardown.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ./resources/python/read_csv.py
#Resource         ../CB008379/CB008379_Resource.robot
#Resource         ../resources/ECEcommon/common_log_capture.robot
#Resource         ../resources/ECEcommon/common_log_analyzer.robot

#Resource         ../CB009027/8955_new_resources.robot
#Resource         ../CB009027/8955_new_resources.robot

Resource          ./resources/common/common_admin.robot

#Suite Setup         Run keywords
#...                 Log To console  SuiteSetup
#...                 AND     Suite setup from scratch
##...                 AND     Update GSCN in AP Iphy Xml     gscn=1582
#...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_2CC_TDD_VONR_MultiUE.json
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#...                 AND     Check Cell On Air      ${wts_cfg_file}

#Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
##...                 AND     Stop Syslog CPRT BIP Logs for ABIO_L1B     #Enable here if issue reports
#...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
Documentation
...
...             author:            Akhil K P, akhil.k_p@nokia.com
...             maintainer:        Akhil K P, akhil.k_p@nokia.com
...
...             INTRODUCTION:      Feature provides counters for measuring VoNR statistics for clear understanding of the performance of Voice over
...              NR calls in the network.The feature provides counters related to Retainability, Accessibility , Utilzation and VoNR Quality
...             The feature also provides some counters at PMQAP level.
...             TEST SET NAME:    1) CB008200-C_1_Network_Quality_Performance_Measurements_WB_CQI_64TBL_5QI1_CQIXX.
...                                The purpose of this test is to verify the PM Counter update for VoNR Wideband CQI per cell for classical gNB when
...                                64QAM table is configured. CQI histogram counters for 64QAM are updated according to the detailed counter
...                                 descriptions and reported CQI values
...                               2) CB008200-C_2_Network_Quality_Performance_Measurements_WB_CQI_256TBL_5QI1_CQIXX.
...                                The purpose of this test is to verify the PM Counter update for VoNR Wideband CQI per cell for classical gNB when
...                                256QAM table is configured. CQI histogram counters for 64QAM are updated according to the detailed counter
...                                descriptions and reported CQI values


...             TESTING SPLIT:     See CB008200 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008200 CFAM
...             Requirement ID:      5G_PM_385
*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB007134_C2-SCF.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB007134_C2-iphy.xml

${wts_cfg_file_1}     ${CURDIR}/config/wts/basic_setup_2CC_tdd_multi_ue_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${QFI_ID}    1
${TRF_ID}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${3}
${en_ue_id_2}     ${1}

#TC2

${SCFC_1}             /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008379/config/SCF/SCF_CB008379_CB007134-A_3_TDD_MP_LO.xml
${AP_XML_1}           /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008379/config/SCF/iphy_CB008379_CB007134-A_3_TDD_LN_LO.xml
#${wts_cfg_file2}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_tdd_um_mode.cfg
${wts_cfg_file_2}     /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008379/config/wts/basic_setup_1CC_max_gfbr_30_tdd_um_mode.cfg

${en_ue_id_1}      ${1}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed it is in the unit of Kn for mb add three 0s
&{gfbr_mfbr_profile}        5_gfbr_ul=20480   5_gfbr_dl=20480    5_mfbr_ul=20480     5_mfbr_dl=20480


@{QOS_Prof1}                1           5
@{QOS_Prof1_speed_ul}       20          30
@{QOS_Prof1_speed_dl}       20          30
@{QOS_Prof1_unit}           mbps        mbps


#TC3

#${wts_cfg_file_3}     ${CURDIR}/config/basic_setup_tdd_gbr_multi_ue_8955.cfg
#${wts_cfg_file_3}     /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB009027/config/basic_setup_tdd_gbr_multi_ue_8955.cfg
${wts_cfg_file_3}      ${CURDIR}/config/wts/basic_setup_TMO65.cfg
${Pdu_session_ID}       1
${Pdu_session_ID_1}       2
${QFI_ID_1}      5
${TRF_ID_1}     2
#${st_ue_id_1}    ${3}
#${en_ue_id_1}    ${3}


*** Test Cases ***

#[1]CB008200-C_2_Network_Quality_Performance_Measurements_WB_CQI_256TBL_5QI1_CQIXX
#    [Tags]    TC01
#    [Setup]         Run keywords	Suite setup from scratch
##...                 Log To console  SuiteSetup
##...                 AND     Suite setup from scratch
##...                 AND     Update GSCN in AP Iphy Xml     gscn=1582
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.133/24 dev eth3
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.134/24 dev eth3
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.131/24 dev eth3
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.136/24 dev eth3
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.135/24 dev eth3
#    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.137/24 dev eth3
#
#    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#    ...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_2CC_TDD_VONR_MultiUE.json
#    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_1}
#    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
#    set test variable      ${LOG_PATH}
#    Set fixed cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    7
##    Perform SCF Delta Commissioning with dl256qam_1CC.json
#    Make MultiUE 5qi1 call with varying cqi and collect ttitrace
#    Get 256QAM cqi counters and validate_updated		${1}		${7}		ttitrace_streaming
#    Remove varying cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    1    7
#	Set fixed cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    0
#    Perform SCF Delta Commissioning with csirepperiod_1CC.json
#    Make MultiUE 5qi1 call with varying cqi and collect ttitrace
#    Get 256QAM cqi counters and validate_updated		${1}		${7}		ttitrace_streaming_2
##    [Teardown]   configuration_id.Link SCOUT SCF to Configuration ID for Reporting
#
##    [Teardown]      Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
##    ...        AND     Run Keyword and Ignore Error    Get Snapshot
##    ...        AND   Link SCOUT SCF to Configuration ID for Reporting
#    [Teardown]    Run Keywords    Log To console    TCTeardown
#    ...        AND      Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
#    ...        AND      Run Keyword and Ignore Error    Get Snapshot
#    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
#    ...        AND      common_setup_teardown.Link SCOUT SCF to Configuration ID for Reporting


[1]CB009027-GBR-call_with_feature_enable_8955-ABIP

    [Tags]    TC03
    [Setup]         Run keywords	Suite setup from scratch
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    #...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_hightolow_gbr_8955_updated.json
    ...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_high2low_8955.json
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_3}

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Make MultiUE 5qi1 call with varying cqi and collect ttitrace_9027
    [Teardown]    Run Keywords    Log To console    TCTeardown
    ...        AND      Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND      Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND      common_setup_teardown.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB008379-5G-A_3_Verify_Modification_of_UL_DL_throughput_for_5QI-3_TDD



    [Tags]    TC02
    [Setup]         Run keywords	Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_8379_FS_3_7.json
    #...                 AND     sleep    600
    #...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_2}
#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}

#Step 1. Attach 1 UE having non-GBR and non-VoNR QOS Profile

    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}    ${en_ue_id_2}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id_2}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    Log to Console             Bearerlist with${ue_to_bearer_list}
    ${total_duration}      Set Variable    600
    ${trf_id}      Set Variable    ${1}

# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL

    ${trigger_point_dur}=     Set Variable      300
    ${remainined_dur}=     Evaluate   ${total_duration}-${trigger_point_dur}
    ${updated_qos_profile_speed_ul}=    Copy Dictionary      ${qos_profile_speed_ul}      deepcopy=True
    ${updated_qos_profile_speed_dl}=    Copy Dictionary      ${qos_profile_speed_dl}      deepcopy=True
    ${prf1}=       Create List    20            20
    Set To Dictionary  ${updated_qos_profile_speed_ul}     ${1}    ${prf1}
    Set To Dictionary  ${updated_qos_profile_speed_dl}     ${1}    ${prf1}
    ${updated_ue_list}=        Create List         ${1}
    log to console     ${updated_qos_profile_speed_ul}
    log to console     ${qos_profile_speed_ul}

    ${delta_time}=     Start Data Transfer After GFBR Update   ${st_ue_id}     ${en_ue_id_2}    ${total_duration}   ${trigger_point_dur}
    ...   both  ${trf_id}   ${qos_profile_unit}     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
    ...   ${updated_ue_list}    ${updated_qos_profile_speed_ul}    ${updated_qos_profile_speed_dl}    both
    ...   ${gfbr_mfbr_profile}    tti_trace_1   update=1    tti_dur=10

    ${bearer_stats_ul}=   Get Received Sent Bytes New     ${st_ue_id}    ${en_ue_id_2}    ${qos_profile}    ul
    ${bearer_stats_dl}=   Get Received Sent Bytes New     ${st_ue_id}    ${en_ue_id_2}    ${qos_profile}    dl

    ${status}=      utility.verify_tp_on_dr_modif       ${bearer_stats_ul}   ${remainined_dur}       ${delta_time[0]}
    ...     ${qos_profile_speed_ul}     ${updated_qos_profile_speed_ul}     ${qos_profile_unit}     ${vonr_codec_rate}
    ...     ${updated_ue_list}
    Should Contain     ${status}    Pass

    ${status}=      utility.verify_tp_on_dr_modif       ${bearer_stats_dl}   ${remainined_dur}       ${delta_time[1]}
    ...     ${qos_profile_speed_dl}     ${updated_qos_profile_speed_dl}     ${qos_profile_unit}     ${vonr_codec_rate}
    ...     ${updated_ue_list}
    Should Contain     ${status}    Pass

    ${tti_tp_ul}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    ul       ${delta_time[2]}/output_ul_formated.csv    tti_dur=10
    ${tti_tp_dl}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    dl       ${delta_time[2]}/output_dl_formated.csv    tti_dur=10

    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_dl}   ${updated_qos_profile_speed_dl}
    ...      ${qos_profile_unit}     ${vonr_codec_rate}  ${total_duration}    ${trigger_point_dur}
    Should Contain     ${status}    Pass
    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_ul}   ${updated_qos_profile_speed_ul}
    ...      ${qos_profile_unit}     ${vonr_codec_rate}  ${remainined_dur}    ${trigger_point_dur}
    Should Contain     ${status}    Pass
    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id_2}
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

    [Teardown]    Run Keywords    Log To console    TCTeardown
    ...        AND      Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND      Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND      common_setup_teardown.Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    #Step 1. Attach multiple VONR UEs, with PDU session 5QI-6 nonGBR qosflow which is default
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
#Step 2. Establish pdu_id=2 for 5QI-5 SIP Signalling
    MultiUE PDU Addition should be Successful        ${st_ue_id}    ${en_ue_id}    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=2   qosflows_to_add=2
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=2    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=2    trf_id=1       qfi_id=2
    Sleep   2s

#Step 3. Establish pdu_id=2 for 5QI-1 VoNR Call
    Start Ttitrace With Streaming Mode
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=2      qosflows_to_add=3
    sleep       10s
	Set varying cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    0    7
	Trigger MultiUE VoNR DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    pdu_id=2     trf_id=2     qfi_id=3    rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    pdu_id=2     trf_id=2     qfi_id=3    rtp_codec=custom
     sleep    10s
     Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    sleep   20s
    Stop Ttitrace
    Wait until the current Measurement Period stops

Get 256QAM cqi counters and validate_updated
    [Arguments]    ${cqi_start}=1     ${cqi_end}=15	${ttitrace_path}=ttitrace_streaming
    CB008200_Resource.Collect PM Counters
    Convert Ttitrace From Pcap To Excelcsv        ${LOG_PATH}/${ttitrace_path}/
    Convert Tti To Csv Mode          ${LOG_PATH}/${ttitrace_path}
   # Get legacy cqi counters
    ${pi_list}=  Create List  M55301C22000  M55301C22001  M55301C22002  M55301C22003  M55301C22004  M55301C22005  M55301C22006
    ...    M55301C22007  M55301C22008  M55301C22009  M55301C22010  M55301C22011  M55301C22012  M55301C22013  M55301C22014  M55301C22015
#    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
#    ...  pi_list=${pi_list}  index=0
    ${actual_tti_values}=       check_cqi_from_ttitrace     ${LOG_PATH}/${ttitrace_path}/output_ul_formated.csv
    FOR     ${cqi}       IN RANGE     ${cqi_start}     7
    #${cqi_from_pm}=     Get From Dictionary    ${actual_pm_values}    M55301C2200${cqi}
    ${cqi_from_pm}=     Get PM counter value      pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters  moc=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_id=M55301C2200${cqi}
    ${cqi_from_pm}=   convert to integer    ${cqi_from_pm}
    log to console   M55301C2200${cqi} ${cqi_from_pm}
    ${cqi_from_tti}=    Get From Dictionary    ${actual_tti_values}    ${cqi}
    #should be equal     ${cqi_from_pm}      ${cqi_from_tti}
    ${condition}=   Evaluate  abs(${cqi_from_pm}-${cqi_from_tti})<=0.1*${cqi_from_pm}
    should be true      ${condition}
    END
    Log to Console    ${cqi_end}


Make MultiUE 5qi1 call with varying cqi and collect ttitrace_9027
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Register should be Successful     1    3
    Sleep   2s
    Set fixed cqi for multiple UEs    3    3    15

    MultiUE PDU Addition should be Successful        3    3    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     3    3    pdu_id=2   qosflows_to_add=5
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    1  1   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    2  2   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    2  2   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA_8955    3  3   Traffic_rate=mbps     dl_rate=130       pdu_id=2    trf_id=2      qfi_id=1
    MultiUE Trigger UL Traffic for SA_8955    3  3   Traffic_rate=mbps     ul_rate=25        pdu_id=2     trf_id=2     qfi_id=1
    sleep    30s
#    Start Ttitrace With Streaming Mode
    Start TTI_TRACE custom     ${51}
    sleep      5s
    Stop Ttitrace
    Stop MultiUE Data Traffic for SA     1    3
    MultiUE Deregister should be Successful   1    3
    sleep    300s
    CB008200_Resource.Collect PM Counters
    Run Keyword And Ignore Error    Get 8955 counters and validate  M55308C10008  M55308C00019
    Convert Ttitrace From Pcap To Excelcsv    ${LOG_PATH}/ttitrace
    Convert Tti To Csv Mode         ${LOG_PATH}/ttitrace
    sleep   10s
    Wait until the current Measurement Period stops  additional_time=${0}

