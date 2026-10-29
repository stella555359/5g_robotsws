
from robot.api import logger
from robot.libraries import BuiltIn

builtin = BuiltIn.BuiltIn()


def _pv(varname):
    vars = builtin.get_variables(no_decoration=True)
    return vars.get(varname, '')


def _spv(varname, value):
    if '$' not in varname and '@' not in varname and '&' not in varname:
        varname = '${%s}' % (varname)
    builtin.set_global_variable(varname, value)


def _getattr(obj, attr_list=[]):
    tmp_obj = obj
    for attr in attr_list:
        if tmp_obj:
            if ',' in attr:
                name, index = attr.split(',')
                if hasattr(tmp_obj, name) and getattr(tmp_obj, name):
                    tmp_obj = getattr(tmp_obj, name)[int(index)]
                else:
                    tmp_obj = None
            else:
                if hasattr(tmp_obj, attr):
                    tmp_obj = getattr(tmp_obj, attr)
                else:
                    tmp_obj = None
    return tmp_obj if tmp_obj else ''


def prepare_global_variables():
    tl = _pv('tl')
    _spv('appserver_addr', _getattr(tl, ['ues,0', 'ssh_connection_details', 'addr']))
    _spv('appserver_username', _getattr(tl, ['ues,0', 'ssh_connection_details', 'username']))
    _spv('appserver_password', _getattr(tl, ['ues,0', 'ssh_connection_details', 'password']))
    _spv('attenuation_port', _getattr(tl, ['attenuator', 'port']))
    _spv('ATTENUATOR_ADDR', _getattr(tl, ['attenuator', 'ip_addr']))
    _spv('ENB_IP', _getattr(tl, ['enbs,0', 'airscale', 'common_units,0', 'lmp_connection', 'addr']))
    _spv('pdu_gnb_addr', _getattr(tl, ['gnbs,0', 'dus,0', 'airscale', 'common_units,0', 'pdu_port', 'pdu', 'addr']))
    _spv('@{pdu_gnb_port}', _getattr(tl, ['gnbs,0', 'dus,0', 'airscale', 'common_units,0', 'pdu_port', 'port_no']))


def show_all_variables():
    for k, v in builtin.get_variables(no_decoration=False).items():
        logger.info('Robot variable [{}]  -- [{}]'.format(k, v))


prepare_global_variables()
