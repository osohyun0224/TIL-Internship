#!/bin/bash
DIR_CURSC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#set -e
#region global functions definition
source $DIR_CURSC/common/util.sh
source $DIR_CURSC/common/args.sh
#endregion

#region info
logger.divider "script info"
logger "current folder: ${Green}$DIR_CURSC${Reset}"
logger "script: ${Green}${BASH_SOURCE##*/}${Reset}"
logger "mode: ${Green}$mode${Reset}"
#endregion

#region set variables
#https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html
user="admin"
pwd="admin"

# 인증 필요시 url https에 
url="http://localhost:9200"
options="-u $user:$pwd --insecure --silent"
#endregion


#region get default resource
helpLink="https://opensearch.org/docs/1.3/opensearch/rest-api/snapshots/restore-snapshot/"
param="pretty"
#endregion


#region args not use mode, tag
PREFIX_TARGET_INDEX="localdevs_"
default_repository="manual-snapshot-dev"
default_snapshot="local_latest"

if [ 0 -eq ${#POSITIONAL_ARGS[@]} ]; then
  alias="*"
  index="*"
elif [ 2 -le ${#POSITIONAL_ARGS[@]} ]; then
  alias=${POSITIONAL_ARGS[0]}
  index=${POSITIONAL_ARGS[1]}
elif [ 3 -eq ${#POSITIONAL_ARGS[@]} ]; then
  snapshot=${POSITIONAL_ARGS[0]}
  alias=${POSITIONAL_ARGS[1]}
  index=${POSITIONAL_ARGS[2]}
else
  repository=${POSITIONAL_ARGS[0]}
  snapshot=${POSITIONAL_ARGS[1]}
  alias=${POSITIONAL_ARGS[2]}
  index=${POSITIONAL_ARGS[3]}
fi


function _findLatestSnapshotName() {
  #don't echo in function
  local repository=$1
  local snapshot_prefix=$2
  snapshots=`curl -XGET $options "$url/_cat/snapshots/$repository?h=id&s=end_epoch:desc" | grep $snapshot_prefix`
  echo $snapshots
}

repository=${repository:-"$default_repository"}
snapshot=${snapshot:-"$default_snapshot"}
args_snapshot=$snapshot
#decide snapshot
snapshots=$(_findLatestSnapshotName $repository $snapshot)
echo $snapshots
snapshot=""
for ss in ${snapshots[@]}; do
  snapshot=$ss
  break
done
if [ "$snapshot" = "" ]; then
  logger "${Red}ERROR: Not found snapshot: '${args_snapshot}' ..${Reset}"
  exit 1;
fi
#endregion

#region info
if [ ! -z $verbose ]; then
logger.divider "script info"
logger "current folder: ${Green}$DIR_CURSC${Reset}"
logger "script: ${Green}${BASH_SOURCE##*/}${Reset}"
_args=$@
logger "args: $_args"
logger "mode: ${Green}$mode${Reset}"
logger "repository: ${Green}$repository${Reset}"
logger "snapshot: ${Green}$snapshot${Reset}"
logger "alias: ${Green}$alias${Reset}"
logger "index: ${Green}$index${Reset}"
fi
#endregion

#region check opensearch
ESHOSTPORT=9200
CHECK='$(curl -XGET "$url"/_cluster/state/cluster_name "$options" | grep cluster_uuid | wc -l) -ne 0'
if [[ ! $CHECK ]]; then
  echo -e "${Red}opensearch not found${Reset}"
  exit 1;
fi
#endregion

#region functions
logger.divider "start"

function _closeIndex(){
  local index=$1
  logger.divider "close index: $index"
  local command="curl -XPOST $options $url/$index/_close?$param"
  printf "$command\n"
  eval ${command}
}

function _openIndex(){
  logger.divider "open index: $index"
  local index=$1
  echo $0
  local command="curl -XPOST $options $url/$index/_open?$param"
  printf "$command\n"
  eval ${command}
}

function _recreateAlias(){
  local alias=$1
  local index=$2
  commandScript="$DIR_CURSC/opensearch.alias.sh $alias $index"
  eval ${commandScript}
}

function _restoreIndex() {
  local repository=$1
  local snapshot=$2
  local index=$3
  local prefix=$PREFIX_TARGET_INDEX
  local include_aliases=false
  if [[ "$index" != "$PREFIX_TARGET_INDEX"* ]]; then
    prefix=""
    include_aliases=true
  else
    local alias=${index//$prefix/""}
  fi

  command=$(cat << EOF
curl -XPOST $options $url/_snapshot/$repository/$snapshot/_restore?$param
  -H  "Content-Type: application/json" 
  -d '{
  "indices": "$index",
  "ignore_unavailable": true,
  "include_global_state": false,
  "include_aliases": $include_aliases,
  "partial": false,
  "rename_pattern": "(.+)",
  "rename_replacement": "\$1",
  "index_settings": {
    "index.blocks.read_only": false,
    "index.number_of_replicas": 0
  },
  "ignore_index_settings": [
    "index.refresh_interval"
  ]
}'
EOF
)
  _closeIndex $index
  logger.divider "restore index"
  printf "$command\n"
  eval ${command}
  _openIndex $index

  if ! $include_aliases ; then
    _recreateAlias $alias $index
  fi
}

function _getAllIndices(){
  local repository=$1
  local snapshot=$2
  local index=$3
  local json=`curl -XGET $options $url/_snapshot/$repository/$snapshot | jq -r '.snapshots[].indices'`
  echo $json
}
#endregion

#region restore index
if [ "$index" = "*" ]; then
  json=$(_getAllIndices $repository $snapshot $index)
  for row in $(echo "${json}" | jq -r '.[]'); do
    _restoreIndex $repository $snapshot $row
  done
else
  _restoreIndex $repository $snapshot $index
fi
#endregion