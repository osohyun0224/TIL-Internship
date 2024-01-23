# Today I Learned, 2024.01.22 (Mon)

## Intro.

오늘은 어제에 이어서 셸 스크립트를 뜯어보고, 본격적으로 alias를 추가하는 작업을 진행하였습니다.

## Main.

- [ ]  scripts/opensearch.restore.sh 분석
- [ ]  scripts/opensearch.alias.sh 분석
- [ ]  scripts/opensearch.sh 분석

1) scripts/opensearch.sh 코드 분석

이 코드는 OpenSearch 서버의 동작을 주로 제어하고 있었다. 도커 컨테이너를 활용해서 오픈서치를 로컬 환경에서 실행하고 관리한다.

2) scripts/opensearch.restore.sh 코드 분석

- 이 코드는 OpenSearch 인덱스의 스냅샷 복원 및 관련 작업을 자동화하고 있었다.
- Opensearch와 통신하기 위해 필요한 사용자 인증 관련을 진행했다.
- 스냅샷 복원 기능이 구현되어있어서 인덱스를 열고 닫는 로직을 구현한다.
- curl 명령어를 통해 OpenSearch API에 스냅샷 복원 요청을 보내고, 복원할 인덱스 이름, 복원 옵션을 포함해서 요청한다.

### alias 구현

```shell
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
```

- 'localdevs_youtube_video_info' 인덱스에 대해서만  'hot_youtube_video_info' alias가 추가 되도록 구현했다.
- 위의 경우에 해당하지 않는 다른 인덱스들은 기존 방식대로 처리되도록 구현했다.

## 이슈,,

- curl 명령어 부분 문법적으로 애매하게 고쳤는데 이 부분 다시 하고 싶다
- alias 추가한 방식을 바꾸고 싶다 (비효율적으로 작성한 것 같다)