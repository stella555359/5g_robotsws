from taf.analyzer.pdml import PdmlReader


def extract_l1subpool_cell_relation(filename):
    phycell_ul_subcell = {}
    l1_subcell_pool_lcr_id = {}
    with open(filename, "rb") as file_obj:
        print("Extracting data from Cell Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if "icom_5g" in root:
                # print(root)
                phycell_id = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                        "itf_l2_ps_cell_CellSetupReq_t.physCellId")
                lcr_id = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                    "itf_l2_ps_cell_CellSetupReq_t.lcrId")
                ulsubcell_pool_id = root.xpath(
                    "icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//itf_l2_ps_ulsubcell//*")
                if len(phycell_id) != 0:
                    phycell_id = int(phycell_id[0].show)
                    lcr_id = int(lcr_id[0].show)
                    for item in ulsubcell_pool_id:
                        if "l1SubPoolId" in str(item.showname):
                            l1_pool_id = item.show
                            phycell_ul_subcell[phycell_id] = int(l1_pool_id)
                            if l1_subcell_pool_lcr_id.get(int(l1_pool_id)) is not None:
                                l1_subcell_pool_lcr_id[int(
                                    l1_pool_id)].append(lcr_id)
                            else:
                                l1_subcell_pool_lcr_id[int(l1_pool_id)] = [
                                    lcr_id]
                            break
    return l1_subcell_pool_lcr_id, phycell_ul_subcell


def extract_sa_param_cellsetup_relation(filename, debug=False):
    """SA case"""
    cellsetupreq = {}
    cellsetupreqconfig = []
    with open(filename, "rb") as file_obj:
        print("Extracting data from cell Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if debug:
                print(root)
            if "icom_5g" in root:
                physCellId = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                        "itf_l2_ps_cell_CellSetupReq_t.physCellId")
                nrCellIdentity = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                            "itf_l2_ps_cell_CellSetupReq_t.nrCellIdentity")
                coresetFreqDomain = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                               "itf_l2_ps_pdcch_ControlResourceSet.coresetFreqDomain")
                csirsTrackingStartingPrb = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                                      "itf_l2_ps_cell_CsiRsTracking.csirsTrackingStartingPrb")
                csirsTrackingNumOfPrbs = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                                    "itf_l2_ps_cell_CsiRsTracking.csirsTrackingNumOfPrbs")
                if len(nrCellIdentity) != 0:
                    _physCellId = int(physCellId[0].show)
                    _nrCellIdentity_id = int(nrCellIdentity[0].show)
                    _coresetFreqDomain = int(coresetFreqDomain[0].show)
                    _coresetFreqDomain_bin = bin(int(coresetFreqDomain[0].show))
                    _coresetFreqDomain_bin_64bits = bin(int(coresetFreqDomain[0].show))[2:].zfill(64)
                    _coresetFreqDomain_hex = hex(int(_coresetFreqDomain_bin_64bits, 2))[2:].zfill(16)
                    _csirsTrackingStartingPrb = int(csirsTrackingStartingPrb[0].show)
                    _csirsTrackingNumOfPrbs = int(csirsTrackingNumOfPrbs[0].show)
                    cellsetupreq = {'cellId': _nrCellIdentity_id,
                                    'physCellId': _physCellId,
                                    'coresetFreqDomain': _coresetFreqDomain,
                                    'coresetFreqDomain_hex': '0x'+_coresetFreqDomain_hex,
                                    'coresetFreqDomain_bin_64bits': _coresetFreqDomain_bin_64bits,
                                    'csirsTrackingStartingPrb': _csirsTrackingStartingPrb,
                                    'csirsTrackingNumOfPrbs': _csirsTrackingNumOfPrbs}
                    cellsetupreqconfig.append(cellsetupreq)
    cellsetupreq_config = cellsetupreqconfig
    cellsetupreq_config_Sorted = sorted(cellsetupreq_config, key=lambda p: p['cellId'])

    return cellsetupreq_config_Sorted


if __name__ == '__main__':
    # print(extract_l1subpool_cell_relation('/home/ute/csamson/TRACES/l2_l3_cellinitial_syscom_tcpdump.pdml'))
    print(extract_sa_param_cellsetup_relation('/home/ute/csamson/TRACES/cellinitial/l2_l3_syscom_tcpdump.pdml'))
    print("")
