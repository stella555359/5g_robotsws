PDL_validation_error_when_CRG_enabled = "*Whenever LNCEL-1 having ${LNCEL-1.cellTechnology} (value: FDD) is within " \
                                        "range FDD|TDD and ${LNCEL-1.cellResourceSharingMode} (value: " \
                                        "selectiveTtiDonate) not equal to none, it is required that " \
                                        "${LNCEL-1.allowTrafficConcentration} (value: true) equal to false'*"

PDL_validation_error_when_uDTX_false_and_TC_true = "'pdl': \"Assertion not met: LNCEL(cellTechnology in range 'FDD'" \
                                                   "|'TDD' and allowTrafficConcentration = 'true') have actMicroDtx" \
                                                   " = 'true'\""
