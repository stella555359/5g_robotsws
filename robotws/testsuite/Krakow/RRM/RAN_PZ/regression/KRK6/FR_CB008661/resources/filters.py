"""
File contains pcap packets filters for pacap checker.

:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com
"""

INTER_GNB_HO_PACKETS_FILTER = """
    SgNBChangeRequired {findBy { has(x2ap.SgNBChangeRequired_element) }}
    SgNBAdditionRequest {findBy { has(x2ap.SgNBAdditionRequest_element) }}
    SgNBAdditionRequestAcknowledge { findBy { has(x2ap.SgNBAdditionRequestAcknowledge_element) }
                                     verifyBy { has(nr-rrc.physCellId:=%s) }}
    SgNBChangeConfirm {findBy { has(x2ap.SgNBChangeConfirm_element) }}
    SgNBReconfigurationComplete { findBy { has(x2ap.SgNBReconfigurationComplete_element) }}
    SNStatusTransfer {findBy { has(x2ap.SNStatusTransfer_element) }}
    SNStatusTransfer {findBy { has(x2ap.SNStatusTransfer_element) }}
"""

SGNB_RELEASE_REQUIRED_FILTER = """
    SgNBReleaseRequired { findBy { has(x2ap.SgNBReleaseRequired_element) }}
"""

UE_CONTEXT_RELEASE_COMPLETE_FILTER = """
    UEContextReleaseComplete { findBy { has(f1ap.UEContextReleaseComplete_element) }}
"""

SGNB_CHANGE_REQUIRED_FILTER = """
    SgNBChangeRequired {findBy { has(x2ap.SgNBChangeRequired_element) }}
"""

SNS_STATUS_TRANSFER_FILTER = """
    SNStatusTransfer {findBy { has(x2ap.SNStatusTransfer_element) }}
"""

SGNB_ADDITION_REQUEST_FILTER = """
    SgNBAdditionRequest { findBy { has(x2ap.SgNBAdditionRequest_element) }}
"""

UE_CONTEXT_MODIFICATION_RESPONSE_FILTER = """
    UEContextModificationResponse { findBy { has(f1ap.protocolIEs:=2) }}
"""
