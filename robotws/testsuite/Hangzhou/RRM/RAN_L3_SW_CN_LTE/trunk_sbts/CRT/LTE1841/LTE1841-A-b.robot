*** Settings ***
Suite Setup    Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4MAQN_CUS
...    owner-rebecca.zhong    release-xL18    team-DEVHZ5_SG4
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{enable_AMLE}
...    LNCEL-1:actAmle=true
...    LNCEL-1:actServRlqInterFreqLB=false
@{reconf_FLBHighLoad}
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=25
...    LNCEL:loadSettings:targetLoadNonGbrDl=25
@{recovery_param}
...    LNCEL-1:actAmle=false
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=60
...    LNCEL:loadSettings:targetLoadNonGbrDl=40
${SOS_REPORT_FLAG}  pass:False,fail:False


*** Test Cases ***
LTE1841-A-b AMLE states - cell in active LB state
    [Documentation]    DESC:
    ...               CAC calculation formula:
    ...               CAC_DL = integer(min (Ac_DlGbr, Ac_DlNonGbr, Ac_Pdcch))
    ...
    ...               Ac_DlGbr = 100 - 100 * min (loadDlGbrAvg / targetLoadGbrDl; 1)
    ...               Ac_DlNonGbr = 100 - 100 * min (loadDlNonGbrAvg / targetLoadNonGbrDl; 1)
    ...               Ac_Pdcch = 100 - 100 * min (loadPdcchAvg / targetLoadPdcch; 1)
    [Tags]
    Enable AMLE and UEs attach to eNB1     cell_id=11
    UE Start downlink UDP traffic_7Mbps over QCI9 at SRC CELL when 2 UEs connected    ue_id=1
    UE re-Start downlink UDP traffic_7Mbps over QCI9 at SRC CELL when 2 UEs connected    ue_id=2
    UE Stop downlink UDP traffic and wait until inactivity timer has run up    ue_id=2
    Verify SRC CELL enters AMLE state and UE is released    ue_id=2
    UE Stop downlink UDP traffic and wait until inactivity timer has run up and check AMLE    ue_id=1
    Verify SRC CELL leaves AMLE state and UE is released    ue_id=1
    OnlineParamChange    ${reconf_FLBHighLoad}
    UE Exit idle state and start downlink UDP traffic (7Mbps) over QCI9 at SRC CELL    ue_id=1
    [Teardown]    Cleanup test environment AC_3


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=LTE1841
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts


Enable AMLE and UEs attach to eNB1
    [Arguments]    ${ue_id1}=1    ${ue_id2}=2    ${cell_id}=11
    ${query}    catenate    Registration-Request eq "start" and ReportingPeriodicity eq 'ten-thousand-ms'
    Expect Message Flow
    ...    ENB_1:X2AP_ResourceStatusRequest (${query} and eUTRANcellIdentifier eq '0b0000000000000000010000000001')
    ...    ENB_1:X2AP_ResourceStatusResponse
    ...    alias=RSR_REQUEST_1_FLOW    overall_timeout=180
    Expect Message Flow
    ...    ENB_1:X2AP_ResourceStatusRequest (${query} and eUTRANcellIdentifier eq '0b0000000000000000000100001011')
    ...    ENB_1:X2AP_ResourceStatusResponse
    ...    alias=RSR_REQUEST_2_FLOW    overall_timeout=180
    OnlineParamChange    ${enable_AMLE}
    sleep    5
    Execute Egate Command    enb_establish_mlb_partnership enb=4 cell=1 tgt_enb=1 tgt_cell=11 reporting_period=10000
    Execute Uex Command    ue_attach id=${ue_id1} cell=${cell_id}
    Execute Uex Command    ue_attach id=${ue_id2} cell=${cell_id}
    Execute Uex Command    bearer_add ue=${ue_id1} qci=9
    Execute Uex Command    bearer_add ue=${ue_id2} qci=9
    Execute Uex Command    trf_data_start ue=${ue_id2} dir=dl protocol=udp stats=true qci=9 kbps=2 trf_id=1
    Flow Occurred as expected    alias=RSR_REQUEST_1_FLOW
    Flow Occurred as expected    alias=RSR_REQUEST_2_FLOW


UE Start downlink UDP traffic_7Mbps over QCI9 at SRC CELL when 2 UEs connected
    [Arguments]    ${ue_id}=1
    ${query}    catenate
    ...    (dL-CompositeAvailableCapacity contains (capacityValue lt 73) and dL-CompositeAvailableCapacity contains (capacityValue gt 63))
    Expect Message Flow
    ...    ENB_1:X2AP_ResourceStatusUpdate (${query} and (eUTRANcellIdentifier eq '0b0000000000000000000100001011'))
    ...    alias=CACEXCHANGE_FLOW    overall_timeout=30
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (carrierFreq eq 800) as reconfig
    ...    alias=RECONFIG_FLOW    overall_timeout=30
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (carrierFreq eq 800) as reconfig2
    ...    alias=RECONFIG_FLOW2    overall_timeout=30
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp stats=true qci=9 Mbps=5 trf_id=1
    sleep    10
    Check Current Throughput    ue_id=${ue_id}    target=6
    Flow Occurred as expected    alias=CACEXCHANGE_FLOW
    Flow Occurred as expected    alias=RECONFIG_FLOW
    Flow Occurred as expected    alias=RECONFIG_FLOW2

UE re-Start downlink UDP traffic_7Mbps over QCI9 at SRC CELL when 2 UEs connected
    [Arguments]    ${ue_id}=1
    ${query}    catenate
    ...    (dL-CompositeAvailableCapacity contains (capacityValue lt 40) and dL-CompositeAvailableCapacity contains (capacityValue gt 10))
    Expect Message Flow
    ...    ENB_1:X2AP_ResourceStatusUpdate (${query} and (eUTRANcellIdentifier eq '0b0000000000000000000100001011'))
    ...    alias=CACEXCHANGE_FLOW2    overall_timeout=30
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToAddModList is present) as reconfig3
    ...    alias=RECONFIG_FLOW3    overall_timeout=30
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (measIdToAddModList is present) as reconfig4
    ...    alias=RECONFIG_FLOW4    overall_timeout=30
    Execute Uex Command    trf_data_stop ue=${ue_id} trf_id=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp stats=true qci=9 Mbps=5 trf_id=1
    sleep    10
    Check Current Throughput    ue_id=${ue_id}    target=6
    Flow Occurred as expected    alias=CACEXCHANGE_FLOW2
    Flow Occurred as expected    alias=RECONFIG_FLOW3
    Flow Occurred as expected    alias=RECONFIG_FLOW4

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Stop downlink UDP traffic and wait until inactivity timer has run up
    [Arguments]    ${ue_id}=1    ${traffic_id}=1
    Execute Uex Command    trf_data_stop ue=${ue_id} trf_id=${traffic_id}
    sleep    20

UE Stop downlink UDP traffic and wait until inactivity timer has run up and check AMLE
    [Arguments]    ${ue_id}=1    ${traffic_id}=1
    Execute Uex Command    trf_data_stop ue=${ue_id} trf_id=${traffic_id}
    sleep    5
    ${query}=  Set Variable  (dL-CompositeAvailableCapacity contains (capacityValue eq 100))
    Expect Message Flow
    ...    ENB_1:X2AP_ResourceStatusUpdate (${query} and (eUTRANcellIdentifier eq '0b0000000000000000000100001011'))
    ...    alias=CACEXCHANGE_FLOW2    overall_timeout=20
    Expect Message Will Not Occur    UE_1:RRC_RRCConnectionReconfiguration
    ...    alias=NORECONFIGURATION_FLOW    overall_timeout=20

Verify SRC CELL enters AMLE state and UE is released
    [Arguments]    ${ue_id}=2
    ${ue2_info}  Execute UEx Command  get_ue_info id=${ue_id}
    should be equal  ${ue2_info["state"]}   IDLE
    ${query}=  Set Variable
    ...    (dL-CompositeAvailableCapacity contains (capacityValue lt 73) and dL-CompositeAvailableCapacity contains (capacityValue gt 56))
    Expect Message Flow
    ...    ENB_1:X2AP_ResourceStatusUpdate (${query} and (eUTRANcellIdentifier eq '0b0000000000000000000100001011'))
    ...    alias=CACEXCHANGE_FLOW3    overall_timeout=20
    Flow Occurred as expected    alias=CACEXCHANGE_FLOW3

Verify SRC CELL leaves AMLE state and UE is released
    [Arguments]    ${ue_id}=1
    Flow Occurred as expected    alias=CACEXCHANGE_FLOW2
    Flow Not Occurred for Message    alias=NORECONFIGURATION_FLOW
    ${ue1_info}  Execute UEx Command  get_ue_info id=${ue_id}
    should be equal  ${ue1_info["state"]}  IDLE

UE Exit idle state and start downlink UDP traffic (7Mbps) over QCI9 at SRC CELL
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_im_exit id=${ue_id}
    Execute Uex Command    ue_stats clear id=${ue_id}
    sleep    2
    ${query}=    Set Variable
    ...    (dL-CompositeAvailableCapacity contains (capacityValue lt 56) and dL-CompositeAvailableCapacity contains (capacityValue ge 40))
    Expect Message Flow
    ...    ENB_1:X2AP_ResourceStatusUpdate (${query} and (eUTRANcellIdentifier eq '0b0000000000000000000100001011'))
    ...    alias=CACEXCHANGE_FLOW4    overall_timeout=30
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (carrierFreq eq 800) as reconfig
    ...    alias=RECONFIG_FLOW5    overall_timeout=30
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp stats=true qci=9 Mbps=5 trf_id=1
    sleep    10
    Check Current Throughput    ue_id=${ue_id}    target=6
    Flow Occurred as expected    alias=CACEXCHANGE_FLOW4
    Flow Occurred as expected    alias=RECONFIG_FLOW5


Cleanup test environment AC_3
    release all ues
#    Execute Egate Command    enb_terminate_mlb_initiated enb=2 cell=21 tgt_enb=1 tgt_cell=1
    OnlineParamChange    ${recovery_param}
    Common Test Teardown And Stop Capture Logs


