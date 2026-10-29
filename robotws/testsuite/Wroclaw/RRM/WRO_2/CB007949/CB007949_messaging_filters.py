csi_rs_and_aCSI_for_PCell_in_RRC_RECONFIGURATION = \
    """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-IM-ResourceToAddModList is not present
            and
            nzp-CSI-RS-ResourceToAddModList is not present
            and
            nzp-CSI-RS-ResourceSetToAddModList is not present
            and
            aperiodicTriggerStateList is not present
            and
            csi-ReportConfigToAddModList contains (reportConfigId ne 1)
            and
            csi-ReportConfigToReleaseModList is not present
        )
    )
    """
PCell_csi_rs_and_aCSI_after_SCell_Addition = \
    """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-IM-ResourceToAddModList is present and length(csi-IM-ResourceToAddModList) eq 2
            and
            csi-IM-ResourceToAddModList contains
            (
               csi-IM-ResourceId eq 0
            )
            and
            csi-IM-ResourceToAddModList contains
            (
               csi-IM-ResourceId eq 1
            )
            and
            nzp-CSI-RS-ResourceToAddModList is present and length(nzp-CSI-RS-ResourceToAddModList) ge 2
            and
            nzp-CSI-RS-ResourceToAddModList contains
            (
               nzp-CSI-RS-ResourceId eq 0
            )
            and
            nzp-CSI-RS-ResourceToAddModList contains
            (
               nzp-CSI-RS-ResourceId eq 181
            )
            and
            aperiodicTriggerStateList is not present
        )
    )
    """
SCells_csi_rs_and_aCSI_after_SCell_Addition = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 2
    and
    sCellToAddModList contains
    (
        sCellIndex eq 1
        and
        nzp-CSI-RS-ResourceToAddModList is present and length(nzp-CSI-RS-ResourceToAddModList) ge 1
        and
        nzp-CSI-RS-ResourceToAddModList contains
        (
           nzp-CSI-RS-ResourceId eq 0
        )
        and
        csi-IM-ResourceToAddModList is present and length(csi-IM-ResourceToAddModList) eq 1
        and
        csi-IM-ResourceToAddModList contains
        (
           csi-IM-ResourceId eq 0
        )
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 2
        and
        nzp-CSI-RS-ResourceToAddModList is present and length(nzp-CSI-RS-ResourceToAddModList) ge 1
        and
        nzp-CSI-RS-ResourceToAddModList contains
        (
           nzp-CSI-RS-ResourceId eq 0
        )
        and
        csi-IM-ResourceToAddModList is present and length(csi-IM-ResourceToAddModList) eq 1
        and
        csi-IM-ResourceToAddModList contains
        (
           csi-IM-ResourceId eq 0
        )
    )
    """
added_SCells_for_TTT_CA_b77_in_RRC_Reconfiguration = \
    """
    sCellToAddModList contains
    (
        sCellIndex eq 1
        and sCellConfigCommon contains (physCellId eq 53)
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 2
        and sCellConfigCommon contains (physCellId eq 55)
    )
  """
PCell_and_SCell1_csi_rs_and_aCSI_after_SCell2_Release = \
    """
    spCellConfig contains
    (
       csi-MeasConfig contains
       (
          nzp-CSI-RS-ResourceToAddModList is not present
          and
          csi-IM-ResourceToAddModList is not present
          and
          aperiodicTriggerStateList is not present
       )
    )
    and
    sCellToAddModList is not present
    and
    sCellToReleaseList is present and length(sCellToReleaseList) eq 1
    and
    sCellToReleaseList contains (2)
   """

pCSI_enabled_after_RRC_setup = \
    """
   uplinkBWP-ToAddModList contains
    (
        pucch-Config contains
        (
            resourceToAddModList contains
            (
                pucch-ResourceId eq 9
            )
            and (not resourceToAddModList contains (pucch-ResourceId eq 18))
            and multi-CSI-PUCCH-ResourceList is present
            and length(multi-CSI-PUCCH-ResourceList) eq 1
            and multi-CSI-PUCCH-ResourceList contains (9)
        )
    )
    """


def create_pCSI_after_TT_SCell_addition_filter(starting_prb):
    pCSI_enabled_after_TT_SCell_addition = \
        """
          uplinkBWP-ToAddModList contains
         (
           pucch-Config contains
           (
               resourceToAddModList contains
                (
                  pucch-ResourceId eq 19
                  and startingPRB eq {}
                )
              and resourceToAddModList contains
              (
                 pucch-ResourceId eq 21
                 and startingPRB eq {}
              )
              and (not resourceToAddModList contains (pucch-ResourceId eq 20))
              and (not resourceToAddModList contains (pucch-ResourceId eq 22))
              and multi-CSI-PUCCH-ResourceList is not present
           )
         )
    """
    return pCSI_enabled_after_TT_SCell_addition.format(starting_prb, starting_prb)


pCSI_enabled_after_SCell2_release = \
    """
   uplinkBWP-ToAddModList contains
  (
    pucch-Config contains
    (
        resourceToReleaseList is present
        and length(resourceToReleaseList) eq 1
        and resourceToReleaseList contains (21)
        and multi-CSI-PUCCH-ResourceList is not present
    )
 )
   """
