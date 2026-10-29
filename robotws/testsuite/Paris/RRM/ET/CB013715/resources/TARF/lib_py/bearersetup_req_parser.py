from taf.analyzer.pdml import PdmlReader
from enum_req_parser import return_UeAddCause_enum, return_allowedPdcchPowerBoostALDue_enum


def extract_pdcch_power_boost_param_bearer_relation(filename, debug=False):
    """SA case"""
    bearersetupreq = {}
    bearersetupreqconfig = []
    with open(filename, "rb") as file_obj:
        print("Extracting data from bearer Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if debug:
                print(root)
            if "icom_5g" in root:
                # ueAddCause = root.xpath("icom_5g//psuser//itf_l2_ps_user_bearersetupreq//"
                #                        "itf_l2_ps_user_BearerSetupReq_t.ueAddCause")
                # ueAddCause = root.xpath("icom_5g//psuser//itf_l2_ps_user_usersetupreq//"
                #                         "itf_l2_ps_user_usersetupreq_t//itf_l2_ps_user_UserSetupReq_t.ueAddCause")
                nrCellIdentity = root.xpath("icom_5g//psuser//itf_l2_ps_user_bearersetupreq//"
                                            "itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity")
                rnti = root.xpath("icom_5g//psuser//itf_l2_ps_user_bearersetupreq//_3gpp.rnti")
                qosId = root.xpath("icom_5g//psuser//itf_l2_ps_user_bearersetupreq//"
                                   "itf_l2_ps_user_bearersetupreq_t//itf_l2_ps_DrbAddReqPs.qosId")
                allowedPdcchPowerBoostALDueCfg = root.xpath("icom_5g//psuser//itf_l2_ps_user_bearersetupreq//"
                                                            "itf_l2_ps_user_bearersetupreq_t//"
                                                            "itf_l2_ps_DrbAddReqPs.allowedPdcchPowerBoostALDueCfg")
                allowedPdcchPowerBoostALDueCce = root.xpath("icom_5g//psuser//itf_l2_ps_user_bearersetupreq//"
                                                            "itf_l2_ps_user_bearersetupreq_t//"
                                                            "itf_l2_ps_DrbAddReqPs.allowedPdcchPowerBoostALDueCce")
                if len(nrCellIdentity) != 0:
                    _nrCellIdentity_id = int(nrCellIdentity[0].show)
                    # _ueAddCause = return_UeAddCause_enum(int(ueAddCause[0].show))
                    _rnti_id = int(rnti[0].show)
                    _phycell_id = _nrCellIdentity_id - 16385
                    _qos_id = int(qosId[0].show)
                    _allowedPdcchPowerBoostALDueCfg = \
                        return_allowedPdcchPowerBoostALDue_enum(int(allowedPdcchPowerBoostALDueCfg[0].show))
                    _allowedPdcchPowerBoostALDueCce = \
                        return_allowedPdcchPowerBoostALDue_enum(int(allowedPdcchPowerBoostALDueCce[0].show))

                    bearersetupreq = {'cellId': _nrCellIdentity_id,
                                      'phycell_id': _phycell_id,
                                      'rnti': _rnti_id,
                                      'qos': _qos_id,
                                      'allowedPdcchPowerBoostALDueCfg': _allowedPdcchPowerBoostALDueCfg,
                                      'allowedPdcchPowerBoostALDueCce': _allowedPdcchPowerBoostALDueCce}

                    bearersetupreqconfig.append(bearersetupreq)
    bearersetupreq_config = bearersetupreqconfig
    bearersetupreq_config_Sorted = sorted(bearersetupreq_config, key=lambda p: p['cellId'])

    return bearersetupreq_config_Sorted


if __name__ == '__main__':
    print(extract_pdcch_power_boost_param_bearer_relation('/home/ute/csamson/TRACES/l2_l3_syscom_tcpdump.pdml',
                                                          False))
    # print(extract_pdcch_power_boost_param_bearer_relation(
    #     '/home/ute/csamson/TRACES/SA/l2_l3_syscom_tcpdump_1msg_2.pdml', True))
    # print(extract_pdcch_power_boost_param_bearer_relation(
    #     '/home/ute/csamson/TRACES/l2_l3_syscom_tcpdump_1msg.pdml'))
    print("")
