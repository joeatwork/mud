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
    const rotX = rotation.get(0);
    const rotY = rotation.get(1);

    const updateX = evt => onUpdate(rotation.set(0, evt.target.value));
    const updateY = evt => onUpdate(rotation.set(1, evt.target.value));

    return (
        <div>
          <label>Rotate X <input type="range" value={rotX} onChange={updateX} /></label>
          <label>Rotate Y <input type="range" value={rotY} onChange={updateY} /></label>
        </div>
    );
});
