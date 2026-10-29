FHGW = {
    'ip': '192.168.0.131',
    'username': 'root',
    'password': 'root',
    'alias': 'ssh_fhgw'
}
AP = {
    'hostname': '192.168.200.1',
    'username': 'toor4nsn',
    'password': 'oZPS0POrRieRtu',
    'alias': 'ssh_ap'
}
WTS = {
    'host': {
        'hostname': '127.0.0.1',
        'username': 'ute',
        'alias': 'ssh_wts'
    },
    'edaemon': {
        'edaemon_ssh_alias': 'ssh_wts',
        'directory_path': '/opt/iphy/latest',
        'port': 22222,
        'sudo_password': None
    },
    'egate': {
        'egate_ssh_alias': 'ssh_wts',
        'directory_path': '/opt/iphy/latest',
        'port': 20000,
        'sudo_password': None,
        'nostats': False
    }
}
CHECK_AP_LO_BOARDS = "export PYTHONPATH=/opt/hwmt/python;" \
                       "python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x5011 -p 15004"
POD_READINESS = r"""'{.status.conditions[?(@.type=="Ready")]}'"""
POD_LIST_READINESS = r"""'{range .items[*]}{.metadata.name}{","}""" \
                     r"""{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'"""
PATTERN_SWVERSION = r"""'(?<=resourceSWVersion=")RF\.SRM.+(?=")'"""
PATTERN_SWFILENAME = r"""'(?<=swFileKeyName=")LTX_RRU_TYPE_[\w-]+\.tar(?=")'"""

PATTERN_ESCAPE_DOUBLE_BACKSLASH = r"""'$s/\([^ ]*\)$/"\1"/'"""
