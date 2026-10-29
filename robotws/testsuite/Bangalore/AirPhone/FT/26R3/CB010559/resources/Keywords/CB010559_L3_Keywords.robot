*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource       ../../../../resources/Keywords/general_common_keywords.robot

*** Keywords ***
L3 Suite Setup
     Log to console      "suite setup"

L3 Suite Teardown
     Log to console      "suite teardown"


CB010559 Suite Setup
     Log to console      "suite setup"

CB010559 Suite Teardown
     Log to console      "suite teardown"


X2 Link
     Exe egate cmd      cmd=${X2_Link}       return_output=False
     Sleep      1

Xn on Link
     Exe egate cmd      cmd=${Xn_on_check}       return_output=False
     Sleep       10

X2 Link StoR
     Exe egate cmd      cmd=${X2_Link_StoR}       return_output=False
     Sleep      1

Xn Link-gNB3
     Exe egate cmd      cmd=${Xn_Link1}       return_output=False
     Sleep      1

Xn Link-gNB4
     Exe egate cmd      cmd=${Xn_Link2}       return_output=False
     Sleep      1

Retrieve UE1-UE5 Context Req
     Exe egate cmd      cmd=${Retrieve_UE1-5_Context_Req}       return_output=False
     Sleep      1

Retreive UE1-UE5 context Req Param
    Exe egate cmd      cmd=${Retreive_UE1-5_Context_Req_Param}       return_output=False
    Sleep        30

UE1-UE5 RRC Restablish with Ransim
    Exe egate cmd      cmd=${UE1-5_RRC_Restablish_with_Ransim}       return_output=False
    Sleep      50

UE1-UE5 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE1-5_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_1-5_REGISTER}
     Sleep      50
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1-5_PDU_SESSION}
     Sleep      50
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE1-UE5 UL Data
     Exe egate cmd      cmd=${CM_UE_1-5_UL_DATA}
     Sleep      10

UE1-UE5 DL Data
    Exe egate cmd      cmd=${CM_UE_1-5_UL_DATA}
     Sleep      10

Retrieve UE6-UE10 Context Req
     Exe egate cmd      cmd=${Retrieve_UE6-10_Context_Req}       return_output=False
     Sleep      1

Retreive UE6-UE10 context Req Param
    Exe egate cmd      cmd=${Retreive_UE6-10_Context_Req_Param}       return_output=False
    Sleep      1

UE6-UE10 RRC Restablish with Ransim
    Exe egate cmd      cmd=${UE6-10_RRC_Restablish_with_Ransim}       return_output=False
    Sleep      1

UE6-UE10 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE6-10_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_6-10_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_6-10_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE6-UE10 UL Data
     Exe egate cmd      cmd=${CM_UE_6-10_UL_DATA}
     Sleep      1

UE6-UE10 DL Data
    Exe egate cmd      cmd=${CM_UE_6-10_UL_DATA}
    Sleep      1

UE Retrieve
    Exe egate cmd      cmd=${UE_Retrieve}
    Sleep      1

RRC Reestablish
    Exe egate cmd      cmd=${RRC_Reestablish}
    Sleep      1

RRC Reestablish gnb3
    Exe egate cmd      cmd=${RRC_Reestablish_gnb3}
    Sleep      1

UE Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}


CB010559 TC02 TESTCASE
     Exe egate cmd      cmd=${CB010559_Trace_xn_check}       return_output=False
     Exe egate cmd      cmd=${CB010559_gNB_Param_check}
     Exe egate cmd      cmd=${CB010559_SET_PDU_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CB010559_UE_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CB010559_UE_PDU_SESSION}
     Exe egate cmd      cmd=${CB010559_TC02_TRF_DL}          return_output=False
     Exe egate cmd      cmd=${CB010559_TC02_TRF_UL}          return_output=False
     Exe egate cmd      cmd=${CB010559_barrer_dl}            return_output=False
     Exe egate cmd      cmd=${CB010559_barrer_ul}            return_output=False
     Exe egate cmd      cmd=${CB010559_UE_SUMMARY}           return_output=False
     Exe egate cmd      cmd=${CB010559_UE_RETRIEVE_UE}         return_output=False
     Exe egate cmd      cmd=${CB010559_RRC_REESTABLISH}        return_output=False
     Exe egate cmd      cmd=${CB010559_UE_SUMMARY}       return_output=False
     Exe egate cmd      cmd=${CB010559_TC02_TRF_UL}      return_output=False
     Exe egate cmd      cmd=${CB010559_barrer_dl}       return_output=False
     Exe egate cmd      cmd=${CB010559_TC02_TRF_UL}     return_output=False
     Exe egate cmd      cmd=${CB010559_barrer_dl}       return_output=False
     Sleep       10
