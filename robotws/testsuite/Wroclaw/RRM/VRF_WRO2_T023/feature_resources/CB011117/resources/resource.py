from robot.libraries.BuiltIn import BuiltIn
import csv


ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def contain_subband(file_path):
    with open(file_path) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for line in csv_reader:
            if line["dlFdSchedData.beamType"] == "SUBBAND":
                return True

    return False
