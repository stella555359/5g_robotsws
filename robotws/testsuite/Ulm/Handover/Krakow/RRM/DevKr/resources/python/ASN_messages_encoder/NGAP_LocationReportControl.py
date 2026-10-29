from __future__ import print_function
from __future__ import absolute_import

import re

from builtins import str
__author__ = 'krawczuk'

from .ASN_message import ASN_message


class NGAP_LocationReportControl(ASN_message):
    def __init__(self):
        super(NGAP_LocationReportControl, self).__init__()

    def set_IDs(self, amf_ue_ngap_id=None, ran_ue_ngap_id=None):
        if amf_ue_ngap_id is not None:
            self.set_field('_AMF_UE_NGAP_IDValue_', str(int(amf_ue_ngap_id)))
        else:
            self.set_field('_AMF_UE_NGAP_ID_', None)

        if ran_ue_ngap_id is not None:
            self.set_field('_RAN_UE_NGAP_IDValue_', str(int(ran_ue_ngap_id)))
        else:
            self.set_field('_RAN_UE_NGAP_ID_', None)

    def set_event_type(self, eventType):
        self.set_field('_eventType_', eventType)

    def add_area(self, nrcellidentity_bits=None, locationReportingReferenceID_dec=None,
                 plmn_hex="134198",
                 ):
        first_item = False
        if self.get_field('_areaOfInterestList_') is None:
            self.set_field('_areaOfInterestList_', '_areaOfInterestListValue_')
            first_item = True

        self.append_to_list('_areaOfInterestListItems_',
                            '_areaOfInterestListItem_')
        self.set_field('_nRCellIdentity_',
                       nrcellidentity_bits if nrcellidentity_bits is not None else "_nRCellIdentityDefault_")
        self.set_field('_pLMNIdentity_',
                       str(re.sub('0x', '', plmn_hex)).upper() if plmn_hex is not None else "_pLMNIdentityDefault_")
        self.set_field('_locationReportingReferenceID_',
                       locationReportingReferenceID_dec
                       if locationReportingReferenceID_dec is not None else '_locationReportingReferenceIDDefault_')

    def remove(self, fieldname):
        self.set_field(fieldname, None)

# ------------------------------------------------------------------------------------------------------------------
# TEST METHODS
# ------------------------------------------------------------------------------------------------------------------

    def test_fill(self):
        pass

    def test_set_both_IDs(self):
        self.set_IDs(5, 10)

    def test_set_MME_ID(self):
        self.set_IDs(amf_ue_ngap_id=9)

    def test_set_ENB_ID(self):
        self.set_IDs(ran_ue_ngap_id=10)

    def test_remove(self):
        self.remove('RAN_UE_NGAP_ID')
        self.remove('AMF_UE_NGAP_ID')

    def test_fill_event_type1(self):
        self.set_event_type('change-of-serve-cell')

    def test_fill_event_type2(self):
        self.set_event_type('ue-presence-in-area-of-interest')

    def test_add_single_interest_area(self):
        self.set_event_type('ue-presence-in-area-of-interest')
        self.add_area()

    def test_add_two_interest_area(self):
        self.set_event_type('ue-presence-in-area-of-interest')
        self.add_area()
        self.add_area()

    def test_add_two_interest_area_different(self):
        self.set_event_type('ue-presence-in-area-of-interest')
        self.add_area('101010101010101010101010101010101011', '11')
        self.add_area('101010101010101010101010101010101000', '12')

    def test_add_two_interest_area_different(self):
        self.set_event_type('ue-presence-in-area-of-interest')
        self.add_area('101010101010101010101010101010101011', '11', 'AABBCC')
        self.add_area('101010101010101010101010101010101000', '12', 'DDEEFF')


if __name__ == '__main__':
    NGAP_LocationReportControl_msg = NGAP_LocationReportControl()
    NGAP_LocationReportControl_msg.add_area()
    NGAP_LocationReportControl_msg.add_area(plmn_hex='112233')
    print(NGAP_LocationReportControl_msg.fill())

# ----------------------------------------------------------------------------------------------------------------------
#  OUTPUT OF MESSAGE
# ----------------------------------------------------------------------------------------------------------------------
'''
initiatingMessage :
{
  procedureCode 16,
  criticality ignore,
  value LocationReportingControl  :
  {
    protocolIEs
    {
      {
        id 10,
        criticality 1,
        value AMF-UE-NGAP-ID : 0
        },
      {
        id 85,
        criticality 1,
        value RAN-UE-NGAP-ID : 0
        },
      {
        id 33,
        criticality ignore,
        value LocationReportingRequestType : {
          eventType change-of-serve-cell,
          reportArea cell
          }
        }
      }
    }
  }
'''
