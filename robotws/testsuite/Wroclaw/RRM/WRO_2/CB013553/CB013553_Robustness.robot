*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS26R1
...    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../CB013553/Keywords_CB013553.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     CB013553_variables.robot
Library      ../CB013553/egate_console_log_verifier.py

*** Variables ***
${IPHY_11116_100_20}=      ${CURDIR}/config/iphy_11116_100_20.xml
${SCFC_11116_100_20}=      scfc_11116_100_20.xml
${cfg_11116_100_20}=       ${CURDIR}/config/cfg_11116_100_20.cfg
${IPHY_9422_100_20}=      ${CURDIR}/config/iphy_9422_100_20.xml
${SCFC_9422_100_20}=      scfc_9422_100_20.xml
${cfg_9422_100_20}=       ${CURDIR}/config/cfg_9422_100_20.cfg
${IPHY_11116_60_10}=      ${CURDIR}/config/iphy_11116_60_10.xml
${SCFC_11116_60_10}=      scfc_11116_60_10.xml
${cfg_11116_60_10}=       ${CURDIR}/config/cfg_11116_60_10.cfg
${IPHY_9422_60_10}=      ${CURDIR}/config/iphy_9422_60_10.xml
${SCFC_9422_60_10}=      scfc_9422_60_10.xml
${cfg_9422_60_10}=       ${CURDIR}/config/cfg_9422_60_10.cfg
${FILE}=    /opt/iphy/latest/egate_console.log

*** Test Cases ***
CB013553_Robustness_TC1_Full_througput_11116_100_tdd_20_fdd_PMCD_MBA_SBA_CU
    [Setup]    Run Keywords    Prepare Test Setup For One Real Gnb    11116_100_20
     ...    AND    Start Listening On TCE Port
     ...    AND    Start Tshark For TCE Msgs And Store Alias

    Attach SA UE And Establish PDU Session
    Start Subscriber Trace
    Start Specific Data UL Traffic    ue_id=1   pdu_id=1    mbps_per_trf_id=175    first_trf_id=1    last_trf_id=3
    Trigger A1 Measurement    ue_id=1    meas_id=3    srsrp_nr=90    srsrq_nr=95
    Wait for Traffic to Stabilize    inactive_timer=10
    Get PUSCH UE Stats from Egate
    Deregister Ue    ue_id=1
    Flush Egate Logs
    Verify Throughput Value From File    ${FILE}    Total    Average    380    395

    [Teardown]    Run Keywords    Add Scout Data Info To Testcase
    ...    AND    Stop Subscriber Trace    ue_id=1
    ...    AND    Stop Tshark    alias=${TCE_ALIAS}
    ...    AND    Stop Listening On TCE Port
    ...    AND    Stop Vm Ethernet Interfaces
    ...    AND    Teardown Egate And Collect Logs

CB013553_Robustness_TC2_Full_througput_9422_100_tdd_20_fdd
    [Setup]    Run Keywords    Prepare Test Setup For One Real Gnb    9422_100_20
     ...    AND    Start Listening On TCE Port
     ...    AND    Start Tshark For TCE Msgs And Store Alias

    Attach SA UE And Establish PDU Session
    Start Specific Data UL Traffic    ue_id=1   pdu_id=1    mbps_per_trf_id=175    first_trf_id=1    last_trf_id=6
    Trigger A1 Measurement    ue_id=1    meas_id=3    srsrp_nr=90    srsrq_nr=95
    Wait for Traffic to Stabilize    inactive_timer=10
    Get PUSCH UE Stats from Egate
    Deregister Ue    ue_id=1
    Flush Egate Logs
    Verify Throughput Value From File    ${FILE}    Total    Average    760    820

    [Teardown]    Run Keywords    Add Scout Data Info To Testcase
    ...    AND    Stop Tshark    alias=${TCE_ALIAS}
    ...    AND    Stop Listening On TCE Port
    ...    AND    Stop Vm Ethernet Interfaces
    ...    AND    Teardown Egate And Collect Logs

CB013553_Robustness_TC3_Full_througput_11116_60_tdd_10_fdd
    [Setup]    Run Keywords    Prepare Test Setup For One Real Gnb    11116_60_10
     ...    AND    Start Listening On TCE Port
     ...    AND    Start Tshark For TCE Msgs And Store Alias

    Attach SA UE And Establish PDU Session
    Start Specific Data UL Traffic    ue_id=1   pdu_id=1    mbps_per_trf_id=175    first_trf_id=1    last_trf_id=3
    Trigger A1 Measurement    ue_id=1    meas_id=3    srsrp_nr=90    srsrq_nr=95
    Wait for Traffic to Stabilize    inactive_timer=10
    Get PUSCH UE Stats from Egate
    Deregister Ue    ue_id=1
    Flush Egate Logs
    Verify Throughput Value From File    ${FILE}    Total    Average    190    230

    [Teardown]    Run Keywords    Add Scout Data Info To Testcase
    ...    AND    Stop Tshark    alias=${TCE_ALIAS}
    ...    AND    Stop Listening On TCE Port
    ...    AND    Stop Vm Ethernet Interfaces
    ...    AND    Teardown Egate And Collect Logs

CB013553_Robustness_TC4_Full_througput_9422_60_tdd_10_fdd_PMCD_MBA_SBA_DU
    [Setup]    Run Keywords    Prepare Test Setup For One Real Gnb    9422_60_10
     ...    AND    Start Listening On TCE Port
     ...    AND    Start Tshark For TCE Msgs And Store Alias

    Attach SA UE And Establish PDU Session
    Start Subscriber Trace
    Start Specific Data UL Traffic    ue_id=1   pdu_id=1    mbps_per_trf_id=175    first_trf_id=1    last_trf_id=4
    Trigger A1 Measurement    ue_id=1    meas_id=3    srsrp_nr=90    srsrq_nr=95
    Wait for Traffic to Stabilize    inactive_timer=10
    Validate Trace Recording Session Elements MBA    filter=nsetapx.recordingSessionReportList == 2 && nsetapx.uplinkTxSwitchingOption == 2
    Validate Trace Recording Session Elements SBA    filter=nsetapx.recordingSessionReportList == 2 && nsetapx.uplinkTxSwitchingOption == 2
    Get PUSCH UE Stats from Egate
    Deregister Ue    ue_id=1
    Flush Egate Logs
    Verify Throughput Value From File    ${FILE}    Total    Average    440    470

    [Teardown]    Run Keywords    Add Scout Data Info To Testcase
    ...    AND    Stop Subscriber Trace    ue_id=1
    ...    AND    Stop Tshark    alias=${TCE_ALIAS}
    ...    AND    Stop Listening On TCE Port
    ...    AND    Stop Vm Ethernet Interfaces
    ...    AND    Teardown Egate And Collect Logs
