import pprint

from testsuite.Krakow.RRM.DevKr.resources.python.ASN_messages_encoder.NGAP_LocationReportControl \
    import NGAP_LocationReportControl
from testsuite.Krakow.RRM.DevKr.resources.python.ASN_messages_encoder.uesim_dump import uesim_dump

plmn = '134198'


def build_LRC(amf_id, ran_id, event_type=None, area_cells=None):
    msg_template = NGAP_LocationReportControl()
    msg_template.set_IDs(amf_id, ran_id)
    if event_type is not None:
        msg_template.set_event_type(event_type)
    if area_cells is not None:
        cells = area_cells.strip().split(',')
        for cell_ref_id in cells:
            cell, ref_id = cell_ref_id.strip().split(':')
            msg_template.add_area(nrcellidentity_bits=cell, locationReportingReferenceID_dec=ref_id, plmn_hex=plmn)
    msg_str = msg_template.fill()
    print(('Message content ready to encode:\n{}'.format(pprint.pformat(msg_str))))
    msg_hex = uesim_dump().encode_message(msg_str, 'NGAP')
    return msg_hex
