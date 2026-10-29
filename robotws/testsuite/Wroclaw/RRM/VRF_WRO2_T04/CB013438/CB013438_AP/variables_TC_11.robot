*** Settings ***
Documentation
...   author: Lukasz Klimowicz
...   contact: lukasz.klimowicz@nokia.com

*** Variables ***

@{counters_to_be_incremented}
@{counters_to_be_decremented}
@{UE_AP_ids}=    5    50    51    6    60    61
@{UE_PDU_AP_ids}=    5    5    5    5    5    5

@{UE5_dl_trf_ids}=    1    2
@{UE5_dl_mbps}=    150    150
@{UE5_dl_qfi_ids}=    1    1
@{UE5_ul_trf_ids}=    3
@{UE5_ul_mbps}=    100
@{UE5_ul_qfi_ids}=    1

@{UE50_dl_trf_ids}=    4
@{UE50_dl_mbps}=    150
@{UE50_dl_qfi_ids}=    1
@{UE50_ul_trf_ids}=    5
@{UE50_ul_mbps}=    100
@{UE50_ul_qfi_ids}=    1

@{UE51_dl_trf_ids}=    6
@{UE51_dl_mbps}=    50
@{UE51_dl_qfi_ids}=    1
@{UE51_ul_trf_ids}=    7
@{UE51_ul_mbps}=    50
@{UE51_ul_qfi_ids}=    1

@{UE5_dl_trf_ids_restart}=    1    2
@{UE5_dl_mbps_restart}=    100    100
@{UE5_dl_qfi_ids_restart}=    1    1
@{UE5_ul_trf_ids_restart}=    3
@{UE5_ul_mbps_restart}=    30
@{UE5_ul_qfi_ids_restart}=    1

@{UE50_dl_trf_ids_restart}=    4
@{UE50_dl_mbps_restart}=    50
@{UE50_dl_qfi_ids_restart}=    1
@{UE50_ul_trf_ids_restart}=    5
@{UE50_ul_mbps_restart}=    30
@{UE50_ul_qfi_ids_restart}=    1

@{UE51_dl_trf_ids_restart}=    6
@{UE51_dl_mbps_restart}=    30
@{UE51_dl_qfi_ids_restart}=    1
@{UE51_ul_trf_ids_restart}=    7
@{UE51_ul_mbps_restart}=    30
@{UE51_ul_qfi_ids_restart}=    1

@{UE6_dl_trf_ids}=    8    9
@{UE6_dl_mbps}=    100    100
@{UE6_dl_qfi_ids}=    1    1
@{UE6_ul_trf_ids}=    10
@{UE6_ul_mbps}=    70
@{UE6_ul_qfi_ids}=    1

@{UE60_dl_trf_ids}=    11    12
@{UE60_dl_mbps}=    100    100
@{UE60_dl_qfi_ids}=    1    1
@{UE60_ul_trf_ids}=    13
@{UE60_ul_mbps}=    30
@{UE60_ul_qfi_ids}=    1

@{UE61_dl_trf_ids}=    14
@{UE61_dl_mbps}=    30
@{UE61_dl_qfi_ids}=    1
@{UE61_ul_trf_ids}=    15
@{UE61_ul_mbps}=    30
@{UE61_ul_qfi_ids}=    1

@{UE6_dl_trf_ids_for_enhanced}=    16
@{UE6_dl_mbps_for_enhanced}=    120
@{UE6_dl_qfi_ids_for_enhanced}=    1

@{PCell_id}=    0

@{counters_to_be_decreased}=    M55308C17001    M55308C10010    M55308C18001    M55308C02000    M55310C05006
@{counters_to_be_increased}=    M55311C10006
@{counters_to_be_equal}=    M55308C02002
@{local_moid_decreasing_counters}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{local_moid_increasing_counters}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
@{local_moid_equal_counters}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5

@{KPI_NR_5192e_local_moid}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{KPI_NR_5192e}=    M55308C10010    M55308C00005    M55308C00015    M55308C00017

@{KPI_NR_5193b_local_moid}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{KPI_NR_5193b}=    M55308C18001    M55308C00006    M55308C00010

@{KPI_NR_5888a_local_moid}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{KPI_NR_5888a}=    M55349C01006    M55349C00006

@{KPI_NR_5887a_local_moid}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{KPI_NR_5887a}=    M55350C01006    M55350C00006

@{KPI_NR_5244e}=    M55304C01000    M55304C01001    M55304C01002    M55304C01003    M55304C01004    M55304C01005    M55304C01006    M55304C01007
...    M55304C01008    M55304C01009    M55304C01010    M55304C01011    M55304C01012    M55304C01013    M55304C01014    M55304C01015
...    M55304C01016    M55304C01017    M55304C01018    M55304C01019    M55304C01020    M55304C01021    M55304C01022    M55304C01023
...    M55304C01024    M55304C01025    M55304C01026    M55304C01027    M55304C01028    M55304C05000    M55304C05001    M55304C05002
...    M55304C05003    M55304C05004    M55304C05005    M55304C05006    M55304C05007    M55304C05008    M55304C05009    M55304C05010
...    M55304C05011    M55304C05012    M55304C05013    M55304C05014    M55304C05015    M55304C05016    M55304C05017    M55304C05018
...    M55304C05019    M55304C05020    M55304C05021    M55304C05022    M55304C05023    M55304C05024    M55304C05025    M55304C05026
...    M55304C05027    M55304C00001    M55308C10001    M55308C10003    M55308C10010    M55308C00005    M55308C00015    M55308C00017

@{KPI_NR_5245d}=    M55304C03000    M55304C03001    M55304C03002    M55304C03003    M55304C03004    M55304C03005    M55304C03006    M55304C03007
...    M55304C03008    M55304C03009    M55304C03010    M55304C03011    M55304C03012    M55304C03013    M55304C03014    M55304C03015
...    M55304C03016    M55304C03017    M55304C03018    M55304C03019    M55304C03020    M55304C03021    M55304C03022    M55304C03023
...    M55304C03024    M55304C03025    M55304C03026    M55304C03027    M55304C03028    M55304C07000    M55304C07001    M55304C07002
...    M55304C07003    M55304C07004    M55304C07005    M55304C07006    M55304C07007    M55304C07008    M55304C07009    M55304C07010
...    M55304C07011    M55304C07012    M55304C07013    M55304C07014    M55304C07015    M55304C07016    M55304C07017    M55304C07018
...    M55304C07019    M55304C07020    M55304C07021    M55304C07022    M55304C07023    M55304C07024    M55304C07025    M55304C07026
...    M55304C07027    M55304C09000    M55304C09001    M55304C09002    M55304C09003    M55304C09004    M55304C09005    M55304C09006
...    M55304C09007    M55304C09008    M55304C09009    M55304C09010    M55304C09011    M55304C09012    M55304C09013    M55304C09014
...    M55304C09015    M55304C09016    M55304C09017    M55304C09018    M55304C09019    M55304C09020    M55304C09021    M55304C09022
...    M55304C09023    M55304C09024    M55304C09025    M55304C09026    M55304C09027    M55304C00001    M55308C10002    M55308C10004
...    M55308C18001    M55308C00006    M55308C00010

@{UE5_dl_trf_ids_enhanced}=    1    2
@{UE5_dl_mbps_enhanced}=    70    70
@{UE5_dl_qfi_ids_enhanced}=    1    1
@{UE5_ul_trf_ids_enhanced}=    3
@{UE5_ul_mbps_enhanced}=    20
@{UE5_ul_qfi_ids_enhanced}=    1

@{UE50_dl_trf_ids_enhanced}=    4
@{UE50_dl_mbps_enhanced}=    30
@{UE50_dl_qfi_ids_enhanced}=    1
@{UE50_ul_trf_ids_enhanced}=    5
@{UE50_ul_mbps_enhanced}=    30
@{UE50_ul_qfi_ids_enhanced}=    1

@{UE51_dl_trf_ids_enhanced}=    6
@{UE51_dl_mbps_enhanced}=    30
@{UE51_dl_qfi_ids_enhanced}=    1
@{UE51_ul_trf_ids_enhanced}=    7
@{UE51_ul_mbps_enhanced}=    30
@{UE51_ul_qfi_ids_enhanced}=    1

@{UE6_dl_trf_ids_enhanced}=    8    9
@{UE6_dl_mbps_enhanced}=    150    150
@{UE6_dl_qfi_ids_enhanced}=    1    1
@{UE6_ul_trf_ids_enhanced}=    10
@{UE6_ul_mbps_enhanced}=    80
@{UE6_ul_qfi_ids_enhanced}=    1

@{UE60_dl_trf_ids_enhanced}=    11    12
@{UE60_dl_mbps_enhanced}=    70    70
@{UE60_dl_qfi_ids_enhanced}=    1    1
@{UE60_ul_trf_ids_enhanced}=    13
@{UE60_ul_mbps_enhanced}=    30
@{UE60_ul_qfi_ids_enhanced}=    1

@{UE61_dl_trf_ids_enhanced}=    14
@{UE61_dl_mbps_enhanced}=    30
@{UE61_dl_qfi_ids_enhanced}=    1
@{UE61_ul_trf_ids_enhanced}=    15
@{UE61_ul_mbps_enhanced}=    30
@{UE61_ul_qfi_ids_enhanced}=    1
