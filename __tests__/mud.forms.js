import mud from '../src/mud';

const unitBox = mud.forms.box(1, 1, 1);
const unitSphere = mud.forms.sphere(0.5);

describe('mud.forms', () => {
  [['box', unitBox], ['sphere', unitSphere]].forEach(([test, obj]) => {
    describe(test, () => {
      it('should be centered on the origin', () => {
        expect(obj.bounds.pos).toEqual([-2, -2, -2]);
      });

      it("should accomodate the whole box in it's size", () => {
        expect(obj.bounds.size).toEqual([3, 3, 3]);
      });

      it('should return false samples for all boundary int points', () => {
        expect(obj.sample(-1, -1, -1)).toBeFalsy();
        expect(obj.sample( 1,  1,  1)).toBeFalsy();
        expect(obj.sample( 0, -1,  1)).toBeFalsy();
      });

      it('should return true samples for interior int points', () => {
        expect(obj.sample(0, 0, 0)).toBeTruthy();
      });
    });
  });
});
