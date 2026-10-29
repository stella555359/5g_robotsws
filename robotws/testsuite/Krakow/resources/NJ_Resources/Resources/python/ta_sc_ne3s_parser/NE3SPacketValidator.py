"""
:copyright: Nokia Networks
:author: Marek Piotrowski
:contact: marek.piotrowski@nokia.com
"""

import robot.api.logger as logger
import ne3s_operations
import json
import re
from collections import OrderedDict


def import_json(json_filepath):
    """
    Function responsible for importing data from json file.

    :param json_filepath:       path to json file
    :type  json_filepath:       string

    :return:                    content of json file converted to python structure
    :rtype:                     dict
    """
    with open(json_filepath, "r") as json_file:
        json_data = json.load(json_file, object_pairs_hook=OrderedDict)
    return json_data


def group_frames_per_manager(json_data):
    """
    Function responsible for grouping frames per ne3s manager.

    :param json_data:       python structure of data
    :type  json_data:       dict

    :return:                {"<manager1_ip>": {<frames>}, ...}
    :rtype:                 dict
    """
    managers_frames = OrderedDict()     # {"<manager1_ip>": {<frames>}, ...}
    errors = []
    for k, v in json_data.items():
        if (not v["xml_data"]) or v["xml_data"] == [{}]:
            logger.debug("xml_data not found in frame:\n{}".format(v))
            continue
        first_param = list(v["xml_data"][0].keys())[0]

        if re.match("^POST /NE3S", v["data_type"]):
            if re.match("^reregister--", first_param):    # if true, frame was sent from agent
                if v["destination"] not in managers_frames.keys():
                    managers_frames[v["destination"]] = OrderedDict({k: v})
                else:
                    managers_frames[v["destination"]].update({k: v})
            else:   # frame was sent from manager
                if v["source"] not in managers_frames.keys():
                    managers_frames[v["source"]] = OrderedDict({k: v})
                else:
                    managers_frames[v["source"]].update({k: v})

        elif re.match("^POST /axis2", v["data_type"]):
            if v["destination"] not in managers_frames.keys():
                managers_frames[v["destination"]] = OrderedDict({k: v})
            else:
                managers_frames[v["destination"]].update({k: v})

        elif re.match("^HTTP", v["data_type"]):
            if re.match(".*--manager.*|softwareReleaseVersion|reregisterResponse", first_param):
                if v["source"] not in managers_frames.keys():
                    managers_frames[v["source"]] = OrderedDict({k: v})
                else:
                    managers_frames[v["source"]].update({k: v})
            elif re.match(".*--agent.*", first_param) or ("SOAP-ENV:Client" in v["xml_data"][0][first_param]):
                if v["destination"] not in managers_frames.keys():
                    managers_frames[v["destination"]] = OrderedDict({k: v})
                else:
                    managers_frames[v["destination"]].update({k: v})
        else:
            logger.error("Can't assign frame: {} to any NE3S Manager!".format(v))

    if not managers_frames:
        errors.append("No manager frames found!")
    else:
        logger.debug("Found {} manager(s)".format(len(managers_frames)))
    return [errors, managers_frames]


def group_frames_per_manager_id(json_data):
    """
    Function responsible for grouping frames per ne3s manager.

    :param json_data:       python structure of data
    :type  json_data:       dict

    :return:                {"<manager1_ip>": {<frames>}, ...}
    :rtype:                 dict
    """
    managers_frames = OrderedDict()     # {"<manager1_id>": {<frames>}, ...}
    start_session_frames = OrderedDict()
    errors = []
    for k, v in json_data.items():
        for param in v["xml_data"][0].items():
            if re.match("upload.*RegistrationId", param[0]) \
             or re.match("reportOperationStatus.*RegistrationId", param[0]):
                if 'emssim' not in param[1].lower():
                    manager_id = re.match(r".*_(\d*)", param[1]).group(1)
                    if manager_id not in managers_frames.keys():
                        managers_frames[manager_id] = OrderedDict({k: v})
                    else:
                        managers_frames[manager_id].update({k: v})
            if re.match("startSession.*RegistrationId", param[0]):
                if 'emssim' not in param[1].lower():
                    manager_id = re.match(r".*_(\d*)", param[1]).group(1)
                    if manager_id not in managers_frames.keys():
                        start_session_frames[manager_id] = OrderedDict({k: v})
                        managers_frames[manager_id] = OrderedDict({k: v})
                    else:
                        start_session_frames[manager_id].update({k: v})
                        managers_frames[manager_id].update({k: v})
    # for key in managers_frames.keys():
    #     frams = []
    #     for i in range(0, len(managers_frames[key])):
    #         frams.append(managers_frames[key].items()[i][0])
    #     print(key, len(managers_frames[key]),frams)
    #     logger.debug("{}, {}, {}".format(key, len(managers_frames[key]), frams))
    if not managers_frames:
        errors.append("No manager frames found!")
    return [errors, managers_frames, start_session_frames]


def group_frames_per_agent(json_data):

    """
    Function responsible for grouping frames per ne3s agent.

    :param json_data:       python structure of data
    :type  json_data:       dict

    :return:                {"<enb1_ip>": {<frames>}, ...}
    :rtype:                 dict
    """
    enb_frames = OrderedDict()     # {"<enb1_ip>": {<frames>}, ...}
    errors = []
    for k, v in json_data.items():
        if (not v["xml_data"]) or v["xml_data"] == [{}]:
            logger.debug("xml_data not found in frame:\n{}".format(v))
            continue
        first_param = list(v["xml_data"][0].keys())[0]

        if re.match("^POST /NE3S", v["data_type"]):
            first_param = list(v["xml_data"][0].keys())[0]
            if re.match("^reregister--", first_param):    # if true, frame was sent from agent
                if v["source"] not in enb_frames.keys():
                    enb_frames[v["source"]] = OrderedDict({k: v})
                else:
                    enb_frames[v["source"]].update({k: v})
            else:   # frame was sent from manager
                if v["destination"] not in enb_frames.keys():
                    enb_frames[v["destination"]] = OrderedDict({k: v})
                else:
                    enb_frames[v["destination"]].update({k: v})

        elif re.match("^POST /axis2", v["data_type"]):
            if v["source"] not in enb_frames.keys():
                enb_frames[v["source"]] = OrderedDict({k: v})
            else:
                enb_frames[v["source"]].update({k: v})

        elif re.match("^HTTP", v["data_type"]):
            if re.match(".*--manager.*|softwareReleaseVersion|reregisterResponse", first_param):
                if v["destination"] not in enb_frames.keys():
                    enb_frames[v["destination"]] = OrderedDict({k: v})
                else:
                    enb_frames[v["destination"]].update({k: v})
            elif re.match(".*--agent.*", first_param) or ("SOAP-ENV:Client" in v["xml_data"][0][first_param]):
                if v["source"] not in enb_frames.keys():
                    enb_frames[v["source"]] = OrderedDict({k: v})
                else:
                    enb_frames[v["source"]].update({k: v})
        else:
            logger.error("Can't assign frame: {} to any NE3S Agent!".format(v))

    if not enb_frames:
        errors.append("No agent frames found!")
    else:
        logger.debug("Found {} agent(s)".format(len(enb_frames)))
    return [errors, enb_frames]


def group_frames_per_agent_netact(json_data):

    """
    Function responsible for grouping frames per ne3s agent.

    :param json_data:       python structure of data
    :type  json_data:       dict

    :return:                {"<oper1_id>": {<frames>}, ...}
    :rtype:                 dict
    """
    enb_frames = OrderedDict()
    errors = []
    port = None
    port_2 = None
    oper_id = None
    for k, v in json_data.items():
        for param in v["xml_data"][0].items():
            if re.match("upload--operationId", param[0]):
                oper_id = param[1]
                port = v["source_port"]
                if oper_id not in enb_frames.keys():
                    enb_frames[oper_id] = OrderedDict({k: v})
                else:
                    enb_frames[oper_id].update({k: v})
            elif re.match("uploadResponse.*", param[0]) and v["destination_port"] == port:
                if oper_id not in enb_frames.keys():
                    enb_frames[oper_id] = OrderedDict({k: v})
                else:
                    enb_frames[oper_id].update({k: v})
            elif re.match("reportOperationStatus--operationId", param[0]):
                # and v["data_type"] == "POST /netact/cmmne3s/NE3SOperationNotificationService HTTP/1.1":
                oper_id = param[1]
                port_2 = v["source_port"]
                if oper_id not in enb_frames.keys():
                    enb_frames[oper_id] = OrderedDict({k: v})
                else:
                    enb_frames[oper_id].update({k: v})
            elif re.match("reportOperationStatusResponse.*", param[0]) and v["destination_port"] == port_2:
                if oper_id not in enb_frames.keys():
                    enb_frames[oper_id] = OrderedDict({k: v})
                else:
                    enb_frames[oper_id].update({k: v})
    # for key in enb_frames.keys():
    #     frams = []
    #     for i in range(0, len(enb_frames[key])):
    #         frams.append(enb_frames[key].items()[i][0])
    #     print(key, len(enb_frames[key]), frams)
    #     logger.debug("{}, {}, {}".format(key, len(enb_frames[key]), frams))
    if not enb_frames:
        errors.append("No agent frames found!")
    return [errors, enb_frames]


def get_frames_for_operation(json_data, operation_name, *args, **kwargs):
    """
    Function responsible for calling function for grouping frames per given ne3s operation name.

    :param json_data:           python structure of data
    :type  json_data:           string
    :param operation_name:      name of ne3s operation
    :type  operation_name:      string

    :return:                    frames for requested operation
    :rtype:                     list
    """
    errors = []
    try:
        operation = getattr(ne3s_operations, "get_" + operation_name + "_frames")
    except AttributeError:
        raise Exception("Unrecognized operation: {}".format(operation_name))
    frames = operation(json_data, *args, **kwargs)
    if not frames:
        errors.append("No frames for operation {} found!".format(operation_name))
    return [errors, frames]


def validate_single_operation(json_data_single_op, operation_name, *args, **kwargs):
    """
    Function responsible for calling function for validating given operation data.

    :param json_data_single_op:         python structure of data
    :type  json_data_single_op:         string
    :param operation_name:              name of ne3s operation
    :type  operation_name:              string
    :param level:                       "basic" or "advanced"
    :type  level:                       string

    :return:                            [errors, parameter_values]
    :rtype:                             list
    """
    alarms = kwargs.get("alarms", "")
    errors = []
    operation = getattr(ne3s_operations, operation_name)
    valid_results = operation(json_data_single_op, alarms, *args, **kwargs)
    if not valid_results:
        errors.append("Validation of operation {} failed!".format(operation_name))
    return [errors, valid_results]


def validate_operation(json_filepath, operation_name, *args, **kwargs):
    """
    Function responsible for validating given operation. Multiple instances of the same operation are supported.

    :param json_filepath:         path to json file
    :type  json_filepath:         string
    :param operation_name:        name of ne3s operation
    :type  operation_name:        string

    :return:                      [status, global_errors] or if KPI is True [status, global_errors, array_of_frames]
    :rtype:                       list
    """
    check_kwargs_correctness(**kwargs)
    KPI = kwargs.get("KPI", False)
    KPI = True if KPI == "True" or KPI is True else False
    array_of_frames = {}
    # level = kwargs.get("level", "basic")
    # alarms = kwargs.get("alarms", "")
    # asc_status = [int(i) for i in kwargs.get("asc_status").split(",")]
    global_errors = []
    json_data = import_json(json_filepath)

    mgr_output = group_frames_per_manager(json_data)
    global_errors.extend(mgr_output[0])
    for manager, man_frames in mgr_output[1].items():
        agent_output = group_frames_per_agent(man_frames)
        global_errors.extend(agent_output[0])
        for enb, enb_frames in agent_output[1].items():
            op_frames = get_frames_for_operation(enb_frames, operation_name, *args, **kwargs)
            if KPI:
                if manager not in array_of_frames.keys():
                    array_of_frames[manager] = []
                array_of_frames[manager].append({enb: op_frames[1]})
            global_errors.extend(op_frames[0])
            logger.debug("Found {} instance(s) of {} operation".format(len(op_frames[1]), operation_name))
            for item in op_frames[1]:
                msg_start = "---Validation operation: {}, for manager: {}, for agent: {}, for instance: {} - start---"\
                    .format(operation_name, manager, enb, op_frames[1].index(item))
                logger.debug(msg_start)
                logger.console(msg_start)

                valid_output = validate_single_operation(item, operation_name, *args, **kwargs)
                global_errors.extend(valid_output[0])
                if valid_output[1][0]:
                    for er in valid_output[1][0]:
                        msg = "[Operation: {}, Manager: {}, Agent: {}, Instance: {}] ".format(
                                     operation_name, manager, enb, op_frames[1].index(item)) + er
                        global_errors.append(msg)
                        # logger.error(msg)
                        # raise Exception("Several errors occurred during validation.")
                else:
                    logger.info("Validation finished without errors!", also_console=True)
                logger.debug("---Validation operation: {}, \
                for manager: {}, \
                for agent: {}, \
                for instance: {} - finish---".format(operation_name, manager, enb, op_frames[1].index(item)))
    logger.debug("All validation errors: \n" + str(global_errors))
    if not global_errors:
        status = "PASS"
    else:
        global_errors = list(OrderedDict.fromkeys(global_errors))   # to remove duplicates
        for err in global_errors:
            logger.error(err)
        status = "FAIL"

    if KPI:
        return [status, global_errors, array_of_frames]
    return [status, global_errors]


def validate_operation_with_netact(json_filepath, clab, operation_name, *args, **kwargs):
    """
    Function responsible for validating given operation.

    :param json_filepath:         path to json file
    :type  json_filepath:         string
    :param operation_name:        name of ne3s operation
    :type  operation_name:        string

    :return:                      [status, global_errors]
    :rtype:                       list
    """
    level = kwargs.get("level", "basic")
    global_errors = []
    json_data = import_json(json_filepath)
    mgr_output = group_frames_per_manager_id(json_data)
    global_errors.extend(mgr_output[0])
    if level == 'advanced':
        start_session_frames = mgr_output[2]
    registered_managers = ne3s_operations.get_netact_registered_managers(clab)
    logger.debug(registered_managers)
    for manager, man_frames in mgr_output[1].items():
        agent_output = group_frames_per_agent_netact(man_frames)
        global_errors.extend(agent_output[0])
        iteration = 0
        for enb, enb_frames in agent_output[1].items():

            # enb_frames = ne3s_operations.get_start_session_frames_per_manager(man_frames, enb)
            op_frames = get_frames_for_operation(enb_frames, operation_name, level=level, )
            if level == 'advanced':
                for start_frame in start_session_frames[manager].items():
                    op_frames[1][0].update([start_frame])
            global_errors.extend(op_frames[0])
            for item in op_frames[1]:
                if manager == registered_managers['cm_manager']:
                    logger.debug("Validate iteration {} \
                    for cm_manager------------------------------".format(iteration))
                elif manager == registered_managers['hw_manager']:
                    logger.debug("Validate iteration {} \
                    for hw_manager------------------------------".format(iteration))
                else:
                    logger.debug("Validate iteration {}".format(iteration))
                # item - all 6 frames per operation
                logger.debug("Validation operation: {}, for manager: {}, for agent: {}, for instance: {} - start"
                             .format(operation_name, manager, enb, op_frames[1].index(item)))
                valid_output = validate_single_operation(item, operation_name, manager, level=level, clab=clab)
                global_errors.extend(valid_output[0])
                if valid_output[1][0]:
                    for er in valid_output[1][0]:
                        msg = "[Operation: {}, Manager: {}, Agent: {}, Instance: {}] ".format(
                                        operation_name, manager, enb, op_frames[1].index(item)) + er
                        global_errors.append(msg)
                        logger.error(msg)
                        # raise Exception("Several errors occurred during validation.")
                else:
                    logger.info("Validation finished without errors!")
                logger.debug("Validation operation: {}, for manager: {}, for agent: {}, for instance: {} - finish"
                             .format(operation_name, manager, enb, op_frames[1].index(item)))
                iteration += 1
    logger.debug("All validation errors: \n" + str(global_errors))

    if not global_errors:
        status = "PASS"
    else:
        for err in global_errors:
            logger.error(err)
        status = "FAIL"
    return [status, global_errors]


def count_msg(json_filepath, msg, *args, **kwargs):
    """
    Function returning qty of 'msg' in given json file.

    :param json_filepath:   path to json file
    :param msg:             msg for count
    :param args:
    :param kwargs:
    :return:                [<total_value>, {<manager>: {<agent>: <val>, ...}, ...}]
    """
    json_data = import_json(json_filepath)
    level = kwargs.get("level", "basic")
    total = ne3s_operations.check_msg_quantity(json_data, msg)
    details = OrderedDict()
    if level == "basic":
        pass
    elif level == "advanced":
        mgr_output = group_frames_per_manager(total[1])
        for manager, man_frames in mgr_output[1].items():
            if manager not in details.keys():
                details[manager] = OrderedDict()
            agent_output = group_frames_per_agent(man_frames)
            for enb, enb_frames in agent_output[1].items():
                qty = ne3s_operations.check_msg_quantity(enb_frames, msg)
                details[manager].update(OrderedDict({enb: qty[0]}))
    return [total[0], details]


def check_kwargs_correctness(**kwargs):
    for param, val in kwargs.items():
        check_parameter_correctness(param, val)


def check_parameter_correctness(parameter, value, *args, **kwargs):
    if not value:
        raise Exception("Please provide some value(s) for parameter: {}".format(parameter))
    elif parameter == "level":
        level_allowed = ["basic", "advanced"]
        if value not in level_allowed:
            raise Exception("Unrecognized level: '{}'. Please use one of following value:  {}"
                            .format(value, level_allowed))
    elif parameter == "asc_status":
        pass
    elif parameter == "alarms":
        pass
    elif parameter == "KPI":
        pass
    #     try:
    #         a = [int(i) for i in value.split(",")]
    #     except ValueError:
    #         raise Exception("Incorrect format for parameter: {}. Example of use: asc_status=1,2,3".format(parameter))
    else:
        raise Exception("Unrecognized parameter: {}".format(value))
