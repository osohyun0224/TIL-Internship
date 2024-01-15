//생략

const ESNames = Object.freeze({
  Index: `youtube_trends_stat`,
});

export default class YoutubeTrends extends Singleton {
  constructor(config) {
//생략
  }

  adjustPayload(obj) {
  //생략
  }

  async getIndexIdGroups(prefixId, startDate, endDate) {
//생략
  }

  async getTrendsData(indexIdGroups, page, pageSize) {
    let allVideos = [];
  
    for (const index of Object.keys(indexIdGroups)) {
//생략
      }
    }
  
    // 모든 비디오를 viewCount로 정렬
    allVideos.sort((a, b) => b.viewCount - a.viewCount);
  
    // 페이지네이션 적용
    const startIndex = (page - 1) * pageSize;
    const paginatedVideos = allVideos.slice(startIndex, startIndex + pageSize);
  
    return { videos: paginatedVideos, page, pageSize, total: allVideos.length };
  }
  

  async Runner(gl, section, section_sub, date, hour, page = 1, pageSize = 20) {
//생략
  
      let dslQuery = {
        index: `${this.ESNames.Index}_${date.split("-")[0]}`,
        type: "_doc",
        body: {
          query: {
            match: {
              _id: id,
            },
          },
          from: from,  // 페이지네이션을 위한 시작 위치를 나타내는 시작문. 근데 page-1을 해야하는데 왜 null오류가 뜰까..........
          size: size   // 페이지당 불러오는 데이터의 수를 정의하였당
        },
      };

//생략

      if (result.body.hits.hits[0]) {
        let videos = result.body.hits.hits[0]._source.videos;
  
        // 조회수에 따라 비디오 배열 정렬
        videos.sort((a, b) => b.viewCount - a.viewCount);
  
        // 페이지네이션 적용
        const startIndex = (page - 1) * pageSize;
        const paginatedVideos = videos.slice(startIndex, startIndex + pageSize);
  
        // 정렬된 비디오와 페이지 정보로 구성된 새로운 payload 생성
        let payload = {
          ...result.body.hits.hits[0]._source,
          videos: paginatedVideos,
          page: page,
          pageSize: pageSize
        };
  
        return this.adjustPayload(payload);
      }
    }
    
//생략

    // trendsData에 page와 pageSize 정보를 추가해서 응답값 확인해보려고 했는데 안뜸
    let response = this.adjustPayload(trendsData);
    response.page = page;
    response.pageSize = pageSize;
    
    //console.log(response);

    // response 객체가 올바른 구조를 가지고 있는지 확인하려고 했는데 안뜸
    if (!response.page || !response.pageSize) {
    console.error("Missing page or pageSize in response");
  }
  
    return response;
