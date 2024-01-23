#!/bin/bash
DIR_CURSC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#region global functions definition
source $DIR_CURSC/common/util.sh
source $DIR_CURSC/common/args.sh
source $DIR_CURSC/config.sh
source $DIR_CURSC/container.sh
#endregion

#region info
logger.divider "script info"
logger "current folder: ${Green}$DIR_CURSC${Reset}"
logger "script: ${Green}${BASH_SOURCE##*/}${Reset}"
logger "mode: ${Green}$mode${Reset}"
#endregion

#region configuration
#show_config
#endregion
command="${POSITIONAL_ARGS[0]}"
resource="${POSITIONAL_ARGS[1]}"
opensearchname="opensearch"

show_help() {
  cat << EOF
Usage: ${0##*/} [command] [arg1] [arg2] ...
    [command]   
    __blank__   :show this help
    start       :start local opensearch:9200
    stop        :stop local opensearch:9200
    dashboard   :commands for opensearch-dashboard
      start         :start local os-dashboard:5601
      stop          :stop local os-dashboard:5601
    restore     :commands for restore snapshot from prod os
      [repository] [snapshot] [alias] [index]
      [snapshot] [alias] [index]
      [alias] [index]
      __blank__     :restore all indices and alias
    
Example:
  opensearch.sh 
  opensearch.sh start
  opensearch.sh stop
  opensearch.sh dashboard start
  opensearch.sh dashboard stop
  opensearch.sh restore
  opensearch.sh restore youtube_channel_info localdevs_youtube_channel_info
  opensearch.sh restore local_latest youtube_channel_info localdevs_youtube_channel_info
  opensearch.sh restore manual-snapshot-dev local_latest youtube_channel_info localdevs_youtube_channel_info
EOF
}
PREFIX_TARGET_INDEX="localdevs_"
default_repository="manual-snapshot-dev"
default_snapshot="local_latest"


if [ "$command" = "stop" ]; then
  docker stop $opensearchname
  exit 0;
elif [ "$command" = "" ]; then
  show_help
  exit 0;
fi

function _restoreIndex(){
  #[snapshot_repository] [snapshot] [alias] [index_name]
  shift
  commandScript="$DIR_CURSC/opensearch.restore.sh $@"
  eval ${commandScript}
}

function _dashboard(){
  shift
  commandScript="$DIR_CURSC/opensearch.dashboard.sh $@"
  eval ${commandScript}
}


if [ "$command" = "dashboard" ]; then
  _dashboard $@
  exit 0;
elif [ "$command" = "restore" ]; then
  _restoreIndex $@
  exit 0;
fi

#region container start

ESHOSTPORT=9200
VOLUMENAME="opensearch_local"
if [ $(docker network ls | grep "$DOCKER_NETWORK_TDD" | wc -l) -eq 0 ]; then
  docker network create "$DOCKER_NETWORK_TDD"
fi

logger.divider "aws ecr login"
#############aws ecr registry login
#aws-cli v1.xx 
#$(aws ecr get-login --no-include-email)
#aws-cli v2.xx
#aws ecr get-login-password | docker login --username AWS --password-stdin 314916389090.dkr.ecr.ap-northeast-2.amazonaws.com
aws ecr get-login-password | docker login --username AWS --password-stdin $ECRPATH


#docker desktop volume
#https://opensearch.org/docs/1.3/opensearch/install/docker/
docker volume create "$VOLUMENAME"
start_container $opensearchname "314916389090.dkr.ecr.ap-northeast-2.amazonaws.com/opensearch" "localdev" false "--network $DOCKER_NETWORK_TDD -v "$VOLUMENAME:/usr/share/opensearch/data" -p $ESHOSTPORT:9200 -p 9600:9600 -e \"discovery.type=single-node\" -e ES_JAVA_OPTS=\"-Xms2G -Xmx2G\" -e DISABLE_INSTALL_DEMO_CONFIG=\"true\" -e DISABLE_SECURITY_PLUGIN=\"true\" "
#_restoreIndex
docker logs -f $opensearchname

#endregion