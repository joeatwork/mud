// A form has
//
//   - a SAMPLE function that, given (x, y, z) numbers returns true or false. Sample
//         should be idempotent and well defined within or including the bounding box
//         of the form.
//
//   - a BOUNDING BOX, {pos, size} such that all samples outside of or on the boundary
//         of the bounding box will be false
//       - pos is an integer position [x, y, z]
//       - size is a non-negative integer offset from position, [dx, dy, dz]
//
// NOTE - sample should successfully return false if given pos or pos + size
//
export default {
  box: (width, height, depth) => {
    const halfW = width / 2.0;
    const halfH = height / 2.0;
    const halfD = depth / 2.0;

    return {
      bounds: {
        pos: [-(halfW + 1), -(halfH + 1), -(halfD + 1)].map(Math.floor),
        size: [width + 2, height + 2, depth + 2].map(Math.ceil),
      },
      sample: (x, y, z) => {
        if (x < -halfW || y < -halfH || z < -halfD) {
          return false;
        }

        if (x > halfW || y > halfH || z > halfD) {
          return false;
        }

        return true;
      },
    };
  },

  sphere: (radius) => {
    const lowbound = -(radius + 1);
    const highbound = (radius * 2) + 2;
    const squared = radius * radius;
    return {
      bounds: {
        pos: [lowbound, lowbound, lowbound].map(Math.floor),
        size: [highbound, highbound, highbound].map(Math.ceil),
      },
      sample: (x, y, z) => {
        const hypSquared = (x * x) + (y * y) + (z * z);
        return squared >= hypSquared;
      },
    };
  },
};
