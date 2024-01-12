# Today I Learned, 

## Topic, Docker - Dan

# 01 기능 구현 목록

part 01 도커에 관하여

1. docker ( nodejs로 만든 apiserver를 docker file을 통해 build하여 container로 띄우기 )
    - [x]  node로 아주 간단한 apiserver 만들기
        - endpoint: /message
        - 위의 endpoint로 body에 string을 담은 요청을 보내면 message.txt라는 파일에 string이 저장 될 수 있도록 할것
    - [x]  docker file 작성 ( From node:16-alpine 할것 )
    - [x]  docker image build
    - [x]  docker container 생성
    - [x]  local에서 container의 apiserver에 요청 보내기 및 결과 확인
    

---

Part 02 쿠버네티스에 관하여 

1. 
k8s ( docker hub에 올라가 있는 image를 사용하여 yaml파일 작성을 통해 k8s에 pod 배포하기 )
    - [x]  1번 실습에서 만든 node server image → docker hub에 올리기 ( docker logIn 필요 )
    - [x]  docker hub에 올린 image를 기반으로 한 pod yaml파일을 작성
    - [x]  namespace: sandbox에 각자의 영어이름으로 된 pod 배포
    - [x]  pod와 port forwarding을 통해 api test ( 위의 3가지 다하면 나한테 슬랙 )

3.

- [ ]  도커 허브에 올라가있는 이미지를 통해서 namespace가 샌드박스에다가 deployment를 만든다.
- [ ]  해당 띄워진 deployment에다가 서비스를 붙인다.
- [ ]  서비스 dns가 무엇인지 조사한다.

# 03 Task Report

### 1번 과제 도커

저는 기능 구현 목록에 따라 테스크 과제를 진행하였습니다.

[1] node.js로 간단한 api 서버를 구현하였습니다.

```jsx
const express = require('express');
const fs = require('fs');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

app.use(bodyParser.text());

app.post('/message', (req, res) => {
    fs.writeFile('message.txt', req.body, (err) => {
        if (err) {
            res.status(500).send('에러 발생');
        } else {
            res.send('Message saved');
        }
    });
});

app.listen(port, () => {
    console.log(`server http://localhost:${port}`);
});
```

[2] 도커 파일 작성

```jsx
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

[3] 도커 이미지 빌드하기

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/9694d96b-9127-4373-af9f-0678f5066575/Untitled.png)

[4] 도커 컨테이너 생성

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/3b421729-794e-4b2e-95f3-e7d4af27bab7/Untitled.png)

[5] local에서 container의 apiserver에 요청 보내기 및 결과 확인

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/1fa1f1d6-2a04-4b79-b2ca-bd6c0610f66e/Untitled.png)

---

### 2번과제 쿠버네티스

[1] 서버 이미지를 도커에 올리기

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/7a1690c5-9748-4663-ae8a-79c3c70c2d80/Untitled.png)

[2] Yaml 파일 생성

/Users/sohyunoh/dan-assign/garden-pod.yaml

```jsx
#!/bin/ash
apiVersion: v1
kind: Pod
metadata:
  name: garden-pod
  namespace: sandbox
spec:
  containers:
  - name: node-api-server
    image: gardenoh/node-api-server:latest
    ports:
    - containerPort: 3000
```

[3] 쿠버네티스 클러스터 pod배포

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/83793c20-7b3b-4ff2-8956-a8887b2011d4/Untitled.png)

[3-1] 번외) 에러 대응

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/5f5d2886-5456-4a8c-89fe-2b0c1456c126/Untitled.png)

제가 생성한 garden-pod가 실행 상태가 되지 않아 이를 해결하기 위해 노력하였고

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/6dcb98ec-ebd3-4e28-8e70-7cf72b841691/Untitled.png)

로그 명령어로 확인해보니까 로컬의 운영체제와 쿠버네티스의 운영체제가 달라서 buildx 로 해결하면 좋을 것 같다는 에러 대응 메세지를 확인하였고, 이를 시도하였습니다.

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/6db32fb8-d065-444a-a531-cb5adf9f2e56/Untitled.png)

다시 빌드 하였습니다.

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/9b9ac9c9-78e6-4bc5-9528-cba311f03624/Untitled.png)

기존 yaml을 삭제하고 다시 적용시켜주니 성공하였습니다.

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/bbdda7cb-82df-4cf7-a2d9-8982268d899d/Untitled.png)

에러를 해결하였습니다ㅠㅠ

[4] api  테스트

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/8ddde90a-30ce-41b6-999e-ae66a8915012/Untitled.png)

응답확인

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/9dc6b260-b69d-4ebf-847c-a40991873bb2/09a43693-d021-4f88-8b4c-53da61df29ba/Untitled.png)

