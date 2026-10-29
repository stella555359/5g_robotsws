*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***
&{ueDuConnectivityRecord_attach}
...    record_name=ueDuConnectivityRecord
...    DuUeCtxSetupData.*result=0
...    DuUeCtxSetupData.*gnb_du_Id=0
...    DuUeCtxSetupData.*gnb_Id_tree.*gnb_id=00:00:04
...    DuUeCtxSetupData.*plmn_Identity=13:41:98
...    DuUeCtxSetupData.*gnb_cu_ue_f1ap_Id=\\d+
...    DuUeCtxSetupData.*gnb_du_ue_f1ap_Id=\\d+
...    DuUeCtxSetupData.*initialUeRrcMessageTransferRcvTime.*seconds=\\d{2,}
...    DuUeCtxSetupData.*initialUeRrcMessageTransferRcvTime.*useconds=\\d{2,}

&{ueDuConnectivityRecord_pdu}
...    record_name=ueDuConnectivityRecord
...    DuUeCtxSetupData.*result=0
...    DuUeCtxSetupData.*gnb_du_Id=0
...    DuUeCtxSetupData.*gnb_id=00:00:04
...    DuUeCtxSetupData.*plmn_Identity=13:41:98
...    DuUeCtxSetupData.*gnb_cu_ue_f1ap_Id=\\d+
...    DuUeCtxSetupData.*gnb_du_ue_f1ap_Id=\\d+
...    DuUeCtxSetupData.*ueCtxSetupReqSndTime.*seconds=\\d{2,}
...    DuUeCtxSetupData.*ueCtxSetupReqSndTime.*useconds=\\d{2,}
...    DuUeCtxSetupData.*ueCtxSetupCmplRcvTime.*seconds=\\d{2,}
...    DuUeCtxSetupData.*ueCtxSetupCmplRcvTime.*useconds=\\d{2,}

&{ueCuUpConnectivityRecord}
...      record_name=ueCuUpConnectivityRecord
...      gnb_cu_up_Ids.*gnb_cu_up_Id=0      gnb_cu_up_Ids.*gnb_Id.*plmn_Identity=13:41:98
...      gnb_cu_up_Ids.*gnb_Id.*gnb_Id=0    gnb_cu_up_Ids.*gnb_Id.*gnb_id=00:00:04
...      CuUpBearerCtxSetupData.*gnb_cu_cp_ue_e1ap_Id=\\d+
...      CuUpBearerCtxSetupData.*gnb_cu_up_ue_e1ap_Id=\\d+
...      CuUpBearerCtxSetupData.*cuUpBearerCtxSetupResult=0
...      cuUpBearerCtxSetupReqSndTime.*seconds=\\d{2,}      cuUpBearerCtxSetupReqSndTime.*useconds=\\d{2,}
...      cuUpBearerCtxSetupCmplRcvTime.*seconds=\\d{2,}   cuUpBearerCtxSetupCmplRcvTime.*useconds=\\d{2,}

&{rrcSetupRecord}
...    record_name=rrcSetupRecord
...    rrcSetupRecord.*rrcConnReqTriggerRcvTime_element.*seconds=\\d{2,}
...    rrcSetupRecord.*rrcConnReqTriggerRcvTime_element.*useconds=\\d{2,}
...    rrcSetupRecord.*result=0
...    rrcSetupRecord.*establishmentCauseType=0
...    rrcSetupRecord.*establishmentCause=4

&{ueInfoRecord}
...    record_name=ueInfoRecord
...    ueInfoRecord.*ueAsRelease=0
...    ueInfoRecord.*drxConfiguration=0
...    ueInfoRecord.*xddCapability=1
...    ueInfoRecord.*selectedBandCombinationSn_element.*bandCombinationIndex=1
...    ueInfoRecord.*selectedBandCombinationSn_element.*featureSetEntryIndex=1

&{ueSetupRecord}
...    record_name=ueSetupRecord
...    ueSetupRecord.*result=0
...    ueSetupRecord.*ran_ue_ngap_Id=\\d+
...    ueSetupRecord.*trigger=0
...    ueSetupRecord.*amf_ue_ngap_Id=\\d+

&{ueSetupRecord_reestablishment}
...    record_name=ueSetupRecord
...    ueSetupRecord.*result=0
...    ueSetupRecord.*ran_ue_ngap_Id=\\d+
...    ueSetupRecord.*trigger=2
...    ueSetupRecord.*amf_ue_ngap_Id=\\d+

&{pduSessionResourceInfoRecord}
...    record_name=pduSessionResourceInfoRecord
...    pduSessionResourceInfoRecord.*trigger=1
...    pduSessionResourceInfoRecord.*result=0
...    pduSessionResourceInfoRecord.*setupPduSessionResources=1
...    pduSessionResourceInfoRecord.*sst=01
...    pduSessionResourceInfoRecord.*pduSessionId=\\d{2,}
...    pduSessionResourceInfoRecord.*qfi=1
...    pduSessionResourceInfoRecord.*fiveQi=6
...    pduSessionResourceInfoRecord.*priorityLevel=15
...    pduSessionResourceInfoRecord.*preemptionCapability=0
...    pduSessionResourceInfoRecord.*preemptionVulnerability=1

&{bearerRecord}
...      record_name=bearerRecord
...      bearerRecord.*trigger=0
...      bearerRecord.*drb_Id=4
...      bearerRecord.*pduSessionId=\\d{2,}
...      bearerRecord.*fiveQi=6
...      bearerRecord.*priorityLevel=15
...      bearerRecord.*preemptionCapability=0
...      bearerRecord.*preemptionVulnerability=1
...      bearerRecord.*qfi=1
