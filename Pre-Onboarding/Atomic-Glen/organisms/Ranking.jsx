import ChannelImage from '../atoms/Image/ChannelImage';
import ChannelName from '../atoms/Text/ChannelName';
import ChannelPrice from '../atoms/Text/ChannelPrice';
import styles from './Ranking.module.scss';

const Ranking = ({ rank, name, revenue, imageUrl }) => {
  return (
    <div className={styles.rankingRow}>
      <div className={styles.rank}>{rank}</div>
      <ChannelImage imageUrl={imageUrl} />
      <ChannelName name={name} />
      <ChannelPrice revenue={revenue} />
    </div>
  );
};

export default Ranking;
