# -*- coding: utf-8 -*-

from cloud5g.commissioning import Context as CommissioningContext
import sys
import os
import importlib
import yaml
import os


def modify_scf(commission_dir, testline_config_dir, scf_path):
    """This keyword is used to modify scf file.

    *AUTHOR* xue.xian@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | commission_dir | Yes |  path of directory under which __init__.py is used to modify scf |
    | testline_config_dir | Yes |  path of test line configuration directory |
    | scf_path | Yes |  path of scf file which will be modified, no new file created |

    *RETURN VALUE*
    None

    Example
        | modify scf |  robotws5g/commissionings/AIC/CLOUD_5G_AIC/VCU  |
          testline_configuration_5G/Hangzhou/7_5_UTE5GAIC001T037 | SCF_CU.xml |
    """
    testline_name = testline_config_dir.strip("/").split("/")[-1]
    sys.path.append(os.path.dirname(testline_config_dir.strip("/")))
    testline_module = importlib.import_module(testline_name)
    sys.path.append(os.path.dirname(commission_dir.strip("/")))
    module_name = commission_dir.strip("/").split("/")[-1]
    commisssion_module = importlib.import_module(module_name)
    site_configuration_path = os.path.join(testline_config_dir, "site_configuration.yaml")
    context = CommissioningContext(tl_config=testline_module.tl,
                                   tl_name=testline_name,
                                   is_coam=False,
                                   commissionings_module=commisssion_module,
                                   number_of_cells=None,
                                   builds=dict(active='', passive=''),
                                   mrbts=testline_module.tl.gnbs[0].instance_id,
                                   nrbts=testline_module.tl.gnbs[0].global_bts_id)
    if os.path.exists(site_configuration_path):
        with open(site_configuration_path, "r") as f:
            context.site_config = yaml.load(f.read(), Loader=yaml.FullLoader)
    else:
        context.site_config = {}
    commission_object = commisssion_module.CustomCommissioning(scf_path)
    with commission_object as co:
        co.modify_scf(context)
