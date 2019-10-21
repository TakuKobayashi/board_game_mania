import React from 'react';
import Iframe from 'react-iframe'
import axios from 'axios';

import lodash from 'lodash';
import { MasterData, Event } from './interfaces/MasterData';

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
import "react-loader-spinner/dist/loader/css/react-spinner-loader.css"

const Loader = require('react-loader-spinner')

interface RenderMasterData{
  video_url: string,
  events: Event[],
}

class App extends React.Component<{},RenderMasterData> {
  constructor(props: any){
    super(props)

    this.state = {
      video_url: "",
      events: [],
    }
    this.loadMstData();
  }

  private async loadMstData(): Promise<MasterData>{
    const masterDataReponse = await axios.get<MasterData>("/master_data.json");
    const masterData = masterDataReponse.data;
    const randVideo = lodash.sample(masterData.videos)
    if(randVideo){
      this.setState({
        video_url: randVideo.url,
      })
    }
    const randEvents = lodash.sampleSize(masterData.events)
    this.setState({
      events: randEvents,
    })
    return masterData;
  }

  private renderEventField(event: Event):
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
      <div className="squarebox eventbox">
        <div className="eventbox_info">
          <div className="event_title"><a href={event.url}>{event.title}</a></div>
          <div className="event_place"><i className="fa fa-map-marker"></i>&nbsp;{event.place}{event.address}</div>
          <div className="event_date"><i className="fa fa-calendar-o"></i>&nbsp;{event.started_at} 〜 {event.ended_at}</div>
        </div>
      </div>
    )
  }

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
    const eventFields = this.state.events.map(event => this.renderEventField(event));
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
            <Iframe width="640" height="360" url={this.state.video_url} />
          </div>
          <div className="middlesubbox">
            <div className="squarebox"><div className="titlebox3">&nbsp;</div><img className="text03" src={text03} alt="Text03" /></div>
            <div className="squarebox"><img className="squareimg-side icon05" src={icon05} alt="Icon05" /></div>
          </div>
        </div>
        <div className="colbox">
          {eventFields}
        </div>
      </div>
    );
  }
}

export default App;
