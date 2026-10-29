smod_post_pattern = [r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}(?:\sok|\sna)+$",
                     r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}(?:\sok|\sna)+$",
                     r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}(?:\sok|\sna)+$"]

smod_reset_pattern = [r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.* "
                      r"System module power reset : User \(Execute reset.\)$",
                      r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.* "
                      r"PowerOn reset \(probably same as previous system module power r"
                      r"eset\) : User \(Execute reset.\)$",
                      r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.* "
                      r"'Oam' System module site reset rapid : User \(Execute reset.\)$",
                      r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.* "
                      r"'Oam' System module site reset rapid : User \(Execute reset.\)$"]

bbmod_post_pattern = [r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}(?:\sok|\sna)+$",
                      r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}(?:\sok|\sna)+$",
                      r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}(?:\sok|\sna)+$"]

bbmod_reset_pattern = [r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.* Power reset "
                       r": User \(Execute reset., Sender.*\)$",
                       r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.* "
                       r"\(probably same as previous power reset\) : User \(Exe"
                       r"cute reset., Sender.*\)$",
                       r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.* "
                       r"'Oam' Warm reset : User \(, Sender.*\)$",
                       r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z.*"
                       r"'Oam' Warm reset : User \(, Sender.*\)$"]
