*** Settings ***
Force Tags    ASOE    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SKIPRUN
    ...    CLOUD_5G_O_E_AP_LO_NSA_FS_ECPRI_MMWV_TDD

Resource       resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

Documentation
...
...      INTRODUCTION:  This feature provides PM counters in relation to NR Throughput distribution.
...                     The PM counters shall provde analyses on the spread of DL and UL Throughput in a histogram.
...                     PM counters are also provided per PMQAP profile to analyze the UL and DL throughput spread
...                     for various QOS combinations.
...                     The UL Throughput histogram is created such that it is possible for the operator to configure
...                     the histogram flexibly with the help of NIDD parameters.
...                     This feature reuses the logic of the UL Throughput counter used in feature 5GC002637.
...                     The PM counter is calculated at RLC.
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
...                     FR2 - Frequency Range 2
...                     TDD/FDD - Time/Frequency Division Duplex
...
...       HISTORY:
...                     [<date>] - Created TC
...                     [<date>] - Approved by (<WHO>, <review_link>)
...                     [<date>] - Test finished at GIT revision
...                     [<date>] - Review closed

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR2.cfg
${ap_xml}=         ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/iphy_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/scfc_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml

*** Test Cases ***
CB008009-B_UL_Throughput_Distribution_counters_linear_for_NON_PMQAP_profile_NSA
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...     This User Scenario verifies UL Throughput Distribution counters in linear scale
    ...     for non PMQAP profile and NSA mode
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
    ...                      Non-Standalone (NSA) mode
    ...                      gNB CU/DU - AirScale (1xASIL, 1xABIO)
    ...                      Simulated RRH (AWEUA) technology: TDD FR2 100MHz
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
    Attach UE  UE_ID=11
    SgNB Addition  UE_ID=11  CELL_ID=1
    Start data ul traffic on single UE11 in NSA mode
    Verify single UE counters with iperf values
    Attach 3 additional UEs and start gNB Addition Procedure
    Start data ul traffic on three UEs in NSA mode
    Verify multiple UEs counters

    [Teardown]    Detach NR-UEs and deconfigure gNB and clear environment

*** Keywords ***
Prepare test environment
    Activate automatic PM Stats
    Wait for next full pm interval

Start data ul traffic on single UE11 in NSA mode
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=33m   duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=54m   duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=85m   duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=95m   duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=103m   duration=30  logfile=iperf_single_ue.log

Verify single UE counters with iperf values
    ${pm_counters}=   Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55349C06000    0-4      UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    0-4      UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    0-4      UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    28-33    UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    0-4      UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    28-33    UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    0-4      UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    0-4      UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    28-33    UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    28-33    UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    28-33    UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    0        UL_RLC_UE_TPUT_BIN12
    ...    M55349C06012    0        UL_RLC_UE_TPUT_BIN13
    ...    M55349C06013    0        UL_RLC_UE_TPUT_BIN14
    ...    M55349C06014    0        UL_RLC_UE_TPUT_BIN15
    ...    M55349C06015    0        UL_RLC_UE_TPUT_BIN16
    ...    M55349C06016    0        UL_RLC_UE_TPUT_BIN17
    ...    M55349C06017    0        UL_RLC_UE_TPUT_BIN18
    ...    M55349C06018    0        UL_RLC_UE_TPUT_BIN19
    ...    M55349C06019    0        UL_RLC_UE_TPUT_BIN20
    ...    M55349C04001    110000-160000      UL_RLC_TIME_UE_TPUT
    ...    M55349C03001    1130000-11600000   UL_RLC_VOL_UE_TPUT_TOT
    ...    M55349C02001    100000-116000      MAX_UL_RLC_UE_TPUT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counter values and evaluate division    M55349C03001    M55349C04001    75000    90000    ${pm_counters}

Start data ul traffic on three UEs in NSA mode
    Start throughput on three ues  tput_type=NSA_UL  tput1=5m   tput2=9m  tput3=33m  duration=20  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=NSA_UL  tput1=7m  tput2=9m  tput3=42m  duration=20  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=NSA_UL  tput1=2m  tput2=12m  tput3=53m  duration=20  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=NSA_UL  tput1=1m  tput2=3m  tput3=73m  duration=20  logfile=multiple_ues.log

Verify multiple UEs counters
    ${pm_counters2}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55349C06000    0-5      UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    0-5      UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    0-5      UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    18-23    UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    18-23    UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    18-23    UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    0-4      UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    18-23    UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    0        UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    0        UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    0        UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    0        UL_RLC_UE_TPUT_BIN12
    ...    M55349C06012    0        UL_RLC_UE_TPUT_BIN13
    ...    M55349C06013    0        UL_RLC_UE_TPUT_BIN14
    ...    M55349C06014    0        UL_RLC_UE_TPUT_BIN15
    ...    M55349C06015    0        UL_RLC_UE_TPUT_BIN16
    ...    M55349C06016    0        UL_RLC_UE_TPUT_BIN17
    ...    M55349C06017    0        UL_RLC_UE_TPUT_BIN18
    ...    M55349C06018    0        UL_RLC_UE_TPUT_BIN19
    ...    M55349C06019    0        UL_RLC_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters2}
    ${M55349C01009}=  Get counter values  counter_id=M55349C01009  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...               pm_counter_file=${pm_counters2}
    ${M55349C00009}=  Get counter values  counter_id=M55349C00009  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...               pm_counter_file=${pm_counters2}
    ${M55349C06019}=  Get counter values  counter_id=M55349C06019  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...               pm_counter_file=${pm_counters2}

    Verify value of counter  counter_id=M55349C01006  pm_counter_file=${pm_counters2}  expected_value=0
    Verify value of counter  counter_id=M55349C00006  pm_counter_file=${pm_counters2}  expected_value=0
    Verify value of counter  counter_id=M55349C01009  pm_counter_file=${pm_counters2}  expected_value=4100000  margin=10
    Verify value of counter  counter_id=M55349C00009  pm_counter_file=${pm_counters2}  expected_value=80000  margin=10
    Verify value of counter  counter_id=M55349C06019  pm_counter_file=${pm_counters2}  expected_value=0

    Get counter values and evaluate division    M55349C03001    M55349C04001    40000    60000    ${pm_counters2}
