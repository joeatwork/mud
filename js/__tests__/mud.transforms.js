import mud from '../src/mud';

const tall = mud.forms.box(1, 3, 1);
const wide = mud.forms.box(3, 1, 1);

describe('mud.transforms', () => {
  describe('untransformed', () => {
    it('tall should look unchanged', () => {
      expect(tall.bounds).toEqual({
        pos: [-2, -3, -2],
        size: [3, 5, 3],
      });

      expect(tall.sample(0, 1, 0)).toBeTruthy();
      expect(tall.sample(0, 0, 1)).toBeFalsy();
      expect(tall.sample(1, 0, 0)).toBeFalsy();
    });
  });

  describe('translate', () => {
    const obj = mud.transforms.translate(tall, 1, 0, 0);
    it('should translate bounds', () => {
      expect(obj.bounds).toEqual({
        pos: [-1, -3, -2],
        size: [3, 5, 3],
      });
    });

    it('should translate samples', () => {
      expect(obj.sample(0, 0, 0)).toBeFalsy();
      expect(obj.sample(1, 0, 0)).toBeTruthy();
    });
  });

  describe('union', () => {
    const obj = mud.transforms.union(tall, wide);
    it('should combine bounds', () => {
      expect(obj.bounds).toEqual({
        pos: [-3, -3, -2],
        size: [5, 5, 3],
      });
    });

    it('should combine samples', () => {
      expect(obj.sample(0, 1, 0)).toBeTruthy();
      expect(obj.sample(1, 0, 0)).toBeTruthy();
      expect(obj.sample(0, 0, 1)).toBeFalsy();
    });
  });

  describe('intersect', () => {
    const obj = mud.transforms.intersect(tall, wide);
    it('should minimize bounds', () => {
      expect(obj.bounds).toEqual({
        pos: [-2, -2, -2],
        size: [3, 3, 3],
      });
    });

    it('should intersect samples', () => {
      expect(obj.sample(0, 1, 0)).toBeFalsy();
      expect(obj.sample(1, 0, 0)).toBeFalsy();
      expect(obj.sample(0, 0, 0)).toBeTruthy();
    });
  });

  describe('subtract', () => {
    const obj = mud.transforms.subtract(tall, wide);
    it('should leave bounds unchanged', () => {
      expect(obj.bounds).toEqual({
        pos: [-2, -3, -2],
        size: [3, 5, 3],
      });
    });

    it('should remove second from first samples', () => {
      expect(obj.sample(0, 1, 0)).toBeTruthy();
      expect(obj.sample(1, 0, 0)).toBeFalsy();
      expect(obj.sample(0, 0, 0)).toBeFalsy();
    });
  });
});
