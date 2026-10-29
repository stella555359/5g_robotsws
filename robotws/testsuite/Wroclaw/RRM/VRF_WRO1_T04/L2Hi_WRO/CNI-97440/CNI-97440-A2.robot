*** Settings ***
Library    CNI-97440_keywords.py

Documentation
...    author: Bartlomiej Urbanowicz
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R1

*** Variables ***
${UE_DC_TDD_ID}=    14
${UL_NUM_RCV_F1_QoS_GRP_06}=    M55323C02006
${ue_eutra_nr_capabilities}    SEPARATOR=
...    A112C0EC160801D0400000007F00000000040D82C100389A0000040FE00000000081B0982007134003A080000080FE00000000081004C1003
...    E2680001F4100000300410000804040080108000402020040088000201010020040400801

*** Keywords ***
CNI97440_Improve_Ping_Latency_In_Nsa_Calls_UlPrimaryPath_OverNr
    Attach Ue With Sgnb    ue_id=${UE_DC_TDD_ID}
    Push Dl Ping F1
    Verify If Pings Are Going Through F1 Link
    Detach Ue    ue_id=${UE_DC_TDD_ID}

Activate FlexibleIcmpRouting And F1 Ul Dl
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/delta_activate_ul_dl_traffic_through_F1.json

Push Dl Ping F1
    Push Ping    ip=4.7.254.211

Verify If Pings Are Going Through F1 Link
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${UL_NUM_RCV_F1_QoS_GRP_06}
    ...    value=100    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
