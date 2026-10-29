from taf.analyzer.pdml import PdmlReader
from enum_req_parser import return_UeAddCause_enum, return_allowedPdcchPowerBoostALDue_enum


def extract_pdcch_power_boost_param_bearer_relation(filename, debug=False):
    """NSA case"""
    bearersetupreq = {}
    bearersetupreqconfig = []
    with open(filename, "rb") as file_obj:
        print("Extracting data from user Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if debug:
                print(root)
            if "icom_5g" in root:
                ueAddCause = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                        "itf_l2_ps_user_UserSetupReq_t.ueAddCause")
                nrCellIdentity = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                            "itf_l2_ps_CellConfigParam_t.nrCellIdentity")
                ueIdDu = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                    "itf_l2_ps_user_UserSetupReq_t.ueIdDu")
                qosId = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                   "itf_l2_ps_drbaddreqps//itf_l2_ps_DrbAddReqPs.qosId")
                allowedPdcchPowerBoostALDueCfg = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                                            "itf_l2_ps_user_usersetupreq_t//"
                                                            "itf_l2_ps_DrbAddReqPs.allowedPdcchPowerBoostALDueCfg")
                allowedPdcchPowerBoostALDueCce = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                                            "itf_l2_ps_user_usersetupreq_t//"
                                                            "itf_l2_ps_DrbAddReqPs.allowedPdcchPowerBoostALDueCce")
                if len(nrCellIdentity) != 0:
                    _nrCellIdentity_id = int(nrCellIdentity[0].show)
                    _ueAddCause = return_UeAddCause_enum(int(ueAddCause[0].show))
                    _ueIdDu = int(ueIdDu[0].show)
                    _phycell_id = _nrCellIdentity_id - 16385
                    _qos_id = int(qosId[0].show)
                    _allowedPdcchPowerBoostALDueCfg = \
                        return_allowedPdcchPowerBoostALDue_enum(int(allowedPdcchPowerBoostALDueCfg[0].show))
                    _allowedPdcchPowerBoostALDueCce = \
                        return_allowedPdcchPowerBoostALDue_enum(int(allowedPdcchPowerBoostALDueCce[0].show))

                    bearersetupreq = {'cellId': _nrCellIdentity_id,
                                      'ueAddCause': _ueAddCause,
                                      'phycell_id': _phycell_id,
                                      'ueIdDu': _ueIdDu,
                                      'qos': _qos_id,
                                      'allowedPdcchPowerBoostALDueCfg': _allowedPdcchPowerBoostALDueCfg,
                                      'allowedPdcchPowerBoostALDueCce': _allowedPdcchPowerBoostALDueCce}

                    bearersetupreqconfig.append(bearersetupreq)
    bearersetupreq_config = bearersetupreqconfig
    bearersetupreq_config_Sorted = sorted(bearersetupreq_config, key=lambda p: p['cellId'])

    return bearersetupreq_config_Sorted


def extract_sa_param_user_relation(filename, ncell_ref=16385, debug=False):
    """SA case"""
    usersetupreq = {}
    usersetupreqconfig = []
    with open(filename, "rb") as file_obj:
        print("Extracting data from user Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if debug:
                print(root)
            if "icom_5g" in root:
                ueAddCause = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                        "itf_l2_ps_user_UserSetupReq_t.ueAddCause")
                nrCellIdentity = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                            "itf_l2_ps_CellConfigParam_t.nrCellIdentity")
                ueIdDu = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                    "itf_l2_ps_user_UserSetupReq_t.ueIdDu")
                rnti = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//_3gpp.rnti")
                freqDomainPosition = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                                "itf_l2_ps_srsresource//"
                                                "itf_l2_ps_SrsResource.freqDomainPosition")
                freqDomainShift = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                             "itf_l2_ps_srsresource//"
                                             "itf_l2_ps_SrsResource.freqDomainShift")
                c_SRS = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                   "itf_l2_ps_freqhopping//"
                                   "itf_l2_ps_FreqHopping.c_SRS")
                b_SRS = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                   "itf_l2_ps_freqhopping//"
                                   "itf_l2_ps_FreqHopping.b_SRS")
                b_hop = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                                   "itf_l2_ps_freqhopping//"
                                   "itf_l2_ps_FreqHopping.b_hop")
                if len(nrCellIdentity) != 0:
                    _nrCellIdentity_id = int(nrCellIdentity[0].show)
                    _ueAddCause = return_UeAddCause_enum(int(ueAddCause[0].show))
                    _ueIdDu = int(ueIdDu[0].show)
                    _phycell_id = _nrCellIdentity_id - ncell_ref
                    _rnti_id = int(rnti[0].show)
                    _freqDomainPosition = int(freqDomainPosition[0].show)
                    _freqDomainShift = int(freqDomainShift[0].show)
                    _c_SRS = int(c_SRS[0].show)
                    _b_SRS = int(b_SRS[0].show)
                    _b_hop = int(b_hop[0].show)
                    usersetupreq = {'cellId': _nrCellIdentity_id,
                                    'ueAddCause': _ueAddCause,
                                    'phycell_id': _phycell_id,
                                    'ueIdDu': _ueIdDu,
                                    'rnti': _rnti_id,
                                    'freqDomainPosition': _freqDomainPosition,
                                    'freqDomainShift': _freqDomainShift,
                                    'c_SRS': _c_SRS,
                                    'b_SRS': _b_SRS,
                                    'b_hop': _b_hop}
                    usersetupreqconfig.append(usersetupreq)
    usersetupreq_config = usersetupreqconfig
    usersetupreq_config_Sorted = sorted(usersetupreq_config, key=lambda p: p['cellId'])

    return usersetupreq_config_Sorted


if __name__ == '__main__':
    print(extract_sa_param_user_relation('/home/ute/csamson/TRACES/l2_l3_syscom_tcpdump.pdml', 32769))
    # print(extract_pdcch_power_boost_param_bearer_relation('/home/ute/csamson/TRACES/l2_l3_syscom_tcpdump_1msg.pdml'))
    print("")
