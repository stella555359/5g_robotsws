RRC_Reconfiguration_Complete = \
    f"""
    (RRCReconfigurationComplete contains
        (rrcReconfigurationComplete is present)
    )
    """


def get_SgNBAddition_message_flow_filters(physcellid):
    filters = {}
    PSCellID_in_SgNBAdditionRequest = \
        f"""
        (CG-ConfigInfo contains
            (candidateCellInfoListMN contains
                (measResultNeighCellListNR contains
                    (physCellId eq {physcellid})
                )
            )
        )
        """
    filters["PSCellID_in_SgNBAdditionRequest"] = PSCellID_in_SgNBAdditionRequest
    UECapa_in_UEContextSetupRequest = \
        f"""
        (CG-ConfigInfo contains
            (ue-CapabilityInfo contains
                (length(CONTAINING) eq 2
                and CONTAINING contains (rat-Type eq "nr")
                and CONTAINING contains (rat-Type eq "eutra-nr")
                )
            )
        )
        """
    UECapa_and_PSCellId_in_UEContextSetupRequest = f"{PSCellID_in_SgNBAdditionRequest} and " \
                                                   f"{UECapa_in_UEContextSetupRequest}"
    filters["UECapa_and_PSCellID_in_UEContextSetupRequest"] = UECapa_and_PSCellId_in_UEContextSetupRequest
    PSCellID_in_RRC_Reconfiguration = \
        f"""
        (spCellConfig contains
            (reconfigurationWithSync contains
                (spCellConfigCommon contains
                    (physCellId eq {physcellid})
                )
            )
        )
        """
    PSCellID_in_UEContextSetupResponse = \
        f"""
        (DUtoCURRCInformation contains
            (CellGroupConfig contains
                {PSCellID_in_RRC_Reconfiguration}
            )
        )
        """
    filters["PSCellID_in_UEContextSetupResponse"] = PSCellID_in_UEContextSetupResponse
    PSCellID_in_SgNBAdditionRequestAck = \
        f"""
        (SgNBtoMeNBContainer contains
            (CG-Config contains
                (scg-CellGroupConfig contains
                    (rrcReconfiguration contains
                        (secondaryCellGroup contains
                            (CONTAINING contains
                                {PSCellID_in_RRC_Reconfiguration}
                            )
                        )
                    )
                )
            )
        )
        """
    filters["PSCellID_in_SgNBAdditionRequestAck"] = PSCellID_in_SgNBAdditionRequestAck
    RRCReconfCmp_in_SgNBReconfCmp = \
        f"""
        (ResponseInformationSgNBReconfComp contains
            (success-SgNBReconfComp contains
                (meNBtoSgNBContainer contains
                    {RRC_Reconfiguration_Complete}
                )
            )
        )
        """
    filters["RRCReconfCmp_in_SgNBReconfCmp"] = RRCReconfCmp_in_SgNBReconfCmp
    return filters
