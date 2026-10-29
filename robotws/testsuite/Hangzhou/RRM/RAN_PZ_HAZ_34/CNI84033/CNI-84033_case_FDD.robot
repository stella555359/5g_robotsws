*** Settings ***
Documentation     author: Cai Wenjuan
...               contact: wenjuan.cai@nokia-sbell.com
...               Cell1 for TDD
...               Cell2 for FDD
Suite Setup       Setup The Suite
Suite Teardown    Teardown The Suite
Force Tags        RAN_5G   RAN_5G_FDD   5G_RAN   5G_RAN_FDD   STATE_SW_UPLOADED
...               SBTS00  SG_01
Resource          Resources/CNI-84033_common_keyword.robot

*** Test Cases ***

[1]Scheduling_of_5G_UEs_with_multiple_non-GBR_bearers_for_SA_mode
    [Documentation]  Main test Steps:
    ...   1) actNonGbrServiceDiff = false
    ...      actFdmScheduling = true
    ...      maxNumPdschAllocationPerSlot = 2
    ...      schedulWeight = 2 for 5qi 6
    ...      schedulWeight = 3 for 5qi 7
    ...   2) wait untill cell on air
    ...   3) SA L3 call and DL data with Huawei SigSpark for UE1 and UE2
    ...   4) Verifiy throughput, DL scheduling of UE1-5QI 6 and UE2-5QI 7 will be 1:1
    ...   5) change actNonGbrServiceDiff = true
    ...   6) detach attach UE2 and DL data again
    ...   7) Verify throughput, DL scheduling of UE1-5QI 6 and UE2-5QI 7 will be 1:3
    [Tags]  CNI84033_Case1
    [Setup]    Setup Case
    [Teardown]    Teardown Case
    TC.Scheduling_of_5G_UEs_with_multiple_non-GBR_bearers_for_SA_mode

[1]Scheduling_of_5G_UEs_with_multiple_non-GBR_bearers_for_NSA_mode
    [Documentation]
    ...    Main test Steps:
    ...   1) actMultiDrbNSA = true
    ...      actNonGbrServiceDiff = true
    ...      schedulWeight of qci 7 70 128 =  2 : 4 : 3
    ...   2) prepare IPSL server
    ...   3) attach NSA UE1 with qci 7 70 128 and start DL traffic
    ...   4) check DL traffic, DL scheduling of qci 7 70 128 corresponds to  2 : 4 : 3
    ...   5) modify scheduling weight of qci 7 70 128 = 1 : 3 : 2
    ...   6) attach UE2 and establish with qci 7 70 128 and start UL/DL traffic
    ...   7) DL scheduling of UE1 and UE2 corresponds to 2 : 4 : 3 : 1 : 3 : 2
    ...   8) UL scheduling of UE1 to UE2 is (2 + 4 + 3) ：(1 + 3 + 2) = 9 : 6

    [Tags]    CNI84033_Case2
    [Setup]    Setup Case
    TC.Scheduling_of_5G_UEs_with_multiple_non-GBR_bearers_for_NSA_mode
    [Teardown]    Teardown Case

[1]Scheduling_of_5G_UEs_with_GBR_bearers
    [Documentation]
    ...    Main test Steps:
    ...   1) actNonVoNRGbrService  = true
    ...      5QI-1 discardTimer = 100ms
    ...      5QI-2 discardTimer = 150ms
    ...      core network provided 5QI-1 GBR-QosInformation:guaranteedFlowBitRateUL/DL = 50 Kbps
    ...      core network provided 5QI-2 GBR-QosInformation:guaranteedFlowBitRateUL/DL = 20 Mbps
    ...      core netword provided 5QI-2 call 51225 port
    ...      scheduling weight of GBR and None-GBR is 1 : 40
    ...   2) UE1 attach with non-GBR traffic with full buffer data, eg: dl 600M qic6
    ...   3) UE2 attach with 5QI-1 voice bearer and 5QI-2 video bearer
    ...   4) 5QI-1 voice call setup ok checked by ng pcap PDUsessionresourcemodifyrequest message
    ...   5) 5QI-1 ims call with AT command and traffic will above 3K
    ...   6) traffic in 5QI-2 video call will no packets discarded. eg: dl 15M, check result will 15M
    ...   7) when traffic exceed GFBR data of 5QI-2, the packets will at least 20M but will not exceed 30M

    [Tags]    CNI84033_Case3
    [Setup]    Setup Case
    TC.Scheduling_of_5G_UEs_with_GBR_bearers
    [Teardown]    Teardown Case

[1]SA_UE_context_preemption_at_Initial_Context_Setup
    [Documentation]
    ...   Main test Steps:
    ...   CB008698 enabled actUserPreemption
    ...   current number of SA UE contexts is above NRCELL.maxNumOfRrcSA
    ...   resources from NRCELL.numOfRadioResReservForTempUse are not fully used
    ...   counter PEAK_NUM_UE_CTX_TEMP_POOL is set to the current number of UE contexts
    ...   which used resources from numOfRadioResReservForTempUse pool or from numOfRadioResReservForTempUse and numOfRadioResReservForEmergency pools
    ...   if allowEmergencyReservForTempUse is set to true
    ...   Contention Based RA and RRC connection establishment.
    ...   Note that PUCCH resources are allocated at RRC connection setup phase from the NRCELL.numOfRadioResReservForTempUse pool
    ...   1) set maxNumOfUsersNRCell=1 and maxNumOfRrcSA =1 and fix related parameters on webem.
    ...      allowEmergencyReservForTempUse=false
    ...      numOfRadioResReservForTempUse=2
    ...      numOfRadioResReservForEmergency=0
    ...   2) SA UE1 attach with prioritylevelARP = 7 which is preconfigured in core network
    ...   3) SA UE2 with prioritylevelARP = 5 which is preconfigured in core network

    [Tags]    CNI84033_Case4    FDD
    [Setup]    Setup Case
    TC.SA_UE_context_preemption_at_Initial_Context_Setup
    [Teardown]    Teardown Case