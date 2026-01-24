# frozen_string_literal: true

class Avo::Resources::ContestWinner < Avo::BaseResource
  self.title = :id
  self.includes = [:submission, :project, :contest]
  
  self.search = {
    query: -> {
      query.where("CAST(id AS TEXT) LIKE ?", "%#{params[:q]}%")
    }
  }

  def fields
    field :id, as: :id, link_to_record: true
    
    # Associations
    field :contest, as: :belongs_to, required: true
    field :submission, as: :belongs_to, required: true
    field :project, as: :belongs_to, required: true
    
    # Timestamps
    field :created_at, as: :date_time, hide_on: [:edit, :new], sortable: true
    field :updated_at, as: :date_time, hide_on: [:edit, :new]
  end
end