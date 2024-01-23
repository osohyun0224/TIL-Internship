# Today I Learned, 2024.01.19 (FRI)

## Intro.
오늘은 어제까지 작업한 샘플링 작업이 잘 되었는지 확인하려고 합니다.

## Main.
### [1] 로컬 opensearch 켜서 인덱스 restore 작업

먼저 template_node 파일에서 로컬 opensearch를 열고 인덱스를 restore 작업을 진행해 보았습니s다.

터미널 1 > 오픈리서치 시작

```
npm run opensearch start
```

터미널 2 >  오픈리서치 대시보드 실행

```
npm run opensearch dashboard start
```

터미널 3> 인덱스 복원

```
npm run opensearch restore
```

### [2] 인덱스 복원

인덱스 복원 명령어를 실행하면 내가 어제까지 작업했던 devsampling 폴더 내에서 각각의 인덱스 별로 샘플링 작업이 쭉 진행되는 것을 확인할 수 있습니다. 

여러개 데이터 샘플링된 것을 확인하면서  예시로 한 부분만 보도록 하겠습니다.


```shell
2024-01-22T00:22:17Z [opensearch.restore.sh:local] 104000 ms ======================= [open index: localdevs_youtube_channel_stat] =======================
/Users/sohyunoh/template_node/_subgql/scripts/opensearch.restore.sh
curl -XPOST -u admin:admin --insecure --silent http://localhost:9200/localdevs_youtube_channel_stat/_open?pretty
{
  "acknowledged" : true,
  "shards_acknowledged" : false
}
2024-01-22T00:22:48Z [opensearch.alias.sh:local] 0 ms ======================= [start] =======================
2024-01-22T00:22:48Z [opensearch.alias.sh:local] 0 ms ======================= [remove alias] =======================
curl -XPOST -u admin:admin --insecure --silent http://localhost:9200/_aliases?pretty
  -H  "Content-Type: application/json" 
  -d '{
  "actions": [
    {
      "remove": {
        "index": "localdevs_youtube_channel_stat",
        "alias": "youtube_channel_stat"
      }
    }
  ]
}'
{
  "acknowledged" : true
}
2024-01-22T00:22:48Z [opensearch.alias.sh:local] 0 ms ======================= [add alias] =======================
curl -XPOST -u admin:admin --insecure --silent http://localhost:9200/_aliases?pretty
  -H  "Content-Type: application/json" 
  -d '{
  "actions": [
    {
      "add": {
        "index": "localdevs_youtube_channel_stat",
        "alias": "youtube_channel_stat"
      }
    }
  ]
}'
{
  "acknowledged" : true
}
2024-01-22T00:22:48Z [opensearch.alias.sh:local] 0 ms ======================= [end] =======================
```

위의 터미널 출력문은 opensearch에서 실행된 Response입니다.

먼저 천천히 단계별로 어떤 것을 하는 지 해석해보았습니다.

1) 인덱스 열기

```shell
2024-01-22T00:22:17Z [opensearch.restore.sh:local] 104000 ms ======================= [open index: localdevs_youtube_channel_stat] =======================
curl -XPOST -u admin:admin --insecure --silent http://localhost:9200/localdevs_youtube_channel_stat/_open?pretty
{
  "acknowledged" : true,
  "shards_acknowledged" : false
}
```

- **`localdevs_youtube_channel_stat`**라는 인덱스를 연다.
- **`curl`** 명령어를 사용하여 OpenSearch API에 접근한다.
- **`acknowledged: true`**는 요청이 성공적으로 처리되었음을 나타냅니다.
- **`shards_acknowledged: false`**는 모든 샤드가 아직 인덱스 열기 요청을 인지하지 못했음을 나타냅니다.


2) 별칭 제거 및 추가

```shell
2024-01-22T00:22:48Z [opensearch.alias.sh:local] 0 ms ======================= [remove alias] =======================
curl -XPOST -u admin:admin --insecure --silent http://localhost:9200/_aliases?pretty
  -H  "Content-Type: application/json" 
  -d '{
  "actions": [
    {
      "remove": {
        "index": "localdevs_youtube_channel_stat",
        "alias": "youtube_channel_stat"
      }
    }
  ]
}'
{
  "acknowledged" : true
}
```

- 해당 인덱스에서 별칭을 제거하는 작업을 수행하고, 다시 해당 인덱스에 **`youtube_channel_stat`**이라는 별칭을 추가하는 작업을 수행하고 있다.

## 번외) 별칭 제거 추가?

alias를 제거하고 다시 추가할 거면 왜 제거한 건지 궁금했습니다. 

알아본 결과 다음과 같았습니다.

---

## alias에 대하여,,,

별칭(alias)란 무엇일까? 이는 오픈 서치나 엘라스틱 서치와 같은 검색 엔진에서 사용되는 중요한 기능이다. 

별칭은 하나 이상의 인덱스에 대한 참조로 작동하여, 인덱스의 이름 대신 사용할 수 있는 간단한 이름을 제공한다. 

본 template_node 파일 내 subgql 내부에서 [opensearch.alias.sh]() 파일을 한번 살펴보았다.

 ## 1. 별칭의 역할

1) 단순화: 별칭을 사용하면 복잡한 인덱스 이름 대신 간단한 이름을 사용하여 데이터에 접근할 수 있다. 

2) 데이터 업데이트 및 마이그레이션: 새로운 데이터 구조로 인덱스를 업데이트 하거나 마이그레이션 할 때, 별칭을 사용하면 기존 인덱스에서 새 인덱스로 쉽게 전환이 가능하다. 사용자는 별칭을 통해 항상 최신 데이터에 접근하고 서비스 중단이 발생하지 않는다. 

3) 복수 인덱스 관리: 하나의 별칭이 여러 인덱스를 가리킬 수 있어서 다양한 인덱스에 걸쳐 있는 데이터를 통합하여 검색할 수 있다.

## 2. 별칭 제거 및 추가의 필요성

1) 업데이트 과정에서 일관성을 유지할 수 있다. 

2) 무중단 업데이트가 가능하다.

### 3. 번외

위의 파일을 보면 로깅과 오류처리하는 부분을 확인할 수 있는데 위의 스크립트에서는 로깅 함수를 사용하여 각 단계에서 발생하는 사항을 로그로 기록한다. 만약어 오픈서치 서비스가 감지되지 않으면 스크립트는 오류 메세지를 출력하고 종료하는 역할을 한다.


--- 

# [3] 새로운 과제 할당

- [ ]  scripts/opensearch.restore.sh
- [ ]  scripts/opensearch.alias.sh
- [ ]  scripts/opensearch.sh

위의 세 셸 스크립트를 분석하고,  로컬 dev의 "youtube_video_info"에 "hot_youtube_video_info"이 alias를 추가하는 작업을 진행하면 된다!d