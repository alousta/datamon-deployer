#!/bin/bash

# Source this file
# . kubhelper.sh
#
# Test the target Kubernetes cluster supports the specified resource name and API version.
# Parameters:
#  1:  Kubernetes resource name
#  2:  Kubernetes API version
# Exit code:
#  0:  Resource and Version exist
#  1:  Resource exists, but not the version.
#  2:  Resource and version do not exist.
resource_version_exists() {
    if [ -z "$1" ]; then echo "resource_version_exists() missing arg 1: resource"; fi
    if [ -z "$2" ]; then echo "resource_version_exists() missing arg 2: apiversion"; fi

    resource="$1"
    apiversion="$2"
    if $clicmd api-resources -o name | grep "$resource" &> /dev/null; then
        if $clicmd api-versions |  grep "$apiversion" &> /dev/null; then
          return 0;
        else
          return 1;
        fi
    fi
    return 2;
}

clicmd=""
which kubectl &> /dev/null
if [ "$?" == "0" ]; then
  clicmd="kubectl"
else
  which oc &> /dev/null
  if [ "$?" == "0" ]; then
    clicmd="oc"
  else
    echo "No client tool either kubectl/oc is found. Exiting..."
    exit 1
  fi
fi

supports_scc() {
  resource_version_exists securitycontextconstraints.security.openshift.io security.openshift.io/v1
  return $?
}

supports_psp() {
  resource_version_exists podsecuritypolicies.policy policy/v1beta1
  return $?
}