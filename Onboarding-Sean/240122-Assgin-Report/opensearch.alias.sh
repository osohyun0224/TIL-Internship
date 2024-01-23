#!/bin/bash
..생략

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

  # 'localdevs_youtube_video_info' 인덱스의 경우에는 aliases에 항목 추가
  if [ "$index" == "localdevs_youtube_video_info" ]; then
    local aliases=("hot_youtube_video_info" "youtube_video_info" )
    for alias in "${aliases[@]}"; do
      if curl -XGET "$url/_cat/indices/$index" $options | grep -q "$index"; then
        logger.divider "add alias"
        commandAdd=$(cat << EOF
curl -XPOST $options "$url/_aliases?$param" \
  -H "Content-Type: application/json" \
  -d '{
    "actions": [
      {
        "add": {
          "index": "'$index'",
          "alias": "'$alias'"
          }
        }
      ]
    }'
EOF
        )
        printf "$commandAdd\n"
        eval "$commandAdd" 
      else
        echo "Index $index does not exist. Cannot add alias: $alias."
      fi
    done
  else
    # 해당하는 인덱스('localdevs_youtube_video_info') 제외하고 다른 인덱스들에 대한 처리
    if curl -XGET "$url/_cat/indices/$index" $options | grep -q "$index"; then
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
    fi
  fi
}
#endregion

_removeAlias $alias $index
_addAlias $alias $index

logger.divider "end"



#./cmd -v alias youtube_channel_info youtube_channel_info_v2.0.3

#endregion