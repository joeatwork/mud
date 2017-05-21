import {fromJS, Map} from 'immutable';
import {combineReducers} from 'redux';

export const reducer = combineReducers({
  // State is Immutable.Map
  visualizer: (state, action) => {
    if (undefined === state) {
      state = fromJS({
        rotation: [0, 0],
      });
    }

    switch(action.type) {
    case 'UPDATE_ROTATION':
      return state.set('rotation', action.payload);
    default:
      return state;
    }
  },
});
