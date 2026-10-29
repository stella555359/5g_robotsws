*** Settings ***
Library     OperatingSystem
Library     ta_attenuator
Library     taf.ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf.admin
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.qxdm_log_collector.QxdmLogCollector  WITH NAME  QXDM
Library     ./test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.bts_utils
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/bts_log.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaStore.py
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     DateTime
Library     testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/qualcomm/qpm_lk.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

Documentation  Set of keywords for feature 5GC005935 execution

*** Keywords ***
CB005935 Suite Setup
    Check Branch
    Testsuite Setup Recommissioning
    Wait Until Keyword Succeeds   2x   10sec   Get QXDM License
    Wait Until Keyword Succeeds   2x   10sec   QXDM.Setup
    QXDM.Set Logging Filter   C:/auto/sebkowa.dmc
    Prepare Ue
    Set Initial Attenuation

Get QXDM License
    Get 5g QXDM And Qcat License
    ...  username=tomasz.sobania@nokia.com
    ...  password=Tsob123,.
    ...  ue_id=${0}

Check Branch
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${sw}=  taf.admin.Get Sw Version  connection=${admin_alias}
    ${is_sw_24r3}=    Check If 24r3    ${sw}
    Set Global Variable  ${IS_SW_24R3}  ${is_sw_24r3}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

CB06733 Suite Teardown
    QXDM.Teardown
    Release 5g QXDM And Qcat License  ue_id=${0}
    ta_attenuator.Release Attenuator

Prepare Ue
    taf.ue.Require UE    UE_1    capabilities=REAL_ANDROID_UE
    taf.ue.Detach UE     UE_1
    Sleep    5s

Attach
    [Arguments]    ${attenuation}    ${cell}
    Set Attenuation   ${cell}   ${attenuation}db
    taf.ue.Attach UE    UE_1
    sleep    5s
    Log to Console    \nUE Attached!

Set Initial Attenuation
    ${cell_list}=   Create list   ${CELL_190}    ${CELL_196}    ${CELL_193}    ${CELL_197}    ${CELL_999}
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    FOR    ${cell}    IN    ${cell_list}
      Set Attenuation    ${cell}    90dB
    END
    Sleep  2s

Attach Ue And Start Ping
    [Arguments]    ${attenuation}    ${cell}=${CELL_190}
    Attach    ${attenuation}    ${cell}
    @{args}=    Create List     IP
    ${ip}=    taf.ue.get ue info    UE_1     infos_list=@{args}
    ${appserver}=    ssh.connect_to    hostname=10.45.168.53    username=5g    password=2019H@slo
    Set Global Variable  ${APPSERVER}  ${appserver}
    ssh.Send Command    command=ping -w900 ${ip}    connection=${APPSERVER}


Unblock Cells After TC
    [Arguments]    @{cells}
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    FOR    ${cell}    IN    @{cells}
        taf.admin.Unblock Cell  dist_name=MRBTS-50819/${cell}    connection=${admin_alias}
    END
    [Teardown]    taf.admin.teardown admin    alias=${admin_alias}

Block Cells Before TC
    [Arguments]    @{cells}
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    FOR    ${cell}    IN    @{cells}
        taf.admin.Block Cell  dist_name=MRBTS-50819/${cell}    connection=${admin_alias}
    END
    [Teardown]    taf.admin.teardown admin    alias=${admin_alias}

Verify Bts Is Operational
    Log To Console  \nBTS Verification Ongoing...
    Wait For Nr Cells On Air
    WATCHDOG.Check Detected Alarms

AA_B4 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Log To Console    \nStep 1: Blocking Cells, Setup Recommissioning
    AA_B4 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195    NRBTS-50819/NRCELL-99
    ...                      NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999
    Start Bts Log  btslog

USCB005935_AA_B4_TC01_Single_UE_call_buffer_based_SCell_activation_deactivation
    @{uplink_carriers}=    Create List    0    2
    @{downlink_carriers}=    Create List    0    1    2
    @{expected_bands_dl}=    Create List    25    66
    @{expected_bands_ul}=    Create List    25
#    Step 2
    Log To Console    \nStep 2: UE attach
    Start Tcpdump On CU    filename=${test_name}_step02_attach.pcap
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_190}
    Set Attenuation    ${CELL_193}     0dB
    Set Attenuation    ${CELL_196}     0dB
    Sleep    3s
    QXDM.Start Log Collecting
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL_attach
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=90s
        ...     throughput=500Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL_attach
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=90s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    3s
    Log To Console    \nGathering pcap from attach
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step02_attach.pcap
    QXDM.Stop Log Collecting
    ${step2_uelog_activate_2}=    QXDM.Download Log    filepath=${LOG_PATH}/step2_activate_2
    QXDM.Start Log Collecting
    taf.ue.Stop Data Transfer    dt_name=DT_DL_attach
    taf.ue.Stop Data Transfer    dt_name=DT_UL_attach
    Sleep    24s
    QXDM.Stop Log Collecting
    ${step2_uelog_deactivate_2}=    QXDM.Download Log    filepath=${LOG_PATH}/step2_deactivate_2
    Log To Console    Verifying Step 2...
    Verify Correct Bands    ${LOG_PATH}/${test_name}_step02_attach.pcap    ${expected_bands_dl}    ${expected_bands_ul}
    Verify Expected Scell State Change    ${step2_uelog_activate_2}[0][0]    ACTIVATED    1
    Verify Expected Scell State Change    ${step2_uelog_activate_2}[0][0]    ACTIVATED    2
    Verify Expected Scell State Change    ${step2_uelog_deactivate_2}[0][0]    CONFIGURED    1
    Verify Expected Scell State Change    ${step2_uelog_deactivate_2}[0][0]    CONFIGURED    2
#    Step 3
    Log To Console    \nStep 3: starting UL tput alone
    QXDM.Start Log Collecting
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL_step3
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=120s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL_5M
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=1420s
        ...     throughput=5Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    10s
    QXDM.Stop Log Collecting
    ${step3_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step3_Ul_start
    Log To Console    Verifying Step 3...
    Verify Uplink Carrier Aggregation    ${step3_uelog}[0][0]
    Verify Expected Scell State Change    ${step3_uelog}[0][0]    ACTIVATED    2
#    Step 4
    Log To Console    \nStep 4: Stopping full buffer UL tput
    QXDM.Start Log Collecting
    taf.ue.Stop Data Transfer    dt_name=DT_UL_step3
    Sleep    24s
    QXDM.Stop Log Collecting
    ${step4_uelog_deactivate_1}=    QXDM.Download Log    filepath=${LOG_PATH}/step4_deactivate_1
    Log To Console    Verifying Step 4...
    Verify Expected Scell State Change    ${step4_uelog_deactivate_1}[0][0]    CONFIGURED    2
#    Step 5
    Log To Console    \nStep 5: gathering ue log to verify UL tput only on pCell
    QXDM.Start Log Collecting
    Sleep    18s
    QXDM.Stop Log Collecting
    ${step5_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step5_Ul_pcell
    Log To Console    Verifying Step 5...
    Verify Uplink Tput Pcell Only    ${step5_uelog}[0][0]
#    Step 6
    Log To Console    \nStep 6: Starting UL/DL tput
    QXDM.Start Log Collecting
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL_step6
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=200s
        ...     throughput=250Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL_step6
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=400s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL_5M
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=1180s
        ...     throughput=5Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    14s
    QXDM.Stop Log Collecting
    ${step6_uelog_activate_2}=    QXDM.Download Log    filepath=${LOG_PATH}/step6_activate_2
    QXDM.Start Log Collecting
    Sleep    16s
    QXDM.Stop Log Collecting
    ${step6_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step6_DLULy
    Log To Console    Verifying Step 6...
    Verify Carrier Aggregation Ongoing Both Ways    ${step6_uelog}[0][0]    ${downlink_carriers}    ${uplink_carriers}
    Verify Expected Scell State Change    ${step6_uelog_activate_2}[0][0]    ACTIVATED    1
    Verify Expected Scell State Change    ${step6_uelog_activate_2}[0][0]    ACTIVATED    2
#    Step 7
    Log To Console    \nStep 7: Stopping DL tput firstly
    QXDM.Start Log Collecting
    Sleep    4s
    taf.ue.Stop Data Transfer    dt_name=DT_DL_step6
    Sleep    26s
    QXDM.Stop Log Collecting
    ${step7_uelog_deactivate_1}=    QXDM.Download Log    filepath=${LOG_PATH}/step7_deactivate_1
    Sleep    28s
    QXDM.Start Log Collecting
    Sleep    16s
    QXDM.Stop Log Collecting
    ${step7_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step7_DL_stopped_first
    Log To Console    Verifying Step 7...
    Verify Uplink Carrier Aggregation With Low Tput Downlink    ${step7_uelog}[0][0]
    Verify Expected Scell State Change    ${step7_uelog_deactivate_1}[0][0]    CONFIGURED    1
#    Step 8
    Log To Console    \nStep 8: Stopping UL tput secondly
    QXDM.Start Log Collecting
    taf.ue.Stop Data Transfer    dt_name=DT_UL_step6
    Sleep    24s
    QXDM.Stop Log Collecting
    ${step8_uelog_deactivate_1}=    QXDM.Download Log    filepath=${LOG_PATH}/step8_deactivate_1
    Sleep    2s
    QXDM.Start Log Collecting
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step8_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step8_UL_stopped_second
    Log To Console    Verifying Step 8...
    Verify Low Uplink And Downlink Throughput    ${step8_uelog}[0][0]
    Verify Expected Scell State Change    ${step8_uelog_deactivate_1}[0][0]    CONFIGURED    2
#    Step 9
    Log To Console    \nStep 9: Starting UL/DL tput
    QXDM.Start Log Collecting
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL_step9
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=300s
        ...     throughput=500Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL_step9
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=240s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep  14s
    QXDM.Stop Log Collecting
    ${step9_uelog_activate_2}=    QXDM.Download Log    filepath=${LOG_PATH}/step9_activate_2
    QXDM.Start Log Collecting
    Sleep    16s
    QXDM.Stop Log Collecting
    ${step9_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step9_DLUL
    Log To Console    Verifying Step 9...
    Verify Carrier Aggregation Ongoing Both Ways    ${step9_uelog}[0][0]    ${downlink_carriers}    ${uplink_carriers}
    Verify Expected Scell State Change    ${step9_uelog_activate_2}[0][0]    ACTIVATED    1
    Verify Expected Scell State Change    ${step9_uelog_activate_2}[0][0]    ACTIVATED    2
#    Step 10
    Log To Console    \nStep 10: Stopping UL tput firstly
    taf.ue.Stop Data Transfer    dt_name=DT_UL_step9
    Sleep    15s
    QXDM.Start Log Collecting
    Sleep    16s
    QXDM.Stop Log Collecting
    ${step10_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step10_UL_stopped_firstly
    Log To Console    Verifying Step 10...
    Verify Downlink Carrier Aggregation With Low Uplink Throughput    ${step10_uelog}[0][0]
#    Step 11
    Log To Console    \nStep 11: Stopping DL tput secondly
    QXDM.Start Log Collecting
    taf.ue.Stop Data Transfer    dt_name=DT_DL_step9
    Sleep    24s
    QXDM.Stop Log Collecting
    Sleep    6s
    ${step11_uelog_deactivate_2}=    QXDM.Download Log    filepath=${LOG_PATH}/step11_deactivate_2
    QXDM.Start Log Collecting
    Sleep    16s
    QXDM.Stop Log Collecting
    ${step11_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/step11_DL_stopped_secondly
    Log To Console    Verifying Step 11...
    Verify Low Uplink And Downlink Throughput    ${step11_uelog}[0][0]
    Verify Expected Scell State Change    ${step11_uelog_deactivate_2}[0][0]    CONFIGURED    1
    Verify Expected Scell State Change    ${step11_uelog_deactivate_2}[0][0]    CONFIGURED    2
#    Step 12
    Log To Console    \nStep 12: Closing leftover low DL/UL tputs
    taf.ue.Stop Data Transfer    dt_name=DT_DL_5M
    taf.ue.Stop Data Transfer    dt_name=DT_UL_5M
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...           Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195    NRBTS-50819/NRCELL-99
    ...           NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999

Common Test Teardown
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    ssh.disconnect    connection=${APPSERVER}
    Add Scout Scf Id To Test Data
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Passed  Find Suspicious Prints In Passed Test
    Make Snapshot In Case Of Error

AA_B4 Teardown
    Log To Console    AA_B4 Teardown
    AA_B4 Teardown Recommissioning
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    Verify Bts Is Operational
    Common Test Teardown

AB_B8 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    AB_B8 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195    NRBTS-50819/NRCELL-99
    ...                      NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    Set Attenuation    ${CELL_197}     90dB
    Start Bts Log  btslog

USCB005935_AB_B8_TC03_Full_mobility_support_for_UE_with_FDD_FR1_FDD_UL_CA_configured
    @{uplink_carriers}=    Create List    0    1
    @{downlink_carriers}=    Create List    0    1    2
    @{expected_bands_190_dl}=    Create List    25    66
    @{expected_bands_190_ul}=    Create List    66
    @{expected_bands_193_dl}=    Create List    25    71
    @{expected_bands_193_ul}=    Create List    71
    Log To Console    \nStep 1: UE attach
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=42    cell=${CELL_190}
    Sleep    2s
    Start Tcpdump On CU    filename=${test_name}_step2_scell_addition.pcap
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=500s
        ...     throughput=500Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=500s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
#    Step 2
    Log To Console    \nStep 2: Trigger scell addition to cell 197 and 198
    Change Attenuation Gradually    ${CELL_190}    42   0    -2
    Change Attenuation Gradually    ${CELL_197}    60   0    -2
    Log To Console    \nGathering pcap from scell addition
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step2_scell_addition.pcap
    Sleep  5s
    Log To Console    \n Verifying Step 2
    Verify Correct Bands    ${LOG_PATH}/${test_name}_step2_scell_addition.pcap
    ...  ${expected_bands_190_dl}    ${expected_bands_190_ul}
    Check If Cell 197 Subbandwidth Is Used    ${LOG_PATH}/${test_name}_step2_scell_addition.pcap
    ...  ${expected_bands_190_dl}    ${expected_bands_190_ul}
#    Step 3
    Log To Console    \nStep 3: Check Carrier Aggregation
    QXDM.Start Log Collecting
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step3_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step3_DLUL
    Log To Console    \n Verifying Step 3
    Verify Carrier Aggregation Ongoing Both Ways    ${step3_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
#    Step 4
    Log To Console    \nStep 4: Handover to cell 193 with CA tput with cell 190 and 196 ongoing
    Start Tcpdump On CU    filename=${test_name}_step4_handover_193.pcap
    Change Attenuation Gradually    ${CELL_193}    60   0    -2
    Change Attenuation Gradually    ${CELL_190}    0    46    1
    Change Attenuation Gradually    ${CELL_197}    0    40    5
    Sleep    8s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step4_handover_193.pcap
    Log To Console    \n Verifying Step 4
    Verify Handover    ${LOG_PATH}/${test_name}_step4_handover_193.pcap    193
    Verify Correct Bands    ${LOG_PATH}/${test_name}_step4_handover_193.pcap
    ...  ${expected_bands_193_dl}    ${expected_bands_193_ul}    193
#    Step 5
    Log To Console    \nStep 5: Check Carrier Aggregation
    Set Attenuation    ${CELL_196}    0dB
    Set Attenuation    ${CELL_190}    10dB
    Sleep    5s
    QXDM.Start Log Collecting
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step5_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step5_DLUL
    Log To Console    \n Verifying Step 5
    Verify Carrier Aggregation Ongoing Both Ways    ${step5_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
#    Step 6
    Log To Console    \nStep 6: Handover back to cell 190 with CA tput with cell 197 and 198 ongoing
    Start Tcpdump On CU    filename=${test_name}_step6_handover_190.pcap
    Change Attenuation Gradually    ${CELL_196}    0    90    5
    Change Attenuation Gradually    ${CELL_193}    0    50    5
    Set Attenuation                 ${CELL_190}    0dB
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step6_handover_190.pcap
    Log To Console    \n Verifying Step 6
    Verify Handover    ${LOG_PATH}/${test_name}_step6_handover_190.pcap    190
    Check If Cell 197 Subbandwidth Is Used    ${LOG_PATH}/${test_name}_step2_scell_addition.pcap
    ...  ${expected_bands_190_dl}    ${expected_bands_190_ul}
#    Step 7
    Log To Console    \nStep 7: Check Carrier Aggregation and close throughput
    Change Attenuation Gradually    ${CELL_197}    40    0    -2
    Sleep    5s
    QXDM.Start Log Collecting
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step7_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step7_DLUL
    Log To Console    \n Verifying Step 7
    Verify Carrier Aggregation Ongoing Both Ways    ${step7_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
    [Teardown]    Run Keywords    taf.ue.Stop Data Transfer    dt_name=DT_DL    AND
    ...                           taf.ue.Stop Data Transfer    dt_name=DT_UL    AND
    ...                           Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...                           Unblock Cells After TC    NRBTS-50819/NRCELL-195    NRBTS-50819/NRCELL-99
    ...                           NRBTS-50819/NRCELL-194   NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999

AB_B8 Teardown
    Log To Console    AB_B8 Teardown
    Run Keyword And Ignore Error    Tshark Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    Set Attenuation    ${CELL_197}     90dB
    AB_B8 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

AB_B6 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    AB_B6 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-99
    ...                      NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999
    Start Bts Log  btslog

USCB005935_AB_B6_TC02_Alternative_A6_based_SCell_swap_supports_for_UE_with_FDD_FR1_FDD_ULCA
    @{uplink_carriers}=    Create List    0    1
    @{downlink_carriers}=    Create List    0    1    2
    @{expected_bands_dl}=    Create List    25    71
    @{expected_bands_ul}=    Create List    25    71
    Log To Console    \nStep 1: UE attach
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=42    cell=${CELL_190}
    Sleep    5s
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=480s
        ...     throughput=500Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=480s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    5s
#    Step 2
    Log To Console    \nStep 2: A1 scell addition
    Start Tcpdump On CU    filename=${test_name}_step2_scell_addition.pcap
    Change Attenuation Gradually    ${CELL_193}    70    0    -5
    Change Attenuation Gradually    ${CELL_196}    70    20   -5
    Set Attenuation    ${CELL_196}     14dB
    Change Attenuation Gradually    ${CELL_190}    42    0   -2
    Sleep    10s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step2_scell_addition.pcap
    QXDM.Start Log Collecting
    Sleep    16s
    QXDM.Stop Log Collecting
    ${step2_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step2_DLUL
    Log To Console    \n Verifying Step 2
    Verify Scells Addition    ${LOG_PATH}/${test_name}_step2_scell_addition.pcap
    Verify Carrier Aggregation Ongoing Both Ways    ${step2_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
#    Step 3
    Log To Console    \nStep 3: Scell swap from 193 to 195
    Start Tcpdump On CU    filename=${test_name}_step3_scell_swap_195.pcap
    Change Attenuation Gradually    ${CELL_196}    18    0   -1
    Change Attenuation Gradually    ${CELL_193}    0    48    2
    Sleep    5s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step3_scell_swap_195.pcap
    QXDM.Start Log Collecting
    Sleep    16s
    QXDM.Stop Log Collecting
    ${step3_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step3_DLUL
    Log To Console    \n Verifying Step 3
    Verify Scell Swap    ${LOG_PATH}/${test_name}_step3_scell_swap_195.pcap    195
    Verify Carrier Aggregation Ongoing Both Ways    ${step3_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
#    Step 4
    Log To Console    \nStep 4: Scell swap from 195 to 193
    Start Tcpdump On CU    filename=${test_name}_step4_scell_swap_193.pcap
    Change Attenuation Gradually    ${CELL_193}    45    0   -5
    Set Attenuation    ${CELL_193}     0dB
    Change Attenuation Gradually    ${CELL_196}    0    16    2
    Set Attenuation    ${CELL_196}     10dB
    Sleep    10s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step4_scell_swap_193.pcap
    QXDM.Start Log Collecting
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step4_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step4_DLUL
    Log To Console    \n Verifying Step 4
    Verify Scell Swap    ${LOG_PATH}/${test_name}_step4_scell_swap_193.pcap    193
    Verify Carrier Aggregation Ongoing Both Ways    ${step4_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
    [Teardown]    Run Keywords    taf.ue.Stop Data Transfer    dt_name=DT_DL  AND
    ...                           taf.ue.Stop Data Transfer    dt_name=DT_UL  AND
    ...                           Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1    AND
    ...                           Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-99
    ...                                                     NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-999


AB_B6 Teardown
    Log To Console    AB_B6 Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Set Attenuation    ${CELL_196}     90dB
    Run Keyword And Ignore Error    Tshark Teardown
    AB_B6 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

Change cellAggrLevel
    [Arguments]    ${value}
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{cellAggrLevel}=    Create List    ${value}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-14    cellAggrLevel=@{cellAggrLevel}
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]    taf.admin.Teardown Admin    connection=admin_gnb

C_B2 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    C_B2 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-999    NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-99
    Start Bts Log  btslog

USCB005935_C_B2_TC04_Interworking_with_DRB_profile_based_carrier_aggregation
    Log To Console    \nStep 1: UE attach
    Start Tcpdump On CU    filename=${test_name}_step1_attach.pcap
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_190}
    Sleep    5s
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=400s
        ...     throughput=500Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=400s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    5s
    Log To Console    \nGathering pcap from attach
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step1_attach.pcap
#    Step 2
    Log To Console    \nStep 2: Deattenuation scells 197 and 198
    Set Attenuation    ${CELL_197}    0dB
    Sleep    5s
    QXDM.Start Log Collecting
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step2_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step2_DLUL
#    Step 3
    Log To Console    \nStep 3: Start VoNR call
    QXDM.Start Log Collecting
    Start Voice Call    VC    UE_1    +555800903300998    60s
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step3_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step3_DLUL_Vonr
#    Step 4
    Log To Console    \nStep 4: Stop VoNR call
    QXDM.Start Log Collecting
    Await Voice Call Finish    VC
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step4_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step4_DLUL
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    taf.ue.Stop Data Transfer    dt_name=DT_UL
    taf.ue.Detach UE    UE_1
    Set Attenuation    ${CELL_197}    90dB
#    Step 5
    Log To Console    \nStep 5: Online modify parameter cellAggrLeve to 'Not FR1 CA eligible'
    Change cellAggrLevel    Not FR1 CA eligible
#   Step 6
    Log To Console    \nStep 6: UE attach
    Start Tcpdump On CU    filename=${test_name}_step6_attach2.pcap
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_190}
    Sleep    5s
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=400s
        ...     throughput=500Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    taf.ue.Start Data Transfer
        ...     dt_name=DT_UL
        ...     ue_alias=UE_1
        ...     direction=ul
        ...     duration=400s
        ...     throughput=100Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    10s
    Log To Console    \nGathering pcap from attach
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step6_attach2.pcap
#    Step 7
    Log To Console    \nStep 7: Deattenuation scells 197 and 198
    Set Attenuation    ${CELL_197}    0dB
    Sleep    10s
    QXDM.Start Log Collecting
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step7_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step7_DLUL
#    Step 8
    Log To Console    \nStep 8: Start VoNR call
    QXDM.Start Log Collecting
    Start Voice Call    VC    UE_1    +555800903300998    60s
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step8_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step8_DLUL_Vonr
#    Step 9
    Log To Console    \nStep 9: Stop VoNR call
    QXDM.Start Log Collecting
    Await Voice Call Finish    VC
    Sleep    20s
    QXDM.Stop Log Collecting
    ${step9_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step9_DLUL
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    taf.ue.Stop Data Transfer    dt_name=DT_UL
#    Analysis
    Log To Console    \nAnalyzing Logs...
    @{uplink_carriers}=    Create List    0    1
    @{downlink_carriers}=    Create List    0    1
    Log to Console    \nVerifying Step 2
    Verify Carrier Aggregation Ongoing Both Ways    ${step2_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
    Log to Console    \nVerifying Step 3
    Verify Carrier Aggregation During Vonr Call    ${step3_uelog}[0][0]
    Log to Console    \nVerifying Step 4
    Verify Carrier Aggregation Ongoing Both Ways    ${step4_uelog}[0][0]    ${downlink_carriers}     ${uplink_carriers}
    Log to Console    \nVerifying Step 7
    Verify Carrier Aggregation With Cellaggrlevel Not Eligible    ${step8_uelog}[0][0]
    Log to Console    \nVerifying Step 8
    Verify Carrier Aggregation During Vonr Call    ${step8_uelog}[0][0]    cell_aggr_level_eligible=${FALSE}
    Log to Console    \nVerifying Step 9
    Verify Carrier Aggregation With Cellaggrlevel Not Eligible    ${step9_uelog}[0][0]
    [Teardown]    Unblock Cells After TC    NRBTS-50819/NRCELL-999    NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-99

C_B2 Teardown
    Log To Console    C_B2 Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_196}     90dB
    Set Attenuation    ${CELL_197}     90dB
    C_B2 Teardown Recommissioning
    Verify Bts Is Operational
    Common Test Teardown

Change Attenuation Gradually
    [Arguments]    ${cell}    ${starting_attenuation}    ${target_attenuation}    ${step}
    FOR    ${attenuation}    IN RANGE    ${starting_attenuation}    ${target_attenuation}    ${step}
        Set Attenuation    ${cell}     ${attenuation}dB
    END

BD_B1 Setup
    Set TESTNAME without spaces
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Set Rd Flags    setup
    BD_B1 Setup Recommissioning
    Verify Bts Is Operational
    Block Cells Before TC    NRBTS-50819/NRCELL-999    NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-99
    ...    NRBTS-50819/NRCELL-198    NRBTS-50819/NRCELL-197    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195
    Wait Until Counter Collection Time

CB005935_BD_B1_Interworking_with_CB008124_UL_Resource_Reservation_and_Scheduling_by_Configured_Grants_Type_2
    Log To Console    \nStep 1: UE attach
    Log To Console    \nAttaching UE to Cell 190
    Set Attenuation    ${CELL_193}    90dB
    Attach Ue And Start Ping    attenuation=30    cell=${CELL_190}
    ${attach_time}=    Get Current Date
    Sleep    2s
    #Step 2
    Start Tcpdump On CU    filename=${test_name}_step2_scell_addition.pcap
    Log To Console    \nStep 2: Trigger scell addition to cell 193
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=70s
        ...     throughput=280Mbits/sec
        ...     protocol=udp
        ...     packet_size=1200
    Change Attenuation Gradually    ${CELL_190}    30   0    -2
    Change Attenuation Gradually    ${CELL_193}    90   0    -2
    Sleep    28s
    taf.ue.Stop Data Transfer  dt_name=DT_DL
    Log To Console    \nGathering pcap from scell addition
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_step2_scell_addition.pcap
    Start Bts Log  btslog
    Sleep    2s
    #Step 3
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL
    ...     ue_alias=UE_1
    ...     direction=ul
    ...     duration=400s
    ...     throughput=100Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    ...     port=5003
    Log To Console    \nStep 3: Check GBR_UL
    QXDM.Start Log Collecting
    Sleep    25s
    Stop And Collect Btslog  btslog  ${LOG_PATH}/Step_3_syslog
    QXDM.Stop Log Collecting
    ${step3_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_Step_3_Check_GBR_UL
    #Step 4
    Start Bts Log  btslog
    Sleep    10s
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL_9
    ...     ue_alias=UE_1
    ...     direction=ul
    ...     duration=200s
    ...     throughput=50Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    Log To Console    \nStep 4: Check Scell_activation_during_add_non_GBR_tput
    QXDM.Start Log Collecting
    Sleep    25s
    Stop And Collect Btslog  btslog  ${LOG_PATH}/Step_4_syslog
    QXDM.Stop Log Collecting
    ${step4_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_Step_4_Check_Scell_activation_during_add_non_GBR_tput
#    Step 5
    taf.ue.Stop Data Transfer  dt_name=DT_UL_9
    taf.ue.Stop Data Transfer    dt_name=DT_UL
    Sleep    5s
    Start Bts Log  btslog
    Sleep    5s
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL
    ...     ue_alias=UE_1
    ...     direction=ul
    ...     duration=400s
    ...     throughput=100Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    ...     port=5003
    QXDM.Start Log Collecting
    Log To Console    \nStep 5: Check Scell_deactivation_after_stop_non_GBR_tput
    Sleep    40s
    Stop And Collect Btslog  btslog  ${LOG_PATH}/Step_5_syslog
    QXDM.Stop Log Collecting
    ${step5_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_Step_5_Check_Scell_deactivation_after_stop_non_GBR_tput
    # Step 6
    Start Bts Log  btslog
    Sleep    2s
    taf.ue.Start Data Transfer
    ...     dt_name=DT_DL
    ...     ue_alias=UE_1
    ...     direction=dl
    ...     duration=400s
    ...     throughput=280Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    QXDM.Start Log Collecting
    Log To Console    \nStep 6: Check Scell activation after start non GBR DL tput
    Sleep    20s
    Stop And Collect Btslog  btslog  ${LOG_PATH}/Step_6_syslog
    QXDM.Stop Log Collecting
    ${step6_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_Step_6_Check_Scell_activation_after_start_non_GBR_DL_tput
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    Sleep    2s
    #Step 7
    Log To Console    \nStep 7: Waiting for Context Modification for the UE
    taf.ue.Stop Data Transfer    dt_name=DT_UL
    Wait Certain Time After Attach    ${attach_time}    580
    Start Bts Log  btslog
    Sleep    25s
    #Step 8
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL_7
    ...     ue_alias=UE_1
    ...     direction=ul
    ...     duration=460s
    ...     throughput=240Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    ...     port=5007
    Log To Console    \nStep 8: Check Scell activation after start new non GBR UL tput
    QXDM.Start Log Collecting
    Sleep    25s
    Stop And Collect Btslog  btslog  ${LOG_PATH}/Step_8_syslog
    QXDM.Stop Log Collecting
    ${step8_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_Step_8_Check_Scell_activation_after_start_new_non_GBR_UL_tput
#    Step 9
    Log To Console    \nStep 9: Trigger_transform_precoder_enabled
    QXDM.Start Log Collecting
    Change Attenuation Gradually    ${CELL_190}    0   40   2
    Change Attenuation Gradually    ${CELL_193}    0   50   2
    Sleep    20s
    Log To Console    \nGathering pcap from transform_precoder_enabled
    QXDM.Stop Log Collecting
    ${step9_uelog}=    QXDM.Download Log    filepath=${LOG_PATH}/${test_name}_step9_Trigger_transform_precoder_enabled
    taf.ue.Stop Data Transfer    dt_name=DT_UL_7
    Log To Console    Waiting for counter period..
    Wait Certain Time After Attach    ${attach_time}    960
    Log To Console    Checking Counters..
    Verify BD_B1 Counter Values
    Log To Console   Analyzing logs...
    ${Step3_status}=    Run Keyword And Return Status    Analyze Bd_B1 Step3    ${step3_uelog}[0][0]    ${LOG_PATH}/Step_3_syslog/btslog
    ${Step4_status}=    Run Keyword And Return Status    Analyze Bd_B1 Step4    ${step4_uelog}[0][0]    ${LOG_PATH}/Step_4_syslog/btslog
    ${Step5_status}=    Run Keyword And Return Status    Analyze Bd_B1 Step5    ${step5_uelog}[0][0]    ${LOG_PATH}/Step_5_syslog/btslog
    ${Step6_status}=    Run Keyword And Return Status    Analyze Bd_B1 Step6    ${step6_uelog}[0][0]    ${LOG_PATH}/Step_6_syslog/btslog
    ${Step8_status}=    Run Keyword And Return Status    Analyze Bd_B1 Step8    ${step8_uelog}[0][0]    ${LOG_PATH}/Step_8_syslog/btslog
    ${Step9_status}=    Run Keyword And Return Status    Analyze Bd_B1 Step9    ${step9_uelog}[0][0]
    @{results}=    Create List   ${Step3_status}    ${Step4_status}    ${Step5_status}    ${Step6_status}    ${Step8_status}    ${Step9_status}
    List Should Not Contain Value    ${results}    ${FALSE}
    [Teardown]    Unblock Cells After TC    NRBTS-50819/NRCELL-999    NRBTS-50819/NRCELL-199    NRBTS-50819/NRCELL-99
    ...           NRBTS-50819/NRCELL-197    NRBTS-50819/NRCELL-198    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195

BD_B1 Teardown
    Log To Console    C_B2 Teardown
    Run Keyword And Ignore Error    taf.ue.Detach UE    UE_1
    ssh.disconnect    connection=${APPSERVER}
    Run Keyword And Ignore Error    Tshark Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_193}     90dB
    Add Scout Scf Id To Test Data
    Set Rd Flags    teardown
    BD_B1 Teardown Recommissioning
    Verify Bts Is Operational
    WATCHDOG.Stop Watching Alarms
    Make Snapshot In Case Of Error

######    RECOMMISSIONINGS    ######
AA_B4 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRDU-1
    ...                           dlToUlContributionRatio=50
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actSlowPrbPooling=true
    ...                           actConnRrcPooling=true    actScheUePooling=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=196
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=blind
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellAdditionMethod
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellOperationalMode
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellOperationalMode=dlAndUl
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb


AA_B4 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRDU-1    dlToUlContributionRatio=101
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellAdditionMethod=covBasedA4
    ...                                                                              sCellOperationalMode=dlOnly
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellOperationalMode=dlOnly
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

AB_B8 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based    A1-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    param_name=sCellAdditionMethod
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    param_name=sCellOperationalMode
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    param_name=sCellPrio
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellPrio
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRDU-1    dlToUlContributionRatio=50
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellOperationalMode=dlAndUl
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-193/NRREL-1    sCellOperationalMode=dlAndUl
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-193/NRREL-2    lcrId=196
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=198
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819    actOverheatingAssistance=false    sCellActivationMethod=blind
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190    a2MeashoEnabledSA=rsrp    actEnhMultipleDedicatedBWPs=true
    ...    a2MeasReleaseEnabled=none    actCDrx=true
        Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  list_name=a2MeasRedirectSsbRsrp
    ...    a2HysteresisRedirectSsbRsrp=0    a2ThresholdRedirectSsbRsrp=39    a2TimeToTriggerRedirectSsbRsrp=ms480
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  list_name=a2MeashoSsbRsrpSA
    ...    a2ThresholdhoSsbRsrpSA=40    a2HysteresishoSsbRsrpSA=0    a2TimeToTriggerhoSsbRsrpSA=ms480
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1HysteresisSCellAddSsbRsrp=0    a1ThresholdSCellAddSsbRsrpFDD=56    a1ThresholdSCellAddSsbRsrpTDD=90
    ...    a1TimeToTriggerSCellAddSsbRsrp=40ms
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  list_name=a1MeashoSsbRsrpSA
    ...    a1HysteresishoSsbRsrpSA=0    a1ThresholdhoSsbRsrpSA=127    a1TimeToTriggerhoSsbRsrpSA=ms480
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-196    actCDrx=false   qRxLevMin=-30
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193  list_name=a2MeashoSsbRsrpSA
    ...    a2ThresholdhoSsbRsrpSA=56    a2HysteresishoSsbRsrpSA=0    a2TimeToTriggerhoSsbRsrpSA=ms480
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-198    actEnhMultipleDedicatedBWPs=true
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-193    actEnhMultipleDedicatedBWPs=true    actCDrx=true
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-197
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    sCellDeactivationTimerGNB=infinity
    IF    ${IS_SW_24R3}    Add Parameters To Delta    MRBTS-50819/NRBTS-50819/NRCELL-196        actCDrxVoNR=false
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

AB_B8 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRDU-1    dlToUlContributionRatio=101
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-193/NRREL-2    lcrId=194
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-197/NRREL-1    sCellAdditionMethod=blind
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-197/NRREL-2    sCellAdditionMethod=blind
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-193/NRREL-1    sCellOperationalMode=dlOnly
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819    actOverheatingAssistance=true    sCellActivationMethod=bufferBased
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190    a2MeashoEnabledSA=none
    ...    a2MeasReleaseEnabled=rsrp    actCDrx=false
        Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  list_name=a2MeasRedirectSsbRsrp
    ...    a2HysteresisRedirectSsbRsrp=0    a2ThresholdRedirectSsbRsrp=47    a2TimeToTriggerRedirectSsbRsrp=ms480
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  list_name=a2MeashoSsbRsrpSA
    ...    a2ThresholdhoSsbRsrpSA=49    a2HysteresishoSsbRsrpSA=0    a2TimeToTriggerhoSsbRsrpSA=ms480
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  list_name=a1MeashoSsbRsrpSA
    ...    a1HysteresishoSsbRsrpSA=0    a1ThresholdhoSsbRsrpSA=57    a1TimeToTriggerhoSsbRsrpSA=ms480
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1HysteresisSCellAddSsbRsrp=0    a1ThresholdSCellAddSsbRsrpFDD=44    a1ThresholdSCellAddSsbRsrpTDD=60
    ...    a1TimeToTriggerSCellAddSsbRsrp=40ms
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197  list_name=a2MeashoSsbRsrpSA
    ...    a2ThresholdhoSsbRsrpSA=49    a2HysteresishoSsbRsrpSA=0    a2TimeToTriggerhoSsbRsrpSA=ms480
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193  list_name=a2MeashoSsbRsrpSA
    ...    a2ThresholdhoSsbRsrpSA=49    a2HysteresishoSsbRsrpSA=0    a2TimeToTriggerhoSsbRsrpSA=ms480
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-196
    ...    qRxLevMin=-70    actCDrx=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=covBasedA4
    ...  sCellOperationalMode=dlOnly    sCellPrio=1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellAdditionMethod=covBasedA4
    ...  sCellOperationalMode=dlOnly    sCellPrio=2
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    sCellDeactivationTimerGNB=ms1280
    ...  actEnhMultipleDedicatedBWPs=false
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    sCellDeactivationTimerGNB=ms1280
    ...  actEnhMultipleDedicatedBWPs=false    actCDrx=false
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    sCellDeactivationTimerGNB=ms1280
    ...  actCDrx=false
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    sCellDeactivationTimerGNB=ms1280
    ...  actEnhMultipleDedicatedBWPs=false
    IF    ${IS_SW_24R3}    Add Parameters To Delta    MRBTS-50819/NRBTS-50819/NRCELL-196        actCDrxVoNR=true
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

AB_B6 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based    A1-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actSCellSwapFr1=a6BasedSa  actSaUeBasedAnrNr=false
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRANR-1    actAutoNrNbRemoval=false
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=covBasedA1
    ...    sCellOperationalMode=dlAndUl
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=covBasedA1
    ...    lcrId=196
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-6    sCellAdditionMethod=covBasedA1
    ...    sCellOperationalMode=dlAndUl
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellAdditionMethod
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellOperationalMode
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190    actUlClosedLoopPwrCtrl=disabled
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-193    actUlClosedLoopPwrCtrl=disabled
    ...    a6MeasSCellSwapEnabled=rsrp    reportAmountA6MeasSCellSwap=r4
    ...    reportIntervalA6MeasSCellSwap=ms1024    thresholdSCellSwapSourceRsrp=96
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193  list_name=a6MeasSCellSwapSsbRsrp
    ...    a6HysteresisSCellSwapSsbRsrp=0    a6OffsetSCellSwapSsbRsrp=3    a6TimeToTrigSCellSwapSsbRsrp=ms480
    ...    useAllowedCellListRsrp=false
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1HysteresisSCellAddSsbRsrp=0    a1ThresholdSCellAddSsbRsrpFDD=56    a1ThresholdSCellAddSsbRsrpTDD=90
    ...    a1TimeToTriggerSCellAddSsbRsrp=40ms
    Add Parameters To Delta    MRBTS-50819/NRBTS-50819/NRCELL-195    thresholdSCellSwapSourceRsrp=96
    ...    actUlClosedLoopPwrCtrl=disabled    a6MeasSCellSwapEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195  list_name=a6MeasSCellSwapSsbRsrp
    ...    a6HysteresisSCellSwapSsbRsrp=0    a6OffsetSCellSwapSsbRsrp=3    a6TimeToTrigSCellSwapSsbRsrp=ms480
    ...    useAllowedCellListRsrp=false
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-196    actUlClosedLoopPwrCtrl=disabled
    ...    actCDrx=false
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRDRB_RLC_AM-1    ulTReassemblyIBCA=30
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRDRB_RLC_AM-2    ulTReassemblyIBCA=30
    IF    ${IS_SW_24R3}    Add Parameters To Delta       MRBTS-50819/NRBTS-50819/NRCELL-196   actCDrxVoNR=false
    IF    ${IS_SW_24R3}    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                                actEnhanceIntraNrIntraFreqAnr=false    actSaIntraFreqAnrDrxProf=false
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

AB_B6 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actSCellSwapFr1=disabled    actSaUeBasedAnrNr=true
    ...    actEnhanceIntraNrIntraFreqAnr=true
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRANR-1    actAutoNrNbRemoval=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellAdditionMethod=covBasedA4
    ...                                                                              sCellOperationalMode=dlOnly
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-6    param_name=sCellAdditionMethod
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-6    param_name=sCellOperationalMode
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    thresholdSCellSwapSourceRsrp=58
    ...    actUlClosedLoopPwrCtrl=pucch
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1HysteresisSCellAddSsbRsrp=0    a1ThresholdSCellAddSsbRsrpFDD=44    a1ThresholdSCellAddSsbRsrpTDD=60
    ...    a1TimeToTriggerSCellAddSsbRsrp=40ms
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=thresholdSCellSwapSourceRsrp
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellOperationalMode=dlOnly
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-190    actUlClosedLoopPwrCtrl=pucchPuschSrs
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-193    actUlClosedLoopPwrCtrl=pucch
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a6MeasSCellSwapEnabled
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=a6MeasSCellSwapSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=reportAmountA6MeasSCellSwap
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=reportIntervalA6MeasSCellSwap
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=thresholdSCellSwapSourceRsrp
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRCELL-196    actUlClosedLoopPwrCtrl=pucch    actCDrx=true
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRDRB_RLC_AM-1    ulTReassemblyIBCA=40
    Add Parameters To Delta  MRBTS-50819/NRBTS-50819/NRDRB_RLC_AM-2    ulTReassemblyIBCA=40
    IF    ${IS_SW_24R3}    Add Parameters To Delta       MRBTS-50819/NRBTS-50819/NRCELL-196   actCDrxVoNR=true
    IF    ${IS_SW_24R3}    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                                actEnhanceIntraNrIntraFreqAnr=true    actSaIntraFreqAnrDrxProf=true
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

C_B2 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actDrbProfileForCellAggrLevel}=    Create List    FR1_SA
    @{actMeasBasedSCellAdditionSa}=    Create List    A1-based
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    param_name=sCellAdditionMethod
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    param_name=sCellOperationalMode
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-3    param_name=sCellAdditionMethod
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-3    param_name=sCellOperationalMode
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-5    param_name=sCellAdditionMethod
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-5    param_name=sCellOperationalMode
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999/NRREL-1    param_name=sCellAdditionMethod
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999/NRREL-1    param_name=sCellOperationalMode
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999/NRREL-2    param_name=sCellAdditionMethod
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999/NRREL-2    param_name=sCellOperationalMode
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=198
    ...                      sCellOperationalMode=dlAndUl    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellOperationalMode=dlAndUl
    ...                                                                              sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-1    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-2    sCellAdditionMethod=blind
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-1    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-2    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-3    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    sCellDeactivationTimerGNB=infinity
    ...                      actUlClosedLoopPwrCtrl=disabled    a1MeashoEnabledSA=none    maxNumScellsDlFr1=3
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    sCellDeactivationTimerGNB=infinity
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    sCellDeactivationTimerGNB=infinity
    ...                      actUlClosedLoopPwrCtrl=disabled
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    sCellDeactivationTimerGNB=infinity    maxNumScellsDlFr1=3
    ...                      actUlClosedLoopPwrCtrl=disabled
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    sCellActivationMethod=blind
    ...                      actOverheatingAssistance=false
    ...    actBufferBasedSCellAddition=disabled    maxNumScellsUl=2    actDrbProfileForCellAggrLevel=@{actDrbProfileForCellAggrLevel}
    ...    actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-14    actDddsReduction=false    actLostPduFastRetx=false
    ...    actOptDataFlowRateEst=false    dscp=10    queuingDelayDiscarding=Disabled
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-14    param_name=reTxPrioritizationType
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB_MAC-2    param_name=schedulBSD
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB_PDCP-2    pdcpDelayThreshRetxMode=disabled
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

C_B2 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{cellAggrLevel}=                    Create List    FR1 CA eligible
    @{actDrbProfileForCellAggrLevel}=    Create List    disabled
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRDRB-14    cellAggrLevel=@{cellAggrLevel}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1
    ...                      sCellAdditionMethod=covBasedA4    sCellOperationalMode=dlOnly
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194
    ...                      sCellOperationalMode=dlOnly    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=covBasedA4
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-6    param_name=sCellAdditionMethod
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellOperationalMode=dlOnly
    ...                                                                              sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-1    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-2    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-3    sCellOperationalMode=dlOnly
    ...                                                                              sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194/NRREL-5    sCellOperationalMode=dlOnly
    ...                                                                              sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-1    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-2    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-3    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999/NRREL-1    sCellOperationalMode=dlOnly
    ...                                                                              sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-999/NRREL-2    sCellOperationalMode=dlOnly
    ...                                                                              sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    sCellDeactivationTimerGNB=ms1280
    ...                      actUlClosedLoopPwrCtrl=pucchPuschSrs    a1MeashoEnabledSA=rsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=maxNumScellsDlFr1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    sCellDeactivationTimerGNB=ms1280
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    sCellDeactivationTimerGNB=ms1280
    ...                      actUlClosedLoopPwrCtrl=pucch
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    sCellDeactivationTimerGNB=ms1280
    ...                      actUlClosedLoopPwrCtrl=pucch
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    param_name=maxNumScellsDlFr1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    sCellActivationMethod=bufferBased
    ...                      actOverheatingAssistance=true
    ...    actBufferBasedSCellAddition=oneShot_Dl_Fr1    maxNumScellsUl=1    actDrbProfileForCellAggrLevel=@{actDrbProfileForCellAggrLevel}
    ...    actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-14    actDddsReduction=true    actLostPduFastRetx=true
    ...    actOptDataFlowRateEst=true    dscp=0    queuingDelayDiscarding=Controlled Delay (CoDel)    reTxPrioritizationType=retxPrioSameLink
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB_MAC-2    schedulBSD=50ms
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB_PDCP-2    pdcpDelayThreshRetxMode=delayThresh1and2Enabled
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

BD_B1 Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based    A1-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7
    ...                      sCellOperationalMode=dlAndUl    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1
    ...                      sCellOperationalMode=dlAndUl    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    actUlCgType2=true    maxGBRTrafficLimit=30
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=ulConfiguredGrantType2
    ...    maxGBRAndCgType2TrafficLimit=90    ulCgMaxNumPrbs=24    ulCgMaxNumUeUl=1    ulCgPrbStartOffset=0
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1HysteresisSCellAddSsbRsrp=0    a1ThresholdSCellAddSsbRsrpFDD=56    a1ThresholdSCellAddSsbRsrpTDD=90
    ...    a1TimeToTriggerSCellAddSsbRsrp=40ms
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    actUlCgType2=true    maxGBRTrafficLimit=30
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    list_name=ulConfiguredGrantType2
    ...    maxGBRAndCgType2TrafficLimit=35    ulCgMaxNumPrbs=16    ulCgMaxNumUeUl=1    ulCgPrbStartOffset=0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-12    nrDrbUlCgDN=MRBTS-50819/NRBTS-50819/NRULCG_PROFILE-2
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-16    nrDrbUlCgDN=MRBTS-50819/NRBTS-50819/NRULCG_PROFILE-1
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

BD_B1 Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1
    ...                      sCellOperationalMode=dlOnly    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7
    ...                      sCellOperationalMode=dlOnly    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    actUlCgType2=false
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=maxGBRTrafficLimit
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=ulConfiguredGrantType2
    ...    ulCgMaxNumPrbs=12    ulCgMaxNumUeUl=1    ulCgPrbStartOffset=0
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    list_name=a1MeasSCellAddSsbRsrp
    ...    a1HysteresisSCellAddSsbRsrp=0    a1ThresholdSCellAddSsbRsrpFDD=44    a1ThresholdSCellAddSsbRsrpTDD=60
    ...    a1TimeToTriggerSCellAddSsbRsrp=40ms
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    actUlCgType2=false
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=maxGBRTrafficLimit
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    list_name=ulConfiguredGrantType2
    ...    ulCgMaxNumPrbs=12    ulCgMaxNumUeUl=1    ulCgPrbStartOffset=0
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-12    param_name=nrDrbUlCgDN
    Add Param Delete To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRDRB-16    param_name=nrDrbUlCgDN
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

Testsuite Setup Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{carrierAggregationSupportList}=    Create List    ca_Fdd_Fdd    ca_Fdd_Fr1Tdd_Sa    ca_Fr1Tdd_Sa
    ...                                                 ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Fr1Tdd_Nsa    ca_Fr1Tdd_Nsa
    ...                                                 ca_Fr1Tdd_Fdd_Nsa    ca_Fdd_Any_Sa
    ...                                                 ca_Fr1Tdd_Any_Sa    ca_Fdd_Fdd_Sa_WithUl
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRDU-1
    ...                           carrierAggregationSupportList=@{carrierAggregationSupportList}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actSaUeBasedAnrEutra=false
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    increaseK1ULCA=K1 not increased    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    increaseK1ULCA=K1 not increased    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    increaseK1ULCA=K1 not increased    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    increaseK1ULCA=K1 not increased    timingAdvanceOffset=n25600
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    increaseK1ULCA=K1 not increased    timingAdvanceOffset=n25600
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

Testsuite Teardown Recommissioning
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    @{carrierAggregationSupportList}=    Create List    ca_Fdd_Fdd    ca_Fdd_Fr1Tdd_Sa    ca_Fr1Tdd_Sa
    ...                                                 ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Fr1Tdd_Nsa    ca_Fr1Tdd_Nsa
    ...                                                 ca_Fr1Tdd_Fdd_Nsa    ca_Fdd_Any_Sa    ca_Fr1Tdd_Any_Sa
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRDU-1
    ...                           carrierAggregationSupportList=@{carrierAggregationSupportList}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actSaUeBasedAnrEutra=true
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    param_name=increaseK1ULCA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    param_name=increaseK1ULCA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    param_name=increaseK1ULCA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    param_name=increaseK1ULCA
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    param_name=increaseK1ULCA
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-191    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-192    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-193    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-194    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-197    timingAdvanceOffset=n0
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-198    timingAdvanceOffset=n0
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb
