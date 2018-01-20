class Game

  class Player < Base
    self.attributes = {
      game: nil,
      name: '',
      life: 20,
      hand: [],
      deck: [],
      playfield: {},
      graveyard: [],
      exile: [],
      poison_counters: []
    }

    def untap_all_permanents
    end

    def empty_unused_mana
    end

    # √
    def draw_initial_cards
      draw 7
    end

    # √
    def shuffle_deck
      deck.shuffle
    end

    # √
    def draw(num=1)
      hand.concat deck.shift num
    end

    # √
    def reset_deck
      cards = [hand, playfield, graveyard, exile, deck].flat_map(&:shift_all)
      # Unowned cards must have been removed previously
      raise unless cards.all? &method(:owns_card?)
      deck.concat cards
      shuffle_deck
    end

    # √
    def owns_card?(card)
      card.owner_name == name
    end

    # √
    def mulligan
      return unless can_mulligan?
      choice = get_input( "Want to mulligan?",
        yes: "yes",
        no: "no"
      )
      case choice
      when :yes
        deck.concat hand
      when :no
        return
      end
    end

    # √
    def loses?
      return :lost_by_life if life <= 0
      return :lost_by_poison if poison_counters >= 10
      return :lost_by_mill if deck.count <= 0
      false
    end

    # √
    def can_mulligan?
      player.hand.length > 0
    end

  end
end