*** Settings ***
Documentation
...    copyright: Nokia

*** Variables ***

${RRC_UE_ASSISTANCE_MAX_CC_0}=    SEPARATOR=
...    ((nr-rrc.ueAssistanceInformation_element) && (nr-rrc.overheatingAssistance_element)
...    && (nr-rrc.reducedCCsDL_r16 == 0) && (!f1ap.UEContextModificationRequest_element))

${RRC_UE_ASSISTANCE_MAX_CC_0_VRAN}=    SEPARATOR=
...    ((nr-rrc.ueAssistanceInformation_element) && (nr-rrc.overheatingAssistance_element)
...    && (nr-rrc.reducedCCsDL_r16 == 0))

${RRC_UE_ASSISTANCE_MAX_CC_2}=    SEPARATOR=
...    (((nr-rrc.ueAssistanceInformation_element) && (nr-rrc.overheatingAssistance_element))
...    && (nr-rrc.reducedCCsDL_r16 == 2) && (!f1ap.UEContextModificationRequest_element))

${RRC_UE_ASSISTANCE_MAX_CC_1}=    SEPARATOR=
...    (((nr-rrc.ueAssistanceInformation_element) && (nr-rrc.overheatingAssistance_element))
...    && (nr-rrc.reducedCCsDL_r16 == 1) && (!f1ap.UEContextModificationRequest_element))

${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE}=    SEPARATOR=
...    (f1ap.UEContextModificationRequest_element && nr-rrc.overheatingAssistance_element)

${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_0}=    SEPARATOR=
...    (f1ap.UEContextModificationRequest_element && nr-rrc.overheatingAssistance_element
...    && nr-rrc.reducedCCsDL_r16 == 0)

${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_1}=    SEPARATOR=
...    (f1ap.UEContextModificationRequest_element && nr-rrc.overheatingAssistance_element
...    && nr-rrc.reducedCCsDL_r16 == 1)

${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_2}=    SEPARATOR=
...    (f1ap.UEContextModificationRequest_element && nr-rrc.overheatingAssistance_element
...    && nr-rrc.reducedCCsDL_r16 == 2)

${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_END_OH}=    SEPARATOR=
...    (f1ap.UEContextModificationRequest_element && nr-rrc.overheatingAssistance_element && !nr-rrc.reducedCCsDL_r16)

${RRC_UE_ASSISTANCE_END_OH}=    SEPARATOR=
...    (((nr-rrc.ueAssistanceInformation_element) && (nr-rrc.overheatingAssistance_element))
...    && (!nr-rrc.reducedCCsDL_r16) && (!f1ap.UEContextModificationRequest_element))
