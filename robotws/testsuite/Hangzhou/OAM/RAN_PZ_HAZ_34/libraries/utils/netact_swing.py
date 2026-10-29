def search_node_scope(gnb_name, nodes):
    bts_index = int(gnb_name.split("-")[1])
    for node in nodes:
        if node.count("MRBTS") > 0:
            if node.count("...") == 0:
                continue
            scope = node.split("-")[1].split("...").split()[0]
            min = int(scope[0])
            max = int(scope[1])
            if bts_index >= min and bts_index <= max:
                return node
    return ""


def is_mo_in_node_list(mo_name, nodes):
    for node in nodes:
        if node.count(mo_name) > 0 and node.count("...") == 0:
            return True
    return False
