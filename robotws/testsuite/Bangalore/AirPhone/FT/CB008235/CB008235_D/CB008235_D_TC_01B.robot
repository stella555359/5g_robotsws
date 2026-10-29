*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This script is to validate CB008235-A
                 ...                               03 test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ../resources/Keywords/CB008235_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ../resources/Variables/CB008235_variables.robot

Suite Setup       CB008235 Suite Setup
Suite Teardown    CB008235 Suite Teardown

*** Test Cases ***
#Alternative Scenarios:
#·    Set NRBTS.NRCELL.ulDMRSAdditionalPosition to "pos0" .
#    - For the UEs which can support two FL DMRS symbols, the IEs in "DMRS-UplinkConfig
# " shall be as follows: maxLength = "len2" ; dmrs-AdditionalPosition = "pos0".
#    - For the UEs which can support one FL DMRS symbols, the IEs in "DMRS-UplinkConfig "
#shall be as follows: maxLength = "len1" ; dmrs-AdditionalPosition = "pos0".
CB008235_D_TC_05_Interworking with CB006062 FDM of DMRS and PUSH data in UL ulDMRSAdditionalPosition pos0
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,17.04.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify IWK 8235 with CB00602 Adaptive Retx enabled
         ...    8 RANK 1 UE NSA  PAIR  with FL symbols changed in UECAP  as alternative scenario
     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_D_TC_01B_GNB_SCF_DELTA}
     ...     cfg=${CFG_CB008235_D_TC_01B_SANSA_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
#     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
#     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     CB008235 X2 link up
     CB008235 Ul Sinr Profile Act
     NSA Call UE11 to UE14
     Validate     log=${L_EGATE_CONSOLE}       element=$${VAL_ADDITIONAL_UL_DMRS_POS}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Run Keyword And Expect Error      Validate     log=${L_EGATE_CONSOLE}       element=$${VAL_2_ULDMRS}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     NSA Call UE15 to UE18
     Validate     log=${L_EGATE_CONSOLE}       element=${VAL_2_ULDMRS}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}       element=$${VAL_ADDITIONAL_UL_DMRS_POS}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Start SOS with BIP     ${sos_script_path}
     NSA UE11 to UE18 Beam Pos Activation
     Sleep      5
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Sleep      60
     Validate NSA 8 UE RANK1 Paired Data Rate
     Start Logs     ${L_GNB_TTI}
     Sleep      1
     Stop Logs     ${L_GNB_TTI}
#    Validation of DMRS , ant port to be added if needed
     Validate 8UE RANK1 Paired in TTI logs
     NSA Detach UE11 to UE14
     NSA Detach UE15 to UE18
