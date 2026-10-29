#!/usr/bin/python
# _*_ coding:utf-8 _*_

def get_nsa_ue_crnti(crnti_list):
    list_len = len(crnti_list)
    ue_crnti_list = []
    if list_len != 0:
        for i in crnti_list:
            if i not in ue_crnti_list:
                if i != 0:
                    ue_crnti_list.append(i)
                else:
                    continue
            else:
                continue
    else:
        print("input list in null")
    return ue_crnti_list


if __name__ == "__main__":
    crnti_list = [22420, 0, 16869, 0, 62307, 16869, 22420, 22420, 62307, 62307, 16869]
    c_list = get_nsa_ue_crnti(crnti_list)
    print(list)
