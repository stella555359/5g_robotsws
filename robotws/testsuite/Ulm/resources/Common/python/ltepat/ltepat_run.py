"""This Module is used to run LTEPAT and create configuration files for LTEPAT.
"""
import argparse
import subprocess
from time import perf_counter
import logging
import json
import pathlib
import xmltodict


LTE_PAT_PATH = '/home/ute/ltepat/PMKPITool/LTEPAT_PMKPITool.exe'
DEFAULT_LTE_PAT_CONFIGURATION_FILE = '/home/ute/ltepat/PMKPITool/pmTemplate_sample.xml'


def run_ltepat(configuration_file_path: str, ltepat_output_path: str) -> str:
    """Run ltepat to calculate KPIs. Make sure that 'create_configuration_file' is run before this function.
       Use the returned configuration file path as the first argument.

    Args:
        configuration_file_path (str): path to ltepat configuration file
        ltepat_output_path (str): path to folder where the ltepat output should be saved.

    Returns:
        str : Elapsed time for the calculation of KPI. Mainly useful for python use.
    """
    start_time = perf_counter()
    current_path = str(pathlib.Path('.').absolute()) + '/'
    repository_root = current_path[:current_path.find('testsuite')]
    with open(ltepat_output_path, 'w', encoding='utf-8') as ltepat_output:
        kpi_calculation_process = subprocess.Popen(
            args=['mono', LTE_PAT_PATH, configuration_file_path],
            cwd=repository_root,
            stdout=ltepat_output)
    logging.info('Running PMKPITool with configuration file: %s', configuration_file_path)
    kpi_calculation_process.wait()
    str_elapsed_time = f'{perf_counter() - start_time:.2f}'
    logging.info('PMKPITool execution finished in %s seconds', str_elapsed_time)
    return str_elapsed_time


def create_configuration_file(pm_files: list[str],
                              conversion_options=None,
                              runtime_options=None,
                              suite_log_dir='/home/ute/ltepat/PMKPITool') -> str:
    """Create a configuration file for LTEPAT. This file will be used by 'run_ltepat'.

    Args:
        pm_files (list[str]): a list of the pm-counter files or a folder containing them.
        conversion_options (dict, optional): Defines what conversions to do.
        runtime_options (dict, optional): Defines what runtime options to use. Used to set the path of the PMKPI and
                                          PMPeg file. Defaults to None (sets default). Defaults to None(sets default).
        suite_log_dir (str, optional): preferably path to the Testsuite log directory. This is where the modified
                                       ltepat configuration file will be saved - can be useful for troubleshooting.
                                       Defaults to '/home/ute/ltepat/PMKPITool'.

    Returns:
        str: the full path to the created configuration file.
    """
    if not conversion_options:
        conversion_options = {}
    if not runtime_options:
        runtime_options = {}
    with open(DEFAULT_LTE_PAT_CONFIGURATION_FILE, 'r', encoding='utf-8') as f:
        xml_dict = xmltodict.parse(xml_input=f.read())
    xml_dict = _add_pm_files(pm_files=pm_files, xml_dict=xml_dict)
    xml_dict = _modify_pm_options(options=conversion_options, xml_dict=xml_dict)
    xml_dict = _modify_runtime_options(options=runtime_options, xml_dict=xml_dict)

    with open(suite_log_dir + '/xml_converted.json', 'w', encoding='utf-8') as f:
        json.dump(xml_dict, f, indent=4)

    configuration_path = suite_log_dir + '/ltepat_config.xml'
    xmltodict.unparse(input_dict=xml_dict,
                      output=open(file=configuration_path, mode='w', encoding='utf-8'),
                      short_empty_elements=True, pretty=True)
    return configuration_path


def _add_pm_files(pm_files: list, xml_dict: dict):
    xml_dict['default']['PM']['files'] = ',\n'.join(pm_files)
    return xml_dict


def _modify_pm_options(options: dict, xml_dict: dict):
    xml_dict['default']['PM'].update(_get_default_pm_options())
    xml_dict['default']['PM'].update(options)
    return xml_dict


def _modify_runtime_options(options: dict, xml_dict: dict):
    xml_dict['default']['runtime'].update(_get_default_runtime_options())
    xml_dict['default']['runtime'].update(options)
    return xml_dict


def _get_default_pm_options():
    return {
        "@excel": "True",
        "@kpiAll": "True",
        "@sysKpi": "True",
        "@enbKpis": "True",
        "@sysCharts": "False",
        "@cellCharts": "False",
        "@mixedCharts": "False",
        "@gmt": "",
        "@timeZoneOffset": "0",
        "@csvOnly": "False",
        "@useLocalTime": "False",
        "@ignoreRaw": "True",
        "@noZeros": "False",
        "@RnD": "True",
        "@mutliplier": "False",
        "@Interval": "5",
        "@digits": "2",
        "@UseInputDir": "False",
        "@tag": ""}


def _get_default_runtime_options():
    return {"@PmReleaseFile": "/home/ute/ltepat/PMKPITool/rel/PMPegs_SBTS25R3_5G.xml",
            "@PmKPIFile": "/home/ute/ltepat/PMKPITool/rel/PMKPI_SBTS25R3_5G.xml",
            "@flexi": "True",
            "@N5G": "True"}


def _main(test_files=None, output_directory="/home/ute/Downloads/"):
    if test_files is None:
        test_files = []
    conversion = {
        '@kpiAll': 'False',
        '@sysKpi': 'True',
        '@enbKpis': 'True',
        "@sysCharts": "False",
        "@cellCharts": "False",
        '@RnD': 'True',
        '@UseInputDir': 'True',
        '@csvOnly': 'False',
        '@excel': 'True',
        "@noZeros": "True"
    }
    runtime = {
        '@PmReleaseFile': '/home/ute/ltepat/PMKPITool/rel/Flexi/PM/PMPegs_SBTS25R3_5G.xml',
        '@PmKPIFile': 'testsuite/Ulm/ET/CB013392/CB013392-E/configurations/PMKPI_SBTS25R2_5G_withTMO.xml',
        '@OutputDirectory': str(output_directory),
    }

    config_file_path = create_configuration_file(pm_files=test_files, conversion_options=conversion,
                                                 runtime_options=runtime)
    elapsed_time: str = run_ltepat(config_file_path, 'ltepat_output.txt')
    print(elapsed_time)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='ltepat_run.py')
    parser.add_argument('test_files')
    parser.add_argument('--output_directory', default="./")
    parser.add_argument('--log_level', default="INFO")
    args = parser.parse_args()
    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=getattr(logging, args.log_level)
    )
    _main(test_files=args.test_files.split(','),
          output_directory=args.output_directory)
