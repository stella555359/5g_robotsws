*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : shivalingesh.sheelavantar@nokia.com
                 ...              :contact      : Shivalingesh
                 ...              :Description  : This script is to CB007880-G Inter gNb HO call
                 ...                               MP_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,24.10.2025,shivalingesh.sheelavantar@nokia.com

Resource          ./resources/Keywords/CB007880_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB007880_variables.robot

Suite Setup       CB007880 Suite Setup
Suite Teardown    CB007880 Suite Teardown

*** Test Cases ***
CB007880-G Inter gNb HO call
    [Documentation]
         ...    author: shivalingesh sheelavantar
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,24.10.2025,shivalingesh.sheelavantar@nokia.com
         ...    This is CB007880-G Inter gNb HO call 2025 common keywords

     Start Logs       ${L_AP_GNB_SYS}
     Get cell On Air     iphy=${CFG_AP_IPHY}      scf_delta=${CFG_GNB_SCF_DELTA_JSON}
     ...     cfg=${CFG_WTS_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE Register and PDU Session
     UL Data
     DL Data
     Exe egate cmd      cmd=${CB007880_G1_INTER_HO_CMD}
     UE1 TRP POS INFO VALIDATION
     UE Deregister
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_TRP_MR_UE1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate       log=${L_GNB_L3}        logfile_with_path=/home/ute/logs/gnbl3.pcap
     ...     filter=nrppa        element=_ws.col.info == "PositioningMeasurementReport"
