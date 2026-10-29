*** Settings ***
Documentation   This is a keyword file for 5GC000710-C, part wireshark verification
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***
${xnap_version}     xnap

${filter_intialContextSetupRequest}   ngap.procedureCode == 14
${filter_UEContextReleaseRequest}     ngap.procedureCode == 42
${filter_registrationRequest}         ngap.procedureCode == 15

${xpath_setup}                        .//field[@name="ngap.IndexToRFSP"]
${xpath_radioNetwork}                 .//field[@name="ngap.radioNetwork"]
${xpath_HO_cause}                     .//field[@name="${xnap_version}.radioNetwork"]

${xpath_UEContextReleaseRequest}      .//field[@name="ngap.UEContextReleaseRequest_element"]
${xpath_sliceType}                    .//field[@name="nas-5gs.mm.sst"]
${xpath_sliceDifferentiator}          .//field[@name="nas-5gs.mm.mm_sd"]

${sliceType1_Differentiator}          13714341
${sliceType2_Differentiator}          13714342

${filter_handover}                    ((${xnap_version}.procedureCode==0)&&(${xnap_version}.indexToRatFrequencySelectionPriority == 99))


*** Keywords ***

verify wireshark t1
    [Documentation]    [PRIVATE]    verify wireshark for priority test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000710_C_SA_Redirection_to_target_based_on_priority_with_mobility_profiles
    Log To Console    verify UE1 ${resultDir}/UE51
    verify wireshark registrationRequest        wireshark_dir=${resultDir}/UE51     sliceType=1    sliceDifferentiator=${sliceType1_Differentiator}
    verify wireshark initialContextSetup        wireshark_dir=${resultDir}/UE51     IndexToRFSP=99
    verify wireshark UEContextReleaseRequest    wireshark_dir=${resultDir}/UE51
    Log To Console    verify UE3 ${resultDir}/UE53
    verify wireshark registrationRequest        wireshark_dir=${resultDir}/UE53     sliceType=1    sliceDifferentiator=${sliceType1_Differentiator}
    verify wireshark initialContextSetup        wireshark_dir=${resultDir}/UE53     IndexToRFSP=99
    verify wireshark UEContextReleaseRequest    wireshark_dir=${resultDir}/UE53
    Log To Console    verify UE2 ${resultDir}/UE52
    verify wireshark registrationRequest        wireshark_dir=${resultDir}/UE52     sliceType=1    sliceDifferentiator=${sliceType1_Differentiator}
    verify wireshark initialContextSetup        wireshark_dir=${resultDir}/UE52     IndexToRFSP=none
    verify wireshark no UEContextReleaseRequest    wireshark_dir=${resultDir}/UE52


verify wireshark t2
    [Documentation]    [PRIVATE]    verify wireshark for UE_capabilities test
    ...       :Autor: Sylvia Schneider
    Log To Console    wireshark verification for C_SA_Redirection_based_on_UE_capabilities_with_mobility_profiles
    Log To Console    verify UE1 ${resultDir}/UE51
    verify wireshark registrationRequest        wireshark_dir=${resultDir}/UE51     sliceType=1    sliceDifferentiator=${sliceType1_Differentiator}
    verify wireshark initialContextSetup        wireshark_dir=${resultDir}/UE51     IndexToRFSP=77
    verify wireshark no UEContextReleaseRequest    wireshark_dir=${resultDir}/UE51
    Log To Console    verify UE3 ${resultDir}/UE53
    verify wireshark registrationRequest        wireshark_dir=${resultDir}/UE53     sliceType=1    sliceDifferentiator=${sliceType1_Differentiator}
    verify wireshark initialContextSetup        wireshark_dir=${resultDir}/UE53     IndexToRFSP=77
    verify wireshark UEContextReleaseRequest    wireshark_dir=${resultDir}/UE53


verify wireshark t3
    [Documentation]    [PRIVATE]    verify wireshark for rsrpCombined test
    ...       :Autor: Sylvia Schneider
    Log To Console    wireshark verification for C_SA_Redirection_with_rsrpCombined_and_mobility_profiles
    verify wireshark registrationRequest        wireshark_dir=${resultDir}     sliceType=1    sliceDifferentiator=${sliceType2_Differentiator}
    verify wireshark initialContextSetup        wireshark_dir=${resultDir}     IndexToRFSP=none
    verify wireshark UEContextReleaseRequest    wireshark_dir=${resultDir}


verify wireshark t4
    [Documentation]    [PRIVATE]    verify wireshark for handover test
    ...       :Autor: Sylvia Schneider
    Log To Console    wireshark verification for C_SA_Redirection_after_inter_gNB_handover_with_mobility_profiles
    verify wireshark registrationRequest        wireshark_dir=${resultDir}     sliceType=1    sliceDifferentiator=${sliceType1_Differentiator}
    verify wireshark initialContextSetup        wireshark_dir=${resultDir}     IndexToRFSP=99
    verify handover                             wireshark_dir=${resultDir}
    verify wireshark UEContextReleaseRequest    wireshark_dir=${resultDir}


verify wireshark t5
    [Documentation]    [PRIVATE]    verify wireshark for redirect to LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    wireshark verification for C_SA_Redirection_to_LTE_eNB_with_mobility_profiles
    verify wireshark UEContextReleaseRequest    wireshark_dir=${resultDir}


verify wireshark initialContextSetup
    [Documentation]    [PRIVATE]    verify initialContextSetup in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_dir}=${resultDir}    ${IndexToRFSP}=none
    Log To Console    \nverify initialContextSetup
    setup tshark    eth1
    Log To Console    create xml file with filter "${filter_intialContextSetupRequest}"
    read_pcap_and_save_to_file
    ...   filename=${wireshark_dir}/NGAP_setup.xml
    ...   packet_filter=${filter_intialContextSetupRequest}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_dir}/wireshark.pcap
    teardown tshark
    ${pdml_xml}    parse xml    ${wireshark_dir}/NGAP_setup.xml
    Log To Console    verify that IndexToRFSP = ${IndexToRFSP}
    IF      '${IndexToRFSP}'=='none'    check 1 initialContextSetup no IndexToRFSP   ${pdml_xml}
    ...         ELSE    check 1 initialContextSetup with IndexToRFSP   ${pdml_xml}     ${IndexToRFSP}


check 1 initialContextSetup no IndexToRFSP
    [Documentation]    [PRIVATE]    verify initialContextSetup no parameter IndexToRFSP
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${pdml_xml}
    Run Keyword And Continue On Failure   Element Should Not Exist    ${pdml_xml}
    ...    xpath=${xpath_setup}
    ...    message=Error inital context setup request contains IndexToRFSP


check 1 initialContextSetup with IndexToRFSP
    [Documentation]    [PRIVATE]    verify initialContextSetup parameter IndexToRFSP
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${pdml_xml}     ${IndexToRFSP}
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    show
    ...    ${IndexToRFSP}
    ...    xpath=${xpath_setup}


verify wireshark UEContextReleaseRequest
    [Documentation]    [PRIVATE]    verify UEContextReleaseRequest with cause redirection in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_dir}=${resultDir}
    ${pdml_xml}    Filter UEContextReleaseRequest message     ${wireshark_dir}
    Log To Console    verify that cause redirection is contained
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    radioNetwork: redirection (41)
    ...    xpath=${xpath_radioNetwork}


verify wireshark no UEContextReleaseRequest
    [Documentation]    [PRIVATE]    verify no UEContextReleaseRequest in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_dir}=${resultDir}
    ${pdml_xml}    Filter UEContextReleaseRequest message     ${wireshark_dir}
    Log To Console    verify that no UEContextReleaseRequest message is contained
    Run Keyword And Continue On Failure   Element Should Not Exist    ${pdml_xml}
    ...    xpath=${xpath_UEContextReleaseRequest}
    ...    message=Error UEContextReleaseRequest present


Filter UEContextReleaseRequest message
    [Documentation]    [PRIVATE]    filter UEContextReleaseRequest
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_dir}
    Log To Console    \nverify UEContextReleaseRequest
    setup tshark    eth1
    Log To Console    create xml file with filter "${filter_UEContextReleaseRequest}"
    read_pcap_and_save_to_file
    ...   filename=${wireshark_dir}/NGAP_contextRel.xml
    ...   packet_filter=${filter_UEContextReleaseRequest}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_dir}/wireshark.pcap
    teardown tshark
    ${pdml_xml}    parse xml    ${wireshark_dir}/NGAP_contextRel.xml
    RETURN    ${pdml_xml}


verify wireshark registrationRequest
    [Documentation]    [PRIVATE]    verify registrationRequest contains sliceType and sliceDifferentiator
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_dir}     ${sliceType}    ${sliceDifferentiator}
    Log To Console    \nverify registrationRequest
    setup tshark    eth1
    Log To Console    create xml file with filter "${filter_registrationRequest}"
    read_pcap_and_save_to_file
    ...   filename=${wireshark_dir}/NGAP_registrationReq.xml
    ...   packet_filter=${filter_registrationRequest}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_dir}/wireshark.pcap
    teardown tshark
    ${pdml_xml}    parse xml    ${wireshark_dir}/NGAP_registrationReq.xml
    Log To Console    verify that sliceType is "${sliceType}"
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    show
    ...    ${sliceType}
    ...    xpath=${xpath_sliceType}
    Log To Console    verify that sliceDifferentiator is "${sliceDifferentiator}"
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    show
    ...    ${sliceDifferentiator}
    ...    xpath=${xpath_sliceDifferentiator}


verify handover
    [Documentation]    [PRIVATE]    verify handover messages contain indexToRatFrequencySelectionPriority
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_dir}
    Log To Console    \nverify verify handover messages
    FOR    ${loop}        ${filter_ips}    IN
    ...    1     (ip.src==${wts_GNB_XN_ADDR})&&(ip.dst==${wts_GNB3_XN_ADDR})
    ...    2     (ip.src==${wts_GNB3_XN_ADDR})&&(ip.dst==${wts_GNB_XN_ADDR})
    setup tshark    eth1
    Log To Console    create xml file with filter "${filter_handover}&&${filter_ips}"
    read_pcap_and_save_to_file
    ...   filename=${wireshark_dir}/handover${loop}.xml
    ...   packet_filter=${filter_handover}&&${filter_ips}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_dir}/wireshark.pcap
    teardown tshark
    ${pdml_xml}    parse xml    ${wireshark_dir}/handover${loop}.xml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *handover-desirable-for-radio-reasons*
    ...    xpath=${xpath_HO_cause}
    END


verify successful xn setup
    [Documentation]    [PRIVATE]    verify that xn setup is successful
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}
    setup tshark    eth1
    Log To Console    \ncheck that successful XNSetupResponse message present
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/XN_setup.xml
    ...   packet_filter=${xnap_version}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_store}
    teardown tshark
    ${pdml_xml}    parse xml    ${resultDir}/XN_setup.xml

    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="${xnap_version}.successfulOutcome_element"]
    Should Not Be Equal As Integers    ${successful_msg}    ${0}
    ...     NO successful XNSetupResponse message
