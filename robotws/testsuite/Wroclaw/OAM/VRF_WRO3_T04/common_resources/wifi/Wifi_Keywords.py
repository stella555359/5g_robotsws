import json
from robot.api import logger


def get_testpc_address(bts_id: str) -> str:
    if bts_id == '51097':
        path_to_json_file = 'testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB013432/Resources/CB013432_settings.json'
    else:
        path_to_json_file = 'testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB009233/Resources/CB009233_settings.json'
    with open(path_to_json_file, "r") as settings:
        data = json.load(settings)
        return data["BTS"][str(bts_id)]["TestPC"]["address"]


def get_testpc_username(bts_id: str) -> str:
    if bts_id == '51097':
        path_to_json_file = 'testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB013432/Resources/CB013432_settings.json'
    else:
        path_to_json_file = 'testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB009233/Resources/CB009233_settings.json'
    with open(path_to_json_file, "r") as settings:
        data = json.load(settings)
        return data["BTS"][str(bts_id)]["TestPC"]["username"]


def get_testpc_password(bts_id: str) -> str:
    if bts_id == '51097':
        path_to_json_file = 'testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB013432/Resources/CB013432_settings.json'
    else:
        path_to_json_file = 'testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/CB009233/Resources/CB009233_settings.json'
    with open(path_to_json_file, "r") as settings:
        data = json.load(settings)
        return data["BTS"][str(bts_id)]["TestPC"]["password"]


def get_testpc_address_and_credentials(bts_id: str) -> dict:
    return {"address": get_testpc_address(bts_id),
            "username": get_testpc_username(bts_id),
            "password": get_testpc_password(bts_id)}


# def get_wifi_network_interface(path_to_json_file, bts_id: str) -> str:
#     with open(path_to_json_file, "r") as settings:
#         data = json.load(settings)
#         return data["BTS"][str(bts_id)]["Wi-Fi"]["network_interface"]
#
#
# def get_wifi_wpa2_psk_ssid(path_to_json_file, bts_id: str) -> str:
#     with open(path_to_json_file, "r") as settings:
#         data = json.load(settings)
#         return data["BTS"][str(bts_id)]["Wi-Fi"]["WPA2_PSK_SSID"]
#
#
# def get_wifi_wpa3_sae_ssid(path_to_json_file, bts_id: str) -> str:
#     with open(path_to_json_file, "r") as settings:
#         data = json.load(settings)
#         return data["BTS"][str(bts_id)]["Wi-Fi"]["WPA3_SAE_SSID"]


# def get_wifi_wpa_psk_ssid(path_to_json_file, bts_id: str) -> str:
#     with open(path_to_json_file, "r") as settings:
#         data = json.load(settings)
#         return data["BTS"][str(bts_id)]["Wi-Fi"]["WPA2_PSK_SSID"]


def get_factory_user_password(path_to_json_file, bts_id: str, username: str) -> str:
    with open(path_to_json_file, "r") as settings:
        data = json.load(settings)
        return data["BTS"][str(bts_id)]["Users_Credentials"][str(username)]["password"]


def get_all_ssids(path_to_json_file, bts_id: str) -> str:
    with open(path_to_json_file, "r") as settings:
        data = json.load(settings)
    return data["BTS"][str(bts_id)]["Wi-Fi"]["ssids"]


def get_mfpc_mpfr_values(path_to_json_file, bts_id: str, ssid: str) -> dict:
    with open(path_to_json_file, "r") as settings:
        data = json.load(settings)
    return {"mfpr": data["BTS"][str(bts_id)]["Wi-Fi"][str(ssid)]["mfpr"],
            "mfpc": data["BTS"][str(bts_id)]["Wi-Fi"][str(ssid)]["mfpc"]}


def get_too_long_password(path_to_json_file, authentication_type: str):
    with open(path_to_json_file, "r") as settings:
        data = json.load(settings)
    return data["Passwords"][str(authentication_type)]["too_long"]


def trim(string: str):
    return string.split()


def add_user_data_structure(auth_type: str,
                            mac_addr_qualifier: str,
                            passphrase: str,
                            user_label: str,
                            wpa3_sae_pwid_qualifier: str):
    prefix_user_data = [
        '        <item>\n'
    ]

    user_data = [
        f'          <p name="configuredAuthType">{auth_type}</p>\n'
        if auth_type != "" else '          <p name="configuredAuthType" />\n',
        f'          <p name="configuredMacAddrQualifier">{mac_addr_qualifier}</p>\n'
        if mac_addr_qualifier != "" else '          <p name="configuredMacAddrQualifier" />\n',
        f'          <p name="configuredPassphrase">{passphrase}</p>\n'
        if passphrase != "" else '          <p name="configuredPassphrase" />\n',
        f'          <p name="configuredUserLabel">{user_label}</p>\n'
        if user_label != "" else '          <p name="configuredUserLabel" />\n',
        f'          <p name="configuredWpa3SaePwidQualifier">{wpa3_sae_pwid_qualifier}</p>\n'
        if wpa3_sae_pwid_qualifier != "" else '          <p name="configuredWpa3SaePwidQualifier" />\n',
    ]

    suffix_user_data = [
        '        </item>\n'
    ]
    return prefix_user_data + user_data + suffix_user_data


def generate_new_user_xml(output_filepath,
                          auth_type: str = "WPA2-PSK",
                          mac_addr_qualifier: str = "",
                          passphrase: str = "userName1!dddddddddd",
                          user_label: str = "user1",
                          wpa3_sae_pwid_qualifier: str = ""):
    # only for PEP8 (max 120 chars in line)
    class_attrib = 'class="SSDWIFILMP"'
    distName_attrib = 'distName="SSD-1/SSDWIFILMP-1"'
    version_attrib = 'version="SSD22R1_2106_100"'
    operation_attrib = 'operation="create"'

    prefix_mandatory_lines = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n',
        '<raml xmlns="raml21.xsd" version="2.1">\n',
        '  <cmData type="plan" scope="all" id="3546609151">\n',
        '    <header>\n',
        '      <log action="create" dateTime="2021-06-21T07:35:08.022Z" />\n',
        '    </header>\n',
        '    <managedObject {} {} {} {}>\n'.format(class_attrib, distName_attrib, version_attrib, operation_attrib),
        '      <list name="configuredUserList">\n'
    ]

    user_data = add_user_data_structure(auth_type,
                                        mac_addr_qualifier,
                                        passphrase,
                                        user_label,
                                        wpa3_sae_pwid_qualifier)

    suffix_mandatory_lines = [
        '      </list>\n',
        '    </managedObject>\n',
        '  </cmData>\n',
        '</raml>\n'
    ]
    with open(output_filepath, "w") as file:
        file.writelines(prefix_mandatory_lines + user_data + suffix_mandatory_lines)
    return output_filepath
