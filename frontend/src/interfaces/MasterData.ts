export interface MasterData{
  videos: Video[],
  events: Event[];
}

interface Video{
  url: string;
}

export interface Event{
  title: string;
  url: string;
  place: string;
  address: string;
  started_at: string;
  ended_at: string;
}