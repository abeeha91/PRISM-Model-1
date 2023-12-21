pta

// Constants
const int SLOTS_PER_EPOCH = 32;
const int SLOT_DURATION = 12;
const int FAR_FUTURE_EPOCH = 10000;
const int MAX_EFFECTIVE_BALANCE = 1000;
const int ACTIVATION_DELAY = 4; // Number of epochs to activate after deposit
const int EXIT_DELAY = 4; // Number of epochs to exit after request
const int REWARD = 1; // Reward for attesting or proposing
const int PENALTY = -1; // Penalty for missing or slashing

// Variables
global slot_counter: [0..(SLOTS_PER_EPOCH - 1)] init 0; // Initializing the slot counter
global current_slot: [0..(SLOTS_PER_EPOCH - 1)] init 0; // Initializing the current slot
//clock t; // Global clock variable

// States representing validator life cycle
module validator_life_cycle

    state: [0..5] init 0;  // States: 0 - Initial, 1 - Deposit, 2 - Pending, 3 - Active, 4 - Slashing/Withdrawal, 5 - Finished
    slot: [0..(SLOTS_PER_EPOCH - 1)]; // Slot number assigned to the validator
    activation_eligibility_epoch: [0..FAR_FUTURE_EPOCH]; // Epoch number when the validator becomes eligible for activation
    effective_balance: [0..MAX_EFFECTIVE_BALANCE]; // Balance of the validator
    t:clock;
    validator_misbehaves_condition:bool;
    // Validator deposits funds
    [] state = 0 -> 0.5: (state' = 1) & (activation_eligibility_epoch' = FAR_FUTURE_EPOCH) & (effective_balance' = MAX_EFFECTIVE_BALANCE); // Move to Deposit state

    // Validator checks for activation eligibility and waits
    [] state = 1 & slot_counter = current_slot & mod(floor(t/(SLOT_DURATION*SLOTS_PER_EPOCH)), ACTIVATION_DELAY) = 0 ->
       0.5: (state' = 2) & (slot' = current_slot); // Move to Pending state, use the current slot

    // Validator transitions to Active after waiting for a certain time
    [] state = 2 & slot_counter = current_slot &
       mod(floor(t/(SLOT_DURATION*SLOTS_PER_EPOCH)), ACTIVATION_DELAY) = 0 ->
        0.5: (state' = 3); // Move to Active state when waiting time is over

    // Validator actively participates and might get slashed
    /// Validator actively participates and might get slashed
    [] state = 3 & (slot_counter != current_slot) ->
        (state' = 4) ;
       

    // Validator moves to Withdrawal after completing Active or Slashing stage
    [] state = 3 | state = 4 ->
        0.5: (state' = 5); // Move to Withdrawal state

    // Validator finishes the life cycle
    [] state = 5 ->
        (state' = 5); // Stay in Finished state

endmodule
