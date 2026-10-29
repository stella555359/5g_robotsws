import sys
import io
import re
import csv
import traceback
import StringTool


class SherpaCsvReader:
    """
    Class to manage a single csv generated files, for reading and manage content for Sherpa
    self.sherpa_list: content of the csv file
    read a file using setup_reader before all
    To use it as a keyword library, import it in your robot test using (WITH NAME is optional)
    Library      resources/sites/NPS/SWENG/python/SherpaCsvReader.py    WITH NAME    csv_reader
    """

    def __init__(self):
        """
        Builds a dict reading a csv sherpa generated file
        :return: none
        """
        self.csv_file_path = None
        self.sherpa_dict_reader = None
        # content of your sherpa file will be here
        self.sherpa_list = list()

    def setup_reader(self, file_path):
        """
        Method reading a csv file.
        It sets csv_file_path to the given file path and the related reader sherpa_dict_reader
        Teh usage of this method is === MANDATORY === before doing anything on a csv file
        :file_path: file path of the csv file to be analysed
        :return: none
        """
        self.sherpa_list = list()
        self.csv_file_path = file_path
        try:
            with io.open(self.csv_file_path, encoding='utf-8', newline='') as csvfile:
                self.sherpa_dict_reader = csv.DictReader(
                    csvfile, delimiter=';')
                for row in self.sherpa_dict_reader:
                    row_dict_keys = row.keys()
                    row_dict_values = row.values()
                    row_dict = self.join_lists_todict_using_zip(
                        row_dict_keys, row_dict_values)
                    self.sherpa_list.append(row_dict)
        except Exception:
            traceback.print_tb(sys.exc_info()[2])
            print(sys.exc_info())
            raise Exception(
                "Unable to open file: {})".format(
                    self.csv_file_path))

    def join_lists_todict_using_zip(self, row_dict_keys, row_dict_values):
        """
        internal method!
        joins the list of keys and values together to form a dict
        :row_dict_keys: colums names
        :row_dict_values: values for a given row
        :return: row_dict
        """
        row_dict = dict()
        zipped = zip(row_dict_keys, row_dict_values)
        for item in zipped:
            if item[0] != '':
                row_dict[item[0]] = item[1]
        return row_dict

    def get_csv_size(self):
        """
        reads the internal dictionary generated from a sherpa csv file
        its size corresponds to number of rows in the csv file
        :return: the internal dictionary size
        """
        if self.sherpa_list:
            return len(self.sherpa_list)
        else:
            raise Exception("Internal list is empty")

    def get_csv_columns(self):
        """
        reads the internal dictionary generated from a sherpa csv file
        :return: a list containing the elements keys, corresponding to file columns
        """
        if len(self.sherpa_list) >= 1:
            return self.sherpa_list[0].keys()
        else:
            raise Exception("Internal list is empty")

    def get_all_values_column(self, column, regexfilter=None):
        """
        reads the internal dictionary generated from a sherpa csv file
        :column: the colums for which the values are demanded
        :regexfilter: filter regular expression to match rows
        :return: a list containing all the values for the given column
        """
        if len(self.sherpa_list) >= 1:
            if regexfilter is None:
                values_list = [item[column] for item in self.sherpa_list]
            else:
                values_list = [
                    item[column] for item in self.sherpa_list if re.search(
                        regexfilter, item[column])]
            return values_list
        else:
            raise Exception("Internal list is empty")

    def get_all_values_column2_from_column1(
            self,
            column1,
            column2,
            regexfilter=None,
            regexfilter2=None):
        """
        reads the internal dictionary generated from a sherpa csv file
        :column1: the colums for which the values are demanded
        :column2: the colums for which the values based on column1
        :regexfilter: filter regular expression to match rows
        :regexfilter2: filter regular expression to match rows
        :return: a list containing all the values for the given column2
        """
        if len(self.sherpa_list) >= 1:
            if regexfilter is None:
                values_list = [item[column2] for item in self.sherpa_list]
            elif regexfilter2 is None:
                values_list = [
                    item[column2] for item in self.sherpa_list if regexfilter == item[column1]]
            else:
                values_list = [item[column2] for item in self.sherpa_list if all(
                    (regexfilter == item[column1], re.search(regexfilter2, item[column2])))]
            return values_list
        else:
            raise Exception("Internal list is empty")

    def get_all_values_column2_from_uzzy_matching_column1(
            self, column1, column2, regexfilter=None, regexfilter2=None):
        """
        reads the internal dictionary generated from a sherpa csv file
        :column1: the colums for which the values are demanded
        :column2: the colums for which the values based on column1
        :regexfilter: filter regular expression to match rows
        :regexfilter2: filter regular expression to match rows
        :return: a list containing all the values for the given column2
        """
        if len(self.sherpa_list) >= 1:
            if regexfilter is None:
                values_list = [item[column2] for item in self.sherpa_list]
            elif regexfilter2 is None:
                values_list = [
                    item[column2] for item in self.sherpa_list if re.search(
                        regexfilter, item[column1])]
            else:
                values_list = [item[column2] for item in self.sherpa_list if all(
                    (regexfilter == item[column1], re.search(regexfilter2, item[column2])))]
            return values_list
        else:
            raise Exception("Internal list is empty")

    def remove_dumplicates_list(self, list):
        list1 = []
        for i in list:
            if i not in list1:
                list1.append(i)
        return list1

    def count_dumplicates_list(self, list1):
        """
        retrun a sigle count value
        """
        list2 = list(set(list1))
        count_times = ""
        for i in list2:
            if i != "":
                count_times = list1.count(i)
                return count_times

    def count_dumplicates_list_get_count_list(self, list1):
        """
        retrun a  count list
        """
        list2 = list(set(list1))
        count_times = ""
        count_times_list = []
        for i in list2:
            if i != "":
                count_times = list1.count(i)
                count_times_list.append(count_times)
        return count_times_list

    def check_all_values_for_column(self, column, values_list_tocheck):
        """
        reads the internal dictionary generated from a sherpa csv file
        :column: the colums for which the values have to be checked
        :values_list_tocheck: a list of value to check
        :return: True if all the values are present, False if at least one is not present
        """
        result = False
        if len(self.sherpa_list) >= 1:
            values_list = [item[column] for item in self.sherpa_list]

            print("\n values_list: " + str(values_list))

            StringTool.console(
                "\nvalues to check:\n" +
                str(values_list_tocheck))
            if isinstance(values_list_tocheck, list):
                for elem_tocheck in values_list_tocheck:
                    result = elem_tocheck in values_list
                    if not result:
                        break
            elif isinstance(values_list_tocheck, str) or isinstance(values_list_tocheck, unicode):
                result = values_list_tocheck in values_list
            else:
                raise Exception(
                    "value parameter is not a list or a string value")
        return result

    def check_csv_column_match_all(self, column, regex_tocheck):
        """
        reads the internal dictionary generated from a sherpa csv file
        :column: the colums for which the values have to be checked
        :regex_tocheck: a regex to check on all the column values
        :return: True if all the values match the regex, False if at least one does not
        """
        # values_list = self.get_all_values_column(column)
        values_list = [item[column] for item in self.sherpa_list]

        result = True if (values_list and len(values_list) > 0) else False
        print("\nres after list first check: {}".format(result))
        for row in values_list:
            print("\n Current row: " + str(row))
            if not re.search(regex_tocheck, row):
                result = False
                print("Not matching value: {}".format(row))
                break
        return result, values_list

    def check_values_column_matching_regex_match_another(
            self, column, regexcondition, regexcheck):
        """
        reads the internal dictionary generated from a sherpa csv file
        :column: the colums for which the values have to be checked
        :regexcondition: a confdition filter on all the column values
        :regexcheck: a regex to check on all the column values for witch filter is matched
        :return: True if all the filtered values match the regexcheck, False if at least one does not
        """
        values_list = self.get_all_values_column(column, regexcondition)
        result = True if (values_list and len(values_list) > 0) else False
        for row in values_list:
            if re.search(r'{}'.format(regexcondition), row):
                if not re.search(r'{}'.format(regexcheck), row):
                    result = False
                    print("Found a NOT matching value: {}".format(row))
                break
        return result, values_list

    def check_value_list_column_when_value(
            self,
            req_column,
            req_column_value,
            check_list_column,
            check_list):
        """
        Reads the internal dictionary generated from a sherpa csv file, then checks a list of values in
        all the rows matching the required value for a given colum
        :req_column: the colums for which the a required value have to be checked
        :req_column_value: the value to be checked to filter the rows
        :check_list_column: the column in which the list of values have to be checked
        :check_list: list of values to be checked in the colum for the filtered rows
        :return: True if all the values are present in the filtered rows, False if at least one is not present
                in at least one filtered row
        """
        if len(self.sherpa_list) >= 1:
            values_list = [(item[req_column], item[check_list_column])
                           for item in self.sherpa_list if item[req_column] == req_column_value]
        result = True if (values_list and len(values_list) > 0) else False
        print("\nres after list first check: {}".format(result))
        for row in values_list:
            for elem in check_list:
                if elem not in row[1]:
                    result = False
                    print("Not matching value: {}".format(row))
                    break
            if not result:
                break
        return result, values_list

    def print_all(self):
        """
        prints the content of the internal dictionary generated from a sherpa csv file
        """
        if self.sherpa_list:
            try:
                for row in self.sherpa_list:
                    print(row)
            except Exception:
                raise Exception(
                    "error reding list: {})".format(
                        self.sherpa_list))
        else:
            raise Exception("Internal  list is empty")
