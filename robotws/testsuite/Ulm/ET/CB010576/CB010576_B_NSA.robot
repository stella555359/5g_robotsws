# Copyright (c) 2021 Nokia. All rights reserved.

*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: shruthi.shivaprasad@nokia.com
...             :contact/s: shruthi.shivaprasad@nokia.com
...             :description: CB010576_Parity_BB_ABIP_NR_FR2

Resource                ../resources/SQD60/sqd60_L3call.robot
Resource                ../resources/SQD60/sqd60_resourceUsage.robot

Suite Setup             Start Test Environment
Suite Teardown          End Test Environment
Test Setup              Start Testcase Environment
Test Teardown           End Testcase Environment


*** Variables ***
# modify during robot run e.x. [ -v ENABLE_ONLINE_REPORTING:true ]
&{TSP}                    COLLECT_GNB_BIP=false          # [ FALSE, TRUE ]        Collect gNB BIP Trace
...                       COLLECT_AP_BIP=false           # [ FALSE, TRUE ]        Collect AP BIP Trace
...                       COLLECT_SCTP=false             # [ FALSE, TRUE ]        Collect sctp trace
...                       COLLECT_SYSLOG=true            # [ FALSE, TRUE ]        Collect btslog2 syslog
...                       COLLECT_TTI_TRACE=false        # [ FALSE, TRUE ]        Collect TTI Trace for traffic
...                       COLLECT_BH_PCAP=false          # [ FALSE, TRUE ]        Collect BH pcap (eth3)
...                       COLLECT_WTS_PCAP=false         # [ FALSE, TRUE ]        Collect WTS pcap (eth4)
...                       COLLECT_SNAPSHOT=true          # [ FALSE, TRUE ]        Collect Snapshot
...                       COLLECT_SOS_REPORT=true        # [ FALSE, TRUE ]        Collect Snapshot
...                       FORCE_REBOOT=false             # [ FALSE, TRUE ]        Reboot testline every start of test
...                       ENFORCE_RESOURCE_USAGE=true    # [false, true] enables resource usage assertion (for testing)

##### Usually Static Values #####
...                       TEST_CU_TYPE=NSA               # [ SA, NSA, SA+NSA ]
...                       ENABLE_ONLINE_REPORTING=false  # [ FALSE, TRUE ]

...                       QC_PATH=testsuite/Ulm/ET/CB010576/CB010576_B.qc

${TRF_MBPS}=            10           # [0 - 999      ]        Thoughput for egate command
${TRF_TOLERANCE}=       .9           # [0.00 - 1.00  ] 90%    Throughput tolerance multiplier
${TRF_DURATION}=        10           # [ n seconds   ]        Traffic Duration
@{TESTUE_IDS_NSA}=      101  102     # [ n or *      ]        Array: UE id
@{TARGET_CELLS_NSA}=    1    2       # [ n or *      ]        Array: Target Cell

*** Test Cases ***
CB010576_B_ABIP_full_L3_call_NSA_FR2_TDD_eCPRI
    [Tags]    CB010576    CB010576_B    STATE_CONFIGURED
    ...       RAN_5G    RAN_5G_TDD    RRM
    Run L3 Call NSA

*** Keywords ***

Run L3 Call NSA
    Log to console    TRF_MBPS:${TRF_MBPS} TRF_TOLERANCE:${TRF_TOLERANCE}, TRF_DURATION:${TRF_DURATION}
    Log to console    TESTUE_IDS_NSA: ${TESTUE_IDS_NSA}, TARGET_CELLS_NSA:${TARGET_CELLS_NSA}
    Verify Commissioning State
    gnb.Wait For Minimum Required State For Cell Setup
    Prepare and Verify Cell On Air

    sqd60_resourceUsage.get resources taken before_test

    ### NSA ###
    Perform SgNBAddition for all UEs
    Verify Random Access in Egate for all Ues

    #################
    # UL + DL Traffic
    #################
    Start Internal Traffic for All UEs     dl=${TRF_MBPS}                                  # NSA
    ...                                    ul=${TRF_MBPS}

    Sleep                                  ${TRF_DURATION} seconds    msg=Sleep During traffic


    ${nsa_trf}=    Run Keyword and Return Status    Print and Verify All Traffic Result
    ...                                             dl=${EXPECTED_TPUT_DL_EGATE}           # NSA
    ...                                             ul=${EXPECTED_TPUT_UL_EGATE}

    Detach all UEs
    Sleep                                  30 seconds    reason=for resource usage

    sqd60_resourceUsage.get resources taken after_test
    sqd60_resourceUsage.add exclude resources    ${exclude_in_resource_check}
    IF    "${TSP.ENFORCE_RESOURCE_USAGE}"=="true"    sqd60_resourceUsage.Verify Resource Usage
    ...       ELSE    Run Keyword And Ignore Error    sqd60_resourceUsage.Verify Resource Usage

    Should be true    ${nsa_trf}    msg=NSA traffic failed
