from taf.analyzer.pmcounter import PMCounterLogReader


def get_cell_counter_value_from_pm_file(pm_file, counter_name,
                                        cell_id=1,
                                        index=0):
    return get_counter_value_from_pm_file_for_object(pm_file,
                                                     "NRCELL",
                                                     counter_name,
                                                     cell_id, index)


def get_all_cell_counters_from_pm_file(pm_file, cell_id, index, counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = \
            get_cell_counter_value_from_pm_file(pm_file,
                                                counter_name,
                                                cell_id,
                                                index)
    return counter_values


def get_counter_value_from_pm_file_for_object(pm_file, object_name,
                                              counter_name,
                                              object_id=1,
                                              index=0):
    pm_xpath = "//{object_name}[@id='{object_id}']//@{counter_name}".\
        format(object_name=object_name, object_id=object_id,
               counter_name=counter_name)
    with open(pm_file) as pm_file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[pm_file_obj]):
            try:
                return log_entry.pm_setup.xpath(pm_xpath)[index]
            except IndexError as e:
                continue
        raise AssertionError('Counter Value {} is not '
                             'present for {} in {}'.
                             format(counter_name, object_name, pm_file))


def get_all_counters_from_pm_file_for_object(pm_file, object_name,
                                             object_id,
                                             index,
                                             counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = \
            get_counter_value_from_pm_file_for_object(pm_file,
                                                      object_name,
                                                      counter_name,
                                                      object_id,
                                                      index)
    return counter_values
