*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB012669/keywords_12669.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ue.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/alarms.py
Library    ute_ue

*** Keywords ***
CB012669-Feature_activation_with_DL_2CC_CA
    Set Default Values On Attenuator
    Show Text on Console    Attaching UE_1 to CELL 20    colour=${GREEN}  show_timestamp=no
    ${attach_pcap}    Attach UE Aic    UE_1    num_of_scells=1    vonr=${FALSE}
    ...    scells_id=${AHLOB_CELL_10}
    Start DL Traffic For Ue    UE_1    dl_tput=160Mbits/sec    duration=60s    protocol=udp    dt=first
    Verify DL Tput For Ue    UE_1    dt=first
    Detach Ue    UE_1

    ${vcu_alarms_before}    Get Alarms Summary From Vcu    total=${TRUE}
    &{vdu_alarms_before}    Get Alarms Summary From Vdu
    Activate Feature Deprioritization    cell_id=20    num_deprioritized=5
    ${vcu_alarms_after}    Get Alarms Summary From Vcu    total=${TRUE}
    &{vdu_alarms_after}    Get Alarms Summary From Vdu

    ${attach_pcap}    Attach UE Aic    UE_1    num_of_scells=1    vonr=${FALSE}
    ...    scells_id=${AHLOB_CELL_10}
    Start DL Traffic For Ue    UE_1    dl_tput=160Mbits/sec    duration=60s    protocol=udp    dt=first
    Verify DL Tput For Ue    UE_1    dt=first
    Should Be True    ${vcu_alarms_before}==${vcu_alarms_after}
    Should Be True    ${vdu_alarms_before}[total]==${vdu_alarms_after}[total]
    [Teardown]    Run Keywords
    ...  Detach Ue  UE_1  AND
    ...  Deactivate Feature Deprioritization    cell_id=20
