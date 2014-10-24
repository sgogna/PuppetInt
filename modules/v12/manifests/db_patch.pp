define v12::db_patch (
  $inst_num,
  $h_db_patch_executor,
  $h_databases,
) {

  $base = "/apps/v12/inst${inst_num}"
  $script_path = "${base}/db_patch_executor"

  $mode = $h_db_patch_executor['mode']
  $source_env1 = $h_db_patch_executor['source_env1']
  $target_env1 = $h_db_patch_executor['target_env1']
  $target_env1_description = $h_db_patch_executor['target_env1_description']
  $target_env1_type = $h_db_patch_executor['target_env1_type']
  $drafts_to_migrate_env1 = $h_db_patch_executor['drafts_to_migrate_env1']
  $first_params = $h_db_patch_executor['first_params']
  $first_arlines = $h_db_patch_executor['first_arlines']
  $source_env2 = $h_db_patch_executor['source_env2']
  $target_env2 = $h_db_patch_executor['target_env2']
  $target_env2_description = $h_db_patch_executor['target_env2_description']
  $target_env2_type = $h_db_patch_executor['target_env2_type']
  $drafts_to_migrate_env2 = $h_db_patch_executor['drafts_to_migrate_env2']
  $second_params = $h_db_patch_executor['second_params']
  $second_arlines = $h_db_patch_executor['second_arlines']
  $past_prod_versions_to_migrate = $h_db_patch_executor['past_prod_versions_to_migrate']
  $latest_draft_versions_to_migrate = $h_db_patch_executor['latest_draft_versions_to_migrate']
  $overrides_data_path = $h_db_patch_executor['overrides_data_path']
  $generated_script_file_path = $h_db_patch_executor['generated_script_file_path']
  $generated_script_file_name = $h_db_patch_executor['generated_script_file_name']
  $obsolete_environments_excluded = $h_db_patch_executor['obsolete_environments_excluded']

  notify { "h_db_patch_executor for instance: $inst_num":
    message => "
      mode: ${h_db_patch_executor['mode']}
      source_env1: ${h_db_patch_executor['source_env1']}
      target_env1: ${h_db_patch_executor['target_env1']}
      target_env1_description: ${h_db_patch_executor['target_env1_description']}
      target_env1_type: ${h_db_patch_executor['target_env1_type']}
      drafts_to_migrate_env1: ${h_db_patch_executor['drafts_to_migrate_env1']}
      first_params: ${h_db_patch_executor['first_params']}
      first_arlines: ${h_db_patch_executor['first_arlines']}
      source_env2: ${h_db_patch_executor['source_env2']}
      target_env2: ${h_db_patch_executor['target_env2']}
      target_env2_description: ${h_db_patch_executor['target_env2_description']}
      target_env2_type: ${h_db_patch_executor['target_env2_type']}
      drafts_to_migrate_env2: ${h_db_patch_executor['drafts_to_migrate_env2']}
      second_params: ${h_db_patch_executor['second_params']}
      second_arlines: ${h_db_patch_executor['second_arlines']}
      past_prod_versions_to_migrate: ${h_db_patch_executor['past_prod_versions_to_migrate']}
      latest_draft_versions_to_migrate: ${h_db_patch_executor['latest_draft_versions_to_migrate']}
      overrides_data_path: ${h_db_patch_executor['overrides_data_path']}
      generated_script_file_path: ${h_db_patch_executor['generated_script_file_path']}
      generated_script_file_name: ${h_db_patch_executor['generated_script_file_name']}
      obsolete_environments_excluded: ${h_db_patch_executor['obsolete_environments_excluded']}
    ",
  }


  file { "${script_path}":
    ensure  => directory ,
    require => File["${base}"],
    mode    => 744,
  }

  file { "${script_path}/dualBatchScriptExecutionRunner.sh":
    content => template("v12/db_patch/dualBatchScriptExecutionRunner.sh"),
    mode    => "u+x",
    owner   => res2,
    group   => res,
    require => File[ "${script_path}"],
  }

  file { "${script_path}/property_change.sh":
    content => template("v12/db_patch/property_change.sh"),
    mode    => "u+x",
    owner   => res2,
    group   => res,
    require => File[ "${script_path}"],
  }

  file { "${script_path}/configuration-patches.properties":
    content => template("v12/db_patch/configuration-patches.properties"),
    mode    => "u+x",
    owner   => res2,
    group   => res,
    require => File[ "${script_path}"],
  }

  file { "${script_path}/batchScriptExecutor.properties":
    content => template("v12/db_patch/batchScriptExecutor.properties"),
    mode    => "0444",
    owner   => res2,
    group   => res,
    require => File[ "${script_path}"],
  }


  exec { "${script_path}/dualBatchScriptExecutionRunner.sh":
    #subscribe => File["${dest_path}/webapps/${app_name}.war"],
    #creates => "${dest_path}/webapps/${app_name}/.extracted.puppet",
    require => [
      File["${script_path}/dualBatchScriptExecutionRunner.sh"],
      File["${script_path}/property_change.sh"],
      File["${script_path}/configuration-patches.properties"],
      File["${script_path}/batchScriptExecutor.properties"],
      Jdk["${base}/jdk"],
    ],
    path => "${script_path}:${base}/jdk/bin:/bin",
    cwd => "${script_path}",
    command => "dualBatchScriptExecutionRunner.sh",
  }

}
