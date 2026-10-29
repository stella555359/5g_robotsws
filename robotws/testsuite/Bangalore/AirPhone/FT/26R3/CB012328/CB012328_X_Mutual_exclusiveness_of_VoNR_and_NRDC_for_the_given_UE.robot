** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72_MMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This script is to validate CB012328
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,05.02.2026,keerthi.chittoor@nokia.com

Resource          resources/Keywords/CB012328_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          resources/Variables/CB012328_variables.robot

Suite Setup       CB012328 Suite Setup            ${TC_DIR_CB012328_X}
Suite Teardown    CB012328 Suite Teardown         ${TC_DIR_CB012328_X}

*** Test Cases ***
CB012328_X_Mutual exclusiveness of VoNR and NR-DC for the given UE
         [Documentation]
         ...    author: keerthi.chittoo@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,23.12.2025,keerthi.chittoor@nokia.com
         ...    To verify SN bearer is take back happen when VONR is established And
         ...    When VONR is active,NRDC is not possible
    Get cell On Air     iphy=${CB012328_X_AP_IPHY}     scf_delta=${CFG_CB012328_X_SCF}
    ...     cfg=${CFG_CB012328_X_WTS}
    Start SOS with BIP     ${sos_script_path}
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    Register UE1
    UE1 with PDU1 session establishment which eligible for NRDC
    UE1 with PDU2 session establishment with VONR
    MN gNB performs SN bearer takeback followed by VoNR DRB setup
    Releasing 5QI-1 bearer and configures A4 measurement for NR-DC activation
    Observing SN take back by esatblishing 5QI-1 and Releasing it and checking for NRDC establishment
    Stop Data Traffic
    DeRegister UE
