NOKIA_LOGIN = "toor4nsn"
NOKIA_PASS = "oZPS0POrRieRtu"
GNB_IP = "192.168.255.129"
AP_IP = "192.168.200.1"
IPHY_DIR_PATH = "/opt/iphy"
EPCSIM_DIR_PATH = "{}/latest".format(IPHY_DIR_PATH)

CONFIG_FILE_WTS = "config_multiple_AMF_UPF.cfg"

SW_CONFIG_ADDITIONAL = {
    '0x10041': 5,  # ERadCcs_AaSysLogOutputMode - UDP logging enabled
    '0x1003F': 1,  # AaSysLogInputLevel
    '0x10040': 1,  # AaSysLogOutputLevel
    '0x590072': 1,  # CP-RT log level
    '0x41001b': 1,  # CP-NRT log level
}
