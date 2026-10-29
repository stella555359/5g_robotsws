** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72_MMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This script is to validate CB008453
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,27.10.2025,keerthi.chittoor@nokia.com

Resource          ../resources/Keywords/CB008453_Keywords.robot
Resource          ../../../resources/Variables/general_common_variables.robot
Resource          ../resources/Variables/CB008453_variables.robot

Suite Setup       CB008453 Suite Setup            ${TC_DIR_CB008453_C_ITW1}
Suite Teardown    CB008453 Suite Teardown         ${TC_DIR_CB008453_C_ITW1}

*** Test Cases ***
CB008453-C_ITW1_Single_UE_scheduling_with_8CC_in_SA_mode
    Get cell On Air     iphy=${CFG_CB008235_C_ITW1_IPHY}      scf_delta=${CFG_CB008453_C_ITW1_SCF}
    ...     cfg=${CFG_CB008453_C_ITW1_WTS}
    Sleep    300s
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    Start SOS with BIP     ${sos_script_path}
    Ue Register    ue_id=1    pdu=1
    PDU session Establishment    ue_id=1    pdu=1    nwslice=1    gw=1
    Verify tdd-UL-DL-ConfigurationCommon
    Start SA traffic    ue=1    dir=dl    traffic_rate=100Mbps
    Start SA traffic    ue=1    dir=ul    traffic_rate=100Mbps
    Sleep    5s    reason=wait for tput stabilization
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=DL    expected_traffic=100Mbps
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=UL    expected_traffic=100Mbps
    Deregister UE    ue_id=1
