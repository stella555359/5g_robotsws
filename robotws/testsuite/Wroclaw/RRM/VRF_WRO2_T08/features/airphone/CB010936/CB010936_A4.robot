*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC    SBTS00

Documentation    :copyright: Nokia
...              :author: Dariusz Maciocha
...              :maintainer: marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_iperf_traffic
Library    ta5g_iphy
Library    ta5g_setups_and_teardowns
Library    ta5g_enb
Library    ta5g_ue_mobility
Library    ta5g_pm_counters
Library    ta5g_delta
Library    ta5g_commissioning
Library    ta5g_testline_management
Library    taf.sw.reporting_portal
Library    CB010936_Keywords.py
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py

Suite Setup    Setup
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs
Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Add Scout Scf Id To Test Data
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Variables ***
${iphy}    ${CURDIR}/config/iphy_n1A_n258M_8CC_BOO_LOO.xml
${egate}   ${CURDIR}/config/egate_A4.cfg

*** Test Cases ***
CB010936_A4_L4S_DL_after_successful_8CC_SCell_Addition_for_FR2_PSCell_During_NR-DC_Establishment_A4-meas_based
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4
    ${cmd} =    Catenate    adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1 target_bler=100,90,80,60,40,20,15,10,5,2,1,0.5,0,0,0
    ...                     target_mcs=18 p_target_bler_profile_id=1
    Execute Egate Command    cmd=${cmd}
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=adv_bler profile_id=1 action=activate
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt    10.0.2.1    7264    1    True
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic.txt   10.0.2.1    7267    1    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_1.txt    10.0.2.1    7261    1    False
    Start Server And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic_5qi7_2.txt   10.0.2.1    7265    1    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_udp_l4s.txt
    ...    1.2.4.2    1G    150    1    10.0.2.1    7264    1300    True
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic.txt
    ...    1.2.4.2    200M    120    60    10.0.2.1    7267    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_1.txt
    ...    1.2.4.2    200M    120    60    10.0.2.1    7261    1400    False
    Start Client And Save Output    ${OUTPUT_DIR}/${TEST_NAME}/iperf_client_tcp_classic_5qi7_2.txt
    ...    1.2.4.2    200M    120    60    10.0.2.1    7265    1400    False
    Sleep    150s
    Check If Average Latency Lower Then Threshold    80    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt
    Check If L4S Traffic Average Bandwidth At Least Half Of Classic
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55352C03021  >0  DL_PDCP_SDU_ENT_N_L4S_Q_PMQAP
    ...    M55352C03022  >0  DL_PDCP_SDU_ENT_L4S_Q_PMQAP
    ...    M55352C03023  >0  DL_PDCP_SDU_DISC_N_L4S_Q_PMQAP
    ...    M55352C03024   0  DL_PDCP_SDU_DISC_L4S_Q_PMQAP
    ...    M55352C03025  >0  DL_PDCP_SDU_MARKED_L4S_Q_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

*** Keywords ***
Check If L4S Traffic Average Bandwidth At Least Half Of Classic
    ${l4s}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_udp_l4s.txt
    ${tcp1}    Get Average Bandwidth    ${OUTPUT_DIR}/${TEST_NAME}/iperf_server_tcp_classic.txt
    Should Be True    ${l4s} >= ${tcp1} / 2    L4S bandwidth (${l4s} Mbits/sec) is less than half of TCP bandwidth (${tcp1} Mbits/sec).

Change RD Parameters In Swconfig File
    @{10936_rd_params}=    Create List
    ...    0x5A0614=1 # rdDebugBearerManagement
    ...    0x5A0618=1 # rdDebugPmqapCounters
    ...    0x5A0621=1 # rdDebugCounters
    ...    0x5A0622=1 # rdDebugPI2
    ...    0x5A0624=1 # rdDebugL4S
    ...    0x66001C=10 # NRBTS.cbtsFlowControlProf.maxTransferDelay
    ...    0x890057=0 # rdActNrDualConnectivity
    Backup And Modify Swconfig File    parameters_list=${10936_rd_params}

Setup
    Change RD Parameters In Swconfig File
    Update And Put Iphy Xml         input_filepath=${iphy}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=scf_A4.xml
    Reach OnAir   lua_cfg=${egate}
