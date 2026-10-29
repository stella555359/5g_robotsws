"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>
"""

from taf.gnb.oam.coam.cu.interface import cu
from taf.gnb.oam.coam.vdu.interface import Vdu
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


@keyword("VRAN Verify SERVEDAMF-${amf_id}:GUAMI-${guami_idx}: backupAmfName=${bkp_name}, guamiStatus=${guami_status}")
def verify_guami_status_on_vran(amf_id, guami_idx, bkp_name, guami_status):
    """
    GUAMI = [amfRegion]:[amfSet]:[amfPointer]
    AMF-1 GUAMIs  1:2:1, 1:2:2
    AMF-2 GUAMIs  1:2:3
    AMF-3 GUAMIs  1:2:4
    """
    vcu = cu()
    vran_moc_dict = vcu.search_parameters_of_current_plan(parameter_name='guamiStatus', connection='default')

    bkp_name = None if bkp_name == 'None' else bkp_name
    amf_properties = ['backupAmfName', 'guamiStatus']
    amf_guami_backup = {}

    for moc in vran_moc_dict['items']:
        if moc['distname'] == 'MRBTS-1/NRBTS-1/SERVEDAMF-{}'.format(amf_id):
            for guami in moc['parameter']['complex_parameter']['value']:  # guami is type ComplexParamChildrenStructure
                guami_parameters_list = guami.to_dict()['structure_parameters']

                amf_pointer = None
                for x in guami_parameters_list:
                    if x['simple_parameter']['name'] == 'amfPointer':
                        amf_pointer = int(x['simple_parameter']['value'])

                guami_values = [x['simple_parameter']['value']
                                for x in guami_parameters_list
                                if x['simple_parameter']['name'] in amf_properties]

                amf_guami_backup[amf_pointer] = guami_values

    amf_pointer = int(amf_id) + int(guami_idx) if int(amf_id) != 1 else int(guami_idx)

    if guami_status not in amf_guami_backup[amf_pointer]:
        raise AssertionError('amf_id={}, guami_idx={} wrong guamiStatus value (should be {})'.format(amf_id,
                                                                                                     guami_idx,
                                                                                                     guami_status))

    if bkp_name is None:
        if len(amf_guami_backup[amf_pointer]) != 1:
            raise AssertionError('amf_id={}, guami_idx={} backupAmfName should not be set'.format(amf_id, guami_idx))
    else:
        if bkp_name not in amf_guami_backup[amf_pointer]:
            raise AssertionError(
                'amf_id={}, guami_idx={} wrong backupAmfName value (should be {})'.format(amf_id, guami_idx, bkp_name))


@keyword("VRAN Verify that alarm with ${fault_name} fault and fault ID=${fault_id} is raised for AMF${amf_id}")
def verify_that_vran_alarm_is_active(fault_name, fault_id, amf_id):
    vcu = cu()
    alarms = vcu.get_active_alarms(connection='default')['alarms']

    for alarm in alarms:
        if alarm['fault_name'] == fault_name and \
           alarm['fault_id'] == fault_id and \
           alarm['alarming_object'] == 'MRBTS-1/NRBTS-1/SERVEDAMF-{}'.format(amf_id):
            return True
    else:
        raise AssertionError('fault_name={} is not active on amf_id={}'.format(fault_name, amf_id))
