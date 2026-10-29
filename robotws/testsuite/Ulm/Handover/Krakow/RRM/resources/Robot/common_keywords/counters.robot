# robocop: off=unused-argument
*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ta5g_pm_counters
Library     ../../Python/floating_counters.py


*** Keywords ***

Wait until PM counters file is ready and saved
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Set suite variable  ${PM_COUNTERS}  ${PM_COUNTERS}

Wait until aggreagted PM counters file is ready and saved
    ${PM_COUNTERS}=    stop collecting counters
    Set suite variable  ${PM_COUNTERS}  ${PM_COUNTERS}

Verify counter value on NRCELL-1 for ${pi_id} - ${NetAct_name} equals ${occurences}
    Verify Last Counters In File
    ...    ${pi_id}     ${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

Verify counter value on NRBTS-1 for ${pi_id} - ${NetAct_name} equals ${occurences}
    Verify Last Counters In File
    ...    ${pi_id}     ${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

Verify counter value on NRPMQAP-${nrpmqap_id:\d+} for ${pi_id} - ${NetAct_name} equals ${occurences}
    Verify Last Counters In File
    ...    ${pi_id}     ${occurences}    ${NetAct_name}
    ...    local_moid=PLMN-PLMN/NRPMQAP-${nrpmqap_id}
    ...    file_path=${PM_COUNTERS}

Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is equal ${value:\d+}
    Run Keyword And Continue On Failure
    ...  Verify that RTPM counter value is equal to
	...    object_name=${object_name}
	...    counter_id=${counter_id}
	...    value=${value}

Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is in range ${lower:\d+} - ${higher:\d+}
    Run Keyword And Continue On Failure
    ...  Verify that RTPM counter value is equal to
	...    object_name=${object_name}
	...    counter_id=${counter_id}
	...    value=[${lower},${higher}]

Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is above ${value:\d+}
    Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is in range ${value} - 99999999
