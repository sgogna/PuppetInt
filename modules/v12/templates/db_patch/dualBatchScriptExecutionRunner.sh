#!/bin/bash


########################################
echo "dualBatchScriptExecutionRunner.sh ..."
exit 0
########################################


. batchScriptExecutor.properties
env_properties_file=appconf/SSW2010/server-env.properties
patches_properties_file=configuration-patches.properties

cp=".:/opt/mw/tomcat-7.0.26-instance1/lib/servlet-api.jar"
JAVA_BIN="/opt/mw/java/jdk1.7.0_06/bin/java"

function getJars {
for file in $1*.jar
do
	cp="${cp}:${file}"
done
}

getJars "webapps/SSW2010.server/WEB-INF/lib/"
cp="${cp}:./appconf"
#echo "$cp"

#remember initial environment property
initial_env=`sed '/^\#/d' $env_properties_file | grep environment | tail -n 1 | sed 's/^.*=//;s/^[[:space:]]*//;s/[[:space:]]*$//'`
#copy $target_env1 to environment property
./property_change.sh environment $target_env1 $env_properties_file
#set latest.draft.versions.to.migrate=$drafts_to_migrate_env1
./property_change.sh latest.draft.versions.to.migrate $drafts_to_migrate_env1 $patches_properties_file
${JAVA_BIN} -Xmx3200M -XX:MaxPermSize=2048M -cp ${cp} -Dlog4j.configuration=log4j.properties -Dcore.main.transaction.timeout=9000 com.sabre.ssw2010.application.configurationpatches.batchexecution.BatchPatchesExecutor $first_params -p "$target_env1_description" $target_env1_type $source_env1 $first_arlines
#copy $target_env2 to environment property
./property_change.sh environment $target_env2 $env_properties_file

#set latest.draft.versions.to.migrate=$drafts_to_migrate_env2
./property_change.sh latest.draft.versions.to.migrate $drafts_to_migrate_env2 $patches_properties_file

echo "$mode"

if [ $mode = "single" ]
then
	#run in no-migration-mode with simply setting active configurations like in target_env1	
	${JAVA_BIN} -Xmx3200M -XX:MaxPermSize=2048M -cp ${cp} -Dlog4j.configuration=log4j.properties -Dcore.main.transaction.timeout=9000 com.sabre.ssw2010.application.configurationpatches.batchexecution.BatchPatchesExecutor $second_params -d $target_env1 -p "$target_env2_description" $target_env2_type $source_env2 $second_arlines
fi

if [ $mode = "dual" ]
then
	#set obsolete.environments.excluded=$target_env1
	./property_change.sh obsolete.environments.excluded $target_env1 $patches_properties_file
	#run in normal mode, but excluding previously created configuration from obsoleting
	${JAVA_BIN} -Xmx3200M -XX:MaxPermSize=2048M -cp ${cp} -Dlog4j.configuration=log4j.properties -Dcore.main.transaction.timeout=9000 com.sabre.ssw2010.application.configurationpatches.batchexecution.BatchPatchesExecutor $second_params -p "$target_env2_description" $target_env2_type $source_env2 $second_arlines
fi

#revert initial env
./property_change.sh environment $initial_env $env_properties_file

