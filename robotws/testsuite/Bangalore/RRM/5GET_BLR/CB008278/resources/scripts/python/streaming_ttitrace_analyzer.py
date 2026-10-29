import csv
import logging
logging.basicConfig(level=logging.INFO)


class ttitrace():
    def __init__(self, ttitrace_file):
        self.in_file = ttitrace_file

    def filter_source_column_return_self(self, source_column_name, condition=["0", "", "0.0"], operation="except",
                                         remove_duplicate="no"):
        print("argument operation={}".format(operation))
        print("argument condition={}".format(condition))
        with open(self.in_file) as fh:
            data = csv.DictReader(fh,)
            ret_list = []
            for line in data:
                try:
                    value = line[source_column_name]
                except ValueError:
                    logging.error("source_column_name={} doesn't exist in {}".format(
                        source_column_name, self.in_file))
                    return
                if operation == "except":
                    if value not in condition:
                        ret_list.append(value)
                elif operation == "include":
                    if value in condition:
                        ret_list.append(value)
        logging.debug("ret_list={}".format(ret_list))
        if remove_duplicate == "yes":
            ret_list = list(set(ret_list))
        return ret_list

    def filter_source_column_return_other(self, source_column_name, condition=["0", ""], operation="except",
                                          target_column_name="", remove_duplicate="no"):
        with open(self.in_file) as fh:
            data = csv.DictReader(fh,)
            ret_list = []
            for line in data:
                try:
                    value = line[source_column_name]
                    return_value = line[target_column_name]
                except ValueError:
                    logging.error("source_column_name={} doesn't exist in {}".format(
                        source_column_name, self.in_file))
                    return
                if operation == "except":
                    if value not in condition:
                        ret_list.append(return_value)
                elif operation == "include":
                    if value in condition:
                        ret_list.append(return_value)
        if remove_duplicate == "yes":
            ret_list = list(set(ret_list))
        logging.debug("ret_list={}".format(ret_list))
        return ret_list

    def filter_2source_column_return_other(self, source_column_name1, source_column_name2, condition1=["0", ""],
                                           operation1="except",
                                           condition2=["0", ""], operation2="except",
                                           target_column_name="", remove_duplicate="no"):
        with open(self.in_file) as fh:
            data = csv.DictReader(fh,)
            ret_list = []
            for line in data:
                try:
                    value1 = line[source_column_name1]
                    value2 = line[source_column_name2]
                    return_value = line[target_column_name]
                except ValueError:
                    logging.error("source_column_name1={} doesn't exist in {}".format(
                        source_column_name1, self.in_file))
                    return
                if operation1 == "except" and operation2 == "except":
                    if value1 not in condition1 and value2 not in condition2:
                        ret_list.append(return_value)
                elif operation1 == "include" and operation2 == "except":
                    if value1 in condition1 and value2 not in condition2:
                        ret_list.append(return_value)
                elif operation1 == "except" and operation2 == "include":
                    if value1 not in condition1 and value2 in condition2:
                        ret_list.append(return_value)
                elif operation1 == "include" and operation2 == "include":
                    if value1 in condition1 and value2 in condition2:
                        ret_list.append(return_value)
        if remove_duplicate == "yes":
            ret_list = list(set(ret_list))
        logging.debug("ret_list={}".format(ret_list))
#        if ret_list == []:
#            raise TypeError('ret_list error')
        return ret_list


def filter_source_column_return_self(file_name, source_column_name, condition=["0", ""], operation="except",
                                     remove_duplicate="no"):
    """
    :param file_name:
    :param source_column_name:
    :param condition: list, default=["0",""]
    :param operation: "except" or "include",default="except"
    :param remove_duplicate:"yes","no",default="no"
    :return: filtered list
    """
    obj_ttitrace = ttitrace(file_name)
    source_column_list = obj_ttitrace.filter_source_column_return_self(
        source_column_name, condition=condition, operation=operation, remove_duplicate=remove_duplicate)
    logging.debug("source_column_list={}".format(source_column_list))
    return source_column_list


def filter_source_column_return_other(file_name, source_column_name, condition=["0", ""], operation="except",
                                      target_column_name="", remove_duplicate="no"):
    """
    :param file_name:
    :param source_column_name:
    :param condition: list, default=["0",""]
    :param operation:"except" or "include",default="except"
    :param target_column_name:
    :param remove_duplicate:"yes","no",default="no"
    :return:
    """
    obj_ttitrace = ttitrace(file_name)
    target_column_list = obj_ttitrace.filter_source_column_return_other(
        source_column_name, condition=condition, operation=operation, target_column_name=target_column_name,
        remove_duplicate=remove_duplicate)
    return target_column_list


def filter_2source_column_return_other(file_name, source_column_name1, source_column_name2, condition1=[],
                                       operation1="include",
                                       condition2=[], operation2="include",
                                       target_column_name="", remove_duplicate="no"):
    obj_ttitrace = ttitrace(file_name)
    target_column_list = obj_ttitrace.filter_2source_column_return_other(
        source_column_name1, source_column_name2, condition1=condition1, operation1=operation1, condition2=condition2,
        operation2=operation2, target_column_name=target_column_name,
        remove_duplicate=remove_duplicate)
    return target_column_list


def count_interval(source_column_list, remove_duplicate="yes"):
    len1 = len(source_column_list)
    interval_list = []
    for i in range(len1-1):
        interval = int(source_column_list[i+1])-int(source_column_list[i])
        interval_list.append(interval)
    if remove_duplicate == "yes":
        interval_list = list(set(interval_list))
    return interval_list


if __name__ == "__main__":
    def test_case_1():
        print("test for duning 1")
        _5qi1 = filter_source_column_return_self("./streaming_test_data/output_ul.csv", "ulFdSchedData.numOf5qi1Prb",
                                                 condition=["0", "", "0.0"], operation="except",
                                                 remove_duplicate="yes")
        rnti_list = filter_source_column_return_other("./streaming_test_data/output_ul.csv",
                                                      "ulFdSchedData.numOf5qi1Prb", condition=[
                                                          "0", "", "0.0"], operation="except",
                                                      target_column_name="rnti",
                                                      remove_duplicate="yes")
        print("_5qi1={}".format(_5qi1))
        print("rnti_list={}".format(rnti_list))
        class_list = filter_source_column_return_other("./streaming_test_data/output_ul.csv", "rnti",
                                                       condition=rnti_list,
                                                       operation="include",
                                                       target_column_name="ulTdSchedSubcellData.resReqClassPrio",
                                                       remove_duplicate="yes")
        print("class_list={}".format(class_list))

    def test_case_2():
        print("test for duning 2")
        sfn_list = filter_source_column_return_other("./streaming_test_data/output_ul.csv",
                                                     "ulFdSchedData.numOf5qi1Prb", condition=[
                                                         "0", "", "0.0"], operation="except",
                                                     target_column_name="sfn", remove_duplicate="no")
        print("sfn_list={}".format(sfn_list))
        interval_list = count_interval(sfn_list, "no")
        print("interval_list={}".format(interval_list))

    def test_case_3():
        print("test for sujuan")
        vp = filter_source_column_return_self(
            "./streaming_test_data/output_ul.csv", "voipVcdTimerData.adaptVoipPacketSize",
            condition=[""], operation="except", remove_duplicate="no")
        print("vp={}".format(vp))
    test_case_1()
    test_case_2()
    test_case_3()
