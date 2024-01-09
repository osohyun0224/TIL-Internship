import Ranking from './organisms/Ranking';
import styles from './RankingComponent.module.scss';

const RankingComponent = ({ title, rankings }) => {
  return (
    <div className={styles.container}>
      <h2 className={styles.title}>{title}</h2>
      <hr className={styles.divider} />
      {rankings.map(({ rank, name, revenue }) => (
        <Ranking key={rank} rank={rank} name={name} revenue={revenue} imageUrl="이미지URL" />
      ))}
      <hr className={styles.divider} />
      <p className={styles.moretext}>더보기</p>
    </div>
  );
};

export default RankingComponent;
