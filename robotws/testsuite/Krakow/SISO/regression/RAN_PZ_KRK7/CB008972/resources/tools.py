import testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords as krk7keywords


def check_active_alarms(allowed_alarms_list, sbts_alarms_list):
    allowed_alarms_list = [int(a) for a in allowed_alarms_list]
    forbidden = [alarm['additionalFaultID'] for alarm in sbts_alarms_list
                 if alarm['additionalFaultID'] not in allowed_alarms_list]
    if forbidden:
        raise Exception(f"Forbidden alarms: {forbidden}")


def get_scf_path_from_robotws(file_name: str):
    return krk7keywords.get_default_scf_path(file_name)
