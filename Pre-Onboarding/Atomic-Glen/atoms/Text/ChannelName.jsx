import styles from './ChannelName.module.scss';

const ChannelName = ({ name }) => {
  return <div className={styles.channelName}>{name}</div>;
};

export default ChannelName;
