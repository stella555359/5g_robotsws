*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN
    ...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Library       ta_emss
Library       resources/CB008009_resources.py
Resource      resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

Documentation
...      INTRODUCTION: This feature provides PM counters in relation to NR Throughput distribution.
...                    The PM counters shall provde analyses on the spread of DL and UL Throughput in a histogram.
...                    PM counters are also provided per PMQAP profile to analyze the UL and DL throughput spread
...                    for various QOS combinations.
...
...      TEST SET NAME: CB008009-A DL Throughput Counters
...
...      TESTING SCOPE: CB008009 is divided for 2 subitems:
...                         - CB008009-A DL Throughput Counters
...                         - CB008009-B UL Throughput Counters
...                       Under this robot file CB008009-A DL Throughput Counters is tested
...
...      *PRECONDTIONS AND DEPENDENCIES (New Feature only)
...          *PRECONDTIONS:  N/A
...
...          *DEPENDENCIES:  N/A
...
...      *TEST INSTANCE SPECIFIC NOTES:  N/A
...
...      CONTACTS:
...                     Korczak, Krzysztof (Nokia - PL/Krakow) <krzysztof.korczak@nokia.com>
...
...      REFERENCES:  CFAM for CB0080009: https://gates.nsn-net.net/view/000263b1#o=0
...
...      *TERMS AND ABBREVIATIONS:
...                     FR1 - Frequency Range 1
...                     FR2 - Frequency Range 2
...                     TDD - Time Division Duplex
...                     FDD - Frequency Division Duplex
...                     SA - Standalone
...                     NSA - Non Standalone
...
...       HISTORY:
...                     [11.01.2023] - Created TC
...                     [<date>] - Approved by (<WHO>, <review_link>)
...                     [<date>] - Test finished at GIT revision
...                     [<date>] - Review closed

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR1.cfg

*** Test Cases ***
CB008009-A_DL_Throughput_Distribution_counters_logarithmic_for_PMQAP_profile_SA
    [Documentation]
    ...  DESCRIPTION:
    ...     This user scenario verifies  PM counters (PMQAP Profile DL Throughput distribution counters)
    ...     when DL throughput varies over the time.
    ...
    ...  PRECONDITION:
    ...      - gNB configured with TDD cell operating in SA mode
    ...      - MRBTS/NRBTS/actThpDist is set to True
    ...      - MRBTS/NRBTS/actIpThpt is set to True
    ...      - MRBTS/NRBTS/thpTimeCalc is set to True
    ...      - NRPMQAP functionality is active
    ...      - NRBTS/NRPMRNL/NRPMQAP/thpHistScale is set to Logarithmic
    ...      - NRBTS/NRPMRNL/NRPMQAP/thpHistDownlinkMaxRange is set to 200000
    ...      - NRBTS/NRPMRNL/NRPMQAP/thpHistDownlinkMinRange is set to 20000
    ...
    ...  POSTCONDITION:
    ...     The PM Counters DL Throughut Distribution BIN counters per profile are available.
    ...     Counters DL_PDCP_UE_TPUT_BIN1_PMQAP to DL_PDCP_UE_TPUT_BIN20_PMQAP are incremented correctly
    ...
    ...  TESTING TOOLS:
    ...                     5G Node B WebUI
    ...                     Syslog
    ...                     PM Counters
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:
    ...                      gNB (ASOE, AMIA) in SA configuration
    ...                      Simulated RRH (AEQE) technology: TDD FR1 <100MHz
    ...                      Airphone ASIL + ABIO
    ...                      WTS 5G core simulator
    ...
    ...   *REQUIREMENTS COVERAGE: This is optional ONLY for EXPLORATORY or MANUAL test cases.
    ...                           In automated test cases this is mandatory.
    ...       *REQUIREMENTS IN SCOPE:    5G_PM_839;CB_FIM_34158
    ...       *REQUIREMENTS OUT OF SCOPE:
    ...       *NON-REQUIREMENTS-BASED TESTS:
    ...       *PM COUNTERS:  DL_PDCP_UE_TPUT_BIN1_PMQAP - DL_PDCP_UE_TPUT_BIN20_PMQAP
    ...       *BACKLOG ID:    FCA_5G_L2L3-113411
    ...
    ...  *FEATURE SUB-ITEMS:  CB008009-A
    ...
    ...  *DEFINITIONS FROM THE TEST PLAN:
    ...
    ...  REQUIRED LOGS:  PM Counters
    ...
    ...  CONTACTS:
    ...                 Korczak, Krzysztof (Nokia - PL/Krakow) <krzysztof.korczak@nokia.com>
    ...
    ...  REFERENCES:
    ...                 GATES:    CFAM for CB008009: https://gates.nsn-net.net/view/000263b1#o=0
    ...
    ...  HISTORY:
    ...                 [11.01.2023] - Created TC
    ...                 [<date>] - Approved by (<WHO>, <review_link>)
    ...                 [<date>] - Test finished at GIT revision
    ...                 [<date>] - Review closed

    [Setup]  Prepare test environment

    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Start variable throughput on single UE
    Collect PM Counters and verify values for single UE
    Register 3 additional UEs and establish PDUs sessions
    Start variable throughput on multiple UEs
    Collect PM Counters and verify values for multiple UEs

    [Teardown]    Deregister UEs and clear up test environment

*** Keywords ***
Prepare test environment
    Configure SA PMQAP Profiles
    Change feature scale to logarithmic
    Set feature flag NRPMQAP-1-1/thpHistDownlinkMaxRange to 200000
    Set feature flag NRPMQAP-1-1/thpHistDownlinkMinRange to 20000
    Set parameter in all objects to value  parameter=durationThresDiscardDl  value=1
    Set parameter in all objects to value  parameter=volThresDiscardDl  value=10

Start variable throughput on single UE
    Wait for clean interval  period=5
    Start throughput to sweep through provided counters  tput_type=SA_DL  ue=UE1  duration=10  logfile=single_ue.log
    ...  BIN1_tput=10m    BIN2_tput=22m      BIN3_tput=27m    BIN4_tput=31m    BIN5_tput=36m
    ...  BIN6_tput=41m    BIN7_tput=51m       BIN8_tput=57m    BIN9_tput=68m    BIN10_tput=79m
    ...  BIN11_tput=95m   BIN12_tput=110m    BIN13_tput=130m  BIN14_tput=152m  BIN15_tput=175m
    ...  BIN16_tput=208m  BIN17_tput=242m    BIN18_tput=290m  BIN19_tput=335m  BIN20_tput=600m

Start variable throughput on multiple UEs
    Wait for clean interval  period=5
    Start throughput on three ues  tput_type=SA_DL  tput1=15m  tput2=15m  tput3=15m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_DL  tput1=30m  tput2=30m  tput3=30m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_DL  tput1=90m  tput2=90m  tput3=90m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_DL  tput1=200m  tput2=200m  tput3=200m  duration=10  logfile=multiple_ues.log

Collect PM Counters and verify values for single UE
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55352C03001    9-12    DL_PDCP_UE_TPUT_BIN1
    ...    M55352C03002    9-12    DL_PDCP_UE_TPUT_BIN2
    ...    M55352C03003    9-12    DL_PDCP_UE_TPUT_BIN3
    ...    M55352C03004    9-12    DL_PDCP_UE_TPUT_BIN4
    ...    M55352C03005    9-12    DL_PDCP_UE_TPUT_BIN5
    ...    M55352C03006    9-12    DL_PDCP_UE_TPUT_BIN6
    ...    M55352C03007    9-12    DL_PDCP_UE_TPUT_BIN7
    ...    M55352C03008    9-12    DL_PDCP_UE_TPUT_BIN8
    ...    M55352C03009    9-12    DL_PDCP_UE_TPUT_BIN9
    ...    M55352C03010    9-12    DL_PDCP_UE_TPUT_BIN10
    ...    M55352C03011    9-12    DL_PDCP_UE_TPUT_BIN11
    ...    M55352C03012    9-12    DL_PDCP_UE_TPUT_BIN12
    ...    M55352C03013    9-12    DL_PDCP_UE_TPUT_BIN13
    ...    M55352C03014    9-12    DL_PDCP_UE_TPUT_BIN14
    ...    M55352C03015    9-12    DL_PDCP_UE_TPUT_BIN15
    ...    M55352C03016    9-12    DL_PDCP_UE_TPUT_BIN16
    ...    M55352C03017    9-12    DL_PDCP_UE_TPUT_BIN17
    ...    M55352C03018    9-12    DL_PDCP_UE_TPUT_BIN18
    ...    M55352C03019    9-12    DL_PDCP_UE_TPUT_BIN19
    ...    M55352C03020    9-12    DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Collect PM Counters and verify values for multiple UEs
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55352C03001    27-34    DL_PDCP_UE_TPUT_BIN1
    ...    M55352C03002      0      DL_PDCP_UE_TPUT_BIN2
    ...    M55352C03003      0      DL_PDCP_UE_TPUT_BIN3
    ...    M55352C03004    27-34    DL_PDCP_UE_TPUT_BIN4
    ...    M55352C03005      0      DL_PDCP_UE_TPUT_BIN5
    ...    M55352C03006      0      DL_PDCP_UE_TPUT_BIN6
    ...    M55352C03007      0      DL_PDCP_UE_TPUT_BIN7
    ...    M55352C03008      0      DL_PDCP_UE_TPUT_BIN8
    ...    M55352C03009      0      DL_PDCP_UE_TPUT_BIN9
    ...    M55352C03010      0      DL_PDCP_UE_TPUT_BIN10
    ...    M55352C03011    27-34    DL_PDCP_UE_TPUT_BIN11
    ...    M55352C03012      0      DL_PDCP_UE_TPUT_BIN12
    ...    M55352C03013      0      DL_PDCP_UE_TPUT_BIN13
    ...    M55352C03014      0      DL_PDCP_UE_TPUT_BIN14
    ...    M55352C03015      0      DL_PDCP_UE_TPUT_BIN15
    ...    M55352C03016    27-34    DL_PDCP_UE_TPUT_BIN16
    ...    M55352C03017      0      DL_PDCP_UE_TPUT_BIN17
    ...    M55352C03018      0      DL_PDCP_UE_TPUT_BIN18
    ...    M55352C03019      0      DL_PDCP_UE_TPUT_BIN19
    ...    M55352C03020      0      DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
