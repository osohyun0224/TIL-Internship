# Today I Learned, 2024.01.17 (WED)

## Intro.

어제까지는 index.js 파일 코드를 열심히 뜯어보았기에 오늘은 각각의 샘플링 클래스에서 어떤 작업을 하고 있는지 알아보았습니다.

## To do list

- [ ] 각각의 샘플링 클래스 코드 파악하고 역할 정의해보기
- [ ] 데이터베이스 쪽 모르는 거 파악하고 공부하기
- [ ] 엘라스틱 서치 기본 구조 공ㅂ하기
- [ ] yaml파일 job에서 workflow로 수정하기


## Main

### [1] 각각의 샘플링 클래스 분석하기

- 데이터 샘플링은 결국 데이터 표본을 추출하는 기법이기 때문에 저희 devsampling 폴더 내에서 샘플링을 담당하는 클래스들이 대표적으로 각각 어떤 역할을 하는지 알아보겠습니다.

```javascript
if (!this.options.skipChInfo) {
      //01. getTotalCount
      const totalCount = await new ChannelTotalCount(Config.get(), ESSrcChannelInfo).run();
      const sampleCount = Math.ceil((sampleRatio / 100) * totalCount);
      logger.info(chalk.blueBright(`Total Channels: ${util.formatNumber(totalCount)}, Sampling Channels will be: ${util.formatNumber(sampleCount)}`));

      //02. sample channels
      await new SampleChannelInfo(Config.get(), ESSrcChannelInfo, ESDstChannelInfo).run(sampleCount, targetDate);
      const sampledCount = await new ChannelTotalCount(Config.get(), ESDstChannelInfo).run();
      logger.info(chalk.blueBright(`Sampled Channels: ${util.formatNumber(sampledCount)}`));
    }

    if (!this.options.skipChStat) {
      //03. sample channelStats
      await new SampleChannelStat({
        ...Config.get(),
        statBeforeDays: ChannelStatBeforeDays,
      }, ESDstChannelInfo, ESSrcChannelStat, ESDstChannelStat).run(targetDate);
    }

    if (!this.options.skipVdInfo) {
      //03. sample videoInfo
      await new SampleVideoInfo({
        ...Config.get(),
      }, ESDstChannelInfo, ESSrcVideoInfo, ESDstVideoInfo).run(targetDate);
    }

    if (!this.options.skipVdStat) {
      //04. sample videoStat
      await new SampleVideoStat({
        ...Config.get(),
        statBeforeDays: VideoStatBeforeDays,
      }, ESDstVideoInfo, ESSrcVideoStat, ESDstVideoStat).run(targetDate);
    }

    if (!this.options.skipChSubslevels){
      //04. sample subslevels
      await new SampleChannelSubsLevels({
        ...Config.get(),
      }, ESSrcChannelSubsLevels, ESDstChannelSubsLevels).run(targetDate);
    }

    if (!this.options.skipSnapshot) {
      await new Snapshot(Config.get()).run();
    }
  }
}
```

현재 index.js에서 샘플링을 담당하는 클래스들을 호출하려 실행시키는 부분의 코드입니다.  <br/>
저는 각각의 클래스들이 어떤 데이터를 샘플링 하는지 조사하기로 했습니다. <br/>
다만, 여기서 샘플링 기법에 대해서는 깊게 다루지 않기로 했습니다 (고거는 ,,,,)

1. SampleChannelInfo 클래스 : 유튜브 채널 정보를 샘플링합니다. <br/>
2. SampleChannelStat 클래스 : 유튜브 채널 통계를 샘플링합니다. <br/>
3. SampleVideoInfo 클래스 : 유튜브 비디오 정보를 샘플링합니다. <br/>
4. SampleChannelSubsLevels 클래스 : 유튜브 채널 구독자 수준 데이터를 샘플링합니다. <br/>
5. SampleVideoStat 클래스 : 유튜브 비디오 통계 데이터를 샘플링합니다. 특히 여기서는  DataPaginationController를 사용해 대량의 데이터를 효율적으로 처리합니다. 각 페이지에서 videoId를 기준으로 필터링하여 해당 기간의 비디오 통계 데이터를 추출합니다.
6. Snapshot 클래스 : 데이터 백업을 담당하고 있습니다.
7. SampleBase 클래스 : 엘라스틱서치와 관련된 다양한 기본 작업을 수행하는 베이스 클래스로 , <br/> 이 클래스는 다른 샘플링 클래스들의 공통적인 작업을 수행하기 위한 기본 기능을 제공합니다.


### [1.5] 이때가 아니면 기회가 없을 것 같은 데이터베이스 공부
지속해서 데이터베이스의 개념이 출제됨으로 이를 가지고 공부를 진행해 보았습니다.

---
#### (1) 데이터베이스 인덱스에 대해서,,,
이 정리글은 우아한테크코스 10분 테코톡(라라,제로) 영상을 보고 개념을 정리한 글입니다.

**Intro.**

이 강의의 학습 대상을 정의해주셨습니다

- 기본적인 데이터베이스 문법을 학습한 개발자
- 인덱스를 데이터베이스에 적용하려는 개발자

**Main.**

**[1] 인덱스란?**

- 사전적 정의는 색인입니다. **색인**은 쉽게 찾아볼 수 있도록 일정한 순서에 따라 놓은 목록입니다.
- 이를 데이터베이스에 적용한다면 어떻게 볼 수 있을까요?
    - 바로, 원하는 값을 빠르게 찾는다는 의미로 볼 수 있습니다
    - SELECT, INSERT, UPDATE, DELETE에서 **SELECT가 되겠네요!**

**[2] 데이터베이스 인덱스란?**

- 현재 100만 건 이상 데이터에서 인덱스 기준이 하나도 잡혀 있지 않을 때, 이메일이 1111@gmail.com인 회원을 조회한다고 해보자. 이때 전체 데이터에서 순차적으로 확인하기에 매우 느릴 것입니다.
    - 왜냐? 현재 데이터는 기준이 없이 저장된 상태이기 때문에 속도가 느릴 것이기 대문입니다.
- 이를 대비해서, **데이터가 특정 기준으로 정렬되어있다면 검색을 빠르게 할 수 있을 것** 입니다.

⬇️

- 이제 인덱스를 이메일로 정했을 경우에 위의 100만건 이상의 데이터가 이메일로 정렬되어있을 것입니다. 이상태에서 특정 이메일인 회원을 조회하면 매우 빠르게 찾을 수 있을 것입니다!

위의 예시를 쿼리로 한 번 나타내보겠습니다.

```jsx
SELECT * FROM member
WHERE email = 'abc123@gmail.com'
```

이 쿼리에서 **1) 인덱스가 적용된 대상을(email로 정렬된 데이터), 2) WHERE 절을 통해 검색한다.**

하지만 아래의 경우에서 살펴보면,

```jsx
SELECT * FROM member
```

이 쿼리에서는 **1) WHERE 절을 통해 검색하지 않고, 2) 인덱스가 사용되지 않았습니다.**

최종적으로 데이터베이스의 인덱스란? **데이터베이스 테이블에 대한 검색 성능을 향상시키는 자료구조이며 WHERE 절 등을 통해 활용됩니다.**

- **인덱스의 특징은?**
    - 1) 인덱스는 항상 최신의 정렬 상태를 유지합니다.
    - 2) 인덱스도 하나의 데이터베이스 객체를 생성합니다.
    - 3) 데이터베이스 크기의 약 10% 정도의 저장공간을 필요로 합니다.
     
**[3] 인덱스의 종류**
데이터베이스에서 클러스터링이란 무엇일까요?

### 1. 클러스터링

- 클러스터란? 무리, 군집, 무리를 이루다
- 실제 데이터와 무리를 이룸
- 클러스터링 인덱스: 실제 데이터와 같은 무리의 인덱스 == 실제 데이터가 정렬된 사전

### 2. 논-클러스터링 인덱스(보조 인덱스, 세컨더리 인덱스)

- 실제 데이터와 무리를 이루지 않음
- 실제 데이터와 다른 무리의 별도의 인덱스 == 실제 데이터 탐색에 도우을 주는 별도의 찾아보기 페이지

코드로 한번 살펴보겠습니다.

```jsx
CREATE TABLE member (
	id   int         primary key, --> 클러스터링 인덱스
	name varchar(255),
  email varchar(255) unique ---> 논-클러스터링 인덱스
}
```

우리는 primary key를 생성하면 자동적으로 클러스터링 인덱스를 사용하고 있는 것이었고, 여기서 unique 에서는 논-클러스터링 인덱스를 사용하고 있는 것이었습니다.

**[4] 클러스터링 인덱스**

```jsx
CREATE TABLE member (
	id      int         
	name    varchar(255)
  email   varchar(255)
}
```

![image](https://github.com/osohyun0224/TIL-Internship/assets/53892427/5abd5567-4930-4b0e-8bd9-b1489b35d0ad)


위와 같이 아무런 제약조건을 걸지 않으면 인덱스가 생성되지 않습니다. (제약조건 X == 인덱스 X)

여기에 순차적으로 데이터를 넣으면 아래처럼 들어가게 됩니다.

![image](https://github.com/osohyun0224/TIL-Internship/assets/53892427/c6604223-7c60-493c-8916-a242bcda88a8)


이렇게 들어가있는 상태에서 id 컬럼에 클러스터링 인덱스를 적용해보겠습니다.

**[5] 인덱스 사용시 주의사항**

1. 잘 활용되지 않는 인덱스는 과가히 제거하자
- WHERE 절에 사용되더라도 자주 사용해야 가치가 있다.
- 불필요한 인덱스로 성능저하가 발생할 수 있다.

2. 데이터 중복도가 높은 컬럼은 인덱스 효과가 적다

3.. 자주 사용되더라도 INSERT / UPDATE / DELETE 가 자주 일어나는 지 고려해야한다.
- 일반적인 웹 서비스와 같은 온라인 트랜잭션 환경에서 쓰기와 읽기 비율은 2:8 도는 1:9이다.
- 조금 느린 쓰기를 감수하고 빠른 읽기를 선택하는 것도 하나의 방법이다.

---
이때가 아니면 데이터베이스 공부를 하지 못할 것 같아서 더 해보기로 했습니다.

우리가 사용하고있는 NoSQL을 MySQL과 비교하여 공부를 진행해 보았습니다…

#### (2) SQL과 NoSQL 차이란?

https://youtu.be/cnPRFqukzek?si=NZ8f7gn-UIVDXI6d

## [1] 쿼리 언어란?

- DBMS에서 DB를 다루기 위해 사용되는 언어입니다.
- DB: 데이터베이스는 여러 사람이 공유하여 사용할 목적으로 체계화해 통합, 관리하는 데이터의 집합입니다.
- DBMS: 다수의 사용자들이 데이터베이스 내의 데이터 접근 할 수 있도록 해주는 소프트웨어 도구의 집합.

![image](https://github.com/osohyun0224/TIL-Internship/assets/53892427/8d3a5628-cc73-42ce-947f-971dd7a093b7)

- DBMS는 사용자 또는 다른 프로그램의 요구를 처리하고 적절히 응답하여 데이터를 사용할 수 있도록 함.

## [2] 쿼리 언어의 특징?

- 비절차적 언어입니다. 원하는 결과에 대한 내용(what)만 명세하고 결과를 얻는 내부의 방식에 대한 내용(how)는 없습니다.

## [3] SQL이란?

- RDBMS에서 사용되는 표준 질의 언어입니다.

![image](https://github.com/osohyun0224/TIL-Internship/assets/53892427/4bd2de12-068e-467f-9d7d-142933f3d166)

- 얜 또 뭘까? RDBMS는 관계형 데이터 베이스 관리 시스템을 의미합니다.

## [4] RDBMS의 특징?

1. 정해진 스키마에 따라서 테이블이 구성됩니다.
    1. 스키마: 데이터베이스에서 사용되는 전체 데이터 구조를 정의하는 객체
    2. 테이블: 데이터를 구성하는 가장 기본적인 단위로, 데이터를 행과 열로 구성된 표 형태로 저장
        1. 열(column): 흔히 속성과 필드라고도 불리는데 특정 유형의 데이터를 저장하기 위한 속성을 가집니다. (이름, 유형, 크기 등등)
        2. 행(row): 흔히 튜플, 레코드라고도 불리는데 테이블의 한 행을 의미합니다.
    3. 제약조건
        - NOT NULL : 해당 속성에 값에 null이 들어갈 수 없다.
        - UNIQUE : 해당 속성의 값들이 모두 고유하다.(중복되지 않는 값이다.)
        - DEFAULT
        - PRIMARY KEY
        - FOREIGN KEY
2. 테이블끼리 관계를 가진다.
    - 1:1 관계
    - 1:N 관계
    - N:M 관계(다대다 관계)
      ![image](https://github.com/osohyun0224/TIL-Internship/assets/53892427/4e32f770-182b-4d04-8401-301dfc4b48cc)


## [5] NoSQL?

### 1. 등장 배경

- 데이터의 폭발적인 증가로 단일 서버에 모든 뎅터를 넣을 수 없어졌습니다. 이는 서버의 확장이 불가피해졌다는 것을 알 수 있습니다.
- 서버의 확장은 2가지가 있습니다.

![image](https://github.com/osohyun0224/TIL-Internship/assets/53892427/f782603a-b737-4feb-a4e3-14f452b9cca4)

- 기존의 RDBMS 확장의 한계?
    - 수직적 확장은 가격이 비싸고, 사양을 무한하게 높일 수도 없습니다.
    - 수평적 확장은 기술적으로 어렵고, 한계도 존재합니다.

이러한 한계를 극복하기 위해 등장하였다!

### 2. 특징?

- 유연한 데이터 모델을 가진다.
- RDBMS와는 달리 고정된 스키마가 없다.

- 유연한 데이터 모델?
    - 데이터를 유연하게 추가, 삭제, 수정 데이터 모델의 변화에 대한 대응이 용이하다.
    - 관계형 데이터 베이스와 달리 어플리케이션 단에서 데이터를 구조에 맞게 매핑할 노력이 필요가 없다.
    - 다양한 데이터 모델이 존재

- 저렴한 비용
    - NoSQL 데이터베이스는 오픈소스 제품들이 많아서 비교적 저렴하고 무료로 사용할 수 있는 제품이 많다.
    - 데이터 가용성을 보장하기 위해 노드를 추가할 수 있어서 하드웨어 비용도 상대적으로 낮다.

- 분산 시스템
    - 데이터를 여러대의 컴퓨터 노드에 분산하여 저장하고 처리하는 시스템이다.
    - 새로운 노드를 추가하는데 용이하다.
      ![image](https://github.com/osohyun0224/TIL-Internship/assets/53892427/0cc48048-157c-4dd2-b16f-ffe3548e6f65
    - 노드 중 하나가 다운되어도 시스템 전체가 중단되지 않도록 하여 시스템의 가용성을 높입니다.
    - 각 노드는 일부 데이터만 처리하고 여러 노드가 병렬처리가 가능하여 빠른 처리가 가능하다.

- 분산 시스템 설계 원칙[CAP]
- 일관성(Consistency):

모든 클라이언트가 같은 시간에 같은 데이터를 볼 수 있다.

- 가용성(Availablity):

노드 중 하나 이상의 노드가 실패하더라도 정상적으로 요청을 처리할 수 있는 기능을 제공한다.

- 장애 내성(Partition tolerance):

장애: 분산 시스템에서 노드 간 통신이 일시적으로 불가능해지는 상황

네트워크 장애 또는 서버 다운과 같은 분할 상황이 발생하더라도 시스템 전체가 작동해야한다.

- 기본적인 가용성
    - 데이터베이스가 일부 노드에서 실패하더라도 적절한 레플리케이션과 분산 시스템을 사용하여 전체적인 시스템의 가용성을 유지한다.
    - 일부 노드에서 데이터베이스 서비스가 중단되어도 다른 노드에서는 계속하여 서비스를 제공한다.
