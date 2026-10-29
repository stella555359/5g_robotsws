*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Variables ***
${disable_ciphering_yaml_path}=         ${CURDIR}/yaml_config/disable_ciphering.json
${SIB_config_yaml_path}=                ${CURDIR}/yaml_config/SIB_config.yaml
${gNBSim_path}=                         ${CURDIR}/yaml_config/gNBSim.json
${FDD_golden_SCF_fix_yaml_path}=        ${CURDIR}/yaml_config/FDD_golden_SCF_fix.yaml
${SA_srb_drb_inactivity_yaml_path}=     ${CURDIR}/yaml_config/SA_srb_drb_inactivity.yaml
${inter_gNB_handover}=                  ${CURDIR}/yaml_config/inter_gnb_ho.yaml
${intra_gNB_handover}=                  ${CURDIR}/yaml_config/intra_gnb_ho.yaml
${NG_handover}=                         ${CURDIR}/yaml_config/NG_handover.yaml
${fdm_scheduling}=                      ${CURDIR}/yaml_config/increased_fdm_scheduling.yaml
${inter_rat_ho_yaml_path}=              ${CURDIR}/yaml_config/inter_rat_ho.yaml
${inter_gnb_intra_freq_ho_yaml_path}=   ${CURDIR}/yaml_config/inter_gnb_intra_freq_ho.yaml
${GBR_5QI_yaml_path}=                   ${CURDIR}/yaml_config/GBR_5QI_1_2_3_4_71_72_76_128_170_212_254.json
${VoNR_GBR}=                            ${CURDIR}/yaml_config/vonr_gbr_activation.yaml
${PCMD_enable_yaml_path}=               ${CURDIR}/yaml_config/pcmd_enable_DU_CU.yaml
${disable_ran_sharing_yaml_path}=       ${CURDIR}/yaml_config/disbaled_ran_sharing.yaml

# LO_AP_LO 4 cells configs
${disable_ran_sharing_yaml_path_4_cells}=       ${CURDIR}/yaml_config/disabled_ran_sharing_4_cells.yaml

