*** Settings ***

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    Description: Suite description in QC

Resource       resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR2.cfg
${ap_xml}=         ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/iphy_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/scfc_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml

*** Test Cases ***
CB008009-B_UL_Throughput_Distribution_counters_logarithmic_for_PMQAP_profile_NSA
    [Setup]  Prepare test environment
    Wait for next full pm interval
    Attach UE  UE_ID=11
    SgNB Addition  UE_ID=11  CELL_ID=1
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=103m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=93m     duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=84m     duration=10
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55353C01002    0         UL_RLC_UE_TPUT_BIN1_PMQAP
    ...    M55353C01003    0         UL_RLC_UE_TPUT_BIN2_PMQAP
    ...    M55353C01004    0         UL_RLC_UE_TPUT_BIN3_PMQAP
    ...    M55353C01005    0         UL_RLC_UE_TPUT_BIN4_PMQAP
    ...    M55353C01006    0         UL_RLC_UE_TPUT_BIN5_PMQAP
    ...    M55353C01007    0         UL_RLC_UE_TPUT_BIN6_PMQAP
    ...    M55353C01008    0         UL_RLC_UE_TPUT_BIN7_PMQAP
    ...    M55353C01009    0         UL_RLC_UE_TPUT_BIN8_PMQAP
    ...    M55353C01010    0         UL_RLC_UE_TPUT_BIN9_PMQAP
    ...    M55353C01011    0         UL_RLC_UE_TPUT_BIN10_PMQAP
    ...    M55353C01012    0         UL_RLC_UE_TPUT_BIN11_PMQAP
    ...    M55353C01013    0         UL_RLC_UE_TPUT_BIN12_PMQAP
    ...    M55353C01014    0         UL_RLC_UE_TPUT_BIN13_PMQAP
    ...    M55353C01015    0         UL_RLC_UE_TPUT_BIN14_PMQAP
    ...    M55353C01016    0         UL_RLC_UE_TPUT_BIN15_PMQAP
    ...    M55353C01017    0-3       UL_RLC_UE_TPUT_BIN16_PMQAP
    ...    M55353C01018    8-13      UL_RLC_UE_TPUT_BIN17_PMQAP
    ...    M55353C01019    9-13       UL_RLC_UE_TPUT_BIN18_PMQAP
    ...    M55353C01020    9-13       UL_RLC_UE_TPUT_BIN19_PMQAP
    ...    M55353C01021    0-3       UL_RLC_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Attach 3 additional UEs and start gNB Addition Procedure
    Start throughput on three ues  tput_type=NSA_UL  tput1=25m  tput2=28m  tput3=23m  duration=10
    ${pm_counters2}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55353C01002    0         UL_RLC_UE_TPUT_BIN1_PMQAP
    ...    M55353C01003    0-4       UL_RLC_UE_TPUT_BIN2_PMQAP
    ...    M55353C01004    0-4       UL_RLC_UE_TPUT_BIN3_PMQAP
    ...    M55353C01005    9-13      UL_RLC_UE_TPUT_BIN4_PMQAP
    ...    M55353C01006    9-13      UL_RLC_UE_TPUT_BIN5_PMQAP
    ...    M55353C01007    9-13      UL_RLC_UE_TPUT_BIN6_PMQAP
    ...    M55353C01008    0-4       UL_RLC_UE_TPUT_BIN7_PMQAP
    ...    M55353C01009    0         UL_RLC_UE_TPUT_BIN8_PMQAP
    ...    M55353C01010    0         UL_RLC_UE_TPUT_BIN9_PMQAP
    ...    M55353C01011    0         UL_RLC_UE_TPUT_BIN10_PMQAP
    ...    M55353C01012    0         UL_RLC_UE_TPUT_BIN11_PMQAP
    ...    M55353C01013    0         UL_RLC_UE_TPUT_BIN12_PMQAP
    ...    M55353C01014    0         UL_RLC_UE_TPUT_BIN13_PMQAP
    ...    M55353C01015    0         UL_RLC_UE_TPUT_BIN14_PMQAP
    ...    M55353C01016    0         UL_RLC_UE_TPUT_BIN15_PMQAP
    ...    M55353C01017    0         UL_RLC_UE_TPUT_BIN16_PMQAP
    ...    M55353C01018    0         UL_RLC_UE_TPUT_BIN17_PMQAP
    ...    M55353C01019    0         UL_RLC_UE_TPUT_BIN18_PMQAP
    ...    M55353C01020    0         UL_RLC_UE_TPUT_BIN19_PMQAP
    ...    M55353C01021    0         UL_RLC_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters2}
    [Teardown]    Detach NR-UEs and deconfigure gNB and clear environment

*** Keywords ***
Prepare test environment
    Configure NSA PMQAP Profiles
    Set feature flag NRPMQAP-1-1/thpHistScale to logarithmic
    Set feature flag NRPMQAP-1-1/thpHistUplinkMinRange to 18000
    Set feature flag NRPMQAP-1-1/thpHistUplinkMaxRange to 120000
