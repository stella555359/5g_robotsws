import os
import sys
import pytest
import json
from taf.analyzer.pmcounter import PMCounterLogReader

#
# Reactivate to perform pytests, comment to respect PEP8
# import sys
# import os
# sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
# Comment until previous line to commit and merge

import create_pretty_kpi_file_new as pretty_kpi
from GetFiles import download_package_using_git

CTR_FILE = "PM.BTS-1.20250312.154500.ANY.xml"


def download_if_not_exists(repo_url, directory, filename, token_name, token_value):
    file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), filename)
    if not os.path.exists(file_path):
        download_package_using_git(repo_url, directory, filename, token_name, token_value,
                                   target_dir=os.path.dirname(os.path.abspath(__file__)))
    else:
        print(f"File {filename} already exists in {directory}.")


@pytest.fixture
def envsetup():
    print("Setup")
    download_if_not_exists('gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git', 'SWENG/Test_files',
                           'PM.BTS-1.20250312.154500.ANY.xml', 'NpsVrfToken', 'glpat-4yNB_jaBXxz_BsyeAsgL')
    download_if_not_exists('gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git', 'SWENG/Test_files',
                           'PM.BTS-1.20250317.050000.ANY.xml', 'NpsVrfToken', 'glpat-4yNB_jaBXxz_BsyeAsgL')
    if os.path.exists("./result") is True:
        os.system("rm -rf ./result")
    yield
    print("Teardown...")
    if os.path.exists("PM.BTS-1.20250312.154500.ANY.xml") is True:
        os.remove("PM.BTS-1.20250312.154500.ANY.xml")
    if os.path.exists("PM.BTS-1.20250317.050000.ANY.xml") is True:
        os.remove("PM.BTS-1.20250317.050000.ANY.xml")


@pytest.fixture
def envsetup2():
    print("Setup2")
    if os.path.exists("./result") is True:
        os.system("rm -rf ./result")
    log_entry = None
    with open(CTR_FILE, "rb") as ctr_file:
        log_reader = PMCounterLogReader(file_obj_iterator=[ctr_file])
        try:
            log_entry = next(iter(log_reader))
        except StopIteration:
            print("No log entries found.")
    with open("./kpi_associations.json", "r") as json_file:
        kpi_associations = json.load(json_file)
    yield kpi_associations, log_entry


def test_create(envsetup):
    print("Testing...  Global create_pretty_kpi_file")
    assert not os.path.exists("./result")
    test_dict = pretty_kpi.create_pretty_kpi_file(CTR_FILE, "./result/", "KPI_Definitions_with_TOPKPI.csv")
    print(f"test_dict length = {len(test_dict)}")
    assert os.path.exists("./result")
    assert len(test_dict) == 2
    # Convert dictionary items to a list and print the second key-value pair
    second_key_value = list(test_dict.items())[1]
    assert list(test_dict.keys())[1] == 'NR_5032'
    xpaths_length = len(second_key_value[1]['xpaths'])
    missing_counters_length = len(second_key_value[1]['missing_counters'])
    print(f"xpaths length: {xpaths_length}")
    print(f"missing_counters length: {missing_counters_length}")
    assert xpaths_length == 12
    assert missing_counters_length == 0
    # print(f"second element of test_dict: {second_key_value}")


def test_full_formula_dict(envsetup2):
    print("Testing...  Global formula_list")
    kpi_associations, log_entry = envsetup2
    formulas = pretty_kpi.check_and_construct_full_formulas_dict(kpi_associations, log_entry)
    assert len(formulas) == 2
    f_1 = "(100*(M55112C00502-M55116C00009-M55116C00012+M55116C00033+M55112C01001+M55110C00020+M55110C00028-"
    f_2 = "M55112C00015+M55110C00019+M55110C00027)/(M55112C00007+M55112C00005-M55116C00009-M55116C00012+"
    f_3 = "M55110C00020+M55110C00028-M55112C00015+M55110C00019+M55110C00027))"
    expected_f = f"{f_1}{f_2}{f_3}"
    print(f"formulas container: {formulas['NR_5032']['formulas'][0]}")
    assert formulas["NR_5032"]["formulas"][0][0] == expected_f
    assert formulas["NR_5032"]["formulas"][0][2] == 9.844134536505333
