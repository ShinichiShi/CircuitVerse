# frozen_string_literal: true

class Avo::Actions::ScheduleContest < Avo::BaseAction
  self.name = "Schedule Contest"
  self.message = "This will schedule/reschedule the contest"
  
  # Only show for live or upcoming contests
  self.visible = -> do
    # On index page, resource.record is nil, so show the action
    return true if resource.nil? || resource.record.nil?
    
    # On show/edit pages, only show for live or upcoming
    ["live", "upcoming"].include?(resource.record.status)
  end

  def handle(query:, fields:, current_user:, resource:, **args)
    query.each do |contest|
      ContestScheduler.call(contest)
    end

    succeed "Contest(s) scheduled successfully!"
  end
end