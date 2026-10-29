# -*- coding: utf-8 -*


def diff_list(list):
    """
    Author: Su Li
    get the list interval
    :param list:
    :return: the interval list
    """
    diff = [list[i + 1] - list[i] for i in range(len(list) - 1)]
    return diff


# uci changes from 7 bits to 8 bits ad SR is added
# Rank is in the second space and PMI is in NO 3&4
def get_rank_pmi_from_uci(uci):
    """
    Author: Su Li
    get the rank and pmi from the message pucchreceiverrespps uciBits
    :param uci:the PUCCH uciBits
    :return: rank and pmi
    """
    uci_1 = map(lambda x: x[0:1], uci)
    uci_2 = map(lambda x: int(x, 16), uci_1)
    uci_3 = map(lambda x: format(x, 'b'), uci_2)
    rank_pmi = map(lambda x: x.zfill(4), uci_3)
    # print uci_1, uci_2, uci_3, rank_pmi
    rank = map(lambda x: int(x[1], 10) + 1, rank_pmi)
    pmi = map(lambda x: (int(x[2], 10)) * 2 + int(x[3], 10), rank_pmi)
    return [rank, pmi]


def get_rank_pmi_from_pdsch(ranklist):
    """
    Author: Su Li
    get the rank or pmi value from psdchsendreq numOfLayers or codebook
    :param ranklist: PDSCH numOfLayers or codebook
    :return: rank or pmi value
    """
    rank = map(lambda x: int(x[-1]), ranklist)
    return rank


def sort_string_list(list):
    """
    Author: Su Li
    sort the string list
    :param list:
    :return: new list
    """
    new_list = sorted(map(int, list))
    return new_list
