APHA_swconfig = '''
#Fan fid 1932
0x00120010 = 0
0x00120011 = 0
0x00120012 = 0
0x00120013 = 0

#Fan fid 1933
0x00120020 = 0
0x00120021 = 0
0x00120022 = 0
0x00120023 = 0
'''
APHG_swconfig = '''
#Fan fid 1932
0x00120010 = 0
0x00120011 = 0
0x00120012 = 0
0x00120013 = 0

#Fan fid 1934
0x0B = 0
'''

tcs_fetch = '''echo '/ action create ConfigAccess /cofi /module
/cofi action fetch DECODED "tcs.bin" "/run/tcs.json"' > ./tcs_fetch.sh'''

tcs_store = '''echo '/cofi action store PERMANENT DECODED "tcs.bin" "/run/tcs.json"' > ./tcs_store.sh\n'''

conn_level_map = {'smod': {'enter_cmd': None, 'prompt': 'root@asc-0a:~ >', 'hostname': 'asc-0a'},
                  'lxc':  {'enter_cmd': 'lxc-attach --name {}',
                           'prompt': 'root@FHNET00:~ >', 'hostname': 'FHNET00'},
                  'APHA':  {'enter_cmd': 'ssh toor4nsn@{}', 'password': 'oZPS0POrRieRtu',
                            'prompt': 'toor4nsn@fzhub10:~# ', 'hostname': 'fzhub10'},
                  'APHG':  {'enter_cmd': 'ssh toor4nsn@{}', 'password': 'oZPS0POrRieRtu',
                            'prompt': 'toor4nsn@fzhub20:~# ', 'hostname': 'fzhub20'},
                  }
