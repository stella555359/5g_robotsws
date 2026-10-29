from .helpers import *
from .operations import *
from collections import OrderedDict
import re
import datetime


def get_start_registration_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    # 20.03.2019 - Multiple operations supported
    messages = ["startRegistration", "startRegistrationResponse", "completeRegistration"]
    frames = OrderedDict()
    list_of_frames = []
    port = None
    for k, v in json_data.items():
        params = v["xml_data"][0]
        par = params.keys()[0]
        if par.split("--")[0] == messages[0] and len(frames) == 0:
            frames[k] = v
            port = v["source_port"]
        elif par.split("--")[0] == messages[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == messages[2]:
            frames[k] = v
        if len(frames) == len(messages):
            list_of_frames.append(frames)
            frames = OrderedDict()
    print("xxx: list of frames is: {}".format(list_of_frames))
    return list_of_frames


def get_start_registration_unauthorized_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    # Only for single registration in json_data
    messages = ["startRegistration", "Fault"]
    start_registration_frames = {}
    for k, v in json_data.items():
        for param in v["xml_data"][0]:
            if param.split("--")[0] in messages:
                start_registration_frames[k] = v
                break
    return [start_registration_frames]


def get_start_registration_fail_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    return [json_data]


def get_start_registration_error_500_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    # Only for single registration in json_data
    messages = ["startRegistration", "startRegistrationResponse", "completeRegistration", "Fault"]
    start_registration_frames = {}
    for k, v in json_data.items():
        for param in v["xml_data"][0]:
            if param.split("--")[0] in messages:
                start_registration_frames[k] = v
                break
    return [start_registration_frames]


def get_registration_with_wrong_vendor_CA_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    msg = ["startRegistration", "startRegistrationResponse", "completeRegistration", "Fault"]
    frames = OrderedDict()
    for k, v in json_data.items():
        for param in v["xml_data"][0]:
            if param.split("--")[0] in msg:
                frames[k] = v
                break
    return [frames]


def get_start_session_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    # 21.03.2019 -  multiple operations supported
    level = kwargs.get('level', 'basic')
    messages = ["startSession", "startSessionResponse"]
    frames = OrderedDict()
    list_of_frames = []
    port = None
    for k, v in json_data.items():
        params = v["xml_data"][0]
        par = params.keys()[0]
        if par.split("--")[0] == messages[0] and len(frames) == 0:
            frames[k] = v
            port = v["source_port"]
        elif par.split("--")[0] == messages[1] and v["destination_port"] == port:
            frames[k] = v
        if len(frames) == len(messages):
            list_of_frames.append(frames)
            frames = OrderedDict()
    if level == "advanced":
        start_registration_frames = get_start_registration_frames(json_data)
        for frame in list_of_frames:
            index = list_of_frames.index(frame) if len(start_registration_frames) == len(list_of_frames) else 0
            frame.update(start_registration_frames[index])
    return list_of_frames


def get_start_session_frames_per_manager(man_frames, enb):
    """author: Anna Bien"""
    errors = []
    port = None
    oper_id = enb
    print(oper_id)
    start_frames = OrderedDict()

    start_length = len(man_frames)
    # append start_session frames at the beginning
    for k, v in man_frames.items():
        for param in v["xml_data"][0].items():
            if re.match("startSession--sessionId", param[0]):
                port = v["source_port"]
                if oper_id not in man_frames.keys():
                    start_frames[oper_id] = OrderedDict({k: v})
                else:
                    start_frames[oper_id].update({k: v})
            elif re.match("startSessionResponse--.*", param[0]) and v["destination_port"] == port:
                if oper_id not in man_frames.keys():
                    start_frames[oper_id] = OrderedDict({k: v})
                else:
                    start_frames[oper_id].update({k: v})
    # for key in enb_frames.keys():
    #     frams = []
    #     for i in range(0, len(enb_frames[key])):
    #         frams.append(enb_frames[key].items()[i][0])
    #     print(key, len(enb_frames[key]), frams)
    if len(man_frames) == start_length:
        errors.append("No start frames found!")
    return [errors, man_frames]


def get_sw_upload_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    level = kwargs.get('level', 'basic')
    msg = ["upload", "uploadResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0] and param.get("upload--filter--objectClass") == "NetworkSoftware":
            frames[k] = v
            oper_id = param["upload--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_cm_download_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["download", "downloadResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            oper_id = param["download--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_cm_activate_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["activate", "activateResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            oper_id = param["activate--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_cm_upload_frames(json_data, *args, **kwargs):
    """author: Anna Bien"""
    level = kwargs.get('level', 'basic')
    msg = ["upload", "uploadResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = []
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = list(param.keys())[0]
        if par.split("--")[0] == msg[0] and param["upload--filter--uploadType"] == "configuration":
            frames[k] = v
            oper_id.append(param["upload--operationId"])
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] in oper_id and \
                param["reportOperationStatus--attachmentProperties--contentType"] == "feedback":
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_cm_upload_netact_frames(json_data, *args, **kwargs):
    """author: Anna Bien"""
    level = kwargs.get('level', 'basic')
    msg = ["upload", "uploadResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    reg_id = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            reg_id = re.match(r".*_(\d*)", param["upload--managerRegistrationId"]).group(1)
            oper_id = param["upload--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port\
                and re.match(r".*_(\d*)", param["uploadResponse--agentRegistrationId"]).group(1) == reg_id:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id\
                and re.match(r".*_(\d*)", param["reportOperationStatus--agentRegistrationId"]).group(1) == reg_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2\
                and re.match(r".*_(\d*)", param["reportOperationStatusResponse--managerRegistrationId"])\
                .group(1) == reg_id:
            frames[k] = v
    return [frames]


def get_alarm_new_event_notification_for_cell_blocked_frames(json_data, *args, **kwargs):
    """author: Anna Bien"""
    # Only for single registration in json_data
    msg = ["transferNotification", "alarmNew", "transferNotificationResponse"]
    frames = OrderedDict()
    src_port = None
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            try:
                param_2 = v["xml_data"][1]
                par_2 = param_2.keys()[0]
                if param_2 and par_2.split("--")[0] == msg[1]:
                    frames[k] = v
                    src_port = v["source_port"]
            except IndexError:
                pass
        elif par.split("--")[0] == msg[2] and v["destination_port"] == src_port:
            frames[k] = v
    return [frames]


def get_alarm_cleared_event_notification_for_cell_blocked_frames(json_data, *args, **kwargs):
    """author: Anna Bien"""
    # Only for single registration in json_data
    msg = ["transferNotification", "alarmCleared", "transferNotificationResponse"]
    frames = OrderedDict()
    src_port = None
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            try:
                param_2 = v["xml_data"][1]
                par_2 = param_2.keys()[0]
                if param_2 and par_2.split("--")[0] == msg[1]:
                    frames[k] = v
                    src_port = v["source_port"]
            except IndexError:
                pass
        elif par.split("--")[0] == msg[2] and v["destination_port"] == src_port:
            frames[k] = v
    return [frames]


def get_alarm_upload_frames(json_data, *args, **kwargs):
    msg = ["upload", "uploadResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frame = OrderedDict()
    upload_id = None
    src_ip_1 = None
    src_port_1 = None
    src_ip_2 = None
    src_port_2 = None
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            tmp_upload_id = None
            for parameter in param:
                if parameter == "upload--operationId":
                    tmp_upload_id = param[parameter]
                elif parameter == "upload--filter--uploadType" and param[parameter] == "active_faults":
                    src_ip_1 = v["source"]
                    src_port_1 = v["source_port"]
                    frame[k] = v
            if k in frame.keys():
                upload_id = tmp_upload_id
        elif par.split("--")[0] == msg[1] and v["destination"] == src_ip_1 and v["destination_port"] == src_port_1:
            frame[k] = v
        elif par.split("--")[0] == msg[2] and v["destination"] == src_ip_1:
            for parameter in param:
                if parameter == "reportOperationStatus--operationId" and param[parameter] == upload_id:
                    src_ip_2 = v["source"]
                    src_port_2 = v["source_port"]
                    frame[k] = v
        elif par.split("--")[0] == msg[3] and v["destination"] == src_ip_2 and v["destination_port"] == src_port_2:
            frame[k] = v
    return [frame]


def get_rebuild_notification_frames(json_data, *args, **kwargs):
    """author: Anna Bien"""
    msg = ["transferNotification", "transferNotificationResponse", "upload", "uploadResponse",
           "reportOperationStatus", "reportOperationStatusResponse"]
    frame = OrderedDict()
    upload_id = None
    dest_ip_1 = None
    dest_port_1 = None
    dest_ip_2 = None
    src_ip_1 = None
    src_port_1 = None
    src_port_2 = None
    rebuild_notif_time = None
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            for parameter in param:
                if parameter == "transferNotification--notificationType" and \
                        param[parameter] == "ne3s_fm_rebuildNotification":
                    rebuild_notif_time = datetime.datetime.strptime(v["time_UTC"], '%Y-%m-%d %H:%M:%S.%f')
                    dest_ip_1 = v["destination"]
                    src_port_1 = v["source_port"]
                    frame[k] = v
                elif parameter == "transferNotification--notificationType" and \
                        param[parameter] == "ne3s_fm_alarmEventNotification":
                    alarm_status = v["xml_data"][1].keys()
                    if alarm_status[0].split("--")[0] == "alarmNew":
                        frame[k] = v
                    else:
                        alarmId = v["xml_data"][1]["alarmCleared--alarmId"]
                        for frame_el in reversed(frame.keys()):
                            if frame[frame_el]["xml_data"][1].get("alarmNew--alarmId") == alarmId:
                                del frame[frame_el]
                                break
        elif par.split("--")[0] == msg[1] and v["source"] == dest_ip_1 and v["destination_port"] == src_port_1:
            frame[k] = v
        elif par.split("--")[0] == msg[2]:
            tmp_upload_id = None
            upload_time = datetime.datetime.strptime(v["time_UTC"], '%Y-%m-%d %H:%M:%S.%f')
            try:
                if upload_time < rebuild_notif_time:
                    continue
            except TypeError:
                continue
            for parameter in param:
                if parameter == "upload--operationId":
                    tmp_upload_id = param[parameter]
                elif parameter == "upload--filter--uploadType" and param[parameter] == "active_faults":
                    dest_ip_2 = v["destination"]
                    dest_port_1 = v["destination_port"]
                    frame[k] = v
            if k in frame.keys():
                upload_id = tmp_upload_id
        elif par.split("--")[0] == "Fault" and v["source"] == dest_ip_2 and v["source_port"] == dest_port_1:
            for frame_el in reversed(frame.keys()):
                if frame[frame_el]["xml_data"][0].get("upload--operationId") == upload_id:
                    del frame[frame_el]
                    break
            upload_id = None
        elif par.split("--")[0] == msg[3] and v["source"] == dest_ip_2 and v["source_port"] == dest_port_1:
            frame[k] = v
        elif par.split("--")[0] == msg[4] and v["source"] == dest_ip_2:
            for parameter in param:
                if parameter == "reportOperationStatus--operationId" and param[parameter] == upload_id:
                    src_ip_1 = v["source"]
                    src_port_2 = v["source_port"]
                    frame[k] = v
        elif par.split("--")[0] == msg[5] and v["destination"] == src_ip_1 and v["destination_port"] == src_port_2:
            frame[k] = v
    return [frame]


def get_send_CCN_2_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski
    Multiple operations supported
    """

    level = kwargs.get('level', 'basic')
    msg = ["transferNotification", "reportOperationStatusResponse"]
    frames = OrderedDict()
    list_of_frames = []
    port = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0] and \
                param.get("transferNotification--notificationType") == "ne3s_common_changeNotification":
            frames[k] = v
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        if len(frames) == len(msg):
            list_of_frames.append(frames)
            frames = OrderedDict()
    return list_of_frames


def get_swm_provision_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["provision", "provisionResponse", "reportOperationStatus", "reportOperationStatusResponse",
           "transferNotification", "transferNotificationResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    port_transferNotification = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            oper_id = param["provision--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
        elif par.split("--")[0] == msg[4] and len(v["xml_data"]) == 2 and \
                ("Download completed" in v["xml_data"][1].values() or "onAir" in v["xml_data"][1].values()):
            frames[k] = v
            port_transferNotification = v["source_port"]
        elif par.split("--")[0] == msg[5] and v["destination_port"] == port_transferNotification:
            frames[k] = v
    return [frames]


def get_send_CCN_frames(json_data, *args, **kwargs):
    """author: Anna Bien"""
    # Only for single registration in json_data
    msg = ["transferNotification", "cmData", "reportOperationStatusResponse"]
    frames = OrderedDict()
    src_port = None
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            try:
                param_2 = v["xml_data"][1]
                par_2 = param_2.keys()[0]
                if param_2 and par_2.split("--")[0] == msg[1]:
                    frames[k] = v
                    src_port = v["source_port"]
            except IndexError:
                pass
        if par.split("--")[0] == msg[2] and v["destination_port"] == src_port:
            frames[k] = v
    return [frames]


def get_sw_rollback_frames(json_data, *args, **kwargs):
    """author: Anna Bien """
    level = kwargs.get('level', 'basic')
    msg = ["provision", "provisionResponse", "reportOperationStatus", "reportOperationStatusResponse",
           "transferNotification", "transferNotificationResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    port_3 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            oper_id = param["provision--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
        elif par.split("--")[0] == msg[4]:
            for parameter in param:
                if parameter == "transferNotification--notificationType" and \
                        param[parameter] == "ne3s_common_changeNotification":
                    port_3 = v["source_port"]
                    frames[k] = v
        elif par.split("--")[0] == msg[5] and v["destination_port"] == port_3:
            frames[k] = v
    return [frames]


def get_cm_provision_mandatory_parameters_missing_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["provision", "provisionResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            oper_id = param["provision--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_cm_provision_wrong_raml_version_frames(json_data, *args, **kwargs):
    """author: Anna Bien"""
    level = kwargs.get('level', 'basic')
    msg = ["provision", "provisionResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            oper_id = param["provision--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_reregister_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    msg = ["reregister", "reregisterResponse"]
    frames = OrderedDict()
    for k, v in json_data.items():
        for param in v["xml_data"][0]:
            if param.split("--")[0] in msg:
                frames[k] = v
                break
    return [frames]


def get_asc_notification_frames(json_data, *args, **kwargs):
    """
    author: Marek Piotrowski

    :param json_data:   {}
    :param args:
    :param kwargs:
    :return:            [ [{<frames>}, {<frames>}, ...] ]
    """
    level = kwargs.get('level', 'basic')
    messages = ["transferNotification", "transferNotificationResponse"]
    frames = OrderedDict()
    list_of_frames = []
    port = None
    for k, v in json_data.items():
        params = OrderedDict()
        for i in v["xml_data"]:
            params.update(i)
        par = list(params.keys())[0]
        if par.split("--")[0] == messages[0] and ("autoConfStatus" in params.values()):
            frames[k] = v
            port = v["source_port"]
        elif par.split("--")[0] == messages[1] and v["destination_port"] == port:
            frames[k] = v
        if len(frames) == len(messages):
            list_of_frames.append(frames)
            frames = OrderedDict()
    if level == "advanced":
        start_registration_frames = get_start_registration_frames(json_data)
        for frame in list_of_frames:
            index = list_of_frames.index(frame) if len(start_registration_frames) == len(list_of_frames) else 0
            frame.update(start_registration_frames[index])
    return [list_of_frames]  # yes, list inside list. poniewaz chcemy przekazac do f-cji validujacej
    # wszystkie instancje tej wiadomosci


def get_pnp_parameters_upload_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["upload", "uploadResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    found = [False, False, False, False]
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0] and not found[0]:
            for parameter in param:
                if parameter == "upload--filter--objects--sdn" and param[parameter] == "*":
                    frames[k] = v
                    oper_id = param["upload--operationId"]
                    port = v["source_port"]
                    found[0] = True
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port and not found[1]:
            frames[k] = v
            found[1] = True
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id and not found[2]:
            for parameter in param:
                if parameter == "reportOperationStatus--attachmentProperties--contentType" and \
                        param[parameter] == "feedback":
                    frames[k] = v
                    port_2 = v["source_port"]
                    found[2] = True
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2 and not found[3]:
            frames[k] = v
            found[3] = True
    return [frames]


def get_cm_provision_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["provision", "provisionResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            oper_id = param["provision--operationId"]
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_pnp_provision_frames(json_data, *args, **kwargs):
    """author: Marek Piotrowski"""
    level = kwargs.get('level', 'basic')
    msg = ["provision", "provisionResponse", "reportOperationStatus", "reportOperationStatusResponse"]
    frames = OrderedDict()
    oper_id = None
    port = None
    port_2 = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            try:
                if "cmData--managedObject--p" in v["xml_data"][1]:
                    frames[k] = v
                    oper_id = param["provision--operationId"]
                    port = v["source_port"]
            except IndexError:
                pass
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
        elif par.split("--")[0] == msg[2] and param["reportOperationStatus--operationId"] == oper_id:
            frames[k] = v
            port_2 = v["source_port"]
        elif par.split("--")[0] == msg[3] and v["destination_port"] == port_2:
            frames[k] = v
    return [frames]


def get_unregister_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["unregister", "unregisterResponse"]
    frames = OrderedDict()
    port = None
    if level == "advanced":
        for frame in get_start_registration_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0]:
            frames[k] = v
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
    return [frames]


def get_pm_upload_basic_notification_frames(json_data, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    msg = ["transferNotification", "transferNotificationResponse"]
    frames = OrderedDict()
    port = None
    if level == "advanced":
        for frame in get_start_session_frames(json_data, level=level):
            frames.update(frame)
    for k, v in json_data.items():
        param = v["xml_data"][0]
        par = param.keys()[0]
        if par.split("--")[0] == msg[0] and param.get("transferNotification--queueId") == "pm_queue":
            frames[k] = v
            port = v["source_port"]
        elif par.split("--")[0] == msg[1] and v["destination_port"] == port:
            frames[k] = v
    return [frames]
