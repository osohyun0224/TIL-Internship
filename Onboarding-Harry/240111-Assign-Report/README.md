# Today I Learned, 2024.01.11 (THUR)

## Intro.

- 오늘은 어제 만들었던 서버를 프론트엔드로 연결하는 것을 목표로 하였습니다. 
- 프론트엔드 구현 내용이 담긴 GUI 버전 2 프론트엔드 파일 코드를 분석하였습니다.

## To do List

- 기존의 코드에서 새로 기능을 추가만 하면 되었던 백엔드 코드와는 다르게 구현해야합니다.
- 프론트에서는 기존에 구현된 코드를 수정하여 새로운 기능을 구현해야하기에 전 코드를 분석하였습니다.

- [ ] 개발 서버 여는 방법 어싸 리포트에 정리하기

- [ ] 프론트엔드 코드 분석하기

- [ ] 기능 구현할 수 있다면 하자,,,

## Today Report

### 1. 개발 서버 여는 방법

[0] 무조건 docker를 먼저 실행한다.

[1] 먼저 Vling_gui_v2 폴더를 오픈하고 터미널을 열어서 아래의 명령어를 실행시킵니다.(프론트)

- 터미널 1

```
npm run dev -- --concurrency=999
```

[2] 백엔드 서버 파일(subgql_yttrends)에서 터미널 3개를 차례로 실행할 것입니다.

- 터미널 1

```
npm run gateway.docker vling
```

- 터미널 2

```
npm run start
```

- 터미널 3

```
npm run gateway
```

---

### 2. 프론트 코드 분석

우선 제가 구현하고자 하는 인급동 페이지 폴더 구조를 파악해보았습니다.

```youtube-recommmend``` > ```YoutubeRecommendWrapper``` > ```AlgoSearchTable``` > ```useFetchTrendVideoList```

직접적으로 기능(데이터를 받아오는) 기능이 구현된 것은 useFetchVideoList에서 구현되고 있고,
해당 컴포넌트는 AlgoSearch에서 구성되고 있습니다.

코드를 올릴 수는 없지만 데이터 받아오는 쪽의 구현 함수에 대해서 메인 함수를 살펴보았습니다.

**`setChildCsvData`** 이 함수의 기능은,

- `fetchVideo?.videoList`가 존재하면, 각 비디오 데이터를 특정 형식으로 변환하여 **`childCsvData`** 상태를 설정합니다. 이 변환 과정은 각 비디오 데이터에서 필요한 정보(제목, 해시태그, ALGO 점수, 구독자 수, 조회 수, 비디오 상세 URL)를 추출하고, 이를 새로운 객체로 매핑합니다.

 **`setChildCsvTitle`** 함수:

- **`childCsvTitle`** 상태를 설정하는데, 이는 CSV 파일의 제목을 형성합니다. 이 제목은 선택된 국가, 카테고리, 날짜, 시간을 포함하여 동적으로 생성됩니다. 이를 통해 사용자가 선택한 필터에 따라 다른 CSV 파일 제목을 가질 수 있습니다.

전체적으로 사용자들이 데이터에 대해서 csv 파일로 다운로드 받을 수 있도록 데이터를 자동적으로 변환해주는 역할을 진행하고 있었습니다.

### 번외,
번외로 여기서 프론트엔드 코드 분석을 진행하다가 상수(한글/영어 텍스트)들이 한 파일에 모두 정의가 되어있는 구조임을 알게 되었습니다.

이는 _next18Next의 기능이라고 하셔서 이를 조금 더 알아볼 예정입니다.

먼저 상수로 따로 관리되는 파일의 코드 일부는 아래와 같았습니다.

```json
  "main_title": {
    "ranking": "순위",
    "home": "유튜브 순위",
    "superchat_ranking": "슈퍼챗 순위",
    "channel_ranking": "채널 순위",
    "video_ranking": "영상 순위",
  }
```

그리고 이게 본 파일에서 아래와 같이 들어가게 됩니다.

```
    <SvgMainTemplate
      title={t('imyoutuber.trending_videos')}
      subTitle={t('imyoutuber.check_trending_videos')}
      svg={
        <div className={styles.hotVideoIcon}>
          <HotVideoNewSVG />
        </div>
      }
      pathname={'https://www.youtube.com/feed/trending'}
      onClick={() => trackEventFnc('trending_image')}
    >
```
사용자가 영어/한글로 볼 때에 따라서 다르게 실행됩니다. 

그러다가 locale이라는 개념으로 파일 코드에 직접 하드 코딩 된 경우가 있었는데,
이는 상수로 정의해서 관리가 불가능 한 것은 하드 코딩이 들어간 것을 확인했습니다.
이상으로 상수 정의에 대한 번외편을 마무리 하겠습니다.

---

### 메인,
이제 본격적으로 구현에 들어가는 메인 로직 구현입니다.

저는 이제 페이지네이션 코드를 적용하려고 이미 잘 적용된 페이지(영상순위) 페이지 코드를 참고해서 구현해보고자 합니다.


