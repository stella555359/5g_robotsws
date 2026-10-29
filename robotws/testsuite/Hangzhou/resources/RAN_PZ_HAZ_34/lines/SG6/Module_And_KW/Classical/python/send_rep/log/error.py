# --------------------
# Error code constant
# --------------------
ReturnSuccess = True
ReturnFailure = False
ReturnDefaultCode = 1000

# 1001-1100, used in Au2Analysis main program
DirFileCreateFail = 1001
DirFileNotExist = 1002
DirFileWriteFail = 1003
DirFileRemoveFail = 1004
DirFileCopyFail = 1005
DirFileRenameFail = 1006
DirFileNotMatch = 1007

# --------------------
# Error code dictionary
# --------------------
__ErrorCodeDict = {
    # Return Success
    0: "Return Success code",

    # Default return code
    1000: "Default return code",

    # 1001-1100, used in DirFile.py
    1001: "Dir File create failure",
    1002: "Dir File is not existed",
    1003: "Dir File write failure",
    1004: "Dir File remove failure",
    1005: "Dir File copy failure",
    1006: "Dir File rename failure",
    1007: "Dir File no match",


}


# ====================================================================
# Function name:GetErrorCause()
# Input: [1]ErrorCode, the value of error code defined in Constant.py
# Output: [1]p_Cause, the cause corresponding to error code
# History: [1]2010-07-30;Zhang Yehui created
# ====================================================================
def get_error_cause(error_code):
    """Get Error Cause Reason from Error code dictionary"""
    try:
        return __ErrorCodeDict[error_code]
    except BaseException:
        return "Error code '%s' Not Defined" % error_code
