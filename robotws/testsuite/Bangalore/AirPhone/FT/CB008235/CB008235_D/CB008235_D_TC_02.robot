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
CB008235_D_TC_02_Interworking with CB008662 Adaptive re-transmission
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,17.04.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify IWK 8235 with CB008662 Adaptive Retx enabled
         ...    1. Verify MCS PM counter for the reserved MCS check
         ...    2. Reserved MCS to be used for paired UEs only - UL
         ...    3. UEs not paired to use initial MCS for reTx in UL
#    ?The PRB pooling feature 5GC001227 is deactivated (NIDD parameter /NRBTS/actSlowPrbPooling is set to FALSE)
#    ? The R&D parameter rdMaxCrReTransmissionDL and rdMaxCrReTransmissionUL are set to the default values of 1.30
#    ? A nonGBR bearer (RLC AM) is setup in DL and UL for the UEs
#    The adaptive retransmission scheme is applied to [Before CB008662-D-UPD001] non-paired
# [End CB008662-D-UPD001] UEs for HARQ retransmissions in DL and UL
#o    a reserved MCS is used for the adaptive retransmission
#§    condition see UC CB008662-A#B1 (DL) and UC CB008662-A#B2 (UL)
#    Check CB8662 PM Counters Expected values      ${CB8662_Initial_and_retransmission_PUSCH_64qam_MCS30} M55304C04030
#    Check CB8662 PM Counters Expected values      ${CB8662_Initial_and_retransmission_PUSCH_64qam_MCS31} M55304C04031
#    Check CB8662 PM Counters Expected values      ${Successful_PUSCH_transmissions_64qam_MCS30}M55302C05030
#    Check CB8662 PM Counters Expected values      ${Successful_PUSCH_transmissions_64qam_MCS31} M55302C05031
#    Check CB8662 PM Counters Expected values      ${Unsuccessful_PUSCH_transmissions_64qam_MCS30} M55302C03030
#    Check CB8662 PM Counters Expected values      ${Unsuccessful_PUSCH_transmissions_64qam_MCS31} M55302C03031
     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_D_TC_02_GNB_SCF}
     ...     cfg=${CFG_CB008235_A_TC_08_NSA_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
#     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
#     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     Start SOS with BIP     ${sos_script_path}
     CB008235 X2 link up
     CB008235 Ul Sinr Profile Act
     NSA Call UE11 to UE14
     NSA Call UE15 to UE18
     NSA UE11 to UE18 Beam Pos Activation
     Trigger Channel Condition Variation using SINR and NOISE
     Sleep      60
     Log to console       "Applied channel conditions"
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Sleep      60
     Start Logs     ${L_GNB_TTI}
     Sleep      1
     Stop Logs     ${L_GNB_TTI}
     Validate 8UE RANK1 Paired in TTI logs
#     Validate NSA 8 UE RANK1 Paired Data Rate
     CB008235 Validate PM counter      ${CB008235_D_RESERVED_MCS}     ${PM_COUNTER_FILE}
     NSA Detach UE11 to UE14
     NSA Detach UE15 to UE18
