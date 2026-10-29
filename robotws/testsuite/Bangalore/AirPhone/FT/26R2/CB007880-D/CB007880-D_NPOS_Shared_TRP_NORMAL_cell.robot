*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Shivalingesh Sheelavantar
                 ...              :contact      : ssheelav
                 ...              :Description  : NR UL-TDoA in RU SRS
                 ...                               MP_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,02.01.2026,shivalingesh.sheelavantar@nokia.com

Resource          ./resources/Keywords/CB007880_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB007880_variables.robot

Suite Setup       CB007880 Suite Setup
Suite Teardown    CB007880 Suite Teardown

*** Test Cases ***
CB007880 D NR UL-TDoA in RU SRS
    [Documentation]
         ...    author: Shivaligesh
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,02.01.2026,shivalingesh.sheelavantar@nokia.com
         ...    NR UL-TDoA in RU SRS  2026 common keywords
     Start Logs     ${L_AP_GNB_SYS}
     Get cell On Air     iphy=${CB007880_D_NRPOS-CELL_AP_IPHY}       scf_delta=${CB007880_D_NRPOS-CELL_gNB_SCF}
     ...     cfg=${CB007880_D_NRPOS-CELL_WTS_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE Register and PDU Session
     UL Data
     DL Data
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_D_NR_POS_CHECK_1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE Register 2 and PDU Session
     UE2 UL Data
     UE2 DL Data
     UE Register 3 and PDU Session
     UE3 UL Data
     UE3 DL Data
     UE Register 4 and PDU Session
     UE4 UL Data
     UE4 DL Data
     UE1 NRPOS MULTICELL TRP INFO VALIDATION
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_TRP_MR_UE1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE2 NRPOS MULTICELL TRP INFO VALIDATION
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_TRP_MR_UE1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE3 NRPOS MULTICELL TRP INFO VALIDATION
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_TRP_MR_UE1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE4 NRPOS MULTICELL TRP INFO VALIDATION
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB007880_TRP_MR_UE1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate       log=${L_GNB_L3}        logfile_with_path=/home/ute/logs/gnbl3.pcap
     ...     filter=nrppa        element=_ws.col.info == "PositioningMeasurementReport"
