import transforms from './transforms';
const {union, translate} = transforms;

export default {
  // replicate unit over points.
  foam: (unit, points) => {
    const bits = points.map(([x, y, z]) => translate(unit, x, y, z));
    return bits.reduce(union);
  },
};
