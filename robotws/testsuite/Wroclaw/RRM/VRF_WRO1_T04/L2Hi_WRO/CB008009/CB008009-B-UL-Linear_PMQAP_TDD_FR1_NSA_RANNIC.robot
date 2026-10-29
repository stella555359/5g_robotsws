*** Settings ***
Force Tags    CONFIGURED    CRT    SBTS00    SBTS23R4    master_vDU    DISABLE_GENERATION    SKIPRUN
...           CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Resource       resources/CB008009_resources.robot
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
...      *TEST INSTANCE SPECIFIC NOTES:  ABIP
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
...                     TDD - Time Division Duplex
...
...       HISTORY:
...                     [<date>] - Created TC
...                     [<date>] - Approved by (<WHO>, <review_link>)
...                     [<date>] - Test finished at GIT revision
...                     [<date>] - Review closed

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR1.cfg
${ap_xml}=         ${CURDIR}/config/TDD_cmW_eCPRI_MP_AP_LO/iphy_TDD_SANSA_MP_AP_LO_2AHLOA_2cells.xml
${scfc}=           ${CURDIR}/config/TDD_cmW_eCPRI_MP_AP_LO/scfc_TDD_SANSA_MP_AP_LO_2AHLOA_2cells.xml

*** Test Cases ***
CB008009-B_UL_Throughput_Distribution_counters_linear_for_PMQAP_profile_NSA
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...     This User Scenario verifies UL Throughput Distribution counters in linear scale
    ...     for PMQAP profile and NSA mode
    ...
    ...  PRECONDITION:
    ...      - gNB(SA) is up and handling traffic
    ...      - actThpDist is set to 1 (TRUE)
    ...      - actIpThpt is set to 1 (TRUE)
    ...      - thpTimeCalc is set to 0
    ...      - PMQAP Profile is active:
    ...          actNrpmqapProfiles set to True
    ...          miNrHighRlcCell is set to 5min
    ...          NRBTS/NRPMRNL/NRPMQAP/cfg5qiRange set to 9
    ...          NRBTS/NRPMRNL/NRPMQAP/cfgProfType set to NSA
    ...          NRBTS/NRPMRNL/NRPMQAP/cfgPlmnId/mcc set to 311
    ...          NRBTS/NRPMRNL/NRPMQAP/cfgPlmnId/mnc set to 489
    ...          NRBTS/NRPMRNL/NRPMQAP/cfgPlmnId/mncLength set to 3
    ...          NRBTS/NRPMRNL/NRPMQAP/cfgSliced.sd set to 13714341
    ...          NRBTS/NRPMRNL/NRPMQAP/cfgSliced.sst set to 1

    ...
    ...  POSTCONDITION:
    ...      The PM Counters UL Throughput Distribution BIN counters are available
    ...      UL_RLC_UE_TPUT_BIN1_PMQAP to UL_RLC_UE_TPUT_BIN20_PMQAP are incremented correctly
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
    ...                      gNB CU/DU - AirScale (1xABIP, 1xASIM)
    ...                      Simulated RRH (AWEUA) technology: TDD FR1 20MHz
    ...                      Airphone ABIP + ASIM
    ...                      WTS 5G core simulator
    ...
    ...   *REQUIREMENTS COVERAGE: This is optional ONLY for EXPLORATORY or MANUAL test cases.
    ...                           In automated test cases this is mandatory.
    ...       *REQUIREMENTS IN SCOPE:  5G_PM_840, CB_FIM_34158
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

    Set feature flag NRPMQAP-1-1/thpHistUplinkMaxRange to 200000
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
    Configure NSA PMQAP Profiles
    Activate automatic PM Stats
    Wait for next full pm interval

Start data ul traffic on single UE11 in NSA mode
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=12m  duration=10  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=22m  duration=10  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=32m  duration=10  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=42m  duration=10  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=52m  duration=10  logfile=iperf_single_ue.log

Verify single UE counters with iperf values
    ${pm_counters}=   Wait for next pm interval and get counters
    Run keyword and continue on failure
    ...    Verify Last Counters In File
    ...    M55353C00001    1560000-1660000  UL_RLC_VOL_UE_TPUT_PMQAP
    ...    M55353C01001    43000-50000      UL_RLC_TIME_UE_TPUT_PMQAP
    ...    M55353C01002    0-4              UL_RLC_UE_TPUT_BIN1_PMQAP
    ...    M55353C01003    7-13             UL_RLC_UE_TPUT_BIN2_PMQAP
    ...    M55353C01004    8-13             UL_RLC_UE_TPUT_BIN3_PMQAP
    ...    M55353C01005    8-13             UL_RLC_UE_TPUT_BIN4_PMQAP
    ...    M55353C01006    8-13             UL_RLC_UE_TPUT_BIN5_PMQAP
    ...    M55353C01007    8-13             UL_RLC_UE_TPUT_BIN6_PMQAP
    ...    M55353C01008    0                UL_RLC_UE_TPUT_BIN7_PMQAP
    ...    M55353C01009    0                UL_RLC_UE_TPUT_BIN8_PMQAP
    ...    M55353C01010    0                UL_RLC_UE_TPUT_BIN9_PMQAP
    ...    M55353C01011    0                UL_RLC_UE_TPUT_BIN10_PMQAP
    ...    M55353C01012    0                UL_RLC_UE_TPUT_BIN11_PMQAP
    ...    M55353C01013    0                UL_RLC_UE_TPUT_BIN12_PMQAP
    ...    M55353C01014    0                UL_RLC_UE_TPUT_BIN13_PMQAP
    ...    M55353C01015    0                UL_RLC_UE_TPUT_BIN14_PMQAP
    ...    M55353C01016    0                UL_RLC_UE_TPUT_BIN15_PMQAP
    ...    M55353C01017    0                UL_RLC_UE_TPUT_BIN16_PMQAP
    ...    M55353C01018    0                UL_RLC_UE_TPUT_BIN17_PMQAP
    ...    M55353C01019    0                UL_RLC_UE_TPUT_BIN18_PMQAP
    ...    M55353C01020    0                UL_RLC_UE_TPUT_BIN19_PMQAP
    ...    M55353C01021    0                UL_RLC_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counter values and evaluate division    M55353C00001    M55353C01001    31000    36000    ${pm_counters}

Start data ul traffic on three UEs in NSA mode
    Start throughput on three ues  tput_type=NSA_UL  tput1=9m  tput2=3m  tput3=23m  duration=10  logfile=iperf_multiple_ues.log
    Start throughput on three ues  tput_type=NSA_UL  tput1=16m  tput2=1m  tput3=32m  duration=10  logfile=iperf_multiple_ues.log
    Start throughput on three ues  tput_type=NSA_UL  tput1=1m  tput2=14m  tput3=42m  duration=10  logfile=iperf_multiple_ues.log
    Start throughput on three ues  tput_type=NSA_UL  tput1=2m  tput2=3m  tput3=52m  duration=10  logfile=iperf_multiple_ues.log

Verify multiple UEs counters
    ${pm_counters2}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55353C00001    1600000-1930000      UL_RLC_VOL_UE_TPUT_PMQAP
    ...    M55353C01001    56000-70000          UL_RLC_TIME_UE_TPUT_PMQAP
    ...    M55353C01002    7-13                 UL_RLC_UE_TPUT_BIN1_PMQAP
    ...    M55353C01003    8-23                 UL_RLC_UE_TPUT_BIN2_PMQAP
    ...    M55353C01004    8-13                 UL_RLC_UE_TPUT_BIN3_PMQAP
    ...    M55353C01005    8-13                 UL_RLC_UE_TPUT_BIN4_PMQAP
    ...    M55353C01006    8-13                 UL_RLC_UE_TPUT_BIN5_PMQAP
    ...    M55353C01007    8-13                 UL_RLC_UE_TPUT_BIN6_PMQAP
    ...    M55353C01008    0                    UL_RLC_UE_TPUT_BIN7_PMQAP
    ...    M55353C01009    0                    UL_RLC_UE_TPUT_BIN8_PMQAP
    ...    M55353C01010    0                    UL_RLC_UE_TPUT_BIN9_PMQAP
    ...    M55353C01011    0                    UL_RLC_UE_TPUT_BIN10_PMQAP
    ...    M55353C01012    0                    UL_RLC_UE_TPUT_BIN11_PMQAP
    ...    M55353C01013    0                    UL_RLC_UE_TPUT_BIN12_PMQAP
    ...    M55353C01014    0                    UL_RLC_UE_TPUT_BIN13_PMQAP
    ...    M55353C01015    0                    UL_RLC_UE_TPUT_BIN14_PMQAP
    ...    M55353C01016    0                    UL_RLC_UE_TPUT_BIN15_PMQAP
    ...    M55353C01017    0                    UL_RLC_UE_TPUT_BIN16_PMQAP
    ...    M55353C01018    0                    UL_RLC_UE_TPUT_BIN17_PMQAP
    ...    M55353C01019    0                    UL_RLC_UE_TPUT_BIN18_PMQAP
    ...    M55353C01020    0                    UL_RLC_UE_TPUT_BIN19_PMQAP
    ...    M55353C01021    0                    UL_RLC_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters2}

    Get counter values and evaluate division    M55353C00001    M55353C01001    26000    31000    ${pm_counters2}
