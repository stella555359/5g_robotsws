*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This script is to validate CB008235-D
                 ...                               03 test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,12.05.2025

Resource          ./resources/Keywords/CB009849_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB009849_variables.robot

#Suite Setup       CB009849 Suite Setup
#Suite Teardown    CB009849 Suite Teardown

*** Test Cases ***
CB009849_D_TC_02_VoNR specific DRX profile is enabled during cell setup and successful setup of VoNR call with FDD
    [Documentation]
         ...    author: keerthi.chittoor@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,12.05.2025,keerthi.chittoor@nokia.com
         ...    To verify reconfiguration with 5QI1 DRB,UE supports
         ...    transform precoder on FDD
    Get cell On Air     iphy=${CB009849_D_iphy}     scf_delta=${CB009849_D_SCF}
    ...     cfg=${CB009849_D_wts.cfg}
    Validate     log=${L_EGATE_CONSOLE}     element=${VAL_SIB1}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    UE Register and PDU Session
    Validate     log=${L_EGATE_CONSOLE}     element=${VAL_UE1_VONRDRX}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    User Modify with 5QI5 DRB Addition
    Start Data Traffic and validate
    User Modify with 5QI1 DRB Addition
    User Modify with 5QI1 DRB Release
