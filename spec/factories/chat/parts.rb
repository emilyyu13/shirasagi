FactoryBot.define do
  factory :chat_part_bot, class: Chat::Part::Bot, traits: [:cms_part] do
    route { "chat/bot" }
    chat_path { unique_id }
  end
end
