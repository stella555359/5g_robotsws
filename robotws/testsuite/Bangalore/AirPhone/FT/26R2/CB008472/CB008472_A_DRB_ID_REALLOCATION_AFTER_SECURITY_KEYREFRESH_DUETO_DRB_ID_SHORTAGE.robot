** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72_MMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This script is to validate CB008472
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,12.12.2025,keerthi.chittoor@nokia.com

Resource          resources/Keywords/CB008472_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          resources/Variables/CB008472_variables.robot

Suite Setup       CB008472 Suite Setup            ${TC_DIR_CB008472_A}
Suite Teardown    CB008472 Suite Teardown         ${TC_DIR_CB008472_A}

*** Test Cases ***
CB008472_A_Verify DRB ID reallocation after security key refresh triggered by PDU session modification
    [Documentation]
         ...    author: keerthi.chittoo@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,12.12.2025,keerthi.chittoor@nokia.com
         ...    To verify INTRA CELL HANDOVER triggered and key refreshement happened
    Get cell On Air     iphy=${CB008472_A_AP_IPHY}     scf_delta=${CFG_CB008472_A_SCF}
    ...     cfg=${CFG_CB008472_A_WTS}
    Start SOS with BIP     ${sos_script_path}
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    Register UE1
    UE1 with PDU1 session establishment
    UE1 with PDU2 session establishment
    UE1 with PDU3 session establishment
    GNB triggers an intra-cell handover to perform a security key refresh
    Stop Data Traffic
    DEREGISTER UE
