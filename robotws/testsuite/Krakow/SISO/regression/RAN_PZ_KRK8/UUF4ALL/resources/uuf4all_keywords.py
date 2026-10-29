def convert_trunk_sw_version(sw_version):
    if "9999" in str(sw_version):
        if "00" not in str(sw_version).split('_')[0]:
            return str(sw_version)[:4] + "00" + str(sw_version)[8:]
    return sw_version
