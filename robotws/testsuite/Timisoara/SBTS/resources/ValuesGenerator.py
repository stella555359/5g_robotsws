def get_faults_list_of_dicts(fault_numbers_list):
    result_dict = [{"faultNumber": str(i), "triggerType": "onFaultDetection"} for i in fault_numbers_list]
    return result_dict


def get_fault_triggers_list(reals, fakes=0):
    reals = int(reals)
    real_triggers = [10, 16, 22, 23]
    fake_triggers = []
    for i in range(24, 24 + fakes):
        fake_triggers.append(i)

    return get_faults_list_of_dicts(real_triggers[:reals] + fake_triggers)


def get_TRBLCADM_object_parameters():
    mandatory_object_parameters = [
        {
            "parameterName": "actCoreDumpFileCollection",
            "operation": "update",
            "value": "true"
        },
        {
            "parameterName": "actInternalTrace",
            "operation": "update",
            "value": "true"
        },
        {
            "parameterName": "actRemoteSyslogTransmission",
            "operation": "update",
            "value": "false"
        },
        {
            "parameterName": "snapshotUploadDelayForFault6450",
            "operation": "update",
            "value": "0"
        },
        {
            "parameterName": "diagSnapDestination",
            "operation": "update",
            "value": "lss"
        }
    ]

    return mandatory_object_parameters
