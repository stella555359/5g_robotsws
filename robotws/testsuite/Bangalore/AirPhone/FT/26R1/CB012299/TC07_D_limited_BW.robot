*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Deepthi A
                 ...              :contact      : Deepthi A
                 ...              :Description  : This script is to validate NRDC release during HO in
                 ...                               MP_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,28.07.2025,deepthi.a@nokia.com

Resource          ./resources/Keywords/CB012299_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB012299_Variables.robot


Suite Setup       L3 Suite Setup
Suite Teardown    L3 Suite Teardown

*** Test Cases ***
CB012299
    [Documentation]
         ...    author: deepthi.a@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,07.08.2025,deepthi.a@nokia.com
         ...    This is Verification of feature activation with new 2025 common keywords

     Start SOS with BIP     ${sos_script_path}
     Add Rad Param Or Modify GNB swconfig     0x58024F=1
     Get cell On Air     iphy=${CB012299_D_IPHY}     scf_delta=${CB012299_D_limited_bwp_SCF}
     ...     cfg=${CB012299_D_CFG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
	 UE Register and PDU Session
     Send 800mbps DATA TRAFIC wait for SCELL activation
     Verifying the Counter for CB012299_D
     ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
     PM Check passing dictionary
     Wait For Next Full Pm Interval
     Deregister UE
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
