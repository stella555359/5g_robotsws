"""
Helping Python Resource for tti trace collection.
"""
import re
import os
import logging
import json
import yaml


logger = logging.getLogger()


def add_file_ending_if_missing(file_path, file_ending):
    """This file adds to the given file_path the file_ending if it does not exist

    :param file_path: The path to the file
    :param file_ending: The file extension to be added, if missing.
    """
    if file_ending not in file_path:
        file_path += file_ending
    return file_path


def get_source_ip_address(raw_ip):
    """Retrieves the source ip address of the given raw_ip address
    """
    try:
        search_object = re.search("inet [0-9,.]*", raw_ip)
        source_ip = search_object.string[search_object.span()[0]+5:search_object.span()[1]]
    except AttributeError:
        logging.warning("Did not recieve usable input -AttributeError-, defaulting to ip 10.0.1.2")
        source_ip = "10.0.1.2"
    except TypeError:
        logging.warning("Wrong Input Type was given. setting IP to 10.0.1.2")
        source_ip = "10.0.1.2"
    return source_ip


def get_static_routes_from_iprt(iprt_data):
    """From the iprt data given by vdu oam, this function extracts the information
    about the currently set list "staticRoutes"

    :param iprt_data: content returned by vdu oam for the managed object IPRT
    """
    try:
        for parameter in iprt_data['parameters']:
            if parameter['complex_parameter']['name'] == 'staticRoutes':
                return parameter['complex_parameter']['value']
    except KeyError:
        return []
    return []


def get_static_route_parameters(iprt_data):
    """This function reads the data from the oam retrieved iprt object
    The staticRoutes element is extracted and translated to a dictionary in the form {param_name: param_value},
    to be easier processed in the robot code
    :param iprt_data: content returned by vdu oam for the managed object IPRT
    """
    routes = get_static_routes_from_iprt(iprt_data)
    data = []
    for route in routes:
        data.append({item.simple_parameter.name: item.simple_parameter.value for item in route.structure_parameters})
    return data


def create_json_commissioning_file_for_static_route(dist_name, gateway, dest_ip_addr):
    """This function creates the commissioning file to set or update the staticRoute item field
    inside of the managed object IPRT.

    :param dist_name: The full dist name for the managed object IPRT
    :param gateway: The gateway ip address
    :param dest_ip_addr: The destination ip address for the static route
    """
    data = [{
        "distName": dist_name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "staticRoutes",
                "value": [
                    {
                        "destIpAddr": dest_ip_addr,
                        "destinationIpPrefixLength": "32",
                        "gateway": gateway,
                        "preference": "1"
                    }
                ],
                "operation": "update"
            }
        ]
    }]

    filename = "/tmp/commission_static_route.json"
    with open(filename, 'w') as commissioning_file:
        json.dump(data, commissioning_file)

    return filename


def get_gateway_ip_from_tl_config(tl):
    """This function determines the gateway ip address for the f1u interface.
    For this, the configuration directory of the testline configuration is determined by
    the tl config itself, and the vcu-cnf.yaml is parsed to retrieve the corresponding
    information

    :param tl: The testline configuration object (since it is not available on py module level)
    """
    config_path = tl.gnbs[0].cloud_deployment.default_cfg_dir

    vcu_config_file = os.path.join(config_path, 'vcu-cnf.yaml')

    if not os.path.exists(vcu_config_file):
        logger.warning('VCU Configuration file not found [{}]'.format(vcu_config_file))

    with open(vcu_config_file, 'r') as stream:
        vcu_config_data = yaml.safe_load(stream)

    try:
        ip_info = vcu_config_data['global']['externalNetwork']['f1u']['ipInfo'][0]
    except KeyError:
        logger.warning('Error getting gateway for TTI Traces: '
                       'No f1u ipInfo found in external Network Data of CU!')
        return ''

    return ip_info['rangeStart']
