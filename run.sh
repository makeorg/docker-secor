#!/bin/sh

echo 'include=secor.prod.partition.properties' > secor.current.properties
# get all env, filter secor config and output key=value in config file
for config in $(env | grep '^SECOR'); do
  var=$(echo $config | cut -f1 -d'=')
  value=$(echo $config | cut -f2 -d'=')
  # convert SECOR_property_complete__name to property.complete_name
  key=$(echo $var | sed 's/^SECOR_//g' | tr '_' '.' | sed 's/\.\./_/g')
  echo "$key=$value" >> secor.current.properties
done

java -Xmx${JVM_MEMORY:-512m} -ea \
  -Dlog4j.configuration=log4j.docker.properties \
  -Dconfig=secor.current.properties \
  -cp secor.jar:lib/* \
  com.pinterest.secor.main.ConsumerMain
