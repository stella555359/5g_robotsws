*** Settings ***
Force Tags    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_MP_AP_LO
    ...    VARIANT_NSA_FS_ECPRI_MMWV_TDD

Resource      resources/CB009794_resources.robot

Suite Setup      Setup test environment
Suite Teardown   Clean suite environment

Documentation
...      INTRODUCTION: This feature provides cell level NR RTWP PM Counters for each UL spatial stream (AxC or eAxC):
...                    - Minimum RTWP per spatial stream;
...                    - Maximum RTWP per spatial stream;
...                    - Average RTWP per spatial stream.
...                    The spatial stream number is dependent on deployments and configurations.
...                    RTWP measurement is executed in the UL slots with PUSCH traffic and with no PUSCH traffic
...                    (with best effort method). Measurement shall be handled on the spatial streams for carrying PUSCH
...                    and is not required for the dedicated antenna streams of carrying PRACH/SRS.
...                    RTWP (Received Total Wideband Power) is the sum of the received user signal power of the cell
...                    plus all interference and thermal noise power that fall into the UL system bandwidth (S+I+N).
...                    In CB009794, measurement is done and reported only on configured PUSCH area.
...                    PUCCH is excluded from measurement.
...
...      TEST SET NAME: CB009794_NR_RTWP_PM_Counters
...
...      TESTING SCOPE: CB009794-F NR_RTWP_PM_Counters
...
...      *PRECONDTIONS AND DEPENDENCIES (New Feature only)
...          *PRECONDTIONS:  N/A
...
...          *DEPENDENCIES:  N/A
...
...      *TEST INSTANCE SPECIFIC NOTES:  N/A
...
...      CONTACTS:
...               Korczak, Krzysztof (Nokia - PL/Krakow) <krzysztof.korczak@nokia.com>
...
...      REFERENCES:
...
...      *TERMS AND ABBREVIATIONS:
...                     FR1 - Frequency Range 1
...                     FR2 - Frequency Range 2
...                     TDD - Time Division Duplex
...                     FDD - Frequency Division Duplex
...                     SA - Standalone
...                     NSA - Non Standalone
...                     RTWP - Received Total Wideband Power
...
...       HISTORY:
...                     [23.01.2023] - Created TC
...                     [<date>] - Approved by (<WHO>, <review_link>)
...                     [<date>] - Test finished at GIT revision
...                     [<date>] - Review closed

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_ABIP_NSA_TDD_FR2.cfg
${counters}=              M55369C00000-M55369C00007,M55369C00100-M55369C00107,M55369C00200-M55369C00207

*** Test Cases ***
CB009794-NR_RTWP_counters_reflects_high_interference_during_a_specific_period_TDD_eCPRI_FR2_NSA
    [Documentation]
    ...  DESCRIPTION:
    ...     This user scenario verifies if high interference during a specific period is reflected in NR RTWP counters.
    ...
    ...  PRECONDITION:
    ...      - gNB configured with TDD cell operating in NSA mode
    ...      - NRBTS/actRtwpMeasurement is set to True
    ...      - NRBTS/NRPMRNL/miNrRtwp parameter is set a value other than 0
    ...
    ...  POSTCONDITION:
    ...      Collected PM counters corresponding to the available spatial streams in the cell shall show higher values
    ...      for the measurement interval when high external interference was generated. Values of PM counter reduced
    ...       to normal range when external interference is stopped
    ...
    ...  TESTING TOOLS:
    ...                     5G Node B WebUI
    ...                     Syslog
    ...                     PM Counters
    ...                     BIP
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:
    ...                      gNB (ASIL, ABIO, AMIA) in SA configuration
    ...                      Simulated RRH (AWEUA) technology: TDD FR2 100MHz
    ...                      Airphone ASIL + ABIO
    ...                      WTS 5G core simulator
    ...
    ...   *REQUIREMENTS COVERAGE: This is optional ONLY for EXPLORATORY or MANUAL test cases.
    ...                           In automated test cases this is mandatory.
    ...       *REQUIREMENTS IN SCOPE: 5G_PM_929
    ...       *REQUIREMENTS OUT OF SCOPE:
    ...       *NON-REQUIREMENTS-BASED TESTS:
    ...       *PM COUNTERS: M55369C00000;M55369C00001;M55369C00100;M55369C00101;M55369C00200;M55369C00201
    ...       *BACKLOG ID: FCA_5G_L2L3-138036
    ...
    ...  *FEATURE SUB-ITEMS:  CB009794
    ...
    ...  *DEFINITIONS FROM THE TEST PLAN:
    ...
    ...  REQUIRED LOGS:  PM Counters
    ...
    ...  CONTACTS:
    ...                 Korczak, Krzysztof (Nokia - PL/Krakow) <krzysztof.korczak@nokia.com>
    ...
    ...  REFERENCES:
    ...                 GATES:    CFAM for CB009794: https://gates.nsn-net.net/view/00026627#o=0
    ...
    ...  HISTORY:
    ...                 [<date>] - Created TC
    ...                 [<date>] - Approved by (<WHO>, <review_link>)
    ...                 [<date>] - Test finished at GIT revision
    ...                 [<date>] - Review closed

    Wait for next full pm interval
    Set feature flag NRBTS-1/nsaInactivityTimer to 60
    Attach UE  UE_ID=101
    SgNB Addition  UE_ID=101  CELL_ID=1
    Start NSA traffic  ue=101  dir=ul  traffic_rate=50Mbps
    Verify NSA traffic  ue=101  dir=UL  expected_traffic=50Mbps  bearer_type=mcg
    Generate High external interference for PUSCH    CELL_ID=1
    Verify NSA traffic  ue=101  dir=UL  expected_traffic=50Mbps  tolerance=10  bearer_type=mcg
    ${High_Int_counters}=  Collect PM Counters values are correct for High external interference
    Get counters value and report to rp  counters=${counters}  filepath=${High_Int_counters}  localmoid=NRCELL-1
    Remove High external interference for PUSCH
    ${Low_Int_counters}=  Collect PM Counters values are correct for no external interference
    Get counters value and report to rp  counters=${counters}  filepath=${Low_Int_counters}  localmoid=NRCELL-1
    Verify if PM Counters show higher values when high external interference was generated
    ...  high_int_counters=${High_Int_counters}  low_int_counters=${Low_Int_counters}    cell_id=1

    [Teardown]  Run keywords
    ...    Clean up external interference and detach NSA UEs
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
