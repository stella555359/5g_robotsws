*** Settings ***

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    Description: Suite description in QC

Library        taf.ul.hanging_resources.listener    ${False}
Resource       resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_FDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup       Setup test environment
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_FDD.cfg
${ap_xml}=         ${CURDIR}/config/FDD_CPRI_LO_AP_LO/iphy_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/FDD_CPRI_LO_AP_LO/scfc_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml
${counters}=       M55349C06000-M55349C06019,M55353C01002-M55353C01021

*** Test Cases ***
CB008009-B_UL_Throughput_Distribution_counters_logarithmic_for_PMQAP_profile_SA
    [Setup]  Prepare test environment
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Wait for next full pm interval
    Start variable throughput on single UE
    Collect and verify UL throughput distribution counters for single UE
    Register 3 additional UEs and establish PDUs sessions
    Start throughput on three ues  tput_type=SA_UL  tput1=31m  tput2=34m  tput3=38m  duration=20
    Collect and verify UL throughput distribution counters for multiple UEs
    [Teardown]  Run keywords
    ...         Deregister UEs and clear up test environment
    ...   AND    Sleep  5s  reason=Hanging resources verification
    ...   AND    Send Configuration ID To Scout


*** Keywords ***
Prepare test environment
    Configure SA PMQAP Profiles
    Set feature flag NRPMQAP-1-1/thpHistScale to logarithmic
    Set feature flag NRPMCCP-1-1/thpHistScale to logarithmic
    Set feature flag NRBTS-1/thpHistScale to logarithmic
    Set feature flag NRBTS-1/thpHistUplinkMinRange to 17800
    Set feature flag NRBTS-1/thpHistUplinkMaxRange to 130000
    Set feature flag NRPMCCP-1-1/thpHistUplinkMinRange to 17800
    Set feature flag NRPMCCP-1-1/thpHistUplinkMaxRange to 130000
    Set feature flag NRPMQAP-1-1/thpHistUplinkMinRange to 17800
    Set feature flag NRPMQAP-1-1/thpHistUplinkMaxRange to 130000

Collect and verify UL throughput distribution counters for multiple UEs
    ${pm_counters_multi}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55353C01002    0         UL_RLC_UE_TPUT_BIN1_PMQAP
    ...    M55353C01003    0         UL_RLC_UE_TPUT_BIN2_PMQAP
    ...    M55353C01004    0         UL_RLC_UE_TPUT_BIN3_PMQAP
    ...    M55353C01005    0         UL_RLC_UE_TPUT_BIN4_PMQAP
    ...    M55353C01006    0         UL_RLC_UE_TPUT_BIN5_PMQAP
    ...    M55353C01007    0-4       UL_RLC_UE_TPUT_BIN6_PMQAP
    ...    M55353C01008    17-23     UL_RLC_UE_TPUT_BIN7_PMQAP
    ...    M55353C01009    17-23     UL_RLC_UE_TPUT_BIN8_PMQAP
    ...    M55353C01010    17-23     UL_RLC_UE_TPUT_BIN9_PMQAP
    ...    M55353C01011    0-4       UL_RLC_UE_TPUT_BIN10_PMQAP
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
    ...    file_path=${pm_counters_multi}

Collect and verify UL throughput distribution counters for single UE
    ${pm_counters_single}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55353C01002    8-13      UL_RLC_UE_TPUT_BIN1_PMQAP
    ...    M55353C01003    8-13      UL_RLC_UE_TPUT_BIN2_PMQAP
    ...    M55353C01004    8-13      UL_RLC_UE_TPUT_BIN3_PMQAP
    ...    M55353C01005    8-13      UL_RLC_UE_TPUT_BIN4_PMQAP
    ...    M55353C01006    8-13      UL_RLC_UE_TPUT_BIN5_PMQAP
    ...    M55353C01007    8-13      UL_RLC_UE_TPUT_BIN6_PMQAP
    ...    M55353C01008    8-13      UL_RLC_UE_TPUT_BIN7_PMQAP
    ...    M55353C01009    8-13      UL_RLC_UE_TPUT_BIN8_PMQAP
    ...    M55353C01010    8-13      UL_RLC_UE_TPUT_BIN9_PMQAP
    ...    M55353C01011    8-13      UL_RLC_UE_TPUT_BIN10_PMQAP
    ...    M55353C01012    8-13      UL_RLC_UE_TPUT_BIN11_PMQAP
    ...    M55353C01013    8-13      UL_RLC_UE_TPUT_BIN12_PMQAP
    ...    M55353C01014    8-13      UL_RLC_UE_TPUT_BIN13_PMQAP
    ...    M55353C01015    8-13      UL_RLC_UE_TPUT_BIN14_PMQAP
    ...    M55353C01016    8-13      UL_RLC_UE_TPUT_BIN15_PMQAP
    ...    M55353C01017    8-13      UL_RLC_UE_TPUT_BIN16_PMQAP
    ...    M55353C01018    8-13      UL_RLC_UE_TPUT_BIN17_PMQAP
    ...    M55353C01019    8-13      UL_RLC_UE_TPUT_BIN18_PMQAP
    ...    M55353C01020    8-13      UL_RLC_UE_TPUT_BIN19_PMQAP
    ...    M55353C01021    0-3       UL_RLC_UE_TPUT_BIN20_PMQAP
    ...    M55349C06000    8-13      UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    8-13      UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    8-13      UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    8-13      UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    8-13      UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    8-13      UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    8-13      UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    8-13      UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    8-13      UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    8-13      UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    8-13      UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    8-13      UL_RLC_UE_TPUT_BIN12
    ...    M55349C06012    8-13      UL_RLC_UE_TPUT_BIN13
    ...    M55349C06013    8-13      UL_RLC_UE_TPUT_BIN14
    ...    M55349C06014    8-13      UL_RLC_UE_TPUT_BIN15
    ...    M55349C06015    8-13      UL_RLC_UE_TPUT_BIN16
    ...    M55349C06016    8-13      UL_RLC_UE_TPUT_BIN17
    ...    M55349C06017    8-13      UL_RLC_UE_TPUT_BIN18
    ...    M55349C06018    8-13      UL_RLC_UE_TPUT_BIN19
    ...    M55349C06019    0-3       UL_RLC_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters_single}
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters_single}  localmoid=NRCELL-1

Start variable throughput on single UE
    Start throughput to sweep through provided counters  tput_type=SA_UL  ue=UE1  duration=10
    ...  BIN1_tput=15m    BIN2_tput=18m      BIN3_tput=20m    BIN4_tput=22m     BIN5_tput=25m
    ...  BIN6_tput=28m    BIN7_tput=31m       BIN8_tput=34m    BIN9_tput=38m     BIN10_tput=42m
    ...  BIN11_tput=46m   BIN12_tput=51m     BIN13_tput=56m   BIN14_tput=63m    BIN15_tput=70m
    ...  BIN16_tput=76m   BIN17_tput=85m     BIN18_tput=95m   BIN19_tput=107m
