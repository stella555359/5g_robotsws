*** Settings ***

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    Description: Suite description in QC

Resource       resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR1.cfg

*** Test Cases ***
CB008009-B_UL_Throughput_Distribution_counters_logarithmic_for_NON_PMQAP_profile_NSA
    [Setup]  Prepare test environment
    Attach UE  UE_ID=11
    SgNB Addition  UE_ID=11  CELL_ID=1
    Wait for next full pm interval
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=15m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=19m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=21m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=23m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=25m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=28m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=31m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=34m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=38m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=42m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=46m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=51m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=56m    duration=10
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=63m    duration=10

    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55349C06000    8-13      UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    9-13      UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    9-13      UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    9-13      UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    9-13      UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    9-13      UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    9-13      UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    9-13      UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    9-13      UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    9-13      UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    9-13      UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    9-13      UL_RLC_UE_TPUT_BIN12
    ...    M55349C06012    9-13      UL_RLC_UE_TPUT_BIN13
    ...    M55349C06013    9-13      UL_RLC_UE_TPUT_BIN14
    ...    M55349C06014    0-4       UL_RLC_UE_TPUT_BIN15
    ...    M55349C06015    0         UL_RLC_UE_TPUT_BIN16
    ...    M55349C06016    0         UL_RLC_UE_TPUT_BIN17
    ...    M55349C06017    0         UL_RLC_UE_TPUT_BIN18
    ...    M55349C06018    0         UL_RLC_UE_TPUT_BIN19
    ...    M55349C06019    0         UL_RLC_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Attach 3 additional UEs and start gNB Addition Procedure
    Start throughput on three ues  tput_type=NSA_UL  tput1=15m  tput2=19m  tput3=28m  duration=20
    Start throughput on three ues  tput_type=NSA_UL  tput1=21m  tput2=23m  tput3=25m  duration=20
    ${pm_counters2}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55349C06000    18-23     UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    18-23     UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    18-23     UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    18-23     UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    18-23     UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    18-23     UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    0-4       UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    0         UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    0         UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    0         UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    0         UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    0         UL_RLC_UE_TPUT_BIN12
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
    [Teardown]    Detach NR-UEs and deconfigure gNB and clear environment

*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/thpHistScale to logarithmic
    Set feature flag NRBTS-1/thpHistUplinkMinRange to 18000
    Set feature flag NRBTS-1/thpHistUplinkMaxRange to 120000
