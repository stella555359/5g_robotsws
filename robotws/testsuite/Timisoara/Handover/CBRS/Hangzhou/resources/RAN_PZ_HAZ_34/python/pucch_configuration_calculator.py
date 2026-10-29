# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
:maintainer: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
"""

import json
import requests
from robot.api import logger
from taf.config.scf.scf_operations import SCFOperations


class PucchCalculator(object):

    """
    PucchCalculator Class is used for collecting SCF file parameters,
    And requesting remote calculator service to calculate pucch prb.
    """

    _REMOTE_SERVER_ADDRESS1 = "http://10.101.47.72:8000"
    _REMOTE_SERVER_ADDRESS2 = "http://10.101.54.18:8000"
    _REMOTE_SERVER_ADDRESS3 = "http://10.71.218.229:8000"

    _GET_REQUIRED_BRANCHS_URLS = [_REMOTE_SERVER_ADDRESS1 + '/pucch/configuration/branchs',
                                  _REMOTE_SERVER_ADDRESS2 + '/pucch/configuration/branchs',
                                  _REMOTE_SERVER_ADDRESS3 + '/pucch/configuration/branchs']

    _GET_REQUIRED_VERSIONS_URLS = [_REMOTE_SERVER_ADDRESS1 + '/pucch/configuration/versions',
                                   _REMOTE_SERVER_ADDRESS2 + '/pucch/configuration/versions',
                                   _REMOTE_SERVER_ADDRESS3 + '/pucch/configuration/versions']

    _GET_REQUIRED_PARAMS_URLS = [_REMOTE_SERVER_ADDRESS1 + '/pucch/configuration/parameters',
                                 _REMOTE_SERVER_ADDRESS2 + '/pucch/configuration/parameters',
                                 _REMOTE_SERVER_ADDRESS3 + '/pucch/configuration/parameters']

    _CALCULATE_PUCCH_PRB_URLS = [_REMOTE_SERVER_ADDRESS1 + '/pucch/prb/calculate',
                                 _REMOTE_SERVER_ADDRESS2 + '/pucch/prb/calculate',
                                 _REMOTE_SERVER_ADDRESS3 + '/pucch/prb/calculate']

    _REQUEST_TIMEOUT = 60

    _CALCULATOR_NAME_MAP_SCF_NAME = [("actMultipleDedicatedBwps", "actMultipleDedicatedBWPs")]

    def __init__(self):
        versions = self._get_supported_versions()
        outstr = ", ".join(["{}:version{}".format(branch, version) for branch, version in versions.items()])
        logger.info("pucch configuration calculator supported {}".format(outstr))

    def _requests_get(self, url, params):
        if params:
            response = requests.get(url=url, params=params, timeout=self._REQUEST_TIMEOUT)
        else:
            response = requests.get(url=url, timeout=self._REQUEST_TIMEOUT)

        return self._parse_response(response)

    def _requests_post(self, url, params):
        response = requests.post(url=url,
                                 json=params,
                                 timeout=self._REQUEST_TIMEOUT)

        return self._parse_response(response)

    def _parse_response(self, response):
        if response.status_code != 200:
            logger.debug("response is invalid code={}".format(response.status_code))
            return None
        return json.loads(response.text)

    def _request_remote_services(self, method, urls, params=None):
        for url in urls:
            try:
                logger.debug("using api '{}' to calculate pucch with params='{}'".format(url, params))
                result = method(url, params)
                if result:
                    return result
            except Exception as err:
                logger.debug("can not get result from api '{}', err is {}".format(url, err))
                continue

        raise Exception("all pucch calculator services {} and {} are unavailable".format(
            self._REMOTE_SERVER_ADDRESS1, self._REMOTE_SERVER_ADDRESS2))

    def _get_supported_branchs(self):
        return self._request_remote_services(method=self._requests_get, urls=self._GET_REQUIRED_BRANCHS_URLS)

    def _get_supported_versions(self):
        return self._request_remote_services(method=self._requests_get, urls=self._GET_REQUIRED_VERSIONS_URLS)

    def _collect_calculate_params(self, scf_file_path, cell, cell_group, branch):
        param_names = self._get_param_names_for_calculator(branch)
        return self._get_scf_parameter_values(param_names, scf_file_path, cell, cell_group)

    def _get_param_names_for_calculator(self, branch):
        return self._request_remote_services(method=self._requests_get,
                                             urls=self._GET_REQUIRED_PARAMS_URLS,
                                             params={"branch": branch})

    def _get_scf_parameter_values(self, param_names, scf_file_path, cell, cell_group):
        scf_op = SCFOperations()
        scf_op.load_scf(scf_file_path)

        cell_technology = scf_op.get_all_values_from_scf(p_name="cellTechnology", dist_name=cell)[0]
        logger.info("cell_technology is {}".format(cell_technology))

        collected_params = self._get_params_from_scf(param_names["common"], scf_op, cell, cell_group)
        if cell_technology.upper() == "TDD":
            collected_params += self._get_params_from_scf(param_names["tdd"], scf_op, cell, cell_group)
        else:
            collected_params += self._get_params_from_scf(param_names["fdd"], scf_op, cell, cell_group)

        return collected_params

    def _get_params_from_scf(self, param_names, scf_op, cell, cell_group):
        params = []
        for name in param_names:
            value = self._get_param_value_from_scf(name, scf_op, cell, cell_group)
            if value is None:
                continue

            '''
            If parameter is chBw, remove the space in value.
            Because chBw only accept the value without space in Excel table, e.g '70MHz',
            But chBw can be set as '70 MHz' in SCF file.
            '''
            if name == "NRCELL.chBw":
                value = value.replace(" ", "")

            params.append([name, value])
        return params

    def _get_param_value_from_scf(self, param, scf_op, cell, cell_group):
        name = param.split(".")[-1]
        for excel_name, scf_name in self._CALCULATOR_NAME_MAP_SCF_NAME:
            if name == excel_name:
                name = scf_name

        if "NRCELL." in param:
            values = scf_op.get_all_values_from_scf(p_name=name, dist_name=cell)
        elif "NRCELLGRP." in param:
            values = scf_op.get_all_values_from_scf(p_name=name, dist_name=cell_group)
        else:
            values = scf_op.get_all_values_from_scf(p_name=name)

        if not values:
            logger.info("parameter {} not found in SCF file".format(param))
            return None

        logger.debug("{} = {}".format(param, values[0]))
        return values[0]

    def _calculate_pucch(self, param_values, branch):
        params = {"data": {"branch": {"id": branch},
                           "params": dict(param_values)}}
        return self._request_remote_services(method=self._requests_post,
                                             urls=self._CALCULATE_PUCCH_PRB_URLS,
                                             params=params)

    def calculate_cell_pucch(self, scf_file_path, cell, cell_group, branch=None):
        """
        Keyword used for calculating pucch with SCF file.

        :param scf_file_path: scf file path, e.g SCF_SBTS00.xml.
        :type scf_file_path: str
        :param cell: cell distname in scf file, e.g MRBTS-2303/NRBTS-36976/NRCELL-1.
        :type cell: str
        :param cell_group: cell group distname in scf file, e.g MRBTS-2303/NRBTS-36976/NRCELLGRP-1.
        :type cell_group: str
        :param branch: branch name, supported 23R1, 23R2, 23R3, 23R4.
        :type branch: str
        :return: calculate result, e.g
            {'#PRB (Long PUCCH - SR)': 4.0,
             '#PRB (Long PUCCH - HARQ ACK/NACK)': 16.0,
             '#PRB (Long PUCCH - pCSI)': 6.0,
             '#PRB (Long PUCCH - Total)': 26.0,
             '#PRB (PUSCH)': 107.0,
             'Max. #RCU estimate (non-CA UEs)*': 384.0,
             'Max. #RCU estimate (CA UEs and non-CA UEs)*': 134.0}
        :rtype: dict
        """
        if not branch:
            branch = self._select_latest_branch()
            logger.info("user did not provide branch info, auto selected latest branch {}".format(branch))

        supported_branchs = self._get_supported_branchs()
        if branch not in supported_branchs:
            branch = self._select_latest_branch()
            logger.info("user provided branch not in supported {}, selected latest branch {}".format(
                supported_branchs, branch))

        param_values = self._collect_calculate_params(scf_file_path, cell, cell_group, branch)
        return self._calculate_pucch(param_values, branch)

    def _select_latest_branch(self):
        branchs = self._get_supported_branchs()
        return sorted(branchs)[-1]


def calculate_cell_pucch(scf_file_path, cell, cell_group, branch=None):
    """
    Keyword used for calculating pucch with SCF file.

    :param scf_file_path: scf file path, e.g SCF_SBTS00.xml.
    :type scf_file_path: str
    :param cell: cell distname in scf file, e.g MRBTS-2303/NRBTS-36976/NRCELL-1.
    :type cell: str
    :param cell_group: cell group distname in scf file, e.g MRBTS-2303/NRBTS-36976/NRCELLGRP-1.
    :type cell_group: str
    :param branch: branch name, supported 23R1, 23R2, 23R3, 23R4, if not provided, select latest branch.
    :type branch: str or None
    :return: calculate result, long pucch sr, long pucch harq, long pucch total values.
    :rtype: list
    """
    result = PucchCalculator().calculate_cell_pucch(scf_file_path=scf_file_path,
                                                    cell=cell,
                                                    cell_group=cell_group,
                                                    branch=branch)
    return (result["#PRB (Long PUCCH - SR)"],
            result["#PRB (Long PUCCH - HARQ ACK/NACK)"],
            result["#PRB (Long PUCCH - Total)"])
