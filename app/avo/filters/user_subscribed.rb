class Avo::Filters::UserSubscribed < Avo::Filters::BooleanFilter
  self.name = "Subscription"

  def apply(request, query, value)
    return query if value.blank?

    if value["subscribed"]
      query.where(subscribed: true)
    elsif value["unsubscribed"]
      query.where(subscribed: false)
    else
      query
    end
  end

  def options
    {
      subscribed: "Subscribed",
      unsubscribed: "Unsubscribed"
    }
  end
end