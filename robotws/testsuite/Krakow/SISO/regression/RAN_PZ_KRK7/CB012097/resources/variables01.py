tcs_fetch = '''echo '/ action create ConfigAccess /ca /module
/ca action fetch DECODED "tcs_parameters.bin" "/ram/tcs_parameters.json"' >/mnt/runtime/tcs_fetch.sh'''

tcs_store = '''echo '/ca action store PERMANENT DECODED "tcs_parameters.bin" "/ram/tcs_parameters.json"'\
> /mnt/runtime/tcs_store.sh\n'''

fans_fetch = '''echo '/ action create ConfigAccess /ca /module
/ca action fetch DECODED "tcs_fans.bin" "/ram/fans.json"' > /mnt/runtime/fans_fetch.sh'''

fans_store = ('''echo '/ca action store PERMANENT DECODED "tcs_fans.bin" "/ram/fans.json"' '''
              + '''> /mnt/runtime/fans_store.sh\n''')

fans_fetch_legacy = '''echo '/ action create ConfigAccess /ca /module
/ca action fetch DECODED "fans.bin" "/ram/fans.json"' > /mnt/runtime/fans_fetch.sh'''

fans_store_legacy = ('''echo '/ca action store PERMANENT DECODED "fans.bin" "/ram/fans.json"' '''
                     + '''> /mnt/runtime/fans_store.sh\n''')

frmon_prepare = '''/ action create FanDevice /CI/fan /fan/1
/CI/fan set control_state TESTABILITY_SW
/ action create ThermometerDevice /CI/ThermoModule /rf/tx1'''
frmon_fan_set_setpoint = '/CI/fan action set_setpoint {}'
frmon_thermo_override = '/CI/ThermoModule action override {}'

tcs_prepare_1933_AHEGA = {'Nrpm_fail': 1, 'Tblock': 60, 'deltaTmulti': 120, 'deltaTctl': 120}
tcs_clear_AHEGA = {'Nrpm_fail': 30, 'Tblock': 105, 'deltaTmulti': 50, 'deltaTctl': 5}
tcs_prepare_1933_AHFIG = {'Nrpm_fail': 1, 'Tblock': 80, 'deltaTmulti': 120, 'deltaTctl': 120}
tcs_prepare_1934_AHFIG = {'Nrpm_fail': 1}
tcs_clear_AHFIG = {'Nrpm_fail': 30, 'Tblock': 55, 'deltaTmulti': 50, 'deltaTctl': 20}

conn_level_map_a = {'smod': {'enter_cmd': None, 'prompt': 'root@fct-4a:~ >', 'hostname': 'fct-4a'},
                    'lxc':  {'enter_cmd': 'lxc-attach --name {}',
                             'prompt': 'root@FHNET80:~ >', 'hostname': 'FHNET80'},
                    'AHFIG':  {'enter_cmd': 'ssh -o StrictHostKeyChecking=no root@{}', 'password': '',
                               'prompt': 'root@nahka-Node0:~# ', 'hostname': 'nahka'},
                    }

conn_level_map_b = {'smod': {'enter_cmd': None, 'prompt': 'root@fct-4a:~ >', 'hostname': 'fct-4a'},
                    'lxc':  {'enter_cmd': 'lxc-attach --name {}',
                             'prompt': 'root@FHNET80:~ >', 'hostname': 'FHNET80'},
                    'AHEGA':  {'enter_cmd': 'ssh -o StrictHostKeyChecking=no root@{}', 'password': '',
                               'prompt': 'root@nahka-Node0:~# ', 'hostname': 'nahka'},
                    }
