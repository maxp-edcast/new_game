%w{
  deps core_ext base input
  cost card player
}.each do |file|
  require_relative "./lib/#{file}.rb"
end


class Game < Base
  self.attributes = {
    players: [],
    winner: nil,
    is_over: true,
    turn_num: 0,
    current_player_idx: nil,
    special_rules: {}
  }

  # √
  def current_player
    players[current_player_idx]
  end

  # √
  def start
    self.is_over = false
    return unless players.length > 1
    players.each(&:shuffle_deck)
    self.current_player_idx = determine_first_player_idx
    self.players = [current_player, *(players-current_player)]
    players
      .each(&:draw_initial_cards)
      .each(&:mulligan)
    take_first_turn
    self.current_player_idx += 1
    start_game_loop
  end

  # Ø
  def take_first_turn
    case get_first_turn_option
    when :play_first
      take_turn(current_player, skip_draw: true)
    when :draw_first
      current_player.draw
    end
  end

  # Ø
  def start_game_loop
    until is_over
      players.each &method(:take_turn)
    end
  end

  # for more detail:
  # https://pokeinthe.io/files/Magic%20the%20Gathering%20Turn%20Structure.pdf
  def take_turn(player, skip_draw: false)
    beginning_phase(skip_draw: skip_draw)
    precombat_main_phase
    combat_phase
    postcombat_main_phase
    ending_phase
  end

  # √
  def determine_first_player_idx
    counts = players.map.with_index do |player, idx|
      [idx, player.deck[-1].cost.converted]
    end
    if counts.map(&:second).uniq.length == 1
      players.decks.each(&:shuffle)
      determine_first_player_idx
    else
      counts.max_by(&:second).first
    end
  end

  # Ø - needs scoping to current player
  def get_first_turn_option
    get_input( "Do you want to play or draw first?",
      play_first: "play",
      draw_first: "draw"
    )
  end

  def trigger_abilities
  end

  def check_instants_and_abilities
  end

  def check_spells_and_lands
  end

  def check_blockers
  end

  def assign_damage_to_blockers
    # an action taken by current_player
  end

  def assign_damage_to_attackers
    # an action taken by attacked player
  end

  def check_attackers
    false # return bool, are there any attackers
  end

  def beginning_phase(skip_draw: false)
    untap_step
    upkeep_step
    draw_step
  end

  def untap_step
    apply_phasing
    current_player.untap_all_permanents
    players.each &:empty_unused_mana
  end

  def upkeep_step
    trigger_abilities :untap_step, :beginning_of_upkeep_step
    check_instants_and_abilities
    players.each &:empty_unused_mana
  end

  def draw_step
    current_player.draw
    trigger_abilities :beginning_of_draw_step
    check_instants_and_abilities
    players.each &:empty_unused_mana
  end

  def precombat_main_phase
    trigger_abilities :beginning_of_main_phase
    check_spells_and_lands
    players.each &:empty_unused_mana
  end

  def combat_phase
    beginning_of_combat_step
    attackers = declare_attackers_step
    unless attackers == :none
      declare_blockers_step
      combat_damage_step
    end
    end_combat_step
  end

  def beginning_of_combat_step
    trigger_abilities :beginning_of_combat
    check_spells_and_lands
    players.each &:empty_unused_mana
  end

  def declare_attackers_step
    has_attackers = check_attackers
    return :none unless has_attackers
    trigger_abilities :attackers_declared
    check_abilities_and_instants
    players.each &:empty_unused_mana
  end

  def declare_blockers_step
    check_blockers
    assign_damage_to_blockers
    assign_damage_to_attackers
    trigger_abilities :blockers_declared
    check_abilities_and_instants
    # must do this twice, in case abilities change the attackers/blockers
    assign_damage_to_blockers
    assign_damage_to_attackers
    players.each &:empty_unused_mana
  end

  def combat_damage_step
    apply_first_strike
  end

  def end_combat_step
  end

  def postcombat_main_phase
  end

  def ending_phase
    end_step
    end
  end

  def apply_phasing
  end

end


