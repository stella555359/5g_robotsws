*** Settings ***
Documentation
...   PM counters verfication keywords for CB012268
...   author:       Dawid Chuchnowski
...   maintainer:   Jakub Matuszczyk
...   contact:      jakub.matuszczyk@nokia.com
...   team:         KRK6

*** Variables ***
${TARGET_CELL_MOID}=         PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-260
${CB012268_A_counters}=         SEPARATOR=
...                             M55353C01001,M55353C00001,M55353C00034
${CB012268_E_counters}=         SEPARATOR=
...                             M55350C00070,M55350C00071,M55350C00072,M55350C00073,M55350C00074,M55350C00075,
...                             M55350C00076,M55350C00077,M55350C00078,M55350C00079
${CB012268_F_counters}=         SEPARATOR=
...                             M55373C00001,M55373C00002,M55373C00003,M55373C00004,M55373C00005,M55373C00006

*** Keywords ***
Check UL throughput volume counters for CB012268-A
    [Documentation]     This keyword verifies CB012268-A counters
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55353C01001    >0    ThpTimeUl UL UE Throughput Time at RLC PDU level NRPMQAP
    ...    M55353C00001    >0    ThpVolUl UL UE Throughput Volume at RLC PDU level Total NRPMQAP
    ...    M55353C00034    >0    ThpVolUl UL UE Throughput Volume at RLC SDU level Total NRPMQAP
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}


Check DL throughput volume counters for CB012268-F are zeroed out
    [Documentation]     This keyword ensures that CB012268-F counters are zeroed out
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55309C00036    0    ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level for FR2
    ...    M55309C00037    0    ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level for FR2
    ...    M55373C00001    0    ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level NRPMQAP for FR2
    ...    M55373C00002    0    ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level NRPMQAP for FR2
    ...    M55309C00002    0    ThpVolDl DL UE Throughput Volume at MAC SDU Level
    ...    M55309C00003    0    ThpTimeDl DL UE Throughput Time at MAC SDU Level
    ...    M55373C00005    0    ThpVolDl DL UE Throughput Volume at MAC SDU Level NRPMQAP
    ...    M55373C00006    0    ThpTimeDl DL UE Throughput Time at MAC SDU Level NRPMQAP
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}


Check DL throughput volume counters for CB012268-F are incremented
    [Documentation]     This keyword verifies that CB012268-F counters are incremented
    [Arguments]    ${cell_id}    ${nrpmqap_profile}
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55309C00036    >0    ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level for FR2
    ...    M55309C00037    >0    ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level for FR2
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}
    Verify NRPMQAP throughput counters for cell
    ...    pm_file=${pm_counter_file}
    ...    counters_list=${CB012268_F_counters}
    ...    cell_id=${cell_id}
    ...    nrpmqap_profile=${nrpmqap_profile}

Check PM counters for CB012268-E
    [Documentation]     This keyword verifies that CB012268-E DL PDCP SDUs size counters are correct
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55350C00070    >0    Number of DL PDCP SDUs whose size is in Bin0
    ...    M55350C00071    >0    Number of DL PDCP SDUs whose size is in Bin1
    ...    M55350C00072    >0    Number of DL PDCP SDUs whose size is in Bin2
    ...    M55350C00073    >0    Number of DL PDCP SDUs whose size is in Bin3
    ...    M55350C00074    >0    Number of DL PDCP SDUs whose size is in Bin4
    ...    M55350C00075    >0    Number of DL PDCP SDUs whose size is in Bin5
    ...    M55350C00076    >0    Number of DL PDCP SDUs whose size is in Bin6
    ...    M55350C00077    >0    Number of DL PDCP SDUs whose size is in Bin7
    ...    M55350C00078    >100000    Number of DL PDCP SDUs whose size is in Bin8
    ...    M55350C00079    >0    Number of DL PDCP SDUs whose size is in Bin9
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}


Check DL and UL Cell PDCP throughput layer counters
    [Arguments]         ${expected_DL}    ${expected_UL}
    [Documentation]     This keyword verifies that CB012268-C DL PDCP SDUs size counters are correct
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55350C00068    ${expected_DL}    Max DL Cell throughput in PDCP layer
    ...    M55350C00069    ${expected_UL}    Max UL Cell throughput in PDCP layer
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}


Check Cell Edge NR MAC PDU throughput counters
    [Documentation]     This keyword verifies Cell Edge NR MAC PDU throughput counters
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55394C00001    >0    Initial transmission volume on PDSCH for UEs in Cell Edge
    ...    M55394C00004    >0    Initial transmission volume on PUSCH for UEs in Cell Edge
    ...    M55394C00007    >0    Number of PDSCH PRBs used by UEs in Cell Edge
    ...    M55394C00010    >0    Number of PUSCH PRBs used by UEs in Cell Edge
    ...    M55394C00003    0    Initial transmission volume on PDSCH for UEs in Cell Middle range
    ...    M55394C00006    0    Initial transmission volume on PUSCH for UEs in Cell Middle range
    ...    M55394C00009    0    Number of PDSCH PRBs used by UEs in Cell Middle range
    ...    M55394C00012    0    Number of PUSCH PRBs used by UEs in Cell Middle range
    ...    M55394C00002    0    Initial transmission volume on PDSCH for UEs in Cell Near range
    ...    M55394C00005    0    Initial transmission volume on PUSCH for UEs in Cell Near range
    ...    M55394C00008    0    Number of PDSCH PRBs used by UEs in Cell Near range
    ...    M55394C00011    0    Number of PUSCH PRBs used by UEs in Cell Near range
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}

Check Cell Middle range NR MAC PDU throughput counters
    [Documentation]     This keyword verifies Cell Middle range NR MAC PDU throughput counters
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55394C00001    0    Initial transmission volume on PDSCH for UEs in Cell Edge
    ...    M55394C00004    0    Initial transmission volume on PUSCH for UEs in Cell Edge
    ...    M55394C00007    0    Number of PDSCH PRBs used by UEs in Cell Edge
    ...    M55394C00010    0    Number of PUSCH PRBs used by UEs in Cell Edge
    ...    M55394C00003    >0    Initial transmission volume on PDSCH for UEs in Cell Middle range
    ...    M55394C00006    >0    Initial transmission volume on PUSCH for UEs in Cell Middle range
    ...    M55394C00009    >0    Number of PDSCH PRBs used by UEs in Cell Middle range
    ...    M55394C00012    >0    Number of PUSCH PRBs used by UEs in Cell Middle range
    ...    M55394C00002    0    Initial transmission volume on PDSCH for UEs in Cell Near range
    ...    M55394C00005    0    Initial transmission volume on PUSCH for UEs in Cell Near range
    ...    M55394C00008    0    Number of PDSCH PRBs used by UEs in Cell Near range
    ...    M55394C00011    0    Number of PUSCH PRBs used by UEs in Cell Near range
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}

Check Cell Near range NR MAC PDU throughput counters
    [Documentation]     This keyword verifies Cell Near range NR MAC PDU throughput counters
    ${pm_counter_file}=    	Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55394C00001    0    Initial transmission volume on PDSCH for UEs in Cell Edge
    ...    M55394C00004    0    Initial transmission volume on PUSCH for UEs in Cell Edge
    ...    M55394C00007    0    Number of PDSCH PRBs used by UEs in Cell Edge
    ...    M55394C00010    0    Number of PUSCH PRBs used by UEs in Cell Edge
    ...    M55394C00003    0    Initial transmission volume on PDSCH for UEs in Cell Middle range
    ...    M55394C00006    0    Initial transmission volume on PUSCH for UEs in Cell Middle range
    ...    M55394C00009    0    Number of PDSCH PRBs used by UEs in Cell Middle range
    ...    M55394C00012    0    Number of PUSCH PRBs used by UEs in Cell Middle range
    ...    M55394C00002    >0    Initial transmission volume on PDSCH for UEs in Cell Near range
    ...    M55394C00005    >0    Initial transmission volume on PUSCH for UEs in Cell Near range
    ...    M55394C00008    >0    Number of PDSCH PRBs used by UEs in Cell Near range
    ...    M55394C00011    >0    Number of PUSCH PRBs used by UEs in Cell Near range
    ...    local_moid=${TARGET_CELL_MOID}
    ...    file_path=${pm_counter_file}