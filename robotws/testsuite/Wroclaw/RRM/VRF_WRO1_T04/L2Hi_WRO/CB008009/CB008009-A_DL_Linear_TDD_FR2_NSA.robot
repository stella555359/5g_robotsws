*** Settings ***

Documentation
...    author: Maciej Majewski
...    contact: maciej.majewski@nokia.com
...    Description: Suite description in QC

Resource       resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR2.cfg
${ap_xml}=         ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/iphy_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/scfc_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${counters}=       M55350C20002-M55350C20021, M55352C03001-M55352C03020

*** Test Cases ***
CB008009-A_DL_Throughput_Distribution_counters_linear_for_PMQAP_profile_NSA

    [Setup]  Prepare test environment

    Wait for next full pm interval
    Attach UE  UE_ID=11
    SgNB Addition  UE_ID=11  CELL_ID=1
    Start throughput on single ue  tput_type=NSA_DL  ue=UE11  tput=30m   duration=10
    Start throughput on single ue  tput_type=NSA_DL  ue=UE11  tput=75m   duration=10
    Start throughput on single ue  tput_type=NSA_DL  ue=UE11  tput=125m  duration=10
    Start throughput on single ue  tput_type=NSA_DL  ue=UE11  tput=175m  duration=10
    Start throughput on single ue  tput_type=NSA_DL  ue=UE11  tput=230m  duration=10
    Collect and verify DL throughput distribution counters for single UE
    Attach 3 additional UEs and start gNB Addition Procedure
    Start throughput on three ues  tput_type=NSA_DL  tput1=30m  tput2=75m  tput3=125m  duration=10
    Collect and verify DL throughput distribution counters for multiple UEs

    [Teardown]    Detach NR-UEs and deconfigure gNB and clear environment

*** Keywords ***
Prepare test environment
    Configure NSA PMQAP Profiles

Collect and verify DL throughput distribution counters for single UE
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55352C03001    0-14    DL_PDCP_UE_TPUT_BIN1_PMQAP
    ...    M55352C03002    8-14    DL_PDCP_UE_TPUT_BIN2_PMQAP
    ...    M55352C03003    8-14    DL_PDCP_UE_TPUT_BIN3_PMQAP
    ...    M55352C03004    8-14    DL_PDCP_UE_TPUT_BIN4_PMQAP
    ...    M55352C03005    8-14    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03006    0       DL_PDCP_UE_TPUT_BIN6_PMQAP
    ...    M55352C03007    0       DL_PDCP_UE_TPUT_BIN7_PMQAP
    ...    M55352C03008    0       DL_PDCP_UE_TPUT_BIN8_PMQAP
    ...    M55352C03009    0       DL_PDCP_UE_TPUT_BIN9_PMQAP
    ...    M55352C03010    0       DL_PDCP_UE_TPUT_BIN10_PMQAP
    ...    M55352C03011    0       DL_PDCP_UE_TPUT_BIN11_PMQAP
    ...    M55352C03012    0       DL_PDCP_UE_TPUT_BIN12_PMQAP
    ...    M55352C03013    0       DL_PDCP_UE_TPUT_BIN13_PMQAP
    ...    M55352C03014    0       DL_PDCP_UE_TPUT_BIN14_PMQAP
    ...    M55352C03015    0       DL_PDCP_UE_TPUT_BIN15_PMQAP
    ...    M55352C03016    0       DL_PDCP_UE_TPUT_BIN16_PMQAP
    ...    M55352C03017    0       DL_PDCP_UE_TPUT_BIN17_PMQAP
    ...    M55352C03018    0       DL_PDCP_UE_TPUT_BIN18_PMQAP
    ...    M55352C03019    0       DL_PDCP_UE_TPUT_BIN19_PMQAP
    ...    M55352C03020    0       DL_PDCP_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Verify Last Counters In File
    ...    M55350C20002    0-14      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    8-14      DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    8-14      DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    8-14      DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    8-14      DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0         DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0         DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0         DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0         DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    0         DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    0         DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0         DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0         DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0         DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0         DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0         DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0         DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0         DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0         DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0         DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters}  localmoid=NRCELL-1

Collect and verify DL throughput distribution counters for multiple UEs
    ${pm_counters_multi}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55352C03001    0-14    DL_PDCP_UE_TPUT_BIN1_PMQAP
    ...    M55352C03002    8-14    DL_PDCP_UE_TPUT_BIN2_PMQAP
    ...    M55352C03003    8-14    DL_PDCP_UE_TPUT_BIN3_PMQAP
    ...    M55352C03004    0       DL_PDCP_UE_TPUT_BIN4_PMQAP
    ...    M55352C03005    0       DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03006    0       DL_PDCP_UE_TPUT_BIN6_PMQAP
    ...    M55352C03007    0       DL_PDCP_UE_TPUT_BIN7_PMQAP
    ...    M55352C03008    0       DL_PDCP_UE_TPUT_BIN8_PMQAP
    ...    M55352C03009    0       DL_PDCP_UE_TPUT_BIN9_PMQAP
    ...    M55352C03010    0       DL_PDCP_UE_TPUT_BIN10_PMQAP
    ...    M55352C03011    0       DL_PDCP_UE_TPUT_BIN11_PMQAP
    ...    M55352C03012    0       DL_PDCP_UE_TPUT_BIN12_PMQAP
    ...    M55352C03013    0       DL_PDCP_UE_TPUT_BIN13_PMQAP
    ...    M55352C03014    0       DL_PDCP_UE_TPUT_BIN14_PMQAP
    ...    M55352C03015    0       DL_PDCP_UE_TPUT_BIN15_PMQAP
    ...    M55352C03016    0       DL_PDCP_UE_TPUT_BIN16_PMQAP
    ...    M55352C03017    0       DL_PDCP_UE_TPUT_BIN17_PMQAP
    ...    M55352C03018    0       DL_PDCP_UE_TPUT_BIN18_PMQAP
    ...    M55352C03019    0       DL_PDCP_UE_TPUT_BIN19_PMQAP
    ...    M55352C03020    0       DL_PDCP_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters_multi}
