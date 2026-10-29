__author__ = 'krawczuk'


NGAP_LocationReportControl_container = """initiatingMessage :
{
procedureCode 16,
criticality ignore,
value LocationReportingControl  :
{
protocolIEs
{
_AMF_UE_NGAP_ID_,
_RAN_UE_NGAP_ID_,
_LocationReportingRequestType_
}
}
}"""

_AMF_UE_NGAP_ID_ = """{
id 10,
criticality 0,
value AMF-UE-NGAP-ID : _AMF_UE_NGAP_IDValue_
}"""

_AMF_UE_NGAP_IDValue_ = """0"""


_RAN_UE_NGAP_ID_ = """{
id 85,
criticality 0,
value RAN-UE-NGAP-ID : _RAN_UE_NGAP_IDValue_
}"""

_RAN_UE_NGAP_IDValue_ = """0"""

_LocationReportingRequestType_ = """{
id 33,
criticality ignore,
value LocationReportingRequestType : {
eventType _eventType_,
reportArea _reportArea_,
_areaOfInterestList_
}
}"""

_eventType_ = """change-of-serve-cell"""
_reportArea_ = """cell"""
_areaOfInterestList_ = None
_areaOfInterestListValue_ = """areaOfInterestList {
_areaOfInterestListItems_
}"""

_areaOfInterestListItems_ = """_areaOfInterestListItem_"""

_areaOfInterestListItem_ = """{
areaOfInterest {
areaOfInterestCellList {
{
nGRAN-CGI nR-CGI : {
pLMNIdentity '_pLMNIdentity_'H,
nRCellIdentity '_nRCellIdentity_'B
}
}
}
},
locationReportingReferenceID _locationReportingReferenceID_
}"""
_nRCellIdentityDefault_ = """101010101010101010101010101010101010"""

_nRCellIdentity_ = _nRCellIdentityDefault_

_pLMNIdentityDefault_ = '616263'

_pLMNIdentity_ = _pLMNIdentityDefault_

_locationReportingReferenceIDDefault_ = """0"""

_locationReportingReferenceID = _locationReportingReferenceIDDefault_
