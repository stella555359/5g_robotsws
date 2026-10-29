# SAS-CBSD protocal version
SAS_VERSION_TS_10 = 'v1.0'
SAS_VERSION_TS_11 = 'v1.1'
SAS_VERSION_TS_12 = 'v1.2'
sas_version_t = (SAS_VERSION_TS_10, SAS_VERSION_TS_11, SAS_VERSION_TS_12)

# CBSD State
STATE_UNREG = 'Unregistered'
STATE_REG = 'Registered'
op_state_t = (STATE_UNREG,
              STATE_REG)

# GRANT State
GRANT_STATE_IDLE = 'Idle'
GRANT_STATE_GRANTED = 'Granted'
GRANT_STATE_AUTHORIZED = 'Authorized'
grant_state_t = (GRANT_STATE_IDLE,
                 GRANT_STATE_GRANTED,
                 GRANT_STATE_AUTHORIZED)

# SAS Method
METHOD_REG = 'registration'
METHOD_DEREG = 'deregistration'
METHOD_INQUIRY = 'spectrumInquiry'
METHOD_GRANT = 'grant'
METHOD_HEARTBEAT = 'heartbeat'
METHOD_RELINQUISH = 'relinquishment'
sas_method_t = (METHOD_REG,
                METHOD_DEREG,
                METHOD_INQUIRY,
                METHOD_GRANT,
                METHOD_HEARTBEAT,
                METHOD_RELINQUISH)

# SAS Manager Method
METHOD_MNG_CBSD = 'mngCbsd'
METHOD_MNG_BLIST = 'mngBlist'
METHOD_MNG_BL_ADD = 'mngBlistAdd'
METHOD_MNG_BL_DEL = 'mngBlistDel'
METHOD_MNG_PPA = 'mngPpa'
METHOD_MNG_PPA_ADD = 'mngPpaAdd'
METHOD_MNG_PPA_DEL = 'mngPpaDel'
METHOD_MNG_GRANT_SP = 'mngGrantSuspend'
METHOD_MNG_GRANT_TN = 'mngGrantTerminate'
METHOD_MNG_GRANT_FREE = 'mngGrantFree'
METHOD_MNG_GRANT_RENEW = 'mngGrantRenew'
METHOD_MNG_TRANSMIT_RENEW = 'mngTransmitRenew'
METHOD_MNG_VERSION = 'mngVersion'
METHOD_MNG_OPTION_BLOCK_REQUEST = 'mngOptionBlockRequest'
METHOD_MNG_OPTION_CONNECTION_REJECT = 'mngOptionConnectionReject'
sas_manager_method_t = (METHOD_MNG_CBSD,
                        METHOD_MNG_BLIST,
                        METHOD_MNG_BL_ADD,
                        METHOD_MNG_BL_DEL,
                        METHOD_MNG_PPA,
                        METHOD_MNG_PPA_ADD,
                        METHOD_MNG_PPA_DEL,
                        METHOD_MNG_GRANT_SP,
                        METHOD_MNG_GRANT_TN,
                        METHOD_MNG_GRANT_FREE,
                        METHOD_MNG_GRANT_RENEW,
                        METHOD_MNG_TRANSMIT_RENEW,
                        METHOD_MNG_VERSION,
                        METHOD_MNG_OPTION_BLOCK_REQUEST,
                        METHOD_MNG_OPTION_CONNECTION_REJECT)

# SAS Internal Method
METHOD_INT_EVENT = 'intEvent'
sas_int_method_t = METHOD_INT_EVENT

# Message Name
REQ_REG = 'registrationRequest'
RES_REG = 'registrationResponse'
REQ_DEREG = 'deregistrationRequest'
RES_DEREG = 'deregistrationResponse'
REQ_INQUIRY = 'spectrumInquiryRequest'
RES_INQUIRY = 'spectrumInquiryResponse'
REQ_GRANT = 'grantRequest'
RES_GRANT = 'grantResponse'
REQ_HEARTBEAT = 'heartbeatRequest'
RES_HEARTBEAT = 'heartbeatResponse'
REQ_RELINQUISH = 'relinquishmentRequest'
RES_RELINQUISH = 'relinquishmentResponse'
sas_req_t = (REQ_REG,
             REQ_DEREG,
             REQ_INQUIRY,
             REQ_GRANT,
             REQ_HEARTBEAT,
             REQ_RELINQUISH)
sas_res_t = (RES_REG,
             RES_DEREG,
             RES_INQUIRY,
             RES_GRANT,
             RES_HEARTBEAT,
             RES_RELINQUISH)

sas_method_2_res_t = {METHOD_REG: RES_REG,
                      METHOD_DEREG: RES_DEREG,
                      METHOD_INQUIRY: RES_INQUIRY,
                      METHOD_GRANT: RES_GRANT,
                      METHOD_HEARTBEAT: RES_HEARTBEAT,
                      METHOD_RELINQUISH: RES_RELINQUISH}

# Manager Message Name
REQ_MNG_CBSD = 'mngCbsdRequest'
RES_MNG_CBSD = 'mngCbsdResponse'
REQ_MNG_BLIST = 'mngBlistRequest'
RES_MNG_BLIST = 'mngBlistResponse'
REQ_MNG_BL_ADD = 'mngBlistAddRequest'
RES_MNG_BL_ADD = 'mngBlistAddResponse'
REQ_MNG_BL_DEL = 'mngBlistDelRequest'
RES_MNG_BL_DEL = 'mngBlistDelResponse'
REQ_MNG_PPA = 'mngPpaRequest'
RES_MNG_PPA = 'mngPpaResponse'
REQ_MNG_PPA_ADD = 'mngPpaAddRequest'
RES_MNG_PPA_ADD = 'mngPpaAddResponse'
REQ_MNG_PPA_DEL = 'mngPpaDelRequest'
RES_MNG_PPA_DEL = 'mngPpaDelResponse'
REQ_MNG_GRANT_SP = 'mngGrantSuspendRequest'
RES_MNG_GRANT_SP = 'mngGrantSuspendResponse'
REQ_MNG_GRANT_TN = 'mngGrantTerminateRequest'
RES_MNG_GRANT_TN = 'mngGrantTerminateResponse'
REQ_MNG_GRANT_FREE = 'mngGrantFreeRequest'
RES_MNG_GRANT_FREE = 'mngGrantFreeResponse'
REQ_MNG_GRANT_RENEW = 'mngGrantRenewRequest'
RES_MNG_GRANT_RENEW = 'mngGrantRenewResponse'
REQ_MNG_TRANSMIT_RENEW = 'mngTransmitRenewRequest'
RES_MNG_TRANSMIT_RENEW = 'mngTransmitRenewResponse'
REQ_MNG_VERSION = 'mngVersionRequest'
RES_MNG_VERSION = 'mngVersionResponse'
REQ_MNG_OPTION_BLOCK_REQUEST = 'mngBlockRequestRequest'
RES_MNG_OPTION_BLOCK_REQUEST = 'mngBlockRequestResponse'
REQ_MNG_OPTION_CONNECTION_REJECT = 'mngConnectionRejectRequest'
RES_MNG_OPTION_CONNECTION_REJECT = 'mngConnectionRejectResponse'
sas_manager_req_t = (REQ_MNG_CBSD,
                     REQ_MNG_BLIST,
                     REQ_MNG_BL_ADD,
                     REQ_MNG_BL_DEL,
                     REQ_MNG_PPA,
                     REQ_MNG_PPA_ADD,
                     REQ_MNG_PPA_DEL,
                     REQ_MNG_GRANT_SP,
                     REQ_MNG_GRANT_TN,
                     REQ_MNG_GRANT_FREE,
                     REQ_MNG_GRANT_RENEW,
                     REQ_MNG_TRANSMIT_RENEW,
                     REQ_MNG_VERSION,
                     REQ_MNG_OPTION_BLOCK_REQUEST,
                     REQ_MNG_OPTION_CONNECTION_REJECT)
sas__manager_res_t = (RES_MNG_CBSD,
                      RES_MNG_BLIST,
                      RES_MNG_BL_ADD,
                      RES_MNG_BL_DEL,
                      RES_MNG_PPA,
                      RES_MNG_PPA_ADD,
                      RES_MNG_PPA_DEL,
                      RES_MNG_GRANT_SP,
                      RES_MNG_GRANT_TN,
                      RES_MNG_GRANT_FREE,
                      RES_MNG_GRANT_RENEW,
                      RES_MNG_TRANSMIT_RENEW,
                      RES_MNG_VERSION,
                      RES_MNG_OPTION_BLOCK_REQUEST,
                      RES_MNG_OPTION_CONNECTION_REJECT)

# Internal Event Message Name
EVENT_HEARTBEAT_TIMEOUT = 'intHbTimeoutEvent'
EVENT_GRANT_TIMEOUT = 'intGrantTimeoutEvent'
EVENT_TRANSMIT_TIMEOUT = 'intTransmitTimeoutEvent'
sas_int_event_t = (EVENT_HEARTBEAT_TIMEOUT,
                   EVENT_GRANT_TIMEOUT,
                   EVENT_TRANSMIT_TIMEOUT)

# Parameter Name
PAR_ERROR = 'response'
PAR_ERR_CODE = 'responseCode'
PAR_ERR_MSG = 'responseMessage'
PAR_ERR_DATA = 'responseData'
PAR_USER_ID = 'userId'
PAR_FCC_ID = 'fccId'
PAR_CBSD_SN = 'cbsdSerialNumber'
PAR_CALL_SIGN = 'callSign'
PAR_CBSD_CAT = 'cbsdCategory'
PAR_CBSD_INFO = 'cbsdInfo'
PAR_INFO_VENDOR = 'vendor'
PAR_INFO_MODEL = 'model'
PAR_INFO_SV = 'softwareVersion'
PAR_INFO_HV = 'hardwareVersion'
PAR_INFO_FV = 'firmwareVersion'
PAR_AIR_IF = 'airInterface'
PAR_RADIO_TECH = 'radioTechnology'
PAR_RADIO_SPEC = 'supportedSpec'
PAR_INSTALL_PAR = 'installationParam'
PAR_LATITUDE = 'latitude'
PAR_LONGITUDE = 'longitude'
PAR_HEIGHT = 'height'
PAR_HEIGHT_TYPE = 'heightType'
PAR_HORI_ACCU = 'horizontalAccuracy'
PAR_VERT_ACCU = 'verticalAccuracy'
PAR_INDOOR_DEP = 'indoorDeployment'
PAR_ANT_AZIM = 'antennaAzimuth'
PAR_ANT_DOWN_TILT = 'antennaDowntilt'
PAR_ANT_GAIN = 'antennaGain'
PAR_ANT_EIRP = 'eirpCapability'
PAR_ANT_BEAMW = 'antennaBeamwidth'
PAR_ANT_MODEL = 'antennaModel'
PAR_GROUP_PAR = 'groupParam'
PAR_GROUP_TYPE = 'groupType'
PAR_GROUP_ID = 'groupId'
PAR_MEAS_CAP = 'measCapability'
PAR_MEAS_REP = 'measReportConfig'
PAR_CBSD_ID = 'cbsdId'
PAR_INQ_SPECT = 'inquiredSpectrum'
PAR_FREQ_RANG = 'frequencyRange'
PAR_OP_FREQ_RANG = 'operationFrequencyRange'
PAR_LOW_FREQ = 'lowFrequency'
PAR_HIGH_FREQ = 'highFrequency'
PAR_AVAIL_CHN = 'availableChannel'
PAR_CHN_TYPE = 'channelType'
PAR_RULE_APPL = 'ruleApplied'
PAR_OP_PAR = 'operationParam'
PAR_PEAK_PW = 'peakPower'
PAR_MAX_EIRP = 'maxEirp'
PAR_GRANT_ID = 'grantId'
PAR_GRANT_RENEW = 'grantRenew'
PAR_GRANT_EXP = 'grantExpireTime'
PAR_HB_DUR = 'heartbeatInterval'
PAR_OP_STATE = 'operationState'
PAR_TRANS_EXP = 'transmitExpireTime'
PAR_EVENT_TYPE = 'eventType'
# used in internal message
PAR_GRANTS = 'grants'
# used in DP features in response
PAR_ERR_BACKOFFINTERVAL = 'backoffInterval'

# constant
CHN_TYPE_PAL = 'PAL'
CHN_TYPE_GAA = 'GAA'

# measurement reporting capabilities supported by TS1.0
MEAS_CAP_RSSI_NON_TX = "EUTRA_CARRIER_RSSI_NON_TX"
MEAS_CAP_RSSI_ALWAYS = "EUTRA_CARRIER_RSSI_ALWAYS"
meas_cap_t = (MEAS_CAP_RSSI_NON_TX, MEAS_CAP_RSSI_ALWAYS)

# measurement reporting capabilities supported by TS1.1
MEAS_CAP_RECEIVED_POWER_WITHOUT_GRANT = "RECEIVED_POWER_WITHOUT_GRANT"
MEAS_CAP_RECEIVED_POWER_WITH_GRANT = "RECEIVED_POWER_WITH_GRANT"
meas_cap_11_t = (MEAS_CAP_RECEIVED_POWER_WITHOUT_GRANT, MEAS_CAP_RECEIVED_POWER_WITH_GRANT)

HEIGHT_TYPE_AGL = "AGL"
HEIGHT_TYPE_AMSL = "AMSL"
heigt_type_t = (HEIGHT_TYPE_AGL, HEIGHT_TYPE_AMSL)

error_code_table = {
    0: 'CBSD request is approved by SAS',
    100: 'SAS protocol version used by CBSD is not supported by SAS',
    101: 'CBSD is blacklisted',
    102: 'Required parameters missing',
    103: 'One or more parameters have invalid value',
    104: 'There is an error in the certificate used to make the request',
    105: 'A CBSD receiving this responseCode is automatically deregistered by the SAS',
    200: 'Incomplete registration information. The registration process is pending.',
    201: 'An error has been identified in the grouping parameters of the CBSD',
    202: 'The CBSD registered as a Category A device but is required to register as a Category B device',
    300: 'SAS does not support the spectrum in the spectrum inquiry request or grant request',
    400: 'Requested operation parameters cause too much interference',
    401: 'Conflict with an existing grant of the same CBSD',
    500: 'The grant is terminated',
    501: 'The grant is suspended',
    502: 'Operation parameters or Grant state(s) is/are out of sync between the CBSD and the SAS',
    999: 'This is an invalid code and used for test purpose only',
    9190: 'DP is not able to communicate with SAS',
    9191: 'DP has performed SAS switchover',
    9192: 'Unable to register due to license/capacity exhaustion at DP',
}

mng_error_code_table = {
    0: 'Management request is approved by SAS',
    101: 'Required parameters missing',
    102: 'Required parameter is invalid',
    201: 'One or more blacklist item is already existing',
    202: 'One or more blacklist item is not existing',
    301: 'One or more suspend/terminate item is already existing',
    302: 'One or more suspend/terminate item is not existing',
    303: 'One or more suspend/terminate item is invalid',
    304: 'One or more item is not suspended or not terminated',
}
