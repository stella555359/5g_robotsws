*** Settings ***
Documentation
...  author : yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot


*** Keyword ***
G_30_SA_ClassicalgNB_Streaming_PCMD_Uplane_Multiple_Bearers_report
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
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
        ${status}   Run Keyword And Return Status   Run Keyword If   ${flag}   Check Msgs Interval Less
        Exit For Loop If   ${flag} and ${status}
    END
    run keyword if  not ${flag} and ${status}   Fail   Check Msgs Interval Less Fail!

Check Msgs Interval Less
    ${ulRbRlcMeasRecord_length}   Get Length   ${ulRbRlcMeasRecord_list}
    ${dlRbRlcMeasRecord_length}   Get Length   ${dlRbRlcMeasRecord_list}
    ${ulSchedulingRecord_length}   Get Length   ${ulSchedulingRecord_list}
    ${dlSchedulingRecord_length}   Get Length   ${dlSchedulingRecord_list}
    ${beamUsageRecord_length}   Get Length   ${beamUsageRecord_list}

    FOR   ${index}    IN RANGE    ${0}   ${ulSchedulingRecord_length - 2}
        ${pre_seconds}   Set Variable   ${ulSchedulingRecord_list[${index}]['seconds']}
        ${pre_useconds}   Set Variable   ${ulSchedulingRecord_list[${index}]['useconds']}
        ${next_seconds}   Set Variable   ${ulSchedulingRecord_list[${index+1}]['seconds']}
        ${next_useconds}   Set Variable   ${ulSchedulingRecord_list[${index+1}]['useconds']}
        ${interval}   Evaluate   (${next_seconds} - ${pre_seconds}) * 1000000 + (${next_useconds} - ${pre_useconds}) - 4096000
        Should Be True   ${interval} < 1000000
    END
    FOR   ${index}    IN RANGE    ${0}   ${dlSchedulingRecord_length - 2}
        ${pre_seconds}   Set Variable   ${dlSchedulingRecord_list[${index}]['seconds']}
        ${pre_useconds}   Set Variable   ${dlSchedulingRecord_list[${index}]['useconds']}
        ${next_seconds}   Set Variable   ${dlSchedulingRecord_list[${index+1}]['seconds']}
        ${next_useconds}   Set Variable   ${dlSchedulingRecord_list[${index+1}]['useconds']}
        ${interval}   Evaluate   (${next_seconds} - ${pre_seconds}) * 1000000 + (${next_useconds} - ${pre_useconds}) - 4096000
        Should Be True   ${interval} < 1000000
    END
    FOR   ${index}    IN RANGE    ${0}   ${beamUsageRecord_length - 2}
        ${pre_seconds}   Set Variable   ${beamUsageRecord_list[${index}]['seconds']}
        ${pre_useconds}   Set Variable   ${beamUsageRecord_list[${index}]['useconds']}
        ${next_seconds}   Set Variable   ${beamUsageRecord_list[${index+1}]['seconds']}
        ${next_useconds}   Set Variable   ${beamUsageRecord_list[${index+1}]['useconds']}
        ${interval}   Evaluate   (${next_seconds} - ${pre_seconds}) * 1000000 + (${next_useconds} - ${pre_useconds}) - 4096000
        Should Be True   ${interval} < 1000000
    END

    FOR   ${index}    IN RANGE    ${0}   ${ulRbRlcMeasRecord_length - 3}
        ${pre_seconds}   Set Variable   ${ulRbRlcMeasRecord_list[${index}]['seconds']}
        ${pre_useconds}   Set Variable   ${ulRbRlcMeasRecord_list[${index}]['useconds']}
        ${next_seconds}   Set Variable   ${ulRbRlcMeasRecord_list[${index+1}]['seconds']}
        ${next_useconds}   Set Variable   ${ulRbRlcMeasRecord_list[${index+1}]['useconds']}
        ${interval}   Evaluate   (${next_seconds} - ${pre_seconds}) * 1000000 + (${next_useconds} - ${pre_useconds}) - 4096000
        Should Be True   ${interval} < 1000000
    END
    FOR   ${index}    IN RANGE    ${0}   ${dlRbRlcMeasRecord_length - 3}
        ${pre_seconds}   Set Variable   ${dlRbRlcMeasRecord_list[${index}]['seconds']}
        ${pre_useconds}   Set Variable   ${dlRbRlcMeasRecord_list[${index}]['useconds']}
        ${next_seconds}   Set Variable   ${dlRbRlcMeasRecord_list[${index+1}]['seconds']}
        ${next_useconds}   Set Variable   ${dlRbRlcMeasRecord_list[${index+1}]['useconds']}
        ${interval}   Evaluate   (${next_seconds} - ${pre_seconds}) * 1000000 + (${next_useconds} - ${pre_useconds}) - 4096000
        Should Be True   ${interval} < 1000000
    END

Case Setup: G_30
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: G_30

Case Teardown: G_30
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: G_30
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756
