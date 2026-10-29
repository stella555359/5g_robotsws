strict_mode_parameters = [{"distName": "MRBTS-{}/EQM-1/APEQM-1/FHS-1/PORTMAPPING-1", "operation": "update",
                          "parameters": [
                                {"parameterName": "portsMappingToPort1", "value": ["8"], "operation": "update"},
                                {"parameterName": "portsMappingToPort2", "value": ["7"], "operation": "update"}]},
                          {"distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update",
                          "parameters": [
                                {"parameterName": "actPrefBbBoard", "value": "Strict", "operation": "update"}]},
                          {"distName": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-2", "operation": "update",
                          "parameters": [
                                {"parameterName": "bbModGroup", "value": "1", "operation": "update"}]},
                          {"distName": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-3", "operation": "update",
                          "parameters": [
                                {"parameterName": "bbModGroup", "value": "2", "operation": "update"}]},
                          {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-0", "operation": "update",
                          "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "1", "operation": "update"}]},
                          {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1", "operation": "update",
                          "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "2", "operation": "update"}]},
                          {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1", "operation": "update",
                          "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "1", "operation": "update"}]},
                          {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2", "operation": "update",
                          "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "2", "operation": "update"}]}]

override_mode_parameters = [{"distName": "MRBTS-{}/EQM-1/APEQM-1/FHS-1/PORTMAPPING-1", "operation": "update",
                            "parameters": [
                                {"parameterName": "portsMappingToPort1", "value": ["8"], "operation": "update"},
                                {"parameterName": "portsMappingToPort2", "value": ["7"], "operation": "update"}]},
                            {"distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update",
                            "parameters": [
                                {"parameterName": "actPrefBbBoard", "value": "Override", "operation": "update"}]},
                            {"distName": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-2", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroup", "value": "1", "operation": "update"}]},
                            {"distName": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-3", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroup", "value": "2", "operation": "update"}]},
                            {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-0", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "1", "operation": "update"}]},
                            {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "2", "operation": "update"}]},
                            {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "1", "operation": "update"}]},
                            {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "2", "operation": "update"}]}]

ports_mapping_fixed_parameters = [{"distName": "MRBTS-{}/EQM-1/APEQM-1/FHS-1/PORTMAPPING-1", "operation": "update",
                                  "parameters": [
                                    {"parameterName": "portsMappingToPort1", "value": ["7"], "operation": "update"},
                                    {"parameterName": "portsMappingToPort2", "value": ["8"], "operation": "update"}]}]

strict_mode_enabled = [{"distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update",
                        "parameters": [
                            {"parameterName": "actPrefBbBoard", "value": "Strict", "operation": "update"}]}]

bbModGroupTarget_changed = [{"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "2", "operation": "update"}]},
                            {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-5", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "2", "operation": "update"}]},
                            {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-8", "operation": "update",
                            "parameters": [
                                {"parameterName": "bbModGroupTarget", "value": "2", "operation": "update"}]}]

override_mode_enabled = [{"distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update",
                         "parameters": [
                            {"parameterName": "actPrefBbBoard", "value": "Override", "operation": "update"}]}]

bbModGroup_changed = [{"distName": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-3", "operation": "update",
                      "parameters": [
                            {"parameterName": "bbModGroup", "value": "1", "operation": "update"}]},
                      {"distName": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-4", "operation": "update",
                      "parameters": [
                            {"parameterName": "bbModGroup", "value": "1", "operation": "update"}]}]
