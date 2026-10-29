from taf.analyzer.pdml import PdmlReader


def extract_l1subpool_cell_relation(filename):
    phycell_ul_subcell = {}
    l1_subcell_pool_lcr_id = {}
    with open(filename, "rb") as file_obj:
        print("Extracting data from Cell Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if "icom_5g" in root:
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


if __name__ == '__main__':
    print(extract_l1subpool_cell_relation(
        '/home/ute/CPRT_Trace/backhaul.pdml'))
    print("")
