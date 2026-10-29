*** Settings ***
Library     pdml_verification.py

*** Keywords ***

Verify attach procedure from packet trace on X2 link
    ${field_names}    Create list  SgNBAdditionRequest  SgNBAdditionRequestAcknowledge
    ...                            SgNBReconfigurationComplete  SNStatusTransfer
    Verify messages in pdml file  ${field_names}

Verify CPUE receives SrbUser BearerSetupResp
    ${field_names}    Create list  SrbUserBearerSetupResp
    verify_messages_in_pdml_file  ${field_names}

Verify CPRT receives F1AP message Ue context Setup Req
    ${field_names}    Create list  UeContextSetupReq
    verify_messages_in_pdml_file  ${field_names}

Verify CPUE sets message SrbUser BearerSetupReq after SgnB Addition Req
    ${field_names}    Create list  SgNBAdditionRequest  SrbUserBearerSetupReq
    verify_messages_in_pdml_file  ${field_names}

Verify if SgNB Addition Req Ack is sent
    ${field_name}    Create list  SgNBAdditionRequest
    verify_messages_in_pdml_file  ${field_name}

Verify if Measurement Report reception via NR SRB3 trigger PSCell Change
    ${field_names}  Create list  RRCReconfiguration  RRCConnectionReconfiguration  RRCConnectionReconfigurationComplete
    verify_messages_in_pdml_file  ${field_names}

Verify S-gNB-CU sends SrbUser BearerSetupReq
    ${field_name}    Create list  SrbUser_BearerSetupReq
    verify_messages_in_pdml_file  ${field_name}

Verify setup of user with SRB3 on 5GL2LO
    ${field_name}   Create list  LoUser_UserSetupReq
    verify_messages_in_pdml_file  ${field_name}

Verify setup of user with SRB3 on 5GL2PS
    ${field_name}   Create list  PsUser_UserSetupReq
    verify_messages_in_pdml_file  ${field_name}

Verify T-gNB-DU sets SrbUser BearerSetupResp after getting SrbUser BearerSetupReq
    ${field_names}    Create list  SrbUser_BearerSetupReq  SrbUser_BearerSetupResp
    verify_messages_in_pdml_file  ${field_names}

Verify gNB-CU-CP releases the UE resource on the source SgNB
    ${field_names}    Create list  F1AP: UE Context Release Command  F1AP: UE Context Release Complete
    verify_messages_in_pdml_file  ${field_names}

Verify if Source UE sends the RRC Reconfiguration Complete on the target gNB-DU
    ${field_name}  Create list  RRCReconfigurationComplete
    verify_messages_in_pdml_file  ${field_name}

Verify gNB-CU-CP suspends data transmisson
    ${field_names}    Create list  F1AP: UE Context Modification Request  PsUser_UserSuspendSchedulingReq
    ...                            PsUser_UserSuspendSchedulingResp  F1AP: UE Context Modification Response
    verify_messages_in_pdml_file  ${field_names}

Verify setup of user with SRB3 on 5GL2HI
    ${field_name}   Create list  HiUserDu_BearerSetupReq
    verify_messages_in_pdml_file  ${field_name}

Verify if Source gNB-DU sends the RRC Reconfiguration messg to the UE via SRB3
    ${field_name}  Create list  RRCReconfiguration
    verify_messages_in_pdml_file  ${field_name}

Verify if srb3 is supported
    ${dict1}  Create Dictionary  field_name=per.optional_field_bit
    ...                          name=showname
    ...                          value=.... .1.. Optional Field Bit: True (srb3 is present)
    ${dict2}  Create Dictionary  field_name=nr-rrc.srb3
    ...                          name=showname
    ...                          value=srb3: supported (0)

    ${message_mapping}  Create List  ${dict1}  ${dict2}
    Verify pdml attribute value exists  ${message_mapping}  mode=all

Verify if splitDRB is supported
    ${dict1}  Create Dictionary  field_name=nr-rrc.splitDRB_withUL_Both_MCG_SCG
    ...                          name=showname
    ...                          value=splitDRB-withUL-Both-MCG-SCG: supported (0)
    ${message_mapping}  Create List  ${dict1}
    Verify pdml attribute value exists  ${message_mapping}
