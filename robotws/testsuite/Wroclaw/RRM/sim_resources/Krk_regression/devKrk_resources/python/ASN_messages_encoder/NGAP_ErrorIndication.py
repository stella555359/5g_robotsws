from __future__ import print_function
from __future__ import absolute_import
from builtins import str
__author__ = 'krawczuk'

from .ASN_message import ASN_message


class NGAP_ErrorIndication(ASN_message):
    def __init__(self):
        super(NGAP_ErrorIndication, self).__init__()

    def set_IDs(self, amf_ue_ngap_id=None, ran_ue_ngap_id=None):
        if amf_ue_ngap_id is not None:
            self.set_field('_AMF_UE_NGAP_IDValue_', str(int(amf_ue_ngap_id)))
        else:
            self.set_field('_AMF_UE_NGAP_ID_', None)

        if ran_ue_ngap_id is not None:
            self.set_field('_RAN_UE_NGAP_IDValue_', str(int(ran_ue_ngap_id)))
        else:
            self.set_field('_RAN_UE_NGAP_ID_', None)

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


if __name__ == '__main__':
    NGAP_ErrorIndication_msg = NGAP_ErrorIndication()
    print(NGAP_ErrorIndication_msg.fill())

# ----------------------------------------------------------------------------------------------------------------------
#  OUTPUT OF MESSAGE
# ----------------------------------------------------------------------------------------------------------------------
'''

'''
