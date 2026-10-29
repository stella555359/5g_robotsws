def get_dn(dn):
    pass


# Incase below not working then change it to
# prefix or psotfix polish notation to expression


def get_attr_frm_kpi_frm(kpi):
    kpi_attr = []
    flag = 0
    cntr = ''
    for i in kpi:
        if i == 'M':
            flag = 1
            cntr = 'M'
        elif i in '+-*/()' and flag == 1:
            # print('---->',cntr)
            flag = 0
            if cntr not in kpi_attr:
                cntr = cntr.strip()
                kpi_attr.append(cntr)
        elif flag == 1:
            cntr = cntr + i
    return kpi_attr


def get_kpi_attrs(kpi_txt_file):
    fp = open(kpi_txt_file)
    kpis = fp.readlines()
    fp.close()
    kpi_attrs = {}
    for kpi in kpis:
        kpi_id = kpi.split('=')
        kpi_attrs[kpi_id[0]] = get_attr_frm_kpi_frm(kpi_id[1])
    # print(kpi_attrs.keys())
    return kpi_attrs

# get_kpi_attrs()
