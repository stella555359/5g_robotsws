#!/usr/bin/env python
# -*- coding: utf-8 -*-


import time
import datetime
import json
import thrading
from httpBase.HttpRequestParser import HttpRequestParser
from Consts import *
from cbsd.Cbsd import CBSD


def reject_all_connection(config):
    if not config.CONNECTION_REJECT:
        config.CONNECTION_REJECT = True


class CBSDManager(object):
    __cbsd_list = {}
    __blist_list = []
    __suspend_list = []
    __terminate_list = []
    __dereg_list = []
    __PPA_list = []
    __http_status = 200
    __response_msg = {}

    def __init__(self, config, logHandler):
        self.config = config
        self.log = logHandler

    def request_dispatcher(self, msg):
        self.__http_status = 200
        self.__response_msg = {}
        # parse http message
        http_p = HttpRequestParser(msg)
        if http_p.req_parse() is False:
            self.__http_status = http_p.get_status()
            self.log.warning('parsing http header fail %d' % self.__http_status)
            return

        http_method = http_p.get_method()
        if http_method != 'POST':
            # HTTP method not allowed
            self.__http_status = 405
            self.log.warning('invalid http method %s for SAS request, only support POST' % http_method)
            return

        # validate URL format
        # The SAS URL path ends with the string "/{sas_version_number}/{sas_method_name}"
        # SAS-CBSD protocol version check will be performed in request handler
        req_uri = http_p.get_uri()
        req_uri_sep = req_uri.split('/')
        if len(req_uri_sep) < 3:
            self.__http_status = 404
            self.log.warning('invalid SAS URL path %s' % req_uri)
            return
        # validate SAS method
        sas_method = req_uri_sep[-1]
        if sas_method in sas_method_t:
            pass
        elif sas_method in sas_manager_method_t:
            pass
        elif sas_method in sas_int_method_t:
            pass
        else:
            # SAS method not supported
            self.__http_status = 404
            self.log.warning('invalid SAS method %s for SAS request' % sas_method)
            return

        msg_json = http_p.get_data()

        # TBD: should check if the input is valid or should catch exception
        try:
            msg_body = json.loads(msg_json, strict=False)
            if sas_method == METHOD_REG:
                self.__reg_dispatcher(msg_body, req_uri_sep[-2])
                return
            elif sas_method == METHOD_DEREG:
                self.__dereg_dispatcher(msg_body, req_uri_sep[-2])
                return
            elif sas_method == METHOD_INQUIRY:
                self.__inquiry_dispatcher(msg_body, req_uri_sep[-2])
                return
            elif sas_method == METHOD_GRANT:
                self.__grant_dispatcher(msg_body, req_uri_sep[-2])
                return
            elif sas_method == METHOD_HEARTBEAT:
                self.__hb_dispatcher(msg_body, req_uri_sep[-2])
                return
            elif sas_method == METHOD_RELINQUISH:
                self.__rlq_dispatcher(msg_body, req_uri_sep[-2])
                return
            elif sas_method == METHOD_MNG_CBSD:
                self.__mng_cbsd_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_BLIST:
                self.__mng_blist_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_BL_ADD:
                self.__mng_bl_add_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_BL_DEL:
                self.__mng_bl_del_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_PPA:
                self.__mng_PPA_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_PPA_ADD:
                self.__mng_PPA_add_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_PPA_DEL:
                self.__mng_PPA_del_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_GRANT_SP:
                self.__mng_grant_sp_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_GRANT_TN:
                self.__mng_grant_tn_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_GRANT_FREE:
                self.__mng_grant_free_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_GRANT_RENEW:
                self.__mng_grant_renew_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_TRANSMIT_RENEW:
                self.__mng_transmit_renew_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_VERSION:
                self.__mng_version_dispatcher(msg_body)
                return
            elif sas_method == METHOD_INT_EVENT:
                self.__int_event_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_OPTION_BLOCK_REQUEST:
                self.__mng_option_block_request_dispatcher(msg_body)
                return
            elif sas_method == METHOD_MNG_OPTION_CONNECTION_REJECT:
                self.__mng_option_connection_reject_dispatcher(msg_body)
                return
        except TypeError:
            self.__http_status = 400
            self.log.warning('type error: invalid syntax of SAS method request')
            return
        except ValueError:
            self.__http_status = 400
            self.log.warning('value error: invalid syntax of SAS method request')
            return

    def __error_response_builder_for_dp(self, res_type=METHOD_HEARTBEAT, cbsdID='', grantID=''):
        res = {}
        for forceResponseMember in self.config.force_response_group:
            forceResponseMemberElenents = forceResponseMember.split(',')
            self.log.debug('res_type: %s, configured_elementKey: %s, configured_sequence: %s, configured_error: %s' %
                           (res_type, forceResponseMemberElenents[0], forceResponseMemberElenents[1],
                            forceResponseMemberElenents[2]))
            if int(forceResponseMemberElenents[2]) <= 999:
                continue
            increasementKey = ''
            if cbsdID != '':
                increasementKey = cbsdID + '-'
            if grantID != '':
                increasementKey = increasementKey + grantID + '-'
            increasementKey = increasementKey + res_type
            elementKey = increasementKey + '-' + str(forceResponseMemberElenents[2])
            configuredElementKey = str(forceResponseMemberElenents[0]) + '-' + str(forceResponseMemberElenents[2])
            self.log.debug('elementKey: %s, configured_elementKey: %s' % (elementKey, configuredElementKey))
            if increasementKey != str(forceResponseMemberElenents[0]):
                continue
            if elementKey in self.config.force_response_group_sequences:
                self.config.force_response_group_sequences[elementKey] += 1
            sequence = int(forceResponseMemberElenents[1])
            self.log.debug('elementKey: %s, configured_sequence: %d, sequence: %d' %
                           (elementKey, sequence, self.config.force_response_group_sequences[elementKey]))
            if sequence == self.config.force_response_group_sequences[elementKey]:
                errorCode = int(forceResponseMemberElenents[2])
                if errorCode == 9191:
                    # deregister CBSD
                    self.__cbsd_list[cbsdID].stop()
                    self.__cbsd_list.pop(cbsdID)
                    self.__dereglist_add(cbsdID)
                if errorCode == 9190:
                    res[PAR_ERROR] = {PAR_ERR_CODE: int(forceResponseMemberElenents[2]),
                                      PAR_ERR_MSG: error_code_table[errorCode],
                                      PAR_ERR_BACKOFFINTERVAL: int(forceResponseMemberElenents[3])}
                else:
                    res[PAR_ERROR] = {PAR_ERR_CODE: int(forceResponseMemberElenents[2]),
                                      PAR_ERR_MSG: error_code_table[errorCode]}
        return res

    def __reg_dispatcher(self, reg_msg, protocol):
        # CBSD reg
        self.log.info('received CBSD registration request')

        res_list = []
        self.__response_msg[RES_REG] = res_list
        self.__excludePar = False

        if REQ_REG not in reg_msg:
            self.log.warning('%s is not included in msg body' % REQ_REG)
            tmp_cbsd = CBSD(self.config, self.log)
            response_msg = tmp_cbsd.response_builder(RES_REG, 102, '')
            res_list.append(response_msg)
            return

        reg_list = reg_msg[REQ_REG]
        if not isinstance(reg_list, list):
            self.log.warning('the %s body should be a list of %s objects' % (REQ_REG, REQ_REG))
            tmp_cbsd = CBSD(self.config, self.log)
            response_msg = tmp_cbsd.response_builder(RES_REG, 102, '')
            res_list.append(response_msg)
            return

        for reg_req in reg_list:
            cbsd = CBSD(self.config, self.log)
            cbsd_id = cbsd.get_cbsdID(reg_req, REQ_REG)
            if len(self.config.force_response_group) != 0 and self.config.DP_MODEL is True:
                responseMsg = self.__error_response_builder_for_dp(METHOD_REG, cbsd_id)
                if bool(responseMsg):
                    res_list.append(responseMsg)
                    return
            myCbsdConfig = self.config
            myCbsdConfig.getCbsdSpecificConfig(cbsd_id)
            if myCbsdConfig.SAS_METHOD_FORCE == METHOD_REG:
                if myCbsdConfig.SUBSEQUENT_CONN_REJECT is True:
                    self.log.warning('will reject all subsequence connection!')
                if myCbsdConfig.HTTP_RESPONSE_CODE_FORCE is not None:
                    self.__http_status = self.config.HTTP_RESPONSE_CODE_FORCE
                    self.log.warning('force the value of http responseCode to be %d' %
                                     self.config.HTTP_RESPONSE_CODE_FORCE)
                    return
            if myCbsdConfig.BLOCKED_REQUEST == METHOD_REG:
                myCbsdConfig.blocked_request_sequences['DUMMY_GRANT'] += 1
                if myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None or \
                        myCbsdConfig.blocked_request_sequences['DUMMY_GRANT'] == myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked, do not respond' % METHOD_REG)
                    return
            # blacklist check
            if cbsd_id in self.__blist_list:
                response_msg = cbsd.response_builder(res_type=RES_REG, error=101)
                res_list.append(response_msg)
                self.log.info('cbsdID %s is blacklisted' % cbsd_id)
                continue
            # reg duplication check
            if cbsd_id in self.__cbsd_list:
                self.log.warning('duplicated registration with cbsdID %s' % cbsd_id)
                # deregister CBSD
                self.__cbsd_list[cbsd_id].stop()
                self.__cbsd_list.pop(cbsd_id)
                self.log.debug('removed cbsd %s from cbsdlist' % cbsd_id)
                self.__dereglist_add(cbsd_id)
                response_msg = cbsd.response_builder(res_type=RES_REG, error=105)
                res_list.append(response_msg)
                continue

            reg_result = cbsd.reg_handler(reg_req, protocol, self.__blist_list)
            if reg_result[0] == 0:
                self.__cbsd_list.setdefault(cbsd_id, cbsd)
                self.__dereglist_remove(cbsd_id)
                response_msg = cbsd.response_builder(res_type=RES_REG, error=0)
                res_list.append(response_msg)
                self.log.info('registration with cbsdID %s OK' % cbsd_id)
                cbsd.reg_handler_cleanup()
                if (myCbsdConfig.SAS_METHOD_FORCE == METHOD_REG and
                        myCbsdConfig.RESPONSE_CODE_FORCE == 0 and cbsd.get_excludePar() is True):
                    self.__cbsd_list.pop(cbsd_id)
                    self.__dereglist_add(cbsd_id)
            else:
                if isinstance(reg_result[1], list) or isinstance(reg_result[1], tuple):
                    response_msg = cbsd.response_builder(RES_REG, reg_result[0], *reg_result[1])
                else:
                    response_msg = cbsd.response_builder(RES_REG, reg_result[0], reg_result[1])
                res_list.append(response_msg)
                self.log.warning('registration with cbsdID %s fail with error code %d' % (cbsd_id, reg_result[0]))
#          self.log.info('DBG:%s'%response_msg)

    def __dereg_dispatcher(self, dereg_msg, protocol):
        # CBSD dereg
        self.log.warning('received CBSD deregistration request')

        res_list = []
        self.__response_msg[RES_DEREG] = res_list
        self.__excludePar = False

        if REQ_DEREG not in dereg_msg:
            self.log.warning('%s is not included in msg body' % REQ_DEREG)
            tmp_cbsd = CBSD(self.config, self.log)
            response_msg = tmp_cbsd.response_builder(RES_DEREG, 102, '')
            res_list.append(response_msg)
            return

        dereg_list = dereg_msg[REQ_DEREG]
        for dereg_req in dereg_list:
            if PAR_CBSD_ID not in dereg_req:
                self.log.warning('missing %s parameter in deregistration request' % PAR_CBSD_ID)
                tmp_cbsd = CBSD(self.config, self.log)
                response_msg = tmp_cbsd.response_builder(RES_DEREG, 102, *[PAR_CBSD_ID])
                res_list.append(response_msg)
                self.log.warning('deregistration request fail with error code 102')
                continue
            cbsd_id = dereg_req[PAR_CBSD_ID]
            myCbsdConfig = self.config
            myCbsdConfig.getCbsdSpecificConfig(cbsd_id)
            if myCbsdConfig.SAS_METHOD_FORCE == METHOD_DEREG:
                if myCbsdConfig.SUBSEQUENT_CONN_REJECT is True:
                    self.log.warning('will reject all subsequence connection!')
                if myCbsdConfig.HTTP_RESPONSE_CODE_FORCE is not None:
                    self.__http_status = myCbsdConfig.HTTP_RESPONSE_CODE_FORCE
                    self.log.warning('force the value of http responseCode to be %d' %
                                     myCbsdConfig.HTTP_RESPONSE_CODE_FORCE)
                    return

            if myCbsdConfig.BLOCKED_REQUEST == METHOD_DEREG:
                myCbsdConfig.blocked_request_sequences['DUMMY_GRANT'] += 1
                if myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None or \
                        myCbsdConfig.blocked_request_sequences['DUMMY_GRANT'] == myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked, do not respond' % METHOD_DEREG)
                    return

            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                if len(self.config.force_response_group) != 0 and self.config.DP_MODEL is True:
                    responseMsg = self.__error_response_builder_for_dp(METHOD_DEREG, cbsd_id)
                    if bool(responseMsg):
                        res_list.append(responseMsg)
                        return
                dereg_result = cbsd.dereg_handler(dereg_req, protocol)
                if dereg_result[0] == 0:
                    # it's not a good way to check following condition. there is similar check in CBSD.dereg_handler
                    # this is just a quick fix
                    no_dereg = False
                    if myCbsdConfig.SAS_METHOD_FORCE == METHOD_DEREG and myCbsdConfig.RESPONSE_CODE_FORCE == 0:
                        if myCbsdConfig.EXCLUDE_PARAM_FORCE == PAR_CBSD_ID:
                            no_dereg = True
                        elif myCbsdConfig.EXCLUDE_PARAM_FORCE == PAR_ERROR or \
                                myCbsdConfig.EXCLUDE_PARAM_FORCE == PAR_ERR_CODE:
                            no_dereg = True
                    if no_dereg:
                        self.__cbsd_list.pop(cbsd_id)
                        self.log.debug('removed cbsd %s from cbsdlist' % cbsd_id)
                        self.__dereglist_add(cbsd_id)
                    response_msg = cbsd.response_builder(res_type=RES_DEREG, error=0)
                    res_list.append(response_msg)
                    self.log.info('deregistration with cbsdID %s OK' % cbsd_id)
                else:
                    if isinstance(dereg_result[1], list) or isinstance(dereg_result[1], tuple):
                        response_msg = cbsd.response_builder(RES_DEREG, dereg_result[0], *dereg_result[1])
                    else:
                        response_msg = cbsd.response_builder(RES_DEREG, dereg_result[0], dereg_result[1])
                    res_list.append(response_msg)
                    self.log.warning('deregistration with cbsdID %s fail with error code %d' %
                                     (cbsd_id, dereg_result[0]))
            elif cbsd_id in self.__dereg_list:
                self.log.warning('the CBSD %s is already deregistered' % cbsd_id)
                cbsd = CBSD(self.config, self.log)
                response_msg = cbsd.response_builder(RES_DEREG, 105)
                res_list.append(response_msg)
            else:
                self.log.warning('invalid cbsdId parameter %s' % cbsd_id)
                cbsd = CBSD(self.config, self.log)
                response_msg = cbsd.response_builder(RES_DEREG, 103, PAR_CBSD_ID)
                res_list.append(response_msg)

    def __dereglist_remove(self, cbsd_id):
        if cbsd_id in self.__dereg_list:
            self.__dereg_list.remove(cbsd_id)
            self.log.debug('removed CBSD %s from dereg list' % cbsd_id)

    def __dereglist_add(self, cbsd_id):
        if cbsd_id not in self.__dereg_list:
            self.__dereg_list.append(cbsd_id)
            self.log.debug('added CBSD %s to dereg list' % cbsd_id)

    def __inquiry_dispatcher(self, inq_msg, protocol):
        # Spectrum inquiry
        self.log.info('received spectrum inquiry request')

        res_list = []
        self.__response_msg[RES_INQUIRY] = res_list
        self.__excludePar = False

        if REQ_INQUIRY not in inq_msg:
            self.log.warning('%s is not included in msg body' % REQ_INQUIRY)
            tmp_cbsd = CBSD(self.config, self.log)
            response_msg = tmp_cbsd.response_builder(RES_INQUIRY, 102, '')
            res_list.append(response_msg)
            return

        # build available channel list
        ch_list = {}
        for ch_id in self.config.spectrum_table.keys():
            ch_list[ch_id] = self.config.spectrum_table[ch_id]

        inq_list = inq_msg[REQ_INQUIRY]
        for inq_req in inq_list:
            if PAR_CBSD_ID not in inq_req:
                self.log.warning('missing %s parameter in inquiry request' % PAR_CBSD_ID)
                tmp_cbsd = CBSD(self.config, self.log)
                response_msg = tmp_cbsd.response_builder(RES_INQUIRY, 102, *[PAR_CBSD_ID])
                res_list.append(response_msg)
                self.log.warning('spectrum inquiry fail with error code 102')
                continue
            cbsd = CBSD(self.config, self.log)
            cbsd_id = cbsd.get_cbsdID(inq_req, REQ_INQUIRY)
            if len(self.config.force_response_group) != 0 and self.config.DP_MODEL is True:
                responseMsg = self.__error_response_builder_for_dp(METHOD_INQUIRY, cbsd_id)
                if bool(responseMsg):
                    res_list.append(responseMsg)
                    return
            myCbsdConfig = self.config
            myCbsdConfig.getCbsdSpecificConfig(cbsd_id)
            if myCbsdConfig.SAS_METHOD_FORCE == METHOD_INQUIRY:
                if myCbsdConfig.SUBSEQUENT_CONN_REJECT is True:
                    self.log.warning('will reject all subsequence connection!')
                if myCbsdConfig.HTTP_RESPONSE_CODE_FORCE is not None:
                    self.__http_status = myCbsdConfig.HTTP_RESPONSE_CODE_FORCE
                    self.log.warning('force the value of http responseCode to be %d' %
                                     myCbsdConfig.HTTP_RESPONSE_CODE_FORCE)
                    return

            if myCbsdConfig.BLOCKED_REQUEST == METHOD_INQUIRY:
                myCbsdConfig.blocked_request_sequences['DUMMY_GRANT'] += 1
                if myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None or \
                        myCbsdConfig.blocked_request_sequences['DUMMY_GRANT'] == myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked, do not respond' % METHOD_INQUIRY)
                    return

            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                inq_result = cbsd.inquiry_handler(inq_req, protocol, ch_list)
                if inq_result[0] == 0:
                    response_msg = cbsd.response_builder(RES_INQUIRY, 0, *inq_result[1])
                    res_list.append(response_msg)
                    self.log.info('spectrum inquiry with cbsdID %s OK' % cbsd_id)
                else:
                    if isinstance(inq_result[1], list) or isinstance(inq_result[1], tuple):
                        response_msg = cbsd.response_builder(RES_INQUIRY, inq_result[0], *inq_result[1])
                    else:
                        response_msg = cbsd.response_builder(RES_INQUIRY, inq_result[0], inq_result[1])

                    if inq_result[0] == 105 and myCbsdConfig.FORCE_RESPONSE_DEREG_IMMEDIATELY is True:
                        # deregister CBSD
                        self.__cbsd_list[cbsd_id].stop()
                        self.__cbsd_list.pop(cbsd_id)
                        self.log.debug('removed cbsd %s from cbsdlist' % cbsd_id)
                        self.__dereglist_add(cbsd_id)

                    res_list.append(response_msg)
                    self.log.warning('spectrum inquiry with cbsdID %s fail with error code %s' % (cbsd_id, inq_result))
            elif cbsd_id in self.__dereg_list:
                self.log.warning('the CBSD %s is already deregistered' % cbsd_id)
                cbsd = CBSD(self.config, self.log)
                response_msg = cbsd.response_builder(RES_INQUIRY, 105)
                res_list.append(response_msg)
            else:
                self.log.warning('invalid cbsdId parameter %s' % cbsd_id)
                response_msg = cbsd.response_builder(RES_INQUIRY, 103, PAR_CBSD_ID)
                res_list.append(response_msg)

    def __grant_dispatcher(self, grant_msg, protocol):
        # Grant request
        self.log.info('received grant request')

        res_list = []
        self.__response_msg[RES_GRANT] = res_list
        self.__excludePar = False

        if REQ_GRANT not in grant_msg:
            self.log.warning('%s is not included in msg body' % REQ_GRANT)
            tmp_cbsd = CBSD(self.config, self.log)
            response_msg = tmp_cbsd.response_builder(REQ_GRANT, 102, '')
            res_list.append(response_msg)
            return

        grant_list = grant_msg[REQ_GRANT]
        for grant_req in grant_list:
            if PAR_CBSD_ID not in grant_req:
                self.log.warning('missing %s parameter in grant request' % PAR_CBSD_ID)
                tmp_cbsd = CBSD(self.config, self.log)
                response_msg = tmp_cbsd.response_builder(RES_GRANT, 102, *[PAR_CBSD_ID])
                res_list.append(response_msg)
                self.log.warning('grant request fail with error code 102')
                continue
            # build available channel list
            ch_list = {}
            for ch_id in self.config.spectrum_table.keys():
                ch_list[ch_id] = self.config.spectrum_table[ch_id]
            cbsd = CBSD(self.config, self.log)
            cbsd_id = cbsd.get_cbsdID(grant_req, REQ_GRANT)
            myCbsdConfig = self.config
            myCbsdConfig.getCbsdSpecificConfig(cbsd_id)
            if myCbsdConfig.SAS_METHOD_FORCE == METHOD_GRANT:
                if myCbsdConfig.SUBSEQUENT_CONN_REJECT is True:
                    self.log.warning('will reject all subsequence connection!')
                if myCbsdConfig.HTTP_RESPONSE_CODE_FORCE is not None:
                    self.__http_status = myCbsdConfig.HTTP_RESPONSE_CODE_FORCE
                    self.log.warning('force the value of http responseCode to be %d' %
                                     myCbsdConfig.HTTP_RESPONSE_CODE_FORCE)
                    return

            grantID = None
            op_par = grant_req[PAR_OP_PAR]
            fre_range = op_par[PAR_OP_FREQ_RANG]
            lowFreq = fre_range[PAR_LOW_FREQ]
            self.log.info('get low %s' % lowFreq)
            highFreq = fre_range[PAR_HIGH_FREQ]
            self.log.info('get high %s' % highFreq)
            grantID = str(lowFreq) + '_' + str(highFreq)
            self.log.info('get grantid %s' % grantID)
            if len(self.config.force_response_group) != 0 and self.config.DP_MODEL is True:
                responseMsg = self.__error_response_builder_for_dp(METHOD_GRANT, cbsd_id, grantID)
                if bool(responseMsg):
                    res_list.append(responseMsg)
                    return
            if myCbsdConfig.BLOCKED_REQUEST == METHOD_GRANT:
                # when blocked_request_grantids and blocked_request_sequence not set, all grants will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is None and myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None:
                    self.log.warning('%s is blocked for all grants, do not respond' % METHOD_GRANT)
                    return
                # when grantid in blocked_request_grantids and blocked_request_sequence not set,
                # hitted grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_GRANTIDS.find(grantID) != -1 and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None:
                    self.log.warning('%s is blocked for current grant, do not respond' % METHOD_GRANT)
                    continue
                self.__cbsd_list[cbsd_id].set_blocked_request_sequence(grantID)
                # when blocked_request_sequence hit and blocked_request_grantids not set,
                # hitted sequence for each grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is None and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is not None and \
                        self.__cbsd_list[cbsd_id].get_blocked_request_sequence(grantID) == \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked for all grants, do not respond' % METHOD_GRANT)
                    continue
                # when both sblocked_request_grantids and blocked_request_sequence set and hit ,
                # hitted sequence and grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_GRANTIDS.find(grantID) != -1 and \
                        self.__cbsd_list[cbsd_id].get_blocked_request_sequence(grantID) == \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked, do not respond' % METHOD_GRANT)
                    continue

            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                grant_result = cbsd.grant_handler(grant_req, protocol, ch_list, self.__terminate_list, self.__PPA_list)
                if grant_result[0] == 0:
                    response_msg = cbsd.response_builder(RES_GRANT, 0, grant_result[1])
                    res_list.append(response_msg)
                    self.log.info('grant with cbsdID %s OK' % cbsd_id)
                    cbsd.grant_handler_cleanup(grant_result[1])
                else:
                    if isinstance(grant_result[1], list) or isinstance(grant_result[1], tuple):
                        response_msg = cbsd.response_builder(RES_GRANT, grant_result[0], *grant_result[1])
                    else:
                        response_msg = cbsd.response_builder(RES_GRANT, grant_result[0], grant_result[1])

                    if grant_result[0] == 105 and myCbsdConfig.FORCE_RESPONSE_DEREG_IMMEDIATELY is True:
                        # deregister CBSD
                        self.__cbsd_list[cbsd_id].stop()
                        self.__cbsd_list.pop(cbsd_id)
                        self.log.debug('removed cbsd %s from cbsdlist' % cbsd_id)
                        self.__dereglist_add(cbsd_id)

                    res_list.append(response_msg)
                    self.log.warning('grant with cbsdID %s fail with error code %s' % (cbsd_id, grant_result[0]))
            elif cbsd_id in self.__dereg_list:
                self.log.warning('the CBSD %s is already deregistered' % cbsd_id)
                cbsd = CBSD(self.config, self.log)
                response_msg = cbsd.response_builder(RES_GRANT, 105)
                res_list.append(response_msg)
            else:
                self.log.warning('invalid cbsdId parameter %s' % cbsd_id)
                response_msg = cbsd.response_builder(RES_GRANT, 103, PAR_CBSD_ID)
                res_list.append(response_msg)

    def __hb_dispatcher(self, hb_msg, protocol):
        # Heartbeat request
        self.log.info('received heartbeat request')

        res_list = []
        self.__response_msg[RES_HEARTBEAT] = res_list
        self.__excludePar = False

        if REQ_HEARTBEAT not in hb_msg:
            self.log.warning('%s is not included in msg body' % REQ_HEARTBEAT)
            tmp_cbsd = CBSD(self.config, self.log)
            response_msg = tmp_cbsd.response_builder(REQ_HEARTBEAT, 102, '')
            res_list.append(response_msg)
            return

        hb_list = hb_msg[REQ_HEARTBEAT]
        for hb_req in hb_list:
            if PAR_CBSD_ID not in hb_req:
                self.log.warning('missing %s parameter in heartbeat request' % PAR_CBSD_ID)
                tmp_cbsd = CBSD(self.config, self.log)
                response_msg = tmp_cbsd.response_builder(RES_HEARTBEAT, 102, *[PAR_CBSD_ID])
                res_list.append(response_msg)
                self.log.warning('heartbeat request fail with error code 102')
                continue
            cbsd = CBSD(self.config, self.log)
            cbsd_id = cbsd.get_cbsdID(hb_req, REQ_HEARTBEAT)
            myCbsdConfig = self.config
            myCbsdConfig.getCbsdSpecificConfig(cbsd_id)
            if myCbsdConfig.SAS_METHOD_FORCE == METHOD_HEARTBEAT:
                if myCbsdConfig.SUBSEQUENT_CONN_REJECT is True:
                    self.log.warning('will reject all subsequence connection!')
                if myCbsdConfig.HTTP_RESPONSE_CODE_FORCE is not None:
                    self.__http_status = myCbsdConfig.HTTP_RESPONSE_CODE_FORCE
                    self.log.warning('force the value of http responseCode to be %d' %
                                     myCbsdConfig.HTTP_RESPONSE_CODE_FORCE)
                    return

            if myCbsdConfig.BLOCKED_REQUEST == METHOD_HEARTBEAT:
                self.log.warning('Cbsd %s dispatcher for heartbeat' % cbsd_id)
                grantID = self.__cbsd_list[cbsd_id].get_grantID_from_req(hb_req)
                self.log.warning('Grant %s dispatcher for heartbeat' % grantID)
                # when blocked_request_grantids and blocked_request_sequence not set, all grants will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is None and myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None:
                    self.log.warning('%s is blocked for all grants, do not respond' % METHOD_GRANT)
                    return
                # when grantid in blocked_request_grantids and blocked_request_sequence not set,
                # hitted grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_GRANTIDS.find(grantID) != -1 and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None:
                    self.log.warning('%s is blocked for current grant, do not respond' % METHOD_GRANT)
                    continue
                self.__cbsd_list[cbsd_id].set_blocked_request_sequence(grantID)
                # when blocked_request_sequence hit and blocked_request_grantids not set,
                # hitted sequence for each grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is None and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is not None and \
                        self.__cbsd_list[cbsd_id].get_blocked_request_sequence(grantID) == \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked for all grants, do not respond' % METHOD_GRANT)
                    continue
                # when both sblocked_request_grantids and blocked_request_sequence set and hit ,
                # hitted sequence and grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_GRANTIDS.find(grantID) != -1 and \
                        self.__cbsd_list[cbsd_id].get_blocked_request_sequence(grantID) == \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked, do not respond' % METHOD_GRANT)
                    continue

            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                grant_id = cbsd.get_grantID_from_req(hb_req)
                if len(self.config.force_response_group) != 0 and self.config.DP_MODEL is True:
                    responseMsg = self.__error_response_builder_for_dp(METHOD_HEARTBEAT, cbsd_id, grant_id)
                    if bool(responseMsg):
                        res_list.append(responseMsg)
                        return
                hb_result = cbsd.heartbeat_handler(hb_req, protocol,
                                                   self.__blist_list,
                                                   self.__suspend_list,
                                                   self.__terminate_list)
                if hb_result[0] == 0:
                    grant_id = cbsd.get_grantID_from_req(hb_req)
                    response_msg = cbsd.response_builder(RES_HEARTBEAT, 0, grantID=grant_id)
                    res_list.append(response_msg)
                    self.log.info('heartbeat with cbsdID %s OK' % cbsd_id)
                    cbsd.heartbeat_handler_cleanup(grant_id)
                else:
                    if hb_result[0] == 101:
                        # build response message prior to CBSD remove
                        grant_id = cbsd.get_grantID_from_req(hb_req)
                        response_msg = cbsd.response_builder(RES_HEARTBEAT, hb_result[0], grantID=grant_id)
                        res_list.append(response_msg)
                        if (myCbsdConfig.SAS_METHOD_FORCE == METHOD_HEARTBEAT and
                                myCbsdConfig.RESPONSE_CODE_FORCE == 101):
                            # do not change op state or remove cbsd if we force responseCode=101
                            pass
                        else:
                            self.__cbsd_list[cbsd_id].set_opState(STATE_UNREG)
                            self.log.debug('change cbsd %s to %s due to blacklist' % (cbsd_id, STATE_UNREG))
                            self.__cbsd_list[cbsd_id].stop()
                            self.__cbsd_list.pop(cbsd_id)
                            self.log.debug('remove cbsd %s from cbsdlist due to blacklist' % cbsd_id)
                            self.__dereglist_add(cbsd_id)
                    else:
                        grant_id = cbsd.get_grantID_from_req(hb_req)
                        if isinstance(hb_result[1], list) or isinstance(hb_result[1], tuple):
                            response_msg = cbsd.response_builder(RES_HEARTBEAT, hb_result[0], *hb_result[1],
                                                                 grantID=grant_id)
                        else:
                            response_msg = cbsd.response_builder(RES_HEARTBEAT, hb_result[0], hb_result[1],
                                                                 grantID=grant_id)

                        if hb_result[0] == 105 and myCbsdConfig.FORCE_RESPONSE_DEREG_IMMEDIATELY is True:
                            # deregister CBSD
                            self.__cbsd_list[cbsd_id].stop()
                            self.__cbsd_list.pop(cbsd_id)
                            self.log.debug('removed cbsd %s from cbsdlist' % cbsd_id)
                            self.__dereglist_add(cbsd_id)

                        res_list.append(response_msg)
                        self.log.warning('heartbeat with cbsdID %s fail with error code %s' % (cbsd_id, hb_result[0]))
            elif cbsd_id in self.__dereg_list:
                self.log.warning('the CBSD %s is already deregistered' % cbsd_id)
                # cbsdId is not a valid CBSD identity
                # grantId is not a valid Grant identity
                response_msg = cbsd.response_builder(RES_HEARTBEAT, 105)
                res_list.append(response_msg)
            else:
                self.log.warning('invalid cbsdId parameter %s' % cbsd_id)
                response_msg = cbsd.response_builder(RES_HEARTBEAT, 103, PAR_CBSD_ID)
                res_list.append(response_msg)

    def __rlq_dispatcher(self, rlq_msg, protocol):
        # Relinquishment request
        self.log.info('received relinquishment request')

        res_list = []
        self.__response_msg[RES_RELINQUISH] = res_list
        self.__excludePar = False

        if REQ_RELINQUISH not in rlq_msg:
            self.log.warning('%s is not included in msg body' % REQ_RELINQUISH)
            tmp_cbsd = CBSD(self.config, self.log)
            response_msg = tmp_cbsd.response_builder(REQ_RELINQUISH, 102, '')
            res_list.append(response_msg)
            return

        if len(self.config.force_response_group) != 0:
            response_msg = self.__response_builder(RES_RELINQUISH)
            if bool(response_msg):
                res_list.append(response_msg)
                return

        rlq_list = rlq_msg[REQ_RELINQUISH]
        for rlq_req in rlq_list:
            if PAR_CBSD_ID not in rlq_req:
                self.log.warning('missing %s parameter in relinquishment request' % PAR_CBSD_ID)
                tmp_cbsd = CBSD(self.config, self.log)
                response_msg = tmp_cbsd.response_builder(RES_RELINQUISH, 102, *[PAR_CBSD_ID])
                res_list.append(response_msg)
                self.log.warning('relinqushment request fail with error code 102')
                continue
            cbsd = CBSD(self.config, self.log)
            cbsd_id = cbsd.get_cbsdID(rlq_req, REQ_RELINQUISH)
            myCbsdConfig = self.config
            myCbsdConfig.getCbsdSpecificConfig(cbsd_id)
            if myCbsdConfig.SAS_METHOD_FORCE == METHOD_RELINQUISH:
                if myCbsdConfig.SUBSEQUENT_CONN_REJECT is True:
                    self.log.warning('will reject all subsequence connection!')
                if myCbsdConfig.HTTP_RESPONSE_CODE_FORCE is not None:
                    self.__http_status = myCbsdConfig.HTTP_RESPONSE_CODE_FORCE
                    self.log.warning('force the value of http responseCode to be %d' %
                                     myCbsdConfig.HTTP_RESPONSE_CODE_FORCE)
                    return

            if myCbsdConfig.BLOCKED_REQUEST == METHOD_RELINQUISH:
                cbsd = self.__cbsd_list[cbsd_id]
                grantID = cbsd.get_grantID_from_req(rlq_req)
                self.log.warning('Grant %s dispatcher for relinquishment' % grantID)
                if len(self.config.force_response_group) != 0 and self.config.DP_MODEL is True:
                    responseMsg = self.__error_response_builder_for_dp(METHOD_RELINQUISH, cbsd_id, grantID)
                    if bool(responseMsg):
                        res_list.append(responseMsg)
                        return
                # when blocked_request_grantids and blocked_request_sequence not set, all grants will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is None and myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None:
                    self.log.warning('%s is blocked for all grants, do not respond' % METHOD_GRANT)
                    return
                # when grantid in blocked_request_grantids and blocked_request_sequence not set,
                # hitted grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_GRANTIDS.find(grantID) != -1 and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is None:
                    self.log.warning('%s is blocked for current grant, do not respond' % METHOD_GRANT)
                    continue
                self.__cbsd_list[cbsd_id].set_blocked_request_sequence(grantID)
                # when blocked_request_sequence hit and blocked_request_grantids not set,
                # hitted sequence for each grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is None and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is not None and \
                        self.__cbsd_list[cbsd_id].get_blocked_request_sequence(grantID) == \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked for all grants, do not respond' % METHOD_GRANT)
                    continue
                # when both sblocked_request_grantids and blocked_request_sequence set and hit ,
                # hitted sequence and grant will be blocked
                if myCbsdConfig.BLOCKED_REQUEST_GRANTIDS is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE is not None and \
                        myCbsdConfig.BLOCKED_REQUEST_GRANTIDS.find(grantID) != -1 and \
                        self.__cbsd_list[cbsd_id].get_blocked_request_sequence(grantID) == \
                        myCbsdConfig.BLOCKED_REQUEST_SEQUENCE:
                    self.log.warning('%s is blocked, do not respond' % METHOD_GRANT)
                    continue

            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                grant_id = cbsd.get_grantID_from_req(rlq_req)
                rlq_result = cbsd.relinquish_handler(rlq_req, protocol)
                if rlq_result[0] == 0:
                    response_msg = cbsd.response_builder(RES_RELINQUISH, 0, grantID=grant_id)
                    res_list.append(response_msg)
                    self.log.info('relinquish with cbsdID %s OK' % cbsd_id)
                else:
                    if isinstance(rlq_result[1], list) or isinstance(rlq_result[1], tuple):
                        response_msg = cbsd.response_builder(RES_RELINQUISH, rlq_result[0], *rlq_result[1],
                                                             grantID=grant_id)
                    else:
                        response_msg = cbsd.response_builder(RES_RELINQUISH, rlq_result[0], rlq_result[1],
                                                             grantID=grant_id)

                    if rlq_result[0] == 105 and myCbsdConfig.FORCE_RESPONSE_DEREG_IMMEDIATELY is True:
                        # deregister CBSD
                        self.__cbsd_list[cbsd_id].stop()
                        self.__cbsd_list.pop(cbsd_id)
                        self.log.debug('removed cbsd %s from cbsdlist' % cbsd_id)
                        self.__dereglist_add(cbsd_id)

                    res_list.append(response_msg)
                    self.log.warning('relinquish with cbsdID %s fail with error code %d' % (cbsd_id, rlq_result[0]))
            elif cbsd_id in self.__dereg_list:
                self.log.warning('the CBSD %s is already deregistered' % cbsd_id)
                cbsd = CBSD(self.config, self.log)
                response_msg = cbsd.response_builder(RES_RELINQUISH, 105)
                res_list.append(response_msg)
            else:
                self.log.warning('invalid cbsdId parameter %s' % cbsd_id)
                response_msg = cbsd.response_builder(RES_RELINQUISH, 103, PAR_CBSD_ID)
                res_list.append(response_msg)

    def __int_event_dispatcher(self, event_msg):
        # internal event message
        self.log.info('received internal event msg')
        self.__response_msg = {}
        if (PAR_EVENT_TYPE not in event_msg) or (PAR_CBSD_ID not in event_msg) or (PAR_GRANT_ID not in event_msg):
            self.log.warning('invalid internal event msg due to parameter missing')
        event_type = event_msg[PAR_EVENT_TYPE]
        if event_type == EVENT_HEARTBEAT_TIMEOUT:
            cbsd_id = event_msg[PAR_CBSD_ID]
            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                cbsd.heartbeat_timeout_handler(event_msg[PAR_GRANT_ID])
            else:
                self.log.warning('could not find cbsd %s for the heartbeat expire event' % cbsd_id)
        elif event_type == EVENT_GRANT_TIMEOUT:
            cbsd_id = event_msg[PAR_CBSD_ID]
            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                cbsd.grant_timeout_handler(event_msg[PAR_GRANT_ID])
            else:
                self.log.warning('could not find cbsd %s for the grant expire event' % cbsd_id)
        elif event_type == EVENT_TRANSMIT_TIMEOUT:
            cbsd_id = event_msg[PAR_CBSD_ID]
            if cbsd_id in self.__cbsd_list:
                cbsd = self.__cbsd_list[cbsd_id]
                cbsd.transmit_timeout_handler(event_msg[PAR_GRANT_ID], self.__suspend_list, self.__terminate_list)
            else:
                self.log.warning('could not find cbsd %s for the transmit expire event' % cbsd_id)
        else:
            self.log.warning('internal event is not supported')

    def __mng_cbsd_dispatcher(self, mng_msg):
        # Sever management request -- cbsd list
        self.log.info('received cbsd request from SAS Manager')
        self.__response_msg = ''
        cbsd_l = []
        fields = {}
        for cbsd_id in self.__cbsd_list.keys():
            cbsd = self.__cbsd_list[cbsd_id]
            mng_result = cbsd.mng_cbsd_handler(mng_msg)
            if mng_result[0] == 0:
                cbsd_l.append(mng_result[1])
            else:
                break
        fields[PAR_ERROR] = {PAR_ERR_CODE: 0, PAR_ERR_MSG: error_code_table[0]}
        fields['cbsd'] = cbsd_l
        self.__response_msg = {RES_MNG_CBSD: fields}

    def __mng_blist_dispatcher(self, mng_msg):
        # Sever management request -- blacklist
        self.log.info('received blacklist request from SAS Manager')
        # no check request body
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: 0, PAR_ERR_MSG: error_code_table[0]}, 'blacklist': self.__blist_list}
        self.__response_msg = {RES_MNG_BLIST: fields}

    def __mng_bl_add_dispatcher(self, mng_msg):
        # Sever management request -- blacklist-add
        self.log.info('received blacklist-add request from SAS Manager')
        error = 0
        if REQ_MNG_BL_ADD not in mng_msg:
            error = 101
        else:
            blist = mng_msg[REQ_MNG_BL_ADD]
            if isinstance(blist, list):
                for item in blist:
                    if item in self.__blist_list:
                        error = 201
                    else:
                        self.__blist_list.append(item)
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_BL_ADD: fields}

    def __mng_bl_del_dispatcher(self, mng_msg):
        # Sever management request -- blacklist-del
        self.log.info('received blacklist-del request from SAS Manager')
        error = 0
        if REQ_MNG_BL_DEL not in mng_msg:
            error = 101
        else:
            blist = mng_msg[REQ_MNG_BL_DEL]
            if isinstance(blist, list):
                for item in blist:
                    if item not in self.__blist_list:
                        error = 202
                    else:
                        self.__blist_list.remove(item)
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_BL_DEL: fields}

    def __mng_PPA_dispatcher(self, mng_msg):
        # Sever management request -- PPA
        self.log.info('received PPA request from SAS Manager')
        # no check request body
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: 0, PAR_ERR_MSG: error_code_table[0]}, 'PPA': self.__PPA_list}
        self.__response_msg = {RES_MNG_PPA: fields}

    def __mng_PPA_add_dispatcher(self, mng_msg):
        # Sever management request -- PPA-add
        self.log.info('received PPA-add request from SAS Manager')
        error = 0
        if REQ_MNG_PPA_ADD not in mng_msg:
            error = 101
        else:
            plist = mng_msg[REQ_MNG_PPA_ADD]
            if isinstance(plist, list):
                for item in plist:
                    if item in self.__PPA_list:
                        error = 201
                    else:
                        self.__PPA_list.append(item)
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_PPA_ADD: fields}

    def __mng_PPA_del_dispatcher(self, mng_msg):
        # Sever management request -- PPA-del
        self.log.info('received PPA-del request from SAS Manager')
        error = 0
        if REQ_MNG_PPA_DEL not in mng_msg:
            error = 101
        else:
            plist = mng_msg[REQ_MNG_PPA_DEL]
            if isinstance(plist, list):
                for item in plist:
                    if item not in self.__PPA_list:
                        error = 202
                    else:
                        self.__PPA_list.remove(item)
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_PPA_DEL: fields}

    def __mng_grant_sp_dispatcher(self, mng_msg):
        # Sever management request -- grant suspend
        self.log.info('received grant suspend request from SAS Manager')
        error = 0
        if REQ_MNG_GRANT_SP not in mng_msg:
            error = 101
        else:
            spar = mng_msg[REQ_MNG_GRANT_SP]
            if isinstance(spar, dict):
                if (PAR_CBSD_ID in spar) and (PAR_GRANT_ID in spar):
                    cbsdID = spar[PAR_CBSD_ID]
                    grantID = spar[PAR_GRANT_ID]
                    existed = False
                    for item in self.__suspend_list:
                        if item[0] == cbsdID and item[1] == grantID:
                            error = 301
                            existed = True
                            self.log.warning('cbsdID %s grantID %s is already suspended' % (cbsdID, grantID))
                            break
                    if not existed:
                        for item in self.__terminate_list:
                            if item[0] == cbsdID and item[1] == grantID:
                                error = 301
                                existed = True
                                self.log.warning('cbsdID %s grantID %s is already terminated' % (cbsdID, grantID))
                                break
                    if not existed:
                        self.__suspend_list.append([cbsdID, grantID])
                        self.log.info('cbsdID %s grantID %s is added to suspending list' % (cbsdID, grantID))
                else:
                    error = 101
                    self.log.warning('%s or %s is missing' % (PAR_CBSD_ID, PAR_GRANT_ID))
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_GRANT_SP: fields}

    def __mng_grant_tn_dispatcher(self, mng_msg):
        # Sever management request -- grant terminate
        self.log.info('received grant terminate request from SAS Manager')
        error = 0
        if REQ_MNG_GRANT_TN not in mng_msg:
            error = 101
        else:
            tpar = mng_msg[REQ_MNG_GRANT_TN]
            if isinstance(tpar, dict):
                if (PAR_CBSD_ID in tpar) and (PAR_GRANT_ID in tpar):
                    cbsdID = tpar[PAR_CBSD_ID]
                    grantID = tpar[PAR_GRANT_ID]
                    existed = False
                    for item in self.__suspend_list:
                        if item[0] == cbsdID and item[1] == grantID:
                            error = 301
                            existed = True
                            self.log.warning('cbsdID %s grantID %s is already suspended' % (cbsdID, grantID))
                            break
                    if not existed:
                        for item in self.__terminate_list:
                            if item[0] == cbsdID and item[1] == grantID:
                                error = 301
                                existed = True
                                self.log.warning('cbsdID %s grantID %s is already terminated' % (cbsdID, grantID))
                                break
                    if not existed:
                        self.__terminate_list.append([cbsdID, grantID])
                        cbsd = self.__cbsd_list[cbsdID]
                        cbsd.grant_handler_cleanup(grantID)
                        self.log.info('cbsdID %s grantID %s is added to terminating list' % (cbsdID, grantID))
                else:
                    error = 101
                    self.log.warning('%s or %s is missing' % (PAR_CBSD_ID, PAR_GRANT_ID))
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_GRANT_TN: fields}

    def __mng_grant_free_dispatcher(self, mng_msg):
        # Sever management request -- grant free
        self.log.info('received grant free request from SAS Manager')
        error = 0
        if REQ_MNG_GRANT_FREE not in mng_msg:
            error = 101
        else:
            fpar = mng_msg[REQ_MNG_GRANT_FREE]
            if isinstance(fpar, dict):
                if (PAR_CBSD_ID in fpar) and (PAR_GRANT_ID in fpar):
                    cbsdID = fpar[PAR_CBSD_ID]
                    grantID = fpar[PAR_GRANT_ID]
                    existed = False
                    for item in self.__suspend_list:
                        if item[0] == cbsdID and item[1] == grantID:
                            self.__suspend_list.pop(self.__suspend_list.index(item))
                            existed = True
                            self.log.warning('cbsdID %s grantID %s is removed from suspending list' %
                                             (cbsdID, grantID))
                            break
                    if not existed:
                        for item in self.__terminate_list:
                            if item[0] == cbsdID and item[1] == grantID:
                                self.__terminate_list.pop(self.__terminate_list.index(item))
                                existed = True
                                self.log.info('cbsdID %s grantID %s is removed from terminating list' %
                                              (cbsdID, grantID))
                                break
                    if not existed:
                        error = 304
                        self.log.warning('cbsdID %s grantID %s is not suspended or not terminated' % (cbsdID, grantID))
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_GRANT_FREE: fields}

    def __mng_grant_renew_dispatcher(self, mng_msg):
        # Sever management request -- (enable or disable )grant renew
        self.log.info('received configure request of grant renewal from SAS Manager')
        error = 0
        if REQ_MNG_GRANT_RENEW not in mng_msg:
            error = 101
        else:
            val = mng_msg[REQ_MNG_GRANT_RENEW]
            if isinstance(val, int):
                if val == 1:
                    # enable grant renewal
                    if self.config.RENEW_GRANT:
                        self.config.RENEW_GRANT = True
                        self.log.info('renew_grant is enabled due to SAS Manager request')
                    else:
                        self.log.info('renew_grant is already enabled')
                elif val == 0:
                    # disable grant renewal
                    if not self.config.RENEW_GRANT:
                        self.config.RENEW_GRANT = False
                        self.log.info('renew_grant is disabled due to SAS Manager request')
                    else:
                        self.log.info('renew_grant is already disabled')
                else:
                    self.log.warning('invalid parameter in request from SAS Manager')
                    error = 102
            else:
                self.log.warning('invalid parameter in request from SAS Manager')
                error = 102

        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_GRANT_RENEW: fields}

    def __mng_transmit_renew_dispatcher(self, mng_msg):
        # Sever management request -- (enable or disable )transmit renew
        self.log.info('received configure request of transmit renewal from SAS Manager')
        error = 0
        if REQ_MNG_TRANSMIT_RENEW not in mng_msg:
            error = 101
        else:
            val = mng_msg[REQ_MNG_TRANSMIT_RENEW]
            if isinstance(val, int):
                if val == 1:
                    # enable transmit renewal
                    if self.config.RENEW_TRANSMIT:
                        self.config.RENEW_TRANSMIT = True
                        self.log.info('renew_transmit is enabled due to SAS Manager request')
                    else:
                        self.log.info('renew_transmit is already enabled')
                elif val == 0:
                    # disable transmit renewal
                    if not self.config.RENEW_TRANSMIT:
                        self.config.RENEW_TRANSMIT = False
                        self.log.info('renew_transmit is disabled due to SAS Manager request')
                    else:
                        self.log.info('renew_transmit is already disabled')
                else:
                    self.log.warning('invalid parameter in request from SAS Manager')
                    error = 102
            else:
                self.log.warning('invalid parameter in request from SAS Manager')
                error = 102

        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_TRANSMIT_RENEW: fields}

    def __mng_version_dispatcher(self, mng_msg):
        # Sever management request -- version info
        self.log.info('received version request from SAS Manager')
        error = 0
        if REQ_MNG_VERSION not in mng_msg:
            error = 101
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]},
                  'version': self.config.VERSION, 'versionInfo': self.config.VERSION_INFO}
        self.__response_msg = {RES_MNG_VERSION: fields}

    def __mng_option_block_request_dispatcher(self, mng_msg):
        # Sever management request -- option block request
        self.log.info('received block request from SAS Manager')
        error = 0
        if REQ_MNG_OPTION_BLOCK_REQUEST not in mng_msg:
            error = 101
        else:
            tag = mng_msg[REQ_MNG_OPTION_BLOCK_REQUEST]
            self.config.update_block_request(tag)
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_OPTION_BLOCK_REQUEST: fields}

    def __mng_option_connection_reject_dispatcher(self, mng_msg):
        # Sever management request -- option connection reject
        self.log.info('received connection reject from SAS Manager')
        error = 0
        if REQ_MNG_OPTION_CONNECTION_REJECT not in mng_msg:
            error = 101
        else:
            tag = mng_msg[REQ_MNG_OPTION_CONNECTION_REJECT]
            self.config.update_connection_reject(tag)
        self.__response_msg = ''
        fields = {PAR_ERROR: {PAR_ERR_CODE: error, PAR_ERR_MSG: mng_error_code_table[error]}}
        self.__response_msg = {RES_MNG_OPTION_CONNECTION_REJECT: fields}

    def response_builder(self):
        http_p = HttpRequestParser('')
        now = datetime.datetime.utcnow()
        header_date = now.strftime("Date: %a, %d %b %Y %H:%M:%S GMT")
        if self.__http_status != 200:
            header_clen = "Content-Length: 0"
            http_tuple = http_p.res_builder(status=self.__http_status, header=(header_date, header_clen), data=None,
                                            chunked=self.config.CHUNKED, chunkSize=self.config.CHUNKSIZE)
        else:
            # self.log.info('DBG:%s'%self.__response_msg)
            res_list = list(self.__response_msg.viewvalues())
            # we don't want respond any request in some cases
            if len(self.__response_msg) == 0 or len(res_list[0]) == 0:
                return None
            json_str = json.dumps(self.__response_msg)
            if self.config.CHUNKED:
                header_clen = "Transfer-Encoding: chunked"
            else:
                header_clen = "Content-Length: " + str(len(json_str))
            header_ctype = "Content-type: application/json"
            header_t = (header_date, header_clen, header_ctype)
            http_tuple = http_p.res_builder(status=self.__http_status, header=header_t, data=json_str,
                                            chunked=self.config.CHUNKED, chunkSize=self.config.CHUNKSIZE)
        return http_tuple[1]

    def cbsd_clean(self):
        self.__blist_list = []
        self.__suspend_list = []
        self.__terminate_list = []
        for cbsd_id in self.__cbsd_list.keys():
            cbsd = self.__cbsd_list[cbsd_id]
            cbsd.stop()
            self.__dereglist_add(cbsd_id)
        self.__cbsd_list.clear()
        self._dereglist = []
