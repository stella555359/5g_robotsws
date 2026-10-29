from os import system
from re import search
# from ipaddress import ip_address, ip_interface
# from taf.gnb.oam.megazone_client import megazone_client
# from taf.transport.ssh import ssh
# import robot_variable_in_python as rv


def get_scf_parameters_version_from_scf(path_to_scf, parameters_name):
    with open(path_to_scf) as scf:
        content = scf.read()
        version = str(search("(?<=version=\"{}).*?(?=\")".format(parameters_name), content).group())
    return version
