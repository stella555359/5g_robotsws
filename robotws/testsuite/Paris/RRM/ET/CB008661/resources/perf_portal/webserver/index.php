<?php

   function show_log_content($log_content) {
      ?>
      <br/><br/>
      See below the processing log file (refresh 10s):
      <blockquote>
      <?php
          /*
          $log_file_size = filesize($log_file);
          if ($log_file_size > 0) {
              $ressource = fopen($log_file, 'r');
              echo nl2br(fread($ressource, filesize($log_file)));
          }
          */
          echo nl2br($log_content);
      ?>
      </blockquote>
      <?php
   }

   function get_log_content($log_file){
       return file_get_contents($log_file);
   }

   function check_not_end_error($log_content) {
       if (preg_match('/End with error/', $log_content)) {
           return false;
       }
       return true;
   }

   $snapshot_full_path = $_GET["snapshot"];

   $root_dir = "/5g_storage/PatchServer/perfport/";
   $dest_dir = dirname($snapshot_full_path);
   $temp_dir = $root_dir."/webserver/tmp";
   $log_dir = $root_dir."/webserver/log";
   $chrome_dir = "/webserver/ChromeFile";

   $chrome_tracing_decoder = "/5g_storage/PatchServer/perfport/ci-scripts/perf_portal/decode_chrome_tracing_on_demand.sh";

   $snapshot_file = basename($snapshot_full_path);
   $chromeTracing_file = preg_replace('/^TimeMarker(Snapshot_.*).json.xz$/', 'ChromeTracing${1}.html', $snapshot_file);
 
   $redirect_destination = "https://5gwebserver.dyn.nesc.nokia.net/CinqG/perfport/".$chrome_dir."/".$chromeTracing_file;

   if (file_exists($root_dir."/".$chrome_dir."/".$chromeTracing_file)) {
      echo "\n<script> window.location.href='".$redirect_destination."'; </script>";
   }
   else if (file_exists($log_dir."/".$chromeTracing_file.".log")) {
      $log_content = get_log_content($log_dir."/".$chromeTracing_file.".log");
      $refresh_message = "";
      if (check_not_end_error($log_content)) {
          header("Refresh:10");
          $refresh_message = "Refresh in 10s, please wait ...";
      }
      ?>
      <h3> ChromeTracing computing in progress for <?php echo $snapshot_file ?></h3>
      <br/><br/>
      <?php
      echo $refresh_message;
      show_log_content($log_content);
   } else {
      // Compute ChromeTracing file

      header("Refresh:10");
      shell_exec("/usr/bin/bash ".$chrome_tracing_decoder." ".$root_dir."/".$snapshot_full_path." >".$log_dir."/".$chromeTracing_file.".log 2>&1 &");
      echo "ChromeTracing file not already done, decoding in progress. Please wait ....<br/>";
      show_log_content(get_log_content($log_dir."/".$chromeTracing_file.".log"));
   }

 ?>