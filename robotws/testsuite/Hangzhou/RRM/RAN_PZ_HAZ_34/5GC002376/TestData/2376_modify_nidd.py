"""
...    author: Liu Zheng
...    contact: zheng.4.liu@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_1_SG
...    feature : 5GC002376
"""
from robot.libraries.BuiltIn import BuiltIn

__all__ = [
    "NULLFALLBACK_VALUE"
]

tl = BuiltIn().get_variable_value('${tl}')

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

NULLFALLBACK_VALUE = {MR_NR_BTS_NAME: {'nullFallback': 'true'}}
