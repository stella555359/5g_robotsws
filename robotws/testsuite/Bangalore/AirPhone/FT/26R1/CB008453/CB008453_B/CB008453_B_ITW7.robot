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

Suite Setup       CB008453 Suite Setup            ${TC_DIR_CB008453_B_ITW7}
Suite Teardown    CB008453 Suite Teardown         ${TC_DIR_CB008453_B_ITW7}

*** Test Cases ***
CB008453-B_ITW7_Single_user_in_8CC_with_UCI_multiplexing_on_PUCCH
    Get cell On Air     iphy=${CFG_CB008235_B_ITW3_IPHY}      scf_delta=${CFG_CB008453_B_ITW7_SCF}
    ...     cfg=${CFG_CB008453_B_ITW3_WTS}
    Start SOS with BIP     ${sos_script_path}
    Attach multi ues    first_ue_id=107    last_ue_id=212
    Verify tdd-UL-DL-ConfigurationCommon
    Start NSA traffic for multiple UEs    ues=107-212   traffic_rate=10Mbps    dir=DL
    Start NSA traffic for multiple UEs    ues=107-212   traffic_rate=10Mbps    dir=UL
    Sleep    5s    reason=wait for tput stabilization
    ${all_ues_traffic_DL}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=212
    ...                                                                       data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   All Ues traffic DL: ${all_ues_traffic_DL}

    ${all_ues_traffic_UL}=    Get summarize data rate for multiple NSA UEs    dir=ul    first_ue=107    last_ue=212
    ...                                                                       data_rate_type=Average    bearer_type=mcg    bearer=2
    Log to console   All Ues traffic UL: ${all_ues_traffic_UL}
    Detach multi ues     first_ue_id=107    last_ue_id=212
