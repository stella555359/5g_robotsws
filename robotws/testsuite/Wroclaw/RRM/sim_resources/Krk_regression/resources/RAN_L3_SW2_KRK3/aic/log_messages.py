UE_BULK_RELEASE_MSG = r"""UeBulkReleaseService.cpp:[0-9]+ Process CpUePartialResetInd, """ \
                      r"""transactionId:[0-9]+, cause.*(haRecovery|upInitiatedE1Reset)"""
F1_RESET_PROCEDURE_MSG = r"""F1ResetProcedureCu.cpp:[0-9]+ """ \
                         r"""Reset with transactionId: [0-9]+ of gnbDuId:[0-9]+ succeeded"""
E1_RESET_EXECUTOR_MSG = r"""E1SctpSender.cpp:[0-9]+ Sending E1Reset"""
NG_RESET_PROCEDURE_MSG = r"""NgResetProcedure.cpp:[0-9]+ .*NG reset initiated"""

CPUE_UE_RELEASE_MSG_LIST = ["{msg}::{timeout}::".format(msg=UE_BULK_RELEASE_MSG, timeout="30s")]
CPIF_LINKS_RESET_MSG_LIST = [
    "{msg}::{timeout}::".format(msg=F1_RESET_PROCEDURE_MSG, timeout="30s"),
    "{msg}::{timeout}::".format(msg=E1_RESET_EXECUTOR_MSG, timeout="30s"),
    "{msg}::{timeout}::".format(msg=NG_RESET_PROCEDURE_MSG, timeout="30s")
]
