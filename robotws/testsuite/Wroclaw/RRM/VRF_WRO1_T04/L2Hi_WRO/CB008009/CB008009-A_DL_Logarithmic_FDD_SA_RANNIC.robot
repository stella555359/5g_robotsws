*** Settings ***
Force Tags    CONFIGURED    CRT    SBTS00    SBTS23R4   master_vDU    DISABLE_GENERATION    SKIPRUN
    ...    CLOUD_5GC_dRNIC_1vDU_O_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD

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
...      REFERENCES:  CFAM for CB008009: https://gates.nsn-net.net/view/000263b1#o=0
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
...                     [23.01.2023] - Created TC
...                     [<date>] - Approved by (<WHO>, <review_link>)
...                     [<date>] - Test finished at GIT revision
...                     [<date>] - Review closed

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_FDD.cfg
${ap_xml}=         ${CURDIR}/config/FDD_CPRI_MP_AP_LO/iphy_FDD_SANSA_MP_AP_LO_2AHLOA_2cells.xml
${scfc}=           ${CURDIR}/config/FDD_CPRI_MP_AP_LO/scfc_FDD_SANSA_MP_AP_LO_2AHLOA_2cells.xml

*** Test Cases ***
CB008009-A_DL_Throughput_Distribution_counters_logarithmic_for_NON_PMQAP_profile_SA
    [Documentation]
    ...  DESCRIPTION:
    ...     This user scenario verifies  PM counters (DL Throughput distribution counters - Non PMQAP Profile)
    ...     when DL throughput varies over the time.
    ...
    ...  PRECONDITION:
    ...      - gNB configured with FDD cell operating in SA mode
    ...      - MRBTS/NRBTS/actThpDist is set to True
    ...      - MRBTS/NRBTS/actIpThpt is set to True
    ...      - MRBTS/NRBTS/thpTimeCalc is set to True
    ...      - NRBTS/thpHistScale is set to Logarithmic
    ...      - NRBTS/thpHistDownlinkMaxRange is set to 200000
    ...      - NRBTS/thpHistDownlinkMinRange is set to 20000
    ...
    ...  POSTCONDITION:
    ...     The Cell level PM Counters for DL Throughut Distribution BIN are available.
    ...     Counters DL_PDCP_UE_TPUT_BIN1 to DL_PDCP_UE_TPUT_BIN20 are incremented correctly
    ...
    ...  TESTING TOOLS:
    ...                     5G Node B WebUI
    ...                     Syslog
    ...                     PM Counters
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:
    ...                      gNB (ASIL, ABIO, AMIA) in SA configuration
    ...                      Simulated RRH (AHLOA) technology: FDD FR1 <100MHz
    ...                      Airphone ASIL + ABIO
    ...                      WTS 5G core simulator
    ...
    ...   *REQUIREMENTS COVERAGE: This is optional ONLY for EXPLORATORY or MANUAL test cases.
    ...                           In automated test cases this is mandatory.
    ...       *REQUIREMENTS IN SCOPE:    5G_PM_839
    ...       *REQUIREMENTS OUT OF SCOPE:
    ...       *NON-REQUIREMENTS-BASED TESTS:
    ...       *PM COUNTERS:   DL_PDCP_UE_TPUT_BIN1 - DL_PDCP_UE_TPUT_BIN20
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
    Change feature scale to logarithmic
    Set feature flag NRBTS-1/thpHistDownlinkMaxRange to 200000
    Set feature flag NRBTS-1/thpHistDownlinkMinRange to 20000
    Set parameter in all objects to value  parameter=durationThresDiscardDl  value=1
    Set parameter in all objects to value  parameter=volThresDiscardDl  value=10

Start variable throughput on single UE
    Wait for clean interval  period=5
    Start throughput to sweep through provided counters  tput_type=SA_DL  ue=UE1  duration=10  logfile=single_ue.log
    ...  BIN1_tput=10m    BIN2_tput=22m      BIN3_tput=24m    BIN4_tput=27m    BIN5_tput=30m
    ...  BIN6_tput=34m    BIN7_tput=39m       BIN8_tput=44m    BIN9_tput=50m    BIN10_tput=58m
    ...  BIN11_tput=62m   BIN12_tput=70m     BIN13_tput=83m   BIN14_tput=91m   BIN15_tput=105m
    ...  BIN16_tput=120m  BIN17_tput=135m    BIN18_tput=150m  BIN19_tput=169m  BIN20_tput=200m

Start variable throughput on multiple UEs
    Wait for clean interval  period=5
    Start throughput on three ues  tput_type=SA_DL  tput1=15m  tput2=15m  tput3=15m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_DL  tput1=30m  tput2=30m  tput3=30m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_DL  tput1=50m  tput2=50m  tput3=50m  duration=10  logfile=multiple_ues.log
    Start throughput on three ues  tput_type=SA_DL  tput1=65m  tput2=65m  tput3=65m  duration=10  logfile=multiple_ues.log

Collect PM Counters and verify values for single UE
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55350C20002    9-12    DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    9-12    DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    9-12    DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    9-12    DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    9-12    DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    9-12    DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    9-12    DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    9-12    DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    9-12    DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    9-12    DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    9-12    DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    9-12    DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    9-12    DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    9-12    DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    9-12    DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    9-12    DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    9-12    DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    9-12    DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    9-12    DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    9-12    DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Collect PM Counters and verify values for multiple UEs
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55350C20002    27-34    DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003      0      DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004      0      DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005      0      DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    27-34    DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007      0      DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008      0      DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009      0      DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    27-34    DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011      0      DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    27-34    DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013      0      DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014      0      DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015      0      DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016      0      DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017      0      DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018      0      DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019      0      DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020      0      DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021      0      DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
