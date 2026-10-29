*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***
@{cucp_tracerecords}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == rrcSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == caConfigurationRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord

@{cuup_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerCtxSetupRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord

@{du_tracerecords}    nsetapx.DuVendorExtensionRecordDataType == ulRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord


*** Keywords ***
Check multi tracerecords
    [Arguments]     ${tracerecords}    ${host}   ${traceId}=00:00:01    ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecords    tracerecords=${tracerecords_index}   host=${host}   traceId=${traceId}
       ...   capture_file_path=${capture_file_path}
       Should Not Be Empty     ${tracerecord}
   END

Check tracerecords
    [Arguments]    ${tracerecords}    ${host}=mba   ${traceId}=00:00:01    ${capture_file_path}=none
    ${traceMessage}  Set Variable    'nsetapx.traceActivationType == ${host} && ${tracerecords} && nsetapx.traceId == ${traceId}'
    ${traceMessage_result} =    Decode tcpdump     input_file=${capture_file_path}
    ...                                            filter_expression=${traceMessage}
    [Return]     ${traceMessage_result}

Decode tcpdump
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence == 115
    ${tshark_comd}  catenate    tshark -r ${input_file} -o ntrstr.defragment:TRUE  -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -Y ${filter_expression}
    ${filtered_packets}    Run    ${tshark_comd}
    [Return]    ${filtered_packets}

Check common tracerecords
    [Arguments]    ${tracerecords}      ${capture_file_path}=none
    ${traceMessage}  Set Variable    '${tracerecords}'
    ${traceMessage_result} =    Decode tcpdump     input_file=${capture_file_path}
    ...                                            filter_expression=${traceMessage}
    Should Not Be Empty     ${traceMessage_result}

Check no tracerecords
    [Arguments]     ${tracerecords}    ${host}=mba   ${traceId}=00:00:01    ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecords    tracerecords=${tracerecords_index}   host=${host}   traceId=${traceId}
       ...   capture_file_path=${capture_file_path}
       Should Be Empty     ${tracerecord}
   END
