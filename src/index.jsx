
import React from 'react';
import ReactDom from 'react-dom';
import Immutable from 'immutable';

import forms from './mud/forms';
import mesh from './mud/mesh';

import Visualizer from './ui/visualizer';
import Rotator from './ui/components/rotator';

import {Provider} from 'react-redux';
import {createStore} from 'redux';
import {reducer} from './ui/state';

const {sphere} = forms;
const {marchingCubes} = mesh;

const store = createStore(reducer);
const radius = 10.0;
const form = sphere(radius);
const triangles = marchingCubes(form);

document.addEventListener('DOMContentLoaded', () => {
    const canvas = document.getElementById('visualizer_root');
    const visualizer = new Visualizer(radius, canvas);
    visualizer.setSubject(triangles);

    let vState = undefined;
    store.subscribe(() => {
        const newState = store.getState().visualizer;
        if (Immutable.is(vState, newState)) {
            return; // Do nothing, nothing has changed.
        }

        vState = newState;
        const rot = vState.get('rotation');
        visualizer.setRotation(rot.get(0), rot.get(1));
    });

    const animate = _timestamp => {
        visualizer.animate();
        window.requestAnimationFrame(animate);
    };
    window.requestAnimationFrame(animate);

    const Root = () => {
        return (
            <Provider store={store}>
              <Rotator />
            </Provider>
        );
    };

    ReactDom.render(<Root />, document.getElementById('app_root'));
});
