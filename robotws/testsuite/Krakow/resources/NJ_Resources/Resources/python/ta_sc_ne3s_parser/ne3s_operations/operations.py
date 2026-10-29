from .helpers import *
import inspect
from .names import *
import json
from .get_op_frames import *


def start_registration(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    messages = {
        "startRegistration": {
            "startRegistration--managerNonce": None,
            "startRegistration--managerIdentity--uniqueId": None,
            "startRegistration--managerIdentity--type": Names.TYPE_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--release": None,
            "startRegistration--agentUniqueId": Names.AGENT_ID_1.value,
            "startRegistration--notificationConsumerURL": None,
            "startRegistration--reRegisterInterval": None,
            "startRegistration--soc": None
        },
        "startRegistrationResponse": {
            "startRegistrationResponse--agentIdentity--uniqueId": "<startRegistration--agentUniqueId>",
            "startRegistrationResponse--agentIdentity--type": Names.TYPE.value,  # Req ID: OM_GEN_SFS_ARCH.1860
            "startRegistrationResponse--agentIdentity--vendor": Names.VENDOR_1.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            # "startRegistrationResponse--agentIdentity--release":
            # get_sw_release_version(),  # Req ID: OM_GEN_SFS_ARCH.1862
            "startRegistrationResponse--agentResponse": None,
            "startRegistrationResponse--licenseRequired": None,
            "startRegistrationResponse--registrationComplete": Names.FALSE.value,
            "startRegistrationResponse--agentNonce": None,
            "startRegistrationResponse--agentCertificate": None,
        },
        "completeRegistration": {
            "completeRegistration--managerResponse": None,
            "completeRegistration--agentUniqueId": "<startRegistrationResponse--agentIdentity--uniqueId>",
            "completeRegistration--managerIdentity--uniqueId": "<startRegistration--managerIdentity--uniqueId>",
            "completeRegistration--managerCertificate": None,
            "completeRegistration--managerIdentity--release": "<startRegistration--managerIdentity--release>",
            "completeRegistration--managerIdentity--type": "<startRegistration--managerIdentity--type>",
            "completeRegistration--managerIdentity--vendor": "<startRegistration--managerIdentity--vendor>"
        },
    }
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def start_registration_unauthorized(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    messages = {
        "startRegistration": {
            "startRegistration--managerNonce": None,
            "startRegistration--managerIdentity--uniqueId": None,
            "startRegistration--managerIdentity--type": Names.TYPE_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--release": None,
            "startRegistration--agentUniqueId": Names.AGENT_ID_1.value,
            "startRegistration--notificationConsumerURL": None,
            "startRegistration--reRegisterInterval": None,
            "startRegistration--soc": None
        },
        "Fault": {
            "Fault--faultcode": Names.FAULT_CODE_1.value,
            "Fault--faultstring": Names.HTTP_UNAUTHORIZED.value
        },
    }
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def start_registration_fail(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    messages = {
        "startRegistration": {
            "startRegistration--managerNonce": None,
            "startRegistration--managerIdentity--uniqueId": None,
            "startRegistration--managerIdentity--type": Names.TYPE_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--release": None,
            "startRegistration--agentUniqueId": Names.AGENT_ID_1.value,
            "startRegistration--notificationConsumerURL": None,
            "startRegistration--reRegisterInterval": None,
            "startRegistration--soc": None
        },
    }
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    errors.extend(err)
    wrong_parameter = "completeRegistration--managerResponse"
    logger.debug("Searching json for parameter: {}".format(wrong_parameter))
    result = get_param_value_from_json(json_data_single_op, wrong_parameter)
    if not result[0]:
        logger.debug("Wrong parameter: {} not found - correct".format(wrong_parameter))
    else:
        err_2 = "Wrong parameter: {} found - not correct!".format(wrong_parameter)
        errors.extend(err_2)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def start_registration_error_500(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    messages = {
        "startRegistration": {
            "startRegistration--managerNonce": None,
            "startRegistration--managerIdentity--uniqueId": None,
            "startRegistration--managerIdentity--type": Names.TYPE_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--release": None,
            "startRegistration--agentUniqueId": Names.AGENT_ID_1.value,
            "startRegistration--notificationConsumerURL": None,
            "startRegistration--reRegisterInterval": None,
            "startRegistration--soc": None
        },
        "startRegistrationResponse": {
            "startRegistrationResponse--agentIdentity--uniqueId": "<startRegistration--agentUniqueId>",
            "startRegistrationResponse--agentIdentity--type": Names.TYPE.value,  # Req ID: OM_GEN_SFS_ARCH.1860
            "startRegistrationResponse--agentIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            # "startRegistrationResponse--agentIdentity--release": get_sw_release_version(),
            # Req ID: OM_GEN_SFS_ARCH.1862
            "startRegistrationResponse--agentResponse": None,
            "startRegistrationResponse--licenseRequired": None,
            "startRegistrationResponse--registrationComplete": Names.FALSE.value,
            "startRegistrationResponse--agentNonce": None,
            "startRegistrationResponse--agentCertificate": None,
        },
        "completeRegistration": {
            "completeRegistration--managerResponse": None,
            "completeRegistration--agentUniqueId": "<startRegistrationResponse--agentIdentity--uniqueId>",
            "completeRegistration--managerIdentity--uniqueId": "<startRegistration--managerIdentity--uniqueId>",
            "completeRegistration--managerCertificate": None,
            "completeRegistration--managerIdentity--release": "<startRegistration--managerIdentity--release>",
            "completeRegistration--managerIdentity--type": "<startRegistration--managerIdentity--type>",
            "completeRegistration--managerIdentity--vendor": "<startRegistration--managerIdentity--vendor>"
        },
        "Fault": {
            "Fault--faultcode": Names.FAULT_CODE_2.value,
            "Fault--faultstring": Names.FAULT_STRING_2.value,
            "Fault--detail": Names.FAULT_DETAIL_2.value,
        },
    }
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def registration_with_wrong_vendor_CA(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    messages = {
        "startRegistration": {
            "startRegistration--managerNonce": None,
            "startRegistration--managerIdentity--uniqueId": None,
            "startRegistration--managerIdentity--type": Names.TYPE_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--release": None,
            "startRegistration--agentUniqueId": Names.AGENT_ID_1.value,
            "startRegistration--notificationConsumerURL": None,
            "startRegistration--reRegisterInterval": None,
            "startRegistration--soc": None
        },
        "startRegistrationResponse": {
            "startRegistrationResponse--agentIdentity--uniqueId": "<startRegistration--agentUniqueId>",
            "startRegistrationResponse--agentIdentity--type": Names.TYPE.value,  # Req ID: OM_GEN_SFS_ARCH.1860
            "startRegistrationResponse--agentIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            # "startRegistrationResponse--agentIdentity--release": get_sw_release_version(),
            # Req ID: OM_GEN_SFS_ARCH.1862
            "startRegistrationResponse--agentResponse": None,
            "startRegistrationResponse--licenseRequired": None,
            "startRegistrationResponse--registrationComplete": Names.FALSE.value,
            "startRegistrationResponse--agentNonce": None,
            "startRegistrationResponse--agentCertificate": None,
        },
        "completeRegistration": {
            "completeRegistration--managerResponse": None,
            "completeRegistration--agentUniqueId": "<startRegistrationResponse--agentIdentity--uniqueId>",
            "completeRegistration--managerIdentity--uniqueId": "<startRegistration--managerIdentity--uniqueId>",
            "completeRegistration--managerCertificate": None,
            "completeRegistration--managerIdentity--release": "<startRegistration--managerIdentity--release>",
            "completeRegistration--managerIdentity--type": "<startRegistration--managerIdentity--type>",
            "completeRegistration--managerIdentity--vendor": "<startRegistration--managerIdentity--vendor>"
        },
        "Fault": {
            "Fault--faultcode": Names.FAULT_CODE_2.value,
            "Fault--faultstring": Names.FAULT_STRING_2.value,
            "Fault--detail": Names.FAULT_DETAIL_2.value,
        },
    }
    messages_2 = {
        "startRegistration": {
            "startRegistration--managerNonce": None,
            "startRegistration--managerIdentity--uniqueId": None,
            "startRegistration--managerIdentity--type": Names.TYPE_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--vendor": Names.VENDOR_2.value,  # Req ID: OM_GEN_SFS_ARCH.1861
            "startRegistration--managerIdentity--release": None,
            "startRegistration--agentUniqueId": Names.AGENT_ID_1.value,
            "startRegistration--notificationConsumerURL": None,
            "startRegistration--reRegisterInterval": None,
            "startRegistration--soc": None
        },
        "Fault": {
            "Fault--faultcode": Names.FAULT_CODE_1.value,
            "Fault--faultstring": Names.HTTP_UNAUTHORIZED.value,
        },
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if errors:
        parameter_values_2, errors_2 = get_message_values_from_json(json_data_single_op, messages_2)
        if errors_2:
            errors.extend(errors_2)
        else:
            logger.debug("Validation parameters for operation: {} - start".format(operation_name))
            err_2 = validate_messages(messages, parameter_values)
            logger.debug("Validation parameters for operation: {} - end".format(operation_name))
            errors_2.extend(err_2)
            errors = errors_2
    else:
        logger.debug("Validation parameters for operation: {} - start".format(operation_name))
        err = validate_messages(messages, parameter_values)
        logger.debug("Validation parameters for operation: {} - end".format(operation_name))
        errors.extend(err)
    return [errors, parameter_values]


def start_session(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    level = kwargs.get('level', 'basic')
    messages = {
        "startSession": {
            "startSession--managerRegistrationId": None,
            "startSession--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None,
            "startSession--sessionId": None,
            "startSession--useStatusRequest": None
        },
        "startSessionResponse": {
            "startSessionResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "startSessionResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "startSessionResponse--sessionTimeout": None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name      # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    if level == "advanced":
        err_reg, par_val_reg = start_registration(json_data_single_op)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def start_session_with_netact(json_data_single_op, manager, *args, **kwargs):
    """author: Anna Bien"""
    level = kwargs.get('level', 'basic')
    clab = kwargs.get('clab', 'clab3011')
    messages = {
        "startSession": {
            "startSession--managerRegistrationId": "NAS@" + clab + "lbwas.netact.nsn-rdnet.net_" + manager,
            "startSession--managerRegistrationKey": None,
            "startSession--sessionId": None,
            "startSession--useStatusRequest": Names.FALSE.value
        },
        "startSessionResponse": {
            "startSessionResponse--agentRegistrationId": None,
            "startSessionResponse--agentRegistrationKey": None,
            "startSessionResponse--sessionTimeout": None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name      # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)

    # print("Start session parameter values: {}".format(parameter_values))
    # if level == "advanced":
    #     err_reg, par_val_reg = start_registration(json_data_single_op)
    #     parameter_values.update(par_val_reg)
    #     errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def sw_upload(json_data_single_op, *args, **kwargs):
    """author: Aleksandra Zbieg, Marek Piotrowski"""
    level = kwargs.get('level', 'basic')
    messages = {
        "upload": {
            "upload--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "upload--operationId": None,
            "upload--filter--objectClass": Names.OBJECT_1.value,
            "upload--progressFeedback--objectAmount": None,
            "upload--filter--objects--depth": None,
            "upload--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "upload--compressionThreshold": None,
            "upload--managerRegistrationId": None,
            "upload--progressFeedback--timeInterval": None,
            "upload--filter--objects--sdn": None,
            "upload--filter--uploadType": Names.UPLOAD_TYPE_1.value,
            "upload--timeout": None
        },

        "uploadResponse": {
            "uploadResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "uploadResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "uploadResponse--timeout": None
        },

        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT_2.value,
            "reportOperationStatus--agentRegistrationId": Names.AGENT_ID_1.value,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<upload--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.FALSE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None
        },

        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def cm_upload(json_data_single_op, *args, **kwargs):
    level = kwargs.get('level', 'basic')
    messages = {"upload":
                {"upload--managerRegistrationKey":
                    "<startRegistration--managerNonce>" if level == "advanced" else None,
                 "upload--operationId": None,
                 "upload--progressFeedback--objectAmount": None,
                 "upload--filter--objects--depth": None,
                 "upload--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
                 "upload--compressionThreshold": None,
                 "upload--managerRegistrationId": None,
                 "upload--progressFeedback--timeInterval": None,
                 "upload--filter--objects--sdn": None,
                 "upload--filter--uploadType": Names.UPLOAD_TYPE_1.value,
                 "upload--timeout": None},

                "uploadResponse":
                    {"uploadResponse--agentRegistrationId":
                        "<startRegistration--agentUniqueId>" if level == "advanced" else None,
                     "uploadResponse--agentRegistrationKey":
                         "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
                     "uploadResponse--timeout": None},

                "reportOperationStatus":
                    {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
                     "reportOperationStatus--agentRegistrationId":
                         "<startRegistration--agentUniqueId>" if level == "advanced" else None,
                     "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
                     "reportOperationStatus--pageSequenceNumber": None,
                     "reportOperationStatus--attachmentProperties--compression": None,
                     "reportOperationStatus--operationId": "<upload--operationId>",
                     "reportOperationStatus--agentRegistrationKey":
                         "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
                     "reportOperationStatus--completed": Names.TRUE.value,
                     "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

                "reportOperationStatusResponse":
                    {"reportOperationStatusResponse--managerRegistrationId":
                         "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
                     "reportOperationStatusResponse--managerRegistrationKey":
                         "<startRegistration--managerNonce>" if level == "advanced" else None}}

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def cm_upload_netact(json_data_single_op, manager='', *args, **kwargs):
    level = kwargs.get('level', 'basic')
    clab = kwargs.get('clab', 'clab3011')
    messages = {"upload":
                {"upload--managerRegistrationKey":
                    "<startSession--managerRegistrationKey>" if level == "advanced" else None,
                 "upload--operationId": None,
                 "upload--filter--objects--depth": None,
                 "upload--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
                 "upload--managerRegistrationId":
                     "<startSession--managerRegistrationId>" if level == "advanced" else None,
                 "upload--filter--objects--sdn": None,
                 "upload--filter--uploadType": Names.UPLOAD_TYPE_1.value,
                 "upload--timeout": None},

                "uploadResponse":
                    {"uploadResponse--agentRegistrationId":
                        "<startSessionResponse--agentRegistrationId>" if level == "advanced" else None,
                     "uploadResponse--agentRegistrationKey":
                         "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
                     "uploadResponse--timeout": None},

                "reportOperationStatus":
                    {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT_2.value,
                     "reportOperationStatus--agentRegistrationId":
                         "<startSessionResponse--agentRegistrationId>" if level == "advanced" else None,
                     "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
                     "reportOperationStatus--pageSequenceNumber": None,
                     "reportOperationStatus--attachmentProperties--compression": None,
                     "reportOperationStatus--operationId": "<upload--operationId>",
                     "reportOperationStatus--agentRegistrationKey":
                         "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
                     "reportOperationStatus--completed": Names.FALSE.value,
                     "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

                "reportOperationStatus_feedback":
                    {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
                     "reportOperationStatus--agentRegistrationId":
                         "<startSessionResponse--agentRegistrationId>" if level == "advanced" else None,
                     "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
                     "reportOperationStatus--pageSequenceNumber": None,
                     "reportOperationStatus--attachmentProperties--compression": None,
                     "reportOperationStatus--operationId": "<upload--operationId>",
                     "reportOperationStatus--agentRegistrationKey":
                         "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
                     "reportOperationStatus--completed": Names.TRUE.value,
                     "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

                "reportOperationStatusResponse":
                    {"reportOperationStatusResponse--managerRegistrationId":
                         "<startSession--managerRegistrationId>" if level == "advanced" else None,
                     "reportOperationStatusResponse--managerRegistrationKey":
                         "<startSession--managerRegistrationKey>" if level == "advanced" else None}}

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json_netact(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    # if level == "advanced":
    #     err_reg, par_val_reg = start_session_with_netact(json_data_single_op, manager, level=level, clab=clab)
    #     parameter_values.update(par_val_reg)
    #     # print(par_val_reg)
    #     errors.extend(err_reg)
    if level == "advanced":
        err_reg, par_val_reg = start_session_with_netact(json_data_single_op, manager, level=level, clab=clab)
        startSession = {}
        startSessionResponse = {}
        for par in par_val_reg:
            if re.match("startSession--.*", par):
                print("Start Session frame: {}".format(par))
                startSession.update({par: par_val_reg[par]})
            else:
                startSessionResponse.update({par: par_val_reg[par]})
        parameter_values.update({'startSession': startSession})
        parameter_values.update({'startSessionResponse': startSessionResponse})
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages_netact(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def swm_provision(json_data_single_op, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    messages = {
        "provision": {
            "provision--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "provision--operationId": None,
            "provision--progressFeedback--objectAmount": None,
            "provision--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "provision--compressionThreshold": None,
            "provision--managerRegistrationId": None,
            "provision--progressFeedback--timeInterval": None,
            "provision--timeout": None,
            "provision--attachmentProperties--compression": None,
            "provision--attachmentProperties--contentType": None,
            "provision--attachmentProperties--checksum--algorithm": None,
            "provision--attachmentProperties--checksum--hash": None,
            "provision--attachmentProperties--primaryDocument": None,
            "provision--planId": None,
            "provision--blockLocalChanges": None,
            "provision--takeFallback": None,
            "provision--extensions--type": None,
            "provision--extensions--attributes--name": None
         },
        "provisionResponse": {
            "provisionResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "provisionResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "provisionResponse--timeout": "<provision--timeout>"
        },
        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<provision--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None
        },
        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        },
        "transferNotification": {
            "transferNotification--queueId": Names.TRANSFER_NOTIFICATION_QUEUE_ID_2.value,
            "transferNotification--sequenceNumber": None,
            "transferNotification--attachmentProperties--checksum--hash": None,
            "transferNotification--attachmentProperties--checksum--algorithm": None,
            "transferNotification--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "transferNotification--attachmentProperties--compression": None,
            "transferNotification--attachmentProperties--primaryDocument": Names.PRIMARY_DOCUMENT_1.value,
            "transferNotification--notificationContent": Names.OPERATION_STATUS_CONTENT_3.value,
            "transferNotification--notificationType": Names.NOTIFICATION_TYPE.value,
            "transferNotification--agentRegistrationId": Names.AGENT_ID_1.value,
            "transferNotification--agentRegistrationKey": None
        },
        "transferNotificationResponse": {
            "transferNotificationResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "transferNotificationResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def sw_rollback(json_data_single_op, *args, **kwargs):
    """author: Anna Bien"""
    level = kwargs.get('level', 'basic')
    messages = {
        "provision": {
            "provision--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "provision--operationId": None,
            "provision--progressFeedback--objectAmount": None,
            "provision--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "provision--compressionThreshold": None,
            "provision--managerRegistrationId": None,
            "provision--progressFeedback--timeInterval": None,
            "provision--timeout": None,
            "provision--attachmentProperties--compression": None,
            "provision--attachmentProperties--contentType": None,
            "provision--attachmentProperties--checksum--algorithm": None,
            "provision--attachmentProperties--checksum--hash": None,
            "provision--attachmentProperties--primaryDocument": None,
            "provision--planId": None,
            "provision--blockLocalChanges": None,
            "provision--takeFallback": None,
            "provision--extensions--type": None,
            "provision--extensions--attributes--name": None
         },
        "provisionResponse": {
            "provisionResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "provisionResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "provisionResponse--timeout": "<provision--timeout>"
        },
        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<provision--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None
        },
        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        },
        "transferNotification": {
            "transferNotification--queueId": Names.TRANSFER_NOTIFICATION_QUEUE_ID_2.value,
            "transferNotification--sequenceNumber": None,
            "transferNotification--attachmentProperties--checksum--hash": None,
            "transferNotification--attachmentProperties--checksum--algorithm": None,
            "transferNotification--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "transferNotification--attachmentProperties--compression": None,
            "transferNotification--attachmentProperties--primaryDocument": None,
            "transferNotification--notificationContent": Names.OPERATION_STATUS_CONTENT_3.value,
            "transferNotification--notificationType": Names.NOTIFICATION_TYPE.value,
            "transferNotification--agentRegistrationId": Names.AGENT_ID_1.value,
            "transferNotification--agentRegistrationKey": None
        },
        "transferNotificationResponse": {
            "transferNotificationResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "transferNotificationResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def get_pm_upload_frames(*args, **kwargs):
    with open('/home/ute/Desktop/parsit.json') as read_file:
        pm_noti_dict = {}
        data = json.load(read_file)
    for element1, element2 in data.items():
        for element3, val in element2["xml_data"][0].items():
            if element3 == "transferNotification--queueId" and val == "pm_queue":
                for i in range(len(element2["xml_data"][0].items())):
                    pm_noti_dict[element2["xml_data"][0].items()[i][0]] = element2["xml_data"][0].items()[i][1]

                break

    pm_noti_json = json.dumps(pm_noti_dict, ensure_ascii=False)

    return pm_noti_json


def pm_upload_basic_notification(json_data_single_op, *args, **kwargs):
    messages = {
        "pmNotification": {
                "transferNotification--notificationContent": None,
                "transferNotification--attachmentProperties--primaryDocument": None,
                "transferNotification--attachmentProperties--compression":
                Names.TRANSFER_NOTIFICATION_COMPRESSION.value,
                "transferNotification--attachmentProperties--contentType":
                Names.TRANSFER_NOTIFICATION_CONTENT_TYPE.value,
                "transferNotification--notificationType": Names.TRANSFER_NOTIFICATION_TYPE.value,
                "transferNotification--agentRegistrationKey": None,
                "transferNotification--sequenceNumber": None,
                "transferNotification--agentRegistrationId": None,
                "transferNotification--attachmentProperties--checksum--algorithm": None,
                "transferNotification--queueId": Names.TRANSFER_NOTIFICATION_QUEUE_ID.value
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def alarm_new_event_notification_for_cell_blocked(json_data_single_op, *args, **kwargs):
    level = kwargs.get('level', 'basic')
    messages = {
        "transferNotification": {
                "transferNotification--notificationContent": None,
                "transferNotification--attachmentProperties--primaryDocument": None,
                "transferNotification--attachmentProperties--contentType": Names.ALARM_EVENT_CONTENT_TYPE.value,
                "transferNotification--notificationType": Names.ALARM_EVENT_NOTIFICATION_TYPE.value,
                "transferNotification--agentRegistrationKey":
                "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
                "transferNotification--sequenceNumber": None,
                "transferNotification--agentRegistrationId":
                "<startSessionResponse--agentRegistrationId>" if level == "advanced" else None,
                "transferNotification--attachmentProperties--compression": None,
                "transferNotification--queueId": Names.ALARM_EVENT_QUEUE_ID.value,
                "transferNotification--attachmentProperties--checksum--hash": None,
                "transferNotification--attachmentProperties--checksum--algorithm": None
        },

        "alarmNew": {
                "alarmNew--eventType": None,
                "alarmNew--eventTime": None,
                "alarmNew--alarmText": Names.ALARM_EVENT_ALARM_TEXT.value,
                "alarmNew--specificProblem": Names.ALARM_EVENT_SPECIFIC_PROBLEM.value,
                "alarmNew--perceivedSeverity": Names.ALARM_EVENT_PERCEIVED_SEVERITY.value,
                "alarmNew--alarmId": None
        },
        "transferNotificationResponse": {
                "transferNotificationResponse--managerRegistrationId":
                "<startSession--managerRegistrationId>" if level == "advanced" else None,
                "transferNotificationResponse--managerRegistrationKey":
                "<startSession--managerRegistrationKey>" if level == "advanced" else None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages, max_range=2)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def alarm_cleared_event_notification_for_cell_blocked(json_data_single_op, *args, **kwargs):
    level = kwargs.get('level', 'basic')
    messages = {
        "transferNotification": {
                "transferNotification--notificationContent": None,
                "transferNotification--attachmentProperties--primaryDocument": None,
                "transferNotification--attachmentProperties--contentType": Names.ALARM_EVENT_CONTENT_TYPE.value,
                "transferNotification--notificationType": Names.ALARM_EVENT_NOTIFICATION_TYPE.value,
                "transferNotification--agentRegistrationKey":
                "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
                "transferNotification--sequenceNumber": None,
                "transferNotification--agentRegistrationId":
                "<startSessionResponse--agentRegistrationId>" if level == "advanced" else None,
                "transferNotification--attachmentProperties--compression": None,
                "transferNotification--queueId": Names.ALARM_EVENT_QUEUE_ID.value,
                "transferNotification--attachmentProperties--checksum--hash": None,
                "transferNotification--attachmentProperties--checksum--algorithm": None
        },

        "alarmCleared": {
                "alarmCleared--alarmId": None,
                "alarmCleared--eventType": None,
                "alarmCleared--perceivedSeverity": Names.ALARM_EVENT_PERCEIVED_SEVERITY_2.value,
                "alarmCleared--eventTime": None,
                "alarmCleared--specificProblem": Names.ALARM_EVENT_SPECIFIC_PROBLEM.value
        },
        "transferNotificationResponse": {
                "transferNotificationResponse--managerRegistrationId":
                "<startSession--managerRegistrationId>" if level == "advanced" else None,
                "transferNotificationResponse--managerRegistrationKey":
                "<startSession--managerRegistrationKey>" if level == "advanced" else None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages, max_range=2)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def alarm_upload(json_data_single_op, *args, **kwargs):
    level = kwargs.get('level', 'basic')
    alarms = kwargs.get("alarms", "")
    messages = {
        "upload":
            {
                "upload--managerRegistrationKey":
                    "<startSession--managerRegistrationKey>" if level == "advanced" else None,
                "upload--operationId": None,
                "upload--progressFeedback--objectAmount": None,
                "upload--filter--objects--depth": None,
                "upload--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
                "upload--compressionThreshold": None,
                "upload--managerRegistrationId":
                    "<startSession--managerRegistrationId>" if level == "advanced" else None,
                "upload--progressFeedback--timeInterval": None,
                "upload--filter--objects--sdn": None,
                "upload--filter--uploadType": Names.UPLOAD_TYPE_2.value,
                "upload--timeout": None},

        "uploadResponse":
            {
                "uploadResponse--agentRegistrationId":
                "<startSessionResponse--agentRegistrationId>" if level == "advanced" else None,
                "uploadResponse--agentRegistrationKey":
                "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
                "uploadResponse--timeout": None},

        "reportOperationStatus":
            {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT_2.value,
             "reportOperationStatus--agentRegistrationId": Names.AGENT_ID_1.value,
             "reportOperationStatus--attachmentProperties--contentType": Names.ALARM_EVENT_CONTENT_TYPE.value,
             "reportOperationStatus--pageSequenceNumber": Names.SEQUENCE_NUMBER_1.value,
             "reportOperationStatus--attachmentProperties--compression": None,
             "reportOperationStatus--operationId": "<upload--operationId>",
             "reportOperationStatus--agentRegistrationKey":
             "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
             "reportOperationStatus--completed": Names.FALSE.value,
             "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

        "reportOperationStatus_feedback":
            {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
             "reportOperationStatus--agentRegistrationId": Names.AGENT_ID_1.value,
             "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
             "reportOperationStatus--pageSequenceNumber": Names.SEQUENCE_NUMBER_2.value,
             "reportOperationStatus--attachmentProperties--compression": None,
             "reportOperationStatus--operationId": "<upload--operationId>",
             "reportOperationStatus--agentRegistrationKey":
             "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
             "reportOperationStatus--completed": Names.TRUE.value,
             "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None}
    }
    for k in alarms:
        messages["reportOperationStatus"].update({k: alarms[k]})
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json_netact(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages_netact(messages, parameter_values)
    errors.extend(err)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))

    return [errors, parameter_values]


def cm_download(json_data_single_op, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    messages = {
        "download": {
            "download--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "download--operationId": None,
            "download--progressFeedback--objectAmount": None,
            "download--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "download--compressionThreshold": None,
            "download--managerRegistrationId": None,
            "download--progressFeedback--timeInterval": None,
            "download--timeout": None,
            "download--planId": None,
            "download--downloadContent": None,
            "download--attachmentProperties--checksum--hash": None,
            "download--attachmentProperties--primaryDocument": None,
            "download--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "download--attachmentProperties--compression": None,
            "download--blockLocalChanges": None,
            "download--extensions--attributes--name": None,
            "download--extensions--type": None,
            "download--takeFallback": None,
            "download--attachmentProperties--checksum--algorithm": None
        },

        "downloadResponse": {
            "downloadResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "downloadResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "downloadResponse--timeout": None
        },

        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId": Names.AGENT_ID_1.value,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<download--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None
        },

        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def rebuild_notification(json_data_single_op, *args, **kwargs):
    level = kwargs.get('level', 'basic')
    alarms = kwargs.get("alarms", "")
    messages = {
        "transferNotification": {
                "transferNotification--agentRegistrationKey": None,
                "transferNotification--sequenceNumber": None,
                "transferNotification--agentRegistrationId": Names.AGENT_ID_1.value,
                "transferNotification--queueId": Names.ALARM_EVENT_QUEUE_ID.value,
                "transferNotification--notificationType": Names.ALARM_EVENT_NOTIFICATION_TYPE_2.value
        },
        "transferNotificationResponse": {
            "transferNotificationResponse--managerRegistrationKey": None,
            "transferNotificationResponse--managerRegistrationId": None
        },
        "upload":
            {
                "upload--managerRegistrationKey":
                    "<startSession--managerRegistrationKey>" if level == "advanced" else None,
                "upload--operationId": None,
                "upload--progressFeedback--objectAmount": None,
                "upload--filter--objects--depth": None,
                "upload--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
                "upload--compressionThreshold": None,
                "upload--managerRegistrationId":
                    "<startSession--managerRegistrationId>" if level == "advanced" else None,
                "upload--progressFeedback--timeInterval": None,
                "upload--filter--objects--sdn": None,
                "upload--filter--uploadType": Names.UPLOAD_TYPE_2.value,
                "upload--timeout": None},

        "uploadResponse":
            {
                "uploadResponse--agentRegistrationId":
                    "<startSessionResponse--agentRegistrationId>" if level == "advanced" else None,
                "uploadResponse--agentRegistrationKey":
                    "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
                "uploadResponse--timeout": None},

        "reportOperationStatus":
            {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT_2.value,
             "reportOperationStatus--agentRegistrationId": Names.AGENT_ID_1.value,
             "reportOperationStatus--attachmentProperties--contentType": Names.ALARM_EVENT_CONTENT_TYPE.value,
             "reportOperationStatus--pageSequenceNumber": Names.SEQUENCE_NUMBER_1.value,
             "reportOperationStatus--attachmentProperties--compression": None,
             "reportOperationStatus--operationId": "<upload--operationId>",
             "reportOperationStatus--agentRegistrationKey":
                 "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
             "reportOperationStatus--completed": Names.FALSE.value,
             "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

        "reportOperationStatus_feedback":
            {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
             "reportOperationStatus--agentRegistrationId": Names.AGENT_ID_1.value,
             "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
             "reportOperationStatus--pageSequenceNumber": Names.SEQUENCE_NUMBER_2.value,
             "reportOperationStatus--attachmentProperties--compression": None,
             "reportOperationStatus--operationId": "<upload--operationId>",
             "reportOperationStatus--agentRegistrationKey":
                 "<startSessionResponse--agentRegistrationKey>" if level == "advanced" else None,
             "reportOperationStatus--completed": Names.TRUE.value,
             "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        }

    }
    for k in alarms:
        messages["reportOperationStatus"].update({k: alarms[k]})
    operation_name = inspect.currentframe().f_code.co_name
    parameter_values, errors = get_message_values_from_json_for_rebuild_notification(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages_netact(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def send_CCN(json_data_single_op, *args, **kwargs):
    messages = {
        "transferNotification": {
            "transferNotification--queueId": Names.TRANSFER_NOTIFICATION_QUEUE_ID_2.value,
            "transferNotification--sequenceNumber": None,
            "transferNotification--attachmentProperties--checksum--hash": None,
            "transferNotification--attachmentProperties--checksum--algorithm": None,
            "transferNotification--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "transferNotification--attachmentProperties--compression": None,
            "transferNotification--attachmentProperties--primaryDocument": None,
            "transferNotification--notificationContent": None,
            "transferNotification--notificationType": Names.NOTIFICATION_TYPE.value,
            "transferNotification--agentRegistrationId": None,
            "transferNotification--agentRegistrationKey": None
        },

        "cmData": {
                "cmData--configDataRevisionNumber--1": None,
                "cmData--planId--257": None,
                "cmData--eventChangeOrigin--257": None
        }
    }
    for entry in add_cmdata_for_sending_CCN_validation():
        messages["cmData"].update(entry)
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages, max_range=2)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def send_CCN_2(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    level = kwargs.get('level', 'basic')
    messages = {
        "transferNotification": {
            "transferNotification--queueId": Names.COMMON_QUEUE.value,
            "transferNotification--sequenceNumber": None,
            "transferNotification--attachmentProperties--checksum--hash": None,
            "transferNotification--attachmentProperties--checksum--algorithm": None,
            "transferNotification--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "transferNotification--attachmentProperties--compression": None,
            "transferNotification--attachmentProperties--primaryDocument": Names.PRIMARY_DOCUMENT_1.value,
            "transferNotification--notificationContent": Names.NOTIFICATION_CONTENT.value,
            "transferNotification--notificationType": Names.NOTIFICATION_TYPE.value,
            "transferNotification--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else Names.AGENT_ID_1.value,
            "transferNotification--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
        },

        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        }
    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def cm_provision_mandatory_parameters_missing(json_data_single_op, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    messages = {
        "provision": {
            "provision--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "provision--operationId": None,
            "provision--progressFeedback--objectAmount": None,
            "provision--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "provision--compressionThreshold": None,
            "provision--managerRegistrationId": None,
            "provision--progressFeedback--timeInterval": None,
            "provision--timeout": None,
            "provision--attachmentProperties--compression": None,
            "provision--attachmentProperties--contentType": None,
            "provision--attachmentProperties--checksum--algorithm": None,
            "provision--attachmentProperties--checksum--hash": None,
            "provision--attachmentProperties--primaryDocument": None,
            "provision--planId": None,
            "provision--blockLocalChanges": None,
            "provision--takeFallback": None,
            "provision--extensions--type": None,
            "provision--extensions--attributes--name": None
         },
        "provisionResponse": {
            "provisionResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "provisionResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "provisionResponse--timeout": "<provision--timeout>"
        },
        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<provision--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None,
            "managedObjects--errorText--1": "Parameter actCellTrace has invalid value (0).",
            "managedObjects--errorText--2":
                "Parameter a5ReportInterval has invalid value (3).;Parameter a5TimeToTrigger has invalid value (2).",
            "managedObjects--errorText--3":
                "Mandatory parameter administrativeState is missing.;Mandatory parameter ipAddrPrim is missing.;\
                Mandatory parameter mmeRatSupport is missing.;Mandatory parameter transportNwId is missing.",
            "message_result": "Validation failed"
        },
        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        },

    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def cm_provision_wrong_raml_version(json_data_single_op, *args, **kwargs):
    """author: Anna Bien"""
    level = kwargs.get('level', 'basic')
    messages = {
        "provision": {
            "provision--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "provision--operationId": None,
            "provision--progressFeedback--objectAmount": None,
            "provision--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "provision--compressionThreshold": None,
            "provision--managerRegistrationId": None,
            "provision--progressFeedback--timeInterval": None,
            "provision--timeout": None,
            "provision--attachmentProperties--compression": None,
            "provision--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "provision--attachmentProperties--checksum--algorithm": None,
            "provision--attachmentProperties--checksum--hash": None,
            "provision--attachmentProperties--primaryDocument": None,
            "provision--planId": None,
            "provision--blockLocalChanges": None,
            "provision--takeFallback": None,
            "provision--extensions--type": None,
            "provision--extensions--attributes--name": None,
            "provision--provisionContent": None
        },
        "provisionResponse": {
            "provisionResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "provisionResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "provisionResponse--timeout": "<provision--timeout>"
        },
        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": Names.SEQUENCE_NUMBER_1.value,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<provision--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None,
            "message_result": "Validation failed for plan"
        },
        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        },

    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    messages["reportOperationStatus"]\
        .update({"message_result": "Validation failed for plan {}".format(parameter_values["provision--planId"])})
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def reregister(json_data_single_op, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    messages = {
        "reregister": {
            "reregister--extensions--attributes--name": Names.AGENT_URL.value,
            "reregister--extensions--attributes--value": None,
            "reregister--extensions--type": Names.REREGISTER_EXTENSIONS_TYPE.value
        },
        "reregisterResponse": {
            "reregisterResponse--extensions--attributes--name": Names.REREGISTER_RESPONSE_ATT_NAME.value,
            "reregisterResponse--extensions--attributes--value": Names.REREGISTER_RESPONSE_ATT_VALUE.value,
            "reregister--extensions--type": Names.REREGISTER_RESPONSE_EXTENSIONS_TYPE.value,
            "reregister--agentRegistrationId": Names.VALUE_NOT_SET.value,
            "reregister--agentRegistrationKey": Names.VALUE_NOT_SET.value
        },
    }
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    return [errors, parameter_values]


def asc_notification(json_data, *args, **kwargs):
    """
    author: Marek Piotrowski

    :param json_data:   [{<dict>}]
    :param args:
    :param kwargs:
    :return:            [ [<errors>], {<parameter_values>}]
    """
    level = kwargs.get('level', 'basic')
    asc_status = [i for i in kwargs.get("asc_status").split(",")]
    json_data = json_data
    status = "cmData--managedObject--p"
    errors = []
    parameter_values = {}
    validated = []
    if not asc_status:
        raise Exception("Mandatory parameter 'asc_status' not provided!")
    for operation in json_data:
        status = get_status_key(operation)
        operation_status = get_param_value_from_json(operation, status)[0][status]
        if operation_status not in asc_status:
            continue
        else:
            err, par = asc_notification_helper(operation, level=level, status=operation_status, statusKey=status)
            errors.extend(err)
            parameter_values.update(par)
            validated.append(operation_status)
    diff = set(asc_status).difference(set(validated))
    for i in diff:
        error = "Frame for value: {} of parameter {} not found!".format(i, status)
        errors.append(error)
    return [errors, parameter_values]


def get_status_key(json_data, *args, **kwargs):
    params = OrderedDict()
    for k, v in json_data.items():
        for i in v["xml_data"]:
            params.update(i)

    for k, v in params.items():
        if v == "autoConfStatus":
            key = str(k).replace("--name", "")
            return key


def asc_notification_helper(json_data_single_op, *args, **kwargs):
    """
    author: Marek Piotrowski

    :param json_data:   {<dict>}
    :param args:
    :param kwargs:
    :return:            [ [<errors>], {<parameter_values>}]
    """
    level = kwargs.get('level', 'basic')
    status = kwargs.get('status')
    status_key = kwargs.get('statusKey', 'cmData--managedObject--p')
    messages = {
        "transferNotification": {
            "transferNotification--queueId": Names.TRANSFER_NOTIFICATION_QUEUE_ID_2.value,
            "transferNotification--sequenceNumber": None,
            "transferNotification--attachmentProperties--checksum--hash": None,
            "transferNotification--attachmentProperties--checksum--algorithm": None,
            "transferNotification--attachmentProperties--contentType": Names.CONTENT_TYPE_2.value,
            "transferNotification--attachmentProperties--compression": None,
            "transferNotification--attachmentProperties--primaryDocument": None,
            "transferNotification--notificationContent": Names.NOTIFICATION_CONTENT.value,
            "transferNotification--notificationType": Names.NOTIFICATION_TYPE.value,
            "transferNotification--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "transferNotification--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None
        },
        "transferNotificationResponse": {
            "transferNotificationResponse--managerRegistrationId": None,
            "transferNotificationResponse--managerRegistrationKey": None
        },
        "cmData": {
            status_key: status
        },
    }
    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    if level == "advanced":
        err_reg, par_val_reg = start_registration(json_data_single_op)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def pnp_parameters_upload(json_data_single_op, *args, **kwargs):
    level = kwargs.get('level', 'basic')
    messages = {"upload":
                {"upload--managerRegistrationKey":
                    "<startRegistration--managerNonce>" if level == "advanced" else None,
                 "upload--operationId": None,
                 "upload--progressFeedback--objectAmount": None,
                 "upload--filter--objects--depth": None,
                 "upload--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
                 "upload--compressionThreshold": None,
                 "upload--managerRegistrationId": None,
                 "upload--progressFeedback--timeInterval": None,
                 "upload--filter--objects--sdn": Names.ASTERISK.value,
                 "upload--filter--uploadType": Names.UPLOAD_TYPE_1.value,
                 "upload--timeout": None},

                "uploadResponse":
                    {"uploadResponse--agentRegistrationId":
                        "<startRegistration--agentUniqueId>" if level == "advanced" else None,
                     "uploadResponse--agentRegistrationKey":
                         "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
                     "uploadResponse--timeout": None},

                "reportOperationStatus":
                    {"reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
                     "reportOperationStatus--agentRegistrationId":
                         "<startRegistration--agentUniqueId>" if level == "advanced" else None,
                     "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
                     "reportOperationStatus--pageSequenceNumber": None,
                     "reportOperationStatus--attachmentProperties--compression": None,
                     "reportOperationStatus--operationId": "<upload--operationId>",
                     "reportOperationStatus--agentRegistrationKey":
                         "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
                     "reportOperationStatus--completed": Names.TRUE.value,
                     "reportOperationStatus--attachmentProperties--checksum--algorithm": None},

                "reportOperationStatusResponse":
                    {"reportOperationStatusResponse--managerRegistrationId":
                         "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
                     "reportOperationStatusResponse--managerRegistrationKey":
                         "<startRegistration--managerNonce>" if level == "advanced" else None}}

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def cm_provision(json_data_single_op, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    messages = {
        "provision": {
            "provision--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "provision--operationId": None,
            "provision--progressFeedback--objectAmount": None,
            "provision--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "provision--compressionThreshold": None,
            "provision--managerRegistrationId": None,
            "provision--progressFeedback--timeInterval": None,
            "provision--timeout": None,
            "provision--attachmentProperties--compression": None,
            "provision--attachmentProperties--contentType": None,
            "provision--attachmentProperties--checksum--algorithm": None,
            "provision--attachmentProperties--checksum--hash": None,
            "provision--attachmentProperties--primaryDocument": None,
            "provision--planId": None,
            "provision--blockLocalChanges": None,
            "provision--takeFallback": None,
            "provision--extensions--type": None,
            "provision--extensions--attributes--name": None
         },
        "provisionResponse": {
            "provisionResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "provisionResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "provisionResponse--timeout": "<provision--timeout>"
        },
        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<provision--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None
        },
        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        },

    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def pnp_provision(json_data_single_op, *args, **kwargs):
    """author: Marek Piotrowski"""
    level = kwargs.get('level', 'basic')
    messages = {
        "provision": {
            "provision--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "provision--operationId": None,
            "provision--progressFeedback--objectAmount": None,
            "provision--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "provision--compressionThreshold": None,
            "provision--managerRegistrationId": None,
            "provision--progressFeedback--timeInterval": None,
            "provision--timeout": None,
            "provision--attachmentProperties--compression": None,
            "provision--attachmentProperties--contentType": None,
            "provision--planId": None,
            "provision--provisionContent": None,
         },
        "provisionResponse": {
            "provisionResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "provisionResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "provisionResponse--timeout": "<provision--timeout>"
        },
        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<provision--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None
        },
        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        },

    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def unregister(json_data_single_op, *args, **kwargs):
    level = kwargs.get('level', 'basic')
    messages = {"unregister":
                {"unregister--managerRegistrationKey":
                    "<startRegistration--managerNonce>" if level == "advanced" else None,
                 "unregister--managerIdentity--uniqueId":
                     "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
                 "unregister--managerIdentity--type":
                     "<startRegistration--managerIdentity--type>" if level == "advanced" else None,
                 "unregister--managerIdentity--vendor":
                     "<startRegistration--managerIdentity--vendor>" if level == "advanced" else None,
                 "unregister--managerIdentity--release":
                     "<startRegistration--managerIdentity--release>" if level == "advanced" else None,
                 },

                "unregisterResponse":
                    {  # "unregisterResponse--agentIdentity--release": get_sw_release_version(),
                     "unregisterResponse--agentIdentity--type":
                         "<startRegistrationResponse--agentIdentity--type>" if level == "advanced" else None,
                     "unregisterResponse--agentIdentity--uniqueId":
                         "<startRegistrationResponse--agentIdentity--uniqueId>" if level == "advanced" else None,
                     "unregisterResponse--agentIdentity--vendor":
                         "<startRegistrationResponse--agentIdentity--vendor>" if level == "advanced" else None,
                     "unregisterResponse--agentRegistrationKey":
                         "<startRegistrationResponse--agentNonce>" if level == "advanced" else None}}

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_registration(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]


def cm_activate(json_data_single_op, *args, **kwargs):
    """author: Aleksandra Zbieg"""
    level = kwargs.get('level', 'basic')
    messages = {
        "activate": {
            "activate--managerRegistrationKey": "<startRegistration--managerNonce>" if level == "advanced" else None,
            "activate--operationId": None,
            "activate--progressFeedback--objectAmount": None,
            "activate--sessionId": "<startSession--sessionId>" if level == "advanced" else None,
            "activate--compressionThreshold": None,
            "activate--managerRegistrationId": None,
            "activate--progressFeedback--timeInterval": None,
            "activate--timeout": None,
            "activate--planId": None,
            "activate--blockLocalChanges": None,
            "activate--takeFallback": None,
            "activate--extensions--type": None,
            "activate--extensions--attributes--name": None,
            "activate--fallbackId": None,
            "activate--extensions--attributes--value": None,
            "activate--activateContent": None
         },
        "activateResponse": {
            "activateResponse--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "activateResponse--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "activateResponse--timeout": "<activate--timeout>"
        },
        "reportOperationStatus": {
            "reportOperationStatus--operationStatusContent": Names.OPERATION_STATUS_CONTENT.value,
            "reportOperationStatus--agentRegistrationId":
                "<startRegistration--agentUniqueId>" if level == "advanced" else None,
            "reportOperationStatus--attachmentProperties--contentType": Names.CONTENT_TYPE.value,
            "reportOperationStatus--pageSequenceNumber": None,
            "reportOperationStatus--attachmentProperties--compression": None,
            "reportOperationStatus--operationId": "<activate--operationId>",
            "reportOperationStatus--agentRegistrationKey":
                "<startRegistrationResponse--agentNonce>" if level == "advanced" else None,
            "reportOperationStatus--completed": Names.TRUE.value,
            "reportOperationStatus--attachmentProperties--checksum--algorithm": None
        },
        "reportOperationStatusResponse": {
            "reportOperationStatusResponse--managerRegistrationId":
                "<startRegistration--managerIdentity--uniqueId>" if level == "advanced" else None,
            "reportOperationStatusResponse--managerRegistrationKey":
                "<startRegistration--managerNonce>" if level == "advanced" else None
        },

    }

    operation_name = inspect.currentframe().f_code.co_name  # function name
    logger.debug("Reading parameters for operation: {} - start".format(operation_name))
    parameter_values, errors = get_message_values_from_json(json_data_single_op, messages)
    logger.debug("Reading parameters for operation: {} - end".format(operation_name))
    if level == "advanced":
        err_reg, par_val_reg = start_session(json_data_single_op, level=level)
        parameter_values.update(par_val_reg)
        errors.extend(err_reg)
    logger.debug("Validation parameters for operation: {} - start".format(operation_name))
    err = validate_messages(messages, parameter_values)
    logger.debug("Validation parameters for operation: {} - end".format(operation_name))
    errors.extend(err)
    return [errors, parameter_values]
