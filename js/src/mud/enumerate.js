import bounds from './bounds';
const {intBounds} = bounds;

// f(x, y, z) for all integer x, y, z inside of bounds, inclusive
const forEachInBounds = (bounds, opts, f) => {
  if ('undefined' === typeof f) {
    f = opts;
    opts = {plane: false};
  }

  const {pos: [basex, basey, basez], size: [sizex, sizey, sizez]} = intBounds(bounds);
  const {plane} = opts;

  for (let xoff = 0; xoff <= sizex; xoff++) {
    const x = xoff + basex;
    for (let yoff = 0; yoff <= sizey; yoff++) {
      const y = yoff + basey;
      if (plane) {
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

  forEachInBounds(form.bounds, opts, (x, y, z) => {
    const s = form.sample(x, y, z);
    f(x, y, z, s);
  });
};

// An integer resolution memo of a form. Notice you can't
// rotate, skew or scale a memo since it's only defined on integer points.
//
// the buffer on a memo is public, and guaranteed to store a dense
// collection of samples as 1 or 0, where
// buffer[x * xstride + y * ystride + z * zstride]
const memo = (form) => {
  const {pos, size} = form;
  const [basex, basey, basez] = pos;
  const [sizex, sizey, sizez] = size.map(x => x + 1); // size is INCLUSIVE

  const buffer = new Uint8Array(sizex * sizey * sizez);
  const ystride = sizex;
  const zstride = sizex * sizey;

  const ix = (x, y, z) => {
    const xoff = x - basex;
    const yoff = y - basey;
    const zoff = z - basez;
    return xoff + (ystride * yoff) + (zstride * zoff);
  };

  forEachSample(form, {}, (x, y, z, s) => {
    const i = ix(x, y, z);
    buffer[i] = s | 0;
  });

  return {
    buffer: buffer,
    xstride: 1,
    ystride: ystride,
    zstride: zstride,
    bounds: form.bounds,
    sample: (x, y, z) => {
      const i = ix(x, y, z);
      return buffer[i];
    },
  };
};

export default {forEachInBounds, forEachSample, memo};
