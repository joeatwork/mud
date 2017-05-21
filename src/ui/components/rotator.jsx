import React from 'react';
import {connect} from 'react-redux';

export default connect(
    ({visualizer}) => { // mapStateToProps
        return {
            rotation: visualizer.get('rotation'),
        };
    },
    (dispatch) => { // mapDispatchToProps
        const onUpdate = (rot) => {
            dispatch({
                type: 'UPDATE_ROTATION',
                payload: rot,
            });
        };
        return {onUpdate};
    }
)(({rotation, onUpdate}) => {
    const maxResolution = 100;
    const slideX = rotation.get(0) * (maxResolution / (Math.PI * 2));
    const slideY = rotation.get(1) * (maxResolution / (Math.PI * 2));

    const change = (ix, evt) => {
        const v = parseInt(evt.target.value, 10);
        const radians = v * ((Math.PI * 2) / maxResolution);
        onUpdate(rotation.set(ix, radians));
    };

    const updateX = evt => change(0, evt);
    const updateY = evt => change(1, evt);

    return (
        <div>
          <div>
            <label>
              Rotate X
              <input type="range" min="0"
                     max={maxResolution} value={slideX} onChange={updateX} />
            </label>
          </div>
          <div>
            <label>
              Rotate Y
              <input type="range" min="0"
                     max={maxResolution} value={slideY} onChange={updateY} />
            </label>
          </div>
        </div>
    );
});
