*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
008_PCMD_Record_DU_UE_Context_Release
    log to console   check NSA_Record_DU_UE_Context_Release_scenario
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}
    ...   any_expression=nsetapx.DuVendorExtensionRecordDataType == 2
    ...   filter=sctp.dstport==${dcap_server_port}
    ${ueCtxReleaseReason}    Get Nsetapx ueCtxReleaseReason
    ${UeCtxReleaseCmdRcvTimeS}    Get Nsetapx UeCtxReleaseCmdRcvTimeS
    ${UeCtxReleaseCmdRcvTimeUS}   Get Nsetapx UeCtxReleaseCmdRcvTimeUS
    ${UeCtxReleaseCmplSndTimeS}    Get Nsetapx UeCtxReleaseCmplSndTimeS
    ${UeCtxReleaseCmplSndTimeUS}   Get Nsetapx UeCtxReleaseCmplSndTimeUS
    ${crnti_list}   Get Nsetapx Crnti
    ${crnti_list}   Remove Duplicates   ${crnti_list}
    ${crnti_length}    Get Length   ${crnti_list}
    ${seconds_list}    Get Nsetapx Seconds
    ${useconds_list}   Get Nsetapx Useconds    
    Check Seconds    ${seconds_list}
    Check Useconds   ${useconds_list}
    Should Be True   ${crnti_length}>0    
    FOR   ${idx}    IN RANGE    0   ${crnti_length}
        Should Match Regexp   ${ueCtxReleaseReason[${idx}]}   .*normal.*
        should not be empty   ${UeCtxReleaseCmdRcvTimeS[${idx}]}
        should not be empty   ${UeCtxReleaseCmdRcvTimeUS[${idx}]}
        should not be empty   ${UeCtxReleaseCmplSndTimeS[${idx}]}
        should not be empty   ${UeCtxReleaseCmplSndTimeUS[${idx}]}
    END
Case Setup: B_008
    Common Setup 1756
    Remove And Add PCMD Object

Case Teardown: B_008
    Common Teardown 1756