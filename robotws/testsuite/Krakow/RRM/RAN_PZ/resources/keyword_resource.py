from robot.libraries.BuiltIn import BuiltIn


def get_library_instance(library):
    instance = BuiltIn().get_library_instance(library)
    if not instance:
        raise ImportError("Unable to access %s instance, check if library is imported" % instance)
    return instance


def get_sum_of_all_counters(pm_info):
    count = 0
    pm_cells = pm_info['BTS']['CELLS']
    measurement_sum = {}
    for _, pm_values in pm_cells.items():
        pm_measurement = pm_values['NULSQ'] if 'NULSQ' in pm_values else pm_values['NDLSQ']
        for measurement, value in pm_measurement.items():
            measurement_sum[measurement] = sum(value.values())
    count = sum(measurement_sum.values())
    return count


def get_list_of_measurement_ID_for_SINR(base_id):
    pm_list = ','.join([base_id + "{:02d}".format(n) for n in range(1, 28)])
    return pm_list


def get_list_of_measurement_ID_for_CQI(base_id):
    pm_list = ','.join([base_id + "{:02d}".format(n) for n in range(1, 16)])
    return pm_list
