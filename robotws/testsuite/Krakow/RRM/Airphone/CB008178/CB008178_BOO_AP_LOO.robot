*** Settings ***
Documentation
...        maintainer:   Lukasz Gdowski
...        contact:      lukasz.gdowski@nokia.com
...        author:       Lukasz Gdowski
...        description:  Test Cases for CB008178
...
...        CB008178_Counters_for_recieved_preamble_power cover TC:
...        CB008178_Counters_for_recieved_preamble_power_distribution
...        CB008178_Transmitted_MAC_PDU_data_volumes_per_SSB_bean_index
...        CB008178_Recieved_MAC_PDU_data_volumes_per_SSB_bean_index

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    CLOUD_5G_I_BOO_AP_LOO  VARIANT_PRIVATE_MMWV_SA_CA_GMC

Library     ../resources/former_l2_sw1/python/traffic_handling.py
Library     ../resources/former_l2_sw1/python/common_keywords.py
Resource    ./resources/CB008178_KW.robot
Resource    ../resources/former_l2_sw1/robot/common_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup     Prepare suite environment       x2=False
Suite Teardown  Clean suite environment

*** Test Cases ***
CB008178_Counters_for_recieved_preamble_power
    [Setup]    Activate NR SSB Level Measurement

    Wait For Next Full PM Interval

    Set beam control testmode

    Set pdu param for internal traffic    UE_ID=1
    Set pdu param for internal traffic    UE_ID=2
    Set pdu param for internal traffic    UE_ID=3

    Register UE and establish PDU session    UE_ID=1   CELL_ID=1
    Register UE and establish PDU session    UE_ID=2   CELL_ID=1
    Register UE and establish PDU session    UE_ID=3   CELL_ID=1

    start SA traffic  ue=1  pdu=1  dir=dl  traffic_rate=150Mbps
    start SA traffic  ue=2  pdu=2  dir=dl  traffic_rate=150Mbps
    start SA traffic  ue=3  pdu=3  dir=dl  traffic_rate=150Mbps
    start SA traffic  ue=1  pdu=1  dir=ul  traffic_rate=150Mbps
    start SA traffic  ue=2  pdu=2  dir=ul  traffic_rate=150Mbps
    start SA traffic  ue=3  pdu=3  dir=ul  traffic_rate=150Mbps

    Wait for next pm interval and get counters

    Confirm that the average counters are updated with PDSCH_INIRE_VOL_SSB

    [Teardown]    Run Keywords
    ...    Release PDU session and deregister UE    UE_ID=1
    ...    AND    Release PDU session and deregister UE    UE_ID=2
    ...    AND    Release PDU session and deregister UE    UE_ID=3
    ...    AND    Run Keyword And Ignore Error    Add Main BTS Metadata to Report
