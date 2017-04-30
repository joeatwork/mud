const {forms} = require('../src/mud'); // TODO import {forms} from 'mud';

describe('mud.forms', () => {
  const unitBox = forms.box(1, 1, 1);

  it('should be centered on the origin', () => {
    expect(unitBox.bounds.pos).toEqual([-1, -1, -1]);
  });

  it("should accomodate the whole box in it's size", () => {
    expect(unitBox.bounds.size).toEqual([2, 2, 2]);
  });

  it('should return true samples for all interior int points', () => {
    expect(unitBox.sample(0, 0, 0)).toBeTruthy();
  });

  it('should return false samples for all boundary int points', () => {
    expect(unitBox.sample(-1, -1, -1)).toBeFalsy();
    expect(unitBox.sample( 1,  1,  1)).toBeFalsy();
    expect(unitBox.sample( 0, -1,  1)).toBeFalsy();
  });
});
