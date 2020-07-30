import * as React from 'react'
import { Link } from 'gatsby'

import Page from '../components/Page'
import Container from '../components/Container'
import IndexLayout from '../layouts'

import icon01 from '../images/icon01.png';
import icon03 from '../images/icon03.png';
import icon04 from '../images/icon04.png';
import icon05 from '../images/icon05.png';
import icon06 from '../images/icon06.png';
import text01 from '../images/text01.png';
import text02 from '../images/text02.png';
import text03 from '../images/text03.png';

import "../stylesheets/normalize.css"
import "../stylesheets/main.css"
import "../stylesheets/font-awesome.min.css"

const IndexPage = () => (
  <IndexLayout>
    <Page>
      <Container>
        <h1>Hi people</h1>
        <p>Welcome to your new Gatsby site.</p>
        <p>Now go build something great.</p>
        <Link to="/page-2/">Go to page 2</Link>
      </Container>
    </Page>
  </IndexLayout>
  <div class="mainbox">
    <div class="colbox">
      <div class="squarebox"><%= image_tag("icon04.png", class: "squareimg icon04", alt: "Icon04") %></div>
      <div class="squarebox"><%= image_tag("text01.png", class: "text01", alt: "Text01") %><div class="titlebox1">&nbsp;</div></div>
      <div class="squarebox"><%= image_tag("icon01.png", class: "squareimg icon01", alt: "Icon01") %></div>
      <div class="squarebox"><%= image_tag("icon06.png", class: "squareimg icon06", alt: "Icon06") %></div>
    </div>
    <div class="middlebox">
      <div class="middlesubbox">
        <div class="squarebox"><%= image_tag("icon03.png", class: "squareimg icon03", alt: "Icon03") %></div>
        <div class="squarebox"><%= image_tag("text02.png", class: "text02", alt: "Text02") %><div class="titlebox2">&nbsp;</div></div>
      </div>
      <div class="videobox">
        <iframe width="640" height="360" src="<%= @video.embed_url %>" frameborder="0"></iframe>
      </div>
      <div class="middlesubbox">
        <div class="squarebox"><div class="titlebox3">&nbsp;</div><%= image_tag("text03.png", class: "text03", alt: "Text03") %></div>
        <div class="squarebox"><%= image_tag("icon05.png", class: "squareimg-side icon05", alt: "Icon05") %></div>
      </div>
    </div>
    <div class="colbox">
        <div class="squarebox eventbox">
          <div class="eventbox_info">
            <div class="event_title"><a href="event.url.to_s">event.title</a></div>
            <div class="event_place"><i class="fa fa-map-marker"></i>&nbsp;<%= event.place %><%= event.address %></div>
            <div class="event_date"><i class="fa fa-calendar-o"></i>&nbsp;<%= event.started_at.strftime("%Y/%m/%d(#{%w(日 月 火 水 木 金 土)[event.started_at.wday]})%H:%M") %> 〜 <%=
              if event.ended_at.blank?
                ""
              elsif event.ended_at.day == event.started_at.day
                event.ended_at.strftime("%H:%M")
              else
                event.ended_at.strftime("%Y/%m/%d(#{%w(日 月 火 水 木 金 土)[event.started_at.wday]})%H:%M")
              end
            %></div>
          </div>
        </div>
    </div>
  </div>
)

export default IndexPage
