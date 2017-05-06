// returns [f(v1[0], v2[0]), f(v1[1], v2[1])...]
const vecZip = (v1, v2, f) => {
  if ('undefined' === typeof f) {
    f = (x1, x2) => [x1, x2];
  }
  return v1.map((_, i) => f(v1[i], v2[i]));
};

// returns [v1[0] + v2[0], v1[1] + v2[1], ...]
const vecPlus = (v1, v2) => {
  return vecZip(v1, v2, (a, b) => a + b);
};

// returns [v1[0] + v2[0], v1[1] + v2[1], ...]
const vecMinus = (v1, v2) => {
  return vecZip(v1, v2, (a, b) => a - b);
};

export default {vecZip, vecPlus, vecMinus};
