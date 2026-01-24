# frozen_string_literal: true

class Avo::Resources::SubmissionVote < Avo::BaseResource
  self.title = :id
  self.includes = [:submission, :user, :contest]
  
  self.search = {
    query: -> {
      query.where("CAST(id AS TEXT) LIKE ?", "%#{params[:q]}%")
    }
  }

  def fields
    field :id, as: :id, link_to_record: true
    
    # Associations
    field :submission, as: :belongs_to, required: true
    field :user, as: :belongs_to, required: true
    field :contest, as: :belongs_to, required: true
    
    # Timestamps
    field :created_at, as: :date_time, hide_on: [:edit, :new], sortable: true
    field :updated_at, as: :date_time, hide_on: [:edit, :new]
  end
  
  # Info banner about voting limit
  def description
    "Each user can vote up to #{SubmissionVote::USER_VOTES_PER_CONTEST} times per contest"
  end
end