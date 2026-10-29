from .smengine.SmEngineInterface import SmEngineInterface

_smEngineInterface = SmEngineInterface(
    r"/home/localuser/NPS_IV_Ispeed5g/robotws5g/resources/NPS_IV/Cockpit/UseCaseDetector")
_smEngineInterface.getStateMachinesInfo(("feature523_1_on.sm",))
_smEngineInterface.launchSmAnalysis(
    r"/home/localuser/FEATURE_523_220190322-17h43m08s/Preparation/UseCaseDetector/")
print("sm Analysis done")
