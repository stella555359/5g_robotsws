*** Settings ***
Documentation
...   maintainer: Filip Jozefczak
...   contact: filip.jozefczak@nokia.com
...   TOL voice tests


Resource         ./resources/tol_keywords.robot

*** Keywords ***
Emergency_Call
    [Arguments]    ${ru_attenuator_ports}    ${ue_capabilities}
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_capabilities}
    Attach UE     UE_1   capabilities=${ue_capabilities}
    Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=911
    Sleep  5
    Stop Voice Call  vc_alias=VC_1
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports

VoLTE_Call
	[Arguments]    ${ru_attenuator_ports}    ${ue_nsa_capabilities}  ${ue_sa_capabilities}
    ${emergency_number}=  Set variable  911
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_nsa_capabilities}
    Require UE    UE_2   capabilities=${ue_sa_capabilities}
    Attach UE     UE_1
    Attach UE     UE_2
    Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    Await Incoming Voice Call    vc_alias=VC_1    ue_alias=UE_2     action=answer   timeout=20s
    Sleep   5
    Stop Voice Call     vc_alias=VC_1
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports
