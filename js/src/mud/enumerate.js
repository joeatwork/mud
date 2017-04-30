// f(x, y, z) for all integer x, y, z inside of bounds, inclusive
const forEachInBounds = ({pos, size}, opts, f) => {
  if ('undefined' === typeof f) {
    f = opts;
    opts = {plane: false};
  }

  const [basex, basey, basez] = pos.map(Math.ceil);
  const [sizex, sizey, sizez] = size.map(Math.floor);
  const {plane} = opts

  for (let xoff = 0; xoff <= sizex; xoff++) {
    const x = xoff + basex;
    for (let yoff = 0; yoff <= sizey; yoff++) {
      const y = yoff + basey;
      if (opts.plane) {
        f(x, y, 0);
      } else {
        for (let zoff = 0; zoff <= sizez; zoff++) {
          const z = zoff + basez;
          f(x, y, z);
        }
      }
    }
  }
};

// f(x, y, z, sample) for each integer x, y, z inside of bounds
const forEachSample = (form, opts, f) => {
  if ('undefined' === typeof f) {
    f = opts;
    opts = {plane: false};
  }

  forEachInBounds(form.bounds, opts, (x, y, z) => f(x, y, z, s));
};

// An integer resolution memo of a form. Notice you can't
// rotate, skew or scale a memo since it's only defined on integer points.
const memo = (form, opts) => {
  if ('undefined' === opts) {
    opts = {plane: false};
  }

  const {plane} = opts;
  const [basex, basey, basez] = pos;
  const [sizex, sizey, sizez] = size.map(x => x + 1); // size is INCLUSIVE

  const result = new Uint8Array(sizex * sizey * sizez);
  const ystride = sizex;
  const zstride = sizex * sizey;

  forEachSample(form, opts, (x, y, z, s) => {
    const ix = x + (ystride * y) + (zstride * z);
    result[ix] = s | 0;
  });

  return {
    bounds: form.bounds,
    sample: (x, y, z) => {
      const ix = x + (ystride * y) + (zstride * z);
      return result[ix];
    }
  };
};

export default {forEachInBounds, forEachSample, memo};
