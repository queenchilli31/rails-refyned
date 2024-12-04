class Lesson < ApplicationRecord
  belongs_to :curriculum
  has_many :cards, dependent: :destroy

  validates :title, :description, presence: true

  def next_lesson
    curriculum.lessons.find_by(order: order + 1)
  end

  def status
    completed = cards.pluck(:correct)

    if completed.all?(&:nil?)
      "pending"
    elsif completed.any?(&:nil?)
      "started"
    else
      "completed"
    end
  end

  # find the first card in the lesson where the
  # correct key is nil. This would represent the
  # "next" card.
  # if card is passed as an argument, return the
  # next card from that provided card

  def next_card(card = nil)
    incomplete_cards = cards.where(correct: nil).order(:id)

    if card.nil?
      incomplete_cards.first
    else
      index = incomplete_cards.find_index(card)
      index.nil? ? incomplete_cards.first : incomplete_cards[index + 1]
    end
  end

  def complete?
    cards.pluck(:correct).count(nil).zero?
  end

  def complete!
    self.status = "completed"
    save
  end

  def verify_complete
    complete! if complete?
  end

  def score
    cards.where(correct: true).length.to_f / cards.length
  end

  def progress
    cards.reject { |card| card.correct.nil? }.length.to_f / cards.length
  end
end
