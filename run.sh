#!/bin/sh

properties=
# get all env, filter secor config and append -Dkey=value in properties var
for config in $(env | grep '^SECOR'); do
  var=$(echo $config | cut -f1 -d'=')
  value=$(echo $config | cut -f2 -d'=')
  # convert SECOR_property_complete__name to property.complete_name
  key=$(echo $var | sed 's/^SECOR_//g' | tr '_' '.' | sed 's/\.\./_/g')
  properties="$properties -D$key=$value"
done

java -Xmx${JVM_MEMORY:-512m} -ea \
  -Dlog4j.configuration=log4j.docker.properties \
  -Dconfig=secor.prod.partition.properties \
  $properties \
  -cp secor.jar:lib/* \
  com.pinterest.secor.main.ConsumerMain
