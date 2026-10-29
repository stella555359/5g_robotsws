import tarfile
import os
from robot.api import ExecutionResult, ResultVisitor
import json
import yaml
import sys
import robot
try:
    from pathlib import Path
except ImportError:
    os.system('pip install pathlib')
    from pathlib import Path

GET_PATH = Path(__file__).resolve()

json_input_info = {}


# The files will be collected from the directory and stores in filepath.
def get_files_present_in_folder(directory):
    file_paths = []
    for root, directories, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            file_paths.append(filepath)
    return file_paths


# The files will be tarred and gunzipped.
def main(password, user, server, suite, run_type, ap_load_id, gnb_load_id, build_number, workspace, yaml_file,
         multiphase_buildid, topology, regression_type):
    Path = workspace + "/robot_log_collector/"
    json_file_generator(workspace, suite, Path, run_type, topology, yaml_file, regression_type)
    mkdir_cmd = 'mkdir -p suites/output_xml'
    cp_cmd = 'cp ' + suite + '.json suites/output_xml/' + suite + '_output.json'
    os.system(mkdir_cmd)
    os.system(cp_cmd)
    return


def get_stats_related_object_for_robot_executor(xml_path):
    testcase = ExecutionResult(xml_path)
    test_obj = TestMetrics()
    return testcase, test_obj


def json_file_generator(workspace, suite, Path, run_type, topology, yaml_file, regression_type):
    print("input_yaml", yaml_file)
    if yaml_file == 'default':
        YML_DATA_FILE = os.path.join(sys.path[0], 'Runner', 'P1_Func_suites.yaml')
    elif yaml_file == 'regression':
        local_yaml_file = os.environ.get("local_yaml_file", "false")
        if local_yaml_file == "true":
            job_workspace = os.environ.get("WORKSPACE", "")
            YML_DATA_FILE = os.path.join(job_workspace, 'regression_suites.yaml')
        else:
            YML_DATA_FILE = os.path.join(str(GET_PATH.parents[1]), 'Runner', 'P1_Regression_suites.yaml')
    else:
        YML_DATA_FILE = yaml_file
    print('yaml_file', YML_DATA_FILE)
    stream = open(YML_DATA_FILE, 'r')
    feature_data = yaml.load(stream, Loader=yaml.FullLoader)
    test_info = {}
    output_xml_path = os.path.join(workspace, 'output.xml')
    run_details_path = os.path.join(workspace, 'run.properties')
    json_file_name = "{}.json".format(suite)
    testcase, test_obj = get_stats_related_object_for_robot_executor(output_xml_path)
    testcase.visit(test_obj)
    test_info['Testcases'] = test_obj.test_info
    stats = testcase.statistics
    all_testcases_result = {}
    run_info = get_testline_used_info(run_details_path)
    for key, value in test_info['Testcases'].items():
        testcase_results = {}
        suite_statistics = {}
        gnb_load_details = {}
        testcase_results['Testline_Used'] = run_info['NODE_NAME_FS_TDD_NSA']
        testcase_results['Testline_URL'] = run_info['NODE_URL_FS_TDD_NSA']
        testcase_results['Run_Type'] = run_info['RUN_TYPE']
        if topology == '':
            testcase_results['Topology'] = feature_data[run_type][regression_type][suite]['Topology']
        else:
            testcase_results['Topology'] = topology
        gnb_load_details[testcase_results['Topology']] = run_info['GNB_LOAD_ID']
        print(f"Robot Version : {robot.__version__}")
        if run_info['AGENT_SIM_EXIT_CODE'] == '0':
            suite_statistics['Agent_sim_installation'] = 'PASS'
            if int(robot.__version__.split('.')[0]) > 3:
                suite_statistics['Total_Pass'] = stats.total.passed
                suite_statistics['Total_Fail'] = stats.total.failed
            else:
                suite_statistics['Total_Pass'] = stats.total.all.passed
                suite_statistics['Total_Fail'] = stats.total.all.failed
            testcase_results['Test_result'] = value
        elif run_info['AGENT_SIM_EXIT_CODE'] == '255':
            suite_statistics['Agent_sim_installation'] = 'SKIPPED'
            if int(robot.__version__.split('.')[0]) > 3:
                suite_statistics['Total_Pass'] = stats.total.passed
                suite_statistics['Total_Fail'] = stats.total.failed
            else:
                suite_statistics['Total_Pass'] = stats.total.all.passed
                suite_statistics['Total_Fail'] = stats.total.all.failed
            testcase_results['Test_result'] = value
        else:
            suite_statistics['Agent_sim_installation'] = 'FAIL'
            if int(robot.__version__.split('.')[0]) > 3:
                suite_statistics['Total_Fail'] = stats.total.total
            else:
                suite_statistics['Total_Fail'] = stats.total.all.total
            suite_statistics['Total_Pass'] = 0
            testcase_results['Test_result'] = 'INSTALL FAILED'
            delete_dry_run_dir = 'rm -rf {}/{}'.format(Path, suite)
            os.system(delete_dry_run_dir)
        all_testcases_result[key] = testcase_results
        suite_statistics['Total_Cases'] = int(suite_statistics['Total_Pass']) + int(suite_statistics['Total_Fail'])
        json_input_info[suite] = {'Suite_Statistics': suite_statistics, 'GNB_Build': gnb_load_details,
                                  'Testcase_Results': all_testcases_result}
    with open(json_file_name, 'w') as outfile:
        json.dump(json_input_info, outfile, indent=6)
    return run_info


def get_testline_used_info(path):
    run_info = {}
    with open(path, 'r') as fh:
        for line in fh.readlines():
            if line[0] != '#':
                if line.find('=') != -1:
                    data = line.split('=')
                    run_info[data[0]] = data[1].strip('\n')
    return run_info


# The arguments will be parsed from jentkins
def get_args():
    import argparse
    parser = argparse.ArgumentParser(description='Script to Collect Logs')
    parser.add_argument('--password', required=True, help='Password for server.')
    parser.add_argument('--user', required=True, help='username for server.')
    parser.add_argument('--server', required=True, help='Server ip.')
    parser.add_argument('--suite', required=True, help='Suite name.')
    parser.add_argument('--run_type', required=True, help='runtype.')
    parser.add_argument('--ap_load', required=True, help='ap load id.')
    parser.add_argument('--gnb_load', required=True, help='gnb load id.')
    parser.add_argument('--build_number', required=True, help='build number of jenkins job.')
    parser.add_argument('--workspace', required=True, help='workspace directory path')
    parser.add_argument('--yaml_file', required=False, default='default', help='yaml file to be used')
    parser.add_argument('--multiphase_buildid', required=False, default='',
                        help='Multiphase build number of jenkins job.')
    parser.add_argument('--topology', required=False, default='', help='Topology to be used')
    parser.add_argument('--regression_type', required=False, default='P1_Feature', help='Regression Type to be used')
    args = parser.parse_args()
    return args


class TestMetrics(ResultVisitor):
    def __init__(self):
        self.test_info = {}

    def visit_test(self, test):
        self.test_info[test.name] = test.status


if __name__ == "__main__":
    args = get_args()
    main(args.password, args.user, args.server, args.suite, args.run_type, args.ap_load, args.gnb_load,
         args.build_number, args.workspace, args.yaml_file, args.multiphase_buildid, args.topology,
         args.regression_type)
