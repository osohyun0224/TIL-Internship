import YoutubeTrends from "./YoutubeTrends";

export const resolvers = {
  Query: {
    getTrendsVideosInfo: async (_, args, context, info) => {
//생략
      return await new YoutubeTrends(Config.get()).Runner(
        args.gl,
        args.section,
        args.section_sub,
        args.date,
        args.hour,
        args.page,      // 추가
        args.pageSize,  // 추가
        GqlFunction.getSelections(info)
      );
    },
  },
};