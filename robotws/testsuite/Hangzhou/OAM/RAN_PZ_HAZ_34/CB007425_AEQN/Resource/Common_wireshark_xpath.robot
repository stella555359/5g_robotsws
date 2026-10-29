*** Settings ***
Documentation
...  author: Chen Liang 6
...  contact: liang.6.chen@nokia-sbell.com

Library     taf.analyzer.pcap   WITH NAME   wireshark

*** Variables ***
${crnti}   crnti
${classifier_element}   classifier_element
${data_r1_element}   data_r1_element
${data_element}   data_element
${enb_Id}   enb_Id
${enb_Id_element}   enb_Id_element
${f1ap}   f1ap
${finalClass}   finalClass
${GNB_CU_UE_F1AP_ID}   GNB_CU_UE_F1AP_ID
${gnb_cu_ue_f1ap_Id_lower}   gnb_cu_ue_f1ap_Id
${GNB_DU_UE_F1AP_ID}   GNB_DU_UE_F1AP_ID
${gnb_du_ue_f1ap_Id_lower}   gnb_du_ue_f1ap_Id
${macro_eNB_Id}   macro_eNB_Id
${menb_ue_x2ap_Id}   menb_ue_x2ap_Id
${nsetapx}   nsetapx
${plmn_Identity_new}   plmn_Identity
${primaryQualifier}   primaryQualifier
${result}   result
${seconds}   seconds
${secondaryQualifier}   secondaryQualifier
${showname}   showname
${sgnbAdditionRecord}   sgnbAdditionRecord
${sgnb_ue_x2ap_Id_lower}   sgnb_ue_x2ap_Id
${sgnbReleaseReason}   sgnbReleaseReason
${sgnbReleaseRecord}   sgnbReleaseRecord
${sgnbAdditionReqRcvTime_element}   sgnbAdditionReqRcvTime_element
${sgnbAdditionReqRejectSndTime_element}   sgnbAdditionReqRejectSndTime_element
${sgnbReconfCmplRcvTime_element}   sgnbReconfCmplRcvTime_element
${sgnbReleaseReqTime_element}   sgnbReleaseReqTime_element
${sgnbReleaseRespTime_element}   sgnbReleaseRespTime_element
${sgnbAdditionReqAckSndTime_element}   sgnbAdditionReqAckSndTime_element
${snStatusTransferRcvTime_element}   snStatusTransferRcvTime_element
${snStatusTransferSndTime_element}   snStatusTransferSndTime_element
${SgNB_UE_X2AP_ID}   SgNB_UE_X2AP_ID
${triggerReason}   triggerReason
${useconds}   useconds
${UE_X2AP_ID}   UE_X2AP_ID
${ueCtxReleaseCmdRcvTime_element}   ueCtxReleaseCmdRcvTime_element
${ueCtxReleaseCmplSndTime_element}   ueCtxReleaseCmplSndTime_element
${ueCtxReleaseReason}   ueCtxReleaseReason
${ueCtxSetupReqRcvTime_element}   ueCtxSetupReqRcvTime_element
${ueCtxSetupCmplSndTime_element}   ueCtxSetupCmplSndTime_element
${ueReleaseRecord}   ueReleaseRecord
${x2ap}   x2ap

*** Keyword ***
Get Nsetapx Trigger
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${triggerReason}
    ...   attribute_name=${showname}
    [Return]   ${field_value}
    
Get Nsetapx Result
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${data_r1_element}/${nsetapx}.${result}
    ...   attribute_name=${showname}
    [Return]   ${field_value}
    
Get Nsetapx CU Result
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbAdditionRecord}/${nsetapx}.${data_r1_element}/${nsetapx}.${result}
    ...   attribute_name=${showname}
    [Return]   ${field_value}
    
Get Nsetapx SgnbReleaseReason
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbReleaseRecord}/${nsetapx}.${data_r1_element}/${nsetapx}.${sgnbReleaseReason}
    ...   attribute_name=${showname}
    [Return]   ${field_value}    
    
Get Nsetapx Enbid Element
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${enb_Id_element}
    ...   attribute_name=${showname}
    [Return]   ${field_value}
    
Get Nsetapx Enb Plmn
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${enb_Id_element}/${nsetapx}.${plmn_Identity_new}
    [Return]   ${field_value}

Get Nsetapx Enbid
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${enb_Id_element}
    ...   attribute_name=${showname}
    [Return]   ${field_value}
    
Get Nsetapx Macro Enbid
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${macro_eNB_Id}
    ...   attribute_name=${showname}
    [Return]   ${field_value}
    
Get Nsetapx MenbUeX2APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${menb_ue_x2ap_Id}
    [Return]   ${field_value}

Get Nsetapx SgnbUeX2APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnb_ue_x2ap_Id_lower}
    [Return]   ${field_value}

Get Nsetapx CuReqRcvTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbAdditionReqRcvTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx CuReqRcvTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbAdditionReqRcvTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}
    
Get Nsetapx sgnbAdditionReqRejectSndTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbAdditionReqRejectSndTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx sgnbAdditionReqRejectSndTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbAdditionReqRejectSndTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}
    
Get Nsetapx sgnbReleaseReqTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbReleaseReqTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx sgnbReleaseReqTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbReleaseReqTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}
    
Get Nsetapx sgnbReleaseRespTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbReleaseRespTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx sgnbReleaseRespTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbReleaseRespTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}
    
Get Nsetapx CuReqAckSndTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbAdditionReqAckSndTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx CuReqAckSndTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbAdditionReqAckSndTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}
    
Get Nsetapx UeCtxSetupReqRcvTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxSetupReqRcvTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}
    
Get Nsetapx UeCtxSetupReqRcvTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxSetupReqRcvTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}

Get Nsetapx UeCtxReleaseCmdRcvTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxReleaseCmdRcvTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}
    
Get Nsetapx UeCtxReleaseCmdRcvTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxReleaseCmdRcvTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}

Get Nsetapx UeCtxReleaseCmplSndTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxReleaseCmplSndTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}
    
Get Nsetapx UeCtxReleaseCmplSndTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxReleaseCmplSndTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}

Get Nsetapx ReconfCmplRcvS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbReconfCmplRcvTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx ReconfCmplRcvUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${sgnbReconfCmplRcvTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}

Get Nsetapx ueCtxSetupCmplSndTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxSetupCmplSndTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx ueCtxSetupCmplSndTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxSetupCmplSndTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx snStatusTransferRcvS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${snStatusTransferRcvTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx snStatusTransferRcvUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${snStatusTransferRcvTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}
    
Get Nsetapx snStatusTransferSndTimeS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${snStatusTransferSndTime_element}/${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx snStatusTransferSndTimeUS
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${snStatusTransferSndTime_element}/${nsetapx}.${useconds}
    [Return]   ${field_value}

Get Nsetapx CFC
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${finalClass}
    ...   attribute_name=${showname}
    [Return]   ${field_value}

Get Nsetapx CFCQ
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${primaryQualifier}
    ...   attribute_name=${showname}
    [Return]   ${field_value}

Get Nsetapx SCFCQ
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${secondaryQualifier}
    ...   attribute_name=${showname}
    [Return]   ${field_value}

Get Nsetapx Crnti
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${Crnti}
    [Return]   ${field_value}
    
Get Nsetapx Seconds
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${seconds}
    [Return]   ${field_value}

Get Nsetapx Useconds
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${useconds}
    [Return]   ${field_value}

Get Nsetapx ueReleaseRecord
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueReleaseRecord}
    [Return]   ${field_value}

Get Nsetapx ueCtxReleaseReason
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${ueCtxReleaseReason}
    ...   attribute_name=${showname}
    [Return]   ${field_value}

Get Nsetapx GnbCuUeF1APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${gnb_cu_ue_f1ap_Id_lower}
    [Return]   ${field_value}

Get Nsetapx GnbDuUeF1APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${nsetapx}.${gnb_du_ue_f1ap_Id_lower}
    [Return]   ${field_value}

Get X2AP MenbUeX2APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${x2ap}.${UE_X2AP_ID}
    [Return]   ${field_value}
    
Get X2AP SgnbUeX2APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${x2ap}.${SgNB_UE_X2AP_ID}
    [Return]   ${field_value}

Get F1AP GnbCuUeF1APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${f1ap}.${GNB_CU_UE_F1AP_ID}
    [Return]   ${field_value}

Get F1AP GnbDuUeF1APId
    ${field_value}=   wireshark.get_field_value_by_xpath
    ...   xpath=.//${f1ap}.${GNB_DU_UE_F1AP_ID}
    [Return]   ${field_value}