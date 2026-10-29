#!/usr/bin/env python
# -*- coding: utf-8 -*-


import datetime
import json

from sas.Consts import *
from utils.LoggerHandler import LoggerHandler

from .grant.Grant import Grant


# remove the key finded firstly from a dictionary by recursion search.
def dict_pop(dic, key):
    if isinstance(dic, dict):
        if key in dic:
            dic.pop(key)
            return True
        else:
            for value_item in iter(dic.values()):
                if isinstance(value_item, dict):
                    if dict_pop(value_item, key):
                        return True
    return False


# update the key value finded firstly from a dictionary by recursion search.
def dict_update(dic, key, val):
    if isinstance(dic, dict):
        if key in dic:
            dic[key] = val
            return True
        else:
            for value_item in iter(dic.values()):
                if isinstance(value_item, dict):
                    if dict_update(value_item, key, val):
                        return True
    return False


class CBSDSeq(object):
    def __init__(self):
        self.force_http_response_sequences = {}
        self.force_sas_feature_capability_list_group_sequences = {}
        self.force_method_cbrsa_version_group_sequences = {}
        self.force_method_eutra_tdd_config_group_sequences = {}
        self.force_method_groupingconfig_group_sequences = {}
        self.force_method_frequency_guidance_group_sequences = {}


class CBSD(object):
    def __init__(self, config, logHandler):
        self.config = config
        self.log = logHandler
        self.version = None
        self.opState = STATE_UNREG
        self.userID = ''
        self.fccID = ''
        self.serialNum = ''
        self.callSign = None
        self.category = None
        self.cbsdID = ''
        self.channelID = ''
        self.PeakPower = 0
        self.cbsdInfo = {}
        self.airIf = {}
        self.instPar = {}
        self.groupingParam = {}
        self.groupingConfig = {}
        self.meas = []
        self.grantList = {}
        self.grantBlockedRequestSequenceList = {}
        self.excludePar = False
        self.clearSasFeatureList = False
        # spectrum which channel type updated by heartbeat
        self.spectrum_channel_type_updated_by_hb0 = {}
        # spectrum which maxEirp updated by heartbeat
        self.spectrum_max_eirp_updated_by_hb0 = {}
        # spectrum which channel type updated by heartbeat for particular cbsd
        self.cbsd_spectrum_channel_type_updated_by_hb0 = {}
        # spectrum which maxEirp updated by heartbeat for particular cbsd
        self.cbsd_spectrum_max_eirp_updated_by_hb0 = {}
        self.cbsdSeq = CBSDSeq()
        self.sas_feature_capability_list = []
        self.recommend_operationParam_heartbeat0_sequences = {}
        self.force_heartbert_channeltype_group_sequences = {}
        self.force_method_feature_exchange_trigger_sequences = {}

    def cleanup(self):
        self.version = None
        self.userID = ''
        self.fccID = ''
        self.serialNum = ''
        self.callSign = None
        self.category = None
        self.cbsdID = ''
        self.channelID = ''
        self.PeakPower = 0
        self.cbsdInfo.clear()
        self.airIf.clear()
        self.instPar.clear()
        self.groupingParam.clear()
        self.groupingConfig.clear()
        self.meas = []
        self.grantList.clear()
        self.excludePar = False
        self.clearSasFeatureList = False
        self.recommend_operationParam_heartbeat0_sequences.clear()
        self.force_heartbert_channeltype_group_sequences.clear()
        self.force_method_feature_exchange_trigger_sequences.clear()

    def stop(self):
        for grant_id in self.grantList.keys():
            grant = self.grantList[grant_id]
            grant.stop()
        self.cleanup()
        self.opState = STATE_UNREG
        self.log.info('cbsd %s is stopped' % self.cbsdID)

    def get_opState(self):
        return self.opState

    def set_opState(self, state, duration=None):
        old_state = self.opState
        if state == STATE_UNREG:
            if old_state == STATE_REG:
                for grant_id in self.grantList:
                    grant = self.grantList[grant_id]
                    grant.stop()
                self.grantList.clear()
            self.opState = state
            self.log.info('cbsd %s change op state to %s from %s' % (self.cbsdID, state, old_state))
        elif state == STATE_REG:
            if old_state == STATE_UNREG:
                self.opState = state
                self.log.info('cbsd %s change op state to %s from %s' % (self.cbsdID, state, old_state))
        else:
            self.log.warning('invalid op state %s' % state)

    def isMatchedPalChannelType(self, lowFreq, availableChannels):
        for item in availableChannels:
            if str(item[PAR_FREQ_RANG][PAR_LOW_FREQ]) == lowFreq:
                if str(item[PAR_CHN_TYPE]) == 'PAL':
                    return True
        return False

    def should_proceed_with_force_response_per_cbsd(self, cbsdId):
        return cbsdId in self.config.cbsd_force_sas_method_set

    def check_REG_Conditional_param(self, reg_req):
        # REG-Conditional Parameters in TS1.1
        if self.version >= SAS_VERSION_TS_11:
            if PAR_CBSD_CAT not in reg_req:
                return PAR_CBSD_CAT
            if PAR_AIR_IF not in reg_req:
                return PAR_AIR_IF
            else:
                if PAR_RADIO_TECH not in reg_req[PAR_AIR_IF]:
                    return PAR_RADIO_TECH
            if reg_req[PAR_CBSD_CAT] != 'A' and reg_req[PAR_CBSD_CAT] != 'B':
                if PAR_INSTALL_PAR not in reg_req:
                    return PAR_INSTALL_PAR
                else:
                    if PAR_LATITUDE not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_LATITUDE
                    if PAR_LONGITUDE not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_LONGITUDE
                    if PAR_HEIGHT not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_HEIGHT
                    if PAR_HEIGHT_TYPE not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_HEIGHT_TYPE
                    if PAR_INDOOR_DEP not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_INDOOR_DEP
                    # antennaAzimuth, antennaDowntilt and antennaBeamwidth denpends on Category
                    if PAR_ANT_GAIN not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_ANT_GAIN

            if PAR_MEAS_CAP not in reg_req:
                return PAR_MEAS_CAP
            return None

    def feadata_handler(self, msg, protocol, blist=None):
        if protocol != self.version:
            self.log.warning('feadata_handler invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]
        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, []]
        feadata_req = msg

        # Required Parameters
        if PAR_CBSD_ID not in feadata_req:
            self.log.warning('missing %s in featureData request' % PAR_CBSD_ID)
            return [102, PAR_CBSD_ID]
        if PAR_CBSD_FEA_INFO not in feadata_req:
            self.log.warning('missing %s in featureData request' % PAR_CBSD_FEA_INFO)
            return [102, PAR_CBSD_FEA_INFO]
        self.cbsdFeatureInfo = feadata_req[PAR_CBSD_FEA_INFO]
        for featureInfo in self.cbsdFeatureInfo:
            if PAR_FEA_ID not in featureInfo:
                self.log.warning('missing %s in cbsdFeatureInfo of featureData request' % PAR_FEA_ID)
                return [102, PAR_FEA_ID]

        # handle forced case
        if self.config.SAS_METHOD_FORCE == METHOD_FEATUREDATA:
            self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
            if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                        self.config.force_sas_method_sequences['DUMMY_GRANT'] in self.config.SAS_METHOD_FORCE_SEQUENCE:
                    self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                    return [self.config.RESPONSE_CODE_FORCE, [self.config.RESPONSE_DATA_FORCE]]

        return [0, '']

    def feaexchange_handler(self, msg, protocol, blist=None):
        if protocol != self.version:
            self.log.warning('feaexchange_handler invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]
        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, []]
        fea_exchange_req = msg

        # Required Parameters
        if PAR_CBSD_ID not in fea_exchange_req:
            self.log.warning('missing %s in featureCapabilityExchange request' % PAR_CBSD_ID)
            return [102, PAR_CBSD_ID]
        if PAR_CBSD_FEATURE_CAPABILITY_LIST not in fea_exchange_req:
            self.log.warning('missing %s in featureCapabilityExchange request' % PAR_CBSD_FEATURE_CAPABILITY_LIST)
            return [102, PAR_CBSD_FEATURE_CAPABILITY_LIST]

        # handle forced case
        if self.config.SAS_METHOD_FORCE == METHOD_FEATUREEXCHANGE:
            self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
            if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                        self.config.force_sas_method_sequences['DUMMY_GRANT'] in self.config.SAS_METHOD_FORCE_SEQUENCE:
                    self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                    return [self.config.RESPONSE_CODE_FORCE, [self.config.RESPONSE_DATA_FORCE]]

        force_sas_method_group_key = 'DUMMY' + '_' + METHOD_FEATUREEXCHANGE
        self.log.info('force the value of grantIdForEachGroup to be %s' % force_sas_method_group_key)
        if force_sas_method_group_key not in self.config.force_sas_method_group_sequences:
            self.log.info('force_sas_method_group_key not in self.config.force_sas_method_group_sequences')
            self.config.force_sas_method_group_sequences[force_sas_method_group_key] = 0
        else:
            self.log.info('force_sas_method_group_key in self.config.force_sas_method_group_sequences')
            self.config.force_sas_method_group_sequences[force_sas_method_group_key] += 1
            if len(self.config.force_sas_method_group) != 0:
                self.log.info('len of force_sas_method_group is %d' % len(self.config.force_sas_method_group))
                for force_sas_method in self.config.force_sas_method_group:
                    force_sas_method_key = force_sas_method.split(',')
                    if (force_sas_method_key[0] == 'DUMMY') and force_sas_method_key[1] == METHOD_FEATUREEXCHANGE:
                        self.log.info('method is %s' % force_sas_method_key[1])
                        sequence = int(force_sas_method_key[2])
                        response_code = force_sas_method_key[3]
                        self.log.info('sequence is  %d' % sequence)
                        self.log.info('response_code is  %s' % response_code)
                        featureDataExchangeConfigFlg = -1
                        if len(force_sas_method_key) >= 5:
                            featureDataExchangeConfigFlg = int(force_sas_method_key[4])
                        reponse_force_data = 0
                        if len(force_sas_method_key) >= 6:
                            reponse_force_data = force_sas_method_key[5]
                            self.log.info('reponse_force_data is  %s' % reponse_force_data)
                        if self.config.force_sas_method_group_sequences[force_sas_method_group_key] == sequence:
                            self.log.info('find the sequence')
                            self.log.info('force the value of resonseCode to be %s' % response_code)
                            if int(response_code) == 0:
                                return [int(response_code), '', featureDataExchangeConfigFlg]
                            if reponse_force_data:
                                return [int(response_code), reponse_force_data, featureDataExchangeConfigFlg]
                            return [int(response_code), '', featureDataExchangeConfigFlg]
        return [0, '']

    def reg_handler(self, msg, protocol, reg_req_num, blist=None):
        self.cleanup()

        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']

        self.log.warning('protocol version: %s' % protocol)
        self.log.warning('self.config.VERSION: %s' % self.config.VERSION)
        if self.config.VERSION in sas_version_1_t and protocol not in sas_version_1_t:
            return [100, sas_version_1_t]

        if self.config.VERSION in sas_version_2_t:
            if self.config.enable_compatible_mode:
                if protocol not in sas_version_1_t + sas_version_2_t:
                    return [100, sas_version_1_t + sas_version_2_t]
            else:
                if protocol not in sas_version_2_t:
                    return [100, sas_version_2_t]

        self.version = protocol

        reg_req = msg
        # Required Parameters
        # userId
        if PAR_USER_ID not in reg_req:  # refer to 2.2 of rfc7542 for format
            self.log.warning('missing %s in registeration request' % PAR_USER_ID)
            return [102, PAR_USER_ID]
        # fccId
        if PAR_FCC_ID not in reg_req:
            self.log.warning('missing %s in registeration request' % PAR_FCC_ID)
            return [102, PAR_FCC_ID]
        elif len(reg_req[PAR_FCC_ID]) > 19:
            self.log.warning('length of %s exceeded 19 characters' % PAR_FCC_ID)
            return [103, PAR_FCC_ID]
        # cbsdSerialNumber
        if PAR_CBSD_SN not in reg_req:
            self.log.warning('missing %s in registeration request' % PAR_CBSD_SN)
            return [102, PAR_CBSD_SN]
        elif len(reg_req[PAR_CBSD_SN]) > 64:
            self.log.warning('length of %s exceeded 64 characters' % PAR_CBSD_SN)
            return [103, PAR_CBSD_SN]
        self.userID = reg_req[PAR_USER_ID]
        self.fccID = reg_req[PAR_FCC_ID]
        self.serialNum = reg_req[PAR_CBSD_SN]
        self.cbsdID = self.userID + '_' + self.fccID + '_' + self.serialNum
        self.config.getCbsdSpecificConfig(self.cbsdID)
        # REG-Conditional Parameters in TS1.1
        if self.version >= SAS_VERSION_TS_11:
            missed_param = self.check_REG_Conditional_param(reg_req)
            if missed_param is not None:
                self.log.warning('missing %s in registeration request' % missed_param)
                return [102, missed_param]

        # Optional/Conditional Parameters
        if PAR_CALL_SIGN in reg_req:
            self.callSign = reg_req[PAR_CALL_SIGN]
        if PAR_CBSD_CAT in reg_req:
            if reg_req[PAR_CBSD_CAT] != 'A' and reg_req[PAR_CBSD_CAT] != 'B':
                self.log.warning('invalid value of %s : %s' % (PAR_CBSD_CAT, reg_req[PAR_CBSD_CAT]))
                return [103, PAR_CBSD_CAT]
            self.category = reg_req[PAR_CBSD_CAT]
        if PAR_CBSD_INFO in reg_req:
            cbsdInfo = reg_req[PAR_CBSD_INFO]
            if PAR_INFO_VENDOR in cbsdInfo:
                self.cbsdInfo[PAR_INFO_VENDOR] = cbsdInfo[PAR_INFO_VENDOR]
            if PAR_INFO_MODEL in cbsdInfo:
                self.cbsdInfo[PAR_INFO_MODEL] = cbsdInfo[PAR_INFO_MODEL]
            if PAR_INFO_SV in cbsdInfo:
                self.cbsdInfo[PAR_INFO_SV] = cbsdInfo[PAR_INFO_SV]
            if PAR_INFO_HV in cbsdInfo:
                self.cbsdInfo[PAR_INFO_HV] = cbsdInfo[PAR_INFO_HV]
            if PAR_INFO_FV in cbsdInfo:
                self.cbsdInfo[PAR_INFO_FV] = cbsdInfo[PAR_INFO_FV]
        if PAR_AIR_IF in reg_req:
            airIf = reg_req[PAR_AIR_IF]
            if PAR_RADIO_TECH in airIf:
                self.airIf[PAR_RADIO_TECH] = airIf[PAR_RADIO_TECH]
            if PAR_RADIO_SPEC in airIf:  # supportedSpec is removed from TS1.1
                self.airIf[PAR_RADIO_SPEC] = airIf[PAR_RADIO_SPEC]
        if PAR_INSTALL_PAR in reg_req:
            instPar = reg_req[PAR_INSTALL_PAR]
            if PAR_LATITUDE in instPar:
                latitude = instPar[PAR_LATITUDE]
                if ((isinstance(latitude, int) or isinstance(latitude, float))
                        and -90.000000 <= latitude <= 90.000000):
                    self.instPar[PAR_LATITUDE] = instPar[PAR_LATITUDE]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_LATITUDE, latitude))
                    return [103, PAR_LATITUDE]
            if PAR_LONGITUDE in instPar:
                longitude = instPar[PAR_LONGITUDE]
                if ((isinstance(longitude, int) or isinstance(longitude, float))
                        and -180.000000 <= longitude <= 180.000000):
                    self.instPar[PAR_LONGITUDE] = instPar[PAR_LONGITUDE]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_LONGITUDE, longitude))
                    return [103, PAR_LONGITUDE]
            if PAR_HEIGHT in instPar:
                if isinstance(instPar[PAR_HEIGHT], int) or isinstance(instPar[PAR_HEIGHT], float):
                    self.instPar[PAR_HEIGHT] = instPar[PAR_HEIGHT]
            if PAR_HEIGHT_TYPE in instPar:
                height_type = instPar[PAR_HEIGHT_TYPE]
                if height_type not in heigt_type_t:
                    self.log.warning('invalid value of %s : %s' % (PAR_HEIGHT_TYPE, height_type))
                    return [103, PAR_HEIGHT_TYPE]
                self.instPar[PAR_HEIGHT_TYPE] = instPar[PAR_HEIGHT_TYPE]
            if PAR_HORI_ACCU in instPar:
                if isinstance(instPar[PAR_HORI_ACCU], int) or isinstance(instPar[PAR_HORI_ACCU], float):
                    if instPar[PAR_HORI_ACCU] >= 50:
                        self.log.warning('invalid value of %s : %s' % (PAR_HORI_ACCU, instPar[PAR_HORI_ACCU]))
                        return [103, PAR_HORI_ACCU]
                    self.instPar[PAR_HORI_ACCU] = instPar[PAR_HORI_ACCU]
            if PAR_VERT_ACCU in instPar:
                if isinstance(instPar[PAR_VERT_ACCU], int) or isinstance(instPar[PAR_VERT_ACCU], float):
                    if instPar[PAR_VERT_ACCU] >= 3:
                        self.log.warning('invalid value of %s : %s' % (PAR_VERT_ACCU, instPar[PAR_VERT_ACCU]))
                        return [103, PAR_HORI_ACCU]
                    self.instPar[PAR_VERT_ACCU] = instPar[PAR_VERT_ACCU]
            if PAR_INDOOR_DEP in instPar:
                if isinstance(instPar[PAR_INDOOR_DEP], bool):
                    self.instPar[PAR_INDOOR_DEP] = instPar[PAR_INDOOR_DEP]
            if PAR_ANT_AZIM in instPar:
                azim = instPar[PAR_ANT_AZIM]
                if isinstance(azim, int) and 0 <= azim <= 359:
                    self.instPar[PAR_ANT_AZIM] = instPar[PAR_ANT_AZIM]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_AZIM, azim))
                    return [103, PAR_ANT_AZIM]
            elif self.category == 'B':
                self.log.warning('missing %s in registeration request for Category B CBSD' % PAR_ANT_AZIM)
                return [102, PAR_ANT_AZIM]
            if PAR_ANT_DOWN_TILT in instPar:
                tilt = instPar[PAR_ANT_DOWN_TILT]
                if isinstance(tilt, int) and -90 <= tilt <= 90:
                    self.instPar[PAR_ANT_DOWN_TILT] = instPar[PAR_ANT_DOWN_TILT]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_DOWN_TILT, tilt))
                    return [103, PAR_ANT_DOWN_TILT]
            elif self.category == 'B':
                self.log.warning('missing %s in registeration request for Category B CBSD' % PAR_ANT_DOWN_TILT)
                return [102, PAR_ANT_DOWN_TILT]
            if PAR_ANT_GAIN in instPar:
                gain = instPar[PAR_ANT_GAIN]
                if isinstance(gain, int) and -127 <= gain <= 128:
                    self.instPar[PAR_ANT_GAIN] = instPar[PAR_ANT_GAIN]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_GAIN, gain))
                    return [103, PAR_ANT_GAIN]
            if PAR_ANT_EIRP in instPar:
                eirp = instPar[PAR_ANT_EIRP]
                if isinstance(eirp, int) and -127 <= eirp <= 47:
                    self.instPar[PAR_ANT_EIRP] = instPar[PAR_ANT_EIRP]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_EIRP, eirp))
                    return [103, PAR_ANT_EIRP]
            if PAR_ANT_BEAMW in instPar:
                beamw = instPar[PAR_ANT_BEAMW]
                if isinstance(beamw, int) and 0 <= beamw <= 360:
                    self.instPar[PAR_ANT_BEAMW] = instPar[PAR_ANT_BEAMW]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_BEAMW, beamw))
                    return [103, PAR_ANT_BEAMW]
            elif self.category == 'B':
                self.log.warning('missing %s in registeration request for Category B CBSD' % PAR_ANT_BEAMW)
                return [102, PAR_ANT_BEAMW]
            if PAR_ANT_MODEL in instPar:
                if len(instPar[PAR_ANT_MODEL]) > 128:
                    self.log.warning('length of %s exceeded 128 characters' % PAR_ANT_MODEL)
                    return [103, PAR_ANT_MODEL]
                self.instPar[PAR_ANT_MODEL] = instPar[PAR_ANT_MODEL]
        if PAR_MEAS_CAP in reg_req:
            if isinstance(reg_req[PAR_MEAS_CAP], list):
                meas_caps = meas_cap_t
                if self.version >= SAS_VERSION_TS_11:  # string comparison?
                    meas_caps = self.config.PAR_MEAS_CAP
                for meas_cap_item in reg_req[PAR_MEAS_CAP]:
                    # If the measCapability parameter contains only the empty string (""),
                    # the SAS assumes that the CBSD is not capable of reporting any measurements
                    if meas_cap_item == "":
                        pass
                    elif meas_cap_item in meas_caps:
                        self.meas.append(meas_cap_item)
                    elif meas_cap_item not in meas_cap_11_t:
                        self.log.warning('invalid value of %s : %s' % (PAR_MEAS_CAP, meas_cap_item))
                        return [103, PAR_MEAS_CAP]

        self.update_cbsd_grouping_config_from_req(REQ_REG, reg_req)

        # handle forced case
        if self.should_proceed_with_force_response_per_cbsd(self.cbsdID):
            if self.cbsdID not in self.config.cbsd_force_sas_method_sequences:
                self.config.cbsd_force_sas_method_sequences[self.cbsdID] = {}
            if self.cbsdID not in self.config.CBSD_RESPONSE_DATA_FORCE:
                self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID] = {}
            if 'DUMMY_GRANT' not in self.config.cbsd_force_sas_method_sequences[self.cbsdID]:
                self.config.cbsd_force_sas_method_sequences[self.cbsdID]['DUMMY_GRANT'] = 0
            if self.config.SAS_METHOD_FORCE == METHOD_REG:
                self.config.cbsd_force_sas_method_sequences[self.cbsdID]['DUMMY_GRANT'] += 1
                if self.cbsdID in self.config.CBSD_RESPONSE_CODE_FORCE and self.config.CBSD_RESPONSE_CODE_FORCE[
                        self.cbsdID] != 0:
                    if self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE or \
                            self.config.cbsd_force_sas_method_sequences[self.cbsdID][
                                'DUMMY_GRANT'] in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE[self.cbsdID]:
                        self.log.info('force the value of resonseCode to be %d' % self.config.CBSD_RESPONSE_CODE_FORCE[
                            self.cbsdID])
                        return [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID]]
            self.set_opState(STATE_REG)
            return [0, '']
        else:
            reg_req_num_str = str(reg_req_num)
            if self.cbsdID in self.config.cbsd_force_registration_method_group_sequences_error_code:
                if self.cbsdID not in self.config.CBSD_SAS_RESPONSE_MESSAGE:
                    self.config.CBSD_SAS_RESPONSE_MESSAGE[self.cbsdID] = ''
                if reg_req_num_str in self.config.cbsd_force_registration_method_group_sequences_error_code[
                        self.cbsdID]:
                    code = \
                        self.config.cbsd_force_registration_method_group_sequences_error_code[self.cbsdID][
                            reg_req_num_str][
                            0]
                    response_data = \
                        self.config.cbsd_force_registration_method_group_sequences_error_code[self.cbsdID][
                            reg_req_num_str][
                            1]
                    self.config.CBSD_SAS_RESPONSE_MESSAGE[self.cbsdID] = \
                        self.config.cbsd_force_registration_method_group_sequences_error_code[self.cbsdID][
                            reg_req_num_str][2]
                    self.log.info(
                        'force registration[{}] resonseCode to {} , responseData to {} , reponseMessage to {}'.format(
                            reg_req_num_str, code,
                            response_data,
                            self.config.CBSD_SAS_RESPONSE_MESSAGE[
                                self.cbsdID]))
                    if code == 0:
                        self.set_opState(STATE_REG)
                    return [code, response_data]
            if reg_req_num_str in self.config.force_registration_method_group_sequences_error_code:
                code = self.config.force_registration_method_group_sequences_error_code[reg_req_num_str][0]
                response_data = self.config.force_registration_method_group_sequences_error_code[reg_req_num_str][1]
                self.config.SAS_RESPONSE_MESSAGE = \
                    self.config.force_registration_method_group_sequences_error_code[reg_req_num_str][2]
                self.log.info(
                    'force registration[{}] resonseCode to {} , responseData to {} , reponseMessage to {}'.format(
                        reg_req_num_str, code,
                        response_data,
                        self.config.SAS_RESPONSE_MESSAGE))
                if code == 0:
                    self.set_opState(STATE_REG)
                return [code, response_data]
            if self.config.SAS_METHOD_FORCE == METHOD_REG:
                self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
                if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or self.config.force_sas_method_sequences[
                            'DUMMY_GRANT'] in self.config.SAS_METHOD_FORCE_SEQUENCE:
                        self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                        return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
            self.set_opState(STATE_REG)
            return [0, '']

    def reg_handler_cleanup(self):
        if (self.config.SAS_METHOD_FORCE == METHOD_REG
                and self.config.RESPONSE_CODE_FORCE == 0
                and self.excludePar is True):
            if self.get_opState() == STATE_REG:
                self.set_opState(STATE_UNREG)
                self.log.info(
                    'change CBSD state to Unregistered due to config.RESPONSE_CODE_FORCE==0 & '
                    'config.EXCLUDE_PARAM_FORCE=True')

    def dereg_handler(self, msg, protocol):
        dereg_req = msg
        if self.get_opState() != STATE_REG:
            self.log.warning('invalid deregistration request because cbsd is not in registered state')
            return [502, '']

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        # handle forced group case
        if self.cbsdID in self.config.cbsd_force_deregistration_method_group:
            if self.cbsdID not in self.config.cbsd_force_deregistration_method_group_sequences:
                self.config.cbsd_force_deregistration_method_group_sequences[self.cbsdID] = 0
            self.config.cbsd_force_deregistration_method_group_sequences[self.cbsdID] += 1
            self.log.info(
                'cbsd_force_deregistration_method_group[' + self.cbsdID + '] is %s' %
                self.config.cbsd_force_deregistration_method_group[self.cbsdID])
            dereg_req_num_str = self.config.cbsd_force_deregistration_method_group[self.cbsdID][0]
            code = self.config.cbsd_force_deregistration_method_group[self.cbsdID][1]
            data_force = self.config.cbsd_force_deregistration_method_group[self.cbsdID][2]
            self.log.info('force the deregistration %s value of resonseCode to be %s' % (dereg_req_num_str,
                                                                                         code) + ' for cbsdId = ' +
                          self.cbsdID)
            if int(dereg_req_num_str) == self.config.cbsd_force_deregistration_method_group_sequences[self.cbsdID]:
                self.log.info("find the sequence")
                return [int(code), data_force]
        if len(self.config.force_deregistration_method_group) != 0:
            self.log.info('force_deregistration_method_group is %s' % self.config.force_deregistration_method_group)
            dereg_req_num_str = self.config.force_deregistration_method_group[0]
            code = self.config.force_deregistration_method_group[1]
            data_force = self.config.force_deregistration_method_group[2]
            self.log.info('force the deregistration %s value of resonseCode to be %s' % (dereg_req_num_str, code))
            del self.config.force_deregistration_method_group[0:3]
            return [int(code), data_force]

        # handle forced case
        if self.should_proceed_with_force_response_per_cbsd(self.cbsdID):
            if self.cbsdID not in self.config.cbsd_force_sas_method_sequences:
                self.config.cbsd_force_sas_method_sequences[self.cbsdID] = {}
            if self.cbsdID not in self.config.CBSD_RESPONSE_DATA_FORCE:
                self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID] = {}
            if 'DUMMY_GRANT' not in self.config.cbsd_force_sas_method_sequences[self.cbsdID]:
                self.config.cbsd_force_sas_method_sequences[self.cbsdID]['DUMMY_GRANT'] = 0
            if self.config.SAS_METHOD_FORCE == METHOD_DEREG:
                self.config.cbsd_force_sas_method_sequences[self.cbsdID]['DUMMY_GRANT'] += 1
                if self.cbsdID in self.config.CBSD_RESPONSE_CODE_FORCE and self.config.CBSD_RESPONSE_CODE_FORCE[
                        self.cbsdID] != 0:
                    if self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE or \
                            self.config.cbsd_force_sas_method_sequences[self.cbsdID][
                                'DUMMY_GRANT'] in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE[self.cbsdID]:
                        self.log.info('force the value of resonseCode to be %d' % self.config.CBSD_RESPONSE_CODE_FORCE[
                            self.cbsdID])
                        return [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID]]
                # For test purpose, do not change CBSD state if CBSD_RESPONSE_CODE_FORCE[self.cbsdID]==0 &
                # CBSD_EXCLUDE_PARAM_FORCE[self.cbsdID]=<a
                # valid value>
                # 'cbsdId'/'response'/'responseCode' are the valid parameters in deregistration response
                # directly check if EXCLUDE_PARAM_FORCE equal to these valid parameters instead of checking
                # CBSD.__excludePar
                elif self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID] == 0:
                    if self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE or \
                            self.config.cbsd_force_sas_method_sequences[self.cbsdID][
                                'DUMMY_GRANT'] in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE[self.cbsdID]:
                        if self.config.CBSD_EXCLUDE_PARAM_FORCE[self.cbsdID] == PAR_CBSD_ID:
                            self.log.info(
                                'do not perform deregistration due to config.CBSD_RESPONSE_CODE_FORCE==0 & '
                                'config.CBSD_EXCLUDE_PARAM_FORCE=True')
                            return [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                    self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID]]
                        elif self.config.CBSD_EXCLUDE_PARAM_FORCE[self.cbsdID] == PAR_ERROR or \
                                self.config.CBSD_EXCLUDE_PARAM_FORCE[
                                    self.cbsdID] == PAR_ERR_CODE:
                            self.log.info(
                                'do not perform deregistration due to config.CBSD_RESPONSE_CODE_FORCE==0 & '
                                'config.CBSD_EXCLUDE_PARAM_FORCE=True')
                            return [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                    self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID]]
            for grant_id in self.grantList:
                grant = self.grantList[grant_id]
                if grant.get_opState() != GRANT_STATE_IDLE:
                    grant.stop()
            self.grantList.clear()
            self.set_opState(STATE_UNREG)
            return [0, '']
        else:
            if self.config.SAS_METHOD_FORCE == METHOD_DEREG:
                self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
                if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or self.config.force_sas_method_sequences[
                            'DUMMY_GRANT'] in self.config.SAS_METHOD_FORCE_SEQUENCE:
                        self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                        return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
                # For test purpose, do not change CBSD state if RESPONSE_CODE_FORCE==0 & EXCLUDE_PARAM_FORCE=<a valid
                # value>
                # 'cbsdId'/'response'/'responseCode' are the valid parameters in deregistration response
                # directly check if EXCLUDE_PARAM_FORCE equal to these valid parameters instead of checking
                # CBSD.__excludePar
                elif self.config.RESPONSE_CODE_FORCE == 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or self.config.force_sas_method_sequences[
                            'DUMMY_GRANT'] in self.config.SAS_METHOD_FORCE_SEQUENCE:
                        if self.config.EXCLUDE_PARAM_FORCE == PAR_CBSD_ID:
                            self.log.info(
                                'do not perform deregistration due to config.RESPONSE_CODE_FORCE==0 & '
                                'config.EXCLUDE_PARAM_FORCE=True')
                            return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
                        elif (self.config.EXCLUDE_PARAM_FORCE == PAR_ERROR or self.config.EXCLUDE_PARAM_FORCE ==
                              PAR_ERR_CODE):
                            self.log.info(
                                'do not perform deregistration due to config.RESPONSE_CODE_FORCE==0 & '
                                'config.EXCLUDE_PARAM_FORCE=True')
                            return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
            for grant_id in self.grantList:
                grant = self.grantList[grant_id]
                if grant.get_opState() != GRANT_STATE_IDLE:
                    grant.stop()
            self.grantList.clear()
            self.set_opState(STATE_UNREG)
            return [0, '']

    def inquiry_handler(self, msg, protocol, inquiry_req_num, cbsd_inquiry_req_num, channel_list, cbsd_channel_list,
                        is_spectrum_table_force_updated=False, is_cbsd_spectrum_table_force_updated=False):
        """
        This method parse spectrum inquiry request -- msg.
        channel_list is a dict which contains available channel data with follow form:
            channel_id, (low_frequency, high_frequency)
        This method returns a list. The first list item is 0 on success or none-zero on failure.
        The second item is a list which contains available channel data to match the inquiry spectrum
        on success or is a list which contains missing/invalid parameters on failure.
        The available channel data has the same form with channel_list.
        """
        if is_spectrum_table_force_updated:
            self.spectrum_channel_type_updated_by_hb0.clear()
            self.spectrum_max_eirp_updated_by_hb0.clear()
        else:
            for origin_channel in channel_list.keys():
                if channel_list[origin_channel][0][0] in self.spectrum_channel_type_updated_by_hb0:
                    channel_list[origin_channel][1] = self.spectrum_channel_type_updated_by_hb0[
                        channel_list[origin_channel][0][0]]
                if channel_list[origin_channel][0][0] in self.spectrum_max_eirp_updated_by_hb0:
                    if len(channel_list[origin_channel]) > 3:
                        channel_list[origin_channel][3] = self.spectrum_max_eirp_updated_by_hb0[
                            channel_list[origin_channel][0][0]]

        if (self.cbsdID in self.cbsd_spectrum_channel_type_updated_by_hb0 and self.cbsdID in
                self.cbsd_spectrum_max_eirp_updated_by_hb0):
            if is_cbsd_spectrum_table_force_updated:
                self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID].clear()
                self.cbsd_spectrum_max_eirp_updated_by_hb0[self.cbsdID].clear()
            else:
                for origin_channel in cbsd_channel_list.keys():
                    if cbsd_channel_list[origin_channel][0][0] in self.cbsd_spectrum_channel_type_updated_by_hb0[
                            self.cbsdID]:
                        cbsd_channel_list[origin_channel][1] = \
                            self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID][
                                cbsd_channel_list[origin_channel][0][0]]
                    if cbsd_channel_list[origin_channel][0][0] in self.cbsd_spectrum_max_eirp_updated_by_hb0[
                            self.cbsdID]:
                        if len(cbsd_channel_list[origin_channel]) > 3:
                            cbsd_channel_list[origin_channel][3] = \
                                self.cbsd_spectrum_max_eirp_updated_by_hb0[self.cbsdID][
                                    cbsd_channel_list[origin_channel][0][0]]
        else:
            if self.cbsdID not in self.cbsd_spectrum_channel_type_updated_by_hb0:
                self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID] = {}
            if self.cbsdID not in self.cbsd_spectrum_max_eirp_updated_by_hb0:
                self.cbsd_spectrum_max_eirp_updated_by_hb0[self.cbsdID] = {}

        featureDataExchangeConfigFlg = self.config.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, [], featureDataExchangeConfigFlg]

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version, featureDataExchangeConfigFlg]

        inq_req = msg
        # Required Parameters
        if PAR_INQ_SPECT not in inq_req:
            self.log.warning('missing %s parameter in inquiry spectrum request' % PAR_INQ_SPECT)
            return [102, [PAR_INQ_SPECT], featureDataExchangeConfigFlg]

        ret_list = []
        inq_list = inq_req[PAR_INQ_SPECT]
        if not isinstance(inq_list, list):
            self.log.warning('the type of %s in inquiry spectrum request should be list' % PAR_INQ_SPECT)
            return [103, [], featureDataExchangeConfigFlg]

        if self.cbsdID in self.config.cbsd_spectrum_table:
            for inq in inq_list:
                if isinstance(inq, dict):
                    if PAR_LOW_FREQ in inq and PAR_HIGH_FREQ in inq:
                        low = inq[PAR_LOW_FREQ]
                        high = inq[PAR_HIGH_FREQ]
                        matched = False
                        for ch_id in cbsd_channel_list.keys():
                            if (cbsd_channel_list[ch_id][0][0] <= low <= cbsd_channel_list[ch_id][0][1]
                                    and cbsd_channel_list[ch_id][0][0] <= high <= cbsd_channel_list[ch_id][0][1]):
                                if len(cbsd_channel_list[ch_id]) > 3:
                                    ret_list.append((ch_id, cbsd_channel_list[ch_id][0][0],
                                                     cbsd_channel_list[ch_id][0][1],
                                                     cbsd_channel_list[ch_id][1], cbsd_channel_list[ch_id][3]))
                                else:
                                    ret_list.append((ch_id, cbsd_channel_list[ch_id][0][0],
                                                     cbsd_channel_list[ch_id][0][1],
                                                     cbsd_channel_list[ch_id][1]))
                                matched = True
                                break

                        if not matched:
                            # join individaul channel
                            join_list = {}
                            key_list = list(cbsd_channel_list.keys())
                            key_list.sort()
                            for ch_id in key_list:
                                joined = False
                                for join_id in join_list.keys():
                                    if join_list[join_id][0][1] == cbsd_channel_list[ch_id][0][0]:
                                        join_list[join_id][0][1] = cbsd_channel_list[ch_id][0][1]
                                        join_list[join_id][1] = False
                                        joined = True
                                        break
                                    elif join_list[join_id][0][0] == cbsd_channel_list[ch_id][0][1]:
                                        join_list[join_id][0][0] = cbsd_channel_list[ch_id][0][0]
                                        join_list[join_id][1] = False
                                        joined = True
                                        break
                                if not joined:
                                    join_list.setdefault(ch_id, [[cbsd_channel_list[ch_id][0][0],
                                                                  cbsd_channel_list[ch_id][0][1]],
                                                                 cbsd_channel_list[ch_id][1]])
                            for ch_id in join_list.keys():
                                if (join_list[ch_id][0][0] <= low <= join_list[ch_id][0][1]
                                        and join_list[ch_id][0][0] <= high <= join_list[ch_id][0][1]):
                                    ret_list.append((ch_id, join_list[ch_id][0][0],
                                                     join_list[ch_id][0][1],
                                                     join_list[ch_id][1]))
                                    self.log.info('matched joined channel %s [%d - %d]'
                                                  % (ch_id, join_list[ch_id][0][0], join_list[ch_id][0][1]))
                                    matched = True
                                    break
        else:
            for inq in inq_list:
                if isinstance(inq, dict):
                    if PAR_LOW_FREQ in inq and PAR_HIGH_FREQ in inq:
                        low = inq[PAR_LOW_FREQ]
                        high = inq[PAR_HIGH_FREQ]
                        matched = False
                        for ch_id in channel_list.keys():
                            if (channel_list[ch_id][0][0] <= low <= channel_list[ch_id][0][1]
                                    and channel_list[ch_id][0][0] <= high <= channel_list[ch_id][0][1]):
                                if len(channel_list[ch_id]) > 3:
                                    ret_list.append((ch_id, channel_list[ch_id][0][0],
                                                     channel_list[ch_id][0][1],
                                                     channel_list[ch_id][1], channel_list[ch_id][3]))
                                else:
                                    ret_list.append((ch_id, channel_list[ch_id][0][0],
                                                     channel_list[ch_id][0][1],
                                                     channel_list[ch_id][1]))
                                matched = True
                                break

                        if not matched:
                            # join individaul channel
                            join_list = {}
                            key_list = list(channel_list.keys())
                            key_list.sort()
                            for ch_id in key_list:
                                joined = False
                                for join_id in join_list.keys():
                                    if join_list[join_id][0][1] == channel_list[ch_id][0][0]:
                                        join_list[join_id][0][1] = channel_list[ch_id][0][1]
                                        join_list[join_id][1] = False
                                        joined = True
                                        break
                                    elif join_list[join_id][0][0] == channel_list[ch_id][0][1]:
                                        join_list[join_id][0][0] = channel_list[ch_id][0][0]
                                        join_list[join_id][1] = False
                                        joined = True
                                        break
                                if not joined:
                                    join_list.setdefault(ch_id, [[channel_list[ch_id][0][0],
                                                                  channel_list[ch_id][0][1]],
                                                                 channel_list[ch_id][1]])
                            for ch_id in join_list.keys():
                                if (join_list[ch_id][0][0] <= low <= join_list[ch_id][0][1]
                                        and join_list[ch_id][0][0] <= high <= join_list[ch_id][0][1]):
                                    ret_list.append((ch_id, join_list[ch_id][0][0],
                                                     join_list[ch_id][0][1],
                                                     join_list[ch_id][1]))
                                    self.log.info('matched joined channel %s [%d - %d]'
                                                  % (ch_id, join_list[ch_id][0][0], join_list[ch_id][0][1]))
                                    matched = True
                                    break
        self.update_cbsd_grouping_config_from_req(REQ_INQUIRY, inq_req)
        # handle forced group case
        if self.cbsdID in self.config.cbsd_force_spectrumInquiry_method_group:
            cbsd_inquiry_req_num_str = str(cbsd_inquiry_req_num)
            self.log.info("cbsd_inquiry_req_num_str: " + cbsd_inquiry_req_num_str)
            if (self.cbsdID in self.config.cbsd_force_spectrumInquiry_method_group_sequences_error_code
                    and cbsd_inquiry_req_num_str in
                    self.config.cbsd_force_spectrumInquiry_method_group_sequences_error_code[self.cbsdID]):
                code = self.config.cbsd_force_spectrumInquiry_method_group_sequences_error_code[self.cbsdID][
                    cbsd_inquiry_req_num_str]
                self.log.info('force the %s value of resonseCode to be %s' % (cbsd_inquiry_req_num_str, code))
                force_data = ''
                if self.cbsdID in self.config.cbsd_force_spectrumInquiry_method_force_data:
                    self.log.info(
                        'cbsd_force_spectrumInquiry_method_group force_data to %s' %
                        self.config.cbsd_force_spectrumInquiry_method_force_data[
                            self.cbsdID])
                    force_data = self.config.cbsd_force_spectrumInquiry_method_force_data[self.cbsdID][0]
                return [int(code), force_data, featureDataExchangeConfigFlg]
        else:
            if len(self.config.force_spectrumInquiry_method_group) != 0:
                inquiry_req_num_str = str(inquiry_req_num)
                if inquiry_req_num_str in self.config.force_spectrumInquiry_method_group_sequences_error_code:
                    code = self.config.force_spectrumInquiry_method_group_sequences_error_code[inquiry_req_num_str]
                    self.log.info('force the %s value of resonseCode to be %s' % (inquiry_req_num_str, code))
                    self.log.info(
                        'force_spectrumInquiry_method force_data to %s' %
                        self.config.force_spectrumInquiry_method_force_data)
                    force_data = ''
                    if len(self.config.force_spectrumInquiry_method_force_data):
                        force_data = self.config.force_spectrumInquiry_method_force_data[0]
                        del self.config.force_spectrumInquiry_method_force_data[0:1]
                    return [int(code), force_data, featureDataExchangeConfigFlg]

        # handle forced case
        if len(ret_list) > 0:
            if self.should_proceed_with_force_response_per_cbsd(self.cbsdID):
                if self.cbsdID not in self.config.cbsd_force_sas_method_sequences:
                    self.config.cbsd_force_sas_method_sequences[self.cbsdID] = {}
                if self.cbsdID not in self.config.CBSD_RESPONSE_DATA_FORCE:
                    self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID] = {}
                if 'DUMMY_GRANT' not in self.config.cbsd_force_sas_method_sequences[self.cbsdID]:
                    self.config.cbsd_force_sas_method_sequences[self.cbsdID]['DUMMY_GRANT'] = 0
                if self.config.SAS_METHOD_FORCE == METHOD_INQUIRY:
                    self.config.cbsd_force_sas_method_sequences[self.cbsdID]['DUMMY_GRANT'] += 1
                    if self.cbsdID in self.config.CBSD_RESPONSE_CODE_FORCE:
                        if self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE or \
                                self.config.cbsd_force_sas_method_sequences[self.cbsdID][
                                    'DUMMY_GRANT'] in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE[self.cbsdID]:
                            self.log.info(
                                'force the value of resonseCode to be %d' % self.config.CBSD_RESPONSE_CODE_FORCE[
                                    self.cbsdID])
                            if self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID] == 0:
                                return [0, ret_list, featureDataExchangeConfigFlg]
                            else:
                                return [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                        [self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID]],
                                        featureDataExchangeConfigFlg]
            else:
                if self.config.SAS_METHOD_FORCE == METHOD_INQUIRY:
                    self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
                    if self.config.RESPONSE_CODE_FORCE is not None:
                        if self.config.SAS_METHOD_FORCE_SEQUENCE is None or self.config.force_sas_method_sequences[
                                'DUMMY_GRANT'] in self.config.SAS_METHOD_FORCE_SEQUENCE:
                            self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                            if self.config.RESPONSE_CODE_FORCE == 0:
                                return [0, ret_list, featureDataExchangeConfigFlg]
                            else:
                                return [self.config.RESPONSE_CODE_FORCE, [self.config.RESPONSE_DATA_FORCE],
                                        featureDataExchangeConfigFlg]

            # handle forced group case
            force_sas_method_group_key = 'DUMMY' + '_' + METHOD_INQUIRY
            self.log.info('force the value of grantIdForEachGroup to be %s' % force_sas_method_group_key)
            if force_sas_method_group_key not in self.config.force_sas_method_group_sequences:
                self.log.info('force_sas_method_group_key not in self.config.force_sas_method_group_sequences')
                self.config.force_sas_method_group_sequences[force_sas_method_group_key] = 0
            else:
                self.log.info('force_sas_method_group_key in self.config.force_sas_method_group_sequences')
                self.config.force_sas_method_group_sequences[force_sas_method_group_key] += 1
                if len(self.config.force_sas_method_group) != 0:
                    self.log.info('len of force_sas_method_group is %d' % len(self.config.force_sas_method_group))
                    for force_sas_method in self.config.force_sas_method_group:
                        force_sas_method_key = force_sas_method.split(',')
                        if (force_sas_method_key[0] == 'DUMMY') and force_sas_method_key[1] == METHOD_INQUIRY:
                            self.log.info('method is %s' % force_sas_method_key[1])
                            sequence = int(force_sas_method_key[2])
                            response_code = force_sas_method_key[3]
                            self.log.info('sequence is  %d' % sequence)
                            self.log.info('response_code is  %s' % response_code)
                            featureDataExchangeConfigFlg = -1
                            if len(force_sas_method_key) >= 5:
                                featureDataExchangeConfigFlg = int(force_sas_method_key[4])
                            reponse_force_data = 0
                            if len(force_sas_method_key) >= 6:
                                reponse_force_data = force_sas_method_key[5]
                                self.log.info('reponse_force_data is  %s' % reponse_force_data)
                            if self.config.force_sas_method_group_sequences[force_sas_method_group_key] == sequence:
                                self.log.info('find the sequence')
                                self.log.info('force the value of resonseCode to be %s' % response_code)
                                if int(response_code) == 0:
                                    return [int(response_code), ret_list, featureDataExchangeConfigFlg]
                                if reponse_force_data:
                                    return [int(response_code), reponse_force_data, featureDataExchangeConfigFlg]
                                return [int(response_code), '', featureDataExchangeConfigFlg]
            return [0, ret_list, featureDataExchangeConfigFlg]
        else:
            return [300, [], featureDataExchangeConfigFlg]

    def grant_handler(self, msg, protocol, channel_list, tlist, ppa_list):
        """
        This method parse spectrum grant request -- msg.
        channel_list is a dict which contains available channel data with follow form:
            channel_id, (low_frequency, high_frequency)
        This method returns a list. The first list item is 0 on success or none-zero on failure.
        The second item is grantId provided for approved grant or is error data on failure.
        """
        featureDataExchangeConfigFlg = -1
        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        grant_req = msg
        # Required Parameters
        if PAR_OP_PAR not in grant_req:
            self.log.warning('missing parameter %s in grant request' % PAR_OP_PAR)
            return [102, PAR_OP_PAR]
        op_par = grant_req[PAR_OP_PAR]
        if PAR_MAX_EIRP not in op_par:
            self.log.warning('missing parameter of %s in grant request' % PAR_MAX_EIRP)
            return [102, PAR_MAX_EIRP]
        if PAR_OP_FREQ_RANG not in op_par:
            self.log.warning('missing parameter of %s in grant request' % PAR_OP_FREQ_RANG)
            return [102, PAR_OP_FREQ_RANG]
        fre_range = op_par[PAR_OP_FREQ_RANG]
        if PAR_LOW_FREQ not in fre_range:
            self.log.warning('missing parameter of %s in grant request' % PAR_LOW_FREQ)
            return [102, PAR_LOW_FREQ]
        if PAR_HIGH_FREQ not in fre_range:
            self.log.warning('missing parameter of %s in grant request' % PAR_HIGH_FREQ)
            return [102, PAR_HIGH_FREQ]

        lowFreq = fre_range[PAR_LOW_FREQ]
        highFreq = fre_range[PAR_HIGH_FREQ]
        grantID = str(lowFreq) + '_' + str(highFreq)

        if self.config.RESPONSE_CODE_FORCE == "400" and self.config.SAS_METHOD_FORCE_GRANTIDS.find(grantID) == 0:
            return [400, '']

        if self.get_opState() == STATE_UNREG:
            self.log.warning('invalid grant request because cbsd is not registered yet')
            return [502, '']

        eirp = op_par[PAR_MAX_EIRP]
        low = fre_range[PAR_LOW_FREQ]
        high = fre_range[PAR_HIGH_FREQ]
        self.log.info('requested grant [%d - %d]' % (low, high))
        grant = Grant(self.config, self.log)
        grant_id = grant.get_ID(low, high)
        isPPA = False
        if self.cbsdID in ppa_list:
            isPPA = True
        if grant_id in self.grantList:
            if self.grantList[grant_id].get_opState() != GRANT_STATE_IDLE:
                if FEATURE_CAPABILITY_WF_GRANT_UPDATE not in self.sas_feature_capability_list:
                    # self.log.warning('conflict with an existing Grant of the same CBSD.')
                    # return 400 -- INTERFERENCE for this case following Lan's comments
                    self.log.warning('Requested operation parameters cause too much interference.')
                    return [401, grant_id]
        self.update_cbsd_grouping_config_from_req(RES_GRANT, grant_req)
        channelType = self.get_grant_channel_type_from_req(grant_req)
        grant_result = grant.grant(self.cbsdID, eirp, low, high, channel_list, tlist, isPPA, channelType)
        featureDataExchangeConfigFlg = -1
        if len(grant_result) == 3:
            featureDataExchangeConfigFlg = grant_result[2]
        if grant_result[0] == 0:
            if grant_id in self.grantList:
                self.grantList[grant_id].stop()
            self.grantList[grant_id] = grant
            return [0, grant.get_ID(), featureDataExchangeConfigFlg]
        else:
            if len(grant_result) == 3:
                return [grant_result[0], grant_result[1], featureDataExchangeConfigFlg]
            return [grant_result[0], grant_result[1], featureDataExchangeConfigFlg]

    def grant_handler_cleanup(self, grant_id):
        if (self.config.SAS_METHOD_FORCE == METHOD_GRANT
                and self.config.RESPONSE_CODE_FORCE == 0
                and self.excludePar is True):
            if grant_id in self.grantList:
                grant = self.grantList[grant_id]
                if grant.get_opState() != GRANT_STATE_IDLE:
                    grant.stop()
                    self.grantList.pop(grant_id)
                    self.log.info(
                        'stoped grant due to config.RESPONSE_CODE_FORCE==0 & config.EXCLUDE_PARAM_FORCE=True')

    def remove_from_grant_list(self, grant_id):
        if grant_id in self.grantList:
            grant = self.grantList[grant_id]
            if grant.get_opState() != GRANT_STATE_IDLE:
                grant.stop()
                self.grantList.pop(grant_id)
                self.log.info('stop a grant and remove it from grantList')

    def get_grantID_from_req(self, req):
        if PAR_GRANT_ID not in req:
            return None
        grantID = req[PAR_GRANT_ID]
        if grantID not in self.grantList:
            return None
        return grantID

    def grant_timeout_handler(self, grant_id):
        self.log.info('cbsd %s received grant expire event' % self.cbsdID)
        if grant_id in self.grantList:
            return self.grantList[grant_id].grant_timeout_handler()
        else:
            self.log.warning('could not find grant %s for grant expire event' % grant_id)
            return -1

    def transmit_timeout_handler(self, grant_id, slist=None, tlist=None):
        self.log.info('cbsd %s received transmit expire event' % self.cbsdID)
        if grant_id in self.grantList:
            return self.grantList[grant_id].transmit_timeout_handler(tlist, slist)
        else:
            self.log.warning('could not find grant %s for transmit expire event' % grant_id)
            return -1

    def heartbeat_handler(self, msg, protocol, blist=None, slist=None, tlist=None):
        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        hb_req = msg
        # Required Parameters
        if PAR_GRANT_ID not in hb_req:
            self.log.warning('missing %s parameter in heartbeat request' % PAR_GRANT_ID)
            return [102, PAR_GRANT_ID]

        if PAR_OP_STATE not in hb_req:
            self.log.warning('missing %s parameter in heartbeat request' % PAR_OP_STATE)
            return [102, PAR_OP_STATE]

        grantRenew = False
        if PAR_GRANT_RENEW in hb_req:
            if isinstance(hb_req[PAR_GRANT_RENEW], bool):
                if hb_req[PAR_GRANT_RENEW]:
                    grantRenew = True
                    self.log.debug('CBSD is asking for grant renewal')

        # blacklist check
        # move balcklist validation to grant.heartbeat
        # if blist != None:
        # if hb_req[PAR_CBSD_ID] in blist:
        # self.set_opState(STATE_UNREG)
        # self.log.info('cbsd %s is blacklisted, change op state to %s'
        # % (hb_req[PAR_CBSD_ID], STATE_UNREG))
        # return [101, '']

        grant_id = hb_req[PAR_GRANT_ID]
        if grant_id not in self.grantList:
            self.log.warning('invalid grantID %s in heartbeat request' % grant_id)
            return [103, PAR_GRANT_ID]

        self.update_cbsd_grouping_config_from_req(RES_HEARTBEAT, hb_req)
        grant = self.grantList[grant_id]
        result = grant.heartbeat(hb_req[PAR_OP_STATE], grantRenew, blist, tlist, slist)
        featureDataExchangeConfigFlg = -1
        if len(result) == 3:
            featureDataExchangeConfigFlg = result[2]
        if result[0] == 101:
            # we should change op state to unknown if CBSD is blacklisted
            # but the update of op state will stop all related Grants and
            # it will make grantId invalid in response builder
            # so the op state will change after response is built completely
            pass
        return [result[0], result[1], featureDataExchangeConfigFlg]

    def heartbeat_handler_cleanup(self, grant_id):
        if (self.config.SAS_METHOD_FORCE == METHOD_HEARTBEAT
                and self.config.RESPONSE_CODE_FORCE == 0
                and self.excludePar is True):
            if grant_id in self.grantList:
                grant = self.grantList[grant_id]
                if grant.get_opState() == GRANT_STATE_AUTHORIZED:
                    grant.set_opState(GRANT_STATE_GRANTED)
                    self.log.info(
                        'change grant state to granted due to config.RESPONSE_CODE_FORCE==0 & '
                        'config.EXCLUDE_PARAM_FORCE=True')

    def heartbeat_timeout_handler(self, grant_id):
        self.log.info('cbsd %s received hearbeat expire event' % self.cbsdID)
        if grant_id in self.grantList:
            return self.grantList[grant_id].heartbeat_timeout_handler()
        else:
            self.log.warning('could not find grant %s for heartbeat expire event' % grant_id)
            return -1

    def relinquish_handler(self, msg, protocol):
        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']

        featureDataExchangeConfigFlg = -1

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        rlq_req = msg
        # Required Parameters
        if PAR_GRANT_ID not in rlq_req:
            self.log.warning('missing %s parameter in relinquishment request' % PAR_GRANT_ID)
            return [102, PAR_GRANT_ID]

        grant_id = rlq_req[PAR_GRANT_ID]
        if grant_id not in self.grantList:
            self.log.warning('invalid grantID %s in relinquishment request' % grant_id)
            return [103, PAR_GRANT_ID]

        grant = self.grantList[grant_id]
        result = grant.relinquish()
        if len(result) == 3:
            featureDataExchangeConfigFlg = result[2]
        return [result[0], result[1], featureDataExchangeConfigFlg]

    def mng_cbsd_handler(self, msg):
        if not isinstance(msg, dict):
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']
        if REQ_MNG_CBSD not in msg:
            self.log.warning('%s is not included in msg body' % REQ_MNG_CBSD)
            return [102, '']

        data = {PAR_CBSD_ID: self.cbsdID, PAR_USER_ID: self.userID, PAR_FCC_ID: self.fccID, PAR_CBSD_SN: self.serialNum,
                PAR_OP_STATE: self.opState}
        if self.callSign is not None:
            data[PAR_CALL_SIGN] = self.callSign
        if self.category is not None:
            data[PAR_CBSD_CAT] = self.category
        if len(self.airIf) > 0:
            data[PAR_AIR_IF] = self.airIf
        if len(self.instPar) > 0:
            data[PAR_INSTALL_PAR] = self.instPar
        if len(self.cbsdInfo) > 0:
            data[PAR_CBSD_INFO] = self.cbsdInfo
        if len(self.groupingParam) > 0:
            data[PAR_GROUP_PARAM] = self.groupingParam
        if len(self.meas) > 0:
            data[PAR_MEAS_CAP] = self.meas
        grantList = []
        for grantId in self.grantList:
            grant = self.grantList[grantId]
            grantItem = {PAR_OP_STATE: grant.get_opState()}
            if grant.get_ID() is not None:
                grantItem[PAR_GRANT_ID] = grant.get_ID()
            if grant.get_maxEirp() is not None:
                grantItem[PAR_MAX_EIRP] = grant.get_maxEirp()
            if grant.get_lowFreq() is not None:
                grantItem[PAR_LOW_FREQ] = grant.get_lowFreq()
            if grant.get_lowFreq() is not None:
                grantItem[PAR_HIGH_FREQ] = grant.get_highFreq()
            if grant.get_channelType() == ChannelType.MIX:
                grantItem[PAR_CHN_TYPE] = CHN_TYPE_MIX
                self.log.info('Will set MIX in mng_cbsd_handler')
            elif grant.get_channelType() == ChannelType.PAL:
                grantItem[PAR_CHN_TYPE] = CHN_TYPE_PAL
                self.log.info('Will set PAL in mng_cbsd_handler')
            else:
                grantItem[PAR_CHN_TYPE] = CHN_TYPE_GAA
                self.log.info('Will set GAA in mng_cbsd_handler')
            if grant.get_grantExp() is not None:
                grantItem[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
            if grant.get_transmitExp() is not None:
                grantItem[PAR_TRANS_EXP] = grant.get_transmitExp().strftime("%Y-%m-%dT%H:%M:%SZ")
            grantList.append(grantItem)
        data[PAR_GRANTS] = grantList
        return [0, data]

    def get_grant_channel_type_from_req(self, req_msg):
        if PAR_CHN_TYPE in req_msg:
            channelType = req_msg[PAR_CHN_TYPE]
            if channelType.lower() == "mix":
                return ChannelType.MIX
            elif channelType.lower() == "pal":
                return ChannelType.PAL
            elif channelType.lower() == "gaa":
                return ChannelType.GAA
        return None

    def update_cbsd_grouping_config_from_req(self, req_type, req_msg):
        if PAR_GROUP_PARAM in req_msg and len(req_msg[PAR_GROUP_PARAM]) > 0:
            grouping_param = req_msg[PAR_GROUP_PARAM][0]
            if PAR_GROUP_TYPE in grouping_param:
                self.groupingConfig[PAR_GROUP_TYPE] = grouping_param[PAR_GROUP_TYPE]
            if PAR_GROUP_ID in grouping_param:
                self.groupingConfig[PAR_GROUP_ID] = grouping_param[PAR_GROUP_ID]
            if PAR_GROUP_INFO in grouping_param and PAR_ALLIANCE_INFO in grouping_param[PAR_GROUP_INFO]:
                cbrsAllianceConfig = {}
                cbrsAllianceInfo = grouping_param[PAR_GROUP_INFO][PAR_ALLIANCE_INFO]
                if PAR_CBRS_VERSION in cbrsAllianceInfo:
                    cbrsAllianceConfig[PAR_CBRS_VERSION] = cbrsAllianceInfo[PAR_CBRS_VERSION]
                if PAR_USED_EUTRA_TDD_CONFIG in cbrsAllianceInfo:
                    cbrsAllianceConfig[PAR_EUTRA_TDD_CONFIG] = cbrsAllianceInfo[PAR_USED_EUTRA_TDD_CONFIG]
                self.groupingConfig[PAR_ALLIANCE_CONFIG] = cbrsAllianceConfig
            self.groupingConfig[PAR_SUPPORTED_BY_SAS] = True

    def update_param_in_response(self, res_type, res_msg):
        if (self.config.SAS_METHOD_FORCE in sas_method_2_res_t
                and sas_method_2_res_t[self.config.SAS_METHOD_FORCE] == res_type):
            if self.config.EXCLUDE_PARAM_FORCE is not None:
                if dict_pop(res_msg, self.config.EXCLUDE_PARAM_FORCE):
                    self.excludePar = True
                    self.log.info('force to remove parameter %s from %s' % (self.config.EXCLUDE_PARAM_FORCE, res_type))
            if self.config.UPDATE_PARAM_FORCE is not None and self.config.UPDATE_PARAM_DATA_FORCE is not None:
                try:
                    pdata = json.loads(self.config.UPDATE_PARAM_DATA_FORCE, strict=False)
                    if dict_update(res_msg, self.config.UPDATE_PARAM_FORCE, pdata):
                        self.log.info(
                            'force to update parameter of %s with %s in %s' % (self.config.UPDATE_PARAM_FORCE, pdata,
                                                                               res_type))
                except TypeError:
                    self.log.warning('type error: invalid syntax of config.UPDATE_PARAM_DATA_FORCE')
                except ValueError:
                    self.log.warning('value error: invalid syntax of config.UPDATE_PARAM_DATA_FORCE')

    def update_param_in_response_for_cbsd(self, cbsdId, res_type, res_msg):
        if (self.config.SAS_METHOD_FORCE in sas_method_2_res_t
                and sas_method_2_res_t[self.config.SAS_METHOD_FORCE] == res_type):
            if cbsdId in self.config.CBSD_EXCLUDE_PARAM_FORCE:
                if dict_pop(res_msg, self.config.CBSD_EXCLUDE_PARAM_FORCE[cbsdId]):
                    self.excludePar = True
                    self.log.info(
                        'force to remove parameter %s from %s' % (self.config.CBSD_EXCLUDE_PARAM_FORCE[cbsdId],
                                                                  res_type))
            if cbsdId in self.config.CBSD_UPDATE_PARAM_FORCE and cbsdId in self.config.CBSD_UPDATE_PARAM_DATA_FORCE:
                try:
                    pdata = json.loads(self.config.CBSD_UPDATE_PARAM_DATA_FORCE[cbsdId], strict=False)
                    if dict_update(res_msg, self.config.CBSD_UPDATE_PARAM_FORCE[cbsdId], pdata):
                        self.log.info(
                            'force to update parameter of %s with %s in %s' % (
                                self.config.CBSD_UPDATE_PARAM_FORCE[cbsdId], pdata, res_type))
                except TypeError:
                    self.log.warning('type error: invalid syntax of config.CBSD_UPDATE_PARAM_DATA_FORCE')
                except ValueError:
                    self.log.warning('value error: invalid syntax of config.CBSD_UPDATE_PARAM_DATA_FORCE')

    def add_group_config_to_msg(self, res_type, res={}, **kw):
        MHZ = 1000000
        eutra_tdd_config_dict = {}
        group_config_dict = {}
        cbrs_alliance_config_dict = {}
        if self.config.VERSION not in sas_version_2_t or self.version not in sas_version_2_t:
            self.log.info(
                "SAS version[{}] or protocol version[{}] is not v2.0".format(self.config.VERSION, self.version))
            return res

        if PAR_GROUP_TYPE in self.groupingConfig:
            group_config_dict[PAR_GROUP_TYPE] = self.groupingConfig[PAR_GROUP_TYPE]
        if PAR_GROUP_ID in self.groupingConfig:
            group_config_dict[PAR_GROUP_ID] = self.groupingConfig[PAR_GROUP_ID]
        if PAR_SUPPORTED_BY_SAS in self.groupingConfig:
            group_config_dict[PAR_SUPPORTED_BY_SAS] = self.groupingConfig[PAR_SUPPORTED_BY_SAS]
        if PAR_ALLIANCE_CONFIG in self.groupingConfig:
            if PAR_CBRS_VERSION in self.groupingConfig[PAR_ALLIANCE_CONFIG]:
                cbrs_alliance_config_dict[PAR_CBRS_VERSION] =\
                    self.groupingConfig[PAR_ALLIANCE_CONFIG][PAR_CBRS_VERSION]
            if PAR_EUTRA_TDD_CONFIG in self.groupingConfig[PAR_ALLIANCE_CONFIG]:
                cbrs_alliance_config_dict[PAR_EUTRA_TDD_CONFIG] = self.groupingConfig[PAR_ALLIANCE_CONFIG][
                    PAR_EUTRA_TDD_CONFIG]

        def update_grouping_config():
            method_key = sas_res_2_method_t[res_type]
            if res_type == RES_REG or res_type == RES_INQUIRY:
                pass
            elif res_type == RES_GRANT or res_type == RES_HEARTBEAT:
                if 'grantID' in kw:
                    method_key = kw['grantID'] + '-' + method_key
                else:
                    self.log.warning('grantID not existed for res_type: %s' % res_type)
            else:
                self.log.warning('{} dont support groupingconfig'.format(method_key))
                return

            # read group_id group_type support_by_sas from config
            grouping_config_method_key = method_key
            if grouping_config_method_key not in self.cbsdSeq.force_method_groupingconfig_group_sequences:
                self.cbsdSeq.force_method_groupingconfig_group_sequences[grouping_config_method_key] = 0
            self.cbsdSeq.force_method_groupingconfig_group_sequences[grouping_config_method_key] += 1
            grouping_config_method_key = grouping_config_method_key + '_' + str(
                self.cbsdSeq.force_method_groupingconfig_group_sequences[grouping_config_method_key])
            self.log.info("groupconfig method_key: {}".format(grouping_config_method_key))
            if (grouping_config_method_key in
                    self.config.force_method_grouping_config_group_type_group_id_supported_by_sas):
                self.log.info("{} is in force_method_grouping_config_group_type_group_id_supported_by_sas".format(
                    grouping_config_method_key))
                group_config_value = self.config.force_method_grouping_config_group_type_group_id_supported_by_sas[
                    grouping_config_method_key]
                group_config_dict[PAR_GROUP_TYPE] = group_config_value[0]
                group_config_dict[PAR_GROUP_ID] = group_config_value[1]
                group_config_dict[PAR_SUPPORTED_BY_SAS] = group_config_value[2]
                # write back lasted groupconfig to self.groupingConfig for subsequent response
                self.groupingConfig[PAR_GROUP_TYPE] = group_config_value[0]
                self.groupingConfig[PAR_GROUP_ID] = group_config_value[1]
                self.groupingConfig[PAR_SUPPORTED_BY_SAS] = group_config_value[2]

            # read cbrsaVersion from config
            cbrsa_version_method_key = method_key
            if cbrsa_version_method_key not in self.cbsdSeq.force_method_cbrsa_version_group_sequences:
                self.cbsdSeq.force_method_cbrsa_version_group_sequences[cbrsa_version_method_key] = 0
            self.cbsdSeq.force_method_cbrsa_version_group_sequences[cbrsa_version_method_key] += 1
            cbrsa_version_method_key = cbrsa_version_method_key + '_' + str(
                self.cbsdSeq.force_method_cbrsa_version_group_sequences[cbrsa_version_method_key])
            self.log.info("cbrsa_version method_key: {}".format(cbrsa_version_method_key))
            if cbrsa_version_method_key in self.config.force_method_cbrsa_version_group:
                self.log.info('{} is in force_method_cbrsa_version_group'.format(cbrsa_version_method_key))
                cbrsaVersion_value = self.config.force_method_cbrsa_version_group[cbrsa_version_method_key]
                cbrs_alliance_config_dict[PAR_CBRS_VERSION] = cbrsaVersion_value
                # write back lasted cbrsaVersion to self.groupingConfig for subsequent response
                if PAR_ALLIANCE_CONFIG not in self.groupingConfig:
                    self.groupingConfig[PAR_ALLIANCE_CONFIG] = {}
                self.groupingConfig[PAR_ALLIANCE_CONFIG][PAR_CBRS_VERSION] = cbrsaVersion_value

            # read eutra_tdd_config from config
            eutra_tdd_config_method_key = method_key
            if eutra_tdd_config_method_key not in self.cbsdSeq.force_method_eutra_tdd_config_group_sequences:
                self.cbsdSeq.force_method_eutra_tdd_config_group_sequences[eutra_tdd_config_method_key] = 0
            self.cbsdSeq.force_method_eutra_tdd_config_group_sequences[eutra_tdd_config_method_key] += 1
            eutra_tdd_config_method_key = eutra_tdd_config_method_key + '_' + str(
                self.cbsdSeq.force_method_eutra_tdd_config_group_sequences[eutra_tdd_config_method_key])
            self.log.info("eutra_tdd_config method_key: {}".format(eutra_tdd_config_method_key))
            if eutra_tdd_config_method_key in self.config.force_method_eutra_tdd_config_group:
                self.log.info('{} is in force_method_eutra_tdd_config_group'.format(eutra_tdd_config_method_key))
                eutra_tdd_config_value = self.config.force_method_eutra_tdd_config_group[eutra_tdd_config_method_key]
                eutra_tdd_config = {PAR_SSF_CONFIG: int(eutra_tdd_config_value[1]),
                                    PAR_ULDL_CONFIG: int(eutra_tdd_config_value[0])}
                cbrs_alliance_config_dict[PAR_EUTRA_TDD_CONFIG] = eutra_tdd_config
                # write back lasted eutra_tdd_config to self.groupingConfig for subsequent response
                if PAR_ALLIANCE_CONFIG not in self.groupingConfig:
                    self.groupingConfig[PAR_ALLIANCE_CONFIG] = {}
                self.groupingConfig[PAR_ALLIANCE_CONFIG][PAR_EUTRA_TDD_CONFIG] = eutra_tdd_config

            # read frequency guidance from config
            frequency_guidance_method_key = method_key
            if frequency_guidance_method_key not in self.cbsdSeq.force_method_frequency_guidance_group_sequences:
                self.cbsdSeq.force_method_frequency_guidance_group_sequences[frequency_guidance_method_key] = 0
            self.cbsdSeq.force_method_frequency_guidance_group_sequences[frequency_guidance_method_key] += 1
            frequency_guidance_method_key = frequency_guidance_method_key + '_' + str(
                self.cbsdSeq.force_method_frequency_guidance_group_sequences[frequency_guidance_method_key])
            self.log.info("frequency_guidance_method_key: {}".format(frequency_guidance_method_key))
            if frequency_guidance_method_key in self.config.force_method_frequency_guidance_group:
                self.log.info("{} is in force_method_frequency_guidance_group".format(frequency_guidance_method_key))
                frequency_guidance_items = self.config.force_method_frequency_guidance_group[
                    frequency_guidance_method_key]
                if frequency_guidance_items is not None:
                    freq_guidance_list = []
                    for frequency_guidance_item in frequency_guidance_items:
                        freq_guidance = {}
                        freq_range = {}
                        freq_low_high = frequency_guidance_item.split('_')
                        if len(freq_low_high) >= 2:
                            freq_range[PAR_LOW_FREQ] = int(freq_low_high[0]) * MHZ
                            freq_range[PAR_HIGH_FREQ] = int(freq_low_high[1]) * MHZ
                            freq_guidance[PAR_FREQ_RANG] = freq_range
                            freq_guidance_list.append(freq_guidance)
                    cbrs_alliance_config_dict[PAR_FREQUENCY_GUIDENCE] = freq_guidance_list

        update_grouping_config()
        if self.config.cbsdFrequencyGuidance:
            cbsdFrequencyGuidance_items = self.config.cbsdFrequencyGuidance.split(";")
            for cbsdFrequencyGuidance_item in cbsdFrequencyGuidance_items:
                item = cbsdFrequencyGuidance_item.split(",")
                method = item[0]
                if sas_res_2_method_t[res_type] != method:
                    continue
                cbsdFrequencyGuidance_list = []
                for i in range(1, len(item)):
                    cbsdFrequencyGuidance = {}
                    fre_range = {}
                    single_freq = item[i].split("_")
                    fre_range[PAR_LOW_FREQ] = int(single_freq[0]) * MHZ
                    fre_range[PAR_HIGH_FREQ] = int(single_freq[1]) * MHZ
                    cbsdFrequencyGuidance[PAR_FREQ_RANG] = fre_range
                    cbsdFrequencyGuidance_list.append(cbsdFrequencyGuidance)
                cbrs_alliance_config_dict[PAR_FREQUENCY_GUIDENCE] = cbsdFrequencyGuidance_list

        if len(cbrs_alliance_config_dict) > 0:
            group_config_dict[PAR_ALLIANCE_CONFIG] = cbrs_alliance_config_dict
        if len(group_config_dict) > 0:
            res[PAR_GROUP_CONFIG] = group_config_dict
            self.log.debug("res[PAR_GROUP_CONFIG] is %s" % res[PAR_GROUP_CONFIG])

        if not self.config.SAS_METHOD_FORCE:
            self.log.info("self.config.SAS_METHOD_FORCE is not configured")
            return res

        if str.find(res_type, self.config.SAS_METHOD_FORCE) == -1:
            self.log.info(
                "SAS_METHOD_FORCE is not equal to res_type, self.config.SAS_METHOD_FORCE %s" %
                self.config.SAS_METHOD_FORCE)
            return res

        if len(self.config.eutraTddConfig) > 0:
            eutra_tdd_config = self.config.eutraTddConfig.split(",")
            eutra_tdd_config_dict[PAR_SSF_CONFIG] = int(eutra_tdd_config[1])
            eutra_tdd_config_dict[PAR_ULDL_CONFIG] = int(eutra_tdd_config[0])

        self.log.debug('eutra_tdd_config_dict is configured to %s' % eutra_tdd_config_dict)
        if len(self.config.eutraTddConfig_change_times) > 0:
            self.config.eutraTddConfig_change_times[0] -= 1
            if self.config.eutraTddConfig_change_times[0] <= 0:
                eutra_tdd_config_dict[PAR_SSF_CONFIG] = int(self.config.eutraTddConfig_change_times[2])
                eutra_tdd_config_dict[PAR_ULDL_CONFIG] = int(self.config.eutraTddConfig_change_times[1])
                self.log.debug('eutra_tdd_config_dict is reconfigured to %s' % eutra_tdd_config_dict)

        if len(eutra_tdd_config_dict) > 0:
            cbrs_alliance_config_dict[PAR_EUTRA_TDD_CONFIG] = eutra_tdd_config_dict

        if self.config.cbrsaVersion:
            if len(self.config.cbrsaVersion_change_times) > 0:
                self.config.cbrsaVersion_change_times[0] -= 1
                if self.config.cbrsaVersion_change_times[0] == 0:
                    self.config.cbrsaVersion = self.config.cbrsaVersion_change_times[1]
                    self.log.debug('self.config.cbrsaVersion is reconfigured to %s' % self.config.cbrsaVersion)
                if self.config.cbrsaVersion_change_times[0] < 0:
                    self.config.cbrsaVersion = "v2.0"

            cbrs_alliance_config_dict[PAR_CBRS_VERSION] = self.config.cbrsaVersion

        if len(cbrs_alliance_config_dict) > 0:
            group_config_dict[PAR_ALLIANCE_CONFIG] = cbrs_alliance_config_dict
        if len(group_config_dict) > 0:
            res[PAR_GROUP_CONFIG] = group_config_dict
            self.log.debug("res[PAR_GROUP_CONFIG] is %s" % res[PAR_GROUP_CONFIG])
        return res

    def update_capability_list(self, res_type, res={}, errorcode=0):
        if res_type not in [RES_REG, RES_FEATUREEXCHANGE]:
            return
        method_key = sas_res_2_method_t[res_type]
        if method_key not in self.cbsdSeq.force_sas_feature_capability_list_group_sequences:
            self.cbsdSeq.force_sas_feature_capability_list_group_sequences[method_key] = 0
        self.cbsdSeq.force_sas_feature_capability_list_group_sequences[method_key] += 1
        if self.config.VERSION not in sas_version_2_t or self.version not in sas_version_2_t:
            return
        method_key = method_key + '_' + str(self.cbsdSeq.force_sas_feature_capability_list_group_sequences[method_key])
        self.log.info('method key for force_sas_feature_capability_list_group_sequences is {}'.format(method_key))
        if method_key in self.config.force_sas_feature_capability_list_group:
            self.log.info('{} is in force_sas_feature_capability_list_group'.format(method_key))
            self.sas_feature_capability_list = self.config.force_sas_feature_capability_list_group[method_key]
        if errorcode == 0:
            if self.sas_feature_capability_list is not None:
                res[PAR_SAS_FEATURE_CAPABILITY_LIST] = self.sas_feature_capability_list
            else:
                if PAR_SAS_FEATURE_CAPABILITY_LIST in res:
                    res.pop(PAR_SAS_FEATURE_CAPABILITY_LIST)

    def response_builder(self, res_type=RES_HEARTBEAT, error=0, featureDataExchangeConfig=-1, *args, **kw):
        res = {}

        if res_type not in sas_res_t:
            self.log.warning('response type %s is not supported' % res_type)
            return res

        if error not in error_code_table:
            self.log.warning('error code %d is not supported' % error)
            return res

        if res_type == RES_REG:
            self.spectrum_channel_type_updated_by_hb0.clear()
            self.spectrum_max_eirp_updated_by_hb0.clear()
            if self.cbsdID not in self.cbsd_spectrum_channel_type_updated_by_hb0:
                self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID] = {}
            if self.cbsdID not in self.cbsd_spectrum_max_eirp_updated_by_hb0:
                self.cbsd_spectrum_max_eirp_updated_by_hb0[self.cbsdID] = {}
            if (self.cbsdID in self.cbsd_spectrum_channel_type_updated_by_hb0 and self.cbsdID in
                    self.cbsd_spectrum_max_eirp_updated_by_hb0):
                self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID].clear()
                self.cbsd_spectrum_max_eirp_updated_by_hb0[self.cbsdID].clear()
            if error == 0:
                # including cbsdId only if the responseCode indicates success
                res[PAR_CBSD_ID] = self.cbsdID
                if self.config.VERSION in sas_version_2_t and self.version in sas_version_2_t:
                    if self.config.sas_feature_capability_exist:
                        self.log.info('sas_feature_capability_exist, config to SAS_FEATURE_CAPABILITY_LIST')
                        self.config.sas_feature_capability_sequence -= 1
                        if self.config.sas_feature_capability_sequence == 0:
                            self.log.info('clear sequence is arrive, clear the sas sasfeaturecapabilitylist')
                            self.clearSasFeatureList = True
                            res[PAR_SAS_FEATURE_CAPABILITY_LIST] = []
                            self.sas_feature_capability_list = []
                        else:
                            if self.config.SAS_FEATURE_CAPABILITY_LIST is not None:
                                res[PAR_SAS_FEATURE_CAPABILITY_LIST] = self.config.SAS_FEATURE_CAPABILITY_LIST
                            self.sas_feature_capability_list = self.config.SAS_FEATURE_CAPABILITY_LIST
                    else:
                        self.config.sas_feature_capability_sequence -= 1
                        if self.config.sas_feature_capability_sequence == 0:
                            self.log.info('VERSION is 2.0, set sasfeaturecapabilitylist not exist')
                            self.clearSasFeatureList = True
                            self.sas_feature_capability_list = None
                        else:
                            if self.config.SAS_FEATURE_CAPABILITY_LIST is not None:
                                res[PAR_SAS_FEATURE_CAPABILITY_LIST] = self.config.SAS_FEATURE_CAPABILITY_LIST
                            self.sas_feature_capability_list = self.config.SAS_FEATURE_CAPABILITY_LIST
                if len(self.meas) > 0:
                    res[PAR_MEAS_REP] = self.meas
            if error == 100 or error == 102 or error == 103 or error == 106 or error == 200 or error == 0:
                reponseMessage = error_code_table[error]
                if self.cbsdID in self.config.CBSD_SAS_RESPONSE_MESSAGE:
                    if self.config.CBSD_SAS_RESPONSE_MESSAGE[self.cbsdID] != '':
                        reponseMessage = self.config.CBSD_SAS_RESPONSE_MESSAGE[self.cbsdID]
                else:
                    if self.config.SAS_RESPONSE_MESSAGE != '':
                        reponseMessage = self.config.SAS_RESPONSE_MESSAGE
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: reponseMessage, PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_DEREG:
            if error == 0:
                res[PAR_CBSD_ID] = self.cbsdID
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            if error == 100 or error == 102 or error == 103 or error == 106:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_INQUIRY:
            if error == 0:
                res[PAR_CBSD_ID] = self.cbsdID
                maxEirp = self.config.MAX_EIRP_FORCE
                sequence = self.config.SAS_METHOD_FORCE_SEQUENCE
                if maxEirp is not None:
                    if sequence is not None:
                        self.config.force_sas_method_sequences['DUMMY_INQUIRY'] += 1
                        self.log.info(f'Will set maxEirp {maxEirp} in spectrumInquiryResponse at sequence {sequence}')
                    else:
                        self.log.info(f'Will set maxEirp {maxEirp} in spectrumInquiryResponse always')
                ch_list = []
                for ch_item in args:
                    ch = {}
                    fre = {PAR_LOW_FREQ: ch_item[1], PAR_HIGH_FREQ: ch_item[2]}
                    ch[PAR_FREQ_RANG] = fre
                    if ch_item[3]:
                        ch[PAR_CHN_TYPE] = CHN_TYPE_PAL
                    else:
                        ch[PAR_CHN_TYPE] = CHN_TYPE_GAA
                    ch[PAR_RULE_APPL] = 'FCC Part 96'
                    if maxEirp is not None:
                        if sequence is None or str(self.config.force_sas_method_sequences['DUMMY_INQUIRY']) == str(
                                sequence[0]):
                            ch[PAR_MAX_EIRP] = maxEirp
                    elif len(self.config.force_max_eirp_group) != 0:
                        grantID = str(fre[PAR_LOW_FREQ]) + '_' + str(fre[PAR_HIGH_FREQ])
                        if grantID in self.config.force_max_eirp_group_sequences:
                            self.config.force_max_eirp_group_sequences[grantID] += 1
                        else:
                            self.config.force_max_eirp_group_sequences[grantID] = 0
                        for force_max_eirp in self.config.force_max_eirp_group:
                            force_max_eirp_keys = force_max_eirp.split(',')
                            if force_max_eirp_keys[0] == grantID:
                                self.log.info('find the grantid, grant id is {}'.format(force_max_eirp_keys[0]))
                                sequence = int(force_max_eirp_keys[1])
                                if self.config.force_max_eirp_group_sequences[grantID] == sequence:
                                    self.log.info(f'find the sequence, sequence is {force_max_eirp_keys[1]}')
                                    self.log.info(f'force the value of maxEirp to be {force_max_eirp_keys[2]}')
                                    try:
                                        ch[PAR_MAX_EIRP] = int(force_max_eirp_keys[2])
                                    except Exception:
                                        ch[PAR_MAX_EIRP] = float(force_max_eirp_keys[2])
                    elif len(ch_item) > 4:
                        ch[PAR_MAX_EIRP] = ch_item[4]
                    spectrum_key = int(fre[PAR_LOW_FREQ]) // 1000000
                    if self.config.VERSION not in sas_version_2_t:
                        spectrum_table_key = str(spectrum_key) + '-10'
                    else:
                        spectrum_table_key = str(spectrum_key) + '-5'
                    if self.cbsdID in self.config.cbsd_spectrum_table:
                        if ch[PAR_CHN_TYPE] == CHN_TYPE_GAA or (ch[PAR_CHN_TYPE] == CHN_TYPE_PAL and (
                                self.config.cbsd_spectrum_table[self.cbsdID][spectrum_table_key][2] == self.cbsdID or
                                self.config.cbsd_spectrum_table[self.cbsdID][spectrum_table_key][2] == 'DUMMYCBSD' or
                                self.config.cbsd_spectrum_table[self.cbsdID][spectrum_table_key][1] is True or
                                self.config.cbsd_force_spectrumInquery_response_group[self.cbsdID][spectrum_table_key][
                                    1] is True)):
                            ch_list.append(ch)
                    else:
                        if ch[PAR_CHN_TYPE] == CHN_TYPE_GAA or (ch[PAR_CHN_TYPE] == CHN_TYPE_PAL and (
                                self.config.spectrum_table[spectrum_table_key][2] == self.cbsdID or
                                self.config.spectrum_table[spectrum_table_key][
                                    2] == 'DUMMYCBSD' or self.config.spectrum_table[spectrum_table_key][1] is True or
                                self.config.force_spectrumInquery_response_group[spectrum_table_key][1] is True)):
                            ch_list.append(ch)
                res[PAR_AVAIL_CHN] = ch_list

                if self.cbsdID not in self.config.cbsd_latest_spectrum_inquiry_available_channels:
                    self.config.cbsd_latest_spectrum_inquiry_available_channels[self.cbsdID] = {}
                self.config.cbsd_latest_spectrum_inquiry_available_channels[self.cbsdID] = ch_list

                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            else:
                # if len(args) > 0:
                if error == 100 or error == 102 or error == 103 or error == 106:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
                else:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_GRANT:
            if self.cbsdID is not None and self.cbsdID != '':
                res[PAR_CBSD_ID] = self.cbsdID
            if error == 0:
                res[PAR_GRANT_ID] = kw['grantID']
                if len(self.meas) > 0:
                    res[PAR_MEAS_REP] = self.meas
                if kw['grantID'] in self.grantList:
                    grant = self.grantList[kw['grantID']]
                    res[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
                res[PAR_HB_DUR] = self.config.CBSD_HEART_BEAT_DUR[
                    self.cbsdID] if self.cbsdID in self.config.CBSD_HEART_BEAT_DUR else self.config.HEART_BEAT_DUR
                spectrum_key = int(grant.get_lowFreq()) // 1000000
                if self.config.VERSION not in sas_version_2_t:
                    spectrum_table_key = str(spectrum_key) + '-10'
                else:
                    spectrum_table_key = str(spectrum_key) + '-5'

                if grant.get_channelType() == ChannelType.MIX:
                    res[PAR_CHN_TYPE] = CHN_TYPE_MIX
                if self.cbsdID in self.config.cbsd_latest_spectrum_inquiry_available_channels:
                    if (grant.get_channelType() == ChannelType.PAL or self.isMatchedPalChannelType(
                            str(grant.get_lowFreq()),
                            self.config.cbsd_latest_spectrum_inquiry_available_channels[
                                self.cbsdID])):
                        res[PAR_CHN_TYPE] = CHN_TYPE_PAL
                    elif grant.get_channelType() == ChannelType.GAA:
                        res[PAR_CHN_TYPE] = CHN_TYPE_GAA
                else:
                    if self.cbsdID in self.config.cbsd_spectrum_table:
                        if (grant.get_channelType() == ChannelType.PAL and
                            self.config.cbsd_spectrum_table[self.cbsdID][spectrum_table_key][
                                2] == 'DUMMYCBSD') or self.config.cbsd_spectrum_table[self.cbsdID][spectrum_table_key][
                            2] == self.cbsdID or \
                                self.config.cbsd_spectrum_table[self.cbsdID][spectrum_table_key][1] is True:
                            res[PAR_CHN_TYPE] = CHN_TYPE_PAL
                        elif grant.get_channelType() == ChannelType.GAA:
                            res[PAR_CHN_TYPE] = CHN_TYPE_GAA
                    else:
                        if (grant.get_channelType() == ChannelType.PAL and
                            self.config.spectrum_table[spectrum_table_key][2] == 'DUMMYCBSD') or \
                                self.config.spectrum_table[spectrum_table_key][2] == self.cbsdID or \
                                self.config.spectrum_table[spectrum_table_key][
                                    1] is True:
                            res[PAR_CHN_TYPE] = CHN_TYPE_PAL
                        elif grant.get_channelType() == ChannelType.GAA:
                            res[PAR_CHN_TYPE] = CHN_TYPE_GAA

                if int(grant.get_lowFreq()) in self.spectrum_channel_type_updated_by_hb0:
                    channelType = self.spectrum_channel_type_updated_by_hb0[int(grant.get_lowFreq())]
                    if channelType == ChannelType.MIX:
                        res[PAR_CHN_TYPE] = CHN_TYPE_MIX
                    elif channelType == ChannelType.PAL:
                        res[PAR_CHN_TYPE] = CHN_TYPE_PAL
                    else:
                        res[PAR_CHN_TYPE] = CHN_TYPE_GAA
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}

                if self.cbsdID in self.cbsd_spectrum_channel_type_updated_by_hb0:
                    if int(grant.get_lowFreq()) in self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID]:
                        channelType = self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID][
                            int(grant.get_lowFreq())]
                        if channelType == ChannelType.MIX:
                            res[PAR_CHN_TYPE] = CHN_TYPE_MIX
                        elif channelType == ChannelType.PAL:
                            res[PAR_CHN_TYPE] = CHN_TYPE_PAL
                        else:
                            res[PAR_CHN_TYPE] = CHN_TYPE_GAA
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            else:
                if error == 100 or error == 102 or error == 103 or error == 106 or error == 401:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
                elif (error == 400 or error == 402) and self.config.GRANT_DISAPPROVE_REASSIGN is True:
                    if len(self.config.operationParamsForGrant) != 0:
                        operationParam = self.config.operationParamsForGrant.pop(0)
                        operationParamForGrant_keys = operationParam.split(',')
                        freRange = {PAR_LOW_FREQ: int(operationParamForGrant_keys[1]),
                                    PAR_HIGH_FREQ: int(operationParamForGrant_keys[2])}
                        opPar = {PAR_MAX_EIRP: int(operationParamForGrant_keys[0]), PAR_OP_FREQ_RANG: freRange}
                        res[PAR_OP_PAR] = opPar
                        res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
                    else:
                        freRange = {PAR_LOW_FREQ: self.config.FREQ_LOW_REASSIGN,
                                    PAR_HIGH_FREQ: self.config.FREQ_HIGH_REASSIGN}
                        opPar = {PAR_MAX_EIRP: self.config.MAX_EIRP_REASSIGN, PAR_OP_FREQ_RANG: freRange}
                        res[PAR_OP_PAR] = opPar
                        res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
                else:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_HEARTBEAT:
            if self.cbsdID is not None and self.cbsdID != '':
                res[PAR_CBSD_ID] = self.cbsdID
            if 'grantID' in kw:
                if kw['grantID'] is not None:
                    res[PAR_GRANT_ID] = kw['grantID']
                    if kw['grantID'] in self.grantList:
                        grant = self.grantList[kw['grantID']]
                        # transmitExpireTime is required parameter
                        transmitExp = grant.get_transmitExp_ex()
                        if transmitExp is not None:
                            res[PAR_TRANS_EXP] = transmitExp.strftime("%Y-%m-%dT%H:%M:%SZ")
            # use a past time as grantExpireTime if we could not get a valid value
            if PAR_TRANS_EXP not in res:
                exp = datetime.datetime.utcnow()
                res[PAR_TRANS_EXP] = exp.strftime("%Y-%m-%dT%H:%M:%SZ")
            if error == 0:
                if len(self.meas) > 0:
                    res[PAR_MEAS_REP] = self.meas
                grant = self.grantList[kw['grantID']]
                # res[PAR_TRANS_EXP] = grant.get_transmitExp().strftime("%Y-%m-%dT%H:%M:%SZ")
                # grantExpireTime is required if the responseCode parameter indicates SUCCESS or SUSPENDED_GRANT
                # and the grantRenew parameter was included and set to True in the corresponding HeartbeatRequest
                # object. This parameter may be included at other times by SAS choice.
                # As per EI requirement, this parameter is included regardless grantRenew is present or not
                # if grant.grantRenew() is True:
                # grantExpireTime may be included if grant is suspened
                # Here we just include grantExpireTime if the request is approved
                # res[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
                res[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")

                heartbeat_grant_id = kw['grantID']
                if heartbeat_grant_id not in self.recommend_operationParam_heartbeat0_sequences:
                    self.recommend_operationParam_heartbeat0_sequences[heartbeat_grant_id] = 0
                self.recommend_operationParam_heartbeat0_sequences[heartbeat_grant_id] += 1
                recommend_operationParam_heartbeat0_key = heartbeat_grant_id + '_' + str(
                    self.recommend_operationParam_heartbeat0_sequences[heartbeat_grant_id])
                self.log.info(
                    'recommend_operationParam_heartbeat0_key: {}]'.format(recommend_operationParam_heartbeat0_key))
                self.log.info('self.config.recommend_operationParam_heartbeat0: {}'.format(
                    self.config.recommend_operationParam_heartbeat0))
                if recommend_operationParam_heartbeat0_key in self.config.recommend_operationParam_heartbeat0:
                    self.log.info('recommend_operationParam_heartbeat0_key hit')
                    operationParam = {}
                    operationParam_group_value = self.config.recommend_operationParam_heartbeat0[
                        recommend_operationParam_heartbeat0_key]
                    operationParam[PAR_MAX_EIRP] = operationParam_group_value[0]
                    operationFrequencyRange = {PAR_LOW_FREQ: operationParam_group_value[1],
                                               PAR_HIGH_FREQ: operationParam_group_value[2]}
                    operationParam[PAR_OP_FREQ_RANG] = operationFrequencyRange
                    res[PAR_OP_PAR] = operationParam
                    heartbeat_low_high_freq = heartbeat_grant_id.split("_")
                    low_freq = int(heartbeat_low_high_freq[0])
                    high_freq = int(heartbeat_low_high_freq[1])
                    for spectrum_value in range(low_freq, high_freq, 5 * 1000000):
                        self.spectrum_max_eirp_updated_by_hb0[spectrum_value] = operationParam_group_value[0]
                        if self.cbsdID in self.cbsd_spectrum_max_eirp_updated_by_hb0:
                            if spectrum_value in self.cbsd_spectrum_max_eirp_updated_by_hb0[self.cbsdID]:
                                self.spectrum_max_eirp_updated_by_hb0[self.cbsdID][spectrum_value] = \
                                    operationParam_group_value[0]

                if heartbeat_grant_id not in self.force_heartbert_channeltype_group_sequences:
                    self.force_heartbert_channeltype_group_sequences[heartbeat_grant_id] = 0
                self.force_heartbert_channeltype_group_sequences[heartbeat_grant_id] += 1
                force_heartbeat_channeltype_group_key = heartbeat_grant_id + '_' + str(
                    self.force_heartbert_channeltype_group_sequences[heartbeat_grant_id])
                if force_heartbeat_channeltype_group_key in self.config.force_heartbeat_channeltype_group:
                    self.log.info('force_heartbeat_channeltype_group_key hit')
                    channelType_group_value = self.config.force_heartbeat_channeltype_group[
                        force_heartbeat_channeltype_group_key]
                    assert channelType_group_value != ChannelType.MIX, "MIX is not support for heartbeat0"
                    if channelType_group_value == ChannelType.MIX:
                        res[PAR_CHN_TYPE] = 'MIX'
                    elif channelType_group_value == ChannelType.PAL:
                        res[PAR_CHN_TYPE] = 'PAL'
                    else:
                        res[PAR_CHN_TYPE] = 'GAA'
                    heartbeat_low_high_freq = heartbeat_grant_id.split("_")
                    low_freq = int(heartbeat_low_high_freq[0])
                    high_freq = int(heartbeat_low_high_freq[1])
                    for spectrum_value in range(low_freq, high_freq, 5 * 1000000):
                        self.spectrum_channel_type_updated_by_hb0[spectrum_value] = channelType_group_value
                        if self.cbsdID in self.cbsd_spectrum_channel_type_updated_by_hb0:
                            self.cbsd_spectrum_channel_type_updated_by_hb0[self.cbsdID][
                                spectrum_value] = channelType_group_value

            if error == 501:
                grant = self.grantList[kw['grantID']]
                if grant.grantRenew:
                    res[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
            if ((error == 500 and self.config.TERMINATED_REASSIGN is True)
                    or (error == 501 and self.config.SUSPENDED_REASSIGN is True)):
                # add new operational parameters
                if len(self.config.operationParamsForHeartbeat) != 0:
                    operationParam = self.config.operationParamsForHeartbeat.pop(0)
                    operationParamsForHeartbeat_keys = operationParam.split(',')
                    opPar = {}
                    freRange = {}
                    if (operationParamsForHeartbeat_keys[0] is not None and operationParamsForHeartbeat_keys[0] != ''
                            and
                            operationParamsForHeartbeat_keys[1] is not None and operationParamsForHeartbeat_keys[
                                1] != ''
                            and
                            operationParamsForHeartbeat_keys[2] is not None and operationParamsForHeartbeat_keys[
                                2] != ''):
                        freRange[PAR_LOW_FREQ] = int(operationParamsForHeartbeat_keys[1])
                        freRange[PAR_HIGH_FREQ] = int(operationParamsForHeartbeat_keys[2])
                        try:
                            opPar[PAR_MAX_EIRP] = int(operationParamsForHeartbeat_keys[0])
                        except Exception:
                            opPar[PAR_MAX_EIRP] = float(operationParamsForHeartbeat_keys[0])
                        opPar[PAR_OP_FREQ_RANG] = freRange
                        res[PAR_OP_PAR] = opPar
                else:
                    opPar = {}
                    freRange = {PAR_LOW_FREQ: self.config.FREQ_LOW_REASSIGN,
                                PAR_HIGH_FREQ: self.config.FREQ_HIGH_REASSIGN}
                    opPar[PAR_MAX_EIRP] = self.config.MAX_EIRP_REASSIGN
                    opPar[PAR_OP_FREQ_RANG] = freRange
                    res[PAR_OP_PAR] = opPar
            if error == 100 or error == 102 or error == 103 or error == 106:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_RELINQUISH:
            res[PAR_CBSD_ID] = self.cbsdID
            if 'grantID' in kw:
                grant_id_relinquish = kw['grantID']
                if kw['grantID'] is not None:
                    res[PAR_GRANT_ID] = grant_id_relinquish
            if error == 100 or error == 102 or error == 103 or error == 106:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_FEATUREDATA:
            if error == 0:
                if self.version >= SAS_VERSION_TS_20:
                    sasFeatureInfo = []
                    sasFeaInfo = {}
                    for cbsdFeaInfo in self.cbsdFeatureInfo:
                        sasFeaInfo[PAR_FEA_ID] = cbsdFeaInfo[PAR_FEA_ID]
                        sasFeatureInfo.append(sasFeaInfo)

                if self.config.ALL_RESPONSE_SASFEATUREINFO_FORCE != 0:
                    res[PAR_SAS_FEA_INFO] = sasFeatureInfo

                res[PAR_CBSD_ID] = self.cbsdID
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            if error == 100 or error == 102 or error == 103 or error == 106:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_FEATUREEXCHANGE:
            if error == 0:
                res[PAR_CBSD_ID] = self.cbsdID
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            if error == 100 or error == 102 or error == 103 or error == 106:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        else:
            # TBD
            self.log.warning('the response type %s is not supported yet' % res_type)

        self.update_capability_list(res_type, res, error)
        self.add_group_config_to_msg(res_type, res, **kw)
        self.update_param_in_response(res_type, res)
        self.update_param_in_response_for_cbsd(self.cbsdID, res_type, res)
        if res_type == RES_INQUIRY or res_type == RES_GRANT or res_type == RES_HEARTBEAT or res_type == RES_RELINQUISH:
            if featureDataExchangeConfig == 0:
                res[PAR_FEA_DATA_EXCHANGE_CONFIG] = False
            elif featureDataExchangeConfig == 1:
                res[PAR_FEA_DATA_EXCHANGE_CONFIG] = True

            if self.config.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE == 0:
                res[PAR_FEA_DATA_EXCHANGE_CONFIG] = False
            elif self.config.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE == 1:
                res[PAR_FEA_DATA_EXCHANGE_CONFIG] = True

            def update_feature_capability_exchange_to_res():
                method_key = sas_res_2_method_t[res_type]
                if res_type == RES_INQUIRY:
                    pass
                else:
                    if 'grantID' not in kw or kw['grantID'] is None:
                        return
                    method_key = kw['grantID'] + '-' + sas_res_2_method_t[res_type]
                if method_key not in self.force_method_feature_exchange_trigger_sequences:
                    self.force_method_feature_exchange_trigger_sequences[method_key] = 0
                self.force_method_feature_exchange_trigger_sequences[method_key] += 1
                if method_key in self.config.force_method_feature_exchange_trigger_group:
                    if self.force_method_feature_exchange_trigger_sequences[method_key] in \
                            self.config.force_method_feature_exchange_trigger_group[
                                method_key]:
                        self.log.info(
                            '{} in self.config.force_method_feature_exchange_trigger_group'.format(method_key))
                        res[PAR_FEATURE_CAPABILITY_EXCHANGE_TRIGGER] = True

            update_feature_capability_exchange_to_res()
        if self.config.hex_code:
            res[PAR_ERROR][PAR_ERR_CODE] = self.config.hex_code
            self.config.hex_code = 0

        return res

    def get_state(self):
        return self.opState

    def get_cbsdID(self, msg=None, msg_type=REQ_REG):
        if msg is not None:
            if REQ_REG == msg_type:
                reg_req = msg
                if ((PAR_USER_ID in reg_req) and
                        (PAR_FCC_ID in reg_req) and
                        (PAR_CBSD_SN in reg_req)):
                    return reg_req[PAR_USER_ID] + '_' + reg_req[PAR_FCC_ID] + '_' + reg_req[PAR_CBSD_SN]
            if REQ_INQUIRY == msg_type:
                inquiry_req = msg
                if PAR_CBSD_ID in inquiry_req:
                    return inquiry_req[PAR_CBSD_ID]
            if REQ_GRANT == msg_type:
                grant_req = msg
                if PAR_CBSD_ID in grant_req:
                    return grant_req[PAR_CBSD_ID]
            if REQ_HEARTBEAT == msg_type:
                hb_req = msg
                if PAR_CBSD_ID in hb_req:
                    return hb_req[PAR_CBSD_ID]
            if REQ_RELINQUISH == msg_type:
                relq_req = msg
                if PAR_CBSD_ID in relq_req:
                    return relq_req[PAR_CBSD_ID]
            if REQ_DEREG == msg_type:
                dereg_req = msg
                if PAR_CBSD_ID in dereg_req:
                    return dereg_req[PAR_CBSD_ID]
            if REQ_FEATUREDATA == msg_type:
                feadata_req = msg
                if PAR_CBSD_ID in feadata_req:
                    return feadata_req[PAR_CBSD_ID]
            if REQ_FEATUREEXCHANGE == msg_type:
                fea_exchange_req = msg
                if PAR_CBSD_ID in fea_exchange_req:
                    return fea_exchange_req[PAR_CBSD_ID]
        return self.cbsdID

    def get_excludePar(self):
        return self.excludePar

    def set_blocked_request_sequence(self, grantID):
        if grantID not in self.grantBlockedRequestSequenceList:
            self.grantBlockedRequestSequenceList[grantID] = 0
        self.grantBlockedRequestSequenceList[grantID] += 1

    def get_blocked_request_sequence(self, grantID):
        return self.grantBlockedRequestSequenceList[grantID]

    def set_cbsdSeq(self, cbsdSeq):
        self.cbsdSeq = cbsdSeq

    def get_cbsSeq(self):
        return self.cbsdSeq

    def get_grant_field_by_grantid(self, grantID, field):
        if grantID not in self.grantList:
            return None
        if field == PAR_GRANT_EXPIRE_TIME:
            return self.grantList[grantID].get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
