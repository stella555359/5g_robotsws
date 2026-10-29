*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED  CRT
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1    PY36
...           NoResUsage


Documentation    :copyright: Nokia
...              :author: Pawel Gniewek
...              :contact: pawel.gniewek@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_tshark
Library      ta5g_egate
Variables    ta5g_global_var

Suite Setup      Start Default Logging And Reach Onair
    ...              lua_cfg_filepath=${CURDIR}/config/egate.lua
    ...              output_dirpath=${OUTPUT_DIR}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000723_D_5_Check_RRC_Guard_Timer_Expiration
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=1 if_contains=any action=drop
    Execute Egate Command    cmd=ue_register id=1 profile=1
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    relation_symbol= >=
