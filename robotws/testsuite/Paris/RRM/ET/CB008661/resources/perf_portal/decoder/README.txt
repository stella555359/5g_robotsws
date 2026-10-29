Decoder option configuration for Performance Portal

A. Overview

This check tool, included in perf_portal.py script, uses the TimeMarkerKPI results to detect big degradations in customers' stable releases.

It checks differents things:
    1. threshold_value: if a KPI value (max, 95p...) exceeds a fixed threshold value for a specific (sub-)component
    2. under_threshold: if a KPI value is under a fixed value. Need to have at least for Total, totalScheduler , preScheduler, tdScheduler, fdScheduler and postScheduler
    3. max_cpu_increase: if a KPI value (max, 95p...) exceeds above a fixed percentage the value of the last previous (reference) successful run of the same test on the same branch
        - for a test not yet merged on master, we retrieve the last previous (reference) successful run from the parent commit (including the parent) of the same test on the parent branch
    4. max_marker_duration: if marker duration duration KPI (max, 95p...) exceeds a fixed value for L2PSUL only
    5. min_cs1_list: if cs1_list KPI is under a fixed value for L2PSUL and L2PSDL (but message is not write on gerrit)
    6. min_cs2_list: if cs1_list KPI is under a fixed value for L2PSUL and L2PSDL (but message is not write on gerrit)
    7. duration: into logger component (same level as L2PSUL and L2PSDL), check if logger duration is lower as value.
    8. max_boxplot_increase: specific for Endurance, compute mean for all group of test for this commit and previous one and check if percent increase is upper than value

On every issue detected perf_portal.py:
    - send a email to the Office365 group I_MN_5GSC_SW_ENG_PERF_PORTAL_ALARM
    - send a comment to the related Gerrit review if ZUUL_CHANGE environment variable exists

It works only for all releases for the following TestType:
    - Check/Gate: Jenkins jobs SCT_TARGET.abil (until 5G19) and SCT.simple.abil (from 5G19A)
    - Post: Jenkins jobs SCT_TARGET_post.abil (until 5G19) and SCT.performance.abil (from 5G19A)

It does NOT fail the related Jenkins jobs except for:
    - L2PSDL.max threshold_value
    - L2PSUL.max threshold_value
    - L2PSDL.Scheduler.fdScheduler.95p max_cpu_increase
    - L2PSDL.Scheduler.fdScheduler.95p max_cpu_increase


B. Usage

The cpu increase and upper thresholds are defined in JSON files in this current folder (uplane/ci-scripts/perf_portal/threshold).
The JSON files used by default is threshold_scheduler.json, unless a file exists for a specific branch (ex: 5G19_threshold_scheduler.json)
If you want us to add new kpi, new component, or a new threshold file for a specific branch, please contact I_MN_5GSC_SW_ENG_PERF_PORTAL.

JSON structure is on three levels:
    1. component/sub-components dictionaries with delimiter {}
       Ex: Here component L2PSUL (total processing) key includes Scheduler (total scheduler) key which includes fdScheduler key, i.e. L2PSUL.Scheduler.fdScheduler
       "L2PSUL": {
         ...
         "Scheduler": {
           ...
           "fdScheduler": {
             ...
           }
         }
       }
    2. KPI lists with delimiter []
       Ex: Here max and 95p KPI keys (containing lists) are defined for L2PSUL (total processing) key, i.e. L2PSUL.max and L2PSUL.95p
       "L2PSUL": {
         "max": [
           ...
         ],
         "95p": [
           ...
         ]
       }
    3. threshold_value, max_cpu_increase, max_marker_duration keys defining thresholds + test parameters
       Ex: Here threshold_value is 125 for TTIDuration (test parameter) 125 for max KPI key for L2PSUL (total processing) key, i.e. L2PSUL.max
       "L2PSUL": {
         "max": [
           "TTIDuration": "125",
           "threshold_value": "125"
         ]
       }
       NB: We can overload a check and if a test match several categories of level 3, then ONLY the last one is checked


C. Example

"Middleware": {
  "totalProcessing": {
    "max": [
      {
        "TTIDuration": "125",
        "threshold_value": "100"
      },
      {
        "TTIDuration": "500",
        "threshold_value": "400"
      },
      {
        "TTIDuration": "500",
        "CCNumber" : "4",
        "threshold_value": "450"
      }
    ],
    "95p": [
      {
        "max_cpu_increase": "10"
      }
    ]
  }
}

This means for Middleware.totalProcessing component:
    - the value of the max kpi for all tests which have a TTIDuration of 125us should not exceed 100us.
    - the value of the max kpi for all tests which have a TTIDuration of 500us should not exceed 400us.
    - the value of the max kpi for all tests which have a TTIDuration of 500us a CCNumber of 4 should not exceed 450us. (overload case)
    - the cpu consumption of any test for 95p value should not exceed 10% in comparison to the last test of the same type.

So we send alarm e-mails and send gerrit comments if (for example):
    - ft000_1BM_1CC_1UE_1UEsched_TDD125_ABIL_SA test has Middleware.totalProcessing.max = 110us.
    - ft789C_8BM_1CC_8UE_8UEsched_TDD500_ABIL test has Middleware.totalProcessing.max = 425us.
    - ft000_1BM_1CC_1UE_1UEsched_TDD125_ABIL_SA has Middleware.totalProcessing.95p = 111us.
        and last test of this type on same branch and different commit has Middleware.totalProcessing.95p = 100us. (+11%)

But we do NOT send alarm e-mails NOR send gerrit comments if (for example):
    - ft000_1BM_1CC_1UE_1UEsched_TDD125_ABIL_SA test has Middleware.totalProcessing.max = 96us.
    - ft789C_8BM_1CC_8UE_8UEsched_TDD500_ABIL test has Middleware.totalProcessing.max = 380us.
    - ft1116_1BM_4CC_8UE_1UEsched_TDD500_ABIL_NSA test has Middleware.totalProcessing.max = 425us.
    - ft789C_8BM_1CC_8UE_8UEsched_TDD500_ABIL has Middleware.totalProcessing.95p = 300us.
        and last test of this type on same branch and different commit has Middleware.totalProcessing.95p = 400us. (-25%)

D. Min logger duration example
    "logger": {
        "core5": {
        "min": [
            {
              "duration": { "Major": 80 }
            }
        ]
    }
    "L2PSDL": {...}

    Min value for core5 only, alarm is detected with level Major if duration is lower than 80.