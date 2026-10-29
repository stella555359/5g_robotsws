import os
import re
import shutil

# author: tomasz.szylkowski@nokia.com

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

# path where output files will be created, end it with slash
output_path = "C:/Users/szylkows/Desktop/REPO/topology-configs/"

# path to local repo with testline-configuration, end it with slash
testline_configuration_repo_path = "C:/Users/szylkows/Desktop/REPO/testline_configuration/"

# allowed builds for single nodes and fullracks
allowed_build_list = ['20C', '21A', '21B', '22R1', '22R2', '22R3', '22R4', '23R1', '23R2', '23R3', '00']

# allowed builds for RFS testlines, as of ver 0.1b there is only support for common builds so no 5G21A and such
# to my knowledge ute-ca does not support old 5g builds
allowed_build_list_5g = ['21B', '22R1', '22R2', '22R3', '22R4', '23R1', '23R2', '23R3', '00']

# suffix for labels - in our team we added _UTECA to label to distinguish which labels work with new agent
label_suffix = ""

# maintainer email to be put in yaml file
maintainer = "tomasz.szylkowski@nokia.com"

# table with testlines to migrate
# hostname, label, type
# hostname - is important because script will search for proper name in testline-configuration repo
# label - is necessary because in ute-ca you define topologies based on label
# type - ranges in "4g5g" / "single" / "fullrack" - selection defines which yaml file is taken
#        also, if 4g5g will get scfs also for node1, although fullracks in old agent hand node 2
#        it will not be merged
testlines = [
    # ["1_16_UTESRAN2201", "CLOUD_SRAN_NLWG_2ASIL_2ABIO_1ABIN_1ABIL_1ABIA_2FXEF_1AQQK_1AHFII_2FXCA_3AHEH", "fullrack"],
    # ["1_16_UTESRAN2203", "CLOUD_SRAN_NLWG_2ASIL_2ABIO_1ABIN_1ABIL_1ABIA_2FRGY_1AQQK_1AHFII_2FXCA_3AHCA", "fullrack"],
    # ["1_16_UTESRAN3209", "CLOUD_SRAN_NL_1ASIL_1ABIO_1ABIN_1ABIA_2FXEB_2FRMA_2FRGU", "single"],
    # ["1_16_UTESRAN3208", "CLOUD_SRAN_NL_1ASIL_1ABIO_1ABIN_1ABIA_2FRGT_2FRHB_2FXED", "single"],
    # ["1_16_UTESRAN2198", "CLOUD_SRAN_NLG_2ASIL_ABIA_4ABIO_3AHLOB_3AHFII_3AEHC", "fullrack"],
    # ["1_16_UTESRAN3222", "CLOUD_SRAN_NL_1ASIL_1ABIO_1ABIN_1ABIA_3FRIG_3FRLB_3FRIJ", "single"],
    # ["1_16_UTESRAN3684", "CLOUD_SRAN_NL_2ASIM_1ABIA_1ABIN_1ABIO_1AHFB_1AHLOA_1AZHL_1FXDA", "fullrack"],
    # ["1_16_UTESRAN2018", "CLOUD_SRAN_NL_1ASIL_1ABIO_3AZHL", "single"],
    # ["1_16_UTESRAN3889", "CLOUD_SRAN_LG_2ASIA_4ABIA_1AHFIB_1AHIB_1AZNA_2FHDB_1FRGU_1FXED", "fullrack"],
    # ["1_16_CLOUD3893", "CLOUD_AIBR_B4_B6_2AAHF_AZHA", "single"],
    # ["1_16_UTESRAN3833", "CLOUD_RFS_AIBL_B1_B3_ASIKR_B4_FRGU", "4g5g"],
    # ["1_16_UTESRAN3755", "CLOUD_SRAN_LWG_1ASIB_3ABIA_1FSMF_1FRIE_1FRIJ_1FXFC_2FRBG", "fullrack"],
    # ["1_16_UTESRAN3000", "CLOUD_RFS_AIL_B1_B2_ASILR_B4_B5_3AHBCC_3AHFIC_3AQQK", "4g5g"],
    # ["1_16_UTESRAN2046", "CLOUD_RF_AIR_B4_B6_2AHIB_2AHFB_2AZRB", "single"],
    # ["1_16_UTESRAN2042", "CLOUD_SRAN_NL_1ASIB_1ABIO_2ABIN_1AHFIB_1AZNA", "single"],
    # ["1_16_UTESRAN2041", "CLOUD_SRAN_NL_1ASOE_3AHCA", "single"],
    # ["1_16_CLOUD2181", "CLOUD_RF_AIBLR_B1_B4_AHCA_AZNA", "fullrack"],
    # ["1_16_UTESRAN3616", "CLOUD_RFS_AIBR_B4_B5_ASILL_B1_AHPD_AHEGB_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2045", "CLOUD_RFS_AIBR_B4_B5_AIBL_B1_B2_B3_6AHBCC_UUF_1", "4g5g"],
    # ["1_16_UTESRAN3873", "CLOUD_RF_AIBL_B1_3AHPF_UUF_1", "single"],
    # ["1_16_UTESRAN2091", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_4", "4g5g"],
    # ["1_16_UTESRAN2096", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_3", "4g5g"],
    # ["1_16_UTESRAN3606", "CLOUD_RFS_AIBR_B5_ASIKL_B1_3AHBCA_UUF_1", "4g5g"],
    # ["1_16_UTESRAN3765", "CLOUD_RFS_AIR_B4_B5_ASIKL_B1_B2_B3_3AHCA_3AHFIC", "4g5g"],
    # ["1_16_UTESRAN2095", "CLOUD_RFS_AIBR_B4_ASIKL_B1_3AHLOA_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2034", "CLOUD_RFS_AIR_B4_B5_ASIKL_B1_B2_3xUHIE_3xUHFA_2xAHFIA", "4g5g"],
    # ["1_16_UTESRAN3600", "CLOUD_RFS_AIBR_B4_B5_ASIKL_B1_B2_B3_3AHFIB_3UHLC_UUF_1", "4g5g"],
    # ["1_16_UTESRAN3763", "CLOUD_RFS_AIR_B4_AIBL_B1_B2_3AHLOA_1FRIG_UUF_1", "4g5g"],
    # ["1_16_UTESRAN3760", "CLOUD_RFS_AIR_B4_B5_B6_ASIKL_B1_3AHLOA_3FRLB_3FRIG_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2093", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_2", "4g5g"],
    # ["1_16_UTESRAN3688", "CLOUD_RFS_AIR_B4_B6_ASIKL_B1_3AHFIG_3AHLOA_3FRIG_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2097", "CLOUD_RF_ASIKLR_B1_B4_3AHLOA_UUF_2", "4g5g"],
    # ["1_16_UTESRAN2090", "CLOUD_RFS_AIBR_B4_AIBL_B1_3AHLOA_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2039", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHNA_1", "4g5g"],
    # ["1_16_UTE4G2171", "CLOUD_RF_AILR_B1_B5_AHHB_FRGU_UHNA_UHFA", "fullrack"],
    # ["1_16_UTESRAN2092", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_1", "4g5g"],
    # ["1_16_UTESRAN2089", "CLOUD_SRAN_NLWG_2ASIL_1ABIA_4ABIO_3AEHC_3AHFIB_3AHLOA", "fullrack"],
    # ["1_16_UTESRAN2031", "CLOUD_SRAN_NL_2ASIB_2ABIO_3AHEH_1AZQP", "fullrack"],
    # ["1_16_UTESRAN2088", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHFIG", "4g5g"],
    # ["1_16_UTESRAN3881", "CLOUD_RFS_AIBL_B1_ASIK_B4_FRPD_FRHF_FXED", "4g5g"],
    # ["10_16_CLOUD3716", "CLOUD_RF_AILR_B1_B5_AAHF_AAHC_mMIMO", "fullrack"],
    # ["1_16_UTE4G3851", "CLOUD_RF_FC_FRMF_FXEB_FRGT", "single"],
    # ["10_16_CLOUD3846", "CLOUD_RF_AIBR_B1_AZQP", "single"],
    # ["1_16_CLOUD2009", "CLOUD_RF_AIR_B4_3AZNA", "single"],
    # ["1_16_UTESRAN2085", "CLOUD_RFS_AIBL_B1_B3_ASIKR_B4_B6_3AAHF", "4g5g"],
    # ["1_16_UTESRAN2083", "CLOUD_RFS_AIBL_B1_B3_ASIKR_B4_B6_3AEHC", "4g5g"],
    # ["1_16_UTESRAN3645", "CLOUD_RFS_AIBR_B4_B5_ASIKL_B1_B2_3AHPMDA_2FXED_FRMC_AREA", "4g5g"],
    # ["1_16_UTESRAN3754", "CLOUD_SRAN_L_1FSIH_2FBIH_1FZHN", "single"],
    # ["1_16_CLOUD3683", "CLOUD_RF_AIL_B1_B2_B3_2FZFF-e", "single"],
    # ["1_16_UTESRAN3689", "CLOUD_SRAN_L_1FSIH_2FBIH_1AZNA", "single"],
    # ["1_16_CLOUD3687", "CLOUD_RF_F_AZNA", "single"],
    # ["1_16_UTESRAN3875", "CLOUD_SRAN_NLWG_1ASIL_1ABIA_1ABIN_1ABIO_1AHFIB_1FXCB", "single"],
    # ["1_16_UTESRAN3874", "CLOUD_SRAN_LWG_1FSMF_2FBBC_1FXJB_2FXEF_1FRGU", "single"],
    # ["1_16_UTESRAN3857", "CLOUD_SRAN_LWG_2ASIA_5ABIA_3AHPMDA_3AHHB_3AHEGB", "fullrack"],
    # ["1_16_UTESRAN3838", "CLOUD_SRAN_LW_2ASIA_2ABIA_6AHEGA", "fullrack"],
    # ["1_16_UTESRAN1279", "CLOUD_SRAN_L_2ASIA_4ABIA_3AAIB_3AAFB_3AHLOA", "fullrack"],
    # ["1_16_UTESRAN3840", "CLOUD_SRAN_LWG_2FSMF_2FBBC_1FXDB_1FRGU_1FXED_1FRMF", "fullrack"],
    # ["1_16_UTESRAN3761", "CLOUD_RFS_AIR_B4_ASIKL_B1_AHLOA", "4g5g"],
    # ["1_16_CLOUD3773", "CLOUD_RF_AIL_B1_B3_AIR_B4_B5_2AHFIC_2AHFIA_4AZRB", "fullrack"],
    # ["1_16_CLOUD3770", "CLOUD_RF_AIL_B1_FRMC_FXED_ARGA", "single"],
    # ["1_16_CLOUDGTA3817", "CLOUD_RF_AIL_B1_B2_3AHFIB_3AHBCA", "single"],
    # ["1_16_UTESRAN3742", "CLOUD_SRAN_L_1FSIH_2FBIH_1FZNI", "single"],
    # ["1_16_CLOUDGTA3814", "CLOUD_RF_AIL_B1_B2_3AZQC", "single"],
    # ["1_16_CLOUD3884", "CLOUD_RF_F_2FXEA_UUF", "single"],
    # ["1_16_UTESRAN3885", "CLOUD_SRAN_NL_1ASIL_2ABIO_3AHFIB", "single"],
    # ["1_16_CLOUD3731", "CLOUD_RF_AIL_B1_3FRBI", "single"],
    # ["1_16_CLOUD3734", "CLOUD_RF_FA_3FHEB_3FHDB", "single"],
    # ["1_16_CLOUD3726", "CLOUD_RF_FC_3FHFB", "single"],
    # ["1_16_CLOUD3728", "CLOUD_RF_AIBR_B1_FXFC", "single"],
    # ["1_16_CLOUD3848", "CLOUD_SRAN_NLWG_2ASIL_2ABIA_1ABIN_1ABIO_1AHCA_1AHFIB_1AZNA_1FXEB", "fullrack"],
    # ["1_16_UTESRAN3850", "CLOUD_SRAN_NL_1ASIL_1ABIO_3AZNA", "single"],
    # ["1_16_CLOUD3844", "CLOUD_RF_FCC_FRIJ_FHEA_FHDB", "single"],
    # ["1_16_UTESRAN3845", "CLOUD_SRAN_NL_1ASIL_3ABIO_3AHIB_3AHLOA_3AHPMDA", "single"],
    # ["1_16_CLOUD3847", "CLOUD_RF_FC_2FXEB_FRMC", "single"],
    # ["1_16_CLOUD1280", "CLOUD_RF_AIBL_B1_B2_FRMC_FXED", "single"],
    # ["1_16_CLOUD1278", "CLOUD_RF_FCC_FRHC_2FXEA", "single"],
    # ["1_16_CLOUD1235", "CLOUD_RF_FC_FZNI", "single"],
    # ["1_16_CLOUD3697", "CLOUD_RF_AIBL_B1_B2_B3_2xFXEB_FRMF_FRHF_UUF", "single"],
    # ["1_16_UTESRAN3634", "CLOUD_SRAN_L_1ASIB_3ABIA_3AAIB_3AAFB", "single"],
    # ["1_16_UTESRAN3212", "CLOUD_SRAN_L_1FSMF_1FBBC_1FBBA_1FXDB_1FXCC_1FXED_UUF_1", "single"],
    # ["1_16_UTESRAN3213", "CLOUD_SRAN_L_1FSMF_1FBBC_1FBBA_1FXDB_1FXCC_1FXED_UUF_2", "single"],
    # ["1_16_UTESRAN3214", "CLOUD_SRAN_L_1FSMF_1FBBC_1FBBA_1FXDB_1FXCC_1FXED_UUF_3", "single"],
    # ["1_16_UTESRAN2029", "CLOUD_SRAN_NL_1ASIB_1ABIA_1ASIK_1ABIL_3FRHG", "4g5g"],
    # ["1_16_UTESRAN2038", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIB_1ABIL_1ABIO_1AZQO_1AZQP", "4g5g"],
    # ["1_16_UTESRAN2205", "CLOUD_SRAN_NLWG_2ASIL_2ABIO_1ABIN_1ABIL_1ABIA_1FRGY_1FXEF_1AQQK_1AHFII_2FXCA_3AHPE",
    #  "fullrack"],
    # ["1_16_UTESRAN3227", "CLOUD_SRAN_N_2ASIK_3ABIL_1AEHC_1AHLOA_1AHFIG_UUF_3_UTECA", "fullrack"], # nutec
    # ["1_16_UTESRAN3225", "CLOUD_SRAN_N_2ASIK_3ABIL_1AEHC_1AHLOA_1AHFIG_UUF_2_UTECA", "fullrack"], # nutec
    # ["1_16_UTESRAN3223", "CLOUD_SRAN_N_2ASIK_3ABIL_1AEHC_1AHLOA_1AHFIG_UUF_1_UTECA", "fullrack"], # nutec
    # ["1_16_UTESRAN3200", "CLOUD_SRAN_NLWG_2ASIL_1ABIA_2ABIO_3ABIP_1AZHL_1AHLOA_1AHFB_1FXCB_1FRCG", "fullrack"],
    # nutec
    ["1_16_UTESRAN3234", "CLOUD_SRAN_LG_1ASIA_1ABIA_1FSMF_1AHFIB_1FRHB_1FXDB_UUF_2_UTECA", "fullrack"],  # nutec
    ["1_16_UTESRAN3236", "CLOUD_SRAN_LG_1ASIB_1ABIA_1FSMF_1AHFIB_1FRHB_1FXDB_UUF_1_UTECA", "fullrack"],  # nutec
    ["1_16_UTESRAN3238", "CLOUD_SRAN_LG_1ASIB_1ABIA_1FSMF_1AHFIB_1FRHB_1FXDB_UUF_2_UTECA", "fullrack"],  # nutec
    # ["1_16_UTESRAN3206", "CLOUD_SRAN_N_1ASOE_3AQQJ_2AHPB_UTECA", "single"],  # nutec
    # ["1_16_UTESRAN3202", "CLOUD_SRAN_N_1ASOE_3AEQZ_2AHPB_UTECA", "single"],  # nutec
    # ["1_16_UTESRAN3607", "CLOUD_RF_AO_3AHPB_3AQQJ_UTECA", "single"],  # nutec
    # ["1_16_UTESRAN3215", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIB_1ABIL_1ABIO_1AZQP_1AZQS", "4g5g"],
    # ["1_16_UTESRAN3216", "CLOUD_SRAN_NL_1ASIB_1ABIN_1ASIB_1ABIL_1ABIO_1AZQO_1AZQS", "4g5g"],
    # ["1_16_UTESRAN3801", "CLOUD_RF_AIBR_AILR_AIKLR_MONSTER_UUF", "special"],
    # ["1_16_UTESRAN3735", "CLOUD_SRAN_NLG_1ASIA_3ABIA_1FSMF_1ASIK_2ABIL_4AHLOA_4AHFIB_KRAKEN_UUF", "special"],

]

skipped_files = []


def make_dir(path):
    if not os.path.exists(path):
        if verbose:
            print("MKDIR: " + path)
        os.mkdir(path)


def copy_file(src, dest):
    if verbose:
        print("COPYING: " + src + " TO " + dest)
    shutil.copyfile(src, dest)


def fill_template(filepath, pattern, label):
    if verbose:
        print("MODIFY: " + filepath + " TO " + "config.yaml")
    filet = open(filepath, 'r')
    filedata = filet.read()
    filet.close()

    newdata = filedata.replace(pattern, label)

    filet = open("config.yaml", 'w')
    filet.write(newdata)
    filet.close()


for testline in testlines:
    if testline[2] != "special":
        make_dir(output_path + testline[1] + label_suffix)
        testline_configuration_directory = testline_configuration_repo_path + testline[0]
        directory = None
        try:
            directory = [f for f in os.listdir(testline_configuration_directory + "/node1/")
                         if os.path.isfile(os.path.join(testline_configuration_directory + "/node1/", f))]
            if verbose:
                print("*** TESTLINE: " + testline[0] + " ***")
            if verbose:
                print("DETECTED: ", directory)
        except Exception as e:
            print(e)
            input("Press Enter to continue...")
        for scf in directory:
            build = re.search('SBTS(.+?).xml', scf)
            if build and testline[1] in scf:
                if verbose:
                    print("DIRECTORY: SBTS" + build.group(1))
                if (testline[2] == "4g5g" and build.group(1) in allowed_build_list_5g) or \
                        (testline[2] != "4g5g" and build.group(1) in allowed_build_list):
                    build_directory = output_path + testline[1] + label_suffix + "/SBTS" + build.group(1)
                    if build.group(1) == "00":
                        # create default dir with sbts00 files
                        default_directory = output_path + testline[1] + label_suffix + "/DEFAULT"
                        make_dir(default_directory)
                        copy_file(testline_configuration_directory + "/node1/" + scf, default_directory + "/node1.xml")
                        copy_file("./swconfig.txt", default_directory + "/swconfig.txt")
                        if testline[2] == "fullrack":
                            fill_template("config_fr.yaml", "{LABEL}", testline[1] + label_suffix)
                            fill_template("config.yaml", "{AUTHOR}", maintainer)
                            copy_file("./config.yaml", default_directory + "/config.yaml")
                            copy_file("./swconfig_secondary.txt", default_directory + "/swconfig_secondary.txt")
                        elif testline[2] == "4g5g":
                            fill_template("config_4g5g.yaml", "{LABEL}", testline[1] + label_suffix)
                            fill_template("config.yaml", "{AUTHOR}", maintainer)
                            copy_file("./config.yaml", default_directory + "/config.yaml")
                            copy_file(testline_configuration_directory + "/node2/" + scf,
                                      default_directory + "/node2.xml")
                        else:
                            fill_template("config_single.yaml", "{LABEL}", testline[1] + label_suffix)
                            fill_template("config.yaml", "{AUTHOR}", maintainer)
                            copy_file("./config.yaml", default_directory + "/config.yaml")
                    make_dir(build_directory)
                    copy_file(testline_configuration_directory + "/node1/" + scf, build_directory + "/node1.xml")
                    copy_file("./swconfig.txt", build_directory + "/swconfig.txt")
                    if testline[2] == "fullrack":
                        fill_template("config_fr.yaml", "{LABEL}", testline[1] + label_suffix)
                        fill_template("config.yaml", "{AUTHOR}", maintainer)
                        copy_file("./config.yaml", build_directory + "/config.yaml")
                        copy_file("./swconfig_secondary.txt", build_directory + "/swconfig_secondary.txt")
                    elif testline[2] == "4g5g":
                        fill_template("config_4g5g.yaml", "{LABEL}", testline[1] + label_suffix)
                        fill_template("config.yaml", "{AUTHOR}", maintainer)
                        copy_file("./config.yaml", build_directory + "/config.yaml")
                        copy_file(testline_configuration_directory + "/node2/" + scf, build_directory + "/node2.xml")
                    else:
                        fill_template("config_single.yaml", "{LABEL}", testline[1] + label_suffix)
                        fill_template("config.yaml", "{AUTHOR}", maintainer)
                        copy_file("./config.yaml", build_directory + "/config.yaml")
            else:
                skipped_files.append(scf)
    if os.path.isfile("./config.yaml"):
        os.remove("./config.yaml")
    if skipped_files:
        print("Skipped files: ")
        for file in skipped_files:
            print(file)
