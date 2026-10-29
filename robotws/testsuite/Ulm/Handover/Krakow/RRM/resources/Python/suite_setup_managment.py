import os
import pprint
import re
import subprocess
import yaml
from robot.libraries.BuiltIn import BuiltIn
from py3_string import py3_string

AGENT_ENV_VARIABLES_PATH = os.path.sep.join([os.sep, 'home', 'ute', 'testline_init_results', 'logs',
                                             'env_variables.txt'])
CA_AGENT_ENV_VARIABLES_PATH = os.path.sep.join([os.sep, 'home', 'ute', 'testline_init_results', 'execution', 'logs',
                                                'env_variables.txt'])
AGENT_ENV_VARIABLE_PATHS = [
    AGENT_ENV_VARIABLES_PATH, CA_AGENT_ENV_VARIABLES_PATH]
AGENT_TOPOLOGY_VAR_NAME = 'CM_TOPOLOGY_NAME'
ENV_VAR_NAME = 'UTE_TESTLINE_TYPE'
LUA_MAPPING_VAR_NAME = '${TOPOLOGY_TO_LUA}'
RETURN_LUA_VAR_NAME = '${LUA}'
CA_AGENT_LOGS_PATH = os.path.abspath(os.path.sep.join(
    [os.sep, 'home', 'ute', 'testline_init_results', 'agent.log']))
CA_AGENT_TOPOLOGY_CONFIGS_DIR = os.path.abspath(os.path.sep.join(
    [os.sep, 'home', 'ute', 'testline_init_results', 'execution', 'configs', 'topology_configs', 'config.yaml']))


def get_lua_for_topology(tl_lua_mapping=None):
    if tl_lua_mapping is None:
        tl_lua_mapping = BuiltIn().get_variable_value(LUA_MAPPING_VAR_NAME)
    assert isinstance(tl_lua_mapping, dict), 'Mapping should be dict'
    topology = _get_topology()
    print('Determined topology as: {}'.format(topology))
    variant = _get_variant()
    assert topology in tl_lua_mapping or "{}:{}".format(topology, variant) in tl_lua_mapping, \
        'Topology: {} or Topo+variant: {}:{} not found in lua mapping:\n{}'\
        .format(topology, topology, variant, pprint.pformat(tl_lua_mapping))
    try:
        selected_lua = tl_lua_mapping["{}:{}".format(topology, variant)]
        print('Selected lua by topology + variant: {}:{}'.format(topology, variant))
    except KeyError:
        selected_lua = tl_lua_mapping["{}".format(topology)]
        print('Selected lua by topology only')
    print('Selected lua: {}'.format(selected_lua))
    BuiltIn().set_global_variable(RETURN_LUA_VAR_NAME, selected_lua)
    return selected_lua


def get_variant_from_multiple_ute_sources():
    return _get_variant()


def get_topology_label_from_multiple_ute_sources():
    return _get_topology()


def _get_variant():
    try:
        variant = get_testline_variant_by_common_agent_label()
        if str(variant).strip().lower() == 'none':
            variant = get_default_variant_from_agent_logs()
            if str(variant).strip().lower() != 'none':
                variant = "VARIANT_{}".format(variant)
                msg = 'Returning DEFAULT variant: {}'.format(variant)
                print(msg)
                return variant
        else:
            variant = 'VARIANT_{}'.format(variant)
            msg = 'Returning variant from agent log: {}'.format(variant)
            print(msg)
            return variant
    except Exception as e:
        msg = 'Could not get variant due to error: {}\n' \
              'Returning variant: None, if it happened on 5G Airphone testline,' \
              'it may cause problems with loading agent scfc files'.format(e)
        print(msg)
        return None


def get_testline_variant_by_common_agent_label():
    """
    execute command:


    :return:
    """
    result = None
    if os.path.exists(CA_AGENT_LOGS_PATH):
        cat_process = subprocess.Popen(
            ["cat", CA_AGENT_LOGS_PATH], stdout=subprocess.PIPE)
        grep_process = subprocess.Popen(
            ["grep", "VARIANT"], stdin=cat_process.stdout, stdout=subprocess.PIPE)
        sed_process = subprocess.Popen(["sed", r's/.*VARIANT\s*:\s*//g'],
                                       stdin=grep_process.stdout, stdout=subprocess.PIPE)
        # Allow ps_process to receive a SIGPIPE if grep_process exits.
        cat_process.stdout.close()
        # Allow ps_process to receive a SIGPIPE if grep_process exits.
        grep_process.stdout.close()
        output = sed_process.communicate()[0]
        output = output.strip()
        output = py3_string(output).strip()
        if re.search(r'^\S+$', output):
            result = output
    return result


def get_default_variant_from_agent_logs():
    result = None
    if os.path.exists(CA_AGENT_TOPOLOGY_CONFIGS_DIR):
        with open(CA_AGENT_TOPOLOGY_CONFIGS_DIR) as file:
            content = file.read()
        yaml_content = yaml.load(content, Loader=yaml.SafeLoader)
        print('Analyzing from file: {}'.format(CA_AGENT_TOPOLOGY_CONFIGS_DIR))
        for variant in yaml_content['variants']:
            print('Analyzing variant: {}'.format(variant['name']))
            default = variant['default']
            name = variant['name']
            if default is True:
                result = name
                break
    return result


def _get_topology():
    try:
        return _get_topology_from_cm_env_variable()
    except Exception as e:
        print('Could not find topology based on cm env variables (only SR execution) due to:\n{}'.format(e))
    try:
        return _get_topology_from_agent_variables()
    except Exception as e1:
        print('Could not find topology based on agent variables (only on reservation without agent rerun) '
              'due to: {}'.format(e1))
    try:
        return get_testline_type_by_agent_label()
    except Exception as e3:
        print('Could not find topology based on agent INFO log due to:\n{}'.format(e3))
    try:
        return _get_topology_from_env_variable()
    except Exception as e2:
        print('Could not find topology based on env variables due to:\n{}'.format(e2))
    raise Exception('FATAL: Could not determine topology by any means')


def _get_topology_from_env_variable():
    assert ENV_VAR_NAME in os.environ, 'Env: {} not defined'.format(
        ENV_VAR_NAME)
    assert os.environ[ENV_VAR_NAME], 'Env:{} is not filled'.format(
        os.environ[ENV_VAR_NAME])
    print('This variable can be outdated if the agent was rerun and variable not aligned')
    return os.environ[ENV_VAR_NAME]


def _get_topology_from_cm_env_variable():
    assert AGENT_TOPOLOGY_VAR_NAME in os.environ, 'Env: {} not defined'.format(
        AGENT_TOPOLOGY_VAR_NAME)
    assert os.environ[AGENT_TOPOLOGY_VAR_NAME], 'Env:{} is not filled'.format(
        os.environ[AGENT_TOPOLOGY_VAR_NAME])
    return os.environ[AGENT_TOPOLOGY_VAR_NAME]


def _get_topology_from_agent_variables():
    for path in AGENT_ENV_VARIABLE_PATHS:
        if not os.path.exists(path):
            print('Cannot find env_variables_from_agent path: {}'.format(path))
            continue
        with open(path) as file:
            cm_topology_from_file = re.findall(
                r'{}=(\S+)'.format(AGENT_TOPOLOGY_VAR_NAME), file.read())
            assert len(cm_topology_from_file) == 1, 'Could not find {} variable in file: {}' \
                .format(AGENT_TOPOLOGY_VAR_NAME, path)
            topology = cm_topology_from_file[0]
            # to do - save toplogy -> add to .bashrc
        return topology
    raise Exception(
        'Could not get topology from agent log (both agent-sim and ca)')


def get_testline_type_by_agent_label():
    info_log_paths = ["/home/ute/testline_init_results/logs/INFO_log.txt",
                      "/home/ute/testline_init_results/execution/logs/agent.log"]
    for info_log_path in info_log_paths:
        if not os.path.exists(info_log_path):
            continue
        cat_process = subprocess.Popen(["cat", info_log_path],
                                       stdout=subprocess.PIPE)
        grep_process = subprocess.Popen(
            ["grep", "LABEL"], stdin=cat_process.stdout, stdout=subprocess.PIPE)
        sed_process = subprocess.Popen(
            ["sed", r's/.*LABEL:\s*//g'], stdin=grep_process.stdout, stdout=subprocess.PIPE)
        # Allow ps_process to receive a SIGPIPE if grep_process exits.
        cat_process.stdout.close()
        # Allow ps_process to receive a SIGPIPE if grep_process exits.
        grep_process.stdout.close()
        output = sed_process.communicate()[0]
        output = output.strip()
        output = _py3_string(output)
        return output
    raise Exception(
        'Could not get tl type via LABEL param in agent.log/INFO_log.txt')


def split_run_keywords(*keywords):
    return BuiltIn()._split_run_keywords(list(keywords))


def run_keywords_with_args(keyword_with_args):
    return BuiltIn().run_keyword(keyword_with_args[0], *keyword_with_args[1])
