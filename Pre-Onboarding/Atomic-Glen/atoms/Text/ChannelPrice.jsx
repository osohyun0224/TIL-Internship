import styles from './ChannelPrice.module.scss';

const ChannelPrice = ({ revenue }) => {
  return <div className={styles.channelPrice}>{revenue}</div>;
};

export default ChannelPrice;
