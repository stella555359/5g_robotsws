
import argparse
import hashlib
import re
import traceback
import pathlib

from testsuite.Ulm.ET.Performance_Test.resources.python import perf_keywords

script_directory = pathlib.Path(__file__).parent.resolve()


def get_scf_sha256sum(file, hash_len=10):
    """To easily check if scf are the same"""
    try:
        with open(file, 'r', encoding='utf-8') as scf:
            scf_tamed = scf.read()
        for regex in [
            r'version="[a-zA-Z0-9_]*"',
            r'<p name="btsName">[a-zA-Z0-9_ ]*</p>',
            r'id="[a-zA-Z0-9_]*"',
            r'dateTime="[\.a-zA-Z0-9_:-]*"',
            r'<p name="vlanId">[0-9]+</p>',
            r'<\?xml .*\?>',
            r'MRBTS-[0-9]+',  # due to marvin, MRBTS is now unique per testline
        ]:
            scf_tamed = re.sub(regex, "", scf_tamed)
        with open(f"{file}.tamed", 'w', encoding='utf-8') as scf:
            scf.write(scf_tamed)
        return hashlib.shake_256(scf_tamed.encode()).hexdigest(int(hash_len))
    except Exception as e:
        print(f"    get_scf_sha256sum e={e}\n{traceback.format_exc()}")
        return "null"


def get_vendor_sha256sum(file, hash_len=10):
    """To easily check if scf are the same"""
    if file is None:
        return "null"
    try:
        with open(file, 'r', encoding='utf-8') as scf:
            vendor_tamed = scf.read()
        for regex in [
            r'action=".*"',
            r'dateTime=".*"',
            r'version=".*"',
        ]:
            vendor_tamed = re.sub(regex, "", vendor_tamed)
        with open(f"{file}.tamed", 'w', encoding='utf-8') as scf:
            scf.write(vendor_tamed)
        return hashlib.shake_256(vendor_tamed.encode()).hexdigest(int(hash_len))
    except Exception as e:
        print(f"    get_vendor_sha256sum e={e}\n{traceback.format_exc()}")
        return "null"


def get_rf_dictionary_sha256sum(rf_dict, hash_len=10):
    """To easily check if rf dict are same"""
    tamed = rf_dict.copy()
    try:
        for key in [
            'P_TURANDOT_DIR', 'P_TURANDOT_LINK', 'P_TESTLINE_NAME', 'P_JOB_DESCRIPTION',
            'BUILD_ID', 'JOB_URL', 'JOB_NAME',
            'hash',
            'previous_tc_testname_for_db',
            'pass_regexp', 'fail_regexp', 'cell_and_ue_mapping'
        ]:
            tamed.pop(key, None)
        tamed = perf_keywords.convert_rf_dict_to_json(tamed, indent=0)
        return (hashlib.shake_256(tamed.encode()).hexdigest(int(hash_len)), tamed)
    except Exception as e:
        print(f"    get_swconfig_sha256sum e={e}\n{traceback.format_exc()}")
        return ("null", "null")


def get_swconfig_sha256sum(swconfig_content, len=10):
    """To easily check if swconfigs are the same"""
    tamed = swconfig_content
    try:
        for regex in [
            r'#.*',
            r' +',
        ]:
            tamed = re.sub(regex, " ", tamed)
        tamed = re.sub(r'\n\s*\n', '\n', tamed, re.MULTILINE)
        return hashlib.shake_256(tamed.encode()).hexdigest(int(len))
    except Exception as e:
        print(f"    get_swconfig_sha256sum e={e}\n{traceback.format_exc()}")
        return "null"


def get_iphy_sha256sum(iphy_content, hash_len=10):
    """To easily check if swconfigs are the same"""
    tamed = iphy_content
    try:
        for regex in [
            r'<?xml version=.* encoding=.*?>',
            r'<IPHY-Config xmlns:xsi=.* xsi:noNamespaceSchemaLocation=.*>',
            r'<bldVersion>.*</bldVersion>',
            r'<productCode>.*</productCode>',
            r'<buildversion>.*</buildversion>',
            # r'<resourceBuildKey>.*</resourceBuildKey>',
            r'<serialno>.*</serialno>',
            r'<name>.*</name>',
            r'<version>.*</version>',
            r'<usageStatus>.*</usageStatus>',
            r'<!--.*-->',
        ]:
            tamed = re.sub(regex, " ", tamed)
        tamed = re.sub(r'\n\s*\n', '\n', tamed, re.MULTILINE)
        return hashlib.shake_256(tamed.encode()).hexdigest(int(hash_len))
    except Exception as e:
        print(f"    get_iphy_sha256sum e={e}\n{traceback.format_exc()}")
        return "null"


def get_sha256sum_from_str(arg, len=10):
    try:
        return hashlib.shake_256(arg.encode()).hexdigest(int(len))
    except Exception as e:
        print(f"    get_sha256sum_from_str e={e}\n{traceback.format_exc()}")
        return "null"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='hasher.py')
    parser.add_argument('filename')
    parser.add_argument('--len', default=10)
    args = parser.parse_args()

    hash_scf = get_scf_sha256sum(args.filename, hash_len=args.len)
    print(f"SCF Hash: {hash_scf}")
