from bs4 import BeautifulSoup
import re
import os


def verify_if_SRS_is_enabled(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
    srs_enable_list = xml_tree.find_all('proto', attrs={'name': 'uldata_srsreceivereq'})
    if not srs_enable_list:
        raise Exception("Check failed - srs_enable_list is empty")
    for record in srs_enable_list:
        srs_info = int(record.find('field', attrs={'name': re.compile('srsBmEnable')}).get('show'))
        if srs_info != 1:
            raise Exception("Check failed")


def verify_if_SRS_is_disabled(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
    srs_enable_list = xml_tree.find_all('proto', attrs={'name': 'uldata_srsreceivereq'})
    if not srs_enable_list:
        raise Exception("Check failed - srs_enable_list is empty")
    for record in srs_enable_list:
        srs_info = int(record.find('field', attrs={'name': re.compile('srsBmEnable')}).get('show'))
        if srs_info == 1:
            raise Exception("Check failed")


def get_mcs_for_pattern(pdml_path):
    patternId_item = []
    mcs = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        pdsch_resources = xml_tree.find_all('proto', attrs={'name': 'nr_l1dl_l2ps_dldata_pdschsendreq_t'})
        for pdsch in pdsch_resources:
            patternId_item.append(int(pdsch.find('field', attrs={'name': re.compile('patternId_item')}).get('show')))
            mcs.append(int(pdsch.find('field', attrs={'name': re.compile('mcs')}).get('show')))
            print(list)
    return list(zip(patternId_item, mcs))


def verify_mcs_for_targetload(pdml_path, patternId, mcs=27):
    actual_values = get_mcs_for_pattern(pdml_path)
    for item in actual_values:
        if int(item[0]) == patternId:
            if int(item[1]) == mcs:
                print("Check passed, For patternId mcs is correct")
            else:
                print(item[1])
                print(item[0])
            raise Exception("Check failed, incorrect number of PRB")


def get_slot_sfn_for_csirs(pdml_path):
    csirs_slot = []
    csirs_sfn = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        csirs_resources = xml_tree.find_all('proto', attrs={'name': 'dldata_csirssendreq'})
        for pdsch in csirs_resources:
            csirs_slot.append(int(pdsch.find('field', attrs={'name': re.compile('slot')}).get('show')))
            csirs_sfn.append(int(pdsch.find('field', attrs={'name': re.compile('sfn')}).get('show')))
            print(list)
    return list(zip(csirs_slot, csirs_sfn))


def get_slot_sfn_prb_for_pdsch(pdml_path):
    slot_num = []
    sfn_num = []
    prb = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        pdsch_tags = xml_tree.find_all('proto', attrs={'name': 'dldata_pdschsendreq'})
        for pdsch_tags in pdsch_tags:
            slot_num.append(pdsch_tags.find('field', attrs={'name': re.compile('slot')}).get('show'))
            sfn_num.append(pdsch_tags.find('field', attrs={'name': re.compile('sfn')}).get('show'))
            prb.append(pdsch_tags.find('field', attrs={'name': re.compile('numOfPrb')}).get('show'))
    return list(zip(slot_num, sfn_num, prb))


def get_patternId_and_PRB(pdml_path, bip_mesg):
    patternId_item = []
    num_prb = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        pdsch_resources = xml_tree.find_all('proto', attrs={'name': bip_mesg})
        for pdsch in pdsch_resources:
            patternId_item.append(int(pdsch.find('field', attrs={'name': re.compile('patternId_item')}).get('show')))
            num_prb.append(int(pdsch.find('field', attrs={'name': re.compile('numOfPrb')}).get('show')))
    return list(zip(patternId_item, num_prb))


def verify_PRB_for_patternId(pdml_path, patternId, num_prb, bip_mesg='nr_l1dl_l2ps_dldata_pdschsendreql1sw_t'):
    actual_values = get_patternId_and_PRB(pdml_path, bip_mesg=bip_mesg)
    pattern_match = 0
    for item in actual_values:
        if int(item[0]) == int(patternId):
            pattern_match += 1
            if int(item[1]) > int(num_prb):
                raise Exception(f"Check failed, incorrect number of PRB={item[1]} for pattern{item[0]}")
    if pattern_match == 0:
        raise Exception("Check failed, no match for given pattern id")


def get_subcellid_and_PRB(pdml_path, bip_mesg):
    subcellid = []
    num_prb = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        pdsch_resources = xml_tree.find_all('proto', attrs={'name': bip_mesg})
        for pdsch in pdsch_resources:
            subcellid.append(int(pdsch.find('field', attrs={'name': re.compile('subcellid')}).get('show')))
            num_prb.append(int(pdsch.find('field', attrs={'name': re.compile('numOfPrb')}).get('show')))
    return list(zip(subcellid, num_prb))


def verify_PRB_for_subcellid(pdml_path, subcellid, num_prb, bip_mesg='nr_l1dl_l2ps_dldata_pdschsendreq_t'):
    actual_values = get_subcellid_and_PRB(pdml_path, bip_mesg=bip_mesg)
    subcellid_match = 0
    for item in actual_values:
        if int(item[0]) == int(subcellid):
            subcellid_match += 1
            if int(item[1]) > int(num_prb):
                raise Exception(f"Check failed, incorrect number of PRB={item[1]} for subcell={item[0]}")
    if subcellid_match == 0:
        raise Exception("Check failed, no match for given subcellid")


def verify_num_of_prb_for_trs_slot(pdml_path, prb=120):
    value_csirs = get_slot_sfn_for_csirs(pdml_path)
    value_pdsch = get_slot_sfn_prb_for_pdsch(pdml_path)
    for item in value_pdsch:
        for item_csirs in value_csirs:
            if int(item[0]) == int(item_csirs[0]):
                if int(item[1]) == int(item_csirs[1]):
                    if int(item[2]) <= prb:
                        print("Check passed, For TRS number of PRB is <= expect value")
                    else:
                        print(item[0])
                        print(item[1])
                        print(item[2])
                        raise Exception("Check failed, incorrect number of PRB")


def check_file_size(file_path):
    file_size = os.path.getsize(file_path)
    if file_size == 0:
        raise Exception("File size equal to 0")
