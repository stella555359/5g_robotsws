"""
Authors:
maciej.ferus@nokia.com
"""

from netact_logs_collector_imp import NetActLogsCollector
import zipfile


def get_netact_list():
    """
    Method mean to store data of all known netact.
    Arguments:
        - netact_name: netact name which can be derived from netact address.
        - password: Password used to login into node
                    Currently user is hardcoded in robot library
        - node_ip: Chosen IP Node of specific netact.
        - password: password to netact
        - btsmed: btsmeds in list
            - releases: releases on which test can be run (put FLAT in if FLAT is needed)
            - virtual_south: Virtual South of BTSMED-X
            - virtual_north: Virtual north of BTSMED-X

      Since interfaces that are using that get_netact_list require such structure, like:
        If key endswith 00: it's trunk,
        Else: it's branch.
      Since Banas tool use those keys to obtain proper names, please keep proper naming.

    :return: netact as list with specific netacts as dicts.
    """
    netact_list = [

        {"netact_name": "clab2334",
         "node_ip": "10.93.20.126",
         "password": "omc",
         "lbjbi": "10.93.20.141",
         "CLS_API_HOST": "10.93.19.68",
         "CLS_DATABASE_HOST": "10.93.19.65",
         "web_gui_username": "omc",
         "web_gui_password": "omc",
         "btsmed": [
             {
                 "releases": [],
                 "virtual_south": "",
                 "virtual_north": "",
             }]},

        {"netact_name": "clab3490",
         "node_ip": "10.91.97.237",
         "password": "omc",
         "lbjbi": "10.91.103.87",
         "CLS_API_HOST": "10.91.111.2",
         "CLS_DATABASE_HOST": "10.91.109.255",
         "web_gui_username": "omc",
         "web_gui_password": "omc",
         "btsmed": [
             {
                 "releases": [],
                 "virtual_south": "",
                 "virtual_north": "",
             }]},

        {"netact_name": "srnclab2009",
         "node_ip": "10.82.44.95",
         "password": "Medsql!_1893",
         "lbjbi": "10.82.44.117",
         "CLS_API_HOST": "10.82.44.116",
         "CLS_DATABASE_HOST": "10.82.44.114",
         "web_gui_username": "omc",
         "web_gui_password": "Medsql!_1893",
         "btsmed": [
             {
                 "releases": [],
                 "virtual_south": "",
                 "virtual_north": "",
             }]},

        {"netact_name": "srnclab3022",
         "node_ip": "10.41.128.170",
         "password": "Medsql!_1893",
         "lbjbi": "10.41.128.194",
         "CLS_API_HOST": "10.41.128.191",
         "CLS_DATABASE_HOST": "10.41.128.189",
         "web_gui_username": "omc",
         "web_gui_password": "Medsql!_1893",
         "btsmed": [
             {
                 "releases": [],
                 "virtual_south": "",
                 "virtual_north": "",
             }]},

        {"netact_name": "srnclab1013",
         "node_ip": "10.41.146.55",
         "password": "Medsql!_1893",
         "lbjbi": "10.41.146.80",
         "CLS_API_HOST": "10.41.146.185",
         "CLS_DATABASE_HOST": "10.41.146.183",
         "web_gui_username": "clsadmin",
         "web_gui_password": "lL4}sunuinownei",
         "btsmed": [
             {"releases": [],
              "virtual_south": "",
              "virtual_north": "",
              },
             {"releases": [],
              "virtual_south": "",
              "virtual_north": "",
              }]},

        {"netact_name": "srnclab1014",
         "node_ip": "10.41.146.88",
         "password": "Medsql!_1893",
         "lbjbi": "10.41.146.113",
         "btsmed": [
             {"releases": ["sbts22r1", "FLAT"],
              "virtual_south": "",
              "virtual_north": "",
              },
             {"releases": [],
              "virtual_south": "",
              "virtual_north": "",
              }]},

    ]
    return netact_list


def get_netact_params_by_btsmed_addresses():
    """
    Method wraps output from get_netact_list in way given in name of method.

    Netacts with more than one virtual_south are returned as separate.
    :return: dict with all netacts
    """
    netact_list = get_netact_list()
    netact_dictionary = {}
    for specific_netact in netact_list:
        btsmeds = specific_netact["btsmed"]
        for btsmed in btsmeds:
            ip_address = btsmed["virtual_south"]
            version_netact = specific_netact.copy()
            netact_dictionary[ip_address] = version_netact
            version_netact["virtual_north"] = btsmed["virtual_north"]
            version_netact["virtual_south"] = btsmed["virtual_south"]
            version_netact.pop("btsmed")
    return netact_dictionary


def get_netacts_by_name_with_release():
    """
    Method modifies output of get_netact_list, creating a dict with keys as netact_name,
    or netact_name + release if there is more virtual_south than one.

    Method made for netact_logs_collector.py script.
    :return: dict with all netacts
    """
    result_netacts = {}
    netacts = get_netact_list()
    for netact in netacts:
        netact_name = netact["netact_name"]
        btsmeds = netact["btsmed"]
        for btsmed in btsmeds:
            if len(btsmeds) > 1:
                netact_with_release = netact_name + "-" + str(btsmeds.index(btsmed) + 1)
            else:
                netact_with_release = netact_name
            version_netact = netact.copy()
            version_netact["virtual_north"] = btsmed["virtual_north"]
            version_netact["virtual_south"] = btsmed["virtual_south"]
            result_netacts[netact_with_release] = version_netact
            version_netact.pop("btsmed")
    return result_netacts


def get_netact_params_by_names():
    """
    Method modifies output from get_netact_list in way given in name of method.

    Netacts with more than one virtual_south are bonded together.
    :return: dict with all netacts
    """
    netact_list = get_netact_list()
    netact_dictionary = {}
    for specific_netact in netact_list:
        if specific_netact.get("netact_name"):
            netact_dictionary[specific_netact.get("netact_name")] = specific_netact
    return netact_dictionary


def get_netact_by_name(name_netact):
    """
    Method is returns ONLY one netacts: records from get_netact_params_by_names with
    empty virtual_south and virtual_north.

    :return: netact dict with keys as names
    """
    print(name_netact)
    netacts = get_netact_list()
    for netact in netacts:
        name_of_netact = netact.get("netact_name")
        if name_of_netact == name_netact:
            print(name_netact)
            dummy_var = 1
            break
    if dummy_var != 1:
        netact = "Netact not found"

    print(netact)
    return netact


def get_netacts_for_software_release(is_trunk, enb_release):
    """
    Method modifies output from get_netact_params_by_names.
    Changes:
        method overwrites virtual_south and virtual_north
            if there is more than one virtual_south and virtual_north

        Based on is_trunk value:
        - if is_trunk is True, virtual_south and virtual_north are switched to trunk IP addresses.
        - if is False, to branch IP addresses.

    :param is_trunk: if True, is Trunk, if not, it's branch.
    :param enb_release: release of software.
    :return: dict with all netacts
    """
    netacts = get_netact_params_by_names()
    for netact in netacts:
        btsmeds = netacts[netact]["btsmed"]
        for btsmed in btsmeds:
            releases = btsmed["releases"]
            for release in releases:
                if is_trunk:
                    condition = release.endswith("00")
                else:
                    condition = enb_release == release.upper()
                if condition:
                    netacts[netact]["virtual_south"] = btsmed["virtual_south"]
                    netacts[netact]["virtual_north"] = btsmed["virtual_north"]
                    print("jeden", netact, btsmed)
                    netacts[netact].pop("btsmed")
                    break
        if netacts[netact].get("btsmed"):
            netacts[netact]["virtual_south"] = btsmeds[0]["virtual_south"]
            netacts[netact]["virtual_north"] = btsmeds[0]["virtual_north"]
            print("dwa")
            netacts[netact].pop("btsmed")
    return netacts


def get_netact_with_argument(argument):
    """
    It returns one specific argument as value, with key as netact name.
    ASAIK it's not used anymore.

    :param argument: specific argument from netact dict, like virtual_south
    :return: netact dict with keys as names wanted argument
    """
    netact_dict = get_netact_params_by_names()
    return {netact: netact_dict[netact][argument] for netact in netact_dict}


def get_enb_connected_to_flat_netacts(enb_release):
    """
    Method combines hardcoded data from netact with netact_tool_updater
    to check if DNS record of ENB is pointing to mplane.

    :param enb_id: ...
    :param m_plane: ...
    :return: netacts with FLAT SOAM
    """
    flat_netacts = get_flat_soam_netacts(enb_release)
    # print (flat_netacts.get('clab1292'))
    for netacts in flat_netacts:
        # print(netacts)
        flat_netact = flat_netacts.get(netacts)
    return flat_netact


def get_flat_soam_netacts(release):
    """
    Method created for FLAT SOAM needs.
    It returns ONLY FLAT SOAM netacts: records from get_netact_params_by_names with
    empty virtual_south and virtual_north.

    :return: netact dict with keys as names
    """
    netacts = get_netact_params_by_names()
    flat_netacts = {}
    release = release.lower()
    for netact in netacts:
        btsmeds = netacts[netact]["btsmed"]
        for btsmed in btsmeds:
            if "FLAT" in btsmed["releases"]:
                releases = btsmed["releases"]
                if release in releases:
                    flat_netacts[netact] = netacts[netact]
                    flat_netacts[netact].pop("btsmed")
                    # print(btsmed)
    return flat_netacts


def get_netact_logs(netact_name):
    """
    Using get_netact_params_by_names with implementation from Netact Logs Collector
    method collects logs from netact, given by name as argument.

    :param netact_name: netact_name which can is usable for get_netact_params_by_names output dictionary.
    """
    netact_dict = get_netact_params_by_names()
    netact_logs_collector = NetActLogsCollector(netact_dict)
    command_list = {
        "dns_records": netact_logs_collector.collect_dns_records,
        "collect_env_info": netact_logs_collector.collect_env_info,
        "collect_env_status": netact_logs_collector.collect_env_status,
    }
    for command in command_list:
        collect_env_info = command_list[command](netact_name)
        zip_file = zipfile.ZipFile("file.zip", "w")
        zip_file.writestr('file.txt', collect_env_info)
        zip_file.close()
    netact_logs_collector.collect_env_logs(netact_name)
    netact_logs_collector.collect_btsmed_logs(netact_name)


def collect_and_check_alarms(allowed_alarms, expected_alarms, history_file):
    """
    Method delivered for LDT tests.
    It's checking created by executing collecting_alarms.py history.log file,
    which directory should be given as argument along with other arguments.

    :param allowed_alarms: Alarms which can be omitted in method.
    :param expected_alarms: Alarms which can be omitted in method.
    :param history_file: File containing
    :return:
    """
    extra_alarms = ""
    history_file = history_file.strip()
    for line in history_file.split("\n"):
        alarm_list = line.split(" - ")[-1]
        if alarm_list == "alarm list nof found due to lack of connection":
            continue
        alarms = alarm_list.split(", ")
        for alarm in alarms:
            if alarm not in allowed_alarms and alarm not in expected_alarms:
                extra_alarms += line.split(" - ")[0] + " - " + alarm + "\n"
    return extra_alarms


def get_m_c_u_plane(enb_side, release):
    """
    Method created to simplify managing M-C-U-plane IP addresses for CLOUD testing.

    Data given in this method can be further simplified, but it would might be more misleading than initial proposition.

    One thing to note here, sometimes "path" within the dict is set to None. It is because in lib_WOM, if such None
    will be found in dict it will run function to determine, based on ENB_RELEASE where to look for such address
    (currently, only mplane). I know it's not a perfect solution to prevent future abstractions for this problem,
    but for now it solves the issue.

    :param enb_side: Enb side from test. Used for paths.
    :param release: release of software on ENB. It should look like keys of release_with_addresses dictionary
    within the method.
    :return: dict with mplane/cplane/uplane
    :rtype: dict
    """

    path_a = "/MRBTS-1/RAT-1/BTS_L-{}//LTE_CONF_L-1/OPERATOR_CONF_L-1".format(enb_side)
    path_b = "/MRBTS-1/RAT-1/BTS_L-{}/EQM_L-1/CABINET_L-1/SMOD_L-1//COMSWITCH_L-1/COMAPPS_L-1/MPLANE_L-1".format(
        enb_side)
    path_c = "/MRBTS-1/RAT-1/BTS_L-{}/LNBTS-*/FTM-1".format(enb_side)
    path_d = "/MRBTS-1/RAT-1/BTS_L-{}/LNBTS-*/FTM-1/IPNO-1".format(enb_side)

    mplane_a = "localIpAddr"
    mplane_b = "ipv4Addr"
    mplane_c = "mPlaneIpAddress"

    cplane_a = "primaryCPlaneIpAddr"
    cplane_b = "primaryCPlaneIpV4Addr"
    cplane_c = "cPlaneIpAddress"

    uplane_a = "primaryUPlaneIpAddr"
    uplane_b = "primaryUPlaneIpV4Addr"
    uplane_c = "uPlaneIpAddress"

    release_with_addresses = {
        "SBTS17A":  {
            "mplane": {"path": None, "attribute": mplane_a},
            "cplane": {"path": path_a, "attribute": cplane_a},
            "uplane": {"path": path_a, "attribute": uplane_a}
        },
        "SBTS18":   {
            "mplane": {"path": None, "attribute": mplane_a},
            "cplane": {"path": path_a, "attribute": cplane_a},
            "uplane": {"path": path_a, "attribute": uplane_a}
        },
        "SBTS18SP": {
            "mplane": {"path": None, "attribute": mplane_a},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "FL18":     {
            "mplane": {"path": path_c, "attribute": mplane_c},
            "cplane": {"path": path_d, "attribute": cplane_c},
            "uplane": {"path": path_d, "attribute": uplane_c}
        },
        "FL18SP":   {
            "mplane": {"path": path_c, "attribute": mplane_c},
            "cplane": {"path": path_d, "attribute": cplane_c},
            "uplane": {"path": path_d, "attribute": uplane_c}
        },
        "FL18A":    {
            "mplane": {"path": path_c, "attribute": mplane_c},
            "cplane": {"path": path_d, "attribute": cplane_c},
            "uplane": {"path": path_d, "attribute": uplane_c}
        },
        "SBTS19A":  {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS19B":  {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "FL19":     {
            "mplane": {"path": None, "attribute": mplane_a},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "FL19A":    {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS20A": {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS20B": {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS20C": {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS21A": {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS21B": {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS22R1": {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },
        "SBTS22R2": {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },

    }
    if release_with_addresses.get(release):
        result = release_with_addresses[release]
    else:
        result = {
            "mplane": {"path": path_b, "attribute": mplane_b},
            "cplane": {"path": path_a, "attribute": cplane_b},
            "uplane": {"path": path_a, "attribute": uplane_b}
        },

    return result


def get_m_c_u_plane_holder(enb_side, release):
    """
    Interface method for get_m_c_u_plane. I decided to use object-like structure from mentioned method to
    easily access as attributes of PlaneHolder class.

    For every Xplane it would require five lines of code to get data from given dict. In my
    solution it requires only two lines, eq:

    ${ip_addresses}=    Get M C U plane    ${enb_side}    ${ENB_RELEASE}
    ${uplane}=    Get From Dictionary    ${ip_addresses}    uplane
    ${uplane_path}=    Get From Dictionary    ${uplane}    path
    ${uplane_attribute}=    Get From Dictionary    ${uplane}    attribute
    ${ENB_UPLANE_IP}=    Get Parameter From Infomodel    ${uplane_path}    ${uplane_attribute}

    VS

    ${ip_addresses}=    Get M C U Plane Holder    ${enb_side}    ${ENB_RELEASE}
    ${ENB_UPLANE_IP}=    Get Parameter From Infomodel    ${ip_addresses.uplane.path}    ${ip_addresses.uplane.attribute}

    which I saw as a huge opportunity for a improvement.

    :param enb_side: Enb side from test. Used for paths.
    :param release: release of software on ENB. It should look like keys of release_with_addresses dictionary
    within the method.
    :return: Object containing xplanes as attributes
    :rtype: PlaneHolder
    """
    release_with_plane = get_m_c_u_plane(enb_side, release)
    holder = PlaneHolder()
    holder.set_cplane(release_with_plane[0]["cplane"]["path"],
                      release_with_plane[0]["cplane"]["attribute"])
    holder.set_uplane(release_with_plane[0]["uplane"]["path"],
                      release_with_plane[0]["uplane"]["attribute"])
    holder.set_mplane(release_with_plane[0]["mplane"]["path"],
                      release_with_plane[0]["mplane"]["attribute"])
    return holder


class PlaneHolder:
    def __init__(self):
        self.mplane = ""
        self.cplane = ""
        self.uplane = ""

    def set_mplane(self, path, attribute):
        self.mplane = Address(path, attribute)

    def set_cplane(self, path, attribute):
        self.cplane = Address(path, attribute)

    def set_uplane(self, path, attribute):
        self.uplane = Address(path, attribute)


class Address:
    def __init__(self, path, attribute):
        self.path = path
        self.attribute = attribute
