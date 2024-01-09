import styles from './ChannelImage.module.scss';

const ChannelImage = ({ imageUrl }) => {
  return <div className={styles.channelImage} style={{ backgroundImage: `url(${imageUrl})` }} />;
};

export default ChannelImage;
