*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ta5g_pm_counters

*** Variables ***


*** Keywords ***
## Old method with floating counters
Check counter: NRCELL-${cell_id} ${counter_name} (${counter_id}) is equal ${value}
    Run Keyword And Continue On Failure
    ...  Verify any counters in file
    ...      ${counter_id}     ${value}    ${counter_name}
    ...      local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...      file_path=${PM_COUNTERS}

Check counter: NRCELL-${cell_id} ${counter_name} (${counter_id}) is in range ${lower} - ${higher}
    Run Keyword And Continue On Failure
    ...  Verify Last Counters In File
    ...      ${counter_id}  > ${lower}  ${counter_name}
    ...      ${counter_id}  < ${higher}  ${counter_name}
    ...      local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...      file_path=${PM_COUNTERS}
