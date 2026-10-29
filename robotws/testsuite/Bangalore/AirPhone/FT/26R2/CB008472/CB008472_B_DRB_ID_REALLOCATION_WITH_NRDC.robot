** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72_MMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This script is to validate CB008472
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,23.12.2025,keerthi.chittoor@nokia.com

Resource          resources/Keywords/CB008472_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          resources/Variables/CB008472_variables.robot

Suite Setup       CB008472_B Suite Setup            ${TC_DIR_CB008472_B}
Suite Teardown    CB008472_B Suite Teardown         ${TC_DIR_CB008472_B}

*** Test Cases ***
CB008472_B_Verify DRB ID reallocation for the UE with established NR-DC
         [Documentation]
         ...    author: keerthi.chittoo@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,23.12.2025,keerthi.chittoor@nokia.com
         ...    To verify UE has established NR-DC, before triggering intra-cell handover NR-DC is released
    Get cell On Air     iphy=${CB008472_B_AP_IPHY}     scf_delta=${CFG_CB008472_B_SCF}
    ...     cfg=${CFG_CB008472_B_WTS}
    Start SOS with BIP     ${sos_script_path}
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    Register UE1
    PDU1 Session Establishment for UE1
    PDU2 Session Establishment for UE1
    PDU3 Session Establishment for UE1
    Before triggering intra-cell handover NR-DC is released
    Stop Data Traffic
    DEREGISTER UE
