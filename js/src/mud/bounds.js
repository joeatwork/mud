export default {
  intBounds: ({pos, size}) => {
    return {
      pos: pos.map(Math.ceil),
      size: size.map(Math.floor),
    };
  },
};
