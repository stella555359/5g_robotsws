*** Settings ***
Force Tags    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_MMWV_TDD

Library       ta_emss
Library       resources/CB008009_resources.py
Resource      resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

Documentation
...
...      INTRODUCTION:
...
...      TEST SET NAME:
...
...      TESTING SCOPE:
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
...      REFERENCES:
...
...      *TERMS AND ABBREVIATIONS:
...                     FR1 - Frequency Range 1
...                     FR2 - Frequency Range 2
...
...       HISTORY:
...                     [<date>] - Created TC
...                     [<date>] - Approved by (<WHO>, <review_link>)
...                     [<date>] - Test finished at GIT revision
...                     [<date>] - Review closed

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR1.cfg
${ap_xml}=         ${CURDIR}/config/5G_TDD_mmW_eCPRI_LO_AP_LO/iphy_TDD_NSA_FS_APoABIO_ASIL_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/5G_TDD_mmW_eCPRI_LO_AP_LO/scfc_TDD_NSA_FS_APoABIO_ASIL_2AWEUA_2cells.xml

*** Test Cases ***
CB008009-A_DL_Throughput_Distribution_counters_logarithmic_for_PMQAP_profile_NSA_exploratory
    [Documentation]
    ...  DESCRIPTION:
    ...
    ...  PRECONDITION:
    ...
    ...  POSTCONDITION:
    ...
    ...  TESTING TOOLS:
    ...                     5G Node B WebUI
    ...                     Syslog
    ...                     PM Counters
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:
    ...                      gNB (ASIL, ABIO, AMIA) in NSA configuration
    ...                      Simulated RRH (AEQE) technology: TDD FR1 <100MHz
    ...                      Airphone ASIL + ABIO
    ...                      WTS 5G core simulator
    ...
    ...   *REQUIREMENTS COVERAGE: This is optional ONLY for EXPLORATORY or MANUAL test cases.
    ...                           In automated test cases this is mandatory.
    ...
    ...  *FEATURE SUB-ITEMS:
    ...
    ...  *DEFINITIONS FROM THE TEST PLAN:
    ...
    ...  REQUIRED LOGS:
    ...
    ...  CONTACTS:
    ...                 Korczak, Krzysztof (Nokia - PL/Krakow) <krzysztof.korczak@nokia.com>
    ...
    ...  REFERENCES:
    ...
    ...  HISTORY:
    ...                 [24.05.2022] - Created TC
    ...                 [<date>] - Approved by (<WHO>, <review_link>)
    ...                 [<date>] - Test finished at GIT revision
    ...                 [<date>] - Review closed

    [Setup]  Prepare test environment

    Attach UE  UE_ID=11
    SgNB Addition  UE_ID=11  CELL_ID=1
    Attach UE  UE_ID=12
    SgNB Addition  UE_ID=12  CELL_ID=1
    Attach UE  UE_ID=13
    SgNB Addition  UE_ID=13  CELL_ID=1
    Attach UE  UE_ID=14
    SgNB Addition  UE_ID=14  CELL_ID=1


    Wait for clean interval  period=5

    Start throughput on single ue  tput_type=NSA_DL  ue=UE11  tput=30m   duration=10
    Start throughput on single ue  tput_type=NSA_DL  ue=UE12  tput=30m   duration=10
    Start throughput on single ue  tput_type=NSA_DL  ue=UE13  tput=30m   duration=10
    Start throughput on single ue  tput_type=NSA_DL  ue=UE14  tput=30m   duration=10

    ${pm_counters}=  Wait for next pm interval and get counters

    Verify Last Counters In File
    ...    M55352C03005    18-26    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-1
    ...    file_path=${pm_counters}
    Verify Last Counters In File
    ...    M55352C03005    18-26    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-2
    ...    file_path=${pm_counters}
    Verify Last Counters In File
    ...    M55352C03005    18-15    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-3
    ...    file_path=${pm_counters}
    Verify Last Counters In File
    ...    M55352C03005    18-26    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-4
    ...    file_path=${pm_counters}


    Set feature flag NRPMQAP-1-1/thpHistScale to logarithmic
    Set feature flag NRPMQAP-1-1/thpHistDownlinkMaxRange to 200000
    Set feature flag NRPMQAP-1-1/thpHistDownlinkMinRange to 20000
    Set feature flag NRPMQAP-1-2/thpHistScale to logarithmic
    Set feature flag NRPMQAP-1-2/thpHistDownlinkMaxRange to 800000
    Set feature flag NRPMQAP-1-2/thpHistDownlinkMinRange to 20000
    Set feature flag NRPMQAP-1-3/thpHistScale to logarithmic
    Set feature flag NRPMQAP-1-3/thpHistDownlinkMaxRange to 600000
    Set feature flag NRPMQAP-1-3/thpHistDownlinkMinRange to 20000
    Set feature flag NRPMQAP-1-4/thpHistScale to logarithmic
    Set feature flag NRPMQAP-1-4/thpHistDownlinkMaxRange to 800000
    Set feature flag NRPMQAP-1-4/thpHistDownlinkMinRange to 20000

    Wait for clean interval  period=5

    Start throughput on single ue  tput_type=NSA_DL  ue=UE11  tput=55m   duration=10  ##qci 9
    Start throughput on single ue  tput_type=NSA_DL  ue=UE12  tput=30m   duration=10  ##qci 9
    Start throughput on single ue  tput_type=NSA_DL  ue=UE13  tput=60m   duration=10  ##qci 6
    Start throughput on single ue  tput_type=NSA_DL  ue=UE14  tput=40m   duration=10  ##qci 6

    ${pm_counters}=  Wait for next pm interval and get counters

    Verify Last Counters In File
    ...    M55352C03005    11    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03010    11    DL_PDCP_UE_TPUT_BIN10_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-1
    ...    file_path=${pm_counters}
    Verify Last Counters In File
    ...    M55352C03004    11    DL_PDCP_UE_TPUT_BIN4_PMQAP
    ...    M55352C03007    11    DL_PDCP_UE_TPUT_BIN7_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-2
    ...    file_path=${pm_counters}
    Verify Last Counters In File
    ...    M55352C03005    11    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03008    11    DL_PDCP_UE_TPUT_BIN8_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-3
    ...    file_path=${pm_counters}
    Verify Last Counters In File
    ...    M55352C03005    11    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03007    11    DL_PDCP_UE_TPUT_BIN7_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-4
    ...    file_path=${pm_counters}

    [Teardown]    Detach NR-UEs and deconfigure gNB and clear environment

*** Keywords ***
Prepare test environment
    Configure  ${CURDIR}/config/activating_NSA_PMQAP_profiles_dl_log_exploratory.yaml
    Change feature scale to logarithmic
    Set parameter in all objects to value  parameter=durationThresDiscardDl  value=1
    Set parameter in all objects to value  parameter=volThresDiscardDl  value=10




