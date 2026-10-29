# -*- coding: utf-8 -*-
import re
import ipaddress
from taf.config.scf.interface import scf
from robot.api.logger import console

EAC_EMPTY_LIST = []


class ScfOperations(object):

    def __init__(self):
        self.scf = scf()

    def get_number_of_object_occurrence(self, dist_name):
        """
        Get number of occurrence given object in scf.
        Example:
        If you have 3 objects IPIF in scf method returns number = 3
        :param dist_name: Object dist_name in SCF (e.g. MRBTS-50237/TNLSVC-1/TNL-1/IPNO-1/IPIF-1).
        :type dist_name: str.
        :return: number of object occurrence in scf.
        :rtype: int.
        """
        splitted_dist_name = dist_name.rsplit("-", 1)[0]
        number = 0
        for object_id in xrange(1, 20):
            status = self.scf.is_object_in_scf(dist_name="{}-{}".format(splitted_dist_name, object_id))
            if status is False:
                break
            number += 1
        return number

    def get_value_from_scf_if_exist(self, dist_name, p_name, list_name=None, index=None):
        """
        Get value from scf if exist. If not exist return None.
        :param dist_name: Object dist_name in SCF (e.g. MRBTS-50237/TNLSVC-1/TNL-1/IPNO-1/IPRT-1).
        :type dist_name: str.
        :param p_name: parameter name (e.g. destIpAddr)
        :type p_name: str.
        :param list_name: (opt) list name (e.g. staticRoutes).
        :type list_name: str.
        :param index: (opt) parameter index if there are more than one parameter with the same name.
        :type index: int or str.
        :return: parameter value or None if parameter doesn't exist.
        :rtype: str or bool.
        """
        try:
            return self.scf.get_value_from_scf(dist_name=dist_name, list_name=list_name, p_name=p_name, index=index)
        except KeyError:
            console("No match found! Query might be not valid. None value is returned")
            return None

    @staticmethod
    def get_gateway_for_ip(ip, mask):
        """
        Calculate gateway for given ip address and mask assuming that gateway ip is first address in network.
        :param ip: ip address.
        :type ip: str.
        :param mask: mask.
        :type mask: str.
        :return: network gateway address.
        :rtype: str.
        """
        return str((ipaddress.ip_network(unicode(ip + "/" + mask), strict=False).network_address + 1).exploded)

    @staticmethod
    def get_mo_id(scf_path, mo_name):
        """
        Get Managed Object id from SCF file.
        Usage:
        get_mo_id(scf_path, "MRBTS") return MRBTS id (e.g. 1900)
        get_mo_id(scf_path, "RMOD") return RMOD id (e.g. 1)

        :param scf_path: Path to SCF file.
        :type scf_path: str.
        :param mo_name: Managed Object name (e.g. MRBTS, NRBTS, RMOD, etc...)
        :type mo_name: str.
        :return: Managed Object ID.
        :rtype: str.
        """
        with open(scf_path, "r") as f:
            content = f.read()
            mo_id = None
            try:
                mo_id = str(re.search(pattern=r'(?<={0}-)\d+?(?=")'.format(mo_name.upper()), string=content).group())
            except AttributeError:
                console("Cannot find {0} object id. None type object is returned".format(mo_name))
            return mo_id

    def get_synchronize_plane_dn(self, mrbts_id, nrbts_id, ipv6=False):
        """
        Get distinguish name for synchronization plane (e.g. MRBTS-50243/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1)
        :param mrbts_id: MRBTS ID.
        :type mrbts_id: str.
        :param nrbts_id: NRBTS ID.
        :type nrbts_id: str.
        :param ipv6: Set True if you want sync DN for ipv6.
        :type ipv6: bool.
        :return:
        """
        p_name = "ipV6AddressDN1" if ipv6 else "ipV4AddressDN1"
        sync_plane_dn = self.scf.get_value_from_scf(
            dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
            list_name="s1Uplane",
            p_name=p_name
        )
        return sync_plane_dn


scf = ScfOperations()


def modify_scf(mrbts, dict_name, base_scf_path):
    scf.scf.load_scf(file_path=base_scf_path)
    if scf.scf.is_list_in_object(dist_name="MRBTS-{}/MNL-1/MNLENT-1/MPLANEONAP-1".format(mrbts),
                                 list_name="certToNameMappingList"):
        scf.scf.save_scf("new_scf.xml")
        return "new_scf.xml"
    else:
        scf.scf.add_list_to_scf(dist_name="MRBTS-{}/MNL-1/MNLENT-1/MPLANEONAP-1".format(mrbts),
                                list_name="certToNameMappingList")
        scf.scf.add_item_to_list(dist_name="MRBTS-{}/MNL-1/MNLENT-1/MPLANEONAP-1".format(mrbts),
                                 list_name="certToNameMappingList", elements=dict_name)
        scf.scf.save_scf("new_scf.xml")
        return "new_scf.xml"


def get_list_of_params_for_mplaneonap_object(mrbts):
    params_list = [
        {"parameterName": "activateOranO1NetconfService", "operation": "update", "value": "false"},
        {"parameterName": "mPlaneOnapId", "operation": "update", "value": 1},
        {"parameterName": "mPlaneAddressDN", "operation": "update",
         "value": "MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1".format(mrbts)}
    ]
    return params_list


def get_list_of_params_for_vesendpoint_object(vesid, ves_ip):
    params_list = [
        {"parameterName": "vesEndpointPortNumber", "operation": "update", "value": 30420},
        {"parameterName": "vesEndpointId", "operation": "update", "value": vesid},
        {"parameterName": "vesEndpointIpAddress", "operation": "update", "value": ves_ip}
    ]
    return params_list


def get_list_of_params_for_eac_1_object():
    params_list = [
        {"parameterName": "startDelay", "operation": "update", "value": 0},
        {"parameterName": "descr", "operation": "update", "value": "EAC fault 1"},
        {"parameterName": "inUse", "operation": "update", "value": "false"},
        {"parameterName": "polarity", "operation": "update", "value": "Normally_closed"},
        {"parameterName": "portId", "operation": "update", "value": 1},
        {"parameterName": "severity", "operation": "update", "value": "Minor"},
        {"parameterName": "cancelDelay", "operation": "update", "value": 0}
    ]
    return params_list


def get_list_of_params_for_eac_1_object_rmod():
    params_list = [
        {"parameterName": "startDelay", "operation": "update", "value": 0},
        {"parameterName": "descr", "operation": "update", "value": "EAC fault 1 RMOD"},
        {"parameterName": "inUse", "operation": "update", "value": "false"},
        {"parameterName": "polarity", "operation": "update", "value": "Normally_closed"},
        {"parameterName": "portId", "operation": "update", "value": 1},
        {"parameterName": "severity", "operation": "update", "value": "Minor"},
        {"parameterName": "cancelDelay", "operation": "update", "value": 0}
    ]
    return params_list
