"""
Helping Python Resource for tti trace collection.
"""
import time
import re
import os
import logging
import json
import yaml
from itertools import islice

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem

# TAF & UTE Libraries:
from taf.converters.eventdecoder import EventDecoderConverter
from taf.converters.eventdecoder import EventDecoderConverterFactory

from taf.analyzer.ttitrace import TtitraceReader
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec

logger = logging.getLogger()
rbi = BuiltIn()


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console("  %s: exception happened (see log.html)" % functionNameStr)


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
        source_ip = search_object.string[search_object.span()[
            0]+5:search_object.span()[1]]
    except AttributeError:
        logging.warning(
            "Did not recieve usable input -AttributeError-, defaulting to ip 10.0.1.2")
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
        data.append(
            {item.simple_parameter.name: item.simple_parameter.value for item in route.structure_parameters})
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
        logger.warning(
            'VCU Configuration file not found [{}]'.format(vcu_config_file))

    with open(vcu_config_file, 'r') as stream:
        vcu_config_data = yaml.safe_load(stream)

    try:
        ip_info = vcu_config_data['global']['externalNetwork']['f1u']['ipInfo'][0]
    except KeyError:
        logger.warning('No f1u ip information found in testline configuration.'
                       'Using hard coded 127.16.2.101 as gateway for tti tracing')
        return '172.16.2.101'

    return ip_info['rangeStart']


def decode_tti_traces_using_TtitraceReaderEvtDec(desired_storage_directory="",
                                                 desired_file_name="ttitrace_streaming.pcap",
                                                 num_of_events=None):
    # ------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console("TTI Trace decoding .", no_newline=True)
    if not desired_storage_directory:
        desired_storage_directory = rbi.run_keyword("Get tc log directory")
    pcapPathName = desired_storage_directory + "/" + desired_file_name
    rbi.log("decode_tti_traces(): pcapPathName = %s" % pcapPathName)
    udpPathName = pcapPathName.replace(".pcap", ".udp")
    basicName = pcapPathName.replace(".pcap", "")
    jsonPathName = pcapPathName.replace(".pcap", ".json")
    if num_of_events is not None:
        num_of_events = int(num_of_events)
    if os.path.exists(pcapPathName) and os.path.getsize(pcapPathName) > 24:
        try:
            rbi.log_to_console(".1.", no_newline=True)
            cmdStr1 = "tshark -r %s --disable-protocol swe --disable-protocol syscom -T fields -e data" % pcapPathName
            cmdStr2 = " | perl -0ne's/\\n//g;print pack\"H*\",$_' > %s" % udpPathName
            cmdStr = cmdStr1 + cmdStr2
            rbi.log("decode_tti_traces(): cmdStr = %s" % cmdStr)
            stdoutStr = os.system(cmdStr)
            rbi.log("decode_tti_traces(): stdoutStr = %s" % stdoutStr)
            rbi.log_to_console(".2.", no_newline=True)
        except Exception as e:
            logException("decode_tti_traces [1]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log("decode_tti_traces(): udpPathName = %s (%s)" % (udpPathName, os.path.getsize(udpPathName)))
    if os.path.exists(pcapPathName) and os.path.getsize(pcapPathName) > 24:
        try:
            rbi.log_to_console(".3.", no_newline=True)
            tti_dec_path = "/opt/tti-dec/tti-dec-bin/"
            jsonDecoder = EventDecoderConverterFactory().create(configuration=dict(input_file_path=pcapPathName,
                                                                                   output_file_path=basicName,
                                                                                   output_file_format="json",
                                                                                   tti_dec_path=tti_dec_path),
                                                                existing_arguments={})
            jsonDecoder.convert()
            rbi.log_to_console(".4.", no_newline=True)
        except Exception as e:
            logException("decode_tti_traces [2]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log("decode_tti_traces(): jsonPathName = %s (%s)" % (jsonPathName, os.path.getsize(jsonPathName)))
    if os.path.exists(jsonPathName) and os.path.getsize(jsonPathName) > 24:
        try:
            # os.system("rm %s >/dev/null 2>&1" % pcapPathName)
            rbi.log_to_console(".5.", no_newline=True)
            file_name = jsonPathName
            msgFile_all = open(desired_storage_directory + "/msg_all.csv", "w")
            with open(file_name, 'rb') as file_obj:
                startTime = int(time.time())
                msgFile_all.write("-;" * 10 + "\n")
                for event in islice(TtitraceReaderEvtDec(file_obj=file_obj), num_of_events):
                    if event.type != "ttiStartInd":
                        outStr = str(event.type) + ";" + repr(event.data) + "\n"
                        outStr = outStr.replace("{u'", "").replace(" u'", "")
                        outStr = outStr.replace("{", "").replace("}", "").replace(" ", "")
                        outStr = outStr.replace("[", "").replace("]", "").replace("'", "")
                        outStr = outStr.replace(":", ";").replace(",", ";")
                        msgFile_all.write(outStr)
            msgFile_all.close()
            rbi.log_to_console(".6.", no_newline=True)
            os.system("zip -mj %s/ttiTrace_stream_udp.zip %s >/dev/null 2>&1" % (desired_storage_directory,
                                                                                 udpPathName))
            os.system("zip -mj %s/ttiTrace_stream_json.zip %s >/dev/null 2>&1" % (desired_storage_directory,
                                                                                  jsonPathName))
        except Exception as e:
            logException("decode_tti_traces [3]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log_to_console(".done")
    return msgFile_all
