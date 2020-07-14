FactoryBot.define do
  factory :lookup_table do
    sequence(:code)     {|n| n}
    sequence(:value)    {|n| "value #{n}"}
    sequence(:translation_spa)    {|n| "translation #{n}"}
  end
end
