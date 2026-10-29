#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import os
import collections
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

robot_obj = BuiltIn()
kw = robot_obj.run_keyword
rv = robot_obj.get_variable_value


class SiteDataStruct:
    def __init__(self, addr, username, password, namespace=None, port=None):
        self.addr = addr
        self.username = username
        self.password = password
        self.namespace = namespace
        self.port = port


class SiteBaseInfo:
    def get_classical_site_obj(self, product_type, bts_index, site):
        if getattr(site, f"{product_type}s") is not None and len(getattr(site, f"{product_type}s")) > 0:
            site_obj = getattr(site, f"{product_type}s")[bts_index]
        else:
            if product_type == "gnb":
                if getattr(site, "enbs") is not None and len(getattr(site, "enbs")) > 0:
                    site_obj = getattr(site, "enbs")[bts_index]
                else:
                    raise Exception("No site object found for gNB")
            elif product_type == "enb":
                if getattr(site, "gnbs") is not None and len(getattr(site, "gnbs")) > 0:
                    site_obj = getattr(site, "gnbs")[bts_index]
                else:
                    raise Exception("No site object found for eNB")
            else:
                raise Exception(f"No site object found for {product_type}")
        return site_obj

    def get_site_oam_info(self, product_type, bts_index, du_index, *args, **kwargs):
        info = SiteDataStruct(username="Nemuadmin", password="nemuuser", addr=None)
        site = rv("${tl}")
        if product_type == "gnb" or product_type == "enb":
            site_obj = self.get_classical_site_obj(product_type, bts_index, site)
            if site_obj.__class__.__name__ == "ClassicalBts":
                if kwargs.get("backhaul_site_oam_ip") and site_obj.cu.backhaul_site_oam_ip:
                    if site_obj.cu.backhaul_site_oam_ip.__class__.__name__ == "NetworkAddress":
                        info.addr = site_obj.cu.backhaul_site_oam_ip.v4
                    else:
                        info.addr = site_obj.cu.backhaul_site_oam_ip
                    logger.info("Using backhaul site OAM IP {}".format(info.addr))
                else:
                    info.addr = site_obj.cu.oam_http_connection_details.addr
                info.username = site_obj.cu.oam_http_connection_details.username
                info.password = site_obj.cu.oam_http_connection_details.password
            elif site_obj.__class__.__name__ == "RealEnb":
                info.addr = site_obj.oam_ip.v4
            info.port = "443"
        elif "du" in product_type:
            info.addr = site.gnbs[bts_index].dus[du_index].oam_http_connection_details.addr
            info.username = site.gnbs[bts_index].dus[du_index].oam_http_connection_details.username
            info.password = site.gnbs[bts_index].dus[du_index].oam_http_connection_details.password
            info.port = site.gnbs[bts_index].dus[du_index].oam_http_connection_details.port
        elif "cu" in product_type:
            info.addr = site.gnbs[bts_index].cu.oam_http_connection_details.addr
            info.username = site.gnbs[bts_index].cu.oam_http_connection_details.username
            info.password = site.gnbs[bts_index].cu.oam_http_connection_details.password
            info.port = site.gnbs[bts_index].cu.oam_http_connection_details.port
        return info

    def get_site_ssh_info(self, product_type, bts_index, du_index, *args, **kwargs):
        info = SiteDataStruct(username="toor4nsn", password="oZPS0POrRieRtu", addr=None)
        site = rv("${tl}")
        if product_type == "gnb" or product_type == "enb":
            site_obj = self.get_classical_site_obj(product_type, bts_index, site)
            if site_obj.__class__.__name__ == "ClassicalBts":
                info.addr = site_obj.cu.oam_ssh_connection_details.addr
                info.username = site_obj.cu.oam_ssh_connection_details.username
                info.password = site_obj.cu.oam_ssh_connection_details.password
            elif site_obj.__class__.__name__ == "RealEnb":
                info.addr = site_obj.oam_ip.v4
        elif "du" in product_type:
            site_obj = site.gnbs[bts_index].dus[du_index]
            site_obj = site_obj.cloud_deployment.cloud_hosting.master_node.ssh_connection_details
            info.addr = site_obj.addr
            info.username = site_obj.username
            info.password = site_obj.password
            info.namespace = site.gnbs[bts_index].dus[du_index].cloud_deployment.cloud_hosting.namespace
        elif "cu" in product_type:
            site_obj = site.gnbs[bts_index]
            site_obj = site.gnbs[bts_index].cloud_deployment.cloud_hosting.master_node.ssh_connection_details
            info.addr = site_obj.addr
            info.username = site_obj.username
            info.password = site_obj.password
            info.namespace = site.gnbs[bts_index].cloud_deployment.cloud_hosting.namespace
        return info

    def get_site_rru_info(self, product_type, bts_index, du_index, ru_index, *args, **kwargs):
        info = None
        site = rv("${tl}")
        if product_type == "gnb" or product_type == "enb":
            site_obj = self.get_classical_site_obj(product_type, bts_index, site)
            if site_obj.__class__.__name__ == "ClassicalBts":
                info = site_obj.dus[du_index].rus[ru_index]
            elif site_obj.__class__.__name__ == "RealEnb":
                info = site_obj.rms[ru_index]
        elif "du" in product_type:
            if site.gnbs[bts_index].dus[du_index].rus:
                info = site.gnbs[bts_index].dus[du_index].rus[ru_index]
            elif site.gnbs[bts_index].dus[du_index].fhgws[0].rus:
                info = site.gnbs[bts_index].dus[du_index].fhgws[0].rus[ru_index]
            else:
                raise Exception("No rru object found")
        elif "cu" in product_type:
            raise "Can't get the rru in cu, please check your product type"
        if info.attenuation_ports:
            info.attenuation_ports = [x.port_no for x in info.attenuation_ports]
        return info

    def get_site_smod_info(self, product_type, bts_index, du_index, *args, **kwargs):
        info = None
        site = rv("${tl}")
        if product_type == "gnb" or product_type == "enb":
            site_obj = self.get_classical_site_obj(product_type, bts_index, site)
            if site_obj.__class__.__name__ == "ClassicalBts":
                info = site_obj.dus[du_index].airscale
            elif site_obj.__class__.__name__ == "RealEnb":
                info = site_obj.system_module
        elif "du" in product_type:
            raise "Can't get the smod in du, please check your product type"
        elif "cu" in product_type:
            raise "Can't get the smod in cu, please check your product type"
        return info


class module_utils(object):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'

    def setup_module_directory(self, module_name='module'):
        """
        Create the log directory for the module.
        It will save the module directory to robot suite variable ${MODULE_LOG_DIRECTORY}

        *Input Parameters:*
        | Name | Type | Mandatory | Default | Description |
        | module_name | string  | Yes | module | module name |

        *Return:* Module log directory path

        *Example:*

        | ${log_path=} | setup_module_directory | mymodule |

        """
        suite_dire = '' or rv('${SUITE_LOG_DIRECTORY}', '') or rv('${SUITE_LOGS_DIR_PATH}', '')
        test_dire = (rv('${Test Results Dir}', '') or
                     rv('${TEST_LOG_DIRECTORY}', '') or
                     rv('${TEST_LOGS_DIR_PATH}', ''))

        if test_dire:
            dire = os.path.join(test_dire, module_name)
        elif suite_dire:
            dire = os.path.join(suite_dire, module_name)
        else:
            dire = os.path.join(rv('${OUTPUT_DIR}'), module_name)

        os.makedirs(dire, exist_ok=True)
        kw('Set Suite Variable', '${MODULE_LOG_DIRECTORY}', dire)
        return dire

    def get_site_info(self, product_type, info_type, bts_index=0, du_index=0, ru_index=0, *args, **kwargs):
        """
        Get the site information for the product type.

        *Input Parameters:*
        | Name | Type | Mandatory | Default | Description |
        | product_type | string  | Yes | | The product type, such as gnb, enb, du, cu |
        | bts_index | integer  | No | 0 | The gNB index |
        | du_index | integer  | No | 0 | The DU index |
        | ru_index | integer  | No | 0 | The RU index |

        *Return:* The site information

        *Example:*

        | ${site_info} | get_site_info | gnb | 0 | 0 | 0 |
        | ${site_info} | get_site_info | enb | 0 | 0 | 0 |
        | ${site_info} | get_site_info | vdu | 0 | 0 | 0 |
        | ${site_info} | get_site_info | cu | 0 | 0 | 0 |
        """
        if info_type in ["rru", "oam", "ssh", "smod"]:
            site = SiteBaseInfo()
            logger.info(f"Calling get_site_{info_type}_info with args: {args}, kwargs: {kwargs}")
            return getattr(site, f"get_site_{info_type}_info")(product_type,
                                                               bts_index,
                                                               du_index,
                                                               ru_index,
                                                               *args,
                                                               **kwargs)
        else:
            raise Exception(f"The info type {info_type} is not supported")

    def instance_for_robot(self, var, t):
        """Convert variable to instance if it is string type name like 'list', 'str', etc."""
        if isinstance(t, str):
            try:
                t = eval(t)
            except NameError:
                raise Exception(f"Unknown type: {t}")
        return isinstance(var, t)
