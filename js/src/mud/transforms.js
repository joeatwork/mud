
const vecZip => (v1, v2, f) => {
  return v1.map((_, i) => f(v1[i], v2[i]));
};

const vecPlus => (v1, v2) => {
  return vecZip(v1, v2, (a, b) => a + b);
};

const boundsUnion = (b1, b2) => {
  const top1 = vecPlus(b1.pos, b1.size);
  const top2 = vecPlus(b2.pos, b2.size);

  const maxTop = vecZip(top1, top2, (a, b) => Math.max(a, b));
  const minPos = vecZip(b1.pos, b2.pos, (a, b) => Math.min(a, b));

  return {
    pos: minPos,
    size: vecZip(maxTop, minPos, (t, p) => t - p),
  };
};

const boundsIntersection = (b1, b2) => {
  const top1 = vecPlus(b1.pos, b1.size);
  const top2 = vecPlus(b2.pos, b2.size);

  const minTops = vecZip(top1, top2, (a, b) => Math.min(a, b));
  const maxPos = vecZip(b1.pos, b2.pos, (a, b) => Math.max(a, b));

  return {
    pos: maxPos,
    size: vecZip(minTops, maxPos, (t, p) => t - p),
  };
};

// We don't guarantee that forms won't throw exceptions
// or act goofily outside of their bounds, so this isn't
// just an optimization.
const boundedSample = (form) {
  const {bounds, sample} = form;

  const [minX, minY, minZ] = bounds.pos;
  const [maxX, maxY, maxZ] = vecPlus(bounds.pos, bounds.size);

  return (x, y, z) => {
    if (x < minX || y < minY || z < minZ) {
      return false;
    }

    if (x > maxX || y > maxY || z > maxZ) {
      return false;
    }

    return sample(x, y, z);
  };
}

export default {
  translate: (form, x, y, z) => {
    const {sample, bounds} = form
    const {pos, size} = bounds
    const vec = [x, y, z];
    return {
      bounds: {
        pos: vecPlus(pos, vec),
        size: size,
      },
      sample: (x, y, z) => sample(x - ox, y - oy, z - ox),
    }
  },

  union: (form1, form2) => {
    const [s1, s2] = [form1.sample, form2.sample];
    return {
      bounds: boundsUnion(form1.bounds, form2.bounds),
      sample: (x, y, z) => s1(x, y, z) || s2(x, y, z),
    }
  },

  intersect: (form1, form2) => {
    const [s1, s2] = [form1.sample, form2.sample];
    return {
      bounds: boundsIntersection(form1.bounds, form2.bounds),
      sample: (x, y, z) => s1(x, y, z) && s2(x, y, z),
    }
  }

  subtract: (form1, form2) => {
    const s1 = form1.sample;
    const s2 = boundedSample(form2);

    return {
      bounds: form1.bounds,
      sample: (x, y, z) => s1(x, y, z) && !s2(x, y, z),
    }
  }
}
