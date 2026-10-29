def prb_check(prb, num_of_prb_list):
    return prb in num_of_prb_list


def check_dmrs(dmrs: dict) -> bool:
    check = False
    for key in dmrs:
        if 'additionalDMRS:' in dmrs[key]:
            if dmrs[key]['additionalDMRS:'] == 'true':
                check = True
            else:
                check = False
                break
    return check
