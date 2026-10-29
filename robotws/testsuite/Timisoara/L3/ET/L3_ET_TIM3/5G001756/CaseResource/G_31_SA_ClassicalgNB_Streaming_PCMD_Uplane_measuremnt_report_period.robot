*** Settings ***
Documentation
...  author : yin.4.chen@nokia-sbell.com

#Resource   ../Resource/Common.robot


*** Keyword ***
G_31_SA_ClassicalgNB_Streaming_PCMD_Uplane_measuremnt_report_period
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${flag}   Set Variable   ${False}
    ${status}   Set Variable   ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_TIMESTAMP.keys()}
        ${s1}   Run Keyword And Return Status
        ...   Set Test Variable   ${ULRBRLCMEASRECORD_LIST}   ${ALL_PCMD_TIMESTAMP['${crnti}']['ulRbRlcMeasRecord']}
        ${s2}   Run Keyword And Return Status
        ...   Set Test Variable   ${DLRBRLCMEASRECORD_LIST}   ${ALL_PCMD_TIMESTAMP['${crnti}']['dlRbRlcMeasRecord']}
        ${s3}   Run Keyword And Return Status
        ...   Set Test Variable   ${ULSCHEDULINGRECORD_LIST}   ${ALL_PCMD_TIMESTAMP['${crnti}']['ulSchedulingRecord']}
        ${s4}   Run Keyword And Return Status
        ...   Set Test Variable   ${DLSCHEDULINGRECORD_LIST}   ${ALL_PCMD_TIMESTAMP['${crnti}']['dlSchedulingRecord']}
        ${s5}   Run Keyword And Return Status
        ...   Set Test Variable   ${BEAMUSAGERECORD_LIST}   ${ALL_PCMD_TIMESTAMP['${crnti}']['beamUsageRecord']}
        ${flag}   Set Variable If   ${s1} and ${s2} and ${s3} and ${s4} and ${s5}   ${True}   ${flag}
        ${status}   Run Keyword And Return Status   Run Keyword If   ${flag}   Check Msgs Timestamp Equal
        Exit For Loop If   ${flag} and ${status}
    END
    run keyword if  not ${flag} and ${status}   Fail   Check Msgs Timestamp Equal Fail!

Check Msgs Timestamp Equal
    ${ulRbRlcMeasRecord_length}   Get Length   ${ulRbRlcMeasRecord_list}
    ${dlRbRlcMeasRecord_length}   Get Length   ${dlRbRlcMeasRecord_list}
    ${ulSchedulingRecord_length}   Get Length   ${ulSchedulingRecord_list}
    ${dlSchedulingRecord_length}   Get Length   ${dlSchedulingRecord_list}
    ${beamUsageRecord_length}   Get Length   ${beamUsageRecord_list}

    Should Be Equal As Integers   ${ulRbRlcMeasRecord_length}   ${dlRbRlcMeasRecord_length}
    Should Be Equal As Integers   ${ulSchedulingRecord_length}   ${dlSchedulingRecord_length}

    Should Be Equal As Integers   ${ulSchedulingRecord_length}   ${beamUsageRecord_length}
    Should Be Equal As Integers   ${dlSchedulingRecord_length}   ${beamUsageRecord_length}

    ${ulRbRlcMeas_s_0}   Set Variable   ${ulRbRlcMeasRecord_list[0]['seconds']}
    ${ulRbRlcMeas_us_0}   Set Variable   ${ulRbRlcMeasRecord_list[0]['useconds']}

    ${ulScheduling_s_0}   Set Variable   ${ulSchedulingRecord_list[0]['seconds']}
    ${ulScheduling_us_0}   Set Variable   ${ulSchedulingRecord_list[0]['useconds']}

    ${interval_0}   Evaluate   abs((${ulRbRlcMeas_s_0} - ${ulScheduling_s_0}) * 1000000 + (${ulRbRlcMeas_us_0} - ${ulScheduling_us_0}))

    Run Keyword If   ${interval_0} > 1000000   Run Keywords
    ...   Remove From List   ${ulSchedulingRecord_list}   0   AND
    ...   Remove From List   ${dlSchedulingRecord_list}   0

    FOR   ${index}    IN RANGE    ${0}   ${ulRbRlcMeasRecord_length - 3}
        ${ulRbRlcMeas_s}   Set Variable   ${ulRbRlcMeasRecord_list[${index}]['seconds']}
        ${ulRbRlcMeas_us}   Set Variable   ${ulRbRlcMeasRecord_list[${index}]['useconds']}

        ${dlRbRlcMeas_s}   Set Variable   ${dlRbRlcMeasRecord_list[${index}]['seconds']}
        ${dlRbRlcMeas_us}   Set Variable   ${dlRbRlcMeasRecord_list[${index}]['useconds']}

        ${ulScheduling_s}   Set Variable   ${ulSchedulingRecord_list[${index}]['seconds']}
        ${ulScheduling_us}   Set Variable   ${ulSchedulingRecord_list[${index}]['useconds']}

        ${dlScheduling_s}   Set Variable   ${dlSchedulingRecord_list[${index}]['seconds']}
        ${dlScheduling_us}   Set Variable   ${dlSchedulingRecord_list[${index}]['useconds']}

        ${interval_1}   Evaluate   abs((${ulRbRlcMeas_s} - ${dlRbRlcMeas_s}) * 1000000 + (${ulRbRlcMeas_us} - ${dlRbRlcMeas_us}))
        ${interval_2}   Evaluate   abs((${ulScheduling_s} - ${dlScheduling_s}) * 1000000 + (${ulScheduling_us} - ${dlScheduling_us}))
        ${interval_3}   Evaluate   abs((${ulRbRlcMeas_s} - ${ulScheduling_s}) * 1000000 + (${ulRbRlcMeas_us} - ${ulScheduling_us}))
        ${interval_4}   Evaluate   abs((${ulRbRlcMeas_s} - ${dlScheduling_s}) * 1000000 + (${ulRbRlcMeas_us} - ${dlScheduling_us}))
        ${interval_5}   Evaluate   abs((${dlRbRlcMeas_s} - ${ulScheduling_s}) * 1000000 + (${dlRbRlcMeas_us} - ${ulScheduling_us}))
        ${interval_6}   Evaluate   abs((${dlRbRlcMeas_s} - ${dlScheduling_s}) * 1000000 + (${dlRbRlcMeas_us} - ${dlScheduling_us}))

        Should Be True   ${interval_1} < 2000000
        Should Be True   ${interval_2} < 2000000
        Should Be True   ${interval_3} < 2000000
        Should Be True   ${interval_4} < 2000000
        Should Be True   ${interval_5} < 2000000
        Should Be True   ${interval_6} < 2000000
    END

Case Setup: G_31
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: G_31
    Load Pcap File with Filter any Expression
    ...   pcap_file=${TCPDUMP_PATH}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType || nsetapx.DuVendorExtensionRecordDataType
    ...   filter=tcp.dstport==${dcap_server_port}
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

Case Teardown: G_31
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: G_31
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756
