*** Settings ***
Force Tags        VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00


Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com


Variables    ta5g_global_var
Resource    resources/5G_SW_WRO_Keywords.robot
Resource    resources/Pdu_attach.robot
Library    resources/Python/tput_scen.py
Library    resources/Python/webem_alarms.py
Library    resources/Python/ue_state.py
Library    resources/Python/ue_rrc_resume_reestab.py
Library    resources/Python/ue_profiles_scen.py

#Resource    ../../../../Ulm/resources/Common/bip_trace.robot
#Resource    ../../../../Ulm/resources/Common/bip_trace_ap.robot
Resource    resources/Ue_reestab_resume.robot
#Resource    resources/configuration_id.robot
Resource    resources/Ue_profiles.robot

Suite Setup    Run Keywords    Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/TMO.cfg    mplane_cells=@{mplane_cells}

#Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#    ...        AND             Start BIP Traces
#    ...        AND             Start Airphone BIP Traces

#Test Teardown    Run Keywords    Stop BIP Traces
#    ...        AND             Stop Airphone BIP Traces
#    ...        AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Deregister 40 UEs
           ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2
@{mplane_cells}=    ${5}    ${6}    ${9}    ${12}
@{pdu_list_ue1}=    ${1}    ${2}
@{pdu_list_ue10}=   ${10}   ${11}
@{pdu_list_ue20}=   ${3}   ${4}
*** Test Cases ***
SkyWatch_Seq_SA_002_03_n41
    [Documentation]
    ...              SkyWatch Project
    ...              https://confluence.ext.net.nokia.com/display/SkywatchProject/SkyWatch_Seq_SA_002_03_n41
    ...              :copyright: Nokia
    ...              :authors: Mateusz Bilewicz
    ...              :contact: mateusz.bilewicz@nokia.com


    Find Scfc and Send Delta Commissioning    scfc_filename=UEInactiveState.json
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    Modify Rrc Setup Cause
    ...  ue_id=${1}
    ...  cause=mo-Signalling
    Attach Ue With Trf Type
    ...    ue=${1}
    ...    pdu_list=@{pdu_list_ue1}
    Execute Egate Command
    ...    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal default_qos_flow=2

    Verify Tcpdump Log  packet_filter=nr-rrc.rrcSetupRequest_element && nr-rrc.establishmentCause == 3  number_of_messages=1

    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ...    pass_regexp=Established PDU session
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    pass_regexp=Established PDU session

    FOR    ${run_id}    IN RANGE    100
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 trf_id=1 dir=dl bytes=2M Mbps=2
    ...    pass_regexp=UE1: Is INACTIVE
    ...    timeout=30
    Verify Ue State
    ...    ue_id=1
    ...    expected_state=ue_inactive
    Send RrcResume To Ue 1 With Cause mo_Data
    END

SkyWatch_Seq_SA_002_02_n25
    [Documentation]
    ...              SkyWatch Project
    ...              https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1900533442
    ...              :copyright: Nokia
    ...              :authors: Mateusz Bilewicz
    ...              :contact: mateusz.bilewicz@nokia.com

    Find Scfc and Send Delta Commissioning    scfc_filename=UEInactiveState.json
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    Modify Rrc Setup Cause
    ...    ue_id=${20}
    ...    cause=mo-Signalling
    Create Cqi Profile
    Activate Cqi Profile
    ...    ue_id=${20}
    ...    profile_id=${1}
    Create Bler Profile
    Activate Bler Profile
    ...    ue_id=${20}
    ...    profile_id=${1}
    Attach Ue With Trf Type
    ...    ue=${20}
    ...    pdu_list=@{pdu_list_ue20}
    Execute Egate Command
    ...    cmd=set_pdu_param ue=20 pdu=4 trf_type=internal default_qos_flow=2
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=3 ue=20 nwslice=1 gw=20
    ...    pass_regexp=Established PDU session
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=4 ue=20 nwslice=1 gw=21
    ...    pass_regexp=Established PDU session

    Verify Tcpdump Log  packet_filter=nr-rrc.rrcSetupRequest_element && nr-rrc.establishmentCause == 3  number_of_messages=1

    FOR    ${run_id}    IN RANGE    10
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=20 pdu=3 trf_id=1 dir=dl bytes=2M Mbps=2
    ...    pass_regexp=UE20: Is INACTIVE
    ...    timeout=30

    Verify Ue State
    ...    ue_id=20
    ...    expected_state=ue_inactive
    Send RrcResume To Ue 20 With Cause mo_Data
    END

SkyWatch_Seq_SA_002_01_n71
    [Documentation]
    ...              SkyWatch Project
    ...              https://confluence.ext.net.nokia.com/display/SkywatchProject/SkyWatch_Seq_SA_002_01_n71
    ...              :copyright: Nokia
    ...              :authors: Mateusz Bilewicz
    ...              :contact: mateusz.bilewicz@nokia.com

    Find Scfc and Send Delta Commissioning    scfc_filename=UEInactiveState.json
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    Modify Rrc Setup Cause
    ...    ue_id=${10}
    ...    cause=mo-Signalling
    Create Cqi Profile
    Activate Cqi Profile
    ...    ue_id=${10}
    ...    profile_id=${1}
    Create Bler Profile
    Activate Bler Profile
    ...    ue_id=${10}
    ...    profile_id=${1}
    Attach Ue With Trf Type
    ...    ue=${10}
    ...    pdu_list=@{pdu_list_ue10}
    Execute Egate Command
    ...    cmd=set_pdu_param ue=10 pdu=10 trf_type=internal default_qos_flow=2
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=10 ue=10 nwslice=1 gw=10
    ...    pass_regexp=Established PDU session
    Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=11 ue=10 nwslice=1 gw=11
    ...    pass_regexp=Established PDU session

    Verify Tcpdump Log  packet_filter=nr-rrc.rrcSetupRequest_element && nr-rrc.establishmentCause == 3  number_of_messages=1

    FOR    ${run_id}    IN RANGE    10
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=10 pdu=10 trf_id=1 dir=dl bytes=2M Mbps=2
    ...    pass_regexp=UE10: Is INACTIVE
    ...    timeout=30

    Verify Ue State
    ...    ue_id=10
    ...    expected_state=ue_inactive
    Send RrcResume To Ue 10 With Cause mo_Data
    END

*** Keywords ***
Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    [Arguments]   ${amf_id}=1   ${plmn_id}=311:489   ${tac_id}=200
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=${amf_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=1 ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=${plmn_id} tac_id=${tac_id}
    Execute Egate Command   cmd=${command}
