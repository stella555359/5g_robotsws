import os
import time

from robot.libraries.BuiltIn import BuiltIn


def setup_vcu_emss(alias='cu1', wait_connected=False):
    """
    Currently can be use only with run emssim command interface
    """
    os.system('rm -rf /var/log/emssim/*vcu*')
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    ta_emss_inst.setup_emss(user='vcu1',
                            bts_ip='192.168.100.129',
                            oam_ip='192.168.100.1/24',
                            alias=alias,
                            wait_connected=wait_connected)
    ta_emss_inst.run_emssim_command('env', alias=alias)
    ta_emss_inst.run_emssim_command('ne3s_activate', alias=alias)
    time.sleep(15)
    ta_emss_inst.run_emssim_command('env', alias=alias)

    return alias


def vcu_configure(*yaml_paths, **kwargs):
    alias = kwargs.get('alias', 'cu1')
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    yaml_abs_paths = []
    for yaml_path in yaml_paths:
        if not isinstance(yaml_path, list):
            yaml_path = [yaml_path]
        for path in yaml_path:
            yaml_abs_path = os.path.abspath(path)
            assert os.path.exists(yaml_abs_path), 'Path: {} does not exist'.format(yaml_abs_path)
            yaml_abs_paths.append(yaml_abs_path)
    for yaml_abs_path in yaml_abs_paths:
        ta_emss_inst.run_emssim_command('configure {}'.format(yaml_abs_path), alias=alias)


def vcu_emss_teardown(alias='cu1'):
    out_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}', os.getcwd())
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    ta_emss_inst.teardown_emss(alias=alias)
    os.system('cp /var/log/emssim/emssim.vcu* {}/emss/emssim_vcu.log'.format(out_dir))


def setup_vdu_emss(alias='du1', wait_connected=False):
    os.system('rm -rf /var/log/emssim/*vdu*')
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    ta_emss_inst.setup_emss(user='vdu1',
                            bts_ip='192.168.255.129',
                            oam_ip='192.168.255.1/24',
                            alias=alias, wait_connected=wait_connected)
    ta_emss_inst.run_emssim_command('env', alias=alias)
    ta_emss_inst.run_emssim_command('ne3s_activate', alias=alias)
    time.sleep(15)
    ta_emss_inst.run_emssim_command('env', alias=alias)
    return alias


def vdu_configure(*yaml_paths, **kwargs):
    alias = kwargs.get('alias', 'du1')
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    yaml_abs_paths = []
    for yaml_path in yaml_paths:
        if not isinstance(yaml_path, list):
            yaml_path = [yaml_path]
        for path in yaml_path:
            yaml_abs_path = os.path.abspath(path)
            assert os.path.exists(yaml_abs_path), 'Path: {} does not exist'.format(yaml_abs_path)
            yaml_abs_paths.append(yaml_abs_path)
    for yaml_abs_path in yaml_abs_paths:
        ta_emss_inst.run_emssim_command('configure {}'.format(yaml_abs_path), alias=alias)


def vdu_emss_teardown(alias='du1'):
    out_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}', os.getcwd())
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    ta_emss_inst.teardown_emss(alias=alias)
    os.system('cp /var/log/emssim/emssim.vdu* {}/emss/emssim_vdu.log'.format(out_dir))
