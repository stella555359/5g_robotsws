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

Suite Setup       CB012328 Suite Setup            ${TC_DIR_CB012328_X_B02}
Suite Teardown    CB012328 Suite Teardown         ${TC_DIR_CB012328_X_B02}

*** Test Cases ***
CB012328_X_B02_The trigger is RRC Reestablishment of UE on prepared gNB
         [Documentation]
         ...    author: keerthi.chittoo@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,05.02.2026,keerthi.chittoor@nokia.com
         ...    To verify SN bearer is take back happen when VONR is established And
         ...    When VONR is active,NRDC is not possible with RRC Reestablishment from prepared GNB
    Get cell On Air     iphy=${CB012328_X_AP_IPHY}     scf_delta=${CFG_CB012328_X_SCF}
    ...     cfg=${CFG_CB012328_X_WTS}
    Start SOS with BIP     ${sos_script_path}
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    Register UE on SimGNB and start traffic
    Configuring Sim GNB with UE history
    Configuring UE to ignore RRC Reconfiguration but to trigger RRC Reestablishment
    Triggering A3 measurment for XN HO from SIM GNB
    Releasing 5QI-1 and Triggering A4 measurment for NRDC Establishment
    Establishing 5QI-1 Bearer
    Triggering A3 measurment for XN HO to SIM GNB
    Stop Data Traffic
    DeRegister UE
