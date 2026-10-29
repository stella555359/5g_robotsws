*** Settings ***

Documentation    :copyright: Nokia
...              :authors: Kamil Wos, Julia Szymczak
...              :contact: kamil.wos@nokia.com, julia.szymczak@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000752_D_Variables.robot

Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb


*** Keywords ***
Change SMF Security Indication
    Execute Egate Command    cmd=smf_param id=1 security_indication=pdu_session_setup:required:required max_data_rate=5mbps

Set Ue NR RRC Reconf Param
    [Arguments]    ${ue_id}    ${value}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${value}

Reset SMF Security Indication
    Execute Egate Command    cmd=smf_param reset

Reset UE NR RRC Reconf Param
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param reset

Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation
    @{id}=    Get AMF And Ran Id    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    output_filepath=${OUTPUT_DIR}/${TEST_NAME}/id.pdml
    Verify Tshark For Ngap Ue Context Release    ran_id=@{id}[1]    amf_id=@{id}[0]    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
