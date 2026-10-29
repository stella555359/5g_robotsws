from taf.analyzer.pmcounter import PMCounterLogReader
from taf.analyzer.pmcounter import interface
import logging
import os
import re


def get_counter_values_from_dir(pi_dir, object_name, counter_name, object_id=1):
    pi_file_pattern = "*PM*.xml"
    logging.debug("reading counter {} values from {}-{} in {}/{}".format(counter_name,
                                                                         object_name,
                                                                         object_id,
                                                                         pi_dir,
                                                                         pi_file_pattern))
    values_list = []
    # taf.analyzer.pmcounter 1.0.1 compatible :
    # for log_entry in PMCounterLogReader.from_dir(dir_path=pi_dir, file_pattern=pi_file_pattern):
    # taf.analyzer.pmcounter 0.3.4 compatible :
    for log_entry in PMCounterLogReader.from_dir(pm_dir=pi_dir, file_pattern=pi_file_pattern):
        values_list.extend(log_entry.pm_setup.xpath("//{object_name}[@id='{object_id}']//@{pi_name}"
                                                    .format(object_name=object_name,
                                                            object_id=object_id,
                                                            pi_name=counter_name)))
        # to get all counter values without object and id filtering :
        # values_list.extend(log_entry.pm_setup.findall(counter_name))
    return values_list


def get_latest_single_counter_value(pm_file, counter_name):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))
        latest_counter = ""
        latest_pi_date = ""
        for pi_dict_values in pi_dict_values_list:
            for pi_date, pi_dict_value in pi_dict_values.items():
                for pi_key_id, pi_xpath_value in pi_dict_value.items():
                    for pi_key_xpath, pi_value in pi_xpath_value.items():
                        if latest_pi_date == "" or str(pi_date) > latest_pi_date:
                            latest_counter = pi_value
                            latest_pi_date = str(pi_date)
                        else:
                            print(">> date {} ignored".format(pi_date))
        print("Counter {} extracted from date {} : {}".format(counter_name, latest_pi_date, latest_counter))
        return str(latest_counter)
    except Exception as e:
        print(e)
    return ""


def get_earliest_single_counter_value(pm_file, counter_name):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))
        earliest_counter = ""
        latest_pi_date = ""
        for pi_dict_values in pi_dict_values_list:
            for pi_date, pi_dict_value in pi_dict_values.items():
                for pi_key_id, pi_xpath_value in pi_dict_value.items():
                    for pi_key_xpath, pi_value in pi_xpath_value.items():
                        if latest_pi_date == "" or str(pi_date) < latest_pi_date:
                            earliest_counter = pi_value
                            latest_pi_date = str(pi_date)
                        else:
                            print(">> date {} ignored".format(pi_date))
        print("Counter {} extracted from date {} : {}".format(counter_name, latest_pi_date, earliest_counter))
        return str(earliest_counter)
    except Exception as e:
        print(e)
    return ""


def get_latest_single_counter_value_with_CellID(pm_file, counter_name, cell_id):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))
        latest_counter = ""
        latest_pi_date = ""
        for pi_dict_values in pi_dict_values_list:
            for pi_date, pi_dict_value in pi_dict_values.items():
                for pi_key_id, pi_xpath_value in pi_dict_value.items():
                    for pi_key_xpath, pi_value in pi_xpath_value.items():
                        idEx = extractId(pi_key_xpath)
                        if latest_pi_date == "" or str(pi_date) > latest_pi_date:
                            read_counter = pi_value
                            read_pi_date = str(pi_date)
                            if idEx == cell_id:
                                latest_counter = pi_value
                                latest_pi_date = str(pi_date)
                        else:
                            print(">> date {} ignored".format(pi_date))
        print("Counter {} extracted from date {} : {}".format(counter_name, latest_pi_date, latest_counter))
        return str(latest_counter)
    except Exception as e:
        print(e)
    return ""


def get_sum_of_counter_values_with_cellid(pm_file, counter_name, cell_id):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))
        sum_retrieved = 0
        for pi_dict_values in pi_dict_values_list:
            for pi_date, pi_dict_value in pi_dict_values.items():
                for pi_key_id, pi_xpath_value in pi_dict_value.items():
                    for pi_key_xpath, pi_value in pi_xpath_value.items():
                        obj = pi_key_xpath.split("/")[-1]
                        objid = obj.split("-")[1]
                        if pi_value == "":
                            print("pi_value_empty: {}".format(pi_value))
                        else:
                            if cell_id == objid:
                                sum_retrieved = sum_retrieved + int(pi_value)
        print("6_xxx_final_sum_retrieved: {}".format(sum_retrieved))
        return str(sum_retrieved)
    except Exception as e:
        print(e)
    return ""


def fetch_from_file_cell_counter_value(pm_file, counter_name, cell_id=1, index=0):
    return fetch_from_file_counter_value_by_object(pm_file, "NRCELL", counter_name, cell_id, index)


def fetch_from_file_all_cell_counters(pm_file, cell_id, index, counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = fetch_from_file_cell_counter_value(pm_file,
                                                                          counter_name,
                                                                          cell_id,
                                                                          index)
    return counter_values


def fetch_from_file_counter_value_by_object(pm_file,
                                            object_name,
                                            counter_name,
                                            object_id=1,
                                            index=0):
    # for_debug
    logging.debug("pm_file : {} object_name : {} counter_name : {} object_id : {} index : {}".format(
        pm_file, object_name, counter_name, object_id, index))
    pm_xpath = "//{object_name}[@id='{object_id}']//@{counter_name}".format(object_name=object_name,
                                                                            object_id=object_id,
                                                                            counter_name=counter_name)
    with open(pm_file, "rb") as pm_file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[pm_file_obj]):
            try:
                return log_entry.pm_setup.xpath(pm_xpath)[index]
            except IndexError as e:
                # continue
                return ""
        raise AssertionError('Counter Value {} is not present for {} in {}'.format(counter_name,
                                                                                   object_name,
                                                                                   pm_file))


# NEW update all values
def fetch_from_file_counter_values_by_object(pm_file, object_name, counter_name, object_id=1):
    # for_debug
    logging.debug("pm_file : {} object_name : {} counter_name : {} object_id : {}".format(pm_file,
                                                                                          object_name,
                                                                                          counter_name,
                                                                                          object_id))
    # pm_xpath = "//{object_name}[@id='{object_id}']//@{counter_name}".format(object_name=object_name,
    #                                                                         object_id=object_id,
    #                                                                         counter_name=counter_name)
    pm_xpath = "//{}[@id='{}']//@{}".format(object_name, object_id, counter_name)
    with open(pm_file, "rb") as pm_file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[pm_file_obj]):
            return log_entry.pm_setup.xpath(pm_xpath)


# NEW update latest values
def fetch_from_file_counter_latest_values_by_object(pm_file,
                                                    object_name,
                                                    counter_name,
                                                    object_id=1):
    # for_debug
    logging.debug("pm_file : {} object_name : {} counter_name : {} object_id : {}".format(pm_file,
                                                                                          object_name,
                                                                                          counter_name,
                                                                                          object_id))
    pm_xpath = "//{object_name}[@id='{object_id}']//@{counter_name}".format(object_name=object_name,
                                                                            object_id=object_id,
                                                                            counter_name=counter_name)
    with open(pm_file, "rb") as pm_file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[pm_file_obj]):
            # for_debug
            val_lis = log_entry.pm_setup.xpath(pm_xpath)
            # for_debug
            logging.debug("val_lis : {}".format(val_lis))
            val_lis.reverse()
            # for_debug
            logging.debug(" val_lis_reverse : {} ".format(val_lis))
            # check if val_lis[0] is not empty
            # return log_entry.pm_setup.xpath(pm_xpath)
            try:
                logging.debug(" val_lis_reverse0 : {}".format(val_lis[0]))
                return val_lis[0]
            except IndexError as e:
                # continue
                return ""
        raise AssertionError('Counter Value {} is not present for {} in {}'.format(counter_name,
                                                                                   object_name,
                                                                                   pm_file))


def fetch_from_file_all_counters_by_object(pm_file, object_name, object_id, index, counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = fetch_from_file_counter_value_by_object(pm_file,
                                                                               object_name,
                                                                               counter_name,
                                                                               object_id,
                                                                               index)
    return counter_values


def extractId(pname):
    idExtract = None
    m1 = re.match(r".*NRCELL-(\d\d?)", pname)
    if m1:
        idExtract = m1.group(1)
    return idExtract
