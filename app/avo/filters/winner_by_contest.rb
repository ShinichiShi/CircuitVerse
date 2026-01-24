class Avo::Filters::WinnerByContest < Avo::Filters::SelectFilter
  self.name = "Contest"

  def apply(request, query, value)
    query.where(contest_id: value)
  end

  def options
    Contest.all.pluck(:name, :id).to_h
  end
end