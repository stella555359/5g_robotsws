__author__ = 'krawczuk'


NGAP_ErrorIndication_container = """initiatingMessage :
{
procedureCode 15,
criticality ignore,
value ErrorIndication :
{
protocolIEs
{
_AMF_UE_NGAP_ID_,
_RAN_UE_NGAP_ID_
}
}
}"""

_AMF_UE_NGAP_ID_ = """{
id 10,
criticality 1,
value AMF-UE-NGAP-ID : _AMF_UE_NGAP_IDValue_
}"""

_AMF_UE_NGAP_IDValue_ = """0"""


_RAN_UE_NGAP_ID_ = """{
id 85,
criticality 1,
value RAN-UE-NGAP-ID : _RAN_UE_NGAP_IDValue_
}"""

_RAN_UE_NGAP_IDValue_ = """0"""
