*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : Sharanya
                 ...              :Description  : This script is to validate L3 call in
                 ...                               LO_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ./resources/Keywords/L3_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/L3_variables.robot

Suite Setup       L3 Suite Setup
Suite Teardown    L3 Suite Teardown

*** Test Cases ***
CB008490 LC L3 call
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com
         ...    This is basic L3 Call with new 2025 common keywords

#     Start SOS with BIP     ${sos_script_path}
     Start Logs     ${L_AP_GNB_SYS}

     Get cell On Air     iphy=${CB008490_LC_CFG_AP_IPHY}     scf_delta=${CB008490_LC_SCF_DELTA_JSON}
     ...     cfg=${CB008490_LC_CFG_WTS_CFG}

     Start Logs     ${L_GNB_L3} ${L_WTS_L3}

     Sleep    10

     Validate     log=${L_EGATE_CONSOLE}      element=${eVAL_XN1}
      ...      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      ...     value=${vVAL_XN1}      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
