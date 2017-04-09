# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  event_id    :string(255)      not null
#  type        :string(255)      not null
#  keyword     :string(255)      not null
#  title       :string(255)      not null
#  url         :string(255)      not null
#  description :string(255)      not null
#  started_at  :datetime         not null
#  ended_at    :datetime         not null
#  limit       :integer          default(0), not null
#  address     :string(255)      not null
#  place       :string(255)      not null
#  lat         :float(24)
#  lon         :float(24)
#  owner_id    :string(255)      not null
#  owner_name  :string(255)
#
# Indexes
#
#  index_events_on_event_id_and_type        (event_id,type) UNIQUE
#  index_events_on_keyword                  (keyword)
#  index_events_on_started_at_and_ended_at  (started_at,ended_at)
#

class Event < ApplicationRecord
end
