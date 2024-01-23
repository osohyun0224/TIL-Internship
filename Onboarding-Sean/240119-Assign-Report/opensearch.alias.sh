#!/bin/bash
DIR_CURSC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -e
#region global functions definition
source $DIR_CURSC/common/util.sh
source $DIR_CURSC/common/args.sh
#endregion

#region args not use mode, tag
alias=${POSITIONAL_ARGS[0]}
index=${POSITIONAL_ARGS[1]}
#endregion

#region info
if [ ! -z $verbose ]; then
logger.divider "script info"
logger "current folder: ${Green}$DIR_CURSC${Reset}"
logger "script: ${Green}${BASH_SOURCE##*/}${Reset}"
_args=$@
logger "args: $_args"
logger "mode: ${Green}$mode${Reset}"
logger "alias: ${Green}$alias${Reset}"
logger "index: ${Green}$index${Reset}"
fi
#endregion

#region set user/password
user="admin"
pwd="admin"
#endregion

#https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html

#region get default resource
helpLink="https://opensearch.org/docs/1.3/opensearch/rest-api/snapshots/restore-snapshot/"
param="pretty"
#endregion

#region functions 인증필요시 url에 https
url="http://localhost:9200"
options="-u $user:$pwd --insecure --silent"

#region check opensearch
ESHOSTPORT=9200
CHECK='$(curl -XGET "$url"/_cluster/state/cluster_name "$options" | grep cluster_uuid | wc -l) -ne 0'
if [[ ! $CHECK ]]; then
  echo -e "${Red}opensearch not found${Reset}"
  exit 1;
fi
#endregion
logger.divider "start"

function _removeAlias(){
  local alias=$1
  local index=$2
  #01. remove/add alias 
  logger.divider "remove alias"
  commandAlias=$(cat << EOF
curl -XPOST $options $url/_aliases?$param
  -H  "Content-Type: application/json" 
  -d '{
  "actions": [
    {
      "remove": {
        "index": "$index",
        "alias": "$alias"
      }
    }
  ]
}'
EOF
)
  printf "$commandAlias\n"
  eval ${commandAlias}
}

function _addAlias(){
  local alias=$1
  local index=$2
  logger.divider "add alias"
  commandAlias=$(cat << EOF
curl -XPOST $options $url/_aliases?$param
  -H  "Content-Type: application/json" 
  -d '{
  "actions": [
    {
      "add": {
        "index": "$index",
        "alias": "$alias"
      }
    }
  ]
}'
EOF
)
  printf "$commandAlias\n"
  eval ${commandAlias}
}
#endregion

_removeAlias $alias $index
_addAlias $alias $index

logger.divider "end"



#./cmd -v alias youtube_channel_info youtube_channel_info_v2.0.3

#endregion