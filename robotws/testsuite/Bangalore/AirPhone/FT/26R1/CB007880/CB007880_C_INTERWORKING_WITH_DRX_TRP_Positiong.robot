*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Shivalingesh
                 ...              :contact      : ssheelav
                 ...              :Description  : This script is DRX C  in
                 ...                               MP_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,24.10.2025, shivalingesh.sheelavantar@nokia.com

Resource          ./resources/Keywords/CB007880_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB007880_variables.robot

Suite Setup       CB007880 Suite Setup
Suite Teardown    CB007880 Suite Teardown

*** Test Cases ***
CB007880 DRX C
    [Documentation]
         ...    author:  shivalingesh.sheelavantar@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,24.10.2025,  Shivalingesh
         ...    This is DRX C  2025 common keywords

#     Start SOS with BIP     ${sos_script_path}
     Start Logs     ${L_AP_GNB_SYS}
     Get cell On Air     iphy=${CFG_AP_IPHY}     scf_delta=${CFG_GNB_SCF_DELTA_JSON}
     ...     cfg=${CFG_WTS_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE Register and PDU Session
     UL Data
     DL Data
     UE1 TRP POS INFO VALIDATION
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_TRP_MR_UE1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_C_Drx_VAL_1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_C_Drx_VAL_2}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate       log=${L_GNB_L3}        logfile_with_path=/home/ute/logs/gnbl3.pcap
     ...     filter=nrppa        element=_ws.col.info == "PositioningMeasurementReport"
