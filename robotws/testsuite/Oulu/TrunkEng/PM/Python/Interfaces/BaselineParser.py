import xml.etree.ElementTree as etr
import re
import os

kept_elements = [
    "MeasurementID",
    "MeasurementName",
    "Name",
    "Intervals",
    "Network_Profile",
    "NW_Aggregation_Levels",
    "Remarks",
]

kept_counters = [
    "PI_ID",
    "LogicalType"
]


class BaselineParser:

    @staticmethod
    def escape_xml_illegal_chars(unicode_string):
        return re.sub(u'[^\x00-\x7F]+', ' ', unicode_string)

    def read_and_write_xml(self, xml_file):
        print("Try to escape illegal characters")
        new_xml_file = xml_file.replace(".xml", "_without_illegal_chars.xml")
        with open(xml_file, "rb") as r, open(new_xml_file, "wb") as w:
            for line in r:
                w.write(self.escape_xml_illegal_chars(line.decode('utf-8')).encode('utf-8'))
        print("Escaped successfully")
        return new_xml_file

    @staticmethod
    def delete_temp_file(temp_file):
        print(f"Delete temp file: {temp_file}")
        return os.remove(temp_file)

    @staticmethod
    def write_aom_parameter_to_remarks(orig_element, measurement):
        for element in measurement[:]:
            if "Remarks" in element.tag:
                element.text = "parameterId:{}".format(str(orig_element.text).strip())

    @staticmethod
    def copy_measurements(lines):
        copy = False
        copied_data = []
        for line in lines:
            if "<Measurement>" in line:
                copied_data.append(line)
                copy = True
            elif "</Measurement>" in line:
                copied_data.append(line)
                copy = False
            elif copy:
                copied_data.append(line)
        return copied_data

    @staticmethod
    def find_last_measurement(data):
        return max(idx for idx, val in enumerate(data) if val.strip() == '</Measurement>')

    @staticmethod
    def merge_data(file_data, new_data, merge_index):
        file_data[merge_index+1:merge_index+1] = new_data
        return file_data

    def merge_copied_data(self, file_data, new_data_list):
        merge_index = self.find_last_measurement(file_data)
        return self.merge_data(file_data, new_data_list, merge_index)

    def combine_baseline_files(self, files, save_location):
        copied_data = []
        for baseline_file in files[:-1]:  # skip last file
            print("Try to combine baseline files")
            with open(baseline_file, 'r') as infile:
                in_lines = infile.readlines()
            copied_data.extend(self.copy_measurements(in_lines))
        with open(files[-1], 'r') as outfile:
            out_lines = outfile.readlines()
        merged_data = self.merge_copied_data(out_lines, copied_data)
        with open(save_location, 'w') as writefile:
            writefile.writelines(merged_data)
        print(f"files list: {files}")
        for temp_file in files:
            self.delete_temp_file(temp_file)
        print("Combined and saved")

    def parse_baseline_files(self, baseline_files, save_location):
        """
        Parse baseline files and remove unnecessary elements and counters
        :param list baseline_files: List of baseline files (2 or more)
        :param str save_location: Save location for the combined baseline file
        """
        print("Script started")
        parsed_files = []
        for baseline_file in baseline_files:
            if baseline_file:
                print(f"File: {baseline_file}")
                xml_file = self.read_and_write_xml(baseline_file)
                print("Parse xml file")
                tree = etr.parse(xml_file)
                root = tree.getroot()
                print("Parsed")
                measurements = root.findall(r'.//Measurement')
                for measurement in measurements:
                    for element in measurement[:]:  # shallow copy for not losing information over iteration
                        if "Aom_Parameter" in element.tag and element.text:
                            self.write_aom_parameter_to_remarks(element, measurement)
                        if "PI" in element.tag:
                            for counter in element[:]:
                                if counter.tag not in kept_counters:
                                    element.remove(counter)
                        elif element.tag not in kept_elements:
                            measurement.remove(element)
                print("Edited")
                temp_file_name = baseline_file.replace(".xml", f"_temp.xml")
                print(f"Temp file: {temp_file_name}")
                parsed_files.append(temp_file_name)
                tree.write(temp_file_name)
                print("Wrote")
                self.delete_temp_file(xml_file)

        self.combine_baseline_files(parsed_files, save_location)
