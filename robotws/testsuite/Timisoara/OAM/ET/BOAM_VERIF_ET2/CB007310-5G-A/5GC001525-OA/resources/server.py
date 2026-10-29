import os

from subprocess import CalledProcessError, check_call

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

config = {
    'udp_file': '/var/log/btslog-udp.json',
    'udp_port': '514',
}
config_template = """# included to default /etc/rsyslog.conf
module(load="imudp")
template(name="json" type="string" string="%jsonmesg%\\n")
ruleset(name="remote-udp"){{
    action(type="omfile" file="{udp_file}" template="json")
}}
input(type="imudp" port="{udp_port}" ruleset="remote-udp")
"""
output_dir = BuiltIn().get_variables(no_decoration=True).get('OUTPUT DIR')


def configure_rsyslog_service():
    check_call(['systemctl', '--no-pager', 'status', 'rsyslog.service'])
    if os.path.isfile(config['udp_file']):
        logger.info('{} already exist. Removing..'.format(config['udp_file']))
        check_call(['sudo', 'rm', config['udp_file']])

    config_file = os.path.join(output_dir, 'rsyslog.conf')
    with open(config_file, 'w') as f:
        f.write(config_template.format(**config))
    logger.info('Loading config from {}'.format(config_file), also_console=True)
    check_call(['sudo', 'cp', config_file, '/etc/rsyslog.d/btslog.conf'])
    check_call(['sudo', 'systemctl', 'restart', 'rsyslog.service'])
    check_call(['systemctl', '--no-pager', 'status', 'rsyslog.service'])

    # assess values by: &{rsyslog_config}[key_string_without_quotes]
    BuiltIn().set_suite_variable('${rsyslog_config}', config)


def rollback_rsyslog_configuration():
    logger.info('Removing file: /etc/rsyslog.d/btslog.conf', also_console=True)
    check_call(['sudo', 'rm', '/etc/rsyslog.d/btslog.conf'])
    logger.info('Restarting rsyslog daemon')
    check_call(['sudo', 'systemctl', 'restart', 'rsyslog.service'])
    check_call(['systemctl', '--no-pager', 'status', 'rsyslog.service'])
