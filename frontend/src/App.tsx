import React from 'react';
import Iframe from 'react-iframe'
import icon01 from './images/icon01.png';
import icon03 from './images/icon03.png';
import icon04 from './images/icon04.png';
import icon05 from './images/icon05.png';
import icon06 from './images/icon06.png';
import text01 from './images/text01.png';
import text02 from './images/text02.png';
import text03 from './images/text03.png';

import "./stylesheets/normalize.css"
import "./stylesheets/main.css"
import "./stylesheets/font-awesome.min.css"

class App extends React.Component {
  render():
    | React.ReactElement<any, string | React.JSXElementConstructor<any>>
    | string
    | number
    | {}
    | React.ReactNodeArray
    | React.ReactPortal
    | boolean
    | null
    | undefined {
    return (
      <div className="mainbox">
        <div className="colbox">
          <div className="squarebox"><img className="squareimg icon04" src={icon04} alt="Icon04" /></div>
          <div className="squarebox"><img className="text01" src={text01} alt="Text01" />
            <div className="titlebox1">&nbsp;</div>
          </div>
          <div className="squarebox"><img className="squareimg icon01" src={icon01} alt="Icon01" /></div>
          <div className="squarebox"><img className="squareimg icon06" src={icon06} alt="Icon06" /></div>
        </div>
        <div className="middlebox">
          <div className="middlesubbox">
            <div className="squarebox"><img className="squareimg icon03" src={icon03} alt="Icon03" /></div>
            <div className="squarebox"><img className="Text02" src={text02} alt="Text02" />
              <div className="titlebox2">&nbsp;</div>
            </div>
          </div>
          <div className="videobox">
            <Iframe width="640" height="360" url="http://www.youtube.com/embed/xDMP3i36naA" />
          </div>
          <div className="middlesubbox">
            <div className="squarebox"><div className="titlebox3">&nbsp;</div><img className="text03" src={text03} alt="Text03" /></div>
            <div className="squarebox"><img className="squareimg-side icon05" src={icon05} alt="Icon05" /></div>
          </div>
        </div>
        <div className="colbox">
        </div>
      </div>
    );
  }
}

export default App;
