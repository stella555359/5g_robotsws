*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
007_PCMD_Record_DU_UE_Context_Setup
    log to console   check NSA_Record_DU_UE_Context_Setup_scenario
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}
    ...   any_expression=f1ap.procedureCode == 5&&f1ap.F1AP_PDU == 1
    ...   filter=sctp.dstport==36422
    ${F1AP_GnbCuUeF1APId}   Get F1AP GnbCuUeF1APId
    ${F1AP_GnbDuUeF1APId}   Get F1AP GnbDuUeF1APId
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}
    ...   any_expression=nsetapx.DuVendorExtensionRecordDataType == 1
    ...   filter=sctp.dstport==${dcap_server_port}
    ${result_list}    Get Nsetapx Result
    ${GnbCuUeF1APId}   Get Nsetapx GnbCuUeF1APId
    ${GnbDuUeF1APId}   Get Nsetapx GnbDuUeF1APId
    ${UeCtxSetupReqRcvTimeS}    Get Nsetapx UeCtxSetupReqRcvTimeS
    ${UeCtxSetupReqRcvTimeUS}   Get Nsetapx UeCtxSetupReqRcvTimeUS
    ${ueCtxSetupCmplSndTimeS}    Get Nsetapx ueCtxSetupCmplSndTimeS
    ${ueCtxSetupCmplSndTimeUS}   Get Nsetapx ueCtxSetupCmplSndTimeUS
    ${crnti_list}   Get Nsetapx Crnti
    ${crnti_list}   Remove Duplicates   ${crnti_list}
    ${crnti_length}    Get Length   ${crnti_list}
    ${seconds_list}    Get Nsetapx Seconds
    ${useconds_list}   Get Nsetapx Useconds    
    Check Seconds    ${seconds_list}
    Check Useconds   ${useconds_list}
    Should Be True   ${GnbCuUeF1APId} == ${F1AP_GnbCuUeF1APId}
    Should Be True   ${GnbDuUeF1APId} == ${F1AP_GnbDuUeF1APId}
    Should Be True   ${crnti_length}>0    
    FOR   ${idx}    IN RANGE    0   ${crnti_length}
        Should Match Regexp   ${result_list[${idx}]}   .*success.*
        should not be empty   ${UeCtxSetupReqRcvTimeS[${idx}]}
        should not be empty   ${UeCtxSetupReqRcvTimeUS[${idx}]}
        should not be empty   ${ueCtxSetupCmplSndTimeS[${idx}]}
        should not be empty   ${ueCtxSetupCmplSndTimeUS[${idx}]}
    END
Case Setup: B_007
    Common Setup 1756
    Remove And Add PCMD Object

Case Teardown: B_007
    Common Teardown 1756