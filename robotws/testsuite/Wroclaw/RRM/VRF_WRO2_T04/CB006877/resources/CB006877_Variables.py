pattern_csi_resource_starting_prb = r'"nr-rrc\.resourceToAddModList_tree".*?"Item 9".*?' \
                                    r'"nr-rrc\.PUCCH_Resource_element".*?' \
                                    r'"nr-rrc\.startingPRB":\s*"(\d+)"'

pattern_csi_resource_second_hop_prb = r'"nr-rrc\.resourceToAddModList_tree".*?"Item 9".*?' \
                                      r'"nr-rrc\.PUCCH_Resource_element".*?' \
                                      r'"nr-rrc\.secondHopPRB":\s*"(\d+)"'

pattern_csi_resource_starting_prb_hkf = r'"nr-rrc\.resourceToAddModList_tree".*?"Item 0".*?' \
                                        r'"nr-rrc\.PUCCH_Resource_element".*?' \
                                        r'"nr-rrc\.startingPRB":\s*"(\d+)"'

pattern_csi_resource_second_hop_hkf = r'"nr-rrc\.resourceToAddModList_tree".*?"Item 0".*?' \
                                      r'"nr-rrc\.PUCCH_Resource_element".*?' \
                                      r'"nr-rrc\.secondHopPRB":\s*"(\d+)"'
