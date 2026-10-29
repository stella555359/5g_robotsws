"""
:copyright: Nokia Networks
:author: Damian Zak
:maintainer: Damian Zak
:contact: damian.zak@nokia.com, I_VRF_KRK_11@internal.nsn.com
:team: MN_RAN_RD_VRF_KRK_11
"""

import json

from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import perform_recomissioning_with_delta


def _nrspidgrp_delta(object_id, nrplm, spid):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRSPIDGRP-{object_id}",
            "operation": "create",
            "parameters":
                [
                    {
                        "parameterName": "nrPlmnDN",
                        "value": f"MRBTS-1/NRBTS-1/NRPLMN-{nrplm}",
                        "operation": "update"
                    },
                    {
                        "parameterName": "spid",
                        "value": f"{spid}",
                        "operation": "update"
                    }
                ]
        }
    ]


def _snssai_delta(object_id, nrplmns):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/SNSSAI-{object_id}",
            "operation": "create",
            "parameters":
                [
                    {
                        "parameterName": "administrativeState",
                        "value": "Unlocked",
                        "operation": "update"
                    },
                    {
                        "parameterName": "nrPlmnDNList",
                        "value":
                            [
                                nrplmn for nrplmn in nrplmns
                            ],
                        "operation": "update"
                    },
                    {
                        "parameterName": "sd",
                        "value": f"{object_id}",
                        "operation": "update"
                    },
                    {
                        "parameterName": "sst",
                        "value": "1",
                        "operation": "update"
                    }
                ]
        }
    ]


def _nrplm_delta(object_id, mcc, mnc, operation):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRPLMN-{object_id}",
            "operation": f"{operation}",
            "parameters":
                [
                    {
                        "parameterName": "mcc",
                        "value": f"{mcc}",
                        "operation": "update"
                    },
                    {
                        "parameterName": "mnc",
                        "value": f"{mnc}",
                        "operation": "update"
                    },
                    {
                        "parameterName": "mncLength",
                        "value": f"{len(str(mnc))}",
                        "operation": "update"
                    }
                ]
        }
    ]


def _rg_delta(rg_id, rg_profile_id, max_quota, min_quota):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-{rg_profile_id}/NRRESOURCEGROUP-{rg_id}",
            "operation": "create",
            "parameters":
                [
                    {
                        "parameterName": "nrResourceList",
                        "value":
                            [

                            ],
                        "operation": "update"
                    },
                    {
                        "parameterName": "schedulerParams",
                        "value":
                            [
                                {
                                    "maxQuota": f"{max_quota}",
                                    "minQuota": f"{min_quota}"
                                }
                            ],
                        "operation": "update"
                    }
                ]
        }
    ]


def _rg_profile_delta(object_id):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-{object_id}",
            "operation": "create",
            "parameters":
                [

                ]
        }
    ]


def _rg_profile_grp_delta(cell_id):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{cell_id}",
            "operation": "update",
            "parameters":
                [

                ]
        }
    ]


def _cell_dep_type_delta(object_id, cell_dep_type, nrplmnn_set_delete):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{object_id}",
            "operation": "update",
            "parameters":
                [
                    {
                        "parameterName": "cellDepType",
                        "value": f"{cell_dep_type}",
                        "operation": "update"
                    }
                ]
        },
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{object_id}/NRPLMNSET_{nrplmnn_set_delete}-1",
            "operation": "delete",
            "parameters":
                []
        }
    ]


def _tracking_area_delta():
    return [
        {
            "distName": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
            "operation": "update",
            "parameters":
                [
                    {
                        "parameterName": "snssaiList",
                        "value":
                            [

                            ],
                        "operation": "update"
                    }
                ]
        }
    ]


def _nrplmnset_delta(cell_id, net_arch):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{cell_id}/NRPLMNSET_{net_arch}-1",
            "operation": "update",
            "parameters":
                [
                    {
                        "parameterName": "nrPlmnDNList",
                        "value":
                            [

                            ],
                        "operation": "update"
                    }
                ]
        }
    ]


def _toggle_nrbts_parameter_delta(parameter_name, value):
    return [
        {
            "distName": "MRBTS-1/NRBTS-1",
            "operation": "update",
            "parameters":
                [
                    {
                        "parameterName": f"{parameter_name}",
                        "value": f"{value}",
                        "operation": "update"
                    }
                ]
        }
    ]


def _common_delta():
    return [
        {
            "distName": "MRBTS-1/NRBTS-1",
            "operation": "update",
            "parameters":
                [
                    {
                        "parameterName": "actSliceAwareScheduler",
                        "value": "true",
                        "operation": "update"
                    },
                    {
                        "parameterName": "actSliceAwareSchedulerUlAndEnh",
                        "value": "true",
                        "operation": "update"
                    }
                ]
        },
        {
            "distName": "MRBTS-1/NRBTS-1/NRPMRNL-1",
            "operation": "update",
            "parameters":
                [
                    {
                        "parameterName": "miNrCellUtilPerNrg",
                        "value": "5min",
                        "operation": "update"
                    },
                    {
                        "parameterName": "miNrCellUtilization",
                        "value": "5min",
                        "operation": "update"
                    }
                ]
        }
    ]


def _dynamic_nrplmn_delta(nrplmn_values):
    """
    Generate NRPLMN delta based on the given NRPLMN values.

    Args:
        nrplmn_values (dict): A dictionary containing NRPLMN values, where the keys are NRPLMN object IDs
                              and the values are tuples of MCC (Mobile Country Code), MNC (Mobile Network Code),
                              and operation. Example input: {1: [311, 489, 'update'], 2: [312, 490, 'create']}

    Returns:
        list: A list of NRPLMN delta values.

    """
    new_nrplmn_delta = []

    for nrplmn_object_id, (mcc, mnc, operation) in nrplmn_values.items():
        delta = _nrplm_delta(nrplmn_object_id, mcc, mnc, operation)
        new_nrplmn_delta.extend(delta)
    return new_nrplmn_delta


def _dynamic_nrspidgrp_delta(nrspidgrp_values):
    """
    Generate the delta for NRSPIDGRP.

    Args:
        nrspidgrp_values (dict): A dictionary containing NRSPIDGRP values. Example input:
        {1: [1, 1, 10], 2: [1, 11, 20], 3: [1, 21, 30], 4: [1, 31, 40], 5: [1, 41, 50]}

    Returns:
        list: A list of delta values for dynamic NRSPIDGRP.
    """
    new_nrspidgrp_delta = []

    for nrspidgrp_object_id, (nrplmn_id, spid, spid_last) in nrspidgrp_values.items():
        delta = _nrspidgrp_delta(nrspidgrp_object_id, nrplmn_id, spid)
        if spid_last:
            delta[0]["parameters"].extend(
                [{"parameterName": "spidLast", "value": f"{spid_last}", "operation": "update"}])
        new_nrspidgrp_delta.extend(delta)
    return new_nrspidgrp_delta


def _dynamic_snssai_delta(snssai_values):
    """
    Generate SNSSAI delta.

    Args:
        snssai_values (dict): A dictionary containing SNSSAI object IDs as keys and NRPLMN values as values.
                              Example input: {1: ['MRBTS-1/NRBTS-1/NRPLMN-1'], 2: ['MRBTS-1/NRBTS-1/NRPLMN-1']}

    Returns:
        list: A list of delta values calculated for the SNSSAI values.
    """
    new_snssa_delta = []
    multiple_sa_plmns_used = False

    for snssai_object_id, nrplmns in snssai_values.items():
        if snssai_object_id != 1:
            delta = _snssai_delta(snssai_object_id, nrplmns)
            new_snssa_delta.extend(delta)
        if any([plmn_path[-1] != '1' for plmn_path in nrplmns]):
            multiple_sa_plmns_used = True
    if multiple_sa_plmns_used:
        new_snssa_delta.extend([{"distName": "MRBTS-1/NRBTS-1", "operation": "update", "parameters": [
            {"parameterName": "actNgcFlexSaMode", "value": "true", "operation": "update"}]}])
    return new_snssa_delta


def _dynamic_rg_delta(rg_values):
    """
    Generate the delta for resource group based on the given RG values.

    Args:
        rg_values (dict): A dictionary containing RG values, where the keys are RG IDs and the values are tuples
                          containing the resource DN, maximum quota, and minimum quota. Example input:
                          {1: [['SNSSAI-1'], 100, 0], 2: [['SNSSAI-2'], 100, 0]}

    Returns:
        list: A list of RG deltas, where each RG delta is a dictionary containing the RG ID, resource DN, and
              quota parameters.

    """
    new_rg_delta = []
    if isinstance((list(rg_values.values())[0]), list):
        for rg_id, (resource_dn, max_quota, min_quota) in rg_values.items():
            delta = _rg_delta(rg_id, 1, max_quota, min_quota)
            for slice in resource_dn:
                delta[0]["parameters"][0]["value"].extend([{"resourceDN": f"MRBTS-1/NRBTS-1/{slice}"}])
            new_rg_delta.extend(delta)
    else:
        for rg_profile_id, rg_data in rg_values.items():
            for rg_id, (resource_dn, max_quota, min_quota) in rg_data.items():
                delta = _rg_delta(rg_id, rg_profile_id, max_quota, min_quota)
                for slice in resource_dn:
                    delta[0]["parameters"][0]["value"].extend([{"resourceDN": f"MRBTS-1/NRBTS-1/{slice}"}])
                new_rg_delta.extend(delta)
    return new_rg_delta


def _dynamic_rg_profile_delta(rg_profile_values):
    """
    Generates the delta for RG profile based on the given RG profile values.

    Args:
        rg_profile_values (dict): A dictionary containing RG profile values. Example input:
                                  {1: {'SA': {1: 2, 2: 12}, 'NSA': {1: 10, 2: 18}}}

    Returns:
        list: A list of delta values for the dynamic RG profile.
    """
    new_rg_profile_delta = []
    sa_parameter_index = 0

    for rg_profile_id, sa_nsa_rg_profile_values in rg_profile_values.items():
        delta = _rg_profile_delta(rg_profile_id)
        if "NSA" in sa_nsa_rg_profile_values.keys():
            sa_parameter_index = 1
            delta[0]["parameters"].extend([{"parameterName": "defaultRgNsaList", "value": [], "operation": "update"}])
            for nrplmn_id_nsa, rg_id_nsa in sa_nsa_rg_profile_values['NSA'].items():
                delta[0]["parameters"][0]["value"].extend(
                    [{"nrPlmnDN": f"MRBTS-1/NRBTS-1/NRPLMN-{nrplmn_id_nsa}", "nrResourceGroupId": f"{rg_id_nsa}"}])
        if "SA" in sa_nsa_rg_profile_values.keys():
            delta[0]["parameters"].extend([{"parameterName": "defaultRgSaList", "value": [], "operation": "update"}])
            for nrplmn_id_sa, rg_id_sa in sa_nsa_rg_profile_values['SA'].items():
                delta[0]["parameters"][sa_parameter_index]["value"].extend(
                    [{"nrPlmnDN": f"MRBTS-1/NRBTS-1/NRPLMN-{nrplmn_id_sa}", "nrResourceGroupId": f"{rg_id_sa}"}])
        new_rg_profile_delta.extend(delta)

    if any(net_arch == "NSA" for rg_profile in rg_profile_values.values() for net_arch in rg_profile.keys()):
        delta = _toggle_nrbts_parameter_delta("actSpidBasedSlicingNSA", "true")
        new_rg_profile_delta.extend(delta)
    return new_rg_profile_delta


def _dynamic_rg_profile_grp_delta(rg_profile_grp_values, should_set_actSliceNumExt_dynamically):
    """
    Generates a delta list for updating resource group profile group parameters based on the given values.

    Args:
        rg_profile_grp_values (dict): A dictionary containing the resource group profile group values.
                                      Example input: {1: {'UL': 1}}
        should_set_actSliceNumExt_dynamically (bool): A bool determining if actSliceNumExt should be set based on
        the content of rg_profile_grp_values.

    Returns:
        list: A list of delta dictionaries representing the changes to be made.

    """
    new_rg_profile_grp_delta = []

    for cell_id, ul_dl_rg_profile_grp_values in rg_profile_grp_values.items():
        delta = _rg_profile_grp_delta(cell_id)
        if "DL" in ul_dl_rg_profile_grp_values.keys():
            delta[0]["parameters"].extend([{"parameterName": "nrResourceGroupProfileDN",
                                            "value": f"MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-"
                                                     f"{ul_dl_rg_profile_grp_values['DL']}", "operation": "update"}])
        if "UL" in ul_dl_rg_profile_grp_values.keys():
            delta[0]["parameters"].extend([{"parameterName": "nrResourceGroupProfileUlDN",
                                            "value": f"MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-"
                                                     f"{ul_dl_rg_profile_grp_values['UL']}", "operation": "update"}])
        new_rg_profile_grp_delta.extend(delta)
    if should_set_actSliceNumExt_dynamically and any(
            direction == "DL" for ul_dl in rg_profile_grp_values.values() for direction in ul_dl.keys()):
        delta = _toggle_nrbts_parameter_delta("actSliceNumExt", "true")
        new_rg_profile_grp_delta.extend(delta)
    return new_rg_profile_grp_delta


def _dynamic_cell_dep_type_delta(cell_dep_type_values):
    """
    Generate the delta for dynamic cell dependency type.

    Args:
        cell_dep_type_values (dict): A dictionary containing cell IDs as keys and cell dependency types as values.
                                     Example input: {1: 'SANSA', 2: 'SANSA', 3: 'SANSA', 4: 'SANSA'}

    Returns:
        list: A list of delta values for dynamic cell dependency type.

    """
    new_cell_dep_type_delta = []

    for cell_id, cell_dep_type in cell_dep_type_values.items():
        if cell_dep_type != "SANSA":
            nrplmnset_to_delete = "NSA" if cell_dep_type == "SA" else "SA"
            delta = _cell_dep_type_delta(cell_id, cell_dep_type, nrplmnset_to_delete)
            new_cell_dep_type_delta.extend(delta)
    return new_cell_dep_type_delta


def _dynamic_tracking_area_delta(tracking_area_values):
    """
    Generates a dynamic tracking area delta based on the given tracking area values.

    Args:
        tracking_area_values (dict): A dictionary containing SNSSAI values. Example input:
                                     {1: ['MRBTS-1/NRBTS-1/NRPLMN-1'], 2: ['MRBTS-1/NRBTS-1/NRPLMN-1']}

    Returns:
        list: A list representing the new tracking area delta.
    """
    new_tracking_area_delta = []
    if tracking_area_values:
        delta = _tracking_area_delta()
        for snssai_id in tracking_area_values.keys():
            delta[0]["parameters"][0]["value"].extend([{"snssaiDN": f"MRBTS-1/NRBTS-1/SNSSAI-{snssai_id}"}])
        new_tracking_area_delta.extend(delta)
    return new_tracking_area_delta


def _dynamic_nrplmnset_delta(cell_dep_type_values, nrplmn_values):
    """
    Generate the NRPLMNSET delta for dynamic SAS.

    Args:
        cell_dep_type_values (dict): A dictionary containing cell IDs as keys and network architecture types as values.
                                     Example input: {1: 'SANSA', 2: 'SANSA', 3: 'SANSA', 4: 'SANSA'}
        nrplmn_values (dict): A dictionary containing NRPLMN values. Example input:
                              {1: [311, 489, 'update'], 2: [312, 490, 'create']}

    Returns:
        list: The NRPLMNSET delta for dynamic SAS.

    """
    def __add_nrplmnset(cell_id, net_arch):
        delta = _nrplmnset_delta(cell_id, net_arch)
        for nrplmn in nrplmn_ids:
            delta[0]["parameters"][0]["value"].extend([f"MRBTS-1/NRBTS-1/NRPLMN-{nrplmn}"])
        new_nrplmnset_delta.extend(delta)

    new_nrplmnset_delta = []
    nrplmn_ids = list(nrplmn_values.keys())
    if any(plmn_id != 1 for plmn_id in nrplmn_ids):
        for cell_id, net_arch in cell_dep_type_values.items():
            if net_arch == "SANSA":
                __add_nrplmnset(cell_id, "SA")
                __add_nrplmnset(cell_id, "NSA")
            else:
                __add_nrplmnset(cell_id, net_arch)
    return new_nrplmnset_delta


def _parse_sas_data(sas_data):
    def __parse_rg_resource_dn():
        """
        Parses the resourceDN, maxQuotas, and minQuotas data from the sas_data dictionary
        and returns a dictionary containing the parsed values for each RG.

        Returns:
            dict: A dictionary containing the parsed values for each RG.
                  The keys are the RG numbers (1-based) and the values are lists
                  containing the resourceDN, maxQuotas, and minQuotas values.
        """
        rg_values = {}
        if isinstance(sas_data["resourceDN"], list):
            for rg in range(sas_data["RG_amount"]):
                if isinstance(sas_data["resourceDN"][rg], list):
                    rg_values[rg + 1] = [sas_data["resourceDN"][rg], sas_data["maxQuotas"][rg],
                                         sas_data["minQuotas"][rg]]
                else:
                    rg_values[rg + 1] = [[sas_data["resourceDN"][rg]], sas_data["maxQuotas"][rg],
                                         sas_data["minQuotas"][rg]]
        elif isinstance(sas_data["resourceDN"], dict):
            for rg_profile_id, resource_dn_list in sas_data["resourceDN"].items():
                rg_profile_values = {}
                for rg in range(len(resource_dn_list)):
                    if isinstance(resource_dn_list[rg], list):
                        rg_profile_values[rg + 1] = [resource_dn_list[rg], sas_data["maxQuotas"][rg_profile_id][rg],
                                                     sas_data["minQuotas"][rg_profile_id][rg]]
                    else:
                        rg_profile_values[rg + 1] = [[resource_dn_list[rg]], sas_data["maxQuotas"][rg_profile_id][rg],
                                                     sas_data["minQuotas"][rg_profile_id][rg]]
                rg_values[rg_profile_id] = rg_profile_values
        return rg_values

    def __parse_nrspidgrp_data():
        """
        Parses the NRSPIDGRP data from the sas_data dictionary and returns a dictionary
        containing the parsed values.

        Returns:
            dict: A dictionary containing the parsed NRSPIDGRP values.
                  The keys are the indices of the NRSPIDGRP data, starting from 1.
                  The values are lists containing the three elements of each NRSPIDGRP data.
        """
        nrspidgrp_values = {}
        if "NRSPIDGRP" in sas_data.keys():
            for idx, nrspidgrp_data in enumerate(sas_data["NRSPIDGRP"]):
                nrspidgrp_values[idx + 1] = [nrspidgrp_data[0], nrspidgrp_data[1], nrspidgrp_data[2]]
        return nrspidgrp_values

    def __parse_snssai_nrplmn():
        """
        Parses the SNSSAI_NRPLMN data and returns a dictionary of SNSSAI values.

        Returns:
            dict: A dictionary containing the parsed SNSSAI values.
                  The keys are the indices of the SNSSAI data, starting from 1.
                  The values are lists containing the NRPLMN IDs of each SNSSAI data.
                  Example: {1: ["NRPLMN-1", "NRPLMN-2"]}
        """
        snssai_values = {}
        if "SNSSAI_NRPLMN" in sas_data.keys():
            for idx, snssai_nrplmn in enumerate(sas_data["SNSSAI_NRPLMN"]):
                snssai_values[idx + 1] = [f"MRBTS-1/NRBTS-1/NRPLMN-{nrplmn_id}" for nrplmn_id in snssai_nrplmn]
        return snssai_values

    def __parse_rg_profile():
        return sas_data["defaultRG"]

    def __parse_nrplmn_ids():
        """
        Parses the NRPLMN IDs from the sas_data dictionary and returns a dictionary of NRPLMN values.

        Returns:
            nrplmn_values (dict): A dictionary containing NRPLMN IDs as keys and corresponding MNC-MCC values as values.
        """
        nrplmn_values = {}
        if "NRPLMN_IDs" in sas_data.keys():
            if isinstance(sas_data["NRPLMN_IDs"], list):
                mnc_mcc = [[311 + iter, 489 + iter] for iter in range(len(sas_data["NRPLMN_IDs"]))]
                for nrplmn_id in sas_data["NRPLMN_IDs"]:
                    nrplmn_values[nrplmn_id] = mnc_mcc[nrplmn_id - 1]
                for key, value in nrplmn_values.items():
                    if key == 1:
                        value.extend(["update"])
                    else:
                        value.extend(["create"])
            if isinstance(sas_data["NRPLMN_IDs"], dict):
                nrplmn_values = sas_data["NRPLMN_IDs"]
        return nrplmn_values

    def __parse_rg_profile_grp_delta():
        return sas_data["RG_profile_grp"]

    def __parse_cell_dep_type():
        return sas_data["cellDepType"]

    parsed_sas_data = {
        "rg_values": __parse_rg_resource_dn(),
        "nrspidgrp_values": __parse_nrspidgrp_data(),
        "snssai_values": __parse_snssai_nrplmn(),
        "rg_profile_values": __parse_rg_profile(),
        "nrplmn_values": __parse_nrplmn_ids(),
        "rg_profile_grp_values": __parse_rg_profile_grp_delta(),
        "cell_dep_type_values": __parse_cell_dep_type(),
    }
    return parsed_sas_data


def create_dynamic_sas_delta(sas_data, data_parser=_parse_sas_data, **kwargs):
    """
    Function for creating Slice Aware Scheduler parameters delta with provided configration

    :param sas_data: (dict) Dict containing SAS configuration. Example:
    sas_data =     {
        "RG_amount": 5,
        "minQuotas": [20,30,30,10,10],
        "maxQuotas": [80,70,60,80,80],
        "resourceDN": ["NRSPIDGRP-1", "SNSSAI-1" ,"SNSSAI-2", ["SNSSAI-3", "NRSPIDGRP-2"],
                      ["SNSSAI-4", "SNSSAI-5", "NRSPIDGRP-3"]],
        "NRSPIDGRP": [[1,1,10], [2,11,20], [2,21,30]],
        "SNSSAI_NRPLMN": [[1], [1], [2], [2], [2]],
        "NRPLMN_IDs":[1,2],
        "defaultRG": {1: {'NSA': {1: 1, 2: 5}, 'SA': {1: 2, 2: 3}}},
        "RG_profile_grp":{1:{'UL': 1}},
        "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
    }
    RG_amount (mandatory) - represents number of RESOURCEGROUP objects
    minQuotas, maxQuotas (mandatory) - quotas for each RG, len of this list must be equal to RG_amount value
    resourceDN (mandatory) - list of resourceDN for RG's, if RG has more then one resourceDN then create list with
                             parameters like in the example
    NRSPIDGRP (optional) - list containing lists representing number of NRSPIDGRP object.
                           [NRPLMN_ID, SPID, SPID_LAST(optional None)]
    SNSSAI_NRPLMN (optional) - list cointaining lists representing number of SNSSAI objects. [NRPLMN_ID] SNSSAI objects
                               can have more than one NRPLMN
    NRPLMN_IDs (optional) - list containing all NRPLMN id's
    defaultRG (mandatory) - dict containing default RG assignment.
                            Key: default_rg_object_id, Value: {Key: net_arch, Value: {Key: NRPLMN_ID, Value: RG_ID}}
    RG_profile_grp (mandatory) - dict containing RG progile group configuration.
                                 Key: Cell_ID , Value: {'Transmitting direction':RG profile group ID}
    cellDepType (mandatory) - dict containing cell configurations
    """
    parsed_sas_data = data_parser(sas_data, **kwargs)

    dynamic_nrspidgrp = _dynamic_nrspidgrp_delta(nrspidgrp_values=parsed_sas_data["nrspidgrp_values"])
    dynamic_snssai = _dynamic_snssai_delta(snssai_values=parsed_sas_data["snssai_values"])
    dynamic_rg = _dynamic_rg_delta(rg_values=parsed_sas_data["rg_values"])
    dynamic_rg_profile = _dynamic_rg_profile_delta(rg_profile_values=parsed_sas_data["rg_profile_values"])
    dynamic_nrplmn = _dynamic_nrplmn_delta(nrplmn_values=parsed_sas_data["nrplmn_values"])
    dynamic_rg_profile_grp = _dynamic_rg_profile_grp_delta(
        rg_profile_grp_values=parsed_sas_data["rg_profile_grp_values"],
        should_set_actSliceNumExt_dynamically=sas_data.get('should_set_actSliceNumExt_dynamically', True))
    dynamic_cell_dep_type = _dynamic_cell_dep_type_delta(cell_dep_type_values=parsed_sas_data["cell_dep_type_values"])
    dynamic_tracking_area = _dynamic_tracking_area_delta(tracking_area_values=parsed_sas_data["snssai_values"])
    dynamic_nrplmnset = _dynamic_nrplmnset_delta(cell_dep_type_values=parsed_sas_data["cell_dep_type_values"],
                                                 nrplmn_values=parsed_sas_data["nrplmn_values"])
    final_delta = _common_delta()
    dynamic_deltas = [dynamic_nrspidgrp, dynamic_snssai, dynamic_rg, dynamic_rg_profile, dynamic_nrplmn,
                      dynamic_rg_profile_grp, dynamic_cell_dep_type, dynamic_tracking_area, dynamic_nrplmnset]
    for dynamic_delta in dynamic_deltas:
        final_delta.extend(dynamic_delta)

    return final_delta


def create_and_save_sas_delta(sas_configuration_data, output_delta_path, **kwargs):
    """
    Creates a dynamic SAS delta based on the provided SAS configuration data and saves it to the specified output file.

    Args:
        sas_configuration_data (dict): The SAS configuration data used to create the delta.
        output_delta_path (str): The path to the output file where the delta will be saved.
    """
    delta = create_dynamic_sas_delta(sas_configuration_data, **kwargs)
    with open(output_delta_path, 'w') as outfile:
        json.dump(delta, outfile)


def create_sas_delta_and_combine_with_test_delta(sas_configuration_data, test_delta, output_delta_path, **kwargs):
    """
    Creates a SAS delta based on the given SAS configuration data and combines it with a test delta.

    Args:
        sas_configuration_data (dict): The SAS configuration data used to create the SAS delta.
        test_delta (str): The file path to the test delta or delta in form of a list.
        output_delta_path (str): The file path to save the combined delta.
    """
    combined_delta = []
    sas_delta = create_dynamic_sas_delta(sas_configuration_data, **kwargs)
    combined_delta.extend(sas_delta)
    if isinstance(test_delta, list):
        combined_delta.extend(test_delta)
    else:
        with open(test_delta) as test_delta:
            test_data = json.load(test_delta)
            combined_delta.extend(test_data)
    with open(output_delta_path, 'w') as outfile:
        json.dump(combined_delta, outfile)


def perform_delta_recomissioning(test_dir_path, sas_configuration_data=None, test_delta=None):
    """
    Perform delta recommissioning based on the provided parameters.

    Args:
        test_dir_path (str): The path to the test directory.
        sas_configuration_data (dict, optional): The SAS configuration data. Defaults to None.
        test_delta (str or list, optional): The path to the test delta or delta in form of a list. Defaults to None.
    """
    if sas_configuration_data and not test_delta:
        create_and_save_sas_delta(sas_configuration_data=sas_configuration_data,
                                  output_delta_path=f"{test_dir_path}/dynamic_sas_delta.json")
        perform_recomissioning_with_delta(path_to_delta=f"{test_dir_path}/dynamic_sas_delta.json")
    elif test_delta and not sas_configuration_data:
        perform_recomissioning_with_delta(path_to_delta=test_delta)
    elif sas_configuration_data and test_delta:
        create_sas_delta_and_combine_with_test_delta(sas_configuration_data=sas_configuration_data,
                                                     test_delta=test_delta,
                                                     output_delta_path=f"{test_dir_path}/combined_delta.json")
        perform_recomissioning_with_delta(path_to_delta=f"{test_dir_path}/combined_delta.json")
