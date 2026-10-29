import re


def get_object_id_from_meas_config_output(meas_config_output, ue_id, carrier_freq, eutra):
    obj_id = ''
    object_table_regex = 'UE{0} MEASUREMENT OBJECTS.*UE{1} EUTRA MEASUREMENT OBJECTS'.format(ue_id, ue_id)
    object_table_match = re.search(object_table_regex, repr(meas_config_output), re.MULTILINE)
    if eutra:
        pattern_regex = '(\\d+)\\s+EUTRAN\\s+{}'.format(carrier_freq)
    else:
        pattern_regex = '(\\d+)\\s+NR\\s+{}'.format(carrier_freq)
    if object_table_match:
        obj_id = re.findall(pattern_regex, repr(object_table_match.group()), re.MULTILINE)
        print("object ids are", obj_id)
        if obj_id:
            print("object id for carrier frequency {0} can be  {1}".format(carrier_freq, obj_id))
        else:
            raise Exception("unable to find object id for carrier frequency - {}".format(carrier_freq))
    return obj_id


def get_report_id_from_meas_config_output(meas_config_output, ue_id, event, eutra):
    report_id = ''
    report_table_regex = 'UE{} NR REPORT CONFIGURATIONS.*DETAILED INFO ABOUT NR REPORT CONFIGURATIONS'.format(ue_id)
    report_table_match = re.search(report_table_regex, repr(meas_config_output))
    if eutra:
        pattern_regex = '(\\d+)\\s+EUTRA\\s+{}'.format(event)
    else:
        pattern_regex = '(\\d+)\\s+NR\\s+{}'.format(event)
    if report_table_match:
        report_id = re.findall(pattern_regex, repr(report_table_match.group()), re.MULTILINE)
        print("report ids are", report_id)
        if report_id:
            print("report id for {0} can be {1}".format(event, report_id))
        else:
            raise Exception("unable to find report id for event - {}".format(event))
    return report_id


def get_measurement_id_from_measurement_config_output(meas_config_output, ue_id, obj_id, report_id):
    measurement_id = ''
    identity_table_regex = r'=== UE{} NR MEASUREMENT IDENTITIES:.*?EGATE'.format(ue_id)
    identity_table_match = re.search(identity_table_regex, meas_config_output, re.DOTALL)
#    pattern_regex = '(\\d+)\\s+{}\\s+{}'.format(object_id, report_id)
    if identity_table_match:
        identity_table_match = identity_table_match.group().replace('\r\n', '\n')
        for object_id in obj_id:
            for rep_id in report_id:
                print(f"\nchecking for {object_id} and {rep_id}\n\n")
                pattern_regex = r'(\d+)\s+{}\s+{}\s*$'.format(object_id, rep_id)
                meas_id = re.search(pattern_regex, identity_table_match, re.MULTILINE)
                if meas_id:
                    print("measurement id for object id {0} and report id {1} is {2}".format(object_id, rep_id,
                                                                                             meas_id.group(1)))
                    measurement_id = meas_id.group(1)
                    break
                else:
                    print("measurement id combination not found for object id {0} and report id {1}"
                          " trying to check next report id-object id combination".format(object_id, rep_id))
    return measurement_id


def get_measurement_id_based_on_carrier_freq_and_event(meas_config_output, ue_id, carrier_freq, event, eutra=False):
    object_id = get_object_id_from_meas_config_output(meas_config_output, ue_id, carrier_freq, eutra)
    report_id = get_report_id_from_meas_config_output(meas_config_output, ue_id, event, eutra)
    meas_id = get_measurement_id_from_measurement_config_output(meas_config_output, ue_id, object_id, report_id)
    if meas_id == '':
        raise Exception("Measurement Id not found for the given event")
    return meas_id


if __name__ == "__main__":
    get_measurement_id_based_on_carrier_freq_and_event()
