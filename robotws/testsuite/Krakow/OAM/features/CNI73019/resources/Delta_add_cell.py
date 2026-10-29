import re
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin

tl = BuiltIn().get_variable_value("${tl}")
instance_id = tl.gnbs[0].instance_id
oam_addr = tl.gnbs[0].dus[0].oam_ip.v4.split('/')[0]

add_cell_delta = [{"distName": "MRBTS-{0}/NRBTS-{0}/NRCELLGRP-0".format(instance_id), "operation": "update",
                   "parameters": [{"parameterName": "nrCellList", "value": ["1", "10"], "operation": "update"}]},
                  {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-10".format(instance_id), "operation": "create",
                   "parameters": [
                       {"parameterName": "cellBwpList",
                        "value": [{"bwpDN": "MRBTS-{0}/NRBTS-{0}/BWP_PROFILE-1".format(instance_id),
                                   "cellBwpId": "0"},
                                  {"bwpDN": "MRBTS-{0}/NRBTS-{0}/BWP_PROFILE-2".format(instance_id),
                                   "cellBwpId": "1"}],
                        "operation": "update"},
                       {"parameterName": "fPdcchMonOccsnPo", "value": ["0"], "operation": "update"},
                       {"parameterName": "lcrId", "value": "10", "operation": "update"},
                   ]},
                  {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10".format(instance_id),
                   "operation": "create",
                   "parameters": [
                       {"parameterName": "actAsiDistMimoNr", "value": "false", "operation": "update"},
                   ]},
                  {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1".format(instance_id),
                   "operation": "create",
                   "parameters": []},
                  {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-1".format(
                      instance_id),
                      "operation": "create",
                      "parameters": [{"parameterName": "direction", "value": "TX", "operation": "update"},
                                     {"parameterName": "resourceDN",
                                      "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                      "operation": "update"}]},
                  {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-2".format(
                      instance_id),
                      "operation": "create",
                      "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                     {"parameterName": "resourceDN",
                                      "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                      "operation": "update"}]},
                  {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-3".format(
                      instance_id),
                      "operation": "create",
                      "parameters": [{"parameterName": "direction", "value": "TX", "operation": "update"},
                                     {"parameterName": "resourceDN",
                                      "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                      "operation": "update"}]},
                  {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-4".format(
                      instance_id),
                      "operation": "create",
                      "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                     {"parameterName": "resourceDN",
                                      "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                      "operation": "update"}]}]

add_cell_delta_old = [{"distName": "MRBTS-{0}/NRBTS-{0}/NRCELLGRP-0".format(instance_id), "operation": "update",
                       "parameters": [{"parameterName": "nrCellList", "value": ["1", "10"], "operation": "update"}]},
                      {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-10".format(instance_id), "operation": "create",
                       "parameters": [
                           {"parameterName": "cellBwpList",
                            "value": [{"bwpDN": "MRBTS-{0}/NRBTS-{0}/BWP_PROFILE-1".format(instance_id),
                                       "cellBwpId": "0"},
                                      {"bwpDN": "MRBTS-{0}/NRBTS-{0}/BWP_PROFILE-2".format(instance_id),
                                       "cellBwpId": "1"}],
                            "operation": "update"},
                           {"parameterName": "fPdcchMonOccsnPo", "value": ["0"], "operation": "update"},
                           {"parameterName": "lcrId", "value": "10", "operation": "update"},
                           {"parameterName": "rModDNList",
                            "value": ["MRBTS-{0}/EQM-1/APEQM-1/RMOD-1".format(instance_id)],
                            "operation": "update"},
                       ]},
                      {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10".format(instance_id),
                       "operation": "create",
                       "parameters": []},
                      {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1".format(
                          instance_id),
                       "operation": "create",
                       "parameters": []},
                      {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-1".format(
                          instance_id),
                          "operation": "create",
                          "parameters": [{"parameterName": "direction", "value": "TX", "operation": "update"},
                                         {"parameterName": "resourceDN",
                                          "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                          "operation": "update"}]},
                      {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-2".format(
                          instance_id),
                          "operation": "create",
                          "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                         {"parameterName": "resourceDN",
                                          "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                          "operation": "update"}]},
                      {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-3".format(
                          instance_id),
                          "operation": "create",
                          "parameters": [{"parameterName": "direction", "value": "TX", "operation": "update"},
                                         {"parameterName": "resourceDN",
                                          "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                          "operation": "update"}]},
                      {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10/CHANNELGROUP-1/CHANNEL-4".format(
                          instance_id),
                          "operation": "create",
                          "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                         {"parameterName": "resourceDN",
                                          "value": "MRBTS-{0}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(instance_id),
                                          "operation": "update"}]}]

current_release = str(BuiltIn().get_variable_value('${ENB_BRANCH}'))
old_releases = ['SBTS22R3', 'SBTS22R4', 'SBTS23R1']

if any(release in current_release for release in old_releases):
    add_cell_delta = add_cell_delta_old


def _extract_configuration_from_scf(scf_content):
    parsed_scf_in_dict = {}
    object_regex = r"\s+<managedObject\s+class=.*distName=(?P<DIST_NAME>.*)\s+version.*"
    param_regex = r"\s+<p\s+name=(?P<PARAM_NAME>.*)>(?P<VALUE>.*)<\/p>"
    list_regex = r"\s+<list\s+name=(?P<LIST_NAME>.*)>"
    actual_dist_name = ""
    actual_list_name = ""
    for line in scf_content:
        object_matched = re.search(object_regex, line)
        list_matched = re.search(list_regex, line)
        param_matched = re.search(param_regex, line)
        if object_matched:
            key_name = object_matched.group("DIST_NAME").replace('"', "")
            actual_dist_name = key_name
            actual_list_name = None
            if key_name not in parsed_scf_in_dict.keys():
                parsed_scf_in_dict.update({key_name: {}})
        elif list_matched:
            list_name = list_matched.group("LIST_NAME").replace('"', "")
            actual_list_name = list_name
            parsed_scf_in_dict[actual_dist_name].update({actual_list_name: {}})
        elif param_matched and actual_list_name:
            param_name = param_matched.group("PARAM_NAME").replace('"', "")
            param_value = param_matched.group("VALUE").replace('"', "")
            parsed_scf_in_dict[actual_dist_name][actual_list_name].update({param_name: param_value})
        elif param_matched:
            param_name = param_matched.group("PARAM_NAME").replace('"', "")
            param_value = param_matched.group("VALUE").replace('"', "")
            parsed_scf_in_dict[actual_dist_name].update({param_name: param_value})
        else:
            continue
    return parsed_scf_in_dict


def prepare_delta():
    connection = admin()
    connection.connect_to(oam_addr)
    scf = connection.get_scf(export_type="configuration").split("\n")
    connection.teardown()
    defined_params_list = list()
    for param_dict in add_cell_delta[1]['parameters']:
        defined_params_list.append(param_dict["parameterName"])
    cell_parameters = _extract_configuration_from_scf(scf)['MRBTS-{0}/NRBTS-{0}/NRCELL-1'.format(instance_id)]
    for parameter in cell_parameters:
        if parameter not in defined_params_list:
            if not isinstance(cell_parameters[parameter], dict):
                add_cell_delta[1]['parameters'].append({"parameterName": parameter,
                                                        "value": cell_parameters[parameter], "operation": "update"})
            else:
                add_cell_delta[1]['parameters'].append({"parameterName": parameter,
                                                        "value": [cell_parameters[parameter]], "operation": "update"})
    return add_cell_delta
