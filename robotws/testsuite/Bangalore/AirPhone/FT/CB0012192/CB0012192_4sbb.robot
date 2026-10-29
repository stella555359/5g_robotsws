*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Malarvannan
                 ...              :contact      : Sharanya
                 ...              :Description  : This script is to validate L3 call in
                 ...                               LO_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,malarvannan.k@nokia.com

Resource          ./resources/Keywords/CB0012192_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB0012192_variables.robot

Suite Setup       L3 Suite Setup
Suite Teardown    L3 Suite Teardown

*** Test Cases ***
4ssb per RACH
    [Documentation]
         ...    author: malarvannan.k@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.01.2025,malarvannan.k@nokia.com
         ...    This is basic 4ssb per RACH new 2025 common keywords

     Start SOS with BIP     ${sos_script_path}
     Start Logs     ${L_AP_GNB_SYS}

     Get cell On Air     iphy=${CFG_AP_IPHY_4ssb}     scf_delta=${CFG_GNB_SCF_DELTA_JSON_4ssb}
     ...     cfg=${CFG_CB0012192_WTS_CFG_12192_TC02}

     Start Logs     ${L_GNB_L3} ${L_WTS_L3}

     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB_4ssb}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
#     UE Register and PDU Session
#     UL Data
#     UE Deregister
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
