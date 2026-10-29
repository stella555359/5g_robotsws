from robot.libraries.BuiltIn import BuiltIn


tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
BTS_ID = str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

MODIFY_SCF_8294_DEFAULT = [
    dict(dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregationFr2SA', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='actCsiReportsMuxOnPucch', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupportFr2SA', value='8CCDL_4CCUL'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod', value='bufferBased'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDlFr2SA', value='7'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUlFr2SA', value='3'),
    ]

ADD_SCF_DEFAULT = []

DELETE_SCF_DEFAULT = []
