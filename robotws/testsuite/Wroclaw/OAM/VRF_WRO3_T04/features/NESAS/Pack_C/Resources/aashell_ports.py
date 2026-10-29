vcu_ports1 = {"cpcl": "15007", "cpif": "15007", "cpnb": ["15007", "15057"], "cpnrt": ["15007", "15057"]}
vcu_ports2 = {"cpue": "15007", "oamasm": ["15007", "15027"], "oamcm": "15007", "oamconfig": "15007"}
vcu_ports3 = {"oamext": ["15007", "15027", "15047", "15067", "15087"], "oamfm": "15007"}
vcu_ports4 = {"oamkpianalyzer": "15007", "oampm": ["15007", "15027"]}
vcu_ports = vcu_ports1 | vcu_ports2 | vcu_ports3 | vcu_ports4

vdu_ports1 = {"cprt": ["15027", "15057"], "l2nrt": "15007", "l2rt-a": "15006", "oamasm": ["15007", "15027"]}
vdu_ports2 = {"oambb": "15007", "oamcalc": "15007", "oamcm": "15007", "oamconfig": "15007"}
vdu_ports3 = {"oamext": ["15007", "15027", "15047", "15067", "15087"], "oamfh": "15067", "oamfm": "15007"}
vdu_ports4 = {"oamkpianalyzer": "15007", "oampm": ["15007", "15027"], "oamswm": "15007"}
vdu_ports = vdu_ports1 | vdu_ports2 | vdu_ports3 | vdu_ports4
