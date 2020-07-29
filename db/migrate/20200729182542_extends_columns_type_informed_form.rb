class ExtendsColumnsTypeInformedForm < ActiveRecord::Migration[6.0]
  def up
    add_column :events, :state, :integer, null: false, default: 0
    add_column :events, :informed_from, :integer, null: false, default: 0
    Event.where(type: 'Atnd').update_all(informed_from: Event.informed_froms[:atnd])
    Event.where(type: 'Connpass').update_all(informed_from: Event.informed_froms[:connpass])
    Event.where(type: 'Doorkeeper').update_all(informed_from: Event.informed_froms[:doorkeeper])
    Event.where(type: 'Peatix').update_all(informed_from: Event.informed_froms[:peatix])
    Event.where(type: 'Meetup').update_all(informed_from: Event.informed_froms[:meetup])
  end

  def down
    Event.atnd.update_all(type: 'Atnd')
    Event.connpass.update_all(type: 'Connpass')
    Event.doorkeeper.update_all(type: 'Doorkeeper')
    Event.peatix.update_all(type: 'Peatix')
    Event.meetup.update_all(type: 'Meetup')
    remove_column :events, :informed_from
    remove_column :events, :state
  end
end
