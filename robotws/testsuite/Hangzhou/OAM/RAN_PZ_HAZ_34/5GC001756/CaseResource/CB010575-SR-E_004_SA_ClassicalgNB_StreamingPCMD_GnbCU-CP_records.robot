*** Settings ***
Documentation
...  author: Jiang Shengyuan
...  contact: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keywords ***
CB010575-SR-E_004_SA_ClassicalgNB_StreamingPCMD_GnbCU-CP_records
    [Arguments]  ${tcpdump}=${TCPDUMP_PATH}
    Check CU-CP records   tcpdump=${tcpdump}

Case Setup: SR-E_004
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: SR-E_004

Case Teardown: SR-E_004
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: SR-E_004

Check CU-CP records
    [Arguments]  ${tcpdump}=${TCPDUMP_PATH}
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 23 && nsetapx.cuUpBearerCtxSetupResult == 0
    ...                        filter=tcp.dstport==49148
    ${crnti}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_list}   Remove Duplicates   ${crnti}

    ${flag}   Set Variable   ${false}
    FOR   ${crnti}   IN   @{crnti_list}
        ${flag}   Run Keyword And Return Status   Check CU-CP Records in Single Call   ${tcpdump}   ${crnti}
        Exit For Loop If   ${flag}
    END
    run keyword if  not ${flag}   Fail   Message Not Found!

Check CU-CP Records in Single Call
    [Arguments]  ${tcpdump}   ${crnti}
    Log To Console   Check ueCuUpConnectivityRecord
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 23 && nsetapx.crnti == ${crnti}
    ...                        filter=tcp.dstport==49148

    ${xpath}   Set Variable   .//nsetapx.ueCuUpConnectivityRecord/nsetapx.data_element/nsetapx.setupData//nsetapx.CuUpBearerCtxSetupData_element
    ${result}   wireshark.get_field_value_by_xpath
        ...    xpath=${xpath}/nsetapx.cuUpBearerCtxSetupResult
        ...   attribute_name=showname
    Should Contain   ${result}   cuUpBearerCtxSetupResult: success (0)

    Log To Console   Check bearerCtxSetupRecord
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.CuUpVendorExtensionRecordDataType == 0
    ...                        filter=tcp.dstport==49148

    ${xpath}   Set Variable   .//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.result
    ${result}   wireshark.get_field_value_by_xpath
        ...    xpath=${xpath}
        ...   attribute_name=showname
    Should Contain   ${result}   result: success (0)

    Log To Console   Check bearerRecord
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.CuUpVendorExtensionRecordDataType == 2
    ...                        filter=tcp.dstport==49148

    ${xpath}   Set Variable   .//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.trigger
    ${trigger}   wireshark.get_field_value_by_xpath
        ...    xpath=${xpath}
        ...   attribute_name=showname
    Should Not Be Empty   ${trigger}

    Log To Console   Check pduSessionResourceInfoRecord
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.CuUpVendorExtensionRecordDataType == 1
    ...                        filter=tcp.dstport==49148

    ${xpath}   Set Variable   .//nsetapx.pduSessionResourceInfoRecord/nsetapx.data_element/nsetapx.result
    ${result}   wireshark.get_field_value_by_xpath
        ...    xpath=${xpath}
        ...   attribute_name=showname
    Should Contain   ${result}   result: success (0)
