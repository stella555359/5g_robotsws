import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin


def change_NRADJGNB_and_XNLINK_objects(operation, number_of_gnb_relations):
    with fixture.webUI.WebUIOperations() as coam:
        for i in range(int(number_of_gnb_relations)):
            rel_id = str(i + 1)
            if operation == 'create':
                param_NRADJGNB_object = set_parameters_for_NRADJGNB_object(rel_id)
                param_XNLINK_object = set_parameters_for_XNLINK_object(rel_id)
            else:
                param_NRADJGNB_object = []
                param_XNLINK_object = []
            coam.perform_object_recommissioning(dist_name=set_dist_name('NRADJGNB', rel_id),
                                                parameter=param_NRADJGNB_object,
                                                operation=operation,
                                                skip_parameter_relation_errors=True)
            coam.perform_object_recommissioning(dist_name=set_dist_name('XNLINK', rel_id),
                                                parameter=param_XNLINK_object,
                                                operation=operation,
                                                skip_parameter_relation_errors=True)


def set_dist_name(object_name, rel_id, gnb_id='0'):
    return 'MRBTS-' + str(BuiltIn().get_variable_value('${tl.gnbs[' + gnb_id + '].instance_id}')) + '/NRBTS-' + \
           str(BuiltIn().get_variable_value('${tl.gnbs[' + gnb_id + '].global_bts_id}')) +\
           '/' + object_name + '-' + str(rel_id)


def set_parameters_for_NRADJGNB_object(gnb_id):
    return [
            {
                'parameterName': 'adjGnbRoutingId',
                'operation': 'update',
                'value': gnb_id
            },
            {
                'parameterName': 'administrativeState',
                'operation': 'update',
                'value': 'Unlocked'
            },
            {
                'parameterName': 'gNbIdLength',
                'operation': 'update',
                'value': '32'
            },
            {
                'parameterName': 'gNodeBId',
                'operation': 'update',
                'value': str(BuiltIn().get_variable_value('${tl.gnbs[' + gnb_id + '].global_bts_id}'))
            },
            {
                'parameterName': 'xnLinkRef',
                'operation': 'update',
                'value': gnb_id
            },
            {
                'parameterName': 'gnbPlmn',
                'operation': 'update',
                'value': [
                    {
                        'mcc': str(BuiltIn().get_variable_value('${tl.core.mcc}')),
                        'mnc': str(BuiltIn().get_variable_value('${tl.core.mnc}')),
                        'mncLength': set_mnc_length()
                    }
                ]
            }
        ]


def set_parameters_for_XNLINK_object(gnb_id):
    return [
            {
                'parameterName': 'cPlaneIpAddr',
                'operation': 'update',
                'value': str(BuiltIn().get_variable_value('${tl.gnbs[' + gnb_id + '].cu.xnc.v4}'))
            }
    ]


def set_mnc_length():
    if len(str(BuiltIn().get_variable_value('${tl.core.mnc}'))) < 3:
        return '2'
    else:
        return '3'


def update_xn_link_status(value, gnb_id):
    dist_name = 'MRBTS-' + str(BuiltIn().get_variable_value('${tl.gnbs[' + gnb_id + '].instance_id}'))\
                + '/NRBTS-' + str(BuiltIn().get_variable_value('${tl.gnbs[' + gnb_id + '].global_bts_id}'))
    session = admin()
    session.connect_to(bts_host=str(BuiltIn().
                                    get_variable_value('${tl.gnbs[' + gnb_id + '].cu.backhaul_site_oam_ip.v4}')))
    session.perform_parameter_recommissioning(dist_name=dist_name,
                                              parameter='actIncXn',
                                              operation='update',
                                              skip_parameter_relation_errors=True,
                                              value=value)
    session.teardown()


def check_xn_link_status(id_length=1):
    with fixture.webUI.WebUIOperations() as coam:
        output = coam.get_managed_objects(class_name='XNLINK_R', timeout=30)
        xn_ref_id_state_dict = {}
        for i in range(len(output)):
            xn_ref_id_state_dict.update({output[i]['distName']
                                         [-int(id_length):]: output[i]['parameters']['xnLinkStatus']})
        return xn_ref_id_state_dict
