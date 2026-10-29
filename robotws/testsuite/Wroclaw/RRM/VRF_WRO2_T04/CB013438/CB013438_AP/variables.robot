*** Settings ***
Documentation
...    Variables for CB013438 TC 07
...   author: Lukasz Klimowicz
...   contact: lukasz.klimowicz@nokia.com

*** Variables ***


@{UE_AP_ids}=    5    50    51    52
@{UE_PDU_AP_ids}=    5    5    5    5

@{UE5_trf_ids}=    1    2    3
@{UE5_mbps}=    60    60    60
@{UE5_qfi_ids}=    1    2    3

@{UE50_trf_ids}=    4    5    6
@{UE50_mbps}=    60    60    60
@{UE50_qfi_ids}=    1    2    3

@{UE51_trf_ids}=    7    8    9    10    11    12
@{UE51_mbps}=    160    160    110    60    60    60
@{UE51_qfi_ids}=    1    2    3    1    2    1

@{UE52_trf_ids}=    13    14    15    16    17
@{UE52_mbps}=    160    160    40    40    40
@{UE52_qfi_ids}=    1    2    3    1    2

@{UE51_trf_ids_robustness_dl}=    1    2    3
@{UE51_mbps_robustness_dl}=    160    160    160
@{UE51_qfi_ids_dl}=    1    2    3

@{UE51_trf_ids_robustness_ul}=    4
@{UE51_mbps_robustness_ul}=    70
@{UE51_qfi_ids_ul}=    1

@{PCell_id}=    0
@{SCell_id}=    1
