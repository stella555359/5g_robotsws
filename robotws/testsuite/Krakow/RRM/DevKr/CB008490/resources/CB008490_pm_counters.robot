*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Malgorzata Konior

Resource    CB008490-common_keywords.robot

*** Keywords ***
Wait until PM counter files are ready and saved for gNBs
    @{PM_FILES_LIST}                  download_counters_reports
    Set suite variable    ${PM_COUNTERS_GNB_2}    ${PM_FILES_LIST}[0]
    Set suite variable    ${PM_COUNTERS_GNB_3}    ${PM_FILES_LIST}[1]

Wait until RD PM counter files are ready and saved for gNBs
    @{PM_FILES_LIST}                  download_counters_reports    counters_type=rd
    Set suite variable    ${PM_COUNTERS_GNB_2}    ${PM_FILES_LIST}[0]
    Set suite variable    ${PM_COUNTERS_GNB_3}    ${PM_FILES_LIST}[1]

Wait until PM counters file is ready and saved for NRBTS-${nrbts_id:\d+}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Set suite variable  ${PM_COUNTERS_GNB_${nrbts_id}}  ${PM_COUNTERS}

Wait until PM counters file is ready and saved for SN NRBTS-${nrbts_id:\d+}
    ${remote_host}=    get_sn_remote_host_ip
    Wait For Next Full Pm Interval    remote_host=${remote_host}
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File    remote_host=${remote_host}
    Set suite variable  ${PM_COUNTERS_GNB_${nrbts_id}}  ${PM_COUNTERS}

Verify counter value on NRBTS-${nrbts_id:\d+} NRCELL-${cell_id} for ${pi_id} - ${NetAct_name} equals ${occurences}
    Verify Last Counters In File
    ...    ${pi_id}     ${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS_GNB_${nrbts_id}}

Verify counter value on NRBTS-${nrbts_id:\d+} NRCELL-${cell_id} for ${pi_id} - ${NetAct_name} is above ${occurences}
    Verify Last Counters In File
    ...    ${pi_id}     >${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS_GNB_${nrbts_id}}

Verify counter value on MRBTS-${mrbts_id} NRBTS-${nrbts_id:\d+} NRCELL-${cell_id} for ${pi_id} - ${NetAct_name} equals ${occurences}
    Verify Last Counters In File
    ...    ${pi_id}     ${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS_GNB_${nrbts_id}}

Verify counter value on MRBTS-${mrbts_id} NRBTS-${nrbts_id:\d+} NRCELL-${cell_id} for ${pi_id} - ${NetAct_name} is above ${occurences}
    Verify Last Counters In File
    ...    ${pi_id}     >${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS_GNB_${nrbts_id}}

Verify counter value on NRBTS-${nrbts_id:\d+} NRPMQAP-${nrpmqap_id:\d+} for ${pi_id} - ${NetAct_name} equals ${occurences}
    Verify Any Counters In File
    ...    ${pi_id}     ${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/NRPMQAP-${nrpmqap_id}
    ...    file_path=${PM_COUNTERS_GNB_${nrbts_id}}

Verify counter value on NRBTS-${nrbts_id:\d+} NRPMQAP-${nrpmqap_id:\d+} for ${pi_id} - ${NetAct_name} is above ${occurences}
    Verify Any Counters In File
    ...    ${pi_id}     >${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/NRPMQAP-${nrpmqap_id}
    ...    file_path=${PM_COUNTERS_GNB_${nrbts_id}}
