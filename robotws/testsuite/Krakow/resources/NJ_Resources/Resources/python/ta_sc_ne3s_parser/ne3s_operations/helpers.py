"""
:copyright: Nokia Networks
:author: Marek Piotrowski
:contact: marek.piotrowski@nokia.com
"""

from robot.api import logger
import re
import os
import ute_fsmaccess
from xml.etree import ElementTree as ET
from collections import OrderedDict
import inspect


def get_param_value_from_json(json_data_single_op, parameter, max_range=1):
    """
    Function for finding value of given parameter in json file, e.g.: startRegistration--managerIdentity--uniqueId

    :return:
    """
    # logger.debug("Parsing json for parameter: {} - start".format(parameter))
    found = None
    errors = []
    index = 0
    for frame_nbr, frame_val in json_data_single_op.items():
        # while index < max_range:
        if type(frame_val["xml_data"]) is list:  # workaround
            for par, par_value in frame_val["xml_data"][0].items():
                # print("par: {}, parameter: {}".format(par, parameter))
                if par == parameter:
                    found = {par: par_value}
                    logger.debug("Parameter: {}. Value: {}".format(parameter, par_value))
                    break
            if found:
                break
            try:
                for par, par_value in frame_val["xml_data"][1].items():
                    # print("par: {}, parameter: {}".format(par, parameter))
                    if par == parameter:
                        found = {par: par_value}
                        logger.debug("Parameter: {}. Value: {}".format(parameter, par_value))
                        break
                if found:
                    break
            except IndexError:
                continue
    if not found:
        logger.debug("Parameter value not found: {}".format(parameter))
        errors = ["Parameter value not found: {}".format(parameter)]
    # logger.debug("Parsing json for parameter: {} - end".format(parameter))
    return [found, errors]


def get_alarm_value_from_json(json_data_single_frame, parameter, max_range=1):
    """
    Function for finding value of given parameter in json file, e.g.: startRegistration--managerIdentity--uniqueId

    :return:
    """
    # logger.debug("Parsing json for parameter: {} - start".format(parameter))
    found = None
    errors = []
    alarms = []
    print("---------------------------------------------------")
    for frame_nbr, frame_val in json_data_single_frame.items():
        print("---------------frame: {}".format(frame_nbr))
        alarm_new = {}
        if type(frame_val["xml_data"]) is list:  # workaround
            try:
                for par_2, par_value_2 in frame_val["xml_data"][1].items():

                    if par_2 == "alarmNew":
                        for item in par_value_2:
                            for k, v in item.items():
                                if k == parameter:
                                    print({k: v["text"]})
                                # print(alarm_new)
                        break
                    break

            except IndexError:
                continue
            if found:
                break
        alarms.append(alarm_new)
        # print(alarms)
        # index += 1
    if not found:
        logger.debug("Parameter value not found: {}".format(parameter))
        errors = ["Parameter value not found: {}".format(parameter)]
    # logger.debug("Parsing json for parameter: {} - end".format(parameter))
    return [found, errors]


def get_message_values_from_json(json_data_single_op, messages, max_range=1):
    parameter_values = {}
    errors = []
    for k, v in messages.items():
        for parameter, value in v.items():
            found, err = get_param_value_from_json(json_data_single_op, parameter, max_range)
            if found:
                parameter_values.update(found)
            errors.extend(err)
    return [parameter_values, errors]


def get_alarm_new_values_from_json(json_data_single_op, messages, max_range=1):
    parameter_values = {}
    errors = []
    for k, v in messages.items():
        for parameter, value in v.items():
            # print(parameter, value)
            found, err = get_param_value_from_json(json_data_single_op, parameter, max_range)
            print(parameter)
            if found:
                parameter_values.update(found)
            errors.extend(err)
    return [parameter_values, errors]


def get_message_values_from_json_netact(json_data_single_op, messages):
    # for frame in json_data_single_op:
    #     print(frame)
    parameter_values = dict()
    errors = []
    unique_messages = ['upload', 'uploadResponse', 'reportOperationStatusResponse',
                       'transferNotification', 'transferNotificationResponse']
    for k, v in messages.items():
        found = OrderedDict()
        for parameter, value in v.items():
            message_type = parameter.split('--')[0]
            if message_type in unique_messages:
                for frame_nbr, frame_val in json_data_single_op.items():
                    if not found:
                        if type(frame_val["xml_data"]) is list:  # workaround
                            for par, par_value in frame_val["xml_data"][0].items():
                                if par.split('--')[0] == message_type:
                                    found.update({par: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                                # try:
                                #     for par, par_value in frame_val["xml_data"][1].items():
                                #         found.update({par: par_value})
                                #         logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                                # except IndexError:
                                #     pass
            elif k == "reportOperationStatus":
                for frame_nbr, frame_val in json_data_single_op.items():
                    if not found:
                        if type(frame_val["xml_data"]) is list and \
                                'reportOperationStatus' == frame_val["xml_data"][0].keys()[0].split('--')[0]:
                            if frame_val["xml_data"][0]["reportOperationStatus--pageSequenceNumber"] == '1':
                                for par, par_value in frame_val["xml_data"][0].items():
                                    found.update({par: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                                try:
                                    for par, par_value in frame_val["xml_data"][1].items():
                                        found.update({par: par_value})
                                        logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                                except IndexError:
                                    pass
            elif k == "reportOperationStatus_feedback":
                for frame_nbr, frame_val in json_data_single_op.items():
                    if not found:
                        if type(frame_val["xml_data"]) is list and \
                                'reportOperationStatus' == frame_val["xml_data"][0].keys()[0].split('--')[0]:
                            if frame_val["xml_data"][0]["reportOperationStatus--pageSequenceNumber"] == '2':
                                for par, par_value in frame_val["xml_data"][0].items():
                                    found.update({par: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
        parameter_values.update({k: found})
    return [parameter_values, errors]


def get_message_values_from_json_for_rebuild_notification(json_data_single_op, messages):
    parameter_values = dict()
    errors = []
    alarms = dict()
    unique_messages = ['upload', 'uploadResponse', 'reportOperationStatusResponse', 'transferNotificationResponse']
    for k, v in messages.items():
        found = OrderedDict()
        for parameter, value in v.items():
            message_type = parameter.split('--')[0]
            if message_type in unique_messages:
                for frame_nbr, frame_val in json_data_single_op.items():
                    if not found:
                        if type(frame_val["xml_data"]) is list:  # workaround
                            for par, par_value in frame_val["xml_data"][0].items():
                                if par.split('--')[0] == message_type:
                                    found.update({par: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
            elif k == "reportOperationStatus":
                for frame_nbr, frame_val in json_data_single_op.items():
                    if not found:
                        if type(frame_val["xml_data"]) is list and \
                                'reportOperationStatus' == frame_val["xml_data"][0].keys()[0].split('--')[0]:
                            if frame_val["xml_data"][0]["reportOperationStatus--pageSequenceNumber"] == '1':
                                for par, par_value in frame_val["xml_data"][0].items():
                                    found.update({par: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                                try:
                                    for par, par_value in frame_val["xml_data"][1].items():
                                        found.update({par: par_value})
                                        logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                                except IndexError:
                                    pass
            elif k == "reportOperationStatus_feedback":
                for frame_nbr, frame_val in json_data_single_op.items():
                    if not found:
                        if type(frame_val["xml_data"]) is list and \
                                'reportOperationStatus' == frame_val["xml_data"][0].keys()[0].split('--')[0]:
                            if frame_val["xml_data"][0]["reportOperationStatus--pageSequenceNumber"] == '2':
                                for par, par_value in frame_val["xml_data"][0].items():
                                    found.update({par: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
            elif k == "transferNotification":
                for frame_nbr, frame_val in json_data_single_op.items():
                    if type(frame_val["xml_data"]) is list and \
                            'transferNotification' == frame_val["xml_data"][0].keys()[0].split('--')[0]:
                        if frame_val["xml_data"][0]["transferNotification--notificationType"] == \
                                'ne3s_fm_rebuildNotification':
                            for par, par_value in frame_val["xml_data"][0].items():
                                found.update({par: par_value})
                                logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                            try:
                                for par, par_value in frame_val["xml_data"][1].items():
                                    found.update({par: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                            except IndexError:
                                pass
                        elif frame_val["xml_data"][0]["transferNotification--notificationType"] == \
                                'ne3s_fm_alarmEventNotification':
                            alarmId = frame_val["xml_data"][1]["alarmNew--alarmId"]
                            try:
                                for par, par_value in frame_val["xml_data"][1].items():
                                    alarms.update({par+'--'+alarmId: par_value})
                                    logger.debug("Parameter: {}. Value: {}.".format(par, par_value))
                            except IndexError:
                                pass
        parameter_values.update({k: found})
    parameter_values['reportOperationStatus'].update(alarms)
    return [parameter_values, errors]


def validate_messages(messages, parameter_values):
    errors = []
    msg = None
    for k, v in messages.items():
        for parameter, value in v.items():
            if value:
                try:
                    value = parameter_values[re.sub("[<>]", "", value)] if re.match("<.*>", value) else value
                    a = parameter_values.get(parameter)
                    if not a:
                        msg = "Parameter: {} not found!".format(parameter)
                        # errors.append(msg)
                    elif a == value:
                        msg = "Parameter: {} has value: {} - correct".format(parameter, a)
                    elif a != value:
                        msg = "Parameter: {} has value: {}, but should be: {} !".format(parameter, a, value)
                        errors.append(msg)
                except TypeError:
                    errors.append("Unrecognized value: {}".format(value))
                logger.debug(msg)
                # print(msg)
    return errors


def validate_messages_netact(messages, parameter_values):
    errors = []
    msg = None
    for k, v in messages.items():
        for parameter, value in v.items():
            if value:
                if re.match("<.*>", value):
                    value = re.sub("[<>]", "", value)
                    for item in parameter_values.values():
                        if value in item.keys():
                            value = item[value]

                a = parameter_values[k].get(parameter)
                if not a:
                    msg = "Parameter: {} not found!".format(parameter)
                    errors.append(msg)
                elif a == value:
                    msg = "Parameter: {} has value: {} - correct".format(parameter, a)
                elif a != value:
                    msg = "Parameter: {} has value: {}, but should be: {} !".format(parameter, a, value)
                    errors.append(msg)
                # print(msg)
                logger.debug(msg)
    return errors


def get_sw_version(trs_ip='192.168.255.129', remote_host=None, prompt="#", partition='active', **kwargs):
    fsm_access = ute_fsmaccess.ute_fsmaccess()
    fsm_access.setup_enb_fsm_access(host=trs_ip, prompt=prompt, remote_host=remote_host,
                                    retry_timeout=60.0)
    sw_version = fsm_access.execute_command_on_enb('ls -rt /rom/TargetBD_[F,T]L[A,F]*xml | tail -1')
    fsm_access.teardown_enb_fsm_access()
    return sw_version.split("BD_")[1].rstrip(".xml")


def get_sw_release_version(trs_ip='192.168.255.129', remote_host=None, prompt="#", partition='active', **kwargs):
    sw_version = get_sw_version(trs_ip, remote_host, prompt, partition, **kwargs)
    sw_release_version = sw_version.split("_")[0]
    return sw_release_version


def get_msg_frames(json_data, message, *args, **kwargs):
    frames = {}
    for k, v in json_data.items():
        for param in v["xml_data"][0]:
            if param.split("--")[0] == message:
                frames[k] = v
                break
    return frames


def join_messages_per_instance(frames):
    joined_frames = []
    for k, v in frames[0].items():
        for k2, v2 in frames[1].items():
            if v2["destination_port"] == v["source_port"]:
                joined_frames.append({k: v, k2: v2})
    return joined_frames
#
#
# def get_start_session_frames_per_manager_id(manager, json_data_single_op):
#     parameter_values = {}
#     errors = []
#     for k, v in messages.items():
#         for parameter, value in v.items():
#             # print(parameter, value)
#             found, err = get_param_value_from_json(json_data_single_op, parameter)
#             if found:
#                 parameter_values.update(found)
#             errors.extend(err)
#     return [parameter_values, errors]


def get_netact_registered_managers(clab, trs_ip='192.168.255.129', remote_host=None, prompt="#", **kwargs):
    """
    Function for finding registered hw/cm manager's ID with netact

    """
    fsm_access = ute_fsmaccess.ute_fsmaccess()
    fsm_access.setup_enb_fsm_access(host=trs_ip, prompt=prompt, remote_host=remote_host, retry_timeout=60.0)
    manager_soc_files = fsm_access.execute_command_on_enb(
        'ls -rt /ffs/run/btsom/coma/working_dir/managers/NAS@{}*_soc.xml'.format(clab)).split('\n')
    registered_managers = {}
    for soc_file in manager_soc_files:
        filename = soc_file.rsplit('/')[-1]
        file_path = fsm_access.get_enb_file(soc_file, '/tmp/{}'.format(filename))
        tree = ET.parse(file_path)
        root = tree.getroot()
        soc_filename_hw = [filename for child in root for younger_child in child for youngest_child in younger_child if
                           child.get('name') == "HardwareManagement" and
                           younger_child.get('name') == "ne3s_common_supportedModel" and
                           younger_child.get('supported') == "true" and
                           youngest_child.get('value') == "com.nsn.mrbts.hw" and
                           youngest_child.get('name') == "adaptationIDs"]

        soc_filename_cm = [filename for child in root for younger_child in child for youngest_child in younger_child if
                           child.get('name') == "ConfigurationManagement" and
                           younger_child.get('name') == "ne3s_common_supportedModel" and
                           younger_child.get('supported') == "true" and
                           youngest_child.get('value') == "com.nokia.mrbts" and
                           youngest_child.get('name') == "adaptationIDs"]
        if not soc_filename_cm:
            hw_man_id = re.search(r'NAS@{}lbwas2Enetact2Ensn-rdnet2Enet_(\d*).*_soc.xml'.
                                  format(clab), soc_filename_hw[0]).group(1)
            registered_managers.update({'hw_manager': hw_man_id})
        if not soc_filename_hw:
            cm_man_id = re.search(r'NAS@{}lbwas2Enetact2Ensn-rdnet2Enet_(\d*).*_soc.xml'
                                  .format(clab), soc_filename_cm[0]).group(1)
            registered_managers.update({'cm_manager': cm_man_id})
    return registered_managers


def add_cmdata_for_sending_CCN_validation():
    cnn_data = []
    for id in range(1, 257):
        cnn_data.append({"cmData--planId--{}".format(id): None})
        cnn_data.append({"cmData--eventChangeOrigin--{}".format(id): None})
        # cnn_data.append({"cmData--x2LinkStatus--{}".format(id): "unavailable"})
    return cnn_data


def check_msg_quantity(json_data, msg, *args, **kwargs):
    """
    Function counts given 'msg' in json data.

    :param json_data:
    :param msg:
    :param args:
    :param kwargs:
    :return:    [<total_value>, {<frames_with_msg>}]
    """

    frames = {}
    for k, v in json_data.items():
        if (not v["xml_data"]) or v["xml_data"] == [{}]:
            logger.debug("{}: xml_data not found in frame:\n{}".format(inspect.currentframe().f_code.co_name, v))
            continue
        first_param = v["xml_data"][0].keys()[0]
        if re.match(msg + "--", first_param):
            frames.update(OrderedDict({k: v}))
    qty = len(frames)
    return [qty, frames]
