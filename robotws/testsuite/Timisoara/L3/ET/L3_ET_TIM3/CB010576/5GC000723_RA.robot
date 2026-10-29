*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO    VARIANT_SA_FS_ECPRI_MMWV_TDD    SBTS00    SBTS23R3    CONFIG
...           CRT    PY36    RAN_5G_TDD    RAN_5G
...           NoResUsage


Documentation      :author: Ilona Kondel
...                :email: ilona.kondel@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_ue_mobility
Library      ta5g_egate
Library      ta5g_setups_and_teardowns
Library      ta5g_tshark

Suite Setup       Start Default Logging And Reach Onair
                  ...    lua_cfg_filepath=${CURDIR}/../resources/egate_2c_tdd_sansa_FR2_n257.lua
                  ...    output_dirpath=${OUTPUT_DIR}
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${ERROR_INDICATION_NOT_INCLUDED_ID}=
...    ngap.ErrorIndication_element and ngap.procedureCode == 9 and ngap.protocol == 0 and ngap.id == 10 and not ngap.id == 85
${NGAP_UE_RELEASE}=    nr-rrc && f1ap.procedureCode == 6

*** Test Cases ***
5GC000723_RA_Ngap_Error_Indication_Received_Not_Included_Ran_Ue_Ngap_Id
    Trigger Error Indication Without RAN UE NGAP ID
    Attach Ue Without Confirmation    ue_id=1
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    packet_filter=${NGAP_UE_RELEASE}
    Verify Ngap Messages    packet_filter=${ERROR_INDICATION__NOT_INCLUDED_ID}

*** Keywords ***
Trigger Error Indication Without RAN UE NGAP ID
    Execute Egate Command    cmd=amf_init_ue_msg_param id=1 action=error_indication_without_ran_ueid cause=PROTOCOL_transfer_syntax_error

