# -*- coding: utf-8 -*-


import yaml
import os


def file_modify(version="10.1100.501", *args, **kwargs):
    """This keyword is used to modify vcu deploy file.

    *AUTHOR* shouxiang.jiao@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | version | Yes |  the vCU version which needs deployment |
    | kwargs | No | the parameter which wants to changing  |

    *RETURN VALUE*
    flavor_name,parameter_dict['vnf_name']

    Example
        | file_modify |  10.1100.501  |
    """
    flavor_file = '5gbts_flavor.env'
    heat_file = '5gbts_heat.env'
    os.chdir('/home/ute/5G')

    # modify flavor_name && save file
    flavor_file = open('5gbts_flavor.env', 'r')
    flavor_dict = yaml.load(flavor_file)
    flavor_name = 'flavor-' + str(version).split('.')[-1]
    flavor_dict['parameters']['vnf_prefix'] = flavor_name
    flavor_file.close()
    flavor = open('5gbts_flavor.env', 'w')
    flavor.write(yaml.dump(flavor_dict))
    heatfile = open(heat_file, 'r')
    configdict = yaml.load(heatfile)
    heatfile.close()
    parameter = configdict['parameters']
    # modify heat_env file
    parameter_dict = {'image': 'AirFrameVirtualized-' + str(version),
                      'uvm_image': 'AirFrameVirtualized-' + str(version),
                      'vnf_name': 'gnb-5222',
                      'flavors': {'db': flavor_name + '_db',
                                  'uvm': flavor_name + '_uvm',
                                  'oam': flavor_name + '_oam',
                                  'cpcl': flavor_name + '_cpcl',
                                  'cpif': flavor_name + '_cpif',
                                  'cpnrt': flavor_name + '_cpnrt',
                                  'cpnb': flavor_name + '_cpnb',
                                  'cpue': flavor_name + '_cpue',
                                  'upue': flavor_name + '_upue'},
                      'external_networks': {'oam': {'uuid': 'ff0c4c98-31ae-4d78-9cb8-8ff9988b066c',
                                                    'fixed_ips': [{'ip_address': '10.110.99.32'}]
                                                    },
                                            'f1c': {'uuid': '9a4cc00b-7058-45e7-a5fb-45ce762727cb',
                                                    'fixed_ips': [{'ip_address': '10.110.100.32'}],
                                                    'fixed_v6_ips': []},
                                            'x2c': {'uuid': 'cbe33a79-41f9-47f3-b4f5-b6605754fd7b',
                                                    'fixed_ips': [{'ip_address': '10.110.101.32'}],
                                                    'fixed_v6_ips': []},
                                            'f1u': {'uuid': '9a4cc00b-7058-45e7-a5fb-45ce762727cb',
                                                    'fixed_ips': [],
                                                    'fixed_v6_ips': []},
                                            'x2u': {'uuid': '77a5c684-ca2d-4a6f-88e2-2b3a41e0a028',
                                                    'fixed_ips': [],
                                                    'fixed_v6_ips': []},
                                            's1u': {'uuid': 'ccc5cffe-a5f0-4236-8fca-76726e6c7386',
                                                    'fixed_ips': [],
                                                    'fixed_v6_ips': []},
                                            'tracing': {'uuid': 'e95b27bd-dd61-4c4f-8675-0076f300a532'}},
                      'internal_provider_networks': 'provider0',
                      'internal_e1_provider_networks': 'provider0'}
    for key, value in kwargs.items():
        if key in parameter_dict:
            parameter_dict[key] = str(value)
        elif key in parameter:
            if isinstance(value, int):
                parameter_dict[key] = int(value)
            else:
                parameter_dict[key] = str(value)

    for key, value in parameter_dict.items():
        parameter[key] = value
    file = open('5gbts_heat.env', 'w')
    file.write(yaml.dump(configdict))
    return flavor_name, parameter_dict['vnf_name']


if __name__ == "__main__":
    file_modify()
