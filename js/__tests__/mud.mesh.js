import mud from '../src/mud';

const orb = mud.forms.sphere(2);

const flatten = lis => lis.reduce((a, b) => a.concat(b), []);

describe('mud.meshes', () => {
  describe('marchingCubes', () => {
    const triangles = mud.mesh.marchingCubes(orb);

    it('should produce triangles from a form', () => {
      expect(triangles.length).toBeGreaterThan(0);
    });

    it('should be triangles', () => {
      triangles.forEach(t => {
        expect(t.length).toBe(3);
      });
    });

    it('should be triangles of points', () => {
      flatten(triangles).forEach(pt => {
        expect(pt.length).toBe(3);
      });
    });

    it('should be triangles of pts of numbers', () => {
      flatten(flatten(triangles)).forEach(x => {
        expect(typeof x).toBe('number');
      });
    });
  });
});
