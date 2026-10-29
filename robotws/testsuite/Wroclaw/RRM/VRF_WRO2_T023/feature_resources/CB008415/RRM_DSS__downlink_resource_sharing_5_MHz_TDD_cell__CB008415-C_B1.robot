*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library       ute_ue
Library       taf.sbts.oam.coam.admin  WITH NAME  admin
Library       taf.converters.ttitracer
Resource      ../../resources/ca_IWK.robot


*** Variables ***
${LTE_CELL_ID}                               #ID of LTE cell to which UE should attach during the test


*** Keywords ***
TC__RRM_DSS__downlink_resource_sharing_5_MHz_TDD_cell__CB008415-C_B1
    Set Tags    CA-INTER_RAT    AUTHOR-szymon.kotlinski@nokia.com    OWNER-kamila.gmerek@nokia.com
    ...         MAINTAINER-szymon.kotlinski@nokia.com    PHASE-CRT   SW-SBTS22R3    FEATURE-CB008415    GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Perform dl Data Transfer In LTE Cell on LTE_UE1
    Step 2: Perform ul Data Transfer In LTE Cell on LTE_UE1
    Step 3: Perform dl Data Transfer In LTE Cell on LTE_UE2


Preconditions
    Log  \n=== Preconditions ===  console=True

    Require UE  LTE_UE1  LTE_TDD_1
    Require UE  LTE_UE2  LTE_TDD_2


Step ${index}: Perform ${direction} Data Transfer In LTE Cell on ${ue}
    Log  \n=== Step ${index}: Perform ${direction} Data Transfer In LTE Cell on ${ue} ===  console=True

    Prepare UE For Data Transfer  ${ue}   ${LTE_CELL_ID}
    Start Datatransfer  LTE_${index}  ${ue}   ${direction}  throughput=50 Mbits/sec  packet_size=1400  duration=1200s  buffer=32M
    Check Data Transfer Is Alive  LTE_${index}

    Log  LTE data transfer has started. Wait for stabilize it...  console=True
    Sleep  90s  Reason=Wait for data transfer to stabilize.

    Log  Collect TTI Traces...  console=True
    Collect 4G TTI Trace   cell_id=${LTE_CELL_ID}
    ...                    trace_time=5s
    ...                    output_path=${LOG_PATH}/TTI_Trace

    ${expected_tput} =  Set Variable If  '${index}' == '1'  18
    ...  '${index}' == '2'  3.85
    ...  '${index}' == '3'  18
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  LTE_${index}  ${expected_tput} Mbits/sec  10%  omit=10
    Run Keyword If  '${index}' == '1'  Stop Datatransfer  LTE_${index}


TC Setup
    Inter RAT Test Setup


TC Teardown
    [Timeout]  30 min
    Stop Data Transfers For All UEs
    Detach UE  LTE_UE1
    Detach UE  LTE_UE2
    Inter RAT Test Teardown
