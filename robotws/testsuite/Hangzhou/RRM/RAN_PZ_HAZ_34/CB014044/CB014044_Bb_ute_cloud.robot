*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

Suite Setup    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T_8pipes
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     H091_Teardown
Force Tags    tl-CLOUD_5G_I_BOO_AP_LOO    release-25R1
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Test Cases ***
[1]CB014044_Bb#B004_Activation_of_Non_GBR_High_buffer_UE_prioritization_in_TD_scheduler_TDD_DL_actBestNList_actTdPfMetricOpt_enable
    [Documentation]
    ...    1. DESCRIPTION
    ...    This User Scenario aims to enable the high buffer UE prioritization in TD scheduler for TDD cell on DL with
    ...    actBestNList=DL_UL and actTdPfMetricOpt=DL or DL_UL.
    ...    2. TEST ENVIRONMENT AND SETTINGS
    ...    - 1 X ASIL
    ...    - 1 X ABIP
    ...    - 1 X 5G RU(TDD:AVHA)
    ...    - 8 X UEs: SPARK 8 UEs
    ...    2.1 Testing Tools
    ...    - Wireshark/Tcpdump/L1/L2 traces/btslog/snapshot
    ...    2.2 Test Automation
    ...    N/A
    ...    3. TEST CASE INFORMATION
    ...    3.1 Definitions from the Test Plan
    ...    NB configuration (SA, FR1,TDD, classicBTS,100Mhz)
    ...    - NRCELL.actRat1Alloc = True
    ...    - NRBTS.NRCELL.actDlSchLowBufferOpt=True
    ...    - NRBTS.NRCELL.actUlSchLowBufferOpt=True
    ...    - NRBTS.NRCELL.actTdHighBufUePrio=disable
    ...    - actSlowPrbPooling = false
    ...    - NRBTS.NRCELL.pucchModeSelect=longPucch
    ...    - NRBTS.NRCELL.lteNrDssMode=none
    ...    - NRCELL.actDlMuMimoEnh = False
    ...    - NRBTS/NRDU.carrierAggregationSupportList is set to None
    ...    - NRBTS.actSliceAwareSchedulerUlAndEnh is set to False(default value)
    ...    - NRBTS.actSliceAwareScheduler is set to 'False'.
    ...    - NRBTS.NRCELL.dlHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.ulHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.actBestNList=DL_UL
    ...    - NRBTS.NRCELL.actFdAlgoEnh=disabled
    ...    - NRBTS.NRCELL.actTdPfMetricOpt=DL_UL
    ...    - maxNumPdschAllocationPerSlot=4
    ...    3.2 Required Logs
    ...    -L1/L2 traces
    ...    -Syslog
    ...    -KPIs
    ...    -snapshot
    ...    4. TESTING INSTRUCTIONS
    ...    4.1 Preconditions
    ...    Golden RRM parameter set
    ...    4.2 Test Steps
    ...    Refer test step description
    ...    4.3 Postconditions
    ...    - For each UE UL and DL data transmission is successful.
    ...    Acceptance criteria:
    ...    - After enabling high buffer prioritization feature, number of high buffer UEs being scheduled increased.
    ...    - DL/UL E2E throughput is increased.
    ...    - Overall PRB Utilization is increased.
    ...    - DL/UL E2E packet delay is reduced. For some UEs with low buffer, packet delay may marginally increase.
    ...    | 1 | 5G cell on air normally with precondition settings
    ...    Expected:
    ...    cell onair without unexpected fault
    ...    | 2 | attach 8 UEs to the 5G cell with same APN, same 5QI, same air condition.
    ...    3UEs transfer low DL/UL data such as 1Mbps DL and 100Kbps UL per UE,  3UEs transfer 100Mbps DL data and 10Mbps UL per UE,
    ...    2UEs transfer 400Mbps DL data and 40Mbps UL per UE. Data transfer last more than 10 minutes
    ...    Expected:
    ...    For each UE UL and DL data transmission is successful,
    ...    record the 14044 disable KPI result as record1 in a whole 10 minutes in the data transfer procedure.
    ...    Monitor KPIs are included in the 26R1_CB014044_5G-KPI-impact_ver1.0.1 table.
    ...    | 3 | update actTdHighBufUePrio=DL without UE detach and data transfer last more than 10 minutes
    ...    Expected:
    ...    For each UE UL and DL data transmission is successful,
    ...    record the actTdHighBufUePrio=DL KPI result as record2 in a whole 10 minutes in the data transfer procedure.
    ...    | 4 | compare record1 and record2
    ...    Expected:
    ...    1. Cell throughput in DL should increased, such as NR_5088d and NR_5258a
    ...    2. PRB Utilization in DL should increased, such as NR_5114b
    ...    3. number of high buffer UEs being scheduled increased
    ...    | 5 | update actTdHighBufUePrio=DL_UL without UE detach and data transfer last more than 10 minutes
    ...    Expected:
    ...    For each UE UL and DL data transmission is successful,
    ...    record the actTdHighBufUePrio=DL_UL KPI result as record3 in a whole 10 minutes in the data transfer procedure.
    ...    | 6 | compare record3 and record2
    ...    Expected:
    ...    record3 and record2 KPIs should in the same level
    ...    | 7 | update actTdHighBufUePrio=UL without UE detach and data transfer last more than 10 minutes
    ...    Expected:
    ...    For each UE UL and DL data transmission is successful,
    ...    record the actTdHighBufUePrio=UL KPI result as record4 in a whole 10 minutes in the data transfer procedure.
    ...    | 8 | compare record4 and record1
    ...    Expected:
    ...    record4 and record1 KPIs should in the same level for DL
    No Operation


*** Keywords ***
H091_Teardown
    Delta Commission Parameters    ${RGQuotaRecover}
    Common Test Teardown And Stop Capture Logs