
import React from 'react';
import ReactDom from 'react-dom';

import forms from './mud/forms';
import mesh from './mud/mesh';

import Visualizer from './ui/visualizer';

const {sphere} = forms;
const {marchingCubes} = mesh;

const radius = 10.0;
const form = sphere(radius);
const triangles = marchingCubes(form);

document.addEventListener('DOMContentLoaded', () => {
    const canvas = document.getElementById('visualizer_root');
    const visualizer = new Visualizer(radius, canvas);
    visualizer.update(triangles);

    window.requestAnimationFrame(_timestamp => {
        visualizer.animate();
    });

    const Root = () => {
        return <h1>IS THIS THING ON?</h1>;
    };

    ReactDom.render(<Root />, document.getElementById('app_root'));
});
