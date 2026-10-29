from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *

carrierAggregationSupportList = BuiltIn().get_variable_value('${carrierAggregationSupportList}')

ACTIVE_5GC001390_VIA_WEBUI_PDL_ERROR_SUB = [
    dict(
        new_value=carrierAggregationSupportList,
        dist_name=DN_NRBTS + '/NRDU-1',
        abbr='carrierAggregationSupportList',
        filter_param='List of supported 5G carrier aggregations'),
]

DEACTIVE_5GC002255_VIA_WEBUI_PDL_ERROR = [
    dict(
        new_value='false',
        dist_name=DN_NRBTS + '/NRDU-1',
        abbr='actInterNumerologyCa',
        filter_param='Activate inter-numerology carrier aggregation')
]

ACTIVE_5GC001390_VIA_WEBUI_PDL_ERROR = ACTIVE_5GC001390_VIA_WEBUI_PDL_ERROR_SUB + \
                                       DEACTIVE_5GC002255_VIA_WEBUI_PDL_ERROR
