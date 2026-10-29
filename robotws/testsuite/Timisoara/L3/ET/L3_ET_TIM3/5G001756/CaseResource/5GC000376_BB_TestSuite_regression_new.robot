*** Settings ***
Documentation
...  author : liangliang.heng@nokia-sbell.com
...  contact: liangliang.heng@nokia-sbell.com   liping.hong@nokia-sbell.com

#Resource        Resource/common.robot

#Force Tags   SG_07   CA_5G_OAM   CIT   CIT_TRUNK   CIT_SBTS00   CIT_25R2   CIT_25R1  SBTS00   STATE_SW_UPLOADED
#...    PY36
#...   RAN_5G   RAN_5G_TDD   CIT_22R1   CRT_UTE   CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AEQV_ENB
#...   5G_RAN   5G_RAN_TDD
#...   PY310    RF50   5G_TTI


#Suite Setup    Setup Sequence
#Suite Teardown    Teardown Sequence

#Test Setup   PCMD Common Case Setup
#Test Teardown   PCMD Common Case Teardown

*** Variables ***
${setupfail_count}    ${0}
${setupfail_count_limit}    ${1}
${setup_condition}    ${False}
${cell_string}    unknown
${dcap_server_port}    49148
${plmn_Identity}    132006
${cellIdentity}    0000040090
${cell_numbers}    1
${traceId}    000001
#${Log_directory}   /home/ute/MN/UTE/robotws/results01
#${filename5}    ZZ_lmp.pcap

*** Keyword ***
[1]5GC000376_BB_1_PCMD_ulTimeUeSched_SUlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet  ulTimeUeSched_SUlSchedulingTraceRecord
    Load Pcap File with Filter
     ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
     ...                        record_type=Du
     ...                        input_type=3
     ...                        filter=tcp.dstport==49148
    ${ulSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${ulTimeUeSched_value_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.timeOfUeSched
    Run Keyword If    0 < ${ulTimeUeSched_value_list}[0] < 134273 or ${ulTimeUeSched_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${ulTimeUeSched_length}=     Get Length   ${ulTimeUeSched_value_list}
    FOR   ${idx}    IN RANGE    1    ${ulTimeUeSched_length}
        Run Keyword If    131073 < ${ulTimeUeSched_value_list}[${idx}] < 134273
        ...   Should Be True   ${ulSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${ulTimeUeSched_value_list}[${idx}] < 131073 or ${ulTimeUeSched_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT

[1]5GC000376_BB_3_PCMD_ulBadMacPdusIniTx_SUlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet  ulBadMacPdusIniTx_SUlSchedulingTraceRecord
    Load Pcap File with Filter
     ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
     ...                        record_type=Du
     ...                        input_type=3
     ...                        filter=tcp.dstport==49148
    ${ulSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${ulBadMacPdusIniTx_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.numOfBad1stMacPduTx
    Run Keyword If    0 < ${ulBadMacPdusIniTx_value_list}[0] < 67137 or ${ulBadMacPdusIniTx_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${ulBadMacPdusIniTx_length}=     Get Length   ${ulBadMacPdusIniTx_value_list}
    FOR   ${idx}    IN RANGE    1    ${ulBadMacPdusIniTx_length}
        Run Keyword If     65537 < ${ulBadMacPdusIniTx_value_list}[${idx}] < 67137
        ...   Should Be True   ${ulSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${ulBadMacPdusIniTx_value_list}[${idx}] < 65537 or ${ulBadMacPdusIniTx_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_4_PCMD_ulBadMacPdusLastTx _SUlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet  ulBadMacPdusLastTx_SUlSchedulingTraceRecord
    Load Pcap File with Filter
     ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
     ...                        record_type=Du
     ...                        input_type=3
     ...                        filter=tcp.dstport==49148
    ${ulSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${ulBadMacPdusLastTx_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.numOfBadLastMacPduTx
    Run Keyword If    0 < ${ulBadMacPdusLastTx_value_list}[0] < 67137 or ${ulBadMacPdusLastTx_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${ulBadMacPdusLastTx_length}=     Get Length   ${ulBadMacPdusLastTx_value_list}
    FOR   ${idx}    IN RANGE    1    ${ulBadMacPdusLastTx_length}
        Run Keyword If     65537 < ${ulBadMacPdusLastTx_value_list}[${idx}] < 67137
        ...   Should Be True   ${ulSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${ulBadMacPdusLastTx_value_list}[${idx}] < 65537 or ${ulBadMacPdusLastTx_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_7_PCMD_ulMacPdusIniTx_SUlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet   ulMacPdusIniTx_SUlSchedulingTraceRecord
    Load Pcap File with Filter
     ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
     ...                        record_type=Du
     ...                        input_type=3
     ...                        filter=tcp.dstport==49148
    ${ulSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${ulMacPdusIniTx_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.numOf1stMacPduTx
    Run Keyword If    0 < ${ulMacPdusIniTx_value_list}[0] < 67137 or ${ulMacPdusIniTx_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${ulMacPdusIniTx_length}=     Get Length   ${ulMacPdusIniTx_value_list}
    FOR   ${idx}    IN RANGE    1    ${ulMacPdusIniTx_length}
        Run Keyword If     65537 < ${ulMacPdusIniTx_value_list}[${idx}] < 67137
        ...   Should Be True   ${ulSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${ulMacPdusIniTx_value_list}[${idx}] < 65537 or ${ulMacPdusIniTx_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_2_PCMD_dlTimeUeSched_SDlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet   dlTimeUeSched_SDlSchedulingTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=4
    ...                        filter=tcp.dstport==49148
    ${dlSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${dlTimeUeSched_value_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.timeOfUeSched
    Run Keyword If    0 < ${dlTimeUeSched_value_list}[0] < 134273 or ${dlTimeUeSched_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${dlTimeUeSched_length}=     Get Length   ${dlTimeUeSched_value_list}
    FOR   ${idx}    IN RANGE    1    ${dlTimeUeSched_length}
        Run Keyword If    131073 < ${dlTimeUeSched_value_list}[${idx}] < 134273
        ...   Should Be True   ${dlSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${dlTimeUeSched_value_list}[${idx}] < 131073 or ${dlTimeUeSched_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_5_PCMD_dlBadMacPdusIniTx_SDlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet   dlBadMacPdusIniTx_SDlSchedulingTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=4
    ...                        filter=tcp.dstport==49148
    ${dlSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${dlBadMacPdusIniTx_value_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.numOfBad1stMacPduTx
    Run Keyword If    0 < ${dlBadMacPdusIniTx_value_list}[0] < 67137 or ${dlBadMacPdusIniTx_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${dlBadMacPdusIniTx_length}=     Get Length   ${dlBadMacPdusIniTx_value_list}
    FOR   ${idx}    IN RANGE    1    ${dlBadMacPdusIniTx_length}
        Run Keyword If     65537 < ${dlBadMacPdusIniTx_value_list}[${idx}] < 67137
        ...   Should Be True   ${dlSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${dlBadMacPdusIniTx_value_list}[${idx}] < 65537 or ${dlBadMacPdusIniTx_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_6_PCMD_dlBadMacPdusLastTx_SDlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet   dlBadMacPdusLastTx_SDlSchedulingTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=4
    ...                        filter=tcp.dstport==49148
    ${dlSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${dlBadMacPdusLastTx_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.numOfBadLastMacPduTx
    Run Keyword If    0 < ${dlBadMacPdusLastTx_value_list}[0] < 67137 or ${dlBadMacPdusLastTx_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${dlBadMacPdusLastTx_length}=     Get Length   ${dlBadMacPdusLastTx_value_list}
    FOR   ${idx}    IN RANGE    1    ${dlBadMacPdusLastTx_length}
        Run Keyword If     65537 < ${dlBadMacPdusLastTx_value_list}[${idx}] < 67137
        ...   Should Be True   ${dlSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${dlBadMacPdusLastTx_value_list}[${idx}] < 65537 or ${dlBadMacPdusLastTx_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_8_PCMD_dlMacPdusIniTx_SDlSchedulingTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet   dlMacPdusIniTx_SDlSchedulingTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=4
    ...                        filter=tcp.dstport==49148
    ${dlSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${dlMacPdusIniTx_value_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.numOf1stMacPduTx
    Run Keyword If    0 < ${dlMacPdusIniTx_value_list}[0] < 67137 or ${dlMacPdusIniTx_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${dlMacPdusIniTx_length}=     Get Length   ${dlMacPdusIniTx_value_list}
    FOR   ${idx}    IN RANGE    1    ${dlMacPdusIniTx_length}
        Run Keyword If     65537 < ${dlMacPdusIniTx_value_list}[${idx}] < 67137
        ...   Should Be True   ${dlSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${dlMacPdusIniTx_value_list}[${idx}] < 65537 or ${dlMacPdusIniTx_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_9_PCMD_ulRlcPduTxBytes_UL_RLCTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console    check elemnet  ulRlcPduTxBytes_UL_RLCTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=5
    ...                        filter=tcp.dstport==49148
    ${ulRbRlcMeasRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.ulRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.UlRadioBearerRlcMeasData_element/nsetapx.endMarker
    ${ulRlcPduTxBytes_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.ulRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.UlRadioBearerRlcMeasData_element/nsetapx.sumOfRlcPduRxBytes
    Run Keyword If    0 < ${ulRlcPduTxBytes_value_list}[0] < 2533693758 or ${ulRlcPduTxBytes_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${ulRlcPduTxBytes_length}=     Get Length   ${ulRlcPduTxBytes_value_list}
    FOR   ${idx}    IN RANGE    1    ${ulRlcPduTxBytes_length}
        Run Keyword If     2473310208 < ${ulRlcPduTxBytes_value_list}[${idx}] < 2533693758
        ...   Should Be True   ${ulRbRlcMeasRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${ulRlcPduTxBytes_value_list}[${idx}] < 2473310208 or ${ulRlcPduTxBytes_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_10_PCMD_ulRlcTxTime_UL_RLCTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console    check elemnet  ulRlcTxTime_UL_RLCTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=5
    ...                        filter=tcp.dstport==49148
    ${ulRbRlcMeasRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.ulRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.UlRadioBearerRlcMeasData_element/nsetapx.endMarker
    ${ulRlcTxTime_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.ulRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.UlRadioBearerRlcMeasData_element/nsetapx.timeOfUePduRx
    Run Keyword If    0 < ${ulRlcTxTime_value_list}[0] < 1074176 or ${ulRlcTxTime_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${ulRlcTxTime_length}=     Get Length   ${ulRlcTxTime_value_list}
    FOR   ${idx}    IN RANGE    1    ${ulRlcTxTime_length}
        Run Keyword If     1048576 < ${ulRlcTxTime_value_list}[${idx}] < 1074176
        ...   Should Be True   ${ulRbRlcMeasRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${ulRlcTxTime_value_list}[${idx}] < 1048576 or ${ulRlcTxTime_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_11_PCMD_dlRlcPduTxBytes_DL_RLCTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console    check elemnet  dlRlcPduTxBytes_DL_RLCTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=6
    ...                        filter=tcp.dstport==49148
    ${dlRbRlcMeasRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.DlRadioBearerRlcMeasData_element/nsetapx.endMarker
    ${dlRlcPduTxBytes_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.dlRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.DlRadioBearerRlcMeasData_element/nsetapx.sumOfRlcPduTxBytes
    Run Keyword If    0 < ${dlRlcPduTxBytes_value_list}[0] < 2533693758 or ${dlRlcPduTxBytes_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${dlRlcPduTxBytes_length}=     Get Length   ${dlRlcPduTxBytes_value_list}
    FOR   ${idx}    IN RANGE    1    ${dlRlcPduTxBytes_length}
        Run Keyword If     2473310208 < ${dlRlcPduTxBytes_value_list}[${idx}] < 2533693758
        ...   Should Be True   ${dlRbRlcMeasRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${dlRlcPduTxBytes_value_list}[${idx}] < 2473310208 or ${dlRlcPduTxBytes_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_12_PCMD_dlRlcTxTime_DL_RLCTraceRecord_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet dlRlcTxTime_DL_RLCTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=6
    ...                        filter=tcp.dstport==49148
    ${dlRbRlcMeasRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.DlRadioBearerRlcMeasData_element/nsetapx.endMarker
    ${dlRlcTxTime_value_list}=    wireshark.get_field_value_by_xpath
    ...  xpath=.//nsetapx.dlRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.DlRadioBearerRlcMeasData_element/nsetapx.timeOfUePduTx
    Run Keyword If    0 < ${dlRlcTxTime_value_list}[0] < 1074176 or ${dlRlcTxTime_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${dlRlcTxTime_length}=     Get Length   ${dlRlcTxTime_value_list}
    FOR   ${idx}    IN RANGE    1    ${dlRlcTxTime_length}
        Run Keyword If     1048576 < ${dlRlcTxTime_value_list}[${idx}] < 1074176
        ...   Should Be True   ${dlRbRlcMeasRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${dlRlcTxTime_value_list}[${idx}] < 1048576 or ${dlRlcTxTime_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_24_PCMD_sumOfWbCqi_SDlSchedulingTraceRecor_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
   [Timeout]  4h
#   [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet   sumOfWbCqi_SDlSchedulingTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=4
    ...                        filter=tcp.dstport==49148
    ${dlSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${sumOfWbCqi_value_list}=    wireshark.get_field_value_by_xpath
    ...         xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.avgTb0WbCqi_element/nsetapx.sumOfWbCqi
    Run Keyword If    0 < ${sumOfWbCqi_value_list}[0] < 503520 or ${sumOfWbCqi_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${sumOfWbCqi_length}=     Get Length   ${sumOfWbCqi_value_list}
    FOR   ${idx}    IN RANGE    1    ${sumOfWbCqi_length}
        Run Keyword If     491520 < ${sumOfWbCqi_value_list}[${idx}] < 503520
        ...   Should Be True   ${dlSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${sumOfWbCqi_value_list}[${idx}] < 491520 or ${sumOfWbCqi_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC000376_BB_25_PCMD_numOfWbCqiSamples_ DlSchedulingTraceRecor_Counter
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet   numOfWbCqiSamples_DlSchedulingTraceRecord
    Load Pcap File with Filter
    ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...                        record_type=Du
    ...                        input_type=4
    ...                        filter=tcp.dstport==49148
    ${dlSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
    ${numOfWbCqiSamples_value_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.dlSchedulingRecord/nsetapx.data_element/nsetapx.avgTb0WbCqi_element/nsetapx.numOfWbCqiSamples
    Run Keyword If    0 < ${numOfWbCqiSamples_value_list}[0] < 33568 or ${numOfWbCqiSamples_value_list}[0]==0
    ...    Log To Console   first value is OK!
    ${numOfWbCqiSamples_length}=     Get Length   ${numOfWbCqiSamples_value_list}
    FOR   ${idx}    IN RANGE    1    ${numOfWbCqiSamples_length}
        Run Keyword If     32768 < ${numOfWbCqiSamples_value_list}[${idx}] < 33568
        ...   Should Be True   ${dlSchedulingRecord_endMark_list}[${idx-1}] ==1
        ...   ELSE    Should Be True   0 < ${numOfWbCqiSamples_value_list}[${idx}] < 32768 or ${numOfWbCqiSamples_value_list}[${idx}]==0
    END
    Log To Console   check value is OK!
#    [Teardown]   Case Teardown CIT
#
[1]5GC001756_B_1_NSA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_SINR
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet  SINR_SUlSchedulingTraceRecord
    Load Pcap File with Filter
     ...                        pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
     ...                        record_type=Du
     ...                        input_type=3
     ...                        filter=tcp.dstport==49148
    ${sumOfSinrSamples_value_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.avgSinr_element/nsetapx.sumOfSinrSamples
    ${numOfSinrSamples_value_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.avgSinr_element/nsetapx.numOfSinrSamples
    ${sumOfSinrSamples_length}=     Get Length   ${sumOfSinrSamples_value_list}
    ${numOfSinrSamples_length}=     Get Length   ${numOfSinrSamples_value_list}
    Should Be True   ${sumOfSinrSamples_length} == ${numOfSinrSamples_length}
    FOR   ${idx}    IN RANGE    0   ${sumOfSinrSamples_length}
        ${numOfSinrSamples}   Set Variable   ${numOfSinrSamples_value_list}[${idx}]
        ${sumOfSinrSamples}   Set Variable   ${sumOfSinrSamples_value_list}[${idx}]
        ${min_sumOfSinrSamples}   Evaluate   ${numOfSinrSamples}* ${-10}
        ${max_sumOfSinrSamples}   Evaluate   ${numOfSinrSamples}* ${40}
        Should Be True   ${numOfSinrSamples} >0 or ${numOfSinrSamples}==0
        Should Be True   ${sumOfSinrSamples} > ${min_sumOfSinrSamples} or ${sumOfSinrSamples} == ${min_sumOfSinrSamples}
        Should Be True   ${sumOfSinrSamples} < ${max_sumOfSinrSamples} or ${sumOfSinrSamples} == ${max_sumOfSinrSamples}
    END
    Log To Console   check value is OK
#    [Teardown]   Case Teardown CIT
#
[1]5GC001756_B_2_NSA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h
#    [Setup]   Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    log to console     check elemnet  TimingAdvance!
    Load Pcap File with Filter
     ...   pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
     ...   record_type=Du
     ...   input_type=15
     ...   filter=tcp.dstport==49148
    ${initial_value_list}=   wireshark.get_field_value_by_xpath
     ...   xpath=.//nsetapx.timingAdvanceRecord/nsetapx.data_element/nsetapx.taData/nsetapx.initial
    ${initial_value_length}=     Get Length   ${initial_value_list}
    FOR   ${idx}    IN RANGE    0   ${initial_value_length}
        Should Be True   ${initial_value_list}[${idx}] >0
    END
    Log To Console   check value is OK!
    Log To Console   Check All Timestamp!
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/ZZ_lmp.pcap
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType || nsetapx.DuVendorExtensionRecordDataType
    ...   filter=tcp.dstport==49148
    ${seconds_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.seconds
    ${useconds_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.useconds
    ${curr_date}   Get Current Date   result_format=epoch
    ${curr_date}   Convert To Integer   ${curr_date}

    FOR   ${seconds}   IN   @{seconds_list}
       ${seconds}   Convert To Integer   ${seconds}
       Should Be True   ${curr_date} - ${seconds} > 0
       Should Be True   ${curr_date} - ${seconds} < ${86400}
    END

    FOR   ${useconds}   IN   @{useconds_list}
        ${useconds}   Convert To Integer   ${useconds}
        Should Be True   ${useconds} < ${1000000}
    END
#    [Teardown]   Case Teardown CIT
#
#
#*** Keywords ***
#Setup Sequence
#    [Timeout]  2h
#    Log To Console   starting ... Setup Sequence
#
#    COAM Try Connect gNB
#    ${status}   Run Keyword And Return Status
#    ...   Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
#    Run Keyword If  '${status}'=='False'
#    ...   Catch Snapshot COAM
##    ...   AND
##    ...   Fail
#    Set Suite Variable    ${commission_status}    ${status}
#
#    AlarmWatchdog.add_allow_alarms    fault_id=8000
#    AlarmWatchdog.add_allow_alarms    fault_id=6450
#    AlarmWatchdog.add_allow_alarms    fault_id=4681
#    robot_common_operations.Common Suite Setup
#
#    Wait Until Keyword Succeeds   3 times   2m   COAM Login
#    ${pcmd_recommision_status}    run keyword and return status    Remove And Add PCMD Object
#    Set Suite Variable    ${pcmd_recommision_status}
#
#    Set Environment Variable   https_proxy   ${empty}
#    asik_handler.connect   i_ipAddr=${ASIK_IP}
#    ${SMOD_name}   Get SMOD Product Name
#    Log To Console   SMOD_name=${SMOD_name}
#    Log To Console   startup_tcpdump
#    Run Keyword If     '${SMOD_name}'=='ASIB'   asik_handler.general_tcpdump_ASIB   i_dir_path=${remote_dir_path}   i_filename=${filename5}
#    ...   ELSE IF  '${SMOD_name}'=='ASIK'  asik_handler.general_tcpdump_ASIK   i_dir_path=${remote_dir_path}   i_filename=${filename5}
#    ...   ELSE   asik_handler.general_tcpdump_ASOE   i_dir_path=${remote_dir_path}   i_filename=${filename5}
#    ${L3CALL_status}   Run Keyword And Return Status   Check CPC Connection Status
#    ${L3CALL_status}   Run Keyword And Return Status   Run Keyword If   ${L3CALL_status}   Wait Until Keyword Succeeds   3x   20s
#    ...   Call Setup and check tput   duration=60    tput=200    tput_expect=50   4G_check=false
#    Set Suite Variable    ${L3CALL_status}
#    asik_handler.kill_tcpdump
#    Log To Console   kill_tcpdump
#    Sleep   5s
#    Run Keyword and Ignore Error   asik_handler.close
#    Create Directory     ${Log_directory}
#    asik_handler.connect   i_ipAddr=${ASIK_IP}
#    asik_handler.download_file_from_Asik   i_filename=${remote_dir_path}/${filename5}   i_local_path=${Log_directory}/${filename5}
#    Run Keyword and Ignore Error   Check Extra Reset From Blackbox
#    Run Keyword and Ignore Error   Check If 6450 Occurred During Setup
#    Run Keyword and Ignore Error   COAM Logout
#    Run Keyword and Ignore Error   Start Catch Relative Log   log_dir_name=${SUITE NAME}
#
#
#Teardown Sequence
#    robot_common_operations.Common Suite Teardown
#    Wait Until Keyword Succeeds   3 times   2m   COAM Login
#    Run Keyword If Any Tests Failed   Collect Relative Log
#    Run Keyword If All Tests Passed   Delete BTS log in VM
#    Run Keyword and Ignore Error   asik_handler.close
#    Run Keyword and Ignore Error   COAM Logout
#
#
#PCMD Common Case Setup
#    robot_common_operations.Common Case Setup   allowed_faults_ids=8000
#
#
#PCMD Common Case Teardown
#    robot_common_operations.Common Case Teardown
#    CI_interface.Common Case Teardown
#
#
#Check If 6450 Occurred During Setup
##    Wait Until Keyword Succeeds   3 times   2m   COAM Login
#    ${fault_list}     create list
#    ${active_alarms}   coam.get_active_alarms    connection=COAM
#    FOR   ${active_alarm}    IN   @{active_alarms}
#        ${faultId}   Get Variable Value   ${active_alarm['faultId']}
#        append to list     ${fault_list}     ${faultId}
#    END
#    ${if_6450}     run keyword and return status     list should not contain value   ${fault_list}    ${6450}
#    Run Keyword unless     ${if_6450}
#    ...    Run Keyword and Ignore Error   Catch Snapshot COAM
##    [Teardown]    Run Keyword and Ignore Error   COAM Logout
#
#Check CPC Connection Status
#    [Arguments]   ${ue_index}=${0}
#    ${ip_address}   Get Variable Value   ${tl.ues[${ue_index}].ssh_connection_details.addr}   ${EMPTY}
#    Run Keyword If   "${ip_address}"==""   FAIL   msg=Control PC IP Address Empty.
#    Run Keyword And Ignore Error   OperatingSystem.Run   sudo chmod +s /usr/bin/ping
#    ${result}   OperatingSystem.Run   command=timeout 3s ping -c 1 ${ip_address} > /dev/null 2>&1; echo $?
#    ${result}   Strip String   ${result}
#    Should Be True   "${result}"=="0"
#
#
#Case Setup CIT
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
#    run keyword if    '${setup_condition}'=='${False}'     Setup Sequence
#    robot_common_operations.Common Case Setup
#    Download wireshark plugin
