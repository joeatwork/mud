import {
  AmbientLight,
  DirectionalLight,
  Face3,
  FlatShading,
  Geometry,
  Mesh,
  MeshPhongMaterial,
  PerspectiveCamera,
  Scene,
  Vector3,
  WebGLRenderer,
} from 'three';

export default class {
  constructor(radius, canvas) {
    const camera = new PerspectiveCamera(
      75, canvas.width/canvas.height, 0.1, 1000
    );
    camera.position.z = radius * 2;

    const renderer = new WebGLRenderer({canvas});
    renderer.setSize(canvas.width, canvas.height);

    this.camera = camera;
    this.renderer = renderer;
  }

  setSubject(triangles) {
    const scene = new Scene();
    scene.add(new AmbientLight(0x444444));
    scene.add(new DirectionalLight());

    const geometry = new Geometry();
    triangles.forEach(t => {
      t.forEach(v => {
        geometry.vertices.push(new Vector3(...v));
      });

      // No normal - is that ok?
      let length = geometry.vertices.length;
      geometry.faces.push(new Face3(length - 3, length - 2, length - 1));
    });
    var material = new MeshPhongMaterial( { color: 0xffffff, shading: FlatShading, overdraw: 0.5, shininess: 0 } );
    var mesh = new Mesh(geometry, material);
    scene.add(mesh);

    this.mesh = mesh;
    this.scene = scene;
  }

  setRotation(xRot, yRot) {
    this.mesh.rotation.x = xRot;
    this.mesh.rotation.y = yRot;
  }

  animate() {
    const {renderer, scene, camera} = this;

    renderer.render(scene, camera);
  }
}
