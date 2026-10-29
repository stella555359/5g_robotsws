import yaml
import json
file_for_testline_type = "/opt/ute/reservation.json"
file_testconfig_yaml = ""
# file_for_testline_type="./reservation.json"


def get_testline_type():
    fh = open(file_for_testline_type)
    data = fh.read()
    print(data)
    data1 = json.loads(data)
    return data1["topology"]


def download_testconfig_repository():
    pass


def find_config_file_in_testconfig_repository(file_name, testline_type):
    f = open(file_name)
    data = yaml.load_all(f, Loader=yaml.FullLoader)
    print(type(data))
    gNB_swconfig = 0
    gNB_DU_scf = 0
    AP_swconfig = 0
    AP_iphy_xml = 0
    WTS_config = 0
    for i in data:
        for j in i["configs"]:
            name = j["name"]
            # print("name={},testline_type={}".format(name, testline_type))
            if testline_type == "CLOUD_5G_I_BOO_AP_LOO":
                testline_type = "CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD"
            # print("name2={},testline_type2={}".format(name,testline_type))
            if name == testline_type:
                # print(name)
                path = j["paths"]
                # print(path)
                gNB_swconfig = path["gNB_swconfig"]
                print("gNB_swconfig={}".format(gNB_swconfig))
                gNB_DU_scf = path["gNB_DU_scf"]
                print("gNB_DU_scf={}".format(gNB_DU_scf))
                AP_swconfig = path["AP_swconfig"]
                print("AP_swconfig={}".format(AP_swconfig))
                AP_iphy_xml = path["AP_iphy_xml"]
                print("AP_iphy_xml={}".format(AP_iphy_xml))
                WTS_config = path["WTS_config"]
                print("WTS_config={}".format(WTS_config))
    return gNB_swconfig, gNB_DU_scf, AP_swconfig, AP_iphy_xml, WTS_config


def find_config_file_by_testline_type(file_testconfig_yaml):
    testline_type = get_testline_type()
    print("testline_type={}".format(testline_type))
    gNB_swconfig, gNB_DU_scf, AP_swconfig, AP_iphy_xml, WTS_config = find_config_file_in_testconfig_repository(
        file_testconfig_yaml, testline_type)
    return gNB_swconfig, gNB_DU_scf, AP_swconfig, AP_iphy_xml, WTS_config, testline_type


if __name__ == "__main__":
    find_config_file_by_testline_type(file_testconfig_yaml)
