*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource      resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

Documentation
...
...      INTRODUCTION:  This feature provides PM counters in relation to NR Throughput distribution.
...                     The PM counters shall provde analyses on the spread of DL and UL Throughput in a histogram.
...                     PM counters are also provided per PMQAP profile to analyze the UL and DL throughput spread for various QOS combinations.
...                     The UL Throughput histogram is created such that it is possible for the operator to configure
...                     the histogram flexibly with the help of NIDD parameters.
...                     This feature reuses the logic of the UL Throughput counter used in feature 5GC002637. The PM counter is calculated at RLC.
...                     The PM counter requires that the parameter actIpThpt is set to True
...
...      TEST SET NAME:  CB008009-B - UL Throughput BIN at PMQAP Profile level and Non Profile level
...
...      TESTING SCOPE:
...                      CB008009 is divided for 2 subfeatures:
...                      - CB008009-A - DL Throughput BIN at PMQAP Profile level and Non Profile level
...                      - CB008009-B - UL Throughput BIN at PMQAP Profile level and Non Profile level
...                      Under this robot file is testing CB008009-B
...
...      *PRECONDTIONS AND DEPENDENCIES (New Feature only)
...          *PRECONDTIONS:  N/A
...          *DEPENDENCIES:  N/A
...
...      *TEST INSTANCE SPECIFIC NOTES:  N/A
...
...      CONTACTS:
...
...
...      REFERENCES:
...                     CFAM for CB008009: https://gates.nsn-net.net/view/000263b1#o=0
...                     5G User Scenarios:  https://gates.nsn-net.net/view/000263b1#o=250
...                     Focal Point: https://focalpoint-prod.int.net.nokia.com/fp/workspace/1314/view/12098/tree/25680
...
...      *TERMS AND ABBREVIATIONS:
...                     FR1 - Frequency Range 1
...                     TDD/FDD - Time/Frequency Division Duplex
...
...       HISTORY:
...                     [<date>] - Created TC
...                     [<date>] - Approved by (<WHO>, <review_link>)
...                     [<date>] - Test finished at GIT revision
...                     [<date>] - Review closed

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_FDD.cfg
${ap_xml}=         ${CURDIR}/config/FDD_CPRI_LO_AP_LO/iphy_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/FDD_CPRI_LO_AP_LO/scfc_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml

*** Test Cases ***
CB008009-B_UL_Throughput_Distribution_counters_linear_for_NON_PMQAP_profile_SA
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...     This User Scenario verifies UL Throughput Distribution counters in linear scale
    ...     for non PMQAP profile and SA mode
    ...
    ...  PRECONDITION:
    ...      - gNB(SA) is up and handling traffic
    ...      - actThpDist is set to 1 (TRUE)
    ...      - actIpThpt is set to 1 (TRUE)
    ...      - thpTimeCalc is set to 0
    ...
    ...  POSTCONDITION:
    ...     The PM Counters UL Throughput Distribution BIN counters per profile are available
    ...     UL_RLC_UE_TPUT_BIN1 to UL_RLC_UE_TPUT_BIN20 are incremented correctly
    ...
    ...  TESTING TOOLS:
    ...                     5G Node B WebUI
    ...                     Wireshark
    ...                     Syslog
    ...                     TCPdump
    ...                     TTi Trace
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:
    ...                      Standalone (SA) mode
    ...                      gNB CU/DU - AirScale (1xASIL, 1xABIO)
    ...                      Simulated RRH (AWEUA) technology: TDD FR1 MHz
    ...                      Airphone ASIL + ABIO
    ...                      WTS 5G core simulator
    ...
    ...   *REQUIREMENTS COVERAGE: This is optional ONLY for EXPLORATORY or MANUAL test cases.
    ...                           In automated test cases this is mandatory.
    ...       *REQUIREMENTS IN SCOPE:  5G_PM_840
    ...       *REQUIREMENTS OUT OF SCOPE:  N/A
    ...       *NON-REQUIREMENTS-BASED TESTS:  N/A
    ...       *PM COUNTERS: N/A
    ...       *BACKLOG ID: FPB-556804
    ...
    ...  *FEATURE SUB-ITEMS:  CB008009-B
    ...
    ...  *DEFINITIONS FROM THE TEST PLAN:  N/A
    ...
    ...  REQUIRED LOGS:  Snapshot, gNB BIP, AP BIP, TTI traces, syslog
    ...
    ...  CONTACTS:
    ...                 Siuta, Tomasz (Nokia - PL/Krakow) <tomasz.siuta@nokia.com>
    ...
    ...  REFERENCES:
    ...                     CFAM for CB008009: https://gates.nsn-net.net/view/000263b1#o=0
    ...                     5G User Scenarios:  https://gates.nsn-net.net/view/000263b1#o=250
    ...
    ...  HISTORY:
    ...                 [<date>] - Created TC
    ...                 [<date>] - Approved by (<WHO>, <review_link>)
    ...                 [<date>] - Test finished at GIT revision
    ...                 [<date>] - Review closed


    [Setup]  Prepare test environment

    Set feature flag NRBTS-1/thpHistUplinkMaxRange to 200000
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Start data ul traffic on single UE1 in SA mode
    Verify single UE counters with iperf values
    Register 3 additional UEs and establish PDUs sessions
    Start data ul traffic on three UEs in SA mode
    Verify multiple UEs counters

    [Teardown]    Deregister UEs and clear up test environment

*** Keywords ***
Prepare test environment
    Activate automatic PM Stats
    Wait for next full pm interval

Start data ul traffic on single UE1 in SA mode
    Start throughput on single ue  tput_type=SA_UL  ue=UE1  tput=500k  duration=30  logfile=iperf.log
    Start throughput on single ue  tput_type=SA_UL  ue=UE1  tput=22m  duration=30  logfile=iperf.log
    Start throughput on single ue  tput_type=SA_UL  ue=UE1  tput=52m  duration=30  logfile=iperf.log
    Start throughput on single ue  tput_type=SA_UL  ue=UE1  tput=82m  duration=30  logfile=iperf.log
    Start throughput on single ue  tput_type=SA_UL  ue=UE1  tput=92m  duration=30  logfile=iperf.log
    Start throughput on single ue  tput_type=SA_UL  ue=UE1  tput=102m  duration=30  logfile=iperf.log

Verify single UE counters with iperf values
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55349C06000    0-4       UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    0-4       UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    28-33     UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    0-4       UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    0-4       UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    28-33     UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    0-4       UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    0-4       UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    28-33     UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    28-33     UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    28-33     UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    0-1       UL_RLC_UE_TPUT_BIN12
    ...    M55349C06012    0         UL_RLC_UE_TPUT_BIN13
    ...    M55349C06013    0         UL_RLC_UE_TPUT_BIN14
    ...    M55349C06014    0         UL_RLC_UE_TPUT_BIN15
    ...    M55349C06015    0         UL_RLC_UE_TPUT_BIN16
    ...    M55349C06016    0         UL_RLC_UE_TPUT_BIN17
    ...    M55349C06017    0         UL_RLC_UE_TPUT_BIN18
    ...    M55349C06018    0         UL_RLC_UE_TPUT_BIN19
    ...    M55349C06019    0         UL_RLC_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    ${M55349C03001}=    Run Keyword And Continue On Failure  Get Nonzero Counter Values    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                 counter_id=M55349C03001  pm_counter_file=${pm_counters}
    ${M55349C04001}=    Run Keyword And Continue On Failure  Get Nonzero Counter Values    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                 counter_id=M55349C04001  pm_counter_file=${pm_counters}
    ${throughput}=      Evaluate    ${M55349C03001}/(${M55349C04001}/1000)
    Log to console      Throughput counted by division of counters M55349C03001 and M55349C04001 is ${throughput} kbps.
    Should Be True      70000<=${throughput}<=75000

Start data ul traffic on three UEs in SA mode
    Start throughput on three ues  tput_type=SA_UL  tput1=1m  tput2=7m  tput3=12m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_UL  tput1=3m  tput2=5m  tput3=22m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_UL  tput1=1m  tput2=4m  tput3=92m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_UL  tput1=1m  tput2=2m  tput3=102m  duration=10  logfile=multiple_ues.log
Verify multiple UEs counters
    ${pm_counters2}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55349C06000    18-33     UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    9-13      UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    9-13      UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    0-4       UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    0-4       UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    0-4       UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    0-4       UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    0-4       UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    0-4       UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    9-13      UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    9-13      UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    0-1       UL_RLC_UE_TPUT_BIN12
    ...    M55349C06012    0         UL_RLC_UE_TPUT_BIN13
    ...    M55349C06013    0         UL_RLC_UE_TPUT_BIN14
    ...    M55349C06014    0         UL_RLC_UE_TPUT_BIN15
    ...    M55349C06015    0         UL_RLC_UE_TPUT_BIN16
    ...    M55349C06016    0         UL_RLC_UE_TPUT_BIN17
    ...    M55349C06017    0         UL_RLC_UE_TPUT_BIN18
    ...    M55349C06018    0         UL_RLC_UE_TPUT_BIN19
    ...    M55349C06019    0         UL_RLC_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters2}

    ${M55349C03001}=    Run Keyword And Continue On Failure  Get Nonzero Counter Values    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                 counter_id=M55349C03001  pm_counter_file=${pm_counters2}
    ${M55349C04001}=    Run Keyword And Continue On Failure  Get Nonzero Counter Values    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                 counter_id=M55349C04001  pm_counter_file=${pm_counters2}
    ${throughput}=      Evaluate    ${M55349C03001}/(${M55349C04001}/1000)
    Log to console      Throughput counted by division of counters M55349C03001 and M55349C04001 is ${throughput} kbps.
    Should Be True      30000<=${throughput}<=42000
