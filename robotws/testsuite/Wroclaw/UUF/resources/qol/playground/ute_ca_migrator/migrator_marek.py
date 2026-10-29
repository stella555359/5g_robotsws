import os
import re
import shutil
import test_lines

# author: tomasz.szylkowski@nokia.com
# modified by: marek.starzyk@nokia.com

# this simple script will convert structure of your selected configurations from agent_gve_common repository
# testline-configuration to ute-ca topology-config repo
#
# regarding SWCONFIG:
# all testlines will have the same swconfig copied from script directory
# if you want it different then you need to adjust the script
#
# regarding YAML
# generally take a look into templates prepared in script repository and adjust accordingly
# special care needs to be taken with 4g5g testlines as you need to specify nsa and rfs settings


# select True if you want to script to printout execution
verbose = True
copy_yaml = False
copy_swconfig = True
copy_scf = False

# path where output files will be created, end it with slash
output_path = "C:/Users/starzyk/repo/topology-configs/"

# path to local repo with testline-configuration, end it with slash
testline_configuration_repo_path = "C:/Users/starzyk/testlines/"

# allowed builds for single nodes and fullracks
allowed_build_list = ['21B', '22R1', '22R2', '22R3', '22R4', '23R1', '23R2', '23R3', '23R4', '24R1', '00']

# the build which is used as a "DEFAULT"
default_release = '24R1'

# allowed builds for RFS testlines, as of ver 0.1b there is only support for common builds so no 5G21A and such
# to my knowledge ute-ca does not support old 5g builds
allowed_build_list_5g = ['21B', '22R1', '22R2', '22R3', '22R4', '23R1', '23R2', '23R3', '23R4', '24R1', '00']

# maintainer email to be put in yaml file
maintainer = "tomasz.szylkowski@nokia.com"

# table with testlines to migrate
# hostname, label, type
# hostname - is important because script will search for proper name in testline-configuration repo
# label - is necessary because in ute-ca you define topologies based on label
# type - ranges in "4g5g" / "single" / "fullrack" / "4+3" / "common"- selection defines which yaml file is taken
#        also, if 4g5g will get scfs also for node1, although fullracks in old agent hand node 2
#        it will not be merged

testlines = [

    # single
    # ["1_16_CLOUD3697", "CLOUD_RF_AIBL_B1_B2_B3_2xFXEB_FRMF_FRHF_UUF", "single"],
    # ["1_16_UTESRAN3845", "CLOUD_SRAN_NL_1ASIL_2ABIO_1AHIB_1AHLOA_1AHPMDA_1AZNA_UUF1_UTECA", "single"], ręcznie
    # ["1_16_UTESRAN3885", "CLOUD_SRAN_NL_1ASIL_2ABIO_1AHIB_1AHLOA_1AHPMDA_1AZNA_UUF2_UTECA", "single"], ręcznie
    # ["1_16_UTESRAN3850", "CLOUD_SRAN_NL_1ASIL_2ABIO_1AHIB_1AHLOA_1AHPMDA_1AZNA_UUF3_UTECA", "single"], ręcznie
    # ["1_16_CLOUDGTA3817", "CLOUD_RF_AIL_B1_B2_3AHFIB_3AHBCA", "single"],
    # ["1_16_CLOUD3770", "CLOUD_RF_AIL_B1_FRMC_FXED_ARGA", "single"],
    # ["1_16_CLOUD3728", "CLOUD_RF_AIBR_B1_FXFC", "single"],
    # ["1_16_UTESRAN3634", "CLOUD_SRAN_L_1ASIB_3ABIA_3AAIB_3AAFB", "single"],
    # ["1_16_CLOUD3844", "CLOUD_RF_FCC_FRIJ_FHEA_FHDB", "single"],
    # ["1_16_CLOUD3847", "CLOUD_RF_FC_2FXEB_FRMC", "single"],
    # ["1_16_UTE4G3851", "CLOUD_RF_FC_FRMF_FXEB_FRGT", "single"],
    # ["1_16_CLOUD3726", "CLOUD_RF_FC_3FHFB", "single"],
    # ["1_16_UTESRAN3212", "CLOUD_SRAN_L_1FSMF_1FBBC_1FBBA_1FXDB_1FXCC_1FXED_UUF_1", "single"],
    # ["1_16_UTESRAN3213", "CLOUD_SRAN_L_1FSMF_1FBBC_1FBBA_1FXDB_1FXCC_1FXED_UUF_2", "single"],
    # ["1_16_UTESRAN3214", "CLOUD_SRAN_L_1FSMF_1FBBC_1FBBA_1FXDB_1FXCC_1FXED_UUF_3", "single"],
    # ["1_16_UTESRAN3874", "CLOUD_SRAN_LWG_1FSMF_2FBBC_1FXJB_2FXEF_1FRGU", "single"],
    # ["1_16_UTESRAN3875", "CLOUD_SRAN_NLWG_1ASIL_1ABIA_1ABIN_1ABIO_1AZNA_1AHFIB_1FXCB", "single"],
    # ["1_16_UTESRAN2041", "CLOUD_SRAN_NL_1ASOE_3AHCA_1AZNA_UTECA", "single"],
    # ["1_16_UTESRAN3222", "CLOUD_SRAN_NL_1ASIL_1ABIO_1ABIN_1ABIA_1FRHB_1FRIJ_1FXEB_UUF_1_UTECA", "single"],
    # ["1_16_UTESRAN3208", "CLOUD_SRAN_NL_1ASIL_1ABIO_1ABIN_1ABIA_1FRHB_1FRIJ_1FXEB_UUF_2_UTECA", "single"],
    # ["1_16_UTESRAN3209", "CLOUD_SRAN_NL_1ASIL_1ABIO_1ABIN_1ABIA_1FRHB_1FRIJ_1FXEB_UUF_3_UTECA", "single"],
    # ["1_16_UTESRAN2040", "CLOUD_SRAN_NL_1ASOF_1AHFB_1AZRB", "single"],
    # ["1_16_UTESRAN2065", "CLOUD_SRAN_NL_1ASIB_1ABIA_1ABIN_1ABIO_1FXDB_1AHEGA_1AHFB_UUF_1_UTECA", "single"],
    # ["1_16_UTESRAN2066", "CLOUD_SRAN_NL_1ASIB_1ABIA_1ABIN_1ABIO_1FXDB_1AHEGA_1AHFB_UUF_2_UTECA", "single"],
    # ["1_16_UTESRAN2067", "CLOUD_SRAN_NL_1ASIB_1ABIA_1ABIN_1ABIO_1FXDB_1AHEGA_1AHFB_UUF_3_UTECA", "single"],
    # ["1_16_UTESRAN3202", "CLOUD_SRAN_N_1ASOE_3AEQZ_2AHPB", "single"],
    # ["1_16_UTESRAN3206", "CLOUD_SRAN_N_1ASOE_3AQQJ_2AHPB", "single"],
    # ["1_16_UTESRAN3607", "CLOUD_RF_AO_3AHPB_3AQQJ", "single"],
    # ["1_16_UTESRAN3689", "CLOUD_SRAN_L_1FSIH_2FBIH_1AZNA", "single"],
    # ["1_16_UTESRAN3754", "CLOUD_SRAN_L_1FSIH_2FBIH_1FZHN", "single"],
    # ["1_16_CLOUD1235", "CLOUD_RF_FC_FZNI", "single"],
    # ["1_16_UTESRAN3742", "CLOUD_SRAN_L_1FSIH_2FBIH_1FZNI", "single"],
    # ["10_16_CLOUD3846", "CLOUD_RF_AIBR_B1_AZQP", "single"],
    # ["1_16_CLOUD3683", "CLOUD_RF_AIL_B1_B2_B3_2FZFF-e", "single"],
    # ["1_16_CLOUD3893", "CLOUD_AIBR_B4_B6_2AAHF_AZHA", "single"],
    # ["2_11_UTE4G276", "CLOUD_RF_AIL_B1_SST30_AHFB_AHIB_2xAZRB", "single"],
    # ["2_11_UTE4G274", "CLOUD_RF_AIL_B1-2_SST505_AAFB_AAIB", "single"],
    # ["1_16_UTESRAN2016", "CLOUD_SRAN_N_1ASOE_3AHPJ_UTECA", "single"],
    # ["1_16_UTESRAN3643", "CLOUD_SRAN_NL_1ASIL_1ABIA_1ABIN_1ABIO_1AHLOA_1AHPMDA", "single"],
    # ["1_16_UTESRAN3644", "CLOUD_SRAN_NL_1ASIM_1ABIA_1ABIP_1ABIQ_1AZQP_1AZNA", "single"],
    # ["1_16_UTESRAN2057", "CLOUD_SRAN_L_1FSFM_1AZQC_1_UTECA", "single"],w budowie
    # ["1_16_UTESRAN2097", "CLOUD_SRAN_L_1FSFM_1AZQC_2_UTECA", "single"],w budowie
    # ["1_16_UTESRAN2107", "CLOUD_SRAN_L_1FSFM_1AZQC_3_UTECA", "single"],w budowie

    # fullrack
    # ["1_16_UTESRAN2046", "CLOUD_SRAN_L_2ASIA_6ABIA_3AHIB_3AHFB_3AZRB_UTECA", "fullrack"],
    # ["1_16_UTESRAN3840", "CLOUD_SRAN_LWG_2FSMF_2FBBC_1FXDB_1FRGU_1FXED_1FRMF", "fullrack"],
    # ["1_16_UTESRAN3787", "CLOUD_SRAN_LWG_2ASIA_4ABIA_1FHFB_1AHLOA_1AHPD_1FZNI_UUF_1_UTECA", "fullrack"],
    # ["1_16_UTESRAN3789", "CLOUD_SRAN_LWG_2ASIA_4ABIA_1FHFB_1AHLOA_1AHPD_1FZNI_UUF_2_UTECA", "fullrack"],
    # ["1_16_UTESRAN3791", "CLOUD_SRAN_LWG_2ASIA_4ABIA_1FHFB_1AHLOA_1AHPD_1FZNI_UUF_3_UTECA", "fullrack"],
    # ["1_16_CLOUD2181", "CLOUD_RF_AIBLR_B1_B4_AHCA_AZNA", "fullrack"],
    # ["1_16_CLOUD3848", "CLOUD_SRAN_NLWG_2ASIL_2ABIA_1ABIN_1ABIO_1AHCA_1AHFIB_1AZNA_1FXEB", "fullrack"],
    # ["1_16_UTESRAN2089", "CLOUD_SRAN_NLWG_2ASIL_1ABIA_4ABIO_3AEHC_3AHFIB_3AHLOA", "fullrack"],
    # ["1_16_UTESRAN1279", "CLOUD_SRAN_L_2ASIA_4ABIA_3AAIB_3AAFB_3AHLOA", "fullrack"],
    # ["1_16_UTESRAN2018", "CLOUD_SRAN_NLG_2ASIL_4ABIO_1ABIA_3AHFII_3AHLOB_2AZHL_UTECA", "fullrack"],
    # ["1_16_UTESRAN3684", "CLOUD_SRAN_NL_2ASIM_1ABIA_1ABIN_1ABIO_1AHFB_1AHLOA_1AZHL_1FRBI_UTECA", "fullrack"],
    # ["1_16_UTESRAN2031", "CLOUD_SRAN_NL_2ASIB_2ABIO_3AHEH_1AZQP", "fullrack"],
    # ["1_16_UTESRAN2201", "CLOUD_SRAN_NLWG_2ASIL_2ABIO_1ABIN_1ABIL_1ABIA_2FXEF_1AQQK_1AHFII_2FXCA_3AHEH_UTECA",
    # "fullrack"],
    # ["1_16_UTESRAN2203",
    #  "CLOUD_SRAN_NLWG_2ASIL_2ABIO_1ABIN_1ABIL_1ABIA_2FRGY_1AQQK_1AHFII_2FXCA_3AHCA_UTECA", "fullrack"],
    # ["1_16_UTESRAN2205", "CLOUD_SRAN_NLWG_2ASIL_2ABIO_1ABIN_1ABIL_1ABIA_1FRGY_1FXEF_1AQQK_1AHFII_2FXCA_3AHPE_UTECA",
    # "fullrack"],
    # ["1_16_UTESRAN2198", "CLOUD_SRAN_NLG_2ASIL_ABIA_4ABIO_3AHLOB_3AHFII_3AEHC", "fullrack"],
    # ["1_16_UTESRAN3223", "CLOUD_SRAN_N_2ASIK_3ABIL_1AEHC_1AHLOA_1AHFIG_UUF_1_UTECA", "fullrack"],
    # ["1_16_UTESRAN3225", "CLOUD_SRAN_N_2ASIK_3ABIL_1AEHC_1AHLOA_1AHFIG_UUF_2_UTECA", "fullrack"],
    # ["1_16_UTESRAN3227", "CLOUD_SRAN_N_2ASIK_3ABIL_1AEHC_1AHLOA_1AHFIG_UUF_3_UTECA", "fullrack"],
    # ["10_16_CLOUD3716", "CLOUD_RF_AILR_B1_B5_AAHF_AAHC_mMIMO", "fullrack"],
    # ["1_16_UTESRAN2194",
    #  "CLOUD_SRAN_NLWG_2ASIB_1ABIN_1ABIL_2ABIO_2ABIA_1FXCC_2FRIJ_1AHPF_1AZNA_1AHPMDA_1FHDB_UUF_1_UTECA", "fullrack"],
    # ["1_16_UTESRAN2196",
    #  "CLOUD_SRAN_NLWG_2ASIB_1ABIN_1ABIL_2ABIO_2ABIA_1FXCC_2FRIJ_1AHPF_1AZNA_1AHPMDA_1FHDB_UUF_2_UTECA", "fullrack"],
    # ["1_16_UTESRAN3641",
    #  "CLOUD_SRAN_NLWG_2ASIB_1ABIN_1ABIL_2ABIO_2ABIA_1FXCC_2FRIJ_1AHPF_1AZNA_1AHPMDA_1FHDB_UUF_3_UTECA", "fullrack"],
    # ["1_16_UTESRAN3200", "CLOUD_SRAN_NLWG_2ASIL_1ABIA_4ABIO_1AHBCA_1AHLOA_1AHFIB_1FXCB_1FRCG_UTECA", "fullrack"],
    # ["1_16_UTESRAN2073", "CLOUD_SRAN_NL_2ASIM_1ABIO_1ABIQ_3ABIP_1AZHA_1AQQQA_1AHLOB_1AVQL_UUF_1_UTECA",
    # "fullrack"], ręcznie
    # ["1_16_UTESRAN2104", "CLOUD_SRAN_NL_2ASIM_1ABIO_1ABIQ_3ABIP_1AZHA_1AQQQA_1AHLOB_1AVQL_UUF_2_UTECA",
    # "fullrack"], ręcznie
    # ["1_16_UTESRAN2119", "CLOUD_SRAN_NL_2ASIM_1ABIO_1ABIQ_3ABIP_1AZHA_1AQQQA_1AHLOB_1AVQL_UUF_3_UTECA",
    # "fullrack"], ręcznie

    # 4+3
    # ["1_16_UTESRAN3230", "CLOUD_SRAN_LG_1ASIA_1ABIA_1FSMF_1AHFIB_1FRHB_1FXDB_UTECA", "4+3"],
    # ["1_16_UTESRAN3234", "CLOUD_SRAN_LG_1ASIA_1ABIA_1FSMF_1AHFIB_1FRHB_1FXDB_UUF_2_UTECA", "4+3"],
    # ["1_16_UTESRAN3236", "CLOUD_SRAN_LG_1ASIB_1ABIA_1FSMF_1AHFIB_1FRHB_1FXDB_UUF_1_UTECA", "4+3"],
    # ["1_16_UTESRAN3238", "CLOUD_SRAN_LG_1ASIB_1ABIA_1FSMF_1AHFIB_1FRHB_1FXDB_UUF_2_UTECA", "4+3"],
    # ["1_16_UTESRAN3755", "CLOUD_SRAN_LWG_1ASIB_3ABIA_1FSMF_1FRIE_1FRIJ_1FXFC_2FRBG", "4+3"],

    # 4g5g
    # ["1_16_UTESRAN2083", "CLOUD_RFS_AIBL_B1_B3_ASIKR_B4_B6_3AEHC", "4g5g"],
    # ["1_16_UTESRAN3881", "CLOUD_RFS_AIBL_B1_ASIK_B4_FRPD_FRHF_FXED_UTECA", "4g5g"],
    # ["1_16_UTESRAN3833", "CLOUD_RFS_AIBL_B1_B3_ASIKR_B4_FRGU_UTECA", "4g5g"],
    # ["1_16_UTESRAN2029", "CLOUD_SRAN_NL_1ASIB_1ABIA_1ASIK_1ABIL_3FRHG", "4g5g"],
    # ["1_16_UTESRAN2085", "CLOUD_RFS_AIBL_B1_B3_ASIKR_B4_B6_3AAHF", "4g5g"],
    # ["1_16_UTESRAN3765", "CLOUD_RFS_AIR_B4_B5_ASIKL_B1_B2_B3_3AHCA_3AHFIC", "4g5g"],
    # ["1_16_UTESRAN3763", "CLOUD_RFS_AIR_B4_AIBL_B1_B2_3AHLOA_1FRIG_UUF_1", "4g5g"],
    # ["1_16_UTESRAN3760", "CLOUD_RFS_AIR_B4_B5_B6_ASIKL_B1_3AHLOA_3FRLB_3FRIG_UUF_1", "4g5g"],
    # ["1_16_UTESRAN3600", "CLOUD_SRAN_NL_1ASIB_1ABIA_1ASIK_1ABIL_1AHNA_1AHFIB_1AHBCA_UUF1_UTECA", "4g5g"],
    # ["1_16_UTESRAN3606", "CLOUD_SRAN_NL_1ASIB_1ABIA_1ASIK_1ABIL_1AHNA_1AHFIB_1AHBCA_UUF2_UTECA", "4g5g"],
    # ["1_16_UTESRAN3000", "CLOUD_RFS_AIL_B1_B2_ASILR_B4_B5_3AHBCC_3AHFIC_3AQQK", "4g5g"],
    # ["1_16_UTESRAN2034", "CLOUD_RFS_AIR_B4_B5_ASIKL_B1_B2_3xUHIE_3xUHFA_2xAHFIA", "4g5g"],
    # ["1_16_UTESRAN2045", "CLOUD_RFS_AIBR_B4_B5_AIBL_B1_B2_B3_6AHBCC_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2038", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIB_1ABIL_1ABIO_1AZQO_1AZQP", "4g5g"],
    # ["1_16_UTESRAN3215", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIB_1ABIL_1ABIO_1AZQO_1AZQS", "4g5g"],
    # ["1_16_UTESRAN3216", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIB_1ABIL_1ABIO_1AZQP_1AZQS", "4g5g"],
    # ["1_16_UTESRAN2039", "CLOUD_SRAN_NL_1ASIA_1ABIA_1ASIK_1ABIL_1AHNA_1AHFIB_1AHBCA_UTECA", "4g5g"],
    # ["1_16_UTESRAN2091", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_4", "4g5g"],
    # ["1_16_UTESRAN2092", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2093", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_2", "4g5g"],
    # ["1_16_UTESRAN2095", "CLOUD_RFS_AIBR_B4_ASIKL_B1_3AHLOA_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2096", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_3", "4g5g"],
    # ["1_16_UTESRAN2051", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIL_2ABIL_1ABIO_1AEQY_1AHLOA_1AHPD_UUF_1_UTECA", "4g5g"],
    # ["1_16_UTESRAN2147", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIL_2ABIL_1ABIO_1AEQY_1AHLOA_1AHPD_UUF_2_UTECA", "4g5g"],
    # ["1_16_UTESRAN3617", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIL_2ABIL_1ABIO_1AEQY_1AHLOA_1AHPD_UUF_3_UTECA", "4g5g"],

    # common
    # [["1_16_UTESRAN2066", "1_16_UTESRAN2065", "1_16_UTESRAN2067"], "CLOUD_SRAN_NL_ASIB_VEG2_FRM5_UTECA",
    #  "common"],
    # [["1_16_UTESRAN3845", "1_16_UTESRAN3885", "1_16_UTESRAN3850"], "CLOUD_SRAN_NL_ASIL_ABIO_FRM5_UTECA", "common"],
    # [["1_16_UTESRAN3222", "1_16_UTESRAN3208", "1_16_UTESRAN3209"],
    #  "CLOUD_SRAN_NL_ASIL_ABIO_ABIN_ABIA_VEG2_FRM2_FRM3_UTECA", "common"],
    # [["1_16_UTESRAN2038", "1_16_UTESRAN3216", "1_16_UTESRAN3215"],
    #  "CLOUD_SRAN_NL_ASIB_ABIN_ASIB_ABIL_ABIO_URM6_ERM6_UTECA", "common"],
    # [["1_16_UTESRAN3230", "1_16_UTESRAN3234", "1_16_UTESRAN3236", "1_16_UTESRAN3238"],
    #  "CLOUD_SRAN_LG_AS_ABIA_FSMF_FRM5_FRM2_VEG2_UTECA", "common"],
    # [["1_16_UTESRAN3212", "1_16_UTESRAN3213", "1_16_UTESRAN3214"], "CLOUD_SRAN_L_FSMF_FBBC_FBBA_MED2_VEG2_FRM3_UTECA",
    #  "common"],
    # [["1_16_UTESRAN2051", "1_16_UTESRAN2147", "1_16_UTESRAN3617"],
    #  "CLOUD_SRAN_NL_ASIB_ABIN_ASIL_ABIL_ABIO_TRM6_SRM6_FRM5_UTECA", "common"],

    # fullrack
    # [["1_16_UTESRAN2194", "1_16_UTESRAN2196", "1_16_UTESRAN3641"],
    #  "CLOUD_SRAN_NLWG_ASIB_ABIA_ABIL_ABIO_ABIN_MED2_FRM3_MRM6_FRM5_VEG2_UTECA", "common"],
    # [["1_16_UTESRAN3787", "1_16_UTESRAN3789", "1_16_UTESRAN3791"], "CLOUD_SRAN_LWG_ASIA_ABIA_FRM3_FRM5_TDL2_UTECA",
    #  "common"],
    # [["1_16_UTESRAN3223", "1_16_UTESRAN3225", "1_16_UTESRAN3227"], "CLOUD_SRAN_N_ASIK_ABIL_CHB0_FRM5_UTECA_UTECA",
    #  "common"],
    # [["1_16_UTESRAN2201", "1_16_UTESRAN2203", "1_16_UTESRAN2205"],
    #  "CLOUD_SRAN_NLWG_ASIL_ABIO_ABIN_ABIL_ABIA_FRM3_CTA6_FRM6_MED2_FRM5_UTECA", "common"],

    # special
    # ["1_16_UTESRAN3735", "CLOUD_SRAN_NLG_1ASIA_3ABIA_1FSMF_1ASIK_2ABIL_4AHLOA_4AHFIB_KRAKEN_UUF", "special"],
    # ["1_16_UTESRAN3801", "CLOUD_RF_AIBR_AILR_AIKLR_MONSTER_UUF", "special"],
    # ["10_16_UTESRAN3871", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ABIO_1TPS_1AEHC", "special"],
    # ["10_16_UTESRAN3878", "CLOUD_SRAN_NL_1ASIL_1ABIN_1TPS_1AZNA", "special"],
    # ["10_16_UTESRAN3879", "CLOUD_SRAN_NL_1ASIL_1ABIO_1ABIN_1TPS_1AEHC", "special"],
    # ["1_16_UTESRAN3738", "NOTCLOUD_SRAN_NL_ASIL_ABIO_ABIN_ABIA_AHFIG_AHLOA_AHFB", "special"],
    # ["1_16_UTESRAN3217", "CLOUD_SRAN_NLWG_2ASIL_ABIA_ABIL_ABIN_ABIO_ABIP_ABIQ_AHCA_AHLOA_AHFIB_AZQO_FRIJ_FXFC",
    # "special"],
]

tl_with_ald = ["1_16_UTESRAN3223", "1_16_UTESRAN3225", "1_16_UTESRAN3227", "1_16_UTESRAN2051", "1_16_UTESRAN2147",
               "1_16_UTESRAN3617", "1_16_UTESRAN3230", "1_16_UTESRAN3234", "1_16_UTESRAN3236", "1_16_UTESRAN3238",
               "1_16_UTESRAN3787", "1_16_UTESRAN3789", "1_16_UTESRAN3791", "1_16_UTESRAN2194", "1_16_UTESRAN2196",
               "1_16_UTESRAN3641", "1_16_UTESRAN3874", "1_16_UTESRAN3840", "1_16_CLOUD3847", "1_16_CLOUD3697",
               "1_16_UTESRAN2093", "1_16_UTESRAN2029", "1_16_UTESRAN2018"
               ]


def make_dir(path):
    if not os.path.exists(path):
        if verbose:
            print("MKDIR: " + path)
        os.mkdir(path)


def check_and_add_new_line(file):
    try:
        with open(file, 'r') as f:
            content = f.read()
        if not content.endswith('\n'):
            with open(file, 'a') as f:
                f.write('\n')
                if verbose:
                    print(f"INFO: end line was added to the file {file}")
    except Exception as e:
        print(f"Error: {e}")


def copy_file(src, dest):
    if verbose:
        print("COPYING: " + src + " TO " + dest)
    shutil.copyfile(src, dest)
    check_and_add_new_line(dest)


def check_label(label):
    if not str(label).endswith("_UTECA"):
        label += "_UTECA"
    return label


def select_proper_yaml(tl_type):
    if tl_type == "fullrack":
        yaml = "config_fr.yaml"
    elif tl_type == "4g5g":
        yaml = "config_4g5g.yaml"
    elif tl_type == "4+3":
        yaml = "config_4_3.yaml"
    else:
        yaml = "config_single.yaml"
    return yaml


def check_scf_release(tl_hostname):
    scf_dir = None
    label = test_lines.tl_dict[tl_hostname]['topology']
    builds = []
    testline_configuration_directory = testline_configuration_repo_path + tl_hostname
    try:
        scf_dir = [f for f in os.listdir(testline_configuration_directory + "/node1/")
                   if os.path.isfile(os.path.join(testline_configuration_directory + "/node1/", f))]
    except Exception as e:
        print(e)
        input("Press Enter to continue...")
    for scf in scf_dir:
        if label in scf:
            build = re.search('SBTS(.+?).xml', scf).group(0).replace(".xml", "")
            builds.append(build)
    builds.append('DEFAULT')
    return builds


def check_tl_type(testline_hostname):
    return test_lines.tl_dict[testline_hostname]["config"]


def check_if_build_allowed(tl_type, build):
    build = build.replace("SBTS", "")
    if build == 'DEFAULT' and tl_type == "4g5g" and default_release in allowed_build_list_5g:
        return True
    elif build == 'DEFAULT' and tl_type != "4g5g" and default_release in allowed_build_list:
        return True
    elif tl_type == "4g5g" and build in allowed_build_list_5g:
        return True
    elif tl_type != "4g5g" and build in allowed_build_list:
        return True
    else:
        return False


def check_number_of_characters(word):
    total_length = 210
    return (total_length - (len(word) + 2)) // 2


def prepare_yaml_for_common_label(yaml, label):
    hook_str = '''
ute_ca_hooks:
  pre_sw_uploaded:
    package: "ute-ca-hook-common-label"
    entrypoint: "ute-ca-hook-common-label"
'''
    fill_template(yaml, "{LABEL}", label)
    fill_template("config.yaml", "{AUTHOR}", maintainer)
    try:
        with open("config.yaml", 'a') as common_yaml:
            common_yaml.write(hook_str)
        if verbose:
            print("ute_ca_hooks successfully added to config.yaml")
    except Exception as e:
        print(f"Error: {e}")


def check_if_ald(hostname):
    return True if hostname in tl_with_ald else False


def sinlge_label(tl):
    yaml = select_proper_yaml(tl[2])
    if verbose:
        print("\n" + "*" * 210 + "\n")
        print(f"label: {tl[1]}")
        print(f"test_line_hostname: {tl[0]}")
        print(f"test_line_type: {tl[2]}")
        print(f'yaml: {yaml}')
    test_line_label = check_label(tl[1])
    builds = check_scf_release(tl[0])
    make_dir(output_path + test_line_label)
    if copy_yaml:
        fill_template(yaml, "{LABEL}", test_line_label)
        fill_template("config.yaml", "{AUTHOR}", maintainer)
    for build in builds:
        if check_if_build_allowed(tl[2], build):
            if verbose:
                number_of_characters = check_number_of_characters(build)
                print("\n" + "-" * number_of_characters + f' {build} ' + '-' * number_of_characters + "\n")
            default_directory = output_path + test_line_label + "/" + build
            make_dir(default_directory)
            if copy_yaml:
                copy_file("./config.yaml", default_directory + "/config.yaml")
            if build == "DEFAULT":
                build_2 = f"SBTS{default_release}"
            else:
                build_2 = build
            scf_directory = \
                testline_configuration_repo_path + f"{tl[0]}/node1/" + f"BTS_{tl[1]}_{build_2}.xml"
            if copy_scf:
                copy_file(scf_directory, f"{default_directory}/node1.xml")
            if copy_swconfig:
                swconfig = "swconfig_ald.txt" if check_if_ald(tl[0]) else "swconfig.txt"
                print(f"{tl[0]}: {swconfig}")
                copy_file(swconfig, f"{default_directory}/swconfig.txt")


def label_4g5g(tl):
    yaml = select_proper_yaml(tl[2])
    if verbose:
        print("\n" + "*" * 210 + "\n")
        print(f"label: {tl[1]}")
        print(f"test_line_hostname: {tl[0]}")
        print(f"test_line_type: {tl[2]}")
        print(f'yaml: {yaml}')
    test_line_label = check_label(tl[1])
    builds = check_scf_release(tl[0])
    make_dir(output_path + test_line_label)
    if copy_yaml:
        fill_template(yaml, "{LABEL}", test_line_label)
        fill_template("config.yaml", "{AUTHOR}", maintainer)
    for build in builds:
        if check_if_build_allowed(tl[2], build):
            if verbose:
                number_of_characters = check_number_of_characters(build)
                print("\n" + "-" * number_of_characters + f' {build} ' + '-' * number_of_characters + "\n")
            default_directory = output_path + test_line_label + "/" + build
            make_dir(default_directory)
            if copy_yaml:
                copy_file("./config.yaml", default_directory + "/config.yaml")
            if build == "DEFAULT":
                build_2 = f"SBTS{default_release}"
            else:
                build_2 = build
            scf_directory = \
                testline_configuration_repo_path + f"{tl[0]}/node1/" + f"BTS_{tl[1]}_{build_2}.xml"
            node_2_scf_directory = \
                testline_configuration_repo_path + f"{tl[0]}/node2/" + f"BTS_{tl[1]}_{build_2}.xml"
            if copy_scf:
                copy_file(scf_directory, f"{default_directory}/node1.xml")
                copy_file(node_2_scf_directory, f"{default_directory}/node2.xml")
            if copy_swconfig:
                swconfig = "swconfig_ald.txt" if check_if_ald(tl[0]) else "swconfig.txt"
                print(f"{tl[0]}: {swconfig}")
                copy_file(swconfig, f"{default_directory}/swconfig.txt")


def label_4_3(tl):
    yaml = select_proper_yaml(tl[2])
    if verbose:
        print("\n" + "*" * 210 + "\n")
        print(f"label: {tl[1]}")
        print(f"test_line_hostname: {tl[0]}")
        print(f"test_line_type: {tl[2]}")
        print(f'yaml: {yaml}')
    test_line_label = check_label(tl[1])
    builds = check_scf_release(tl[0])
    make_dir(output_path + test_line_label)
    if copy_yaml:
        fill_template(yaml, "{LABEL}", test_line_label)
        fill_template("config.yaml", "{AUTHOR}", maintainer)
    for build in builds:
        if check_if_build_allowed(tl[2], build):
            if verbose:
                number_of_characters = check_number_of_characters(build)
                print("\n" + "-" * number_of_characters + f' {build} ' + '-' * number_of_characters + "\n")
            default_directory = output_path + test_line_label + "/" + build
            make_dir(default_directory)
            if copy_yaml:
                copy_file("./config.yaml", default_directory + "/config.yaml")
            if build == "DEFAULT":
                build_2 = f"SBTS{default_release}"
            else:
                build_2 = build
            scf_directory = \
                testline_configuration_repo_path + f"{tl[0]}/node1/" + f"BTS_{tl[1]}_{build_2}.xml"
            if copy_scf:
                copy_file(scf_directory, f"{default_directory}/node1.xml")
            if copy_swconfig:
                swconfig = "swconfig_ald.txt" if check_if_ald(tl[0]) else "swconfig.txt"
                swconfig_secondary = "swconfig_secondary_ald.txt" if check_if_ald(tl[0]) else "swconfig_secondary.txt"
                print(f"{tl[0]}: {swconfig}")
                print(f"{tl[0]}: {swconfig_secondary}")
                copy_file(swconfig, f"{default_directory}/swconfig.txt")
                copy_file(swconfig_secondary, f"{default_directory}/swconfig_secondary.txt")


def fullrack_label(tl):
    yaml = select_proper_yaml(tl[2])
    if verbose:
        print("\n" + "*" * 210 + "\n")
        print(f"label: {tl[1]}")
        print(f"test_line_hostname: {tl[0]}")
        print(f"test_line_type: {tl[2]}")
        print(f'yaml: {yaml}')
    test_line_label = check_label(tl[1])
    builds = check_scf_release(tl[0])
    make_dir(output_path + test_line_label)
    if copy_yaml:
        fill_template(yaml, "{LABEL}", test_line_label)
        fill_template("config.yaml", "{AUTHOR}", maintainer)
    for build in builds:
        if check_if_build_allowed(tl[2], build):
            if verbose:
                number_of_characters = check_number_of_characters(build)
                print("\n" + "-" * number_of_characters + f' {build} ' + '-' * number_of_characters + "\n")
            default_directory = output_path + test_line_label + "/" + build
            make_dir(default_directory)
            if copy_yaml:
                copy_file("./config.yaml", default_directory + "/config.yaml")
            if build == "DEFAULT":
                build_2 = f"SBTS{default_release}"
            else:
                build_2 = build
            scf_directory = \
                testline_configuration_repo_path + f"{tl[0]}/node1/" + f"BTS_{tl[1]}_{build_2}.xml"
            if copy_scf:
                copy_file(scf_directory, f"{default_directory}/node1.xml")
            if copy_swconfig:
                swconfig = "swconfig_ald.txt" if check_if_ald(tl[0]) else "swconfig.txt"
                swconfig_secondary = "swconfig_secondary_ald.txt" if check_if_ald(tl[0]) else "swconfig_secondary.txt"
                print(f"{tl[0]}: {swconfig}")
                print(f"{tl[0]}: {swconfig_secondary}")
                copy_file(swconfig, f"{default_directory}/swconfig.txt")
                copy_file(swconfig_secondary, f"{default_directory}/swconfig_secondary.txt")


def common_label(tl):
    test_lines_hostname_list = tl[0]
    test_lines_label = check_label(tl[1])
    test_lines_type = check_tl_type(test_lines_hostname_list[0])
    yaml = select_proper_yaml(test_lines_type)
    if verbose:
        print("\n" + "*" * 210 + "\n")
        print(f"label: {test_lines_label}")
        print(f'test_lines_hostname_list: {test_lines_hostname_list}')
        print(f'test_lines_type: {test_lines_type}')
        print(f'yaml: {yaml}')
    builds = check_scf_release(test_lines_hostname_list[0])
    make_dir(output_path + test_lines_label)
    if copy_yaml:
        prepare_yaml_for_common_label(yaml, test_lines_label)
    for build in builds:
        if check_if_build_allowed(test_lines_type, build):
            if verbose:
                number_of_characters = check_number_of_characters(build)
                print("\n" + "-" * number_of_characters + f' {build} ' + '-' * number_of_characters + "\n")
            default_directory = output_path + test_lines_label + "/" + build
            make_dir(default_directory)
            if copy_yaml:
                copy_file("./config.yaml", default_directory + "/config.yaml")
            for hostname in test_lines_hostname_list:
                hostname_directory = default_directory + "/" + hostname
                make_dir(hostname_directory)
                hostname_label = test_lines.tl_dict[hostname]["topology"]
                if build == "DEFAULT":
                    build_2 = f"SBTS{default_release}"
                else:
                    build_2 = build
                scf_directory = \
                    testline_configuration_repo_path + f"{hostname}/node1/" + f"BTS_{hostname_label}_{build_2}.xml"
                if copy_scf:
                    copy_file(scf_directory, f"{hostname_directory}/node1.xml")
                if test_lines_type == "4g5g":
                    node_2_scf_directory = \
                        testline_configuration_repo_path + f"{hostname}/node2/" + f"BTS_{hostname_label}_{build_2}.xml"
                    if copy_scf:
                        copy_file(node_2_scf_directory, f"{hostname_directory}/node2.xml")
                if copy_swconfig:
                    swconfig = "swconfig_ald.txt" if check_if_ald(hostname) else "swconfig.txt"
                    print(f"{hostname}: {swconfig}")
                    copy_file(swconfig, f"{hostname_directory}/swconfig.txt")
                if test_lines_type == "fullrack" or test_lines_type == "4+3":
                    if copy_swconfig:
                        conf_sec = "swconfig_secondary_ald.txt" if check_if_ald(hostname) else "swconfig_secondary.txt"
                        print(f"{hostname}: {conf_sec}")
                        copy_file(conf_sec, f"{hostname_directory}/swconfig.txt")


def fill_template(filepath, pattern, label):
    if verbose:
        print("MODIFYyyyy: " + filepath + " TO " + "config.yaml")
    filet = open(filepath, 'r')
    filedata = filet.read()
    filet.close()

    newdata = filedata.replace(pattern, label)

    filet = open("config.yaml", 'w')
    filet.write(newdata)
    filet.close()


def migrate_to_the_future(testlines_list):
    for testline in testlines_list:
        if testline[2] == "single":
            sinlge_label(testline)
        if testline[2] == "fullrack":
            fullrack_label(testline)
        if testline[2] == "common":
            common_label(testline)
        if testline[2] == "4g5g":
            label_4g5g(testline)
        if testline[2] == "4+3":
            label_4_3(testline)
        if os.path.isfile("./config.yaml"):
            os.remove("./config.yaml")


if __name__ == '__main__':
    migrate_to_the_future(testlines)
