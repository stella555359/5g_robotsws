from datetime import datetime
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog


def print_pretty_alarms(alarms):
    blog("Activated Alarms:")
    blog('################################')
    try:
        for alarm in alarms:
            date_time_obj = datetime.strptime(str(alarm['btsObservationTime']).split('.')[0], '%Y%m%d%H%M%S')
            blog('Time: {}'.format(date_time_obj))
            blog('Alarm Severity: {}'.format(alarm['severity']))
            blog('Alarm ID: {}'.format(alarm['alarmId']))
            blog('Fault ID: {}'.format(alarm['faultId']))
            blog('Alarm Name: {}'.format(alarm['alarmName']))
            blog('Alarm Detail: {}'.format(alarm['alarmDetail']))
            blog('################################')
    except BaseException as e:
        blog("Cannot print alarms. Exception: {}".format(e), level='WARN')


def print_pretty_radio_objects(radio_objects):
    blog("Radio Objects:")
    blog('################################')
    try:
        for radio_object in radio_objects:
            blog('Radio Name: {}'.format(radio_object['productName']))
            blog('Radio Code: {}'.format(radio_object['productCode']))
            blog('SN: {}'.format(radio_object['serialNumber']))
            blog('Administrative State: {}'.format(radio_object['status']['administrativeState']))
            blog('Operational State: {}'.format(radio_object['status']['operationalState']))
            blog('Usage State: {}'.format(radio_object['status']['usageState']))
            blog('Procedural Status: {}'.format(radio_object['status']['proceduralStatus']))
            try:
                blog('Availability Status: {}'.format(radio_object['status']['availabilityStatus']))
            except BaseException:
                blog('Availability Status: -')
            blog('################################')
    except BaseException as e:
        blog("Cannot print radio objects. Exception: {}".format(e), level='WARN')


def print_pretty_cells(cells):
    blog("Cells Status:")
    blog('################################')
    try:
        for cell in cells:
            blog('Cell ID: {}'.format(cell['id']['configuration']))
            blog('Cell Name: {}'.format(cell['cellName']))
            blog('Administrative State: {}'.format(cell['status']['administrativeState']))
            blog('Operational State: {}'.format(cell['status']['operationalState']))
            blog('Usage State: {}'.format(cell['status']['usageState']))
            blog('Blocking State: {}'.format(cell['status']['blockingState']))
            blog('Procedural Status: {}'.format(cell['status']['proceduralStatus']))
            blog('Barring Status: {}'.format(cell['status']['barringStatus']))
            blog('################################')
    except BaseException as e:
        blog("Cannot print cells objects. Exception: {}".format(e), level='WARN')


def print_pretty_smods(smods):
    blog("SMODs Status:")
    blog('################################')
    try:
        for smod in smods:
            blog('SMOD Name: {}'.format(smod['productName']))
            blog('SMOD Code: {}'.format(smod['productCode']))
            blog('SN: {}'.format(smod['serialNumber']))
            blog('Administrative State: {}'.format(smod['status']['administrativeState']))
            blog('Operational State: {}'.format(smod['status']['operationalState']))
            blog('Usage State: {}'.format(smod['status']['usageState']))
            blog('Procedural Status: {}'.format(smod['status']['proceduralStatus']))
            blog('################################')
    except BaseException as e:
        blog("Cannot print SMOD objects. Exception: {}".format(e), level='WARN')


def print_pretty_bbmods(bbmods):
    blog("BBMODs Status:")
    blog('################################')
    try:
        for bbmod in bbmods:
            blog('BBMOD Name: {}'.format(bbmod['productName']))
            blog('BBMOD Code: {}'.format(bbmod['productCode']))
            blog('SN: {}'.format(bbmod['serialNumber']))
            blog('Administrative State: {}'.format(bbmod['status']['administrativeState']))
            blog('Operational State: {}'.format(bbmod['status']['operationalState']))
            blog('Usage State: {}'.format(bbmod['status']['usageState']))
            blog('Procedural Status: {}'.format(bbmod['status']['proceduralStatus']))
            try:
                blog('Availability Status: {}'.format(bbmod['status']['availabilityStatus']))
            except BaseException:
                blog('Availability Status: -')
            blog('################################')
    except BaseException as e:
        blog("Cannot print BBMOD objects. Exception: {}".format(e), level='WARN')


def print_pretty_pdu(pdu_port):
    try:
        blog('PDU port status:')
        blog('#####################')
        blog('PDU IP address: {}'.format(pdu_port.pdu.addr))
        blog('PDU vendor: {}'.format(pdu_port.pdu.vendor))
        if pdu_port.pdu.model:
            blog('PDU model: {}'.format(pdu_port.pdu.model))
        if pdu_port.pdu.version:
            blog('PDU version: {}'.format(pdu_port.pdu.version))
        blog('PDU port number: {}'.format(pdu_port.port_no))
        blog('PDU contactor: {}'.format(pdu_port.contactor))
        blog('#####################')
    except BaseException as e:
        blog("Cannot print PDU object. Exception: {}".format(e), level='WARN')
